unit module Commands::ChatCommand;

use Lain::CommandRegistry;
use Helpers::Connector::LMS;
use Helpers::Logger;

register-command('chat', -> @args {
    my $lms_connector = Helpers::Connector::LMS::LMSConnector.new();
    $lms_connector.max-tokens = 75;

    # Define the system message
    my $system_message = "Your name is Lain. You are an AI. You are here to help me. Answer the questions like in an irc chatroom. Answer short and precise. Prefix your answers with 'lain>'. Include previous conversation history when answering.";

    # Initialize chat log as an empty string
    my $chat-log = '';

    say "lain: I'm ready for our chat! Type '/exit' to end it.";

    while my $question = prompt("You> ") {
        chomp($question);
        # exit if the user types /exit
        last if $question eq '/exit';

        # Append current question to chat log
        $chat-log ~= "You> {$question}\n";

        await answer($lms_connector, $system_message, $question, $chat-log);
        dd $chat-log;
    }
});

sub answer(
    Helpers::Connector::LMS::LMSConnector $lms_connector,
    Str $system-message,
    Str $question,
    Str $chat-log is rw
) {
    # Define a closure to handle partial content
    my $on-content = sub ($partial-content) {
        print $partial-content;  # Print to console

        # Append Lain's answer to chat log
        $chat-log ~= "{$partial-content}";
    };

    # Create and return a promise
    start {
        try {
#            $chat-log ~= "Lain> ";

            await $lms_connector.send(
                system-message => $system-message,
                user-message   => "Previous conversation:\n{$chat-log}Current question: {$question}",
                on-content     => $on-content
            );
#            $chat-log ~= "\n";

        }
        CATCH {
            default {
                say "Error during LLM Response: $_";
            }
        }
    };
}

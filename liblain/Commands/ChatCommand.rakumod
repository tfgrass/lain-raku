unit module Commands::ChatCommand;

use Lain::CommandRegistry;
use Helpers::Connector::LMS;
use Helpers::Logger;

register-command('chat', -> @args {
    my $lms_connector = Helpers::Connector::LMS::LMSConnector.new();
    $lms_connector.max-tokens = 512;

    # Define the system message
    my $system_message = "Your name is Lain. You are an AI. You are here to help me. Answer the questions like in an irc chatroom. Answer short and precise. Prefix your answers with 'lain>'.";

    # Initialize chat log as an empty string
    my $chat-log = '';

    say 'Joining chatroom. Type /exit to leave.';

    while my $question = prompt("\nYou> ") {
        chomp($question);
        # exit if the user types /exit
        last if $question eq '/exit';

        # Append current question to chat log
        $chat-log ~= "User> {$question}\n";

        # Await the answer and ensure it completes before proceeding
        await answer($lms_connector, $system_message, $question, $chat-log);
        log(5, $chat-log);
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

    my $on-error = sub ($error) {
        log(0, "Error during LLM Response: $error");
    };

    # Create and return a promise
    start {
        try {

            await $lms_connector.send(
                system-message => $system-message ~ "\nPrevious conversation:\n{$chat-log}\n",
                user-message   => "{$question}",
                on-content     => $on-content,
                on-error       => $on-error
            );

        }
        CATCH {
            default {
                log(0, "Error during LLM Response: $_");
            }
        }
    };
}

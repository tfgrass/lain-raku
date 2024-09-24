unit module Commands::AskCommand;

use Lain::CommandRegistry;
use Helpers::Connector::LMS;
use Helpers::Logger;

register-command('ask', -> @args {
    my $question = @args[0] // '';
    
    # exit if no question is provided
    unless $question {
        say "lain is in the chatroom. Ask a question.";
        say "Usage: lain ask <question> ";
        exit 1;
    }


    my $lms_connector = Helpers::Connector::LMS::LMSConnector.new(
#        model-name => "lmstudio-community/Codestral-22B-v0.1-GGUF/Codestral-22B-v0.1-Q4_K_M.gguf"
    );

    $lms_connector.max-tokens = 75;
    # Start an asynchronous block
    my $promise = start {
        answer($lms_connector, $question);
    }

    # Wait for the documentation generation to complete
    await $promise;
});
sub answer(
    Helpers::Connector::LMS::LMSConnector $lms_connector,
    Str $question,
) {
    # Define a closure to handle partial content
    my $on-content = sub ($partial-content) {
        print $partial-content;  # Print to console
    };

    # Define the system message
    my $system_message = "Your name is Lain. You are an AI. You are here to help me. Answer the questions like in an irc chatroom. Answer short and precise. Prefix your answers with 'lain>'.";

    # Start an asynchronous block
    my $promise = start {
        try {
            await $lms_connector.send(
                system-message => $system_message,
                user-message   => $question,
                on-content     => $on-content
            );
        }
        CATCH {
            default {
                say "Error during LLM Response: $_";
            }
        }
        say "\nConnection closed.";
    }

    # Wait for the promise to complete
    await $promise;
}
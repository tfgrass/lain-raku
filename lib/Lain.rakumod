unit module Lain;


# Function to handle CLI commands
our sub run-cli(@args) {

    my $command = @args[0] // 'help';
    # Load all commands from system and user directories
    Lain::CommandLoader::load-commands();

    # Find the registered command and execute it
    my &handler = Lain::CommandRegistry::get-command($command);
    if &handler {
        &handler(@args);  # Pass the @args to the command handler
    } else {
        say "Unknown command: $command";
        say "Available commands: {Lain::CommandRegistry::list-commands.join(', ')}";
    }
}

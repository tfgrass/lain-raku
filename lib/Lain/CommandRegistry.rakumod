unit module Lain::CommandRegistry;

my %commands;  # Hash to store command names and associated subroutines

# Function to register a new command
sub register-command(Str $name, &handler) is export {
    %commands{$name} = &handler;
}

# Function to get a command by name
sub get-command(Str $name) is export {
    return %commands{$name}:exists ?? %commands{$name} !! Nil;
}

# Function to list all registered commands
sub list-commands() is export {
    return %commands.keys;
}

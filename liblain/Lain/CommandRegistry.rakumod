unit module Lain::CommandRegistry;

my %commands;  # Hash to store command names and associated subroutines

# Function to register a new command
our sub register-command(Str $name, &handler) is export {
    %commands{$name} = &handler;
}

# Function to get a command by name
our sub get-command(Str $name) is export {
    return %commands{$name}:exists ?? %commands{$name} !! Nil;
}

# Function to list all registered commands
our sub list-commands() is export {
    return %commands.keys;
}

our sub load-commands() is export {
    # Load system commands from lib/Lain/Commands
    my $system-path = 'lib/Lain/Commands';
    load-modules-from($system-path);

    # Load user commands from ~/.lain/modules
    my $user-path = "$*HOME/.lain/modules";
    load-modules-from($user-path);
}

sub load-modules-from(Str $path) {
    if $path.IO.d {
        for dir($path) -> $file {
            next unless $file.extension eq 'rakumod';
            say "Loading module from file: {$file.Str}";
            require "file#{$file.Str}";
        }
    }
}

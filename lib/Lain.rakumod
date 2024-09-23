unit module Lain;

# Function to handle CLI commands
sub run-cli(@args) is export {
    my $command = @args[0] // 'help';

    given $command {
        when 'doc' {
            say "Generating documentation for { @args[1] // 'file' }...";
            # Call your LM Studio API here
        }
        when 'help' {
            say "Usage: lain <command> [arguments]";
            say "Commands:";
            say "  doc    Generate documentation";
            say "  help   Show this message";
        }
        default {
            say "Unknown command: $command";
        }
    }
}

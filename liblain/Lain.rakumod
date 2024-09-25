unit module Lain;

use Lain::CommandRegistry;


our sub run-cli(@args) is export {
    Lain::CommandRegistry::load-commands();

    my $command = @args.shift // 'help';

    if $command eq 'version' {
        say "Lain v0.1.1a 09/2024 by tfgrass \n";

        say "- somebody said, 'Done is better than perfect.'";
    } elsif $command eq 'help' {
        say "Usage: lain <command> [arguments]";
        say "Commands:";
        say "  version";
        say "  help";
        for list-commands() -> $cmd {
            say "  $cmd";
        }
        
    } elsif my $command-sub = get-command($command) {
        $command-sub(@args);
    } else {
        say "Unknown command: $command";
    }
}


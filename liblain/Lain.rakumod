unit module Lain;

use Lain::CommandRegistry;
use Lain::CommandLoader;


our sub run-cli(@args) is export {
    Lain::CommandLoader::load-commands();

    my $command = @args.shift // 'help';

    if my $command-sub = get-command($command) {
        $command-sub(@args);
    } elsif $command eq 'version' {
        say "Lain v0.1.0 09/2024 by tfgrass \n";

        say "- somebody said, 'Done is better than perfect.'";
    } else {
        say "Unknown command: $command";
    }
}


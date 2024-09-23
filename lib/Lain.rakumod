unit module Lain;

use Lain::CommandRegistry;
use Lain::CommandLoader;

our sub run-cli(@args) is export {
    Lain::CommandLoader::load-commands();

    my $command = @args.shift // 'help';

    if my $command-sub = get-command($command) {
        $command-sub(@args);
    } else {
        say "Unknown command: $command";
    }
}

register-command('help', -> @args {
    say "Usage: lain <command> [arguments]";
    say "Commands:";
    for list-commands() -> $cmd {
        say "  $cmd";
    }
});

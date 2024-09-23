unit module Lain::CommandLoader;

use Lain::CommandRegistry;

sub load-commands() is export {
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
            require $file.Str;  # Dynamically require the module
        }
    }
}

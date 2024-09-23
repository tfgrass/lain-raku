unit module Lain::Commands::DocCommand;

use Lain::CommandRegistry;

# Register the 'doc' command
register-command('doc', -> @args {
    my $file = @args[1] // 'default-file';
    say "Generating documentation for $file...";
});

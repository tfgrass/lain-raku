# lib/Helpers/Logger.rakumod
unit module Helpers::Logger;

my $instance;

class Logger {
    has Int $.log-level is rw;

    method new {
        # Prevent multiple instantiation
        return $instance if $instance.defined;
        $instance = self.bless(:log-level(3));  # Default log level
        return $instance;
    }

    method log(Int $level, Str $message) {
        if $level <= $.log-level {
            say "[LOG-$level] $message";
        }
    }
}

sub logger is export {
    return Logger.new;  # Always return the Singleton instance
}

unit module Helpers::Logger;

my $instance;         

# Logger Singleton class
class Logger {
    has Int $.log-level is rw = 0;

    method new {
        # Ensure singleton
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

# Return the singleton instance of Logger
sub logger is export {
    return Logger.new;
}

# Global log function that simplifies logging
sub log(Int $level, Str $message) is export {
    logger().log($level, $message);
}

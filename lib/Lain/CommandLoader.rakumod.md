
# Lain::CommandLoader Documentation

This document provides detailed documentation for the `Lain::CommandLoader` Perl6 module, which is responsible for loading system and user commands in a Lain application. The module exports a single subroutine, `load-commands`, which handles this task. It first loads system commands from the 'lib/Lain/Commands' directory and then loads user commands from their respective directory located at '~/.lain/modules'.

## Subroutines

### load-commands()

The main subroutine exported by `Lain::CommandLoader` module. It is responsible for loading system and user commands into the application. This is accomplished by calling the `load-modules-from` subroutine with the appropriate paths for both system and user commands.

#### Usage

```perl6
use Lain::CommandLoader;
load-commands();
```

### load-modules-from($path)

This subroutine is used to load modules (commands) from a specified path. It checks if the provided path exists and is a directory, and then iterates over all files in that directory. For each file with an extension of 'rakumod', it prints out a message indicating which module is being loaded and then requires that module using Perl6's `require` statement.

#### Parameters
- `$path`: A string representing the path from where to load modules.

#### Usage
```perl6
load-modules-from('path/to/directory');
```
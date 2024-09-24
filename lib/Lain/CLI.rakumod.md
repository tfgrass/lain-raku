# Lain::CLI Documentation

The `Lain::CLI` module contains a single subroutine, `normalize-args`, which is designed to standardize the input arguments for command line interfaces. This can be beneficial when the name of the program or script may vary depending on how it's invoked. The function checks if the first argument matches the current program's name, and if so, removes it from the list of arguments.

## Subroutine: normalize-args(@args)

This subroutine takes an array of command line arguments as input (`@args`) and returns a normalized version of that array. If the first argument matches the current program's name, it is removed from the output list. The function is exported, meaning it can be used in other modules or scripts with the appropriate `use` statement.

### Usage:
```perl6
use Lain::CLI;
my @normalized-args = normalize-args(@*ARGS);
```

### Parameters:
- `@args` (Array of Str): The array of command line arguments to be normalized.

### Returns:
- Array of Str: A new array containing the normalized command line arguments. If the first argument matched the current program's name, it will not appear in this array.

### Example:
```perl6
say normalize-args('my-program', 'arg1', 'arg2');  # Outputs: ('arg1', 'arg2')
```

### Variables:
- `$program-name` (Str): The name of the current program. This is determined by checking the `$*PROGRAM`, `$*PROGRAM-NAME`, and `$*EXECUTABLE` variables, in that order. If none of these are defined, an empty string will be used as a fallback.
- `@normalized-args` (Array of Str): The normalized array of command line arguments. This is initially set to the input argument list, but may be modified if the first argument matches the current program's name.
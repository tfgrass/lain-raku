## Documentation for the code file

This code file sets up a command line interface (CLI) application using various modules. The main components of this script include importing necessary libraries, setting the log level for logging messages, and running the CLI with provided arguments.

The script begins by adding the 'lib' directory to the module search path and importing several custom modules such as `Lain`, `Lain::CommandLoader`, `Lain::CommandRegistry`, `Commands::DocCommand`, `Lain::CLI`, and `Helpers::Logger`.

A logger is then initialized and configured with a log level of 3. This means that any logging messages at a severity level equal to or less than 3 will be printed, while higher levels will be ignored. Two example logs are included in the script, one at level 1 (which will be printed) and another at level 4 (which will not be printed).

The `normalize-args` function is then called with the command line arguments provided to the script (`@*ARGS`) and the result is stored in an array `@args`.

Finally, the `Lain::run-cli` function is called with `@args` as its argument, which starts the CLI application with the given input.

### Details:

- `use lib 'lib';` - adds the 'lib' directory to the module search path so that custom modules can be imported.
- `use Lain;`, `use Lain::CommandLoader;`, `use Lain::CommandRegistry;`, `use Commands::DocCommand;`, `use Lain::CLI;`, and `use Helpers::Logger;` - import the necessary modules for the CLI application.
- `logger().log-level = 3;` - sets the log level to 3, which determines which logging messages are printed.
- `log(1, "This is a low-level log.");` and `log(4, "This is a high-level log.");` - example logs at different severity levels. The first one will be printed if the log level is set to 3 or lower, while the second one will not be printed in this case.
- `my @args = normalize-args(@*ARGS);` - calls the `normalize-args` function with the command line arguments provided to the script (`@*ARGS`) and stores the result in an array `@args`.
- `Lain::run-cli(@args);` - starts the CLI application with the given input.
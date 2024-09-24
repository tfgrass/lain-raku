# Lain Documentation

## Overview
This script initializes the Lain module, sets up a logger with a specified log level, and logs some messages. It then normalizes command line arguments and runs the Lain CLI.

## Dependencies
- `Lain`: The main Entry-Module for the application.
- `Lain::CommandLoader` and `Lain::CommandRegistry`: Modules for loading and managing commands.
- `Commands::DocCommand`: A specific command module.
- `Lain::CLI`: Module for running the Command Line Interface.
- `Helpers::Logger`: Module for logging messages with a specified level of importance.

## Usage
The script is expected to be run from the command line, with optional arguments. These arguments are normalized and then passed to the Lain CLI for processing.

## Code Breakdown

### Imports and Library Additions
- `use lib 'lib';`: This line adds the `lib` directory to the module search path. This allows Perl 6 to find and use modules that are stored in this directory.
- The rest of the `use` statements import various modules into the script, which provide functionality for command loading, logging, and running the CLI.

### Logger Configuration
- `logger().log-level = 3;`: This line sets the log level of the logger to 3. Messages with a log level higher than this will not be printed.

### Logging Messages
- `log(1, "This is a low-level log.");`: This line logs a message with a log level of 1. Since the log level is set to 3, this message will be printed.
- `log(4, "This is a high-level log.");`: This line logs a message with a log level of 4. Since the log level is set to 3, this message will not be printed.

### Command Line Argument Processing
- `my @args = normalize-args(@*ARGS);`: This line takes the command line arguments passed to the script (`@*ARGS`) and normalizes them into a format that can be used by the Lain CLI. The normalized arguments are stored in the `@args` array.

### Running the Lain CLI
- `Lain::run-cli(@args);`: This line calls the `run-cli` function from the `Lain` module, passing it the normalized command line arguments. This function starts the Lain CLI and processes the commands passed in the arguments.
# Lain Module Documentation

The `Lain` module is a command line interface (CLI) application that allows users to execute various commands. This documentation provides an overview of the module's structure, functions, and usage.

## Modules Used

- `Lain::CommandRegistry`: A module responsible for registering available commands.
- `Lain::CommandLoader`: A module responsible for loading command definitions from external sources.

## Functions

### `run-cli(@args)`

The main function that initializes and runs the CLI application. It takes an array of arguments as input, with the first argument being considered the command to execute. If no command is provided, it defaults to 'help'. The function uses the `Lain::CommandLoader` module to load commands, then checks if the specified command exists using the `get-command()` function from `Lain::CommandRegistry`. If the command is found, its associated subroutine is called with the remaining arguments. If not, an error message is displayed indicating that the command is unknown.

### `register-command($name, $code)`

A helper function used to register a new command with the CLI application. It takes two arguments: the name of the command and a code reference (a subroutine) that will be executed when the command is invoked. This function is defined in the `Lain::CommandRegistry` module.

## Commands

### 'help' Command

The 'help' command displays a list of available commands and their usage to the user. When this command is invoked, it simply prints out a message listing all registered commands using the `list-commands()` function from `Lain::CommandRegistry`.
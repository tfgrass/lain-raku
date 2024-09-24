
# Lain::CommandRegistry Module Documentation

The `Lain::CommandRegistry` module provides functionality for registering, retrieving, and listing command handlers within a Perl6 application. It utilizes a hash-based storage system to associate command names with their corresponding subroutines.

## Functions

### `register-command(Str $name, &handler)`

The `register-command` function is used to register a new command and its associated handler in the registry.

#### Parameters:
- `$name` (Str): The name of the command as a string.
- `&handler` (Subroutine): A reference to the subroutine that handles the command.

#### Returns:
This function does not explicitly return any value. It updates the internal hash `%commands`, associating the provided command name with its handler.

### `get-command(Str $name)`

The `get-command` function retrieves a registered command's handler based on the given command name.

#### Parameters:
- `$name` (Str): The name of the command as a string.

#### Returns:
This function returns the subroutine handler associated with the provided command name if it exists in the registry; otherwise, it returns `Nil`.

### `list-commands()`

The `list-commands` function lists all registered commands in the registry.

#### Parameters:
None.

#### Returns:
This function returns a list of strings representing the names of all registered commands in the internal hash `%commands`.
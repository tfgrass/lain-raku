# Documentation for Commands::DocCommand Perl 6 Module

This markdown documentation provides a detailed explanation of the `Commands::DocCommand` Perl 6 module. The module defines a command that generates detailed markdown documentation for a given source file using an LMS API.

## Command Registration

The module registers a new command named 'doc' with the `Lain::CommandRegistry`. This command takes two optional arguments: `source_file` and `existing_doc`. If no `source_file` is provided, the command will display an error message and exit.

## Helpers::Connector::LMS Module Usage

The module uses the `Helpers::Connector::LMS::LMSConnector` class to interact with the LMS API for generating documentation. An instance of this class is created within the command implementation, with a default API URL and model name.

## generate-documentation Subroutine

The main functionality of this module is encapsulated in the `generate-documentation` subroutine. This subroutine takes four arguments: an `LMSConnector` object, a source file path, an optional existing documentation file path, and an output file path. If no existing documentation file is provided or if it doesn't exist, the function will proceed without it.

The subroutine then opens the output file in write mode and sends a request to the LMS API using the `send` method of the provided `LMSConnector` object. The generated documentation content is written to both standard output and the specified output file.

### Variables:
- **$lms_connector**: An instance of the `Helpers::Connector::LMS::LMSConnector` class used for interacting with the LMS API.
- **$source-file**: The path to the source code file for which documentation will be generated.
- **$existing-doc-file**: An optional path to an existing markdown documentation file that may contain additional information or context.
- **$output-file**: The path where the generated markdown documentation will be saved.

### Functions:
- **register-command('doc', ...)**: Registers a new command with the `Lain::CommandRegistry`.
- **generate-documentation(...)**: Generates detailed markdown documentation for a source code file using an LMS API and saves it to an output file.
# Lain

Lain is a CLI tool built in Raku that communicates with the LM Studio API. It allows users to define and use subcommands, utilizing customizable templates for system and user messages. The tool is designed to be lightweight, flexible, and extendable, making it easy to create custom AI-powered interactions.

## Features

- **Subcommand-based**: Define and execute subcommands with ease.
- **Template-driven**: System and user messages are template-based, allowing customization.
- **Integration with LM Studio API**: Seamless communication with the LM Studio API.
- **Cross-platform**: Designed to run on Linux and macOS.
- **Distributed via Homebrew**: Easy installation and distribution via Homebrew.

### Example Use Case

```
lain doc main.py
```

The `doc` command generates documentation for the given code (`main.py`) by sending a system message that explains that the AI is an assistant for generating documentation, followed by the user message containing the code.

### Customizable Templates

Users can define their own templates for system and user messages, providing flexibility to create tailored interactions.

## Installation

### Prerequisites

- Raku programming language 
- Zefs
- Git
- LM Studio 


### From Source (Manual)

1. Clone the repository:
   ```
   git clone https://github.com/tfgrass/lain.git
   ```
2. Install dependencies and build the project.

## Usage

After installation, you can run the `lain` command from your terminal:

```
lain [command] [arguments]
```

For example:

```
lain doc myscript.py
```

## License

Lain is released under the Artistic License 2.0. See the [LICENSE](LICENSE) file for more details.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

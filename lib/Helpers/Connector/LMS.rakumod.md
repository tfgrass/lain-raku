
# LMSConnector Module Documentation

This documentation provides an overview of the `LMSConnector` module, a Perl 6 class designed to interact with a language model service (LMS) API. The module facilitates sending code content and existing documentation to generate or update detailed markdown documentation for the provided code.

## Class: LMSConnector

The `LMSConnector` class encapsulates the functionality required to communicate with the LMS API. It provides methods for setting up a connection, sending requests, and handling responses.

### Attributes

- **$.api-url**: A read/write string attribute representing the URL of the LMS API.
- **$.model-name**: A read/write string attribute specifying the name of the language model to be used.
- **$.max-tokens**: An integer attribute indicating the maximum number of tokens for the LMS response (default is -1).
- **$.temperature**: A rational number attribute that influences the randomness of the generated documentation (default is 0.7).
- **$.system-message**: A read/write string attribute containing a predefined system message to guide the behavior of the LMS (default value provided in the code).

### Methods

#### new

The `new` method initializes a new instance of the `LMSConnector` class. It requires two named parameters: **$api-url** and **$model-name**. The method returns the blessed object with the specified attributes.

```perl6
method new(:$api-url!, :$model-name!) {
    self.bless(:$api-url, :$model-name);
}
```

#### send

The `send` method sends a request to the LMS API with the provided code content and optional existing documentation. It constructs a JSON payload containing the required parameters and sends an HTTP POST request to the specified API URL. The method handles errors during the HTTP request and returns a hash reference indicating the success or failure of the operation, along with relevant data or error messages.

```perl6
method send(Str $code-content, Str :$existing-doc?) {
    # Construct headers, user message, payload, and perform HTTP POST request
}
```
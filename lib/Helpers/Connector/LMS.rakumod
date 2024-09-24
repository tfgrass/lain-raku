unit module Helpers::Connector::LMS;

use Cro::HTTP::Client;
use JSON::Fast;

class LMSConnector {
    has Str $.api-url is rw;
    has Str $.model-name is rw;
    has Int $.max-tokens is rw = -1;
    has Rat $.temperature is rw = 0.7;
    has Str $.system-message is rw = "You are a documentation generator. Given code, generate or update detailed markdown documentation for the code file. Summarize what the whole code does and then go into details on each function, class, and variable.";

    method new(:$api-url!, :$model-name!) {
        self.bless(:$api-url, :$model-name);
    }

method send(Str $code-content, Str :$existing-doc?) {
    say 'In send';

    my %headers = (
        "Content-Type" => "application/json",
    );

    my $user-message = $existing-doc
        ?? "Update the following documentation with the new code:\n\nCode:\n{$code-content}\n\nExisting Documentation:\n{$existing-doc}"
        !! "Generate detailed markdown documentation for the following code:\n\n{$code-content}";

    my @messages = (
        { role => "system", content => $.system-message },
        { role => "user", content => $user-message }
    );

    my %payload = (
        model       => $.model-name,
        messages    => @messages,
        temperature => $.temperature,
        max_tokens  => $.max-tokens,
        # Removed 'stream' parameter as we're not streaming
    );

    my $json_payload = JSON::Fast::to-json(%payload);
    say "Payload: $json_payload";

    # Set connection, headers, and body timeouts to 3600 seconds, and keep the default value for total timeout (Inf)
    my $client = Cro::HTTP::Client.new(timeout => { connection => 3600, headers => 3600, body => 3600 });

    # Using Raku's built-in try for error handling
    my $response = try {
        await $client.post: $.api-url, :%headers, body => $json_payload;
    };

    if $response.defined {
        say "Received response with status {$response.status}";

       if $response.status == 200 {
    # Await the response body to ensure we get the full content
    my %response-body = await $response.body;

    # Ensure that %response-body{'choices'} is an array and has content
    if %response-body<choices> && %response-body<choices>[0]<message><content> {
        my $message = %response-body<choices>[0]<message><content>;
        say "Generated Message: $message";
        return { status => 'success', data => $message };
    } else {
        warn "No valid message found in the response.";
        return { status => 'error', message => "No valid message found." };
    }
}
    }
    else {
        # Handle the case where the HTTP request failed
        warn "Exception during HTTP request: {$!}";
        return { status => 'error', message => "An error occurred: {$!}" };
    }
}

}

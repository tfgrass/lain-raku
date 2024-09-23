unit module Helpers::Connector::LMS;

use Cro::HTTP::Client;
use JSON::Fast;

class LMSConnector {
    has Str $.api-url is rw;
    has Str $.model-name is rw;
    has Int $.max-tokens = (-1);
    has Rat $.temperature = 0.7;
    has Str $.system-message is rw = "You are a documentation generator. Given code, generate or update detailed markdown documentation for the code file. Summarize what the whole code does and then go into details on each function, class, and variable.";

    method new(:$api-url!, :$model-name!) {
        self.bless(:$api-url, :$model-name);
    }



    method send(Str $code-content, Str :$existing-doc?) {
        say 'In send';

        my %headers = (
            "Content-Type"  => "application/json",
        );

    my $user-message = $existing-doc ??
        "Update the following documentation with the new code:\n\nCode:\n{$code-content}\n\nExisting Documentation:\n{$existing-doc}"
        !!
        "Generate detailed markdown documentation for the following code:\n\n{$code-content}";

    my @messages = (
        { role => "system", content => $.system-message },
        { role => "user", content => $user-message }
    );

    my %payload = (
        model       => $.model-name,
        messages    => @messages,
        temperature => $.temperature,
        max_tokens  => $.max-tokens,
        stream      => True
    );

    my $json_payload = JSON::Fast::to-json(%payload);
    say "Payload: $json_payload";

    my $client = Cro::HTTP::Client.new(timeout => 60);  # Increased timeout

    return supply {
        start {
            say 'Before await';
            my $response = try await $client.post: $.api-url, :%headers, body => $json_payload;
            if $! {
                warn "Exception during HTTP request: $!";
                emit "An error occurred";
                done;
                return;
            }
            say 'After await';

            if $response.status == 200 {
                say 'Request successful';
                $response.body.tap(-> $chunk {
                    say "Received chunk: $chunk";
                    emit $chunk;
                });
                $response.body.wait;
            }
            else {
                warn "Request failed with status {$response.status}";
                say "Response Body: {$response.body.slurp-rest}";
                emit "An error occurred";
                done;
            }
        }
    }
}


}


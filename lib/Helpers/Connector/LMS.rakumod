unit module Helpers::Connector::LMS;

use Cro::HTTP::Client;
use JSON::Fast;
use IO::Handle;

class LMSConnector {
    has Str $.api-url is rw;
    has Str $.model-name is rw;
    has Int $.max-tokens = -1 is rw;
    has Num $.temperature = 0.7 is rw;
    has Str $.system-message is rw = "You are a documentation generator. Given code, generate or update detailed markdown documentation for the code file. Summarize what the whole code does and then go into details on each function, class, and variable.";

    method new(:$api-url!, :$model-name!) {
        self.bless(*, :$api-url, :$model-name);
    }

    method send(Str $code-content, Str :$existing-doc?) {
        my %headers = "Content-Type" => "application/json";

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

        my $client = Cro::HTTP::Client.new;

        my $response-promise = $client.post: $.api-url, 
            :$%headers, 
            body => json(%payload);

        my $response = $response-promise.result;

        if $response.code == 200 {
            my $body-supply = $response.body;

            # Process each line of the response
            my $processed-supply = $body-supply
                .split("\n")
                .map(-> $line {
                    $line .= trim;
                    return unless $line;
                    if $line.starts-with('data: ') {
                        my $data = $line.substr(6);
                        return if $data eq '[DONE]';
                        try {
                            my $chunk-data = from-json $data;
                            if $chunk-data<choices>:exists {
                                my %delta = $chunk-data<choices>[0]<delta>;
                                if %delta<content>:exists {
                                    return %delta<content>;
                                }
                            }
                        }
                        CATCH {
                            default {
                                # Ignore JSON parse errors
                            }
                        }
                    }
                })
                .grep(*.defined);

            return $processed-supply;
        } else {
            die "Error: Received status code {$response.code}";
        }
    }
}

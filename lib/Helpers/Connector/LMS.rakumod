unit module Helpers::Connector::LMS;

use Cro::HTTP::Client;
use JSON::Fast;
use Helpers::Logger;

class LMSConnector {
    has Str $.api-url is rw;
    has Str $.model-name is rw;
    has Int $.max-tokens is rw = -1;
    has Rat $.temperature is rw = 0.7;

    method new(:$api-url!, :$model-name!) {
        self.bless(:$api-url, :$model-name);
    }

    method send(
        Str :$system-message!,
        Str :$user-message!,
        Callable :$on-content!
    ) {
        log(1, 'in send');

        my %headers = (
            "Content-Type" => "application/json",
        );

        my @messages = (
            { role => "system", content => $system-message },
            { role => "user", content => $user-message }
        );

        my %payload = (
            model       => $.model-name,
            messages    => @messages,
            temperature => $.temperature,
            max_tokens  => $.max-tokens,
            stream      => True,  # Enable streaming
        );

        my $json_payload = to-json(%payload);
        log(1, "Payload: $json_payload");

        my $client = Cro::HTTP::Client.new();

        # Return a Promise
        return start {
            # Await the HTTP response
            my $response = await $client.post($.api-url, :%headers, body => $json_payload);

            if $response.defined {
                log(1, "Response status: {$response.status}");
                if $response.status == 200 {
                    log(1, "Response is OK, starting to process chunks...");

                    my $buffer = '';  # Buffer to accumulate partial data
                    my $done-promise = Promise.new;  # Promise to signal completion

                    # Use a react block to process the streaming response
                    react {
                        whenever $response.body-byte-stream -> $chunk {
                            # Decode the chunk to a string (assuming UTF-8)
                            my $data = $chunk.decode('utf8');
                            log(5, "Received chunk: $data");

                            # Append the new data to the buffer
                            $buffer ~= $data;

                            # Process complete lines in the buffer
                            while $buffer ~~ /(.*?) \r? \n / {
                                my $line = $0.Str;
                                $buffer = $/.postmatch;

                                if $line.starts-with('data: ') {
                                    my $json-str = $line.substr('data: '.chars);
                                    if $json-str eq '[DONE]' {
                                        $on-content("\n");  # finish with a new line

                                        log(1, "Streaming completed");

                                        # Signal completion and exit the react block
                                        $done-promise.keep;
                                        done;
                                    } else {
                                        try {
                                            my %chunk-data = from-json $json-str;
                                            if %chunk-data<choices> && %chunk-data<choices>[0]<delta><content> {
                                                my $partial_content = %chunk-data<choices>[0]<delta><content>;
                                                log(5, "Generated Partial Content: $partial_content");
                                                # Call the provided content handler
                                                $on-content($partial_content);
                                            }
                                        }
                                        CATCH {
                                            default {
                                                log(1, "Error parsing chunk: {$json-str}");
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        whenever $done-promise {
                            log(1, "All chunks processed.");
                        }
                        CATCH {
                            log(1, "error while streaming: $_");

                        }
                    }

                    # Wait for the react block to complete
                    await $done-promise;
                } else {
                    log(2, "Received non-OK response status: {$response.status}");
                }
            } else {
                log(2, "No response received or response is undefined.");
            }
        }
    }
}

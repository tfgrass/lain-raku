unit module Helpers::Connector::LMS;

use Cro::HTTP::Client;
use JSON::Fast;
use Helpers::Logger;

class LMSConnector {
    has Str $.api-url is rw;
    has Str $.model-name is rw;
    has Int $.max-tokens is rw = -1;
    has Rat $.temperature is rw = 0.7;

    method new(:$api-url = 'http://127.0.0.1:1234/v1/chat/completions', :$model-name = '') {
        self.bless(:$api-url, :$model-name);
    }

    method send(
        Str :$system-message!,
        Str :$user-message!,
        Callable :$on-content!,
        Callable :$on-error?  # Optional error handler
    ) {
        log(1, 'Starting send method');

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
        log(3, "Payload to be sent: $json_payload");

        my $client = Cro::HTTP::Client.new();

        # Start the asynchronous request
        start {
            try {
                my $response = await $client.post($.api-url, :%headers, body => $json_payload, :timeout(10));

                if $response.defined {
                    log(1, "Received response with status: {$response.status}");
                    if $response.status == 200 {
                        log(1, "Response OK, processing chunks");

                        my $buffer = '';  # Buffer to accumulate partial data
                        my $done-promise = Promise.new;  # Promise to signal completion

                        # Use a react block to process the streaming response
                        react {
                            whenever $response.body-byte-stream -> $chunk {
                                my $data = $chunk.decode('utf8');
                                log(5, "Received chunk: $data");
                                $buffer ~= $data;

                                while $buffer ~~ /(.*?) \r? \n / {
                                    my $line = $0.Str;
                                    $buffer = $/.postmatch;

                                    if $line.starts-with('data: ') {
                                        my $json-str = $line.substr('data: '.chars);
                                        if $json-str eq '[DONE]' {
                                            $on-content("\n");  # Finish with a new line
                                            log(1, "Streaming completed");
                                            $done-promise.keep;
                                            done;
                                        } else {
                                            try {
                                                my %chunk-data = from-json $json-str;
                                                if %chunk-data<choices> && %chunk-data<choices>[0]<delta><content> {
                                                    my $partial_content = %chunk-data<choices>[0]<delta><content>;
                                                    log(5, "Partial content generated: $partial_content");
                                                    $on-content($partial_content);
                                                }
                                            }
                                            CATCH {
                                                default {
                                                    log(2, "Error parsing chunk: $json-str");
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            whenever $done-promise {
                                log(1, "All chunks processed successfully.");
                            }

                            CATCH {
                                log(2, "Error during streaming: $_");
                                $on-error("Error during streaming: $_") if $on-error;
                            }
                        }

                        # Wait for the react block to complete
                        await $done-promise;
                    } else {
                        log(2, "Received non-OK status: {$response.status}");
                        $on-error("Non-OK response: {$response.status}") if $on-error;
                    }
                } else {
                    log(2, "No response or response undefined.");
                    $on-error("No response or undefined response.") if $on-error;
                }
            }
            CATCH {
                default {
                    log(2, "Request failed: $_");
                    $on-error("Request failed: $_") if $on-error;
                }
            }
        }
    }
}

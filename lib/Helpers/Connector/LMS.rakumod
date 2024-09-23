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
            :%headers, 
            body => JSON::Fast::to-json(%payload);


    # Declare and assign $body-supply using the response promise
    my $body-supply = $response-promise.Supply;
        # Create a new supply for handling the stream
           return $body-supply.lines.tap( -> $line {
        # Process each line of the response and emit tokens as they become available
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
                        # Emit the token to the Supply
                        emit(%delta<content>);
                    }
                }
            }
            CATCH {
                default {
                    # Handle any errors within the tap block as needed
                }
            }
        } );
    } 
}

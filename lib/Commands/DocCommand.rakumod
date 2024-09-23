unit module Commands::DocCommand;

use Lain::CommandRegistry;
use Helpers::Connector::LMS;

register-command('doc', -> @args {
    my $source-file = @args[0] // '';
    my $existing-doc-file = @args[1] // '';  # Can be Nil

    unless $source-file {
        say "Error: No source file provided.";
        say "Usage: lain doc <source_file> [existing_doc]";
        exit 1;
    }

    my $output-file = "{$source-file}.md";

    my $lms_connector = Helpers::Connector::LMS::LMSConnector.new(
        api-url    => "http://127.0.0.1:1234/v1/chat/completions",
        model-name => "lmstudio-community/Codestral-22B-v0.1-GGUF/Codestral-22B-v0.1-Q4_K_M.gguf"
    );

    generate-documentation($lms_connector, $source-file, :$existing-doc-file, :$output-file);
});

sub generate-documentation(
    Helpers::Connector::LMS::LMSConnector $lms-connector,
    Str $source-file,
    Str() :$existing-doc-file,
    Str :$output-file
) {
    unless $source-file.IO.e {
        say "Error: The file '{$source-file}' does not exist.";
        return;
    }
#dd $existing-doc-file;

    my $code-content = $source-file.IO.slurp;

    my $existing-doc = '';
    if $existing-doc-file.defined && $existing-doc-file.Str.chars > 0 && $existing-doc-file.IO.e {
        $existing-doc = $existing-doc-file.IO.slurp;
    } elsif $existing-doc-file.defined && $existing-doc-file.Str.chars > 0 {
        say "Warning: The documentation file '{$existing-doc-file}' does not exist. Proceeding without it.";
    }

    my $md-file = $output-file.IO.open(:w);

    my $response-supply = $lms-connector.send($code-content, :$existing-doc);

    $*OUT.flush;

    say "Generating documentation for '{$source-file}'...\n";

    $response-supply.tap(-> $content {
        print $content;
        $md-file.print($content);
    });

    $response-supply.wait;

    $md-file.close;

    say "\n\nDocumentation saved to: {$output-file}";
}

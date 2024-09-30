unit module Commands::AutoMergeCommand;

use Lain::CommandRegistry;
use Helpers::Connector::LMS;
use Helpers::Logger;

register-command('auto-merge', -> @args {
    # Get list of files with merge conflicts
    my @conflict-files = qx{git diff --name-only --diff-filter=U}.lines;

    unless @conflict-files {
        say "No merge conflicts detected.";
        exit 0;
    }

    say "Merge conflicts detected in the following files:";
    for @conflict-files -> $file {
        say "- $file";
    }

    my $lms_connector = Helpers::Connector::LMS::LMSConnector.new(
        api-url    => "http://127.0.0.1:1234/v1/chat/completions",
        model-name => "lmstudio-community/Codestral-22B-v0.1-GGUF/Codestral-22B-v0.1-Q4_K_M.gguf"
    );

    # Process each conflicting file asynchronously
    my @promises = @conflict-files.map: -> $file {
        start {
            say "\nProcessing file: $file";
            resolve-conflicts($lms_connector, $file);
        }
    };

    # Wait for all promises to complete
    await Promise.allof(@promises);
});

sub resolve-conflicts(
    Helpers::Connector::LMS::LMSConnector $lms_connector,
    Str $file
) {
    # Read the file content
    my $file-content = $file.IO.slurp;

    # Find conflict regions
    my @conflicts = parse-conflicts($file-content);

    if @conflicts.elems == 0 {
        say "No conflict regions found in $file.";
        return;
    }

    # Process each conflict region
    for @conflicts.kv -> $idx, %conflict {
        say "Resolving conflict #{$idx + 1} in $file...";
        my $resolved = resolve-conflict($lms_connector, %conflict);

        # Replace the conflict region in the file content
        $file-content .= subst(%conflict<full_text>, $resolved);
    }

    # Write the resolved content back to the file
    $file.IO.spurt($file-content);

    say "Conflicts in $file have been resolved.";
}
sub parse-conflicts(Str $content) {
    my @conflicts;

    # Normalize line endings to Unix style
    $content .= subst(/\r\n/, "\n", :g);

    # Define the conflict regex with :ms modifiers
    my $conflict-regex = rx:m{
        ^ '<<<<<<<' \s* 'HEAD' \n        # Start of the conflict marker
        (<ours> .*? )                    # Capture our changes (non-greedy)
        ^ '=======' \n                   # Divider between our changes and theirs
        (<theirs> .*? )                  # Capture their changes (non-greedy)
        ^ '>>>>>>>' \s* \N* \n?          # End of the conflict marker with optional branch
    };

    # Iterate over each match
    while $content ~~ m:g/ $conflict-regex / {
        my $full_text = $/.Str;
        my $ours      = $<ours>.Str;
        my $theirs    = $<theirs>.Str;

        # Debugging output
        say "Matched conflict:\n$full_text\n";
        say "Our changes:\n$ours\n";
        say "Their changes:\n$theirs\n";

        # Push the captured conflict into the conflicts array
        @conflicts.push: {
            full_text => $full_text,
            ours      => $ours,
            theirs    => $theirs
        };
    }
    dd @conflicts;
    # If no conflicts are found, print the file content for debugging
    unless @conflicts.elems {
        say "No conflicts found. File content:\n$content";
    }

    return @conflicts;
}






sub resolve-conflict(
    Helpers::Connector::LMS::LMSConnector $lms_connector,
    %conflict
) {
    my $system_message = "You are a code merge assistant. Given two versions of code, help merge them into a single version, resolving any conflicts. Provide only the merged code.";

    my $user_message = "Our version:\n{%conflict<ours>}\n\nTheir version:\n{%conflict<theirs>}\n\nMerge these into a single version.";

    my $merged = '';

    my $on-content = sub ($partial-content) {
        $merged ~= $partial-content;
    };

    my $on-error = sub ($error) {
        log(0, "Error during LLM Response: $error");
    };

    # Start an asynchronous block
    my $promise = start {
        try {
            await $lms_connector.send(
                system-message => $system_message,
                user-message   => $user_message,
                on-content     => $on-content,
                on-error       => $on-error
            );
        }
        CATCH {
            default {
                say "Error during conflict resolution: $_";
            }
        }
    };

    # Wait for the promise to complete
    await $promise;

    return $merged;
}

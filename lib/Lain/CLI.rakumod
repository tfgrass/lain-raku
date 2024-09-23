unit module Lain::CLI;

sub normalize-args(@args) is export {
    my $program-name = $*PROGRAM || $*PROGRAM-NAME || $*EXECUTABLE.Str.IO.basename;

    my @normalized-args = @args;

    if @args[0] eq $program-name {
        @normalized-args = @args[1..*];
    }

    return @normalized-args;
}
BEGIN {
    if( $ENV{PERL_CORE} ) {
        chdir 't';
        @INC = ('../lib', 'lib');
    }
    else {
        unshift @INC, 't/lib';
    }
}

use strict;
use File::Spec;
use Test::More;
plan skip_all => 'Not adapted to perl core' if $ENV{PERL_CORE};
plan skip_all => 'Not installing prove' if -e 't/SKIP-PROVE';

# Work around a Cygwin bug.  Remove this if Perl bug 30952 ever gets fixed.
# http://rt.perl.org/rt3/Ticket/Display.html?id=30952.
plan skip_all => 'Skipping because of a Cygwin bug' if ( $^O =~ /cygwin/i );

plan tests => 11;

my $blib = File::Spec->catfile( File::Spec->curdir, 'blib' );
my $blib_lib = File::Spec->catfile( $blib, 'lib' );
my $blib_arch = File::Spec->catfile( $blib, 'arch' );
my $prove = File::Spec->catfile( $blib, 'script', 'prove' );
$prove = "$^X $prove";

CAPITAL_TAINT: {
    local $ENV{PROVE_SWITCHES};

    output_matches(
        [ qx/$prove -Ifirst -D -I second -Ithird -Tvdb/ ],
        [ "# \$Test::Harness::Switches: -T -w -I$blib_arch -I$blib_lib -Ifirst -Isecond -Ithird" ],
        'Capital taint flags OK'
    );
}

LOWERCASE_TAINT: {
    local $ENV{PROVE_SWITCHES};

    output_matches(
        [ qx/$prove -dD -Ifirst -I second -t -Ithird -vb/ ],
        [ "# \$Test::Harness::Switches: -t -w -I$blib_arch -I$blib_lib -Ifirst -Isecond -Ithird" ],
        'Lowercase taint OK'
    );
}

PROVE_SWITCHES: {
    local $ENV{PROVE_SWITCHES} = "-dvb -I fark";

    output_matches(
        [ qx/$prove -Ibork -Dd/ ],
        [ "# \$Test::Harness::Switches: -w -I$blib_arch -I$blib_lib -Ifark -Ibork" ],
        'PROVE_SWITCHES OK'
    );
}

PROVE_SWITCHES_L: {
    output_matches(
        [ qx/$prove -l -Ibongo -Dd/ ],
        [ '# $Test::Harness::Switches: -w -Ilib -Ibongo' ],
        '-l OK'
    );
}

PROVE_SWITCHES_LB: {
    output_matches(
        [ qx/$prove -lb -Dd/ ],
        [ "# \$Test::Harness::Switches: -w -Ilib -I$blib_arch -I$blib_lib" ],
        '-l -b OK'
    );
}

PROVE_VERSION: {
    # This also checks that the prove $VERSION is in sync with Test::Harness's $VERSION
    use_ok( 'Test::Harness' );

    my $thv = $Test::Harness::VERSION;
    my $pv = sprintf( '%vd', $^V );
    output_matches(
        [ qx/$prove --version/ ],
        [ "prove v$thv, using Test::Harness v$thv and Perl v$pv" ],
        '--version OK'
    );
}


PROVE_SWITCHES_NONE: {
    output_matches(
        [ qx/$prove -Dd/ ],
        [ '# $Test::Harness::Switches: -w' ],
        'OK w/no switches'
    );
}


PROVE_SWITCHES_WARN: {
    output_matches(
        [ qx/$prove -w -Dd/ ],
        [ '# $Test::Harness::Switches: -w' ],
        'prove -w OK'
    );
}


PROVE_SWITCHES_REALLY_WARN: {
    output_matches(
        [ qx/$prove -W -Dd/ ],
        [ '# $Test::Harness::Switches: -w -W' ],
        'prove -W OK'
    );
}


PROVE_SWITCHES_NO_WARN: {
    output_matches(
        [ qx/$prove -X -Dd/ ],
        [ '# $Test::Harness::Switches: -w -X' ],
        'prove -X OK'
    );
}


sub output_matches {
    my $actual = shift;
    my $expected = shift;
    my $msg = shift;

    chomp @{$actual};
    chomp @{$expected};

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    return is_deeply( $actual, $expected, $msg );
}

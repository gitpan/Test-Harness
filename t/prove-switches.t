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
plan skip_all => "Not installing prove" if -e "t/SKIP-PROVE";

plan tests => 3;
local $/ = undef;

my $blib = File::Spec->catfile( File::Spec->curdir, "blib" );
my $blib_lib = File::Spec->catfile( $blib, "lib" );
my $blib_arch = File::Spec->catfile( $blib, "arch" );
my $prove = File::Spec->catfile( $blib, "script", "prove" );

CAPITAL_TAINT: {
    local $ENV{PROVE_SWITCHES};
    my $actual = qx/$prove -Ifirst -D -I second -Ithird -Tvdb/;
    my $expected = "# \$Test::Harness::Switches: -T -I$blib_arch -I$blib_lib -Ifirst -Isecond -Ithird\n";
    is( $actual, $expected, "Capital taint flags OK" );
}

LOWERCASE_TAINT: {
    local $ENV{PROVE_SWITCHES};
    my $actual = qx/$prove -dD -Ifirst -I second -t -Ithird -vb/;
    my $expected = "# \$Test::Harness::Switches: -t -I$blib_arch -I$blib_lib -Ifirst -Isecond -Ithird\n";
    is( $actual, $expected, "Lowercase taint OK" );
}

PROVE_SWITCHES: {
    local $ENV{PROVE_SWITCHES} = "-dvb -I fark";
    my $actual = qx/$prove -Ibork -D/;
    my $expected = "# \$Test::Harness::Switches: -I$blib_arch -I$blib_lib -Ifark -Ibork\n";
    is( $actual, $expected, "PROVE_SWITCHES ok" );
}

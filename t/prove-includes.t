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

plan tests=>1;
local $/ = undef;

my $blib = File::Spec->catfile( qw( blib lib ) );
my $prove = File::Spec->catfile( qw( blib script prove ) );
my $actual = qx/$prove -d -Ifirst -I second -Ithird -Tvb/;
my $expected = "# \$Test::Harness::Switches: -I$blib -Ifirst -Isecond -Ithird -T\n";
is( $actual, $expected, "Proper flags found" );

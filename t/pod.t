BEGIN {
    if( $ENV{PERL_CORE} ) {
        chdir 't';
        @INC = ('../lib', 'lib');
    }
    else {
        unshift @INC, 't/lib';
    }
}

use File::Spec;
use File::Find;
use Test::More;
use strict;

eval "use Test::Pod 0.95";

plan skip_all => "Test::Pod v0.95 required for testing POD" if $@;

my @files;
my $blib = File::Spec->catfile(qw(blib lib));
find( sub {push @files, $File::Find::name if /\.p(l|m|od)$/}, $blib);
plan tests => scalar @files;
Test::Pod::pod_file_ok($_) foreach @files;

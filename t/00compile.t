#!/usr/bin/perl -Tw

use lib qw(t/lib);
use Test::More tests => 3;

BEGIN { use_ok 'Test::Harness' }

BEGIN { use_ok 'Test::Harness::Straps' }

# If the $VERSION is set improperly, this will spew big warnings.
use_ok 'Test::Harness', 1.1601;

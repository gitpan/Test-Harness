use strict;
use Test::More 'no_plan';

use_ok('Test::Harness::Straps');

my %samples = (
   combined         => {
                        max         => 10,
                        seen        => 10,

                        ok          => 8,
                        todo        => 2,
                        skip        => 1,
                        bonus       => 1,

                        summary     => [ undef,
                                         { ok => 1, actual_ok => 1 },
                                         { ok => 1, actual_ok => 1 },
                                         { ok => 0, actual_ok => 0 },
                                         { ok => 1, actual_ok => 1,
                                           type => 'todo'
                                         },
                                         { ok => 1, actual_ok => 1 },
                                         { ok => 1, actual_ok => 1 },
                                         { ok => 1, actual_ok => 1,
                                           type   => 'skip',
                                           reason => 'contract negociations'
                                         },
                                         { ok => 1, actual_ok => 1 },
                                         { ok => 0, actual_ok => 0 },
                                         { ok => 1, actual_ok => 0,
                                           type   => 'todo' 
                                         },
                                       ]
                       },

   simple           => {
                        max         => 5,
                        seen        => 5,
                        
                        ok          => 5,
                        todo        => 0,
                        skip        => 0,
                        bonus       => 0,
                        
                        summary     => [ undef,
                                         ({ ok => 1, actual_ok => 1 }) x 5
                                       ]
                       },

   simple_fail      => {
                        max         => 5,
                        seen        => 5,
                        
                        ok          => 3,
                        todo        => 0,
                        skip        => 0,
                        bonus       => 0,
                        
                        summary     => [ undef,
                                         { ok => 1, actual_ok => 1 },
                                         { ok => 0, actual_ok => 0 },
                                         { ok => 1, actual_ok => 1 },
                                         { ok => 1, actual_ok => 1 },
                                         { ok => 0, actual_ok => 0 },
                                       ]
                       },

   skip             => {
                        max         => 5,
                        seen        => 5,

                        ok          => 5,
                        todo        => 0,
                        skip        => 1,
                        bonus       => 0,
                        
                        summary     => [ undef,
                                         { ok => 1, actual_ok => 1 },
                                         { ok   => 1, actual_ok => 1,
                                           type   => 'skip',
                                           reason => 'rain delay',
                                         },
                                         ({ ok => 1, actual_ok => 1 }) x 3
                                       ]
                       },

   todo             => {
                        max         => 5,
                        seen        => 5,
                                    
                        ok          => 5,
                        todo        => 2,
                        skip        => 0,
                        bonus       => 1,

                        summary     => [ undef,
                                         { ok => 1, actual_ok => 1 },
                                         { ok => 1, actual_ok => 1,
                                           type => 'todo' },
                                         { ok => 1, actual_ok => 0,
                                           type => 'todo' },
                                         ({ ok => 1, actual_ok => 1 }) x 2
                                       ],
                       },
);


while( my($test, $expect) = each %samples ) {
    my $strap = Test::Harness::Straps->new;
    my %results = $strap->analyze_file("t/sample-tests/$test");
    
    ok( eq_array($expect->{summary}, $results{summary}), 
        "$test summary" );

    delete $expect->{summary};
    delete $results{summary};
    ok( eq_hash($expect, \%results), "  the rest" );
}

#!/usr/bin/perl -w

use strict;
use lib qw(t/lib);

use Test::More 'no_plan';

use_ok('Test::Harness::Straps');

my %samples = (
   combined   => {
                  max         => 10,
                  seen        => 10,

                  'ok'        => 8,
                  'todo'      => 2,
                  'skip'      => 1,
                  bonus       => 1,

                  details     => [ { 'ok' => 1, actual_ok => 1 },
                                   { 'ok' => 1, actual_ok => 1,
                                     name => 'basset hounds got long ears',
                                   },
                                   { 'ok' => 0, actual_ok => 0,
                                     name => 'all hell broke lose',
                                   },
                                   { 'ok' => 1, actual_ok => 1,
                                     type => 'todo'
                                   },
                                   { 'ok' => 1, actual_ok => 1 },
                                   { 'ok' => 1, actual_ok => 1 },
                                   { 'ok' => 1, actual_ok => 1,
                                     type   => 'skip',
                                     reason => 'contract negociations'
                                   },
                                   { 'ok' => 1, actual_ok => 1 },
                                   { 'ok' => 0, actual_ok => 0 },
                                   { 'ok' => 1, actual_ok => 0,
                                     type   => 'todo' 
                                   },
                                 ]
                       },

   descriptive      => {
                        max         => 5,
                        seen        => 5,

                        'ok'          => 5,
                        'todo'        => 0,
                        'skip'        => 0,
                        bonus       => 0,

                        details     => [ { 'ok' => 1, actual_ok => 1,
                                           name => 'Interlock activated'
                                         },
                                         { 'ok' => 1, actual_ok => 1,
                                           name => 'Megathrusters are go',
                                         },
                                         { 'ok' => 1, actual_ok => 1,
                                           name => 'Head formed',
                                         },
                                         { 'ok' => 1, actual_ok => 1,
                                           name => 'Blazing sword formed'
                                         },
                                         { 'ok' => 1, actual_ok => 1,
                                           name => 'Robeast destroyed'
                                         },
                                       ],
                       },

   duplicates       => {
                        max         => 10,
                        seen        => 11,

                        'ok'          => 11,
                        'todo'        => 0,
                        'skip'        => 0,
                        bonus       => 0,

                        details     => [ ({ 'ok' => 1, actual_ok => 1 }) x 10
                                       ],
                       },

   head_end         => {
                        max         => 4,
                        seen        => 4,

                        'ok'        => 4,
                        'todo'      => 0,
                        'skip'      => 0,
                        bonus       => 0,

                        details     => [ ({ 'ok' => 1, actual_ok => 1 }) x 4
                                       ],
                       },

   head_fail           => {
                           max      => 4,
                           seen     => 4,

                           'ok'     => 3,
                           'todo'   => 0,
                           'skip'   => 0,
                           bonus    => 0,

                           details  => [ { 'ok' => 1, actual_ok => 1 },
                                         { 'ok' => 0, actual_ok => 0 },
                                         ({ 'ok'=> 1, actual_ok => 1 }) x 2
                                       ],
                          },
               
   simple           => {
                        max         => 5,
                        seen        => 5,
                        
                        'ok'          => 5,
                        'todo'        => 0,
                        'skip'        => 0,
                        bonus       => 0,
                        
                        details     => [ ({ 'ok' => 1, actual_ok => 1 }) x 5
                                       ]
                       },

   simple_fail      => {
                        max         => 5,
                        seen        => 5,
                        
                        'ok'          => 3,
                        'todo'        => 0,
                        'skip'        => 0,
                        bonus       => 0,
                        
                        details     => [ { 'ok' => 1, actual_ok => 1 },
                                         { 'ok' => 0, actual_ok => 0 },
                                         { 'ok' => 1, actual_ok => 1 },
                                         { 'ok' => 1, actual_ok => 1 },
                                         { 'ok' => 0, actual_ok => 0 },
                                       ]
                       },

   'skip'             => {
                        max         => 5,
                        seen        => 5,

                        'ok'          => 5,
                        'todo'        => 0,
                        'skip'        => 1,
                        bonus       => 0,
                        
                        details     => [ { 'ok' => 1, actual_ok => 1 },
                                         { 'ok'   => 1, actual_ok => 1,
                                           type   => 'skip',
                                           reason => 'rain delay',
                                         },
                                         ({ 'ok' => 1, actual_ok => 1 }) x 3
                                       ]
                       },

   'todo'             => {
                        max         => 5,
                        seen        => 5,
                                    
                        'ok'          => 5,
                        'todo'        => 2,
                        'skip'        => 0,
                        bonus       => 1,

                        details     => [ { 'ok' => 1, actual_ok => 1 },
                                         { 'ok' => 1, actual_ok => 1,
                                           type => 'todo' },
                                         { 'ok' => 1, actual_ok => 0,
                                           type => 'todo' },
                                         ({ 'ok' => 1, actual_ok => 1 }) x 2
                                       ],
                       },
   taint            => {
                        max         => 1,
                        seen        => 1,

                        'ok'          => 1,
                        'todo'        => 0,
                        'skip'        => 0,
                        bonus       => 0,

                        details     => [ { 'ok' => 1, actual_ok => 1,
                                           name => '- -T honored'
                                         },
                                       ],
                       },
);


while( my($test, $expect) = each %samples ) {
    my $strap = Test::Harness::Straps->new;
    my %results = $strap->analyze_file("t/sample-tests/$test");
    
    is_deeply($expect->{details}, $results{details}, "$test details" );

    delete $expect->{details};
    delete $results{details};
    is_deeply($expect, \%results, "  the rest" );
}

# -*- Mode: cperl; cperl-indent-level: 4 -*-
# $Id: Straps.pm,v 1.1.2.6 2001/09/29 03:53:03 schwern Exp $

package Test::Harness::Straps;

use strict;
use vars qw($VERSION);
$VERSION = '0.02';

use Test::Harness::Assert;


# Flags used as return values from our methods.  Just for internal 
# clarification.
my $TRUE  = (1==1);
my $FALSE = !$TRUE;
my $YES   = $TRUE;
my $NO    = $FALSE;


=head1 NAME

Test::Harness::Straps - detailed analysis of test results

=head1 SYNOPSIS

  use Test::Harness::Straps;

  my $strap = Test::Harness::Straps->new;

  # Various ways to interpret a test
  my %results = $strap->analyze($name, @test_output);
  my %results = $strap->analyze_fh($name, $test_filehandle);
  my %results = $strap->analyze_file($test_file);

  # UNIMPLEMENTED
  my %total = $strap->total_results;

  # Altering the behavior of the strap  UNIMPLEMENTED
  my $verbose_output = $strap->dump_verbose();
  $strap->dump_verbose_fh($output_filehandle);


=head1 DESCRIPTION

Test::Harness is limited to printing out its results.  This makes
analysis of the test results difficult for anything but a human.  To
make it easier for programs to work with test results, we provide
Test::Harness::Straps.  Instead of printing the results, straps
provide them as raw data.  You can also configure how the tests are to
be run.

=head2 Construction

=over 4

=item B<new>

  my $strap = Test::Harness::Straps->new;

Initialize a new strap.

=cut

sub new {
    my($proto) = shift;
    my($class) = ref $proto || $proto;

    my $self = bless {}, $class;
    $self->_init;

    return $self;
}

=begin _private

=item B<_init>

  $strap->_init;

Initialize the internal state of a strap to make it ready for parsing.

=cut

sub _init {
    my($self) = shift;

}


=head2 Analysis

=over 4

=item B<analyze>

  my %results = $strap->analyze($name, \@test_output);

Analyzes the output of a single test, assigning it the given $name for
use in the total report.  Returns the %results of the test.  L<See
Results>.

@test_output should be the raw output from the test, including newlines.

=cut

sub analyze {
    my($self, $name, $test_output) = @_;

    $self->_reset_file_state;
    $self->{file} = $name;
    my %totals  = (
                   max      => 0,
                   seen     => 0,

                   ok       => 0,
                   todo     => 0,
                   skip     => 0,
                   bonus    => 0,
                   
                   summary  => []
                  );


    foreach my $line (@$test_output) {
        my %result = ();
        
        $self->{line}++;
        

        if( $self->_is_header($line) ) {
            $self->{saw_header}++;

            $totals{max} += $self->{max};

#            $self->_callback('saw_header', $line);
        }
        elsif( $self->_is_test($line, \%result) ) {
            $totals{seen}++;
            $result{number} = $self->{'next'} unless $result{number};

            my $pass = $result{ok};

            # special case for VMS, sometimes the 'not ' and the 'ok' are
            # on different lines if you do this:
            #   print "not " unless $test;
            #   print "ok $num\n";
            if( $self->{_is_vms}                             &&
                $self->{_saw_lone_not} == $self->{line} - 1  &&
                $result{ok}
              ) 
            {   
                $result{ok} = 0;
            }

            $result{type} = 'todo' if $self->{todo}{$result{number}};

            if( $result{type} eq 'todo' ) {
                $totals{todo}++;
                $pass = 1;
                $totals{bonus}++ if $result{ok}
            }
            elsif( $result{type} eq 'skip' ) {
                $totals{skip}++;
                $pass = 1;
            }

            $totals{ok}++ if $pass;

            $totals{summary}[$result{number}] = 
              {$self->_summarize($pass, \%result)};

            $self->{'next'}++;

            # XXX handle counter mismatch

        }
    }

    $self->{totals}{$name} = \%totals;
    return %totals;
}


=item B<analyze_fh>

  my %results = $strap->analyze_fh($name, $test_filehandle);

Like C<analyze>, but it reads from the given filehandle.

=cut

sub analyze_fh {
    my($self, $name, $fh) = @_;

    $self->analyze($name, [<$fh>]);
}

=item B<analyze_file>

  my %results = $strap->analyze_file($test_file);

Like C<analyze>, but it reads from the given $test_file.  It will also
use that name for the total report.

=cut

sub analyze_file {
    my($self, $file) = @_;

    local $ENV{IFS} = '';

    # If $^X is just 'perl' we'll have to figure it out from PATH.
    # So rather than implicitly trusting PATH, we'll just save
    # ourselves a lot of work and explicitly trust it.
    local($ENV{PATH}) = $ENV{PATH} =~ /(.*)/;

    unless( open(FILE, '-|') || exec $^X, $file ) {
        # XXX fix up this error handling.
        die $!;
    }

    # XXX simple, stupid, easy for now.
    $self->analyze_fh($file, \*FILE);
}


=back


=begin _private

=head2 Parsing

Methods for identifying what sort of line you're looking at.

=item B<_is_comment>

  my $is_comment = $strap->_is_comment($line, \$comment);

Checks if the given line is a comment.  If so, it will place it into
$comment (sans #).

=cut

sub _is_comment {
    my($self, $line, $comment) = @_;

    if( $line =~ /^\s*\#(.*)/ ) {
        $$comment = $1;
        return $YES;
    }
    else {
        return $NO;
    }
}

=item B<_is_header>

  my $is_header = $strap->_is_header($line);

Checks if the given line is a header (1..M) line.  If so, it places
how many tests there will be in $strap->{max}, a list of which tests
are todo in $strap->{todo} and if the whole test was skipped
$strap->{skip_all} contains the reason.

=cut

# Regex for parsing a header.  Will be run with /x
my $Extra_Header_Re = <<'REGEX';
                       ^
                        (?: \s+ todo \s+ ([\d \t]+) )?      # optional todo set
                        (?: \s* \# \s* ([\w:]+) (.*) )?     # optional skip with optional reason
REGEX

sub _is_header {
    my($self, $line) = @_;

    if( my($max, $extra) = $line =~ /^1..(\d+)(.*)/ ) {
        $self->{max}  = $max;
        assert( $self->{max} >= 0,  'Max # of tests looks right' );

        if( defined $extra ) {
            my($todo, $skip, $reason) = $extra =~ /$Extra_Header_Re/xo;

            $self->{todo} = { map { $_ => 1 } split /\s+/, $todo } if $todo;

            $self->{skip_all} = $reason if defined $skip and $skip =~ /^Skip/i;
        }

        return $YES;
    }
    else {
        return $NO;
    }
}

=item B<_is_test>

  my $is_test = $strap->_is_test($line, \%test);

Checks if the $line is a test report (ie. 'ok/not ok').  Reports the
result back in %test which will contain:

  ok            did it succeed?  This is the literal 'ok' or 'not ok'.
  name          name of the test (if any)
  number        test number (if any)

  type          'todo' or 'skip' (if any)
  reason        why is it todo or skip? (if any)

If will also catch lone 'not' lines and note them in $strap->{_saw_lone_not}.

=cut

my $Report_Re = <<'REGEX';
                 ^
                  (not\ )?               # failure?
                  ok\b
                  (?:\s+(\d+))?         # optional test number
                  \s*
                  (.*)                  # and the rest
REGEX

my $Extra_Re = <<'REGEX';
                 ^
                  (.*?) (?:(?:[^\\]|^)# (.*))?
                 $
REGEX

sub _is_test {
    my($self, $line, $test) = @_;

    # We pulverize the line down into pieces in three parts.
    if( my($not, $num, $extra)    = $line  =~ /$Report_Re/ox ) {
        my($name, $control) = split /(?:[^\\]|^)#/, $extra if $extra;
        my($type, $reason)  = $control =~ /^\s*(\S+)(?:\s+(.*))?$/ if $control;

        $test->{number} = $num;
        $test->{ok}     = $not ? 0 : 1;
        $test->{name}   = $name;

        if( defined $type ) {
            $test->{type}   = $type =~ /^TODO$/i ? 'todo' :
                              $type =~ /^Skip/i  ? 'skip' : 0;
        }
        else {
            $test->{type} = '';
        }
        $test->{reason} = $reason if $reason;

        return $YES;
    }
    else{
        # Sometimes the "not " and "ok" will be on seperate lines on VMS.
        # We catch this and remember we saw it.
        if( $self->{_is_vms} && $line =~ /^not\s+$/ ) {
            $self->{_saw_lone_not} = $self->{line};
        }

        return $NO;
    }
}

=item B<_is_bail_out>

  my $is_bail_out = $strap->_is_bail_out($line, \$reason);

Checks if the line is a "Bail out!".  Places the reason for bailing
(if any) in $reason.

=cut

sub _is_bail_out {
    my($self, $line, $reason) = @_;

    if( $line =~ /^Bail out!\s*(.*)/i ) {
        $$reason = $1 if $1;
        return $YES;
    }
    else {
        return $NO;
    }
}

=item B<_reset_file_state>

  $strap->_reset_file_state;

Resets things like $strap->{max}, $strap->{skip_all}, etc... so its
ready to parse the next file.

=cut

sub _reset_file_state {
    my($self) = shift;

    delete @{$self}{qw(max skip_all todo)};
    $self->{line}       = 0;
    $self->{saw_header} = 0;
    $self->{'next'}       = 1;
}

=back

=end _private


=head2 Results

The %results returned from analyze() contain the following information:

  max               total tests which should have been run
  seen              total tests actually seen
  skip_all          if the whole test was skipped, this will 
                      contain the reason.

  ok                number of tests which passed 
                      (including todo and skips)

  todo              number of todo tests seen
  bonus             number of todo tests which 
                      unexpectedly passed

  skip              number of tests skipped

So a successful test should have max == seen == ok.


There is one final item, the summary.

  summary           an array ref reporting the result of 
                    each test looks like this:

    $results{summary}[$test_num] = 
            { ok        => is the test considered ok?
              actual_ok => did it literally say 'ok'?
              name      => name of the test (if any)
              type      => 'skip' or 'todo' (if any)
              reason    => reason for the above (if any)
            };

  Element 0 is unused (but reserved for future use).

=begin _private

=over 4

=item B<_summarize>

  my %summary = $strap->_summarize($pass, \%test);

Generates the summary based on the last test line seen.  $pass is true
if it was considered to be a passed test.  %test is the results of the
test you're summarizing.

=cut

sub _summarize {
    my($self, $pass, $test) = @_;

    my %summary = ( ok         => $pass,
                    actual_ok  => $test->{ok}
                  );

    assert( !(grep !defined $summary{$_}, keys %summary),
            'test contains the ok and actual_ok info' );

    foreach my $piece (qw(name type reason)) {
        $summary{$piece} = $test->{$piece} if $test->{$piece};
    }

    return %summary;
}

=end _private

=back

=head1 NOTES

Test::Harness::Straps will run fine under taint mode.

=head1 AUTHOR

Michael G Schwern E<lt>schwern@pobox.comE<gt>

=head1 SEE ALSO

L<Test::Harness>, L<Test::Harness::Assert>

=cut


1;

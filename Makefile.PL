require 5.004;

use ExtUtils::MakeMaker;
use ExtUtils::Command qw( touch rm_f );

warn "Test::Harness likes to have Devel::CoreStack, but doesn't require it.\n"
  unless eval { require Devel::CoreStack; 1 };

use constant FLAG_SKIP_PROVE => "t/SKIP-PROVE";

my %parms = (
    NAME            => "Test::Harness",
    VERSION_FROM    => "lib/Test/Harness.pm",
    PREREQ_PM       => { File::Spec => 0.6 },
    INSTALLDIRS     => 'perl',
);

my $install_prove = eval { require Pod::Usage; 1 };
if ( $install_prove ) {
    $parms{EXE_FILES} = [ 'bin/prove' ];
    local @ARGV = FLAG_SKIP_PROVE;
    rm_f();
} else {
    warn "Pod::Usage not found, so prove utility will not be installed.\n";
    local @ARGV = FLAG_SKIP_PROVE;
    touch();
}

WriteMakefile( %parms );


# If PERL_TEST_ALL is set, run "make test" against other perls
# as well as the current perl.
{
    package MY;

    sub test_via_harness {
        my($self, $orig_perl, $tests) = @_;

        my @other_perls = qw(bleadperl
                             perl5.6.1
                             perl5.6.0
                             perl5.5.3
                             perl5.4.0
                            );

        my @perls = ($orig_perl);
        push @perls, @other_perls if $ENV{PERL_TEST_ALL};

        my $out;
        foreach my $perl (@perls) {
            $out .= $self->SUPER::test_via_harness($perl, $tests);
        }
        $out =~ s{"?-I\$\(PERL_\w*LIB\)"?}{}g;

        return $out;
    }
}


## We'll try this later once I've made the failing tests nicer.
# package MY;
# sub MY::test {
#     my $test = shift->SUPER::test(@_);
#     $test =~ s|t/\*\.t|t/*.t 2>&1 \| \$(PERL) t/filter_test_out|;
#     return $test;
# }

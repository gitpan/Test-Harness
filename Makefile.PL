# A template for Makefile.PL used by Arena Networks.
# - Set the $PACKAGE variable to the name of your module.
# - Set $LAST_API_CHANGE to reflect the last version you changed the API 
#   of your module.
# - Fill in your dependencies in PREREQ_PM
# Alternatively, you can say the hell with this and use h2xs.

require 5.004;

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

$PACKAGE = 'Test::Harness';
($PACKAGE_FILE = $PACKAGE) =~ s|::|/|g;
$LAST_API_CHANGE = 0;

eval "require $PACKAGE";

unless ($@) { # Make sure we did find the module.
    print <<"CHANGE_WARN" if ${$PACKAGE.'::VERSION'} < $LAST_API_CHANGE;

NOTE: There have been API changes between this version and any older
than version $LAST_API_CHANGE!  Please read the Changes file if you
are upgrading from a version older than $LAST_API_CHANGE.

CHANGE_WARN
}


warn "Test::Harness likes to have Devel::CoreStack, but doesn't require it.\n"
  unless eval { require Devel::CoreStack; 1 };

WriteMakefile(
    NAME            => $PACKAGE,
    VERSION_FROM    => "lib/$PACKAGE_FILE.pm", # finds $VERSION
    PREREQ_PM       => { },
    INSTALLDIRS     => 'perl',
);


# If PERL_TEST_ALL is set, run "make test" against other perls
# as well as the current perl.
{
    package MY;

    sub test_via_harness {
        my($self, $orig_perl, $tests) = @_;

        my @other_perls = qw(bleadperl
                             perl5.6.1
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

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

warn "\a\a\a", <<'UNSTABLE_WARN';
***WARNING***WARNING***WARNING***WARNING***WARNING***WARNING***WARNING***
As of version 1.18, Test::Harness is now **UNSTABLE!**

Its undergoing an incremental internal refactoring as well as
back-porting to older perls (< 5.7.0).  There are no known bugs, but
it hasn't been well enough tested for such a critical module.

                ** USE AT YOUR OWN RISK!!! **

However, please run the tests and report their success or failure to
me along with your architecture and Perl version.

I'll pause for a few seconds to allow you to reflect on this...
kill me now if you have any doubts!

UNSTABLE_WARN

sleep 15;        # give a chance to kill this

warn <<'MORE_WARNING';
Ok, your funeral.

I'll install myself in site_perl instead of with the core libraries
for now.  Use "perl Makefile.PL INSTALLDIRS=perl" or
"make install UNINST=1" to put me into the core.
***WARNING***WARNING***WARNING***WARNING***WARNING***WARNING***WARNING***
MORE_WARNING

warn "Test::Harness likes to have Devel::CoreStack, but doesn't require it.\n"
  unless eval { require Devel::CoreStack; 1 };

WriteMakefile(
    NAME            => $PACKAGE,
    VERSION_FROM    => "lib/$PACKAGE_FILE.pm", # finds $VERSION
    PREREQ_PM       => { },
#    INSTALLDIRS     => 'perl',
    'dist'          => { COMPRESS   => 'gzip -9',
                         SUFFIX     => '.gz',
                         DIST_DEFAULT   => 'all tardist',
                       },
);


## We'll try this later once I've made the failing tests nicer.
# package MY;
# sub MY::test {
#     my $test = shift->SUPER::test(@_);
#     $test =~ s|t/\*\.t|t/*.t 2>&1 \| \$(PERL) t/filter_test_out|;
#     return $test;
# }

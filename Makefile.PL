use 5.008005;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Pod::WSDL',
    VERSION_FROM      => 'lib/Pod/WSDL.pm', # finds $VERSION
    PREREQ_PM         => {'XML::Writer' => 0.531,
    	'IO::Scalar' => 2.110,
    	'XML::XPath' => 1.13,
    	'XML::XPath' => 1.13,
    	'Pod::Text' => 2.21},
    ($] >= 5.006 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Pod/WSDL.pm', # retrieve abstract from module
       AUTHOR         => 'Tarek Ahmed <luke.lubbock -at- gmx.net>') : ()),
);

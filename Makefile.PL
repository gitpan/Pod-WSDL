
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Creates WSDL documents from (extended) pod",
  "AUTHOR" => "Tarek Ahmed <bloerch -at- oelbsk.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Pod-WSDL",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Pod::WSDL",
  "PREREQ_PM" => {
    "Carp" => "1.03",
    "IO::Scalar" => "2.110",
    "Pod::Text" => "2.21",
    "Test::More" => "0.47",
    "Test::XML" => 0,
    "XML::Writer" => "0.531",
    "XML::XPath" => "1.13"
  },
  "TEST_REQUIRES" => {},
  "VERSION" => "0.062",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Carp" => "1.03",
  "IO::Scalar" => "2.110",
  "Pod::Text" => "2.21",
  "Test::More" => "0.47",
  "Test::XML" => 0,
  "XML::Writer" => "0.531",
  "XML::XPath" => "1.13"
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);




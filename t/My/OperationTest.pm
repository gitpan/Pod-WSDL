package My::OperationTest;

=begin WSDL

_IN in $string
_FAULT My::Foo
_RETURN $string
_DOC bla bla

=cut

sub testGeneral {}

=begin WSDL

_IN in $string
_OUT out $string
_INOUT inout $string

=cut

sub testInOut {}

=begin WSDL

_IN in @string
_RETURN @string

=cut

sub testArray {}

sub testWithoutPod {}

1;

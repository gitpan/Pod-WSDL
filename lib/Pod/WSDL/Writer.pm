package Pod::WSDL::Writer;

use strict;
use warnings;
use XML::Writer;
use Pod::WSDL::Utils ':writexml';

our $AUTOLOAD;
our $VERSION = "0.02";

our $INDENT_CHAR = "\t";
our $NL_CHAR     = "\n";

sub new {
	my ($pkg, %data) = @_;

	$data{pretty} ||= 0;
	$data{withDocumentation} ||= 0;
	
	my $outStr = "";

	my $me = bless {
		_pretty              => $data{pretty},
		_withDocumentation   => $data{withDocumentation},
		_outStr              => \$outStr,
		_writer              => undef,
		_indent              => 1,
		_lastTag             => '',
		_faultMessageWritten => {},
	}, $pkg;

	$me->{_writer} = new XML::Writer(OUTPUT => $me->{_outStr});
	$me->{_writer}->xmlDecl("UTF-8");

	return $me;	
		
}

sub wrNewLine {
	my $me  = shift;
	my $cnt = shift;

	$cnt ||= 1;

	return unless $me->{_pretty};

	$me->{_writer}->characters($NL_CHAR x $cnt);
}

sub wrElem {
	my $me     = shift;
	my $type   = shift;

	if ($me->{_pretty}) {
		if ($me->{_lastTag} eq $START_PREFIX_NAME and ($type eq $START_PREFIX_NAME or $type eq $EMPTY_PREFIX_NAME)) {
			$me->{_indent}++;
		} elsif ($me->{_lastTag} ne $START_PREFIX_NAME and $type eq $END_PREFIX_NAME) {
			$me->{_indent}--;
		}
		
		$me->{_lastTag} = $type;

		$me->{_writer}->characters($INDENT_CHAR x $me->{_indent});
	}

	$type .= 'Tag';
	$me->{_writer}->$type(@_);

	$me->wrNewLine;
}

sub wrDoc {
	my $me  = shift;
	my $txt = shift;

	return unless $me->{_withDocumentation};

	$txt ||= '';
	$txt =~ s/\s+$//;
		
	return unless $txt;
	
	$me->{_writer}->characters($INDENT_CHAR x ($me->{_indent} + ($me->{_lastTag} eq $START_PREFIX_NAME ? 1 : 0))) if $me->{_pretty};
	$me->{_writer}->startTag("wsdl:documentation");
	$me->{_writer}->characters($txt);
	$me->{_writer}->endTag("wsdl:documentation");
	$me->wrNewLine;
}

sub output {
	return ${$_[0]->{_outStr}};
}

sub withDocumentation {
	my $me = shift;
	my $arg = shift;
	
	if (defined $arg) {
		$me->{_withDocumentation} = $arg;
		return $me;
	} else {
		return $me->{_withDocumentation};
	}
}

sub registerWrittenFaultMessage {
	my $me = shift;
	my $arg = shift;
	
	return $me->{_faultMessageWritten}->{$arg} = 1;
}

sub faultMessageWritten {
	my $me = shift;
	my $arg = shift;
	
	return $me->{_faultMessageWritten}->{$arg};
}

sub AUTOLOAD {
    my $me     = shift;
    
    my $method   = $AUTOLOAD;
    $method =~ s/.*:://;

    if ($method eq "DESTROY"){
		return;
    } else {
    	no strict 'refs';
    	$me->{_writer}->$method(@_);
    }
}

1;
__END__

=head1 NAME

Pod::WSDL::Writer - Writes XML output for Pod::WSDL

=head1 SYNOPSIS

  use Pod::WSDL::Writer;
  my $wr = new Pod::WSDL::Writer(pretty => 1, withDocumentation => 1);

=head1 DESCRIPTION

This module is used internally by Pod::WSDL. By using AUTOLOADing it delegates all unknown methods to XML::Writer. It is unlikely that you have to interact directly with it. If that is the case, take a look at the code, it is rather simple.

=head1 METHODS

=head2 new

Instantiates a new Pod::WSDL::Writer. The method can take two parameters C<pretty> with a true value triggers  pretty printing of the WSDL output. C<withDocumentation> with a true value produces a WSDL docuemnt containing documentation for types and methods.

=head2 wrNewLine

Has XML::Writer write a newline

=head2 wrElem

Has XML::Writer write an Element. The first argument is one of (empty|start|end), to write an empty element, a start or an end tag. The second argument signifies the name of the tag. All further arguments are attributes of the tag (does not work, when first argument is 'end')

=head2 wrDoc

Writes the string passed to the method as a <wsdl:documentation> Element

=head2 registerWrittenFaultMessage

There needs to be only one fault message per fault type. Here the client class can register fault types already written. The fault name is passed as the single argument to this method.

=head2 faultMessageWritten

Counterpart to registerWrittenFaultMessage. The client can ask if a fault message has already written. The fault name is passed as the single argument to this method.

=head2 output

Returns XML output.

=head1 EXTERNAL DEPENDENCIES

  XML::Writer

=head1 EXAMPLES

see Pod::WSDL

=head1 BUGS

see Pod::WSDL

=head1 TODO

see Pod::WSDL

=head1 SEE ALSO

  Pod::WSDL
 
=head1 AUTHOR

Tarek Ahmed, E<lt>luke.lubbock -the character every email address contains- gmx.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Tarek Ahmed

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut

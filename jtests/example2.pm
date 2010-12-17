package ADSL_Coverage::SOAP::Webservice::HasULLSimple;

use strict;
use warnings;

import SOAP::Data 'type', 'uri', 'attr', 'name';
use Sonaecom::Logger;
use XML::Simple;
use Data::Dumper;

use LWP::UserAgent;

=begin WSDL

    _RETURN $boolean Resultado do calculo da elegibilidade

=end WSDL
=cut 

my $base_remote_coverage_url     = 'http://elegibilidade.sonaecom.pt/';
my $base_remote_zip_coverage_url = 'http://elegibilidade.sonaecom.pt/cp7/';

my $logger = Sonaecom::Logger->get_logger();

sub has_ull_coverage {
    my $s = shift;
    my ( $dn, $cp ) = @_;

    if ( !$dn && !$cp ) {
        die SOAP::Fault->faultcode( '101' )
            ->faultstring( 'Parametros invalidos' );
    }

    if ( $dn && ($dn !~ /^\d{9}$/) ) {
        die SOAP::Fault->faultcode( '103' )
            ->faultstring( 'Numero de telefone invalido' );
    }

    if ( $cp && $cp !~ /^(\d{7}|\d{4})$/ ) {
        die SOAP::Fault->faultcode( '102' )
            ->faultstring( 'CPinvalido' );
    }

    if ( $dn ) {
        return SOAP::Data->name( 'has_ull_coverageReturn',
                                 SOAP::Data->type(
                                          'boolean' => $s->_has_ull_by_dn( $dn )
                                 )
        );
    }
    return SOAP::Data->name( 'has_ull_coverageReturn',
                             SOAP::Data->type(
                                          'boolean' => $s->_has_ull_by_cp( $cp )
                             )
    );
}

sub _fetch_and_parse {
    my $s              = shift;
    my $url            = shift;
    my $parser_options = shift || {};

    $logger->debug( "Fetching $url" );

    my $ua   = LWP::UserAgent->new();
    my $resp = $ua->get( $url );

    if ( !$resp->is_success ) {
        $logger->error( 'Got ' . $resp->status_line . " for: $url" );
        die SOAP::Fault->faultcode( '1' )
            ->faultstring( 'Servico temporariamente indisponivel' );
    }

    my $ref = undef;
    eval {
        my $parser = XML::Simple->new();
        $ref = $parser->XMLin( $resp->content, %{$parser_options} );
    };
    if ( !$ref ) {
        $logger->error( "Failed to parse XML: $@" );
        die SOAP::Fault->faultcode( '1' )
            ->faultstring( 'Servico temporariamente indisponivel' );
    }
    $logger->debug( Dumper( $ref ) );
    return $ref;
}

sub _has_ull_by_cp {
    my $s  = shift;
    my $cp = shift;

    my $url = "$base_remote_zip_coverage_url?cp=$cp&list=clix";

    my $ref = $s->_fetch_and_parse( $url, {} );

    my $has_ull = 0;
    if ( $ref->{'return_code'} ne '0' ) {
        $logger->error(   'Error from remote service. XML return_code: '
                        . $ref->{'return_code'} . q{:}
                        . $ref->{'message'} );

        die SOAP::Fault->faultcode( '1' )
            ->faultstring( 'Servico temporariamente indisponivel' );
    }
    if ( $ref->{'is_valid'} == 1 ) {
        $has_ull = 1;
    }
    return $has_ull;
}

sub _has_ull_by_dn {
    my $s  = shift;
    my $dn = shift;

    my $url = sprintf( '%s?phonenum=%s&policy=negative&tag=clixadsl&source=NOVIS',
                       $base_remote_coverage_url,
                       $dn );

    my $ref = $s->_fetch_and_parse(
                              $url,
                              {  'forcearray' => [ 'item',
                                                   'lista',
                                                   'infosource' ]
                              }
    );

    my $has_ull = 0;
    eval {
        if (    $ref->{'infosource'}->[0]->{'cobertura'}
             && $ref->{'infosource'}->[0]->{'cobertura'} == 1 ) {
            $has_ull = 1;
        }
    };
    if ( $@ ) {
        $logger->error( "Invalid XML struct: $@" );
        die SOAP::Fault->faultcode( '1' )
            ->faultstring( 'Servico temporariamente indisponivel' );
    }
    return $has_ull;
}

1;

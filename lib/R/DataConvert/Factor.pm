package R::DataConvert::Factor;

use strict;
use warnings;

use R::DataConvert::PDL;
use PDL::Factor;
use Scalar::Util qw(blessed);

sub convert_r_to_perl {
	my ($self, $data) = @_;
	if( R::DataConvert->check_r_sexp($data) ) {
		if( $data->r_class eq 'factor' ) {
			return convert_r_to_perl_factor(@_);
		}
	}
	die "could not convert";
}

sub convert_r_to_perl_factor {
	my ($self, $data) = @_;

	my $r_levels = $data->attrib( "levels" );
	my $levels = R::DataConvert->convert_r_to_perl( $r_levels);
	my $data_int = R::DataConvert::PDL->convert_r_to_perl_intsxp( $data );
	unshift @$levels, undef; # undef for index 0 for levels: because R starts at 1
	my $f = PDL::Factor->new( integer => $data_int->unpdl, levels => $levels );
	return $f;
}

sub convert_perl_to_r {
	my ($self, $data) = @_;
	if( blessed($data) && $data->isa('PDL::Factor') ) {
		return convert_perl_to_r_factor(@_);
	}
	die "could not convert";
}

sub convert_perl_to_r_factor {
	my ($self, $data) = @_;
	my $pdl_data = $data->{PDL}->copy;
	my $levels = $data->levels;
	if( not defined $levels->[0] ) {
		shift @$levels; # TODO this is because R is 1-based and we put in an undef when converting
	} else {
		$pdl_data += 1; # we increment so that 0 -> 1, 1 -> 2, etc.
	}
	my $fac_r = R::DataConvert::PDL->convert_perl_to_r_PDL_ndims_1($pdl_data);
	$fac_r->attrib( 'levels', R::DataConvert->convert_perl_to_r( $levels ) );
	$fac_r->attrib( 'class', R::DataConvert->convert_perl_to_r('factor') );
	return $fac_r;
}

1;

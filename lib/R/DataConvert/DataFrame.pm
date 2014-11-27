package R::DataConvert::DataFrame;

use strict;
use warnings;

use R::DataConvert::PDL;
use Data::Frame;
use Scalar::Util qw(blessed);
use List::AllUtils;

sub convert_r_to_perl {
	my ($self, $data) = @_;
	if( R::DataConvert->check_r_sexp($data) ) {
		if( $data->r_class eq 'data.frame' ) {
			return convert_r_to_perl_dataframe(@_);
		}
	}
	die "could not convert";
}

sub convert_r_to_perl_dataframe {
	my ($self, $data) = @_;

	my $data_list = R::DataConvert::Perl->convert_r_to_perl_vecsxp( $data );
	my $col_names = R::DataConvert->convert_r_to_perl($data->attrib( "names" ));
	my $row_names = R::DataConvert->convert_r_to_perl($data->attrib( "row.names" ));
	my $colspec = [ List::AllUtils::mesh @$col_names, @$data_list ];
	my $df = Data::Frame->new( columns => $colspec );
	$df->row_names( $row_names );
	return $df;
}

sub convert_perl_to_r {
	my ($self, $data) = @_;
	if( blessed($data) && $data->isa('Data::Frame') ) {
		return convert_perl_to_r_dataframe(@_);
	}
	die "could not convert";
}

sub convert_perl_to_r_dataframe {
	my ($self, $data) = @_;
	my $df_colarray = [ map { $data->nth_column($_) } 0..$data->number_of_columns-1 ];
	my $df_r = R::DataConvert::Perl->convert_perl_to_r_arrayref( $df_colarray );
	$df_r->attrib( 'names', R::DataConvert->convert_perl_to_r( $data->column_names ) );
	$df_r->attrib( 'row.names', R::DataConvert::Perl->convert_perl_to_r_string( $data->row_names->unpdl ) );
	$df_r->attrib( 'class', R::DataConvert->convert_perl_to_r('data.frame') );
	return $df_r;
}

1;

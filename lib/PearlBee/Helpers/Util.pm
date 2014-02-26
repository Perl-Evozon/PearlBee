package PearlBee::Helpers::Util;

use Data::GUID;

require Exporter;
our @ISA 		= qw(Exporter);
our @EXPORT_OK 	= qw/generate_crypted_filename generate_new_slug_name/;

=head

Generate a unique filename using GUID

=cut

sub generate_crypted_filename {
  	my $guid 	 = Data::GUID->new;
  	my $filename = $guid->as_string;

  	return $filename;
}

=head

Generate a new slug name based on existing slug names

=cut

sub generate_new_slug_name {
	my ( $original_slug, $similar_slugs ) = @_;

	# Extract only the slugs that matter: the slugs with this pattern: $original_slug-number	
	my @slugs_of_interest = grep { $_ =~ /^${original_slug}-\d*$/ } @{ $similar_slugs };

	my $max_number = 0;
	foreach ( @slugs_of_interest ) {
		my @parts = split('-', $_);
		my $number = $parts[-1];											# Get the number at the end of the slugs
		
		$max_number = ( $max_number < $number ) ? $number : $max_number;	# Find the biggest one
	}

	my $new_slug_name = $original_slug . '-' . ++$max_number;				# Generate the new slug name

    return $new_slug_name;
}

1;
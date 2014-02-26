package PearlBee::Helpers::Util;

use Time::HiRes qw(time);
use DateTime::Format::Strptime;
use POSIX qw(strftime);
use Digest::SHA1 qw(sha1_hex);

require Exporter;
our @ISA 		= qw(Exporter);
our @EXPORT_OK 	= qw/generate_crypted_filename generate_new_slug_name/;

=head

Generate a random string based on the current time and date

TODO: do not use localtime, ps or any other fake random source for random names, colisions will occur under sufficient stress

use Data::GUID

=cut

sub generate_crypted_filename {
  	my $t = time;
  	my $date = strftime "%Y%m%d %H:%M:%S", localtime $t;
  	$date .= sprintf ".%03d", ( $t - int($t) ) * 1000;    # without rounding
  	$date = sha1_hex($date);

  	return $date;
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
package PearlBee::Helpers::Captcha;

use Dancer2;
use Authen::Captcha;

require Exporter;
our @ISA 	= qw(Exporter);
our @EXPORT	= qw/generate/;

=head

Generate a secret code

=cut

sub generate {

	my $self = shift;

	# Generate a new captcha code
    my $captcha = Authen::Captcha->new();

    # set the data_folder. contains flatfile db to maintain state
    $captcha->data_folder( config->{captcha_folder} );

    # set directory to hold publicly accessable images
    $captcha->output_folder( config->{captcha_folder} .'/image' );
    my $md5sum = $captcha->generate_code(5);

   return $md5sum;

}
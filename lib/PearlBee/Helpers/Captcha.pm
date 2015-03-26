package PearlBee::Helpers::Captcha;

use Dancer2;
use Authen::Captcha;

require Exporter;
our @ISA 	= qw(Exporter);
our @EXPORT	= qw/generate $captcha/;

our $captcha = Authen::Captcha->new(
  data_folder => config->{captcha_folder},
  output_folder => config->{captcha_folder} .'/image',
);

=head

Generate a secret code

=cut

sub generate {

	my $self = shift;

	# Generate a new captcha code

    my $md5sum = $captcha->generate_code(5);
    
    return $md5sum;
}
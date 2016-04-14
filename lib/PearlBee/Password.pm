package PearlBee::Password;

use Digest;
use Digest::Bcrypt;
use Data::Entropy::Algorithms qw(rand_bits);
use MIME::Base64 qw(encode_base64 decode_base64);

require Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(generate_hash);

# Input: A string containing a password and optionally a salt encoded in base64 (from the database for example)
# Output: A hashref containing a salt and a hash. (keys are 'salt' and 'hash') If you provided the salt than the salt in the hashref will be the same.

=head2 generate_hash

Return the hashed version of the password

=cut

sub generate_hash {
    return -1 if @_ < 1 || @_ > 2;
	
    my $password = shift;
    my $hashref = {};

    my $bcrypt = Digest->new('Bcrypt');
    $bcrypt->cost(12);
    my @alpha  = ( 'a' .. 'z', 'A' .. 'Z', 0 .. 9 );
    my $salt   = join '', map $alpha[ rand @alpha ], 1 .. 16;
    $bcrypt->salt($salt);
    $bcrypt->add($password);

    $hashref->{hash} = $bcrypt->hexdigest;
	
    return $hashref;
}

1;

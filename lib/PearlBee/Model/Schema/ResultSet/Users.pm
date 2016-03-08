package  PearlBee::Model::Schema::ResultSet::Users;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head1 Create user with pre-hashed password

=cut

sub create_hashed {
  my ($self, $args) = @_;
  my $schema  = $self->result_source->schema;

  my @alpha  = ( 'a' .. 'z', 'A' .. 'Z', 0 .. 9 );
  my $salt   = join '', map $alpha[ rand @alpha ], 1 .. 16;

#  my $crypt_sha = '$6$' .
#                  $salt .
#                  '$' .
#                  Digest::SHA::sha512_base64( $salt . $params->{'password'} );
#  #crypt( $salt, '$6$'.$args->{password} );
#  crypt( '$6$' . $salt, $args->{password} );
#  my $crypted = (split /\$/,$crypt_sha)[-1];
#  $crypted = '$6$' . $salt . '$' . $crypted;
#warn $crypted;
#
  my $algo   = '$6$' . $salt . '$';
  #my $hashed = crypt( $algo, $args->{password} );
  my $hashed = crypt( $args->{password}, $algo );

  $schema->resultset('Users')->create({
    username       => $args->{username},
    password       => $hashed,
    email          => $args->{email},
    name           => $args->{name},
    role           => $args->{role},
    status         => $args->{status},
    activation_key => $args->{activation_token}
  });
}

1;

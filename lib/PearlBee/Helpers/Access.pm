package PearlBee::Helpers::Access;

use strict;
use warnings;

use Scalar::Util qw( blessed );

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;
#use PearlBee::Model::Schema;

use base qw( Exporter );
our @EXPORT_OK = qw( has_ability );

=item has_ability( $user, $ability )

Does user $user have ability $ability?

=cut

sub has_ability {
  my ($user, $ability) = @_;
  my $role = 'visitor';

  if ( $user->{role} ) {
    $role = $user->{role};
  }

  unless ( $ability ) {
    info "No ability provided"; # XXX Choose defaults
    return;
  }

  my $acl = resultset('Acl')-> find({ name => $role, ability => $ability });
  return $acl ? 1 : 0;
}

1;

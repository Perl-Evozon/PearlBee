package PearlBee::Routes::Avatar;

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;
use PearlBee::Helpers::Util qw(map_pages);
use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link);

our $VERSION = '0.1';

# Internal note here - Keep the Routes/ directory clean of little "handlers".
# Given the history of the application anything added here will be replicated
# all over h*ll.

get '/avatar-light' => sub { config->{'avatar'}{'default'}{'light'} };
get '/avatar-dark'  => sub { config->{'avatar'}{'default'}{'dark'}  };

=head2 Blog assets - XXX this should be managed by nginx or something.

=cut

get '/avatar/:combo_breaker/:username' => sub {
  my $username = route_parameters('username');

  redirect "/avatar/$username"
};

=head2 Avatar route that just returns the theme-based image

=cut

get '/avatar/' => sub {
  my $avatar_path = config->{'avatar'}{'default'}{'dark'};
  my $theme       = session( 'theme' ) || 'dark';

  if ( $theme eq 'light' ) {
    $avatar_path = config->{'avatar'}{'default'}{'light'}
  }

  send_file $avatar_path;
};

=head2 Avatar username

=cut

get '/avatar/:username' => sub {
  my $username      = route_parameters->{'username'};
  my $user          = resultset( 'Users' )->find({ username => $username });
  my $avatar_config = config->{'avatar'};
  my $avatar_path   = $avatar_config->{'default'}{'dark'};
  my $theme         = session( 'theme' );

  if ( $user->avatar_path ne '' ) {
    my $path = $user->avatar_path;
    $avatar_path = $path if -e "public/$path";
  }
  elsif ( $theme and $theme eq 'light' ) {
    $avatar_path = $avatar_config->{'default'}{'light'}
  }

  return send_file $avatar_path;
};

1;

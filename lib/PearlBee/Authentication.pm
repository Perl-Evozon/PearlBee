package PearlBee::Authentication;

use Dancer2;
use Dancer2::Plugin::DBIC;
use Digest::SHA1 qw(sha1_hex);

=head

index

=cut

get '/admin' => sub {
  my $user = session('user');

  redirect('/dashboard') if ( $user );
  template 'login', {}, { layout => 'admin' };
};

=head

login metehod

=cut

post '/login' => sub {
  my $password = params->{password};
  my $username = params->{username};

  my $user = resultset("User")->search({
      username => $username,
      password => sha1_hex($password),
      -or => [
        status => 'activated',
        status => 'deactivated'
      ]
    })->first;

  if ( $user ) {
    session user => $user;
    redirect('/dashboard');
  }
  else {
    template 'login', { warning => "Incorrect login" }, { layout => 'admin' };
  }
};

=head

logout method

=cut

get '/logout' => sub {
  context->destroy_session;
  
  template 'login', {}, { layout => 'admin' };
};

true;
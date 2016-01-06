package PearlBee::Authentication;

use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Password;

=head

index

=cut

get '/admin' => sub {
  my $user = session('user');

  redirect('/dashboard') if ( $user );
  template 'login', {}, { layout => 'admin' };
};

=head

login method

=cut

post '/login' => sub {
  my $password = params->{password};
  my $username = params->{username};
  
  my $user = resultset("User")->search({
      username => $username,
      -or => [
      	status => 'active',
      	status => 'inactive'
      ]
    })->first;
  
  unless ( $user ) {
    template 'login', { warning => "Login failed for the provided username/password pair." }, { layout => 'admin' };
  }

  my $password_hash = crypt( $password, $user->password );
  if($user && $user->password eq $password_hash) {
    
    my $user_obj->{is_admin} = $user->is_admin;
    $user_obj->{role}        = $user->role;
    $user_obj->{id}          = $user->id;
    $user_obj->{username}    = $user->username;

    session user => $user_obj;
    session user_id => $user->id;
	
    redirect('/');
  }
  else {
    template 'login', { warning => "Login failed for the provided username/password pair." }, { layout => 'admin' };
  }
};

=head

logout method

=cut

get '/logout' => sub {
  
  context->destroy_session;
  
  session blog_name => resultset('Setting')->first->blog_name unless ( session('blog_name') );
  session app_url   => config->{app_url};

  template 'login', { success => "You were successfully logged out." }, { layout => 'admin' };
};

true;

package PearlBee::Authentication;

use Try::Tiny;
use JSON qw//;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::reCAPTCHA;

use PearlBee::Password;
use PearlBee::Helpers::Email qw( send_email_complete );
use PearlBee::Helpers::Util qw( create_password generate_hash );

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

get '/recover-password' => sub { template 'password_recovery' };

post '/recover-password' => sub {

  my $params = body_parameters;
  my $user   = resultset('Users')->find({ email => $params->{'email'} });
  my $date   = DateTime->now();
  my $token  = generate_hash( $params->{'email'} . $date );
  my $err;

  my $template_params = {
    email => $params->{'email'},
  };

  my $existing_users =
    resultset('Users')->search({ email => $params->{'email'} })->count;
  if ($existing_users == 0) {
    template 'password_recovery', {
      warning => "The email does not exist in the database."
    }; 
  }
  else {

    $user->update({ activation_key => $token });

    my $first_admin =
      resultset('Users')->
      search({ role => 'admin', status => 'active' })->first;
    if ( $first_admin ) {
      $first_admin = $first_admin->email;
    }
    else {
      $first_admin = config->{admin_email_sender};
    }

    try {
      PearlBee::Helpers::Email::send_email_complete({
        template => 'forgot-password.tt',
        from     => config->{'default_email_sender'},
        to       => $first_admin,
        subject  => 'A new user applied as an author to the blog',

        template_params => {
          config    => config,
          name      => $params->{'name'},
          username  => $params->{'username'},
          email     => $params->{'email'},
          signature => config->{'email_signature'}
        }
      });
 
      PearlBee::Helpers::Email::send_email_complete({
        template => 'forgot-password.tt',
        from     => config->{'default_email_sender'},
        to       => $params->{email},
        subject  => 'Reset your blogs.perl.org password',

        template_params => {
          config    => config,
          name      => $user->name,
          username  => $user->username,
          mail_body => "/activation?token=$token",
        }
      });
    }
    catch {
      error $_;
    };

    template 'recover-password', {
      success => 'The password was updated.'
    }
  }
};

get '/register_success' => sub { template 'register_success' };

post '/register_success' => sub {
  my $params   = body_parameters;
  my $response = $params->{'g-recaptcha-response'};
  my $result   = recaptcha_verify($response);
  my $captcha  = recaptcha_display();
  my $err;

  my $template_params = {
    username => $params->{'username'},
    email    => $params->{'email'},
    name     => $params->{'name'},
  };

  unless ( $params->{'username'} ) {
    template 'signup', {
      warning  => "Please provide a username",
      ecaptcha => $captcha
    };
    return
  }

  unless ( $result->{success} || $ENV{CAPTCHA_BYPASS} ) {
    # The user entered the correct secret code
    template 'signup', {
      warning  => "Captcha failed",
      ecaptcha => $captcha
    };
    return
  }

  my $existing_users =
    resultset('Users')->search({ email => $params->{'email'} })->count;
  if ($existing_users > 0) {
    template 'signup', {
      warning  => "An user with this email address already exists.",
      ecaptcha => $captcha
    };
    return
  }

  $existing_users =
    resultset('Users')->search_lc( $params->{username} )->count;
  if ($existing_users > 0) {
    template 'signup', {
      warning  => "The provided username is already in use.",
      ecaptcha => $captcha
    };
    return
  }

  my $date  = DateTime->now();
  my $token = generate_hash( $params->{'email'} . $date );

  resultset('Users')->create_hashed({
    username       => $params->{username},
    password       => $params->{password},
    email          => $params->{email},
    name           => $params->{name},
    role           => 'author',
    status         => 'pending',
    activation_key => $token,
  });

  # Notify the author that a new comment was submitted
  my $first_admin =
    resultset('Users')->search({ role => 'admin', status => 'active' })->first;
  if ( $first_admin ) {
    $first_admin = $first_admin->email;
  }
  else {
    $first_admin = config->{admin_email_sender};
  }
  info "No administrator found in the database!" unless $first_admin;

  try {
     PearlBee::Helpers::Email::send_email_complete({
       template => 'new_user.tt',
       from     => config->{default_email_sender},
       to       => $first_admin,
       subject  => 'A new user applied as an author to the blog',

       template_params => {
         config    => config,
         name      => $params->{'name'},
         username  => $params->{'username'},
         email     => $params->{'email'},
         signature => config->{email_signature}
       }
     });

     PearlBee::Helpers::Email::send_email_complete({
       template => 'activation_email.tt',
       from     => config->{default_email_sender},
       to       => $params->{email},
       subject  => 'Finish setting up your blogs.perl.org account',

       template_params => {
         config    => config,
         name      => $params->{'name'},
         username  => $params->{'username'},
         mail_body => "/activation?token=$token",
       }
     });
  }
  catch {
      error $_;
  };

  template 'register_success';
};

=head1 Add OpenAuth ID to an existing user

=cut

post '/oauth/:username/service/:service/service_id/:service_id' => sub {
  my $username   = route_parameters->{'username'};
  my $service    = route_parameters->{'service'};
  my $service_id = route_parameters->{'service_id'};
  my $user       = resultset('Users')->find(
    \[ 'lower(username) = ?' => $username ] );
  error "No username specified to attach a service to"
    unless $username;
  error "No service name specified to attach a service to"
    unless $service;
  error "No service ID specified to attach a service to"
    unless $service_id;
  try {
    my $user_oauth = resultset("Useroauth")->create(
      user_id    => $user->{id},
      service    => $service,
      service_id => $service_id
    );
  }
  catch {
    error "Could not assign $service ID";
  };
};

=head1 Validate OpenAuth ID for an existing user

=cut

get '/oauth/:service/service_id/:service_id' => sub {
  my $service    = route_parameters->{'service'};
  my $service_id = route_parameters->{'service_id'};
  error "No service name specified to attach a service to"
    unless $service;
  error "No service ID specified to attach a service to"
    unless $service_id;

  my $user;
  try {
    my $user_oauth = resultset('UserOAuth')->
                  find({ service => $service, service_id => $service_id });
    $user       = resultset('Users')->find($user->{id});
  }
  catch {
    return to_json({ username => undef });
  };
  
  return to_json({ username => $user->{username} });
};

get '/login' => sub {
      template 'signup'
};


post '/login' => sub {
  my $password = params->{password};
  my $username = params->{username};

  my $user = resultset("Users")->search( \[
    "lower(username) = ? AND (status = 'active' or status = 'inactive')",
    $username ]
  )->first;
  
  if ( defined $user ) {

    if ( $user->validate($password) ) {
      
      session user    => $user->as_hashref;
      session user_id => $user->id;
      
      redirect('/');
    }
    else {
      template 'signup', { warning => "Login failed for the provided username/password pair." };
    }
  }
  else {
    template 'signup', { warning => "Login failed for the provided username/password pair." };
  }
};

=head

logout method

=cut

get '/logout' => sub {
  
  context->destroy_session;
  
  session blog_name => resultset('Setting')->first->blog_name
    unless ( session('blog_name') );
  session app_url   => config->{app_url};

  redirect "/";
};

true;

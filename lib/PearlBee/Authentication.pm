package PearlBee::Authentication;

use Try::Tiny;
use JSON qw//;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Captcha::reCAPTCHA::V2;

use PearlBee::Password;
use PearlBee::Helpers::Email qw( send_email_complete );
use PearlBee::Helpers::Util qw( create_password generate_hash );

use URI::Encode qw(uri_encode uri_decode);

=head2 /admin route

index

=cut

get '/admin' => sub {
  my $user = session('user');

  redirect('/dashboard') if ( $user );
  template 'login', {}, { layout => 'admin' };
};

=head2 /recover-password route

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

=head2 /register_success route

=cut

get '/register_success' => sub { template 'register_success' };

=head2 /register_success route

=cut

post '/register_success' => sub {
  my $params   = body_parameters;
  my $response = $params->{'g-recaptcha-response'};
  my $rc       = Captcha::reCAPTCHA::V2->new;
  my $result   = $rc->verify(config->{plugins}{reCAPTCHA}{secret} || $ENV{bpo_recaptcha_secret}, $response);
  my $captcha  = $rc->html(config->{plugins}{reCAPTCHA}{site_key} || $ENV{bpo_recaptcha_site_key});
  my $err;

  my $template_params = {
    username => $params->{'username'},
    email    => $params->{'email'},
    name     => $params->{'name'},
  };

  unless ( $params->{'username'} ) {
    return 
    template 'register', {
      error => "Please provide a username",  
      email => $params->{'email'},
      recaptcha => $rc->html(config->{plugins}{reCAPTCHA}{site_key} || $ENV{bpo_recaptcha_site_key})
    };
  }

  unless ( $result->{success} || $ENV{CAPTCHA_BYPASS} ) {
    # The user entered the correct secret code
    return 
    template 'register', {
      error => "Make sure you introduced the captcha",  
      email => $params->{'email'},
      username => $params->{'username'},
      name => $params->{'name'},
      recaptcha => $rc->html(config->{plugins}{reCAPTCHA}{site_key} || $ENV{bpo_recaptcha_site_key})
    }; 
  }

  my $existing_users =
    resultset('Users')->search({ email => $params->{'email'} })->count;
  if ($existing_users > 0) {
    return 
    template 'register', {
      warning => "An user with this email address already exists.",
      email => $params->{'email'},  
      username => $params->{'username'},
      name => $params->{'name'},
      recaptcha => $rc->html(config->{plugins}{reCAPTCHA}{site_key} || $ENV{bpo_recaptcha_site_key})
    };
  }

  $existing_users =
    resultset('Users')->search( \[ 'lower(username) = ?' =>
                                   $params->{username} ] )->count;
  if ($existing_users > 0) {
    return 
    template 'register', {
      warning => "The provided username is already in use.",  
      email => $params->{'email'},
      name => $params->{'name'},
      recaptcha => $rc->html(config->{plugins}{reCAPTCHA}{site_key} || $ENV{bpo_recaptcha_site_key})
    };
  }

  my $date  = DateTime->now();
  my $token = generate_hash( $params->{'email'} . $date );

  resultset('Users')->create_hashed_with_blog({
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

=head2 /oauth/:username/service/:service/service_id/:service_id route

Add OpenAuth ID to an existing user

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

=head2 /oauth/:service/service_id/:service_id

Validate OpenAuth ID for an existing user

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

=head2 /login route

=cut

get '/login' => sub {
    my $template_data = { };
    if ( query_parameters->get('redirect' ) ) {
        $template_data->{redirect} =query_parameters->get('redirect' );
    }
    template 'signup', $template_data;
};

=head2 /login route

=cut

post '/login' => sub {
  my $password = params->{password};
  my $username = params->{username};
  my $redirect = param('redirect') || session('redirect');

  my $user = resultset("Users")->search( \[
    "lower(username) = ? AND (status = 'active' or status = 'inactive')",
    $username ]
  )->first;
  
  if ( defined $user ) {

    if ( $user->validate($password) ) {
      
      session user    => $user->as_hashref;
      session user_id => $user->id;
      
      redirect $redirect || '/';
    }
    else {
      template 'signup', { warning => "Login failed for the provided username/password pair." };
    }
  }
  else {
    template 'signup', { warning => "Login failed for the provided username/password pair." };
  }
};

=head2 /logout route

logout method

=cut

get '/logout' => sub {

  context->destroy_session;

  session blog_name => resultset('Setting')->first->blog_name
    unless ( session('blog_name') );
  session app_url   => config->{app_url};

  redirect "/";
};

=head2 /smlogin route

Route handler for login with various social media services

=cut

get '/smlogin' => sub {
  my $sm_service = params->{socialMediaService};


  if (defined $sm_service) {
    my $base_uri = config->{plugins}->{social_media}->{callback_base_uri} || config->{app_url} ||'http://localhost:5000/';
    my $callback_handler = 'smcallback/'.$sm_service;

    if ($sm_service eq 'facebook') {
      my $facebook_client_id = config->{plugins}->{social_media}->{facebook}->{client_id} || $ENV{bpo_social_media_facebook_client_id};

      my $query_string = 'https://www.facebook.com/dialog/oauth?';
      $query_string .= 'client_id='.$facebook_client_id;
      $query_string .= '&redirect_uri='.uri_encode($base_uri . $callback_handler);

      redirect $query_string;

    } elsif ($sm_service eq 'twitter') {
      # body...
    } elsif ($sm_service eq 'google') {
      # body...
    } elsif ($sm_service eq 'linkedin') {
      # body...
    } elsif ($sm_service eq 'github') {
      # body...
    } elsif ($sm_service eq 'openid') {
      # body...
    } else {
      return "Unsupported social media service.";
    }

  } else {
    return "No social media service specified.";
  }

};

=head2 /smcallback/:sm_service

Route handler for callbacks originating from social media services

=cut

get '/smcallback/:sm_service' => sub {
  my $sm_service = params->{sm_service};

  if ($sm_service eq 'facebook') {
    my $code = query_parameters->get('code');
    my $facebook_client_id = config->{plugins}->{social_media}->{facebook}->{client_id} || $ENV{bpo_social_media_facebook_client_id};
    my $facebook_client_secret = config->{plugins}->{social_media}->{facebook}->{client_secret} || $ENV{bpo_social_media_facebook_client_secret};

# https://graph.facebook.com/v2.3/oauth/access_token?client_id=561229140719641&redirect_uri=http://localhost:5000/smcallback/facebook/&client_secret=76a4673d554bccc603e9fdc9416db685&code=AQAME1qW03oJLWy3WIlJIYu1UDuVwFSaX4wPZLyLAbFYobolkBkjUR7lI2THCiOsTUyErciiVNP2F5nddASBfZ21VyP_wwIZJg0oe3dr4uPFE5u9RqPl5iYjbvE4a2dV9hJFJ0RPGQIKtP2aftW_abO--bFiH-zzAjVekeCzbwCe5HyZ_ATCxiQ5KGz41EMDHv2207xB8nP7zc3YhXexBv9GTeJLyBqoPB6sxmDyZooeX4GkKGPkNgzay5gbMPVHWI1COz13JFssXnxofvpwC2QHL-x1wfOw_p7WO2p5V3jPqFvFs4xxvXAD00aE_GqYHiLMq-oFyFfnXyWC3REm3qJI


    return to_json({
        code => $code,
        service => $sm_service
      })
  } elsif ($sm_service eq 'twitter') {
    # body...
  } elsif ($sm_service eq 'google') {
    # body...
  } elsif ($sm_service eq 'linkedin') {
    # body...
  } elsif ($sm_service eq 'github') {
    # body...
  } elsif ($sm_service eq 'openid') {
    # body...
  } else {
    return "Unsupported social media service.";
  }

};

true;

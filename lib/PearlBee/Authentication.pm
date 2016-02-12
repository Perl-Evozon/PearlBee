package PearlBee::Authentication;

use JSON qw//;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::reCAPTCHA;
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

post '/register_success' => sub {
  my $params = body_parameters;

  my $err;

  my $template_params = {
    username        => $params->{'username'},
    email           => $params->{'email'},
    name            => $params->{'name'},
  };

  my $response = $params->{'g-recaptcha-response'};
  my $result = recaptcha_verify($response);


  if ( $result->{success} || $ENV{CAPTCHA_BYPASS} ) {
    # The user entered the correct secrete code
    eval {

      my $existing_users = resultset('User')->search( { email => $params->{'email'} } )->count;

      if ($existing_users > 0) {
        $err = "An user with this email address already exists.";
      } else {
        $existing_users = resultset('User')->search( \[ 'lower(username) = ?' => $params->{username} ] )->count;
        if ($existing_users > 0) {
          $err = "The provided username is already in use.";
        } else {

          # Create the user
          if ( $params->{'username'} ) {

            # Set the proper timezone
            my $dt       = DateTime->now;
            my $settings = resultset('Setting')->first;
            $dt->set_time_zone( $settings->timezone );

            # Match encryption from MT
            my @alpha  = ( 'a' .. 'z', 'A' .. 'Z', 0 .. 9 );
            my $salt   = join '', map $alpha[ rand @alpha ], 1 .. 16;

            my $crypt_sha  = '$6$' .
                             $salt .
                             '$' .
                             Digest::SHA::sha512_base64( $salt . $params->{'password'} );

            resultset('User')->create({
              username        => $params->{username},
              password        => $crypt_sha,
              email           => $params->{'email'},
              name            => $params->{'name'},
              register_date   => join (' ', $dt->ymd, $dt->hms),
              role            => 'author',
              status          => 'pending'
            });

            # Notify the author that a new comment was submited
            my $first_admin = resultset('User')->search( {role => 'admin', status => 'active' } )->first;

            Email::Template->send( config->{email_templates} . 'new_user.tt',
            {
              From     => config->{default_email_sender},
              To       => $first_admin->email,
              Subject  => 'A new user applied as an author to the blog',

              tt_vars  => {
                name             => $params->{'name'},
                username         => $params->{'username'},
                email            => $params->{'email'},
                signature        => config->{email_signature},
                blog_name        => session('blog_name'),
                app_url          => session('app_url'),
              }
            }) or error "Could not send new_user email";

            my $date             = DateTime->now();
            my $activation_token = generate_hash( $params->{'email'} . $date );
            my $token = $activation_token->{hash};
            Email::Template->send( config->{email_templates} .
                                   'activation_email.tt',
            {
              From     => config->{default_email_sender},
              To       => $params->{'email'},
              Subject  => 'Welcome to Blogs.Perl.Org',

              tt_vars  => {
                name      => $params->{'name'},
                username  => $params->{'username'},
                mail_body => "/activation?token=$token",
              }
            }) or error "Could not send the email";

          } else {
            $err = 'Please provide a username.';
          }
        }
      }
    };
    error $@ if ( $@ );
  }
  else {
    # The secret code inncorrect
    # Repopulate the fields with the data
    $err = "Invalid secret code.";
  }

  if ($err) {
    $template_params->{warning} = $err if $err;
    $template_params->{recaptcha} = recaptcha_display();

    template 'signup', $template_params;
  } else {
    template 'notify', {success => 'The user was created and it is waiting for admin approval.'};
  }
};

=head1 Add OpenAuth ID to an existing user

=cut

post '/oauth/:username/service/:service/service_id/:service_id' => sub {
  my $username   = route_parameters->{'username'};
  my $service    = route_parameters->{'service'};
  my $service_id = route_parameters->{'service_id'};
  my $user       = resultset('User')->find(
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
    $user       = resultset('User')->find($user->{id});
  }
  catch {
    return to_json({ username => undef });
  };
  
  return to_json({ username => $user->{username} });
};


post '/login' => sub {
  my $password = params->{password};
  my $username = params->{username};

  my $user = resultset("User")->search( \[
    "lower(username) = ? AND (status = 'active' or status = 'inactive')",
    $username ]
  )->first;
  
  if ( defined $user ) {
    my $password_hash = crypt( $password, $user->password );
    if($user && $user->password eq $password_hash) {
      
      session user => $user->as_hashref;
      session user_id => $user->id;
  	
      redirect('/');
    }
    else {
      template 'login', { warning => "Login failed for the provided username/password pair." }, { layout => 'admin' };
    }
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

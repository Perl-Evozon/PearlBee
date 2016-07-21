package PearlBee::Authentication;

use Try::Tiny;
use JSON qw//;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Captcha::reCAPTCHA::V2;
use HTTP::Tiny;
use WWW::OAuth;
use WWW::OAuth::Util 'form_urldecode';

use PearlBee::Password;
use PearlBee::Helpers::Email qw( send_email_complete );
use PearlBee::Helpers::Util qw( create_password generate_hash );

use URI::Encode qw(uri_encode uri_decode);
use Data::Dumper;
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

# =head2 /oauth/:username/service/:service/service_id/:service_id route

# Add OpenAuth ID to an existing user

# =cut

# post '/oauth/:username/service/:service/service_id/:service_id' => sub {
#   my $username   = route_parameters->{'username'};
#   my $service    = route_parameters->{'service'};
#   my $service_id = route_parameters->{'service_id'};
#   my $user       = resultset('Users')->find(
#     \[ 'lower(username) = ?' => $username ] );
#   error "No username specified to attach a service to"
#     unless $username;
#   error "No service name specified to attach a service to"
#     unless $service;
#   error "No service ID specified to attach a service to"
#     unless $service_id;
#   try {
#     my $user_oauth = resultset("Useroauth")->create(
#       user_id    => $user->{id},
#       service    => $service,
#       service_id => $service_id
#     );
#   }
#   catch {
#     error "Could not assign $service ID";
#   };
# };

# =head2 /oauth/:service/service_id/:service_id

# Validate OpenAuth ID for an existing user

# =cut

# get '/oauth/:service/service_id/:service_id' => sub {
#   my $service    = route_parameters->{'service'};
#   my $service_id = route_parameters->{'service_id'};
#   error "No service name specified to attach a service to"
#     unless $service;
#   error "No service ID specified to attach a service to"
#     unless $service_id;

#   my $user;
#   try {
#     my $user_oauth = resultset('UserOAuth')->
#                   find({ service => $service, service_id => $service_id });
#     $user       = resultset('Users')->find($user->{id});
#   }
#   catch {
#     return to_json({ username => undef });
#   };
  
#   return to_json({ username => $user->{username} });
# };

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
      setConnectedAccountsOntoSession();
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

  # Generate a state token used in the API handshakes.
  # Generate a random key, save the key=>value pair in-memory
  # Set the token_key in a cookie on the client side for later verification
  my @chars = ("A".."Z", "a".."z");
  my $token_key;
  my $token_value;
  $token_key.= $chars[rand @chars] for 1..10;
  $token_value.= $chars[rand @chars] for 1..10;

  session $token_key => $token_value;
  cookie 'token_key' => $token_key;

  if (defined $sm_service) {
    my $http = HTTP::Tiny->new();
    my $base_uri = config->{plugins}->{social_media}->{callback_base_uri} || config->{app_url} ||'http://localhost:5000/';
    my $callback_handler = 'smcallback/'.$sm_service;

    if ($sm_service eq 'facebook') {
      my $facebook_client_id = config->{plugins}->{social_media}->{facebook}->{client_id} || $ENV{bpo_social_media_facebook_client_id};

      my $query_string = 'https://www.facebook.com/dialog/oauth?';
      $query_string .= 'client_id='.$facebook_client_id;
      $query_string .= '&state='.$token_value;
      $query_string .= '&redirect_uri='.uri_encode($base_uri . $callback_handler);

      redirect $query_string;

    } elsif ($sm_service eq 'twitter') {
      my $twitter_consumer_key = config->{plugins}->{social_media}->{twitter}->{consumer_key} || $ENV{bpo_social_media_twitter_consumer_key};
      my $twitter_consumer_secret = config->{plugins}->{social_media}->{twitter}->{consumer_secret} || $ENV{bpo_social_media_twitter_consumer_secret};

      # Get a request token and a request secret
      my $query_string = 'https://api.twitter.com/oauth/request_token';
      my $cb_url = uri_encode($base_uri . $callback_handler);

      my $oauth = WWW::OAuth->new(
         client_id => $twitter_consumer_key,
         client_secret => $twitter_consumer_secret
       );

      my $res = $oauth->authenticate(Basic => { method => 'POST', url => $query_string }, { oauth_callback => $cb_url })->request_with(HTTP::Tiny->new);

      # Anything but 200 is an error
      if ($res->{status} != 200) {
        return template 'signup', {
          error_header => "Hmm...",
          error => "Failed to communicate with Twitter for some reason."
        };
      };

      my %res_data = @{form_urldecode $res->{content}};
      my ($request_token, $request_secret, $oauth_callback_confirmed) = @res_data{'oauth_token','oauth_token_secret', 'oauth_callback_confirmed'};

      # Verify oauth_callback_confirmed
      if ($oauth_callback_confirmed ne 'true') {
        return template 'signup', {
          error_header => "Oauth callback isn't confirmed",
          error => "Failed to correctly communicate with Twitter. (oauth_callback_confirmed is false)"
        };
      }

      # Redirect the user to authorize the app
      redirect "https://api.twitter.com/oauth/authenticate?oauth_token=".$request_token;

    } elsif ($sm_service eq 'google') {

      my $google_client_id = config->{plugins}->{social_media}->{google}->{client_id} || $ENV{bpo_social_media_google_client_id};

      my $query_string = 'https://accounts.google.com/o/oauth2/v2/auth?';
      $query_string .= 'scope=openid%20email%20profile%20';
      $query_string .= '&client_id='.$google_client_id;
      $query_string .= '&state='.$token_value;
      $query_string .= '&response_type=code';
      $query_string .= '&redirect_uri='.uri_encode($base_uri . $callback_handler);

      redirect $query_string;

    } elsif ($sm_service eq 'github') {

      my $github_client_id = config->{plugins}->{social_media}->{github}->{client_id} || $ENV{bpo_social_media_github_client_id};

      my $query_string = 'https://github.com/login/oauth/authorize?';
      $query_string .= '&client_id='.$github_client_id;
      $query_string .= '&state='.$token_value;
      $query_string .= '&response_type=code';
      $query_string .= '&redirect_uri='.uri_encode($base_uri . $callback_handler);

      redirect $query_string;

    } elsif ($sm_service eq 'linkedin') {

      my $linkedin_client_id = config->{plugins}->{social_media}->{linkedin}->{client_id} || $ENV{bpo_social_media_linkedin_client_id};

      my $query_string = 'https://www.linkedin.com/uas/oauth2/authorization?';
      $query_string .= '&client_id='.$linkedin_client_id;
      $query_string .= '&response_type=code';
      $query_string .= '&state='.$token_value;
      $query_string .= '&redirect_uri='.uri_encode($base_uri . $callback_handler);

      redirect $query_string;

    } elsif ($sm_service eq 'openid') {

      return template 'signup', {
        error_header => "Deprecated...",
        error => "We're sorry, we do not support OpenID any longer. Please sign in with a different account."
      };

    } else {
      return template 'signup', {
        error => "The social media service specified to connect with is unsupported by us."
      };
    }

  } else {
    return template 'signup', {
      error => "No social media service specified."
    };
  }

};

=head2 /smcallback/:sm_service

Route handler for callbacks originating from social media services

=cut

get '/smcallback/:sm_service' => sub {
  my $sm_service = params->{sm_service};
  my $base_uri = config->{plugins}->{social_media}->{callback_base_uri} || config->{app_url} ||'http://localhost:5000/';
  my $callback_handler = 'smcallback/'.$sm_service;
  my $http = HTTP::Tiny->new();
  my $user;
  my $user_oauth;
  my $userLoggedIn = session('user') || undef;

  # Get the token_value based on the token_key saved on the cookie
  my $token_key = cookie('token_key');
  my $token_value = session($token_key);

  if (!defined $token_value) {
    return template 'signup', {
      error_header => "Gastronomy error",
      error => "Please enable cookeis in order to continue."
    };
  };

  # ===============FACEBOOK=============
  if ($sm_service eq 'facebook') {

    # Handle authorization cancellation (user clicked on deny...)
    if (query_parameters->get('error') && query_parameters->get('error') eq 'access_denied') {
      return template 'signup', {
        error_header => "Whoops",
        error => "In order to continue, you must authorize the blogs.perl.org application to identify you."
      };
    }

    my $code = query_parameters->get('code');
    my $facebook_client_id = config->{plugins}->{social_media}->{facebook}->{client_id} || $ENV{bpo_social_media_facebook_client_id};
    my $facebook_client_secret = config->{plugins}->{social_media}->{facebook}->{client_secret} || $ENV{bpo_social_media_facebook_client_secret};
    my $app_access_token = $facebook_client_id . "|" . $facebook_client_secret;

    # Verify state token
    if (query_parameters->get('state') ne $token_value) {
      return template 'signup', {
        error_header => "Hmm...",
        error => "It seems the service did not return our random token, or returned an invalid one."
      };
    }

    # Got facebook code, exchange it for an access token
    my $link = 'https://graph.facebook.com/v2.3/oauth/access_token?client_id=' . $facebook_client_id;
    $link .= ('&redirect_uri=' . uri_encode($base_uri . $callback_handler)  );
    $link .= ('&client_secret=' . $facebook_client_secret );
    $link .= ('&code=' . params->{code} );

    my $response = $http->get($link);
    my $access_token = from_json($response->{content})->{access_token};

    if (!$access_token || $access_token eq undef) {
      return template 'signup', {
        error_header => "Hmm...",
        error => "It seems that the service did not return an access token for us to work with."
      };
    };

    # Verify that token was indeed issued by BPO
    $link = 'https://graph.facebook.com/debug_token?input_token=';
    $link .= $access_token;
    $link .= ("&access_token=".$app_access_token);

    $response = $http->get($link);

    my $data = from_json($response->{content})->{data};

    if ($data->{app_id} ne $facebook_client_id) {
      return template 'signup', {
        error_header => "Oh you...",
        error => "We got back a bad application id. Why won't you just stop hacking around?"
      };
    }

    my $user_id_from_first_request = $data->{user_id};

    $link = 'https://graph.facebook.com/me?access_token=';
    $link .= $access_token;
    $link .= '&fields=';
    $link .= 'id,name,email,about,bio,birthday,first_name,last_name,gender,link,picture';

    $response = $http->get($link);
    my $user_data = from_json($response->{content});

    if ($user_data->{id} ne $user_id_from_first_request) {
      return template 'signup', {
        error_header => "Oh you...",
        error => "User mismatch. Impersonating someone else isn't really nice, you know?"
      };
    }

    # If user is logged in, it means he's connecting the social media account in the profile page
    if ($userLoggedIn) {
      # User is logged in. We should add a new entry in the DB which connects his blogs.perl.org account to this social media account

      resultset('UserOauth')->update_or_create({
        name    => "Facebook",
        user_id => session('user')->{id},
        service_id => $user_id_from_first_request
      });

      # Afterwards, add this info into the user from the session (or resync the user in the session from the one in the DB), so the changes can appear in the frontend.
      setConnectedAccountsOntoSession();

      # ...and render the profile settings page
      return template 'profile';

    } else {
      # There's no user logged in. It's a login process

      try {
        $user_oauth = resultset('UserOauth')->find({ name => 'Facebook', service_id => $user_id_from_first_request });
      }
      catch {
        warn $_;
      };

      if ($user_oauth) {
        try {
          $user = resultset('Users')->find($user_oauth->user_id());
        } catch {
          warn $_;
        };

        if ($user) {
          # Found account. Send him to dashboard
          session user    => $user->as_hashref;
          session user_id => $user->id;
          return redirect '/';

        } else {
          return template 'signup', {
            error_header => "Hmm...",
            error => "It seems that your social media account isn't yet connected to an existing blogs.perl.org account."
          };
        }
      } else {
        return template 'signup', {
          error_header => "Hmm...",
          error => "It seems that your social media account isn't yet connected to an existing blogs.perl.org account."
        };
      }
    }

  # ===============TWITTER=============
  } elsif ($sm_service eq 'twitter') {

    # Handle authorization cancellation
    if (query_parameters->get('denied')) {
      return template 'signup', {
        error_header => "Whoops",
        error => "In order to continue, you must authorize the blogs.perl.org application to identify you."
      };
    }

    my $request_token = query_parameters->get('oauth_token');
    my $verifier_token = query_parameters->get('oauth_verifier');

    # Should verify that this token is the same with the token from the previous step but ain't gonna do it for now.

    # Exchange the request token for an access token

    my $twitter_consumer_key = config->{plugins}->{social_media}->{twitter}->{consumer_key} || $ENV{bpo_social_media_twitter_consumer_key};
    my $twitter_consumer_secret = config->{plugins}->{social_media}->{twitter}->{consumer_secret} || $ENV{bpo_social_media_twitter_consumer_secret};
    my $query_string = 'https://api.twitter.com/oauth/access_token';

    my $oauth = WWW::OAuth->new(
       client_id => $twitter_consumer_key,
       client_secret => $twitter_consumer_secret,
       token => $request_token,
     );

    my $res = $oauth->authenticate(Basic => { method => 'POST', url => $query_string }, { oauth_verifier => $verifier_token })->request_with(HTTP::Tiny->new);

    # Anything but 200 is an error
    if ($res->{status} != 200) {
      return template 'signup', {
        error_header => "Communication error",
        error => "Something went wrong while trying to communicate with Twitter."
      };
    };

    my %res_data = @{form_urldecode $res->{content}};
    my ($oauth_token, $oauth_token_secret, $user_id, $screen_name) = @res_data{'oauth_token','oauth_token_secret', 'user_id', 'screen_name'};

    # If user is logged in, it means he's connecting the social media account in the profile page
    if ($userLoggedIn) {
      # User is logged in. We should add a new entry in the DB which connects his blogs.perl.org account to this social media account

      resultset('UserOauth')->update_or_create({
        name    => "Twitter",
        user_id => session('user')->{id},
        service_id => $user_id
      });

      # Afterwards, add this info into the user from the session (or resync the user in the session from the one in the DB), so the changes can appear in the frontend.
      setConnectedAccountsOntoSession();

      # ...and render the profile settings page
      return template 'profile';

    } else {
      # There's no user logged in. It's a login process

      try {
        $user_oauth = resultset('UserOauth')->find({ name => 'Twitter', service_id => $user_id });
      }
      catch {
        warn $_;
      };

      if ($user_oauth) {
        try {
          $user = resultset('Users')->find($user_oauth->user_id());
        } catch {
          warn $_;
        };

        if ($user) {
          # Found account. Send him to dashboard
          session user    => $user->as_hashref;
          session user_id => $user->id;
          return redirect '/';

        } else {
          return template 'signup', {
            error_header => "Hmm...",
            error => "It seems that your social media account isn't yet connected to an existing blogs.perl.org account."
          };
        }
      } else {
        return template 'signup', {
          error_header => "Hmm...",
          error => "It seems that your social media account isn't yet connected to an existing blogs.perl.org account."
        };
      }
    }

  # ===============GOOGLE=============
  } elsif ($sm_service eq 'google') {

    # Handle authorization cancellation
    if (query_parameters->get('error') && (query_parameters->get('error') eq 'access_denied')) {
      return template 'signup', {
        error_header => "Whoops",
        error => "In order to continue, you must authorize the blogs.perl.org application to identify you."
      };
    }

    # Verify state token
    if (query_parameters->get('state') ne $token_value) {
      return template 'signup', {
        error_header => "Hmm...",
        error => "It seems the service did not return our random token, or returned an invalid one."
      };
    }

    my $code = query_parameters->get('code');
    my $google_client_id = config->{plugins}->{social_media}->{google}->{client_id} || $ENV{bpo_social_media_google_client_id};
    my $google_client_secret = config->{plugins}->{social_media}->{google}->{client_secret} || $ENV{bpo_social_media_google_client_secret};

    # Got google code, exchange it for an access token
    my $link = 'https://www.googleapis.com/oauth2/v4/token';

    my $response = $http->post_form($link, {
      client_secret => $google_client_secret,
      client_id => $google_client_id,
      code => $code,
      redirect_uri => uri_encode($base_uri . $callback_handler),
      grant_type => 'authorization_code'
    });

    my $access_token = from_json($response->{content})->{access_token};

    if (!$access_token || $access_token eq undef) {
      return template 'signup', {
        error_header => "Hmm...",
        error => "It seems that the service did not return an access token for us to work with."
      };
    };

    $link = 'https://www.googleapis.com/oauth2/v1/userinfo?';
    $link .= ("access_token=".$access_token);

    $response = $http->get($link);

    my $data = from_json($response->{content});
    my $user_id = $data->{id};

    # If user is logged in, it means he's connecting the social media account in the profile page
    if ($userLoggedIn) {
      # User is logged in. We should add a new entry in the DB which connects his blogs.perl.org account to this social media account

      resultset('UserOauth')->update_or_create({
        name    => "Google",
        user_id => session('user')->{id},
        service_id => $user_id
      });

      # Afterwards, add this info into the user from the session (or resync the user in the session from the one in the DB), so the changes can appear in the frontend.
      setConnectedAccountsOntoSession();

      # ...and render the profile settings page
      return template 'profile';

    } else {
      # There's no user logged in. It's a login process

      try {
        $user_oauth = resultset('UserOauth')->find({ name => 'Google', service_id => $user_id });
      }
      catch {
        warn $_;
      };

      if ($user_oauth) {
        try {
          $user = resultset('Users')->find($user_oauth->user_id());
        } catch {
          warn $_;
        };

        if ($user) {
          # Found account. Send him to dashboard
          session user    => $user->as_hashref;
          session user_id => $user->id;
          return redirect '/';

        } else {
          return template 'signup', {
            error_header => "Hmm...",
            error => "It seems that your social media account isn't yet connected to an existing blogs.perl.org account."
          };
        }
      } else {
        return template 'signup', {
          error_header => "Hmm...",
          error => "It seems that your social media account isn't yet connected to an existing blogs.perl.org account."
        };
      }
    }

  # ===============GITHUB=============
  } elsif ($sm_service eq 'github') {

    # Handle authorization cancellation
    if (query_parameters->get('error') && (query_parameters->get('error') eq 'access_denied')) {
      return template 'signup', {
        error_header => "Whoops",
        error => "In order to continue, you must authorize the blogs.perl.org application to identify you."
      };
    }

    # Handle uri mismatch
    if (query_parameters->get('error') && (query_parameters->get('error') eq 'redirect_uri_mismatch')) {
      return template 'signup', {
        error_header => "Bummer",
        error => "It seems like the redirect URL does not match the one specified in the application details from Github."
      };
    }

    # Verify state token
    if (query_parameters->get('state') ne $token_value) {
      return template 'signup', {
        error_header => "Hmm...",
        error => "It seems the service did not return our random token, or returned an invalid one."
      };
    }

    my $code = query_parameters->get('code');
    my $github_client_id = config->{plugins}->{social_media}->{github}->{client_id} || $ENV{bpo_social_media_github_client_id};
    my $github_client_secret = config->{plugins}->{social_media}->{github}->{client_secret} || $ENV{bpo_social_media_github_client_secret};

    # Got github code, exchange it for an access token
    my $link = 'https://github.com/login/oauth/access_token';

    my $response = $http->post_form($link, {
      client_secret => $github_client_secret,
      client_id => $github_client_id,
      code => $code,
      redirect_uri => uri_encode($base_uri . $callback_handler)
    });

    my %res_data = @{form_urldecode $response->{content}};
    my $access_token = $res_data{'access_token'};

    if (!$access_token || $access_token eq undef) {
      return template 'signup', {
        error_header => "Hmm...",
        error => "It seems that the service did not return an access token for us to work with."
      };
    };

    $link = 'https://api.github.com/user?access_token='.$access_token;
    $response = $http->get($link);

    my $data = from_json($response->{content});
    my $user_id = $data->{id};

    # If user is logged in, it means he's connecting the social media account in the profile page
    if ($userLoggedIn) {
      # User is logged in. We should add a new entry in the DB which connects his blogs.perl.org account to this social media account

      resultset('UserOauth')->update_or_create({
        name    => "Github",
        user_id => session('user')->{id},
        service_id => $user_id
      });

      # Afterwards, add this info into the user from the session (or resync the user in the session from the one in the DB), so the changes can appear in the frontend.
      setConnectedAccountsOntoSession();

      # ...and render the profile settings page
      return template 'profile';

    } else {
      # There's no user logged in. It's a login process

      try {
        $user_oauth = resultset('UserOauth')->find({ name => 'Github', service_id => $user_id });
      }
      catch {
        warn $_;
      };

      if ($user_oauth) {
        try {
          $user = resultset('Users')->find($user_oauth->user_id());
        } catch {
          warn $_;
        };

        if ($user) {
          # Found account. Send him to dashboard
          session user    => $user->as_hashref;
          session user_id => $user->id;
          return redirect '/';

        } else {
          return template 'signup', {
            error_header => "Hmm...",
            error => "It seems that your social media account isn't yet connected to an existing blogs.perl.org account."
          };
        }
      } else {
        return template 'signup', {
          error_header => "Hmm...",
          error => "It seems that your social media account isn't yet connected to an existing blogs.perl.org account."
        };
      }
    }

  # ===============LINKEDIN=============
  } elsif ($sm_service eq 'linkedin') {

    # Handle authorization cancellation
    if (query_parameters->get('error') && (query_parameters->get('error') eq 'access_denied')) {
      return template 'signup', {
        error_header => "Whoops",
        error => "In order to continue, you must authorize the blogs.perl.org application to identify you."
      };
    }

    # Verify state token
    if (query_parameters->get('state') ne $token_value) {
      return template 'signup', {
        error_header => "Hmm...",
        error => "It seems the service did not return our random token, or returned an invalid one."
      };
    }

    my $code = query_parameters->get('code');
    my $linkedin_client_id = config->{plugins}->{social_media}->{linkedin}->{client_id} || $ENV{bpo_social_media_linkedin_client_id};
    my $linkedin_client_secret = config->{plugins}->{social_media}->{linkedin}->{client_secret} || $ENV{bpo_social_media_linkedin_client_secret};

    # Got linkedin code, exchange it for an access token
    my $link = 'https://www.linkedin.com/uas/oauth2/accessToken';

    my $response = $http->post_form($link, {
      client_secret => $linkedin_client_secret,
      client_id => $linkedin_client_id,
      code => $code,
      grant_type => 'authorization_code',
      redirect_uri => uri_encode($base_uri . $callback_handler)
    });

    my $access_token = from_json($response->{content})->{access_token};

    if (!$access_token || $access_token eq undef) {
      return template 'signup', {
        error_header => "Hmm...",
        error => "It seems that the service did not return an access token for us to work with."
      };
    };

    $link = 'https://api.linkedin.com//v1/people/~?format=json';
    $response = $http->get($link, {
      headers => {
        Authorization => 'Bearer '.$access_token
      }
    });

    my $data = from_json($response->{content});
    my $user_id = $data->{id};

    # If user is logged in, it means he's connecting the social media account in the profile page
    if ($userLoggedIn) {
      # User is logged in. We should add a new entry in the DB which connects his blogs.perl.org account to this social media account

      resultset('UserOauth')->update_or_create({
        name    => "LinkedIn",
        user_id => session('user')->{id},
        service_id => $user_id
      });

      # Afterwards, add this info into the user from the session (or resync the user in the session from the one in the DB), so the changes can appear in the frontend.
      setConnectedAccountsOntoSession();

      # ...and render the profile settings page
      return template 'profile';

    } else {
      # There's no user logged in. It's a login process

      try {
        $user_oauth = resultset('UserOauth')->find({ name => 'LinkedIn', service_id => $user_id });
      }
      catch {
        warn $_;
      };

      if ($user_oauth) {
        try {
          $user = resultset('Users')->find($user_oauth->user_id());
        } catch {
          warn $_;
        };

        if ($user) {
          # Found account. Send him to dashboard
          session user    => $user->as_hashref;
          session user_id => $user->id;
          return redirect '/';

        } else {
          return template 'signup', {
            error_header => "Hmm...",
            error => "It seems that your social media account isn't yet connected to an existing blogs.perl.org account."
          };
        }
      } else {
        return template 'signup', {
          error_header => "Hmm...",
          error => "It seems that your social media account isn't yet connected to an existing blogs.perl.org account."
        };
      }
    }

  } else {
    return template 'signup', {
      error_header => "Bummer",
      error => "Unsupported media service. How did you even manage to get here?"
    };
  }

};


=head2 /smdisconnect

Route handler for disconnecting social media services

=cut

get '/smdisconnect' => sub {
  my $sm_service = params->{socialMediaService};
  my $userLoggedIn = session('user') || undef;

  unless ($userLoggedIn) {
    return template 'profile', {
      error => "Error. No user logged in!"
    };
  };

  # ===============FACEBOOK=============
  if ($sm_service eq 'facebook') {
    # Delete the database entry in the database which assigns the facebook account to the current user

    my $disconnected = 0;

    try {
      resultset('UserOauth')->find({
        name    => "Facebook",
        user_id => session('user')->{id}
      })->delete();
    } catch {
      $disconnected = 1;
    };

    return template 'profile', {
      info => 'Already disconnected.'
    } if $disconnected == 1;

    setConnectedAccountsOntoSession();

    return template 'profile';
  # ===============TWITTER=============
  } elsif ($sm_service eq 'twitter') {
    # Delete the database entry in the database which assigns the twitter account to the current user

    my $disconnected = 0;

    try {
      resultset('UserOauth')->find({
        name    => "Twitter",
        user_id => session('user')->{id}
      })->delete();
    } catch {
      $disconnected = 1;
    };

    return template 'profile', {
      info => 'Already disconnected.'
    } if $disconnected == 1;

    setConnectedAccountsOntoSession();

    return template 'profile';
  # ===============GOOGLE=============
  } elsif ($sm_service eq 'google') {
    # Delete the database entry in the database which assigns the google account to the current user

    my $disconnected = 0;

    try {
      resultset('UserOauth')->find({
        name    => "Google",
        user_id => session('user')->{id}
      })->delete();
    } catch {
      $disconnected = 1;
    };

    return template 'profile', {
      info => 'Already disconnected.'
    } if $disconnected == 1;

    setConnectedAccountsOntoSession();

    return template 'profile';
  # ===============GITHUB=============
  } elsif ($sm_service eq 'github') {
    # Delete the database entry in the database which assigns the github account to the current user

    my $disconnected = 0;

    try {
      resultset('UserOauth')->find({
        name    => "Github",
        user_id => session('user')->{id}
      })->delete();
    } catch {
      $disconnected = 1;
    };

    return template 'profile', {
      info => 'Already disconnected.'
    } if $disconnected == 1;

    setConnectedAccountsOntoSession();

    return template 'profile';
  # ===============LINKEDIN=============
  } elsif ($sm_service eq 'linkedin') {
    # Delete the database entry in the database which assigns the linkedin account to the current user

    my $disconnected = 0;

    try {
      resultset('UserOauth')->find({
        name    => "LinkedIn",
        user_id => session('user')->{id}
      })->delete();
    } catch {
      $disconnected = 1;
    };

    return template 'profile', {
      info => 'Already disconnected.'
    } if $disconnected == 1;

    setConnectedAccountsOntoSession();

    return template 'profile';
  } else {
    return template 'profile', {
      error => "Unsupported social media service to disconnect."
    };
  }
};

sub setConnectedAccountsOntoSession {

  my @connectedAccounts;

  try {
    my @connected = resultset('UserOauth')->search({
        user_id => session('user_id')
      },{
        columns => "name"
    });

    foreach my $account (@connected) {
      push @connectedAccounts, $account->name();
    };

  } catch {
    warn $_;
  };


  warn Dumper(@connectedAccounts);
  session(connectedAccounts => \@connectedAccounts);

}

true;

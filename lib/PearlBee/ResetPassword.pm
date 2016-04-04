package ResetPassword;

use strict;
use warnings;

use Try::Tiny;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::reCAPTCHA;

use PearlBee::Helpers::Util;
use PearlBee::Helpers::Email;

use PearlBee::Password;

use DateTime;

get '/activation' => sub {
    my $token = params->{'token'};

    my $user_reset_token =
         resultset('Users')->search({ activation_key => $token })->first();
    if ($user_reset_token and
        $user_reset_token->status eq 'pending' ) 
    {
        $user_reset_token->update({ 
        status         => 'active',
        activation_key => ''          
        });

        my $user_obj = $user_reset_token->as_hashref_sanitized;

        session user    => $user_obj;
        session user_id => $user_reset_token->id;
        
        template 'register_done' ;
    }  
    elsif ($user_reset_token->status eq 'active') {
        template 'set-password' => {
            show_input => 1,
            token      => $token,
        }, { layout => 'admin' };
    }
    else {
        session error => 'Your activation token is invalid, please try the forgot password option again.';

        template 'login';
    }
};

any ['post', 'get'] => '/set-password' => sub {
    my $params = params;

    unless ( $params->{token} and $params->{password} ) {
        template 'set-password' => {
            show_input => 1,
            token      => $params->{'token'}
        }, {layout => 'admin'};
        return;
    }

    my $user =
        resultset('Users')->search({
            activation_key => $params->{'token'} })->first();
    unless ( defined $user ) {
        error "No activation key found for this user";
        return;
    }

    # Password must match the confirmation
    #
    unless ( $params->{'password'} eq $params->{'rep_password'} ) {
        session error           => 'Entered and confirmed passwords do not match';
        template 'set-password' => {show_input => 1,token      => $params->{'token'},}, {layout => 'admin'};
    }

    my $hashed_password =
        crypt( $params->{'password'}, $user->password );
    my $updated = $user->update({
        password       => $hashed_password,
        activation_key => '',
        status         => 'active'
    });

    my $user_obj = {
      is_admin  => $user->is_admin,
      role      => $user->role,
      id        => $user->id,
      username  => $user->username,
      avatar    => $user->avatar,
      biography => $user->biography,
    };

    session user    => $user_obj;
    session user_id => $user->id;

    session success => 'Your password was sucessfuly changed';
    redirect('/');
};

any ['get', 'post'] => '/forgot-password' => sub {
    my $params = params;

    #it was a post request
    if ( $params->{email} ) {

        my $secret = param('g-recaptcha-response');
        my $result = recaptcha_verify($secret);
        if ( $result->{success} || $ENV{CAPTCHA_BYPASS} ) {

            my $user = resultset('Users')->search({ email => $params->{email} })->first;

            if ($user) {
                my $date             = DateTime->now();
                my $activation_token = generate_hash( $params->{email} . $date );

                my $token = $activation_token;

                if ($token) {
                    if ( $user->status ne 'suspended' ) {
                        $user->update({ activation_key => $token });

                        try {
                            PearlBee::Helpers::Email::send_email_complete({
                                template => 'forgot-password.tt',
                                from     => config->{default_email_sender},
                                to       => $params->{email},
                                subject  => 'Reset password link on blog.cluj.pm',

                                template_params => {
                                    name      => $user->name,
                                    app_url   => config->{app_url},
                                    token     => "/activation?token=$token",
                                    blog_name => session('blog_name'),
                                    signature => config->{email_signature}
                                }
                            });
                        }
                        catch {
                            error "Could not send the email";
                        };

                        session success => 'You have successfully reset you password! Please check your inbox!';
                        template 'forgot-password', {show_input => 0}, {layout => 'admin'};
                    }
                    else {
                        session error => 'Your account is suspended!';
                        template 'forgot-password', {show_input => 0}, {layout => 'admin'};
                    }
                }

                # no user with this email
                else {
                    session warning => 'There is no user with this email address:' . $params->{'email'};
                    template 'forgot-password', {show_input => 1}, {layout => 'admin'};
                }
            }

            # captcha incorrect
            else {
                session error => 'Incorrect captcha';
                template 'forgot-password', {
                    show_input => 1,
                    recaptcha => recaptcha_display(),
                }, {layout => 'admin'};
            }
        }
    }

    # it was a get request
    else {
        template 'forgot-password', {
            show_input => 1,
            recaptcha  => recaptcha_display(),
        }, { layout => 'admin' };
    }
};

true;

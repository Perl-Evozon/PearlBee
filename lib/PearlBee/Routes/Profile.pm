package PearlBee::Routes::Profile;

=head1 PearlBee::Routes::Profile

Profile routes from the old PearlBee main file

=cut

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;

use PearlBee::Helpers::Access qw( has_ability );

our $VERSION = '0.1';

hook before => sub {
  my $user = session('user');

  unless ( request->dispatch_path =~ m{ ^/profile }x and
           PearlBee::Helpers::Access::has_ability( $user, 'update profile' ) ) {
    forward '/', { requested_path => request->dispatch_path };
  }
};

=head2 Display profile page

=cut

get '/profile' => sub {

  template 'profile';

};

=head2 Display profile for a given author

=cut
  
get '/profile/author/:username' => sub {

  my $nr_of_rows = config->{blogs_on_page} || 5; # Number of posts per page
  my $username   = route_parameters->{'username'};
  my ( $user )   = resultset('Users')->search_lc( $username );
  unless ($user) {
    error "No such user '$username'";
  }
  my @blog_owners = resultset('BlogOwner')->search({ user_id => $user->id });
  my @blogs;
  for my $blog_owner ( @blog_owners ) {
    push @blogs, map { $_->as_hashref_sanitized }
                 resultset('Blog')->find({ id => $blog_owner->blog_id });
  }
  my @posts = resultset('Post')->search({ user_id => $user->id });
  my @post_tags;
  for my $post ( @posts ) {
    push @post_tags, map { $_->as_hashref_sanitized } $post->tag_objects;
  }
  for my $blog ( @blogs ) {
    $blog->{count} = {
      owners => 1,
      post   => scalar @posts,
      tag    => scalar @post_tags,
    };
    $blog->{post_tags} = \@post_tags;
  }

  my $template_data = {
    blogs      => \@blogs,
    blog_count => scalar @blogs,
    user       => $user->as_hashref_sanitized,
  }; 

  if (param('format')) {
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    $json->encode( $template_data );
  }     
  else {
    template 'profile/author', $template_data;
  }

};

post '/profile' => sub  {

  my $params            = body_parameters;
  my $user              = session('user');
  my $flag_modification = 0;
  my $flag_error        = 0;
  my $message           = '';

  if ($params->{'email'} ne '') {
    my $existing_user =
      resultset('Users')->search({ email => $params->{'email'} })->count;
    if ($existing_user > 0) {
      $flag_error = 1;
      $message    = "A user with this email address already exists.";
    
    }
    else {
      $flag_modification = 1;
      $user->{email}     = $params->{email};
      my $res_user       = resultset('Users')->find({ id => $user->{id} });
      $res_user->update({ email => $params->{email} });
      session('user', $user);
    }
  }

  if ($params->{'username'} ne '') {
    my $existing_user =
      resultset('Users')->search({ username => $params->{'username'} })->count;
    if ($existing_user > 0) {
       $flag_error = 1;
       $message   .= "\n A user with this username already exists.";
    }
    else {
      $flag_modification = 1;
      $user->{username}  = $params->{username};
      my $res_user       = resultset('Users')->find({ id => $user->{id} });
      $res_user->update({ username => $params->{username} });
      session('user', $user);
    }
  }

  if ($params->{'displayname'} ne '') {
    my $existing_user =
      resultset('Users')->search({ name => $params->{'displayname'} })->count;
    if ($existing_user > 0) {
      $flag_error = 1;
      $message   .= "\n A user with this displayname already exists.";
    }
    else {
      $flag_modification = 1;
      $user->{name}      = $params->{displayname};
      my $res_user       = resultset('Users')->find({ id => $user->{id} });
      $res_user->update({ name => $params->{displayname} });
      session('user', $user);
    }
  }

  if ($params->{'about'} ne '') {
 
    $flag_modification = 1;
    $user->{biography} = $params->{about};
    my $res_user = resultset('Users')->find({ id => $user->{id} });
    $res_user->update({ biography => $params->{about} });
    session('user', $user);
  }

  if (($flag_modification == 1) && ($flag_error==0)) {
    template 'profile',
      {
        success => "Everything was successfully updated.",
      };
  }
  elsif (($flag_modification == 1) && ($flag_error==1)) {
    template 'profile',
      {
        warning => "Some fields were updated, but ". $message,
      };
  }
  else {
    template 'profile',
      {
         warning => $message,
      };
  }
};

post '/profile_password' => sub  {
  my $params   = body_parameters;
  my $user     = session('user');
  my $res_user = resultset('Users')->find({ id => $user->{id} });

  if (defined($res_user) && ($params->{'new_password'} ne '')) {
    
    if ($params->{'new_password'} eq $params->{'confirm_password'}) {
      
      if ($res_user->validate($params->{'old_password'})) {

        my $hashed_password =
          crypt( $params->{'new_password'}, $res_user->password );
        $res_user->update({
          password => $hashed_password,
        });

        template 'profile',
          {
            success => "You can now use your new password",
          };

      }
      else {
        template 'profile',
          {
            warning => "Please insert correctly your old password",
          };
      }
    }
    else {
      template 'profile',
        {
          warning => "Confirmation password was wrongly introduced",
        };
    }

  }
  else {
    template 'profile',
      {
        warning => "No new password was inserted ",
      };
 }
 
};

get '/profile_password' => sub  {

   template 'profile';

};

1;

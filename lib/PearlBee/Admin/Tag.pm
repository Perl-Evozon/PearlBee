package PearlBee::Admin::Tag;

use Try::Tiny;
use Dancer2;
use Dancer2::Plugin::DBIC;

use PearlBee::Dancer2::Plugin::Admin;

use PearlBee::Helpers::Util qw(string_to_slug);

=head2 List all tags

=cut

get '/admin/tags' => sub {

  my @tags = resultset('Tag')->all;

  template 'admin/tags/list', { tags => \@tags }, { layout => 'admin' };

};

=head2 Add a new tag

=cut

post '/admin/tags/add' => sub {

  my @tags;
  my $name = params->{name};
  my $slug = string_to_slug( params->{slug} );

  my $found_slug_or_name = resultset('Tag')->search({ -or => [ slug => $slug, name => $name ] })->first;

  # Check for slug or name duplicates
  if ( $found_slug_or_name ) {
    @tags = resultset('Tag')->all;

    template 'admin/tags/list', { warning => "The tag name or slug already exists", tags => \@tags } , { layout => 'admin' };
  }
  else {
    try {
      my $tag = resultset('Tag')->create({
        name   => $name,
        slug   => $slug
      });
    }
    catch {
      info "Could not create tag named '$name'";
    };

    @tags = resultset('Tag')->all;

    template 'admin/tags/list', {
      success => "The cateogry was successfully added.",
      tags => \@tags
    }, { layout => 'admin' };
  }

};

=head2 Delete method

=cut

get '/admin/tags/delete/:id' => sub {

  my $tag_id = params->{id};
  my $tag    = resultset('Tag')->find( $tag_id );

  # Delete first all many to many dependecies for safly removal of the isolated tag
  try {
    foreach ( $tag->post_tags ) {
      $_->delete;
    }

    $tag->delete;
  }
  catch {
    info $_;
    error "Could not delete tag";
  };

  redirect '/admin/tags';

};

=head2 edit method

=cut

any '/admin/tags/edit/:id' => sub {

  my $tag_id = params->{id};
  my @tags   = resultset('Tag')->all;
  my $tag    = resultset('Tag')->find( $tag_id );

  my $name = params->{name};
  my $slug = string_to_slug( params->{slug} );

  # Check if the form was submited
  if ( $name && $slug ) {
    my $found_slug = resultset('Tag')->search({ id => { '!=' => $tag->id }, slug => $slug })->first;
    my $found_name = resultset('Tag')->search({ id => { '!=' => $tag->id }, name => $name })->first;

    # Check if the user entered an existing slug
    if ( $found_slug ) {

      template 'admin/tags/list',
        {
        tag     => $tag,
        tags    => \@tags,
        warning => 'The tag slug already exists'
        },
        { layout => 'admin' };

    }
    # Check if the user entered an existing name
    elsif ( $found_name ) {

      template 'admin/tags/list',
        {
        tag     => $tag,
        tags    => \@tags,
        warning => 'The tag name already exists'
        },
      { layout => 'admin' };

    }
    else {
      try {
        $tag->update({
          name => $name,
          slug => $slug
        });
      }
      catch {
        info $_;
        error "Could not update tag named '$name'";
      };

      @tags = resultset('Tag')->all;

      template 'admin/tags/list',
        {
        tag     => $tag,
        tags    => \@tags,
        success => 'The tag was updated successfully'
        },
      { layout => 'admin' };
    }
  }
  else {
    # If the form wasn't submited just list the tags
    template 'admin/tags/list',
      {
      tag  => $tag,
      tags => \@tags
      },
      { layout => 'admin' };
  }

};

1;

=head

Author: Andrei Cacio
Email: andrei.cacio@evozon.com

=cut

package PearlBee::Admin::Category;

use Dancer2;
use Dancer2::Plugin::DBIC;

use String::Dirify;
use String::Util 'trim';

=head

list all categories

=cut

get '/admin/categories' => sub {
  my @categories = resultset('Category')->search({ name => { '!=' => 'Uncategorized'} });

  template '/admin/categories/list', { categories => \@categories }, { layout => 'admin' };
};

=head

create method

=cut

post '/admin/categories/add' => sub {

  my @categories;
  my $name = params->{name};
  my $slug = params->{slug};

  $slug = String::Dirify->dirify( trim($slug), '-'); # Convert the string intro a valid slug

  my $found_slug_or_name = resultset('Category')->search({ -or => [ slug => $slug, name => $name ] })->first;

  if ( $found_slug_or_name ) {
    @categories = resultset('Category')->search({ name => { '!=' => 'Uncategorized'} });

    template '/admin/categories/list', { warning => "The category name or slug already exists", categories => \@categories } , { layout => 'admin' };
  }
  else {
    # TODO: unchecked eval
    eval {
      my $user = session('user');
      my $category = resultset('Category')->create({
          name   => $name,
          slug   => $slug,
          user_id => $user->id
        });
    };

    @categories = resultset('Category')->search({ name => { '!=' => 'Uncategorized'} });

    template '/admin/categories/list', { success => "The cateogry was successfully added.", categories => \@categories }, { layout => 'admin' };
  }

};

=head

delete method

=cut

get '/admin/categories/delete/:id' => sub {

  eval {
    my $id = params->{id};
    my $category = resultset('Category')->find( $id );

    foreach ( $category->post_categories ) {
      my $post = $_->post;
      my @post_categories = $post->post_categories;

      if ( scalar ( @post_categories ) == 1 ) {
        resultset('PostCategory')->create({
            post_id => $post->id,
            category_id => '1'
          });
      }

      $_->delete();
    }

    $category->delete();
  };

  # TODO: eval {...; 1;} or do {};, or else you might miss errors 
  if ( $@ ) {
    error $@;
    my @categories   = resultset('Category')->search({ name => { '!=' => 'Uncategorized'} });

    template '/admin/categories/list', { categories => \@categories, warning => "Something went wrong." }, { layout => 'admin' };
  }
  else {
    redirect session('app_url') . "/admin/categories";
  }

};

=head

edit method

=cut

any '/admin/categories/edit/:id' => sub {

  my $category_id = params->{id};
  my @categories   = resultset('Category')->search({ name => { '!=' => 'Uncategorized'} });
  my $category   = resultset('Category')->find( $category_id );

  my $name = params->{name};
  my $slug = params->{slug};
  # Check if the form was submited
  if ( $name && $slug ) {

    $slug = String::Dirify->dirify( trim($slug), '-'); # Convert the string intro a valid slug

    my $found_slug = resultset('Category')->search({ id => { '!=' => $category->id }, slug => $slug })->first;
    my $found_name = resultset('Category')->search({ id => { '!=' => $category->id }, name => $name })->first;

    # Check if the user entered an existing slug
    if ( $found_slug ) {

      template '/admin/categories/list',
      {
        category   => $category,
        categories => \@categories,
        warning    => 'The category slug already exists'
      },
      { layout => 'admin' };

    }
    # Check if the user entered an existing name
    elsif ( $found_name ) {

      template '/admin/categories/list',
      {
        category   => $category,
        categories => \@categories,
        warning    => 'The category name already exists'
      },
      { layout => 'admin' };

    }
    else {
      eval {
        $category->update({
            name => $name,
            slug => $slug
          });
      };

      @categories = resultset('Category')->search({ name => { '!=' => 'Uncategorized'} });

      template '/admin/categories/list',
      {
        category   => $category,
        categories => \@categories,
        success    => 'The category was updated successfully'
      },
      { layout => 'admin' };
    }
  }
  else {
    # If the form wasn't submited just list the categories
    template '/admin/categories/list',
      {
        category   => $category,
        categories => \@categories
      },
      { layout => 'admin' };
  }

};

1;
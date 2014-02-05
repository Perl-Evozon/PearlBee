
=head

Author: Andrei Cacio
Email: andrei.cacio@evozon.com

=cut

package PearlBee::Admin::Post;

use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Helpers::Util qw/generate_crypted_filename generate_new_slug_name/;

use String::Dirify;
use String::Util 'trim';

=head

list all posts method

=cut

get '/admin/posts' => sub {

    my @posts   = resultset('Post')->search( {}, { order_by => 'created_date DESC' } );
    my $publish = resultset('Post')->search( { status       => 'published' } )->count;
    my $trash   = resultset('Post')->search( { status       => 'trash' } )->count;
    my $draft   = resultset('Post')->search( { status       => 'draft' } )->count;
    my $all     = scalar(@posts);

    template '/admin/posts/list',
      {
        posts   => \@posts,
        trash   => $trash,
        draft   => $draft,
        publish => $publish,
        all     => $all
      },
      { layout => 'admin' };

};

=head

list all published posts

=cut

get '/admin/posts/published' => sub {

    my @posts = resultset('Post')->search( { status => 'published' }, { order_by => 'created_date DESC' } );

    my $all   = resultset('Post')->search( { 1      => '1' } )->count;
    my $trash = resultset('Post')->search( { status => 'trash' } )->count;
    my $draft = resultset('Post')->search( { status => 'draft' } )->count;
    my $publish = scalar(@posts);

    template '/admin/posts/list',
      {
        posts   => \@posts,
        trash   => $trash,
        draft   => $draft,
        publish => $publish,
        all     => $all
      },
      { layout => 'admin' };
};

=head

list all draft posts

=cut

get '/admin/posts/draft' => sub {

    my @posts = resultset('Post')->search( { status => 'draft' }, { order_by => 'created_date DESC' } );

    my $all     = resultset('Post')->search( { 1      => '1' } )->count;
    my $trash   = resultset('Post')->search( { status => 'trash' } )->count;
    my $publish = resultset('Post')->search( { status => 'published' } )->count;
    my $draft   = scalar(@posts);

    template '/admin/posts/list',
      {
        posts   => \@posts,
        trash   => $trash,
        draft   => $draft,
        publish => $publish,
        all     => $all
      },
      { layout => 'admin' };

};

=head

list all trash posts

=cut

get '/admin/posts/trash' => sub {

    my @posts = resultset('Post')->search( { status => 'trash' }, { order_by => 'created_date DESC' } );

    my $all     = resultset('Post')->search( { 1      => '1' } )->count;
    my $publish = resultset('Post')->search( { status => 'published' } )->count;
    my $draft   = resultset('Post')->search( { status => 'draft' } )->count;
    my $trash   = scalar(@posts);

    template '/admin/posts/list',
      {
        posts   => \@posts,
        trash   => $trash,
        draft   => $draft,
        publish => $publish,
        all     => $all
      },
      { layout => 'admin' };
};

=head

publish method

=cut

get '/admin/posts/publish/:id' => sub {
    my $post_id = params->{id};

    my $post;
    eval {
        $post = resultset('Post')->find($post_id);
        $post->update( { status => 'published' } );
    };

    redirect '/admin/posts';

};

=head

draft method

=cut

get '/admin/posts/draft/:id' => sub {
    my $post_id = params->{id};

    my $post;
    eval {
        $post = resultset('Post')->find($post_id);
        $post->update( { status => 'draft' } );
    };

    redirect '/admin/posts';
};

=head

trash method

=cut

get '/admin/posts/trash/:id' => sub {

    my $post_id = params->{id};

    my $post;
    eval {
        $post = resultset('Post')->find($post_id);
        $post->update( { status => 'trash' } );
    };

    redirect '/admin/posts';

};

=head

add method

=cut

any '/admin/posts/add' => sub {

    my @categories = resultset('Category')->all();
    my $post_id;

    eval {
        if ( params->{post} ) {

          my $user    = session('user');
          my $status  = params->{status};
          my $title   = params->{title};
          my $content = params->{post};
          my $slug    = String::Dirify->dirify( trim( params->{slug} ), '-' );    # Convert the string intro a valid slug

          # Check if the slug used is already taken
          my $found_slug = resultset('Post')->find({ slug => $slug });

          if ( $found_slug ) {
            # Extract the posts with slugs starting the same with the submited slug
            my @posts_with_same_slug = resultset('Post')->search({ slug => { like => "$slug%"}});
            my @slugs;
            push @slugs, $_->slug foreach @posts_with_same_slug;

            $slug = generate_new_slug_name($slug, \@slugs);

            # Store a warning message so it can be shown on the view
            session warning => 'The slug was already taken but we generated a similar slug for you! Feel free to change it as you wish.';
          }

          # Upload the cover image first so we'll have the generated filename ( if exists )
          my $cover;
          my $ext;
          my $crypted_filename = generate_crypted_filename();
          if ( upload('cover') ) {
              $cover = upload('cover');
              ($ext) = $cover->filename =~ /(\.[^.]+)$/;  #extract the extension
              $ext = lc($ext);
          }
          $cover->copy_to( config->{covers_folder} . $crypted_filename . $ext ) if $cover;

          # Next we can store the post into the database safely
          my $post = resultset('Post')->create(
              {
                  title   => $title,
                  slug    => $slug,
                  content => $content,
                  user_id => $user->id,
                  status  => $status,
                  cover   => ( $cover ) ? $crypted_filename . $ext : '',
              });
          # Store the post id so that we can redirect the user to the post created
          $post_id = $post->id;

          # Connect the categories selected with the new post
          params->{category} = 1 if ( !params->{category} );                                                                # If no category is selected the Uncategorized category will be stored default
          my @categories_selected = ref( params->{category} ) eq 'ARRAY' ? @{ params->{category} } : params->{category};    # Force an array if only one category was selected

          resultset('PostCategory')->create(
              {
                  category_id => $_,
                  post_id     => $post->id
              }
          ) foreach (@categories_selected);

          # Connect and update the tags table
          my @tags = split( ', ', params->{tags} );
          foreach my $tag (@tags) {

            # Replace all white spaces with hyphen
            my $slug = $tag;
            $slug = String::Dirify->dirify( trim($slug), '-' );    # Convert the string intro a valid slug

            my $db_tag = resultset('Tag')->find_or_create( { name => $tag, slug => $slug } );

            resultset('PostTag')->create(
                {
                    tag_id  => $db_tag->id,
                    post_id => $post->id
                }
            );
          }
        }
    };

    error $@ if ($@);
    # If the post was added successfully, store a success message to show on the view
    session success => 'The post was added successfully' if ( !$@ && $post_id );

    # If the user created a new post redirect him to the post created
    if ( $post_id ) {
      redirect '/admin/posts/edit/' . $post_id;
    }
    else {
      template '/admin/posts/add', { categories => \@categories }, { layout => 'admin' };
    }

};

=head

edit method

=cut

get '/admin/posts/edit/:id' => sub {

    my $post_id         = params->{id};
    my $post            = resultset('Post')->find($post_id);
    my @post_categories = $post->post_categories;
    my @post_tags       = $post->post_tags;
    my @all_categories  = resultset('Category')->all;

    # Prepare tags for the UI
    my @tag_names;
    push( @tag_names, $_->tag->name ) foreach (@post_tags);
    my $joined_tags = join( ', ', @tag_names );

    # Prepare the categories
    my @categories;
    push( @categories, $_->category ) foreach (@post_categories);

    # Array of post categories id for populating the checkboxes
    my @categories_ids;
    push( @categories_ids, $_->id ) foreach (@categories);

    my $params = {
        post           => $post,
        tags           => $joined_tags,
        categories     => \@categories,
        all_categories => \@all_categories,
        ids            => \@categories_ids
      };

    # Check if there are any messages to show
    # Delete them after stored on the stash
    if ( session('warning') ) {
      $params->{warning} = session('warning');
      session warning => undef
    }
    elsif ( session('success') ) {
      $params->{success} = session('success');
      session success => undef;
    }

    template '/admin/posts/edit', $params, { layout => 'admin' };

};

=head

update method

=cut

post '/admin/posts/update/:id' => sub {

    my $post_id = params->{id};
    my $post    = resultset('Post')->find($post_id);
    my $title   = params->{title};
    my $content = params->{post};
    my $tags    = params->{tags};
    my $slug    = String::Dirify->dirify( trim( params->{slug} ), '-' );    # Convert the string intro a valid slug

    # Check if the slug used is already taken
    my $found_slug = resultset('Post')->search({ id => { '!=' => $post_id }, slug => $slug })->first;

    if ( $found_slug ) {
      # Extract the posts with slugs starting the same with the submited slug
      my @posts_with_same_slug = resultset('Post')->search({ slug => { like => "$slug%"}});
      my @slugs;
      push @slugs, $_->slug foreach @posts_with_same_slug;

      $slug = generate_new_slug_name($slug, \@slugs);
      session warning => 'The slug was already taken but we generated a similar slug for you! Feel free to change it as you wish.';
    }

    eval {
        # Upload the cover image
        my $cover;
        my $ext;
        my $crypted_filename;

        if ( upload('cover') ) {

            # If the user uploaded a cover image, generate a crypted name for uploading
            $crypted_filename = generate_crypted_filename();            
            $cover = upload('cover');
            ($ext) = $cover->filename =~ /(\.[^.]+)$/;            #extract the extension
            $ext = lc($ext);
            $cover->copy_to( config->{covers_folder} . $crypted_filename . $ext );
        }

        my $status = params->{status};
        $post->update(
            {
                title   => $title,
                slug    => $slug,
                cover   => ($crypted_filename) ? $crypted_filename . $ext : $post->cover,
                status  => $status,
                content => $content,
            }
        );

        # Reconnect the categories with the new one and delete the old ones
        my @post_categories = resultset('PostCategory')->search( { post_id => $post_id } );
        $_->delete foreach (@post_categories);

        my @categories = ref( params->{category} ) eq 'ARRAY' ? @{ params->{category} } : params->{category};    # Force an array if only one category was selected

        resultset('PostCategory')->create(
            {
                category_id => $_,
                post_id     => $post->id
            }
        ) foreach (@categories);

        # Reconnect and update the selected tags
        my @post_tags = resultset('PostTag')->search( { post_id => $post_id } );
        $_->delete foreach (@post_tags);

        my @tags = split( ',', params->{tags} );
        foreach my $tag (@tags) {
            my $slug = $tag;
            $slug = String::Dirify->dirify( trim($slug), '-' );    # Convert the string intro a valid slug

            my $db_tag = resultset('Tag')->find_or_create( { name => $tag, slug => $slug } );

            resultset('PostTag')->create(
                {
                    tag_id  => $db_tag->id,
                    post_id => $post->id
                }
            );
        }

    };

    error $@ if ($@);

    session success => 'The post was updated successfully!';

    redirect '/admin/posts/edit/' . $post_id;

};

1;

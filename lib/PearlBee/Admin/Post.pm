
=head

Author: Andrei Cacio
Email: andrei.cacio@evozon.com

=cut

package PearlBee::Admin::Post;

use Dancer2;
use Dancer2::Plugin::DBIC;

use PearlBee::Helpers::Util qw/generate_crypted_filename generate_new_slug_name/;
use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link generate_pagination_numbering);

use String::Dirify;
use String::Util 'trim';
use DateTime;

get '/admin/posts' => sub { redirect session('app_url') . '/admin/posts/page/1'; };

=head

list all posts method per page

=cut

get '/admin/posts/page/:page' => sub {

    my $nr_of_rows  = 5; # Number of posts per page
    my $page        = params->{page};
    my @posts       = resultset('Post')->search( {}, { order_by => { -desc => 'created_date' }, rows => $nr_of_rows, page => $page } );
    my $publish     = resultset('Post')->search( { status       => 'published' } )->count;
    my $trash       = resultset('Post')->search( { status       => 'trash' } )->count;
    my $draft       = resultset('Post')->search( { status       => 'draft' } )->count;
    my $all         = resultset('Post')->search( {}, { order_by => { -desc => 'created_date' } })->count;

    # Calculate the next and previous page link
    my $total_pages                 = get_total_pages($all, $nr_of_rows);
    my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/admin/posts');

    # Generating the pagination navigation
    my $total_posts     = $all;
    my $posts_per_page  = $nr_of_rows;
    my $current_page    = $page;
    my $pages_per_set   = 7;
    my $pagination      = generate_pagination_numbering($total_posts, $posts_per_page, $current_page, $pages_per_set);

    template '/admin/posts/list',
      {
        posts         => \@posts,
        trash         => $trash,
        draft         => $draft,
        publish       => $publish,
        all           => $all,
        page          => $page,
        next_link     => $next_link,
        previous_link => $previous_link,
        action_url    => 'admin/posts/page',
        pages         => $pagination->pages_in_set
      },
      { layout => 'admin' };

};

=head

list all published posts

=cut

get '/admin/posts/:status/page/:page' => sub {

    my $nr_of_rows  = 5; # Number of posts per page
    my $page        = params->{page} || 1;
    my $status      = params->{status};
    my @posts       = resultset('Post')->search( { status => $status }, { order_by => { -desc => 'created_date' }, rows => $nr_of_rows, page => $page } );
    my $all         = resultset('Post')->search( { 1      => '1' } )->count;
    my $trash       = resultset('Post')->search( { status => 'trash' } )->count;
    my $draft       = resultset('Post')->search( { status => 'draft' } )->count;
    my $publish     = resultset('Post')->search( { status => 'published' }, { order_by => { -desc => 'created_date' } } )->count;
    
    my $status_count = resultset('Post')->search( { status => $status } )->count;

    # Calculate the next and previous page link
    my $total_pages                 = get_total_pages($status_count, $nr_of_rows);
    my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/admin/posts/' . $status);

    # Generating the pagination navigation
    my $total_posts     = $status_count;
    my $posts_per_page  = $nr_of_rows;
    my $current_page    = $page;
    my $pages_per_set   = 7;
    my $pagination      = generate_pagination_numbering($total_posts, $posts_per_page, $current_page, $pages_per_set);

    template '/admin/posts/list',
      {
        posts         => \@posts,
        trash         => $trash,
        draft         => $draft,
        publish       => $publish,
        all           => $all,
        page          => $page,
        next_link     => $next_link,
        previous_link => $previous_link,
        action_url    => 'admin/posts/' . $status . '/page',
        pages         => $pagination->pages_in_set
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

    redirect session('app_url') . '/admin/posts';

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

    redirect session('app_url') . '/admin/posts';
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

    redirect session('app_url') . '/admin/posts';

};

=head

add method

=cut

any '/admin/posts/add' => sub {

    my @categories = resultset('Category')->all();
    my $post;

    eval {
        if ( params->{post} ) {
          
          # Set the proper timezone
          my $dt       = DateTime->now;          
          my $settings = resultset('Setting')->first;
          $dt->set_time_zone( $settings->timezone );

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
          my $dtf = schema->storage->datetime_parser;
          $post = resultset('Post')->create(
              {
                  title        => $title,
                  slug         => $slug,
                  content      => $content,
                  user_id      => $user->id,
                  status       => $status,
                  created_date => $dtf->format_datetime($dt),
                  cover        => ( $cover ) ? $crypted_filename . $ext : '',
              });

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
          my @tags = split( ',', params->{tags} );
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
    session success => 'The post was added successfully' if ( !$@ && $post );

    # If the user created a new post redirect him to the post created
    if ( $post ) {
      redirect session('app_url') . '/admin/posts/edit/' . $post->slug;
    }
    else {
      template '/admin/posts/add', { categories => \@categories }, { layout => 'admin' };
    }

};

=head

edit method

=cut

get '/admin/posts/edit/:slug' => sub {

    my $post_slug       = params->{slug};
    my $post            = resultset('Post')->find({ slug => $post_slug });
    my @post_categories = $post->post_categories;
    my @post_tags       = $post->post_tags;
    my @all_categories  = resultset('Category')->all;
    my @all_tags        = resultset('Tag')->all;

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
        ids            => \@categories_ids,
        all_tags       => \@all_tags
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

    my $post_slug = params->{slug};
    my $post      = resultset('Post')->find({ slug => $post_slug });
    my $title     = params->{title};
    my $content   = params->{post};
    my $tags      = params->{tags};
    my $slug      = String::Dirify->dirify( trim( params->{slug} ), '-' );    # Convert the string intro a valid slug

    # Check if the slug used is already taken
    my $found_slug = resultset('Post')->search({ id => { '!=' => $post->id }, slug => $slug })->first;

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
        my @post_categories = resultset('PostCategory')->search( { post_id => $post->id } );
        $_->delete foreach (@post_categories);

        my @categories = ref( params->{category} ) eq 'ARRAY' ? @{ params->{category} } : params->{category};    # Force an array if only one category was selected

        resultset('PostCategory')->create(
            {
                category_id => $_,
                post_id     => $post->id
            }
        ) foreach (@categories);

        # Reconnect and update the selected tags
        my @post_tags = resultset('PostTag')->search( { post_id => $post->id } );
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

    redirect session('app_url') . '/admin/posts/edit/' . $post->slug;

};

1;

package PearlBee::Search;

=head

Search controller

=cut

use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Model::Schema;
use PearlBee::Helpers::Util qw(map_posts);
use Search::Elasticsearch;
use Try::Tiny;
use Data::Dumper;

=head

Search user info.

=cut

sub map_user {
    my ($user) = @_;

    my $blog_count    = resultset('BlogOwner')->count({user_id => $user->id});
    my $post_count    = resultset('Post')->count({user_id => $user->id});
    my $comment_count = resultset('Comment')->count({uid => $user->id});

    return
      { id            => $user->id,
        name          => $user->name,
        username      => $user->username,
        register_date => $user->register_date,
        email         => $user->email,
        avatar_path   => $user->avatar_path,
        company       => $user->company,
        telephone     => $user->telephone,
        role          => $user->role,
        status        => $user->status,
        
        counts =>
        { blog    => $blog_count,
          post    => $post_count,
          comment => $comment_count,
        } };
}

get '/search/user-info/:query' => sub {
    my $search_query = route_parameters->{'query'};
    my @user         = resultset('User')->search(
      { username => { like => '%' . $search_query . '%' } } );

    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    return $json->encode(
      { info => [ map { map_user($_) } @user ] } );
};

=head

Search user posts.

=cut

get '/search/user-posts/:query' => sub {
    my $search_query = route_parameters->{'query'};
    my $user         = resultset('User')->find({username => $search_query});
    my @posts        = resultset('Post')->search(
                        { status => 'published', user_id => $user->id },
                        { order_by => { -desc => "created_date" },
                          rows => config->{'search'}{'user_posts'} || 10 }
    );

    # extract demo posts info
    my @mapped_posts = map_posts(@posts);
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    return $json->encode({ posts => [ @mapped_posts ] });
};

=head

Search user tags.

=cut

sub map_tags {
    my ($self) = @_;
    return {
        id => $self->id,
        name => $self->name,
        slug => $self->slug,
    }
}

get '/search/user-tags/:query' => sub {
    my $search_query = route_parameters->{'query'};
    my $user         = resultset('User')->find({username => $search_query});
    my @posts        = resultset('Post')->search(
                        { status => 'published', user_id => $user->id },
                        { order_by => { -desc => "created_date" } }
    );
    my @tags = map { map_tags( $_ ) } map { $_->tag_objects } @posts;

    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    return $json->encode({ tags => \@tags });
};


=head

Search posts.

=cut

get '/search/posts/:query' => sub {
    my $search_query = route_parameters->{'query'};
    my $user = session('user');
    my $es = Search::Elasticsearch->new(
        trace_to => 'Stderr'    # Trace to stderr
    );

    my $error;
    my $elastic_results;
    my @results;

    try {
        $elastic_results = $es->search(
            index => 'posts',
            body => {
                query => {
                    match_phrase_prefix => {
                        title => $search_query
                    }
                }
            }
        );
        # Iterate through elastic result hits, search DB for them and push them in results
        for (my $i = 0; $i < $elastic_results->{hits}{total}; $i++) {
            my $rs = resultset('Post')->find({ id => $elastic_results->{hits}{hits}[$i]{_id}});
            push (@results, {
                id            => $rs->id,
                title         => $rs->title,
                slug          => $rs->slug,
                description   => $rs->description,
                content       => $rs->content,
                created_date  => $rs->created_date
            });
        }
    } catch {
        $error = "Error in search: $_";
    };

    return Dumper(\@results);
};

=head

Search users.

=cut

get '/search/users/:query' => sub {
    my $search_query = route_parameters->{'query'};
    my $user = session('user');
    my $es = Search::Elasticsearch->new(
        trace_to => 'Stderr'    # Trace to stderr
    );

    my $error;
    my $elastic_results;
    my @results;

    try {
        $elastic_results = $es->search(
            index => 'users',
            body => {
                query => {
                    match_phrase_prefix => {
                        name => $search_query
                    }
                }
            }
        );
        # Iterate through elastic result hits, search DB for them and push them in results
        for (my $i = 0; $i < $elastic_results->{hits}{total}; $i++) {
            my $rs = resultset('User')->find({ id => $elastic_results->{hits}{hits}[$i]{_id}});
            push (@results, {
                id          => $rs->id,
                name        => $rs->name,
                username    => $rs->username,
                email       => $rs->email,
                role        => $rs->role
            });
        }
    } catch {
        $error = "Error in search: $_";
    };

    return Dumper \@results;
};



=head

Search tags.

=cut

get '/search/tags/:query' => sub {
    my $search_query = route_parameters->{'query'};
    my $user = session('user');
    my $es = Search::Elasticsearch->new(
        trace_to => 'Stderr'    # Trace to stderr
    );

    my $error;
    my $elastic_results;
    my @results;

    try {
        $elastic_results = $es->search(
            index => 'tags',
            body => {
                query => {
                    match_phrase_prefix => {
                        name => $search_query
                    }
                }
            }
        );
        # Iterate through elastic result hits, search DB for them and push them in results
        for (my $i = 0; $i < $elastic_results->{hits}{total}; $i++) {
            my $rs = resultset('Tag')->find({ id => $elastic_results->{hits}{hits}[$i]{_id}});
            push (@results, {
                id     => $rs->id,
                name   => $rs->name,
                slug   => $rs->slug
            });
        }
    } catch {
        $error = "Error in search: \n $_";
    };

    return Dumper(\@results);
};

=head

Index the DB for elastic

=cut

sub indexDB {
    my $es = Search::Elasticsearch->new(
        trace_to => 'Stderr'    # Trace to stderr
    );
    print "Indexing DB...\n";

    try {
        # $es->indices->delete(index => '*');     # <<< More risky option. Clears whole elastic!
        $es->indices->delete(index=>'posts');
        $es->indices->delete(index=>'users');
        $es->indices->delete(index=>'tags');
    } catch {
        warn "Indexes were probably not yet created before, so nothing to delete.\n"
    };

    $es->indices->create(index=>'posts');
    $es->indices->create(index=>'users');
    $es->indices->create(index=>'tags');

    my $posts = resultset('Post')->search({});
    while ( my $post = $posts->next()) {
        if($post->status eq 'published') {
            $es->index(
                index   => 'posts',
                type    => 'published_blog_posts',
                id      => $post->id,
                body    => {
                    title       => $post->title,
                    description => $post->description,
                    date        => $post->created_date
                }
            );
        }
    };

    my $users = resultset('User')->search({});
    while ( my $user = $users->next()) {
        if($user->status eq 'active') {
            $es->index(
                index   => 'users',
                type    => 'active_users',
                id      => $user->id,
                body    => {
                    email   => $user->email,
                    name    => $user->name,
                    date    => $user->register_date
                }
            );
        }
    };

    my $tags = resultset('Tag')->search({});
    while ( my $tag = $tags->next()) {
        $es->index(
            index   => 'tag',
            type    => 'post_tag',
            id      => $tag->id,
            body    => {
                name => $tag->name,
                slug => $tag->slug
            }
        );
    };
};

true;

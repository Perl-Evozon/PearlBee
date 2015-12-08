package PearlBee::Search;

=head

Search controller

=cut

use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Model::Schema;
use Search::Elasticsearch;
use Try::Tiny;
use Data::Dumper;

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
                id          => $rs->id,
                title       => $rs->title,
                slug        => $rs->slug,
                description => $rs->description,
                content     => $rs->content
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

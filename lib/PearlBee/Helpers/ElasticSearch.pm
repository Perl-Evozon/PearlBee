package PearlBee::Helpers::ElasticSearch;

use strict;
use warnings;

use Dancer2;
use Search::ElasticSearch;

use Data::Dumper;

=item index_comment( $comment )

Index a Post object

=cut

sub index_post {
    my ($comment) = @_;
    reurn unless $post->status eq 'published';
    my $e = Search::ElasticSearch->new;

    try {
        $e->index(
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
    catch {
        info 'ElasticSearch index of comment ID ' . $comment->id . " failed: $_";
    };
}

=item index_comment( $comment )

Index a Comment object

=cut

sub index_comment {
    my ($comment) = @_;
    reurn unless $comment->status eq 'approved';
    my $e = Search::ElasticSearch->new;

    try {
        $e->index(
            index   => 'comments',
            type    => 'published_comments',
            id      => $comment->id,
            body    => {
                title       => $comment->title,
                description => $comment->description,
                date        => $comment->created_date
            }
        );
    }
    catch {
        info 'ElasticSearch index of comment ID ' . $comment->id . " failed: $_";
    };
}

=item search_posts( $text )

Search for posts by fulltext

=cut

sub search_posts {
    my ($text) = @_;
    my $es = Search::Elasticsearch->new;

    my $error;
    my $elastic_results;
    my @results;

    try {
        $elastic_results = $es->search(
            index => 'posts',
            body => {
                query => {
                    match_phrase_prefix => {
                        title => $text
                    }
                }
            }
        );

        # Iterate through elastic result hits, search DB for them and push them in results
        for my $i (0 .. $elastic_results->{hits}{total} - 1) {
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

    return $results;
}

=item search_comments( $text )

Search comments by fulltext

=cut

sub search_comments {
    my ($text) = @_;
    my $es = Search::Elasticsearch->new;

    my $error;
    my $elastic_results;
    my @results;

    try {
        $elastic_results = $es->search(
            index => 'comments',
            body => {
                query => {
                    match_phrase_prefix => {
                        title => $text
                    }
                }
            }
        );

        # Iterate through elastic result hits, search DB for them and push them in results
        for my $i (0 .. $elastic_results->{hits}{total} - 1) {
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

    return $results;
}

=item /search/tags:query

Search tags.

=cut

get '/search/tags/:query' => sub {
    my $search_query = route_parameters->{'query'};
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

=item indexDB()

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

1;

package PearlBee::Helpers::ElasticSearch;

use strict;
use warnings;

use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Model::Schema;
use Search::Elasticsearch;

require Exporter;
our @ISA 	= qw(Exporter);
our @EXPORT_OK 	= qw/search_posts search_comments/;

=head2 index_comment( $comment )

Index a Post object

=cut

sub index_post {
    my ($post) = @_;
    my $e      = Search::ElasticSearch->new;

    return unless $post->status eq 'published';

    try {
        $e->index(
            index => 'posts',
            type  => 'published_blog_posts',
            id    => $post->id,
            body  => {
                title       => $post->title,
                description => $post->description,
                date        => $post->created_date
            }
        );
    }
    catch {
        info 'ElasticSearch index of comment ID ' . $post->id . " failed: $_";
    };
}

=head2 index_comment( $comment )

Index a Comment object

=cut

sub index_comment {
    my ($comment) = @_;
    my $e         = Search::ElasticSearch->new;

    return unless $comment->status eq 'approved';

    try {
        $e->index(
            index => 'comments',
            type  => 'published_comments',
            id    => $comment->id,
            body  => {
                title       => $comment->title,
                description => $comment->description,
                date        => $comment->created_date
            }
        );
    }
    catch {
        info 'ElasticSearch index of comment ID ' .
             $comment->id .
             " failed: $_";
    };
}

=head2 search_posts( $text, $page )

Search for posts by fulltext

=cut

sub search_posts {
    my ($text,$page) = @_;
    my $page_size    = config->{search}{user_posts} || 10;
    my $es           = Search::Elasticsearch->new;

    my $start = $page * $page_size;
    my $elastic_results = $es->search(
        index => 'posts',
        params => { from => $start, size => $page_size },
        body => {
            query => {
		bool => {
		    should => [
                        { match => { title => $text } },
		        { match => { content => $text } },
		        { match => { username => $text } },
		    ]
                }
            }
        }
    );

    my @results;
    for my $result ( @{ $elastic_results->{hits}{hits} } ) {
        my $rs = resultset('Post')->find({ id => $result->{_id} });
        next unless $rs and $rs->id;
        my $user_avatar = $rs->user->avatar;
        if ( $user_avatar and $user_avatar =~ m{ ^/blog }x ) {
            $user_avatar = "";
        }                
	my $href = $rs->as_hashref_sanitized;
	$href->{created_date}   = $rs->created_date_human;
	$href->{nr_of_comments} = $rs->nr_of_comments;
	$href->{user}           = $rs->user->as_hashref_sanitized;
        $href->{tags}           = $result->{_source}{tags};
	push @results, $href;
    }

    return @results;
}

=head2 search_comments( $text )

Search comments by fulltext

=cut

sub search_comments {
    my ($text) = @_;
    my $es     = Search::Elasticsearch->new;

    my $elastic_results = $es->search(
        index => 'comments',
        body => {
            query => {
                match_phrase_prefix => { title => $text }
            }
        }
    );

    my @results;
    for my $result ( @{ $elastic_results->{hits}{hits} } ) {
        my $rs = resultset('Post')->find({ id => $result->{_id} });
        next unless $rs->status eq 'approved';
        push @results, $rs->as_hashref;
    }

    return @results;
}

=head2 indexDB()

Index the DB for elastic

=cut

sub indexDB {
    my $es = Search::Elasticsearch->new(
        trace_to => 'Stderr' # Trace to stderr
    );
    print "Indexing DB...\n";

    try {
        # $es->indices->delete(index => '*');     # <<< More risky option. Clears whole elastic!
        $es->indices->delete( index => 'posts' );
        $es->indices->delete( index => 'users' );
        $es->indices->delete( index => 'tags' );
    } catch {
        warn "Indexes were probably not yet created before, so nothing to delete.\n"
    };

    $es->indices->create( index => 'posts' );
    $es->indices->create( index => 'users' );
    $es->indices->create( index => 'tags' );

    my $posts = resultset('Post')->search({});
    while ( my $post = $posts->next()) {
        if($post->status eq 'published') {
            $es->index(
                index => 'posts',
                type  => 'published_blog_posts',
                id    => $post->id,
                body  => {
                    title       => $post->title,
                    description => $post->description,
                    date        => $post->created_date
                }
            );
        }
    };

    my $users = resultset('Users')->search({});
    while ( my $user = $users->next()) {
        if($user->status eq 'active') {
            $es->index(
                index => 'users',
                type  => 'active_users',
                id    => $user->id,
                body  => {
                    email => $user->email,
                    name  => $user->name,
                    date  => $user->register_date
                }
            );
        }
    };

    my $tags = resultset('Tag')->search({});
    while ( my $tag = $tags->next()) {
        $es->index(
            index => 'tag',
            type  => 'post_tag',
            id    => $tag->id,
            body  => {
                name => $tag->name,
                slug => $tag->slug
            }
        );
    };
};

1;

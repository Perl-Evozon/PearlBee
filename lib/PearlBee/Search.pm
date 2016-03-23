package PearlBee::Search;

=head1 Search controller

=cut

use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Model::Schema;
use PearlBee::Helpers::Util qw(map_posts);
use PearlBee::Helpers::ElasticSearch qw(search_posts search_comments);
use Data::Dumper;

=head2 Search user info.

=cut

sub map_user {
    my ($user) = @_;

    my $blog_count    = resultset('BlogOwner')->count({ user_id => $user->id });
    my $post_count    = resultset('Post')->count({ user_id => $user->id });
    my $comment_count = resultset('Comment')->count({ uid => $user->id });
    my $user_href     = $user->as_hashref_sanitized;

    $user_href->{counts} = {
      blog    => $blog_count,
      post    => $post_count,
      comment => $comment_count,
    };

    return $user_href;
}

=head2 Search for user info, return JSON

=cut

get '/search/user-info/:query' => sub {
    my $search_query = route_parameters->{'query'};
    my @user         = resultset('Users')->search_lc( $search_query );

    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    return $json->encode(
      { info => [ map { map_user($_) } @user ] } );
};

=head2 Search user posts.

=cut

get '/search/user-posts/:query' => sub {
    my $search_query = route_parameters->{'query'};
    my ( $user )     = resultset('Users')->search_lc( $search_query );
    my @posts        = resultset('Post')->search_published(
                        { user_id => $user->id },
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

=head2 Search user tags.

=cut

get '/search/user-tags/:query' => sub {
    my $search_query = route_parameters->{'query'};
    my @tags         = resultset('Tag')->search_lc($search_query);
    @tags = map { $_->as_hashref } @tags;

    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    return $json->encode({ tags => \@tags });
};


=head2 /search/posts/:query

Search posts via ElasticSearch

=cut

get '/search/posts/:query/:page' => sub {
    my $search_query = route_parameters->{'query'};
    my $page = route_parameters->{'page'};
    my @results =
        PearlBee::Helpers::ElasticSearch::search_posts($search_query,$page);
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    return $json->encode({ posts => \@results });
};

=head2 Search users.

=cut

get '/search/users/:query' => sub {
    my $search_query = route_parameters->{'query'};
    my $page         = 1;
    my @results =
        PearlBee::Helpers::ElasticSearch::search_posts($search_query,$page);
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    return $json->encode({ posts => \@results });
};

true;

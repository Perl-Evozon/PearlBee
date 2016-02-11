package PearlBee::Search;

=head

Search controller

=cut

use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Model::Schema;
use PearlBee::Helpers::Util qw(map_posts);
use PearlBee::Helpers::ElasticSearch qw(search_posts search_comments);
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
      { #id            => $user->id, # We shouldn't be exposing this.
        name          => $user->name,
        username      => $user->username,
        register_date => $user->register_date,
        email         => $user->email,
        avatar_path   => $user->avatar_path,
        avatar        => $user->avatar,
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
    my @user         = resultset('User')->
                       search( \[ "lower(username) like '%?%'" => $search_query ] );

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
    my $user         = resultset('User')->find( \[ 'lower(username) = ?' => $search_query ] );
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
        #id => $self->id, # We shouldn't be exposing this.
        name => $self->name,
        slug => $self->slug,
    }
}

get '/search/user-tags/:query' => sub {
    my $search_query = route_parameters->{'query'};
    my @tags         = resultset('Tag')->search(
      name => { like => '%' . $search_query . '%' }
    );
    @tags = map { map_tags( $_ ) } @tags;

    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    return $json->encode({ tags => \@tags });
};


=item /search/posts/:query

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

=head

Search users.

=cut

get '/search/users/:query' => sub {
    my $search_query = route_parameters->{'query'};
    my @results = search_posts($search_query);
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    return $json->encode({ posts => \@results });
};

true;

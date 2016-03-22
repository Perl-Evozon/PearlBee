package PearlBee::REST;

use Dancer2;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::REST;

prepare_serializer_for_format;

=haed

Get an array with all tags

=cut

get '/api/tags.:format' => sub {  
	my $user = session('user');

	if ($user) {
		my @tags = resultset('Tag')->all;
		my @list = map { $_->name } @tags;

		return \@list;
	}
};

=head

Get an array with all categories

=cut
get '/api/categories.:format' => sub {
  
	my $user = session('user');

	if ($user) {
		my @categories = resultset('Category')->all;
		my @list = map { $_->name } @categories;

		return \@list;
	}
};

1;

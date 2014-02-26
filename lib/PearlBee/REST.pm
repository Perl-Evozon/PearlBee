package PearlBee::REST;

use Dancer2;
use Dancer2::Plugin::DBIC;

=haed

Get an array with all tags

=cut

get '/api/tags.json' => sub {
  
	my $user = session('user');

    if ($user) {
	  my @tags = resultset('Tag')->all;
	  my @list;

	  push @list, $_->name foreach(@tags);
	  content_type 'application/json';

	  return to_json(\@list);
   }
};

1;
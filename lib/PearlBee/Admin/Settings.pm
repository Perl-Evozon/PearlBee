=head

Author: Andrei Cacio
Email: andrei.cacio@evozon.com

=cut

package PearlBee::Admin::Settings;

use Dancer2;
use Dancer2::Plugin::DBIC;

=haed

Index of settings page

=cut

get '/admin/settings' => sub {

	my $settings  = resultset('Setting')->first;
	my @timezones = resultset('Timezone')->all;

	template 'admin/settings/index.tt', 
		{ 
			settings  => $settings,
			timezones => \@timezones
		}, 
		{ layout => 'admin' };

};

1;
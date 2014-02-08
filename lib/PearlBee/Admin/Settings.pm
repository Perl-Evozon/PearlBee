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

	template 'admin/settings/index.tt', {}, { layout => 'admin' };

};

1;
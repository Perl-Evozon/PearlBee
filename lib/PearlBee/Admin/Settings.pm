=head

Author: Andrei Cacio
Email: andrei.cacio@evozon.com

=cut

package PearlBee::Admin::Settings;

use Dancer2;
use Dancer2::Plugin::DBIC;

use PearlBee::Helpers::Util qw/generate_crypted_filename/;

use DateTime::TimeZone;
use POSIX qw(tzset);

=haed

Index of settings page

=cut

get '/admin/settings' => sub {

	my $settings  = resultset('Setting')->first;
	my @timezones = DateTime::TimeZone->all_names;

	template 'admin/settings/index.tt', 
		{ 
			setting  => $settings,
			timezones => \@timezones
		}, 
		{ layout => 'admin' };

};

post '/admin/settings/save' => sub {
	
	my $settings;
	my @timezones 	 = DateTime::TimeZone->all_names;
	my $path 		 = params->{path};
	my $social_media = params->{social_media}; # If the social media checkbox isn't checked the value will be undef
	my $timezone  	 = params->{timezone};
	my $blog_name 	 = params->{blog_name};

	eval {
		$settings = resultset('Setting')->first;

		$settings->update({
			blog_path    => $path,
			timezone     => $timezone,
			social_media => ($social_media) ? '1' : '0',
			blog_name    => $blog_name
		});
	};

	error $@ if ( $@ );

	template 'admin/settings/index.tt', 
		{ 
			setting   => $settings,
			timezones => \@timezones,
			success   => 'The settings have been saved!'
		}, 
		{ layout => 'admin' };
};

1;
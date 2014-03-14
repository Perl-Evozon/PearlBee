=head

Author: Andrei Cacio
Email: andrei.cacio@evozon.com

=cut

package PearlBee::Admin::Settings;

use Dancer2;
use Dancer2::Plugin::DBIC;

use PearlBee::Helpers::Util qw/generate_crypted_filename/;
use PearlBee::Helpers::Import;

use DateTime::TimeZone;
use POSIX qw(tzset);
use XML::Simple qw(:strict);

=head

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

get '/admin/settings/import' => sub {
    template 'admin/settings/import.tt', 
		{}, 
		{ layout => 'admin' };    
};

post '/admin/settings/wp_import' => sub {
    if ( upload('source') ) {
        my $import          = upload('source');
        my $import_filename = generate_crypted_filename();
        my ($ext)           = $import->filename =~ /(\.[^.]+)$/;  #extract the extension
        $ext                = lc($ext);
        
        return template 'admin/settings/import.tt', 
            { 
                error   => 'File format not supported. Please choose an .xml file!'
            }, 
            { layout => 'admin' } if ( $ext ne '.xml' );
        
        $import_filename .= $ext;
        $import->copy_to( config->{import_folder} . $import_filename );
        
        my $xml_handler = XML::Simple->new();
        my $parsed_file = $xml_handler->XMLin( config->{import_folder} . $import_filename, ForceArray => 0, KeyAttr => 0 );

        return template 'admin/settings/import.tt', 
            { 
                error   => 'File format not supported. Please choose an .xml file!'
            }, 
            { layout => 'admin' } if ( !$parsed_file );

        my $import_handler = PearlBee::Helpers::Import->new(
            args => {
                parsed_file => $parsed_file,
                session     => session
            }
        );
        my $import_response = ( $import_handler->run_wp_import() )
                            ? { success => 'Blog content successfuly imported!' }
                            : { error   => 'There has been a problem with the import. Please contact support.' };
                                
        return	template 'admin/settings/import.tt', 
            $import_response, 
            { layout => 'admin' };            
    }
    
    return	template 'admin/settings/import.tt', 
        { 
            error   => 'No file chosen for import'
        }, 
        { layout => 'admin' };

};

1;
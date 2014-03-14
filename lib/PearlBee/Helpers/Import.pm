package PearlBee::Helpers::Import;

use Moose;

use Dancer2;
use Dancer2::Plugin::DBIC;

use LWP::UserAgent;
use LWP::Simple qw(getstore);
use File::Path qw( make_path );

use PearlBee::Helpers::Util qw(string_to_slug);
=head1 NAME

SubMan::Helpers::Import Helpers for PearlBee import functionality

=head1 DESCRIPTION

=head1 METHODS

=cut

=head2
    Arguments necessary to create the object:
        args => {
            parsed_file => $parsed_file, #the data gathered from the xml file
            session     => $args->{session}
        }
=cut

has args => (
    is       => 'rw',
    isa      => 'Maybe[HashRef]',
    required => 1
);

has run_wp_import => (
    is      => 'ro',
    builder => '_wp_import',
    lazy    => 1
);

sub _wp_import {
    my $self = shift;
    
    my $args = $self->args;
    
    #import user pictures
    my $host_link     = $args->{parsed_file}->{channel}->{link} =~ /(.*)\// ? $1 : ''; # it's greedy so it takes the entire host
    my $uploads_link  = $args->{parsed_file}->{channel}->{link} . '/wp-content/uploads/';
    my $content_link  = $args->{parsed_file}->{channel}->{link} . '/wp-content';
    
    my $ua            = LWP::UserAgent->new();
    my $year_response = $ua->get($uploads_link);
    my @year_links    = $year_response->content =~ /<a\shref=\"(.*)\">/gmi;       
    @year_links       = grep {  $_ =~ /\d+/g } @year_links if scalar @year_links;
    
    eval {
        foreach my $year_link ( @year_links ) {
            my $month_response = $ua->get( $host_link . $year_link );
            my @month_links    =  $month_response->content =~ /<a\shref=\"(.*)\">/gmi;
            @month_links       = grep {  $_ =~ /\d+/g } @month_links if scalar @year_links;
            
            foreach my $month_link ( @month_links ) {
                my $image_response = $ua->get( $host_link . $month_link );
                my @image_links    = $image_response->content =~ /<a\shref=\"(.*)\">/gmi;
                @image_links       = grep {  $_ =~ /\..*/g } @image_links if scalar @image_links;
                
                foreach my $image( @image_links ) {
                    my $image_save_path = $month_link =~ s/\/.*\/wp-content//r;
                    my $image_file_path = $image =~ s/\/.*\/wp-content//r;
    
                    make_path( config->{images_folder} . $image_save_path ) if ( ! -d config->{images_folder} . $image_save_path );
                    getstore( $host_link . $image, config->{images_folder} . $image_file_path );
                }
            }
        }
        
        #import user posts with related data
        foreach my $post ( @{ $args->{parsed_file}{channel}{item} } ) {            
            #insert new posts in db, avoid existing ones
            my $categories         = ( ref $post->{category} ne 'ARRAY' ) ? [ $post->{category} ] : $post->{category};
            my $comments           = ( ref $post->{"wp:comment"} ne 'ARRAY' ) ? [ $post->{"wp:comment"} ] : $post->{"wp:comment"};
            my $images_upload_path = config->{images_path};
            
            #replace image links with the ones related to our application           
            my $post_content       = $post->{"content:encoded"} =~ s/${content_link}/${images_upload_path}/rg;
            
            my $existing_post = schema->resultset('Post')->post_slug_exists( string_to_slug($post->{title}), $args->{session}->data->{user_id} );
            if ( $existing_post ) {
                $self->_update_wp_posts_on_import( $categories, $comments, $existing_post->id );
                next;
            }
            
            my $post_entry = schema->resultset('Post')->create({
                title        => $post->{title},
                slug         => string_to_slug($post->{title}),
                content      => $post_content,
                created_date => $post->{"wp:post_date"},
                status       => 'published',
                user_id      => $args->{session}->data->{user_id}
            });
            $self->_update_wp_posts_on_import( $categories, $comments, $post_entry->id );
        }
    };
    
    return ( $@ ) ? 0 : 1;
}

sub _update_wp_posts_on_import {
    my ( $self, $categories, $comments, $post_id ) = @_;
    
    my $args = $self->args;
    
    #import categories and tags
    foreach my $category ( grep { defined } @{ $categories } ) {
        my $category_set = {
            category => sub {
                #insert new categories
                schema->resultset('PostCategory')->connect_categories( $category->{content}, $post_id, $args->{session}->data->{user_id} );
            },
            post_tag => sub {
                #insert new tags
                schema->resultset('PostTag')->connect_tags( $category->{content}, $post_id );
            }
        };
        
        $category_set->{$category->{domain}}->();
    }
    
    #import comments
    foreach my $comment ( grep { defined } @{$comments} ) {
        schema->resultset('Comment')->create({
            content      => $comment->{"wp:comment_content"},
            email        => $comment->{"wp:comment_author_email"},
            comment_date => $comment->{"wp:comment_date"},
            status       => $comment->{"wp:comment_approved"} ? 'approved' : 'pending',
            post_id      => $post_id
        });
    }
}

__PACKAGE__->meta->make_immutable;

1;
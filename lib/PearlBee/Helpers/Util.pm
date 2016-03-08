package PearlBee::Helpers::Util;

use Data::GUID;
use String::Dirify;
use String::Random;
use String::Util 'trim';

use Digest::Bcrypt;
use Data::Entropy::Algorithms qw(rand_bits);
use MIME::Base64 qw(encode_base64 decode_base64);

use PearlBee::Password;

require Exporter;
our @ISA 	= qw(Exporter);
our @EXPORT_OK 	= qw(
    generate_crypted_filename 
    generate_new_slug_name 
    string_to_slug 
    map_posts 
    create_password
    generate_hash
);


=head

Generate a unique filename using GUID

=cut

sub generate_crypted_filename {
  	my $guid 	 = Data::GUID->new;
  	my $filename = $guid->as_string;

  	return $filename;
}

=head

Generate a new slug name based on existing slug names

=cut

sub generate_new_slug_name {
	my ( $original_slug, $similar_slugs ) = @_;

	# Extract only the slugs that matter: the slugs with this pattern: $original_slug-number	
	my @slugs_of_interest = grep { $_ =~ /^${original_slug}-\d*$/ } @{ $similar_slugs };

	my $max_number = 0;
	foreach ( @slugs_of_interest ) {
		my @parts = split('-', $_);
		my $number = $parts[-1];											# Get the number at the end of the slugs
		
		$max_number = ( $max_number < $number ) ? $number : $max_number;	# Find the biggest one
	}

	my $new_slug_name = $original_slug . '-' . ++$max_number;				# Generate the new slug name

    return $new_slug_name;
}

=head

Generate a valid slug kind name

=cut

sub string_to_slug {
	my ($string) = @_;

	my $slug = String::Dirify->dirify( trim($string), '-');

	return $slug;
}

=head

Generate a valid slug kind name

=cut

sub map_posts {
    my (@posts) = @_;
    
    # map info (utf8 compliance)
    my @mapped_posts = ();
    foreach my $post (@posts) {
        my $el = $post->as_hashref;
        $el->{nr_of_comments}     = $post->nr_of_comments;
        $el->{created_date_human} = $post->created_date_human;
        
        # get post author
        $el->{user} = {
            username => $post->user->username,
            avatar   => $post->user->avatar,
            id       => $post->user->id,
        };
        
        # add post categories
        foreach my $category ($post->post_categories) {
            my $details;
            $details->{category}->{name} = $category->category->name;
            $details->{category}->{slug} = $category->category->slug;
            push(@{$el->{post_categories}}, $details);
        }

        push(@mapped_posts, $el)
    }

    return @mapped_posts;
}

=head2 Create a password

=cut

sub create_password {
  my $plaintext = shift;
	
  # Match encryption from MT
  my @alpha  = ( 'a' .. 'z', 'A' .. 'Z', 0 .. 9 );
  my $salt   = join '', map $alpha[ rand @alpha ], 1 .. 16;

  my $crypt_sha =
    '$6$' . $salt . '$' . Digest::SHA::sha512_base64( $salt . $plaintext );
}

=head2 Create an authentication token

=cut

sub generate_hash {
    return -1 if @_ < 1 || @_ > 2;
	
    my $password = shift;
    my $hashref = {};

    my $bcrypt = Digest->new('Bcrypt');
    $bcrypt->cost(12);

    my @alpha  = ( 'a' .. 'z', 'A' .. 'Z', 0 .. 9 );
    my $salt   = join '', map $alpha[ rand @alpha ], 1 .. 16;
    $bcrypt->salt($salt);
    $bcrypt->add($password);

    return $bcrypt->hexdigest;
}

1;

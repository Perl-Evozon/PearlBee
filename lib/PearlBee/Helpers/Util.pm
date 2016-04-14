package PearlBee::Helpers::Util;

use URI::Encode qw(uri_encode);
use Data::GUID;
use String::Dirify;
use String::Random;

use Digest::Bcrypt;

use PearlBee::Password;

require Exporter;
our @ISA 	= qw(Exporter);
our @EXPORT_OK 	= qw(
    generate_crypted_filename 
    generate_new_slug_name 
    string_to_slug 
    map_posts 
    map_pages 
    create_password
    generate_hash
);


=head2 generate_crypted_filename

Generate a unique filename using GUID

=cut

sub generate_crypted_filename {
  	my $guid     = Data::GUID->new;
  	my $filename = $guid->as_string;

  	return $filename;
}

=head2 generate_new_slug_name

Generate a new slug name based on existing slug names

=cut

sub generate_new_slug_name {
	my ($original_slug, $similar_slugs) = @_;

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

=head2 xliterate_utf8

Generate a valid slug kind name

=cut

sub _xliterate_utf8 {
    my ($str) = @_;
    $str = Encode::encode_utf8($str);
    my %utf8_table = (
        "\xc3\x80" => 'A',     # A`
        "\xc3\xa0" => 'a',     # a`
        "\xc3\x81" => 'A',     # A'
        "\xc3\xa1" => 'a',     # a'
        "\xc3\x82" => 'A',     # A^
        "\xc3\xa2" => 'a',     # a^
        "\xc4\x82" => 'A',     # latin capital letter a with breve
        "\xc4\x83" => 'a',     # latin small letter a with breve
        "\xc3\x86" => 'AE',    # latin capital letter AE
        "\xc3\xa6" => 'ae',    # latin small letter ae
        "\xc3\x85" => 'A',     # latin capital letter a with ring above
        "\xc3\xa5" => 'a',     # latin small letter a with ring above
        "\xc4\x80" => 'A',     # latin capital letter a with macron
        "\xc4\x81" => 'a',     # latin small letter a with macron
        "\xc4\x84" => 'A',     # latin capital letter a with ogonek
        "\xc4\x85" => 'a',     # latin small letter a with ogonek
        "\xc3\x84" => 'A',     # A:
        "\xc3\xa4" => 'a',     # a:
        "\xc3\x83" => 'A',     # A~
        "\xc3\xa3" => 'a',     # a~
        "\xc3\x88" => 'E',     # E`
        "\xc3\xa8" => 'e',     # e`
        "\xc3\x89" => 'E',     # E'
        "\xc3\xa9" => 'e',     # e'
        "\xc3\x8a" => 'E',     # E^
        "\xc3\xaa" => 'e',     # e^
        "\xc3\x8b" => 'E',     # E:
        "\xc3\xab" => 'e',     # e:
        "\xc4\x92" => 'E',     # latin capital letter e with macron
        "\xc4\x93" => 'e',     # latin small letter e with macron
        "\xc4\x98" => 'E',     # latin capital letter e with ogonek
        "\xc4\x99" => 'e',     # latin small letter e with ogonek
        "\xc4\x9a" => 'E',     # latin capital letter e with caron
        "\xc4\x9b" => 'e',     # latin small letter e with caron
        "\xc4\x94" => 'E',     # latin capital letter e with breve
        "\xc4\x95" => 'e',     # latin small letter e with breve
        "\xc4\x96" => 'E',     # latin capital letter e with dot above
        "\xc4\x97" => 'e',     # latin small letter e with dot above
        "\xc3\x8c" => 'I',     # I`
        "\xc3\xac" => 'i',     # i`
        "\xc3\x8d" => 'I',     # I'
        "\xc3\xad" => 'i',     # i'
        "\xc3\x8e" => 'I',     # I^
        "\xc3\xae" => 'i',     # i^
        "\xc3\x8f" => 'I',     # I:
        "\xc3\xaf" => 'i',     # i:
        "\xc4\xaa" => 'I',     # latin capital letter i with macron
        "\xc4\xab" => 'i',     # latin small letter i with macron
        "\xc4\xa8" => 'I',     # latin capital letter i with tilde
        "\xc4\xa9" => 'i',     # latin small letter i with tilde
        "\xc4\xac" => 'I',     # latin capital letter i with breve
        "\xc4\xad" => 'i',     # latin small letter i with breve
        "\xc4\xae" => 'I',     # latin capital letter i with ogonek
        "\xc4\xaf" => 'i',     # latin small letter i with ogonek
        "\xc4\xb0" => 'I',     # latin capital letter with dot above
        "\xc4\xb1" => 'i',     # latin small letter dotless i
        "\xc4\xb2" => 'IJ',    # latin capital ligature ij
        "\xc4\xb3" => 'ij',    # latin small ligature ij
        "\xc4\xb4" => 'J',     # latin capital letter j with circumflex
        "\xc4\xb5" => 'j',     # latin small letter j with circumflex
        "\xc4\xb6" => 'K',     # latin capital letter k with cedilla
        "\xc4\xb7" => 'k',     # latin small letter k with cedilla
        "\xc4\xb8" => 'k',     # latin small letter kra
        "\xc5\x81" => 'L',     # latin capital letter l with stroke
        "\xc5\x82" => 'l',     # latin small letter l with stroke
        "\xc4\xbd" => 'L',     # latin capital letter l with caron
        "\xc4\xbe" => 'l',     # latin small letter l with caron
        "\xc4\xb9" => 'L',     # latin capital letter l with acute
        "\xc4\xba" => 'l',     # latin small letter l with acute
        "\xc4\xbb" => 'L',     # latin capital letter l with cedilla
        "\xc4\xbc" => 'l',     # latin small letter l with cedilla
        "\xc4\xbf" => 'l',     # latin capital letter l with middle dot
        "\xc5\x80" => 'l',     # latin small letter l with middle dot
        "\xc3\x92" => 'O',     # O`
        "\xc3\xb2" => 'o',     # o`
        "\xc3\x93" => 'O',     # O'
        "\xc3\xb3" => 'o',     # o'
        "\xc3\x94" => 'O',     # O^
        "\xc3\xb4" => 'o',     # o^
        "\xc3\x96" => 'O',     # O:
        "\xc3\xb6" => 'o',     # o:
        "\xc3\x95" => 'O',     # O~
        "\xc3\xb5" => 'o',     # o~
        "\xc3\x98" => 'O',     # O/
        "\xc3\xb8" => 'o',     # o/
        "\xc5\x8c" => 'O',     # latin capital letter o with macron
        "\xc5\x8d" => 'o',     # latin small letter o with macron
        "\xc5\x90" => 'O',     # latin capital letter o with double acute
        "\xc5\x91" => 'o',     # latin small letter o with double acute
        "\xc5\x8e" => 'O',     # latin capital letter o with breve
        "\xc5\x8f" => 'o',     # latin small letter o with breve
        "\xc5\x92" => 'OE',    # latin capital ligature oe
        "\xc5\x93" => 'oe',    # latin small ligature oe
        "\xc5\x94" => 'R',     # latin capital letter r with acute
        "\xc5\x95" => 'r',     # latin small letter r with acute
        "\xc5\x98" => 'R',     # latin capital letter r with caron
        "\xc5\x99" => 'r',     # latin small letter r with caron
        "\xc5\x96" => 'R',     # latin capital letter r with cedilla
        "\xc5\x97" => 'r',     # latin small letter r with cedilla
        "\xc3\x99" => 'U',     # U`
        "\xc3\xb9" => 'u',     # u`
        "\xc3\x9a" => 'U',     # U'
        "\xc3\xba" => 'u',     # u'
        "\xc3\x9b" => 'U',     # U^
        "\xc3\xbb" => 'u',     # u^
        "\xc3\x9c" => 'U',     # U:
        "\xc3\xbc" => 'u',     # u:
        "\xc5\xaa" => 'U',     # latin capital letter u with macron
        "\xc5\xab" => 'u',     # latin small letter u with macron
        "\xc5\xae" => 'U',     # latin capital letter u with ring above
        "\xc5\xaf" => 'u',     # latin small letter u with ring above
        "\xc5\xb0" => 'U',     # latin capital letter u with double acute
        "\xc5\xb1" => 'u',     # latin small letter u with double acute
        "\xc5\xac" => 'U',     # latin capital letter u with breve
        "\xc5\xad" => 'u',     # latin small letter u with breve
        "\xc5\xa8" => 'U',     # latin capital letter u with tilde
        "\xc5\xa9" => 'u',     # latin small letter u with tilde
        "\xc5\xb2" => 'U',     # latin capital letter u with ogonek
        "\xc5\xb3" => 'u',     # latin small letter u with ogonek
        "\xc3\x87" => 'C',     # ,C
        "\xc3\xa7" => 'c',     # ,c
        "\xc4\x86" => 'C',     # latin capital letter c with acute
        "\xc4\x87" => 'c',     # latin small letter c with acute
        "\xc4\x8c" => 'C',     # latin capital letter c with caron
        "\xc4\x8d" => 'c',     # latin small letter c with caron
        "\xc4\x88" => 'C',     # latin capital letter c with circumflex
        "\xc4\x89" => 'c',     # latin small letter c with circumflex
        "\xc4\x8a" => 'C',     # latin capital letter c with dot above
        "\xc4\x8b" => 'c',     # latin small letter c with dot above
        "\xc4\x8e" => 'D',     # latin capital letter d with caron
        "\xc4\x8f" => 'd',     # latin small letter d with caron
        "\xc4\x90" => 'D',     # latin capital letter d with stroke
        "\xc4\x91" => 'd',     # latin small letter d with stroke
        "\xc3\x91" => 'N',     # N~
        "\xc3\xb1" => 'n',     # n~
        "\xc5\x83" => 'N',     # latin capital letter n with acute
        "\xc5\x84" => 'n',     # latin small letter n with acute
        "\xc5\x87" => 'N',     # latin capital letter n with caron
        "\xc5\x88" => 'n',     # latin small letter n with caron
        "\xc5\x85" => 'N',     # latin capital letter n with cedilla
        "\xc5\x86" => 'n',     # latin small letter n with cedilla
        "\xc5\x89" => 'n',     # latin small letter n preceded by apostrophe
        "\xc5\x8a" => 'N',     # latin capital letter eng
        "\xc5\x8b" => 'n',     # latin small letter eng
        "\xc3\x9f" => 'ss',    # double-s
        "\xc5\x9a" => 'S',     # latin capital letter s with acute
        "\xc5\x9b" => 's',     # latin small letter s with acute
        "\xc5\xa0" => 'S',     # latin capital letter s with caron
        "\xc5\xa1" => 's',     # latin small letter s with caron
        "\xc5\x9e" => 'S',     # latin capital letter s with cedilla
        "\xc5\x9f" => 's',     # latin small letter s with cedilla
        "\xc5\x9c" => 'S',     # latin capital letter s with circumflex
        "\xc5\x9d" => 's',     # latin small letter s with circumflex
        "\xc8\x98" => 'S',     # latin capital letter s with comma below
        "\xc8\x99" => 's',     # latin small letter s with comma below
        "\xc5\xa4" => 'T',     # latin capital letter t with caron
        "\xc5\xa5" => 't',     # latin small letter t with caron
        "\xc5\xa2" => 'T',     # latin capital letter t with cedilla
        "\xc5\xa3" => 't',     # latin small letter t with cedilla
        "\xc5\xa6" => 'T',     # latin capital letter t with stroke
        "\xc5\xa7" => 't',     # latin small letter t with stroke
        "\xc8\x9a" => 'T',     # latin capital letter t with comma below
        "\xc8\x9b" => 't',     # latin small letter t with comma below
        "\xc6\x92" => 'f',     # latin small letter f with hook
        "\xc4\x9c" => 'G',     # latin capital letter g with circumflex
        "\xc4\x9d" => 'g',     # latin small letter g with circumflex
        "\xc4\x9e" => 'G',     # latin capital letter g with breve
        "\xc4\x9f" => 'g',     # latin small letter g with breve
        "\xc4\xa0" => 'G',     # latin capital letter g with dot above
        "\xc4\xa1" => 'g',     # latin small letter g with dot above
        "\xc4\xa2" => 'G',     # latin capital letter g with cedilla
        "\xc4\xa3" => 'g',     # latin small letter g with cedilla
        "\xc4\xa4" => 'H',     # latin capital letter h with circumflex
        "\xc4\xa5" => 'h',     # latin small letter h with circumflex
        "\xc4\xa6" => 'H',     # latin capital letter h with stroke
        "\xc4\xa7" => 'h',     # latin small letter h with stroke
        "\xc5\xb4" => 'W',     # latin capital letter w with circumflex
        "\xc5\xb5" => 'w',     # latin small letter w with circumflex
        "\xc3\x9d" => 'Y',     # latin capital letter y with acute
        "\xc3\xbd" => 'y',     # latin small letter y with acute
        "\xc5\xb8" => 'Y',     # latin capital letter y with diaeresis
        "\xc3\xbf" => 'y',     # latin small letter y with diaeresis
        "\xc5\xb6" => 'Y',     # latin capital letter y with circumflex
        "\xc5\xb7" => 'y',     # latin small letter y with circumflex
        "\xc5\xbd" => 'Z',     # latin capital letter z with caron
        "\xc5\xbe" => 'z',     # latin small letter z with caron
        "\xc5\xbb" => 'Z',     # latin capital letter z with dot above
        "\xc5\xbc" => 'z',     # latin small letter z with dot above
        "\xc5\xb9" => 'Z',     # latin capital letter z with acute
        "\xc5\xba" => 'z',     # latin small letter z with acute
    );

    $str =~ s/([\200-\377]{2})/$utf8_table{$1}||''/ge;
    $str = Encode::decode_utf8($str)
        unless Encode::is_utf8($str);
    $str;
}

=head2 remove_html

=cut

sub remove_html {
	my ($text) = @_;
	return '' unless defined $text;    # suppress warnings
	$text = Encode::encode_utf8($text);
	$text =~
	  s/(<\!\[CDATA\[(.*?)\]\]>)|(<[^>]+>)/defined $1 ? $1 : ''/geisx;
	$text =~ s/<(?!\!\[CDATA\[)/&lt;/gis;
	$text = Encode::decode_utf8($text)
		unless Encode::is_utf8($text);
	$text;
}

=head2 string_to_slug

Properly encode a UTF-8 text string to an ASCII slug.
Well, 'properly' in the sense that it should match MovableType out to Latin-1
But I'm guessing 

=cut

sub string_to_slug {
	my ($string) = @_;
	my $s = _xliterate_utf8( $string );
	my $sep = '-';

	$s = lc $s;            ## lower-case.
	$s = uri_encode( $s );
	$s = remove_html($s);  ## remove HTML tags.
	$s =~ s!&[^;\s]+;!!gs; ## remove HTML entities.
	$s =~ s![^\w\s-]!!gs;  ## remove non-word/space chars.
	$s =~ s!\s+!$sep!gs;

	return $s;
}

=head2 map_posts

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
        $el->{content_formatted}  = $post->content_formatted;
        
        # get post author
        $el->{user} = $post->user->as_hashref;
        
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

=head2 map_pages

Generate a valid slug kind name

=cut

sub map_pages {
    my (@pages) = @_;
    
    # map info (utf8 compliance)
    my @mapped_pages = ();
    foreach my $page (@pages) {
        my $el = $page->as_hashref;
        $el->{nr_of_comments}     = $page->nr_of_comments;
        $el->{created_date_human} = $page->created_date_human;
        
        # get page author
        $el->{user} = {
            username => $page->user->username,
            avatar   => $page->user->avatar,
            id       => $page->user->id,
        };
        
        # add post categories
        foreach my $category ($page->page_categories) {
            my $details;
            $details->{category}->{name} = $category->category->name;
            $details->{category}->{slug} = $category->category->slug;
            push(@{$el->{post_categories}}, $details);
        }

        push(@mapped_pages, $el)
    }

    return @mapped_pages;
}

=head2 create_password

Create a password

=cut

sub create_password {
  my ($plaintext) = @_;
	
  # Match encryption from MT
  my @alpha  = ( 'a' .. 'z', 'A' .. 'Z', 0 .. 9 );
  my $salt   = join '', map $alpha[ rand @alpha ], 1 .. 16;

  my $crypt_sha =
    '$6$' . $salt . '$' . Digest::SHA::sha512_base64( $salt . $plaintext );
}

=head2 generate_hash

Create an authentication token

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

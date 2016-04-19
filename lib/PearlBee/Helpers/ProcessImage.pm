package PearlBee::Helpers::ProcessImage;


=head1 NAME

Helpers::ProcessImage

=head1 SYNOPSIS

An easy way to resize uploaded images with ImageMagick.

=cut


use strict;
use warnings;

use Imager;
use Dancer2;

=head2 new

Process an existing image or newly uploaded image.

=cut

sub new {
    my ( $class, $file ) = @_;
    die 'Specify a file' unless defined($file);
 
    my $self = bless { file => $file }, $class;
    return $self;
}

=head2 resize

Resize the image to a given bounding box, specifying the path and name.

=cut

sub resize {
    my ( $self, $bounds, $save_path, $save_name ) = @_;

    my @fields = qw( height width top left );
    for my $name ( @fields ) {
        die "Missing field '$name'\n" unless exists $bounds->{$name};
    }
 
    die 'Specify a path for the file' unless defined($save_path);
    die 'Specify a name for the file' unless defined($save_name);

    my $pic = Imager->new( file => $self->{file} );
    $pic = $pic->crop(
        top    => int( $bounds->{top}    ),
        left   => int( $bounds->{left}   ),
        height => int( $bounds->{height} ),
        width  => int( $bounds->{width}  ),
    );
    $pic = $pic->scale(
        xpixels => config->{avatar}{bounds}{width},
        ypixels => config->{avatar}{bounds}{height},
    );

    $pic->write( file => "$save_path/$save_name" );

    return 1;
}

1;

package PearlBee::Helpers::ProcessImage;


=head1 NAME

Helpers::ProcessImage

=head1 SYNOPSIS

An easy way to resize uploaded images with ImageMagick.

=cut


use strict;
use warnings;
use Exporter qw(import);

our @EXPORT_OK = qw(new resize);

use Imager;

use Data::Dumper;
=head2 new

The new method;
It Will receive the desired maximum width and height of the new image to be created and returns a new object;

=cut

sub new {
    my ( $class, $max_width, $max_height ) = @_;

    if ( !defined($max_width) ) {
        die 'Please give in a max width';
    }
    elsif ( !defined($max_height) ) {
        die 'Please give in a max height';
    }
    my $self = bless {
        max_width  => $max_width,
        max_height => $max_height,
    }, $class;
    return $self;
}

=head2 resize

The resizing method;
It Will receive the uploaded file, where to save the new image, under what name and if desired,
the new extension of the image( in the eventuality that you desire to save a .jpg file as a .png).

=cut

sub resize {
    my ( $self, $file, $save_path, $save_name, $extension ) = @_;

    my $extensions = {
        'JPEG' => 'jpg',
        'JPG'  => 'jpg',
        'PNG'  => 'png',
    };

    if ( !defined($file) ) {
        die 'Please give a file';
    }
    elsif ( !defined($save_path) ) {
        die 'Please give a saving path for the file';
    }
    elsif ( !defined($save_name) ) {
        die 'Please give a saving name for the file';
    }

    my $pict = $file;
    my $pic = Imager->new( file => $pict->tempname );

    my $width  = $pic->getwidth;
    my $height = $pic->getheight;

    #resize the file according to the specified max width and max height
    my ( $tw, $th );

    if ( $height / $width < 1 ) {
        $th = $self->{max_width} * ( $height / $width );
        $tw = $self->{max_width};
    }
    else {
        $tw = $self->{max_height} * ( $width / $height );
        $th = $self->{max_height};
    }

    #creating the small images for the startup page
    $pic = $pic->scale( xpixels => $tw, ypixels => $th, type => 'nonprop' );
#        $pic = $pic->Montage( geometry => $tw . 'x' . $th, background => 'transparent', fill => 'transparent' );

#        $pic->Set( quality => 60 );

#    unless ($extension) {
#        $extension = $extensions->{$image_extension};
#    }
# $extension = 'jpg';

#     $pic->write( file => "$save_path/$save_name.$extension" );
$extension = 'png';

    $pic->write( file => "$save_path/$save_name.$extension" );

    return 1;
}

1;

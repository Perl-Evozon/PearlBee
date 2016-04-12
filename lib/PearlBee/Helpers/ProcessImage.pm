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
    my ( $class, $args ) = @_;
 
    my @fields = qw( height width top left );
    for my $name ( @fields ) {
        die "Missing field '$name'\n" unless exists $args->{$name};
    }
 
    my $self = bless {
        top    => int( $args->{top}    ),
        left   => int( $args->{left}   ),
        height => int( $args->{height} ),
        width  => int( $args->{width}  ),
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

    die 'Specify a file'              unless defined($file);
    die 'Specify a path for the file' unless defined($save_path);
    die 'Specify a name for the file' unless defined($save_name);

    my $pic = Imager->new( file => $file->tempname );
    $pic = $pic->crop(
        top    => $self->{top},
        left   => $self->{left},
        height => $self->{height},
        width  => $self->{width},
    );

    $extension = 'png';
    $pic->write( file => "$save_path/$save_name" );

    return 1;
}

1;

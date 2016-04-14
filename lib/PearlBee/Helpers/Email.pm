package PearlBee::Helpers::Email;

use strict;
use warnings;

use Dancer2;
use Email::Template;

use Email::MIME;
use IO::All;
use MIME::Lite::TT;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP::TLS;
use Data::Dumper;

use Try::Tiny;
use FindBin;
use Cwd qw( realpath );
use lib realpath("$FindBin::Bin/../lib");

require Exporter;
our @ISA       = qw( Exporter );
our @EXPORT_OK = qw( send_email send_email_complete );

=head2 send_email

=cut

sub send_email {
    my ( $template, $from, $to, $subject, $body ) = @_;

    my $appdir =
        realpath("$FindBin::Bin/..") .
        '/' .
        config->{email_templates} .
        $template;

    Email::Template->send(
        $appdir, {
            From    => $from,
            To      => $to,
            Subject => $subject,

            tt_vars => {
                mail_body => $body
            },
        }
    );
}

=head2 send_email_complete( $params )

Note: from can have this format: 'This is my name <myname@test.com>'

my $email_params = {
                from                => config->{ jobs_email },
                to                  => $job->poster_email,
                subject             => 'Applicant for ' . $job->title,
                attach_type         => request->uploads->{ uploadCV }->{ headers }->{ 'Content-Type' },
                attach_name         => request->uploads->{ uploadCV }->{ filename },
                attach_path         => request->uploads->{ uploadCV }->{ tempname },
                path_email_template => 'mypath/email-template.tt',
                template_params     => {
                    param1 => 'test,
                    ...
                }
            };
=cut

sub send_email_complete {
    my ( $params ) = @_;
    unless ( $params ) {
        error "NO PARAMETERS SENT";
    }

    my $transport = Email::Sender::Transport::SMTP::TLS->new({
        host     => config->{mail_server}->{host},
        port     => config->{mail_server}->{port},
        username => config->{mail_server}->{user},
        password => config->{mail_server}->{password},
    });

    my $template = join( '',
        realpath("$FindBin::Bin/.."),
        '/',
        config->{email_templates},
        $params->{template}
    );

    my $email_template = MIME::Lite::TT->new(
        Template   => $template,
        TmplParams => $params->{template_params},
    );

    my $attachment_part;

    #we might not send an attachment, so we check first if there is a path given for the file
    if ( $params->{attach_path} ) {
        $attachment_part = Email::MIME->create(
            attributes => {
                disposition  => "attachment",
                content_type => $params->{attach_type},
                name         => $params->{attach_path},
                filename     => $params->{attach_name},
                encoding     => "base64",
            },
            body => io( $params->{attach_path} )->all,
        );
    }

    my $actual_email_body = Email::MIME->create(
        attributes => {
            content_type => "text/html",
            encoding     => 'base64',
            charset      => "UTF-8",
        },
        body_str => $email_template->body_as_string,
    );

    my @parts = $actual_email_body;
    push @parts, $attachment_part if defined $attachment_part;

    #here we create the actual email and we set the parts
    my $email = Email::MIME->create(
        header_str => [
            From => $params->{from},
            To   => $params->{to},

            Subject => $params->{subject},
        ],
        parts => [@parts],
    );

    try {
        sendmail( $email, {transport => $transport} );
    }
    catch {
        error "COULD NOT send email from: '$params->{from}' to: '$params->{to}'" . $_;
        return 0;
    };
    return 1;
}

=head2 check_attachment( $path_to_file )

    This function tests if an attachment is safe to send.

    First the files are checked for extensions which can be executable
    on windows/mac/linux. They are found in "windows_extension.txt".

    Then, if the above step succeeds another verification is done using the
    "file" command.

    The command "file" alone can not detect a windows script( like .bat ), that is why we check the exctension for every one.

    Unacceped files are: executable, archive and sript.

    Not covered cases: .pdf, .doc which contain viruses.

=cut

sub check_attachment {
    my ($path_to_file) = @_;
    my $extension_bad = 0;

    # checking for extensions which are executable on windows/mac/linux
    open( my $fh, "<", config->{email_extensions} . "extensions.txt" ) or die "cannot open files with extensions: $!";

    while ( my $line = <$fh> ) {

        my $pattern;
        chomp( $pattern = $line );
        $pattern = "\\." . $pattern . "\$";

        if ( $path_to_file =~ /$pattern/i ) {
            $extension_bad = 1;
            info "Attachment '$path_to_file' has bad extension";
            return 0;
        }
    }

    close($fh);

    # check the file with 'file' command
    #run a command and capture its STDOUT
    my $output = `~/bin/file $path_to_file`;

    unless ( $output =~ /(executable|archive|script)/ ) {
        info "flle(1) reported that '$path_to_file' was potential malware";
        return 0;
    }

    return 1;
}

true;

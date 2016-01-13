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

use FindBin;
use Cwd qw( realpath );
use lib realpath("$FindBin::Bin/../lib");

sub send_email {
    my ( $template, $from, $to, $subject, $body ) = @_;
    my $transport = Email::Sender::Transport::SMTP::TLS->new(
        {   host     => config->{mail_server}->{host},
            port     => config->{mail_server}->{port},
            username => config->{mail_server}->{user},
            password => config->{mail_server}->{password},
        }
    );

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

=head
This is the structure of params

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
    my $transport = Email::Sender::Transport::SMTP::TLS->new(
        {   host     => config->{mail_server}->{host},
            port     => config->{mail_server}->{port},
            username => config->{mail_server}->{user},
            password => config->{mail_server}->{password},
        }
    );

    my $template =
        realpath("$FindBin::Bin/..") .
        '/' .
        config->{email_templates} .
        $params->{template};

    #info "\n\n-------------------SEND EMAIL-------------------\n\n";
    #info Dumper($params);
    if ($params) {
        eval {

            # email::mime does not have a module for tt templates, so I prepared the
            # body with mime::lite::tt and then return the body with body_as_string
            my $email_template = MIME::Lite::TT->new(
                Template   => $template,
                TmplParams => $params->{template_params},
            );

            # our email will have 2 parts: an html body and an attachment
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

            sendmail( $email, {transport => $transport} );

            #info "\n\n---------------------------email sent --------------------\n\n";
            return 1;
        } or do {
            warning "\n\n---------------------------COULD NOT send email from: '$params->{from}' to: '$params->{to}'---------\n\n" . $@;
            return 0;
        };
    }
    else {
        warning "\n\n---------------------------NO PARAMETERS SENT --------------------\n\n";
    }
}

=head
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
            last;
        }
    }

    close($fh);

    # check the file with 'file' command
    if ( !$extension_bad ) {

        print "\nEXTENSION OK!\n";

        #run a command and capture its STDOUT
#        m#y $output = qx/file $path_to_file/;
#		#run a command and capture its STDOUT
		my $output = `~/bin/file $path_to_file`;

        if ( $output !~ /(executable|archive|script)/ ) {
            print "\n FILE OK!\n";
            return 1;
        }

    }
    else {
        print "\nEXTENSION NOT OK!\n";
    }

    print "\n FILE NOT OK!\n";

    return 0;

}

true;

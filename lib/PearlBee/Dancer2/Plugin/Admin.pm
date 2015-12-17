package PearlBee::Dancer2::Plugin::Admin;
use strict;
use Dancer2::Plugin;
#use PearlBee;
use Dancer2::Plugin::DBIC;
use Data::Dumper;
on_plugin_import {
    my $dsl = shift;
    #$dsl->prefix('/admin');  
    $dsl->app->add_hook(
        Dancer2::Core::Hook->new(
            name => 'before',
            code => sub {
                $dsl->set( layout => 'admin' );
                my $context = shift;

                my $user = $context->session->{'data'}->{'user'};

                $user = $dsl->resultset('User')->find( $user->{id} ) if ($user);
                my $request = $context->request->path_info;
                my $app_url = $context->config->{'app_url'};
                # Check if the user is logged in
                if ( !$user && $request =~ /admin/ ) {
                    my $redir = $dsl->redirect( $app_url . '/admin' );
                    return $redir;
                }
                # Check if the user is activated
                if ( $request !~ /\/dashboard/ && $user) {
                    my $redir = $dsl->redirect( $app_url . '/dashboard' ) if ( $user->status eq 'inactive' );
                    return $redir;
                }

                # Restrict access to non-admin users
                if ( $request =~ '/admin/' && $user->is_author ) {
                    my $redir = $dsl->redirect( $app_url . '/author/posts' );
                    return $redir;
                }
            }
        )
    );
};


register_plugin for_versions => [2];

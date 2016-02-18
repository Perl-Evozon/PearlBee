use strict;
use warnings;

use Test::More tests => 72;
use Test::WWW::Mechanize;

my $BASE = 'http://139.162.204.109:5030';

note "Testing $BASE";
 
my $mech = Test::WWW::Mechanize->new;

#$mech->base_is( $BASE, 'Proper <BASE HREF>' );
#$mech->title_is( 'Invoice Status', "Make sure we're on the invoice page" );
#$mech->text_contains( 'Andy Lester', 'My name somewhere' );
#$mech->content_like( qr/(cpan|perl)\.org/, 'Link to perl.org or CPAN' );

my $avatar_path = 'support/uploads/1011226.jpg';
my $user_path = 'acme/useperl.png';

my $page_1 = 1;
my $slug = 'my_wonderful_post';
my $username = 'drforr';
my $query = 'Perl';

 
subtest 'GET tests' => sub {
  plan tests => 72;

  $mech->get_ok( $BASE . '/activation'                                   );
  #$mech->get_ok( $BASE . '/admin/categories/delete/:id'                  );
  $mech->get_ok( $BASE . '/admin/categories'                             );
  #$mech->get_ok( $BASE . '/admin/comments/approve/:id'                   );
  $mech->get_ok( $BASE . '/admin/comments/page/' . $page_1               );
  #$mech->get_ok( $BASE . '/admin/comments/pending/:id'                   );
  #$mech->get_ok( $BASE . '/admin/comments/spam/:id'                      );
  $mech->get_ok( $BASE . '/admin/comments/:status/page/' . $page_1       );
  $mech->get_ok( $BASE . '/admin/comments'                               );
  #$mech->get_ok( $BASE . '/admin/comments/trash/:id'                     );
  #$mech->get_ok( $BASE . '/admin/posts/draft/:id'                        );
  $mech->get_ok( $BASE . '/admin/posts/edit/' . $slug                    );
  $mech->get_ok( $BASE . '/admin/posts/page/' . $page_1                  );
  #$mech->get_ok( $BASE . '/admin/posts/publish/:id'                      );
  #$mech->get_ok( $BASE . '/admin/posts/:status/page/:page'               );
  $mech->get_ok( $BASE . '/admin/posts'                                  );
  #$mech->get_ok( $BASE . '/admin/posts/trash/:id'                        );
  $mech->get_ok( $BASE . '/admin/settings/import'                        );
  $mech->get_ok( $BASE . '/admin/settings'                               );
  $mech->get_ok( $BASE . '/admin'                                        );
  #$mech->get_ok( $BASE . '/admin/tags/delete/:id'                        );
  $mech->get_ok( $BASE . '/admin/tags'                                   );
  $mech->get_ok( $BASE . '/admin/users/page/' . $page_1                  );
  #$mech->get_ok( $BASE . '/admin/users/:status/page/' . $page_1          );
  $mech->get_ok( $BASE . '/admin/users'                                  );
  #$mech->get_ok( $BASE . '/api/categories.:format'                       );
  #$mech->get_ok( $BASE . '/api/tags.:format'                             );
  #$mech->get_ok( $BASE . '/author/comments/approve/:id'                  );
  #$mech->get_ok( $BASE . '/author/comments/page/' . $page_1              );
  #$mech->get_ok( $BASE . '/author/comments/pending/:id'                  );
  #$mech->get_ok( $BASE . '/author/comments/spam/:id'                     );
  #$mech->get_ok( $BASE . '/author/comments/' . $status . '/page/' . $page_1      );
  #$mech->get_ok( $BASE . '/author/comments'                              );
  #$mech->get_ok( $BASE . '/author/comments/trash/:id'                    );
  $mech->get_ok( $BASE . '/author/posts/add'                             );
  #$mech->get_ok( $BASE . '/author/posts/draft/:id'                       );
  #$mech->get_ok( $BASE . '/author/posts/edit/' . $slug                   );
  $mech->get_ok( $BASE . '/author/posts/page/' . $page_1                 );
  #$mech->get_ok( $BASE . '/author/posts/publish/:id'                     );
  #$mech->get_ok( $BASE . '/author/posts/:status/page/' . $page_1         );
  $mech->get_ok( $BASE . '/author/posts'                                 );
  #$mech->get_ok( $BASE . '/author/posts/trash/:id'                       );
  #$mech->get_ok( $BASE . '/avatars/*'                                    );
  $mech->get_ok( $BASE . '/feed/author/' . $username                     );
  $mech->get_ok( $BASE . '/feed/post/' . $slug                           );
  $mech->get_ok( $BASE . '/feed'                                         );
  #$mech->get_ok( $BASE . '/feed/:uid'                                    );
  $mech->get_ok( $BASE . '/logout'                                       );
  #$mech->get_ok( $BASE . '/oauth/:service/service_id/:service_id'        );
  $mech->get_ok( $BASE . '/page/' . $page_1                              );
  $mech->get_ok( $BASE . '/password_recovery'                            );
  $mech->get_ok( $BASE . '/posts/category/' . $slug . '/page/' . $page_1 );
  $mech->get_ok( $BASE . '/posts/category/' . $slug                      );
  $mech->get_ok( $BASE . '/post/' . $slug                                );
  $mech->get_ok( $BASE . '/posts/tag/' . $slug . '/page/' . $page_1      );
  $mech->get_ok( $BASE . '/posts/tag/' . $slug                           );
  $mech->get_ok( $BASE . '/posts/user/' . $username . '/page/' . $page_1 );
  $mech->get_ok( $BASE . '/posts/user/' . $username                      );
  $mech->get_ok( $BASE . '/profile/author/' . $username                  );
  $mech->get_ok( $BASE . '/profile'                                      );
  $mech->get_ok( $BASE . '/register_done'                                );
  $mech->get_ok( $BASE . '/register'                                     );
  $mech->get_ok( $BASE . '/register_success'                             );
  $mech->get_ok( $BASE . '/search/posts/' . $query . '/' . $page_1       );
  $mech->get_ok( $BASE . '/search'                                       );
  $mech->get_ok( $BASE . '/search/user-info/' . $username                );
  $mech->get_ok( $BASE . '/search/user-posts/' . $query                  );
  $mech->get_ok( $BASE . '/search/users/' . $query                       );
  $mech->get_ok( $BASE . '/search/user-tags/' . $query                   );
  $mech->get_ok( $BASE . '/sign-up'                                      );
  $mech->get_ok( $BASE . '/users/' . $user_path                          );
  $mech->get_ok( $BASE . '/'                                             );
};

subtest 'POST tests' => sub {
  plan tests => 13;

# $mech->post_ok( '/author/posts/add'
# $mech->post_ok( '/author/posts/update/:id'
# $mech->post_ok( '/register_success'
# $mech->post_ok( '/oauth/:username/service/:service/service_id/:service_id'
# $mech->post_ok( '/login'
# $mech->post_ok( '/admin/settings/save'
# $mech->post_ok( '/admin/settings/wp_import'
# $mech->post_ok( '/admin/categories/add'
# $mech->post_ok( '/admin/posts/update/:id'
# $mech->post_ok( '/admin/tags/add'
# $mech->post_ok( '/theme'
# $mech->post_ok( '/comments'
# $mech->post_ok( '/sign-up'
};

subtest 'ANY tests' => sub {
  plan tests => 12;

  my $id = 23;

  $mech->get_ok( $BASE . '/set-password' );
  $mech->get_ok( $BASE . '/forgot-password' );
  $mech->get_ok( $BASE . '/dashboard' );
  $mech->get_ok( $BASE . '/profile' );
  $mech->get_ok( $BASE . '/admin/users/activate/' . $id );
  $mech->get_ok( $BASE . '/admin/users/deactivate/' . $id );
  $mech->get_ok( $BASE . '/admin/users/suspend/' . $id );
  $mech->get_ok( $BASE . '/admin/users/allow/' . $id );
  $mech->get_ok( $BASE . '/admin/users/add' );
  $mech->get_ok( $BASE . '/admin/categories/edit/' . $id );
  $mech->get_ok( $BASE . '/admin/posts/add' );
  $mech->get_ok( $BASE . '/admin/tags/edit/:id' );
};

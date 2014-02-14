package PearlBee::Helpers::Pagination;

require Exporter;
our @ISA 		= qw(Exporter);
our @EXPORT_OK 	= qw/get_total_pages get_previous_next_link/;

=head

Return the total number of pages

=cut

sub get_total_pages {
	my ($nr_of_items, $nr_of_rows) = @_;

	my $total_pages   = ( ($nr_of_items / $nr_of_rows) != int($nr_of_items / $nr_of_rows) ) ? int($nr_of_items / $nr_of_rows) + 1 : ($nr_of_items % $nr_of_rows);

	return $total_pages;
}

sub get_previous_next_link {
	my ($page, $total_pages, $custom_link) = @_;

	$custom_link = $custom_link || '';

	my $previous_link = ( $page == 1 ) ? '#' : $custom_link . '/page/' . ( int($page) - 1 );
  	my $next_link     = ( $page == $total_pages ) ? '#' : $custom_link . '/page/' . ( int($page) + 1 );

  	return ($previous_link, $next_link);
}

1;

package PearlBee::Model::Schema::Result::Timezone;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("timezone");


__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "gmt",
  { data_type => "varchar", is_nullable => 0, size => 5 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 120 },
);
__PACKAGE__->set_primary_key("id");


__PACKAGE__->has_many(
  "settings",
  "PearlBee::Model::Schema::Result::Setting",
  { "foreign.timezone_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

1;

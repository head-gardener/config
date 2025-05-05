use v5.40;
use JSON::PP;
use Data::Dumper;
use List::Util qw(none);

my @net =
  map { {
    "name" => $_->{"ifname"},
    "mac" => $_->{"address"},
  } }
  grep { $_->{"ifname"} =~ /^en|^wl|^ww|^sl/ }
  @{decode_json `ip -json addr show`};

my %facts = (
  "net" => {
    "interfaces" => \@net,
  },
);

say encode_json \%facts;

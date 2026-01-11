use v5.40;
use JSON::PP;
# use Data::Dumper;

my @swapfiles =
  split "::",
  exists($ENV{FACTS_SWAPFILES}) ? $ENV{FACTS_SWAPFILES} : '';

my @net =
  map { {
    "name" => $_->{"ifname"},
    "mac" => $_->{"address"},
  } }
  grep { $_->{"ifname"} =~ /^en|^wl|^ww|^sl/ }
  @{decode_json `ip -json addr show`};

my @hibernation_files =
  map {
    my $fstype = trim `findmnt -no FSTYPE -T $_`;
    my $d = trim `findmnt -no UUID -T $_`;
    my $o = "";
    if ($fstype eq "btrfs") {
      $o = trim `btrfs inspect-internal map-swapfile -r "$_"`;
    } else {
      my $out = `filefrag -v "$_"`;
      if ($out =~ /.*0:.*/) {
        $o = (split /\s+/, $&)[4] =~ s/\.\.$//r;
      } else {
        warn "Couldn't filefrag $_ on filesystem type $fstype!\n"
      }
    }
    if ($o ne "") {
      {
        "path" => $_,
        "offset" => $o,
        "device" => "/dev/disk/by-uuid/$d",
      }
    } else { () }
  }
  @swapfiles;

my %facts = (
  "net" => {
    "interfaces" => \@net,
  },
  "swapfiles" => \@hibernation_files,
);

say encode_json \%facts;

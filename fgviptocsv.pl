#!/usr/bin/perl
#

my $output = "VIP-out.csv";

my $VipName = "";
my $setting = "";
my %Vips;
my %seen;
my $in_VIP_block = 0;
my @order_keys;
my $order_key = 0;

open(OUTFILE,">$output") || die "Can't open file $output: $!\n";

while (<>) {
	if ($in_VIP_block) {
		if (/^\s*edit\s+(.*)/i) {
			# start of new policy
			$VipName = $1;
		} elsif (/^\s*set\s+(\S+)\s+(.*)$/i) {
			# it's a setting
			my ($key,$value) = ($1,$2);
			$value =~ tr/\"\015\012\n\r//d;
			$order_keys[$order_key++] = $key unless $seen{$key}++;
			$Vips{$VipName}{$key} = $value;
		} elsif (/^\s*end/i) {
			$in_VIP_block = 0;
		}
	} elsif (/^\s*config firewall vip/i) {
		$in_VIP_block = 1;
	}
}

# print out our header
print OUTFILE "id";
foreach my $key (@order_keys) {
	print OUTFILE ",$key";
}
print OUTFILE "\n";

# now print out each record
foreach my $VIP (sort keys %Vips ) {
	print OUTFILE "$VIP";
	foreach my $key (@order_keys) {
		if (defined($Vips{$VIP}{$key})) {
			print OUTFILE ",$Vips{$VIP}{$key}";
		} else {
			print OUTFILE ",";
		}
	}
	print OUTFILE "\n";
}


close(OUTFILE);

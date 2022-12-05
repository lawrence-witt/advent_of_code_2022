use strict;
use warnings;

open my $lines, "input.txt" or die "failed to open";

my @stacks = ();

while(my $line = <$lines>)  {
  if ($line =~ /\s?([A-Z]|\s\s\s)/) {
    my @crates = $line =~ /\s?([A-Z]|\s\s\s)/g;
    for(my $i = 0; $i < scalar @crates; $i++){
      if (scalar @stacks < $i + 1) {
        push @stacks, ();
      }
      if($crates[$i] =~ /^\w$/) {
        unshift @{$stacks[$i]}, $crates[$i];
      }
    }
  }
  if ($line =~ /move\s(\d+)\sfrom\s(\d+)\sto\s(\d+)/g) {
    my $height = scalar @{$stacks[$2 - 1]};
    my @slice = splice(@{$stacks[$2 - 1]}, $height - $1, $height);
    push(@{$stacks[$3 - 1]}, $ARGV[0] == 1 ? reverse @slice : @slice);
  }
}

for my $i (@stacks) {
  my $height = scalar @{$i}; 
  print @{$i}[$height - 1];
}

close $lines;
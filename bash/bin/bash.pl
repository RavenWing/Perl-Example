#!/usr/bin/perl
use 5.016;
use warnings;

BEGIN {
	push ( @INC, '../lib' );
}

use Local::StringParser;

#$| = 1;

print "\$ ";
while (<>) {
	my $obj =Local::StringParser->new($_);
	$obj->startPipeline; 
	print "\$ ";
} 




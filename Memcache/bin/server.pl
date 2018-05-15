#!/usr/bin/env perl

use 5.016;
use warnings;

use AnyEvent::Socket;
use AnyEvent::Handle;
use AE;

BEGIN {
	push @INC, '../lib';
};

use Local::KeyValue;

my $cv = AE::cv;

tcp_server(undef, 8081, sub {
	my ($fh, $host, $port) = @_;

	my $h = AnyEvent::Handle->new(
		fh => $fh,
	);

	$h->on_error( sub{
		$h->destroy;
	});
	
	my $cb;
	$cb = sub {	
	        my $ans = parceAdd($_[1]);
		print "in cb\n";
    	   	if ( $_[1] =~ /^add/ ) {
       			my $w; $w = AE::timer 20, 0, sub {
					undef $w;
					deletKey();
			};
		}	   
		$h->push_read(line => $cb);
		$h->push_write($ans);	
	}; $h->on_read ( sub { $h->push_read( line => $cb )} );				
	
});

$cv->recv;

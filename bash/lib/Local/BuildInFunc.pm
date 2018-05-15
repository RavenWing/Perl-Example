package Local::BuildInFunc;

use warnings;
use 5.016;
use Cwd;
use Exporter 'import';
our @EXPORT = qw ( pwd cd ls echo killProc );

sub pwd {
	my $hd = shift;
	print $hd cwd() . "\n";
}

sub cd {
	my $path = shift;
    unless ( chdir($path) ) { print "Bad path\n" };
}

sub echo {
	my ($hd, $str) = @_;
	print $hd "$str\n";
}

sub killProc {
	my $aref = $_[0];
	kill 'KILL', @$aref;
}

sub ls {
	my $hd = shift;
	opendir(my $dh, './') or die $!;
	while( my $fname = readdir $dh ) {
		print $hd $fname."\t" unless ( $fname =~ /^\./ ) ;
	}
	print $hd "\n";
}



1;

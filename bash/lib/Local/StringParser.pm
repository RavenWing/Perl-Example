package Local::StringParser;

use warnings;
use 5.016;
use Local::ProsesStarter;
use Data::Dumper;

use Fcntl;

sub new {
	my ( $self, $str ) = @_;
	chomp $str;

	my $h = {
		'string' => $str,
		'commands' => [split /\|/, $str],
	};

	return bless $h, $self;
}

sub startPipeline {
	my $self = shift;
	my @a;
	my @pidChld;

	for ( @{ $self->{'commands'} } ) {
		push @a, Local::ProsesStarter->new($_);
	}

	my $outPid = $a[0]->makePipe(\*STDIN);

	for ( 1 .. $#a ) {
		$outPid = $a[$_]->makePipe( $outPid );
	}

	#fcntl($outPid, F_SETFL, O_NONBLOCK) or die "Can't set flags for the socket: $!\n";
	for (@a) {
		$_->start();
		push @pidChld, $_->getPidChild();
	}

	while (my $str = <$outPid>) {
		print $str;
	};

	close ($outPid);

	for (@pidChld) {
		waitpid ($_, 0) if $_;

	}
}

1;

package Local::ProsesStarter;

use Local::BuildInFunc;
use POSIX qw(:sys_wait_h);

use warnings;
use 5.016;

use Data::Dumper;

sub new {
	my ( $self, $str ) = @_;
	
	$str =~ s!(&)!!;
	my $h = {
		'str' => $str,
		'pidParent' => $$,
		'daemon' => $1,
	};

	return bless $h, $self;
}

sub makePipe {
	my ( $self, $readHd ) = @_;
		my ($readHdForOut, $writeHd);
		pipe ($readHdForOut, $writeHd);
		$self->{'writeHd'} = $writeHd;
		$self->{'readHd'} = $readHd;
		$self->{'readHdForOut'} = $readHdForOut;

		return $readHdForOut;
}

sub getWrite { my $self = shift; return $self->{'$readHd'} }

sub start {
	my $self = shift;

	if ( $self->{'str'} eq 'ls' ) {
		ls( $self->{'writeHd'} ) if ( $self->{'pidParent'} == $$ );
	}
	elsif ( $self->{'str'} eq 'pwd' ){
		pwd( $self->{'writeHd'} ) if ( $self->{'pidParent'} == $$ );
	}
	elsif ( $self->{'str'} =~ /^echo\s*['"]?([^'"]*)['"]?$/ ) {
		echo( $self->{'writeHd'}, $1 ) if ( $self->{'pidParent'} == $$ );
	} elsif ($self->{'str'} =~ /^cd (.+)/) {
		cd($1);
	}
	elsif ( $self->{'str'} =~ /^kill/ ) {
			my @a = grep {$_ =~ /^\d+$/} split //, $self->{'str'};
			killProc(\@a);
	} else {
		$self->{'myPid'} = fork() if $self->{'pidParent'} == $$;
		if ( $self->{'myPid'} == 0 ) {
			open ( STDIN, "<&", $self->{'readHd'} ); 
			open ( STDOUT, ">&", $self->{'writeHd'} ); 
			open ( STDERR, ">&",  \*STDOUT ); 

			exec $self->{'str'};
		}
	}

	close ( $self->{'writeHd'} );
	close ( $self->{'readHd'} ) if ( $self->{'readHd'} ne \*STDIN );
}

sub getPidChild {
	my $self = shift;
	return $self->{'myPid'} if ( $$ == $self->{'pidParent'} );
}

1;

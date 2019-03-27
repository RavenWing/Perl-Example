#!/usr/bin/perl
use 5.016;
use warnings;
use Getopt::Long qw/:config no_ignore_case/;
use Data::Dumper;
use List::Util qw /uniq/;
# хеш ключей
my %key = (
	'A' => 0,
	'B' => 0,
	'C' => 0
);

print "Hello";
# шаблон
my $regexp = $ARGV[$#ARGV];

GetOptions ( \%key,
	'A=i',
	'B=i',
	'C=i',
	'c'  ,
	'i'  ,
	'v'  ,
	'F'  ,
	'n'
) or die "Incorrect key";

# функция для сравнения с учетом ключей
my $regexpTrue;

if ( $key{'i'} && $key{'F'} ) {
	$regexpTrue = sub {
		my $a = shift;
		chomp $a;
		return 1 + index( lc $a, lc $regexp );
	};
}
elsif ( $key{'F'} ) {
	$regexpTrue = sub {
		my $a = shift;
		chomp $a;
		return 1 + index( $a, $regexp );
	};
}
elsif ( $key{'i'} ) {
	$regexpTrue = sub {
		my $a = shift;
		chomp $a;
		return $a =~ /$regexp/i;
	};
} else {
	$regexpTrue = sub {
		my $a = shift;
		chomp $a;
		return $a =~ /$regexp/;
	};
}

my $n = 0;

my $up = $key{'B'} > $key{'C'} ? $key{'B'} : $key{'C'};
my $down = $key{'A'} > $key{'C'} ? $key{'A'} : $key{'C'};
my $downCheck; # проверка выведения нижеследующих строк при наличии down
my $prev = 0; # последняя выведенная строчка
my @queue; # очередь строк
my @queueNum; # очередь номеров строк
#  функция для печати строк с номером
sub printLine {
	my ($foo, $bar) = @_;
	print "$bar." if $key{'n'};
	print $foo;
}

while (<STDIN>) {
	# ключ с - считаем количество строк
	if ( $key{'c'} ) {
		$n++ if ( $key{'v'} ? !$regexpTrue->($_) : $regexpTrue->($_) );
	}
	# если нет ключей А В С v
	elsif ( !$key{'A'} && !$key{'B'} && !$key{'C'} ) {
		printLine ($_, $.) if ( $key{'v'} ? !$regexpTrue->($_) : $regexpTrue->($_) );
	} else {
		# случай наличия отступов
		if ( $regexpTrue->($_) ) {
			# шаблон совпал - проверяем очередь и печатаем
			if ( scalar @queue > 0 ) {
				print "--\n" if ( $prev &&
						  $queueNum[0] - $prev > 1 );
				for ( 0..$#queue ) {
					printLine ($queue[$_], $queueNum[$_]);
				}
			} else {
				print "--\n" if ( $prev &&
								  $. - $prev > 1 );
			}
			printLine ($_, $.);
			$prev = $.;
			$downCheck = $down; # устанавливаем downcheck для печати нижнего отступа
			@queue = ();
			@queueNum = ();
		}
		# шаблон не совпал - но есть нижний отступ
		elsif ( $downCheck ) {
			printLine ($_, $.);
			$prev = $.;
			$downCheck--;
		}
		#если есть верхний отступ - заполняем очередь
		elsif ( $up ) {
			if ( scalar @queue < $up ) {
				push @queue, $_;
				push @queueNum, $.;
			} else {
				shift @queue;
				shift @queueNum;
				push @queue, $_;
				push @queueNum, $.;
			}
		}
	}
}

print "$n\n" if $key{'c'};

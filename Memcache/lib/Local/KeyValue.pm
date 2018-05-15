package Local::KeyValue;

use 5.016;
use warnings;
use Exporter 'import';
our @EXPORT = qw (parceAdd deletKey);

use AnyEvent;

our %h;
our $lastKey;

sub get {
	my ($key) = @_;
	return "Need key\n" unless defined $key;
	defined $h{$key} ? return $h{$key} : return "Invalid key $key\n";
}

sub set {
	my ($key, $value) = @_;
	return "Need key\n" unless defined $key;
	return "Need value\n" unless defined $value;
	defined $h{$key} ? $h{$key} = $value : return "Invalid key $key\n";
	return "Key $key now has $value value\n";
}

sub add {
	my ($key, $value) = @_;
	my $str;
	$lastKey = $key;
	return "Need key\n" unless defined $key;
	return "Need value\n" unless defined $value;
	$h{$key} = $value;

	return "Pair $key : $value added\n";
}

sub deletKey { delete $h{$lastKey} }

sub parceAdd {
	my ($str) = @_;
	defined $str or return "Undefined command\n";
	my @a = split /\s+/, $str;
	my $command = shift @a;
	return add(@a) if $command eq 'add';
	return set(@a) if $command eq 'set';
	return get(@a) if $command eq 'get';
	return "Undefined command\n";
}

1;

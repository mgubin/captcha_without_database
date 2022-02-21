package App::Helper::Exception;
use strict;
use warnings;
use Data::Dumper;
use English qw(-no_match_vars);
use Scalar::Util qw(blessed);
use overload q{""} => \&message, fallback => 1;

sub new
{
	my $class  = shift;
	my %params = @_;

	my $self = {
		message => "$class exception thrown",
		%params,
	};

	$class = ref $class if ref $class;
	bless $self, $class;

	return $self;
}

sub caught
{
	my $this_class = shift;

	return if not blessed $EVAL_ERROR;
	return $EVAL_ERROR->isa($this_class);
}

sub message
{
	my $self = shift;
	return $self->{message};
}

1;

__END__

=encoding cp1251

=head1 NAME

App::Helper::Exception - Работа с исключениями

=head1 SYNOPSIS

use Carp;
use App::Helper::Exception;
croak(App::Helper::Exception->new(message => $message));

=cut

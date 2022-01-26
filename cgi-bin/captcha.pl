#!/usr/bin/perl
BEGIN {
    use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
}
use strict;
use warnings;
use lib qw( ../lib );
use Controller::Captcha;
use Data::Dumper;
use Helper::Config;
use Helper::Logger;

my $logger = Helper::Logger->new();

# Получаем конфигурацию
my %config = Helper::Config->new(
    config_file => '../conf/capture.cfg',
    logger      => $logger
)->get();

my $web = Controller::Captcha->new(
    config => \%config,
    logger => $logger,
);

$web->process() if $web;

__END__


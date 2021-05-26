# ROCInput for Linux Plugin for SqueezeCenter

# Copyright (C) 2008 Bryan Alton and others
# All rights reserved.

# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Plugins::ROCInput::Settings;

use strict;
use base qw(Slim::Web::Settings);

use Slim::Utils::Log;
use Slim::Utils::Prefs;
use Slim::Player::Client;
use Slim::Utils::OSDetect;

my $prefs = preferences('plugin.rocinput');
my $log   = logger('plugin.rocinput');

my $osdetected = Slim::Utils::OSDetect::OS();


my %defaults = (
	pausestop  => 1,
);

$log->debug("Settings called");


sub new {
	my $class = shift;
	$log->debug("New Settings");
	$class->SUPER::new;
}

sub name {

# assumes at least SC 7.0
	if ( substr($::VERSION,0,3) lt 7.4 ) {
		return Slim::Web::HTTP::protectName('PLUGIN_ROCINPUT');
	} else {
	    # $::noweb to detect TinySC or user with no web interface
	    if (!$::noweb) {
		return Slim::Web::HTTP::CSRF->protectName('PLUGIN_ROCINPUT');
	    }
	}

}

sub page {


# assumes at least SC 7.0
	if ( substr($::VERSION,0,3) lt 7.4 ) {
		return Slim::Web::HTTP::protectURI('plugins/ROCInput/settings/basic.html');
	} else {
	    # $::noweb to detect TinySC or user with no web interface
	    if (!$::noweb) {
		return Slim::Web::HTTP::CSRF->protectURI('plugins/ROCInput/settings/basic.html');
	    }
	}

}

sub prefs {
	$log->debug("Prefs called");
	return ($prefs, qw( pausestop ));
}

sub handler {
	my ($class, $client, $params) = @_;
	$log->debug("Handler called");

	if ($params->{'saveSettings'}) {
		$prefs->set('pausestop', $params->{'pausestop'});
	}
	return $class->SUPER::handler( $client, $params );
}

sub setDefaults {
	my $force = shift;

	foreach my $key (keys %defaults) {
		if (!defined($prefs->get($key)) || $force) {
			$log->debug("Missing pref value: Setting default value for $key: " . $defaults{$key});
			$prefs->set($key, $defaults{$key});
		}
	}
}

sub init {
	my $self = shift;
	$log->debug("Initializing settings");
	setDefaults(0);
}

1;

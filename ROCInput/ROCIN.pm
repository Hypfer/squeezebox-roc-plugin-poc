#
#

package Plugins::ROCInput::ROCIN;

use strict;
use base qw(Slim::Player::Pipeline);
use Slim::Utils::Strings qw(string);
use Slim::Utils::Misc;
use Slim::Utils::Log;
use Slim::Utils::Prefs;

# use a small buffer threshold to make stream start playing quickly 
sub bufferThreshold { 60 } # 40kb = 1s of 320kbit/s mp3

Slim::Player::ProtocolHandlers->registerHandler('rocin', __PACKAGE__);

my $log		= logger('plugin.ROCInput');
my $prefs	= preferences('plugin.ROCInput');


sub isRemote { 1 } 

sub new {

	my $class = shift;
	my $args  = shift;
	my $transcoder = $args->{'transcoder'};
	my $url        = $args->{'url'} ;
	my $client     = $args->{'client'};


	my $restoredurl;

	$restoredurl = $url;
	$restoredurl =~ s|^rocin:||;

	Slim::Music::Info::setContentType($url, 'rocin');
	my $quality = preferences('server')->client($client)->get('lameQuality');

	my $command = Slim::Player::TranscodingHelper::tokenizeConvertCommand2( $transcoder, $restoredurl, $url, 1, $quality );
	$log->debug("ROCInput command =\'$command\'");

	my $self = $class->SUPER::new(undef, $command);

	${*$self}{'contentType'} = $transcoder->{'streamformat'};

	return $self;
}


sub canDoAction {
	my ( $class, $client, $url, $action ) = @_;
	$log->info("Action=$action");
	if (($action eq 'pause') && $prefs->get('pausestop') ) {
		$log->info("Stopping track because pref is set yo stop");
		return 0;
	}
	
	return 1;
}

sub canHandleTranscode {
	my ($self, $song) = @_;
	
	return 1;
}

sub getStreamBitrate {
	my ($self, $maxRate) = @_;
	
	return Slim::Player::Song::guessBitrateFromFormat(${*$self}{'contentType'}, $maxRate);
}

sub isAudioURL { 1 }

# XXX - I think that we scan the track twice, once from the playlist and then again when playing
sub scanUrl {
	my ( $class, $url, $args ) = @_;
	
	Slim::Utils::Scanner::Remote->scanURL($url, $args);
}

sub canDirectStream {
	return 0;
}

sub contentType 
{
	my $self = shift;

	return ${*$self}{'contentType'};
}


sub getMetadataFor {
	my ( $class, $client, $url, $forceCurrent ) = @_;

	my $icon = Plugins::ROCInput::Plugin->_pluginDataFor('icon');

	$log->debug("Begin Function for $url $icon");

	
#	Slim::Music::Info::setCurrentTitle( $url, 'PC ROCInput'  );
	return {
#		title    =>  'ROCInput', 
		bitrate  =>  "320k ",
		icon   => $icon,
		cover  => $icon,
		type   => 'ROCInput',
	};

}


1;

# Local Variables:
# tab-width:4
# indent-tabs-mode:t
# End:

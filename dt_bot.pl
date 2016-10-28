#!/usr/bin/env perl
# Main bot code

package DateTimePicker;

use common::sense;
use Mojolicious::Lite;

use DateTime;
use DateTime::Duration;
use DateTime::Format::ISO8601;
use Data::Dumper;

use FindBin;
use lib "$FindBin::Bin/perlgram/lib";

use Telegram::Wizard;
use Telegram::Polling qw(get_last_messages);

my $config = plugin JSONConfig => {file => 'config.json'};

my $w = Telegram::Wizard->new({
	screens_arrayref => $config->{screens},
	dyn_kbs_class => 'DynamicKeyboards',
	keyboard_type => 'regular',
	max_keys_per_row => 2,
	debug => 1
});

use WWW::Telegram::BotAPI;
BEGIN { $ENV{TELEGRAM_BOTAPI_DEBUG}=1 };
my $api = WWW::Telegram::BotAPI->new (
    token => $config->{token}
);

sub serialize {
	my $replies = shift;
	warn "All replies:".Dumper $replies;
	my $dt = DateTime->now();
	if ($replies->{day_select} eq 'tomorrow') {
		$dt->add_duration( DateTime::Duration->new( days => 1) );
	}
	my $h = (split(':',$replies->{morning_time_range_select}))[0];
	$dt->set_hour($h);
	$dt->set_minute(0);
	my $text = $dt->datetime();
	warn Dumper $text;

	return $text;
};

Mojo::IOLoop->recurring(1 => sub {
	my $hash = get_last_messages($api); # or just post '/' => sub
	while ( my ($chat_id, $update) = each(%$hash) ) {
		# $update as result of Post
		my $msg;
		my $res = $w->process($update);
		if (defined $res->{replies}) {
			warn Dumper $res;
			$msg = { chat_id => $chat_id, text => serialize($res->{replies}) };
		} else {
			$msg = $res;
		}
		$api->sendMessage($msg);
	}
		
});

app->start;

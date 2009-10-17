package SubscriberNotice;

use strict;
use warnings;
# use Data::Dumper;

sub update_notifcation {
    my ($cb, $obj, $orig) = @_;
    my $unsub = $cb->method eq 'MT::Notification::post_remove' ? 1 : 0;
    my $notify_addr = 'jay@endevver.com';
    my $email       = $obj->email;
    my %head        = (
        From    => MT->config->EmailAddressMain,
        To      => $notify_addr,
        Subject
            => MT->translate("Betawave investor [_1]: [_2]",
                        ($unsub ? 'unsubscription' : 'subscription'), $email)
    );
    my $charset = MT->config('MailEncoding')
        || MT->config('PublishCharset');
    $head{'Content-Type'} = qq(text/plain; charset="$charset");
    
    my $body = MT->translate(
        '[_1] has [_2] the Betawave Investor mailing list.',
            $obj->email, 
            ($unsub ? 'unsubscribed from' : 'subscribed to')
    );
    # print STDERR Dumper(\%head);
    # print STDERR $body."\n";
    use MT::Mail;
    my $rc = MT::Mail->send( \%head, $body )
        or return $cb->error( 'Error sending mail: '.MT::Mail->errstr );
}


1;
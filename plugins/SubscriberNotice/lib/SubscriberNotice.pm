package SubscriberNotice;

use strict;
use warnings;
# use Data::Dumper;

sub update_notifcation {
    my ($cb, $obj, $orig) = @_;
    my $plugin = MT->component(__PACKAGE__);
    my $notify_addr
        = $plugin->get_config_value('notification_email','blog:'.$obj->blog_id);
    return unless $notify_addr;

    my $unsub = $cb->method eq 'MT::Notification::post_remove' ? 1 : 0;
    my $email       = $obj->email;
    my $blogname  = MT->model('blog')->load($obj->blog_id)
                 || 'Blog ID # '.$obj->blog_id;
    
    my %head        = (
        From    => MT->config->EmailAddressMain,
        To      => $notify_addr,
        Subject => MT->translate("[_1] [_2]: [_3]",
                        $blogname, 
                        ($unsub ? 'unsubscription' : 'subscription'), 
                        $email)
    );
    my $charset = MT->config('MailEncoding')
        || MT->config('PublishCharset');
    $head{'Content-Type'} = qq(text/plain; charset="$charset");
    
    my $body = MT->translate(
        '[_1] has [_2] the notification list for [_3].',
            $obj->email, 
            ($unsub ? 'unsubscribed from' : 'subscribed to'),
            $blogname
    );
    # print STDERR Dumper(\%head);
    # print STDERR $body."\n";
    use MT::Mail;
    my $rc = MT::Mail->send( \%head, $body )
        or return $cb->error( 'Error sending mail: '.MT::Mail->errstr );
}


1;
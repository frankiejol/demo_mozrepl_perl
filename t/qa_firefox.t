# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl qa_firefox.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More;
use WWW::Mechanize::Firefox;
use Mojo::DOM;
BEGIN { use_ok('qa_firefox') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read

my $TAB_NAME ="Barcelona";
my $HOME = "http://localhost:3000";
my $SEL_DROPDOWN=".dropdown-toggle";
my $SEL_MULT ='.dropdown-menu > li:nth-child(3) > a:nth-child(1)';
my $SEL_LINK_MULT = 'div.container:nth-child(5) > div:nth-child(1) > div:nth-child(1) > p:nth-child(2) > a:nth-child(1)';
my $mech;
my $SLEEP = 1;

##############################################################

sub test_mult {
    my ($op1, $op2) = @_;

    my $exp_result = $op1 * $op2 ;

    diag("Testing $op1 * $op2");

    my $sel_result = '#result';

    $mech->submit_form( with_fields => {op1 => $op1 , op2 => $op2 });
    ok($mech->success);
    sleep 2 if $SLEEP;

    my $dom = Mojo::DOM->new($mech->content);

    my $result = $dom->find('#result')->text;
    ok($result eq $exp_result,"Expecting '$exp_result', got $result")
        or do {
            $mech->highlight_node($mech->selector('#result'));
            sleep 2 if $SLEEP;
        };
}

##################################################################

eval { $mech = WWW::Mechanize::Firefox->new(tab=> qr{$TAB_NAME}
    , create => 1
    , timeout => 5
    , activate => 1
    , autoclose => 0
    ) };
ok($mech, $@) or BAIL_OUT("Can't connect to mozrepl. Install Firefox"
    ." mozrepl plugin: https://addons.mozilla.org/en-us/firefox/addon/mozrepl/"
    .". Then enable it on Tools->mozrpl->start");

ok ($mech->get($HOME),"I can't connect to $HOME");
ok ($mech->click({selector => $SEL_DROPDOWN, synchronize => 0}));
sleep 2 if $SLEEP;
ok ($mech->click({selector => $SEL_MULT, synchronize => 0}));
sleep 2 if $SLEEP;
ok ($mech->click({selector => $SEL_LINK_MULT, synchronize => 1}));
sleep 2 if $SLEEP;

$mech->autodie(0);
ok ($mech->form_id('mult')) && do {
    test_mult(33,2);
    test_mult(1,0);
};
$mech = undef;
done_testing();

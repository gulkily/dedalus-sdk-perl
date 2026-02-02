use Test2::V0;

use Dedalus::Util::Params qw(deep_copy);
use Scalar::Util qw(refaddr);

sub assert_different_identities {
    my ($a, $b, $label) = @_;
    is($a, $b, "$label equality");
    ok(refaddr($a) != refaddr($b), "$label different identity");
}

my $obj1 = { foo => 'bar' };
my $obj2 = deep_copy($obj1);
assert_different_identities($obj1, $obj2, 'simple hash');

my $obj3 = { foo => { bar => 1 } };
my $obj4 = deep_copy($obj3);
assert_different_identities($obj3, $obj4, 'nested hash');
assert_different_identities($obj3->{foo}, $obj4->{foo}, 'nested hash child');

my $obj5 = { foo => { bar => [ { hello => 'world' } ] } };
my $obj6 = deep_copy($obj5);
assert_different_identities($obj5, $obj6, 'complex hash');
assert_different_identities($obj5->{foo}, $obj6->{foo}, 'complex hash child');
assert_different_identities($obj5->{foo}{bar}, $obj6->{foo}{bar}, 'complex hash array');
assert_different_identities($obj5->{foo}{bar}[0], $obj6->{foo}{bar}[0], 'complex hash array entry');

my $list1 = [ 'a', 'b', 'c' ];
my $list2 = deep_copy($list1);
assert_different_identities($list1, $list2, 'simple array');

my $list3 = [ 'a', [ 1, 2, 3 ] ];
my $list4 = deep_copy($list3);
assert_different_identities($list3, $list4, 'nested array');
assert_different_identities($list3->[1], $list4->[1], 'nested array child');

{
    package MyObject;
}

my $obj = bless {}, 'MyObject';
my $mixed = { foo => $obj };
my $mixed_copy = deep_copy($mixed);
assert_different_identities($mixed, $mixed_copy, 'custom object hash');
is($mixed_copy->{foo}, $obj, 'custom object preserved');

done_testing;

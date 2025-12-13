requires 'HTTP::Tiny';
requires 'Cpanel::JSON::XS';
requires 'Time::HiRes';
requires 'Scalar::Util';
requires 'Moo';
requires 'Types::Standard';
requires 'URI';
requires 'Try::Tiny';
requires 'Future';
requires 'AnyEvent';
requires 'Hash::Merge';
requires 'AnyEvent::HTTP';

on 'test' => sub {
    requires 'Test2::V0';
    requires 'Test::MockModule';
};

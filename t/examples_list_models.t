use Test2::V0;

my $file = 'examples/list_models.pl';
open my $fh, '<', $file or die $!;
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/models->list/, 'models script lists models');
ok(-x $file, 'models script executable');

done_testing;

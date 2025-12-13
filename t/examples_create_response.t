use Test2::V0;

my $file = 'examples/create_response.pl';
open my $fh, '<', $file or die $!;
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/responses->create/, 'response script hits responses API');
ok(-x $file, 'script executable');

done_testing;

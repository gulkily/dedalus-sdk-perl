use Test2::V0;

my $file = 'examples/async_create_embedding.pl';
open my $fh, '<', $file or die $!;
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/embeddings->create/, 'async embedding script hits embeddings API');
ok(-x $file, 'script executable');

done_testing;

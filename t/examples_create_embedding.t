use Test2::V0;

my $file = 'examples/create_embedding.pl';
open my $fh, '<', $file or die $!;
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/embeddings->create/, 'script calls embeddings API');
ok(-x $file, 'script is executable');

done_testing;

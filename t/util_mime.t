use Test2::V0;

use Dedalus::Util::MIME qw(guess_content_type);

is(guess_content_type('file.txt'), 'text/plain', 'txt extension');
is(guess_content_type('file.JSON'), 'application/json', 'case-insensitive extension');
is(guess_content_type('archive.tar'), 'application/x-tar', 'tar extension');
is(guess_content_type('audio.mp3'), 'audio/mpeg', 'mp3 extension');
is(guess_content_type('data.jsonl'), 'application/jsonl', 'jsonl extension');

ok(!defined guess_content_type('README'), 'no extension yields undef');
ok(!defined guess_content_type(undef), 'undef yields undef');

done_testing;

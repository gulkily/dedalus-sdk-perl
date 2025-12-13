use Test2::V0;
use Dedalus::Client;

{
    package TestHTTP;
    sub new { bless {}, shift }
    sub request {
        my ($self, $method, $path, %opts) = @_;
        if ($method eq 'GET' && $path eq '/v1/files') {
            return {
                status => 200,
                data   => {
                    object => 'list',
                    data   => [
                        {
                            id       => 'file-1',
                            object   => 'file',
                            filename => 'example.txt',
                        },
                    ],
                },
            };
        }
        if ($method eq 'GET' && $path eq '/v1/files/file-1') {
            return {
                status => 200,
                data   => {
                    id       => 'file-1',
                    object   => 'file',
                    filename => 'example.txt',
                },
            };
        }
        if ($method eq 'POST' && $path eq '/v1/files') {
            return {
                status => 200,
                data   => {
                    id       => 'file-2',
                    object   => 'file',
                    filename => 'upload.dat',
                },
            };
        }
        if ($method eq 'DELETE' && $path eq '/v1/files/file-1') {
            return {
                status => 200,
                data   => { id => 'file-1', deleted => 1 },
            };
        }
        if ($method eq 'GET' && $path eq '/v1/files/file-1/content') {
            return {
                status  => 200,
                headers => { 'content-type' => 'text/plain' },
                content => 'hello',
            };
        }
        die "Unhandled $method $path";
    }
}

my $client = Dedalus::Client->new(api_key => 'test', http => TestHTTP->new);

my $list = $client->files->list;
isa_ok($list, 'Dedalus::Types::ListFilesResponse');
isa_ok($list->data->[0], 'Dedalus::Types::FileObject');

my $single = $client->files->retrieve('file-1');
isa_ok($single, 'Dedalus::Types::FileObject');

my $uploaded = $client->files->upload(
    purpose => 'fine-tune',
    file    => \"hello",
);
isa_ok($uploaded, 'Dedalus::Types::FileObject');

my $deleted = $client->files->delete('file-1');
is($deleted->{deleted}, 1, 'delete returns status');

my $content = $client->files->content->retrieve('file-1');
is($content->{content}, 'hello', 'content retrieved');


done_testing;

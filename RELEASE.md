# Release process

The Perl SDK currently follows a manual release flow inspired by the Python project's `publish-pypi` job. Until we reproduce that automation, use the checklist below for each release:

1. **Confirm versions**
   - Update `lib/Dedalus/Version.pm` with the new semantic version.
   - Update `Changes` with a dated entry summarizing the release contents.
2. **Run quality gates**
   - `cpanm --installdeps --with-develop .`
   - `perl Makefile.PL && make test`
   - `script/lint.sh` (perlcritic + perltidy assertions)
3. **Tag and push**
   - `git commit -am "release: vX.Y.Z"`
   - `git tag vX.Y.Z`
   - `git push origin master --tags`
4. **Upload to CPAN**
   - `script/check-release-environment.sh`
   - `script/publish-cpan.sh`
5. **Post-release**
   - Open an issue to port any automation improvements from `dedalus-sdk-python` (e.g., release scripts, changelog generators).

Keep this file updated as CI/release automation evolves so contributors can follow a clear, synchronized process across SDKs.

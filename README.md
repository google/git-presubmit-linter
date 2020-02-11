# Git Presubmit Linter
Git Presubmit Linter is a project which contains a variety of QOL tools
to help developers maintain high-quality, consistent commits in
their projects.

The project contains a collection of shell scripts which can be
configured and run during a pre-submit task. The scripts will report
potential issues found in the commit.

This is not an officially supported Google product.

## Get Started
You can easily include this project into your CI system when
it runs:

```bash
git clone https://github.com/google/git-presubmit-linter
set -e
git log -1 --pretty=%B | ./git-presubmit-linter/rules/verb-tense.sh
```

## Using Rules
There are many rules that are available in the `rules/` directory.
Each can be accessed in a shell script by piping a string into the
script and providing additional parameters.

Each rule will either complete without issue or return an error
code. In a presubmit script, you can set errors to exit the
script early.

`set -e`

### Verb Tense
This rule is used to verify that a commit message is written in a
given verb tense, such as present tense or past tense.

`git log -1 --pretty=%B | ./rules/verb-tense.sh <tense>`

If the commit message starts with a `present` tense verb, like:

"**Adds new field**"

The script succeeds. However, if it is in a different tense like below,
the script will exit early with a non-zero status.

"**I have added a new field**"

This supports `present`, `imperative`, and `past` tense verbs.

### No Second Line
This rule verifies that the second line in a commit message is
empty, a common style in git.

`git log -1 --pretty=%B | ./rules/no-second-line.sh`

The script succeeds if the second line of the commit message is
empty, and it fails otherwise with a non-zero status.

### Line Length
This rule verifies that every line in a commit message or in the
code diff is under a certain line length. Style guides often
want code to be a maximum length per line, and git commit
messages are typically short as well.

It can be used by passing a string and including the maximum
length.

`git log -1 --pretty=%B | ./rules/line-length.sh <max>`
`git diff HEAD~1 --pretty=%B | ./rules/line-length.sh <max>`

**Note**: Git diffs will add in additional spacing to each line.
To verify the line length, you will need to add 2 to your maximum,
eg. A style guide with `80` characters max per line should use `82`.

#### First Line Length
Sometimes you may only want to check the length of the first line of
a message only, or may want a different maximum. This can be implemented
by piping your commit message into the rule using `head`.

`git log -1 --pretty=%B | head -n1 | ./rules/line-length.sh <max>`

### Contains String
This rule verifies that a certain string appears in a commit message.
Style guides may require developers to include a description of a test,
or an issue number.

It can be used by including the string you want to identify. This script
will pass if the string is exactly matched anywhere on any line of the
string.

`git log -1 --pretty=%B | ./rules/has-string.sh <string>`

To require contributors to mention tests, you can use:
`git log -1 --pretty=%B | ./rules/has-string.sh "Test:"`

#### Searching for edited files
If you want to check whether a certain file has been modified such as a
`CHANGELOG` file, you can instead run:

`git diff HEAD~1 --name-only | ./rules/has-string.sh "CHANGELOG"`

### Contains Pattern
Sometimes simple string matching is not enough. This rule will check
every line for the instance of a regular expression.

`git log -1 --pretty=%B | head -n1 | ./rules/has-pattern.sh <regex>`

If a style guide requires commit messages to start with a capital
letter, you can use:

`git log -1 --pretty=%B | head -n1 | ./rules/has-pattern.sh "^[A-Z]"`

### Does not contain string
Style guides may ban the use of certain notes that developers put into
code such as "TODO", "FIXME", "NOTE", etc. This rule will check each line
and exit with a non-zero status if a given string is found.

`git log -1 --pretty=%B | ./rules/block-string.sh <string>`

### Trailing Whitespace
This rule verifies that no changed line has any trailing whitespace.
Style guides may require this to be removed.

`git diff HEAD~1 --pretty=%B | ./rules/trailing-whitespace.sh`

## Tools
This repo also contains tools to be run during a presubmit task. These do
not verify the git metadata or other project details, but can produce
useful artifacts that may be part of the presubmit process.

### Changelog
This tool will generate a changelog between two points in your git history in
a Markdown format, with the summary of each commit prepended by an asterisk.

`./tools/changelog.sh` - Generates a changelog between HEAD and the most recent tag
`./tools/changelog.sh v1.0.0` - Generates a changelog between HEAD and the provided revision
`./tools/changelog.sh v1.0.0 v1.0.1` - Generates a changelog between the two revisions

### Generate sanitized archives
This tool will generate zipped archives of specific directories and the files inside.
Unlike a standard `zip` command, this tool will check each file against a blocklist,
denoted as the file `.archiveignore`, and prevent any unwanted files (credentials, build files, etc.)
from being added to your archive.

An `.archiveignore` is a simple list of files, separated by newlines. It checks against the filename, so
any part that matches will block it from being included in the archive.

```
file1.txt
file2.txt
zip
```

`./tools/archive.sh myfiles.zip "*"` - Puts all non-blocked files in an archive called `myfiles.zip`
`./tools/archive.sh myfiles.zip /src "*"` - Puts all non-blocked files from the `src` directory in an archive called `myfiles.zip`

### Verify package contents
This tool will take in a list of files, which can come from an archive file, and check each file
against a list of regular expressions. If an packaged file does not match any of the regular
expressions, the tool will report the file and fail.

`tar -tf myfiles.tar.gz | ./tools/filelist.sh ./listoffiles.txt`

The `listoffiles.txt` can contain a series of regular expressions. Be sure to escape backslashes.

```
file\\d\\.txt
```

For some CI systems, you may need to set a custom IFS (Internal Field Separator). That can be
a second parameter. In the example below, the IFS will be manually set to a single space. By
default, this is typically a newline character (\n).

`tar -tf myfiles.tar.gz | ./tools/filelist.sh ./listoffiles.txt " "`

### SPDX Licenses
Code licenses can be identified using the SPDX license list in a standardized way.
(https://spdx.org/licenses/)

To make it easy for developers to validate individual licenses, a tool has been created that
will check the input against the current list of licenses.

`echo "MIT" | ./tools/spdx.sh`

This will return 0 or 1 depending if the license is valid or invalid, respectively.

A second tool exists which can validate a list of dependencies against an approved list of licenses.
This tool pulls licensing information from https://libraries.io, and requires an API key to be obtained
first.

`cat requirements.txt | sed -r 's/([A-Za-z-]*).*/\1/g' | ./tools/spdx-dependencies.sh pypi approved-licenses.txt <libraries.io api key>`

The list of approved licenses, `approved-licenses.txt`, is a text file with each approved license on a new line in the spdx format.

### Filepath exists
This rule finds all filenames in provided files, such as documentation,
and verifies that the file exists either in that directory or in general.

If it is a URL, this script will check that the URL returns a `200` status code. If you also
want to allow redirects to pass, use the flag `--allow-redirects`.

`cat *.md | ./rules/path-exists.sh`

`cat *.md | ./rules/path-exists.sh --allow-redirects`

## License
See `LICENSE`.
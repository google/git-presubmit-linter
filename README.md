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

This supports `present` and `past` tense verbs.

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

## License
See `LICENSE`.
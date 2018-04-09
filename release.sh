#!/bin/bash
# Grabs the latest release from pypi and creates an updated formula for the
# new release, before pushing it to git.

echo "=> Installing okta_aws to a virtualenv"
virtualenv homebrew
source homebrew/bin/activate
pip install okta_aws homebrew-pypi-poet

echo "=> Generating formula"
poet -f okta_aws > Formula/okta_aws.rb

echo "=> Removing virtualenv"
deactivate
rm -rf homebrew

echo "=> Patching generated formula"
patch --ed Formula/okta_aws.rb <<EOF
47c
    system "#{bin}/okta_aws --help"
.
9a
  # okta_aws dependes on the aws cli. If you install it using something other
  # than homebrew, then pass --without-awscli when installing okta_aws
  option "without-awscli", "Don't install the AWS cli tools with homebrew"
  depends_on "awscli" => :recommended
.
8a
  head "https://github.com/chef/okta_aws.git"

.
4c
  desc "Okta AWS API tool"
.
EOF

echo "=> Committing changes to git"
git add Formula/okta_aws.rb
git commit -m "Update to new version of okta_aws"
git --no-pager show HEAD

echo "About to push changes to git. Press Enter to continue, or ^C to cancel"
read -r

echo "=> Pushing changes to git"
git push origin master

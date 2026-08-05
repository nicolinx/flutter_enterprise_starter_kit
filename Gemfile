source "https://rubygems.org"

gem "fastlane", "~> 2.237"
gem "fastlane-plugin-firebase_app_distribution"

# Locally, fastlane is installed via Homebrew with its own isolated Ruby/gem
# environment (see fastlane --version output), so this Gemfile is mainly for
# CI: release.yml uses ruby/setup-ruby + `bundle exec fastlane` to get a
# reproducible fastlane version on a fresh Ubuntu runner, independent of any
# machine's system Ruby.
#
# Gemfile.lock is committed (generated with Homebrew's Ruby, not this
# machine's ancient system Ruby, which can't resolve modern gems) and
# includes the x86_64-linux platform explicitly (`bundle lock
# --add-platform x86_64-linux`), so GitHub's Ubuntu runners can install from
# it without re-resolving from scratch.

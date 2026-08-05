source "https://rubygems.org"

gem "fastlane", "~> 2.237"
gem "fastlane-plugin-firebase_app_distribution"

# Locally, fastlane is installed via Homebrew with its own isolated Ruby/gem
# environment (see fastlane --version output), so this Gemfile is mainly for
# CI: release.yml uses ruby/setup-ruby + `bundle exec fastlane` to get a
# reproducible fastlane version on a fresh Ubuntu runner, independent of any
# machine's system Ruby.

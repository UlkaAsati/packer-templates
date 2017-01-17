name 'travis_ci_ruby'
maintainer 'Travis CI GmbH'
maintainer_email 'contact+packer-templates@travis-ci.org'
license 'MIT'
description 'Installs/Configures travis_ci_ruby'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'
source_url 'https://github.com/travis-ci/packer-templates'
issues_url 'https://github.com/travis-ci/packer-templates/issues'

depends 'java'
depends 'rvm'
depends 'sweeper'
depends 'travis_build_environment'
depends 'travis_ci_standard'
depends 'travis_packer_templates'
depends 'travis_system_info'

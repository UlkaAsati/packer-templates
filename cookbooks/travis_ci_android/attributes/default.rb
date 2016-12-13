override['java']['alternate_versions'] = %w(
  openjdk6
  openjdk7
  oraclejdk8
)

override['travis_packer_templates']['job_board']['stack'] = 'android'
override['travis_packer_templates']['job_board']['features'] = %w(
  android-sdk
  basic
  chromium
  firefox
  google-chrome
  jdk
  memcached
  mongodb
  mysql
  phantomjs
  postgresql
  rabbitmq
  redis
  sphinxsearch
  sqlite
  xserver
)
override['travis_packer_templates']['job_board']['languages'] = %w(android)

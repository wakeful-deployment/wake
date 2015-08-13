function install_ruby {
  cd /opt/src
  apt-get -y install autoconf bison libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev
  mkdir /usr/local/ruby-$1
  curl -OL http://cache.ruby-lang.org/pub/ruby/ruby-${1}.tar.gz
  tar xfvz ruby-${1}.tar.gz
  cd ruby-$1
  ./configure --prefix=/usr/local/ruby-$1/ --disable-install-doc --with-openssl-dir=/opt/src/openssl-1.0.1m
  make install
  rm -rf /opt/src/ruby-${1}.tar.gz /opt/src/ruby-${1}
  cd /opt/bin
  ln -s /usr/local/ruby-1.9.3-p550/bin/{ruby,gem,rake,irb} .
}

install_ruby 1.9.3-p550

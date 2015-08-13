function install_openssl {
  mkdir -p /opt/src
  cd /opt/src
  curl -L https://s3-eu-west-1.amazonaws.com/wake/blobs/openssl-1.0.1m.tar.gz -O
  tar xfzv openssl-1.0.1m.tar.gz
  cd openssl-1.0.1m
  ./config shared
  make
  rm /opt/src/openssl-1.0.1m.tar.gz
}

. /opt/assets/scripts/build_essentials.sh
install_openssl

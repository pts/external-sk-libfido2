#! /bin/sh --
# by pts@fazekas.hu at Wed Jul  1 10:33:24 CEST 2020
#
# Tested and it works on Linux with libfido2 1.3.0, 1.3.1 and 1.4.0. It
# doesn't work with libfido2 1.2.x or earlier.
#
# To download and build libfido2 on Linux:
#
#   $ sudo apt-get install libcbor-dev libudev-dev libssl-dev build-essential cmake  # Debian and Ubuntu.
#   $ wget https://developers.yubico.com/libfido2/Releases/libfido2-1.4.0.tar.gz
#   $ tar xzvf libfido2-1.4.0.tar.gz
#   $ (cd libfido2-1.4.0 && cmake . && make)
#
# To build libsk-libfido2.so:
#
#   $ git clone --depth 1 https://github.com/pts/external-sk-libfido2
#   $ (export LIBFIDO2_SRCDIR="$PWD/libfido2-1.4.0" && cd external-sk-libfido2 && ./compile.sh)
#
# To use (on the client, connecting to MYSERVER):
#
#   $ ssh-keygen -t ecdsa-sk -f ~/.ssh/id_mykey_sk -C id_mykey_sk -w "$PWD/libsk-libfido2.so"
#   $ cat >>~/.ssh/authorized_keys <~/.ssh/id_mykey_sk.pub
#   $ ssh MYSERVER "cat >>.ssh/authorized_keys" <~/.ssh/id_mykey_sk.pub
#   $ ssh -v -i ~/.ssh/id_mykey_sk -o IdentitiesOnly=yes -o SecurityKeyProvider=$PWD/libsk-libfido2.so MYSERVER"
#   (Upon successful connection, please double check that id_mykey_sk was used.)
#

set -ex
test -f sk-libfido2.c
test -f sk-api.h
if test "$LIBFIDO2_SRCDIR"; then
  unset F FF
  for F in "$LIBFIDO2_SRCDIR"/src/libfido2.so*; do FF="$F"; done
  test -f "$FF"
  LIBFIDO2_INCLUDEARGS="-I/$LIBFIDO2_SRCDIR/src"
  LIBFIDO2_ARGS="-Wl,-rpath,$LIBFIDO2_SRCDIR/src $FF"
else
  LIBFIDO2_INCLUDEARGS=''
  LIBFIDO2_ARGS='-lfido2'
fi
WARNING_ARGS='-Wall -Wextra -Werror -Wshadow -Wwrite-strings -Wmissing-prototypes -Wbad-function-cast -Wno-pointer-sign -Wno-unused-parameter -Wno-unused-result -Wcast-qual'
if test "$LIBFIDO2_INCLUDEARGS"; then
  test -f "${LIBFIDO2_INCLUDEARGS#-I}/fido.h"
fi
${CC:-gcc} -s -O2 \
    -D_GNU_SOURCE -DENABLE_SK_INTERNAL -DSK_STANDALONE -DWITH_OPENSSL \
    -I. $LIBFIDO2_INCLUDEARGS -fPIC $WARNING_ARGS \
    sk-libfido2.c -o libsk-libfido2.so -shared $LIBFIDO2_ARGS #-lcrypto -lcbor -lcrypto -ludev 
: "$0" OK.
set +ex
echo ""
echo "You need OpenSSH 8.2p1 or later on both the client and server."
echo "Example env (optional): SSH_SK_PROVIDER=\"$PWD/libsk-libfido2.so\""
echo "Example command: ssh-keygen -t ecdsa-sk -f ~/.ssh/id_mykey_sk -C id_mykey_sk -w \"$PWD/libsk-libfido2.so\""
echo "Example command: cat >>~/.ssh/authorized_keys <~/.ssh/id_mykey_sk.pub"
echo "Example command: ssh MYSERVER \"cat >>.ssh/authorized_keys\" <~/.ssh/id_mykey_sk.pub"
echo "Example command: ssh -v -i ~/.ssh/id_mykey_sk -o IdentitiesOnly=yes -o SecurityKeyProvider=$PWD/libsk-libfido2.so MYSERVER"
echo "(Upon successful connection, please double check that id_mykey_sk was used.)"

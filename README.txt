external-sk-libfido2: external U2F (FIDO) authenticator for OpenSSH
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
external-sk-libfido2 implements an external U2F (FIDO) authenticator
provider for OpenSSH >=8.2 client. It is useful if the OpenSSH client was
built without `configure --with-security-key-builtin'. You need
external-sk-libfido2 if SSH authentication fails locally with `internal
security key support not enabled'.

Compatibility:

* OpenSSH 8.2p1 or later is needed, tested and works with OpenSH 8.2p1.
* Tested and works on Linux desktop with udev, more specifically Debian 10
  Buster.
* Tested and works with libfido2 1.3.0, 1.3.1, 1.4.0.

Client-side hardware dependencies:

* USB token with U2F (FIDO) support. FIDO2 is optional. Any old YubiKey or
  similar will work.

* For the resident key feature only: USB token with FIDO2 support.

* To avoid confusion, only a single USB token should be connected when
  ssh-keygen is run. (When ssh is run, multiple USB tokens work, the user
  can touch the wrong one many times, and authentication succeeds after the
  user touches the right one.)

* ED25519 support in the token is optional. (`ssh-keygen -t ecdsa-sk ...'
  uses the NIST P-256 curve, which works with all U2F tokens.)

Client-side software dependencies:

* For communicating with the token over USB, OpenBSD or (Linux with udev).

* OpenSSH 8.2p1 or later.

* OpenSSH client (ssh) compiled with or without `configure
  --with-security-key-builtin'. It it's compiled with it, then
  external-sk-libfido2 is not needed, and the `-w ...' and `-o
  SecurityKeyProvider=...' flags below can be dropped.

* libfido2 >=1.3.0. Install instructions are provided below. It doesn't work
  with libfido2 1.2.x or earlier. Tested and works with libfido2 1.3.0,
  1.3.1 and 1.4.0.

Server-side software dependencies:

* OpenSSH 8.2p1 or later.

* Default OpenSSH server (sshd) settings (without PubkeyAcceptedKeyTypes),
  or PubkeyAcceptedKeyTypes in /etc/ssh/sshd_config containing
  sk-ecdsa-sha2-nistp256@openssh.com and (optionally, for ed25519-sk keys)
  sk-ssh-ed25519@openssh.com .

To download and build libfido2 on Linux:

  $ sudo apt-get install libcbor-dev libudev-dev libssl-dev build-essential cmake  # Debian and Ubuntu.
  $ wget https://developers.yubico.com/libfido2/Releases/libfido2-1.4.0.tar.gz
  $ tar xzvf libfido2-1.4.0.tar.gz
  $ (cd libfido2-1.4.0 && cmake . && make)

To build libsk-libfido2.so:

  $ git clone --depth 1 https://github.com/pts/external-sk-libfido2
  $ (export LIBFIDO2_SRCDIR="$PWD/libfido2-1.4.0" && cd external-sk-libfido2 && ./compile.sh)

To use (on the client, connecting to MYSERVER):

  $ ssh-keygen -t ecdsa-sk -f ~/.ssh/id_mykey_sk -C id_mykey_sk -w "$PWD/libsk-libfido2.so"
  $ cat >>~/.ssh/authorized_keys <~/.ssh/id_mykey_sk.pub
  $ ssh MYSERVER "cat >>.ssh/authorized_keys" <~/.ssh/id_mykey_sk.pub
  $ ssh -v -i ~/.ssh/id_mykey_sk -o IdentitiesOnly=yes -o SecurityKeyProvider=$PWD/libsk-libfido2.so MYSERVER"
  (Upon successful connection, please check on the console output that
  id_mykey_sk was used.)

FYI instead of the `-w ...' and `-o SecurityKeyProvider=...' flags, it
possible to specify the .so pathname like this:

  $ export SSH_SK_PROVIDER="$PWD/libsk-libfido2.so"

Links:

* tutorial: https://www.stavros.io/posts/u2f-fido2-with-ssh/
* tutorial: https://duo.com/labs/tech-notes/u2f-key-support-in-openssh
* OpenSSH announcement with details: http://www.openssh.com/txt/release-8.2
* Hacker News discussion: https://news.ycombinator.com/item?id=23689499

__END__

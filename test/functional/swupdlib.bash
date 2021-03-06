# NOTE: source this file from a *.bats file

# The location of the swupd_* binaries
export SRCDIR="$BATS_TEST_DIRNAME/../../../../"

export SWUPD="$SRCDIR/swupd"

export DIR="$BATS_TEST_DIRNAME"

export STATE_DIR="$BATS_TEST_DIRNAME/state"

export SWUPD_OPTS="-S $STATE_DIR -p $DIR/target-dir -F staging -u file://$DIR/web-dir"

clean_test_dir() {
  sudo rm -rf "$STATE_DIR"
}

clean_tars() {
  local ver=$1
  local path=
  if [ -n $2 ]; then
    path="$DIR/web-dir/$ver/$2"
  else
    path="$DIR/web-dir/$ver"
  fi
  pushd $path
  sudo rm *.tar
  popd
}

chown_root() {
  sudo chown root:root "$1"
}

revert_chown_root() {
  sudo chown $(ls -l "$DIR/test.bats" | awk '{ print $3 ":" $4 }') "$1"
}

create_manifest_tar() {
  local ver=$1
  local name=$2
  chown_root "$DIR/web-dir/$ver/Manifest.$name"
  sudo tar -C "$DIR/web-dir/$ver" -cf "$DIR/web-dir/$ver/Manifest.$name.tar" Manifest.$name Manifest.$name.signed
}

create_fullfile_tar() {
  local ver=$1
  local hash="$2"
  local extra_arg=
  local dir="$DIR/web-dir/$ver/files"
  local path="$dir/$hash"
  chown_root "$path"
  if [ -d "$path" ]; then
    extra_arg="--exclude=$hash/*"
  else
    extra_arg=""
  fi
  sudo tar -C "$dir" -cf "$path.tar" $extra_arg $hash
}

# TODO several tests create packs, so it would be nice to encapsulate those steps
# create_pack_tar() {
#   local from_ver=$1
#   local to_ver=$2
#   local bundle=$3
#   local contents="${@:4}"
#   return
# }

ignore_sigverify_error() {
  local index="$1"
  if [[ "${lines[$index]}" =~ ^WARNING!!!\ FAILED\ TO\ VERIFY\ SIGNATURE\ OF\ Manifest.MoM ]]; then
    # remove element from array
    unset lines[$index]
    # reassign indices
    lines=("${lines[@]}")
  fi
}

# vi: ft=sh ts=8 sw=2 sts=2 et tw=80

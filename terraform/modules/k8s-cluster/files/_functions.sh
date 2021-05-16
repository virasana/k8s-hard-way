function copy_to_remote {
  local instance=$1
  local source_path=$2
  local remote_dest_path=$3

  local remote_tmp_path="/home/fedora${source_path}"
  local remote_tmp_dir="$(dirname "${remote_tmp_path}")"

  echo "==> copying from ${source_path} to ${instance}:${remote_dest_path}"

  echo "==> instance: ${instance}"
  echo "==> source_path: ${source_path}"
  echo "==> dest_path: ${remote_dest_path}"

  ssh "${instance}" mkdir -p "${remote_tmp_dir}"
  ssh "${instance}" sudo chown fedora "${remote_tmp_dir}"
  scp "${source_path}" "${instance}":"${remote_tmp_path}"
  ssh "${instance}" sudo mv "${remote_tmp_path}" "${remote_dest_path}"

  echo "==> done!"
}

#! /bin/bash
set -x

cleanup() {
  rm -fv terraform terraform_0.11.7_linux_amd64.zip
}
trap "cleanup" EXIT
ctr=$(buildah from scratch) || (echo "Must be root to execute buildah" && exit 1)
mnt=`buildah mount $ctr` || (echo "Must be root to execute buildah" && exit 1)
wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip
unzip terraform_0.11.8_linux_amd64.zip
cp terraform $mnt || exit 1
mkdir $mnt/tmp || exit 1
buildah unmount $ctr
buildah config --entrypoint='["/terraform"]' "${ctr}"
buildah commit $ctr terraform-scratch:v0.11.8
set +x
echo "run 'podman run -v "$PWD":"$PWD":ro terraform-scratch:v0.11.8 fmt -list -check -write=false' to terraform fmt source"
echo "to cleanup run 'podman stop [containerid from podman run]; podman rm [containerid from podman run]'"

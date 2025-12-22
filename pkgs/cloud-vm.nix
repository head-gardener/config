{
  lib,
  writeShellScript,
  runCommand,
  writeText,
  fetchurl,
  cloud-utils,
  qemu,
  imgUrl ? lib.warn (
    "<cloud-vm> You are using current cloud ubuntu image"
    + ", please override with a specific date: cloud-vm.override "
    + "{ imgUrl = \"https://cloud-images.ubuntu.com/noble/20251213/noble-server-cloudimg-amd64.img\"; }"
  ) "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img",
  imgHash ? lib.warn (
    "<cloud-vm> Please provide hash value from "
    + "the error below as imgHash: cloud-vm.override { imgHash = \"<hash>\"; }"
  ) lib.fakeHash,
  userData ? ''
    #cloud-config

    password: password
    chpasswd:
      users:
        - {name: root, password: password, type: text}
      expire: false
  '',
  metaData ? "",
}:
let
  img = fetchurl {
    url = imgUrl;
    hash = imgHash;
  };
  seed =
    let
      userDataFile = writeText "cloud-vm-user-data.yml" userData;
      metaDataFile = writeText "cloud-vm-meta-data.yml" metaData;
    in
    runCommand "coud-vm-seed.img" { } ''
      ${cloud-utils}/bin/cloud-localds "$out" ${userDataFile} ${metaDataFile}
    '';
in
writeShellScript "run-cloud-vm" ''
  exec ${qemu}/bin/qemu-system-x86_64 \
    -name "cloud-vm" \
    -cpu host -machine type=q35,accel=kvm -m 2048 \
    -nographic \
    -snapshot \
    -drive if=virtio,format=qcow2,file=${img} \
    -drive if=virtio,format=raw,file=${seed} \
    $ARGV
''

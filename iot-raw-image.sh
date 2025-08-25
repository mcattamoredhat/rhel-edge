#!/bin/bash
set -euox pipefail

# Provision the software under test.
./iot-setup.sh

# Get OS data.
source /etc/os-release
ARCH=$(uname -m)

# Set up variables.
TEST_UUID=$(uuidgen)
IMAGE_KEY="iot-raw-${TEST_UUID}"
BIOS_GUEST_ADDRESS=192.168.100.50
UEFI_GUEST_ADDRESS=192.168.100.51
PROD_REPO_URL=http://192.168.100.1/repo
PROD_REPO=/var/www/html/repo
STAGE_REPO_ADDRESS=192.168.200.1
STAGE_REPO_URL="http://${STAGE_REPO_ADDRESS}:8080/repo/"
REF_PREFIX="rhel-edge"
CONTAINER_TYPE=edge-container
CONTAINER_FILENAME=container.tar
RAW_TYPE=edge-raw-image
RAW_FILENAME=image.raw.xz
# Workaround BZ#2108646
BOOT_ARGS="uefi,firmware.feature0.name=secure-boot,firmware.feature0.enabled=no"
# RHEL and CS default ostree os_name is redhat
# But Fedora uses fedora-iot
ANSIBLE_OS_NAME="redhat"

# SSH setup.
SSH_OPTIONS=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5)
SSH_KEY=key/ostree_key
SSH_KEY_PUB=$(cat "${SSH_KEY}".pub)
EDGE_USER_PASSWORD=foobar
# Mount /sysroot as RO by new ostree-libs-2022.6-3.el9.x86_64
# It's RHEL 9.2 and above, CS9, Fedora 37 and above ONLY
SYSROOT_RO="false"

# COMPOSE variable example value: Fedora-IoT-44-20250825.0
# TO DO: Implement a way to handle the compose_id variable when compose is the latest image
COMPOSE_URL="https://kojipkgs.fedoraproject.org/compose/iot/${COMPOSE}/compose/IoT/${ARCH}/images/"
COMPOSE_ID=$(echo ${COMPOSE} | cut -d- -f4)

case "${ID}-${VERSION_ID}" in
    "fedora-42")
        CONTAINER_TYPE=fedora-iot-container
        RAW_TYPE=iot-raw-image
        OSTREE_REF="fedora/42/${ARCH}/iot"
        OS_VARIANT="fedora-unknown"
        ADD_SSSD="false"
        ANSIBLE_OS_NAME="fedora-iot"
        USER_IN_RAW="true"
        REF_PREFIX="fedora-iot"
        SYSROOT_RO="true"
        RAW_FILENAME="Fedora-IoT-raw-42-${COMPOSE_ID}.${ARCH}.raw.xz"
        ;;
    "fedora-43")
        CONTAINER_TYPE=fedora-iot-container
        RAW_TYPE=iot-raw-image
        OSTREE_REF="fedora/43/${ARCH}/iot"
        OS_VARIANT="fedora-unknown"
        ADD_SSSD="false"
        ANSIBLE_OS_NAME="fedora-iot"
        USER_IN_RAW="true"
        REF_PREFIX="fedora-iot"
        SYSROOT_RO="true"
        RAW_FILENAME="Fedora-IoT-raw-43-${COMPOSE_ID}.${ARCH}.raw.xz"
        ;;
    "fedora-44")
        CONTAINER_TYPE=fedora-iot-container
        RAW_TYPE=iot-raw-image
        OSTREE_REF="fedora/44/${ARCH}/iot"
        OS_VARIANT="fedora-rawhide"
        ADD_SSSD="false"
        ANSIBLE_OS_NAME="fedora-iot"
        USER_IN_RAW="true"
        REF_PREFIX="fedora-iot"
        SYSROOT_RO="true"
        RAW_FILENAME="Fedora-IoT-raw-44-${COMPOSE_ID}.${ARCH}.raw.xz"
        ;;
    *)
        echo "unsupported distro: ${ID}-${VERSION_ID}"
        exit 1;;
esac

# Colorful output.
function greenprint {
    echo -e "\033[1;32m${1}\033[0m"
}

# Wait for the ssh server up to be.
wait_for_ssh_up () {
    SSH_STATUS=$(sudo ssh "${SSH_OPTIONS[@]}" -i "${SSH_KEY}" admin@"${1}" '/bin/bash -c "echo -n READY"')
    if [[ $SSH_STATUS == READY ]]; then
        echo 1
    else
        echo 0
    fi
}

# Clean up our mess.
clean_up () {
    greenprint "🧼 Cleaning up"

    # Clear vm
    if [[ $(sudo virsh domstate "${IMAGE_KEY}-uefi") == "running" ]]; then
        sudo virsh destroy "${IMAGE_KEY}-uefi"
    fi
    sudo virsh undefine "${IMAGE_KEY}-uefi" --nvram
    # Remove qcow2 file.
    sudo virsh vol-delete --pool images "${IMAGE_KEY}-uefi.qcow2"

    # Remove any status containers if exist
    sudo podman ps -a -q --format "{{.ID}}" | sudo xargs --no-run-if-empty podman rm -f
    # Remove all images
    sudo podman rmi -f -a

    # Remove prod repo
    sudo rm -rf "$PROD_REPO"

    # Remomve tmp dir.
    sudo rm -rf "$TEMPDIR"

    # Stop prod repo http service
    sudo systemctl disable --now httpd
}

# Test result checking
check_result () {
    greenprint "🎏 Checking for test result"
    if [[ $RESULTS == 1 ]]; then
        greenprint "💚 Success"
    else
        greenprint "❌ Failed"
        clean_up
        exit 1
    fi
}

setup_ignition () {
    sudo tee /var/www/html/fiot.ign > /dev/null << EOF
{
  "ignition": {
    "version": "3.4.0"
  },
  "passwd": {
    "users": [
      {
        "groups": [
          "wheel"
        ],
        "homeDir": "/home/admin",
        "name": "admin",
        "passwordHash": "\$6\$GRmb7S0p8vsYmXzH\$o0E020S.9JQGaHkszoog4ha4AQVs3sk8q0DvLjSMxoxHBKnB2FBXGQ/OkwZQfW/76ktHd0NX5nls2LPxPuUdl.",
        "shell": "/bin/bash"
      }
    ]
  }
}
EOF
}

function download_image {
    IMAGE_URL="${COMPOSE_URL}/${RAW_FILENAME}"
    sudo wget --progress=bar "$IMAGE_URL"
    if [ $? -eq 0 ] && [ -f "$RAW_FILENAME" ]; then
        echo "Download completed successfully: ${RAW_FILENAME}"
    else
        echo "Download failed. Please check the URL and try again."
        exit 1
    fi
}

# Download the raw image
download_image

# Setup ignition
setup_ignition

# Uncompress the raw image
greenprint "Extracting and converting the raw image to a qcow2 file"
sudo xz -d "${RAW_FILENAME}"
# Uncompressed image name
UNC_IMAGE_NAME="Fedora-IoT-raw-${VERSION_ID}-${COMPOSE_ID}.${ARCH}.raw"
sudo qemu-img convert -f raw "${UNC_IMAGE_NAME}" -O qcow2 "${IMAGE_KEY}.qcow2"
# Remove raw file
sudo rm -f "${UNC_IMAGE_NAME}"

# Prepare qcow2 file for tests
sudo cp "${IMAGE_KEY}.qcow2" /var/lib/libvirt/images/"${IMAGE_KEY}-uefi.qcow2"
LIBVIRT_IMAGE_PATH_UEFI=/var/lib/libvirt/images/"${IMAGE_KEY}-uefi.qcow2"

# Ensure SELinux is happy with our new images.
greenprint "👿 Running restorecon on image directory"
sudo restorecon -Rv /var/lib/libvirt/images/

# Remove qcow2 file
sudo rm -f "${IMAGE_KEY}.qcow2"

##################################################################
##
## Install and test edge vm with edge-raw-image (UEFI)
##
##################################################################
greenprint "💿 Installing raw image on UEFI VM"
sudo virt-install  --name="${IMAGE_KEY}-uefi"\
                   --disk path="${LIBVIRT_IMAGE_PATH_UEFI}",format=qcow2 \
                   --ram 4096 \
                   --vcpus 2 \
                   --network network=integration,mac=34:49:22:B0:83:31 \
                   --os-type linux \
                   --os-variant ${OS_VARIANT} \
                   --boot ${BOOT_ARGS} \
                   --nographics \
                   --noautoconsole \
                   --wait=-1 \
                   --import \
                   --noreboot

# Start VM.
greenprint "💻 Start UEFI VM"
sudo virsh start "${IMAGE_KEY}-uefi"

# Check for ssh ready to go.
greenprint "🛃 Checking for SSH is ready to go"
for _ in $(seq 0 30); do
    RESULTS="$(wait_for_ssh_up $UEFI_GUEST_ADDRESS)"
    if [[ $RESULTS == 1 ]]; then
        echo "SSH is ready now! 🥳"
        break
    fi
    sleep 10
done

# Reboot one more time to make /sysroot as RO by new ostree-libs-2022.6-3.el9.x86_64
sudo ssh "${SSH_OPTIONS[@]}" -i "${SSH_KEY}" "admin@${UEFI_GUEST_ADDRESS}" 'nohup sudo systemctl reboot &>/dev/null & exit'
# Sleep 10 seconds here to make sure vm restarted already
sleep 10
for _ in $(seq 0 30); do
    RESULTS="$(wait_for_ssh_up $UEFI_GUEST_ADDRESS)"
    if [[ $RESULTS == 1 ]]; then
        echo "SSH is ready now! 🥳"
        break
    fi
    sleep 10
done

# Check image installation result
check_result

# Add instance IP address into /etc/ansible/hosts
tee "${TEMPDIR}"/inventory > /dev/null << EOF
[ostree_guest]
${UEFI_GUEST_ADDRESS}

[ostree_guest:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_user=admin
ansible_private_key_file=${SSH_KEY}
ansible_ssh_common_args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
ansible_become=yes 
ansible_become_method=sudo
ansible_become_pass=${EDGE_USER_PASSWORD}
EOF

# Test IoT/Edge OS
podman run --network=host --annotation run.oci.keep_original_groups=1 -v "$(pwd)":/work:z -v "${TEMPDIR}":/tmp:z --rm quay.io/rhel-edge/ansible-runner:latest ansible-playbook -v -i /tmp/inventory -e os_name="${ANSIBLE_OS_NAME}" -e ostree_commit="${INSTALL_HASH}" -e ostree_ref="${REF_PREFIX}:${OSTREE_REF}" -e sysroot_ro="$SYSROOT_RO" check-ostree.yaml || RESULTS=0
check_result

##################################################################
##
## Upgrade and test edge vm with edge-raw-image (UEFI)
##
##################################################################

# Write a blueprint for ostree image.
# NB: no ssh key in the upgrade commit because there is no home dir
tee "$BLUEPRINT_FILE" > /dev/null << EOF
name = "upgrade"
description = "An upgrade rhel-edge container image"
version = "0.0.2"
modules = []
groups = []

[[packages]]
name = "python3"
version = "*"

[[packages]]
name = "wget"
version = "*"

[[customizations.user]]
name = "admin"
description = "Administrator account"
password = "\$6\$GRmb7S0p8vsYmXzH\$o0E020S.9JQGaHkszoog4ha4AQVs3sk8q0DvLjSMxoxHBKnB2FBXGQ/OkwZQfW/76ktHd0NX5nls2LPxPuUdl."
home = "/home/admin/"
groups = ["wheel"]
EOF

# Fedora does not have kernel-rt
if [[ "$ID" != "fedora" ]]; then
    tee -a "$BLUEPRINT_FILE" >> /dev/null << EOF
[customizations.kernel]
name = "kernel-rt"
EOF
fi

# For BZ#2088459, RHEL 8.6 and 9.0 will not have new release which fix this issue
# RHEL 8.6 and 9.0 will not include sssd package in blueprint
if [[ "${ADD_SSSD}" == "true" ]]; then
    tee -a "$BLUEPRINT_FILE" > /dev/null << EOF
[[packages]]
name = "sssd"
version = "*"
EOF
fi

greenprint "📄 upgrade blueprint"
cat "$BLUEPRINT_FILE"

# Prepare the blueprint for the compose.
greenprint "📋 Preparing upgrade blueprint"
sudo composer-cli blueprints push "$BLUEPRINT_FILE"
sudo composer-cli blueprints depsolve upgrade

# Build upgrade image.
build_image upgrade  "${CONTAINER_TYPE}" "$PROD_REPO_URL"

# Download the image
greenprint "📥 Downloading the upgrade image"
sudo composer-cli compose image "${COMPOSE_ID}" > /dev/null

# Clear stage repo running env
greenprint "🧹 Clearing stage repo running env"
# Remove any status containers if exist
sudo podman ps -a -q --format "{{.ID}}" | sudo xargs --no-run-if-empty podman rm -f
# Remove all images
sudo podman rmi -f -a

# Deal with stage repo container
greenprint "🗜 Extracting image"
RAW_FILENAME="${COMPOSE_ID}-${CONTAINER_FILENAME}"
sudo podman pull "oci-archive:${RAW_FILENAME}"
sudo podman images
# Clear image file
sudo rm -f "$RAW_FILENAME"

# Run edge stage repo
greenprint "🛰 Running edge stage repo"
# Get image id to run image
EDGE_IMAGE_ID=$(sudo podman images --filter "dangling=true" --format "{{.ID}}")
sudo podman run -d --name rhel-edge --network edge --ip "$STAGE_REPO_ADDRESS" "$EDGE_IMAGE_ID"
# Wait for container to be running
until [ "$(sudo podman inspect -f '{{.State.Running}}' rhel-edge)" == "true" ]; do
    sleep 1;
done;

# Pull upgrade to prod mirror
greenprint "⛓ Pull upgrade to prod mirror"
sudo ostree --repo="$PROD_REPO" pull --mirror edge-stage "$OSTREE_REF"
sudo ostree --repo="$PROD_REPO" static-delta generate "$OSTREE_REF"
sudo ostree --repo="$PROD_REPO" summary -u

# Get ostree commit value.
greenprint "🕹 Get ostree upgrade commit value"
UPGRADE_HASH=$(curl "${PROD_REPO_URL}/refs/heads/${OSTREE_REF}")

# Clean compose and blueprints.
greenprint "🧽 Clean up upgrade blueprint and compose"
sudo composer-cli compose delete "${COMPOSE_ID}" > /dev/null
sudo composer-cli blueprints delete upgrade > /dev/null

if [[ "$ID" == "fedora" ]]; then
    # The Fedora IoT Raw image sets the fedora-iot remote URL to https://ostree.fedoraproject.org/iot
    # Replacing with our own local repo
    greenprint "Replacing default remote"
    sudo ssh "${SSH_OPTIONS[@]}" -i "${SSH_KEY}" admin@${UEFI_GUEST_ADDRESS} "echo ${EDGE_USER_PASSWORD} |sudo -S ostree remote delete ${ANSIBLE_OS_NAME}"
    sudo ssh "${SSH_OPTIONS[@]}" -i "${SSH_KEY}" admin@${UEFI_GUEST_ADDRESS} "echo ${EDGE_USER_PASSWORD} |sudo -S ostree remote add --no-gpg-verify ${ANSIBLE_OS_NAME} ${PROD_REPO_URL}"
fi

# Upgrade image/commit.
greenprint "🗳 Upgrade ostree image/commit"
sudo ssh "${SSH_OPTIONS[@]}" -i "${SSH_KEY}" admin@${UEFI_GUEST_ADDRESS} "echo ${EDGE_USER_PASSWORD} |sudo -S rpm-ostree upgrade"
sudo ssh "${SSH_OPTIONS[@]}" -i "${SSH_KEY}" admin@${UEFI_GUEST_ADDRESS} "echo ${EDGE_USER_PASSWORD} |nohup sudo -S systemctl reboot &>/dev/null & exit"

# Sleep 10 seconds here to make sure vm restarted already
sleep 10

# Check for ssh ready to go.
greenprint "🛃 Checking for SSH is ready to go"
for _ in $(seq 0 30); do
    RESULTS="$(wait_for_ssh_up $UEFI_GUEST_ADDRESS)"
    if [[ $RESULTS == 1 ]]; then
        echo "SSH is ready now! 🥳"
        break
    fi
    sleep 10
done

# Check ostree upgrade result
check_result

# Add instance IP address into /etc/ansible/hosts
tee "${TEMPDIR}"/inventory > /dev/null << EOF
[ostree_guest]
${UEFI_GUEST_ADDRESS}

[ostree_guest:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_user=admin
ansible_private_key_file=${SSH_KEY}
ansible_ssh_common_args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
ansible_become=yes 
ansible_become_method=sudo
ansible_become_pass=${EDGE_USER_PASSWORD}
EOF

# Test IoT/Edge OS
podman run --network=host --annotation run.oci.keep_original_groups=1 -v "$(pwd)":/work:z -v "${TEMPDIR}":/tmp:z --rm quay.io/rhel-edge/ansible-runner:latest ansible-playbook -v -i /tmp/inventory -e os_name="${ANSIBLE_OS_NAME}" -e ostree_commit="${UPGRADE_HASH}" -e ostree_ref="${REF_PREFIX}:${OSTREE_REF}" -e sysroot_ro="$SYSROOT_RO" check-ostree.yaml || RESULTS=0
check_result

# Final success clean up
clean_up

exit 0

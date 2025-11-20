# RHEL-Edge

RHEL-Edge help [documentation](HELP.md)

## RHEL-Edge Test Scope

RHEL for Edge test from QE is more like an integration test. The test flow aligns with the customer scenario. The whole test includes three parts:

1. RHEL for Edge image building with [osbuild-composer](https://github.com/osbuild/osbuild-composer.git)

    - Build RHEL 8 and RHEL 9 x86_64 images at OpenStack VM
    - Build CentOS Stream 8, CentOS Stream 9 and Fedora x86_64 images at Google Cloud VM
    - Build ARM images on bare metal ARM server or ARM VM at beaker

2. RHEL for Edge image installation

    - `edge-commit/iot-commit`: Setup HTTP server to serve as ostree repo, and HTTP boot to install with kickstart
    - `edge-container/iot-container`: Setup prod ostree repo, `edge-container/iot-container` as stage repo, and install with kickstart from prod ostree repo
    - `edge-installer/iot-installer`: Install from `edge-installer/iot-installer` ISO
    - `edge-raw-image/iot-raw-image`: Boot from raw image with KVM
    - `edge-simplified-installer`: Install from `edge-simplified-installer` ISO
    - `minimal-raw`: Boot from RPM based raw image with KVM
    - `edge-ami`: Image for AWS ec2 instance

3. RHEL for Edge system upgrade

    - Upgrade with the same OSTree ref
    - Rebase to a new OSTree ref
    - Upgrade from RHEL 8 to RHEL 9 or from CentOS Stream 8 to CentOS Stream 9

3. Checkings after installation/upgrade.

    - Check installed ostree commit
    - Check mount point
    - Check [`greenboot`](https://github.com/fedora-iot/greenboot.git) services
    - Run container with `podman` (root and non-root)
    - Check persistent journal log
    - Check FDO onboarding and status (simplified-installer only)
    - Check LVM PV and LV, and check growfs (raw-image and simplified-installer only)
    - Check auto rollback with [`greenboot`](https://github.com/fedora-iot/greenboot.git) when failure is detected
    - Check ignition configurations (raw-image and simplified-installer only)

## RHEL-Edge CI

### Upstream CI

For RHEL-Edge project, 90% of features come from [osbuild](https://github.com/osbuild/osbuild.git) and [osbuild-composer](https://github.com/osbuild/osbuild-composer.git). In this case, [osbuild](https://github.com/osbuild/osbuild.git) and [osbuild-composer](https://github.com/osbuild/osbuild-composer.git) CI will be used ad RHEL-Edge project upstream CI.

The Upstream CI is triggered by each PR and it focuses on code change.

Considering Upstream CI environment and test duration, the Upstream CI only covers virtualization tests, bare metal is out of Upstream CI scope.

### Downstream CI

[RHEL 8/9, CentOS Stream 8/9 report dashboard](https://github.com/virt-s1/rhel-edge/projects/1)

[Fedora report dashboard](https://github.com/virt-s1/rhel-edge/projects/2)

[Package greenboot, fido-device-onboard, rust-coreos-installer, rpm-ostree, ostree report](https://github.com/virt-s1/rhel-edge/projects/3)

[Customer case test report](https://github.com/virt-s1/rhel-edge/projects/4)

### CI for this repository

CI for this repository is to test `test code`. It's triggered by PR in this repository. Any changes for `test code` has to be pass all tests of CI before they are merged into master.

Test of this CI includes:

1. [commit lint](https://www.conventionalcommits.org/en/v1.0.0/)
2. [spell check](https://github.com/codespell-project/codespell)
3. [Shellcheck](https://www.shellcheck.net/): running on Github
4. [Yaml lint](https://yamllint.readthedocs.io/en/stable/): running on Github
5. [Edge tests](https://github.com/virt-s1/rhel-edge/blob/main/CI.md#rhel-for-edge-ci): running on Github

RHEL-Edge CI details can be found from [CI doc](CI.md)

## RHEL-Edge Test

### Test Scenario

Test suites in scenario:

1. [`ostree.sh`](ostree.sh) and [`arm-commit.sh`](arm-commit.sh): edge-commit/iot-commit(tar) image type test on RHEL 8.x, RHEL 9.x, CentOS Stream 8,  CentOS Stream 9, and Fedora
2. [`ostree-ng.sh`](ostree-ng.sh) and [`arm-installer.sh`](arm-installer.sh): edge-container/iot-container and edge-installer/iot-installer(ISO) image types test on RHEL 8.x, RHEL 9.x, CentOS Stream 8, CentOS Stream 9 and Fedora
3. [`ostree-raw-image.sh`](ostree-raw-image.sh) and [`arm-raw.sh`](arm-raw.sh): edge-raw-image/iot-raw-image(raw) image types test on RHEL 8.x, RHEL 9.x, CentOS Stream 8, CentOS Stream 9, and Fedora
4. [`ostree-simplified-installer.sh`](ostree-simplified-installer.sh) and [`arm-simplified.sh`](arm-simplified.sh): edge-simplified-installer(ISO) image types test on RHEL 8.x, RHEL 9.x, CentOS Stream 8, and CentOS Stream 9
5. [`arm-rebase.sh`](arm-rebase.sh): Different ostree ref rebase test on RHEL 8.x and CentOS Stream 8
6. [`ostree-8-to-9.sh`](ostree-8-to-9.sh): RHEL 8/CentOS Stream 8 Edge system upgrade to RHEL 9/CentOS Stream 9 Edge system test
7. [`ostree-9-to-9.sh`](ostree-9-to-9.sh): RHEL 9/CentOS Stream 9 Edge system upgrade and rebase to RHEL 9/CentOS Stream 9 Edge system test
8. [`minimal-raw.sh`](minimal-raw.sh) and [`arm-minimal.sh`](arm-minimal.sh): RPM based system test (Not ostree)
9. [`ostree-ignition.sh`](ostree-ignition.sh) and [`arm-ignition.sh`](arm-ignition.sh): Ignition test for simplified installer and raw image
10. [`ostree-ami-image.sh`](ostree-ami-image.sh): AWS ec2 instance image test
11. [`ostree-fdo-aio.sh`](ostree-fdo-aio.sh): FDO All-In-One service test
12. [`ostree-fdo-db.sh`](ostree-fdo-db.sh): FDO with database backend test
13. [`ostree-fdo-container.sh`](ostree-fdo-container.sh): FDO container image test
14. [`ostree-pulp.sh`](ostree-pulp.sh): Pulp content management integration test
15. [`ostree-vsphere.sh`](ostree-vsphere.sh): vSphere image deployment test
16. [`ostree-iot-qcow2.sh`](ostree-iot-qcow2.sh): Fedora IoT qcow2 image test
17. [`iot-installer.sh`](iot-installer.sh): Fedora IoT installer ISO test
18. [`iot-simplified-installer.sh`](iot-simplified-installer.sh): Fedora IoT simplified installer test
19. [`iot-raw-image.sh`](iot-raw-image.sh): Fedora IoT raw image test
20. [`iot-bootc-image.sh`](iot-bootc-image.sh): Fedora IoT bootc (bootable container) image test

### Setup Scripts

Before running tests, the environment must be set up:

- [`setup.sh`](setup.sh): Sets up test environment for RHEL Edge tests
  - Installs required packages (osbuild, composer-cli, podman, etc.)
  - Configures repositories based on OS version
  - Sets up HTTP server for image serving
  - **Required:** `DOWNLOAD_NODE` environment variable

- [`iot-setup.sh`](iot-setup.sh): Sets up test environment for Fedora IoT tests
  - Similar to setup.sh but configured for Fedora IoT

### Test environment

#### For x86_64

You can run RHEL for Edge test on any x86_64 machine, like server, laptop, or VM, but KVM has to be enabled. Otherwise QEMU will be used and the test will take a really long time.

    $ls -l /dev/kvm

#### for ARM

To run RHEL for Edge test on ARM server, a bare metal ARM server is required.

#### Supported OS

    RHEL 8.6/8.8/8.9
    RHEL 9.0/9.2/9.3
    CentOS Stream 8
    CentOS Stream 9
    Fedora 37 (Simplified-installer not supported)
    Fedora 38 (Simplified-installer not supported)
    Fedora rawhide (Simplified-installer not supported)

### Test Run

#### For x86_64

    $ DOWNLOAD_NODE="hello-world.com" ./ostree.sh
    $ DOWNLOAD_NODE="hello-world.com" OCP4_TOKEN=abcdefg QUAY_USERNAME=rhel-edge QUAY_PASSWORD=123456 ./ostree-ng.sh
    $ DOWNLOAD_NODE="hello-world.com" DOCKERHUB_USERNAME=rhel-edge DOCKERHUB_PASSWORD=123456 ./ostree-raw-image.sh
    $ DOWNLOAD_NODE="hello-world.com" ./ostree-simplified-installer.sh
    $ DOWNLOAD_NODE="hello-world.com" ./ostree-8-to-9.sh
    $ DOWNLOAD_NODE="hello-world.com" ./ostree-9-to-9.sh
    $ ./minimal-raw.sh (Fedora 37 and above)
    $ DOWNLOAD_NODE="hello-world.com" ./ostree-ignition.sh
    $ DOWNLOAD_NODE="hello-world.com" ./ostree-ami-image.sh

#### For ARM64

    $ tools/deploy_bare.sh
    $ DOWNLOAD_NODE="hello-world.com" ./arm-commit.sh <test os>
    $ DOWNLOAD_NODE="hello-world.com" QUAY_USERNAME=rhel-edge QUAY_PASSWORD=123456 ./arm-installer.sh <test os>
    $ DOWNLOAD_NODE="hello-world.com" DOCKERHUB_USERNAME=rhel-edge DOCKERHUB_PASSWORD=123456 ./arm-raw.sh <test os>
    $ DOWNLOAD_NODE="hello-world.com" ./arm-simplified.sh <test os>
    $ DOWNLOAD_NODE="hello-world.com" ./arm-ignition.sh <centos-stream-9 or rhel-9-2>
    $ DOWNLOAD_NODE="hello-world.com" ./arm-minimal.sh <fedora-37 or fedora-38>

    <test os> can be one of "rhel-9-3", "centos-stream-9", "fedora-38"

### Test Configuration

You can set these environment variables to run tests:

#### Required Variables

- `DOWNLOAD_NODE` - RHEL nightly compose download URL
  - **Required for:** All test scripts
  - **Example:** `DOWNLOAD_NODE="download.eng.bos.redhat.com"`

#### Optional Variables (for specific test scenarios)

- `QUAY_USERNAME` - quay.io username
  - **Used by:** `ostree-ng.sh`, `iot-bootc-image.sh`
  - **Purpose:** Test pushing Edge OCI-archive image to quay.io

- `QUAY_PASSWORD` - quay.io password
  - **Used by:** `ostree-ng.sh`, `iot-bootc-image.sh`

- `DOCKERHUB_USERNAME` - Docker hub account username
  - **Used by:** `ostree-raw-image.sh`, `tools/arm-raw.sh`, `tools/edge-raw.sh`
  - **Purpose:** Test pushing Edge OCI-archive image to Docker hub

- `DOCKERHUB_PASSWORD` - Docker hub account password
  - **Used by:** `ostree-raw-image.sh`, `tools/arm-raw.sh`, `tools/edge-raw.sh`

- `TEST_CASE` - Test case identifier for tmt execution
  - **Used by:** `tmt/tests/test.sh` dispatcher
  - **Values:** See TMT execution section

- `ARTIFACTS` - Directory for test artifacts (default: `/tmp/artifacts`)
  - **Used by:** Various scripts for storing test outputs

#### AWS Variables (for cleanup scripts)

- `AWS_DEFAULT_REGION` - AWS region for cleanup operations
- AWS credentials via AWS CLI configuration
  - **Used by:** `tools/aws-ami-cleanup.sh`

### Utility Scripts

#### Cleanup Scripts

- [`tools/aws-ami-cleanup.sh`](tools/aws-ami-cleanup.sh): Cleanup idle AWS EC2 resources
  - Removes old instances, snapshots, images, buckets, and keypairs
  - **Required:** AWS credentials and `AWS_DEFAULT_REGION`

- [`tools/vsphere-cleanup.py`](tools/vsphere-cleanup.py): Cleanup vSphere resources
  - **Required:** vSphere credentials

### Running Tests with TMT

Tests can be executed via Test Management Tool (tmt), which is the primary method used in CI:

```bash
# Run all edge tests
tmt run -a

# Run specific test plan
tmt run plan -n edge-test
tmt run plan -n iot-test

# Run specific test case
TEST_CASE=edge-commit tmt run
```

The `TEST_CASE` environment variable determines which script is executed:
   - `edge-commit`, `edge-installer`, `edge-raw-image`, `edge-simplified-installer`, etc.
   - `iot-installer`, `iot-simplified-installer`, `iot-raw-image`, `iot-bootc`

## Test Architecture

### Script Organization

- **Root directory scripts:** x86_64 tests for RHEL Edge and Fedora IoT
- **tools/ directory:** ARM64 tests and utility scripts
- **tmt/ directory:** Test Management Tool definitions and plans

### Test Categories

1. **Edge Tests** (`ostree-*.sh`): RHEL for Edge image tests
2. **IoT Tests** (`iot-*.sh`): Fedora IoT image tests
3. **ARM Tests** (`tools/arm-*.sh`): ARM64 architecture tests
4. **Utility Scripts** (`tools/*.sh`, `tools/*.py`): Helper and cleanup scripts

## Contact us

- RHEL for Edge discussion channel: [`Google Chat room`](https://mail.google.com/chat/u/0/#chat/space/AAAAlhJ-myk)

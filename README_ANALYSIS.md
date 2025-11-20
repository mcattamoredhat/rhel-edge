# RHEL-Edge Repository Analysis and README Improvement Recommendations

## Executive Summary

This repository contains integration tests for **RHEL for Edge** (and Fedora IoT) operating system images. The tests validate the complete workflow from image building through installation to system upgrades, ensuring Edge images work correctly in customer-like scenarios.

**What this repository does:**
- Tests RHEL for Edge and Fedora IoT image building using osbuild-composer
- Validates image installation via multiple methods (HTTP boot, ISO installer, raw images, containers)
- Tests system upgrades and rebases
- Verifies post-installation functionality (greenboot, podman, FDO, LVM, ignition, etc.)
- Provides CI/CD integration for test code validation

---

## Repository Purpose (According to README)

The README states this repository is for:
1. **Integration testing** of RHEL for Edge images
2. **Customer-scenario aligned** test flows
3. **Three main test phases:**
   - Image building with osbuild-composer
   - Image installation (multiple methods)
   - System upgrades and rebases
4. **Post-installation verification** of various features

---

## Complete Script Inventory and Analysis

### Scripts in Root Directory

| Script Name | In README? | Purpose | TMT Test? | Required Variables |
|------------|------------|---------|-----------|-------------------|
| `setup.sh` | ❌ **NO** | Sets up test environment, installs packages, configures repositories | ✅ Yes (via test.sh) | `DOWNLOAD_NODE` |
| `ostree.sh` | ✅ Yes | Tests edge-commit/iot-commit (tar) image type | ✅ Yes | `DOWNLOAD_NODE` |
| `ostree-ng.sh` | ✅ Yes | Tests edge-container/iot-container and edge-installer/iot-installer (ISO) | ✅ Yes | `DOWNLOAD_NODE`, `QUAY_USERNAME`, `QUAY_PASSWORD`, `OCP4_TOKEN` |
| `ostree-raw-image.sh` | ✅ Yes | Tests edge-raw-image/iot-raw-image (raw) image types | ✅ Yes | `DOWNLOAD_NODE`, `DOCKERHUB_USERNAME`, `DOCKERHUB_PASSWORD` |
| `ostree-simplified-installer.sh` | ✅ Yes | Tests edge-simplified-installer (ISO) | ✅ Yes | `DOWNLOAD_NODE` |
| `ostree-8-to-9.sh` | ✅ Yes | RHEL 8/CentOS Stream 8 → RHEL 9/CentOS Stream 9 upgrade | ✅ Yes | `DOWNLOAD_NODE` |
| `ostree-9-to-9.sh` | ✅ Yes | RHEL 9/CentOS Stream 9 upgrade and rebase | ✅ Yes | `DOWNLOAD_NODE` |
| `ostree-ignition.sh` | ✅ Yes | Ignition test for simplified installer and raw image | ✅ Yes | `DOWNLOAD_NODE` |
| `ostree-ami-image.sh` | ✅ Yes | AWS EC2 instance image test | ✅ Yes | `DOWNLOAD_NODE` |
| `ostree-fdo-aio.sh` | ❌ **NO** | Tests FDO (FIDO Device Onboard) with All-In-One service | ✅ Yes | `DOWNLOAD_NODE` |
| `ostree-fdo-db.sh` | ❌ **NO** | Tests FDO with database backend | ✅ Yes | `DOWNLOAD_NODE` |
| `ostree-fdo-container.sh` | ❌ **NO** | Tests FDO container image | ✅ Yes | `DOWNLOAD_NODE` |
| `ostree-pulp.sh` | ❌ **NO** | Tests Pulp content management integration | ✅ Yes | `DOWNLOAD_NODE` |
| `ostree-vsphere.sh` | ❌ **NO** | Tests vSphere image deployment | ✅ Yes | `DOWNLOAD_NODE` |
| `ostree-iot-qcow2.sh` | ❌ **NO** | Tests Fedora IoT qcow2 image | ✅ Yes | `DOWNLOAD_NODE` |
| `iot-installer.sh` | ❌ **NO** | Tests Fedora IoT installer ISO | ✅ Yes | `DOWNLOAD_NODE` |
| `iot-simplified-installer.sh` | ❌ **NO** | Tests Fedora IoT simplified installer ISO | ✅ Yes | `DOWNLOAD_NODE` |
| `iot-raw-image.sh` | ❌ **NO** | Tests Fedora IoT raw image | ✅ Yes | `DOWNLOAD_NODE` |
| `iot-bootc-image.sh` | ❌ **NO** | Tests Fedora IoT bootc (bootable container) image | ✅ Yes | `DOWNLOAD_NODE`, `QUAY_USERNAME`, `QUAY_PASSWORD` (optional) |
| `iot-setup.sh` | ❌ **NO** | Sets up test environment for Fedora IoT tests | ✅ Yes (via test.sh) | `DOWNLOAD_NODE` |
| `minimal-raw.sh` | ✅ Yes | RPM-based system test (not ostree) | ❌ **NO** | None (for Fedora 37+) |

### Scripts in `tools/` Directory

| Script Name | In README? | Purpose | TMT Test? | Required Variables |
|------------|------------|---------|-----------|-------------------|
| `tools/arm-commit.sh` | ✅ Yes | ARM edge-commit/iot-commit test | ❌ **NO** | `DOWNLOAD_NODE`, `<test os>` |
| `tools/arm-installer.sh` | ✅ Yes | ARM edge-installer/iot-installer test | ❌ **NO** | `DOWNLOAD_NODE`, `QUAY_USERNAME`, `QUAY_PASSWORD`, `<test os>` |
| `tools/arm-raw.sh` | ✅ Yes | ARM edge-raw-image/iot-raw-image test | ❌ **NO** | `DOWNLOAD_NODE`, `DOCKERHUB_USERNAME`, `DOCKERHUB_PASSWORD`, `<test os>` |
| `tools/arm-simplified.sh` | ✅ Yes | ARM edge-simplified-installer test | ❌ **NO** | `DOWNLOAD_NODE`, `<test os>` |
| `tools/arm-ignition.sh` | ✅ Yes | ARM ignition test | ❌ **NO** | `DOWNLOAD_NODE`, `<test os>` |
| `tools/arm-minimal.sh` | ✅ Yes | ARM RPM-based system test | ❌ **NO** | `<test os>` |
| `tools/arm-rebase.sh` | ✅ Yes | ARM ostree ref rebase test | ❌ **NO** | `DOWNLOAD_NODE` |
| `tools/edge-raw.sh` | ❌ **NO** | Edge raw image test (alternative implementation?) | ❌ **NO** | `DOWNLOAD_NODE`, `DOCKERHUB_USERNAME`, `DOCKERHUB_PASSWORD` |
| `tools/aws-ami-cleanup.sh` | ❌ **NO** | Cleanup AWS EC2 resources (buckets, snapshots, images, instances) | ❌ **NO** | `AWS_DEFAULT_REGION`, AWS credentials |
| `tools/vsphere-cleanup.py` | ❌ **NO** | Cleanup vSphere resources | ❌ **NO** | vSphere credentials |

### Utility Scripts

| Script Name | In README? | Purpose | TMT Test? | Required Variables |
|------------|------------|---------|-----------|-------------------|
| `check-ostree.yaml` | ❌ **NO** | Ansible playbook for ostree checks? | ❌ **NO** | Unknown |
| `check-ostree-iot.yaml` | ❌ **NO** | Ansible playbook for IoT ostree checks? | ❌ **NO** | Unknown |

---

## TMT Test Coverage Analysis

### TMT Test Structure

The repository uses **Test Management Tool (tmt)** for test execution:

- **Test Plans:** `tmt/plans/`
  - `edge-test.fmf` - Edge test plan with multiple test scenarios
  - `iot-test.fmf` - Fedora IoT test plan
  - `export-to-polarion-plan.fmf` - Plan for exporting tests to Polarion

- **Test Definitions:** `tmt/tests/`
  - `edge-test.fmf` - Edge test definition
  - `iot-test.fmf` - IoT test definition
  - `test.sh` - Main test runner that dispatches to appropriate script based on `TEST_CASE` environment variable
  - `export-tc-to-polarion.fmf` - Test case export definition

### Test Coverage by Script

**Fully Tested (via tmt):**
- ✅ `ostree.sh` → `edge-commit`
- ✅ `ostree-ng.sh` → `edge-installer`
- ✅ `ostree-raw-image.sh` → `edge-raw-image`
- ✅ `ostree-simplified-installer.sh` → `edge-simplified-installer`
- ✅ `ostree-ami-image.sh` → `edge-ami-image`
- ✅ `ostree-vsphere.sh` → `edge-vsphere`
- ✅ `ostree-fdo-aio.sh` → `edge-fdo-aio`
- ✅ `ostree-fdo-db.sh` → `edge-fdo-db`
- ✅ `ostree-ignition.sh` → `edge-ignition`
- ✅ `ostree-pulp.sh` → `edge-pulp`
- ✅ `ostree-8-to-9.sh` → `edge-8to9`
- ✅ `ostree-9-to-9.sh` → `edge-9to9`
- ✅ `ostree-fdo-container.sh` → `edge-fdo-container`
- ✅ `iot-installer.sh` → `iot-installer`
- ✅ `iot-simplified-installer.sh` → `iot-simplified-installer`
- ✅ `iot-raw-image.sh` → `iot-raw-image`
- ✅ `iot-bootc-image.sh` → `iot-bootc`

**Not Tested via TMT:**
- ❌ `minimal-raw.sh` - Not in tmt test.sh dispatcher
- ❌ All `tools/arm-*.sh` scripts - Not in tmt test.sh dispatcher
- ❌ `tools/edge-raw.sh` - Not in tmt test.sh dispatcher
- ❌ `tools/aws-ami-cleanup.sh` - Utility script
- ❌ `tools/vsphere-cleanup.py` - Utility script

---

## Environment Variables Analysis

### Currently Documented in README

The README currently documents these variables:
- `QUAY_USERNAME` - quay.io username
- `QUAY_PASSWORD` - quay.io password
- `DOCKERHUB_USERNAME` - Docker hub username
- `DOCKERHUB_PASSWORD` - Docker hub password
- `OCP4_TOKEN` - Openshift 4 service account token
- `DOWNLOAD_NODE` - RHEL nightly compose download URL

### Missing from README

Based on script analysis, these variables are used but **NOT documented**:

1. **`TEST_CASE`** - Used by tmt test.sh to dispatch to correct script
   - Values: `edge-commit`, `edge-installer`, `edge-raw-image`, `edge-simplified-installer`, `edge-ami-image`, `edge-vsphere`, `edge-fdo-aio`, `edge-fdo-db`, `edge-ignition`, `edge-pulp`, `edge-8to9`, `edge-9to9`, `edge-fdo-container`, `iot-installer`, `iot-simplified-installer`, `iot-raw-image`, `iot-bootc`

2. **AWS-related variables** (for `aws-ami-cleanup.sh`):
   - `AWS_DEFAULT_REGION` - AWS region for cleanup operations
   - AWS credentials (via AWS CLI configuration)

3. **vSphere-related variables** (for `ostree-vsphere.sh` and cleanup):
   - vSphere credentials (likely via environment or config files)

4. **Optional variables:**
   - `ARTIFACTS` - Used in some scripts to specify artifact directory (defaults to `/tmp/artifacts`)

---

## README Gaps and Issues

### 1. Missing Script Documentation

**Scripts NOT mentioned in README but exist and are tested:**
- `ostree-fdo-aio.sh`
- `ostree-fdo-db.sh`
- `ostree-fdo-container.sh`
- `ostree-pulp.sh`
- `ostree-vsphere.sh`
- `ostree-iot-qcow2.sh`
- `iot-installer.sh`
- `iot-simplified-installer.sh`
- `iot-raw-image.sh`
- `iot-bootc-image.sh`
- `setup.sh` (critical setup script)
- `iot-setup.sh` (IoT setup script)

### 2. Missing Test Execution Methods

README doesn't explain:
- How to run tests via **tmt** (the primary CI method)
- The relationship between direct script execution and tmt execution
- How `TEST_CASE` environment variable works

### 3. Incomplete Variable Documentation

- Missing `TEST_CASE` variable explanation
- Missing AWS variables for cleanup scripts
- Missing vSphere variables
- No explanation of optional vs required variables

### 4. Missing Utility Scripts Documentation

- `tools/aws-ami-cleanup.sh` - AWS resource cleanup
- `tools/vsphere-cleanup.py` - vSphere resource cleanup
- `tools/edge-raw.sh` - Purpose unclear (duplicate of `ostree-raw-image.sh`?)

### 5. Missing Architecture Information

README doesn't clearly explain:
- The difference between x86_64 scripts and ARM scripts
- When to use `tools/` directory scripts vs root scripts
- The relationship between Edge and IoT test suites

### 6. Numbering Issues

- Section "3. Checkings after installation/upgrade" appears twice (lines 25 and 31)
- Test scenario list has duplicate numbering (two items numbered "6", two numbered "8")

### 7. Missing Workflow Description

README lacks:
- Clear workflow description of the testing process
- How to add new test cases
- Test architecture overview

---

## Recommended README Improvements

### Priority 1: Critical Additions

1. **Add missing scripts to "Test Scenario" section:**
   ```
   9. [`ostree-fdo-aio.sh`](ostree-fdo-aio.sh): FDO All-In-One service test
   10. [`ostree-fdo-db.sh`](ostree-fdo-db.sh): FDO with database backend test
   11. [`ostree-fdo-container.sh`](ostree-fdo-container.sh): FDO container image test
   12. [`ostree-pulp.sh`](ostree-pulp.sh): Pulp content management integration test
   13. [`ostree-vsphere.sh`](ostree-vsphere.sh): vSphere image deployment test
   14. [`ostree-iot-qcow2.sh`](ostree-iot-qcow2.sh): Fedora IoT qcow2 image test
   15. [`iot-installer.sh`](iot-installer.sh): Fedora IoT installer ISO test
   16. [`iot-simplified-installer.sh`](iot-simplified-installer.sh): Fedora IoT simplified installer test
   17. [`iot-raw-image.sh`](iot-raw-image.sh): Fedora IoT raw image test
   18. [`iot-bootc-image.sh`](iot-bootc-image.sh): Fedora IoT bootc (bootable container) image test
   ```

2. **Add setup scripts documentation:**
   ```
   ## Setup Scripts
   
   Before running tests, the environment must be set up:
   
   - [`setup.sh`](setup.sh): Sets up test environment for RHEL Edge tests
     - Installs required packages (osbuild, composer-cli, podman, etc.)
     - Configures repositories based on OS version
     - Sets up HTTP server for image serving
     - **Required:** `DOWNLOAD_NODE` environment variable
   
   - [`iot-setup.sh`](iot-setup.sh): Sets up test environment for Fedora IoT tests
     - Similar to setup.sh but configured for Fedora IoT
     - **Required:** `DOWNLOAD_NODE` environment variable
   ```

3. **Fix numbering and duplicate sections**

4. **Add TMT execution method:**
   ```
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
   ```

### Priority 2: Important Additions

5. **Expand environment variables section:**
   ```
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
   
   - `OCP4_TOKEN` - Edit-able SA token on PSI Openshift 4
     - **Used by:** `ostree-ng.sh`
     - **Purpose:** Deploy edge-container on PSI OCP4
   
   - `TEST_CASE` - Test case identifier for tmt execution
     - **Used by:** `tmt/tests/test.sh` dispatcher
     - **Values:** See TMT execution section
   
   - `ARTIFACTS` - Directory for test artifacts (default: `/tmp/artifacts`)
     - **Used by:** Various scripts for storing test outputs
   
   #### AWS Variables (for cleanup scripts)
   
   - `AWS_DEFAULT_REGION` - AWS region for cleanup operations
   - AWS credentials via AWS CLI configuration
     - **Used by:** `tools/aws-ami-cleanup.sh`
   ```

6. **Add utility scripts section:**
   ```
   ## Utility Scripts
   
   ### Cleanup Scripts
   
   - [`tools/aws-ami-cleanup.sh`](tools/aws-ami-cleanup.sh): Cleanup idle AWS EC2 resources
     - Removes old instances, snapshots, images, buckets, and keypairs
     - **Required:** AWS credentials and `AWS_DEFAULT_REGION`
   
   - [`tools/vsphere-cleanup.py`](tools/vsphere-cleanup.py): Cleanup vSphere resources
     - **Required:** vSphere credentials
   ```

### Priority 3: Nice to Have

7. **Add architecture explanation:**
   ```
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
   ```

8. **Add workflow diagram description**

---

## Workflow Description: What Are We Testing and How?

### What Are We Testing?

This repository tests **RHEL for Edge** and **Fedora IoT** operating system images, which are immutable, container-focused operating systems designed for edge computing scenarios. The tests validate:

1. **Image Building:** Can we build Edge/IoT images using osbuild-composer?
2. **Image Installation:** Can we install images via multiple methods (HTTP boot, ISO, raw images, containers)?
3. **System Operations:** Do installed systems function correctly (greenboot, podman, networking, storage)?
4. **System Upgrades:** Can we upgrade and rebase systems correctly?
5. **Advanced Features:** Do advanced features work (FDO, Pulp, Ignition, vSphere, AWS AMI)?

### How Do We Test It?

The testing follows an **integration test approach** that mimics customer scenarios:

#### Phase 1: Environment Setup
1. Run `setup.sh` or `iot-setup.sh` to:
   - Install required packages (osbuild, composer-cli, podman, etc.)
   - Configure repositories based on OS version
   - Set up HTTP server for serving images
   - Configure networking

#### Phase 2: Image Building
1. Use **osbuild-composer** to build Edge/IoT images:
   - Create blueprint with desired configuration
   - Submit compose request
   - Wait for compose to complete
   - Download and verify image

#### Phase 3: Image Installation
1. Deploy image using one of several methods:
   - **HTTP Boot:** Serve image via HTTP, boot VM via PXE
   - **ISO Installer:** Create bootable ISO, install via installer
   - **Raw Image:** Boot directly from raw disk image
   - **Container:** Deploy as container image
   - **Simplified Installer:** Use simplified installation ISO

#### Phase 4: Post-Installation Verification
1. SSH into installed system
2. Verify:
   - OSTree commit is correct
   - Mount points are correct
   - Greenboot services are running
   - Podman can run containers (root and non-root)
   - Journal logs are persistent
   - FDO onboarding (if applicable)
   - LVM and growfs (if applicable)
   - Ignition configurations (if applicable)

#### Phase 5: System Upgrades (if applicable)
1. Create upgrade image
2. Deploy upgrade
3. Verify system upgraded correctly
4. Test rollback functionality

### Test Execution Methods

#### Method 1: Direct Script Execution (Manual Testing)
```bash
# Set required variables
export DOWNLOAD_NODE="download.eng.bos.redhat.com"

# Run specific test
./ostree.sh
./ostree-ng.sh
```

#### Method 2: TMT Execution (CI/Recommended)
```bash
# Run all tests
tmt run -a

# Run specific plan
tmt run plan -n edge-test

# Run specific test case
TEST_CASE=edge-commit tmt run
```

#### Method 3: ARM Testing (Bare Metal)
```bash
# Deploy to bare metal first
tools/deploy_bare.sh

# Run ARM tests
DOWNLOAD_NODE="..." ./tools/arm-commit.sh rhel-9-3
```

---

## How to Add a New Test Case

### Step-by-Step Guide

#### Step 1: Create the Test Script

1. **Create a new shell script** in the root directory (for x86_64) or `tools/` (for ARM):
   ```bash
   #!/bin/bash
   set -euox pipefail
   
   # Provision the software under test
   ./setup.sh
   
   # Get OS data
   source /etc/os-release
   ARCH=$(uname -m)
   
   # Set up variables
   TEST_UUID=$(uuidgen)
   IMAGE_KEY="your-test-${TEST_UUID}"
   # ... add your test-specific variables
   ```

2. **Follow the pattern** of existing scripts:
   - Call `./setup.sh` at the beginning
   - Set up variables (TEST_UUID, IMAGE_KEY, etc.)
   - Build image using osbuild-composer
   - Deploy/install image
   - Verify installation
   - Clean up resources

#### Step 2: Add to TMT Test Dispatcher

Edit `tmt/tests/test.sh` to add your test case:

```bash
elif [ "$TEST_CASE" = "your-test-name" ]; then
    ./your-test-script.sh
```

#### Step 3: Add TMT Test Definition

1. **Add to test plan** (`tmt/plans/edge-test.fmf` or `iot-test.fmf`):
   ```yaml
   /edge-x86-your-test:
     summary: Test your new feature
     environment+:
       TEST_CASE: edge-your-test
     adjust+:
       - when: arch != x86_64
         enabled: false
   ```

2. **Ensure test definition exists** in `tmt/tests/edge-test.fmf` or `tmt/tests/iot-test.fmf`

#### Step 4: Update README

1. Add your script to the "Test Scenario" section
2. Document required environment variables
3. Add example execution command

#### Step 5: Test Your Implementation

1. **Test locally:**
   ```bash
   TEST_CASE=edge-your-test tmt run
   ```

2. **Verify CI passes:**
   - Create PR
   - Ensure all CI checks pass
   - Verify your test appears in test results

#### Step 6: Export to Polarion (Optional)

If you want to track test cases in Polarion:

1. Ensure your test has a `.fmf` file in `tmt/tests/`
2. Run the Polarion export workflow (see `.github/workflows/export-tc-to-polarion.yml`)
3. The test case will be exported with a Polarion ID

### Best Practices

1. **Follow existing patterns:** Look at similar scripts for structure
2. **Include cleanup:** Always clean up VMs, images, and temporary files
3. **Use meaningful names:** Use descriptive variable and function names
4. **Add comments:** Document complex logic
5. **Handle errors:** Use `set -euox pipefail` and proper error handling
6. **Test locally first:** Verify script works before adding to CI
7. **Document variables:** Add all required variables to README

---

## Summary of Recommended Changes

### Immediate Actions Required

1. ✅ Add all missing scripts to README "Test Scenario" section
2. ✅ Document `setup.sh` and `iot-setup.sh`
3. ✅ Fix duplicate section numbering
4. ✅ Add TMT execution documentation
5. ✅ Expand environment variables section with all variables
6. ✅ Add utility scripts section
7. ✅ Add workflow description section
8. ✅ Add "How to Add New Test Case" section

### Documentation Structure Improvements

1. Reorganize README with clearer sections
2. Add table of contents for easier navigation
3. Add architecture diagram (text-based or link to image)
4. Add troubleshooting section
5. Add examples section with common use cases

---

## Conclusion

The README is **significantly outdated** and missing documentation for:
- **10+ test scripts** that are actively used and tested
- **2 setup scripts** that are critical for test execution
- **TMT execution method** (the primary CI method)
- **Multiple environment variables** used by scripts
- **Utility scripts** for resource cleanup
- **Workflow description** for new team members
- **Guide for adding new test cases**

This analysis provides a comprehensive foundation for updating the README to be accurate, complete, and useful for new team members.

---

## Fedora IoT Scripts: Detailed Analysis

### Overview: How Fedora IoT Scripts Differ from RHEL Edge Scripts

The Fedora IoT test scripts (`iot-*.sh`) follow a fundamentally different approach compared to the RHEL Edge scripts (`ostree-*.sh`). While RHEL Edge scripts **build images from scratch** using osbuild-composer, Fedora IoT scripts **download and use pre-built images** from Koji (Fedora's build system). This difference reflects the different release models and build infrastructures of the two projects.

### Key Architectural Differences

| Aspect | RHEL Edge Scripts (`ostree-*.sh`) | Fedora IoT Scripts (`iot-*.sh`) |
|--------|----------------------------------|--------------------------------|
| **Image Source** | Built locally via osbuild-composer | Pre-built images from Koji |
| **Build Process** | Creates blueprints, submits composes, waits for builds | Downloads ready-made images |
| **Environment Variable** | `DOWNLOAD_NODE` (RHEL compose URL) | `COMPOSE` (Koji compose identifier) |
| **Image Location** | Local osbuild-composer output | `https://kojipkgs.fedoraproject.org/compose/iot/` |
| **Verification Playbook** | `check-ostree.yaml` | `check-ostree-iot.yaml` |
| **Setup Script** | `setup.sh` | `iot-setup.sh` |
| **OSTree Reference** | `rhel/8/${ARCH}/edge` or `rhel/9/${ARCH}/edge` | `fedora/stable/${ARCH}/iot` or `fedora/rawhide/${ARCH}/iot` |

### The Role of Koji in Fedora IoT Testing

**Koji** is Fedora's build system that produces official Fedora images. For Fedora IoT, images are built and published to Koji as part of the Fedora release process. The IoT test scripts leverage these pre-built images rather than building them locally, which:

1. **Reduces test execution time** - No need to wait for image builds (which can take 30+ minutes)
2. **Tests official images** - Validates the exact images that users will receive
3. **Simplifies test infrastructure** - No need for osbuild-composer setup for IoT tests
4. **Enables faster iteration** - Tests can run against multiple compose versions quickly

**Koji Compose Structure:**
- Compose URL format: `https://kojipkgs.fedoraproject.org/compose/iot/${COMPOSE}/compose/IoT/${ARCH}/`
- Compose identifier example: `Fedora-IoT-43-20241201.0`
- Different image types available:
  - `/iso/` - ISO installer images
  - `/images/` - Raw images and OCI archives

### Detailed Script Analysis

#### 1. `iot-installer.sh` - Fedora IoT Installer ISO Test

**What it tests:**
- Fedora IoT installer ISO functionality
- Installation process via ISO media
- Post-installation system verification

**How it works:**
1. **Setup:** Runs `iot-setup.sh` to prepare the test environment
2. **Image Download:** Downloads the Fedora IoT installer ISO from Koji:
   - URL: `https://kojipkgs.fedoraproject.org/compose/iot/${COMPOSE}/compose/IoT/${ARCH}/iso/`
   - Filename: `Fedora-IoT-ostree-43-${COMPOSE_ID}.${ARCH}.iso` (for Fedora 43)
3. **Kickstart Modification:** Uses `modksiso` to:
   - Extract the existing kickstart file from the ISO
   - Modify it to add SSH key, user configuration, and network settings
   - Create a new ISO with the modified kickstart
4. **VM Installation:** 
   - Creates a VM with the modified ISO as CD-ROM
   - Installs Fedora IoT via the installer
   - VM boots from the installed system
5. **Verification:** Runs `check-ostree-iot.yaml` Ansible playbook to verify:
   - OSTree commit is correct
   - System services are running
   - Basic functionality works

**Key differences from RHEL Edge installer:**
- Uses pre-built ISO instead of building one
- Downloads from Koji instead of creating via osbuild-composer
- Simpler workflow (no blueprint creation, no compose submission)

**Required Environment Variables:**
- `COMPOSE` - Koji compose identifier (e.g., `Fedora-IoT-43-20241201.0`)

#### 2. `iot-raw-image.sh` - Fedora IoT Raw Image Test

**What it tests:**
- Fedora IoT raw disk image functionality
- Booting directly from raw disk image
- Ignition configuration support
- Storage expansion capabilities

**How it works:**
1. **Setup:** Runs `iot-setup.sh` to prepare the test environment
2. **Image Download:** Downloads compressed raw image from Koji:
   - URL: `https://kojipkgs.fedoraproject.org/compose/iot/${COMPOSE}/compose/IoT/${ARCH}/images/`
   - Filename: `Fedora-IoT-raw-43-${COMPOSE_ID}.${ARCH}.raw.xz` (compressed)
3. **Ignition Setup:** 
   - Creates Ignition configuration file with user, SSH keys, and system settings
   - Serves it via HTTP server at `/var/www/html/ignition/`
4. **Image Preparation:**
   - Decompresses the raw image (`xz -d`)
   - Resizes the image to add storage (`qemu-img resize`)
   - Uses `kpartx` to create device-mapper entries for partitions
   - Mounts boot partition and embeds Ignition URL in kernel parameters
   - Converts raw image to qcow2 format for libvirt
5. **VM Boot:**
   - Creates VM with the prepared qcow2 image
   - VM boots and applies Ignition configuration on first boot
   - System is configured with SSH keys and user settings
6. **Verification:** Runs `check-ostree-iot.yaml` to verify system functionality

**Key differences from RHEL Edge raw image:**
- Downloads pre-built raw image instead of building one
- Uses Ignition for first-boot configuration (similar to RHEL Edge, but simpler)
- No container image creation step (raw image is directly available)

**Required Environment Variables:**
- `COMPOSE` - Koji compose identifier

#### 3. `iot-bootc-image.sh` - Fedora IoT Bootable Container (bootc) Test

**What it tests:**
- Fedora IoT bootc (bootable container) image functionality
- Container-to-disk image conversion using bootc-image-builder
- Booting from container-derived disk images
- Bootc system management capabilities

**How it works:**
1. **Setup:** Runs `iot-setup.sh` to prepare the test environment
2. **Container Image Download:** Downloads OCI archive from Koji:
   - URL: `https://kojipkgs.fedoraproject.org/compose/iot/${COMPOSE}/compose/IoT/${ARCH}/images/`
   - Filename: `Fedora-IoT-bootc-${ARCH}-43.${COMPOSE_ID}.ociarchive`
3. **Container Image Import:**
   - Uses `skopeo` to copy the OCI archive into local container storage
   - Tags it with the Fedora version (e.g., `43`)
4. **BIB Configuration:**
   - Creates `config.json` with user customization:
     - User name, password, SSH keys
     - Groups (wheel for sudo access)
5. **bootc-image-builder (BIB) Execution:**
   - **This is the key differentiator** - Uses `bootc-image-builder` tool to convert container image to disk image
   - Runs BIB in a privileged Podman container:
     ```bash
     podman run --privileged \
       quay.io/centos-bootc/bootc-image-builder:latest \
       --type qcow2 \
       --local \
       --config /config.json \
       --rootfs xfs \
       "${CONTAINER_IMG_NAME}:${OCI_ARCHIVE_TAG}"
     ```
   - BIB reads the container image and generates a bootable disk image
   - Output: `output/qcow2/disk.qcow2`
6. **VM Boot:**
   - Moves the generated qcow2 to libvirt images directory
   - Creates and starts VM with the bootc-generated disk image
   - VM boots the container-derived system
7. **Verification:** Runs `check-ostree-iot.yaml` with `bootc_system=true` to verify:
   - Bootc system is functional
   - Container-based system management works
   - System can be managed via bootc commands

**What is bootc-image-builder (BIB)?**

**bootc-image-builder** is a tool that converts container images (OCI archives) into bootable disk images. It's part of the bootc (bootable container) ecosystem, which allows treating operating systems as container images.

**Key BIB Features:**
- **Container-to-Disk Conversion:** Takes an OCI container image and creates a bootable disk image (qcow2, raw, etc.)
- **Customization:** Allows injecting configuration (users, SSH keys, etc.) during image generation
- **Root Filesystem:** Configures the root filesystem (XFS, ext4, etc.)
- **Boot Configuration:** Sets up bootloader, kernel, and initramfs
- **Integration:** Works with bootc-managed systems for container-based OS updates

**Why use BIB for IoT testing?**
- Tests the bootc workflow end-to-end
- Validates that container images can be converted to bootable systems
- Ensures bootc-managed systems work correctly
- Tests the integration between container images and disk images

**Key differences from other IoT scripts:**
- Uses container images (OCI archives) instead of disk images
- Requires bootc-image-builder tool (runs in container)
- Tests bootc ecosystem functionality
- More complex workflow (container → disk conversion step)

**Required Environment Variables:**
- `COMPOSE` - Koji compose identifier
- `QUAY_USERNAME`, `QUAY_PASSWORD` (optional) - For pushing to quay.io if needed

#### 4. `iot-simplified-installer.sh` - Fedora IoT Simplified Installer Test

**What it tests:**
- Fedora IoT simplified installer (provisioner) ISO
- Automated installation with FDO (FIDO Device Onboard) support
- Zero-touch provisioning capabilities

**How it works:**
1. **Setup:** Runs `iot-setup.sh` and sets up FDO server components
2. **Image Download:** Downloads simplified installer ISO from Koji
3. **FDO Server Configuration:** Sets up FDO rendezvous, owner onboarding, and serviceinfo servers
4. **ISO Modification:** Modifies kickstart to include FDO configuration
5. **VM Installation:** Installs via simplified installer with FDO onboarding
6. **Verification:** Verifies FDO onboarding completed successfully

**Key Feature:** Tests FDO (zero-touch device onboarding) which is a key differentiator for IoT deployments.

### Comparison: RHEL Edge vs Fedora IoT Testing Approach

#### RHEL Edge Approach (Build-First)
```
1. Setup environment (setup.sh)
2. Create blueprint with desired configuration
3. Submit compose to osbuild-composer
4. Wait for build to complete (30-60 minutes)
5. Download built image
6. Deploy and test image
```

**Advantages:**
- Tests the entire build pipeline
- Validates osbuild-composer functionality
- Can test custom configurations
- Tests build reproducibility

**Disadvantages:**
- Longer test execution time
- Requires osbuild-composer infrastructure
- More complex setup

#### Fedora IoT Approach (Download-First)
```
1. Setup environment (iot-setup.sh)
2. Download pre-built image from Koji
3. Optionally modify/customize image
4. Deploy and test image
```

**Advantages:**
- Faster test execution (no build wait time)
- Tests official release images
- Simpler infrastructure requirements
- Can test multiple compose versions quickly

**Disadvantages:**
- Doesn't test build process
- Limited customization options
- Depends on Koji availability

### Testing Philosophy

The different approaches reflect the different goals:

- **RHEL Edge tests** focus on validating the **image building process** and ensuring osbuild-composer works correctly for creating Edge images
- **Fedora IoT tests** focus on validating **pre-built images** and ensuring they work correctly when deployed, since the images are built by Fedora's infrastructure

Both approaches are valid and serve different purposes in the overall testing strategy.

### Environment Variables for Fedora IoT Scripts

All Fedora IoT scripts require:
- **`COMPOSE`** - Koji compose identifier
  - Format: `Fedora-IoT-{VERSION}-{DATE}.{BUILD}`
  - Example: `Fedora-IoT-43-20241201.0`
  - Used to construct download URLs from Koji

Optional variables:
- **`QUAY_USERNAME`**, **`QUAY_PASSWORD`** - For `iot-bootc-image.sh` if pushing to quay.io
- **`ARTIFACTS`** - Directory for test artifacts (defaults to `/tmp/artifacts`)

### Verification: check-ostree-iot.yaml

All Fedora IoT scripts use `check-ostree-iot.yaml` Ansible playbook for verification, which:
- Checks OSTree commit and ref
- Verifies system services (greenboot, etc.)
- Tests podman container functionality
- Validates networking and storage
- For bootc: Verifies bootc system management capabilities

This is different from `check-ostree.yaml` used by RHEL Edge scripts, as it's tailored for Fedora IoT-specific configurations and features.

---

## Summary: Fedora IoT Scripts

The Fedora IoT test scripts represent a **download-and-test** approach that complements the **build-and-test** approach of RHEL Edge scripts. They leverage Koji's pre-built images to provide fast, reliable testing of official Fedora IoT releases, with special focus on:

1. **Container-based workflows** (bootc-image-builder)
2. **Zero-touch provisioning** (FDO)
3. **Official image validation** (testing what users receive)
4. **Rapid iteration** (testing multiple compose versions)

The use of **bootc-image-builder** in `iot-bootc-image.sh` is particularly important as it tests the emerging bootc ecosystem, which treats operating systems as container images and enables container-based OS management - a key innovation for edge and IoT deployments.


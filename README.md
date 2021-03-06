# Vagrant base box templates

Packer templates for building Vagrant base boxes and publishing them to [Vagrant Cloud](https://vagrantcloud.com/).

## Description

All boxes are configured as follows:

* 48 GiB sparse expandable virtual disk
* Second virtual disk for swap (except for `libvirt` boxes)
* Minimal package set
* Default installation settings wherever possible
* Paravirtualized device drivers where available
* Guest add-ons where available
* Customized according to [Vagrant guidelines](https://www.vagrantup.com/docs/boxes/base.html)

## Boxes

| Name             | Distribution                                |
| ---------------- | ------------------------------------------- |
| `archlinux-32`   | Arch Linux (i686)                           |
| `archlinux-64`   | Arch Linux (x86_64)                         |
| `centos6-32`     | CentOS Linux 6 (i386)                       |
| `centos6-64`     | CentOS Linux 6 (x86_64)                     |
| `centos7`        | CentOS Linux 7 (x86_64)                     |
| `debian7-32`     | Debian 7 (wheezy) (i386)                    |
| `debian7-64`     | Debian 7 (wheezy) (amd64)                   |
| `debian8-32`     | Debian 8 (jessie) (i386)                    |
| `debian8-64`     | Debian 8 (jessie) (amd64)                   |
| `debian9-32`     | Debian 9 (stretch) (i386)                   |
| `debian9-64`     | Debian 9 (stretch) (amd64)                  |
| `fedora24-32`    | Fedora 24 (i386)                            |
| `fedora24-64`    | Fedora 24 (x86_64)                          |
| `fedora25-32`    | Fedora 25 (i386)                            |
| `fedora25-64`    | Fedora 25 (x86_64)                          |
| `ubuntu14.04-32` | Ubuntu 14.04 LTS (Trusty Tahr) (i386)       |
| `ubuntu14.04-64` | Ubuntu 14.04 LTS (Trusty Tahr) (amd64)      |
| `ubuntu16.04-32` | Ubuntu 16.04 LTS (Xenial Xerus) (i386)      |
| `ubuntu16.04-64` | Ubuntu 16.04 LTS (Xenial Xerus) (amd64)     |
| `ubuntu17.04-32` | Ubuntu 17.04 (Zesty Zapus) (i386)           |
| `ubuntu17.04-64` | Ubuntu 17.04 (Zesty Zapus) (amd64)          |

## Providers

The following Vagrant providers are supported:

* `parallels`
* `libvirt`
* `virtualbox`
* `vmware_desktop` (also known as `vmware_fusion` and `vmware_workstation`)

## Requirements

* [GNU Make](https://www.gnu.org/software/make/)

* [Packer](http://packer.io/)

* [Vagrant](http://vagrantup.com/): If the build environment is not Linux (e.g. macOS), `libvirt` builds will be done in an Ubuntu
  Linux VM controlled by Vagrant. The `parallels` or `vmware_desktop` provider is required for this as VirtualBox does not support
  nested virtualization for 64-bit guests.

* [jq](https://stedolan.github.io/jq/)

* Hypervisors

  * [Parallels Desktop for Mac](http://www.parallels.com/products/desktop/) with
    [Parallels Virtualization SDK](http://www.parallels.com/uk/products/desktop/download/)
  * [VirtualBox](https://www.virtualbox.org/)
  * [VMware Fusion](http://www.vmware.com/products/fusion/), [VMware Workstation Player](https://www.vmware.com/products/player/) or
    [VMware Workstation Pro](http://www.vmware.com/products/workstation/)

* [Vagrant Cloud](https://vagrantcloud.com/) account. Note that the box "release" action can be performed during upload only once
  for a given box version. Any repetition (i.e. when a different provider is uploaded for the same box version) will result in an
  error. To avoid this, the box version will be released only during the libvirt provider upload.

* `vars.json` file containing configuration variables as described below

## Configuration

### Packer Variables

| Name                          | Description                                        |
| ----------------------------- | -------------------------------------------------- |
| `vagrantcloud_username`       | Vagrant Cloud username or organization name        |
| `vagrantcloud_token`          | Vagrant Cloud API token                            |
| `open_vm_tools_version`       | String to be included in Vagrant Cloud description |
| `parallels_tools_version`     | String to be included in Vagrant Cloud description |
| `virtualbox_additions_version`| String to be included in Vagrant Cloud description |
| `vmware_tools_version`        | String to be included in Vagrant Cloud description |

### Example

```json
{
    "open_vm_tools_version": "10.1.5",
    "parallels_tools_version": "12.2.0",
    "vagrantcloud_token": "ABCDEFGHIJKLMN.atlasv1.OPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRS",
    "vagrantcloud_username": "username",
    "virtualbox_additions_version": "5.1.22",
    "vmware_tools_version": "10.1.7"
}
```

## Usage Examples

```sh
$ make ubuntu16.10-32-parallels
$ make HEADLESS=false fedora24-64
$ make debian8-virtualbox
$ make centos7
$ make libvirt
$ make all
```

# Setting up a single node vSphere instance and installing a Tanzu Community Edition (TCE) management and workload cluster on it.

This script assumes an installed ESXi instance running on my NUC.
I'm using the following IP Addresses on my home network. You will need to modify the local files accordingly.

My Router Gateway is 192.168.8.1 and my DHCP Range is 192.168.8.10-192.168.8.99. I'm using Static IP Addresses for the major components which should be outside this range.

- Gateway - 192.168.8.1
- ESXi - 192.168.8.100
- VCSA - 192.168.8.105
- Management Cluster Control Plane Endpoint - 192.168.8.8
- Workload Cluster 1 Control Plane Endpoint - 192.168.8.7

## Install vSphere

#### Setup

1. The scripts default to using `VMware!` as the password for both ESXi and vSphere. If you wish to change it, you can do so manually or set environment variables and run `./update-tce-json.sh`.
1. Download the VCSA installer. [official docs](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vcenter.install.doc/GUID-11468F6F-0D8C-41B1-82C9-29284630A4FF.html)
1. Mount the Installer ISO the default `DiskImageMounter`
1. This mounts it as `/Volumes/VMware VCSA`
1. There is an issue on MacBooks with running this so you'll need to remove the quarantine. Plus, the mounted volume is read-only so first you'll need to copy the contents to another directory and then run the command.
   1. `cp -R /Volumes/VMware\ VCSA/* ~/software/VMware-VCSA` (In my case, `~/software/VMware-VCSA` already existed)
   1. Run `sudo xattr -r -d com.apple.quarantine ~/software/VMware-VCSA` to allow running this command on you Mac. See [this](https://williamlam.com/2020/02/how-to-exclude-vcsa-ui-cli-installer-from-macos-catalina-security-gatekeeper.html) for more information.
1. cd into the cli installer directory for macos
1. `cd ~/software/VMware-VCSA/vcsa-cli-installer/mac/`


#### Run the installer

1. Excute the VCSA CLI Installer with the following (Change the path to the tce.tanzu.local.json file as necessary)
1. `./vcsa-deploy install -v --accept-eula --no-ssl-certificate-verification ~/Documents/GitHub/pksheldon4/tce-on-vsphere-homelab/tce.tanzu.local.json`
1. This will run for about 20-30 minutes.


## Setup vSphere for Tanzu Community Edition

This step requires Powershell available on your mac with the VMware PowerCLI installed (See comments in setup_vcsa_tce.ps1)

1. cd into this repository (Change the path as necessary)
1. `cd ~/Documents/GitHub/pksheldon4/tce-on-vsphere-homelab`
1. run `pwsh` to get a Powershell prompt
1. run the setup `./setup_vcsa_tce.ps1`
1. This script will attach the ESXi host to the vsphere instance and setup resources to be used by TCE.
1. If this is your first time running the VMware PowerCLI, you will need to install it by running these commands inside pwsh.
   ```Powershell
   Install-Module VMware.PowerCLI -Scope CurrentUser
   Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore
   ```

## Prepare to Deploy Tanzu Community Edition on vSphere

Follow the instructions under the `Procedure` section of the TCE/vsphere docs - https://tanzucommunityedition.io/docs/latest/vsphere/

Specifically:

1. Download the photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova file.
1. Generate an SSH Key pair


### Create Management Cluster

1. Run `tanzu management-cluster create -ui`. This will open your default browser. Select vSphere.
1. Follow the Prompts filling in each of the sections. (There are several sections you can leave blank.)
1. When this is completed, it should have updated your ~/.kube/config file to include the management cluster.
1. Switch to the management cluster and you can run commands like `kubectl get nodes -o wide` to see your management nodes. `kubectl get apps -A` will show you the kapp apps that are running.


### Create Workload Cluster

1. Copy the management cluster yaml into the homelab directory `p /Users/psheldon/.config/tanzu/tkg/clusterconfigs/1hlwoz0yw4.yaml management.yaml`
1. Open the `management.yaml` and `workload-cluster.yaml` files side-by-side and copy the following 3 fields from `management.yaml` into `workload-cluster.yaml`.

```yml
VSPHERE_SSH_AUTHORIZED_KEY:
VSPHERE_PASSWORD:
VSPHERE_TLS_THUMBPRINT:
```

1. Create the workload cluster by running `tanzu cluster create workload-1 --file workload-cluster.yaml` (Takes about 10 minutes)
1. Run `tanzu cluster kubeconfig get workload-1 --admin` to add the workload kubeconfig to `~/.kube`
1. You can now switch to that cluser and perform `kubeconfig` commands as needed.

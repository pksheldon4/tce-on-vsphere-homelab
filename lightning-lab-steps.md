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

1. Set the VCSA_PWD and ESXI_PWD environment variables (`I'm using .envrc and direnv` to set environment)
1. Run `./update-tce-template.sh` to generate the `tce.tanzu.local.json` file with passwords. Depending on your Esx
1. Download the VCSA installer. (Change the below command as necessary to point to the ISO file)
1. Mount the Installer ISO the default `DiskImageMounter`
1. This mounts it as `/Volumes/VMware VCSA`
1. There is an issue on Macs with running this so you'll need to remove the quarantine. The mounted volume is read-only so first you'll need to copy the contents to another directory and then run the command.
   1. `cp -R /Volumes/VMware\ VCSA/* ~/software/VMware-VCSA` (In my case, `~/software/VMware-VCSA` already exists)
   1. Run `sudo xattr -r -d com.apple.quarantine ~/software/VMware-VCSA` to allow running this command on you Mac. See [this](https://williamlam.com/2020/02/how-to-exclude-vcsa-ui-cli-installer-from-macos-catalina-security-gatekeeper.html) for more information.
1. cd into the cli installer directory for macos
1. `cd ~/software/VMware-VCSA/vcsa-cli-installer/mac/`

#### Run the installer

1. Excute the VCSA CLI Installer with the following (Change the path to the tce.tanzu.local.json file as necessary)
1. `./vcsa-deploy install -v --accept-eula --no-ssl-certificate-verification ~/Documents/GitHub/pksheldon4/vsphere-tce-homelab/tce.tanzu.local.json`
1. This will run for about 20-30 minutes.

## Setup vSphere for Tanzu Community Edition

This step requires Powershell available on your mac with the VMware PowerCLI installed (See comments in setup_vcsa_tce.ps1)

1. cd into this repository (Change the path as necessary)
1. `cd ~/Documents/GitHub/pksheldon4/vsphere-tce-homelab`
1. run `pwsh` to get a Powershell prompt
1. run the setup `./setup_vcsa_tce.ps1`
1. This script will attach the ESXi host to the vsphere instance and setup resources to be used by TCE.

## Prepare to Deploy Tanzu Community Edition on vSphere
Follow the instructions under the `Procedure` section. https://tanzucommunityedition.io/docs/latest/vsphere/ 

### Create Management Cluster
1. run `tanzu management-cluster create -ui`
1. Follow the Prompts filling in each of the sections. (There are several sections you can leave blank.)
1. When this is completed, it should have updated your ~/.kube/config file to include the management cluster.
1. Switch to the management cluster and you can run commands like `kubectl get nodes -o wide` to see your management nodes. `kubectl get apps -A` will show you the kapp apps that are running.

 ### Create Workload Cluster
1. copy the management cluster yaml into the homelab directory `p /Users/psheldon/.config/tanzu/tkg/clusterconfigs/1hlwoz0yw4.yaml management.yaml`
1. open the `management.yaml` and `workload-cluster.yaml` files side-by-side and copy the following 3 fields from `management.yaml` into `workload-cluster.yaml`.
```yml
    VSPHERE_SSH_AUTHORIZED_KEY: 
    VSPHERE_PASSWORD:
    VSPHERE_TLS_THUMBPRINT:
```
1. Create the workload cluster by running `tanzu cluster create workload-1 --file workload-cluster.yaml` (Takes about 10 minutes)
1. Run `tanzu cluster kubeconfig get workload-1 --admin` to add the workload kubeconfig to `~/.kube`
1. You can now switch to that cluser and perform `kubeconfig` commands as needed.
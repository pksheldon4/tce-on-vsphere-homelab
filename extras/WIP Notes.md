*** WIP Notes ***

Installing Tanzu Community Edition on vSphere using a single host 

NOTE: My router gateway is on `192.168.8.1` and I install Esxi on a NUC using a static IP of 192.168.8.100.  vSphere gets installed on a static IP of 192.168.8.105

1. Download the  Esxi image - [VMware vSphere Hypervisor (ESXi ISO) image](https://customerconnect.vmware.com/en/web/vmware/evalcenter?p=free-esxi7&src=vmw_so_vex_dbori_1255)

Create a bootable USB Drive. Here are directions with Rufus, I used balenaEtcher
https://www.virten.net/2014/12/howto-create-a-bootable-esxi-installer-usb-flash-drive/

1. Boot Intel NUC using Drive. Best if there's no internet connection
1. Agree to everything and install. Then remove drive and reboot.
1. Configure networking to use a static IP Address, and router information.


Set environment variable `VCSA_PWD` to the password to use for vSphere and `ESXI_PWD` to the password you used when you setup ESXI.
1. Run the `./update-tce-json.sh` script to replace `VMware!` in the tce.tanzu.local.json file used to setup vsphere.



***Install tanzu on your bootstrap machine. Either a Mac or linux is easiest. Must have Docker installed and running.
https://tanzucommunityedition.io/download/
https://tanzucommunityedition.io/docs/latest/cli-installation/

Deploy vSphere
1. Download VMware-VCSA-all-7.0.3-18700403.iso and mount it. 
    1. On a mac, double click the ISO will mount it as `/Volumes/VMware VCSA` 
    1. On linux, you can run `sudo mount -o loop /home/psheldon/Downloads/VMware-VCSA-all-7.0.3-18700403.iso /mnt/VCSA/`
1. CD to `(mount path from previous)/vcsa-cli-installer/mac` (or `/lin64` if running on linux)
1. Execute the following command `./vcsa-deploy install -v --accept-eula --no-ssl-certificate-verification [Path to this repo on local machine]/tce.tanzu.local.json` (Runs for 10-20 minutes)
1. Open Powershell (pwsh) and run `./setup_vcsa_tce.ps1`

The above steps should satisfy the `Befor you Begin` section, but follow the `Procedure` section of this document.
https://tanzucommunityedition.io/docs/latest/vsphere/

Next, move on to https://tanzucommunityedition.io/docs/latest/vsphere-install-mgmt/ 
**TL;DR.**
If running on a local machine, open a terminal and run `tanzu management-cluster create -ui` Your browser should open. If running on a vm or a machine using ssh, run `tanzu management-cluster create --ui --bind 192.168.8.101:8080 --browser none` where the ip address is the IP of that machine. You can then open that ip/port in a local browser to perform the install.

After the Management Cluster is up, copy the `~/.config/tanzu/tkg/clusterconfigs/xxxxx.yaml` file that's generated for creating the Management Cluster and update the following fields in `workload-cluster.yaml`
```yaml
VSPHERE_SSH_AUTHORIZED_KEY: 
VSPHERE_PASSWORD: 
VSPHERE_TLS_THUMBPRINT:  
```
Note: The `workload-cluster.template` contains the full set of possible values, but they're not important for this exercise.

The create the workload cluster using this file `tanzu cluster create workload-1 -f workload-cluster.yaml` 
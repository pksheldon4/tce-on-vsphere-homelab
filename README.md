### This Repository contains scripts and configuration for Installing a single-node vSphere VCSA and Tanzu Community Edition

My Homelab setup includes (Cost on amazon 2021/11/01) $889.96

1. Intel NUC 10 Performance Kit – Intel Core i5 Processor (Tall Chassis) $549.99
1. Crucial 32GB Single DDR4 2666 MT/S CL19 SODIMM 260-Pin Memory - CT32G4SFD8266 (x2) $129.99ea $259.98
1. Samsung 970 EVO Plus SSD 500GB - M.2 NVMe Interface Internal Solid State Drive with V-NAND Technology (MZ-V7S500B/AM) $79.99

Note: You will need a usb keyboard for the initial ESXi installation but not after that.

I try and follow William Lam's [blog](https://williamlam.com) regularly even though much of it goes over my head. When Tanzu Community Edition was released, I really wanted to be able to install it on my homelab and hoped he would release something. After some trial and error trying to decide which pieces of his previous [post](https://williamlam.com/2020/11/complete-vsphere-with-tanzu-homelab-with-just-32gb-of-memory.html) were relevant, I found his new post on installing vcsa without dns and ntp (link above) and realized I could greatly simplify the entire process.

This repo is a result of that effort, as well as some more learnings on the vSphere CLI to script the creation of folders for organizing TCE.

For the Tanzu Community Edition (TCE) install pieces, I followed the official documentation. https://tanzucommunityedition.io/docs/latest/vsphere-intro/

The step by step guide to using this repo is broken out [here](lightning-lab-steps.md).

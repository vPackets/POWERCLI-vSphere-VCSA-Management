# ANSIBLE-vSphere-VCSA-OVA-Deploy


## Using Powershell to automatically deploy a VDS on a vSphere 7.0 vCenter automatically
by Nicolas MICHEL [@vpackets](https://twitter.com/vpackets) / [LinkedIn](https://www.linkedin.com/in/mclnicolas/) / [Blog](http://vpackets.net/) 

_**This disclaimer informs readers that the views, thoughts, and opinions expressed in this series of posts belong solely to the author, and not necessarily to the author’s employer, organization, committee or other group or individual.**_

### Introduction ###

I had a need to automate my NSX-T lab deployment. I could have used a single tool to perform all the relevant task but I wanted to learn and will use multiple scripts and tools.
_*This particular repository uses Powershell and Powercli. This is my first time using Powercli and Powershell hence the code is ugly and I just wanted to learn all the syntax that the code was expecting.*_

The goal is to create a vds on 3 hosts that are part of multiple cluster (management and compute).

In a later release, I will optimize the code in a much better way and introduce loops.


### Prerequisites ###

I have used [my own docker container](https://hub.docker.com/repository/docker/vpackets/tools) - ([Source code](https://github.com/vPackets/DOCKER-Tools))  to run this particular repository.
It contains all the libraries and software I need to accomplish my day to day job.

I am using Powershell version 7.0.3 with Powercli automatically installed by pwsh during the container creation.


### Version Used ###

```
Ubuntu Version :        18.04.3 LTS 
Powershell:             7.0.3
VCSA OVA:               7.0.0.10300-16189094

PS /home/nmichel/code/ANSIBLE-NSXT-Deploy> Get-Module -Name VMware.* | Select-Object -Property Name,Version       

Name                          Version
----                          -------
VMware.Vim                    7.0.0.15939650
VMware.VimAutomation.Cis.Core 12.0.0.15939657
VMware.VimAutomation.Common   12.0.0.15939652
VMware.VimAutomation.Core     12.0.0.15939655
VMware.VimAutomation.Sdk      12.0.0.15939651
VMware.VimAutomation.Vds      12.0.0.15940185

```


### Software Requirements #

none



### Code architecture ###

```
|-- README.md
|-- assign_dvuplink.ps1
`-- vds_creation.ps1
```

I wanted to have something flexible so that I could test a single playbook without impacting the code on other playbooks.
Deploy.yml is the main playbook to run. It will call each playbooks in order.

```
- import_playbook: playbooks/00-deploy-vcsa.yml
- import_playbook: playbooks/01-basic-config-vcsa.yml
- import_playbook: playbooks/02-add-hosts.yml
- import_playbook: playbooks/03-storage.yml
```


#### Code Execution ####

Open vds_creation.ps1 and execute the commands 


#### TO DO ####

    - General code improvement ... Current code not suitable for production - Used as a learning tool only
    - Loops, Variable definition .... 
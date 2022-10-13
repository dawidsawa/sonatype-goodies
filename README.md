# sonatype-goodies
Helper scripts for Sonatype Nexus Repository Manager

## [nxrm-container-latest.sh](nxrm-container-latest.sh)
### **How to run?**
`sh nxrm-container-latest.sh`

### **What does it do?**
It will find (or create) container running Sonatype Nexus Repository Manager and make sure it runs the latest available version. It will try to preserve the data between updates or will set it up a volume, so the data will be preserved on the next script execution. It will run Nexus on port 1234 by default or whatever port it was previously running.

You can put your own config customsation in nexus.properties in this directory as that file will be attached to the container.

If you plan to use Docker repositories with port connectors you will have to edit the script file to expose the port which you plan to use for the HTTP(S) connector.
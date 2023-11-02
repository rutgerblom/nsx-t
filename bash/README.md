# import_activate_certificate.sh
A bash script that imports and activates a TLS certificate for the NSX Manger API/UI.

## Preparations
On an Ubuntu 22.04 machine: 

* ```sudo apt update && sudo apt install git curl jq```
* ```git clone https://github.com/rutgerblom/nsx-t.git ~/git/nsx-t```
* ```chmod +x ~/git/nsx-t/bash/import_activate_certificate.sh```
* Place the signed certificate (chain) and its key in a directory on the Ubuntu machine

Modify the values for ```NSX_MANAGER```, ```NSX_USER```, ```NSX_PASSWORD```, ```CERTIFICATE_CHAIN```, ```PRIVATE_KEY```, and ```CERTIFICATE_NSX_DISPLAY_NAME``` in the ```f~/git/nsx-t/bash/import_activate_certificate.sh``` file so that these match your environment.

## Usage
Run ```~/git/nsx-t/bash/import_activate_certificate.sh```. The script will use the NSX REST API to import the TLS certificate and then apply it to the NSX Manager nodes and VIP. 


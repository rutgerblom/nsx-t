# import_activate_certificate.sh
A bash script that imports and applies a signed API/UI TLS certificate on NSX Manager.

## Preparations
Using an Ubuntu 22.04 machine: 

* ```sudo apt update && sudo apt install git curl jq```
* ```git clone https://github.com/rutgerblom/nsx-t.git ~/git/nsx-t```
* ```chmod +x ~/git/nsx-t/bash/import_activate_certificate.sh```
* Place the signed certificate (chain) and its key in a directory on the Ubuntu machine

Edit ```~/git/nsx-t/bash/import_activate_certificate.sh``` and update the values for the below variables so that these match your environment:
* ```NSX_MANAGER``` 
* ```NSX_USER```
* ```NSX_PASSWORD```
* ```CERTIFICATE_CHAIN```
* ```PRIVATE_KEY```
* ```CERTIFICATE_NSX_DISPLAY_NAME```

## Usage
After configuring the proper values for the variables mentioned above, run ```~/git/nsx-t/bash/import_activate_certificate.sh```. 
The script will use the NSX REST API to import the TLS certificate and then apply it to the NSX Manager nodes and VIP. 


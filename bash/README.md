# import_apply_certificate.sh
A bash script that imports and applies a signed TLS certificate for the NSX Manager API/UI.

## Preparations
Using an Ubuntu 22.04 machine: 

* ```sudo apt update && sudo apt install git curl jq```
* ```git clone https://github.com/rutgerblom/nsx-t.git ~/git/nsx-t```
* ```chmod +x ~/git/nsx-t/bash/import_apply_certificate.sh```
* Place the signed certificate (chain) and its key in a directory on the Ubuntu machine

Edit ```~/git/nsx-t/bash/import_apply_certificate.sh``` and update the values for the below variables so that these match your environment:
* ```NSX_MANAGER``` 
* ```NSX_USER```
* ```NSX_PASSWORD```
* ```CERTIFICATE_CHAIN```
* ```PRIVATE_KEY```
* ```CERTIFICATE_NSX_DISPLAY_NAME```

## Usage
After configuring the proper values for the variables listed above you simply run ```~/git/nsx-t/bash/import_apply_certificate.sh```. 
The script will leverage the NSX REST API to import the TLS certificate and then apply it to the NSX Manager nodes and VIP. 

## Example workflow using easy-rsa CA
1. Prepare an OpenSSL .cnf file. An example .cnf file can be found [here](nsx_oslo.cnf).
2. Create a private key: ```openssl genrsa -out /tmp/pod-240-nsxt-lm.key 2048```
3. Create a certificate signing request (CSR): ```openssl req -new -nodes -out /tmp/pod-240-nsxt-lm.csr -keyout /tmp/pod-240-nsxt-lm.key -config ./nsx_oslo.cnf```
4. Import the certificate signing request to easy-rsa: ```ea /tmp/pod-240-nsxt-lm.csr pod-240-nsxt-lm``` (FYI "ea" is an alias that I defined for the command ```/usr/share/easy-rsa/easyrsa --vars=/home/vmware/easy-rsa/vars```)
5. Sign the request: ```ea sign-req server pod-240-nsxt-lm```
6. Copy the certificate ```cat /home/vmware/easy-rsa/pki/issued/pod-240-nsxt-lm.crt | sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' > /tmp/pod-240-nsxt-lm.crt```
7. Append the root certificate to the file: ```cat /home/vmware/easy-rsa/pki/ca.crt >> /tmp/pod-240-nsxt-lm.crt```
8. Update the variables in ```~/git/nsx-t/bash/import_apply_certificate.sh``` so that they match your environment and requirements.
9. Run ```~/git/nsx-t/bash/import_apply_certificate.sh``` to import and apply the TLS certificate to NSX Manager


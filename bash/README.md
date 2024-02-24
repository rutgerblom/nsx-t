# import_apply_certificate.sh
A bash script that imports and applies a CA signed TLS certificate for the NSX Manager API/UI.

## Preparations
Using an Ubuntu 22.04 machine: 

* ```sudo apt update && sudo apt install git curl jq```
* ```git clone https://github.com/rutgerblom/nsx-t.git ~/git/nsx-t```
* ```chmod +x ~/git/nsx-t/bash/import_apply_certificate.sh```
* Copy the certificate (chain) and its key to a working directory on the Ubuntu machine

Export variables with the values that are relevant for your environment. For example:
```export NSX_MANAGER="Pod-240-NSXT-LM.SDDC.Lab"``` 
```export NSX_USER="admin"```
```export NSX_PASSWORD="VMware1!VMware1!"```
```export NSX_CERTIFICATE_CHAIN="/tmp/pod-240-nsxt-lm.crt"```
```export NSX_CERTIFICATE_PRIVATE_KEY="/tmp/pod-240-nsxt-lm.key"```
```export NSX_CERTIFICATE_DISPLAY_NAME="Pod-240-NSXT-LM"```

## Usage
After the preparations are completed you simply run: ```~/git/nsx-t/bash/import_apply_certificate.sh```. 
The script will leverage the NSX REST API to import the TLS certificate and then apply it to the NSX Manager nodes and the VIP. 

### Example workflow using easy-rsa CA
1. Prepare an OpenSSL .cnf file. An example .cnf file can be found [here](nsx.cnf).
2. Create a private key: ```openssl genrsa -out /tmp/pod-240-nsxt-lm.key 2048```.
3. Create a certificate signing request (CSR): ```openssl req -new -nodes -out /tmp/pod-240-nsxt-lm.csr -keyout /tmp/pod-240-nsxt-lm.key -config ./nsx.cnf```.
4. Import the certificate signing request to easy-rsa: ```ea import-req /tmp/pod-240-nsxt-lm.csr pod-240-nsxt-lm``` (FYI "ea" is an alias that I defined for the command ```/usr/share/easy-rsa/easyrsa --vars=/home/vmware/easy-rsa/vars```).
5. Sign the request: ```ea sign-req server pod-240-nsxt-lm```.
6. Copy the certificate to a working directory: ```cat /home/vmware/easy-rsa/pki/issued/pod-240-nsxt-lm.crt | sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' > /tmp/pod-240-nsxt-lm.crt```.
7. Append the root certificate to the certificate in the working directory: ```cat /home/vmware/easy-rsa/pki/ca.crt >> /tmp/pod-240-nsxt-lm.crt```.
8. Export variables with the correcy values .
9. Run ```~/git/nsx-t/bash/import_apply_certificate.sh``` to import and apply the TLS certificate to NSX Manager.
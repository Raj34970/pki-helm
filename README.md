

# First isntallation generate certs

```shell
# 1. Generate the Root CA private key
openssl genrsa -out ca.key 4096

# 2. Generate the self-signed Root CA certificate
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt -subj "/CN=Lxhome Root CA/O=Lxhome/C=FR"

cat ca.crt | base64 | tr -d '\n'

cat ca.key | base64 | tr -d '\n'

```

# First isntallation generate certs

```shell
# Then run the HELM
helm install lxhome-pki ./pki
```

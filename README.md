

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

```shell
helm push lxhome-pki-*.tgz oci://harbor.lxhome.fr/lxhome
```

## Have to install Github-cli into the control-plane node
```shell
apt-get update && apt-get install -y curl
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list >/dev/null
apt-get update && apt-get install -y gh
```

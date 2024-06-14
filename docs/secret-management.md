# Preqs

- Make sure you have the kubeseal CLI tool installed.

### documentation

[Usage](https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#usage)

# Creating a new secret

```sh
# Create a json/yaml-encoded Secret somehow:
# (note use of `--dry-run` - this is just a local file!)
kubectl create secret generic mysecret --dry-run=client --from-literal=key1=supersecret -o yaml > mysecret.yaml

# This is the important bit:
kubeseal -f mysecret.yaml -w secret.yaml

# Eventually:
kubectl create -f secret.yaml

# Profit!
kubectl get secret mysecret
```

# Managing existing secrets

If you want the Sealed Secrets controller to manage an existing Secret, you can annotate your Secret with the:

`sealedsecrets.bitnami.com/managed: "true"` annotation.

The existing Secret will be overwritten when unsealing a SealedSecret with the same name and namespace, and the SealedSecret will take ownership of the Secret

(so that when the SealedSecret is deleted the Secret will also be deleted).

# Patching existing secrets

There are some use cases in which you don't want to replace the whole Secret but just add or modify some keys from the existing Secret.

For this, you can annotate your Secret with `sealedsecrets.bitnami.com/patch: "true"`.

Using this annotation will make sure that secret keys, labels and annotations in the Secret that are not present in the SealedSecret won't be deleted, and those present in the SealedSecret will be added to the Secret (secret keys, labels and annotations that exist both in the Secret and the SealedSecret will be modified by the SealedSecret).

This annotation does not make the SealedSecret take ownership of the Secret. You can add both the patch and managed annotations to obtain the patching behavior while also taking ownership of the Secret.

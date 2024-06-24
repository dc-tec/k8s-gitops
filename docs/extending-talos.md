# Boot Assets

In order to extend Talos with system extensions we can create a custom boot iamge using the Talos Image Factory.

For example to use Longhorn within the cluster Talos needs to be extended with the following system extensions:

- iscsi-tools
- util-linux-tools

To be able to upgrade our running Talos cluster with the new system extensions we can do the following

- Create a new schema which includes our new extensions:

```yaml
customization:
  systemExtensions:
    officialExtensions:
      - siderolabs/iscsi-tools
      - siderolabs/util-linux-tools
```

- Upload the schematic to the Talos Image Factory:
  `curl -X POST --data-binary @longhorn.yaml https://factory.talos.dev/schematics`

We will receive an Id which we can use in the next step to upgrade Talos
`{"id":"b8e8fbbe1b520989e6c52c8dc8303070cb42095997e76e812fa8892393e1d176"}`

- Upgrade the cluster nodes:
  `talosctl upgrade --image factory.talos.dev/installed/<schema id>:v1.7.4 --nodes $NODE`

- Run the upgrade command on each node in the cluster (or the nodes where the extension(s) need to be installed.

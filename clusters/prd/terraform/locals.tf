locals {
  machine_config = {
    machine = {
      features = {
        kubePrism = {
          enabled = true
          port    = 7445
        }
      }
      kernel = {
        modules = [
          {
            name       = "drdb"
            parameters = ["usermode_helper=disabled"]
          },
          {
            name = "drdb_transport_tcp"
          }
        ]
      }
    }
    cluster = {
      discovery = {
        enabled = true
        registries = {
          kubernetes = {
            disabled = false
          }
          service = {
            disabled = true
          }
        }
      }
      network = {
        cni = {
          name = "none"
        }
      }
      proxy = {
        disabled = true
      }
    }
  }
  cilium_helm_manifest_template = [
    {
      apiVersion = "cilium.io/v2alpha1"
      kind       = "CiliumL2AnnouncementPolicy"
      metadata = {
        name = "external"
      }
      spec = {
        LoadBalancerIPs = true
        interfaces = [
          "eth0",
        ]
        nodeSelector = {
          matchExpressions = [
            {
              key      = "node-role.kubernetes.io/control-plane"
              operator = "DoesNotExist"
            }
          ]
        }
      }
    },
    {
      apiVersion = "cilium.io/v2alpha1"
      kind       = "CiliumLoadBalancerIPPool"
      metadata = {
        name = "external"
      }
      spec = {
        blocks = [
          {
            start = cidrhost(var.cluster_network, 100)
            end   = cidrhost(var.cluster_network, 150)
          }
        ]
      }
    }
  ]
  cilium_helm_manifest = join("---\n", [for manifest in local.cilium_helm_manifest_template : yamlencode(manifest)])
}

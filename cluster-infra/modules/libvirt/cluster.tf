resource "talos_machine_secrets" "main" {
  depends_on    = [libvirt_domain.control_node]
  talos_version = var.talso_version
}

data "talos_machine_configuration" "control_node" {
  depends_on         = [libvirt_domain.control_node]
  cluster_name       = "${var.cluster_env}-${var.cluster_name}"
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.main.machine_secrets
  machine_type       = "controlplane"
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  examples           = false
  docs               = false

  config_patches = [
    yamlencode(local.machine_config),
    yamlencode({
      machine = {
        network = {
          interfaces = [
            {
              interface = "eth0"
              dhcp      = true
              vip = {
                ip = var.cluster_vip
              }
            }
          ]
          nameservers = ["1.1.1.1", "1.0.0.1"]
        }
      }
    }),
    yamlencode({
      cluster = {
        inlineManifests = [
          {
            name = "cilium"
            contents = join("---\n", [
              data.helm_template.cilium.manifest,
              local.cilium_helm_manifest,
            ])
          },
        ]
      }
    }),
    yamlencode({
      machine = {
        features = {
          kubernetesTalosAPIAccess = {
            enabled = true
            allowedRoles = [
              "os:etcd:backup",
            ]
            allowedKubernetesNamespaces = [
              "default",
            ]
          }
        }
      }
    }),
  ]
}

data "talos_machine_configuration" "worker_node" {
  depends_on = [libvirt_domain.worker_node]

  cluster_name       = "${var.cluster_env}-${var.cluster_name}"
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.main.machine_secrets
  machine_type       = "worker"
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  examples           = false
  docs               = false

  config_patches = [
    yamlencode(local.machine_config),
  ]
}

resource "talos_machine_configuration_apply" "control_node" {
  depends_on = [libvirt_domain.control_node]
  for_each   = var.control_nodes

  client_configuration        = talos_machine_secrets.main.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_node.machine_configuration
  endpoint                    = libvirt_domain.control_node[each.key].network_interface[0].addresses[0]
  node                        = libvirt_domain.control_node[each.key].network_interface[0].addresses[0]

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.value.node_name
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "worker_node" {
  depends_on = [libvirt_domain.worker_node]
  for_each   = var.worker_nodes

  client_configuration        = talos_machine_secrets.main.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker_node.machine_configuration
  endpoint                    = libvirt_domain.worker_node[each.key].network_interface[0].addresses[0]
  node                        = libvirt_domain.worker_node[each.key].network_interface[0].addresses[0]

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname    = each.value.node_name
          nameservers = ["1.1.1.1", "1.0.0.1"]
        }
        kubelet = {
          extraMounts = [{
            destination = "/var/lib/longhorn"
            type        = "bind"
            source      = "/var/lib/longhorn"
            options     = ["bind", "rw", "rshared"]
          }]
        }
        disks = [{
          device = "/dev/sdb"
          partitions = [{
            mountpoint = "/var/lib/longhorn"
          }]
        }]
      }
    })
  ]
}

resource "talos_machine_bootstrap" "main" {
  depends_on = [talos_machine_configuration_apply.control_node]

  client_configuration = talos_machine_secrets.main.client_configuration
  endpoint             = libvirt_domain.control_node["control_01"].network_interface[0].addresses[0]
  node                 = libvirt_domain.control_node["control_01"].network_interface[0].addresses[0]
}

resource "talos_cluster_kubeconfig" "main" {
  depends_on = [talos_machine_bootstrap.main]

  client_configuration = talos_machine_secrets.main.client_configuration
  endpoint             = libvirt_domain.control_node["control_01"].network_interface[0].addresses[0]
  node                 = libvirt_domain.control_node["control_01"].network_interface[0].addresses[0]
}

data "talos_client_configuration" "main" {
  depends_on = [talos_machine_bootstrap.main]

  cluster_name         = "${var.cluster_env}-${var.cluster_name}"
  client_configuration = talos_machine_secrets.main.client_configuration
  endpoints            = [for key in keys(var.control_nodes) : libvirt_domain.control_node[key].network_interface[0].addresses[0]]
}

data "helm_template" "cilium" {
  depends_on = [libvirt_domain.control_node]

  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.15.10"
  namespace  = "kube-system"


  api_versions = [
    "gateway.networking.k8s.io/v1beta1/GatewayClass"
  ]

  set {
    name  = "ipam.mode"
    value = "kubernetes"
  }
  set {
    name  = "securityContext.capabilities.ciliumAgent"
    value = "{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
  }
  set {
    name  = "securityContext.capabilities.cleanCiliumState"
    value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
  }
  set {
    name  = "cgroup.autoMount.enabled"
    value = "false"
  }
  set {
    name  = "cgroup.hostRoot"
    value = "/sys/fs/cgroup"
  }
  set {
    name  = "k8sServiceHost"
    value = "localhost"
  }
  set {
    name  = "k8sServicePort"
    value = local.machine_config.machine.features.kubePrism.port
  }
  set {
    name  = "kubeProxyReplacement"
    value = "true"
  }
  set {
    name  = "l2announcements.enabled"
    value = "true"
  }
  set {
    name  = "devices"
    value = "{eth0}"
  }
  set {
    name  = "ingressController.enabled"
    value = "true"
  }
  set {
    name  = "ingressController.default"
    value = "true"
  }
  set {
    name  = "ingressController.loadbalancerMode"
    value = "shared"
  }
  set {
    name  = "ingressController.enforceHttps"
    value = "false"
  }
  set {
    name  = "envoy.enabled"
    value = "true"
  }
  set {
    name  = "hubble.relay.enabled"
    value = "true"
  }
  set {
    name  = "hubble.ui.enabled"
    value = "true"
  }
  set {
    name  = "gatewayAPI.enabled"
    value = "true"
  }
  set {
    name  = "nodePort.enabled"
    value = "true"
  }
  set {
    name  = "loadBalancer.l7.backend"
    value = "envoy"
  }
}

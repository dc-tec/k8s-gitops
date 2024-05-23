resource "talos_machine_secrets" "main" {
  talos_version = var.talso_version
}

data "talos_machine_configuration" "control_node" {
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
    })
  ]
}

data "talos_machine_configuration" "worker_node" {
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
  endpoint                    = each.value.ip_address
  node                        = each.value.ip_address

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
  endpoint                    = each.value.ip_address
  node                        = each.value.ip_address

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

resource "talos_machine_bootstrap" "main" {
  depends_on = [talos_machine_configuration_apply.control_node]

  client_configuration = talos_machine_secrets.main.client_configuration
  endpoint             = var.control_nodes["control_01"].ip_address
  node                 = var.control_nodes["control_01"].ip_address
}

data "talos_cluster_kubeconfig" "main" {
  depends_on = [talos_machine_bootstrap.main]

  client_configuration = talos_machine_secrets.main.client_configuration
  endpoint             = var.control_nodes["control_01"].ip_address
  node                 = var.control_nodes["control_01"].ip_address
}

data "talos_client_configuration" "main" {
  depends_on = [talos_machine_bootstrap.main]

  cluster_name         = "${var.cluster_env}-${var.cluster_name}"
  client_configuration = talos_machine_secrets.main.client_configuration
  endpoints            = [for node in var.control_nodes : node.ip_address]
}

data "helm_template" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.15.5"
  namespace  = "kube-system"

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
}

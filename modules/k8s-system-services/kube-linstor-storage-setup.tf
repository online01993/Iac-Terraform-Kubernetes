#kube-linstor-storage-setup.tf
#Genirate Linstor/Piraeus storage
resource "kubernetes_labels" "kubernetes_labels_linstor_satellite" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel,
    kubernetes_cluster_role.flannel,
    kubernetes_cluster_role_binding.flannel,
    kubernetes_config_map.kube_flannel_cfg,
    kubernetes_daemonset.kube_flannel_ds
  ]
  for_each = { for i in var.nodes : i.id => i 
    if 
        i.storage.ssd.present || i.storage.nvme.present || i.storage.hdd.present
  }
  field_manager = "TerraformLabels_linstor-satellite"
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = each.value.netbios
  }
  labels = {
    "node-role.kubernetes.io/linstor-satellite" = ""
  }
}

resource "kubernetes_labels" "kubernetes_labels_linstor_satellite-ssd_storage" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel,
    kubernetes_cluster_role.flannel,
    kubernetes_cluster_role_binding.flannel,
    kubernetes_config_map.kube_flannel_cfg,
    kubernetes_daemonset.kube_flannel_ds
  ]
  for_each = { for i in var.nodes : i.id => i if i.storage.ssd.present }
  field_manager = "TerraformLabels_linstor-satellite-storage-ssd"
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = each.value.netbios
  }
  labels = {
    "linstor-satellite-storage-ssd" = ""
  }
}

resource "kubernetes_labels" "kubernetes_labels_linstor_satellite-nvme_storage" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel,
    kubernetes_cluster_role.flannel,
    kubernetes_cluster_role_binding.flannel,
    kubernetes_config_map.kube_flannel_cfg,
    kubernetes_daemonset.kube_flannel_ds
  ]
  for_each = { for i in var.nodes : i.id => i if i.storage.nvme.present }
  field_manager = "TerraformLabels_linstor-satellite-storage-nvme"
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = each.value.netbios
  }
  labels = {
    "linstor-satellite-storage-nvme" = ""
  }
}

resource "kubernetes_labels" "kubernetes_labels_linstor_satellite-hdd_storage" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel,
    kubernetes_cluster_role.flannel,
    kubernetes_cluster_role_binding.flannel,
    kubernetes_config_map.kube_flannel_cfg,
    kubernetes_daemonset.kube_flannel_ds
  ]
  for_each = { for i in var.nodes : i.id => i if i.storage.hdd.present }
  field_manager = "TerraformLabels_linstor-satellite-storage-hdd"
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = each.value.netbios
  }
  labels = {
    "linstor-satellite-storage-hdd" = ""
  }
}

resource "kubectl_manifest" "LinstorCluster_piraeus_datastore" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_config_map.piraeus_operator_image_config,
    kubernetes_service.piraeus_operator_webhook_service,
    kubernetes_validating_webhook_configuration.piraeus_operator_validating_webhook_configuration,
    kubernetes_deployment.piraeus_operator_controller_manager,
    kubernetes_deployment.piraeus_operator_gencert,
    kubernetes_labels.kubernetes_labels_linstor_satellite
    #kubectl_manifest.piraeus_operator_gencert
  ]
  server_side_apply = true
  wait = true
  yaml_body = <<YAML
apiVersion: piraeus.io/v1
kind: LinstorCluster
metadata:
  name: linstorcluster
  namespace: piraeus-datastore
spec:
  nodeSelector:
    node-role.kubernetes.io/linstor-satellite: ""
  patches:
    - target:
        kind: Deployment
        name: linstor-controller
      patch: |
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: linstor-controller
        spec:
          template:
            spec:
              nodeSelector:
                node-role.kubernetes.io/control-plane: ""
              tolerations:
                - key: node-role.kubernetes.io/control-plane
                  effect: NoSchedule
    - target:
        kind: Deployment
        name: linstor-csi-controller 
      patch: |
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: linstor-csi-controller 
        spec:
          template:
            spec:
              nodeSelector:
                node-role.kubernetes.io/control-plane: ""
              tolerations:
                - key: node-role.kubernetes.io/control-plane
                  effect: NoSchedule
    - target:
        kind: DaemonSet
        name: ha-controller  
      patch: |
        apiVersion: apps/v1
        kind: DaemonSet
        metadata:
          name: ha-controller  
        spec:
          template:
            spec:
              affinity:
                nodeAffinity:
                  requiredDuringSchedulingIgnoredDuringExecution:
                    nodeSelectorTerms:
                      - matchExpressions:
                        - key: node-role.kubernetes.io/control-plane
                          operator: DoesNotExist
    - target:
        kind: DaemonSet
        name: linstor-csi-node
      patch: |
        apiVersion: apps/v1
        kind: DaemonSet
        metadata:
          name: linstor-csi-node  
        spec:
          template:
            spec:
              affinity:
                nodeAffinity:
                  requiredDuringSchedulingIgnoredDuringExecution:
                    nodeSelectorTerms:
                      - matchExpressions:
                        - key: node-role.kubernetes.io/control-plane
                          operator: DoesNotExist
YAML
}

resource "kubectl_manifest" "LinstorNodeConnection_piraeus_datastore" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_config_map.piraeus_operator_image_config,
    kubernetes_service.piraeus_operator_webhook_service,
    kubernetes_validating_webhook_configuration.piraeus_operator_validating_webhook_configuration,
    kubernetes_deployment.piraeus_operator_controller_manager,
    kubernetes_deployment.piraeus_operator_gencert,
    kubectl_manifest.LinstorCluster_piraeus_datastore,
    kubernetes_labels.kubernetes_labels_linstor_satellite
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.LinstorCluster_piraeus_datastore.uid
    ]
  }
  server_side_apply = true
  wait = true
  yaml_body = <<YAML
apiVersion: piraeus.io/v1
kind: LinstorNodeConnection
metadata:
  name: linstornodeconnection
  namespace: piraeus-datastore
spec:
  selector:
    - matchLabels:
        - key: node-role.kubernetes.io/control-plane
          op: DoesNotExist
        - key: node-role.kubernetes.io/linstor-satellite
          op: Exists
        - key: topology.kubernetes.io/region
          op: Same
        - key: topology.kubernetes.io/zone
          op: Same  
YAML
}

resource "kubectl_manifest" "LinstorSatelliteConfiguration_piraeus_datastore_ssd" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_config_map.piraeus_operator_image_config,
    kubernetes_service.piraeus_operator_webhook_service,
    kubernetes_validating_webhook_configuration.piraeus_operator_validating_webhook_configuration,
    kubernetes_deployment.piraeus_operator_controller_manager,
    kubernetes_deployment.piraeus_operator_gencert,
    kubectl_manifest.LinstorCluster_piraeus_datastore,
    kubernetes_labels.kubernetes_labels_linstor_satellite,
    kubectl_manifest.LinstorNodeConnection_piraeus_datastore
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.LinstorCluster_piraeus_datastore.uid
    ]
  }
  for_each = { for i in var.nodes : i.id => i if i.storage.ssd.present }
  server_side_apply = true
  wait = true
  yaml_body = var.ssd_k8s_stor_pool_type == "thin" ? <<YAML
apiVersion: piraeus.io/v1
kind: LinstorSatelliteConfiguration
metadata:
  name: linstorsatelliteconfiguration-${each.value.netbios}-ssd
  namespace: piraeus-datastore
spec:
  nodeSelector:
    kubernetes.io/hostname: "${each.value.netbios}"
  storagePools:
     - name: ${var.ssd_k8s_stor_pool_type}-${var.ssd_k8s_stor_pool_type}-${var.ssd_k8s_stor_pool_name}-ssd-pool
       lvmThinPool: 
         volumeGroup: vg-${var.ssd_k8s_stor_pool_type}-${var.ssd_k8s_stor_pool_type}-${var.ssd_k8s_stor_pool_name}-ssd-pool
         thinPool: ${var.ssd_k8s_stor_pool_type}
       source:
         hostDevices:
         - ${each.value.storage.ssd.hostPath}
YAML
: <<YAML
apiVersion: piraeus.io/v1
kind: LinstorSatelliteConfiguration
metadata:
  name: linstorsatelliteconfiguration-${each.value.netbios}-ssd
  namespace: piraeus-datastore
spec:
  nodeSelector:
    kubernetes.io/hostname: "${each.value.netbios}"
  storagePools:
     - name: thin-ssd-pool
       lvmThinPool: 
         volumeGroup: vg-thin-ssd-pool
         thinPool: thin
       source:
         hostDevices:
         - ${each.value.storage.ssd.hostPath}
YAML
}

resource "kubectl_manifest" "LinstorSatelliteConfiguration_piraeus_datastore_nvme" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_config_map.piraeus_operator_image_config,
    kubernetes_service.piraeus_operator_webhook_service,
    kubernetes_validating_webhook_configuration.piraeus_operator_validating_webhook_configuration,
    kubernetes_deployment.piraeus_operator_controller_manager,
    kubernetes_deployment.piraeus_operator_gencert,
    kubectl_manifest.LinstorCluster_piraeus_datastore,
    kubernetes_labels.kubernetes_labels_linstor_satellite,
    kubectl_manifest.LinstorNodeConnection_piraeus_datastore
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.LinstorCluster_piraeus_datastore.uid
    ]
  }
  for_each = { for i in var.nodes : i.id => i if i.storage.nvme.present }
  server_side_apply = true
  wait = true
  yaml_body = <<YAML
apiVersion: piraeus.io/v1
kind: LinstorSatelliteConfiguration
metadata:
  name: linstorsatelliteconfiguration-${each.value.netbios}-nvme
  namespace: piraeus-datastore
spec:
  nodeSelector:
    kubernetes.io/hostname: "${each.value.netbios}"
  storagePools:
     - name: thin-nvme-pool
       lvmThinPool: 
         volumeGroup: vg-thin-nvme-pool
         thinPool: thin
       source:
         hostDevices:
         - ${each.value.storage.nvme.hostPath}
YAML
}

resource "kubectl_manifest" "LinstorSatelliteConfiguration_piraeus_datastore_hdd" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_config_map.piraeus_operator_image_config,
    kubernetes_service.piraeus_operator_webhook_service,
    kubernetes_validating_webhook_configuration.piraeus_operator_validating_webhook_configuration,
    kubernetes_deployment.piraeus_operator_controller_manager,
    kubernetes_deployment.piraeus_operator_gencert,
    kubectl_manifest.LinstorCluster_piraeus_datastore,
    kubernetes_labels.kubernetes_labels_linstor_satellite,
    kubectl_manifest.LinstorNodeConnection_piraeus_datastore
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.LinstorCluster_piraeus_datastore.uid
    ]
  }
  for_each = { for i in var.nodes : i.id => i if i.storage.hdd.present }
  server_side_apply = true
  wait = true
  yaml_body = <<YAML
apiVersion: piraeus.io/v1
kind: LinstorSatelliteConfiguration
metadata:
  name: linstorsatelliteconfiguration-${each.value.netbios}-hdd
  namespace: piraeus-datastore
spec:
  nodeSelector:
    kubernetes.io/hostname: "${each.value.netbios}"
  storagePools:
     - name: thin-hdd-pool
       lvmThinPool: 
         volumeGroup: vg-thin-hdd-pool
         thinPool: thin
       source:
         hostDevices:
         - ${each.value.storage.hdd.hostPath}
YAML
}

resource "kubernetes_storage_class" "storage_class_ssd_storage_replicated" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_config_map.piraeus_operator_image_config,
    kubernetes_service.piraeus_operator_webhook_service,
    kubernetes_validating_webhook_configuration.piraeus_operator_validating_webhook_configuration,
    kubernetes_deployment.piraeus_operator_controller_manager,
    kubernetes_deployment.piraeus_operator_gencert,
    kubectl_manifest.LinstorCluster_piraeus_datastore,
    kubernetes_labels.kubernetes_labels_linstor_satellite,
    kubectl_manifest.LinstorNodeConnection_piraeus_datastore,
    kubectl_manifest.LinstorSatelliteConfiguration_piraeus_datastore_hdd
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.LinstorCluster_piraeus_datastore.uid,
      kubectl_manifest.LinstorSatelliteConfiguration_piraeus_datastore_hdd
    ]
  }
  count = length([for i in var.nodes: i if i.storage.ssd.present]) > 0 ? 1 : 0
  metadata {
    name = "storage-class-${var.ssd_k8s_stor_pool_type}-${var.ssd_k8s_stor_pool_name}-ssd-storage-replicated"
  }
  parameters = {
    "linstor.csi.linbit.com/placementCount" = "${length([for i in var.nodes: i if i.storage.ssd.present])}"
    "linstor.csi.linbit.com/storagePool" = "${var.ssd_k8s_stor_pool_type}-${var.ssd_k8s_stor_pool_name}-ssd-pool"
    "DrbdOptions/Net/max-buffers"        =  "10000"
  }
  storage_provisioner    = "linstor.csi.linbit.com"
  allow_volume_expansion = true
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
}

resource "kubernetes_storage_class" "storage_class_nvme_storage_replicated" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_config_map.piraeus_operator_image_config,
    kubernetes_service.piraeus_operator_webhook_service,
    kubernetes_validating_webhook_configuration.piraeus_operator_validating_webhook_configuration,
    kubernetes_deployment.piraeus_operator_controller_manager,
    kubernetes_deployment.piraeus_operator_gencert,
    kubectl_manifest.LinstorCluster_piraeus_datastore,
    kubernetes_labels.kubernetes_labels_linstor_satellite,
    kubectl_manifest.LinstorNodeConnection_piraeus_datastore,
    kubectl_manifest.LinstorSatelliteConfiguration_piraeus_datastore_hdd
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.LinstorCluster_piraeus_datastore.uid,
      kubectl_manifest.LinstorSatelliteConfiguration_piraeus_datastore_hdd
    ]
  }
  count = length([for i in var.nodes: i if i.storage.nvme.present]) > 0 ? 1 : 0
  metadata {
    name = "storage-class-${var.nvme_k8s_stor_pool_type}-${var.nvme_k8s_stor_pool_name}-nvme-storage-replicated"
  }
  parameters = {
    "linstor.csi.linbit.com/placementCount" = "${length([for i in var.nodes: i if i.storage.nvme.present])}"
    "linstor.csi.linbit.com/storagePool" = "${var.nvme_k8s_stor_pool_type}-${var.nvme_k8s_stor_pool_name}-nvme-pool"
    "DrbdOptions/Net/max-buffers"        =  "10000"
  }
  storage_provisioner    = "linstor.csi.linbit.com"
  allow_volume_expansion = true
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
}

resource "kubernetes_storage_class" "storage_class_hdd_storage_replicated" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_config_map.piraeus_operator_image_config,
    kubernetes_service.piraeus_operator_webhook_service,
    kubernetes_validating_webhook_configuration.piraeus_operator_validating_webhook_configuration,
    kubernetes_deployment.piraeus_operator_controller_manager,
    kubernetes_deployment.piraeus_operator_gencert,
    kubectl_manifest.LinstorCluster_piraeus_datastore,
    kubernetes_labels.kubernetes_labels_linstor_satellite,
    kubectl_manifest.LinstorNodeConnection_piraeus_datastore,
    kubectl_manifest.LinstorSatelliteConfiguration_piraeus_datastore_hdd
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.LinstorCluster_piraeus_datastore.uid,
      kubectl_manifest.LinstorSatelliteConfiguration_piraeus_datastore_hdd
    ]
  }
  count = length([for i in var.nodes: i if i.storage.hdd.present]) > 0 ? 1 : 0
  metadata {
    name = "storage-class-${var.hdd_k8s_stor_pool_type}-${var.hdd_k8s_stor_pool_name}-hdd-storage-replicated"
  }
  parameters = {
    "linstor.csi.linbit.com/placementCount" = "${length([for i in var.nodes: i if i.storage.hdd.present])}"
    "linstor.csi.linbit.com/storagePool" = "${var.hdd_k8s_stor_pool_type}-${var.hdd_k8s_stor_pool_name}-hdd-pool"
    "DrbdOptions/Net/max-buffers"        =  "10000"
  }
  storage_provisioner    = "linstor.csi.linbit.com"
  allow_volume_expansion = true
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
}
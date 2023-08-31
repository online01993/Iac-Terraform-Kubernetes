# #main.tf
# #Genirate Linstor storege
# resource "kubectl_manifest" "LinstorSatellite_each_nodes_piraeus_datastore" {
#   depends_on = [
#     kubernetes_namespace.piraeus_datastore,
#     kubectl_manifest.CRD_linstorclusters_piraeus_io,
#     kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
#     kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
#     kubectl_manifest.CRD_linstorsatellites_piraeus_io,
#     kubernetes_config_map.piraeus_operator_image_config,
#     kubernetes_service.piraeus_operator_webhook_service,
#     kubernetes_validating_webhook_configuration.piraeus_operator_validating_webhook_configuration,
#     kubernetes_deployment.piraeus_operator_controller_manager,
#     kubernetes_deployment.piraeus_operator_gencert,
#     kubectl_manifest.LinstorCluster_piraeus_datastore,
#     kubernetes_labels.kubernetes_labels_linstor_satellite,
#     kubectl_manifest.LinstorNodeConnection_piraeus_datastore,
#     kubectl_manifest.LinstorSatelliteConfiguration_piraeus_datastore
#   ]
#   for_each = { for i in var.nodes : i.id => i }
#   server_side_apply = true
#   force_conflicts = true
#   wait = true
#   yaml_body = <<YAML
# apiVersion: piraeus.io/v1
# kind: LinstorSatellite
# metadata:
#   name: ${each.value.netbios}
#   namespace: piraeus-datastore
# spec:
#   clusterRef: 
#     name: linstorcluster
#   storagePools:
#     - name: thinpool
#       lvmThinPool: {}
#       source:
#         hostDevices:
#           - /dev/xvdb
# YAML
# }

# resource "kubectl_manifest" "StorageClass_drbd_storage_piraeus_datastore" {
#   depends_on = [
#     kubernetes_namespace.piraeus_datastore,
#     kubectl_manifest.CRD_linstorclusters_piraeus_io,
#     kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
#     kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
#     kubectl_manifest.CRD_linstorsatellites_piraeus_io,
#     kubernetes_config_map.piraeus_operator_image_config,
#     kubernetes_service.piraeus_operator_webhook_service,
#     kubernetes_validating_webhook_configuration.piraeus_operator_validating_webhook_configuration,
#     kubernetes_deployment.piraeus_operator_controller_manager,
#     kubernetes_deployment.piraeus_operator_gencert,
#     kubectl_manifest.LinstorCluster_piraeus_datastore,
#     kubernetes_labels.kubernetes_labels_linstor_satellite,
#     kubectl_manifest.LinstorNodeConnection_piraeus_datastore,
#     kubectl_manifest.LinstorSatelliteConfiguration_piraeus_datastore
#   ]
#   server_side_apply = true
#   wait = true
#   #force_conflicts = true
#   yaml_body = <<YAML
# apiVersion: storage.k8s.io/v1
# kind: StorageClass
# metadata:
#   name: piraeus-storage-replicated
# provisioner: linstor.csi.linbit.com
# allowVolumeExpansion: true
# volumeBindingMode: WaitForFirstConsumer
# parameters:
#   linstor.csi.linbit.com/storagePool: "thinpool"
#   linstor.csi.linbit.com/placementCount: "${length(var.nodes)}"
# YAML
# }

# resource "kubectl_manifest" "PersistentVolumeClaim_drbd_storage_piraeus_datastore" {
#   depends_on = [
#     kubernetes_namespace.piraeus_datastore,
#     kubectl_manifest.CRD_linstorclusters_piraeus_io,
#     kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
#     kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
#     kubectl_manifest.CRD_linstorsatellites_piraeus_io,
#     kubernetes_config_map.piraeus_operator_image_config,
#     kubernetes_service.piraeus_operator_webhook_service,
#     kubernetes_validating_webhook_configuration.piraeus_operator_validating_webhook_configuration,
#     kubernetes_deployment.piraeus_operator_controller_manager,
#     kubernetes_deployment.piraeus_operator_gencert,
#     kubectl_manifest.LinstorCluster_piraeus_datastore,
#     kubernetes_labels.kubernetes_labels_linstor_satellite,
#     kubectl_manifest.LinstorNodeConnection_piraeus_datastore,
#     kubectl_manifest.LinstorSatelliteConfiguration_piraeus_datastore,
#     kubectl_manifest.StorageClass_drbd_storage_piraeus_datastore
#   ]
#   server_side_apply = true
#   yaml_body = <<YAML
# apiVersion: v1
# kind: PersistentVolumeClaim
# metadata:
#   name: replicated-volume
# spec:
#   storageClassName: piraeus-storage-replicated
#   resources:
#     requests:
#       storage: 1Gi
#   accessModes:
#     - ReadWriteOnce
# YAML
# }
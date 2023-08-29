#kube-linstor-piraeus-operator.tf
#https://github.com/piraeusdatastore/piraeus-operator/blob/debian-11/doc/README.md
#kubectl kustomize "https://github.com/piraeusdatastore/piraeus-operator//config/default?ref=v2" > kube-linstor-piraeus-operator.yaml

resource "kubernetes_namespace" "piraeus_datastore" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel,
    kubernetes_cluster_role.flannel,
    kubernetes_cluster_role_binding.flannel,
    kubernetes_config_map.kube_flannel_cfg,
    kubernetes_daemonset.kube_flannel_ds
  ]
  metadata {
    name = "piraeus-datastore"
    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/enforce-version" = "latest"
    }
  }
}

resource "kubectl_manifest" "CRD_linstorclusters_piraeus_io" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore
  ]
  server_side_apply = true
  yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.12.0
  labels:
    app.kubernetes.io/name: piraeus-datastore
  name: linstorclusters.piraeus.io
spec:
  group: piraeus.io
  names:
    kind: LinstorCluster
    listKind: LinstorClusterList
    plural: linstorclusters
    singular: linstorcluster
  scope: Cluster
  versions:
  - name: v1
    schema:
      openAPIV3Schema:
        description: LinstorCluster is the Schema for the linstorclusters API
        properties:
          apiVersion:
            description: 'APIVersion defines the versioned schema of this representation
              of an object. Servers should convert recognized schemas to the latest
              internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
            type: string
          kind:
            description: 'Kind is a string value representing the REST resource this
              object represents. Servers may infer this from the endpoint the client
              submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
            type: string
          metadata:
            type: object
          spec:
            description: LinstorClusterSpec defines the desired state of LinstorCluster
            properties:
              apiTLS:
                description: "ApiTLS secures the LINSTOR API. \n This configures the
                  TLS key and certificate used to secure the LINSTOR API."
                nullable: true
                properties:
                  apiSecretName:
                    description: ApiSecretName references a secret holding the TLS
                      key and certificate used to protect the API. Defaults to "linstor-api-tls".
                    type: string
                  certManager:
                    description: CertManager references a cert-manager Issuer or ClusterIssuer.
                      If set, cert-manager.io/Certificate resources will be created,
                      provisioning the secrets referenced in *SecretName using the
                      issuer configured here.
                    properties:
                      group:
                        description: Group of the resource being referred to.
                        type: string
                      kind:
                        description: Kind of the resource being referred to.
                        type: string
                      name:
                        description: Name of the resource being referred to.
                        type: string
                    required:
                    - name
                    type: object
                  clientSecretName:
                    description: ClientSecretName references a secret holding the
                      TLS key and certificate used by the operator to configure the
                      cluster. Defaults to "linstor-client-tls".
                    type: string
                  csiControllerSecretName:
                    description: CsiControllerSecretName references a secret holding
                      the TLS key and certificate used by the CSI Controller to provision
                      volumes. Defaults to "linstor-csi-controller-tls".
                    type: string
                  csiNodeSecretName:
                    description: CsiNodeSecretName references a secret holding the
                      TLS key and certificate used by the CSI Nodes to query the volume
                      state. Defaults to "linstor-csi-node-tls".
                    type: string
                type: object
              externalController:
                description: ExternalController references an external controller.
                  When set, the Operator will skip deploying a LINSTOR Controller
                  and instead use the external cluster to register satellites.
                properties:
                  url:
                    description: URL of the external controller.
                    minLength: 3
                    type: string
                required:
                - url
                type: object
              internalTLS:
                description: "InternalTLS secures the connection between LINSTOR Controller
                  and Satellite. \n This configures the client certificate used when
                  the Controller connects to a Satellite. This only has an effect
                  when the Satellite is configured to for secure connections using
                  `LinstorSatellite.spec.internalTLS`."
                nullable: true
                properties:
                  certManager:
                    description: CertManager references a cert-manager Issuer or ClusterIssuer.
                      If set, a Certificate resource will be created, provisioning
                      the secret references in SecretName using the issuer configured
                      here.
                    properties:
                      group:
                        description: Group of the resource being referred to.
                        type: string
                      kind:
                        description: Kind of the resource being referred to.
                        type: string
                      name:
                        description: Name of the resource being referred to.
                        type: string
                    required:
                    - name
                    type: object
                  secretName:
                    description: SecretName references a secret holding the TLS key
                      and certificates.
                    type: string
                type: object
              linstorPassphraseSecret:
                description: "LinstorPassphraseSecret used to configure the LINSTOR
                  master passphrase. \n The referenced secret must contain a single
                  key \"MASTER_PASSPHRASE\". The master passphrase is used to * Derive
                  encryption keys for volumes using the LUKS layer. * Store credentials
                  for accessing remotes for backups. See https://linbit.com/drbd-user-guide/linstor-guide-1_0-en/#s-encrypt_commands
                  for more information."
                type: string
              nodeSelector:
                additionalProperties:
                  type: string
                description: NodeSelector selects the nodes on which LINSTOR Satellites
                  will be deployed. See https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
                type: object
              patches:
                description: "Patches is a list of kustomize patches to apply. \n
                  See https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/patches/
                  for how to create patches."
                items:
                  description: Patch represent either a Strategic Merge Patch or a
                    JSON patch and its targets.
                  properties:
                    options:
                      additionalProperties:
                        type: boolean
                      description: Options is a list of options for the patch
                      type: object
                    patch:
                      description: Patch is the content of a patch.
                      minLength: 1
                      type: string
                    target:
                      description: Target points to the resources that the patch is
                        applied to
                      properties:
                        annotationSelector:
                          description: AnnotationSelector is a string that follows
                            the label selection expression https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#api
                            It matches against the resource annotations.
                          type: string
                        group:
                          type: string
                        kind:
                          type: string
                        labelSelector:
                          description: LabelSelector is a string that follows the
                            label selection expression https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#api
                            It matches against the resource labels.
                          type: string
                        name:
                          description: Name of the resource.
                          type: string
                        namespace:
                          description: Namespace the resource belongs to, if it can
                            belong to a namespace.
                          type: string
                        version:
                          type: string
                      type: object
                  type: object
                type: array
              properties:
                description: "Properties to apply on the cluster level. \n Use to
                  create default settings for DRBD that should apply to all resources
                  or to configure some other cluster wide default."
                items:
                  properties:
                    name:
                      description: Name of the property to set.
                      minLength: 1
                      type: string
                    value:
                      description: Value to set the property to.
                      type: string
                  required:
                  - name
                  type: object
                type: array
                x-kubernetes-list-map-keys:
                - name
                x-kubernetes-list-type: map
              repository:
                description: Repository used to pull workload images.
                type: string
            type: object
          status:
            description: LinstorClusterStatus defines the observed state of LinstorCluster
            properties:
              conditions:
                description: Current LINSTOR Cluster state
                items:
                  description: "Condition contains details for one aspect of the current
                    state of this API Resource. --- This struct is intended for direct
                    use as an array at the field path .status.conditions.  For example,
                    \n type FooStatus struct{ // Represents the observations of a
                    foo's current state. // Known .status.conditions.type are: \"Available\",
                    \"Progressing\", and \"Degraded\" // +patchMergeKey=type // +patchStrategy=merge
                    // +listType=map // +listMapKey=type Conditions []metav1.Condition
                    `json:\"conditions,omitempty\" patchStrategy:\"merge\" patchMergeKey:\"type\"
                    protobuf:\"bytes,1,rep,name=conditions\"` \n // other fields }"
                  properties:
                    lastTransitionTime:
                      description: lastTransitionTime is the last time the condition
                        transitioned from one status to another. This should be when
                        the underlying condition changed.  If that is not known, then
                        using the time when the API field changed is acceptable.
                      format: date-time
                      type: string
                    message:
                      description: message is a human readable message indicating
                        details about the transition. This may be an empty string.
                      maxLength: 32768
                      type: string
                    observedGeneration:
                      description: observedGeneration represents the .metadata.generation
                        that the condition was set based upon. For instance, if .metadata.generation
                        is currently 12, but the .status.conditions[x].observedGeneration
                        is 9, the condition is out of date with respect to the current
                        state of the instance.
                      format: int64
                      minimum: 0
                      type: integer
                    reason:
                      description: reason contains a programmatic identifier indicating
                        the reason for the condition's last transition. Producers
                        of specific condition types may define expected values and
                        meanings for this field, and whether the values are considered
                        a guaranteed API. The value should be a CamelCase string.
                        This field may not be empty.
                      maxLength: 1024
                      minLength: 1
                      pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                      type: string
                    status:
                      description: status of the condition, one of True, False, Unknown.
                      enum:
                      - "True"
                      - "False"
                      - Unknown
                      type: string
                    type:
                      description: type of condition in CamelCase or in foo.example.com/CamelCase.
                        --- Many .condition.type values are consistent across resources
                        like Available, but because arbitrary conditions can be useful
                        (see .node.status.conditions), the ability to deconflict is
                        important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
                      maxLength: 316
                      pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                      type: string
                  required:
                  - lastTransitionTime
                  - message
                  - reason
                  - status
                  - type
                  type: object
                type: array
                x-kubernetes-list-map-keys:
                - type
                x-kubernetes-list-type: map
            type: object
        type: object
    served: true
    storage: true
    subresources:
      status: {}
YAML
}

resource "kubectl_manifest" "CRD_linstornodeconnections_piraeus_io" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore
  ]
  server_side_apply = true
  yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.12.0
  labels:
    app.kubernetes.io/name: piraeus-datastore
  name: linstornodeconnections.piraeus.io
spec:
  group: piraeus.io
  names:
    kind: LinstorNodeConnection
    listKind: LinstorNodeConnectionList
    plural: linstornodeconnections
    singular: linstornodeconnection
  scope: Cluster
  versions:
  - name: v1
    schema:
      openAPIV3Schema:
        description: LinstorNodeConnection is the Schema for the linstornodeconnections
          API
        properties:
          apiVersion:
            description: 'APIVersion defines the versioned schema of this representation
              of an object. Servers should convert recognized schemas to the latest
              internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
            type: string
          kind:
            description: 'Kind is a string value representing the REST resource this
              object represents. Servers may infer this from the endpoint the client
              submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
            type: string
          metadata:
            type: object
          spec:
            description: LinstorNodeConnectionSpec defines the desired state of LinstorNodeConnection
            properties:
              paths:
                description: Paths configure the network path used when connecting
                  two nodes.
                items:
                  properties:
                    interface:
                      description: Interface to use on both nodes.
                      type: string
                    name:
                      description: Name of the path.
                      type: string
                  required:
                  - interface
                  - name
                  type: object
                type: array
                x-kubernetes-list-map-keys:
                - name
                x-kubernetes-list-type: map
              properties:
                description: "Properties to apply for the node connection. \n Use
                  to create default settings for DRBD that should apply to all resources
                  connections between a set of cluster nodes."
                items:
                  properties:
                    name:
                      description: Name of the property to set.
                      minLength: 1
                      type: string
                    value:
                      description: Value to set the property to.
                      type: string
                  required:
                  - name
                  type: object
                type: array
                x-kubernetes-list-map-keys:
                - name
                x-kubernetes-list-type: map
              selector:
                description: Selector selects which pair of Satellites the connection
                  should apply to. If not given, the connection will be applied to
                  all connections.
                items:
                  description: SelectorTerm matches pairs of nodes by checking that
                    the nodes match all specified requirements.
                  properties:
                    matchLabels:
                      description: MatchLabels is a list of match expressions that
                        the node pairs must meet.
                      items:
                        properties:
                          key:
                            description: Key is the name of a node label.
                            minLength: 1
                            type: string
                          op:
                            default: Exists
                            description: Op to apply to the label. Exists (default)
                              checks for the presence of the label on both nodes in
                              the pair. DoesNotExist checks that the label is not
                              present on either node in the pair. In checks for the
                              presence of the label value given by Values on both
                              nodes in the pair. NotIn checks that both nodes in the
                              pair do not have any of the label values given by Values.
                              Same checks that the label value is equal in the node
                              pair. NotSame checks that the label value is not equal
                              in the node pair.
                            enum:
                            - Exists
                            - DoesNotExist
                            - In
                            - NotIn
                            - Same
                            - NotSame
                            type: string
                          values:
                            description: Values to match on, using the provided Op.
                            items:
                              type: string
                            type: array
                        required:
                        - key
                        type: object
                      type: array
                  type: object
                type: array
            type: object
          status:
            description: LinstorNodeConnectionStatus defines the observed state of
              LinstorNodeConnection
            properties:
              conditions:
                description: Current LINSTOR Node Connection state
                items:
                  description: "Condition contains details for one aspect of the current
                    state of this API Resource. --- This struct is intended for direct
                    use as an array at the field path .status.conditions.  For example,
                    \n type FooStatus struct{ // Represents the observations of a
                    foo's current state. // Known .status.conditions.type are: \"Available\",
                    \"Progressing\", and \"Degraded\" // +patchMergeKey=type // +patchStrategy=merge
                    // +listType=map // +listMapKey=type Conditions []metav1.Condition
                    `json:\"conditions,omitempty\" patchStrategy:\"merge\" patchMergeKey:\"type\"
                    protobuf:\"bytes,1,rep,name=conditions\"` \n // other fields }"
                  properties:
                    lastTransitionTime:
                      description: lastTransitionTime is the last time the condition
                        transitioned from one status to another. This should be when
                        the underlying condition changed.  If that is not known, then
                        using the time when the API field changed is acceptable.
                      format: date-time
                      type: string
                    message:
                      description: message is a human readable message indicating
                        details about the transition. This may be an empty string.
                      maxLength: 32768
                      type: string
                    observedGeneration:
                      description: observedGeneration represents the .metadata.generation
                        that the condition was set based upon. For instance, if .metadata.generation
                        is currently 12, but the .status.conditions[x].observedGeneration
                        is 9, the condition is out of date with respect to the current
                        state of the instance.
                      format: int64
                      minimum: 0
                      type: integer
                    reason:
                      description: reason contains a programmatic identifier indicating
                        the reason for the condition's last transition. Producers
                        of specific condition types may define expected values and
                        meanings for this field, and whether the values are considered
                        a guaranteed API. The value should be a CamelCase string.
                        This field may not be empty.
                      maxLength: 1024
                      minLength: 1
                      pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                      type: string
                    status:
                      description: status of the condition, one of True, False, Unknown.
                      enum:
                      - "True"
                      - "False"
                      - Unknown
                      type: string
                    type:
                      description: type of condition in CamelCase or in foo.example.com/CamelCase.
                        --- Many .condition.type values are consistent across resources
                        like Available, but because arbitrary conditions can be useful
                        (see .node.status.conditions), the ability to deconflict is
                        important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
                      maxLength: 316
                      pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                      type: string
                  required:
                  - lastTransitionTime
                  - message
                  - reason
                  - status
                  - type
                  type: object
                type: array
                x-kubernetes-list-map-keys:
                - type
                x-kubernetes-list-type: map
            type: object
        type: object
    served: true
    storage: true
    subresources:
      status: {}
YAML
}

resource "kubectl_manifest" "CRD_linstorsatelliteconfigurations_piraeus_io" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore
  ]
  server_side_apply = true
  yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.12.0
  labels:
    app.kubernetes.io/name: piraeus-datastore
  name: linstorsatelliteconfigurations.piraeus.io
spec:
  group: piraeus.io
  names:
    kind: LinstorSatelliteConfiguration
    listKind: LinstorSatelliteConfigurationList
    plural: linstorsatelliteconfigurations
    singular: linstorsatelliteconfiguration
  scope: Cluster
  versions:
  - name: v1
    schema:
      openAPIV3Schema:
        description: LinstorSatelliteConfiguration is the Schema for the linstorsatelliteconfigurations
          API
        properties:
          apiVersion:
            description: 'APIVersion defines the versioned schema of this representation
              of an object. Servers should convert recognized schemas to the latest
              internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
            type: string
          kind:
            description: 'Kind is a string value representing the REST resource this
              object represents. Servers may infer this from the endpoint the client
              submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
            type: string
          metadata:
            type: object
          spec:
            description: "LinstorSatelliteConfigurationSpec defines a partial, desired
              state of a LinstorSatelliteSpec. \n All the LinstorSatelliteConfiguration
              resources with matching NodeSelector will be merged into a single LinstorSatelliteSpec."
            properties:
              internalTLS:
                description: "InternalTLS configures secure communication for the
                  LINSTOR Satellite. \n If set, the control traffic between LINSTOR
                  Controller and Satellite will be encrypted using mTLS."
                nullable: true
                properties:
                  certManager:
                    description: CertManager references a cert-manager Issuer or ClusterIssuer.
                      If set, a Certificate resource will be created, provisioning
                      the secret references in SecretName using the issuer configured
                      here.
                    properties:
                      group:
                        description: Group of the resource being referred to.
                        type: string
                      kind:
                        description: Kind of the resource being referred to.
                        type: string
                      name:
                        description: Name of the resource being referred to.
                        type: string
                    required:
                    - name
                    type: object
                  secretName:
                    description: SecretName references a secret holding the TLS key
                      and certificates.
                    type: string
                type: object
              nodeSelector:
                additionalProperties:
                  type: string
                description: NodeSelector selects which LinstorSatellite resources
                  this spec should be applied to. See https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
                type: object
              patches:
                description: "Patches is a list of kustomize patches to apply. \n
                  See https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/patches/
                  for how to create patches."
                items:
                  description: Patch represent either a Strategic Merge Patch or a
                    JSON patch and its targets.
                  properties:
                    options:
                      additionalProperties:
                        type: boolean
                      description: Options is a list of options for the patch
                      type: object
                    patch:
                      description: Patch is the content of a patch.
                      minLength: 1
                      type: string
                    target:
                      description: Target points to the resources that the patch is
                        applied to
                      properties:
                        annotationSelector:
                          description: AnnotationSelector is a string that follows
                            the label selection expression https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#api
                            It matches against the resource annotations.
                          type: string
                        group:
                          type: string
                        kind:
                          type: string
                        labelSelector:
                          description: LabelSelector is a string that follows the
                            label selection expression https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#api
                            It matches against the resource labels.
                          type: string
                        name:
                          description: Name of the resource.
                          type: string
                        namespace:
                          description: Namespace the resource belongs to, if it can
                            belong to a namespace.
                          type: string
                        version:
                          type: string
                      type: object
                  type: object
                type: array
              properties:
                description: Properties is a list of properties to set on the node.
                items:
                  properties:
                    name:
                      description: Name of the property to set.
                      minLength: 1
                      type: string
                    optional:
                      description: Optional values are only set if they have a non-empty
                        value
                      type: boolean
                    value:
                      description: Value to set the property to.
                      type: string
                    valueFrom:
                      description: ValueFrom sets the value from an existing resource.
                      properties:
                        nodeFieldRef:
                          description: Select a field of the node. Supports `metadata.name`,
                            `metadata.labels['<KEY>']`, `metadata.annotations['<KEY>']`.
                          minLength: 1
                          type: string
                      type: object
                  required:
                  - name
                  type: object
                type: array
                x-kubernetes-list-map-keys:
                - name
                x-kubernetes-list-type: map
              storagePools:
                description: StoragePools is a list of storage pools to configure
                  on the node.
                items:
                  properties:
                    filePool:
                      description: Configures a file system based storage pool, allocating
                        a regular file per volume.
                      properties:
                        directory:
                          description: Directory is the path to the host directory
                            used to store volume data.
                          type: string
                      type: object
                    fileThinPool:
                      description: Configures a file system based storage pool, allocating
                        a sparse file per volume.
                      properties:
                        directory:
                          description: Directory is the path to the host directory
                            used to store volume data.
                          type: string
                      type: object
                    lvmPool:
                      description: Configures a LVM Volume Group as storage pool.
                      properties:
                        volumeGroup:
                          type: string
                      type: object
                    lvmThinPool:
                      description: Configures a LVM Thin Pool as storage pool.
                      properties:
                        thinPool:
                          description: ThinPool is the name of the thinpool LV (without
                            VG prefix).
                          type: string
                        volumeGroup:
                          type: string
                      type: object
                    name:
                      description: Name of the storage pool in linstor.
                      minLength: 3
                      type: string
                    properties:
                      description: Properties to set on the storage pool.
                      items:
                        properties:
                          name:
                            description: Name of the property to set.
                            minLength: 1
                            type: string
                          optional:
                            description: Optional values are only set if they have
                              a non-empty value
                            type: boolean
                          value:
                            description: Value to set the property to.
                            type: string
                          valueFrom:
                            description: ValueFrom sets the value from an existing
                              resource.
                            properties:
                              nodeFieldRef:
                                description: Select a field of the node. Supports
                                  `metadata.name`, `metadata.labels['<KEY>']`, `metadata.annotations['<KEY>']`.
                                minLength: 1
                                type: string
                            type: object
                        required:
                        - name
                        type: object
                      type: array
                      x-kubernetes-list-map-keys:
                      - name
                      x-kubernetes-list-type: map
                    source:
                      properties:
                        hostDevices:
                          description: HostDevices is a list of device paths used
                            to configure the given pool.
                          items:
                            type: string
                          minItems: 1
                          type: array
                      type: object
                  required:
                  - name
                  type: object
                type: array
            type: object
          status:
            description: LinstorSatelliteConfigurationStatus defines the observed
              state of LinstorSatelliteConfiguration
            properties:
              conditions:
                description: Current LINSTOR Satellite Config state
                items:
                  description: "Condition contains details for one aspect of the current
                    state of this API Resource. --- This struct is intended for direct
                    use as an array at the field path .status.conditions.  For example,
                    \n type FooStatus struct{ // Represents the observations of a
                    foo's current state. // Known .status.conditions.type are: \"Available\",
                    \"Progressing\", and \"Degraded\" // +patchMergeKey=type // +patchStrategy=merge
                    // +listType=map // +listMapKey=type Conditions []metav1.Condition
                    `json:\"conditions,omitempty\" patchStrategy:\"merge\" patchMergeKey:\"type\"
                    protobuf:\"bytes,1,rep,name=conditions\"` \n // other fields }"
                  properties:
                    lastTransitionTime:
                      description: lastTransitionTime is the last time the condition
                        transitioned from one status to another. This should be when
                        the underlying condition changed.  If that is not known, then
                        using the time when the API field changed is acceptable.
                      format: date-time
                      type: string
                    message:
                      description: message is a human readable message indicating
                        details about the transition. This may be an empty string.
                      maxLength: 32768
                      type: string
                    observedGeneration:
                      description: observedGeneration represents the .metadata.generation
                        that the condition was set based upon. For instance, if .metadata.generation
                        is currently 12, but the .status.conditions[x].observedGeneration
                        is 9, the condition is out of date with respect to the current
                        state of the instance.
                      format: int64
                      minimum: 0
                      type: integer
                    reason:
                      description: reason contains a programmatic identifier indicating
                        the reason for the condition's last transition. Producers
                        of specific condition types may define expected values and
                        meanings for this field, and whether the values are considered
                        a guaranteed API. The value should be a CamelCase string.
                        This field may not be empty.
                      maxLength: 1024
                      minLength: 1
                      pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                      type: string
                    status:
                      description: status of the condition, one of True, False, Unknown.
                      enum:
                      - "True"
                      - "False"
                      - Unknown
                      type: string
                    type:
                      description: type of condition in CamelCase or in foo.example.com/CamelCase.
                        --- Many .condition.type values are consistent across resources
                        like Available, but because arbitrary conditions can be useful
                        (see .node.status.conditions), the ability to deconflict is
                        important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
                      maxLength: 316
                      pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                      type: string
                  required:
                  - lastTransitionTime
                  - message
                  - reason
                  - status
                  - type
                  type: object
                type: array
                x-kubernetes-list-map-keys:
                - type
                x-kubernetes-list-type: map
            type: object
        type: object
    served: true
    storage: true
    subresources:
      status: {}
YAML
}

resource "kubectl_manifest" "CRD_linstorsatellites_piraeus_io" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore
  ]
  server_side_apply = true
  yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.12.0
  labels:
    app.kubernetes.io/name: piraeus-datastore
  name: linstorsatellites.piraeus.io
spec:
  group: piraeus.io
  names:
    kind: LinstorSatellite
    listKind: LinstorSatelliteList
    plural: linstorsatellites
    singular: linstorsatellite
  scope: Cluster
  versions:
  - name: v1
    schema:
      openAPIV3Schema:
        description: LinstorSatellite is the Schema for the linstorsatellites API
        properties:
          apiVersion:
            description: 'APIVersion defines the versioned schema of this representation
              of an object. Servers should convert recognized schemas to the latest
              internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
            type: string
          kind:
            description: 'Kind is a string value representing the REST resource this
              object represents. Servers may infer this from the endpoint the client
              submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
            type: string
          metadata:
            type: object
          spec:
            description: LinstorSatelliteSpec defines the desired state of LinstorSatellite
            properties:
              clusterRef:
                description: ClusterRef references the LinstorCluster used to create
                  this LinstorSatellite.
                properties:
                  clientSecretName:
                    description: ClientSecretName references the secret used by the
                      operator to validate the https endpoint.
                    type: string
                  externalController:
                    description: ExternalController references an external controller.
                      When set, the Operator uses the external cluster to register
                      satellites.
                    properties:
                      url:
                        description: URL of the external controller.
                        minLength: 3
                        type: string
                    required:
                    - url
                    type: object
                  name:
                    description: Name of the LinstorCluster resource controlling this
                      satellite.
                    type: string
                type: object
              internalTLS:
                description: "InternalTLS configures secure communication for the
                  LINSTOR Satellite. \n If set, the control traffic between LINSTOR
                  Controller and Satellite will be encrypted using mTLS. The Controller
                  will use the client key from `LinstorCluster.spec.internalTLS` when
                  connecting."
                nullable: true
                properties:
                  certManager:
                    description: CertManager references a cert-manager Issuer or ClusterIssuer.
                      If set, a Certificate resource will be created, provisioning
                      the secret references in SecretName using the issuer configured
                      here.
                    properties:
                      group:
                        description: Group of the resource being referred to.
                        type: string
                      kind:
                        description: Kind of the resource being referred to.
                        type: string
                      name:
                        description: Name of the resource being referred to.
                        type: string
                    required:
                    - name
                    type: object
                  secretName:
                    description: SecretName references a secret holding the TLS key
                      and certificates.
                    type: string
                type: object
              patches:
                description: "Patches is a list of kustomize patches to apply. \n
                  See https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/patches/
                  for how to create patches."
                items:
                  description: Patch represent either a Strategic Merge Patch or a
                    JSON patch and its targets.
                  properties:
                    options:
                      additionalProperties:
                        type: boolean
                      description: Options is a list of options for the patch
                      type: object
                    patch:
                      description: Patch is the content of a patch.
                      minLength: 1
                      type: string
                    target:
                      description: Target points to the resources that the patch is
                        applied to
                      properties:
                        annotationSelector:
                          description: AnnotationSelector is a string that follows
                            the label selection expression https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#api
                            It matches against the resource annotations.
                          type: string
                        group:
                          type: string
                        kind:
                          type: string
                        labelSelector:
                          description: LabelSelector is a string that follows the
                            label selection expression https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#api
                            It matches against the resource labels.
                          type: string
                        name:
                          description: Name of the resource.
                          type: string
                        namespace:
                          description: Namespace the resource belongs to, if it can
                            belong to a namespace.
                          type: string
                        version:
                          type: string
                      type: object
                  type: object
                type: array
              properties:
                description: Properties is a list of properties to set on the node.
                items:
                  properties:
                    name:
                      description: Name of the property to set.
                      minLength: 1
                      type: string
                    optional:
                      description: Optional values are only set if they have a non-empty
                        value
                      type: boolean
                    value:
                      description: Value to set the property to.
                      type: string
                    valueFrom:
                      description: ValueFrom sets the value from an existing resource.
                      properties:
                        nodeFieldRef:
                          description: Select a field of the node. Supports `metadata.name`,
                            `metadata.labels['<KEY>']`, `metadata.annotations['<KEY>']`.
                          minLength: 1
                          type: string
                      type: object
                  required:
                  - name
                  type: object
                type: array
                x-kubernetes-list-map-keys:
                - name
                x-kubernetes-list-type: map
              repository:
                description: Repository used to pull workload images.
                type: string
              storagePools:
                description: StoragePools is a list of storage pools to configure
                  on the node.
                items:
                  properties:
                    filePool:
                      description: Configures a file system based storage pool, allocating
                        a regular file per volume.
                      properties:
                        directory:
                          description: Directory is the path to the host directory
                            used to store volume data.
                          type: string
                      type: object
                    fileThinPool:
                      description: Configures a file system based storage pool, allocating
                        a sparse file per volume.
                      properties:
                        directory:
                          description: Directory is the path to the host directory
                            used to store volume data.
                          type: string
                      type: object
                    lvmPool:
                      description: Configures a LVM Volume Group as storage pool.
                      properties:
                        volumeGroup:
                          type: string
                      type: object
                    lvmThinPool:
                      description: Configures a LVM Thin Pool as storage pool.
                      properties:
                        thinPool:
                          description: ThinPool is the name of the thinpool LV (without
                            VG prefix).
                          type: string
                        volumeGroup:
                          type: string
                      type: object
                    name:
                      description: Name of the storage pool in linstor.
                      minLength: 3
                      type: string
                    properties:
                      description: Properties to set on the storage pool.
                      items:
                        properties:
                          name:
                            description: Name of the property to set.
                            minLength: 1
                            type: string
                          optional:
                            description: Optional values are only set if they have
                              a non-empty value
                            type: boolean
                          value:
                            description: Value to set the property to.
                            type: string
                          valueFrom:
                            description: ValueFrom sets the value from an existing
                              resource.
                            properties:
                              nodeFieldRef:
                                description: Select a field of the node. Supports
                                  `metadata.name`, `metadata.labels['<KEY>']`, `metadata.annotations['<KEY>']`.
                                minLength: 1
                                type: string
                            type: object
                        required:
                        - name
                        type: object
                      type: array
                      x-kubernetes-list-map-keys:
                      - name
                      x-kubernetes-list-type: map
                    source:
                      properties:
                        hostDevices:
                          description: HostDevices is a list of device paths used
                            to configure the given pool.
                          items:
                            type: string
                          minItems: 1
                          type: array
                      type: object
                  required:
                  - name
                  type: object
                type: array
            required:
            - clusterRef
            type: object
          status:
            description: LinstorSatelliteStatus defines the observed state of LinstorSatellite
            properties:
              conditions:
                description: Current LINSTOR Satellite state
                items:
                  description: "Condition contains details for one aspect of the current
                    state of this API Resource. --- This struct is intended for direct
                    use as an array at the field path .status.conditions.  For example,
                    \n type FooStatus struct{ // Represents the observations of a
                    foo's current state. // Known .status.conditions.type are: \"Available\",
                    \"Progressing\", and \"Degraded\" // +patchMergeKey=type // +patchStrategy=merge
                    // +listType=map // +listMapKey=type Conditions []metav1.Condition
                    `json:\"conditions,omitempty\" patchStrategy:\"merge\" patchMergeKey:\"type\"
                    protobuf:\"bytes,1,rep,name=conditions\"` \n // other fields }"
                  properties:
                    lastTransitionTime:
                      description: lastTransitionTime is the last time the condition
                        transitioned from one status to another. This should be when
                        the underlying condition changed.  If that is not known, then
                        using the time when the API field changed is acceptable.
                      format: date-time
                      type: string
                    message:
                      description: message is a human readable message indicating
                        details about the transition. This may be an empty string.
                      maxLength: 32768
                      type: string
                    observedGeneration:
                      description: observedGeneration represents the .metadata.generation
                        that the condition was set based upon. For instance, if .metadata.generation
                        is currently 12, but the .status.conditions[x].observedGeneration
                        is 9, the condition is out of date with respect to the current
                        state of the instance.
                      format: int64
                      minimum: 0
                      type: integer
                    reason:
                      description: reason contains a programmatic identifier indicating
                        the reason for the condition's last transition. Producers
                        of specific condition types may define expected values and
                        meanings for this field, and whether the values are considered
                        a guaranteed API. The value should be a CamelCase string.
                        This field may not be empty.
                      maxLength: 1024
                      minLength: 1
                      pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                      type: string
                    status:
                      description: status of the condition, one of True, False, Unknown.
                      enum:
                      - "True"
                      - "False"
                      - Unknown
                      type: string
                    type:
                      description: type of condition in CamelCase or in foo.example.com/CamelCase.
                        --- Many .condition.type values are consistent across resources
                        like Available, but because arbitrary conditions can be useful
                        (see .node.status.conditions), the ability to deconflict is
                        important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
                      maxLength: 316
                      pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                      type: string
                  required:
                  - lastTransitionTime
                  - message
                  - reason
                  - status
                  - type
                  type: object
                type: array
                x-kubernetes-list-map-keys:
                - type
                x-kubernetes-list-type: map
            type: object
        type: object
    served: true
    storage: true
    subresources:
      status: {}
YAML
}

resource "kubernetes_service_account" "piraeus_operator_controller_manager" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io
  ]
  metadata {
    name      = "piraeus-operator-controller-manager"
    namespace = "piraeus-datastore"
    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
}

resource "kubernetes_service_account" "piraeus_operator_gencert" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io
  ]
  metadata {
    name      = "piraeus-operator-gencert"
    namespace = "piraeus-datastore"
    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
}

resource "kubernetes_role" "piraeus_operator_gencert" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io
  ]
  metadata {
    name      = "piraeus-operator-gencert"
    namespace = "piraeus-datastore"
    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
  rule {
    verbs      = ["get", "list", "watch", "create", "patch", "update"]
    api_groups = [""]
    resources  = ["secrets"]
  }
}

resource "kubernetes_role" "piraeus_operator_leader_election_role" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io
  ]
  metadata {
    name      = "piraeus-operator-leader-election-role"
    namespace = "piraeus-datastore"
    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
  rule {
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    api_groups = [""]
    resources  = ["configmaps"]
  }
  rule {
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }
  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }
}

resource "kubernetes_cluster_role" "piraeus_operator_controller_manager" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io
  ]
  metadata {
    name = "piraeus-operator-controller-manager"
    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = [""]
    resources  = ["configmaps", "events", "persistentvolumes", "secrets", "serviceaccounts", "services"]
  }
  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = [""]
    resources  = ["configmaps", "pods", "secrets"]
  }
  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }
  rule {
    verbs      = ["get", "list", "patch", "update", "watch"]
    api_groups = [""]
    resources  = ["nodes", "persistentvolumeclaims"]
  }
  rule {
    verbs      = ["patch"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims/status"]
  }
  rule {
    verbs      = ["delete", "list", "watch"]
    api_groups = [""]
    resources  = ["pods"]
  }
  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["pods/eviction"]
  }
  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }
  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["apps"]
    resources  = ["daemonsets", "deployments"]
  }
  rule {
    verbs      = ["get"]
    api_groups = ["apps"]
    resources  = ["replicasets"]
  }
  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["cert-manager.io"]
    resources  = ["certificates"]
  }
  rule {
    verbs      = ["create", "get", "list", "patch", "update", "watch"]
    api_groups = ["events.k8s.io"]
    resources  = ["events"]
  }
  rule {
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
    api_groups = ["internal.linstor.linbit.com"]
    resources  = ["*"]
  }
  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies"]
  }
  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["piraeus.io"]
    resources  = ["linstorclusters"]
  }
  rule {
    verbs      = ["update"]
    api_groups = ["piraeus.io"]
    resources  = ["linstorclusters/finalizers"]
  }
  rule {
    verbs      = ["get", "patch", "update"]
    api_groups = ["piraeus.io"]
    resources  = ["linstorclusters/status"]
  }
  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["piraeus.io"]
    resources  = ["linstornodeconnections"]
  }
  rule {
    verbs      = ["update"]
    api_groups = ["piraeus.io"]
    resources  = ["linstornodeconnections/finalizers"]
  }
  rule {
    verbs      = ["get", "patch", "update"]
    api_groups = ["piraeus.io"]
    resources  = ["linstornodeconnections/status"]
  }
  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["piraeus.io"]
    resources  = ["linstorsatelliteconfigurations"]
  }
  rule {
    verbs      = ["get", "patch", "update"]
    api_groups = ["piraeus.io"]
    resources  = ["linstorsatelliteconfigurations/status"]
  }
  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["piraeus.io"]
    resources  = ["linstorsatellites"]
  }
  rule {
    verbs      = ["update"]
    api_groups = ["piraeus.io"]
    resources  = ["linstorsatellites/finalizers"]
  }
  rule {
    verbs      = ["get", "patch", "update"]
    api_groups = ["piraeus.io"]
    resources  = ["linstorsatellites/status"]
  }
  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["clusterrolebindings", "clusterroles", "rolebindings", "roles"]
  }
  rule {
    verbs          = ["use"]
    api_groups     = ["security.openshift.io"]
    resources      = ["securitycontextconstraints"]
    resource_names = ["privileged"]
  }
  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotclasses", "volumesnapshots"]
  }
  rule {
    verbs      = ["delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents"]
  }
  rule {
    verbs      = ["patch", "update"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents/status"]
  }
  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["csidrivers"]
  }
  rule {
    verbs      = ["get", "list", "patch", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["csinodes"]
  }
  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["csistoragecapacities"]
  }
  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
  }
  rule {
    verbs      = ["delete", "get", "list", "patch", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments"]
  }
  rule {
    verbs      = ["patch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments/status"]
  }
}

resource "kubernetes_cluster_role" "piraeus-operator-gencert" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io
  ]
  metadata {
    name = "piraeus-operator-gencert"
    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
  rule {
    verbs          = ["get", "list", "watch", "update"]
    api_groups     = ["admissionregistration.k8s.io"]
    resources      = ["validatingwebhookconfigurations"]
    resource_names = ["piraeus-operator-validating-webhook-configuration"]
  }
}

resource "kubernetes_role_binding" "piraeus_operator_gencert" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_role.piraeus_operator_gencert
  ]
  metadata {
    name      = "piraeus-operator-gencert"
    namespace = "piraeus-datastore"

    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
  subject {
    kind      = "ServiceAccount"
    name      = "piraeus-operator-gencert"
    namespace = "piraeus-datastore"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "piraeus-operator-gencert"
  }
}

resource "kubernetes_role_binding" "piraeus_operator_leader_election_rolebinding" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_role.piraeus_operator_leader_election_role
  ]
  metadata {
    name      = "piraeus-operator-leader-election-rolebinding"
    namespace = "piraeus-datastore"
    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
  subject {
    kind      = "ServiceAccount"
    name      = "piraeus-operator-controller-manager"
    namespace = "piraeus-datastore"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "piraeus-operator-gencert"
    namespace = "piraeus-datastore"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "piraeus-operator-leader-election-role"
  }
}

resource "kubernetes_cluster_role_binding" "piraeus_operator_gencert" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_cluster_role.piraeus-operator-gencert
  ]
  metadata {
    name = "piraeus-operator-gencert"
    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
  subject {
    kind      = "ServiceAccount"
    name      = "piraeus-operator-gencert"
    namespace = "piraeus-datastore"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "piraeus-operator-gencert"
  }
}

resource "kubernetes_cluster_role_binding" "piraeus_operator_manager_rolebinding" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_cluster_role.piraeus_operator_controller_manager
  ]
  metadata {
    name = "piraeus-operator-manager-rolebinding"
    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
  subject {
    kind      = "ServiceAccount"
    name      = "piraeus-operator-controller-manager"
    namespace = "piraeus-datastore"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "piraeus-operator-controller-manager"
  }
}

resource "kubernetes_config_map" "piraeus_operator_image_config" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io
  ]
  metadata {
    name      = "piraeus-operator-image-config"
    namespace = "piraeus-datastore"
    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
  data = {
    "0_piraeus_datastore_images.yaml" = "---\n# This is the configuration for default images used by piraeus-operator\n#\n# \"base\" is the default repository prefix to use.\nbase: quay.io/piraeusdatastore\n# \"components\" is a mapping of image placeholders to actual image names with tag.\n# For example, the image name \"linstor-controller\" in the kustomize-resources will be replaced by:\n#   quay.io/piraeusdatastore/piraeus-server:v1.22.0\ncomponents:\n  linstor-controller:\n    tag: v1.23.0\n    image: piraeus-server\n  linstor-satellite:\n    tag: v1.23.0\n    image: piraeus-server\n  linstor-csi:\n    tag: v1.2.0\n    image: piraeus-csi\n  drbd-reactor:\n    tag: v1.2.0\n    image: drbd-reactor\n  ha-controller:\n    tag: v1.1.4\n    image: piraeus-ha-controller\n  drbd-shutdown-guard:\n    tag: v1.0.0\n    image: drbd-shutdown-guard\n  drbd-module-loader:\n    tag: v9.2.4\n    # The special \"match\" attribute is used to select an image based on the node's reported OS.\n    # The operator will first check the k8s node's \".status.nodeInfo.osImage\" field, and compare it against the list\n    # here. If one matches, that specific image name will be used instead of the fallback image.\n    image: drbd9-jammy # Fallback image: chose a fairly recent kernel, which can hopefully compile whatever config is actually in use\n    match:\n      - osImage: CentOS Linux 7\n        image: drbd9-centos7\n      - osImage: CentOS Linux 8\n        image: drbd9-centos8\n      - osImage: AlmaLinux 8\n        image: drbd9-almalinux8\n      - osImage: Red Hat Enterprise Linux CoreOS\n        image: drbd9-almalinux8\n      - osImage: AlmaLinux 9\n        image: drbd9-almalinux9\n      - osImage: Ubuntu 18\\.04\n        image: drbd9-bionic\n      - osImage: Ubuntu 20\\.04\n        image: drbd9-focal\n      - osImage: Ubuntu 22\\.04\n        image: drbd9-jammy\n      - osImage: Debian GNU/Linux 11\n        image: drbd9-bullseye\n      - osImage: Debian GNU/Linux 10\n        image: drbd9-buster\n"
    "0_sig_storage_images.yaml" = "---\nbase: registry.k8s.io/sig-storage\ncomponents:\n  csi-attacher:\n    tag: v4.3.0\n    image: csi-attacher\n  csi-livenessprobe:\n    tag: v2.10.0\n    image: livenessprobe\n  csi-provisioner:\n    tag: v3.5.0\n    image: csi-provisioner\n  csi-snapshotter:\n    tag: v6.2.2\n    image: csi-snapshotter\n  csi-resizer:\n    tag: v1.8.0\n    image: csi-resizer\n  csi-external-health-monitor-controller:\n    tag: v0.9.0\n    image: csi-external-health-monitor-controller\n  csi-node-driver-registrar:\n    tag: v2.8.0\n    image: csi-node-driver-registrar\n"
  }
}

resource "kubernetes_service" "piraeus_operator_webhook_service" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io
  ]
  metadata {
    name      = "piraeus-operator-webhook-service"
    namespace = "piraeus-datastore"
    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
  spec {
    port {
      protocol    = "TCP"
      port        = 443
      target_port = "9443"
    }
    selector = {
      "app.kubernetes.io/component" = "piraeus-operator"
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
}

resource "kubernetes_deployment" "piraeus_operator_controller_manager" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_config_map.piraeus_operator_image_config,
    kubernetes_service_account.piraeus_operator_controller_manager,
    kubernetes_cluster_role_binding.piraeus_operator_manager_rolebinding
  ]
  metadata {
    name      = "piraeus-operator-controller-manager"
    namespace = "piraeus-datastore"
    labels = {
      "app.kubernetes.io/component" = "piraeus-operator"
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "piraeus-operator"
        "app.kubernetes.io/name" = "piraeus-datastore"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "piraeus-operator"
          "app.kubernetes.io/name" = "piraeus-datastore"
        }
        annotations = {
          "kubectl.kubernetes.io/default-container" = "manager"
        }
      }
      spec {
        volume {
          name = "cert"
          secret {
            secret_name  = "webhook-server-cert"
            default_mode = "0644"
          }
        }
        container {
          name    = "manager"
          image   = "quay.io/piraeusdatastore/piraeus-operator:v2"
          command = ["/manager"]
          args    = ["--leader-elect", "--metrics-bind-address=0", "--namespace=$(NAMESPACE)", "--image-config-map-name=$(IMAGE_CONFIG_MAP_NAME)"]
          port {
            name           = "webhook-server"
            container_port = 9443
            protocol       = "TCP"
          }
          env {
            name = "NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          env {
            name  = "IMAGE_CONFIG_MAP_NAME"
            value = "piraeus-operator-image-config"
          }
          resources {
            limits = {
              cpu = "500m"
              memory = "256Mi"
            }
            requests = {
              cpu = "10m"
              memory = "64Mi"
            }
          }
          volume_mount {
            name       = "cert"
            read_only  = true
            mount_path = "/tmp/k8s-webhook-server/serving-certs"
          }
          liveness_probe {
            http_get {
              path = "/healthz"
              port = "8081"
            }
            initial_delay_seconds = 15
            period_seconds        = 20
          }
          readiness_probe {
            http_get {
              path = "/readyz"
              port = "8081"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          security_context {
            read_only_root_filesystem  = true
            allow_privilege_escalation = false
          }
        }
        termination_grace_period_seconds = 10
        service_account_name             = "piraeus-operator-controller-manager"
        security_context {
          run_as_non_root = true
        }
      }
    }
  }
}

resource "kubernetes_deployment" "piraeus_operator_gencert" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_config_map.piraeus_operator_image_config,
    kubernetes_service_account.piraeus_operator_gencert,
    kubernetes_cluster_role_binding.piraeus_operator_gencert
  ]
  metadata {
    name      = "piraeus-operator-gencert"
    namespace = "piraeus-datastore"
    labels = {
      "app.kubernetes.io/component" = "piraeus-operator-gencert"
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "piraeus-operator-gencert"
        "app.kubernetes.io/name" = "piraeus-datastore"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "piraeus-operator-gencert"
          "app.kubernetes.io/name" = "piraeus-datastore"
        }
        annotations = {
          "kubectl.kubernetes.io/default-container" = "gencert"
        }
      }
      spec {
        container {
          name    = "gencert"
          image   = "quay.io/piraeusdatastore/piraeus-operator:v2"
          command = ["/gencert"]
          args    = ["--leader-elect", "--namespace=$(NAMESPACE)", "--webhook-configuration-name=$(WEBHOOK_CONFIGURATION_NAME)", "--webhook-service-name=$(WEBHOOK_SERVICE_NAME)", "--webhook-tls-secret-name=$(WEBHOOK_TLS_SECRET_NAME)"]
          env {
            name = "NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          env {
            name  = "WEBHOOK_CONFIGURATION_NAME"
            value = "piraeus-operator-validating-webhook-configuration"
          }
          env {
            name  = "WEBHOOK_SERVICE_NAME"
            value = "piraeus-operator-webhook-service"
          }
          env {
            name  = "WEBHOOK_TLS_SECRET_NAME"
            value = "webhook-server-cert"
          }
          resources {
            limits = {
              cpu = "50m"
              memory = "128Mi"
            }
            requests = {
              cpu = "5m"
              memory = "32Mi"
            }
          }
          liveness_probe {
            http_get {
              path = "/healthz"
              port = "8081"
            }
            initial_delay_seconds = 15
            period_seconds        = 20
          }
          readiness_probe {
            http_get {
              path = "/readyz"
              port = "8081"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          security_context {
            read_only_root_filesystem  = true
            allow_privilege_escalation = false
          }
        }
        termination_grace_period_seconds = 10
        service_account_name             = "piraeus-operator-gencert"
        security_context {
          run_as_non_root = true
        }
      }
    }
  }
}

/* resource "kubectl_manifest" "piraeus_operator_gencert" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_config_map.piraeus_operator_image_config,
    kubernetes_service_account.piraeus_operator_gencert,
    kubernetes_cluster_role_binding.piraeus_operator_gencert     
  ]
  server_side_apply = true
  yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/component: piraeus-operator-gencert
    app.kubernetes.io/name: piraeus-datastore
  name: piraeus-operator-gencert
  namespace: piraeus-datastore
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/component: piraeus-operator-gencert
      app.kubernetes.io/name: piraeus-datastore
  template:
    metadata:
      annotations:
        kubectl.kubernetes.io/default-container: gencert
      labels:
        app.kubernetes.io/component: piraeus-operator-gencert
        app.kubernetes.io/name: piraeus-datastore
    spec:
      containers:
        - args:
            - --leader-elect
            - --namespace=$(NAMESPACE)
            - --webhook-configuration-name=$(WEBHOOK_CONFIGURATION_NAME)
            - --webhook-service-name=$(WEBHOOK_SERVICE_NAME)
            - --webhook-tls-secret-name=$(WEBHOOK_TLS_SECRET_NAME)
          command:
            - /gencert
          env:
            - name: NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: WEBHOOK_CONFIGURATION_NAME
              value: piraeus-operator-validating-webhook-configuration
            - name: WEBHOOK_SERVICE_NAME
              value: piraeus-operator-webhook-service
            - name: WEBHOOK_TLS_SECRET_NAME
              value: webhook-server-cert
          image: quay.io/piraeusdatastore/piraeus-operator:v2
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8081
            initialDelaySeconds: 15
            periodSeconds: 20
          name: gencert
          readinessProbe:
            httpGet:
              path: /readyz
              port: 8081
            initialDelaySeconds: 5
            periodSeconds: 10
          resources:
            limits:
              cpu: 50m
              memory: 128Mi
            requests:
              cpu: 5m
              memory: 32Mi
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
      securityContext:
        runAsNonRoot: true
      serviceAccountName: piraeus-operator-gencert
      terminationGracePeriodSeconds: 10
YAML
} */

data "kubernetes_secret" "datasource_webhook-server-cert" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_config_map.piraeus_operator_image_config,
    kubernetes_service.piraeus_operator_webhook_service,
    kubernetes_deployment.piraeus_operator_controller_manager,
    kubernetes_deployment.piraeus_operator_gencert
  ]
  metadata {
    name      = "webhook-server-cert"
    namespace = "piraeus-datastore"
  }
}

resource "kubernetes_validating_webhook_configuration" "piraeus_operator_validating_webhook_configuration" {
  depends_on = [
    kubernetes_namespace.piraeus_datastore,
    kubectl_manifest.CRD_linstorclusters_piraeus_io,
    kubectl_manifest.CRD_linstornodeconnections_piraeus_io,
    kubectl_manifest.CRD_linstorsatelliteconfigurations_piraeus_io,
    kubectl_manifest.CRD_linstorsatellites_piraeus_io,
    kubernetes_config_map.piraeus_operator_image_config,
    kubernetes_service.piraeus_operator_webhook_service,
    kubernetes_deployment.piraeus_operator_controller_manager,
    kubernetes_deployment.piraeus_operator_gencert,
    data.kubernetes_secret.datasource_webhook-server-cert
  ]
  metadata {
    name = "piraeus-operator-validating-webhook-configuration"
    labels = {
      "app.kubernetes.io/name" = "piraeus-datastore"
    }
  }
  webhook {
    name = "vlinstorcluster.kb.io"
    client_config {
    ca_bundle     = "${data.kubernetes_secret.datasource_webhook-server-cert.data["tls.crt"]}"
      service {
        namespace = "piraeus-datastore"
        name      = "piraeus-operator-webhook-service"
        path      = "/validate-piraeus-io-v1-linstorcluster"
      }
    }
    rule {
      operations = ["CREATE", "UPDATE"]
      resources    = ["linstorclusters"]
      api_versions = ["v1"]
      api_groups   = ["piraeus.io"]
    }
    failure_policy            = "Fail"
    side_effects              = "None"
    admission_review_versions = ["v1"]
  }
  webhook {
    name = "vlinstornodeconnection.kb.io"
    client_config {
    ca_bundle     = "${data.kubernetes_secret.datasource_webhook-server-cert.data["tls.crt"]}"
      service {
        namespace = "piraeus-datastore"
        name      = "piraeus-operator-webhook-service"
        path      = "/validate-piraeus-io-v1-linstornodeconnection"
      }
    }
    rule {
      operations = ["CREATE", "UPDATE"]
      resources    = ["linstornodeconnections"]   
      api_versions = ["v1"]
      api_groups   = ["piraeus.io"]
    }
    failure_policy            = "Fail"
    side_effects              = "None"
    admission_review_versions = ["v1"]
  }
  webhook {
    name = "vlinstorsatellite.kb.io"
    client_config {
    ca_bundle     = "${data.kubernetes_secret.datasource_webhook-server-cert.data["tls.crt"]}"
      service {
        namespace = "piraeus-datastore"
        name      = "piraeus-operator-webhook-service"
        path      = "/validate-piraeus-io-v1-linstorsatellite"
      }
    }
    rule {
      operations = ["CREATE", "UPDATE"]
      resources    = ["linstorsatellites"]
      api_versions = ["v1"]
      api_groups   = ["piraeus.io"]
    }
    failure_policy            = "Fail"
    side_effects              = "None"
    admission_review_versions = ["v1"]
  }
  webhook {
    name = "vlinstorsatelliteconfiguration.kb.io"
    client_config {
    ca_bundle     = "${data.kubernetes_secret.datasource_webhook-server-cert.data["tls.crt"]}"
      service {
        namespace = "piraeus-datastore"
        name      = "piraeus-operator-webhook-service"
        path      = "/validate-piraeus-io-v1-linstorsatelliteconfiguration"
      }
    }
    rule {
      operations = ["CREATE", "UPDATE"]
      resources    = ["linstorsatelliteconfigurations"]
      api_versions = ["v1"]
      api_groups   = ["piraeus.io"]
    }
    failure_policy            = "Fail"
    side_effects              = "None"
    admission_review_versions = ["v1"]
  }
}

resource "kubectl_manifest" "linstorcluster_piraeus_datastore" {
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
    kubernetes_deployment.piraeus_operator_gencert
    #kubectl_manifest.piraeus_operator_gencert
  ]
  server_side_apply = false
  yaml_body = <<YAML
apiVersion: piraeus.io/v1
kind: LinstorCluster
metadata:
  name: linstorcluster
spec: 
  nodeSelector:
    node-role.kubernetes.io/worker: ""
YAML
}

resource "kubectl_manifest" "linstorcluster_piraeus_lvm_storage" {
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
    kubectl_manifest.linstorcluster_piraeus_datastore
  ]
  server_side_apply = false
  yaml_body = <<YAML
apiVersion: piraeus.io/v1
kind: LinstorSatelliteConfiguration
metadata:
  name: storage-pool
spec:
  storagePools:
    - name: thinpool
      lvmThinPool: {}
      source:
        hostDevices:
          - /dev/xvdb
YAML
}
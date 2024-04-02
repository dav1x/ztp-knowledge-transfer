# Zero Touch Provisioning Workflow 

The [OpenShift Docs](https://docs.openshift.com/container-platform/latest/scalability_and_performance/ztp_far_edge/ztp-manual-install.html) provide some exhaustive information on how to deploy a managed single-node OpenShift cluster using Red Hat Advanced Cluster Management (RHACM) and the assisted service. 

![GitOps ZTP flow overview](images/ztp_gitops_flow.png)

The [CNF features repo](https://github.com/openshift-kni/cnf-features-deploy/tree/release-4.15/ztp/gitops-subscriptions/argocd) walks through the setup of the GitOps workflow for ZTP deployment and policy rollout for installation.

The site-config CR included in the [repository](https://github.com/openshift-kni/cnf-features-deploy/blob/release-4.15/ztp/gitops-subscriptions/argocd/example/siteconfig/example-sno.yaml) include some example options for configuring the deployments of both single node OpenShift (SNO) and multinode OpenShift (MNO). 

## The pre-built ztp-site-generator container 
```
    $ podman pull quay.io/openshift-kni/ztp-site-generator:latest
```

This container is responsible for converting the site-config and site-policies into usable CRs for Advanced Cluster Manager (ACM) and Assisted Service. Here is an example site-config with baremetal host .


## Sample SiteConfig
```
---
apiVersion: ran.openshift.io/v1
kind: SiteConfig
metadata:
  name: "smc-sno1"
  namespace: "smc-sno1"
spec:
  baseDomain: "product-int.example.com"
  pullSecretRef:
    name: "assisted-deployment-pull-secret"
  clusterImageSetNameRef: "img4.15.0-x86-64-appsub"
  sshPublicKey: "ssh-rsa KEYHERE"
  clusters:
  - clusterName: "smc-sno1"
    clusterLabels:
      # Placement Rule Labels for policy binding 
      logicalGroup: "active"
      common-415: "true"
      group-du-sno: ""
      sites : "product-int.example.com"
      vendor: "OpenShift"
      flexran: "timer-mode"
      du-profile: "seed"
    clusterNetwork:
      - cidr: "10.128.0.0/14"
        hostPrefix: 23
    machineNetwork:
      - cidr: "10.0.0.0/24"
    serviceNetwork:
      - "172.30.0.0/16"
    networkType: "OVNKubernetes"
    additionalNTPSources:
      - "clock.redhat.com"
    cpuPartitioningMode: AllNodes
    nodes:
      - hostName: "smc-sno1.oob.product-int.example.com"
        role: "master"
        bmcAddress: "redfish-virtualmedia://10.6.0.84/redfish/v1/Systems/1"
        bmcCredentialsName:
          name: "smc-sno1-worker"
        bootMACAddress: "7C:C2:55:99:BE:EF"
        bootMode: "UEFI"
        rootDeviceHints:
          deviceName: "/dev/sda"
        nodeNetwork:
          interfaces:
            - name: "eno1np0"
              macAddress: "7C:C2:55:99:BE:EF"
          config:
            interfaces:
            - name: eno1np0
              type: ethernet
              state: up
              ipv4:
                address:
                  - ip: 10.0.0.31 
                    prefix-length: 24
                dhcp: false
                enabled: true
              ipv6:
                dhcp: false
                autoconf: false
                enabled: false
            dns-resolver:
              config:
                server:
                - 10.0.0.2
                - 10.0.0.1 
            routes:
              config:
                - destination: '0.0.0.0/0'
                  next-hop-address: '10.0.0.254'
                  next-hop-interface: eno1np0
 ```

## The Anatomy of a SiteConfig

Clone the repository and use the included sample site-config to generate the applicable custom resources for the cluster deployment. 

```
$ git clone git@github.com:dav1x/ztp-knowledge-transfer.git

$ cd ztp-knowledge-transfer

$ podman run -it --rm -v `pwd`/sample-siteconfigs:/resources:Z -v `pwd`/generated-crs:/output:Z,U registry.redhat.io/openshift4/ztp-site-generate-rhel8:v4.15 generator install dell-sno1.yaml /output
 
$ tree
.
├── generated-crs
│   └── dell-sno1
│       ├── dell-sno1_agentclusterinstall_dell-sno1.yaml
│       ├── dell-sno1_baremetalhost_dell-sno1.oob.product-int.example.com.yaml
│       ├── dell-sno1_clusterdeployment_dell-sno1.yaml
│       ├── dell-sno1_configmap_dell-sno1.yaml
│       ├── dell-sno1_infraenv_dell-sno1.yaml
│       ├── dell-sno1_klusterletaddonconfig_dell-sno1.yaml
│       ├── dell-sno1_machineconfig_05-kdump-config-master.yaml
│       ├── dell-sno1_machineconfig_05-kdump-config-worker.yaml
│       ├── dell-sno1_machineconfig_06-kdump-enable-master.yaml
│       ├── dell-sno1_machineconfig_06-kdump-enable-worker.yaml
│       ├── dell-sno1_machineconfig_07-sriov-related-kernel-args-master.yaml
│       ├── dell-sno1_machineconfig_07-sriov-related-kernel-args-worker.yaml
│       ├── dell-sno1_machineconfig_08-set-rcu-normal-master.yaml
│       ├── dell-sno1_machineconfig_08-set-rcu-normal-worker.yaml
│       ├── dell-sno1_machineconfig_99-crio-disable-wipe-master.yaml
│       ├── dell-sno1_machineconfig_99-crio-disable-wipe-worker.yaml
│       ├── dell-sno1_machineconfig_99-sync-time-once-master.yaml
│       ├── dell-sno1_machineconfig_99-sync-time-once-worker.yaml
│       ├── dell-sno1_machineconfig_container-mount-namespace-and-kubelet-conf-master.yaml
│       ├── dell-sno1_machineconfig_container-mount-namespace-and-kubelet-conf-worker.yaml
│       ├── dell-sno1_machineconfig_load-sctp-module-master.yaml
│       ├── dell-sno1_machineconfig_load-sctp-module-worker.yaml
│       ├── dell-sno1_managedcluster_dell-sno1.yaml
│       ├── dell-sno1_namespace_dell-sno1.yaml
│       ├── dell-sno1_namespace_openshift-marketplace.yaml
│       ├── dell-sno1_nmstateconfig_dell-sno1.oob.product-int.example.com.yaml
│       └── dell-sno1_node_cluster.yaml
├── README.md
└── sample-siteconfigs
    ├── dell-sno1.yaml
    └── smc-sno1.yaml

4 directories, 30 files

 
```

Besides the rendered MachineConfig, we are primarily interested in the components of the installation.

```
$ oc get crd | grep -Ei "^AgentClusterInstalls|^BareMetalHosts|^ClusterDeployments|^InfraEnvs|^KlusterletAddonConfig|^ManagedClusters\.|^NMStateConfigs"
agentclusterinstalls.extensions.hive.openshift.io                         2024-03-11T16:44:52Z
baremetalhosts.metal3.io                                                  2024-03-11T16:16:17Z
clusterdeployments.hive.openshift.io                                      2024-03-11T16:44:53Z
infraenvs.agent-install.openshift.io                                      2024-03-11T16:44:52Z
klusterletaddonconfigs.agent.open-cluster-management.io                   2024-03-12T20:46:35Z
managedclusters.cluster.open-cluster-management.io                        2024-03-11T17:06:03Z
nmstateconfigs.agent-install.openshift.io                                 2024-03-11T16:44:52Z

```

In the above 7 CRs generated from the site-config you can identify the components that are a part of [hive](https://github.com/openshift/hive), [acm](https://www.redhat.com/en/technologies/management/advanced-cluster-management) or [open-cluster-management](https://open-cluster-management.io/), [agent-install or assisted service](https://github.com/openshift/assisted-service/blob/master/docs/user-guide/README.md) and [metal3.](https://metal3.io/)


## After the Spoke is installed 

These manifests are created and we are brought to step 4 in the following work flow:

![GitOps ZTP workflow part 1](images/ztp-day-n_1.png)

Now, cluster policies are assigned based on the managedcluster labels and placement rules of created policies. All of these policies are created as "inform". The [Topology Aware Lifecycle Manager (TALM)](https://www.redhat.com/en/blog/how-to-use-the-topology-aware-lifecycle-manager) assists with managing the rest of the lifecycle of the cluster including remediating required policies. 

```
  - clusterName: "smc-sno1"
    clusterLabels:
      # Placement Rule Labels for policy binding 
      logicalGroup: "active"
      common-415: "true"

..omitted..

apiVersion: ran.openshift.io/v1
kind: PolicyGenTemplate
metadata:
  name: "common-415"
  namespace: "ztp-common"
  annotations:
spec:
  bindingRules:
    common-415: "true"
    logicalGroup: "active"
  remediationAction: inform
  sourceFiles:
    # Create operators policies that will be installed in all clusters
    # SRIOV
    - fileName: SriovSubscription.yaml
      policyName: "common-subscription"
      spec:
```

TALM looks for labels on the managedcluster and new clusters "auto-create" a cluster group upgrade (CGU) that marks the policies to "enforce" mode in waves. For example, Operator configurations require subscriptions which require catalog sources etc.

![GitOps ZTP workflow part 2](images/ztp-day-n_2.png)

As this process is completed TALM ends the workflow by adding a "ztp-done" label to the managedcluster. This signifies the process is complete and also provides additional filtering from further TALM invocations. 

## Updates to the policies in git

Finally, modifications to cluster configurations in git will cause policies to no longer remain compliant. This will allow TALM to rollout progressive changes in a non-destruptive manner for your cluster fleet.

![GitOps ZTP workflow part 3](images/ztp-day-n_3.png)

## Troubleshooting

Included is a helpful script for cluster install messages via command line. 

```
$ ./01_checkin_install.sh dell-sno1
-----Thu Mar 28 04:14:03 PM CDT 2024----------
null
null

NAME            HUB ACCEPTED   MANAGED CLUSTER URLS                                         JOINED   AVAILABLE   AGE
local-cluster   true           https://api.inbound-int.se-lab.eng.rdu2.dc.redhat.com:6443   True     True        17d
dell-sno1        true                                                                                 Unknown     40m

No resources found in dell-sno1 namespace.

```

For a more in depth breakdown of the hive and assisted service integration the following are great resources:

- https://github.com/openshift/assisted-service/blob/master/docs/hive-integration/ZTP_converged_flow.png
- https://github.com/openshift/assisted-service/tree/master/docs/hive-integration
- https://www.redhat.com/en/blog/red-hat-openshift-edge-zero-touch-provisioning

# Zero Touch Provisioning Workflow 
Helpful ZTP how-to knowledge

![GitOps ZTP flow overview](https://github.com/openshift-kni/cnf-features-deploy/blob/release-4.15/ztp/gitops-subscriptions/argocd/ztp_gitops_flow.png)

The [CNF features repo](https://github.com/openshift-kni/cnf-features-deploy/tree/release-4.15](https://github.com/openshift-kni/cnf-features-deploy/tree/release-4.15/ztp/gitops-subscriptions/argocd) walks through the setup of the GitOps workflow for ZTP deployment and policy rollout for installation.

The site-config CR included in the [repository](https://github.com/openshift-kni/cnf-features-deploy/blob/release-4.15/ztp/gitops-subscriptions/argocd/example/siteconfig/example-sno.yaml) include some example options for configuring the deployments of both single node OpenShift (SNO) and multinode OpenShift (MNO). 

## The pre-built ztp-site-generator container 
```
    $ podman pull quay.io/openshift-kni/ztp-site-generator:latest
```

This container is responsible for converting the site-config and site-policies into usable CRs for Advanced Cluster Manager (ACM) and Assisted Service. Here is an example site-config with hardware.

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

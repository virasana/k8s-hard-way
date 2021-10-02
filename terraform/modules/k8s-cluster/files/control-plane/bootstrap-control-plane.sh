#!/bin/bash
set -euo pipefail

function _create_k8s_config_directory {
  echo "*** CREATE K8S CONFIG DIRECTORY ***"
  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    echo "${instance} ==> sudo mkdir -p /etc/kubernetes/config"
    ssh "${instance}" sudo mkdir -p /etc/kubernetes/config
  done
  echo "<== done!"
}

function _donwload_binaries {
  echo "*** DOWNLOAD CONTROL PLANE BINARIES (APISERVER, CONTROLLER-MANAGER, KUBE-SCHEDULER, KUBECTL) ***"
  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    echo "${instance} (in progress...)"
    ssh "${instance}" wget -q --https-only --timestamping \
    "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-apiserver" \
    "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-controller-manager" \
    "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-scheduler" \
    "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl"
  done
}

function _install_binaries {
  echo "*** INSTALL CONTROL PLANE BINARIES (APISERVER, CONTROLLER-MANAGER, KUBE-SCHEDULER, KUBECTL) ***"
  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    echo "${instance} (in progress...)"
    ssh "${instance}" chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
    ssh "${instance}" sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/
  done
}

function _configure_api_server {
  echo "*** CONFIGURE API SERVER ***"
  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    echo "${instance} (in progress...)"
    echo "==> mkdir -p /var/lib/kubernetes/"
    ssh "${instance}" sudo mkdir -p /var/lib/kubernetes/

     echo "==> determining internal ip address for ${instance}"
     controller_name=$(echo "${instance}" | sed 's/.ksone//g')
     INTERNAL_IP=$(aws --region=eu-west-1 ec2 describe-instances | jq --arg instance_name "${controller_name}" -r '.Reservations[].Instances[] | select(.Tags[] | select(.Key=="Description" and .Value==$instance_name)).NetworkInterfaces[].PrivateIpAddress')
     echo "INTERNAL_IP: ${INTERNAL_IP}"

     echo "==> determine k8s public ip address"
     KUBERNETES_PUBLIC_ADDRESS=$(aws --region=eu-west-1 ec2 describe-addresses | jq -r '. | select(.Addresses[].Tags[] | .Key=="name" and .Value=="k8s-hard-way").Addresses[].PublicIp')
     echo "KUBERNETES_PUBLIC_ADDRESS: ${KUBERNETES_PUBLIC_ADDRESS}"

     echo "==> configure the apiserver service"
     mkdir -p "/tmp/k8s-hard-way/control-plane/"
     cat <<EOF | tee "/tmp/k8s-hard-way/control-plane/${instance}-kube-apiserver.service"
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=https://10.240.0.10:2379,https://10.240.0.11:2379,https://10.240.0.12:2379 \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --runtime-config='api/all=true' \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-account-signing-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-account-issuer=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
  echo "==> copying kube-apiserver instance to ${instance}"
  scp "/tmp/k8s-hard-way/control-plane/${instance}-kube-apiserver.service" "${instance}":/home/ubuntu/${instance}-kube-apiserver.service
  echo "==> moving kube-apiserver to /etc/systemd/system/kube-apiserver.service"
  ssh "${instance}" sudo mv "/home/ubuntu/${instance}-kube-apiserver.service" /etc/systemd/system/kube-apiserver.service
  done
  echo "<== done!"
}

function _configure_k8s_controller_manager {
  echo "*** CONFIGURE THE K8S CONTROLLER MANAGER ***"
  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    echo "${instance} (in progress...)"
    echo "==> move controller manager binaries to /var/lib/kubernetes/"
    ssh "${instance}" sudo cp -f kube-controller-manager.kubeconfig /var/lib/kubernetes/

    echo "==> create controller manager service file"
    cat <<EOF | tee "/tmp/k8s-hard-way/control-plane/${instance}-kube-controller-manager.service"
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --bind-address=0.0.0.0 \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
  echo "==> copying controller manager binary file to ${instance}"
  scp "/tmp/k8s-hard-way/control-plane/${instance}-kube-controller-manager.service" "${instance}":"/home/ubuntu/${instance}-kube-controller-manager.service"
  echo "==> moving controller manager to /etc/systemd/system/kube-controller-manager.service"
  ssh "${instance}" sudo mv "/home/ubuntu/${instance}-kube-controller-manager.service" /etc/systemd/system/kube-controller-manager.service
  done
  echo "<== done!"
}

function _configure_k8s_scheduler {
  echo "*** CONFIGURE K8S SCHEDULER ***"
  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    echo "${instance} (in progress...)"
    ssh "${instance}" sudo cp -f kube-scheduler.kubeconfig /var/lib/kubernetes/

    echo "==> create scheduler yaml file"
    cat <<EOF | tee "/tmp/k8s-hard-way/control-plane/${instance}-kube-scheduler.yaml"
apiVersion: kubescheduler.config.k8s.io/v1beta1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF
    scp "/tmp/k8s-hard-way/control-plane/${instance}-kube-scheduler.yaml" "${instance}":/home/ubuntu/kube-scheduler.yaml
    ssh "${instance}" sudo cp -f /home/ubuntu/kube-scheduler.yaml /etc/kubernetes/config/kube-scheduler.yaml

  echo "==> create kube-scheduler.service"
  cat <<EOF | tee "/tmp/k8s-hard-way/control-plane/${instance}-kube-scheduler.service"
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --config=/etc/kubernetes/config/kube-scheduler.yaml \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  scp /tmp/k8s-hard-way/control-plane/"${instance}-kube-scheduler.service" "${instance}":/home/ubuntu/kube-scheduler.service
  ssh "${instance}" sudo cp -f /home/ubuntu/kube-scheduler.service /etc/systemd/system/kube-scheduler.service
  done
  echo "<== done"
}

function _start_controller_services {
  echo "*** START THE CONTROLLER SERVICE ***"
  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
  echo "${instance} (in progress...)"
    ssh "${instance}" sudo systemctl daemon-reload
    ssh "${instance}" sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
    ssh "${instance}" sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler &
  done
  echo "<== done!"
}

function _deploy_certs {
  echo "*** DEPLOY CERTS ***"
  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    echo "${instance} (in progress...)"
    echo "==> /var/lib/kubernetes/service-account-key.pem"
    echo "${instance} (in progress...)"
    echo "==> mkdir -p /var/lib/kubernetes/q"
    ssh "${instance}" sudo mkdir -p /var/lib/kubernetes/
    echo "==> /var/lib/kubernetes/service-account.pem"
    ssh "${instance}" sudo cp -f /home/ubuntu/service-account.pem /var/lib/kubernetes/service-account.pem
    echo "==> /var/lib/kubernetes/kubernetes.pem"
    ssh "${instance}" sudo cp -f /home/ubuntu/kubernetes.pem /var/lib/kubernetes/kubernetes.pem
    echo "==> /var/lib/kubernetes/kubernetes-key.pem"
    ssh "${instance}" sudo cp -f /home/ubuntu/kubernetes-key.pem /var/lib/kubernetes/kubernetes-key.pem
    echo "==> var/lib/kubernetes/encryption-config.yaml"
    ssh "${instance}" sudo cp -f /home/ubuntu/encryption-config.yaml /var/lib/kubernetes/encryption-config.yaml
    echo "==> /var/lib/kubernetes/ca.pem"
    ssh "${instance}" sudo cp -f /home/ubuntu/ca.pem /var/lib/kubernetes/ca.pem
  done
  echo "<== done!"
}

function _welcome {
  echo "*** DEPLOY CONTROL PLANE ***"
}

function _goodbye {
  echo "<== done!"
}

function _verify_controller_services {
  echo "*** VERIFY CONTROLLER SERVICES ***"
  echo "==> get kubermetes public ip address"
  KUBERNETES_PUBLIC_ADDRESS=$(aws ec2 describe-addresses | jq -r '. | select(.Addresses[].Tags[] | .Key=="name" and .Value=="k8s-hard-way").Addresses[].PublicIp')
  echo "KUBERNETES_PUBLIC_ADDRESS: ${KUBERNETES_PUBLIC_ADDRESS}"
  echo "<== done!"
}

declare -g KUBERNETES_PUBLIC_ADDRESS

#_welcome
#_deploy_certs
#_create_k8s_config_directory
#_donwload_binaries
#_install_binaries
#_configure_api_server
#_configure_k8s_controller_manager
#_configure_k8s_scheduler
#_start_controller_services
_verify_controller_services
_goodbye
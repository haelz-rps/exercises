#!/bin/bash

metricsYaml() {
cat << EOF > metricsServer.yml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metrics-server
  namespace: kube-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    k8s-app: metrics-server
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  template:
    metadata:
      name: metrics-server
      labels:
        k8s-app: metrics-server
    spec:
      serviceAccountName: metrics-server
      volumes:
      # mount in tmp so we can safely use from-scratch images and/or read-only containers
      - name: tmp-dir
        emptyDir: {}
      containers:
      - name: metrics-server
        image: k8s.gcr.io/metrics-server-amd64:v0.3.6
        imagePullPolicy: Always
        args:
        - /metrics-server
        - --kubelet-insecure-tls
        - --v=10
        - --kubelet-preferred-address-types=InternalIP
        volumeMounts:
        - name: tmp-dir
          mountPath: /tmp;
---
kind: Service
apiVersion: v1
metadata:
  name: metrics-server-external
  namespace: kube-system
  labels:
    k8s-app: metrics-server
spec:
  ports:
  - protocol: TCP
    port: 443
    targetPort: 443
    nodePort: 30996
  selector:
    k8s-app: metrics-server
  type: NodePort
---
apiVersion: v1
kind: Service
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    kubernetes.io/name: "Metrics-server"
    kubernetes.io/cluster-service: "true"
spec:
  selector:
    k8s-app: metrics-server
  ports:
  - port: 443
    protocol: TCP
    targetPort: 443
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: system:aggregated-metrics-reader
  labels:
    rbac.authorization.k8s.io/aggregate-to-view: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
rules:
- apiGroups: ["metrics.k8s.io"]
  resources: ["pods", "nodes"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  - nodes/stats
  - namespaces
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: apiregistration.k8s.io/v1beta1
kind: APIService
metadata:
  name: v1beta1.metrics.k8s.io
spec:
  service:
    name: metrics-server
    namespace: kube-system
  group: metrics.k8s.io
  version: v1beta1
  insecureSkipTLSVerify: true
  groupPriorityMinimum: 100
  versionPriority: 100
EOF
}

getMetricsServerToken() {
    secretName=`kubectl describe sa metrics-server -n kube-system | grep Tokens | awk '{print$2}'`
    while [ secretName == '<none>' ]; do
        secretName=`kubectl describe sa metrics-server -n kube-system | grep Tokens | awk '{print$2}'`
    done
    token=`kubectl get secret $secretName -n kube-system -o jsonpath='{.data.token}' | base64 --decode`
}

mangue_cluster_ip=`kubectl get svc -n ustore | grep cluster | awk '{print$3}'`

printf "\n(1) CRIANDO ARQUIVO DO METRICS\n"
metricsYaml
printf "\n(2)CRIANDO METRICS-SERVER NO CLUSTER\n"
kubectl create -f metricsServer.yml
printf "\n(3) BUSCANDO TOKEN DO METRICS-SERVER\n"
getMetricsServerToken
port='30996'
ip=$1
echo {} | jq --arg port "$port" --arg ip "$ip" --arg token "$token" '. + {"metricServerIp": $ip, "metricServerPort": $port, "bearerToken": $token}' > billing.json
printf "\n(4) PERSISTINDO INFORMACOES DO METRICS DO BANCO\n"
curl -d "@billing.json" -H "Content-Type: application/json" -H "clusterid: 1" -X POST http://$mangue_cluster_ip:8893/api/billing

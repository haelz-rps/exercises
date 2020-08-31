#!bin/bash

checkSecret() {
    tokenName=`kubectl describe serviceaccount $1 | grep Tokens | awk '{print$2}'`
    while [ $tokenName == '<none>' ]; do
        tokenName=`kubectl describe serviceaccount $1 | grep Tokens | awk '{print$2}'`
    done
}

create_kube_user() {
cat << EOF > permission.yml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: $1-crb
subjects:
- kind: ServiceAccount
  name: $1
  namespace: default
roleRef:
  kind: ClusterRole
  name: $1-cluster-admin
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $1
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: null
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: $1-cluster-admin
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
- nonResourceURLs:
  - '*'
  verbs:
  - '*'
EOF
}

mangue_cluster_ip=`kubectl get svc -n ustore | grep cluster | awk '{print$3}'`

echo "(1) CRIANDO ARQUIVO DE PERMISSAO"
create_kube_user $1
echo "(2) CRIANDO PERMISSOES PARA O USUARIO $1"
kubectl create -f permission.yml
checkSecret $1
echo Criei Token: $tokenName
token=`kubectl get secret $tokenName -o jsonpath="{.data.token}"`
echo "(3) CRIANDO RELACAO CLUSTER-PERMISSION"
cat clusterPermission.json | jq --arg cluster "$2" --arg grupo "$3" --arg kubeip "$4" '.cluster + {"clusterName": $cluster, "groupName": $grupo, "publicIp": $kubeip, "mangueIp": $kubeip}' > cluster.json
cat clusterPermission.json | jq --arg token "$token" --arg crb "$1-crb"  --arg cr "$1-cluster-admin" --arg user "$1" '.permission + {"ucname": $user, "serviceAccountName": $user, "clusterRoleBindingName": $crb, "bearerToken": $token, "clusterRoleName": $cr}' > permission.json
cat clusterPermission.json | jq --argfile permission permission.json --argfile cluster cluster.json '. + {"cluster": $cluster, "permission": $permission}' > cp.json
echo "(4) PERSISTINDO PERMISSAO NO BANCO DE DADOS"
curl -d "@cp.json" -H "Content-Type: application/json" -X POST http://$mangue_cluster_ip:8893/api/clusterPermission
echo "(5) PERSISTINDO GRUPO"
curl -H "Content-Type: application/json" -H "clusterid: 1" -H "groupname: $3" -H "firstgroup: true" -X GET http://$mangue_cluster_ip:8893/api/groups

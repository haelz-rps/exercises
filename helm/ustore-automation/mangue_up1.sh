#!/bin/bash

apt install jq mysql-client -y

checkDeploy() {
    PODS='0';
    while [ $PODS != $2 ]; do
        PODS=$(kubectl get deploy $1 -n ustore | awk '{print$2}' | grep -v READY)
    done
}

createUmarketYamls() {
cat << EOF > umarket.yml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: umarket-ui
  name: umarket-ui
  namespace: ustore
spec:
  ports:
  - nodePort: 31440
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: umarket
  type: NodePort
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: umarket-server
  name: umarket-server
  namespace: ustore
spec:
  ports:
  - nodePort: 31441
    port: 9091
    protocol: TCP
    targetPort: 9091
  selector:
    app: umarket
  type: NodePort
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: umarket
  name: umarket
  namespace: ustore
spec:
  replicas: 1
  selector:
    matchLabels:
      app: umarket
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: umarket
    spec:
      containers:
      - image: magueio/umarket-ui:tlmx-v1.20
        imagePullPolicy: Always
        name: umarket-ui
        ports:
        - containerPort: 80
          protocol: TCP
        resources:
          limits:
            cpu: 250m
            memory: 200Mi
          requests:
            cpu: 150m
            memory: 100Mi
        volumeMounts:
        - mountPath: /usr/share/nginx/html/photo
          name: umarket-pv
        - mountPath: /usr/share/nginx/html/assets/apis
          name: umarket-config
      - env:
        - name: MYSQL_IP
          value: $1
        image: magueio/umarket-server:tlmx-v1.0.5
        imagePullPolicy: Always
        name: umarket-server
        ports:
        - containerPort: 9091
          protocol: TCP
        resources:
          limits:
            cpu: 350m
            memory: 200Mi
          requests:
            cpu: 150m
            memory: 100Mi
        volumeMounts:
        - mountPath: /usr/src/app/photo
          name: umarket-pv
      volumes:
      - name: umarket-pv
        persistentVolumeClaim:
          claimName: umarket-pv
      - name: umarket-config
        configMap:
          name: umarket-config
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: umarket-pv
  annotations:
    volume.beta.kubernetes.io/storage-class: "external-nfs"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
EOF
}

createBillingYaml() {
cat << EOF > mangue-cluster-billing.yml
apiVersion: v1
kind: Service
metadata:
  name: mangue-billing
  labels:
    app: mangue-billing
spec:
  ports:
    - name: http
      port: 9090
      nodePort: 30995
  selector:
    app: mangue-billing
  type: NodePort
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: mangue-billing
  name: mangue-billing
spec:
  selector:
    matchLabels:
      app: mangue-billing
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: mangue-billing
    spec:
      containers:
      - env:
        - name: MYSQL_IP
          value: $1
        - name: MYSQL_PORT
          value: "3306"
        - name: MANGUE_SERVER
          value: "mangue-server"
        - name: MANGUE_SERVER_PORT
          value: "9090"
        image: magueio/billing-server:tlmx-v1.0.3
        imagePullPolicy: Always
        name: container0
        ports:
        - containerPort: 9097
          protocol: TCP
        resources:
          limits:
            cpu: 180m
            memory: 600Mi
          requests:
            cpu: 100m
            memory: 256Mi
        readinessProbe:
          httpGet:
            path: "/api/billing/health-check"
            port: 9097
            scheme: HTTP
          timeoutSeconds: 2
          periodSeconds: 10
          initialDelaySeconds: 20
          successThreshold: 1
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: "/api/billing/health-check"
            port: 9097
            scheme: HTTP
          periodSeconds: 10
          initialDelaySeconds: 20
EOF
}

createAppsYamls() {
cat << EOF > mangue_apps.yml
# Mangue-Cluster
---
apiVersion: v1
kind: Service
metadata:
  name: mangue-cluster
  labels:
    app: mangue-cluster
spec:
  ports:
    - name: http
      port: 8893
  selector:
    app: mangue-cluster
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: mangue-cluster
  labels:
    app: mangue-cluster
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mangue-cluster
  strategy:
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: mangue-cluster
    spec:
      containers:
      - name: container0
        ports:
        - containerPort: 8893
        image: magueio/clustermanager:tlmx-v1.1.0
        env:
        - name: CLUSTER_IP
          value: $1
        - name: MYSQL_PORT
          value: "3306"
        imagePullPolicy: Always
        resources:
          limits:
            cpu: 400m
            memory: 600Mi
          requests:
            cpu: 200m
            memory: 400Mi
        readinessProbe:
          httpGet:
            path: "/api/health-check"
            port: 8893
            scheme: HTTP
          timeoutSeconds: 2
          periodSeconds: 10
          initialDelaySeconds: 20
          successThreshold: 1
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: "/api/health-check"
            port: 8893
            scheme: HTTP
          periodSeconds: 10
          initialDelaySeconds: 20
---
# Mangue-Server
apiVersion: v1
kind: Service
metadata:
  name: mangue-server
  labels:
    app: mangue-server
spec:
  ports:
    - name: http
      port: 9090
  selector:
    app: mangue-server
---
apiVersion: v1
kind: Service
metadata:
  name: mangue-server-external
  labels:
    app: mangue-server-external
spec:
  ports:
    - name: http
      port: 9090
      nodePort: 32588
  selector:
    app: mangue-server
  type: NodePort
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: mangue-server
  labels:
    app: mangue-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mangue-server
  strategy:
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: mangue-server
    spec:
      containers:
      - name: container0
        ports:
        - containerPort: 9090
        image: magueio/mangueio-server:tlmx-v1.1.0
        env:
        - name: CLUSTER_IP
          value: "mangue-cluster"
        - name: MANAGER_PORT
          value: "8893"
        - name: UCLOUD_HOST
          value: "intercloud.telmex.com"
        - name: UCLOUD_REQUEST
          value: "https"
        imagePullPolicy: Always
        resources:
          limits:
            cpu: 400m
            memory: 600Mi
          requests:
            cpu: 200m
            memory: 400Mi
        readinessProbe:
          httpGet:
            path: "/api/kube//health-check"
            port: 9090
            scheme: HTTP
          timeoutSeconds: 2
          periodSeconds: 10
          initialDelaySeconds: 20
          successThreshold: 1
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: "/api/kube//health-check"
            port: 9090
            scheme: HTTP
          periodSeconds: 10
          initialDelaySeconds: 20
---
# Mangue-UI
apiVersion: v1
kind: Service
metadata:
  name: mangueuiv2
  labels:
    app: mangueuiv2
spec:
  ports:
    - port: 80
      nodePort: 31445
  selector:
    app: mangueuiv2
  type: NodePort
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: mangueuiv2
  creationTimestamp:
  labels:
    app: mangueuiv2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mangueuiv2
  template:
    metadata:
      creationTimestamp:
      labels:
        app: mangueuiv2
    spec:
      containers:
      - name: mangueuiv2
        image: magueio/mangueuiv2:tlmx-v1.1.0
        imagePullPolicy: Always
        resources:
          limits:
            cpu: 250m
            memory: 200Mi
          requests:
            cpu: 150m
            memory: 100Mi
        volumeMounts:
        - mountPath: /usr/share/nginx/html/assets/apis
          name: mangueui-config
      volumes:
      - configMap:
          name: mangueui-config
        name: mangueui-config
EOF
}

createConfigMaps() {
cat << EOF > mangue-cluster/configmaps/mangue-cluster-market-cm.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mangueui-config
data:
    config.json: |
        {
         "MARKET_URL": "http://$1:32582/api/",
         "SERVER_URL": "http://$1:32588/api/",
         "BILLING_URL": "http://$1:30995/"
        }
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: umarket-config
data:
    config.json: |
        {
         "SERVER_URL": "http://$1:31441/api/",
         "BILLING_URL": "http://$1:30995/",
         "MANGUE_SERVER_URL": "http://$1:32588/api/"
        }
EOF
}

user="$1"
cluster_name="$2"
user_group="$3"
kube_ip="$4"
db_ip="$5"
ucloud="$6"

#echo "P$Market#.01" | sudo -S su
#sudo su

printf "\n---------- CRIANDO NAMESPACE USTORE -----------\n"
kubectl create ns ustore

printf "\n---------- CRIANDO ARQUIVOS DE CONFIGURACAO DO MANGUE-UI E DO UMARKET-UI ----------\n"
createConfigMaps $kube_ip
kubectl create -f mangue/configmaps/mangue-market-cm.yml -n ustore

printf "\n---------- LEVANTANDO APLICACOES DO MANGUE ----------\n"
createAppsYamls $db_ip
kubectl create -f mangue_apps.yml -n ustore

if [ $ucloud == "ucloud" ]; then
    printf "\n---------- JA POSSUO PRIVILEGIOS DE ACESSO REMOTO AO DB ----------\n"
else
    printf "\n---------- DANDO PRIVILEGIOS DE ACESSO REMOTO AO DB ----------\n"
    mysql -u root -pBHU*nji9 -h$db_ip < mysql_root_privileges.sql
    sed 's/^bind-address/#&/' /etc/mysql/mysql.conf.d/mysqld.cnf > /etc/mysql/mysql.conf.d/mysqld.cnf
fi

printf "\n---------- CRIANDO DB MANGUE -----------\n"
mysql -u root -pBHU*nji9 -h$db_ip < mangue_create_db.sql

printf "\n-------- AGUARDANDO MANGUE-CLUSTER ----------\n"
checkDeploy mangue-cluster 1/1

printf "\n---------- SETANDO PERMISSOES -----------\n"
bash createUser.sh $user $cluster_name $user_group $kube_ip

printf "\n---------- LEVANTANDO METRICS-SERVER ----------\n"
bash billing_metrics_server.sh $kube_ip

printf "\n---------- CRIANDO DB BILLING E SETANDO TABELAS E TRIGGER ----------\n"
mysql -u root -pBHU*nji9 -h$db_ip < billing.sql

printf "\n---------- LEVANTANDO MANGUE-BILLING ----------\n"
createBillingYaml $db_ip
kubectl create -f mangue-billing.yml -n ustore

printf "\n---------- LEVANTANDO UMARKET ----------\n"
mysql -u root -pBHU*nji9 -h$db_ip < umarket_create_db.sql
createUmarketYamls $db_ip
kubectl create -f umarket.yml -n ustore

printf "\n-------- ACABEI O SCRIPT!! ----------\n"

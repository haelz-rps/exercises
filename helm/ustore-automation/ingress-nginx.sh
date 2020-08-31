
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
git clone https://github.com/kubernetes/ingress-nginx.git
cd ingress-nginx/charts/ingress-nginx/
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install my-release ingress-nginx/ingress-nginx \
    --set controller.metrics.enabled=true


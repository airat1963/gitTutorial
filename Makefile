YC_CLUSTER_NAME := my-ml-service
YC_NETWORK_NAME := mlops-network
YC_ZONE := ru-central1-b
YC_SUBNET_NAME := mlops-network-ru-central1-b
YC_RELEASE_CHANNEL := regular
YC_CLUSTER_IPV4_RANGE := 10.3.0.0/16
YC_SERVICE_IPV4_RANGE := 10.4.0.0/16
YC_NODE_SERVICE_ACCOUNT_NAME := mlops-service-account
YC_SERVICE_ACCOUNT_NAME := mlops-service-account

# Цели
.PHONY: create-cluster create-node-group get-credentials apply-manifests install-ingress-controller setup delete-cluster create-dns-zone

create-cluster:
	@echo "Создание кластера Kubernetes..."
	yc managed-kubernetes cluster create \
		--name $(YC_CLUSTER_NAME) \
		--network-name $(YC_NETWORK_NAME) \
		--zone $(YC_ZONE) \
		--subnet-name $(YC_SUBNET_NAME) \
		--public-ip \
		--release-channel $(YC_RELEASE_CHANNEL) \
		--cluster-ipv4-range $(YC_CLUSTER_IPV4_RANGE) \
		--service-ipv4-range $(YC_SERVICE_IPV4_RANGE) \
		--node-service-account-name $(YC_NODE_SERVICE_ACCOUNT_NAME) \
		--service-account-name $(YC_SERVICE_ACCOUNT_NAME)

create-node-group:
	@echo "Создание группы узлов..."
	yc managed-kubernetes node-group create \
		--cluster-name $(YC_CLUSTER_NAME) \
		--name my-node-group \
		--platform standard-v2 \
		--memory 4 \
		--cores 2 \
		--core-fraction 100 \
		--disk-type network-ssd \
		--disk-size 64 \
		--fixed-size 3 \
		--preemptible \
		--network-interface subnets=$(YC_SUBNET_NAME),ipv4-address=nat

get-credentials:
	@echo "Получение учетных данных для кластера..."
	yc managed-kubernetes cluster get-credentials $(YC_CLUSTER_NAME) --external

install-ingress-controller:
	@echo "Установка NGINX Ingress Controller..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/cloud/deploy.yaml

apply-manifests:
	@echo "Применение манифестов в кластере..."
	kubectl apply -f deployment.yaml
	kubectl apply -f service.yaml
	kubectl apply -f ingress.yaml

create-dns-zone:
	@echo "Создание новой зоны DNS..."
	yc dns zone create --name my-dns-zone --zone my-new-domain.com. --public-visibility
	@echo "Добавление DNS-записи..."
	yc dns recordset add-records --name my-new-domain.com. --type A --ttl 300 --record "51.250.41.124"

delete-cluster:
	@echo "Удаление кластера Kubernetes..."
	yc managed-kubernetes cluster delete $(YC_CLUSTER_NAME)

# Основная цель
setup: create-cluster create-node-group get-credentials install-ingress-controller apply-manifests create-dns-zone

docker-build:
	@echo "docker build"
	yc docker build -t my-ml-service:latest .

docker-run:
	@echo "docker run "
	yc docker run -d -p 8000:8000 my-ml-service:latest

docker-test:
	@echo  "docker test"
	yc curl -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d '{"day": 5}'
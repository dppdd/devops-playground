#!/bin/bash

# We assume that the env is ready with docker.
# We run Prometheus as Docker, and docker exports metrics to Prometheus


echo_() {
    terminalColorWarning='\033[1;34m'
    terminalColorClear='\033[0m'
    echo -e "${terminalColorWarning}$1${terminalColorClear}"
}

echo_ " ----- Mod Firewall -----"

firewall-cmd --add-port=9090/tcp --permanent
firewall-cmd --add-port=9323/tcp --permanent
firewall-cmd --add-port=8081/tcp --permanent
firewall-cmd --add-port=8082/tcp --permanent
firewall-cmd --reload


echo_ " ----- Configure Docker's metrics -----"

my_ip=$(hostname -I | cut -d ' ' -f 1)
cat << EOF > /etc/docker/daemon.json
{
  "metrics-addr" : "${my_ip}:9323",
  "experimental" : true
}
EOF

echo_ " ----- Docker restart -----"
systemctl restart docker

echo_ " ----- Define Docker's metrics -----"
mkdir -p /etc/prometheus
touch /etc/prometheus/prometheus.yml


cat << EOF > /etc/prometheus/prometheus.yml
  # my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
      monitor: 'codelab-monitor'

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first.rules"
  # - "second.rules"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ['${my_ip}:9090']

  - job_name: 'docker-container-metrics'
         # metrics_path defaults to '/metrics'
         # scheme defaults to 'http'.

    static_configs:
      - targets: ['${my_ip}:8081','${my_ip}:8082']

  - job_name: 'docker system'
         # metrics_path defaults to '/metrics'
         # scheme defaults to 'http'.

    static_configs:
      - targets: ['${my_ip}:9323']
EOF

echo_ " ----- Start Swarm Cluster -----"
docker swarm init
docker service create --replicas 1 --name my-prometheus --mount type=bind,source=/etc/prometheus/prometheus.yml,destination=/etc/prometheus/prometheus.yml     --publish published=9090,target=9090,protocol=tcp     prom/prometheus

echo_ " ----- Install Grafana -----"

docker volume create grafana
docker run -d -p 3000:3000 --name grafana --rm -v grafana:/var/lib/grafana grafana/grafana-oss


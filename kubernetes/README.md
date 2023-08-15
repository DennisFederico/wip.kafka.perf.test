# Build

## Local Build Image

```shell
docker build -t dfederico/kafka-perf-base .
```

## Remote Image Deploy

```shell
# Add tag to the local build
docker tag dfederico/kafka-perf-base europe-west1-docker.pkg.dev/solutionsarchitect-01/dfederico/kafka-perf-base

# Push tag
docker push europe-west1-docker.pkg.dev/solutionsarchitect-01/dfederico/kafka-perf-base
```

## Deploy in K8s

### CA Certificate Secret

```shell
kubectl create secret generic kafka-ca-cert \
  --from-file=cacert.pem=./configs/CAcert.pem \
  --namespace confluent
```

OR using the deployment descriptor

```shell
# EDIT and Encode the secret according using base64 command
kubectl apply -f ./deployments/secrets/secret-kafka-ca.yaml 
```

### Connection to Kafka Properties as Secret

```shell
kubectl create secret generic kafka-connection-properties \
  --from-file=connection.properties=./configs/connection.properties \
  --namespace confluent
```

OR using the deployment descriptor

```shell
# EDIT and Encode the secret according using base64 command
kubectl apply -f ./deployments/secrets/secret-kafka-properties.yaml 
```

### Producer Perf Test connection properties

```shell
kubectl apply -f deployments/secrets/secret-producer-properties.yaml
```

### Consumer Perf Test connection properties

```shell
kubectl apply -f deployments/secrets/secret-consumer-properties.yaml
```

## Running Jobs

There are 4 "tasks" available:

- Create topics (create_topics.sh)
- Delete topcs (delete_topics.sh)
- Producer perf test (producer_perf.sh)
- Consumer perf test (consumer_perf.sh)

Each require a configmap to define the environment variables needed to run the script backed on the image

| Task | ConfigMapFile | DeploymentFile | JobName |
|---|---|---|---|
| Create Topics | configmap-createtopics.yaml | job-create-topics.yaml | job-create-topics |
| Delete Topics | configmap-createtopics.yaml | job-delete-topics.yaml | job-delete-topics |
| Producer Perf | configmap-producer-perf.yaml | job-producer-perf.yaml | job-producer-perf |
| Consumer Perf | configmap-consumer-perf.yaml | job-consumer-perf.yaml | job-consumer-perf |

### Configmap for env variables

Examples available in `/deployments/configmaps` folder.

```shell
kubectl apply -f ./deployments/configmaps/<ConfigMapFile>
```

### Deploy the job

Examples available in `/deployments/jobs` folder.

```shell
kubectl apply -f ./deployments/jobs/<DeploymentFile>
```

### Check the logs

Once completions have reached the desired number you can use it to parse and report the results

```shell
kubectl logs job <JobName>
```

### Remove the job

```shell
kubectl delete -f ./deployments/jobs/<DeploymentFile>

#OR

kubectl delete job <JobName>
```

## DEV NOTES

Run tester pod...

```shell
kubectl apply -f deployments/tester-pod.yaml

kubectl exec -it pod/kafka-perf-tester -- bash

kubectl delete -f deployments/tester-pod.yaml
```

Base64 encoding

`openssl base64 -A -in myfile.binary`

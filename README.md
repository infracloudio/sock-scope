# Weave Scope implementation to trace sock shop

## Pre requisites

* A running GKE cluster with context set in kubectl


## Steps for implementation

Run the `runme.sh` script which will do following: 

* Install sock shop and check if all pods are ready
* Install load test containers to simulate traffic on the application
* Install weave scope
* At the end of execution, an IP of a LoadBalancer is displayed. Use this IP to open weave scope.
* Notice various traffic flowing from frontend pod. As the load test container runs in loop, the arrows keep going on and off every few seconds.
* Change the deployment image to `harshals/sock-load-test:only-login` this triggers only login flow and hence only few arrows are seen related to login flow.

## Cleanup

Run `runme.sh cleanup` to delete all resources.

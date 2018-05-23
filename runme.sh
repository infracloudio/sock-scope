#!/bin/bash

#
# Script to install sock-shop and then install weave scope 
#

REPO_ROOT=${PWD};
POD_READY_RETRY_COUNT=20;
POD_READY_RETRY_SECS=10;

install_sock_shop(){
     echo "------------------ Start installation of sock shop ---------------------------------------------";
     kubectl create ns sock-shop;
     kubectl apply -f ${REPO_ROOT}/sock-manifests/
}

check_all_pods(){
     all_true=0;
     for w in $(kubectl get po -n sock-shop -o jsonpath='{.items[*].status.containerStatuses[*].ready}')
     do
     if [[ "$w" != "true" ]]; then
         all_true=1
	 break;
     fi
     done
     return $all_true;
}


check_all_pods_ready(){
    all_pods=1;
    echo "---------------------------- checking if all pods are ready ---------------------------------";
    for n in $(seq $POD_READY_RETRY_COUNT)
    do
	    check_all_pods
	    all_pods=$?
	    if [[ $all_pods -eq 0 ]]; then
		    echo "--- Found all pods ready ----";
		    all_pods=0;
		    break;
            else
		    echo "Not all pods are ready, retrying (Attempt $n of $POD_READY_RETRY_COUNT)";
		    sleep $POD_READY_RETRY_SECS;
            fi
    done
    if [[ $all_pods -ne 0 ]]; then
	    echo "ERROR: Could not find all pods in ready state. Exiting";
	    exit 1;
    fi


}


install_weave_scope(){
   kubectl create clusterrolebinding "cluster-admin-$(whoami)" --clusterrole=cluster-admin --user="$(gcloud config get-value core/account)"
   kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
   kubectl patch svc  weave-scope-app -n weave -p '{"spec":{"type": "LoadBalancer"}}'
   echo "========== Sleeping few seconds to assign public IP ===========";
   sleep 40;
   PUB_IP=$(kubectl get svc weave-scope-app -n weave -o jsonpath='{.status.loadBalancer.ingress[*].ip}')
   echo "Weave scope is available on IP $PUB_IP ";
}


cleanup(){
	kubectl delete ns weave
	kubectl delete ns sock-shop
	kubectl delete ns loadtest
}


##### MAIN ######

if [[ "$1" == "cleanup" ]]; then

	cleanup
	sleep 30;
	exit 0
fi

install_sock_shop
check_all_pods_ready;
install_weave_scope;

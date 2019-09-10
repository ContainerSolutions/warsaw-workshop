# Recreate deployment

```
# open a second terminal in your browser
$ watch 'kubectl get po'

# create v1 deployment
$ kubectl apply -f app-v1.yaml

# create service
$ kubectl apply -f service.yaml

# open a third browser terminal
$ externalip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type == "ExternalIP")].address}') 
$ nodeport=$(kubectl get svc my-app -o jsonpath="{.spec.ports[0].nodePort}")
$ watch curl ${externalip}:${nodeport}

# deploy v2 of the app
$ kubectl apply -f app-v2.yaml

# clean-up
$ kubectl delete -f .
```

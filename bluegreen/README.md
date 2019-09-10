# Blue/Green deployment

```
# open a second terminal in your browser
$ watch 'kubectl get po'

# apply all the yaml files
$ kubectl apply -f .

# open a third browser terminal
$ externalip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type == "ExternalIP")].address}') 
$ nodeport=$(kubectl get svc my-app -o jsonpath="{.spec.ports[0].nodePort}")
$ watch curl ${externalip}:${nodeport}

# change the service to point to v2 of the app
$ sed -i 's/v1.0.0/v2.0.0/g' service.yaml

# reapply the service definition
$ kubectl apply -f service.yaml

# clean-up
$ kubectl delete -f .
```

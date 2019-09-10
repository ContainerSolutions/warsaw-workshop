# Canary deployment

```
# open a second terminal in your browser
$ watch 'kubectl get po'

# replace the uri prefix in istio.yaml (change your_group_name to your group name)
$ sed -i 's/CHANGE_ME/your_group_name/g' istio.yaml

# apply all the yaml files
$ kubectl apply -f .

# from several local terminals (use the browser env if you need to) peg the endpoint
watch -n .1 curl <ISTIO_INGRESS_IP>/your_group_name

# in another browser terminal watch the status of the horizontal pod autoscaler
$ watch kubectl get hpa

# change the virtual service traffic distribution to 50/50
$ vi istio.yaml

# reapply the istio definitions
$ kubectl apply -f istio.yaml

# change the virtual service traffic distribution to 0/100
$ vi istio.yaml

# reapply the istio definitions
$ kubectl apply -f istio.yaml

# clean-up
$ kubectl delete -f .
```

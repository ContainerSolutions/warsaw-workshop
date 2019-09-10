# A/B testing

```
# open a second terminal in your browser
$ watch 'kubectl get po'

# replace the uri prefix in istio.yaml (change your_group_name to your group name)
$ sed -i 's/CHANGE_ME/your_group_name/g' istio.yaml

# apply all the yaml files
$ kubectl apply -f .

# open the endpoint from firefox and chrome to see that each one serves
# different versions, or use curl
$ curl <ISTIO_INGRESS_IP>/your_group_name -H "User-Agent: Chrome"
$ curl <ISTIO_INGRESS_IP>/your_group_name -H "User-Agent: Firefox"

# clean-up
$ kubectl delete -f .
```

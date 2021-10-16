eksctl utils associate-iam-oidc-provider --region eu-west-1 --cluster esleCluster --approve --profile ddmdavid
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.1/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam-policy.json --profile ddmdavid
eksctl create iamserviceaccount --cluster=esleCluster --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::130767921673:policy/AWSLoadBalancerControllerIAMPolicy --override-existing-serviceaccounts --approve --profile ddmdavid --region eu-west-1
helm repo add eks https://aws.github.io/eks-charts
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=esleCluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

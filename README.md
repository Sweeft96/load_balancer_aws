# Load Balancers on AWS
Different variants to configure load balancer on AWS

## First variant (HAProxy)
After the launch terraform
```
$ terraform apply
```
One server is being created for HAProxy and three more servers.
We get an automatically configured haproxy.cfg and inventory file for ansible.
It remains only to open the directory with ansible playbook and run it.
```
$ ansible-playbook haproxy.yml
```
As a result, we got 4 servers with configured load balancer on HAProxy

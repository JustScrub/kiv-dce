import json, sys, os

if __name__ == '__main__':
    tf_state_file = sys.argv[1]
    with open(tf_state_file) as f:
        tf_state = json.load(f)

    backend_ips = tf_state['outputs']['backend-ips']['value']
    frontend_ips = tf_state['outputs']['frontend-ips']['value']

    # add to known_hosts
    for ip in backend_ips + frontend_ips:
        os.system(f"ssh-keyscan -H {ip} >> ~/.ssh/known_hosts")

    if(len(sys.argv) > 2):
        backend_ips.append(frontend_ips[0])
    
    backend_ips = '\n'.join(backend_ips)
    frontend_ips = '\n'.join(frontend_ips)

    inventory = '\n'.join(['[backends]', backend_ips, '', '[load_balancer]', frontend_ips])

    print(inventory)
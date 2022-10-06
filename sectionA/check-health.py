import sys, requests, json, paramiko

hosts = sys.argv[1:2]
human_output = True
hosts_with_errors = []

def check_webserver(ip):
    try:
        status_code = requests.get("http://"+ip).status_code
        if human_output:
            print("{} response code was {}".format(ip, status_code))
        return status_code
    except Exception as e:
        if human_output:
            print("Connection error to "+ip)
        return -1

#def check_ssh():
#    try:
#        ssh = paramiko.SSHClient()
#        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
#        ssh.connect(ip, username=adminuser, key_filename="id_rsa")
#        check_service()
#    except (BadHostKeyException, AuthenticationException, 
#        SSHException, socket.error) as e:
#        
#        print(e)
#        return -1


if hosts == [] or None:
    if human_output:
        print("Proceeding with machines deployed by terraform on port 80")
    tfstate = json.load(open('./terraform.tfstate'))
    hosts = tfstate['outputs']['vm_public_ips']['value']

for host in hosts:
    response = check_webserver(host)
    if response < 0 or response > 500:
        hosts_with_errors.append(host)
        #check_ssh(ip)
print("Hosts with errors:")
print(hosts_with_errors)

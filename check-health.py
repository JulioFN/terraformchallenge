import sys, requests, json, socket, paramiko

human_output = True


hosts = []
if len(sys.argv) == 2:
    hosts = sys.argv[1].split(",")
hosts_with_errors = []

def check_webserver(ip):
    try:
        status_code = requests.get("http://"+ip, timeout=7).status_code

        if human_output:
            print("{} response code was {}".format(ip, status_code))

        return status_code

    except Exception as e:

        if human_output:
            print("{} connection error".format(ip))

        return -1

def is_ssh_reachable(ip, port=22):
    try:
        test_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        test_socket.settimeout(7)
        test_socket.connect((ip, port))

        if human_output:
            print("{} is accepting connections on port {}".format(ip,port))

    except Exception as ex:

        if human_output:
            print("{} is unavailable on port {}".format(ip,port))

        return False
    else:
        test_socket.close()
    return True



if hosts == [] or None:

    if human_output:
        print("Proceeding with machines deployed by terraform on port 80")

    tfstate = json.load(open('./terraform.tfstate'))
    hosts = tfstate['outputs']['vm_public_ips']['value']

for host in hosts:
    response = check_webserver(host)
    if response < 0 or response > 500:
        ssh_reachable = is_ssh_reachable(host)
        hosts_with_errors.append({"host": host, "ssh_reachable": ssh_reachable})

if human_output:
    print("Hosts with errors:")
print(hosts_with_errors)




#def auto_ssh():
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

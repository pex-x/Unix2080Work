import socket

SERVER_HOST = '127.0.0.1'
SERVER_PORT = 12345
stuId = '110761434'
name = 'Nicholas O'

'''
AF is Address Family, which tells socket what it can comminicate with, 
INET is for IPv4.

SOCK Stream is TCP and sends over packets until communicaition is terminated. 
'''
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

#Binding to socket.
server.bind((SERVER_HOST, SERVER_PORT))

server.listen(1)
print("Server is running on " + SERVER_HOST + ' Port ' + SERVER_PORT)


client, client_address = server.accept()
print("Client connected...")

while True:
    data = client.recv(1024).decode('utf-8')
    
    if data == stuId:
        response = name
    else:
        response = "Sorry, nothing to show, please try again later."

    client.send(response.encode('utf-8'))

client.close()
server.close()
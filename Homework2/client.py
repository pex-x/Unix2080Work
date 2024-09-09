# Nicholas Olsen | 110761434

import socket

SERVER_HOST = '127.0.0.1'
SERVER_PORT = 12345

client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect((SERVER_HOST, SERVER_PORT))

stuId = input("Please Enter a Student ID: ")

client_socket.send(stuId.encode('utf-8'))

response = client_socket.recv(1024).decode('utf-8')
print("Server Response: " + response)

client_socket.close()
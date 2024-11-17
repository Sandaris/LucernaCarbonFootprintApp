import socket
import json
from flask import Flask, jsonify
import threading
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Global variable to store the latest data
latest_data = {
    "light": "0",
    "temperature": "0",
    "carbon": "0",
    "algaeBiomass": "False"
}

def socket_server():
    global latest_data
    # Set up the server socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_ip = "0.0.0.0"  # Listen on all available interfaces
    server_port = 12345
    client_error = 0

    # Bind the socket to the address and port
    server_socket.bind((server_ip, server_port))
    server_socket.listen(1)

    print(f"Server listening on {server_ip}:{server_port}")

    while True:
        # Accept a connection from a client
        client_socket, addr = server_socket.accept()
        print(f"Connection from {addr}")

        # Set a timeout of 10 seconds to break the loop if no data is received
        client_socket.settimeout(10.0)  # Set timeout to 10 seconds

        try:
            while True:
                try:
                    # Receive data from the client
                    data = client_socket.recv(1024)

                    # If recv returns an empty byte string, the client has disconnected
                    if not data:
                        print("Client disconnected.")
                        break

                    # Decode and process data
                    data = data.decode()
                    data_dict = json.loads(data)

                    # Extracting data from the dictionary
                    light = data_dict["light"]
                    temperature = data_dict["temperature"]
                    carbon = data_dict["Carbon"]
                    algae_biomass = data_dict["algaeBiomass"]

                    # Store the extracted values in latest_data
                    latest_data = {
                        "light": str(light),
                        "temperature": str(temperature),
                        "carbon": str(carbon),
                        "algaeBiomass": str(algae_biomass)
                    }

                    # Print the extracted values
                    print(f"Light: {light}")
                    print(f"Temperature: {temperature}")
                    print(f"Carbon: {carbon}")
                    print(f"Algae Biomass: {algae_biomass}")

                except socket.timeout:
                    # If no data is received within the timeout, break the loop
                    print("No data received for 10 seconds. Closing the connection.")
                    break

                except (ConnectionResetError, BrokenPipeError):
                    # Handle client disconnection or broken pipe
                    print("Connection lost. Closing the connection.")
                    break

                except json.JSONDecodeError:
                    # Handle invalid JSON data received
                    print("Received invalid JSON data.")

        finally:
            # Ensure the client socket is closed after the connection is lost or ended
            client_socket.close()
            print("Connection closed.")
            client_error = 1

        if client_error == 1:
            print("Client error. Trying to reconnect...")

@app.route('/getData', methods=['GET'])
def get_data():
    return jsonify(latest_data)

def run_flask():
    app.run(host='0.0.0.0', port=5001)

if __name__ == "__main__":
    # Start the socket server in a separate thread
    threading.Thread(target=socket_server).start()
    # Start the Flask app
    run_flask()

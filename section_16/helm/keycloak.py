import os
import requests
import json
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Get variables from the .env file
KEYCLOAK_URL = os.getenv("KEYCLOAK_URL")
POSTMAN_API_KEY = os.getenv("POSTMAN_API_KEY")
ENVIRONMENT_NAME = os.getenv("ENVIRONMENT_NAME")

# Admin credentials
username = "user"
password = "password"

def get_admin_token():
    url = f"{KEYCLOAK_URL}/realms/master/protocol/openid-connect/token"
    data = {
        "username": username,
        "password": password,
        "grant_type": "password",
        "client_id": "admin-cli"
    }
    response = requests.post(url, data=data)
    return response.json()["access_token"]

def role_exists(access_token, role_name):
    url = f"{KEYCLOAK_URL}/admin/realms/master/roles/{role_name}"
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(url, headers=headers)
    return response.status_code == 200

def create_role(access_token, role_name):
    if role_exists(access_token, role_name):
        print(f"Role '{role_name}' already exists. Skipping creation.")
        return {"name": role_name, "id": get_role_id(access_token, role_name)}
    
    url = f"{KEYCLOAK_URL}/admin/realms/master/roles"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    data = {"name": role_name}
    
    response = requests.post(url, headers=headers, json=data)
    
    # Check if the role was created successfully (status 201)
    if response.status_code == 201:  # HTTP 201 Created
        print(f"Role '{role_name}' created successfully.")
        # Retrieve the role ID after creation
        role_id = get_role_id(access_token, role_name)
        return {"name": role_name, "id": role_id}
    else:
        print(f"Failed to create role '{role_name}'. Status code: {response.status_code}")
        print("Response content:", response.text)
        return None

def get_role_id(access_token, role_name):
    url = f"{KEYCLOAK_URL}/admin/realms/master/roles/{role_name}"
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()["id"]
    raise ValueError(f"Role '{role_name}' does not exist")

def client_exists(access_token, client_id):
    url = f"{KEYCLOAK_URL}/admin/realms/master/clients?clientId={client_id}"
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(url, headers=headers)
    return len(response.json()) > 0

def create_client(access_token):
    client_id = "eazybank-callcenter-cc"
    if client_exists(access_token, client_id):
        print(f"Client '{client_id}' already exists. Skipping creation.")
        # Retrieve existing client ID
        url = f"{KEYCLOAK_URL}/admin/realms/master/clients?clientId={client_id}"
        headers = {"Authorization": f"Bearer {access_token}"}
        response = requests.get(url, headers=headers)
        return response.json()[0]["id"]
    
    url = f"{KEYCLOAK_URL}/admin/realms/master/clients"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    client_data = {
        "clientId": client_id,
        "name": "EazyBank Call Center App",
        "description": "EazyBank Call Center App",
        "enabled": True,
        "publicClient": False,
        "serviceAccountsEnabled": True,
        "authorizationServicesEnabled": True,
        "standardFlowEnabled": False,
        "directAccessGrantsEnabled": False,
        "clientAuthenticatorType": "client-secret",
        "protocol": "openid-connect"
    }
    response = requests.post(url, headers=headers, json=client_data)

    # Check if client was created successfully
    if response.status_code == 201:  # HTTP 201 Created
        print(f"Client '{client_id}' created successfully.")
        # Extract the client ID from the Location header
        client_url = response.headers["Location"]
        client_id = client_url.split("/")[-1]  # Get the last part of the URL
        return client_id
    else:
        print(f"Failed to create client '{client_id}'. Status code: {response.status_code}")
        print("Response content:", response.text)
        return None

def assign_roles_to_service_account(access_token, client_id, roles):
    # Get the service account user ID
    url = f"{KEYCLOAK_URL}/admin/realms/master/clients/{client_id}/service-account-user"
    headers = {"Authorization": f"Bearer {access_token}"}
    user_id = requests.get(url, headers=headers).json()["id"]

    # Get existing roles assigned to the service account user
    assigned_roles_url = f"{KEYCLOAK_URL}/admin/realms/master/users/{user_id}/role-mappings/realm"
    assigned_roles_response = requests.get(assigned_roles_url, headers=headers)
    assigned_roles = assigned_roles_response.json() if assigned_roles_response.status_code == 200 else []

    # Extract the names of already assigned roles
    assigned_role_names = {role["name"] for role in assigned_roles}

    # Assign only the roles that are not yet assigned
    for role in roles:
        if role["name"] not in assigned_role_names:
            role_data = [{"id": role["id"], "name": role["name"]}]
            role_url = f"{KEYCLOAK_URL}/admin/realms/master/users/{user_id}/role-mappings/realm"
            response = requests.post(role_url, headers=headers, json=role_data)
            if response.status_code == 204:  # HTTP 204 No Content indicates success
                print(f"Role '{role['name']}' assigned to service account user.")
            else:
                print(f"Failed to assign role '{role['name']}' to service account user. Status code: {response.status_code}")
        else:
            print(f"Role '{role['name']}' is already assigned to service account user. Skipping assignment.")

def get_client_secret(access_token, client_id):
    url = f"{KEYCLOAK_URL}/admin/realms/master/clients/{client_id}/client-secret"
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(url, headers=headers)
    return response.json()["value"]

def get_environment_id():
    headers = {
        "X-Api-Key": POSTMAN_API_KEY
    }
    response = requests.get("https://api.getpostman.com/environments", headers=headers)
    environments = response.json().get("environments", [])
    
    for env in environments:
        if env["name"] == ENVIRONMENT_NAME:
            return env["id"]
    raise ValueError(f"Environment '{ENVIRONMENT_NAME}' not found.")

def update_postman_variable(client_secret):
    environment_id = get_environment_id()
    postman_api_url = f"https://api.getpostman.com/environments/{environment_id}"
    
    headers = {
        "X-Api-Key": POSTMAN_API_KEY,
        "Content-Type": "application/json"
    }
    payload = {
        "environment": {
            "values": [
                {
                    "key": "ClientSecret_CC",
                    "value": client_secret,
                    "enabled": True
                }
            ]
        }
    }
    response = requests.put(postman_api_url, headers=headers, json=payload)
    if response.status_code == 200:
        print("ClientSecret_CC updated in Postman successfully.")
    else:
        print("Failed to update Postman variable:", response.json())

# Main script execution
if __name__ == "__main__":
    # Step 1: Authenticate
    token = get_admin_token()

    # Step 2: Create roles
    roles = []
    for role_name in ["ACCOUNTS", "CARDS", "LOANS"]:
        role = create_role(token, role_name)
        roles.append(role)

    # Step 3: Create client
    client_id = create_client(token)

    # Step 4: Assign roles to service account
    assign_roles_to_service_account(token, client_id, roles)

    # Step 5: Retrieve client secret and update in Postman
    client_secret = get_client_secret(token, client_id)
    update_postman_variable(client_secret)

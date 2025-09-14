import os
import shutil

REGION = os.environ.get("AWS_REGION")
ACCESS_KEY = os.environ.get("AWS_ACCESS_KEY_ID")
SECRET_KEY = os.environ.get("AWS_SECRET_ACCESS_KEY")

def main():
    env = get_environment()
    replace_placeholders(env)

def replace_placeholders(env):

    tfvars_path = "../iac/terraform.tfvars"
    backend_path = "../iac/provider.tf"

    with open (tfvars_path, "r") as f:
        tfvars = f.read()
    tfvars = tfvars.replace("access_key_placeholder", str(ACCESS_KEY))
    tfvars = tfvars.replace("secret_key_placeholder", str(SECRET_KEY))
    tfvars = tfvars.replace("env_placeholder", str(env))
    tfvars = tfvars.replace("aws_region_placeholder", str(REGION))
    with open(tfvars_path, "w") as f:
        f.write(tfvars)

    with open(backend_path, "r") as f:
        backend_config = f.read()
    backend_config = backend_config.replace("access_key_placeholder", str(ACCESS_KEY))
    backend_config = backend_config.replace("secret_key_placeholder", str(SECRET_KEY))
    backend_config = backend_config.replace("aws_region_placeholder", str(REGION))
    backend_config = backend_config.replace("key_placeholder", f"intens-praksa/{env}/terraform.tfstate")
    with open(backend_path, "w") as f:
        f.write(backend_config) 


def get_environment():
    curr_env = os.environ.get("GITHUB_REF", "")
    curr_env_parts = curr_env.split("/")
    curr_env = curr_env_parts[-1]

    return curr_env


########## START ###########
if __name__ == "__main__":
    main()
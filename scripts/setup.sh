#!/bin/bash

clear

# Expect parent to have Nargo.toml
nargo_toml_file_path="$(dirname "$0")/../Nargo.toml"

# Exit when Nargo.toml is missing from parent folder
if [ ! -f "$nargo_toml_file_path" ]; then
    echo -e "\e[32m/Nargo.toml missing\e[0m\n"
    exit 1
fi

# Check noirup
if [ ! -f ~/.nargo/bin/noirup ]; then
    echo -e "Sourcing \e[32mnoirup\e[0m...\n"
    curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash

    echo -e "\nReloading \e[32mbash environment\e[0m...\n"
    source ~/.bashrc
fi

echo -e "Checking \e[32mNargo\e[0m version...\n"

# Extract version from Nargo.toml: take the version line, split it by ",", and echo the 2nd element from that array
version=$(grep 'compiler_version[ ]*=[ ]*' $nargo_toml_file_path | awk -F '"' '{print $2}')

# Check nargo
if [ ! -f ~/.nargo/bin/nargo ]; then
    echo -e "\e[1A\e[32mNargo\e[0m is \e[31mmissing\e[0m.\n\nSourcing \e[32mNargo\e[0m \e[33m$version\e[0m...\n"
    noirup -v $version
else
    # Extract local version of nargo
    local_version=$(nargo --version | awk -F ' ' '/nargo version/ {print $4}')

    if [ "$local_version" != "$version" ]; then
        echo -e "Found mismatch between the local Nargo version (\e[34m$local_version\e[0m) and this project's required Nargo version (\e[33m$version\e[0m)."
        echo -e "\nSourcing \e[32mNargo\e[0m \e[33m$version\e[0m...\n"
        noirup -v $version
    fi
fi

# Should have a nargo binary present, unless requested version artefact is also missing from GitHub server
if [ ! -f ~/.nargo/bin/nargo ]; then
    echo -e "\n\e[31mFailed to source requested \e[32mNargo\e[0m \e[31mversion \e[33m$version\e[31m.\e[0m\n"
    exit 1
fi

local_version=$(nargo --version | awk -F ' ' '/nargo version/ {print $4}')

# Should have the requested nargo version downloaded, unless it's missing from GitHub server
if [ "$local_version" != "$version" ]; then
    echo -e "\n\e[31mFailed to source requested \e[32mNargo\e[0m \e[31mversion \e[33m$version\e[31m.\e[0m\n"
    exit 1
fi

echo -e "\e[32mNargo\e[0m version \e[33m$version\e[0m is available.\n"

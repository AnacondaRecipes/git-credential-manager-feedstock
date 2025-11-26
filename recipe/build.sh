set -eoux pipefail

if [[ "${target_platform}" == linux-64 ]]
then
  export RUNTIME="linux-x64"
elif [[ "${target_platform}" == linux-aarch64 ]]
then
  export RUNTIME="linux-arm64"
elif [[ "${target_platform}" == osx-arm64 ]]
then
  export RUNTIME="osx-arm64"
else
  echo "Unknown target platform: ${target_platform}"
  exit 1
fi

# Switch to conda-dotnet
# See src/linux/Packaging.Linux/layout.sh
export DOTNET_ROOT="$BUILD_PREFIX/lib/dotnet"
export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"

: "${LD_LIBRARY_PATH:=}"
export LD_LIBRARY_PATH="$PREFIX/lib:$BUILD_PREFIX/lib:$LD_LIBRARY_PATH"

if [[ "${target_platform}" == linux-* ]]
then
  export CONFIGURATION=LinuxRelease
  src/linux/Packaging.Linux/layout.sh
  PAYLOAD=out/linux/Packaging.Linux/"$CONFIGURATION"/payload
elif [[ "${target_platform}" == osx-* ]]
then
  export CONFIGURATION=MacRelease
  export PAYLOAD=payload
  src/osx/Installer.Mac/layout.sh
else
  echo "Unknown target platform: ${target_platform}"
  exit 1
fi

# Install script taken from
# https://github.com/git-ecosystem/git-credential-manager/blob/release/src/linux/Packaging.Linux/build.sh

INSTALL_TO="$PREFIX/share/gcm-core/"
LINK_TO="$PREFIX/bin/"

mkdir -p "$INSTALL_TO" "$LINK_TO"
cp -R "$PAYLOAD"/* "$INSTALL_TO"

# Create symlink
ln -s "$INSTALL_TO/git-credential-manager" "$LINK_TO/git-credential-manager"

# Create legacy symlink with older name
ln -s "$INSTALL_TO/git-credential-manager" "$LINK_TO/git-credential-manager-core"

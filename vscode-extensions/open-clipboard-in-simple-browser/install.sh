#!/usr/bin/env bash
# Packages this extension into a .vsix and installs it.
#
# Builds the .vsix by hand (a zip with a vsixmanifest) rather than with
# `npx @vscode/vsce package`, because npx hangs on corp machines without
# registry access and the extension has no dependencies anyway.
#
# Usage:
#   ./install.sh              # build, then install with `code`
#   ./install.sh --build-only # just build the .vsix
#
# Run it from VS Code's integrated terminal so `code` installs into the right
# place: when connected over Remote-SSH, that's the remote VS Code server
# (where GitLens also runs), which is what we want.
set -euo pipefail

cd "$(dirname "$0")"
name=$(node -p "require('./package.json').name")
version=$(node -p "require('./package.json').version")
publisher=$(node -p "require('./package.json').publisher")
out="$PWD/$name-$version.vsix"

staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT
mkdir -p "$staging/extension"
cp package.json extension.js README.md "$staging/extension/"

cat >"$staging/[Content_Types].xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension=".json" ContentType="application/json"/><Default Extension=".js" ContentType="application/javascript"/><Default Extension=".md" ContentType="text/markdown"/><Default Extension=".vsixmanifest" ContentType="text/xml"/></Types>
EOF

cat >"$staging/extension.vsixmanifest" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011">
  <Metadata>
    <Identity Language="en-US" Id="$name" Version="$version" Publisher="$publisher"/>
    <DisplayName>Open Clipboard URL in Simple Browser</DisplayName>
    <Description xml:space="preserve">Opens the URL on the clipboard in VS Code's integrated Simple Browser.</Description>
    <Properties>
      <Property Id="Microsoft.VisualStudio.Code.Engine" Value="^1.80.0"/>
      <Property Id="Microsoft.VisualStudio.Code.ExtensionKind" Value="workspace,ui"/>
    </Properties>
  </Metadata>
  <Installation><InstallationTarget Id="Microsoft.VisualStudio.Code"/></Installation>
  <Dependencies/>
  <Assets><Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true"/></Assets>
</PackageManifest>
EOF

rm -f "$out"
(cd "$staging" && zip -qr "$out" .)
echo "Built $out"

if [[ "${1:-}" != "--build-only" ]]; then
  code --install-extension "$out"
  echo "Installed. Run 'Developer: Reload Window' in VS Code to activate it."
fi

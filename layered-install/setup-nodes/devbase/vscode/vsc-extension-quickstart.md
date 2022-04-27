# Instructions on How to Make Extensions

## Install tools

- `$ bash install-node.sh`
- `$ bash install-vscode-vsce.sh`

## Create New Extension Pack

- Run `$ yo code`
- Select `New Extension Pack`
- Go through the steps in the prompts

## Modifying an Existing Extension Pack

- Modify the `package.json`:
    - The `extensionPack` list contains all the extensions the pack will contain, modifying this list will change what the extension pack will contain

## Packaging Up the Extension Pack

- Once your extension pack looks good, run:
    
    `$ cd myExtension`
    
    `$ vsce package`
    
- This will generate a `.vsix` package file, which can be installed as a vscode extension pack

## **Install your extension**

- To start using your extension with Visual Studio Code copy it into the `<user home>/.vscode/extensions` folder and restart Code.
- Alternative 1: Open the folder that contains the `.vsix` file in Vscode, right click the file, and select “Install Extension VSIX”
- Alternative 2: Open the extensions tab, at the top, select the triple dot menu, and select “Install from VSIX”
- Alternative 3: run `code --install-extension /path/to/extension.vsix`
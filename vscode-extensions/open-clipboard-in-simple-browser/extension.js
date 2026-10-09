// Adds a command that opens the URL currently on the clipboard in VS Code's
// integrated Simple Browser. Intended to be chained after GitLens's
// "copy remote URL" commands via a runCommands keybinding.
const vscode = require('vscode');

function activate(context) {
  context.subscriptions.push(
    vscode.commands.registerCommand('sos.openClipboardInSimpleBrowser', async () => {
      const text = (await vscode.env.clipboard.readText()).trim();
      if (!/^https?:\/\//i.test(text)) {
        vscode.window.showWarningMessage(`Clipboard does not contain a URL: ${text.slice(0, 100)}`);
        return;
      }
      await vscode.commands.executeCommand('simpleBrowser.show', text);
    }),
  );
}

function deactivate() {}

module.exports = { activate, deactivate };

# Raycast Debugging Guide

This file contains useful information for debugging Raycast script commands.

## Debugging Script Commands

### Viewing Script Output

Raycast script commands support different output modes via the `@raycast.mode` header:

- **`silent`** - No output shown (used by our project scripts)
- **`compact`** - Last line of stdout shown in toast
- **`fullOutput`** - Entire output shown in separate view (like a terminal)
- **`inline`** - First line shown directly in command item

To see output from a silent script, temporarily change the mode to `fullOutput` in the script header.

### Enabling Debug Logs for vscode-open

Our Raycast project scripts use the `vscode-open` helper which supports debug logging.

**To enable debug logging:**

1. Edit the script generator template:
   ```bash
   chezmoi edit ~/.local/share/chezmoi/managed/run_onchange_generate-raycast-scripts.sh.tmpl
   ```

2. Uncomment the `--debug` flag line (around line 26):
   ```bash
   # Debug: Uncomment to enable logging to ~/.vscode-open.log
   exec "$HOME/.bin/vscode-open" --debug {{ .path }} "{{ .name }}"
   ```

3. Apply changes:
   ```bash
   chezmoi apply
   ```

4. Watch the log file:
   ```bash
   tail -f ~/.vscode-open.log
   ```

5. Run your Raycast command and observe timing breakdown

6. When done, comment out `--debug` again and reapply

### Redirecting stderr to Log File

For any script, you can redirect stderr to a log file by adding this near the top:

```bash
exec 2>/tmp/myscript.$$.log
```

This will create a log file with the process ID that captures all stderr output.

### Viewing Raycast App Logs

To capture Raycast's internal logs:

```bash
log stream --predicate "subsystem == 'com.raycast.macos'" --level debug --style compact >> ~/Desktop/raycast.$(date +%Y%m%d_%H%M%S).log
```

Then trigger the issue in Raycast and check the timestamped log file on your Desktop.

## Common Issues

### PATH Issues

Raycast scripts don't load your full shell environment (`.zshrc`), so:

- Use absolute paths for executables
- Manually export PATH with needed directories
- Our scripts export: `$HOME/.bin:$HOME/.asdf/shims:/opt/homebrew/bin:/usr/local/bin:$PATH`

### Environment Variables

If your script needs specific environment variables:

```bash
# Load from a lightweight env file
if [ -f "$HOME/.raycast-env" ]; then
    source "$HOME/.raycast-env"
fi
```

### Script Permissions

Raycast scripts must be executable:

```bash
chmod +x ~/.raycast/scripts/projects/*.sh
```

## Resources

- [Debug an Extension | Raycast API](https://developers.raycast.com/basics/debug-an-extension)
- [Getting logs via terminal | Raycast Manual](https://manual.raycast.com/troubleshooting/getting-logs-via-consoleapp)
- [Script Commands Documentation](https://github.com/raycast/script-commands/blob/master/commands/README.md)
- [Output Modes Documentation](https://github.com/raycast/script-commands/blob/master/documentation/OUTPUTMODES.md)
- [Getting started with script commands - Raycast Blog](https://www.raycast.com/blog/getting-started-with-script-commands)

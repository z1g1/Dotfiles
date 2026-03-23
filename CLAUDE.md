# Global Claude Preferences

## Tool Usage

- Never chain Bash commands with `&&` or `;`. Run each command as a separate tool call. Permission allowlist patterns match the full command string, so chaining bypasses them and triggers unnecessary prompts.
- Use parallel tool calls when commands are independent.

## Communication

- Be concise. Lead with the answer or action, not the reasoning.
- Don't ask for confirmation on routine operations that are clearly implied by the request.
- When something fails, explain what went wrong and suggest a fix — don't just retry the same thing.

## Git Workflow

- Write commit messages that explain *why*, not *what*.
- Don't amend commits unless explicitly asked.
- Don't push unless explicitly asked.

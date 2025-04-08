# git-scribe 🧃
a CLI commit message builder to improve the experience of writing actually useful commit messages.

follows the [conventional commit](https://www.conventionalcommits.org/en/about/) specs. 

intended to be used in place of `git commit` + optional no-op (`-n`) and push (`-p`) flags. shell script, so you can treat it like a binary. `bash` and `zsh` compatible. dropdown options are configurable (check the `Makefile` for where they live after `make install`) and are intended to be project-specific.

<img height="370" alt="Screen Shot 2025-04-07 at 9 41 11 PM" src="https://github.com/user-attachments/assets/a3b5d981-63a0-4d56-9fe7-2b96285877f3" /> <br>
<img height="115" alt="Screen Shot 2025-04-07 at 9 41 51 PM" src="https://github.com/user-attachments/assets/7914b5a9-fefb-47bc-9a6b-9e30aea819a9" />
<img height="115" alt="Screen Shot 2025-04-07 at 9 42 07 PM" src="https://github.com/user-attachments/assets/aa1eb1fd-6808-46c3-89b2-6e24d179ed5a" />

built using charmbracelet's [`gum`](https://github.com/charmbracelet/gum). 🌠

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)

# mstdn-editor.vim

Editor-window opener for [mstdn.vim](https://github.com/gw31415/mstdn.vim).

## Usage

Open the window in the manner described below, edit the content, and send it
with `:w`, `ZZ` or etc.

## Installation
Read [this](https://github.com/gw31415/mstdn.vim#installation--config-example).

## API

### Keybinding(s)

| Key                         | Description                                         |
| --------------------------- | --------------------------------------------------- |
| `<Plug>(mstdn-editor-open)` | Open editor window according to the current window. |

### Function(s)

| Function                             | Description                                         |
| ------------------------------------ | --------------------------------------------------- |
| `mstdn#editor#open(user, opts = {})` | Open editor window with specified user and options. |
| `mstdn#editor#set_user(user)`        | Change editing user of the current editor window.   |

### Variable(s)

| Variable                | Description                                          |
| ----------------------- | ---------------------------------------------------- |
| `g:mstdn_editor_opener` | Command used to open the windows. Default is `4new`. |

## Related projects

- [`gw31415/mstdn.vim`](https://github.com/gw31415/mstdn.vim): The dependent plugin. The backend through which this plugin communicates with Mastodon.
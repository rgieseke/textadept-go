### A [Go](http://golang.org) module for the [Textadept](http://foicica.com/textadept/) editor

#### Installation

    cd ~/.textadept/modules
    git clone https://github.com/rgieseke/textadept-go.git go

#### Features

- Snippets
- Run and build commands
- Run source through `gofmt` for automatic formatting before saving
- Highlight syntax errors when saving the file

#### Options

You can configure the go format command in your `.textadept/init.lua`, e.g.:

```lua
_M["go"] = require("go")
_M["go"].format_command = "goimports"
```

#### License

MIT

---
title: Your First Program
sidebar_position: 2
---

This tutorial will show you how to require the module, and create a client.

## Text Editor

The first important step to development of any kind is to pick your text
editor. Any editor that can edit simple text files will work, but things
like notepad might not work for you. I personally use [Visual Studio Code](https://code.visualstudio.com/),
but I would also recommend [Atom](https://atom.io/) and [Sublime](https://www.sublimetext.com/).

## Loading the Module

Make your entry file, I suggest `main.lua`. Require the module and create a client like in the code below.

```lua
local Lublox = require("Lublox")
local Client = Lublox.Client ()
```

The client will be used to make all requests and construct all objects. Lets get the "About Me" section of 
the roblox profile.

```lua
local User = Client:User ("Roblox")

print(User.Description)
```

We first create the User object, then print the Description property. To run your code open a terminal
of your choice, navigate to the file, and run the file with luvit.

`luvit main.lua`
# Testmycode (for Emacs)


<a id="org3fa7dda"></a>

## What is this?

This is an Emacs minor-mode for calling the `tmc` command-line program with its various arguments.  The package provides both keybindings and a menu for accessing the commands.  It also provides commands for instantly jumping  to the next/previous exercise without having to navigate the directories yourself.

The Java Programming I and II courses from [mooc.fi](https://www.mooc.fi/en/) are very popular and frequently recommended on [r/learnjava](https://www.reddit.com/r/learnjava/).  The school provides instructions for setting up an older version of the "NetBeans" IDE, but this is not the preferred editor for all.

Fortunately, you can use any editor you like, because the TestMyCode project provides [a command-line interface](https://github.com/testmycode/tmc-cli) to the same features that their NetBeans plugin provides.

So if you wanted to use Emacs (or Vim, or Nano, etc.), you could use that for the exercises and then go to your shell to type `tmc test`, `tmc submit`, etc.

But I like to stay in Emacs, so I made this package to interface with the command-line program and jump between exercise files.


<a id="org72db47b"></a>

## Prerequisite

For this to be of any use, you must have the [tmc-cli command](https://github.com/testmycode/tmc-cli) installed on your system.  If it’s in one of the directories listed in Emacs’s `exec-path` variable, it will be found automatically.  Otherwise, you can provide the full path as described in the Configuration section below.

If you’re on Linux, I recommend just downloading the executable from [this page](https://github.com/testmycode/tmc-cli/releases/latest) and dropping it in either "~/.local/bin/" or "/usr/local/bin/".


<a id="orgfa0fa75"></a>

## Installation


<a id="org24c2a6e"></a>

### First, clone this repository to your machine.

    git clone https://github.com/mmarshall540/testmycode.git


<a id="org20d6584"></a>

### Now you can proceed in one of two ways:

#### Option 1 (package.el, recommended)

Open up Emacs and do the following:

    M-x package-install-file RET [PATH-TO-THE-TESTMYCODE-DIRECTORY] RET

This will copy the package from your local git repo into the Emacs package store.  Package.el will make it available and set up autoloading.

#### Option 2 (manual)

If you don’t use package.el, or prefer to keep this package separate from it, you can add the following to your Emacs ‘init’ file.

    (load [PATH-TO-THE-TESTMYCODE-DIRECTORY]/testmycode.el)

This will load the package directly from your local git repo.


<a id="org02f0ba9"></a>

## Configuration


<a id="org09ae21c"></a>

### Location of the "tmc" command on your system

If the `tmc` command isn’t in your system path, you’ll need to tell the package where it is.
You can do that with Emacs’s Customize system: `M-x customize-variable RET tmc-executable RET`.
Or if you prefer to set it manually in your init file, just add the following before testmycode.el gets loaded.
`(customize-set-variable 'tmc-executable "~/.local/opt/testmycode/tmc")`
(where the quoted file-path is the location of the ‘tmc’ executable)


<a id="org603e34a"></a>

### Start the mode automatically whenever opening Java files

While working through the courses, it makes sense to have the mode enabled in all ‘java-mode‘ buffers’.  To do that, add the following to your init file.
`(add-hook 'java-mode-hook 'tmc-mode)`


<a id="org793ce96"></a>

### Change the prefix key

The default prefix key for the commands is `C-c '` , but you can change this through Emacs’s "Customize" system: `M-x customize-variable RET tmc-prefix-key RET`.

Or if you prefer to set it manually in your init file, just add the following before testmycode.el gets loaded.
`(customize-set-variable 'tmc-prefix-key (kbd "C-c t"))`
(if you wanted to set the prefix key to "C-c t")

You can also change the ‘tmc’ command arguments and the keys used to call them.  The way to do this is to customize the `tmc-arg-key-alist` variable.


<a id="org3defda3"></a>

## See also


<a id="orgf6f0aee"></a>

### [tmc-intellij](https://github.com/testmycode/tmc-intellij)

A TestMyCode plugin for the IntelliJ IDEA program.


<a id="orgae7a54e"></a>

### [tmc-netbeans](https://github.com/testmycode/tmc-netbeans)

The original TestMyCode plugin for the NetBeans IDE.


<a id="org51c68d4"></a>

### [tmc-cli-rust](https://github.com/rage/tmc-cli-rust)

A newer version of ‘tmc-cli’ written in Rust.  Haven’t tested it with this package.  I had easier success installing the older version.


<a id="org65aa88d"></a>

### [tmc-cli](https://github.com/testmycode/tmc-cli)

The command on which this package depends.


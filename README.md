# Kill or Bury Alive

[![License GPL 3](https://img.shields.io/badge/license-GPL_3-green.svg)](http://www.gnu.org/licenses/gpl-3.0.txt)
[![MELPA](https://melpa.org/packages/kill-or-bury-alive-badge.svg)](https://melpa.org/#/kill-or-bury-alive)
![CI](https://github.com/mrkkrp/kill-or-bury-alive/workflows/CI/badge.svg?branch=master)

Have you ever killed a buffer that you might want to leave alive? Motivation
for killing is usually “get out of my way,” and killing may be not the best
choice in some cases. This package allows us to teach Emacs which buffers to
kill and which to bury alive.

When we want to kill a buffer, it turns out that not all buffers would like
to die in the same way. To help with that, the package allows us to specify
*how* to kill different kinds of buffers. This may be especially useful when
a buffer has an associated process.

## Installation

The package is available via MELPA, so you can just type `M-x
package-install RET kill-or-bury-alive RET`.

If you would like to install the package manually, download or clone it and
put on Emacs' `load-path`. Then you can require it in your init file like
this:

```emacs-lisp
(require 'kill-or-bury-alive)
```

## Usage

I have noticed that people usually want to kill the current buffer. They
even rebind `C-x k` to `kill-this-buffer`. This makes sense, it's natural
for us to care about buffers that are visible and active. It's also
intuitive to switch to some buffer before killing it. If you use this sort
of workflow, you can add something like this to your initialization file:

```emacs-lisp
(global-set-key (kbd "C-x k") #'kill-or-bury-alive)
(global-set-key (kbd "C-c p") #'kill-or-bury-alive-purge-buffers)
```

The second function purges all buffers (see its description below). `C-c p`
is just a key binding that I use myself, you can choose whatever you like,
of course.

## API

*Buffer designator* is something that can be used to match a particular kind
of buffer. In `kill-or-bury-alive`, a buffer designator is either:

* a string—a regular expression to match the name of a buffer;

* a symbol—the major mode of a buffer.

----

```
kill-or-bury-alive-kill-with buffer-designator killing-function &optional simple
```

Kill buffers selected by the `buffer-designator` with `killing-function`.

Normally, `killing-function` should be able to take one argument: a buffer
object. However, you can use a function that operates on the current buffer
and doesn't take any arguments. Just pass non-`nil` `simple` argument and
`killing-function` will be wrapped as needed automatically.

*This function should be used to configure the package, it cannot be called
interactively.*

----

```
kill-or-bury-alive &optional arg
```

Kill or bury the current buffer.

This is a universal killing mechanism. When the argument `arg` is given and
it's not `nil`, kill the current buffer. Otherwise the behavior of this
command varies. If the current buffer matches a buffer designator listed in
`kill-or-bury-alive-must-die-list`, kill it immediately, otherwise just bury
it.

You can specify how to kill various kinds of buffers, see
`kill-or-bury-alive-killing-function-alist` for more information. Buffers
are killed with `kill-or-bury-alive-killing-function` by default.

----

```
kill-or-bury-alive-purge-buffers &optional arg
```

Kill all buffers except for the long lasting ones.

The long lasting buffers are specified in
`kill-or-bury-alive-long-lasting-list`.

If `kill-or-bury-alive-base-buffer` is not `nil`, switch to the buffer with
that name after purging and delete all other windows.

When `arg` is given and it's not `nil`, ask to confirm killing of every
buffer.

## Customization

This package can be customized via the customization system. Type `M-x
customize-group RET kill-or-bury-alive RET` to try it out.

There are quite a few variables that you can modify to control behavior the
package. Let's list them (we give their default values too).

----

```
kill-or-bury-alive-must-die-list => nil
```

A list of buffer designators for buffers that always should be killed.

This variable is used by the `kill-or-bury-alive` function.

----

```
kill-or-bury-alive-killing-function-alist => nil
```

AList that maps buffer designators to functions that should kill them.

This variable is used by `kill-or-bury-alive` and
`kill-or-bury-alive-purge-buffers`.

You can use `kill-or-bury-alive-kill-with` to add elements to this alist.

----

```
kill-or-bury-alive-long-lasting-list =>
  ("^\\*scratch\\*$"
   "^\\*Messages\\*$"
   "^\\*git-credential-cache--daemon\\*$"
   erc-mode)
```

A list of buffer designators for buffers that should not be purged.

This variable is used by `kill-or-bury-alive-purge-buffers`.

----

```
kill-or-bury-alive-killing-function => nil
```

The default function for buffer killing.

This function is used when nothing is found in
`kill-or-bury-alive-killing-function-alist`.

The function should be able to take one argument: buffer object to kill or
its name.

If the value of the variable is `nil`, `kill-buffer` is used.

----

```
kill-or-bury-alive-burying-function ⇒ nil
```

The function used by `kill-or-bury-alive` to bury a buffer.

The function should be able to take one argument: buffer object to bury or
its name.

If value of the variable is `nil`, `kill-or-bury-alive--bury-buffer*` is
used.

----

```
kill-or-bury-alive-base-buffer ⇒ "*scratch*"
```

Name of the buffer to switch to after `kill-or-bury-alive-purge-buffers`.

## License

Copyright © 2015–present Mark Karpov

Distributed under GNU GPL, version 3.

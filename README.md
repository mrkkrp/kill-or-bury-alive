# Kill or Bury Alive

[![License GPL 3](https://img.shields.io/badge/license-GPL_3-green.svg)](http://www.gnu.org/licenses/gpl-3.0.txt)
[![MELPA](http://melpa.org/packages/kill-or-bury-alive-badge.svg)](http://melpa.org/#/kill-or-bury-alive)
[![Build Status](https://travis-ci.org/mrkkrp/kill-or-bury-alive.svg?branch=master)](https://travis-ci.org/mrkkrp/kill-or-bury-alive)

Have you ever killed some buffer that you might want to left alive?
Motivation for killing is usually “get out of my way for now”, and killing
may be not the best choice in many cases unless your RAM is very-very
limited. This package allows to teach Emacs which buffers we want to kill
and which ones we prefer to bury alive.

When we really want to kill a buffer, it turns out that not all buffers
would like to die the same way. The package allows to specify *how* to kill
various kinds of buffers. This may be especially useful when you're working
with some buffer that has an associated process, for example.

But sometimes you may want to get rid of most buffers and bring Emacs to
some more or less virgin state. You probably don't want to kill scratch
buffer and maybe ERC-related buffers too. You can specify which buffers to
purge.

## Installation

Download this package and place it somewhere, so Emacs can see it. Then put
`(require 'kill-or-bury-alive)` into your configuration file. Done!

To install the package via MELPA, execute: <kbd>M-x package-install RET
kill-or-bury-alive RET</kbd>.

## Usage

All you need to do to start using the package is to bind two useful
functions: `kill-or-bury-alive` and `kill-or-bury-alive-purge-buffers`.

I've noticed that many people only ever want to kill current buffer, they
even rebind <kbd>C-x k</kbd> to `kill-this-buffer`. This makes sense, it's
natural for us to care about buffers that are visible and active. It's also
intuitive to switch to some buffer before killing it. If you are into this
sort of workflow, you can add something like this to your initialization
file (if you want to preserve original `kill-buffer`, choose different key
binding):

```emacs-lisp
(global-set-key (kbd "C-x k") #'kill-or-bury-alive)
(global-set-key (kbd "C-c p") #'kill-or-bury-alive-purge-buffers)
```

The second function purges all buffers (see description below). <kbd>C-c
p</kbd> is just a key binding that I use myself, you can choose whatever you
like, of course.

## API

Before I describe the API, you need to know about a notion that this
package uses: *buffer designator*.

*Buffer designator* is something that can define particular sort of
buffers. In `kill-or-bury-alive` buffer designator is either:

* a string — regular expression to match name of buffer, this sort of buffer
  designator represents all buffers with matching names;

* a symbol — major mode of buffer, this represents all buffers that have
  such major mode.

That's it, pretty simple (and useful!).

----

```
kill-or-bury-alive-kill-with buffer-designator killing-function &optional simple
```

Kill buffers selected by `buffer-designator` with `killing-function`.

Normally, `killing-function` should be able to take one argument: buffer
object. However, you can use a function that operates on current buffer and
doesn't take any arguments. Just pass non-`nil` `simple` argument and
`killing-function` will be wrapped as needed automatically.

*This function should be used to configure the package, it cannot be called
interactively.*

----

```
kill-or-bury-alive &optional arg
```

Kill or bury current buffer.

This is universal killing mechanism. When argument `arg` is given and it's
not `nil`, kill current buffer. Otherwise behavior of this command varies.
If current buffer matches a buffer designator listed in
`kill-or-bury-alive-must-die-list`, kill it immediately, otherwise just bury
it.

You can specify how to kill various kinds of buffers, see
`kill-or-bury-alive-killing-function-alist` for more information. Buffers
are killed with `kill-or-bury-alive-killing-function` by default.

----

```
kill-or-bury-alive-purge-buffers &optional arg
```

Kill all buffers except for long lasting ones.

Long lasting buffers are specified in `kill-or-bury-alive-long-lasting-list`.

If `kill-or-bury-alive-base-buffer` is not `nil`, switch to buffer with that
name after purging and delete all other windows.

When `arg` is given and it's not `nil`, ask to confirm killing of every
buffer.

## Customization

There are quite a few variables that you can modify to control behavior of
`kill-or-bury-alive` package. Let's list them (we list their default values
too after ‘⇒’ character).

----

```
kill-or-bury-alive-must-die-list ⇒ nil
```

List of buffer designators for buffers that always should be killed.

This variable is used by `kill-or-bury-alive` function.

----

```
kill-or-bury-alive-killing-function-alist ⇒ nil
```

AList that maps buffer designators to functions that should kill them.

This variable is used by `kill-or-bury-alive` and
`kill-or-bury-alive-purge-buffers`.

You can use `kill-or-bury-alive-kill-with` to add elements to this alist.

----

```
kill-or-bury-alive-long-lasting-list ⇒
  ("^\\*scratch\\*$" "^\\*Messages\\*$" erc-mode)
```

List of buffer designators for buffers that should not be purged.

This variable is used by `kill-or-bury-alive-purge-buffers`.

----

```
kill-or-bury-alive-killing-function ⇒ nil
```

Default function for buffer killing.

This is used when nothing is found in
`kill-or-bury-alive-killing-function-alist`.

The function should be able to take one argument: buffer object
to kill or its name.

If value of the variable is `nil`, `kill-buffer` is used.

----

```
kill-or-bury-alive-burying-function ⇒ nil
```

Function used by `kill-or-bury-alive` to bury a buffer.

The function should be able to take one argument: buffer object to bury or
its name.

If value of the variable is `nil`, `kill-or-bury-alive--bury-buffer*` is
used.

----

```
kill-or-bury-alive-base-buffer ⇒ "*scratch*"
```

Name of buffer to switch to after `kill-or-bury-alive-purge-buffers`.

## License

Copyright © 2015 Mark Karpov

Distributed under GNU GPL, version 3.

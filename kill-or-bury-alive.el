;;; kill-or-bury-alive.el --- Precise control over buffer killing in Emacs -*- lexical-binding: t; -*-
;;
;; Copyright © 2015 Mark Karpov <markkarpov@openmailbox.org>
;;
;; Author: Mark Karpov <markkarpov@openmailbox.org>
;; URL: https://github.com/mrkkrp/kill-or-bury-alive
;; Version: 0.1.0
;; Package-Requires: ((emacs "24.4") (cl-lib "0.5"))
;; Keywords: buffer, killing, convenience
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the
;; Free Software Foundation, either version 3 of the License, or (at your
;; option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
;; Public License for more details.
;;
;; You should have received a copy of the GNU General Public License along
;; with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Have you ever killed some buffer that you might want to left alive?
;; Motivation for killing is usually “get out of my way for now”, and
;; killing may be not the best choice in many cases unless your RAM is
;; very-very limited. This package allows to teach Emacs which buffers we
;; want to kill and which ones we prefer to bury alive.
;;
;; Even when we really want to kill a buffer, not all buffers would like to
;; die the same way, though. The package allows to specify *how* to kill
;; various kinds of buffers. This may be especially useful when you're
;; working with some buffer that has an associated process, for example.
;;
;; But sometimes you may want to get rid of most buffers and bring Emacs to
;; some more or less virgin state. You probably don't want to kill scratch
;; buffer and maybe ERC-related buffers too. You can specify which buffers
;; to purge too.

;;; Code:

(require 'cl-lib)

(defvar koba-must-die-list nil
  "List of buffer designators for buffers that always should be killed.

Buffer designator can be a string (regexp to match name of
buffer) or a symbol (major mode of buffer).

This variable is used by `kill-or-bury-alive' function.")

(defvar koba-killing-function-alist nil
  "AList that maps buffer designators to functions that should kill them.

Buffer designator can be a string (regexp to match name of
buffer) or a symbol (major mode of buffer).

This variable is used by `kill-or-bury-alive' and
`koba-purge-buffers'.

You can use `koba-kill-with' to add elements to this alist.")

(defvar koba-long-lasting-list '("^\\*scratch\\*$")
  "List of buffer designators for buffers that should not be purged.

Buffer designator can be a string (regexp to match name of
buffer) or a symbol (major mode of buffer).

This variable is used by `koba-purge-buffers'.")

(defvar koba-killing-function nil
  "Default function for buffer killing.

This is used when nothing is found in
`koba-killing-function-alist'.

The function should be able to take one argument: buffer object
to kill or its name.

If value of the variable is NIL, `kill-buffer' is used.")

(defvar koba-burying-function nil
  "Function used by `kill-or-bury-alive' to bury a buffer.

The function should be able to take one argument: buffer object
to bury or its name.

If value of the variable is NIL, `bury-buffer' is used.")

(defvar koba-base-buffer "*scratch*"
  "Name of buffer to switch to after `koba-purge-buffers'.")

;;;###autoload
(defun koba-kill-with (buffer-designator killing-function)
  "Kill buffers selected by BUFFER-DESIGNATOR with KILLING-FUNCTION.

Buffer designator can be a string (regexp to match name of
buffer) or a symbol (major mode of buffer)."
  (push (cons buffer-designator killing-function)
        koba-killing-function-alist))

(defun koba--buffer-match (buffer buffer-designator)
  "Return non-NIL value if BUFFER matches BUFFER-DESIGNATOR.

BUFFER should be a buffer object.  Buffer designator can be a
string (regexp to match name of buffer) or a symbol (major mode
of buffer)."
  (if (stringp buffer-designator)
      (string-match-p buffer-designator
                      (buffer-name buffer))
    (with-current-buffer buffer
      (eq major-mode buffer-designator))))

(defun koba--must-die-p (buffer)
  "Return non-NIL value when BUFFER must be killed no matter what."
  (cl-some (apply-partially #'koba--buffer-match buffer)
           koba-must-die-list))

(defun koba--long-lasting-p (buffer)
  "Return non-NIL value when BUFFER is a long lasting one."
  (cl-some (apply-partially #'koba--buffer-match buffer)
           koba-long-lasting-list))

(defun koba--kill-buffer (buffer)
  "Kill buffer BUFFER according to killing preferences.

Variable `koba-killing-function-alist' is used to find how to
kill BUFFER.  If nothing special is found,
`koba-killing-function' is used."
  (funcall
   (or (cdr
        (cl-find-if
         (apply-partially #'koba--buffer-match buffer)
         koba-killing-function-alist
         :key #'car))
       koba-killing-function
       #'kill-buffer)
   buffer))

(defun koba--bury-buffer (buffer)
  "Bury buffer BUFFER according to burying preferences.

`koba-burying-function' is used to bury the buffer, see its
description for more information."
  (funcall (or koba-burying-function
               (lambda (buffer) ; fixing peculiar logic of `bury-buffer'
                 (bury-buffer
                  (unless (eq (current-buffer) buffer)
                    buffer))))
           buffer))

;;;###autoload
(defun kill-or-bury-alive (&optional arg)
  "Kill or bury current buffer.

This is universal killing mechanism.  When argument ARG is given
and it's not NIL, kill current buffer.  Otherwise behavior of
this command varies.  If current buffer matches a buffer
designator listed in `koba-must-die-list', kill it immediately,
otherwise just bury it.

You can specify how to kill various kinds of buffers, see
`koba-killing-function-alist' for more information.  Buffers are
killed with `koba-killing-function' by default."
  (interactive "P")
  (let ((buffer (current-buffer)))
    (if (or arg (koba--must-die-p buffer))
        (koba--kill-buffer buffer)
      (koba--bury-buffer buffer))))

;;;###autoload
(defun koba-purge-buffers ()
  "Kill all buffers except for long lasting ones.

Long lasting buffers are specified in `koba-long-lasting-list'.

If `koba-base-buffer' is not NIL, switch to buffer with that name
after purging and delete all other windows."
  (interactive)
  (dolist (buffer (buffer-list))
    (unless (koba--long-lasting-p buffer)
      (koba--kill-buffer buffer)))
  (when koba-base-buffer
    (switch-to-buffer koba-base-buffer)
    (delete-other-windows)))

(provide 'kill-or-bury-alive)

;;; kill-or-bury-alive.el ends here

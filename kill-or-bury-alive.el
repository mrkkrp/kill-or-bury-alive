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

(provide 'kill-or-bury-alive)

;;; kill-or-bury-alive.el ends here

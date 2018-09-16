;;; auto-scroll.el ---  Adds functions to automatically scroll the screen. -*- lexical-binding: t; -*-

;; Copyright (C) 2018 Ryan J. Kinnear

;; Author: Ryan J. Kinnear <Ryan@Kinnear.ca>
;; Keywords: conveniences
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; This package provides the function (auto-scroll-start period) which
;; will scroll down by one line every 'period seconds.  This is useful
;; for reading without having to keep your hands on the keyboard, or
;; for scrolling down musical charts while playing, which was the use
;; for which I originally created these methods.
;;

;;; Code:

(defgroup auto-scroll nil
  "Let cursor scroll on a timer."
  :group 'convenience
  :prefix "auto-scroll")

(define-minor-mode auto-scroll-mode
  "Minor mode for automatically scrolling the cursor"
  :init-value nil
  :keymap '(("\C-c \M-a s" . 'auto-scroll-start))
  )

(make-sparse-keymap)

(defcustom auto-scroll-mode-hook nil
  "Hooks to run after command `auto-scroll-mode' is toggled."
  :group 'auto-scroll
  :type 'hook)

(defvar auto-scroll-period nil)
(defvar auto-scroll-timer nil)

(defun auto-scroll-next-line ()
  "Move cursor to next line, if not at end of buffer.
Otherwise, stop the auto-scroll timer"
  (if (not (eq (point) (point-max)))
      (forward-line)
    (auto-scroll-stop)))

(defun auto-scroll-start (period)
  "Start auto scrolling with the given PERIOD."
  (setq auto-scroll-period period)
  (setq auto-scroll-timer
	(run-at-time 0 period 'auto-scroll-next-line))
  )

(defun auto-scroll-stop ()
  "Stop the auto-scroll timer."
  (if (timerp auto-scroll-timer)
      (cancel-timer auto-scroll-timer)
    )
  )

(provide 'auto-scroll)
;;; auto-scroll.el ends here

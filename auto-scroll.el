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
  "Set cursor to scroll itself on a timer."
  :group 'convenience
  :prefix "auto-scroll")

(define-minor-mode auto-scroll-mode
  "Minor mode for automatically scrolling the cursor"
  :init-value nil
  :keymap '(("\C-c \M-a" . 'auto-scroll-start)
	    ("\C-c \M-a" . 'auto-scroll-stop)
	    )
  :group 'convenience
  )

(defcustom auto-scroll-mode-hook nil
  "Hooks to run after command `auto-scroll-mode' is toggled."
  :group 'auto-scroll
  :type 'hook)

(defcustom auto-scroll-default-scroll-period 1
  "Default scrolling period."
  :group 'auto-scroll
  :type 'number)

(defcustom auto-scroll-period-granularity 0.1
  "Granularity for increasing / decreasing scroll period."
  :group 'auto-scroll
  :type 'number)

(defcustom auto-scroll-minimum-period 0.1
  "Shortest allowed scrolling period."
  :group 'auto-scroll
  :type 'number)

(defvar auto-scroll-period auto-scroll-default-scroll-period)
(defvar auto-scroll-timer nil)

(defun auto-scroll-start (&optional period)
  "Start auto scrolling with the given PERIOD.

This function can be safely called multiple times without
starting multiple times, it will cancel the previous timer and
start a new one with the given period."
  (interactive)
  (progn
    (if period (setq auto-scroll-period period))
    (if (timerp auto-scroll-timer)
	(auto-scroll-stop))
    (setq auto-scroll-timer
	  (run-at-time auto-scroll-period auto-scroll-period
		       'auto-scroll-next-line)))
  )

(defun auto-scroll-next-line ()
  "Move cursor to next line, if not at end of buffer.
Otherwise, stop the auto-scroll timer"
  (interactive)
  (if (not (eq (point) (point-max)))
      (forward-line)
    (auto-scroll-stop))
  )

(defun auto-scroll-stop ()
  "Stop the auto-scroll timer."
  (interactive)
  (if (timerp auto-scroll-timer)
      ;; Don't try to stop a timer that hasn't been start.
      (progn (cancel-timer auto-scroll-timer)
	     (setq auto-scroll-timer nil))
    ))

(defun auto-scroll-faster ()
  "Reduce period by period-granularity."
  (interactive)
  (auto-scroll-delta-period (* -1 auto-scroll-period-granularity))
  )

(defun auto-scroll-slower ()
  "Increase period by period-granularity."
  (interactive)
  (auto-scroll-delta-period auto-scroll-period-granularity)
  )

(defun auto-scroll-delta-period (delta)
  "Change period by DELTA, subject to auto-scroll-minimum-period."
  (let ((new-period
	 (max auto-scroll-minimum-period (+ auto-scroll-period delta))
	 ))
    (if (timerp auto-scroll-timer)
      (auto-scroll-start new-period)
      (setq auto-scroll-period new-period)
      )
    new-period))

(provide 'auto-scroll)
;;; auto-scroll.el ends here

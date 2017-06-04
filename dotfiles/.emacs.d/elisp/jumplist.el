;;; jumplist.el ---

;; Copyright (C) 2013  keisuke

;; Author: keisuke <keisuke@keisuke-virtual-machine>
;; Keywords: jumplist

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

;;

;;; Code:

(defvar backward-jump-list nil)
(defvar forward-jump-list nil)

(defun get-current-line ()
  "get the current line number (in the buffer) of point."
  (interactive)
  (save-restriction
    (widen)
    (save-excursion
      (beginning-of-line)
      (1+ (count-lines 1 (point))))))

(defmacro push-place-uniq (place jump-list)
  ;; if the place is already at the head of jump-list, ignore it
  ;; otherwise add it at the head of jump-list
  (list 'cond
        (list (list 'equal place (list 'car jump-list)))
        (list t
              (list 'cond
                    (list (list '>= (list 'length jump-list) 100)
                          (list 'nbutlast jump-list 1)))
              (list 'push place jump-list))))

(defun get-current-place ()
  "Return (current-buffer current-point)"
  (cons (current-buffer) (get-current-line)))

(defun push-current-place ()
  "Push current-place to backward-jump-list and clear forward-jump-list"
  (interactive)
  (setq forward-jump-list nil)
  (push-place-uniq (get-current-place) backward-jump-list))

(defun backward-jump ()
  "Move to the place at the head of backward-jump-list."
  "Pop it from backward-jump-list and push it to forward-jump-list"
  (interactive)
  (cond
   (backward-jump-list
    (push-place-uniq (get-current-place) forward-jump-list)
    (setq next-place (pop backward-jump-list))
    (cond ((equal next-place (get-current-place))
           (setq next-place (pop backward-jump-list))))
    (switch-to-buffer (car next-place))
    (goto-line (cdr next-place))
    (push-place-uniq next-place forward-jump-list))
   (t
    (message "no more backward history"))))

(defun forward-jump ()
  "Move to the place at the head of forward-jump-list."
  "Pop it from forward-jump-list and push it to backward-jump-list"
  (interactive)
  (cond
   (forward-jump-list
    (push-place-uniq (get-current-place) backward-jump-list)
    (setq next-place (pop forward-jump-list))
    (cond ((equal next-place (get-current-place))
           (setq next-place (pop forward-jump-list))))
    (switch-to-buffer (car next-place))
    (goto-line (cdr next-place))
    (push-place-uniq next-place backward-jump-list))
   (t
    (message "no more forward history"))))

(provide 'jumplist)
;;; jumplist.el ends here

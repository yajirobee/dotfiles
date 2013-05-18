;;; pg-config.el --- 

;; Copyright (C) 2013  keisuke

;; Author: keisuke <keisuke@keisuke-virtual-machine>
;; Keywords: 

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

;;; Code:

(defun pgsql-c-mode ()
  ;; sets up formatting for PostgreSQL C code
  (interactive)
  (c-mode)
  (c-set-style "bsd")             ; set c-basic-offset to 4, plus other stuff
  (c-set-offset 'case-label '+)   ; tweak case indent to match PG custom
  (setq indent-tabs-mode t)       ; make sure we keep tabs when indenting
  (setq tab-stop-list (number-sequence tab-width 512 tab-width))
  (setq c-basic-offset 4))

;; check for files with a path containing "postgres" or "pgsql"
(setq auto-mode-alist
      (cons '("\\(postgres\\|pgsql\\).*\\.[ch]\\'" . pgsql-c-mode)
            auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\(postgres\\|pgsql\\).*\\.cc\\'" . pgsql-c-mode)
            auto-mode-alist))

(provide 'pg-config)
;;; pg-config.el ends here

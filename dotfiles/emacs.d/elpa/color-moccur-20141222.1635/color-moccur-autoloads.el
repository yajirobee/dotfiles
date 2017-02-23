;;; color-moccur-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "color-moccur" "../../../../../../.emacs.d/elpa/color-moccur-20141222.1635/color-moccur.el"
;;;;;;  "219efa6562fe107309ad67e45ceb8e1f")
;;; Generated autoloads from ../../../../../../.emacs.d/elpa/color-moccur-20141222.1635/color-moccur.el

(autoload 'occur-by-moccur "color-moccur" "\
Use this instead of occur.
Argument REGEXP regexp.
Argument ARG whether buffers which is not related to files are searched.

\(fn REGEXP ARG)" t nil)

(autoload 'moccur-grep-find "color-moccur" "\


\(fn DIR INPUTS)" t nil)

(autoload 'dired-do-moccur "color-moccur" "\
Show all lines of all buffers containing a match for REGEXP.
The lines are shown in a buffer named *Moccur*.
It serves as a menu to find any of the occurrences in this buffer.
\\[describe-mode] in that buffer will explain how.

\(fn REGEXP ARG)" t nil)

(autoload 'grep-buffers "color-moccur" "\
*Run `grep` PROGRAM to match EXPRESSION (with optional OPTIONS) on all visited files.

\(fn)" t nil)

(autoload 'search-buffers "color-moccur" "\
*Search string of all buffers.

\(fn REGEXP ARG)" t nil)

;;;***

;;;### (autoloads nil nil ("../../../../../../.emacs.d/elpa/color-moccur-20141222.1635/color-moccur-autoloads.el"
;;;;;;  "../../../../../../.emacs.d/elpa/color-moccur-20141222.1635/color-moccur.el")
;;;;;;  (22702 65433 725607 274000))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; color-moccur-autoloads.el ends here

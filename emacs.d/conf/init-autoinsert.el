;;; init-autoinsert.el ---

;;; Code:
(require 'autoinsert)

;; template directory
(setq auto-insert-directory "~/.emacs.d/template/")

;; change templates corresponding to extension of files
(setq auto-insert-alist
      (nconc '(
               ("\\.c$" . ["template.c" ctemplate-replace])
               ("\\.cpp$" . ["template.cpp" ctemplate-replace])
               ("\\.h$" . ["template.h" ctemplate-replace])
               ("\\.py$" . "template.py")
               ("[Mm]akefile$" . "Makefile")
               ("\\.tex$" . "template.tex")
               ) auto-insert-alist))
(require 'cl)

(defvar ctemplate-replacements-alists
  '(("%file%"             .
     (lambda () (file-name-nondirectory (buffer-file-name))))
    ("%file-without-ext%" .
     (lambda () (file-name-sans-extension
                 (file-name-nondirectory (buffer-file-name)))))
    ("%include-guard%"    .
     (lambda () (format "__SCHEME_%s__"
                        (upcase (file-name-sans-extension
                                 (file-name-nondirectory buffer-file-name))))))
    ))

(defun ctemplate-replace ()
  (time-stamp)
  (mapc #'(lambda(c)
            (progn
              (goto-char (point-min))
              (replace-string (car c) (funcall (cdr c)) nil)))
        ctemplate-replacements-alists)
  (goto-char (point-max))
  (message "done."))

(defvar cplustemplate-replacements-alists
  '(("%file%"             .
     (lambda () (file-name-nondirectory (buffer-file-name))))
    ("%file-without-ext%" .
     (lambda () (file-name-sans-extension
                 (file-name-nondirectory (buffer-file-name)))))
    ("%include-guard%"    .
     (lambda () (format "__SCHEME_%s__"
                        (upcase (file-name-sans-extension
                                 (file-name-nondirectory buffer-file-name))))))
    ("%namespace%" .
              (lambda () (setq namespace (read-from-minibuffer "namespace: "))))
    ("%namespace-open%" .
     (lambda ()
       (cond ((string= namespace "") "")
             (t (progn
                  (setq namespace-list (split-string namespace "::"))
                  (setq namespace-text "")
                  (while namespace-list
                    (setq namespace-text (concat namespace-text "namespace "
                                                 (car namespace-list) " {\n"))
                    (setq namespace-list (cdr namespace-list)))
                  (eval namespace-text))))))
    ("%namespace-close%" .
     (lambda ()
       (cond ((string= namespace "") "")
             (t (progn
                  (setq namespace-list (reverse (split-string namespace "::")))
                  (setq namespace-text "")
                  (while namespace-list
                    (setq namespace-text (concat namespace-text "} // "
                                                 (car namespace-list) "\n"))
                    (setq namespace-list (cdr namespace-list)))
                  (eval namespace-text))))))
    ))

(defun cplustemplate-replace ()
  (time-stamp)
  (mapc #'(lambda(c)
            (progn
              (goto-char (point-min))
              (replace-string (car c) (funcall (cdr c)) nil)))
        cplustemplate-replacements-alists)
  (goto-char (point-max))
  (message "done."))

(add-hook 'find-file-not-found-hooks 'auto-insert)

(provide 'init-autoinsert)
;;; init-autoinsert.el ends here

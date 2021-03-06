;;; init-python.el --- init python configuration

(defun my-python-mode ()
  (define-key python-mode-map "\'" 'skeleton-pair-insert-maybe)
  (when (require 'highlight-indentation nil t)
	(setq py-indent-offset 4)
	;(add-hook 'python-mode-hook 'highlight-indentation-current-column-mode)
  ))

(add-hook 'python-mode-hook 'my-python-mode)
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)

(provide 'init-python)
;;; init-python.el ends here

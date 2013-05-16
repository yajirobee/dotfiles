;;; init-python.el --- init python configuration

(add-hook 'python-mode-hook
          (lambda ()
            (define-key python-mode-map "\'" 'skeleton-pair-insert-maybe)))

(when (require 'highlight-indentation nil t)
  (setq py-indent-offset 4)
  ;(add-hook 'python-mode-hook 'highlight-indentation-current-column-mode)
  )

(when (require 'pymacs-autoloads nil t))

(provide 'init-python)
;;; init-python.el ends here

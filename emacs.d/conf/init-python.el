;;; init-python.el --- init python configuration

(add-hook 'python-mode-hook
          (lambda ()
            (define-key python-mode-map "\'" 'electric-pair)))

(when (require 'highlight-indentation nil t)
  (setq py-indent-offset 4)
  (add-hook 'python-mode-hook 'highlight-indentation-current-column-mode))

(provide 'init-python)
;;; init-python.el ends here

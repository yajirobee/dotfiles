;;; init-auto-complete.el ---

;;; Code:
(when (require 'auto-complete-config nil t)
  (ac-config-default)
  ;; dictionary directories
  (add-to-list 'ac-dictionary-directories
               "~/.emacs.d/ac-dict")
  ;; source files for each major modes
  (add-hook 'sh-mode-hook (lambda () (add-to-list 'ac-sources 'ac-source-files-in-current-dir)))
  (add-hook 'c-mode-common-hook (lambda () (add-to-list 'ac-sources 'ac-source-semantic)))
  (add-hook 'c++-mode (lambda () (add-to-list 'ac-sources 'ac-source-semantic)))
  ;; manually start auto complete
  (setq ac-auto-start nil)
  ;; keybind
  (define-key ac-mode-map (kbd "C-\]") 'auto-complete)
  (setq ac-use-menu-map t)
  ;; same as defaults
  (define-key ac-menu-map (kbd "C-n") 'ac-next)
  (define-key ac-menu-map (kbd "C-p") 'ac-previous))

(provide 'init-auto-complete)
;;; init-auto-complete.el ends here

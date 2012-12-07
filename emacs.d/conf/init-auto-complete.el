;;; init-auto-complete.el --- 

;;; Code:
(when (require 'auto-complete-config nil t)
  (ac-config-default)
  ;; 辞書ファイルの存在するディレクトリ
  (add-to-list 'ac-dictionary-directories
               "~/.emacs.d/ac-dict")
  ;; major modeごとの情報源の指定
  (add-hook 'sh-mode-hook (lambda () (add-to-list 'ac-sources 'ac-source-files-in-current-dir)))
  (add-hook 'c-mode-common-hook (lambda () (add-to-list 'ac-sources 'ac-source-semantic)))
  (add-hook 'c++-mode (lambda () (add-to-list 'ac-sources 'ac-source-semantic)))
  ;; 補完を自動で開始しない
  (setq ac-auto-start nil)
  ;; keybind
  (define-key ac-mode-map (kbd "C-\]") 'auto-complete)
  (setq ac-use-menu-map t)
  ;; デフォルトで設定済み
  (define-key ac-menu-map (kbd "C-n") 'ac-next)
  (define-key ac-menu-map (kbd "C-p") 'ac-previous))

(provide 'init-auto-complete)
;;; init-auto-complete.el ends here

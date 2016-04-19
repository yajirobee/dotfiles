;;; init-helm.el --- my helm configuration           -*- lexical-binding: t; -*-

;; Copyright (C) 2016

;; Author:  <keisuke@seifer>

;;; Code:
(when (require 'helm-config nil t)
  (helm-mode 1)
  (define-key global-map (kbd "M-x")     'helm-M-x)
  (define-key global-map (kbd "C-x C-f") 'helm-find-files)
  (define-key global-map (kbd "C-x C-r") 'helm-recentf)
  (define-key global-map (kbd "M-y")     'helm-show-kill-ring)
  (define-key global-map (kbd "C-c i")   'helm-imenu)
  (define-key global-map (kbd "C-x b")   'helm-mini)
  (define-key global-map (kbd "C-M-o")   'helm-occur)
  (define-key helm-map (kbd "C-h") 'delete-backward-char)
  (define-key helm-find-files-map (kbd "C-h") 'delete-backward-char)
  (define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action)
  (define-key helm-read-file-map (kbd "TAB") 'helm-execute-persistent-action)

  ;; Emulate `kill-line' in helm minibuffer
  (setq helm-delete-minibuffer-contents-from-point t)
  (defadvice helm-delete-minibuffer-contents (before helm-emulate-kill-line activate)
    "Emulate `kill-line' in helm minibuffer"
    (kill-new (buffer-substring (point) (field-end))))

  (when (require 'helm-descbinds nil t)
    (helm-descbinds-mode))

  (when (require 'helm-gtags nil t)
    (add-hook 'c-mode-hook 'helm-gtags-mode)
    (add-hook 'c++-mode-hook 'helm-gtags-mode)
    (add-hook 'java-mode-hook 'helm-gtags-mode)
    (add-hook 'asm-mode 'helm-gtags-mode)
    (add-hook 'python-mode-hook 'helm-gtags-mode)
    (add-hook 'ruby-mode-hook 'helm-gtags-mode)
    ;; key bindings
    (add-hook 'helm-gtags-mode-hook
              '(lambda ()
                 ;;入力されたタグの定義元へジャンプ
                 (local-set-key (kbd "M-.") 'helm-gtags-find-tag)
                 ;;入力タグを参照する場所へジャンプ
                 (local-set-key (kbd "M-r") 'helm-gtags-find-rtag)
                 ;;入力したシンボルを参照する場所へジャンプ
                 (local-set-key (kbd "M-s") 'helm-gtags-find-symbol)
                 ;;タグ一覧からタグを選択し, その定義元にジャンプする
                 (local-set-key (kbd "M-l") 'helm-gtags-select)
                 ;;ジャンプ前の場所に戻る
                 (local-set-key (kbd "M-t") 'helm-gtags-pop-stack))))

  (when (require 'helm-swoop nil t)
    (define-key helm-swoop-map (kbd "C-r") 'helm-previous-line)
    (define-key helm-swoop-map (kbd "C-s") 'helm-next-line)

    (when (require 'ace-isearch nil t)
      (global-ace-isearch-mode 1)
      (custom-set-variables
       '(ace-isearch-jump-delay 0.6))))

  (require 'helm-ls-git))

(provide 'init-helm)
;;; init-helm.el ends here

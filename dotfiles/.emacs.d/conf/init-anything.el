;;; anything

(when (require 'anything nil t)
  (setq
   ;; delay time to display candidates
   anything-idel-delay 0.3
   ;;delay time to refresh from input change
   anything-input-idle-delay 0.2
   ;; candidate limitation
   anything-candidate-number-limit 100
   ;; quick update if there are many candidates
   anything-quick-update t
   ;; using alphabet for shortcut of selection
   anything-enable-shortcuts 'alphabet)
  ;; keybind
  (define-key global-map (kbd "C-x b") 'anything)
  (define-key global-map (kbd "M-y") 'anything-show-kill-ring)

  (when (require 'anything-config nil t)
    ;; command for root
    (setq anything-su-or-sudo "sudo")
    (setq anything-sources
          '(anything-c-source-buffers+
            anything-c-source-recentf
            anything-c-source-files-in-current-dir
            anything-c-source-man-pages
            anything-c-source-emacs-commands
            anything-c-source-locate
            anything-c-source-colors)))

  (require 'anything-match-plugin nil t)

  (when (and (executable-find "cmigemo")
             (require 'migemo nil t))
    (require 'anything-migemo nil t))

  (when (require 'anything-complete nil t)
    ;; search time limit for lisp symbol complete candidates
    (anything-lisp-complete-symbol-set-timer 150))

  (require 'anything-show-completion nil t)

  (when (require 'auto-install nil t)
    (require 'anything-auto-install nil t))

  (when (require 'descbinds-anything nil t)
    ;; replace describe-bindings to Anything
    (descbinds-anything-install))

  (when (require 'color-moccur)
    (when (require 'anything-c-moccur nil t)
      (setq
       ;; 'anything-idle-delay' for anything-c-moccur
       anything-c-moccur-anything-idle-delay 0.1
       ;; highlight buffer information
       lanything-c-moccur-highlight-info-line-flag t
       ;; display selected candidate position to other window
       anything-c-moccur-enable-auto-look-flag t
       ;; initiate word position for initial pattern
       anything-c-moccur-enable-initial-pattern t)
      ;; keybind
      (global-set-key (kbd "M-o") 'anything-c-moccur-occur-by-moccur)
      (global-set-key (kbd "C-M-o") 'anything-c-moccur-dmoccur)))

  (when (require 'anything-exuberant-ctags nil t)
    (setq ctags-command "ctags -R --fields=\"+afikKlmnsSZt\" ")
    ;; define sources for anything-for-tags
    (setq anything-for-tags
          (list anything-c-source-imenu
                ;; configuration for etags
                ;;anything-c-source-etags-select
                anything-c-source-exuberant-ctags-select))
    ;; command for anything-for-tags
    (defun anything-for-tags ()
      "Preconfigured 'anythig' for anything-for-tags."
      (interactive)
      (anything anything-for-tags
                (thing-at-point 'symbol)
                nil nil nil "*anything for tags*"))
    ;; keybind
    (define-key global-map (kbd "M-.") 'anything-for-tags)))

(provide 'init-anything)

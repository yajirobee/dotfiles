;;; anything

(when (require 'anything nil t)
  (setq
   ;; 候補を表示するまでの時間
   anything-idel-delay 0.3
   ;; タイプして再描画するまでの時間
   anything-input-idle-delay 0.2
   ;; 候補の最大表示数
   anything-candidate-number-limit 100
   ;; 候補が多い時に体感速度を速くする
   anything-quick-update t
   ;; 候補選択ショートカットをアルファベットに
   anything-enable-shortcuts 'alphabet)
  ;; キーバインド
  (define-key global-map (kbd "C-x b") 'anything)
  (define-key global-map (kbd "M-y") 'anything-show-kill-ring)

  (when (require 'anything-config nil t)
    ;; root権限でアクションを実行するときのコマンド
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
    ;; lispシンボルの補完候補の再検索時間
    (anything-lisp-complete-symbol-set-timer 150))

  (require 'anything-show-completion nil t)

  (when (require 'auto-install nil t)
    (require 'anything-auto-install nil t))

  (when (require 'descbinds-anything nil t)
    ;; describe-bindingsをAnythingに置き換える
    (descbinds-anything-install))
  (when (require 'color-moccur)
    (when (require 'anything-c-moccur nil t)
      (setq
       ;; anything-c-moccur用 'anything-idle-delay'
       anything-c-moccur-anything-idle-delay 0.1
       ;; bufferの情報をハイライトする
       lanything-c-moccur-highlight-info-line-flag t
       ;; 選択中の候補の位置を他のwindowに表示する
       anything-c-moccur-enable-auto-look-flag t
       ;; 起動時にポイントの位置の単語を初期パターンにする
       anything-c-moccur-enable-initial-pattern t)
      ;; keybind
      (global-set-key (kbd "M-o") 'anything-c-moccur-occur-by-moccur)
      (global-set-key (kbd "C-M-o") 'anything-c-moccur-dmoccur))))

(provide 'init-anything)

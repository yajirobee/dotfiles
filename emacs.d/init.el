;;;
;;; system設定
;;;

;;; ロードパスの追加
(setq load-path (append '("~/.emacs.d") load-path))

(when (> emacs-major-version 23)
  (defvar user-emacs-directory "~/.emacs.d/"))

(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
	      (expand-file-name (concat user-emacs-directory path))))
	(add-to-list 'load-path default-directory)
	(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	    (normal-top-level-add-subdirs-to-load-path))))))

(add-to-load-path "conf" "elisp")

;;; auto-install
(when (require 'auto-install nil t)
  ;; インストールディレクトリの設定
  (setq auto-install-directory "~/.emacs.d/elisp/")
  ;; EmacsWikiに登録されているelispの名前を取得する
  (auto-install-update-emacswiki-package-name t)
  ;; 必要であればプロキシの設定を行う
  ;; (setq url-proxy-service '(("http" . "localhost:8339")))
  ;; install-elispの関数を利用可能にする
  (auto-install-compatibility-setup))

;;; package.el
(when (require 'package nil t)
  ;; パッケージレポジトリにMarmaladeと開発者運営のELPAを追加
  (add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/"))
  (add-to-list 'package-archives
               '("ELPA" . "http://tromey.com/elpa/"))
  ;; インストールしたパッケージにロードパスを通して読み込む
  (package-initialize))

;; auto-complete
(when (require 'auto-complete-config nil t)
  (add-to-list 'ac-dictionary-directories
               "~/.emacs.d/elisp/ac-dict")
  (define-key ac-mode-map (kbd "C-\]") 'auto-complete)
  (ac-config-default)
  (setq ac-auto-start nil)
  (setq ac-use-menu-map t)
  ;; デフォルトで設定済み
  (define-key ac-menu-map (kbd "C-n") 'ac-next)
  (define-key ac-menu-map (kbd "C-p") 'ac-previous))

;;; Localeに合わせた環境の設定
(set-locale-environment nil)

;;; キーバインド
(define-key global-map (kbd "C-h") 'delete-backward-char) ; 削除
(define-key global-map (kbd "M-?") 'help-for-help)        ; ヘルプ
(define-key global-map (kbd "C-c i") 'indent-region)      ; インデント
(define-key global-map (kbd "C-c C-i") 'hippie-expand)    ; 補完
(define-key global-map (kbd "C-c ;") 'comment-dwim)       ; コメントアウト
(define-key global-map (kbd "C-o") 'toggle-input-method)  ; 日本語入力切替
(define-key global-map (kbd "M-C-g") 'grep)               ; grep
(define-key global-map (kbd "C-[ M-C-g") 'goto-line)      ; 指定行へ移動
(define-key global-map (kbd "C-m") 'newline-and-indent)   ; RETと対応
(define-key global-map (kbd "C-j") 'newline)

;;C-mode, sh-modeではインデントして改行してインデントする
(add-hook 'c-mode-common-hook
          '(lambda ()
             (local-set-key (kbd "C-m") 'reindent-then-newline-and-indent)))

(add-hook 'sh-mode-hook
          '(lambda ()
             (local-set-key (kbd "C-m") 'reindent-then-newline-and-indent)))

;;; clipboardの使用
(cond (window-system
       (setq x-select-enable-clipboard t)))

;;; ファイルが#!から始まる場合、+xを付けて保存する
(add-hook 'after-save-hook
	  'executable-make-buffer-file-executable-if-script-p)

;;; オートセーブファイルの作成場所を/tmpに変更する
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;;; バックアップファイルの作成場所を/tmpに変更する
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))

;;; カーソルの場所を保存する
(require 'saveplace)
(setq-default save-place t)

;;; 関数定義へジャンプする
(find-function-setup-keys)

;;; 履歴数を大きくする
(setq history-length 10000)

;;; 最近開いたファイルを保存する数を増やす
(setq recentf-max-saved-items 10000)

;;; gzファイルも編集できるようにする
(auto-compression-mode t)

;;; ediffを1ウィンドウで実行
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;;; diffのオプション
(setq diff-switches '("-u" "-p" "-N"))

;;; 再帰的にgrep
(require 'grep)
(setq grep-command-before-query "grep -nH -r -e ")
(defun grep-default-command ()
  (if current-prefix-arg
      (let ((grep-command-before-target
             (concat grep-command-before-query
                     (shell-quote-argument (grep-tag-default)))))
        (cons (if buffer-file-name
                  (concat grep-command-before-target
                          " *."
                          (file-name-extension buffer-file-name))
                (concat grep-command-before-target " ."))
              (+ (length grep-command-before-target) 1)))
    (car grep-command)))
(setq grep-command (cons (concat grep-command-before-query " .")
                         (+ (length grep-command-before-query) 1)))

;;;
;;; 表示関係
;;;

;;; Pairing parentheses
(setq skeleton-pair t)
(global-set-key "(" 'skeleton-pair-insert-maybe)
(global-set-key "[" 'skeleton-pair-insert-maybe)
(global-set-key "{" 'skeleton-pair-insert-maybe)
(global-set-key "\"" 'skeleton-pair-insert-maybe)

;;; 対応する括弧を光らせる。
(show-paren-mode t)

;;; ウィンドウ内に収まらないときだけ括弧内も光らせる。
(setq show-paren-style 'mixed)

;;; Tab文字の表示幅
(setq-default tab-width 4)

;;; インデントにTab文字を使用しない
(setq-default indent-tabs-mode nil)

;;; highlight-indentaion
(when (require 'highlight-indentation nil t))

;;; 行末の空白を表示
(setq-default show-trailing-whitespace t)

;;; 現在行を目立たせる
(defface my-hl-line-face
  ;; 背景がdarkならば背景色を紺に
  '((((class color) (background dark))
     (:background "NavyBlue" t))
    ;; 背景がlightならば背景色を緑に
    (((class color) (background light))
     (:background "LightGoldenrodYellow" t))
    (t (:bold t)))
  "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)
(global-hl-line-mode t)

;;; col-highlight
;(when (require 'col-highlight nil t)
;  (column-highlight-mode 1)
;  (custom-set-faces '(col-highlight ((t (:background "gray50"))))))

;;; カーソルの位置が何文字目かを表示する
(column-number-mode t)

;;; カーソルの位置が何行目かを表示する
(line-number-mode t)

;;; 最終行に必ず一行挿入する
(setq require-final-newline t)

;;; バッファの最後でnewlineで新規行を追加するのを禁止する
(setq next-line-add-newlines nil)

;;; 補完時に大文字小文字を区別しない
(setq completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)

;;; diredを便利にする
(require 'dired-x)

;;; diredから"r"でファイル名をインライン編集する
(require 'wdired)
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)

;;; ファイル名が重複していたらディレクトリ名を追加する。
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

;;; 新規フレームのデフォルト設定
(setq default-frame-alist
      (append
       '((width               . 85)	; フレーム幅(文字数)
         (height              . 47))	; フレーム高(文字数)
       default-frame-alist))

;;; スクロールを一行ずつにする
(setq scroll-step 1)

;;; スクロールバーを右側に表示する
(set-scroll-bar-mode 'right)

;;; ツールバーを消す
(tool-bar-mode nil)

;; フォント設定
(set-face-attribute 'default nil
                    :family "inconsolata"
                    :height 120)

(set-fontset-font "fontset-default"
                  'japanese-jisx0208
                  '("TakaoExゴシック*" . "jisx0208.*"))

(set-fontset-font "fontset-default"
                  'katakana-jisx0201
                  '("TakaoExゴシック*" . "jisx0201.*"))

;;;
;;; auto-insert
;;;
(require 'autoinsert)

;; テンプレートのディレクトリ
(setq auto-insert-directory "~/.emacs.d/template/")

;; 各ファイルによってテンプレートを切り替える
(setq auto-insert-alist
      (nconc '(
               ("\\.c" . ["template.c" ctemplate-replace])
               ("\\.cpp$" . ["template.c" ctemplate-replace])
               ("\\.h$" . ["template.h" ctemplate-replace])
               ("\\.py" . "template.py")
               ("[Mm]akefile" . "Makefile")
               ("\\.tex" . "template.tex")
               ) auto-insert-alist))
(require 'cl)

(defvar template-replacements-alists
  '(("%file%"             . (lambda () (file-name-nondirectory (buffer-file-name))))
    ("%file-without-ext%" . (lambda () (file-name-sans-extension (file-name-nondirectory (buffer-file-name)))))
    ("%include-guard%"    . (lambda () (format "__SCHEME_%s__" (upcase (file-name-sans-extension (file-name-nondirectory buffer-file-name))))))))

(defun ctemplate-replace ()
  (time-stamp)
  (mapc #'(lambda(c)
        (progn
          (goto-char (point-min))
          (replace-string (car c) (funcall (cdr c)) nil)))
    template-replacements-alists)
  (goto-char (point-max))
  (message "done."))

(add-hook 'find-file-not-found-hooks 'auto-insert)

;;; Flymake
(require 'init-flymake)

;;; Yatex
(require 'init-yatex)

;;; Ocaml
(require 'init-ocaml)

;;; Anything
(require 'init-anything)

;;; Python
(require 'init-python)

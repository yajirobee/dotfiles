;; byte-compile elisps
(byte-recompile-directory "~/.emacs.d" 0)

;;;
;;; system configuration
;;;

;;; load path configuration
(when (< emacs-major-version 24)
  (setq load-path (append '("~/.emacs.d") load-path)))

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

;;; settings depends on Locale
(set-locale-environment nil)

;;; keybind
(setq windmove-wrap-around t)
(windmove-default-keybindings)
(define-key global-map (kbd "C-h") 'delete-backward-char) ; backward delete
(define-key global-map (kbd "M-?") 'help-for-help)        ; help
(define-key global-map (kbd "C-c i") 'indent-region)      ; indent
(define-key global-map (kbd "C-c C-i") 'hippie-expand)    ; auto complete
(define-key global-map (kbd "C-o") 'toggle-input-method)  ; change input method
(define-key global-map (kbd "C-c ;") 'comment-dwim)       ; comment out
(define-key global-map (kbd "M-C-g") 'grep)               ; grep
(define-key global-map (kbd "C-[ M-C-g") 'goto-line)      ; go to specified line
(define-key global-map (kbd "C-m") 'newline-and-indent)   ; Retern
(define-key global-map (kbd "C-j") 'newline)
(when (require 'jumplist nil t)
  (define-key global-map (kbd "M-P") 'push-current-place)
  (define-key global-map (kbd "M-p") 'backward-jump)
  (define-key global-map (kbd "M-n") 'forward-jump))

;; in C-mode and sh-mode, indent before and after newline
(add-hook 'c-mode-common-hook
          '(lambda ()
             (local-set-key (kbd "C-m") 'reindent-then-newline-and-indent)))

(add-hook 'sh-mode-hook
          '(lambda ()
             (local-set-key (kbd "C-m") 'reindent-then-newline-and-indent)))

;;; cua mode
(cua-mode t)
(setq cua-enable-cua-keys nil)

;;; using clipboard in emacs gui mode
(cond (window-system (setq x-select-enable-clipboard t)))

;;; if file starts by "#!", change permission to +x
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;;; change auto save file directory to /tmp
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;;; change back up file directory to /tmp
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))

;;; save place of cursor
(when (require 'saveplace nil t)
  (setq-default save-place t))

;;; jumping to function definition
(find-function-setup-keys)

;;; expanding history length
(setq history-length 10000)

;;; increase number of recently used file
(setq recentf-max-saved-items 10000)

;;; enable editing gz file
(auto-compression-mode t)

;;; complete ediff on 1 window
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;;; diff option
(setq diff-switches '("-u" "-p" "-N"))

;;; grep recursively
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

;;; wgrep
(when (require 'wgrep nil t)
  (setf wgrep-enable-key "e")
  (setq wgrep-auto-save-buffer t))

;; color-moccur
(when (require 'color-moccur nil t)
  ;; keybind
  (define-key global-map (kbd "M-o") 'occur-by-moccur) ;in buffer
  (define-key global-map (kbd "C-M-o") 'dmoccur) ;directory
  ;; AND search by space delimiter
  (setq moccur-split-word t)
  ;; excluding files for directory search
  (add-to-list 'dmoccur-exclusion-mask "\\.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$")
  ;; using Migemo if available
  (when (and (executable-find "cmigemo")
             (require 'migemo nil t))
    (setq moccur-use-migemo t))
  (require 'moccur-edit nil t))

;; open large file with read only mode
(defun my-find-file-check-make-large-file-read-only-hook ()
  "If a file is over a given size, make the buffer read only."
  (when (> (buffer-size) (* 1024 1024))
    (setq buffer-read-only t)
    (buffer-disable-undo)
    (fundamental-mode)))

(add-hook 'find-file-hook 'my-find-file-check-make-large-file-read-only-hook)

;; ctags
(when (require 'ctags nil t)
  (setq tags-revert-without-query t)
  ;; command line for ctags
  ;; (setq ctags-command "ctags -e -R")
  ;; keybind
  (define-key global-map (kbd "M-u") 'ctags-create-or-update-tags-table))

;;;
;;; display configuration
;;;

;;; Pairing parentheses
(setq skeleton-pair t)
(global-set-key "(" 'skeleton-pair-insert-maybe)
(global-set-key "[" 'skeleton-pair-insert-maybe)
(global-set-key "{" 'skeleton-pair-insert-maybe)
(global-set-key "\"" 'skeleton-pair-insert-maybe)

;;; highlight correesponding parentheses
(show-paren-mode t)

;;; highlight contents in parenthesis if the correspoinding parenthesis
(setq show-paren-style 'mixed)

;;; Tab width
(setq-default tab-width 4)

;;; disable indentation by Tab character
(setq-default indent-tabs-mode nil)

;;; highlight-indentaion
(when (require 'highlight-indentation nil t))

;;; show tail whitespace
(setq-default show-trailing-whitespace t)

;;; highlight current line
(defface my-hl-line-face
  ;; setting background color
  ;; NavyBlue if background is dark
  '((((class color) (background dark))
     (:background "NavyBlue" t))
    ;; mediumspringgreen if background is light
    (((class color) (background light))
     (:background "mediumspringgreen" t))
    (t (:bold t)))
  "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)
(global-hl-line-mode t)

;;; col-highlight
;(when (require 'col-highlight nil t)
;  (column-highlight-mode 1)
;  (custom-set-faces '(col-highlight ((t (:background "gray50"))))))

;;; display current column
(column-number-mode t)

;;; display current row
(line-number-mode t)

;;; insert final newline
(setq require-final-newline t)

;;; prohibiting add newline on the tail of buffer
(setq next-line-add-newlines nil)

;;; ignore case in completion
(setq completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)

;;; using dired-x
(require 'dired-x)

;;; start inline edit of file name from dired
(require 'wdired)
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)

;;; ls option
(setq dired-listing-switches "-alh")

;;; if the same file names exist in buffer, adding directory names to display file names
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

;;; default frame size
(cond (window-system
       (progn
         ;; use 120 char wide window for largeish displays
         ;; and smaller 80 column windows for smaller displays
         ;; pick whatever numbers make sense for you
         (if (> (x-display-pixel-width) 1280)
             (add-to-list 'default-frame-alist (cons 'width 120))
           (add-to-list 'default-frame-alist (cons 'width 80)))
         ;; for the height, subtract a couple hundred pixels
         ;; from the screen height (for panels, menubars and
         ;; whatnot), then divide by the height of a char to
         ;; get the height we want
         (add-to-list 'default-frame-alist
                      (cons 'height (/ (- (x-display-pixel-height) 100)
                                       (frame-char-height)))))))

;;; set scroll step
(setq scroll-step 1)

;;; display scroll bar right side
(set-scroll-bar-mode 'right)

;;; erase tool bar
(tool-bar-mode 0)

;; font
(set-face-attribute 'default nil
                    :family "inconsolata"
                    :height 120)

(set-fontset-font "fontset-default"
                  'japanese-jisx0208
                  '("TakaoExゴシック*" . "jisx0208.*"))

(set-fontset-font "fontset-default"
                  'katakana-jisx0201
                  '("TakaoExゴシック*" . "jisx0201.*"))

;;; yasnippet
(when (require 'yasnippet nil t)
  (yas-global-mode 1))

;;; ispell
(setq-default ispell-program-name "aspell")
(eval-after-load "ispell"
 '(add-to-list 'ispell-skip-region-alist '("[^\000-\377]+")))

;;; auto-insert
(require 'init-autoinsert)

;;; auto-install
(when (require 'auto-install nil t)
  ;; install directory
  (setq auto-install-directory "~/.emacs.d/elisp/")
  ;; get elisp names registered in EmacsWiki
  (auto-install-update-emacswiki-package-name t)
  ;; if necessary, setting proxy
  ;; (setq url-proxy-service '(("http" . "localhost:8339")))
  ;; enable functions of install-elisp
  (auto-install-compatibility-setup))

;;; package.el
(when (require 'package nil t)
  (add-to-list 'package-archives
               '("melpa" . "http://melpa.milkbox.net/packages/") t)
  (add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/"))
  (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
  ;; setting load path and loading installed packages
  (package-initialize))

;;; auto-complete
(require 'init-auto-complete)

;;; Anything
;(require 'init-anything)

;;; helm
(require 'init-helm)

;;; Flymake
(require 'init-flymake)

;;; Yatex
(require 'init-yatex)

;;; Ocaml
(require 'init-ocaml)

;;; Python
(require 'init-python)

;;; Web
(require 'init-web)

;;; org-mode
(require 'init-org nil t)

;; smartrep
(when (require 'smartrep nil t)
  (defvar ctl-q-map (make-keymap))
  (define-key global-map (kbd "C-q") ctl-q-map)
  (smartrep-define-key global-map (kbd "C-x") '(("o" . 'other-window)))
  (smartrep-define-key global-map (kbd "C-q") '(("l" . 'windmove-right)
                                                ("h" . 'windmove-left)
                                                ("j" . 'windmove-down)
                                                ("k" . 'windmove-up))))

;; configure for postgresql code
(require 'pg-config nil t)

;; configure for windows
(if (eq system-type 'windows-nt)
    (require 'init-windows))
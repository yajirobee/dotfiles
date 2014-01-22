;;; Yatex

(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
(setq auto-mode-alist
      (append '(("\\.tex$" . yatex-mode)
                ("\\.ltx$" . yatex-mode)
                ("\\.cls$" . yatex-mode)
                ("\\.sty$" . yatex-mode)
                ("\\.clo$" . yatex-mode)
                ("\\.bbl$" . yatex-mode)) auto-mode-alist))
(setq YaTeX-inhibit-prefix-letter nil)
(setq YaTeX-kanji-code nil)
(setq YaTeX-use-LaTeX2e t)
(setq YaTeX-use-AMS-LaTeX t)
(setq YaTeX-dvi2-command-ext-alist
      '(("xdg-open\\|texworks\\|evince\\|okular\\|zathura\\|qpdfview\\|pdfviewer\\|mupdf\\|firefox\\|chromium\\|acroread\\|pdfopen" . ".pdf")))
(setq tex-command "platex -kanji=utf8 -no-guess-input-enc -synctex=1 -src-specials")
;(setq YaTeX-use-font-lock t)

;; section color
;(setq YaTeX-hilit-sectioning-face '(light時のforecolor/backcolor dark時の forecolor/backcolor))
;(setq YaTeX-hilit-sectioning-face '(white/snow3 snow1/snow3))
(add-hook 'yatex-mode-hook
          '(lambda ()
             (setq auto-fill-function nil) // disable auto new line
             (when (require 'font-latex nil t)
               (font-latex-setup)
               (progn
                 (modify-syntax-entry ?% "<" (syntax-table))
                 (modify-syntax-entry 10 ">" (syntax-table))
                 (make-variable-buffer-local 'outline-level)
                 (setq outline-level 'latex-outline-level)
                 (make-variable-buffer-local 'outline-regexp)
                 (setq outline-regexp
                       (concat "[  \t]*\\\\\\(documentstyle\\|documentclass\\|chapter\\|"
                               "section\\|subsection\\|subsubsection\\|paragraph\\)"
                               "\\*?[ \t]*[[{]")
                       )))))

; generate pdf from dvi (%s is file name)
(setq dviprint-command-format "dvipdfmx %s")

;;; RefTeX with YaTeX
(add-hook 'yatex-mode-hook
          '(lambda ()
             (reftex-mode 1)
             (define-key reftex-mode-map (concat YaTeX-prefix ">") 'YaTeX-comment-region)
             (define-key reftex-mode-map (concat YaTeX-prefix "<") 'YaTeX-uncomment-region)))
(add-hook 'latex-mode-hook 'turn-on-reftex) ; with Emacs latex mode
(add-hook 'LaTeX-mode-hook 'turn-on-reftex) ; with AUCTeX LaTeX mode
(provide 'init-yatex)

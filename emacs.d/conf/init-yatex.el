;;; Yatex
(provide 'init-yatex)
(setq auto-mode-alist
      (append '(("\\.tex$" . yatex-mode)) auto-mode-alist))
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
(setq YaTeX-inhibit-prefix-letter nil)
(setq YaTeX-kanji-code nil)
(setq tex-command "platex -kanji=utf8 -no-guess-input-enc -synctex=1 -src-specials")
;(setq tex-command "pdfplatex")
;(setq YaTeX-use-font-lock t)

;; section color
;(setq YaTeX-hilit-sectioning-face '(light時のforecolor/backcolor dark時の forecolor/backcolor))
;(setq YaTeX-hilit-sectioning-face '(white/snow3 snow1/snow3))
(add-hook 'yatex-mode-hook
          '(lambda ()
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
; dviからpdfを作成する%sはファイル名
(setq dviprint-command-format "dvipdfmx %s")

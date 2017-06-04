;;; Ocaml

(when (require 'tuareg nil t)
  ;;(autoload 'tuareg-mode "tuareg" "Major mode for editing Caml code" t)
  (autoload 'camldebug "camldebug" "Run the Caml debugger" t)
  (autoload 'tuareg-imenu-set-imenu "tuareg-imenu"
    "Configuration of imenu for tuareg" t)
  (add-hook 'tuareg-mode-hook 'tuareg-imenu-set-imenu)

  (setq auto-mode-alist
        (append '(("\\.ml[ily]?$" . tuareg-mode)
                  ("\\.topml$" . tuareg-mode))
                auto-mode-alist))

  (if (and (boundp 'window-system) window-system)
      (when (string-match "XEmacs" emacs-version)
        (if (not (and (boundp 'mule-x-win-initted) mule-x-win-initted))
            (require 'sym-lock))
        (require 'font-lock))))
(provide 'init-ocaml)

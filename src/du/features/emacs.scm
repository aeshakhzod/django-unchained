(define-module (du features emacs)
  #:use-module (rde packages)
  #:use-module (rde features)
  #:use-module (rde features emacs)
  #:export (feature-personal-emacs-config))

(define* (feature-personal-emacs-config)
  "Personal Emacs configuration with extra packages and settings."
  (define f-name 'personal-emacs-config)

  (define (get-home-services config)
    (list
     (rde-elisp-configuration-service
      f-name
      config
      `((with-eval-after-load 'org
                              (setq org-use-speed-commands t)
                              (setq org-enforce-todo-dependencies t)
                              ;; (setq org-enforce-todo-checkbox-dependencies t)
                              (setq org-log-reschedule 'time)
                              (defun rde-org-goto-end-of-heading ()
                                (interactive)
                                (org-end-of-meta-data t)
                                (left-char)
                                (unless (string-blank-p (buffer-substring (line-beginning-position)
                                                                          (line-end-position)))
                                  (newline)))
                              (define-key org-mode-map (kbd "M-o") 'rde-org-goto-end-of-heading))

        ((with-eval-after-load 'telega
                               (telega-adblock-mode 1)
                               (telega-notifications-mode 1)))

        (use-package rustic
                     :ensure t
                     :config
                     (setq rustic-format-on-save nil)
                     :custom
                     (rustic-cargo-use-last-stored-arguments t))

        (use-package vterm
                     :ensure t)

        ;; https://gluer.org/blog/eglot-keybindings-that-i-use/
        (use-package eglot
                     :bind (:map eglot-mode-map
	                    ("C-c l a" . eglot-code-actions)
	                    ("C-c l r" . eglot-rename)
	                    ("C-c l h" . eldoc)
	                    ("C-c l f" . eglot-format)
	                    ("C-c l F" . eglot-format-buffer)
	                    ("C-c l d" . xref-find-definitions-at-mouse)
	                    ;; sometimes ionide acts up
	                    ("C-c l R" . eglot-reconnect)))

        (use-package nix-mode
                     :mode "\\.nix\\'")

        (with-eval-after-load 'geiser-mode
                              (setq geiser-mode-auto-p nil)
                              (defun abcdw-geiser-connect ()
                                (interactive)
                                (geiser-connect 'guile "localhost" "37146"))

                              (define-key geiser-mode-map (kbd "C-c M-j") 'abcdw-geiser-connect))

        (with-eval-after-load 'page-break-lines
                              (global-page-break-lines-mode 1))
        (with-eval-after-load 'simple
                              (setq-default display-fill-column-indicator-column 80)
                              (add-hook 'prog-mode-hook 'display-fill-column-indicator-mode))

        (setq copyright-names-regexp
              (format "%s <%s>" user-full-name user-mail-address))
        (add-hook 'after-save-hook (lambda () (copyright-update nil nil))))
      #:elisp-packages
      (append
       (list
        ;; (@ (rde packages emacs-xyz) emacs-corfu-candidate-overlay)
        )
       (strings->packages
        ;; "emacs-dirvish"
        "emacs-elixir-mode"
        "emacs-company-posframe"
        "emacs-wgrep"
        "emacs-ox-haunt"
        "emacs-haskell-mode"
        "emacs-rainbow-mode"
        "emacs-hl-todo"
        "emacs-yasnippet"
        ;; "emacs-xkb-mode"
        ;; "emacs-consult-dir"
        "emacs-kind-icon"
        "emacs-nginx-mode"
	"emacs-yaml-mode"
        "emacs-multitran"
        "emacs-minimap"
        "emacs-ement"
        "emacs-restart-emacs"
        "emacs-org-present"
        "emacs-rustic"
        "emacs-vterm"
        "emacs-nix-mode")))))
  (feature
   (name f-name)
   (values `((,f-name . #t)))
   (home-services-getter get-home-services)))

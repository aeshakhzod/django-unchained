(define-module (du users shakhzod)
  #:use-module (contrib features javascript)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services xdg)
  #:use-module (gnu home services)
  #:use-module (gnu home-services ssh)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages window-management)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages bash)
  #:use-module (gnu services)
  #:use-module (gnu services admin)
  #:use-module (gnu services base)
  #:use-module (gnu services desktop)
  #:use-module (gnu services sddm)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services sysctl)
  #:use-module (guix channels)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix inferior)
  #:use-module (guix packages)
  #:use-module (rde features android)
  #:use-module (rde features base)
  #:use-module (rde features clojure)
  #:use-module (rde features containers)
  #:use-module (rde features difftastic)
  #:use-module (rde features emacs)
  #:use-module (rde features emacs-xyz)
  #:use-module (rde features fontutils)
  #:use-module (rde features gnupg)
  #:use-module (rde features ghostty)
  #:use-module (rde features gtk)
  #:use-module (rde features guile)
  #:use-module (rde features irc)
  #:use-module (rde features keyboard)
  #:use-module (rde features libreoffice)
  #:use-module (rde features linux)
  #:use-module (rde features llm)
  #:use-module (rde features mail)
  #:use-module (rde features matrix)
  #:use-module (rde features markup)
  #:use-module (rde features networking)
  #:use-module (rde features niri)
  #:use-module (rde features ocaml)
  #:use-module (rde features password-utils)
  #:use-module (rde features presets)
  #:use-module (rde features security-token)
  #:use-module (rde features sourcehut)
  #:use-module (rde features system)
  #:use-module (rde features terminals)
  #:use-module (rde features uml)
  #:use-module (rde features version-control)
  #:use-module (rde features video)
  #:use-module (rde features virtualization)
  ;; #:use-module (rde features wm)
  #:use-module (rde features xdg)
  #:use-module (rde features)
  #:use-module (rde home services emacs)
  #:use-module (rde home services i2p)
  #:use-module (rde home services shells)
  #:use-module (rde home services video)
  ;; #:use-module (rde home services wm)
  #:use-module (rde packages aspell)
  #:use-module (rde packages)
  #:use-module (srfi srfi-1)
  #:use-module (du features nix))


;;; Helpers

(define* (mail-acc id user #:optional (type 'gmail))
  "Make a simple mail-account with gmail type by default."
  (mail-account
   (id   id)
   (fqda user)
   (type type)))

(define* (mail-lst id fqda urls)
  "Make a simple mailing-list."
  (mailing-list
   (id   id)
   (fqda fqda)
   (config (l2md-repo
            (name (symbol->string id))
            (urls urls)))))

(define (feature-kanata)
  (define (kanata-system-services config)
    (list
     (service
      kanata-service-type
      (kanata-configuration
       (keymaps
        (list
         (local-file
          ((@ (rde lib file) find-file-in-load-path)
           "du/files/config/kanata/kanata.kbd"))))))))

  (feature
   (name 'kanata)
   (system-services-getter kanata-system-services)))


;;; Wallpapers

(define (wallpaper url name hash)
  (origin
   (method url-fetch)
   (uri url)
   (file-name name)
   (sha256 (base32 hash))))

;; https://wallhaven.cc/search?q=id%3A37&categories=110&purity=100&atleast=3840x1600&sorting=hot
(define wallpapers
  (list
   ;; https://wallhaven.cc/w/w5w866
   (wallpaper "https://w.wallhaven.cc/full/w5/wallhaven-w5w866.jpg"
              "wuye-youshen-1.jpg"
              "01spgksqayqnkps08w6xzkzmxrz6f8wnrh99liv6hvk2mwpl06yr")))

(define (feature-wallpapers)
  (define (wallpapers-home-services config)
    (list
     (simple-service
      'copy-wallpapers-to-home-folder
      home-files-service-type
      ;; TODO: make that nice in the future
      `(("Pictures/Wallpapers/wuye-youshen-1.jpg" ,(car wallpapers))))))

  (feature
   (name 'wallpapers)
   (home-services-getter wallpapers-home-services)))


;;; Plasma

(define (feature-plasma)
  (define (plasma-system-services config)
    (list
     (service
      plasma-desktop-service-type
      (plasma-desktop-configuration))

     (service
      sddm-service-type
      (sddm-configuration))

     (service
      kwallet-service-type
      (kwallet-configuration))))

  (feature
   (name 'plasma)
   (system-services-getter plasma-system-services)))



;;; Service extensions

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

(define home-extra-packages-service
  (simple-service
   'home-profile-extra-packages
   home-profile-service-type
   (append
    (list
     (@ (gnu packages tree-sitter) tree-sitter-clojure)
     (@ (gnu packages tree-sitter) tree-sitter-html))
    (strings->packages
     "figlet" ;; TODO: Move to emacs-artist-mode
     ;; "calibre"
     ;; "nyxt"

     "dino"
     "libnotify"
     "utox" "qtox"
     ;; "jami"

     "flatpak"

     "python-yubikey-manager"

     "alsa-utils"
     ;; "cozy"
     "pavucontrol" "wev"
     "imagemagick"
     "obs" "obs-wlrobs"
     "recutils" "binutils" "make" "gdb"
     "fheroes2" "sdlpop"

     "hicolor-icon-theme" "adwaita-icon-theme" "gnome-themes-extra"
     ;; "papirus-icon-theme" ; 85k files
     "arc-theme"
     "fd"
     "nautilus"
     "qbittorrent"
     "kdenlive"
     ;; "glib:bin"

     ;; "ffmpeg"
     "ripgrep"
     ;; "element-desktop"
     "keepassxc"
     "swaybg"
     "vim"
     "kanata"
     )
    (list curl))))

(define rde-guix-add-to-shell-profile-service
  (simple-service
   'rde-guix-add-to-shell-profile
   home-shell-profile-service-type
   (list "
GUIX_PROFILE=/data/abcdw/work/abcdw/rde/examples/target/profiles/guix
if [ -f $GUIX_PROFILE/etc/profile ]; then source $GUIX_PROFILE/etc/profile; fi
")))

(define (feature-additional-services)
  (feature-custom-services
   #:feature-name-prefix 'shakhzod
   #:home-services
   (list
    home-extra-packages-service

    ;; xkb-symbols-us-service
    ;; ssh-extra-config-service
    ;; i2pd-add-ilita-irc-service
    ;; rde-guix-add-to-shell-profile-service
    ;; mpv-add-user-settings-service
    )))

;;; User-specific features with personal preferences

;; Initial user's password hash will be available in store, so use this
;; feature with care (display (crypt "hi" "$6$abc"))

(define dev-features
  (list
   (feature-markdown)))

(define virtualization-features
  (list
   (feature-podman)
   (feature-distrobox)
   (feature-qemu)))

(define general-features
  (append
   rde-base
   ;; rde-desktop
   ;; rde-mail
   rde-cli
   rde-emacs))

(define %all-features
  (append
   virtualization-features
   dev-features
   general-features))

;; To override default features obtained from (rde presets) just remove them
;; from the list and add them back with customizations needed.
(define shakhzod-all-features
  (append
   ;; "C-h S" (info-lookup-symbol), "C-c C-d C-i" (geiser-doc-look-up-manual)
   ;; to see the info manual for a particular function.

   ;; Here we basically remove all the features which has feature name equal
   ;; to either 'base-services or 'kernel.
   (remove (lambda (f)
             (member
              (feature-name f)
              '(base-services
                kernel
                sway
                swaylock
                xdg
                guile
                git
                wayland-compositor-run-on-tty
                vterm)))
           %all-features)
   (list
    (feature-nix)
    (feature-plasma)
    (feature-wallpapers)
    (feature-kanata)
    (feature-git)
    (feature-guile)
    (feature-base-services))))

(define-public %shakhzod-features
  (append
   shakhzod-all-features
   (list
    (feature-additional-services)
    (feature-user-info
     #:user-name "shakhzod"
     #:full-name "Shakhzod Kudratov"
     #:email "shakhzodkudratov@gmail.com"
     #:user-groups '("wheel" "netdev" "audio" "video" "dialout" "uinput" "input"))
    (feature-gnupg
     #:gpg-primary-key "5A1E1590CA201638ECCF834FD98C2DC59CFA95D4"
     ;; #:ssh-keys '(("58AAE5966479124A357F7D6B9D710EBA1C24E10E"))
     )
    (feature-irc-settings
     #:irc-accounts (list
		     (irc-account
		      (id 'libera)
		      (network "irc.libera.chat")
		      (nick "aeshakhzod"))))
    (feature-personal-emacs-config)
    (feature-keyboard
     ;; To get all available options, layouts and variants run:
     ;; cat `guix build xkeyboard-config`/share/X11/xkb/rules/evdev.lst
     ;; To get a list of symbols and actions:
     ;; cat `guix build xorgproto`/include/X11/keysymdef.h
     #:keyboard-layout
     (keyboard-layout
      "us" ""
      ))
    ;; (feature-mail-settings
    ;;  #:mail-directory-fn (const "/data/abcdw/mail")
    ;;  #:mail-accounts (list
    ;;                   (mail-account
    ;;                    (id 'work)
    ;;                    (type 'migadu)
    ;;                    (fqda "andrew@trop.in")
    ;;                    (aliases '("admin@trop.in" "postmaster@trop.in"))
    ;;                    (pass-cmd "pass show mail/work"))
    ;;                   (mail-account
    ;;                    (id 'personal)
    ;;                    (type 'migadu)
    ;;                    (fqda "mail@trop.in")
    ;;                    (pass-cmd "pass show mail/personal")))
    ;;  #:mailing-lists (list (mail-lst 'guile-devel "guile-devel@gnu.org"
    ;;                                  '("https://yhetil.org/guile-devel/0"))
    ;;                        (mail-lst 'guix-devel "guix-devel@gnu.org"
    ;;                                  '("https://yhetil.org/guix-devel/0"))
    ;;                        (mail-lst 'guix-bugs "guix-bugs@gnu.org"
    ;;                                  '("https://yhetil.org/guix-bugs/0"))
    ;;                        (mail-lst 'guix-patches "guix-patches@gnu.org"
    ;;                                  '("https://yhetil.org/guix-patches/1"))))

    ;; (feature-emacs-keycast #:turn-on? #t)

    ;; (feature-emacs-tempel
    ;;  #:default-templates? #t
    ;;  #:templates
    ;;  `(fundamental-mode
    ;;    ,#~""
    ;;    (t (format-time-string "%Y-%m-%d"))
    ;;    (todo
    ;;     (if (derived-mode-p 'lisp-data-mode 'clojure-mode 'scheme-mode)
    ;;         ";;"
    ;;         comment-start)
    ;;     (if (string-suffix-p " " comment-start) "" " ")
    ;;     "TODO"  ": [" user-full-name ", "
    ;;     (format-time-string "%Y-%m-%d") "] ")
    ;;    ;; TODO: Move to feature-guix
    ;;    ;; ,((@ (rde gexp) slurp-file-like)
    ;;    ;;   (file-append ((@ (guix packages) package-source)
    ;;    ;;                 (@ (gnu packages package-management) guix))
    ;;    ;;                "/etc/snippets/tempel/text-mode"))
    ;;    ))
    ;; (feature-emacs-time)
    ;; (feature-emacs-spelling
    ;;  #:spelling-program (@ (gnu packages hunspell) hunspell)
    ;;  #:spelling-dictionaries
    ;;  (list
    ;;   (@ (gnu packages hunspell) hunspell-dict-en)
    ;;   (@ (rde packages aspell) hunspell-dict-ru)))
    ;; (feature-emacs-git
    ;;  #:project-directory "/data/abcdw/work")
    ;; ;; https://plaindrops.de/blog/2020/GTDorgmode/
    ;; ;; https://www.labri.fr/perso/nrougier/GTD/index.html#org2d62325
    ;; (feature-emacs-org
    ;;  #:org-directory "/data/abcdw/work/abcdw/private"
    ;;  #:org-indent? #f
    ;;  #:org-capture-templates
    ;;  ;; https://libreddit.tiekoetter.com/r/orgmode/comments/gc76l3/org_capture_inside_notmuch/
    ;;  `(("r" "Reply" entry (file+headline "" "Tasks")
    ;;     "* TODO %:subject %?\nSCHEDULED: %t\n%U\n%a\n"
    ;;     :immediate-finish t)
    ;;    ("t" "Todo" entry (file+headline "" "Tasks") ;; org-default-notes-file
    ;;     "* IDEA %?\nSCHEDULED: %t\n%a\n")
    ;;    ("s" "Subtask" entry (function rde-org-find-subtask-location)
    ;;     "* TODO %?\nSCHEDULED: %t\n%a\n")
    ;;    ;; ("s" "Subtask" entry (function org-capture-target-under-point)
    ;;    ;;  "* TODO %?\n  %i\n  %a")
    ;;    ("p" "PhD Todo" entry
    ;;     (file+headline "/data/abcdw/work/abcdw/private/phd.org" "Tasks")
    ;;     "* TODO %?\nSCHEDULED: %t\n%a\n")))
    ;; (feature-emacs-org-roam
    ;;  ;; TODO: Rewrite to states
    ;;  #:org-roam-directory "/data/abcdw/work/abcdw/notes/notes")
    ;; (feature-emacs-org-dailies
    ;;  #:encrypted? #t)

    ;; (feature-emacs-org-agenda
    ;;  ;; Add efforts to agenda, it's a bit space hungry, so not included in
    ;;  ;; feature by default yet.
    ;;  #:org-agenda-prefix-format
    ;;  '((agenda . " %i %-12:c%-6e%?-12t% s")
    ;;    (todo . " %i %-12:c %-6e")
    ;;    (tags . " %i %-12:c")
    ;;    (search . " %i %-12:c"))
    ;;  #:org-agenda-files '("/data/abcdw/work/abcdw/private/todo.org"
    ;;                       "/data/abcdw/work/abcdw/private/phd.org"))
    ;; (feature-emacs-elfeed
    ;;  #:elfeed-org-files '("/data/abcdw/work/abcdw/private/rss.org"))

    ;; (feature-android)
    ;; (feature-javascript)
    ;; (feature-ocaml #:opam? #t)

    ;; (feature-emacs-piem
    ;;  #:piem-inboxes '(("rde-devel"
    ;;                    :url "https://lists.sr.ht/~abcdw/rde-devel"
    ;;                    :address "~abcdw/rde-devel@lists.sr.ht"
    ;;                    :coderepo ("~/work/abcdw/rde/"
    ;;                               "~/work/abcdw/emacs-arei/"
    ;;                               "~/work/abcdw/guile-ares-rs/"))
    ;;                   ("guix-devel"
    ;;                    :url "https://yhetil.org/guile-devel/"
    ;;                    :address "guile-devel@gnu.org"
    ;;                    :coderepo "~/work/gnu/guile/")
    ;;                   ("guix-patches"
    ;;                    :url "https://yhetil.org/guix-patches/"
    ;;                    :address "guix-patches@gnu.org"
    ;;                    :coderepo "~/work/gnu/guix/")))
    ;; TODO: move feature to general, move extra configuration to service.
    ;;     (feature-notmuch
    ;;      #:notmuch-queries
    ;;      '((rde-all . "to:\"rde-devel\" or to:\"rde-discuss\" or tag:rde")
    ;;        (rde-inbox . "query:rde-all and tag:inbox"))
    ;;      #:extra-tag-updates-post
    ;;      '("notmuch tag +guix-home +inbox -- 'thread:\"\
    ;; {((subject:guix and subject:home) or (subject:service and subject:home) or \
    ;; subject:/home:/) and tag:new}\"'"
    ;;        "notmuch tag +rde +list -- 'to:.*rde.*@lists.sr.ht and tag:new}'")
    ;;      #:notmuch-saved-searches
    ;;      (append
    ;;       ;; TODO: [Andrew Tropin, 2024-01-07] Archive replied emails automatically
    ;;       '((:name "To Process"
    ;;          :query "tag:todo or (tag:inbox and not tag:unread and not tag:replied)"
    ;;          :key "t")
    ;;         (:name "Drafts" :query "tag:draft" :key "d")
    ;;         (:name "Watching" :query "thread:{tag:watch} and tag:unread" :key "w")
    ;;         (:name "RDE Inbox"
    ;;          :query "query:rde-inbox" :key "ir")
    ;;         (:name "RDE All"
    ;;          :query "query:rde-all" :key "pr")
    ;;         (:name "Project Suitbl"
    ;;          :query "to: 2024-10-272@NLnet.nl or \
    ;; to:srfi-269@srfi.schemers.org or tag:suitbl"
    ;;          :key "ps")
    ;;         (:name "Project Guile Build Daemon"
    ;;          :query "to:2023-04-050@nlnet.nl or tag:guile-build-daemon" :key "pg")
    ;;         (:name "Project Guile Hoot IDE"
    ;;          :query "to:2025-10-436@nlnet.nl or tag:guile-hoot-ide" :key "ph")
    ;;         (:name "Work Inbox (Unsorted)"
    ;;          :query "(tag:work and tag:inbox) and not query:rde-all"
    ;;          :key "iu")
    ;;         (:name "Work Inbox"
    ;;          :query "tag:work and tag:inbox"
    ;;          :key "iw")
    ;;         (:name "Personal Inbox"
    ;;          :query "tag:personal and tag:inbox"
    ;;          :key "ip")
    ;;         (:name "Guix Home Inbox" :key "H" :query "tag:guix-home and tag:unread"))
    ;;       ;; %rde-notmuch-saved-searches
    ;;       '()))

    ;; (feature-sourcehut
    ;;  #:user-name-fn (const "abcdw"))
    ;; (feature-yt-dlp)

    ;; (feature-plantuml)
    ;; (feature-clojure)
    ;; (feature-libreoffice)

    ;; TODO: Remove auctex dependency, which interjects in texinfo-mode.
    ;; (feature-emacs-citation
    ;;  #:global-bibliography
    ;;  (list "/data/abcdw/work/abcdw/notes/bibliography.bib"))

    ;; (feature-font-japanese)
    ;; (feature-emacs-gptel)
    ;; (feature-emacs-ellama)
    ;; (feature-emacs-cua)
    ;; (feature-difftastic
    ;;  #:parse-error-limit 1000)

    )))

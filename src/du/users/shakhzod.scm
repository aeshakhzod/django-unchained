(define-module (du users shakhzod)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (rde features base)
  #:use-module (rde features containers)
  #:use-module (rde features gnupg)
  #:use-module (rde features guile)
  #:use-module (rde features keyboard)
  #:use-module (rde features markup)
  #:use-module (rde features presets)
  #:use-module (rde features version-control)
  #:use-module (rde features virtualization)
  #:use-module (rde features irc)
  #:use-module (rde features)
  #:use-module (rde packages)
  #:use-module (srfi srfi-1))

(define (feature-home-shepherd)
  (define (home-shepherd-system-services config)
    (list
     (service
      home-profile-service-type
      (list))
     (service
      home-shepherd-service-type
      (home-shepherd-configuration))))

  (feature
   (name 'home-shepherd)
   (system-services-getter home-shepherd-system-services)))


;;; Service extensions

(define home-extra-packages-service
  (simple-service
   'home-profile-extra-packages
   home-profile-service-type
   (append
    ;; (list
    ;;  (@ (gnu packages tree-sitter) tree-sitter-clojure)
    ;;  )
    (strings->packages
     ;; "nyxt"
     "dbus"
     "recutils" "binutils" "make" "gdb"
     "ripgrep"
     "keepassxc"
     "vim")
    (list
     ;; (@ (du packages aerothemeplasma) aeroshell-components)
       ))))


(define (feature-additional-services)
  (feature-custom-services
   #:feature-name-prefix 'shakhzod
   #:home-services
   (list
    home-extra-packages-service)))


;;; User-specific features with personal preferences

(define %all-features
  (append
   rde-base
   ;; rde-desktop
   ;; rde-mail
   rde-cli
   rde-emacs

   (list
    (feature-podman)
    (feature-distrobox)
    (feature-qemu)
    (feature-markdown))))

(define-public %shakhzod-features
  (append
   ;; To override default features obtained from (rde presets) just remove them
   ;; from the list and add them back with customizations needed.

   ;; "C-h S" (info-lookup-symbol), "C-c C-d C-i" (geiser-doc-look-up-manual)
   ;; to see the info manual for a particular function.

   ;; Here we basically remove all the features which has feature name equal
   ;; to either 'base-services or 'kernel.
   (remove (lambda (f)
             (member
              (feature-name f)
              '(
                ;; base-services
                kernel
                sway
                swaylock
                xdg
                guile
                git
                wayland-compositor-run-on-tty
                vterm
                input-method
                networking
                backlight)))
           %all-features)
   (list
    ((@ (du features nix) feature-nix))
    ((@ (du features plasma) feature-plasma))
    ((@ (du features wallpapers) feature-wallpapers))
    ((@ (du features kanata) feature-kanata))
    ((@ (du features networking) feature-networking-nonrde))
    ((@ (du features emacs) feature-personal-emacs-config))
    (feature-git)
    (feature-guile)
    ;; (feature-home-shepherd)
    (feature-additional-services)
    (feature-user-info
     #:user-name "shakhzod"
     #:full-name "Shakhzod Kudratov"
     #:email "shakhzodkudratov@gmail.com"
     #:user-groups '("wheel" "netdev" "audio" "video" "dialout" "uinput" "input"))
    (feature-irc-settings
     #:irc-accounts (list
                     (irc-account
                      (id 'libera)
                      (network "irc.libera.chat")
                      (nick "aeshakhzod"))))
    (feature-gnupg #:gpg-primary-key "5A1E1590CA201638ECCF834FD98C2DC59CFA95D4")
    (feature-keyboard #:keyboard-layout (keyboard-layout "us" "")))))

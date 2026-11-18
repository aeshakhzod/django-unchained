(define-module (du features nix)
  #:use-module (rde features)
  #:use-module (gnu services)
  #:use-module (gnu services nix)
  #:use-module (gnu home services)
  #:use-module (gnu packages)
  #:export (feature-nix))

;; I took it from https://github.com/engstrand-config/guix-dotfiles repo, thank you very much!
(define* (feature-nix)
  "Setup the nix package manager."

  (define (get-system-services config)
    "Return a list of system services required by nix."
    (list
     (simple-service
      'add-nix-system-packages-to-profile
      profile-service-type
      (list
       (specification->package "nix")))
     (service nix-service-type)))

  (define (get-home-services config)
    "Return a list of home services required by nix."
    (list
     ;; TODO: This is kindy of hacky and does not set all necessary variables.
     ;;       The better solution is to source /run/current-system/profile/etc/profile.d/nix.sh,
     ;;       but I am not shure how to source files in Guile. If we figure it out, we can probably
     ;;       source it in the "startup-commands" field of dwl-guile.
     (simple-service
      'add-nix-bin-to-path
       home-environment-variables-service-type
       `(("PATH" . ,(string-append "$HOME/.nix-profile/bin:"
                                   (getenv "PATH")))))))

  (feature
   (name 'nix)
   (system-services-getter get-system-services)
   (home-services-getter get-home-services)))

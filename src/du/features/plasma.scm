(define-module (du features plasma)
  #:use-module (rde features)
  #:use-module (gnu services)
  #:use-module (gnu services desktop)
  #:use-module (gnu services sddm)
  #:use-module (gnu services pm)
  #:use-module (gnu home services)
  #:use-module (gnu packages kde-plasma)
  #:use-module (guix gexp))

(define-public (feature-plasma)
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
      (kwallet-configuration))

     (service
        power-profiles-daemon-service-type
        (power-profiles-daemon-configuration))))

  (define (plasma-home-services config)
    (list
     (simple-service
      'plasma-set-environment-variables
      home-environment-variables-service-type
      `(("SSH_ASKPASS" . ,(file-append ksshaskpass "/bin/ksshaskpass"))))))

  (feature
   (name 'plasma)
   (system-services-getter plasma-system-services)
   (home-services-getter plasma-home-services)))

(define-module (du features kanata)
  #:use-module (rde features)
  #:use-module (gnu services)
  #:use-module (gnu services desktop)
  #:use-module (guix gexp))

(define-public (feature-kanata)
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

(define-module (du features networking)
  #:use-module (rde features)
  #:use-module (gnu services)
  #:use-module (gnu services networking))

(define-public (feature-networking-nonrde)
  (feature
   (name 'networking-nonrde)
   (system-services-getter
    (lambda (config)
      (list
       (service
        network-manager-service-type
        (network-manager-configuration
         (shepherd-requirement '(iwd))))
       (service
        iwd-service-type
        (iwd-configuration)))))))

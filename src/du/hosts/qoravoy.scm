(define-module (du hosts qoravoy)
  #:use-module (rde features base)
  #:use-module (rde features system)
  #:use-module (rde features wm)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (ice-9 match))

(define qoravoy-mapped-devices
  (list (mapped-device
	 (source (uuid "7525db80-cea0-4d96-9349-b0f25e7a9123"))
	 (target "cryptroot")
	 (type luks-device-mapping))))

(define qoravoy-file-systems
  (list
   (file-system
    (mount-point "/")
    (device "/dev/mapper/cryptroot")
    (type "btrfs")
    (dependencies qoravoy-mapped-devices))
   (file-system
    (mount-point "/boot/efi")
    (device (uuid "35E0-C938" 'fat32))
    (type "vfat"))))

(define-public %qoravoy-features
  (list
   (feature-host-info
    #:host-name "qoravoy"
    #:timezone "Asia/Tashkent")

   (feature-kernel
    #:kernel linux
    #:initrd microcode-initrd
    #:firmware (list
                sof-firmware
                linux-firmware))

   (feature-file-systems
    #:mapped-devices qoravoy-mapped-devices
    #:file-systems   qoravoy-file-systems)

   ;; feature-kanshi for laptop state

   (feature-hidpi)))

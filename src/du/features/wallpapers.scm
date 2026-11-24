(define-module (du features wallpapers)
  #:use-module (rde features)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (gnu services)
  #:use-module (gnu home services))

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

(define-public (feature-wallpapers)
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

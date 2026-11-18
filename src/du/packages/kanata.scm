(define-module (du packages kanata)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module (guix licenses))

(define-public kanata
  (let ((version "1.12.0")
        (hash "01jsdwp1yxg5kc40wdnx2awizs98b9ncky546v88v8hc0676cdss"))

    (package
     (name "kanata")
     (version version)
     (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/jtroo/kanata.git")
                    (commit (string-append "v" version))))
              (sha256 (base32 hash))))
     (build-system cargo-build-system)
     (synopsis "Improve keyboard comfort and usability with advanced customization")
     (description "Improve keyboard comfort and usability with advanced customization")
     (home-page "https://github.com/jtroo/kanata")
     (license lgpl3))))

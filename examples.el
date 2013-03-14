(require 'thinatra)

(elnode-stop 8021)

;; Show all of the vars passed in.
(get "/test1/:a/:b/:c/:d"
  (message
   (format "we are in %s controller a:%s b:%s c:%s d:%s"
           (th-get-controller-from-path path) a b c d )))

;; Add two numbers
(get "/sum/:a/:b"
  (message 
     (format "%i"
             (+ (string-to-number a)
                (string-to-number b)))))

(defun th-controller-pwgen (path)
  "open http://localhost:8028/pwgen to get a random password each time"

  ;; Following functions taken from http://github.com/ober/sgpass
  (defun b64-md5 (pickle)
    "Encrypt the string given to us as Base64 encoded Md5 byte stream"
    (replace-regexp-in-string "=" "A" (replace-regexp-in-string "+" "9" (replace-regexp-in-string "/" "8" (base64-encode-string (secure-hash 'md5 pickle nil nil t))))))

  (defun sgp-generate (password domain)
    "Create a unique password for a given domain and master password"
    (let ((i 0) (results (format "%s:%s" password domain)))
      (setq results (format "%s:%s" password domain))
      (while
          (not (and (> i 9) (secure-enough results 10)))
        (setq results (b64-md5 results))
        (setq i (1+ i)))
      (substring results 0 10)))

  (defun secure-enough (results len)
    "Ensure the password we have is sufficiently secure"
    (let
        ((case-fold-search nil))
      (and
       (> (length results) len)
       (string-match "[0-9]" (substring results 0 len))
       (string-match "[A-Z]" (substring results 0 len))
       (string-match "^[a-z]" (substring results 0 len)))))
  (message (format "<h1>%s</h1>" (sgp-generate  (random 1000000) (random 1000000)))))

(elnode-start 'th-event-handler :port 8021 :host "localhost")

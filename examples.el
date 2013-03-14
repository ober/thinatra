(require 'thinatra)

(elnode-stop 8021)

;; hello world
(get "/helloworld"
  "Hello world!")

;; about
(get "/about"
  "A little about me.")

;; Hello name/city
(get "/hello/:name/:city"
  (format "Hey there %s from %s" name city))

;; Talk to the doctor;;
;; Need to figure out how to redirect output to web page.
(get "/doctor"
  (doctor))

;; Show my daily agenda
;; Need to figure out how to redirect output to web page.
(get "/agenda/:days"
  (org-agenda-list days))

;; generate random secure password
;;(require 'supergenpass) ;; http://github.com/ober/sgpass
(get "/pwgen"
  (s-pwgen))

;; Show all of the vars passed in.
(get "/test1/:a/:b/:c/:d"
  (message
   (format
    "we are in controller:%s a:%s b:%s c:%s d:%s"
    controller a b c d )))

;; Add two numbers
(get "/sum/:a/:b"
  (message 
   (format "%i"
           (+ (string-to-number a)
              (string-to-number b)))))

(elnode-start 'th-event-handler :port 8021 :host "localhost")

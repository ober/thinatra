(require 'thinatra)

;; Basic page
(get "/"
  "Welcome to Thinatra!")

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
  (with-stdout-to-elnode httpcon (doctor)))

;; Show my daily agenda
;; Need to figure out how to redirect output to web page.
(get "/agenda/:days"
  (with-stdout-to-elnode httpcon (org-agenda-list days)))

;; generate random secure password
;;(require 'supergenpass) ;; http://github.com/ober/sgpass
(get "/pwgen"
  (s-pwgen))

;; Show all of the vars passed in.
(get "/test1/:a/:b/:c/:d"
    (format "we are in controller:%s a:%s b:%s c:%s d:%s" controller a b c d ))

;; Route patterns may also include splat (or wildcar) parameters
(get "/say/*/to/*"
  splat)

;; Use ruby-esque string interpolation. (this sucked to do)
(get "/hello/:a/:b/:c"
  "Hello to #{a} and #{b} and #{c}")

;; Add two numbers
(get "/sum/:a/:b"
  (number-to-string
   (+
    (string-to-number a)
    (string-to-number b))))

(th-server-start 8021 "0.0.0.0")

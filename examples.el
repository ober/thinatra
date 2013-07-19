(require 'thinatra)
(require 'rubyinterpol)

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
  (ria "GET! hey there #{name} from #{city}" parms))

(post "/hello/:name/:city"
  (format "params:%s" params)

;; Talk to the doctor;;
;; Need to figure out how to redirect output to web page.
(get "/doctor"
  (with-stdout-to-elnode httpcon (doctor)))

;; Show my daily agenda
;; Need to figure out how to redirect output to web page.
(get "/agenda/:days"
  (with-stdout-to-elnode httpcon (org-agenda-list days)))

;; generate random secure password
;;(require 'supergenpass) ;; M-x package-install <ret> supergenpass <ret>
;; (get "/pwgen"
;;   (s-pwgen)) # !> useless use of - in void context

;; Show all of the vars passed in.
(get "/test1/:a/:b/:c/:d"
  "We are in #{controller} a:#{a} b:#{b} c:#{c} d:#{d}")

;; Route patterns may also include splat (or wildcar) parameters
(get "/say/*/to/*"
  splat)

;; Evaluate Go-lang Fibonacci
;; (require 'das-ich)
;; (get-go "/fib/:number"
;;   "
;;   ;; (setq code
;; ;;    (ris "
;; package main

;; import (
;; 	\"fmt\"
;; 	\"flag\"
;; )

;; func fib(n int) uint64 {
;; 	if n < 2 {
;; 		return 1
;; 	}
;; 	return (fib(n-1) + fib(n-2))
;; }

;; func fib2(n int) uint64 {
;; 	if n < 2 {
;; 		return 1
;; 	}
;; 	var n1 uint64 = 1
;; 	var n2 uint64 = 1
;; 	for i := 2; i < n; i++ {
;; 		t := n2
;; 		n2 += n1
;; 		n1 = t
;; 	}
;; 	return n2
;; }

;; func main() {
;; 	var n int
;; 	var f bool
;; 	flag.IntVar(&n, \"n\", #{number}, \"number to calc\")
;; 	flag.BoolVar(&f, \"f\", true, \"func to use(default=fast)\")
;; 	flag.Parse()
;; 	var x uint64 = 0
;; 	if f {
;; 		x = fib2(n)
;; 	} else {
;; 		x = fib(n)
;; 	}
;; 	fmt.Printf(\"fib[%d]=%d\n\", n, x)
;; }
;; "
;; "1"
;;  )

;; Add two numbers
(get "/sum/:a/:b"
  (number-to-string
   (+
    (string-to-number a)
    (string-to-number b))))

(th-server-start 8021 "0.0.0.0")

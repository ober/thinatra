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


(elnode-start 'th-event-handler :port 8021 :host "localhost")

;;; thinatra.el --- Sinatra clone for Emacs (a poor one at that)

;; Copyright (C) 2013  Jaime Fournier <jaimef@linbsd.org>

;; Author: Jaime Fournier <jaimef@linbsd.org>
;; Keywords: Thinatra
;; Version: 0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; Warning this code is far from useful at the moment and will be some
;; time, and many revisions before I would expect it to be useful to anyone.
;;
;; I love the simplicity of the Ruby based Sinatra framework.
;; With Elnode Emacs finally has the base for something to build on.
;;

;; Many thanks to freenode #emacs and nicferrier for an awesome
;; framework on elisp.
;; Nic also provided initial th-parse-path function

;;; Code:

;; Example Functions that handle calls to rest endpoints
;; e.g.

(defun th-controller-test1 (path)
  (let ((parms (th-parse-path path "/test1/:a/:b/:c/:d")))
    (message (format "We Be in th-controller-test1: and got got %s a:%s b:%s" path (val 'a) (val 'b)))))

(defun th-controller-test2 (path)
  (let ((parms (th-parse-path path "/test2/:a/:b/:c/:d")))
    (message (format "We Be in thd-controller-test2: and got got %s a:%s b:%s" path (val 'a) (val 'b)))))

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
  (sgp-generate  (random 1000000) (random 1000000)))

;; End of Examples

;; Stop previous server;; Remove when done with testing.
(elnode-stop 8028)

(defun th-event-handler (httpcon)
  (elnode-http-start httpcon 200 '("Content-Type" . "text/html"))
  (elnode-http-return
   httpcon
   (th-controller-dispatcher (elnode-http-pathinfo httpcon))))

(defun th-controller-dispatcher (path)
  "Find a function corresponding to controller name and call it with the args"
  (let ((controller (intern (format "th-controller-%s" (th-get-controller-from-path path)))))
    (if
        (fboundp controller)
        (funcall controller path)
      (message (format "<font color=red>No controller found named %s</font>" controller)))))

(defun th-get-controller-from-path (path)
  (th-get-value-by-name path "/:controller/" 'controller))

(defun th-v (i)
  "Small function to help cleanup the templates"
  (cdr (assoc i parms))
  )

(defun th-get-value-by-name (path pattern name)
  "Return the entry if we find it, otherwise nil"
  (cdr (assoc name (th-parse-path path pattern))))

(defun th-parse-path (path pattern)
  (let* ((lst (split-string pattern "/" t))
         (patlst
          (let ((i 1))
            (loop for part in lst
                  if (string-match-p "^:.*" part)
                  collect (cons i (intern (substring part 1)))
                  do (setq i (+ 1 i)))))
         (splt (split-string path "/")))
    (let ((i 0))
      (loop for part in splt
            if (aget patlst i)
            collect (cons (aget patlst i) part)
            do (setq i (+ i 1))))))

(elnode-start 'th-event-handler :port 8028 :host "localhost")

(provide 'thinatra)

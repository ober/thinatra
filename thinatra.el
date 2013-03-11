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
;; Nic also provided initial instantiate-url function

;;; Code:

(elnode-stop 8028)

(defun my-elnode-hello-world-handler (httpcon)
  (elnode-http-start httpcon 200 '("Content-Type" . "text/html"))
  (elnode-http-return
   httpcon
   (controller-dispatcher (elnode-http-pathinfo httpcon))))

(defun controller-dispatcher (path)
  "Find a function corresponding to controller name and call it with the args"
  (let ((controller (intern (format "my-controller-%s" (get-controller-from-path path)))))
    (if
        (fboundp controller)
        (funcall controller path)
      (message (format "<font color=red>No controller found named %s</font>" controller)))))

(defun my-controller-test1 (path)
  (let ((parms (instantiate-url path "/test1/:a/:b/:c/:d")))
    (message (format "We Be in my-controller-test1: and got got %s a:%s b:%s" path (val 'a) (val 'b)))))


(defun my-controller-test2 (path)
  (let ((parms (instantiate-url path "/test2/:a/:b/:c/:d")))
    (message (format "We Be in my-controller-test2: and got got %s a:%s b:%s" path (val 'a) (val 'b)))))


(defun get-controller-from-path (path)
  (get-value-by-name path "/:controller/" 'controller))

(defun val (i)
  (cdr (assoc i parms))
  )

(defun get-value-by-name (path pattern name)
  "Return the entry if we find it, otherwise nil"
  (cdr (assoc name (instantiate-url path pattern))))

(defun instantiate-url (path pattern)
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

(elnode-start 'my-elnode-hello-world-handler :port 8028 :host "localhost")

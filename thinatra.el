;;; thinatra.el --- Sinatra clone for Emacs (a poor one at that)

;;; -*- lexical-binding: t -*-

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

;; Example Functions that handle calls to rest endpoints can be found in examples.el

(require 'elnode)

(defmacro get (pattern &rest forms)
  (declare (indent defun))
  (let ((fun-name (intern (format "th-controller-%s" (th-get-controller-from-path pattern))))
        (parms '(th-parse-path path pattern)))
    `(progn
       (defun ,fun-name (path)
         (let ((parms
                (th-parse-path path (replace-regexp-in-string "*" ":splat" ,pattern)))
               (controller (format "th-controller-%s" (th-get-controller-from-path ,pattern))))
           (loop for (var . val) in parms
                 do
                 (set var ""))
           (loop for (var . val) in parms
                 do
                 (if (boundp 'var)
                     (set var (format "%s %s" (eval var) val))
                   (set var val)))
           (th-interpose-like-ruby
                                   ,@forms))))))

(defun th-interpose-get-vars (str)
  (let ((result nil))
    (with-temp-buffer
      (insert str)
      (goto-char
       (point-min))
      (while (re-search-forward "#{\\([^}]*\\)}" nil t)
        (setq result
              (cons
               (intern (match-string 1))
               result)))
      (reverse result))))

(defun th-interpose-get-format (str)
  (replace-regexp-in-string "#{.[^#]*}" "%s" str))

(defun th-interpose-like-ruby (str)
  "Thinatra ruby like interposition for strings"
  (apply #'format (th-interpose-get-format str) (mapcar #'symbol-value (th-interpose-get-vars str))))

(defun th-event-handler (httpcon)
  "Thinatra event handler"
  (elnode-http-start httpcon 200 '("Content-Type" . "text/html"))
  (elnode-http-return
   httpcon
   (th-controller-dispatcher (elnode-http-pathinfo httpcon))))

(defun th-root-handler (httpcon)
  "Thinatra root handler"
  (elnode-hostpath-dispatcher httpcon
                              '((".*/favicon.ico" . elnode-send-404)
                                (".*" . th-event-handler))))

(defun th-controller-dispatcher (path)
  "Find a function corresponding to controller name and call it with the args"
  (let ((controller (intern (format "th-controller-%s" (th-get-controller-from-path path)))))
    (if
        (fboundp controller)
        (funcall controller path)
      (message (format "<b>Error: No controller found named <font color=red>%s</font></b>"
                       (replace-regexp-in-string "^th-controller-" "" (format "%s" controller)))))))

(defun th-get-controller-from-path (path)
  (th-get-value-by-name path "/:controller/" 'controller))

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
                  do (setq i (1+ i)))))
         (splt (split-string path "/")))
    (let ((i 0))
      (loop for part in splt
            if (aget patlst i)
            collect (cons (aget patlst i) part)
            do (setq i (1+ i))))))

(defun th-server-start (port host)
  "Wrapper for elnode stop/start on a given port"
  (elnode-stop port)
  (elnode-start 'th-root-handler :port port :host host))

(provide 'thinatra)

;; called with
; emacs -Q --eval '(load-file "~/.emacs.d/jsonip.el")'

(setq debug-on-error t)
(setq debug-init t)
(setq debug-on-quit t)
(setq stack-trace-on-error t)

(setq dotfiles-dir (file-name-directory
                    (or (buffer-file-name) load-file-name)))

(setq pahinckage-archives '())
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(add-to-list 'package-archives
'("melpa" . "http://melpa.milkbox.net/packages/") t)

;; missing babel xcscope websocket ein text-translator
(defvar my-packages '(elnode))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))
(add-to-list 'load-path dotfiles-dir)
(setq elnode-error-log-to-messages nil)

(setq thinatra-missing-controller "Elisp is smarter than you")
(load-file "~/thinatra/thinatra.el")

;;
;; (get "/ip"
;;   (message "{\"ip\":\"%s\",\"about\":\"/about\",\"The One True Editor\":\"Emacs\"}"  (first (split-string (elnode-http-header httpcon "X-Forwarded-For") ":" ))))



(get "/ip"
  (message "{\"ip\":\"%s\",\"about\":\"/about\",\"The One True Editor\":\"Emacs\"}"  (first (split-string (request.env "X-Forwarded-For")))))

(get "/about"
  (message "<li><a href=\"https://github.com/nicferrier/elnode\">Elnode</a> on Emacs using <a href=\"http://github.com/ober/thinatra\">Thinatra</a>.<li>Emacs Uptime:%s" (emacs-uptime)))

(get "/usage"
  (message "cons-cells-consed:%s floats-consed:%s vector-cells-consed:%s symbols-consed:%s string-chars-consed:%s misc-objects-consed:%s intervals-consed:%s strings-consed:%s" cons-cells-consed floats-consed vector-cells-consed symbols-consed string-chars-consed misc-objects-consed intervals-consed strings-consed))

(get "/ipwtf"
  (message "%s"  (print (elnode-http-headers httpcon))))

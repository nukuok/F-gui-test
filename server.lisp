(ql:quickload '(:hunchentoot :cl-who :parenscript :smackjack))

(defpackage :sbc-tools
  (:use :cl :hunchentoot :cl-who :parenscript :smackjack))
(in-package sbc-tools)

(defparameter *server*
  (make-instance 'easy-acceptor :address "localhost" :port 4246))

(setq *dispatch-table* (list 'dispatch-easy-handlers
			     (create-ajax-dispatcher *plink-test*)))

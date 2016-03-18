(in-package sbc-tools)

(defparameter *server*
  (make-instance 'easy-acceptor :address "localhost" :port 4247))

(setf (acceptor-document-root *server*) "./")

(setq *dispatch-table* (list 'dispatch-easy-handlers
			     (create-ajax-dispatcher *ajax-processor-plink-conversation*)))

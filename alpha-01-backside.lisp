(in-package 'sbc-tools)

(setf *js-string-delimiter* #\")

(defparameter *plink-test*
  (make-instance 'ajax-processor :server-uri "/plink-conversation-api"))

(defun-ajax plink-phrase (def) (*plink-test* :callback-data :response-text)
  (progn
    (log-message* 2 "~A~%" def)
    (plink-command-input *plink* def)
    (plink-get-output *plink*)))

(define-easy-handler (plink-conversation :uri "/plink-conversation") ()
  (with-html-output-to-string (s)
    (:html
      (:head
        (:title "A plink")
        (str (generate-prologue *plink-test*))
        (:script :type "text/javascript"
          (str
            (ps
              (defun callback (response)
		(progn
		  (setf (chain document plink-form result value) response)
		  (setf (chain document plink-form result scroll-top)
			(chain document plink-form result scroll-height))))
              (defun on-click ()
                (chain smackjack (plink-phrase
				  (chain document
					 (get-element-by-id "data")
					 value)
				  callback)))))))
      (:body
       (:form :name "plinkForm"
	      (:p
	       (:input :id "data" :size 92 :type "text"))
	      (:p
	       (:button :type "button" 
			:onclick (ps-inline (on-click))
			"Submit!"))
	      (:p 
	       (:textarea :rows 30 :cols 83
			  :name "result" :class "txt"
			  (htm (fmt "~a" (plink-get-output *plink*))))))))))


(setq *dispatch-table* (list 'dispatch-easy-handlers
                             (create-ajax-dispatcher *plink-test*)))

(defvar *plink* nil)
(setf *plink* (new-plink-connection '("-pw" "telecom" "telecom@10.22.98.203")))

(defparameter *server*
  (make-instance 'easy-acceptor :address "localhost" :port 4243))



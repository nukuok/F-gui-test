(in-package sbc-tools)

(setf *js-string-delimiter* #\")

(defparameter *plink-test*
  (make-instance 'ajax-processor :server-uri "/plink-conversation-api"))

(defun-ajax plink-phrase (def) (*plink-test* :callback-data :response-text)
  (handler-case
      (progn 
	(plink-command-input *plink* def)
	(plink-get-output *plink*))
    (CCL:NO-APPLICABLE-METHOD-EXISTS () "")))

(define-easy-handler (plink-conversation :uri "/plink-conversation") ()
  (with-html-output-to-string (s)
    (:html
      (:head
        (:title "A plink")
        (str (generate-prologue *plink-test*))
        (:script :type "text/javascript"
          (str
            (ps
	      (defun plink-status-callback (response)
		(setf (chain document
			     (get-element-by-id "status")
			     inner-h-t-m-l)
		      response))
	      (defun plink-status-query ()
		(chain smackjack (plink-status-check
				  plink-status-callback)))
	      (defun alert-abc ()
		(alert "abc"))
	      (defun set-timer ()
		(setf timer-i-d
		      (chain (set-interval
			      plink-status-query 2000))))
	      (plink-status-query)
	      (set-timer)
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
	      (:p :id "status" "init")
	      (:p
	       (:button :type "button" 
			:onclick (ps-inline (plink-status-query))
			"Status!"))
	      (:p
	       (:button :type "button" 
			:onclick (ps-inline (on-click))
			"Submit!"))
	      (:p 
	       (:textarea :rows 30 :cols 83
			  :name "result" :class "txt"
			  (htm (fmt "~a" (plink-phrase ""))))))))))

(setq *dispatch-table* (list 'dispatch-easy-handlers
			     (create-ajax-dispatcher *plink-test*)))

(defparameter *server*
  (make-instance 'easy-acceptor :address "localhost" :port 4245))


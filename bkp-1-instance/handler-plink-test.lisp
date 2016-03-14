(in-package sbc-tools)

(setf *js-string-delimiter* #\")

(define-easy-handler (plink-conversation :uri "/plink-conversation") ()
  (with-html-output-to-string (s)
    (:html
     (:head
      (str (apply
       #'concatenate
       (cons 'string (loop for x in
			  (reverse (handler-html-head *plink-conversation*)) collect x)))))
     (:body
      (str (apply
       #'concatenate
       (cons 'string (loop for x in
			  (reverse (handler-html-body *plink-conversation*)) collect x))))))))

(push-to-handler-html-head
 *plink-conversation*
 (:title "A plink"))

(push-to-handler-html-head
 *plink-conversation*
 (str (generate-prologue *plink-test*)))

(push-to-handler-html-head
 *plink-conversation*
 (:script :type "text/javascript"
 (str (ps
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

(push-to-handler-html-body
 *plink-conversation*
 (:form :name "plinkForm"
	(:p (:input :id "data" :size 92 :type "text"))
	(:p :id "status" "init")
	(:p (:button :type "button" 
		  :onclick (ps-inline (plink-status-query))
		  "Status!"))
	(:p (:button :type "button" 
		  :onclick (ps-inline (on-click))
		  "Submit!"))
	(:p (:textarea :rows 30 :cols 83
		    :name "result" :class "txt"
		    (htm (fmt "~a" (plink-phrase "")))))))

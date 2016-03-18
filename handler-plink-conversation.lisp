(in-package sbc-tools)

;;(scenario-run (scenario-read "scenario/nakahara_2_login.scenario") nil)
;;(scenario-run (scenario-read "scenario/nakahara_2_logout.scenario") nil)

(setf *js-string-delimiter* #\")

(defvar *plink-conversation* nil)
(setf *plink-conversation* (make-instance 'easy-handler-html))

(define-easy-handler (plink-conversation :uri "/plink-conversation") ()
  (with-html-output-to-string (s nil :indent t)
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
 (:title "PERIMETA MODE"))

(push-to-handler-html-head
 *plink-conversation*
 (str (generate-prologue *ajax-processor-plink-conversation*)))

(push-to-handler-html-head
 *plink-conversation*
 (:script :type "text/javascript"
 (str (ps
	(defvar processing #\u)
	(defvar processing-timer)
	(defun locked () (equal processing #\l))
	(defun lock-part ()
	  (progn
	    (setf processing #\l)
	    (setf (chain document (get-element-by-id "processing") inner-h-t-m-l)
		  (processing-string)
		  )))
	(defun lock ()
	  (setf processing-timer
		(chain (set-interval
			lock-part 125))))
	(defun unlock ()
	  (progn
	    (setf processing #\u)
	    (chain (clear-interval processing-timer))
	    (setf (chain document (get-element-by-id "processing") inner-h-t-m-l)
			 "------")))))))

(push-to-handler-html-head
 *plink-conversation*
 (:script :type "text/javascript"
	  (str (ps
		 (defun front-show-scenario-list (response)
		   (setf (chain document
				(get-element-by-id "canditate")
				inner-h-t-m-l)
			 response))
		 (defun front-update-scenario-list ()
		   (chain smackjack (ajax-show-scenario-list
				     front-show-scenario-list)))
		 (front-update-scenario-list)))))

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
	(defvar timer-i-d)
	(defun set-timer ()
	  (progn
	    (chain (clear-interval timer-i-d))
	    (setf timer-i-d
		  (chain (set-interval
			  plink-status-query 2000)))))
	(defun set-iframe (page)
	  ((chain document
		  (get-element-by-id "inst")
		  content-document location replace)
	   page))
	  ))))

(push-to-handler-html-head
 *plink-conversation*
 (:script :type "text/javascript"
 (str (ps
	(defvar processing-anime-number 8)
	(defun processing-anime-number-update ()
	  (if (> processing-anime-number 7)
	      (setf processing-anime-number 1)
	      (incf processing-anime-number)))
;	  (case processing-anime-number
;	    (1 (setf processing-anime-number 2))
;	    (2 (setf processing-anime-number 3))
;	    (3 (setf processing-anime-number 4))
;	    (4 (setf processing-anime-number 1))))
	(defun processing-string ()
	  (progn
	    (case (processing-anime-number-update)
	      (1 "<font color='red'> &larr;-PROCESSING-&rarr; </font>")
	      (2 "<font color='red'> &#8598;-PROCESSING-&#8599; </font>")
	      (3 "<font color='red'> &uarr;-PROCESSING-&uarr; </font>")
	      (4 "<font color='red'> &#8599;-PROCESSING-&#8598; </font>")
	      (5 "<font color='red'> &rarr;-PROCESSING-&larr; </font>")
	      (6 "<font color='red'> &#8600;-PROCESSING-&#8601; </font>")
	      (7 "<font color='red'> &darr;-PROCESSING-&darr; </font>")
	      (8 "<font color='red'> &#8601;-PROCESSING-&#8600; </font>"))))
	))))

(push-to-handler-html-head
 *plink-conversation*
 (:script :type "text/javascript"
 (str (ps
	(defun front-show-scenario (response)
	  (setf (chain document
		       (get-element-by-id "tree")
		       value)
		response))
	(defun front-scenario-chosen (scenarioname)
	  (progn
	    (set-iframe "/instruction/scenario-loaded.html")
	    (setf (chain document
			 (get-element-by-id "scenarioname")
			 value)
		  scenarioname)
	    (chain smackjack (ajax-load-scenario scenarioname
					       front-show-scenario))))))))

(push-to-handler-html-head
 *plink-conversation*
 (:script :type "text/javascript"
 (str (ps
	(defun front-run-scenario (response)
	  (progn 
	    (unlock)
	    (set-timer)
	    (setf (chain document
			 (get-element-by-id "result")
			 value) response)
	    (setf (chain document
			 (get-element-by-id "commandarea")
			 value) "config")
	    (setf (chain document (get-element-by-id "result") scroll-top)
		  (chain document (get-element-by-id "result") scroll-height))))
	(defun front-run-scenario-clicked ()
	  (progn
	    (when (not (locked))
	      (lock)
	      (set-iframe "/instruction/start-submit.html")
	      (chain smackjack (ajax-run-scenario
			    (chain document
				   (get-element-by-id "tree")
				   value)
			    front-run-scenario)))))))))

(push-to-handler-html-head
 *plink-conversation*
 (:script :type "text/javascript"
 (str (ps
	(defun callback (response)
	  (progn
	    (unlock)
	    (setf (chain document
			 (get-element-by-id "result")
			 value) response)
	    (setf (chain document (get-element-by-id "result") scroll-top)
		  (chain document (get-element-by-id "result") scroll-height))))
	(defun on-click ()
	  (when (not (locked))
	    (lock)
	    (chain smackjack (plink-phrase
			    (chain document
				   (get-element-by-id "commandarea")
				   value)
			    callback))))))))

(defvar *area1* nil)
(setf *area1*
      (with-html-output-to-string (s nil :indent 1)
	(:table
	 (:tr
	  (:td :width "100")
	  (:td :width "100")
	  (:td :width "100")
	  (:td :width "100")
	  (:td :width "100")
	  (:td :width "100")
	  )
	 (:tr
	  (:td :colspan 2 (:p :style "border: 1px solid black;text-align: center;"
		   :id "processing" "------"))
	  (:td :colspan 2 :width "100"
	       (:button :style "width: 200px" :type "button"
			:onlick (ps-inline (front-update-scenario-list)) "List Scenario"))
	  (:td :colspan 2 (:button :style "width: 200px"
				   :type "button" "PERIMETA mode ON"))
	  )
	 (:tr
	  (:td :colspan 2  
	       (:p :style "border: 1px solid black;text-align: center;"
		   :id "status" "------"))
	  (:td :colspan 2 (:button :style "width: 200px"
				   :onclick (ps-inline (plink-status-query))
				   :type "button" "Status Update"))
	  (:td :colspan 2 (:button :style "width: 200px"
				   :type "button" "MANUAL auto switching ON"))
	  )
	 (:tr
	  (:td :colspan 6 (:p (:textarea :rows 16 :cols 75 :id "result" :class "txt" ))))
	 (:tr
	  (:td :colspan 5 (:input :id "commandarea" :size 81 :type "text"))
	  (:td (:button :style "width: 95px"
			:onclick (ps-inline (on-click))
			:type "button" "Submit")))
	 (:tr
	  (:td :colspan 2 :width "100" (:input :id "scenarioname" :size 28 :type "text"))
	  (:td :colspan 2 :width "100" (:button :style "width: 200px":type "button" "Save"))
	  (:td :colspan 2 :width "100" (:button :style "width: 200px"
				     :onclick (ps-inline (front-run-scenario-clicked))
				     :type "button" "Run"))
	  ))))

(push-to-handler-html-body
 *plink-conversation*
 (:table
  (:tr
   (:td (str *area1*))
   (:td (:iframe :id "inst" :width 625 :height 340 :src "/instruction/start.html")))
  (:tr
   (:td (:textarea :rows 12 :cols 76
		   :id "tree" :class "txt"))
   (:td :width "100" :height "100" :style "border: 1px solid black;" :valign "top"
	:id "canditate"))))

;;   (:td (:textarea :rows 12 :cols 76
;;		   :id "canditate" :class "txt")))))

	  

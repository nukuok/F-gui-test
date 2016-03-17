;;;; push and extend 1 ;failure
(defmethod push-to-handler-html-head ((handler easy-handler-html) sentence)
  (push sentence (handler-html-head handler)))
(defmethod push-to-handler-html-body ((handler easy-handler-html) sentence)
  (push sentence (handler-html-body handler)))

(defmethod extend-handler-html-head ((handler easy-handler-html))
  `(:head ,@(loop for x in (reverse (handler-html-head handler)) collect x)))
(defmethod extend-handler-html-body ((handler easy-handler-html))
  `(:body ,@(loop for x in (reverse (handler-html-body handler)) collect x)))

(defmacro handler-html-seperate (handler)
	 `(with-html-output-to-string (s)
	      (:html
	       ,(extend-handler-html-head handler)
	       ,(extend-handler-html-body handler))))


;;;; pool-definition-for-easy-handler ;;useless
(macrolet
    ((i-c (&rest sentence)
       `(intern (concatenate 'string ,@sentence))))
  (defmacro define-html-handler-separate (name)
    (let* ((handler-name (symbol-name name))
	(handler-head-pool (i-c "*" handler-name "-head*"))
	(handler-body-pool (i-c "*" handler-name "-body*"))
	(handler-push-head-function (i-c handler-name "-head-add"))
	(handler-push-body-function (i-c handler-name "-body-add"))
	(handler-extend-head-function (i-c handler-name "-head-extend"))
	(handler-extend-body-function (i-c handler-name "-body-extend")))
      `(defvar ,handler-head-pool nil)
      `(defvar ,handler-body-pool nil) 
      `(defun  ,handler-push-head-function (sentence)
	 (push sentence  ,handler-head-pool))
      `(defun  ,handler-push-body-function (sentence)
	 (push sentence  ,handler-body-pool)) 
      `(defmacro ,handler-extend-head-function ()
	 (loop for x in ,handler-head-pool collect
	    x))
      `(defmacro ,handler-extend-body-function ()
	 (loop for x in ,handler-body-pool collect
	    x)))))


(defun commandp (mame)
  (let ((mame-length (length mame))
	(command-head-length (length *command-head*)))
    (when (string-equal-on-base mame *command-head*)
      (string-trim *command-end*
		   (subseq mame command-head-length)))))

(defun scenario-run (result plink)
  (loop for x in result do
       (when x
	 (let ((command (car x)))
	   (cond ((equal command "PLINK-COMMAND")
		  (setf plink (new-plink-connection (cdr (string-to-list (cadr x))))))
		 ((equal command "WAIT-OUTPUT")
		  (let ((output (plink-get-output plink)))
		    (unless (string-equal-last (string-trim " " output) (cadr x))
		      (return :with-wrong-wait-target))))
		 ((equal command "INPUT-COMMAND")
		  (loop for y in (cdr x) do
		       (plink-command-input plink y)))))))
  plink)

 (:form :name "plinkForm"
	(:p (:input :id "data" :size 92 :type "text"))
	(:p :id "processing" "--")
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

;(setf abc "<head></head>")
;(eval `(with-html-output-to-string (s) (:html ,abc)))

;;(defmacro extend-handler-html-head (handler)
;;  `(:head ,@(loop for x in (reverse (handler-html-head handler)) collect x)))

;;(defmacro extend-handler-html-body (handler)
;;  `(:body ,@(loop for x in (reverse (handler-html-body handler)) collect x)))

;;(defmacro test (mame) `(with-html-output-to-string (s) ,mame))

(defmacro make-scenario-list-links ()
  `(with-html-output-to-string (s nil :indent t)
     ,@(loop for x in (list-scenario) append
	   (list
	    `(:strong (:font :color "blue" :onclick
		    (ps-inline 
		     (alert ,(princ-to-string x)))
		    "&lt;" ,(filename-from-directory x) "&gt;"))
	    `(:br)))))

;;(format t "~A" (make-scenario-list-links))

(defmacro scenario-run (result plink stream)
  `(loop for x in ,result do
       (when x
	 (let ((command (car x)))
	   (cond ((equal command "PLINK-COMMAND")
		  (format ,stream "~A" (cadr x))
		  (setf ,plink (new-plink-connection (cdr (string-to-list (cadr x))))))
		 ((equal command "WAIT-OUTPUT")
		  (let ((output (plink-get-output ,plink)))
		  (format ,stream "~A" output)
		    (unless (string-equal-last (string-trim " " output) (cadr x))
		      (return :with-wrong-wait-target))))
		 ((equal command "INPUT-COMMAND")
		  (loop for y in (cdr x) do
		       (format ,stream "~A" y)
		       (plink-command-input ,plink y)))))))
  plink)

(ql:quickload '(:hunchentoot :cl-who :parenscript :smackjack))

(defpackage :sbc-tools
  (:use :cl :hunchentoot :cl-who :parenscript :smackjack))

(in-package sbc-tools)

;;(defun color-html-string (string color)
;;  (with-html-output-to-string (a) (:font :color color (fmt "~a" string))))

;;;; make html string
(defun html-string (string &optional color)
  (cond
    (color (with-html-output-to-string (a) (:font :color color (fmt "~a" string))))
    (t (with-html-output-to-string (a) (fmt "~a" string)))))

;;;; plink
(defun read-from-stream-wait (stream listen-ng-times result)
  (cond ((< listen-ng-times 0) (coerce result 'string))
	((listen stream)
	 (read-from-stream-wait stream listen-ng-times
				(append result (list (read-char stream)))))
	(t (sleep 0.1)
	   (read-from-stream-wait stream (- listen-ng-times 1) result))))

;(defun read-from-stream-wait (stream listen-ng-times result)
;  (get-output-stream-string stream))

(defclass plink ()
  ((process :accessor plink-process :initarg :pp)
   (instream :accessor plink-in :initarg :pi)
   (outstream :accessor plink-out :initarg :po)))

(defmethod new-plink-connection ((command list))
  (let ((mame-process
	 (ccl:run-program "plink" command :input :stream :output :stream :wait nil :sharing :lock)))
    (make-instance 'plink
		   :pp mame-process
		   :pi (ccl:external-process-input-stream mame-process)
		   :po (ccl:external-process-output-stream mame-process))))

(defmethod plink-status ((instance plink))
  (ccl:external-process-status (plink-process instance)))

;;(defethod plink-exit ())
(defmethod plink-get-output ((instance plink))
   (read-from-stream-wait (plink-out instance) 10 nil))

(defmethod plink-command-input ((instance plink) (command string))
  (progn (format (plink-in instance) "~A~%" command)
	 (finish-output (plink-in instance))))

(defun f-plink-status-output (may-be-a-plink)
  (handler-case
      (let ((status (plink-status may-be-a-plink)))
	(log-message* 4 "plink-status: ~A~%" status)
	(case status
	  (:running (html-string status "green"))
	  (:exited (html-string status "red"))
	  (otherse (html-string "~a" status))))
    (CCL:NO-APPLICABLE-METHOD-EXISTS ()
      (html-string "Not connected" "grey"))))

;;;; easy-handler-html-class

(defclass easy-handler-html ()
  ((head :accessor handler-html-head :initform nil)
   (body :accessor handler-html-body :initform nil)))

;;;; push and extend 2 
(defmacro push-to-handler-html-head (handler sentence)
  `(push (with-html-output-to-string (s nil :indent t) ,sentence)
	(handler-html-head ,handler)))
(defmacro push-to-handler-html-body (handler sentence)
  `(push (with-html-output-to-string (s nil :indent t) ,sentence)
	(handler-html-body ,handler)))


(defun list-scenario ()
  (directory "scenario/*"))

(defun string-null (mame)
  (equal mame ""))

(defun string-split (string char &optional result)
  (let ((char-position (position char string)))
    (cond ((string-null string) (reverse result))
	  (char-position (string-split (subseq string (+ 1 char-position))
		      char (cons (subseq string 0 char-position) result)))
	  (t (string-split "" char (cons string result))))))

(defun last-1 (mame)
  (car (last mame)))

(defun filename-from-directory (mame)
  (last-1 (string-split (princ-to-string mame) #\/)))

(defmacro make-scenario-list-links ()
  `(with-html-output-to-string (s nil :indent t)
     ,@(loop for x in (list-scenario) append
	    (list
	    `(:strong (:u (:font :color "blue" :style "cursor:pointer;" :onclick
		 (ps-inline 
		  (front-scenario-chosen ,(filename-from-directory x)))
		 "&#x21D2; " ,(filename-from-directory x) )))
	    `(:br)))))

(defun file-string (path)
  (with-open-file (stream path)
    (let ((data (make-string (file-length stream))))
      (read-sequence data stream)
      data)))

(defun stream-string (stream)
  (let ((result (make-sequence 'string (length stream))))
    (read-sequence result stream)
    result))

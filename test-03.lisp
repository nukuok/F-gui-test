(ql:quickload '(:hunchentoot :cl-who :parenscript :smackjack))

(defpackage :sbc-tools
  (:use :cl :hunchentoot :cl-who :parenscript :smackjack))
(in-package 'sbc-tools)


(defun read-from-stream-wait (stream listen-ng-times result)
  (cond ((< listen-ng-times 0) (coerce result 'string))
	((listen stream)
	 (read-from-stream-wait stream listen-ng-times
				(append result (list (read-char stream)))))
	(t (sleep 0.1)
	   (read-from-stream-wait stream (- listen-ng-times 1) result))))

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
(defvar *plink* nil)
(setf *plink* (new-plink-connection '("-pw" "telecom" "telecom@10.22.98.203")))


(defmethod plink-get-output ((instance plink))
    (read-from-stream-wait (plink-out instance) 10 nil))

(defmethod plink-command-input ((instance plink) (command string))
  (progn (format (plink-in instance) "~A~%" command)
	 (finish-output (plink-in instance))))

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

(defparameter *server*
  (make-instance 'easy-acceptor :address "localhost" :port 4244))

(setq *dispatch-table* (list 'dispatch-easy-handlers
                             (create-ajax-dispatcher *plink-test*)))



;;;; defun in defun => defun out
(defun temp (x)
  (progn 
    (defun a (x) (+ x 1))
    (defun b (x) (* x 4))
    (+ (a x) (b x))))

(defvar *pool-for-temp* nil)
(setf *pool-for-temp* nil)

(defmacro defun-in (name lambda-list &rest body)
  `(push (list ',name ',lambda-list ',body) *pool-for-temp*))

(defmacro temp (x)
  (progn
    (loop for tt in *pool-for-temp* do
	 `(defun ,(car tt) ,(cadr tt) ,(caddr tt)))
    (+ (a x) (b x))))
	 
(defmacro temp (name p1 p2)
  `(',name ,p1 ,p2))

(defmacro temp2 (name p1 p2)
  `(,name ,p1 ,p2))

(defvar *temp3-pool* niL)
(defmacro temp3 (a b c)
  `(push (list ',a ',b ',c) *temp3-pool*))

;;;; about macro
(setf tt1 'tt2)
(setf tt2 1)

(symbol-value tt1)
;; 1
(defmacro test () tt1)
(test)
;; 1
(defun test2 () tt1)
;; tt2
(eval tt1)
;; 1
(eval tt2)
;; 1

;;;; about macro for html
(defmacro test () ''(:html (:head "1")))
(defmacro test2 () 
  `(with-html-output-to-string (s) ,(test)))



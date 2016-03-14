(in-package sbc-tools)

(defparameter *plink-test*
  (make-instance 'ajax-processor :server-uri "/plink-conversation-api"))

(defvar *plink* nil)
(setf *plink* (new-plink-connection '("-pw" "telecom" "telecom@10.22.98.203")))

(defvar *plink-conversation* nil)
(setf *plink-conversation* (make-instance 'easy-handler-html))

(defun-ajax plink-phrase (def) (*plink-test* :callback-data :response-text)
  (handler-case
      (progn 
	(plink-command-input *plink* def)
	(plink-get-output *plink*))
    (CCL:NO-APPLICABLE-METHOD-EXISTS () "")))

(defun-ajax plink-status-check () (*plink-test* :callback-data :response-text)
  (progn
    (log-message* 3 "~A~%")
    (f-plink-status-output *plink*)))




(in-package sbc-tools)

(defparameter *ajax-processor-plink-conversation*
  (make-instance 'ajax-processor :server-uri "/plink-conversation-api"))

(defvar *plink* (make-instance 'plink))
;(setf *plink* (new-plink-connection '("-pw" "telecom" "telecom@10.22.98.203")))


(defun-ajax plink-phrase (def) (*ajax-processor-plink-conversation*
				:callback-data :response-text)
  (handler-case
      (progn 
	(plink-command-input *plink* def)
	(remove #\return (plink-get-output *plink*)))
    (CCL:NO-APPLICABLE-METHOD-EXISTS () "")
    (CCL::SIMPLE-STREAM-ERROR () "")))

(defun-ajax ajax-show-scenario-list () (*ajax-processor-plink-conversation*
				    :callback-data :response-text)
  (make-scenario-list-links))

(defun-ajax plink-status-check () (*ajax-processor-plink-conversation*
				   :callback-data :response-text)
  (progn
    (log-message* 3 "~A~%" "status")
    (f-plink-status-output *plink*)))

(defun-ajax ajax-load-scenario (path) (*ajax-processor-plink-conversation*
				       :callback-data :response-text)
  (remove #\return (file-string
		    (concatenate 'string "scenario/" path))))

(defun-ajax ajax-run-scenario (scenario) (*ajax-processor-plink-conversation*
					  :callback-data :response-text)
  (log-message* 3 "~A" scenario)
  (scenario-run-from-string-to-string scenario))

(defun-ajax ajax-perimeta-mode-command-input (command) (*ajax-processor-plink-conversation*
							:callback-data :response-text)
  (log-message* 3 "~A" command)
  (pm-command-input command)
  (pm-command-output))

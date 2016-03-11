(in-package sbc-tools)

(defvar *plink* nil)
(setf *plink* (new-plink-connection '("-pw" "telecom" "telecom@10.22.98.203")))

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

(defun-ajax plink-status-check () (*plink-test* :callback-data :response-text)
  (progn
    (log-message* 3 "~A~%")
    (f-plink-status-output *plink*)))



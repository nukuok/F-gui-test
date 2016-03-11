(defmacro macro-test (name) ;; heyhey
  `(defun ,name (arg)
     (cond
       ,@(loop
	   for con in '(4 7 9)  
	   for x in '(1 2 3) collect
	     `(,con (print ,x))))))

(defmethod plink-connection-inputstream ((plink-connection external-process))
  (let ((instream nil))
    (unless instream
      (setf instream (external-process-input-stream plink-connection))
      (debug "input-stream-made"))
    instream))

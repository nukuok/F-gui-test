(defmacro new-plink-connection (name
				&optional (command '("-pw" "telecom" "telecom@1.22.98.203")))
  (let ((connection (run-program "plink" command :input :stream :output :stream :wait nil)))
    `(defun ,name (tag)
       (cond 
	 `(loop for x in *plink-connection-method* collect
	       `((equal ,,tag ,(car x)) (funcall ,(cadr x) ,,,connection)))))))

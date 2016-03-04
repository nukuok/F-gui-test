(defvar *debug-switch*)
(setf *debug-switch* t)
  
(defmacro debug (message &rest parameters)
  `(when *debug-switch*
     (format t "~%~A~%" ,message)
     (loop for x in (list ,@parameters) do
	  (print x))))


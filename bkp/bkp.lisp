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

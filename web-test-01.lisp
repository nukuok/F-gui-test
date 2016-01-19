(in-package :cl-user)
(ql:quickload :cl-who)
(ql:quickload :parenscript)
(ql:quickload :cffi)
(pushnew "." cffi:*FOREIGN-LIBRARY-DIRECTORIES*)
(ql:quickload :hunchentoot)
(defvar parenscript::suppress-values? nil)


(defpackage :gui-for-perimeta
  (:use :cl :cl-who :hunchentoot :parenscript))
(in-package :gui-for-perimeta)

(defvar *acceptor* nil "the hunchentoot acceptor")

(defun start-server (&optional (port 8080))
  (setf *acceptor* (make-instance 'easy-acceptor :port port))  
  (setf (acceptor-document-root *acceptor*)
	"c:/Users/Administrator/Desktop/program/gui-test/www/")
  (start *acceptor*))

(defmacro define-url-fn ((name) &body body)
  `(progn
     (defun ,name ()
       ,@body)
     (push (create-prefix-dispatcher ,(format nil "/~(~a~).htm" name) ',name)
	   *dispatch-table*)))

(defmacro standard-page ((&key title) &body body)
  `(with-html-output-to-string (*standard-output* nil :prologue t :indent t)
     (:html :xmlns "http://www.w3.org/1999/xhtml"  :xml\:lang "en" :lang "en"
	    (:head 
	     (:meta :http-equiv "Content-Type" :content "text/html;charset=utf-8")
	     (:title ,title))
	     ;;(:link :type "text/css" :rel "stylesheet" :href "/retro.css"))
	    (:body 
	     ,@body))))

(define-url-fn (new-game)
  (standard-page (:title "Command and result")
    (:h1 "Add a new game to the chart ~")
    (:form :action "/game-added.htm" :method "post" 
	   :onsubmit (ps-inline
		      (when (= newname.value "")
			(alert "Please enter a name.")
			(return false)))
	   (:p "What is the name of the game?" (:br)
	       (:input :type "text" :name "newname" :class "txt"))
	   (:p (:input :type "submit" :value "Add" :class "btn")))))



(in-package :cl-user)
(ql:quickload :cl-who)
(ql:quickload :parenscript)
(ql:quickload :cffi)
(pushnew "." cffi:*FOREIGN-LIBRARY-DIRECTORIES*)
(ql:quickload :hunchentoot)

(defpackage :retro-games
  (:use :cl :cl-who :hunchentoot :parenscript))
(in-package :retro-games)

(defvar *games* '())

(defvar parenscript::suppress-values? nil)

(defvar *acceptor* nil "the hunchentoot acceptor")

(defun start-server (&optional (port 8080))
  (setf *acceptor* (make-instance 'easy-acceptor :port port))  
  (setf (acceptor-document-root *acceptor*)
	"c:/Users/Administrator/Desktop/program/gui-test/www/")
  (start *acceptor*))
;;(start-server)

(defclass game ()
  ((name :reader name :initarg :name)
   (votes :accessor votes :initarg :votes :initform 0)))

;;(push (create-static-file-dispatcher-and-handler "/logo.jpg" "imgs/Commodore64.jpg") *dispatch-table*)
;;(push (create-static-file-dispatcher-and-handler "/retro.css" "css/retro.css") *dispatch-table*)

(defmethod vote-for (user-selected-game)
  (incf (votes user-selected-game)))

(defun game-from-name (name)
  (find name *games* :test #'string-equal 
	:key  #'name))

(defun game-stored? (game-name)
  (game-from-name game-name))

(defun add-game (name)
  (unless (game-stored? name)
    (push (make-instance 'game :name name) *games*)))

(defun games ()
  (sort (copy-list *games*) #'> :key #'votes))

(defmacro define-url-fn ((name) &body body)
  `(progn
     (defun ,name ()
       ,@body)
     (push (create-prefix-dispatcher ,(format nil "/~(~a~).htm" name) ',name) *dispatch-table*)))

(defmacro standard-page ((&key title) &body body)
  `(with-html-output-to-string (*standard-output* nil :prologue t :indent t)
     (:html :xmlns "http://www.w3.org/1999/xhtml"  :xml\:lang "en" :lang "en"
	    (:head 
	     (:meta :http-equiv "Content-Type" :content "text/html;charset=utf-8")
	     (:title ,title)
	     (:link :type "text/css" :rel "stylesheet" :href "/retro.css"))
	    (:body 
	     (:div :id "header"
		   (:img :src "/logo.jpg" :alt "Commodore 64" :class "logo")
		   (:span :class "strapline" "Vote on your favourite Retro Game"))
	     ,@body))))

(define-url-fn (retro-games)
  (standard-page (:title "Top Retro Games")
    (:h1 "Vote on your all time favourite retro games!")
    (:p "Missing a game? Make it available for votes "
	(:a :href "new-game.htm" "here"))
    (:h2 "Current stand")
    (:div :id "chart"
	  (:ol
	   (dolist (game (games))
	     (htm  
	      (:li (:a :href (format nil "vote.htm?vname=~a" (name game)) "Vote!")
		   (fmt "~A with ~d votes" (name game) (votes game)))))))))

(define-url-fn (new-game)
  (standard-page (:title "Add a new game")
    (:h1 "Add a new game to the chart ~")
    (:form :action "/game-added.htm" :method "post" 
	   :onsubmit (ps-inline
		      (when (= newname.value "")
			(alert "Please enter a name.")
			(return false)))
	   (:p "What is the name of the game?" (:br)
	       (:input :type "text" :name "newname" :class "txt"))
	   (:p (:input :type "submit" :value "Add" :class "btn")))))

(define-url-fn (game-added)
  (let ((name (parameter "newname")))
    (unless (or (null name) (zerop (length name)))
      (add-game name))
    (redirect "/retro-games.htm"))) 

(define-url-fn (vote)
  (let ((game (game-from-name (parameter "vname"))))
    (if game
	(vote-for game))
    (redirect "/retro-games.htm"))) 


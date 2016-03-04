;;(run-program "ssh" '("-pw" "telecom" "telecom@10.22.98.203") :output :stream :input :stream :wait nil)

(defvar *t*)
(defvar *in*)
(defvar *out*)

(setf *t* *)
(setf *in* (external-process-input-stream *t*))
(setf *out* (external-process-output-stream *t*))
(read-line *out*)
(format *in* "ls -l~%")

(finish-output *in*)
(read-line *out*)



(with-open-stream
    (stream 
     (run-program "plink"
		  (list (format nil "~A@~A" "telecom" "10.22.98.203")
			"bash"
			"-c"
			(format nil "\"cat > ~S\"" "test"))
		  :input :stream :output :stream))
  (princ "Hello world!" stream)
  (format t "~A~%" (read-line stream))
  (terpri stream)
  (finish-output stream))


(run-program "ssh"
	     (list (format nil "~A@~A" "pjb" "localhost")
		   "bash"
		   "-c"
		   (format nil "\"cat > ~S\"" "test"))
	     :input :stream :output :stream)

(run-program "plink"
	     (list (format nil "~A@~A" "pjb" "localhost")
		   "bash"
		   "-c"
		   (format nil "\"cat > ~S\"" "test"))
	     :input :stream :output :stream)

(setf test-stream (run-program "plink" (list "-pw" "telecom" "telecom@10.22.98.203") :input :stream :output *standard-output* :wait nil))


(load "examples.lisp")
(load "libssh2-libc-cffi.lisp")
(load "solutions.lisp")
(load "types.lisp")
(load "libssh2-cffi.lisp")
(load "package.lisp")
(load "streams.lisp")
(load "util.lisp")

(asdf:load-system :cffi-grovel)

;;;;
(setf test-stream (run-program "plink" (list "-pw" "telecom" "telecom@10.22.98.203") :input :stream :output :stream :wait nil))
(setf *in* (external-process-input-stream test-stream))
(setf *out* (external-process-output-stream test-stream))
(format *in* "ls~%")
(format *in* "pwd~%")
(finish-output *in*)

(let
    ((in (external-process-input-stream test-stream))
     (out (external-process-output-stream test-stream)))
  (loop for line = (read-line out nil nil)
     while line
     do (format t "~A~%" line)))




;;;;
(defvar *in*)
(defvar *out*)

(let* ((test-stream (run-program "plink" (list "-pw" "telecom" "telecom@10.22.98.203")
				 :input :stream :output :stream :wait nil))
       (in (external-process-input-stream test-stream))
       (out (external-process-output-stream test-stream)))
  (defvar line-text)
  (defvar is-last-line)
  (loop
     (multiple-value-bind (line-text is-last-line) (read-line out)
       (format t "~A~%" line-text)
       (when is-last-line
	 (print 12345)
	 (let ((command-line (read-line)))
	   (format in command-line)
	   (finish-output *in*))))))


http://stackoverflow.com/questions/15988870/how-to-interact-with-a-process-input-output-in-sbcl-common-lisp



;;;;
(defvar line-text)
(defvar is-last-line)
(multiple-value-bind (line-text is-last-line) (read-line *out*)
  (format t "~A~%" line-text)
  (when is-last-line
    (print 12345)
    (let ((command-line (read-line)))
      (format *in* command-line)
      (finish-output *in*))))

;;;;
(let* ((test-stream (run-program "plink" (list "-pw" "telecom" "telecom@10.22.98.203")
				 :input :stream :output :stream :wait nil))
       (in (external-process-input-stream test-stream))
       (out (external-process-output-stream test-stream)))
  (defvar line-text)
  (defvar is-last-line)
  (loop
     (multiple-value-bind (line-text is-last-line) (read-line out)
       (format t "~A~%" line-text)
       (when is-last-line
	 (print 12345)
	 (let ((command-line (read-line)))
	   (format in command-line)
	   (finish-output in))))))



;;;;
(setf *temp* (make-string-input-stream "abc
def
ghi"))

(print (read-line *temp*))
(print (read-line *temp*))
(print (read-line *temp*))

;;;;

(setf test-stream (run-program "plink" (list "-pw" "telecom" "telecom@10.22.98.203") :input :stream :output :stream :wait nil))
(setf *in* (external-process-input-stream test-stream))
(setf *out* (external-process-output-stream test-stream))
(format *in* "ls~%")
(format *in* "pwd~%")
(finish-output *in*)

(read-line *out*)
(let
    ((in (external-process-input-stream test-stream)))
  (loop
       (let ((command-line (read-line)))
	 (when (equal command-line "exit") (return))
	 (format in command-line)
	 (finish-output in))))

;;;; X
(with-open-stream 
    (test-stream nil)
  (run-program "plink" (list "-pw" "telecom" "telecom@10.22.98.203")
	       :input :stream :pty t :wait nil)
  (format t (read-line test-stream)))

;;;; freeze

(let*
    ((proc
      (run-program "plink" (list "-pw" "telecom" "telecom@10.22.98.203")
		   :input :stream :output :stream :wait nil))
     (in (external-process-input-stream proc))
     (out (external-process-output-stream proc))
     (tempchar))
  (loop for tempchar = (stream-read-char-no-hang out)
     while tempchar 
     do (format t "~A" tempchar))
  (format in "exit~%")
  (finish-output in))

;;;; well done with read-line 

(let*
    ((proc
      (run-program "plink" (list "-pw" "telecom" "telecom@10.22.98.203")
		   :input :stream :output :stream :wait nil))
     (in (external-process-input-stream proc))
     (out (external-process-output-stream proc))
     tempchar)
  (print (read-line out))
  (print (stream-read-char-no-hang out))
  (format t "~A" tempchar)
  (dotimes (x 3000) 
    (setf tempchar (stream-read-char-no-hang out))
    (format t "~A" tempchar))
  (format in "exit~%")
  (finish-output in))

;;;; well done with (sleep 1)

(let*
    ((proc
      (run-program "plink" (list "-pw" "telecom" "telecom@10.22.98.203")
		   :input :stream :output :stream :wait nil))
     (in (external-process-input-stream proc))
     (out (external-process-output-stream proc))
     tempchar)
  ;;(sleep 1)
  (format t "~A" (stream-read-char out))
  (dotimes (x 3000) 
    (setf tempchar (stream-read-char-no-hang out))
    (format t "~A" tempchar))
  (format in "exit~%")
  (finish-output in))

;;;; well done with readchar at first

(defun test ()
  (let*
      ((proc
	(run-program "plink" (list "-pw" "telecom" "telecom@10.22.98.203")
		     :input :stream :output :stream :wait nil))
       (in (external-process-input-stream proc))
       (out (external-process-output-stream proc))
       tempchar)
    (format t "~A" (stream-read-char out))
    (loop
       (setf tempchar (stream-read-char-no-hang out))
       (unless tempchar (return))
       (format t "~A" tempchar))
    (loop 
       (let ((command (read-line)))
	 (when (equal command "program-exit") (return))
	 (format t "~A~%" command)
	 (format in "~A~%" command)
	 (finish-output in))
       (format t "~A" (stream-read-char out))
       (loop
	  (setf tempchar (stream-read-char-no-hang out))
	  (unless tempchar (return))
	  (format t "~A" tempchar)))
    (format in "exit~%")
    (finish-output in)))


(ccl:save-application "mame.exe"
		  :toplevel-function ;'test
		  :prepend-kernel t)


;;;; read-char test
(defun test2 ()
  (loop
       (let ((temp (read-char)))
	 (if (equal temp ;\z)
	     (return)
	     (print temp)))))

(ccl:save-application "mame.exe"
		  :toplevel-function ;'test2
		  :prepend-kernel t)

(progn (unread-char (read-char)) (list (listen) (read-char)))


(with-input-from-string
    (tempstream "abcdefg")
  (let ((count 0))
    (loop
       (if (listen tempstream)
	   (progn
	     (format t "~A" (read-char tempstream))
	     (setf count 0))
	   (progn
	     (sleep 0.01)
	     (setf count (+ count 1))
	     (when (> count 20)
	       (print count)
	       (print "ok")
	       (return)))))))

(print 20)


;;;; use listen
(defun read-from-stream-wait (stream listen-ng-times result)
  (print listen-ng-times)
  (if (< listen-ng-times 0)
    (coerce result 'string)
    (if (listen stream)
	(read-from-stream-wait stream listen-ng-times
			       (append result (list (read-char stream))))
	(read-from-stream-wait stream (- listen-ng-times 1) result))))


;;;; use listen 2 šš
(defun read-from-stream-wait (stream listen-ng-times result)
  (cond ((< listen-ng-times 0) (coerce result 'string))
	((listen stream)
	 (read-from-stream-wait stream listen-ng-times
				(append result (list (read-char stream)))))
	(t (sleep 0.1)
	   (read-from-stream-wait stream (- listen-ng-times 1) result))))

(defun test (args)
  (let*
      ((proc
	(run-program (car args) (cdr args)
		     :input :stream :output :stream :wait nil))
       (in (external-process-input-stream proc))
       (out (external-process-output-stream proc)))
    (format t "~A" (read-from-stream-wait out 10 nil))
    (loop 
       (let ((command (read-line)))
	 (when (equal command "program-exit") (return))
	 (format in "~A~%" command)
	 (finish-output in))
       (format t "~A" (read-from-stream-wait out 10 nil)))
    (format in "exit~%")
    (finish-output in)))

(test (list "plink" "-pw" "telecom" "telecom@192.168.39.105"))
(test (list "plink" "-pw" "telecom" "telecom@10.22.98.203"))

(defun external-process-exited (external-process)
  (equal :exited (external-process-status external-process)))




;;;; use class not so good
(defclass plink ()
  ((process :accessor plink-process)
   (instream :accessor plink-in)
   (outstream :accessor plink-out)))

(defmethod plink-new ((plink-instance plink) (plink-command list))
  (cond ((or (not (slot-boundp plink-instance 'process))
	     (null (plink-process plink-instance))
	     (external-process-exited (plink-process plink-instance)))
	 (let ((mame (run-program "plink" plink-command
				  :input :stream :output :stream :wait nil)))
	   (setf (plink-process plink-instance)
		 mame
		 (plink-in plink-instance)
		 (external-process-input-stream mame)
		 (plink-out plink-instance)
		 (external-process-output-stream mame))
	   plink-instance))
	(t (format t "Already exists."))))
   

;;;(let ((mame  (plink-new (make-instance 'plink) '("-pw" "telecom" "telecom@10.22.98.203")))) (print (read-from-stream-wait (plink-out mame) 10 nil)) (format (plink-in mame) "exit~%") (finish-output (plink-in mame)) (sleep 0.03) (external-process-status (plink-process mame))) ;; 0.03 for exiting


;;;; heyhey
(defvar *plink-connection-method* nil)
(setf *plink-connection-method* nil)

(push (list :input #'plink-connection-inputstream) *plink-connection-method*)
(push (list :output #'external-process-output-stream) *plink-connection-method*)
(push (list :status #'external-process-status) *plink-connection-method*)

(defmacro get-plink-connection ()
	 connection)

(defmethod plink-connection-inputstream ((plink-connection external-process))
  (let ((mame (get plink-connection
  (unless instream
      (setf instream (external-process-input-stream plink-connection))
      (debug "input-stream-made"))
    instream))

;; funcall evaluated when run (name ...)
(defmacro new-plink-connection (name
				&optional (command '("-pw" "telecom" "telecom@10.22.98.203")))
  (let ((connection (run-program "plink" command :input :stream :output :stream :wait nil)))
    `(defun ,name (tag)
       (cond 
	 ((equal tag :process) ,connection)
	 ,@(loop for x in *plink-connection-method* collect
		`((equal tag ,(car x)) (funcall ,(cadr x) ,connection)))))))

;; funcall evaluated once 
(defmacro new-plink-connection (name
				&optional (command '("-pw" "telecom" "telecom@10.22.98.203")))
  (let ((connection (run-program "plink" command :input :stream :output :stream :wait nil)))
    `(defun ,name (tag)
       (cond 
	 ((equal tag :process) ,connection)
	 ,@(loop for x in *plink-connection-method* collect
		`((equal tag ,(car x)) ,(funcall (cadr x) connection)))))))

;;;; well, use class for it takes more work to write in above method, because of the condition judgement of function runs each time and only once

(defclass plink ()
  ((process :accessor plink-process :initarg :pp)
   (instream :accessor plink-in :initarg :pi)
   (outstream :accessor plink-out :initarg :po)))

(defmethod new-plink-connection ((command list))
  (let ((mame-process
	 (run-program "plink" command :input :stream :output :stream :wait nil)))
    (make-instance 'plink
		   :pp mame-process
		   :pi (external-process-input-stream mame-process)
		   :po (external-process-output-stream mame-process))))

(defmethod plink-status ((instance plink))
  (external-process-status (plink-process instance)))

(defmethod plink-exit


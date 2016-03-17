(in-package sbc-tools)

(defvar *command-head* "#!#!")
(defvar *command-end* ":")

(defvar *command-sentence*
  '("PLINK-COMMAND"
  "WAIT-OUTPUT"
  "INPUT-COMMAND"))

(defun eof-linep (mame)
  (equal mame :eof))

(defun string-equal-on-base (eva-string base-string)
  (let ((base-len (length base-string))
	(eva-len (length eva-string)))
    (when (> eva-len base-len)
      (string-equal eva-string base-string :end1 base-len))))

(defun string-equal-last (eva-string base-string)
  (let ((base-len (length base-string))
	(eva-len (length eva-string)))
    (when (> eva-len base-len)
      (string-equal eva-string base-string :start1 (- eva-len base-len)))))

(defun commandp (mame)
  (string-equal-on-base mame *command-head*))

(defun command-part (mame)
  (let ((command-head-length (length *command-head*)))
    (string-trim *command-end*
		 (subseq mame command-head-length))))

(defvar *return* (princ-to-string #\return))
(defun remove-last-return (mame)
  (if (stringp mame)
      (string-trim *return* mame)
      mame))

(defun cons-to-last (element list)
  (append (to-list list) (list element)))

(defun blank-linep (mame)
  (string-equal "" mame))

(defun to-list (mame)
  (if (atom mame)
      (list mame)
      mame))

(defun scenario-read (filename)
  (let (result)
    (with-open-file (in filename :direction :input)
      (loop
	   (let ((current-line (remove-last-return (read-line in nil :eof))))
	     (cond ((eof-linep current-line) (return))
		   ((commandp current-line) (push (command-part current-line) result))
		   ((blank-linep current-line) (push nil result))
		   (t (setf (car result) (cons-to-last current-line (car result)))))))
      (remove-if #'null (reverse  result)))))

(defun scenario-read-from-stream (in)
  (let (result)
    (loop
       (let ((current-line (remove-last-return (read-line in nil :eof))))
	 (cond ((eof-linep current-line) (return))
	       ((commandp current-line) (push (command-part current-line) result))
	       ((blank-linep current-line) (push nil result))
	       (t (setf (car result) (cons-to-last current-line (car result)))))))
    (remove-if #'null (reverse  result))))

(defun scenario-write (filename string)
  (with-open-file (out filename
		       :direction :output
		       :if-exists :supersede
		       :if-does-not-exist :create)
    (format string "~A" out)))

(defun string-to-list (mame &optional result)
  (let* ((new-mame (string-trim " " mame ))
	 (space-position (position #\space new-mame)))
    (if space-position
	(string-to-list (subseq new-mame space-position)
			(cons (subseq new-mame 0 space-position) result))
	(reverse (cons new-mame result)))))

(defun scenario-run (result stream)
  (loop for x in result do
       (when x
	 (let ((command (car x)))
	   (cond ((equal command "PLINK-COMMAND")
		  (format stream "~A" (cadr x))
		  (setf *plink* (new-plink-connection (cdr (string-to-list (cadr x))))))
		 ((equal command "WAIT-OUTPUT")
		  (let ((output (plink-get-output *plink*)))
		  (format stream "~A" output)
		    (unless (string-equal-last (string-trim " " output) (cadr x))
		      (return :with-wrong-wait-target))))
		 ((equal command "INPUT-COMMAND")
		  (loop for y in (cdr x) do
		       (format stream "~A" y)
		       (plink-command-input *plink* y))))))))

(defun scenario-list ()
  (directory "scenario/*"))

(defun extract-file-name (mame)
  (let ((slash-position (position #\/ mame)))
    (if slash-position
	(extract-file-name (subseq mame (+ slash-position 1)))
	mame)))

(defun scenario-run-from-string-to-string (input-string)
  (let ((in (make-string-input-stream input-string))
	(out (make-string-output-stream)))
    (scenario-run (scenario-read-from-stream in) out)
    (get-output-stream-string out)))
					   

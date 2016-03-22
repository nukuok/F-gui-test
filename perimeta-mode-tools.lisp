(in-package sbc-tools)

(defun pm-get-question (&optional input-command)
  (plink-command-input *plink*
		       (concatenate 'string input-command " ?"))
  (remove #\return (plink-get-output *plink*)))

;(defvar *current-configuration-position* nil)
(defvar *current-tree*)
(setf *current-tree* nil)
(defvar *current-candidates-list*)
(setf *current-candidates-list* nil)
(defvar *current-command-area*)
(setf *current-command-area* "")
(defvar *head-for-candidates* "  ")
;(defvar *last-prompt*)

(defun pm-is-alphabet (mame)
  (let ((cc (char-code mame)))
    (or (< 96 cc 123) (< 64 cc 91))))

(defun pm-is-candidate (line)
  (let ((l (length *head-for-candidates*)))
  (and (string-equal *head-for-candidates* line
		     :end2 l)
       (pm-is-alphabet (nth l (coerce line 'list)))
       (car (string-split (string-trim " " line) #\space)))))

(defun pm-get-candidates (&optional input-command)
  (let ((question-result (string-split (pm-get-question input-command) #\newline)))
    (loop for x in question-result collect
	 (pm-is-candidate x))))

(defun pm-get-last-prompt (mame)
  (let ((last-line (last-1 (remove nil (string-split mame #\newline)))))
    (subseq last-line (or (position #\( last-line) 0))))

(defun submode-changed-p (mame1 mame2)
  (not (equal mame1 mame2)))

(defun count-line (mame &optional (linum 1))
  (let ((newline-position (position #\newline mame)))
    (if newline-position
	(count-line (subseq mame (1+ newline-position)) (1+ linum))
	linum)))

(defun contain-char (char sentence)
  (member char (coerce sentence 'list)))

(defun string-equal-base (base-string eva-string)
  (let ((length-base (length base-string))
	(length-eva (length eva-string)))
    (and (< length-base length-eva)
	 (string-equal base-string eva-string :end2 length-base))))

(defun incomplete-command-p (mame)
  (member "% Incomplete command." (string-split mame #\newline)
	  :test #'string-equal-base))

(defun last-char (mame)
  (last-1 (coerce mame 'list)))

(let ((last-prompt "#"))
  (defun pm-command-input (input-command)
    (progn
      (plink-command-input *plink* input-command)
      (let* ((output-result (remove #\return (plink-get-output *plink*)))
	     (new-prompt (pm-get-last-prompt output-result)))
	(cond
	  ((not (equal (last-char new-prompt) #\#))
	   (setf *current-command-area* ""))
	  ((submode-changed-p last-prompt new-prompt)
	   (push input-command *current-tree*)
	   (setf *current-command-area* "")
	   (setf *current-candidates-list* (remove nil (pm-get-candidates))))
	  ((contain-char #\%  output-result)
	   (setf *current-command-area* input-command))
	  (t
	   (setf *current-command-area* "")))
	(setf last-prompt new-prompt))
      (list *current-tree* *current-command-area* *current-candidates-list*))))

(defun pm-command-output ()
  (


    (setf *current-candidates-list* (remove nil (pm-get-candidates)))
	 (let 	((output-result (remove #\return (plink-get-output *plink*)))
	 (temp-current-candidates-list (remove nil (pm-get-candidates))))
    (or (equal temp-current-candidates-list *current-candidates-list*)
	(progn 
  (push input-command *current-configuration-position*)
	  (setf *current-candidates-list* temp-current-candidates-list)))
    output-result))
  

(defun pm-candidate-chosen (input-command)
  (plink-command-input *plink* input-command)
  (let 	((output-result (remove #\return (plink-get-output *plink*))))

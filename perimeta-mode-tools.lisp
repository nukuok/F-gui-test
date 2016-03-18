(in-package sbc-tools)

(defun pm-get-question (&optional input-command)
  (plink-command-input *plink*
		       (concatenate 'string input-command " ?"))
  (remove #\return (plink-get-output *plink*)))

(defvar *current-configuration-position* nil)
(defvar *current-candidates-list* nil)
(defvar *head-for-candidates* "  ")
(defvar *last-prompt*)

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

(defun pm-candidate-chosen (input-command)
  (plink-command-input *plink* input-command)
  (let 	((output-result (remove #\return (plink-get-output *plink*))))

      
(let ((last-prompt "#"))
  (defun pm-command-input (command-or-submode)
    (plink-command-input *plink* input-command)
  (let 	((output-result (remove #\return (plink-get-output *plink*))))
    

    (setf *current-candidates-list* (remove nil (pm-get-candidates)))
	 (let 	((output-result (remove #\return (plink-get-output *plink*)))
	 (temp-current-candidates-list (remove nil (pm-get-candidates))))
    (or (equal temp-current-candidates-list *current-candidates-list*)
	(progn 
	  (push input-command *current-configuration-position*)
	  (setf *current-candidates-list* temp-current-candidates-list)))
    output-result))

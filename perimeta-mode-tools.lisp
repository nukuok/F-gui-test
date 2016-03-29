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
    (or (< 47 cc 58) (< 96 cc 123) (< 64 cc 91))))

(defun pm-is-candidate (line)
  (let ((l (length *head-for-candidates*)))
    (and (<= l (length line))
	 (string-equal *head-for-candidates* line
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
    (and (<= length-base length-eva)
	 (string-equal base-string eva-string :end2 length-base))))

(defun incomplete-command-p (mame)
  (member "% Incomplete command." (string-split (remove #\return mame) #\newline)
	  :test #'string-equal-base))

(defun invalid-input-p (mame)
  (member "% Invalid input" (string-split (remove #\return mame) #\newline)
	  :test #'string-equal-base))

(defun last-char (mame)
  (last-1 (coerce mame 'list)))

(defun equal-tree-element (base-element eva-element)
  (let ((base-splited (remove nil (string-split base-element #\space)))
	(eva-splited (remove nil (string-split eva-element #\space))))
    (and (= (length base-splited) (length eva-splited))
	 (loop for x in base-splited for y in eva-splited collect
	      (string-equal-base x y)))))

(defun member-tree-element (element tree)
  (member element tree :test
	  (lambda (x y)
	    (and (loop for a in x for b in y collect (or a b))))))
	   

(defun submode-included-in-current-tree (mame)
  (let ((submode-position
	 (position mame *current-tree* :test (lambda (x y) (equal x (car y))))))
    (nthcdr (+ (or submode-position -1) 1) *current-tree*)))
;; remove adjacency-submode when change from adjacency to adjacency


(defun make-new-current-tree (mame input-command)
  (cons (list mame input-command)
	(submode-included-in-current-tree mame)))

(defun pm-command-input (input-command)
  (progn
    (plink-command-input *plink* input-command)
    (let* ((output-result (remove #\return (plink-get-output *plink*)))
	   (new-prompt (pm-get-last-prompt output-result)))
      (cond
	((invalid-input-p output-result)
	 (setf *current-command-area* "")
	 (setf *current-candidates-list* (remove nil (pm-get-candidates))))
	((not (equal (last-char new-prompt) #\#))
	 (setf *current-command-area* ""))
	((incomplete-command-p  output-result)
	 (setf *current-command-area* input-command)
	 (setf *current-candidates-list*
	       (remove nil (pm-get-candidates input-command))))
	(t
	 (setf *current-tree* (make-new-current-tree new-prompt input-command))
	 (setf *current-command-area* "")
	 (setf *current-candidates-list* (remove nil (pm-get-candidates))))))
    (list *current-tree* *current-command-area* *current-candidates-list*)))

;;(defun pm-command-output ()
;;  (
(defun reverse-list (list)
  (reverse (coerce list 'sequence)))

(defun pm-command-output-current-tree ()
  `(with-html-output-to-string (s nil :indent t)
    (:div
     (:strong (:u (:font :color "blue" :style "cursor:pointer;"
			 :onclick (ps-inline front-input-command "end")
			 "#")))
     ,@(loop for x in (reverse *current-tree*) append
	    (list
	     " &gt; "
	     `(:strong (:u (:font :color "blue" :style "cursor:pointer;"
				  :onclick (ps-inline (ajax-input-command ,(cadr x)))
									  ,(cadr x)))))))))

(defun pm-command-output-candidate ()
  `(with-html-output-to-string (s nil :indent t)
     (:div
      ,@(loop for x in *current-candidates-list* append
	     (list
	      `(:br) "=&gt;"
	      `(:strong (:u (:font :color "blue" :style "cursor:pointer;"
				 :onclock (ps-inline (front-move-to-commandare ,x)) ,x))))))))

(defun pm-command-output ()
  (concatenate 'string
	       *current-command-area*
	       "#;#"
	       (eval (pm-command-output-current-tree))
	       (eval (pm-command-output-candidate))))



(defun pm-candidate-chosen (input-command)
  (plink-command-input *plink* input-command)
  (let 	((output-result (remove #\return (plink-get-output *plink*))))))



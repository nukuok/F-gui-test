(in-package sbc-tools)

;;(defun color-html-string (string color)
;;  (with-html-output-to-string (a) (:font :color color (fmt "~a" string))))

(defun html-string (string &optional color)
  (cond
    (color (with-html-output-to-string (a) (:font :color color (fmt "~a" string))))
    (t (with-html-output-to-string (a) (fmt "~a" string)))))

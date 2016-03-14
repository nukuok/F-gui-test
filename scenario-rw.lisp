(in-package sbc-tools)

(defvar *command-head* "#!#!")

(defvar *command-sentence*
  "PLINK-COMMAND"
  "WAIT-OUTPUT"
  "INPUT-CMMAND")

(defun scenario-read (filename)
  (with-open-file (in filename :direction :input 

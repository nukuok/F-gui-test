(pushnew "." cffi:*FOREIGN-LIBRARY-DIRECTORIES*)
(ql:quickload "hunchentoot")
(hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 4242))

(ql:quickload :parenscript)
(ql:quickload :cl-who)



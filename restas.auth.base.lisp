;(ql:quickload :restas)

(defpackage :restas.auth.base
  (:use :cl :restas :restas.auth.storage)
  (:import-from :hunchentoot #:authorization #:require-authorization #:session-value)
  (:import-from :routes #:proxy-route #:route-check-conditions)
  (:export   
   #:@http-auth-require #:prepare-password 
   #:store-user-pass #:get-user-pass #:check-password
   #:set-salt #:get-salt #:set-storage #:get-storage
   #:set-auth-message #:get-auth-message
   #:storage #:trivial-storage))

(in-package :restas.auth.base)

(defclass http-auth-route (proxy-route) ())

(defparameter *salts* (make-hash-table))
(defparameter *auth-storages* (make-hash-table))
(defparameter *auth-messages* (make-hash-table))
(defparameter *default-auth-message* "Welcome! Please enter your username and password")

(defun set-salt (salt &optional (package *package*))
  (setf (gethash package *salts*) salt))

(defun get-salt (&optional (package *package*))
  (or (gethash package *salts*) *default-salt*))

(defun set-storage (storage &optional (package *package*))
  (setf (gethash package *auth-storages*) storage))

(defun get-storage (&optional (package *package*))
  (gethash package *auth-storages*))

(defun get-auth-message (&optional (package *package*))
  (or (gethash package *auth-messages*) *default-auth-message*))

(defun set-auth-message (message &optional (package *package*))
  (setf (gethash package *auth-messages*) message))

(defmethod route-check-conditions ((route http-auth-route) bindings)
  (and (call-next-method)
       (multiple-value-bind (user password)
           (authorization)
         (let ((storage (get-storage)))
           (or (and (user-exist-p user storage)
                    (check-password user
                                    password
                                    storage))
               (require-authorization (get-auth-message)))))))

(defun @http-auth-require (route)
  (make-instance 'http-auth-route :target route))

(defun check-password (user pass storage)
  ;(setf user "LinkFly" storage #P"D:/linkfly-win-files/projects/restas-login/example/users.trivial-storage")
  (string= (get-user-pass user storage)
           (maybe-hashing-password pass storage)))



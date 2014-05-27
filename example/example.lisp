(defparameter *this-dir* (make-pathname :defaults *load-pathname* :name nil :type nil))
(pushnew #P"D:/linkfly-win-files/projects/restas.auth/" asdf:*central-registry*)
(ql:quickload :restas.auth)

(restas:define-module :restas.login-example
  (:use :cl :restas :restas.auth))

(in-package :restas.login-example)

(defparameter *this-dir* cl-user::*this-dir*)

(define-route main ("")
  "Hello closed World")

(defparameter *hashing-salt* "<blabla>")

(defun get-trivial-storage ()
  (make-instance 'trivial-storage :pathname (merge-pathnames *this-dir* "users.trivial-storage")))

(restas.auth:store-user-pass "user" 
                             (restas.auth:prepare-password "pass" *hashing-salt*)
                             (get-trivial-storage))

(if (not (check-password "user"
                         (restas.auth:prepare-password "pass" 
                                                       *hashing-salt*)
                         (get-trivial-storage)))
    (error "Example not working! Please send bug message"))

;(restas.auth:set-salt restas.auth.storage:*default-salt*)
;(restas.auth:set-auth-message "Hi! Enter username and password")
;(restas.auth:set-auth-message restas.auth::*default-auth-message*)
(restas.auth:set-storage (get-trivial-storage))
;(restas.auth::get-users (get-storage))


(restas:start :restas.login-example :port 8443 ;;Listening 443 port denied (by default) on Windows7
       :decorators (list #'restas.auth:@http-auth-require)
       :ssl-certificate-file (probe-file (merge-pathnames "example.crt" *this-dir*))
       :ssl-privatekey-file (probe-file (merge-pathnames "example.key" *this-dir*))
       )
;(stop-all)
;(restas:debug-mode-on)



(defparameter *this-dir* (make-pathname :defaults *load-pathname* :name nil :type nil))
(pushnew (make-pathname :defaults *this-dir* :directory (butlast (pathname-directory *this-dir*)))
         asdf:*central-registry*)
(ql:quickload :restas.auth.base)

(restas:define-module :restas.login-example
  (:use :cl :restas :restas.auth.base))

(in-package :restas.login-example)

(defparameter *this-dir* cl-user::*this-dir*)

(define-route main ("")
  "Hello closed World")

(defparameter *hashing-salt* "<blabla>")

(defun get-trivial-storage ()
  (make-instance 'trivial-storage :pathname (merge-pathnames *this-dir* "users.trivial-storage")
                 :salt *hashing-salt*))

(restas.auth.base:store-user-pass "user" "pass" (get-trivial-storage))

(unless (check-password "user" "pass" (get-trivial-storage))
  (error "Example not working! Please send bug message"))

(restas.auth.base:set-auth-message "Hi! Enter username and password")
(restas.auth.base:set-storage (get-trivial-storage))
;(restas.auth::get-users (get-storage))

(restas:start :restas.login-example :port 8443 ;;Listening 443 port denied (by default) on Windows7
       :decorators (list #'restas.auth.base:@http-auth-require)
       :ssl-certificate-file (probe-file (merge-pathnames "example.crt" *this-dir*))
       :ssl-privatekey-file (probe-file (merge-pathnames "example.key" *this-dir*))
       )
;(stop-all)
;(restas:debug-mode-on)



;(ql:quickload :ironclad)
;(ql:quickload :babel)
;(ql:quickload :hu.dwim.defclass-star)
;(ql:quickload :iterate)

(defpackage :restas.auth.storage
  (:use :cl :hu.dwim.defclass-star :iterate)
  (:import-from :babel #:string-to-octets)
  (:import-from :ironclad #:digest-sequence)
  (:export #:prepare-password #:store-user-pass #:get-user-pass #:*default-salt* #:get-users #:user-exist-p))

(in-package :restas.auth.storage)

(defparameter *default-salt* "<blabla>")

(defclass* pass-hashing ()
           ((algorithm :initform :sha1)
            (salt :initform "")
            (enabled :initform t :type boolean)))
;(setf tmp (make-instance 'pass-hashing))

;;;;;;;;; Generic API ;;;;;;;;;;
(defgeneric store-user-pass (user pass storage))
(defgeneric get-user-pass (user storage))
(defgeneric get-users (storage))
(defgeneric user-exist-p (user storage))
;;;;;;;;;

(defgeneric crypthash-to-string (hash))
(defgeneric pass-hashing (pass pass-hashing))

;;;;;;;;;;;;;;;;;;

(defun bytes-to-hexstr (bytes &aux str)
  (iter (for byte in-vector bytes)
    (with str = (make-string (* 2 (length bytes))))
    (for i upfrom 0 by 2)
    (setf (subseq str i (+ i 2)) (format nil "~2,'0X" byte))
    (finally (return str))))

(defmethod crypthash-to-string (crypthash)
  (bytes-to-hexstr crypthash))

(defmethod pass-hashing ((pass string) (pass-hashing pass-hashing))
  ;(setf pass-hashing (make-instance 'pass-hashing :salt *hashing-salt*))
  (if (not (enabled-p pass-hashing))
      pass
    (crypthash-to-string 
     (ironclad:digest-sequence :sha1 (string-to-octets
                                      (format nil "~A~A" 
                                              (salt-of pass-hashing)
                                              pass))))))

;;;;; Else API ;;;;;;; 
(defun prepare-password (pass salt)
  (pass-hashing pass (make-instance 'pass-hashing :salt salt)))
;(prepare-password "somepass" "<blabla>")
;;;;;;;;;;;;

;;;;;;;;; Trivial implementation ;;;;;;;;;;

(defun update-trivial-storage (file data)
  (with-open-file (s file :direction :output :if-does-not-exist :create :if-exists :supersede)
    (write data :stream s)))

(defun init-trivial-storage (file)
  (update-trivial-storage file nil))

(defun read-file (file)
  (with-open-file (s file)
    (read s)))

(defun read-trivial-storage (file)
  (read-file file))

(defmethod store-user-pass (user pass (storage pathname) &aux data)
  (setf data (if (probe-file storage)
                 (read-trivial-storage storage)
               (progn (init-trivial-storage storage) nil)))
  (if (not data)
                 (setf data `((,user ,pass)))
               (let ((pair (assoc user data :test #'string=)))
                 (if pair 
                     (setf (second pair) pass)
                   (push (list user pass) data))))
  (update-trivial-storage storage data))

(defmethod get-user-pass (user (storage pathname))
  (second (assoc user (read-trivial-storage storage) :test #'string=)))
;(get-user-pass "LinkFly" storage)
      
(defmethod get-users ((storage pathname))
  ;(setf storage (merge-pathnames "example/users.trivial-storage" (asdf:system-source-directory :restas.auth)))
  (mapcar #'first (read-trivial-storage storage)))
  
(defmethod user-exist-p (user (storage pathname))
  (and (get-user-pass user storage) t))
  
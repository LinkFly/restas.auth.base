(asdf:defsystem :restas.auth
  :depends-on (:restas :hunchentoot :routes :ironclad :babel :hu.dwim.defclass-star :iterate)
  :serial t
  :components ((:file "storage")
               (:file "restas.auth")))
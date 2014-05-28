(asdf:defsystem :restas.auth.base
  :depends-on (:restas :hunchentoot :routes :ironclad :babel :hu.dwim.defclass-star :iterate)
  :serial t
  :components ((:file "storage")
               (:file "restas.auth.base")))
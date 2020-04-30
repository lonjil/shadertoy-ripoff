(asdf:defsystem #:shadertoy-pyx
  :description "Describe shadertoy ripoff here"
  :author "Lonjie <lonjil@gmail.com>"
  :license  "Pain"
  :version "0.0.1"
  :serial t
  :depends-on (#:pyx #:origin)
  :pathname "src"
  :components ((:file "package")
               (:file "shader")
               (:file "foo")))

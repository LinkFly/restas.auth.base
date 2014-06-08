RESTAS.AUTH.BASE - ������� ������� �������������� ��� ������ �� ���� RESTAS/HUNCHENTOOT
================

������ ������������� ��. � example/example.lisp
��� ����, ����� ��������� ���� ������ �� 8443 ����� ���������� ��������� ���� ����:
`(load "<����_�_����������>/example/example.lisp")`

��������!
��������� ������������� TRIVIAL-STORAGE � �������� ����� ���������������� �������� � �� ������������� ��� �������������.
���������� ��������� ������� �� ������������� ������ ���������. ��� ����� ���������� ������� ��������� ����:

1) ������� ������ ���������� �� ������ STORAGE

2) ���������� ������ ��� ������ ������, ��� ��������� ���������� �-��:
STORE-USER-PASS
GET-USER-PASS
GET-USERS
USER-EXIST-P

������
------------
* ����� �������� ���-������� � �������� ��������������, ���������� ���������� ��� ��������� � �������������� � ��������.
��� ����������������� ��������� TRIVIAL-STORAGE (��������� ������������� � ������ � ������� ������������� ������ � �����) 
����� ������� �������� ���������: :pathname � :salt (����� ������, ������� ����� �������������� � ������, 
��� ����������� ���������):

```common-lisp
(defun get-trivial-storage ()
  (make-instance 'trivial-storage :pathname (merge-pathnames *this-dir* "users.trivial-storage")
                 :salt *hashing-salt*))
(restas.auth.base:set-storage (get-trivial-storage))
```

* ��� ������� ���-������� � �������� �������������� ���������� �������� ��������� #'restas.auth.base:@http-auth-require :

```common-lisp
(restas:start :restas.login-example :port 8443
              :decorators (list #'restas.auth.base:@http-auth-require))
```

����������
------------
* ����� ���������� ��� ��������� ��� ������ ��������������:

`(restas.auth.base:set-auth-message "Hi! Enter username and password")`

* ����� ��� �������� ��������� (����� ����������� STORAGE) ��������� ����������� �������, 
� ���� ������ �������� :salt �� �����:

```common-lisp
(make-instance 'trivial-storage :pathname (merge-pathnames *this-dir* "users.trivial-storage")
               :hashing-password nil)
```

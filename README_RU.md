RESTAS.AUTH.BASE - Базовая система аутентификации для систем на базе RESTAS/HUNCHENTOOT
================

Пример использования см. в example/example.lisp
Для того, чтобы запустить этот пример на 8443 порту достаточно загрузить этот файл:
`(load "<путь_к_исходникам>/example/example.lisp")`

Внимание!
Хранилище пользователей TRIVIAL-STORAGE с паролями носит демонстрационный характер и не рекомендуется для использования.
Необходимо настроить систему на использование своего хранилища. Для этого необходимо сделать следующие шаги:

1) Создать своего наследника от класса STORAGE

2) Определить методы для нового класса, для следующих обобщённых ф-ий:
STORE-USER-PASS
GET-USER-PASS
GET-USERS
USER-EXIST-P

Детали
------------
* Перед запуском веб-сервера с системой аутентификации, необходимо установить своё хранилище с пользователями и паролями.
Для демонстрационного хранилища TRIVIAL-STORAGE (сохраняет пользователей и пароли в простом ассоциативном списке в файле) 
нужно указать ключевые аргументы: :pathname и :salt (любая строка, которая будет присоединяться к паролю, 
для затруднения брутфорса):

```common-lisp
(defun get-trivial-storage ()
  (make-instance 'trivial-storage :pathname (merge-pathnames *this-dir* "users.trivial-storage")
                 :salt *hashing-salt*))
(restas.auth.base:set-storage (get-trivial-storage))
```

* Для запуска веб-сервера с системой аутентификации необходимо передать декоратор #'restas.auth.base:@http-auth-require :

```common-lisp
(restas:start :restas.login-example :port 8443
              :decorators (list #'restas.auth.base:@http-auth-require))
```

Дополнения
------------
* Можно установить своё сообщение для данных аутентификации:

`(restas.auth.base:set-auth-message "Hi! Enter username and password")`

* Можно при создании хранилища (любых наследников STORAGE) запретить хэширование паролей, 
в этом случае аргумент :salt не нужен:

```common-lisp
(make-instance 'trivial-storage :pathname (merge-pathnames *this-dir* "users.trivial-storage")
               :hashing-password nil)
```

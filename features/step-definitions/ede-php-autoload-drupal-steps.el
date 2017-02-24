;; Originally stolen from ede-php-autoload and adapted.

(defvar ede-php-autoload-drupal-project-paths)
(defvar ede-projects)

(Before
 ;; Kill all file buffers.
 (mapc 'kill-buffer (cl-remove-if-not 'buffer-file-name (buffer-list)))
 ;; Make EDE forget all projects.
 (setq ede-projects nil))

(When "^I visit \"\\(.+\\)\" in project \"\\(.+\\)\"$"
  (lambda (file-path project-name)
    (find-file (ede-php-autoload-drupal-test-get-project-file-path file-path project-name))))

(Then "^ede-php-autoload-project should exist$"
  (lambda ()
    (should (ede-php-autoload-project-p (ede-current-project)))))

(Then "^the class \"\\(.+\\)\" should be detected in \"\\(.+\\)\"$"
  (lambda (class-name file-path)
    (should
     (string=
      (ede-php-autoload-drupal-test-get-project-file-path
       file-path
       (ede-php-autoload-drupal-test-get-current-project-name))
      (ede-php-autoload-find-class-def-file (ede-current-project) class-name)))))

(Then "^the class \"\\(.+\\)\" should not be detected"
  (lambda (class-name)
    (should-not (ede-php-autoload-find-class-def-file (ede-current-project) class-name))))

(Then "^guessing the class name for \"\\(.+\\)\" should return \"\\(.+\\)\""
  (lambda (file-name class-name)
    (should (string= (ede-php-autoload-get-class-name-for-file
                      (ede-current-project)
                      file-name)
                     class-name))))

(Then "^completions for query \"\\(.+\\)\" should be:"
  (lambda (query suggestion-table)
    (should (equal (ede-php-autoload-complete-type-name (ede-current-project) query)
                   (car suggestion-table)))))

(Then "^I should see a \"\\([^\"]+\\)\" warning$"
  (lambda (expected)
    (should
     (with-current-buffer "*Warnings*"
       (s-contains?
        ;; Emacs 25+ translates ' quotes to ’.
        (if (> emacs-major-version 24)
            (s-replace "'" "’"expected)
          expected)
        (buffer-string))))))

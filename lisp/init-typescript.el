(maybe-require-package 'web-mode)
(maybe-require-package 'tide)

(add-to-list 'auto-mode-alist '("\\.tsx$" . web-mode))
(add-to-list 'auto-mode-alist '("\\.ts$" . typescript-mode))

(with-eval-after-load 'flycheck
  (flycheck-add-mode 'typescript-tslint 'typescript-mode)
  (flycheck-add-mode 'typescript-tslint 'web-mode))

;; use local eslint from node_modules before global
;; http://emacs.stackexchange.com/questions/21205/flycheck-with-file-relative-eslint-executable
;; This assumes we're in typescript all the time or it will fail
(defun my/use-tslint-from-node-modules ()
  "Load the local tslint."
  (let* ((root (locate-dominating-file
                (or (buffer-file-name) default-directory)
                "node_modules"))
         (tslint (and root
                      (expand-file-name "node_modules/tslint/bin/tslint"
                                        root))))
    (when (and tslint (file-executable-p tslint))
      (setq-local flycheck-typescript-tslint-executable tslint))))

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  (add-hook 'flycheck-mode-hook #'my/use-tslint-from-node-modules)
  (company-mode +1))

(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "tsx" (file-name-extension buffer-file-name))
              (setup-tide-mode))))

;; (add-hook 'web-mode-hook #'setup-tide-mode)
(add-hook 'typescript-mode-hook #'setup-tide-mode)

(setq tide-format-options '(:indentSize 0 :tabSize 0))
(setq typescript-indent-level 2)

(provide 'init-typescript)

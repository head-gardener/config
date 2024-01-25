;; Appearance
(load-theme 'nordic-night)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(set-face-attribute 'default nil :font "LilexNerdFontMedium-9")
(setq visible-bell t)

;; this shit doesn't work smh
(setq inhibit-startup-screen t)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

(setq backup-directory-alist '(("." . "~/.emacs.d/backups/")))

;; Initialize Org Mode
(require 'org)

;; Set default Org Mode keybindings
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c b") 'org-switchb)

;; Set default Org Mode directories
(setq org-directory "~/org")
(setq org-default-notes-file (concat org-directory "/notes.org"))

;; Load agenda files from Org Mode directory
(setq org-agenda-files (list org-directory))

(org-babel-do-load-languages
    'org-babel-load-languages
    '((mermaid . t)))

(require 'magit)

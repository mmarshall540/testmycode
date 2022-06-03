;;; testmycode.el --- Interface to the tmc-cli command for use with mooc.fi courses.  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Martin Marshall

;; Author: Martin Marshall <law@martinmarshall.com>
;; URL: https://github.com/mmarshall540/testmycode
;; Version: 0.1
;; Keywords: convenience, tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; An interface to the tmc-cli command line tool for use with the
;; mooc.fi online programming courses.
;;
;; Requires the `tmc-cli' program.
;;
;; See https://github.com/testmycode/tmc-cli

;;; Code:

;; TODO Add an option to autodecline the feedback prompt when
;; submitting exercises.
;; (when tmc-feedback-autodecline
;;   (fset 'tmc-run-submit
;;         (lambda ()
;;           (interactive)
;;           (term (concat "/bin/bash -c \"yes \'n\' \| cat\"")))))
;; ;; | " tmc-executable " submit\"")))))

(defgroup testmycode nil
  "Settings for testmycode, which is an interface to the TestMyCode cli program.
See https://github.com/testmycode/tmc-cli"
  :group 'term)

(defcustom tmc-executable (executable-find "tmc")
  "Location of the `tmc' executable on the system."
  :type '(file :must-match t)
  :group 'testmycode)

(defcustom tmc-prefix-key (kbd "C-c '")
  "Prefix under which to bind tmc-cli commands."
  :type '(key-sequence)
  :group 'testmycode)

(defcustom tmc-arg-key-alist '(("login"             . [?l])
                               ("courses"           . [?c])
                               ("test"              . [?t])
                               ("submit"            . [?s])
                               ("update"            . [?u])
                               ("exercises -n"      . [?e])   ;; optional -n or --no-pager arg
                               ("paste"             . [?y])
                               ("organization"      . [?o])
                               ("download -a"       . [?a])   ;; -a to download all courses
                               ("config -l"         . [?g])) ;; -l to list all settings
  "Alist of arguments to the `tmc' command and the keys to call them."
  :type '(alist :key-type string :value-type key-sequence)
  :group 'testmycode)

(define-prefix-command 'tmc-prefix)

(defvar tmc-mode-map (make-sparse-keymap))

(define-key tmc-mode-map [menu-bar tmc]
            (cons "TMC" (make-sparse-keymap "TMC")))

(defun tmc--define-key-menu (key cmd menu-string)
  "Set up key binding and menu-entry for testmycode.
Use KEY, CMD, and MENU-STRING for same."
  (define-key 'tmc-prefix key cmd)
  (define-key tmc-mode-map (vector 'menu-bar 'tmc `,cmd) `(,menu-string . ,cmd)))

(tmc--define-key-menu [?n] 'tmc-next-exercise "Next Exercise")
(tmc--define-key-menu [?p] 'tmc-previous-exercise "Previous Exercise")
(tmc--define-key-menu [?r] 'tmc-run-run "Run this file")

(dolist (pair tmc-arg-key-alist)
  (let ((s (intern (concat "tmc-run-" (car (split-string (car pair))))))
        (k (cdr pair)))
    (fset s
          (lambda ()
            (interactive)
            (tmc-run (car pair))))
    (tmc--define-key-menu k s (car pair))))

(defun tmc-run (cmd)
  "Run `tmc' in *terminal* buffer with the given CMD.
Optionally, add ARGS."
  (term (concat "/bin/bash -c \"" tmc-executable " " cmd "\"")))

(defun tmc-run-run ()
  "Run the java program for the current exercise."
  (interactive)
  (let* ((source (file-name-nondirectory buffer-file-name))
         (out (file-name-sans-extension source))
         (class (concat out ".class")))
    (save-buffer)
    (shell-command (format "rm -f %s && javac %s" class source))
    (if (file-exists-p class)
        (term (format "/bin/bash -c \"java %s\"" out))
      (progn
        (set (make-local-variable 'compile-command)
             (format "javac %s" source))
        (command-execute 'compile)))))

(defun tmc-next-exercise (&optional currdir previous)
  "Find next exercise file from.

Defaults to search from current value of variable
`default-directory' unless CURRDIR is provided.

If PREVIOUS is non-nil, search for previous exercise."
  ;; TODO If no matching dirs, try incrementing the "part" numbers and
  ;; opening section 01.
  ;;
  ;; TODO Simplify the procedure for finding next/previous directory.
  ;; Also, get it to work from any subdirectory of the exercise
  ;; directory, not only direct ancestors of the "java" directory.
  (interactive)
  (catch 'undoable
    (let* ((d (or currdir default-directory)) ;; full path of the current directory
           (l (file-name-split d))     ;; list of components in the default-directory
           (lenl (length l))           ;; # of components in the directory
           (bd (nth (- lenl 2) l))     ;; name of top-level current directory
           (edi (- lenl (pcase bd      ;; index number of the exercise directory in l
                          ("java" 5)
                          ("main" 4)
                          ("src"  3)
                          (name (if (string= (substring name 0 4) "part")
                                    2 ;; if it matches, we're in the exercise directory itself
                                  (throw 'undoable (message "Aborting because we don't appear to be under an exercise directory!
This means we can't automatically find the next or previous exercise file.")))))))
           (exercisedir (nth edi l))   ;; the "part##-Part##_##.AbcDef" directory in the file-path
           (cdi (- edi 1))             ;; coursedir is the parent of exercisedir
           (coursedirfull (string-join (butlast l (- lenl 1 cdi)) "/")) ;; full path of coursedir
           (section (substring exercisedir 14 16))  ;; section number from current exercise directory
           (part (substring exercisedir 0 14))      ;; portion of current exercise directory name ending with underscore
           (contingentnextsec (if previous          ;; increment/decrement the section number
                                  (number-to-string (- (string-to-number section) 1)) ;; go backwards
                                (number-to-string (+ (string-to-number section) 1)))) ;; go forwards
           (contingentnextsecpadded (if (eq (length contingentnextsec) 1) (concat "0" contingentnextsec) contingentnextsec))
           (matchingdirs (directory-files coursedirfull t (concat "^" part contingentnextsecpadded ".*") nil 1))
           (matchingfiles (directory-files (concat (car matchingdirs) "/src/main/java") t "^[^#.~].*\.java$" nil 1)))
      (if (not matchingdirs)
          (message "No matching directories found.")
        (if matchingfiles
            (find-file (car matchingfiles))
          (message "No matching files found."))))))

(defun tmc-previous-exercise (&optional file)
  "Find previous exercise FILE."
  (interactive)
  (tmc-next-exercise file t))

;;;###autoload
(define-minor-mode tmc-mode
  "Set up commands for running the TestMyCode cli program."
  :lighter " TMC"
  :keymap tmc-mode-map
  :global t
  :group 'testmycode
  :after-hook
  (if tmc-mode
      (define-key global-map tmc-prefix-key 'tmc-prefix)
    (define-key global-map tmc-prefix-key nil)))

(provide 'testmycode)
;;; testmycode.el ends here

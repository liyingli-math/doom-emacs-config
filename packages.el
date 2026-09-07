;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or
;; use 'M-x doom/reload'.


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;; (package! some-package)

;; To install a package directly from a remote git repo, you must specify a
;; `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/radian-software/straight.el#the-recipe-format
;; (package! another-package
;;   :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;; (package! this-package
;;   :recipe (:host github :repo "username/repo"
;;            :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
;; (package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;; (package! builtin-package :recipe (:nonrecursive t))
;; (package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see radian-software/straight.el#279)
;; (package! builtin-package :recipe (:branch "develop"))

;; Use `:pin' to specify a particular commit to install.
;; (package! builtin-package :pin "1a2b3c4d5e")


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
;; (unpin! pinned-package)
;; ...or multiple packages
;; (unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;; (unpin! t)

;;
(package! org :recipe
  (:host nil :repo "https://git.tecosaur.net/mirrors/org-mode.git" :remote "mirror" :fork
   (:host nil :repo "https://git.tecosaur.net/tec/org-mode.git" :branch "dev" :remote "tecosaur")
   :files
   (:defaults "etc")
   :build t :pre-build
   (with-temp-file "org-version.el"
     (require 'lisp-mnt)
     (let
         ((version
           (with-temp-buffer
             (insert-file-contents "lisp/org.el")
             (lm-header "version")))
          (git-version
           (string-trim
            (with-temp-buffer
              (call-process "git" nil t nil "rev-parse" "--short" "HEAD")
              (buffer-string)))))
       (insert
        (format "(defun org-release () \"The release version of Org.\" %S)\n" version)
        (format "(defun org-git-version () \"The truncate git commit hash of Org mode.\" %S)\n" git-version)
        "(provide 'org-version)\n"))))
  :pin nil)
(unpin! org)

;;super save
(package! super-save)
;; pyim-wubi
(package! pyim-wbdict
  :recipe (:host github :repo "tumashu/pyim-wbdict"))
(package! keycast)
;; jinx: spell checker
(package! jinx
  :recipe (:host github :repo "minad/jinx"))
;; pdf-tools
;; (unpin! pdf-tools)
;; (package! pdf-tools
;;   :recipe (:host github :repo "aikrahguzar/pdf-tools" :branch "child-frame-preview"))
;; org-mode related
;; (package! org-fragtog
;;   :recipe (:host github :repo "io12/org-fragtog"))
;; (package! org-preview
;;   :recipe (:host github :repo "karthink/org-preview"))
;; related to org-roam
;;(package! emacsql :pin "fb05d0f72729a4b4452a3b1168a9b7b35a851a53")
;; this is the commit before the regression of no ID for headline nodes.
;;(package! org-roam :pin "f4ba41cf3d")
;; ORUI need to keep to date with OR. See https://github.com/org-roam/org-roam-ui
(package! org-roam-ui)
(package! org-ref)
(package! org-appear)
;; (package! helm)
;; (package! helm-bibtex)
;; (package! bibtex-completion)
;; (package! org-roam-bibtex :recipe (:host github :repo "org-roam/org-roam-bibtex"))
(package! procress :recipe (:host github :repo "haji-ali/procress"))
(package! org-noter-pdftools)
;; https://github.com/nobiot/org-transclusion
;; ~/.doom.d/package.el
(package! org-transclusion)
(package! org-modern-indent :recipe (:host github :repo "jdtsmith/org-modern-indent"))
(unpin! auctex)
;; AI tools
(package! gptel-agent :recipe (:host github :repo "karthink/gptel-agent"))
(package! llm-tool-collection :recipe (:host github :repo "skissue/llm-tool-collection"))
(package! gptel-org-heading-adjust :recipe (:local-repo "~/.config/doom/lisp/gptel-heading/" :type nil))
(package! claude-code-ide
  :recipe (:host github :repo "manzaltu/claude-code-ide.el"))

(package! magit-gptcommit)

(package! eca :recipe (:host github :repo "editor-code-assistant/eca-emacs" :files ("*.el")))

(package! preview-auto)

;; accent letters
(package! accent :recipe (:host github :repo "eliascotto/accent"))

;; rainbow delimiter
(package! rainbow-delimiters :recipe (:host github :repo "Fanael/rainbow-delimiters"))

;; kdl (for niri config)
(package! emacs-kdl-mode :recipe (:host github :repo "taquangtrung/emacs-kdl-mode"))

;; disable mouse
(package! inhibit-mouse :recipe (:host github :repo "jamescherti/inhibit-mouse.el"))

;; consult reftex
(package! consult-reftex :recipe (:host github :repo "karthink/consult-reftex"))

;; reftex-xref
(package! reftex-xref :recipe (:local-repo "~/.config/doom/lisp/reftex-xref/" :type nil))
;; flash.nvim style jump and isearch
(package! flash :recipe (:host github :repo "Prgebish/flash"))

;; obsidian
(package! obsidian :recipe (:host github :repo "licht1stein/obsidian.el"))

;;(package! preview-dvisvgm)

(package! lazytab :recipe (:host github :repo "karthink/lazytab"))
(package! ox-hugo)

;; agent-shell
(package! shell-maker)
(package! acp)
(package! agent-shell)
(package! org-present)

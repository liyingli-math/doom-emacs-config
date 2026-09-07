;;; -*- lexical-binding: t; -*-
;;; some common replacements:

(defun my/regreplace-in-buffer (oldstr newstr)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward oldstr nil t) (replace-match newstr))))

(defun my/replace-delimiter-by-lr-version ()
  "Regreplace \\big, etc, by their left and right versions like \\bigl and \\bigr."
  (interactive)
  ;; replace left delimiters
  (my/regreplace-in-buffer
   (rx (and (group (and (or ?B ?b)
                        "ig"
                        (zero-or-one ?g)))
            (group (or "[" "(" "\\{"))))
   "\\1l\\2" )
  ;; replace right delimiters
  (my/regreplace-in-buffer
   (rx (and (group (and (or ?B ?b)
                        "ig"
                        (zero-or-one ?g)))
            (group (or "]" ")" "\\}"))))
   "\\1r\\2" ))

(defun my/replace-lrVert ()
  "Reg replace \\|...\\| (norm notation) by \\lVert and \\rVert."
  (interactive)
  (my/regreplace-in-buffer
   (rx
    (and (group (and (zero-or-one (and (or ?B ?b)
                                       "ig"
                                       (zero-or-one ?g)))))
         (zero-or-one ?l)
         "\\|"
         (group (one-or-more (not ?|)))
         (group (and (zero-or-one (and (or ?B ?b)
                                       "ig"
                                       (zero-or-one ?g)))))
         (zero-or-one ?r)
         "\\|"))
   "\\1\\\\lVert \\2 \\3\\\\rVert "))

(defun my/replace-lrvert ()
  "Reg replace |...| (absolute value) \\lvert...\\rvert."
  (interactive)
  (my/regreplace-in-buffer
   (rx (and
        (group (and (zero-or-one (and (or ?B ?b)
                                      "ig"
                                      (zero-or-one ?g)))))
        (zero-or-one ?l)
        ?|
        (group (one-or-more (not ?|)))
        (group (and (zero-or-one (and (or ?B ?b)
                                      "ig"
                                      (zero-or-one ?g)))))
        (zero-or-one ?r)
        ?|))
   "\\1\\\\lvert \\2 \\3\\\\rvert "))

;; This function require evil-tex
(defun my/replace-reg-condition ()
  "Reg replace (...\\mid...) (cond. expect.) by my customized macro \\con{...|...}."
  (interactive)
  (require 'evil-tex)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward (rx "\\mid") nil t)
      (replace-match "|")
      (let* ((case-fold-search nil)
             (outer (evil-tex-a-delim)) (inner (evil-tex-inner-delim))
             (left-over (ignore-errors (make-overlay (car outer) (car inner))))
             (right-over (ignore-errors (make-overlay (cadr inner) (cadr outer)))))
        (when (and left-over right-over outer inner)
          (save-excursion
            (let ((left-str (buffer-substring-no-properties (overlay-start left-over) (overlay-end left-over)))
                  (right-str (buffer-substring-no-properties (overlay-start right-over) (overlay-end right-over))))
              (cl-destructuring-bind (l . r)
                  (cond ; note: bigg/Bigg must be before big/Big
                   ((looking-at "\\\\\\(?:Bigg\\)")
                    (cons "\\con{\\Bigg}" "}"))
                   ((looking-at "\\\\\\(?:bigg\\)")
                    (cons "\\con{\\bigg}" "}"))
                   ((looking-at "\\\\\\(?:Big\\)")
                    (cons "\\con{\\Big}" "}"))
                   ((looking-at "\\\\\\(?:big\\)")
                    (cons "\\con{\\big}" "}"))
                   (t
                    (cons "\\con{" "}")))
                (evil-tex--overlay-replace left-over l)
                (evil-tex--overlay-replace right-over r)))
            (delete-overlay left-over) (delete-overlay right-over)))))))

(defun my/replace-dollars-by-bracket ()
  "Reg replace $...$ by \\(...\\)."
  (interactive)
  (my/regreplace-in-buffer
   (rx (and "$" (group (1+ (not "$"))) "$"))
   "\\\\(\\1\\\\)"))




;; help to convert tex to org file
(defun my/tex-ref-to-org-ref-format ()
  (interactive)
  (while (re-search-forward
          (rx "\\" (group (or "ref" "cref" "eqref")) "{"
              (group (1+ (not "}"))) "}") nil t)
    (let* ((ref-type (match-string 1))
           (full-label (match-string 2))
           (short-label (if (> (length full-label) 17)
                            (concat (substring full-label 0 10) "…" (substring full-label -6))
                          full-label)))
      (replace-match (format "[[%s:%s][%s]]" ref-type full-label short-label)))))

(defun my/convert-tex-to-org ()
  "Convert a LaTeX file to an Org-mode file. "
  (interactive)
  (my/regreplace-in-buffer "~" " ") ; Remove ~
  (my/regreplace-in-buffer "%\\(.*\\)$" "") ; Remove comments
  ;; Sections
  (my/regreplace-in-buffer "\\\\section{\\([^}]+\\)}" "* \\1")
  (my/regreplace-in-buffer "\\\\subsection{\\([^}]+\\)}" "** \\1")
  (my/regreplace-in-buffer "\\\\subsubsection{\\([^}]+\\)}" "*** \\1")
  (my/regreplace-in-buffer "\\\\subsubsubsection{\\([^}]+\\)}" "**** \\1")
  (my/regreplace-in-buffer
   (rx "\\label{" (group (and "sec:" (1+ (not "}"))))  "}")
   "\n:PROPERTIES:\n:CUSTOM_ID: \\1\n:END:")
  ;; Itemize and enumerate
  (my/regreplace-in-buffer
   (rx "\\" (or "begin" "end")
       "{" (or "itemize" "enumerate") "}") "")
  (my/regreplace-in-buffer "\\\\item" "- ")
  ;; Bold and italic
                                        ;    (my/regreplace-in-buffer (rx "\\" "textbf{" (group (1+ (not "}"))) "}") "\\1")
  (my/regreplace-in-buffer (rx "\\" "textit{" (group (1+ (not "}"))) "}") "/\\1/")
  (my/regreplace-in-buffer (rx "\\" "emph{" (group (1+ (not "}"))) "}") "/\\1/")
  (my/regreplace-in-buffer (rx  "``" (group (1+ (not "'"))) "''") "\"\\1\"")
  ;; theorem-like env
  ;; (my/regreplace-in-buffer
  ;;  (rx "\\begin{" (group (or "theorem" "example" "lemma" "proposition" "definition" "remark")) "}"
  ;;      (group (* nonl)) )
  ;;  "#+ATTR_LATEX: :options \\2\n#+begin_\\1")
  ;; (my/regreplace-in-buffer
  ;;  (rx "\\end{" (group (or "theorem" "example" "lemma" "proposition" "definition" "remark")) "}")
  ;;  "#+end_\\1")
  ;; proof and thm-like env
  (my/regreplace-in-buffer
   (rx (group (and "\\"
                   (or "begin{" "end{")
                   (or "proof" "theorem" "example" "lemma" "proposition" "definition" "remark")
                   "}"
                   (* nonl))))
   "@@latex:\\1@@ ")
  ;; index
  (my/regreplace-in-buffer
   (rx "\\index{" (group (1+ (not "}"))) "}")
   "[[index:\\1]]")
  ;; citation
  (my/regreplace-in-buffer
   (rx "\\cite"
       (zero-or-one (and "[" (group (1+ (not "]"))) "]"))
       "{" (group (1+ (not "}"))) "}")
   "[cite:@\\2 \\1]")
  ;; equation reference
  (my/tex-ref-to-org-ref-format)
  ;; Clean up multiple empty lines
  (my/regreplace-in-buffer "\n\n\n+" "\n\n")
  (my/regreplace-in-buffer "\.\\\\ " ". "))


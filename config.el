;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; variables that depend on the screen size
(defvar my/font-size 36)
(defvar my/org-latex-preview-scale 1.2)
(defvar my/org-noter-doc-split-fraction '(0.5 . 0.5))
(defvar my/buf-file-name-max 15)
;; UI setting
(defvar my/set-transparent-background nil)
(defvar my/hide-title-bar nil)
(defvar my/is-wm nil) ; whether using a window manager

(defun my/load-file-if-exists (filename)
  "Load the file if it exists, otherwise do nothing."
  (let* ((truename (expand-file-name filename)))
    (if (file-exists-p truename)
        (load-file truename)
      (message "%s does not exists!" filename))))

(setq my/system-variable-file "~/.config/doom/system-variable.el")
(my/load-file-if-exists my/system-variable-file)

(setq my/personal-info-file "~/.config/doom/personal-info.el")
(my/load-file-if-exists my/personal-info-file)

(defun my/pyim-probe-latex-mode ()
  "LaTeX-mode 中的数学环境自动切换到英文输入."
  (and (eq major-mode 'LaTeX-mode)
       (if (fboundp 'texmathp) (texmathp) nil)))

;; 五笔输入法
(use-package! pyim-wbdict
  :after pyim)

(after! pyim
  ;; 使用五笔作为默认输入法
  (require 'pyim-wbdict)
  (setq! default-input-method "pyim"
         pyim-default-scheme 'wubi)
  ;; 使用从 http://gaokuan.ysepan.com/?xzpd=1 上手动下载的五笔词库.
  (pyim-extra-dicts-add-dict
   `(:name "my-wubi-dict" :file
     ,(file-truename (expand-file-name "~/.config/my-wubi-86-dict.pyim"))))
  ;; 将光标前英文字符转为中文的快捷键
  (map! "M-p" #'pyim-convert-string-at-point)
  ;; 去掉了默认列表中的 popup
  (setq! pyim-page-tooltip '(posframe minibuffer))
  (setq-default pyim-punctuation-translate-p '(no); 总是输入半角标点. 半角标点后用 ~M-p~ 可以转化为全角
                pyim-english-input-switch-functions
                '(pyim-probe-auto-english
                  pyim-probe-isearch-mode
                  pyim-probe-program-mode
                  pyim-probe-org-structure-template
                  pyim-probe-org-latex-mode
                  my/pyim-probe-latex-mode) ; LaTeX-mode 的数学模式下只输入英文
                pyim-punctuation-half-width-functions
                '(pyim-probe-punctuation-line-beginning
                  pyim-probe-punctuation-after-punctuation)))

(map! :leader
      :prefix ("I^" . " ^ circumflex")
      :desc  "insert ê" "e" #'(lambda () (interactive) (insert "ê"))
      :desc  "insert ô" "o" #'(lambda () (interactive) (insert "ô"))
      :prefix ("I:" . " ¨ diaeresis")
      :desc  "insert ö" "o" #'(lambda () (interactive) (insert "ö"))
      :prefix ("I`" . " ` grave")
      :desc  "insert è" "e" #'(lambda () (interactive) (insert "è"))
      :desc  "insert à" "a" #'(lambda () (interactive) (insert "à"))
      :prefix ("I'" . " ´ acute")
      :desc  "insert é" "e" #'(lambda () (interactive) (insert "é"))
      :desc  "insert á" "a" #'(lambda () (interactive) (insert "á")))

(setq! system-time-locale "en_US")

(when my/set-transparent-background
  (set-frame-parameter nil 'alpha-background 95)
  (add-to-list 'default-frame-alist '(alpha-background . 95)))

(setq! confirm-kill-emacs nil)

(use-package! super-save
  :custom
  (super-save-auto-save-when-idle t)
  :config
  (super-save-mode +1))

;; Pick any fonts you like
(defvar my/fixed-pitch-font "Jetbrains Mono")
(defvar my/variable-pitch-font "Cascadia Code")
(defvar my/math-font  "Latin Modern Math") ; This is available from TeXlive installation.
(defvar my/chinese-font "AR PL UKai CN") ; 文泉驿楷体

(setq! doom-font
       (font-spec :family my/fixed-pitch-font :size my/font-size)
       doom-variable-pitch-font
       (font-spec :family my/variable-pitch-font))

(use-package! mixed-pitch
  :hook
  ;; enabled in all text mode
  (text-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-fixed-pitch-faces
        '(TeX-folded-face tooltip org-drawer org-font-lock-comment-face org-done org-todo org-todo-keyword-outd org-todo-keyword-kill org-todo-keyword-wait org-todo-keyword-done org-todo-keyword-habt org-todo-keyword-todo org-tag org-ref-cite-face org-property-value org-special-keyword org-footnote org-date solaire-line-number-face diff-added diff-context diff-file-header diff-function diff-header diff-hunk-header diff-removed font-latex-sedate-face font-latex-warning-face font-latex-sectioning-5-face font-lock-builtin-face font-lock-comment-delimiter-face font-lock-constant-face font-lock-doc-face font-lock-function-name-face font-lock-keyword-face font-lock-negation-char-face font-lock-preprocessor-face font-lock-regexp-grouping-backslash font-lock-regexp-grouping-construct font-lock-string-face font-lock-type-face font-lock-variable-name-face line-number line-number-current-line line-number-major-tick line-number-minor-tick markdown-code-face markdown-gfm-checkbox-face markdown-inline-code-face markdown-language-info-face markdown-language-keyword-face message-header-name message-header-to message-header-cc message-header-newsgroups message-header-xheader message-header-subject message-header-other mu4e-header-key-face mu4e-header-value-face mu4e-link-face mu4e-contact-face mu4e-compose-separator-face mu4e-compose-header-face org-block org-block-begin-line org-block-end-line org-document-info-keyword org-code org-indent org-checkbox org-formula org-meta-line org-table org-verbatim)))

(after! unicode-fonts
  (dolist (unicode-block '("CJK Unified Ideographs"
                           "CJK Symbols and Punctuation"
                           "CJK Compatibility"
                           "CJK Unified Ideographs Extension A"
                           "CJK Unified Ideographs Extension B"
                           "Enclosed CJK Letters and Months"
                           "Ideographic Description Characters"
                           "CJK Compatibility Ideographs Supplement"
                           "CJK Radicals Supplement"))
    (push my/chinese-font (cadr (assoc unicode-block unicode-fonts-block-font-mapping)))))

(after! unicode-fonts
  (dolist (unicode-block '("Greek and Coptic"
                           "Greek Extended"
                           "Mathematical Alphanumeric Symbols"
                           "Mathematical Operators"
                           "Miscellaneous Mathematical Symbols-A"
                           "Miscellaneous Mathematical Symbols-B"
                           "Miscellaneous Symbols"
                           "Miscellaneous Symbols and Arrows"
                           "Miscellaneous Symbols and Pictographs"))
    (push my/math-font (cadr (assoc unicode-block unicode-fonts-block-font-mapping)))))

(defun unicode-fonts-setup-h (frame)
   "Run unicode-fonts-setup, then remove the hook."
   (progn
     (select-frame frame)
     (unicode-fonts-setup)
     (message "Removing unicode-fonts-setup to after-make-frame-functions hook")
     (remove-hook 'after-make-frame-functions 'unicode-fonts-setup-h)
     ))

 (add-hook 'after-make-frame-functions 'unicode-fonts-setup-h nil)

(setq doom-theme 'doom-moonlight)

(unless my/is-wm
  (add-to-list 'default-frame-alist '((fullscreen . maximized))))
(if my/hide-title-bar
    (add-to-list 'default-frame-alist '(undecorated . t)))

(scroll-bar-mode 0)

(custom-set-faces!
  '(mode-line :height 0.9)
  '(mode-line-inactive :height 0.9))
(after! nerd-icons
  (setq! nerd-icons-font-family "Symbols Nerd Font"))
(after! doom-modeline
  (setq doom-modeline-workspace-name t
        doom-modeline-persp-name t
        doom-modeline-buffer-file-name-style 'auto
        doom-modeline-mu4e t))

(after! doom-modeline
  (setq! doom-modeline-buffer-file-name-function #'my/truncate-buffer-name))
(defun my/truncate-buffer-name (buf-name)
  (let* ((ext (file-name-extension buf-name))
         (dotext (if ext (concat "." ext) nil))
         (dir (file-name-directory buf-name))
         (filename (file-name-base buf-name))
         (filename-no-timestamp
          (if (> (length filename) my/buf-file-name-max)
              ;; delete prefixed timestamp in org-roam files
              (concat "⋯" (replace-regexp-in-string "^\[0-9\]*-" "" filename))
            filename))
         (trun-filename
          (if (> (length filename-no-timestamp) my/buf-file-name-max)
              (concat (substring filename-no-timestamp 0 my/buf-file-name-max) "⋯")
            filename-no-timestamp)))
    (concat dir trun-filename dotext)))

(use-package! keycast
  :config
  (setq! keycast-header-line-mode t))

(map! "C-M-d" #'scroll-other-window
      "C-M-v" #'scroll-other-window-down)

(setq! evil-want-C-u-delete nil
       evil-want-C-u-scroll nil)

(setq display-line-numbers-type 'visual)

(after! evil
  (setq! evil-move-cursor-back nil
         evil-move-beyond-eol t
         evil-want-fine-undo t))

(add-to-list 'auto-mode-alist '("\\.tex\\'" . LaTeX-mode))

(defun my/set-latex-font ()
  (interactive)
  (require 'font-latex)
  ;; fix the color of math formulas
  (set-face-attribute 'font-latex-math-face nil :foreground "#f78c6c" :font my/math-font :height 1.15) ; 数学符号
  (set-face-attribute 'font-latex-script-char-face nil :foreground "#c792ea") ; 上下标字符^与_
  (set-face-attribute 'font-latex-sedate-face nil :foreground "#ffcb6b") ; 关键字
  ;; adjust the font size for section titles
  (setq! font-latex-fontify-sectioning 1.05)
  ;; use smaller comment face for unimportant keywords in formulas
  ;; adapted from https://endlessparentheses.com/improving-latex-equations-with-font-lock.html
  (defface endless/unimportant-latex-face
    '((t :height 0.8 :weight light
       :inherit font-lock-doc-face))
    "Face used on less relevant math commands.")
  (font-lock-add-keywords
   'LaTeX-mode
   `((,(rx (or "\$"
               (and "\\"
                    (or "\(" "\)" "\[" "\]"
                        (any ",.!;")
                        (and (or "left" "right" "big" "Big" "bigg" "Bigg")
                             symbol-end)))))
      0 'endless/unimportant-latex-face prepend))
   'end))

(after! tex
  (my/set-latex-font))

(defun my/more-prettified-symbols ()
  (require 'tex-mode) ; 载入 tex--prettify-symbols-alist 变量
  (mapc (lambda (pair) (delete pair tex--prettify-symbols-alist))
        '(("\\supset" . 8835)))
  (mapc (lambda (pair) (cl-pushnew pair tex--prettify-symbols-alist))
        '(;; brackets
          ("\\big(" . ?\N{Z notation left image bracket}) ; ⦇, #x2987
          ("\\bigl(" . ?\N{Z notation left image bracket}) ; ⦇, #x2987
          ("\\big)" . ?\N{Z notation right image bracket}) ; ⦈ #x2988
          ("\\bigr)" . ?\N{Z notation right image bracket}) ; ⦈ #x2988
          ("\\Big(" . ?\N{left white parenthesis}); ⦅ #x2985
          ("\\Bigl(" . ?\N{left white parenthesis}); ⦅ #x2985
          ("\\Big)" . ?\N{right white parenthesis}) ; ⦆ #x2986
          ("\\Bigr)" . ?\N{right white parenthesis}) ; ⦆ #x2986
          ("\\bigg(" . ?\N{left double parenthesis}) ; ⸨
          ("\\biggl(" . ?\N{left double parenthesis}) ; ⸨
          ("\\bigg)" . ?\N{right double parenthesis}) ; ⸩
          ("\\biggr)" . ?\N{right double parenthesis}) ; ⸩
          ("\\big[" . ?\N{mathematical left white tortoise shell bracket}) ; ⟬
          ("\\bigl[" . ?\N{mathematical left white tortoise shell bracket}) ; ⟬
          ("\\big]" . ?\N{mathematical right white tortoise shell bracket}) ; ⟭
          ("\\bigr]" . ?\N{mathematical right white tortoise shell bracket}) ; ⟭
          ("\\Big[" . ?\N{mathematical left white square bracket}) ; ⟦ #x27E6
          ("\\Bigl[" . ?\N{mathematical left white square bracket}) ; ⟦ #x27E6
          ("\\Big]" . ?\N{mathematical right white square bracket}) ; ⟧ #x27E7
          ("\\Bigr]" . ?\N{mathematical right white square bracket}) ; ⟧ #x27E7
          ("\\bigg[" . ?\N{left white lenticular bracket}) ; 〖
          ("\\biggl[" . ?\N{left white lenticular bracket}) ; 〖
          ("\\bigg]" . ?\N{right white lenticular bracket}) ; 〗
          ("\\biggr]" . ?\N{right white lenticular bracket}) ; 〗
          ("\\{" . ?\N{medium left curly bracket ornament}) ; ❴
          ("\\}" . ?\N{medium right curly bracket ornament}) ; ❵
          ("\\big\\{" . ?\N{left white curly bracket}) ; ⦃
          ("\\bigl\\{" . ?\N{left white curly bracket}) ; ⦃
          ("\\big\\}" . ?\N{right white curly bracket}) ; ⦄
          ("\\bigr\\}" . ?\N{right white curly bracket}) ; ⦄
          ("\\Big\\{" . ?\N{left arc less-than bracket}) ; ⦓
          ("\\Bigl\\{" . ?\N{left arc less-than bracket}) ; ⦓
          ("\\Big\\}" . ?\N{right arc greater-than bracket}) ; ⦔
          ("\\Bigr\\}" . ?\N{right arc greater-than bracket}) ; ⦔
          ("\\bigg\\{" . ?\N{double left arc greater-than bracket}) ; ⦕
          ("\\biggl\\{" . ?\N{double left arc greater-than bracket}) ; ⦕
          ("\\bigg\\}" . ?\N{double right arc less-than bracket}) ; ⦖
          ("\\biggr\\}" . ?\N{double right arc less-than bracket}) ; ⦖
          ("\\big|" .?\N{left wiggly fence}) ; ⧘
          ("\\bigl|" .?\N{left wiggly fence}) ; ⧘
          ("\\bigr|" .?\N{left wiggly fence}) ; ⧘
          ("\\lvert" .?\N{left wiggly fence}) ; ⧘
          ("\\rvert" .?\N{left wiggly fence}) ; ⧚
          ("\\Big|" .?\N{left double wiggly fence}) ; ⧚
          ("\\Bigl|" .?\N{left double wiggly fence}) ; ⧚
          ("\\Bigr|" .?\N{left double wiggly fence}) ; ⧚
          ("\\lVert" .?\N{DOUBLE VERTICAL LINE}) ; ‖
          ("\\rVert" .?\N{DOUBLE VERTICAL LINE}) ; ‖
          ("\\coloneq" .?\N{colon equal}); ≔
          ("\\eqcolon" .?\N{equal colon}); ≕
          ;; blackboard bold/double-struck
          ("\\Z" . ?\N{double-struck capital Z}) ; ℤ 8484
          ("\\Q" . ?\N{double-struck capital Q}) ; ℚ 8474
          ("\\N" . ?\N{double-struck capital N}) ; ℕ 8469
          ("\\R" . ?\N{double-struck capital R}) ; ℝ 8477
          ("\\PP" . ?\N{double-struck capital P}) ; ℙ #x2119
          ("\\HH" . ?\N{double-struck capital H}) ; ℍ
          ("\\TT" . ?\N{mathematical double-struck capital T}) ;𝕋
          ("\\EE" . ?\N{mathematical double-struck capital E}) ; 𝔼 #x1D53C
          ("\\mathbb{S}" . ?\N{mathematical double-struck capital S}) ; 𝕊 #x1D54A
          ("\\ONE" . ?\N{mathematical double-struck digit ONE}) ; 𝟙 #x1D7D9
          ;; bold face
          ("\\Pp" . ?\N{mathematical bold capital P}) ; 𝐏 #x1D40F
          ("\\Qq" . ?\N{mathematical bold capital Q}) ; 𝐐
          ("\\Ee" . ?\N{mathematical bold capital E}) ; 𝐄 #x1D404
          ("\\bb" . ?\N{mathematical bold small b}) ; 𝐛
          ("\\mm" . ?\N{mathematical bold small m}) ; 𝐦
          ;; calligraphy
          ("\\Fc" . ?\N{script capital F}) ; ℱ #x2131
          ("\\Nc" . ?\N{mathematical script capital N}) ; 𝒩 #x1D4A9
          ("\\Zc" . ?\N{mathematical script capital Z}) ; 𝒵
          ("\\Pc" . ?\N{mathematical script capital P}) ; 𝒫
          ("\\Qc" . ?\N{mathematical script capital Q}) ; 𝒫
          ("\\Gc" . ?\N{mathematical script capital G}) ; 𝒢
          ;; san-serif
          ("\\P" . ?\N{mathematical sans-serif capital P}) ; 𝖯 #x1D5AF
          ("\\E" . ?\N{mathematical sans-serif capital E}) ; 𝖤 #x1D5A4
          ;; others
          ("\\supset" . ?\N{superset of}) ; ⊃
          ("\\temp" . ?\N{mathematical italic kappa symbol}) ; 𝜘, varkappa
          ("\\varnothing" . ?\N{empty set}) ; ∅
          ("\\dotsb" . 8943)
          ("\\dotsc" . 8230)
          ("\\eps" . 949))))

(after! tex
  (my/more-prettified-symbols)
  (add-hook 'LaTeX-mode-hook 'prettify-symbols-mode))

(after! tex
  (remove-hook 'TeX-update-style-hook #'rainbow-delimiters-mode))

(defun my/set-cdlatex-command-alist ()
  (setq cdlatex-command-alist
        '(("Big(" "insert \\Bigl( \\Bigr)" "\\Bigl( ? \\Bigr" cdlatex-position-cursor nil nil t)
          ("Big*" "insert \\con[\\Big]{} macro for Big conditional probability" "\\con[\\Big ]{?}" cdlatex-position-cursor nil nil t)
          ("Big[" "insert \\Bigl[ \\Bigr]" "\\Bigl[ ? \\Bigr" cdlatex-position-cursor nil nil t)
          ("Big\\|" "insert \\Big\\lVert \\Big\\rVert " "\\Big\\lVert ? \\Big\\rVert " cdlatex-position-cursor nil nil t)
          ("Bigg(" "insert \\Biggl( \\Biggr)" "\\Biggl( ? \\Biggr" cdlatex-position-cursor nil nil t)
          ("Bigg*" "insert \\con[\\Bigg]{} macro for Bigg conditional probability" "\\con[\\Bigg ]{?}" cdlatex-position-cursor nil nil t)
          ("Bigg[" "insert \\Biggl[ \\Biggr]" "\\Biggl[ ? \\Biggr" cdlatex-position-cursor nil nil t)
          ("Bigg\\|" "insert \\Bigg\\lvert \\Bigg\\rvert " "\\Bigg\\lvert ? \\Bigg\\rvert " cdlatex-position-cursor nil nil t)
          ("Bigg{" "insert \\Biggl\\{ \\Biggr\\}" "\\Biggl\\{ ? \\Biggr\\" cdlatex-position-cursor nil nil t)
          ("Bigg|" "insert \\Bigg\\lvert \\Bigg\\rvert " "\\Bigg\\lvert ? \\Bigg\\rvert " cdlatex-position-cursor nil nil t)
          ("Big{" "insert \\Bigl\\{ \\Bigr\\}" "\\Bigl\\{ ? \\Bigr\\" cdlatex-position-cursor nil nil t)
          ("Big|" "insert \\Big\\lvert \\Bigr\rvert " "\\Big\\lvert ? \\Big\\rvert " cdlatex-position-cursor nil nil t)
          ("aali" "insert equation" "\\left\\{\n\\begin{aligned}\n? \n\\end{aligned}\\right." cdlatex-position-cursor nil nil t)
          ("alb" "Insert beamer alert block with overlay" "\\begin{alertblock}<+->{ ? } \n\n\\end{alertblock}" cdlatex-position-cursor nil t nil)
          ("alb*" "Insert beamer alert block without overlay" "\\begin{alertblock}{ ? } \n\n\\end{alertblock}" cdlatex-position-cursor nil t nil)
          ("big(" "insert \\bigl( \\bigr)" "\\bigl( ? \\bigr" cdlatex-position-cursor nil nil t)
          ("big*" "insert \\con[\\big]{} macro for big conditional probability" "\\con[\\big ]{?}" cdlatex-position-cursor nil nil t)
          ("big[" "insert \\bigl[ \\bigr]" "\\bigl[ ? \\bigr" cdlatex-position-cursor nil nil t)
          ("big\\|" "insert \\big\\lvert \\big\\rvert " "\\big\\lvert ? \\big\\rvert " cdlatex-position-cursor nil nil t)
          ("bigg(" "insert \\biggl( \\biggr)" "\\biggl( ? \\biggr" cdlatex-position-cursor nil nil t)
          ("bigg*" "insert \\con[\\bigg]{} macro for bigg conditional probability" "\\con[\\bigg ]{?}" cdlatex-positio-cursor nil nil t)
          ("bigg[" "insert \\biggl[ \\biggr]" "\\biggl[ ? \\biggr" cdlatex-position-cursor nil nil t)
          ("bigg\\|" "insert \\bigg\\lvert \\bigg\\rvert " "\\bigg\\lvert ? \\bigg\\rvert " cdlatex-position-cursor nil nil t)
          ("bigg{" "insert \\biggl\\{ \\biggr\\}" "\\biggl\\{ ? \\biggr\\" cdlatex-position-cursor nil nil t)
          ("bigg|" "insert \\bigg\\lvert \\bigg\\rvert " "\\bigg\\lvert ? \\bigg\\rvert " cdlatex-position-cursor nil nil t)
          ("big{" "insert \\bigl\\{ \\bigr\\}" "\\bigl\\{ ? \\bigr\\" cdlatex-position-cursor nil nil t)
          ("big|" "insert \\big\\lvert \\big\\rvert " "\\big\\lvert ? \\big\\rvert " cdlatex-position-cursor nil nil t)
          ("blo" "Insert beamer block with overlay" "\\begin{block}<+->{ ? } \n\n\\end{block}" cdlatex-position-cursor nil t nil)
          ("blo*" "Insert beamer block WITHOUT overlay" "\\begin{block}{ ? } \n\n\\end{block}" cdlatex-position-cursor nil t nil)
          ("bn" "binomial" "\\binom{?}{}" cdlatex-position-cursor nil nil t)
          ("capl" "insert \\bigcap\\limits_{}^{}" "\\bigcap\\limits_{?}^{}" cdlatex-position-cursor nil nil t)
          ("case" "insert cases" "\\begin{cases}\n? & \\\\\n &\n\\end{cases}" cdlatex-position-cursor nil nil t)
          ("cd" "insert dotsb" "\\dotsb" nil nil t t)
          ("cd*" "insert \\con{} macro for conditional probability" "\\con{?}" cdlatex-position-cursor nil nil t)
          ("ce" "insert :=" "\\coloneq " nil nil nil t)
          ("cte" "insert citation using helm-bibtex" "" helm-bibtex-with-local-bibliography nil t nil)
          ("cupl" "insert \\bigcup\\limits_{}^{}" "\\bigcup\\limits_{?}^{}" cdlatex-position-cursor nil nil t)
          ("dd" "insert ddots" "\\ddots" nil nil t t)
          ("def" "insert definition env" "" cdlatex-environment ("definition") t nil)
          ("des" "insert description" "" cdlatex-environment ("description") t nil)
          ("ec" "insert =:" "\\eqcolon " nil nil nil t)
          ("eq" "insert pairs of \\[ \\]" "\\[ ? \\]" cdlatex-position-cursor nil t t)
          ("equ*" "insert unlabel equation" "" cdlatex-environment ("equation*") t nil)
          ("exb" "Insert beamer example block with overlay" "\\begin{exampleblock}<+->{ ? } \n\n\\end{exampleblock}" cdlatex-position-cursor nil t nil)
          ("exb*" "Insert beamer example block without overlay" "\\begin{exampleblock}{ ? } \n\n\\end{exampleblock}" cdlatex-position-cursor nil t nil)
          ("exe" "Insert exercise" "\\begin{exercise}\n? \n\\end{exercise}" cdlatex-position-cursor nil t nil)
          ("fra" "insert frame (for beamer)" "" cdlatex-environment ("frame") t nil)
          ("hhl" "insert \\ \\hline" "\\\\ \\hline" ignore nil t nil)
          ("hl" "insert \\hline" "\\hline" ignore nil t nil)
          ("ipenu" "insert in paragraph enumerate" "" cdlatex-environment ("inparaenum") t nil)
          ("ipite" "insert in paragraph itemize" "" cdlatex-environment ("inparaitem") t nil)
          ("ld" "insert dotsc" "\\dotsc" nil nil t t)
          ("lem" "insert lemma env" "" cdlatex-environment ("lemma") t nil)
          ("liml" "insert \\lim\\limits_{}" "\\lim\\limits_{?}" cdlatex-position-cursor nil nil t)
          ("lr<" "insert bra-ket" "\\langle ? \\rangle" cdlatex-position-cursor nil nil t)
          ("lr|" "insert \\lvert ? \\rvert " "\\lvert ? \\rvert " cdlatex-position-cursor nil nil t)
          ("myenu" "insert in my enumerate for beamer" "" cdlatex-environment ("myenumerate") t nil)
          ("myite" "insert in my itemize for beamer" "" cdlatex-environment ("myitemize") t nil)
          ("no" "insert \\lVert ? \\rVert " "\\lVert ? \\rVert " cdlatex-position-cursor nil nil t)
          ("ons" "" "\\onslide<?>{ }" cdlatex-position-cursor nil t t)
          ("pa" "insert pause" "\\pause" ignore nil t nil)
          ("pro" "insert proof env" "" cdlatex-environment ("proof") t nil)
          ("prodl" "insert \\prod\\limits_{}^{}" " \\prod\\limits_{?}^{}" cdlatex-position-cursor nil nil t)
          ("prop" "insert proposition" "" cdlatex-environment ("proposition") t nil)
          ("se" "insert \\{\\}" "\\{ ? \\}" cdlatex-position-cursor nil nil t)
          ("spl" "insert split" "" cdlatex-environment ("split") nil t)
          ("st" "stackrel" "\\stackrel{?}{}" cdlatex-position-cursor nil nil t)
          ("te" "insert text" "\\text{?}" cdlatex-position-cursor nil nil t)
          ("tf" "tiny fraction" "\\tfrac" nil nil nil t)
          ("thm" "insert theorem env" "" cdlatex-environment ("theorem") t nil)
          ("vd" "insert vdots" "\\vdots" nil nil t t))))

(defun my/set-cdlatex-math-symbol-alist ()
  (setq cdlatex-math-symbol-alist
        '((?0 ("\\varnothing" "\\emptyset"))
          (?1 ("\\ONE" "\\one"))
          (?. ("\\cdot" "\\circ"))
          (?v ("\\vee" "\\bigvee"))
          (?& ("\\wedge" "\\bigwedge"))
          (?9 ("\\cap" "\\bigcap" "\\bigoplus"))
          (?+ ("\\cup" "\\bigcup" "\\oplus"))
          (?- ("\\rightharpoonup" "\\hookrightarrow" "\\circlearrowleft"))
          (?= ("\\equiv" "\\Leftrightarrow" "\\Longleftrightarrow"))
          (?~ ("\\sim" "\\approx" "\\propto"))
          (?L ("\\Lambda" "\\limits"))
          (?* ("\\times" "\\otimes" "\\bigotimes"))
          (?e ("\\eps" "\\epsilon" "\\exp\\Big( ? \\Big)"))
          (?> ("\\mapsto" "\\longrightarrow" "\\rightrightarrows"))
          (?< ("\\preceq" "\\leftarrow" "\\longleftarrow"))
          (?| ("\\parallel" "\\mid" "\\perp"))
          (?S ("\\Sigma" "\\sum_{?}^{}"))
          (?{ ("\\subset" "\\prec" "\\subseteq"))
          (?} ("\\supset" "\\succ" "\\supseteq")))))

(defun my/set-cdlatex-math-modify-alist ()
  (setq cdlatex-math-modify-alist
        '((?k "\\mathfrak" "" t nil nil)
          (?t "\\mathbb" "" t nil nil))))

(defun my/set-cdlatex-env-alist ()
  (setq cdlatex-env-alist
        '(("definition" "\\begin{definition}AUTOLABEL\n\n\\end{definition}" nil)
          ("equation" "\\begin{equation}AUTOLABEL\n?\n\\end{equation}" nil)
          ("equation*" "\\begin{equation*}\n? \n\\end{equation*}" nil)
          ("exercise" "\\begin{exercise}[?]\n\n\\end{exercise}" nil)
          ("frame" "\\begin{frame}{ ? }\n\n\\end{frame}" nil)
          ("inparaenum" "\\begin{inparaenum}\n\\item ? \n\\end{inparaenum}" "\\item ?")
          ("inparaitem" "\\begin{inparaitem}\n\\item ?\n\\end{inparaitem}" "\\item ?")
          ("lemma" "\\begin{lemma}AUTOLABEL\n\n\\end{lemma}" nil)
          ("myenumerate" "\\begin{myenumerate}\n\\item ?\n\\end{myenumerate}" "\\item ?")
          ("myitemize" "\\begin{myitemize}\n\\item ?\n\\end{myitemize}" "\\item ?")
          ("proof" "\\begin{proof}?\n\n\\end{proof}" nil)
          ("proposition" "\\begin{proposition}AUTOLABEL\n\n\\end{proposition}" nil)
          ("theorem" "\\begin{theorem}AUTOLABEL\n\n\\end{theorem}" nil))))

(after! cdlatex
  (my/set-cdlatex-command-alist)
  (my/set-cdlatex-math-symbol-alist)
  (my/set-cdlatex-math-modify-alist)
  (my/set-cdlatex-env-alist))

(defun my/move-backward-after-vert ()
  (interactive)
  (if (looking-back "rvert " 6 nil)
      (backward-char 1)))
(after! cdlatex
  (advice-add #'cdlatex-tab :after #'my/move-backward-after-vert))

(after! cdlatex
  (map! :map cdlatex-mode-map
        :i "<tab>" #'cdlatex-tab))

(defun my/cdlatex-dollar (&optional arg)
  "Insert a pair of dollars unless number of backslashes before point is odd.
With ARG, insert pair of double dollars."
  (interactive "P")
  (let* ((char (preceding-char)))
    (cond
     ((cdlatex-number-of-backslashes-is-odd)
      (insert "$"))
     ((cdlatex--texmathp)
      (defvar texmathp-why)
      (if (and (stringp (car texmathp-why))
               (equal (substring (car texmathp-why) 0 1) "$"))
          (progn
            (insert (car texmathp-why))
            (save-excursion
              (goto-char (cdr texmathp-why))
              (if (pos-visible-in-window-p)
                  (sit-for 1))))
        (message "No dollars inside a math environment!")
        (ding)))
     (t
      (if (char-equal char ?\s) ; if after a space, delete the space and insert ~.
          (progn (delete-char -1) (insert "~"))
        (unless ; scenarios not to insert ~; can add whatever you want here.
            (or (bolp) ; beginning of the line
                (char-equal char ?~) ; a ~ is already there
                (char-equal char ?\() ; inside a bracket
                (char-equal char ?`) ; inside quotation marks
                (char-equal char ?-)) ; after hyphen
          (insert "~")))
      (insert "$$")
      (backward-char 1)))))

(after! tex
  (map! :map LaTeX-mode-map
        :i "$" #'my/cdlatex-dollar))

(setq +latex-viewers '(pdf-tools))

(after! pdf-tools
  ;; enable continuous scrolling when viewing PDFs
  (add-hook! 'pdf-view-mode-hook 'pdf-view-roll-minor-mode)
  (setq! pdf-view-display-size 'fit-width)
  (map! :map pdf-history-minor-mode-map
        :n "C-i" #'evil-collection-pdf-jump-forward)
  ;; keybindings for annotation.
  (map! :map pdf-annot-minor-mode-map
        :n "a a" #'pdf-annot-add-highlight-markup-annotation
        :n "a s" #'pdf-annot-add-squiggly-markup-annotation
        :n "a u" #'pdf-annot-add-underline-markup-annotation
        :n "a d" #'pdf-annot-delete))

(after! reftex
  ;; Under Evil, cannot use "r" to reparse the document in the reftex buffer and the keybinding is hardcoded so it is hard to fix.
  ;; So I reparse the document before invoking reftex-reference.
  (advice-add #'reftex-reference :before #'reftex-parse-all)
  (setq! reftex-label-alist ; 交叉引用的自定义类型
         '((nil ?e nil "\\cref{%s}" nil nil) ; 与 cref 配合使用.
           ("theorem" ?t "thm:" nil t ("Theorem" "定理"))
           ("proposition" ?p "prop:" nil t ("Proposition" "命题"))
           ("definition" ?d "def:" nil t ("Definition" ))
           ("lemma" ?a "lem:" nil t ("Lemma" "引理")))
         reftex-label-menu-flags '(t t nil nil t nil t t)
         reftex-plug-into-AUCTeX t
         reftex-trust-label-prefix t
         reftex-toc-follow-mode t
         reftex-insert-label-flags '("stapd" "stapdf")
         reftex-ref-macro-prompt nil ; ~ref<tab>~ 后不提示类型
         reftex-ref-style-default-list '("Cleveref") ; 默认引用风格
         font-latex-match-reference-keywords '(("cref" "[{"))) ; also fontify \cref macro
  (map! :map reftex-mode-map
        :leader
        "r" #'reftex-parse-all
        "R" #'reftex-change-label))

(defun my/insert-latex-citation (keys)
  (insert (format "\\cite{%s}" keys)))
(after! helm-bibtex
  (helm-add-action-to-source "Insert latex citation command \\cite{}" 'my/insert-latex-citation helm-source-bibtex 0))

(after! tex
  ;; turn on the outline-minor-mode
  (add-hook 'LaTeX-mode-hook 'outline-minor-mode)
  ;; show only the outline (section and subsection titles) upon opening a .tex file
  (add-hook 'LaTeX-mode-hook 'outline-hide-body))

(after! outline
  (map! :map outline-minor-mode-map
        :n "z g" #'outline-hide-body
        :n "z v" #'outline-show-entry))

(after! tex
  (setq! LaTeX-section-list
         '(;;("part" 0) ;; exam class use this
           ("chapter" 1)
           ("section" 2)
           ("subsection" 3)
           ("subsubsection" 4)
           ("paragraph" 5)
           ("subparagraph" 6))))

(use-package! tex-fold
  :hook (TeX-mode . +latex-TeX-fold-buffer-h)
  :hook (TeX-mode . TeX-fold-mode)
  :config
  ;; Reveal folds when moving cursor into them.  This saves us the trouble of
  ;; having to whitelist all motion commands in `TeX-fold-auto-reveal-commands'.
  (setq TeX-fold-auto-reveal t)
  (setq TeX-fold-type-list '(env macro)) ; not folding math which is done by prettified mode
  (setq TeX-fold-env-spec-list
        '(("[Tikz Picture]" ("tikcd" "tikzpicture"))
           (2 ("frame")) ; fold the entire "frame" in beamer;
          ("[comment]" ("comment"))))
  (setq TeX-fold-macro-spec-list
        '(("[cr]" ("cref" "Cref"))
          (1 ("texorpdfstring"))
          ("[f]" ("footnote" "marginpar"))
          ("[l]" ("label"))
          ("[r]" ("ref" "pageref" "eqref" "footref"))
          ("[i]" ("index" "glossary"))
          ("[1]:||*" ("item"))
          ("..." ("dots"))
          ("(C)" ("copyright"))
          ("(R)" ("textregistered"))
          ("TM" ("texttrademark"))
          (1 ("chapter" "section" "subsection" "subsubsection" "paragraph" "subparagraph" "part*" "chapter*" "section*" "subsection*" "subsubsection*" "paragraph*" "subparagraph*" "emph" "textit" "textsl" "textmd" "textrm" "textsf" "texttt" "textbf" "textsc" "textup"))))
  (defun +latex-TeX-fold-buffer-h ()
    (run-with-idle-timer 0 nil 'TeX-fold-buffer))
  ;; Fold after all AUCTeX macro insertions.
  ;; (advice-add #'TeX-insert-macro :after #'+latex-fold-last-macro-a)
  ;; ;; Fold after CDLaTeX macro insertions.
  ;; (advice-add #'reftex-label :after #'+latex-fold-last-macro-a) ; after lbl
  ;; (advice-add #'reftex-citation :after #'+latex-fold-last-macro-a) ; after cte
  ;; (advice-add #'reftex-reference :after #'+latex-fold-last-macro-a) ; after ref
  ;; (advice-add #'reftex-index :after #'+latex-fold-last-macro-a) ; after ind
  ;; (advice-add #'helm-bibtex-with-local-bibliography :after #'+latex-fold-last-macro-a)
  (add-hook! 'mixed-pitch-mode-hook
    (defun +latex-fold-set-variable-pitch-h ()
      "Fix folded things invariably getting fixed pitch when using mixed-pitch.
Math faces should stay fixed by the mixed-pitch blacklist, this is mostly for
\\section etc."
      (when mixed-pitch-mode
        ;; Adding to this list makes mixed-pitch clean the face remaps after us
        (add-to-list 'mixed-pitch-fixed-cookie
                     (face-remap-add-relative
                      'TeX-fold-folded-face
                      :family (face-attribute 'variable-pitch :family)
                      :height (face-attribute 'variable-pitch :height))))))

  (map! :map TeX-fold-mode-map
        :localleader
        :desc "TeX fold dwim" "f f" #'TeX-fold-dwim
        :desc "TeX fold env" "f e" #'TeX-fold-env))

(defun my/evil-tex-incre-delim-size ()
  "Cycle through delimiter sizes from small to large: normal size ->\big->\Big->\bigg->\Bigg."
  (interactive)
  (let* ((case-fold-search nil)
	 (outer (evil-tex-a-delim)) (inner (evil-tex-inner-delim))
	 (left-over (ignore-errors (make-overlay (car outer) (car inner))))
	 (right-over (ignore-errors (make-overlay (cadr inner) (cadr outer)))))
    (when (and left-over right-over outer inner)
      (save-excursion
	(let ((left-str (buffer-substring-no-properties (overlay-start left-over) (overlay-end left-over)))
	      (right-str (buffer-substring-no-properties (overlay-start right-over) (overlay-end right-over))))
	  (goto-char (overlay-start left-over))
	  (cl-destructuring-bind (l . r)
	      (cond ; note: bigg/Bigg must be before big/Big
	       ((looking-at "\\\\\\(?:Bigg\\)") ; cycle to no modifiers
		(cons (replace-regexp-in-string
		       "\\\\\\(?:Biggl\\|Bigg\\)" "" left-str)
		      (replace-regexp-in-string
		       "\\\\\\(?:Biggr\\|Bigg\\)" "" right-str)))
	       ((looking-at "\\\\\\(?:bigg\\)")
		(cons (replace-regexp-in-string
		       "\\\\bigg" "\\\\Bigg" left-str)
		      (replace-regexp-in-string
		       "\\\\bigg" "\\\\Bigg" right-str)))
	       ((looking-at "\\\\\\(?:Big\\)")
		(cons (replace-regexp-in-string
		       "\\\\Big" "\\\\bigg" left-str)
		      (replace-regexp-in-string
		       "\\\\Big" "\\\\bigg" right-str)))
	       ((looking-at "\\\\\\(?:big\\)")
		(cons (replace-regexp-in-string
		       "\\\\big" "\\\\Big" left-str)
		      (replace-regexp-in-string
		       "\\\\big" "\\\\Big" right-str)))
	       (t (cons (concat "\\bigl" left-str)
			(concat "\\bigr" right-str))))
	    (evil-tex--overlay-replace left-over  l)
	    (evil-tex--overlay-replace right-over r)))
	(delete-overlay left-over) (delete-overlay right-over)))))

(defun my/evil-tex-decre-delim-size ()
  "Cycle through delimiter sizes from large to small : \Bigg->\bigg->\Big->\big-> normal size."
  (interactive)
  (let* ((case-fold-search nil)
	 (outer (evil-tex-a-delim)) (inner (evil-tex-inner-delim))
	 (left-over (ignore-errors (make-overlay (car outer) (car inner))))
	 (right-over (ignore-errors (make-overlay (cadr inner) (cadr outer)))))
    (when (and left-over right-over outer inner)
      (save-excursion
	(let ((left-str (buffer-substring-no-properties (overlay-start left-over) (overlay-end left-over)))
	      (right-str (buffer-substring-no-properties (overlay-start right-over) (overlay-end right-over))))
	  (goto-char (overlay-start left-over))
	  (cl-destructuring-bind (l . r)
	      (cond ; note: bigg/Bigg must be before big/Big
	       ((looking-at "\\\\\\(?:Bigg\\)")
		(cons (replace-regexp-in-string
		       "\\\\Bigg" "\\\\bigg" left-str)
		      (replace-regexp-in-string
		       "\\\\Bigg" "\\\\bigg" right-str)))
	       ((looking-at "\\\\\\(?:bigg\\)")
		(cons (replace-regexp-in-string
		       "\\\\bigg" "\\\\Big" left-str)
		      (replace-regexp-in-string
		       "\\\\bigg" "\\\\Big" right-str)))
	       ((looking-at "\\\\\\(?:Big\\)")
		(cons (replace-regexp-in-string
		       "\\\\Big" "\\\\big" left-str)
		      (replace-regexp-in-string
		       "\\\\Big" "\\\\big" right-str)))
	       ((looking-at "\\\\\\(?:big\\)")
		(cons (replace-regexp-in-string
		       "\\\\\\(?:bigl\\|big\\)" "" left-str)
		      (replace-regexp-in-string
		       "\\\\\\(?:bigr\\|big\\)" "" right-str)))
	       (t
		(cons (concat "\\Biggl" left-str)
		      (concat "\\Bigrg" right-str))))
	    (evil-tex--overlay-replace left-over  l)
	    (evil-tex--overlay-replace right-over r)))
	(delete-overlay left-over) (delete-overlay right-over)))))

(defun my/evil-tex-cycle-delim-type ()
  "Cycle through (), [] and {}, while keeping \big, \Big, etc."
  (interactive)
  (let* ((case-fold-search nil)
	 (outer (evil-tex-a-delim)) (inner (evil-tex-inner-delim))
	 (left-over (ignore-errors (make-overlay (car outer) (car inner))))
	 (right-over (ignore-errors (make-overlay (cadr inner) (cadr outer)))))
    (when (and left-over right-over outer inner)
      (save-excursion
	(let ((left-str (buffer-substring-no-properties (overlay-start left-over) (overlay-end left-over)))
	      (right-str (buffer-substring-no-properties (overlay-start right-over) (overlay-end right-over))))
	  (cl-destructuring-bind (l . r)
	      (cond
	       ((string-match "(" left-str)
		(cons (replace-regexp-in-string "(" "[" left-str)
		      (replace-regexp-in-string ")" "]" right-str)))
	       ((string-match "\\[" left-str)
		(cons (replace-regexp-in-string "\\[" "\\\\{" left-str)
		      (replace-regexp-in-string "\\]" "\\\\}" right-str)))
	       ((string-match "\\\\{" left-str)
		(cons (replace-regexp-in-string "\\\\{" "(" left-str)
		      (replace-regexp-in-string "\\\\}" ")" right-str)))
	       (t (cons left-str right-str))) ; do nothing
	    (evil-tex--overlay-replace left-over  l)
	    (evil-tex--overlay-replace right-over r)))
	(delete-overlay left-over) (delete-overlay right-over)))))

(after! evil-tex
  (map! :map evil-tex-toggle-map
        :desc "incre delimi size" "+" #'my/evil-tex-incre-delim-size
        :desc "decre delim size" "-" #'my/evil-tex-decre-delim-size
        :desc "change delim type" "c" #'my/evil-tex-cycle-delim-type))

(use-package! procress
  :commands procress-auctex-mode
  :init
  (add-hook 'LaTeX-mode-hook #'procress-auctex-mode)
  :config
  (procress-load-default-svg-images))

(setq! org-directory "~/repos/notes/") ; same as org-roam repo

(after! cdlatex
  (map! :map org-cdlatex-mode-map
        :i "<tab>" #'cdlatex-tab
        :i "$" #'my/insert-inline-OCDL
        :n "SPC i `" #'my/insert-backquote))
(defun my/insert-inline-OCDL ()
  (interactive)
  ;; insert the pair "\(" "\)" with an extra space in between
  (insert "\\(")
  (save-excursion (insert " \\)" )))
(defun my/insert-backquote ()
  (interactive)
  (insert "`"))

(use-package! org-latex-preview
  :config
  ;; Increase preview width
  (plist-put org-latex-preview-appearance-options :page-width 0.8)
  (plist-put org-latex-preview-appearance-options :zoom my/org-latex-preview-scale)
  ;; preview at startup
  (setq org-startup-with-latex-preview t)
  ;; Use dvisvgm to generate previews
  ;; You don't need this, it's the default:
  (setq org-latex-preview-process-default 'dvisvgm)
  ;; Turn on auto-mode, it's built into Org and much faster/more featured than
  ;; org-fragtog. (Remember to turn off/uninstall org-fragtog.)
  (add-hook 'org-mode-hook 'org-latex-preview-auto-mode)
  ;; Block C-n, C-p etc from opening up previews when using auto-mode
  (setq org-latex-preview-auto-ignored-commands
        '(next-line previous-line mwheel-scroll
          scroll-up-command scroll-down-command))
  ;; Enable consistent equation numbering
  (setq org-latex-preview-numbered t)
  ;; Bonus: Turn on live previews.  This shows you a live preview of a LaTeX
  ;; fragment and updates the preview in real-time as you edit it.
  ;; To preview only environments, set it to '(block edit-special) instead
  (setq org-latex-preview-live t)
  ;; More immediate live-previews -- the default delay is 1 second
  (setq org-latex-preview-live-debounce 0.25))

(defun org-html-format-latex (latex-frag processing-type info)
  "Format a LaTeX fragment LATEX-FRAG into HTML.
PROCESSING-TYPE designates the tool used for conversion.  It can
be `mathjax', `verbatim', `html', nil, t or symbols in
`org-preview-latex-process-alist', e.g., `dvipng', `dvisvgm' or
`imagemagick'.  See `org-html-with-latex' for more information.
INFO is a plist containing export properties."
  (let ((cache-relpath "") (cache-dir ""))
    (unless (or (eq processing-type 'mathjax)
                (eq processing-type 'html))
      (let ((bfn (or (buffer-file-name)
                     (make-temp-name
                      (expand-file-name "latex" temporary-file-directory))))
            (latex-header
             (let ((header (plist-get info :latex-header)))
               (and header
                    (concat (mapconcat
                             (lambda (line) (concat "#+LATEX_HEADER: " line))
                             (org-split-string header "\n")
                             "\n")
                            "\n")))))
        (setq cache-relpath
              (concat (file-name-as-directory org-preview-latex-image-directory)
                      (file-name-sans-extension
                       (file-name-nondirectory bfn)))
              cache-dir (file-name-directory bfn))
        ;; Re-create LaTeX environment from original buffer in
        ;; temporary buffer so that dvipng/imagemagick can properly
        ;; turn the fragment into an image.
        (setq latex-frag (concat latex-header latex-frag))))
    (org-export-with-buffer-copy
     :to-buffer (get-buffer-create " *Org HTML Export LaTeX*")
     :drop-visibility t :drop-narrowing t :drop-contents t
     (erase-buffer)
     (insert latex-frag)
     (org-format-latex cache-relpath nil nil cache-dir nil
                       "Creating LaTeX Image..." nil processing-type)
     (buffer-string))))

;; 在 ~/texmf/tex/latex/ 下的 .sty 文件
(setq org-latex-packages-alist '(("" "mypreamble" t)
                                 ("" "mysymbol" t)))

(map! :map org-mode-map
      :leader
      :prefix ("l" . "LaTeX preview")
      :desc "preview dwim" "k"  #'org-latex-preview
      :desc "preview buffer" "p" #'(lambda () (interactive) (org-latex-preview '(16)))
      :desc "clear buffer preview" "0" #'(lambda () (interactive) (org-latex-preview '(64))))

(defun my/org-tempo-setting ()
  (interactive)
  (require 'org-tempo) ; 保证 org-structure-template-alist 可用
  (setq org-structure-template-alist ; 用 org-tempo 快速插入代码块
        '(("el" . "src elisp")
          ("la" . "src latex")
          ("sh" . "src shell")
          ("a" . "export ascii")
          ("c" . "center")
          ("C" . "comment")
          ("e" . "example")
          ("E" . "export")
          ("h" . "export html")
          ("l" . "export latex")
          ("q" . "quote")
          ("s" . "src")
          ("v" . "verse"))))
(after! org
  (my/org-tempo-setting))

(after! org
  (remove-hook! 'org-mode-local-vars-hook #'+org-init-gifs-h)
  ;; show inline image at startup
  (setq! org-startup-with-inline-images t)
  ;; show only headlines at startup
  (setq! org-startup-folded 'content))

(setq! org-roam-directory "~/repos/notes/")

(after! org-roam
  (setq org-roam-capture-templates
        '(;; ordinary note templat, this will override the "default" template普通模板
          ("d" "default" plain "- tag :: \n %?"
           :target
           (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title} \n#+SETUPFILE: ./latex-preamble.org")
           :unnarrowed t)
          ;; template for seminar notes学术报告模板
          ("s" "Seminar notes" plain "#+FILETAGS: seminar draft\n- title:${title}\n- speaker:\n- event:\n- ref :: \n- tags ::"
           :target
           (file+head "seminar/%<%Y%m%d>-seminar-${slug}.org" "#+title: ${title}\n#+SETUPFILE: ../latex-preamble.org")
           :jump-to-captured t
           :unnarrowed t))))

;; find org-roam notes at startup
(map! :leader
      "m m f" #'org-roam-node-find)
(after! org-roam
  (map! :map org-mode-map
        :localleader
        "m A" #'org-roam-node-random
        "m s" #'org-roam-db-sync)
  (map! :leader "d" #'org-roam-dailies-capture-today))

(after! org-roam
  (map! :map org-mode-map
        :localleader
        :desc "toggle zen mode" "m z" #'my/toggle-org-roam-zen-mode))
(defun my/toggle-org-roam-zen-mode ()
  (interactive)
  (flycheck-mode 'toggle)
  (corfu-mode 'toggle))

(after! org-roam
  (setq!
   ;; show only headings of backlinks
   org-roam-buffer-postrender-functions '(magit-section-show-level-2)
   ;; show unique backlinks
   org-roam-mode-sections '((org-roam-backlinks-section :unique t)
                            org-roam-reflinks-section)))

(defun my/set-ORUI-latex-macros ()
  (setq org-roam-ui-latex-macros
        '(("\\C" . "\\mathbb{C}")
          ("\\Fc" . "\\mathcal{F}")
          ("\\Nc" . "\\mathcal{N}")
          ("\\Ps" . "\\mathsf{P}")
          ("\\Pp" . "\\mathbf{P}")
          ("\\PP" . "\\mathbb{P}")
          ("\\E" . "\\mathsf{E}")
          ("\\Ee" . "\\mathbf{E}")
          ("\\EE" . "\\mathbb{E}")
          ("\\ONE" . "\\mathbf{1}")
          ("\\R" . "\\mathbb{R}")
          ("\\Z" . "\\mathbb{Z}")
          ("\\Q" . "\\mathbb{Q}")
          ("\\N" . "\\mathbb{N}")
          ("\\eps" . "\\varepsilon")
          ("\\det" . "\\mathop{det}"))))

(use-package! websocket
  :after org-roam)
(use-package! org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t)
  (my/set-ORUI-latex-macros))

(after! org-roam
  (map! :map org-mode-map
        :localleader
        "m u" #'org-roam-ui-mode))

(use-package! org-transclusion
  :after org
  :init
  (map!
   :map global-map "<f12>" #'org-transclusion-add
   :leader
   :prefix "n"
   :desc "Org Transclusion Mode" "e" #'org-transclusion-mode))

(after! org-roam
  (add-to-list 'org-roam-capture-templates
               '("r" "bibliography reference" plain ; template for bibliography linked to Zotero文献模板
                 "- tags :: %^{keywords} \n* %^{title}
  :PROPERTIES:\n:Custom_ID: %^{citekey}\n:URL: %^{url}\n:AUTHOR: %^{author-or-editor}\n:NOTER_DOCUMENT: ~/Nutstore/1/Nutstore/Zotero-Library/%^{citekey}.pdf\n:NOTER_PAGE:\n:END:"
                 :target
                 (file+head "ref/${citekey}.org" "#+title: ${title}\n#+FILETAGS: reading research \n#+SETUPFILE: ../latex-preamble.org\n")
                 :unnarrowed t :jump-to-captured t)
               t ))

(setq
 ;; path to the bib file exported from Zotero.  This is how Emacs commutes with Zotero.
 zot_bib "~/Nutstore/1/Nutstore/Zotero-Library/Ref-setting/Main.bib"
 ;; the folder where Zotero stores its linked files.  Org Noter will look for PDF in this folder.
 zot_pdf "~/Nutstore/1/Nutstore/Zotero-Library"
 ;; subfolder under Roam folder to store reference notes
 org_notes "~/repos/notes/ref/")
(unless (file-exists-p zot_bib)
  (message "Zotero bib file does not exist.") (setq zot_bib nil))
(unless (file-exists-p zot_pdf)
  (message "Zotero file folder does not exist.") (setq zot_pdf nil))
(unless (file-exists-p org_notes)
  (message "Ref folder does not exist.") (setq org_ntoes nil))

(use-package! helm-bibtex
  :defer t
  :config
  (setq! bibtex-completion-notes-path org_notes
         bibtex-completion-bibliography zot_bib
         bibtex-completion-library-path zot_pdf
         bibtex-completion-cite-prompt-for-optional-arguments nil))

(use-package! org-roam-bibtex
  :after org-roam
  :config
  (require 'org-ref)
  (add-hook! 'org-roam-mode-hook 'org-roam-bibtex-mode)

  (setq! orb-insert-interface 'helm-bibtex
         orb-insert-link-description 'citekey
         orb-preformat-keywords
         '("citekey" "title" "url" "author-or-editor" "keywords" "file")
         orb-process-file-keyword t
         orb-attached-file-extensions '("pdf")))

(after! org
  (map! :map org-mode-map
        :localleader
        "m k" #'orb-insert-link
        "m a" #'orb-note-actions))

(setq! org-noter-notes-search-path '("~/repos/notes/ref/"))
(after! org-noter
  (setq! org-noter-highlight-selected-text t
         org-noter-doc-split-fraction my/org-noter-doc-split-fraction
         org-noter-use-indirect-buffer nil)
  ;; keybinds to insert notes
  (map! :map org-noter-doc-mode-map
        :leader
        "e e" #'org-noter-insert-precise-note-toggle-no-questions
        "e w" #'org-noter-insert-note-toggle-no-questions
        "e 3" #'org-noter-insert-precise-note
        "e 4" #'org-noter-insert-note))

(after! org-noter
  (setq! org-noter-always-create-frame nil)
  (map! :map org-mode-map
        :localleader
        "m n" #'my/noter-session-new-workspace
        "m N" #'my/open-noter-pdf-at-roam-link))

(defvar noter-ws-name "*noter*")

;; These two functions work when there is ONLY ONE frame.
(defun my/noter-session-new-workspace()
  (interactive)
  (let ((cur-buf (buffer-name)))
    ;; if the workspace exists (assuming there is a single org-noter-sesssion which is in the workspace named NOTER-WS-NAME), kill the org-noter session; otherwise create a workspace named NOTER-WS-NAME
    (require 'org-noter)
    (org-noter-kill-session (car org-noter--sessions))
    (unless (+workspace-exists-p noter-ws-name)
      (+workspace-new noter-ws-name))
    ;; add the current org buffer to the workspace named NOTER-WS-NAME, add the org buffer to it and switch to the org buffer
    (+workspace-switch noter-ws-name)
    (persp-add-buffer cur-buf (get-current-persp) t nil)
    ;; start an org-noter session from the org buffer
    (org-noter)))

(defun my/open-noter-pdf-at-roam-link ()
  (interactive)
  (require 'org-roam-node)
  (require 'org-noter)
  (let* ((context (org-element-context))
         (type (org-element-property :type context))
         (id (org-element-property :path context))
         (f-name (org-roam-node-file (org-roam-node-from-id id))))
    (when (string= type "id")
      (org-noter-kill-session (car org-noter--sessions))
      (unless (+workspace-exists-p noter-ws-name)
        (+workspace-new noter-ws-name))
      (+workspace-switch noter-ws-name)
      (find-file f-name)
      (end-of-buffer)
      (org-noter))))

(after! org
  (setq! org-agenda-files "~/repos/notes/agenda/agenda-files.txt"))

(defvar my/task-inbox-file "~/repos/notes/agenda/refile.org")

(after! org
  (setq! org-todo-keywords
         '((sequence
            "HOLD(h@/@)"  ; This task is stuck, or need new idea.  Capture a note in and out of the state explaining the reason
            "IDEA(i)"  ; An unconfirmed and unapproved task or notion, can turn into TODO
            "TODO(t)"  ; A task that needs doing & is ready to do
            ;;"PROJ(p)"  ; A project, which usually contains other tasks, just TODO with sub TODOs
            "NEXT(n)"  ; A ongoing task
            "|"
            "DONE(d)"  ; Task successfully completed
            "KILL(k@)")) ; Task was cancelled, aborted, or is no longer applicable
         org-todo-keyword-faces
         '(("NEXT" . +org-todo-active)
           ("HOLD" . +org-todo-onhold)
           ("IDEA" . +org-todo-project)
           ("KILL" . +org-todo-cancel))))

(after! org
  (setq! org-priority-start-cycle-with-default nil
         ;; org-agenda 的优先级设为 A-D
         org-priority-lowest ?D
         ;; org-agenda 的默认优先级设为 C
         org-priority-default ?C
         ;; use color to distinguish priority
         org-priority-faces '((?A . error) (?B . warning) (?C . success) (?D . success))))
(after! org-fancy-priorities
  (setq! org-fancy-priorities-list
         '("⚑" "⬆" "■" "☕")))

(after! org
  ;; All tasks will go to the default location
  (setq org-capture-templates
        `(("t" "todo" entry (file ,my/task-inbox-file)
           "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
          ("e" "email" entry (file ,my/task-inbox-file)
           "* NEXT [#B] Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
          ("n" "note" entry (file ,my/task-inbox-file) ; a task to write some note
           "* TODO WRITE NOTE: %? :writing:\n%U\n%a\n" :clock-in t :clock-resume t)
          ("r" "reading" entry (file ,my/task-inbox-file)
           "* TODO Read/Review: %? :read:\n%U\n%a\n" :clock-in t :clock-resume t)
          ("w" "org-protocol" entry (file ,my/task-inbox-file)
           "* TODO Review %c\n%U\n" :immediate-finish t)
          ("i" "idea" entry (file ,my/task-inbox-file)
           "* IDEA [#D] %? :idea: \n%U\n%a\n" :clock-in t :clock-resume t) ; some ideas, fleeting note
          ;; Below are project setting imported from Doom
          ;; Will use {project-root}/{todo,notes,changelog}.org, unless a
          ;; {todo,notes,changelog}.org file is found in a parent directory.
          ;; Uses the basename from `+org-capture-todo-file',
          ;; `+org-capture-changelog-file' and `+org-capture-notes-file'.
          ;; ("p" "Templates for projects")
          ;; ("pt" "Project-local todo" entry  ; {project-root}/todo.org
          ;;  (file+headline +org-capture-project-todo-file "Inbox")
          ;;  "* TODO %?\n%i\n%a" :prepend t)
          ;; ("pn" "Project-local notes" entry  ; {project-root}/notes.org
          ;;  (file+headline +org-capture-project-notes-file "Inbox")
          ;;  "* %U %?\n%i\n%a" :prepend t)
          ;; ("pc" "Project-local changelog" entry  ; {project-root}/changelog.org
          ;;  (file+headline +org-capture-project-changelog-file "Unreleased")
          ;;  "* %U %?\n%i\n%a" :prepend t)
          )))

(map! "<f5>" #'org-agenda)
(after! org
  (setq! org-agenda-span 'week)
  (setq! org-agenda-start-day "-1d")
  (setq! org-agenda-compact-blocks t
         org-agenda-dim-blocked-tasks nil)
  ;; how to show deadlines
  (setq! org-deadline-warning-days 3 ; 3 days is enough to prepare teaching.
         ;; less deadlines
         org-agenda-skip-deadline-if-done t
         org-agenda-skip-scheduled-if-deadline-is-shown t
         org-agenda-skip-timestamp-if-deadline-is-shown t)
  (setq! org-agenda-custom-commands
         `((" " "Agenda"
            (;; deadlines
             (agenda "" nil)
             ;; recently added tasks
             (tags "REFILE"
                   ((org-agenda-overriding-header "Tasks to Refile")
                    (org-tags-match-list-sublevels nil)))
             ;; ongoing tasks
             (tags-todo "-REFILE/!NEXT"
                        ((org-agenda-overriding-header "Next Tasks")
                         (org-agenda-sorting-strategy
                          '(urgency-down priority-down time-up effort-up))))
             ;; all todos
             (tags-todo "-REFILE/!-IDEA-NEXT-HOLD"
                        ((org-agenda-overriding-header "All TODOs")
                         (org-agenda-sorting-strategy
                          '(urgency-down priority-down time-up effort-up))))
             ;; ideas
             (tags-todo "-REFILE/!IDEA"
                        ((org-agenda-overriding-header "Ideas")
                         (org-agenda-sorting-strategy
                          '(urgency-down priority-down time-up effort-up))))
             ;; paused tasks
             (tags-todo "-REFILE/!HOLD"
                        ((org-agenda-overriding-header "Paused Tasks")
                         (org-agenda-sorting-strategy
                          '(urgency-down priority-down time-up effort-up))))
             )))))

(defvar my/org-roam-project-template
  '("p" "project" plain
    "* Tasks\n"
    :target (file+head "%%<%Y%m%d>-${slug}.org"
                       "#+title: ${title}\n#+CATEGORY: %^{short title}\n#+FILETAGS: Project KEEP\n#+SETUPFILE: ../latex-preamble.org\n")
    :jump-to-captured t :unnarrowed t))
(after! org-roam
  (add-to-list 'org-roam-capture-templates my/org-roam-project-template t))
(after! org
  (add-to-list 'org-tags-exclude-from-inheritance "Project"))

(map! :leader
      "m m p" #'my/org-roam-create-project)
(defun my/org-roam-create-project ()
  (interactive)
  (org-roam-capture nil "p")
  (unless org-note-abort
    (with-current-buffer (org-capture-get :buffer)
      (org-agenda-file-to-front))))

;; daily file name日记默认文件名
(defvar my/daily-note-filename "%<%Y-%m-%d>.org")
;; daily file header
(defvar my/daily-note-header
  "#+title: %<%Y-%m-%d %a>\n#+SETUPFILE: ~/repos/notes/latex-preamble.org\n\n[[roam:%<%Y-%B>]]\n\n" )
(after! org-roam-dailies
  ;; default daily folder
  ;;(setq org-roam-dailies-directory "daily/")
  (setq org-roam-dailies-capture-templates
        `(("d" "default" entry "* %?" ; 普通条目
           :target (file+head ,my/daily-note-filename
                              ,my/daily-note-header))
          ("j" "journal" entry "* %<%I:%M %p> - Journal  :journal:\n\n%?\n\n" ; 日志
           :if-new (file+head+olp ,my/daily-note-filename
                                  ,my/daily-note-header
                                  ("Log"))
           :clock-in t :clock-resume t)
          ("m" "meeting" entry "* %<%I:%M %p> - Meeting with %^{whom}  :meetings:\n\n%?\n\n"
           :if-new (file+head+olp ,my/daily-note-filename
                                  ,my/daily-note-header
                                  ("Meeting"))
           :clock-in t :clock-resume t))))

(defun my/org-roam-copy-todo-to-today ()
  (interactive)
  (let ((org-refile-keep (member "KEEP" (org-get-tags)))
        (org-roam-dailies-capture-templates
         `(("t" "tasks" entry "%?"
            :if-new (file+head+olp ,my/daily-note-filename ,my/daily-note-header ("Tasks")))))
        today-file
        pos)
    (save-window-excursion
      (org-clock-report)
      (org-roam-dailies--capture (current-time) t)
      (setq today-file (buffer-file-name))
      (setq pos (point)))
    ;; Only refile if the target file is different than the current file
    (unless (equal (file-truename today-file)
                   (file-truename (buffer-file-name)))
      (org-refile nil nil (list "Tasks" today-file nil pos)))))

(after! org
  (add-to-list 'org-after-todo-state-change-hook ; 将完成的待办事项备份至日记
               (lambda ()
                 (when (or (equal org-state "DONE")
                           (equal org-state "KILL"))
                   (my/org-roam-copy-todo-to-today)))))

(add-hook 'org-after-refile-insert-hook #'save-buffer)

(after! org
  (setq! org-clock-in-switch-to-state #'my/clock-in-to-next))

(defun my/clock-in-to-next (kw)
  "Switch a task from TODO to NEXT when clocking in."
  (when (not (and (boundp 'org-capture-mode) org-capture-mode))
    (cond
     ((member (org-get-todo-state) (list "TODO"))
      "NEXT"))))

(after! org
  (add-hook 'org-clock-in-hook #'save-buffer)
  (add-hook 'org-clock-out-hook #'save-buffer))

(use-package! org-pomodoro
  :config
  ;; time of one pomodoro
  (setq! org-pomodoro-length 40)
  ;; number of pomodoros before a long break
  (setq! org-pomodoro-long-break-frequency 3))

(after! flycheck
  (map! :map flycheck-mode-map
        :n "g ]" #'flycheck-next-error
        :n "g [" #'flycheck-previous-error))

(after! flycheck
  (setq! flycheck-disabled-checkers '(tex-lacheck proselint))
  (setq! flycheck-textlint-config "~/.config/.textlintrc.json"
         flycheck-textlint-plugin-alist
         '((LaTeX-mode . "latex2e")
           (markdown-mode . "@textlint/markdown")
           (gfm-mode . "@textlint/markdown")
           (t . "@textlint/text")))
  ;; for tex file, use textlint after tex-chktex
  (flycheck-add-next-checker 'tex-chktex 'textlint))

(setq my/enchant-personal-dic-en (file-truename "~/.config/enchant/en_US.dic"))
(unless (file-exists-p my/enchant-personal-dic-en)
  (setq my/enchant-personal-dic-en nil))
(setq ispell-personal-dictionary my/enchant-personal-dic-en)
;; a dictionary for completion using company-ispell
(setq my/completion-dic-en (file-truename "~/.config/english-words.txt"))
(if (file-exists-p my/completion-dic-en)
    (setq ispell-alternate-dictionary (file-truename my/completion-dic-en)
          ispell-complete-word-dict (file-truename my/completion-dic-en)))

(use-package! jinx
  :after vertico-multiform
  :hook (emacs-startup . global-jinx-mode)
  ;; remap the jinx-correct key to that of ispell
  :bind ([remap ispell-word] . jinx-correct)
  :config
  ;; show spelling suggestion in multi-column拼写建议使用多列显示
  (add-to-list 'vertico-multiform-categories
               '(jinx grid (vertico-grid-annotate . 20)))
  ;; a hunspell dictionary that allows accent letters.
  (setq jinx-languages "en_US-large")
  ;; 通过正则表达式, 在拼写检查中忽略中文
  (add-to-list 'jinx-exclude-regexps '(t "\\cc"))
  ;; ignore labels and commentsin in spell checking拼写检查中忽略LaTeX 中的 label 和注释
  (add-to-list 'jinx-exclude-faces
               '(latex-mode font-lock-constant-face
                 font-lock-comment-face)))

(after! magit
  ;; location of my git repositories
  (setq! magit-repository-directories
         '(("~/repos/" . 1)
           ("~/.dotfiles/" . 0)
           ("~/.password-store/" . 0)))
  ;; format of repolist buffer
  (setq! magit-repolist-columns
         '(("Name" 25 magit-repolist-column-ident nil)
           ("Version" 25 magit-repolist-column-version ((:sort magit-repolist-version<)))
           ("NUS" 3 magit-repolist-column-flags ((:right-align t) (:sort <)))
           ("B<U" 3 magit-repolist-column-unpulled-from-upstream ((:right-align t) (:sort <)))
           ("B>U" 3 magit-repolist-column-unpushed-to-upstream ((:right-align t) (:sort <)))
           ("Path" 99 magit-repolist-column-path nil))))

(after! ox-hugo
  (setq! org-hugo-use-code-for-kbd t))

(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/mu4e")

(after! mu4e
  (setq mu4e-context-policy 'pick-first
        mu4e-compose-context-policy 'always-ask
        mu4e-update-interval 300
        send-mail-function 'smtpmail-send-it
        mu4e-get-mail-command "mbsync -a"
        mu4e-maildir-shortcuts
        '((:maildir "/sustech/Inbox" :key ?s :name "Sustech")
          (:maildir "/sustech/&UXZO1mWHTvZZOQ-.arxiv" :key ?a :name "Arxiv news")
          (:maildir "/foxmail/Inbox" :key ?f :name "foxmail")))
  ;; load my email account info
  (defvar my/message-signature "Best.\n") ; This is can be adjusted in my/email-account-info-file.
  (setq my/email-account-info-file "~/.config/doom/email-account-info.el")
  (my/load-file-if-exists my/email-account-info-file))

(after! mu4e
  ;; do not put the signature befor forwarded message
  (setq message-forward-before-signature nil)
  ;; do not insert the signature using the built-in function
  (setq message-signature nil)
  ;; use my own function to insert the signature
  (add-hook 'mu4e-compose-mode-hook #'message-insert-signature-at-point))

(defun message-insert-signature-at-point ()
  "Function to insert signature at point."
  (interactive)
  (require 'message)
  (message-goto-body)
  (save-restriction
    (narrow-to-region (point) (point))
    (insert my/message-signature))
  (mu4e-compose-goto-top))

(setq! sh-shell-file "/bin/zsh")
(after! vterm
  (setq! vterm-shell "/bin/zsh"))

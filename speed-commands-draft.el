;;; speed-commands-draft.el -*- lexical-binding: t; -*-

(setq org-use-speed-commands t)

;;; --------- Adaptions to make doom play nice with speed-commands -------------

;; Calling `org-cycle' on the first char of a heading in insert mode will indent
;; instead of cycle... can't have that :(
(after! evil-org
  (remove-hook! 'org-tab-first-hook #'+org-indent-maybe-h))

;; Disable jk-escaping to normal mode when speed keys are active
(add-hook! 'evil-escape-inhibit-functions
  (defun +evil-inhibit-escape-with-org-speed-commands-fn ()
    "Condition from `org-speed-command-activate'"
    (or (and (bolp) (looking-at org-outline-regexp))
        (and (functionp org-use-speed-commands)
             (funcall org-use-speed-commands)))))

;;; -------------------------- The new bindings --------------------------------

(setq org-speed-commands-default

      '(("Outline Navigation")

        ;; NOTE Moved to the bottom
        ;; ("j" . (org-speed-move-safe 'org-next-visible-heading))
        ;; ("k" . (org-speed-move-safe 'org-previous-visible-heading))

        ;; Not sure about the usefulness of these and
        ;; unable to find a good, free binding -> keep default
        ("f" . (org-speed-move-safe 'org-forward-heading-same-level))
        ("b" . (org-speed-move-safe 'org-backward-heading-same-level))

        ;; These are kind of broken (also in vanilla)
        ;; they don't move from block to block -> keep default
        ("F" . org-next-block)
        ("B" . org-previous-block)

        ;; NOTE Moved to the bottom
        ;; ("h" . (org-speed-move-safe 'outline-up-heading))

        ("g" . org-goto)
        ;; This is no refile, but a goto in disguise
        ("G" . (org-refile t))

        ("Outline Visibility")

        ;; NOTE Moved to the bottom
        ;; Was c/C, but c makes more sense for `org-edit-headline'
        ;; l/L is not intuitive but useful for one-handed operation
        ;; ... and one can also use TAB/S-TAB
        ;; (not binding l at all will cause the char to be inserted, which is
        ;; unexpected and breaks speed-key-navigation)
        ;; ("l" . org-cycle)
        ;; ("L" . org-shifttab)

        (" " . org-display-outline-path)
        ("n" . org-toggle-narrow-to-subtree)
        ("d" . org-cut-subtree)

        ;; Default, works for me ergonomically
        ("=" . org-columns)

        ("Outline Structure Editing")

        ;; Default. Not very useful, because we have M-j/k
        ("U" . org-metaup)
        ("D" . org-metadown)

        ("." . org-metaright)
        ("," . org-metaleft)
        (">" . org-shiftmetaright)
        ("<" . org-shiftmetaleft)

        ;; TODO I noticed that inserting headings is problematic. The functions
        ;; mess with whitespace. Henrik mentions that here + a low-level
        ;; workaround: [[file:~/.emacs.d/modules/lang/org/autoload/org.el::(_]]
        ;; -------------------------------------------------------------------
        ;; changed this from "i" to "a",because the new heading gets inserted
        ;; after the current heading
        ("a" . (progn (forward-char 1) (call-interactively
                                        'org-insert-heading-respect-content)))
        ;; Addition: for the expected symmetry
        ;; currently broken - doesn't work on the first heading
        ("i" . (progn (previous-line) (call-interactively
                                       'org-insert-heading-respect-content)))

        ;; Default, because of C-c ^
        ("^" . org-sort)
        ;; Addition: more mnemonic (also in doom)
        ("s" . org-sort)

        ("r" . org-refile)

        ;; doom only, but neat
        ;; Would have to be removed / copied to evil-org
        ("R" . +org/refile-to-last-location)

        ("A" . org-archive-subtree-default-with-confirmation)
        ("@" . org-mark-subtree)
        ("v" . org-mark-subtree)
        ("#" . org-toggle-comment)

        ;; Addition: merge consecutive headings should probably be a function, but
        ;; I'm staying true to the original style here....
        ("J" . (progn (save-excursion
                        (call-interactively #'org-next-visible-heading)
                        (org-toggle-heading))))

        ("Clock Commands")

        ;; Default. At first, I changed these to lowercase, but it's probably
        ;; better if they are harder to hit accidentally
        ("I" . org-clock-in)
        ("O" . org-clock-out)

        ("Meta Data Editing")

        ("t" . org-todo)
        ("p" . (org-priority))
        ("0" . (org-priority ?\ ))
        ("1" . (org-priority ?A))
        ("2" . (org-priority ?B))
        ("3" . (org-priority ?C))

        ;; I'm torn between these. We could keep all of them, especially as
        ;; tagging is probably a pretty common use-case
        ;; (1) because C-c C-q, SPC m q (my favorite)
        ("q" . org-set-tags-command)
        ;; (2) the default, because tags start with a :
        ;; but you need to hold shift for that
        (":" . org-set-tags-command)
        ;; (3) for mnemonics, because we can
        ("T" . org-set-tags-command)

        ("e" . org-set-effort)
        ("E" . org-inc-effort)
        ("W" . (lambda (m) (interactive "sMinutes before warning: ")
                 (org-entry-put (point) "APPT_WARNTIME" m)))
        ("Agenda Views etc")

        ;; Was on "v" (not sure why), which is now `mark-subtree'
        ;; "Home" made some sense to me, but meh...
        ("~" . org-agenda)

        ("/" . org-sparse-tree)

        ("Misc")

        ;; Not entirely sure about the behaviour in different contexts
        ;; seems to open the first link it finds
        ("o" . org-open-at-point)

        ("?" . org-speed-command-help)

        ;; Was </> (now used for indenting)
        ;; Couldn't think of better alternatives
        ("[" . (org-agenda-set-restriction-lock 'subtree))
        ("]" . (org-agenda-remove-restriction-lock))

        ;; Addition: edit headline in the minibuffer, very useful for not having
        ;; to leave the speed-key state
        ("c" . org-edit-headline)

        ;; Addition
        ("u" . undo)
        ;; Addition
        ("z" . evil-scroll-line-to-center)

        ("For non-hjkl evil-org-movement-bindings to not get overwritten,
 these have to be on the bottom... ugly.")

        (,(alist-get 'down evil-org-movement-bindings)
         . (org-speed-move-safe 'org-next-visible-heading))

        (,(alist-get 'up evil-org-movement-bindings)
         . (org-speed-move-safe 'org-previous-visible-heading))
        (,(alist-get 'left evil-org-movement-bindings)

         . (org-speed-move-safe 'outline-up-heading))
        (,(alist-get 'right evil-org-movement-bindings)
         . org-cycle)

        (,(upcase (alist-get 'right evil-org-movement-bindings))
         . org-shifttab)))

;;; funcs.el --- agent-shell layer functions for Spacemacs.  -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2026 Cate B.
;;
;; Author: Cate B. <0x6362@users.noreply.github.com>
;; URL: https://github.com/0x6362/agent-shell-layer
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; Functions for the agent-shell Spacemacs layer.

;;; Code:

(defun agent-shell//current-shell-buffer ()
  "Return the agent-shell shell buffer for the current buffer, or nil.
Handles shell buffers directly and both viewport modes transparently."
  (cond
   ((derived-mode-p 'agent-shell-mode) (current-buffer))
   ((derived-mode-p 'agent-shell-viewport-view-mode
                    'agent-shell-viewport-edit-mode)
    (agent-shell-viewport--shell-buffer))
   (t nil)))

(defun agent-shell//switch-to-buffer ()
  "Switch to an agent-shell buffer using completing-read."
  (interactive)
  (when-let* ((buffers (agent-shell-buffers))
              (names (mapcar #'buffer-name buffers))
              (name (completing-read "Agent shell: " names nil t)))
    (switch-to-buffer name)))

(defun agent-shell/set-project (dir)
  "Start a fresh agent session in DIR, preserving the old session.
An existing ACP session cannot be moved by changing Emacs variables."
  (interactive
   (let* ((shell (agent-shell//current-shell-buffer))
          (current (when shell
                     (with-current-buffer shell (agent-shell-cwd)))))
     (list (read-directory-name "Project directory: "
                                (or current default-directory)
                                nil t))))
  (let ((shell (or (agent-shell//current-shell-buffer)
                   (when-let* ((buffers (agent-shell-buffers)))
                     (get-buffer
                      (completing-read "Agent shell: "
                                       (mapcar #'buffer-name buffers)
                                       nil t))))))
    (unless shell (user-error "No agent-shell buffer found"))
    (agent-shell--new-shell :location (file-name-as-directory (expand-file-name dir))
                           :config (agent-shell-get-config shell))))

(defun brad/agent-shell-render-markdown (&rest options)
  "Render Markdown without automatically downloading remote images."
  (apply #'agent-shell-markdown-replace-markup
         (plist-put options :image-cache-directory nil)))

(defun brad/agent-shell-configure ()
  "Use local ACP adapters and the existing Claude and ChatGPT logins."
  (let ((adapters (expand-file-name "private/agent-shell/local/adapters/node_modules/"
                                    user-emacs-directory))
        (node (or (executable-find "node") (user-error "Node.js is not on Emacs PATH"))))
    (setq agent-shell-anthropic-claude-acp-command
          (list node (expand-file-name "@agentclientprotocol/claude-agent-acp/dist/index.js" adapters))
          agent-shell-openai-codex-acp-command
          (list node (expand-file-name "@agentclientprotocol/codex-acp/dist/index.js" adapters))
          agent-shell-openai-codex-environment
          (list (concat "CODEX_PATH=" (or (executable-find "codex")
                                          (user-error "Codex is not on Emacs PATH"))))))
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t)
        agent-shell-openai-authentication
        (agent-shell-openai-make-authentication :login t)
        agent-shell-agent-configs
        '(agent-shell-anthropic-make-claude-code-config agent-shell-openai-make-codex-config)
        agent-shell-preferred-agent-config #'agent-shell-anthropic-make-claude-code-config
        agent-shell-anthropic-default-session-mode-id "default"
        agent-shell-openai-default-session-mode-id "workspace-write"
        agent-shell-session-strategy 'prompt
        agent-shell-permission-responder-function nil
        ;; Avoid third-party icon downloads and protocol logs containing prompts.
        agent-shell-show-config-icons nil
        agent-shell-markdown-render-function #'brad/agent-shell-render-markdown
        acp-logging-enabled nil)
  (evil-set-initial-state 'agent-shell-mode 'normal)
  (evil-set-initial-state 'agent-shell-viewport-edit-mode 'insert)
  ;; Let one purpose-dedicated window alternate between PDFs and agents.
  (with-eval-after-load 'window-purpose
    (purpose-add-user-purposes
     :modes '((pdf-view-mode . reference)
              (agent-shell-mode . reference)
              (agent-shell-viewport-view-mode . reference)
              (agent-shell-viewport-edit-mode . reference))))
  (define-key agent-shell-layer--global-map (kbd "a") #'agent-shell-anthropic-start-claude-code)
  (define-key agent-shell-layer--global-map (kbd "x") #'agent-shell-openai-start-codex)
  (spacemacs/declare-prefix "aA" "agent-shell")
  (spacemacs/set-leader-keys
    "aAa" #'agent-shell-anthropic-start-claude-code
    "aAx" #'agent-shell-openai-start-codex
    "aAn" #'agent-shell-new-shell
    "aAj" #'agent-shell//switch-to-buffer
    "aAt" #'agent-shell-toggle
    "aAr" #'agent-shell-send-region
    "aAf" #'agent-shell-send-file))

;;; funcs.el ends here

(exec-path-from-shell-copy-envs '("BOXEN_NVM_DIR"
                                  "BOXEN_NVM_DEFAULT_VERSION"))
;; make sure Magit knows where to find the Emacs client
(setq magit-emacsclient-executable "/opt/boxen/homebrew/bin/emacsclient")

#lang scheme/base

(require "utils.ss")
(provide (all-defined-out))

;; This value depends on the server; this seems to work for freenode
(define *my-nick*
  (box (from-env "BOTNICK" "rudybot")))
(define *my-master*
  ;; use authentication by default, but allow to set a regexp for convenience
  (box (let ([master (from-env "BOTMASTER" "")])
         (and (not (equal? master ""))
              (regexp (string-append "^" master "$"))))))

(define *initial-channels* ; env var can be "#foo,#bar"
  (make-parameter (from-env "BOTCHANNELS" '("#scheme" "#emacs" "##SICP") #rx",")))
(define *nickserv-password*
  (make-parameter (from-env "BOTPASSWD" #f)))
(define *bot-gives-up-after-this-many-silent-seconds* (make-parameter 250))
(define *irc-server-hostname* (make-parameter "localhost"))

(define *sandboxes* (make-hash))
(define *max-values-to-display* 5)

(define *start-time*            (current-seconds))
(define *connection-start-time* (make-parameter #f))

;; some state is put globally, to be able to separate functions conveniently
(define *irc-output*      (make-parameter #f))
(define *current-words*   (make-parameter #f))
(define *response-target* (make-parameter #f))
(define *for-whom*        (make-parameter #f))
(define *full-id*         (make-parameter #f))
(define *logger*          (make-parameter #f))

;; Maybe I should use rnrs/enums-6 to guard against typos
(define *authentication-state* (box 'havent-even-tried))

;; Lines much longer than this will cause the server to kick us for
;; flooding.
(define *max-output-line* 500)
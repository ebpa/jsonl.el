;;; jsonl.el --- Utility functions for working with line-delimited JSON  -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Erik Anderson

;; Author: Erik Anderson <erik@ebpa.link>
;; Homepage: https://github.com/ebpa/jsonl.el
;; Keywords: tools
;; Package-Requires: ((emacs "25"))
;; Version: 0.0.1

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

;;  This library contains some utility functions to simplify working
;;  with line-delimited JSON (JSONL).  Sometimes called
;;  "newline-delimited JSON" or "JSON lines", line-delimited JSON is a
;;  format for encoding multiple JSON values within a single file:
;;
;;  > {"foo": "bar"}
;;  > {"baz": "bat"}

;;; Code:

(require 'json)

(defvar jsonl-line-separator "\n"
  "JSON delimiter (generally ``\\n'' or ``\\r\\n'') to use when writing and appending.  Must contain ``\\n'' to remain valid JSONL.  ``\\r\\n'' may be used to cater to Windows systems as whitespace is ignored when reading.")

(defun jsonl-append-value (file value)
  "Append JSON VALUE to FILE.  Encoding is done by `json-encode'."
  (let* ((json-encoding-pretty-print nil))
    (with-temp-buffer
      (when (file-exists-p file)
        (insert jsonl-line-separator))
      (insert (json-encode value))
      (append-to-file (point-min) (point-max) file))))

(defun jsonl-read-from-file (file)
  "Return a list of all JSONL records in FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (jsonl-read-from-string
     (buffer-substring (point-min) (point-max)))))

(defun jsonl-read-from-string (str)
  "Return all JSON values in STR."
  (with-temp-buffer
    (insert str)
    (goto-char (point-min))
    (cl-loop while t
             for json = (condition-case nil
                              (json-read)
                           (error nil))
             until (not json)
             collect json)))

(defun jsonl-read-nth-file-record (file n)
  "Return the Nth JSONL record from FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (cl-loop while t
             for i from 0
             for json = (condition-case nil
                              (json-read)
                           (error 'EOF))
             until (or (eq json 'EOF)
                       (eq i n))
             finally
             return (unless (eq json 'EOF)
                      json))))

(provide 'jsonl)

;;; jsonl.el ends here


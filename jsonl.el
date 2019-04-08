;;; jsonl.el --- Utility functions for working with line-delimited JSON  -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Erik Anderson

;; Author: Erik Anderson <erik@ebpa.link>
;; Keywords: tools

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

;; 

;;; Code:

(require 'json)

(defvar jsonl-line-separator "\n" "JSON delimiter to use (\\n or \\r\\n).")

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
             for json = (condition-case err
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
             for json = (condition-case err
                              (json-read)
                           (error 'EOF))
             until (or (eq json 'EOF)
                       (eq i n))
             finally
             return (unless (eq json 'EOF)
                      json))))

(provide 'jsonl)
;;; jsonl.el ends here

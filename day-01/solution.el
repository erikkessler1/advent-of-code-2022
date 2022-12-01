(defun read-lines (filePath)
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) "\n")))

(setq lines (read-lines "input.txt"))
(setq res (seq-reduce (lambda (groups line)
                        (pcase (list groups line)
                          (`((,all ,current) "")
                           (list (cons current all) '()))
                          (`((,all ,current) ,_)
                           (list all (cons (string-to-number line) current)))))
                      lines
                      '(() ())))

(setq sums (mapcar (lambda (items) (apply '+ items)) (car res)))
(seq-length sums)
; Part 1
(apply 'max sums)

; Part 2
(apply '+ (seq-take (seq-sort '> sums) 3))

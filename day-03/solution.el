(defun read-lines (filePath)
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) "\n")))

(defun sum (list)
  (apply '+ list))

(defun copy-to-end (list end)
  (if (zerop end)
      ()
    (cons (car list) (copy-to-end (cdr list) (- end 1)))))

(defun subseq (list start end)
  (if (zerop start)
      (copy-to-end list end)
    (subseq (cdr list) (- start 1) (- end 1))))

(defun cut-list (list)
  (let
      ((half (/ (length list) 2)))
    (list (subseq list 0 half) (nthcdr half list))))

(defun char-to-priority (char)
  (if (>= char ?a)
      (- char 96)
    (- char 38)))

(setq lines (read-lines "input.txt"))
(setq line-lists
      (remove
       '(nil nil)
       (mapcar
        'cut-list
        (mapcar
         (lambda (line)
           (mapcar 'char-to-priority line))
         lines))))

; Part 1
(sum
 (mapcar
  (lambda (line-list)
    (car (cl-intersection (car line-list) (car (cdr line-list)))))
  line-lists))

; Part 2

; Too much recursion...
(defun group (list size &optional partial groups)
  (let ((partial (or partial ()))
        (groups (or groups ())))
    (if (eq (length partial) size)
        (group list size () (cons partial groups))
      (if list
          (group (cdr list) size (cons (car list) partial) groups)
        (cons partial groups)))))

(defun intersect-group (group)
  (if (>= (length group) 2)
      (intersect-group (cons (cl-intersection (car group) (car (cdr group))) (cdr (cdr group))))
    (car group)))

(let ((i 0)
      (sum 0)
      (ha (remove nil (mapcar (lambda (line) (mapcar 'char-to-priority line)) lines))))
  (dotimes (- (/ (length ha) 3) 1)
    (setq sum (+ sum (car (intersect-group (subseq ha i (+ i 3))))))
    (setq i (+ i 3))
    )
  sum
  )

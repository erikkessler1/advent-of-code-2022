(defun read-lines (filePath)
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) "\n")))

(defun sum (list)
  (apply '+ list))

(setq lines (read-lines "input.txt"))

; Part 1
(sum
 (mapcar
  (lambda (line)
    (pcase line
      ("A X" (+ 1 3))
      ("A Y" (+ 2 6))
      ("A Z" (+ 3 0))
      ("B X" (+ 1 0))
      ("B Y" (+ 2 3))
      ("B Z" (+ 3 6))
      ("C X" (+ 1 6))
      ("C Y" (+ 2 0))
      ("C Z" (+ 3 3))
      (_ 0)))
  lines))

; Part 2
(sum
 (mapcar
  (lambda (line)
    (pcase line
      ("A X" (+ 0 3)) ; R | L => Z
      ("A Y" (+ 3 1)) ; R | T => X
      ("A Z" (+ 6 2)) ; R | W => Y
      ("B X" (+ 0 1)) ; P | L => X
      ("B Y" (+ 3 2)) ; P | T => Y
      ("B Z" (+ 6 3)) ; P | W => Z
      ("C X" (+ 0 2)) ; S | L => Y
      ("C Y" (+ 3 3)) ; S | T => Z
      ("C Z" (+ 6 1)) ; S | W => X
      (_ 0)))
  lines))

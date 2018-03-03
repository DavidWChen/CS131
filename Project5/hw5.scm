#lang racket
;Check if pair, then check if pair elements are equal
(define (null-ld? obj) 
  (if (not (pair? obj)) #f
      (eq? (car obj) (cdr obj))))

;Check null-ld, if not pair, if element not pair,check eq, else tail
(define (ld? obj)
  (cond
    ((null-ld? obj) #t)
    ((not (pair? obj)) #f)
    ((not (pair? (car obj))) #f)
    ((eq? (car obj) (cdr obj)) #t)
    (else (ld? (cons (cdr (car obj)) (cdr obj))))))

;Cons first, then the rest on
(define (cons-ld obj listdiff)
  (cons (cons obj (car listdiff)) (cdr listdiff)))

;if ld, then get first of first of ld
(define (car-ld listdiff)
  (cond
    ((null-ld? listdiff) "error")
    ((ld? listdiff) (car (car listdiff)))
    (else "error")))

;Again, check and get second half of first pair, add it to the rest
(define (cdr-ld listdiff)
  (cond
    ((null-ld? listdiff) "error")
    ((ld? listdiff) (cons (cdr (car listdiff)) (cdr listdiff)))
    (else "error")))

;Just cons it all on
(define (ld obj . arg)
  (cons (cons obj arg) '()))

;Length helper: if 'reach' end, return acc, else keep going
;Check ld, call helper with init length 0
(define (length-ld listdiff)
  (define (length-a listdiff acc)
    (cond
      ((null-ld? listdiff) acc)
      (else (length-a (cdr-ld listdiff) (+ acc 1)))))
  (if (ld? listdiff)
     (length-a listdiff 0) "error"))

;Act depending on args: 0-return, 1 - ->list->append->ld, 2-1, but include arg_list
(define (append-ld listdiff . arg)
  (cond
    ((null? arg) listdiff)
    ((= (length arg) 1)
     (cons (append (ld->list listdiff) (car (car arg))) (cdr (car arg))))
    (else
     (append-ld
      (cons (append (ld->list listdiff) (car (car arg))) (cdr (car arg)))
      (car (cdr arg))))))

(define(ld-tail listdiff k)
  (cond
    ((= k 0) listdiff)
    ((< k 0) "error")
    ((> k (length-ld listdiff)) "error")
    (else (ld-tail (cdr-ld listdiff) (- k 1)))))

(define (list->ld list)
  (cond
    ((not (list? list)) "error")
    (else (cons list null))))

(define (ld->list listdiff)
  (define (ld->list-a listdiff lst)
    (if (eq? (car listdiff) (cdr listdiff)) lst
        (ld->list-a
         (cons (cdr (car listdiff))(cdr listdiff))
         (append lst (list (car (car listdiff)))))))
  (cond
    ((not (ld? listdiff)) "error")
    ((eq? (cdr listdiff) '()) (car listdiff))
    (else (ld->list-a listdiff '()))))

(define (map-ld proc . listdiffs)
  (if (null-ld? (car listdiffs)) '()
         (cons (apply proc (map car-ld listdiffs)) (apply map-ld (cons proc (map cdr-ld listdiffs))))
      ))

(define (expr2ld expr)
(define (replace lst-ele ld-ele expr)
    (if (null? expr) '()
        (if (list? (car expr)) (cons
                                (replace lst-ele ld-ele (car expr))
                                (replace lst-ele ld-ele (cdr expr)))
            (cond
              ((equal? (car expr) 'list)
               (cons 'ld (replace 'list 'ld (cdr expr))))
              ((equal? (car expr) 'null)
               (cons 'null-ld (replace 'null 'null-ld (cdr expr))))
              ((equal? (car expr) 'cons)
               (cons 'cons-ld (replace 'cons 'cons-ld (cdr expr))))
              ((equal? (car expr) 'car)
               (cons 'car-ld (replace 'car 'car-ld (cdr expr))))
              ((equal? (car expr) 'cdr)
               (cons 'cdr-ld (replace 'cdr 'cdr-ld (cdr expr))))
              ((equal? (car expr) 'length)
               (cons 'length-ld (replace 'length 'length-ld (cdr expr))))
              ((equal? (car expr) 'append)
               (cons 'append-ld (replace 'append 'append-ld (cdr expr))))
              ((equal? (car expr) 'list-tail)
               (cons 'ld-tail (replace 'list-tail 'ld-tail (cdr expr))))
              ((equal? (car expr) 'map)
               (cons 'map-ld (replace 'map 'map-ld (cdr expr))))
              (else expr)))))
  (replace 'X 'X expr))


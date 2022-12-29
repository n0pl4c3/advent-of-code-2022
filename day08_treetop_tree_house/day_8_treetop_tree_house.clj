(ns day8-treetop-tree-house.core)

(use 'clojure.java.io)

(defn read-lines [filename]
  (let [rdr (reader filename)]
    (defn read-next-line []
      (if-let [line (.readLine rdr)]
       (cons line (lazy-seq (read-next-line)))
       (.close rdr)))
    (lazy-seq (read-next-line))))

(def read-input (fn [] (read-lines "input.txt")))

(def split-input (fn [] (map #(clojure.string/split % #"") (read-input))))

(defn parse-line [line]
  (map inc (map #(Integer/parseInt %) line)))

(defn parse-line-no-inc [line]
  (map #(Integer/parseInt %) line))

(def parse-input (fn [] (map parse-line (split-input))))

(def parse-input-no-inc (fn [] (map parse-line-no-inc (split-input))))

(def reduce-entry (fn [x y] (if (> x y) x 0)))

(def reduce-line (fn [x y]
                   (map #(reduce-entry % y) x)))

(defn find-visible [collection result]
  (def collection_new (reduce-line collection (first collection)))
  (def result_new (conj result (first collection)))
  
  ;;(println "Collection: " collection)
  ;;(println "Result: " result_new)
  (if (empty? collection_new)
    result
    (find-visible (rest collection_new) result_new)))

(def find-visible-flat
  (fn [x] (flatten (find-visible x []))))

(def visibility-left-to-right
  (fn []  (map find-visible-flat (parse-input))))

(def visibility-top-to-bottom
  (fn [] (apply map vector (map find-visible-flat (apply map vector (parse-input))))))

(def get-columns
  (fn [] (apply map vector (parse-input))))

(def get-columns-inverse
  (fn [] (map reverse (get-columns))))

(def visibility-bottom-to-top
  (fn []  (map find-visible-flat (get-columns-inverse))))

(def invert-columns-inverse
  (fn [] (map reverse (visibility-bottom-to-top))))

(def columns-to-rows
  (fn [] (apply map vector (invert-columns-inverse))))

(def visibility-right-to-left
  (fn [] (map reverse  (map find-visible-flat
                            (map reverse (parse-input))))))

(defn combine-lines [x y akk]
  ;(println "X: " x)
  ;(println "Y: " y)
  ;(println "Akk: " akk)
  (def first_x (first x))
  (def first_y (first y))
  (def finished (not (empty? x)))
  ;(println "Finished: " finished)
  (if finished
     (if (> first_x 0)
       (combine-lines
        (rest x)
        (rest y)
        (conj akk [(first x)]))
       (if (> first_y 0)
         (combine-lines
          (rest x)
          (rest y)
          (conj akk [(first y)]))
         (combine-lines
          (rest x)
          (rest y)
          (conj akk [0]))))
     akk))

(defn combine-lines-wrapper [x y]
  (combine-lines x y []))

(defn solution1 [x res]
  (if (empty? x) res (if (> (first x)  0) (solution1 (rest x) (+ res 1)) (solution1 (rest x) res))))

(defn solution1-wrapper [x res]
  (if (empty? x) res (solution1_wrapper (rest x) (+ res (solution1 (first x) 0)))))

(defn scenic-score-direction [x origin result]
  (if (empty? x)
    result
    (if (>= (first x) origin)
      (+ result 1)
      (scenic-score-direction (rest x) origin (+ result 1)))))

(defn scenic-score-line [x res]
  (if (empty? x)
    res
    (scenic-score-line (rest x) (conj res (scenic-score-direction (rest x) (first x) 0)))))

(defn get-max [x result]
  (if (empty? x)
    result
    (if (> (first x) result)
      (get-max (rest x) (first x))
      (get-max (rest x) result))))

(defn testing []
  (doall (parse-input))
  ;(println "")
  
  (def lines_r (visibility-right-to-left))
  (doall lines_r)
  ;(println lines_r)
  (def lines_l (visibility-left-to-right))
  (doall lines_l)
  ;(println lines_l)
  (def lines_t (visibility-top-to-bottom))
  (doall lines_t)
  ;(println lines_t)
  (def lines_b (columns-to-rows))
  (doall lines_b)

  (def horizontal (map flatten
                      (map combine-lines-wrapper lines_l lines_r)))
  (doall horizontal)
  (def vertical (map flatten
                    (map combine-lines-wrapper lines_t lines_b)))
 (doall vertical)
  (def total    (map flatten
                     (map combine-lines-wrapper horizontal vertical)))

  (println "")
  
  (def solution1 (solution1-wrapper total 0))
  (println "Solution 1: " solution1)

  (println "Part 2 Start")

  (println "")

  (def input_s2 (parse-input-no-inc))

  (def scenic-l-t-r (map #(scenic-score-line % []) input_s2))

  (def scenic-r-t-l (map reverse (map #(scenic-score-line % []) (map reverse input_s2))))

  (def cols (apply map vector input_s2))
  (def scenic-t-t-b (apply map vector (map #(scenic-score-line % []) cols)))

  (def cols_rev (map reverse cols))

  (def scenic-b-t-t (apply map vector (map reverse (map #(scenic-score-line % []) cols_rev))))

  (def scenic-map (map (fn [row1 row2 row3 row4] (map * row1 row2 row3 row4))
                       scenic-l-t-r scenic-r-t-l scenic-t-t-b scenic-b-t-t))

  (println "Solution 2: " (get-max (map #(get-max % 0) scenic-map) 0))
  
  solution1)

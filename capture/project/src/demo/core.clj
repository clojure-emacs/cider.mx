(ns demo.core)

;; Evaluate each form with C-c C-e and the result shows up right here.

(defn greet [who]
  (str "Hello, " who "!"))

(greet "CIDER")

(map greet ["Clojure" "Emacs"])

(frequencies "mississippi")

(->> (range 1 11) (filter even?) (map #(* % %)) (reduce +))

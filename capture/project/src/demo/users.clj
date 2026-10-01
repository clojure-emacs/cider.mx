(ns demo.users)

(def users
  [{:id 1 :name "Ada"   :langs #{:clojure :lisp} :city "London"}
   {:id 2 :name "Rich"  :langs #{:clojure :java} :city "Durham"}
   {:id 3 :name "Grace" :langs #{:cobol}         :city "Arlington"}])

(group-by :city users)

(defn total-price [items]
  (->> items
       (map :price)
       (reduce +)))

(total-price [{:price 10} {:price 32}])

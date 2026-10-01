(ns demo.core-test
  (:require [clojure.test :refer [deftest is testing]]
            [demo.core :refer [greet]]))

(deftest greet-test
  (is (= "Hello, CIDER!" (greet "CIDER"))))

(deftest greet-many-test
  (testing "greeting a few people at once"
    (is (= ["Hello, Clojure!" "Hello, Emacs!"]
           (map greet ["Clojure" "Emacs"])))
    (is (= {:greeted 2 :names ["Ada" "Rich"]}
           {:greeted 3 :names ["Ada" "Rich" "Grace"]}))))

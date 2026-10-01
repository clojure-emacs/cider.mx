(ns demo.art
  (:import (java.awt Color RenderingHints)
           (java.awt.image BufferedImage)))

;; Functions that return images render right in the buffer.

(defn sunburst [size rings]
  (let [img (BufferedImage. size size BufferedImage/TYPE_INT_ARGB)
        g   (.createGraphics img)]
    (.setRenderingHint g RenderingHints/KEY_ANTIALIASING
                       RenderingHints/VALUE_ANTIALIAS_ON)
    (doseq [i (range rings 0 -1)
            :let [r (* i (/ size 2 rings))
                  c (float (/ i rings))]]
      (.setColor g (Color. (float 1) (float (- 1 (* 0.35 c))) (float (* 0.4 (- 1 c)))))
      (.fillOval g (- (/ size 2) r) (- (/ size 2) r) (* 2 r) (* 2 r)))
    (.dispose g)
    img))

(sunburst 120 8)

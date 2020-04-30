(in-package #:shadertoy-pyx)

(pyx:define-asset-pool my-textures ()
  :path "data"
  :filter "png")

(pyx:define-texture text1 ()
  (:source (my-textures splotches)))

(pyx:define-material test ()
  (:shader shader::test
   :uniforms (:mouse (v2:vec)
              :res (pyx:as-uniform 'pyx:get-viewport-dimensions)
              :time (pyx:as-uniform 'pyx:get-running-time)
              :tex 'text1)))

(pyx:define-geometry-layout quad ()
  (:data (:format interleaved)
         (position :type float :count 2)
         (uv :type float :count 2)))

(pyx:define-geometry quad ()
  (:layout quad
   :vertex-count 4
   :primitive :triangle-strip
   :buffers (:data (((-0.5 0.5) (0 1))
                    ((-0.5 -0.5) (0 0))
                    ((0.5 0.5) (1 1))
                    ((0.5 -0.5) (1 0))))))

(pyx:define-texture color ()
  (:pixel-format :rgba
   :internal-format :rgba8
   :generate-mipmap nil))
(pyx:define-framebuffer buffer ()
  (color :buffer (:texture color)
         :point (:color 0)))


(pyx:define-prefab camera (:add (pyx:camera))
  :camera/debug-speed 4
  :transform/translate (v3:vec 0 0 1)
  :camera/mode :orthographic
  :camera/clip-near 0
  :camera/clip-far 16)

(pyx:define-material pass1 (test)
  (:output (buffer (color))
   :pass pass1))
(pyx:define-material pass2 ()
  (:shader shader::blit
   :uniforms (:sampler 'color)
   :pass pass2))

(pyx:define-prefab quad (:add (pyx:geometry pyx:render))
  :geometry/name 'quad)
(pyx:define-prefab render (:template quad)
  :render/materials '(pass1))
(pyx:define-prefab blit (:template quad :add (input-handler))
  :render/materials '(pass2))

(pyx:define-render-pass pass1 ()
  (:framebuffer buffer
   :clear-color (v4:vec 1 0 0 1)))
(pyx:define-render-pass pass2 ()
  (:clear-buffers (:color)))

(pyx:define-scene start ()
  (:passes (pass1 pass2)
   :sub-trees (camera render blit)))



(pyx:define-component input-handler ()
  ())

(pyx:define-entity-hook :update (entity input-handler)
  (when (pyx:on-button-enter :key :escape)
    (pyx:stop-engine)))

(pyx:define-entity-hook :pre-render (entity input-handler)
  (when (pyx:on-button-enabled :mouse :left)
    (let ((res (pyx:get-viewport-dimensions)))
      (multiple-value-bind (x y) (pyx:get-mouse-position)
        (pyx:set-uniforms entity
                          :mouse (v2:/ (v2:vec x y) res))))))

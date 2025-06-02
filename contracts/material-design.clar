;; Material Design Contract
;; This contract manages the development of self-healing materials

(define-data-var admin principal tx-sender)

;; Data structure for material designs
(define-map materials
  { material-id: uint }
  {
    name: (string-ascii 100),
    creator: principal,
    lab-id: uint,
    creation-date: uint,
    healing-mechanism: (string-ascii 100),
    composition: (string-ascii 255),
    status: (string-ascii 20)
  }
)

;; Counter for material IDs
(define-data-var material-id-counter uint u1)

;; Function to register a new material design
(define-public (register-material
    (name (string-ascii 100))
    (lab-id uint)
    (healing-mechanism (string-ascii 100))
    (composition (string-ascii 255)))
  (let ((new-id (var-get material-id-counter)))
    (begin
      (var-set material-id-counter (+ new-id u1))
      (map-set materials
        { material-id: new-id }
        {
          name: name,
          creator: tx-sender,
          lab-id: lab-id,
          creation-date: block-height,
          healing-mechanism: healing-mechanism,
          composition: composition,
          status: "draft"
        }
      )
      (ok new-id)
    )
  )
)

;; Function to update material status
(define-public (update-material-status (material-id uint) (new-status (string-ascii 20)))
  (begin
    (match (map-get? materials { material-id: material-id })
      material-data
        (begin
          (asserts! (or (is-eq tx-sender (get creator material-data)) (is-eq tx-sender (var-get admin))) (err u403))
          (map-set materials
            { material-id: material-id }
            (merge material-data { status: new-status })
          )
          (ok true)
        )
      (err u404)
    )
  )
)

;; Function to update material composition
(define-public (update-material-composition (material-id uint) (new-composition (string-ascii 255)))
  (begin
    (match (map-get? materials { material-id: material-id })
      material-data
        (begin
          (asserts! (is-eq tx-sender (get creator material-data)) (err u403))
          (map-set materials
            { material-id: material-id }
            (merge material-data { composition: new-composition })
          )
          (ok true)
        )
      (err u404)
    )
  )
)

;; Function to get material details
(define-read-only (get-material-details (material-id uint))
  (map-get? materials { material-id: material-id })
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)

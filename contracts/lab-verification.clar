;; Laboratory Verification Contract
;; This contract validates research facilities and their self-healing materials research

(define-data-var admin principal tx-sender)

;; Data structure for registered laboratories
(define-map laboratories
  { lab-id: uint }
  {
    name: (string-ascii 100),
    address: (string-ascii 100),
    verified: bool,
    verification-date: uint,
    specialization: (string-ascii 100)
  }
)

;; Counter for lab IDs
(define-data-var lab-id-counter uint u1)

;; Function to register a new laboratory
(define-public (register-lab (name (string-ascii 100)) (address (string-ascii 100)) (specialization (string-ascii 100)))
  (let ((new-id (var-get lab-id-counter)))
    (begin
      (asserts! (is-eq tx-sender (var-get admin)) (err u403))
      (map-set laboratories
        { lab-id: new-id }
        {
          name: name,
          address: address,
          verified: false,
          verification-date: u0,
          specialization: specialization
        }
      )
      (var-set lab-id-counter (+ new-id u1))
      (ok new-id)
    )
  )
)

;; Function to verify a laboratory
(define-public (verify-lab (lab-id uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (match (map-get? laboratories { lab-id: lab-id })
      lab-data (begin
        (map-set laboratories
          { lab-id: lab-id }
          (merge lab-data { verified: true, verification-date: block-height })
        )
        (ok true)
      )
      (err u404)
    )
  )
)

;; Function to get laboratory details
(define-read-only (get-lab-details (lab-id uint))
  (map-get? laboratories { lab-id: lab-id })
)

;; Function to check if a laboratory is verified
(define-read-only (is-lab-verified (lab-id uint))
  (match (map-get? laboratories { lab-id: lab-id })
    lab-data (ok (get verified lab-data))
    (err u404)
  )
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)

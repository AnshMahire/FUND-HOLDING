;; Simple Escrow Contract
;; Holds STX in escrow until released by the sender to the recipient

;; Data storage
(define-map escrows principal {recipient: principal, amount: uint})

;; Error codes
(define-constant err-invalid-amount (err u100))
(define-constant err-no-funds (err u101))
(define-constant err-not-sender (err u102))

;; Function 1: Deposit funds into escrow
(define-public (deposit-escrow (recipient principal) (amount uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set escrows tx-sender {recipient: recipient, amount: amount})
    (ok true)
  )
)

;; Function 2: Release funds from escrow to recipient
(define-public (release-escrow (sender principal))
  (let ((escrow-data (map-get? escrows sender)))
    (match escrow-data
      escrow
        (begin
          (asserts! (is-eq tx-sender sender) err-not-sender)
          (try! (stx-transfer? (get amount escrow) (as-contract tx-sender) (get recipient escrow)))
          (map-delete escrows sender)
          (ok true)
        )
      err-no-funds
    )
  )
)

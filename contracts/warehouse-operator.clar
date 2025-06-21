;; Warehouse Operator Verification Contract
;; Manages verification and authorization of warehouse operators

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VERIFIED (err u101))
(define-constant ERR_NOT_VERIFIED (err u102))
(define-constant ERR_INVALID_OPERATOR (err u103))

;; Data maps
(define-map verified-operators principal bool)
(define-map operator-details principal {
    name: (string-ascii 50),
    license-number: (string-ascii 20),
    verification-date: uint,
    is-active: bool
})

;; Read-only functions
(define-read-only (is-verified-operator (operator principal))
    (default-to false (map-get? verified-operators operator))
)

(define-read-only (get-operator-details (operator principal))
    (map-get? operator-details operator)
)

;; Public functions
(define-public (verify-operator (operator principal) (name (string-ascii 50)) (license (string-ascii 20)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (not (is-verified-operator operator)) ERR_ALREADY_VERIFIED)
        (map-set verified-operators operator true)
        (map-set operator-details operator {
            name: name,
            license-number: license,
            verification-date: block-height,
            is-active: true
        })
        (ok true)
    )
)

(define-public (revoke-operator (operator principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-verified-operator operator) ERR_NOT_VERIFIED)
        (map-set verified-operators operator false)
        (map-set operator-details operator
            (merge (unwrap-panic (get-operator-details operator)) { is-active: false })
        )
        (ok true)
    )
)

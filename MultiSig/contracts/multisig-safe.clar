(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_APPROVALS (err u101))
(define-constant ERR_ALREADY_APPROVED (err u102))
(define-constant ERR_TRANSACTION_NOT_FOUND (err u103))
(define-constant ERR_INVALID_TRANSFER_AMOUNT (err u104))
(define-constant ERR_OWNER_ALREADY_EXISTS (err u105))
(define-constant ERR_NOT_OWNER (err u106))
(define-constant ERR_CANNOT_EXECUTE (err u107))

(define-data-var wallet-owners (list 10 principal) (list))
(define-data-var required-approvals uint u2)
(define-data-var transaction-records (map uint (tuple (transfer-amount uint) (recipient principal) (approvals (list 10 principal)) (is-executed bool))) (map))
(define-data-var transaction-id-counter uint u0)

;; Helper function to check if a wallet owner is authorized
(define-read-only (is-authorized-owner (user principal))
    (ok (contains? (var-get wallet-owners) user))
)

;; Function to add owners to the wallet
(define-public (add-wallet-owner (new-owner principal))
    (begin
        (asserts! (is-authorized-owner (tx-sender)) ERR_NOT_AUTHORIZED)
        (asserts! (not (contains? (var-get wallet-owners) new-owner)) ERR_OWNER_ALREADY_EXISTS)

        ;; Update the list of owners
        (var-set wallet-owners (append (var-get wallet-owners) (list new-owner)))
        (ok new-owner)
    )
)

;; Function to submit a transaction
(define-public (submit-wallet-transaction (recipient principal) (transfer-amount uint))
    (begin
        (asserts! (is-authorized-owner (tx-sender)) ERR_NOT_AUTHORIZED)
        (asserts! (> transfer-amount u0) ERR_INVALID_TRANSFER_AMOUNT)

        ;; Increment transaction counter and store the new transaction
        (let ((new-tx-id (+ (var-get transaction-id-counter) u1)))
            (map-set transaction-records new-tx-id
                (tuple
                    (transfer-amount transfer-amount)
                    (recipient recipient)
                    (approvals (list))
                    (is-executed false)
                )
            )
            (var-set transaction-id-counter new-tx-id)
            (ok new-tx-id)
        )
    )
)

;; Function to approve a transaction
(define-public (approve-wallet-transaction (tx-id uint))
    (let ((tx (map-get? transaction-records tx-id)))
        (match tx
            tx-none (err ERR_TRANSACTION_NOT_FOUND)
            tx-some (begin
                (asserts! (is-authorized-owner (tx-sender)) ERR_NOT_AUTHORIZED)

                ;; Check if the transaction is already approved by the caller
                (let ((approvals (get approvals tx)))
                    (asserts! (not (contains? approvals (tx-sender))) ERR_ALREADY_APPROVED)

                    ;; Append the approval and update the transaction record
                    (let ((new-approvals (append approvals (list (tx-sender)))))
                        (map-set transaction-records tx-id
                            (tuple
                                (transfer-amount (get transfer-amount tx))
                                (recipient (get recipient tx))
                                (approvals new-approvals)
                                (is-executed (get is-executed tx))
                            )
                        )
                        (ok tx-id)
                    )
                )
            )
        )
    )
)

;; Function to execute a transaction
(define-public (execute-wallet-transaction (tx-id uint))
    (let ((tx (map-get? transaction-records tx-id)))
        (match tx
            tx-none (err ERR_TRANSACTION_NOT_FOUND)
            tx-some (begin
                ;; Ensure the caller is an authorized owner
                (asserts! (is-authorized-owner (tx-sender)) ERR_NOT_AUTHORIZED)

                ;; Ensure the transaction has enough approvals and is not already executed
                (asserts! (>= (len (get approvals tx)) (var-get required-approvals)) ERR_INSUFFICIENT_APPROVALS)
                (asserts! (not (get is-executed tx)) ERR_CANNOT_EXECUTE)

                ;; Execute the transaction
                (let ((transfer-amount (get transfer-amount tx))
                      (recipient (get recipient tx)))
                    (map-set transaction-records tx-id
                        (tuple
                            (transfer-amount transfer-amount)
                            (recipient recipient)
                            (approvals (get approvals tx))
                            (is-executed true)
                        )
                    )
                    (try! (transfer-stx transfer-amount tx-sender recipient))
                    (ok true)
                )
            )
        )
    )
)

;; Function to remove a wallet owner
(define-public (remove-wallet-owner (owner-to-remove principal))
    (begin
        (asserts! (is-authorized-owner (tx-sender)) ERR_NOT_AUTHORIZED)
        (asserts! (contains? (var-get wallet-owners) owner-to-remove) ERR_NOT_OWNER)

        ;; Remove the owner
        (let ((new-owners (filter (lambda (owner) (not (is-eq owner owner-to-remove))) (var-get wallet-owners))))
            (var-set wallet-owners new-owners)
            (ok owner-to-remove)
        )
    )
)

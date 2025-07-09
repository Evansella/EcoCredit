;; EcoCredit - Carbon Credit Trading Platform

;; Constants
(define-constant platform-owner tx-sender)
(define-constant error-access-denied (err u100))
(define-constant error-trader-not-registered (err u101))
(define-constant error-insufficient-credits (err u102))
(define-constant error-invalid-credit-amount (err u103))
(define-constant error-trade-execution-failed (err u104))
(define-constant error-operation-forbidden (err u105))
(define-constant error-invalid-carbon-rate (err u106))
(define-constant error-trader-already-registered (err u107))
(define-constant error-invalid-profile-data (err u108))
(define-constant error-marketplace-suspended (err u109))

;; State Variables
(define-data-var carbon-conversion-rate uint u0)
(define-data-var trading-commission-basis-points uint u150) ;; 1.5% commission, expressed in basis points
(define-data-var marketplace-suspension-status bool false) ;; Emergency suspension functionality

;; Mappings
(define-map carbon-credit-holdings principal uint)
(define-map trader-profiles 
  principal 
  { company-name: (string-ascii 55), 
    carbon-registry-id: (string-ascii 22) })
(define-map rate-validators principal bool)

;; Read-only Queries
(define-read-only (get-carbon-holdings (trader principal))
  (default-to u0 (map-get? carbon-credit-holdings trader)))

(define-read-only (get-trader-profile (trader principal))
  (map-get? trader-profiles trader))

(define-read-only (get-current-carbon-rate)
  (ok (var-get carbon-conversion-rate)))

(define-read-only (is-rate-validator (trader principal))
  (default-to false (map-get? rate-validators trader)))

(define-read-only (is-marketplace-suspended)
  (var-get marketplace-suspension-status))

;; Private Validation Methods
(define-private (validate-company-name (name (string-ascii 55)))
  (and (> (len name) u0) (<= (len name) u55)))

(define-private (validate-registry-id (identifier (string-ascii 22)))
  (and (> (len identifier) u0) (<= (len identifier) u22)))

;; Public Methods
(define-public (register-trader (company-name (string-ascii 55)) (carbon-registry-id (string-ascii 22)))
  (begin
    (asserts! (is-none (get-trader-profile tx-sender)) error-trader-already-registered)
    (asserts! (validate-company-name company-name) error-invalid-profile-data)
    (asserts! (validate-registry-id carbon-registry-id) error-invalid-profile-data)
    (ok (map-set trader-profiles tx-sender {company-name: company-name, carbon-registry-id: carbon-registry-id}))))

(define-public (mint-carbon-credits (amount uint))
  (let ((current-holdings (get-carbon-holdings tx-sender)))
    (asserts! (> amount u0) error-invalid-credit-amount)
    (ok (map-set carbon-credit-holdings tx-sender (+ current-holdings amount)))))

(define-public (transfer-credits (recipient principal) (amount uint))
  (let
    (
      (sender-holdings (get-carbon-holdings tx-sender))
      (commission-amount (/ (* amount (var-get trading-commission-basis-points)) u10000))
      (total-deduction (+ amount commission-amount))
      (current-rate (var-get carbon-conversion-rate))
    )
    (asserts! (not (var-get marketplace-suspension-status)) error-marketplace-suspended)
    (asserts! (is-some (get-trader-profile tx-sender)) error-trader-not-registered)
    (asserts! (is-some (get-trader-profile recipient)) error-trader-not-registered)
    (asserts! (>= sender-holdings total-deduction) error-insufficient-credits)
    (asserts! (> current-rate u0) error-invalid-carbon-rate)
    (try! (stx-transfer? amount tx-sender recipient))
    (try! (stx-transfer? commission-amount tx-sender platform-owner))
    (map-set carbon-credit-holdings tx-sender (- sender-holdings total-deduction))
    (ok (/ (* amount current-rate) u100000000)))) ;; Returns converted amount with assumed 8 decimals

(define-public (retire-credits (amount uint))
  (let ((trader-holdings (get-carbon-holdings tx-sender)))
    (asserts! (>= trader-holdings amount) error-insufficient-credits)
    (try! (as-contract (stx-transfer? amount platform-owner tx-sender)))
    (ok (map-set carbon-credit-holdings tx-sender (- trader-holdings amount)))))

(define-public (update-carbon-rate (new-rate uint))
  (begin
    (asserts! (is-rate-validator tx-sender) error-operation-forbidden)
    (asserts! (> new-rate u0) error-invalid-carbon-rate)
    (ok (var-set carbon-conversion-rate new-rate))))

;; Emergency marketplace suspension
(define-public (set-marketplace-suspension (suspension-status bool))
  (begin
    (asserts! (is-eq tx-sender platform-owner) error-access-denied)
    (ok (var-set marketplace-suspension-status suspension-status))))

;; Administrator Functions
(define-public (update-trading-commission (new-commission-basis-points uint))
  (begin
    (asserts! (is-eq tx-sender platform-owner) error-access-denied)
    (asserts! (<= new-commission-basis-points u10000) error-invalid-credit-amount) ;; Cap at 100%
    (ok (var-set trading-commission-basis-points new-commission-basis-points))))

(define-public (add-rate-validator (trader principal))
  (begin
    (asserts! (is-eq tx-sender platform-owner) error-access-denied)
    (asserts! (is-none (map-get? rate-validators trader)) error-invalid-profile-data)
    (ok (map-set rate-validators trader true))))

(define-public (remove-rate-validator (trader principal))
  (begin
    (asserts! (is-eq tx-sender platform-owner) error-access-denied)
    (asserts! (is-some (map-get? rate-validators trader)) error-invalid-profile-data)
    (ok (map-delete rate-validators trader))))
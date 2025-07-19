;; Housing Allocation Contract
;; Manages temporary and permanent accommodation

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-ALREADY-EXISTS (err u301))
(define-constant ERR-NOT-FOUND (err u302))
(define-constant ERR-INVALID-INPUT (err u303))
(define-constant ERR-HOUSING-UNAVAILABLE (err u304))
(define-constant ERR-INVALID-TRANSITION (err u305))

;; Data Variables
(define-data-var next-housing-id uint u1)
(define-data-var next-allocation-id uint u1)

;; Data Maps
(define-map housing-units
  { housing-id: uint }
  {
    address: (string-ascii 200),
    housing-type: (string-ascii 50),
    capacity: uint,
    current-occupancy: uint,
    amenities: (list 10 (string-ascii 50)),
    accessibility-features: (list 5 (string-ascii 50)),
    monthly-cost: uint,
    status: (string-ascii 20),
    owner-contact: (string-ascii 100),
    registered-at: uint
  }
)

(define-map housing-allocations
  { allocation-id: uint }
  {
    refugee-id: uint,
    housing-id: uint,
    allocation-type: (string-ascii 20),
    start-date: uint,
    end-date: (optional uint),
    monthly-rent: uint,
    status: (string-ascii 20),
    notes: (string-ascii 500),
    created-at: uint,
    updated-at: uint
  }
)

(define-map housing-owners
  { principal: principal }
  { verified: bool }
)

;; Public Functions

;; Register a housing unit
(define-public (register-housing
  (address (string-ascii 200))
  (housing-type (string-ascii 50))
  (capacity uint)
  (amenities (list 10 (string-ascii 50)))
  (accessibility-features (list 5 (string-ascii 50)))
  (monthly-cost uint)
  (owner-contact (string-ascii 100)))
  (let
    (
      (housing-id (var-get next-housing-id))
    )
    (asserts! (> capacity u0) ERR-INVALID-INPUT)
    (asserts! (>= monthly-cost u0) ERR-INVALID-INPUT)

    (map-set housing-units
      { housing-id: housing-id }
      {
        address: address,
        housing-type: housing-type,
        capacity: capacity,
        current-occupancy: u0,
        amenities: amenities,
        accessibility-features: accessibility-features,
        monthly-cost: monthly-cost,
        status: "available",
        owner-contact: owner-contact,
        registered-at: block-height
      }
    )

    (var-set next-housing-id (+ housing-id u1))
    (ok housing-id)
  )
)

;; Allocate housing to refugee
(define-public (allocate-housing
  (refugee-id uint)
  (housing-id uint)
  (allocation-type (string-ascii 20))
  (duration-months uint)
  (notes (string-ascii 500)))
  (let
    (
      (allocation-id (var-get next-allocation-id))
      (housing-data (unwrap! (map-get? housing-units { housing-id: housing-id }) ERR-NOT-FOUND))
      (end-date (if (> duration-months u0) (some (+ block-height (* duration-months u4320))) none))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (< (get current-occupancy housing-data) (get capacity housing-data)) ERR-HOUSING-UNAVAILABLE)
    (asserts! (is-eq (get status housing-data) "available") ERR-HOUSING-UNAVAILABLE)

    (map-set housing-allocations
      { allocation-id: allocation-id }
      {
        refugee-id: refugee-id,
        housing-id: housing-id,
        allocation-type: allocation-type,
        start-date: block-height,
        end-date: end-date,
        monthly-rent: (get monthly-cost housing-data),
        status: "active",
        notes: notes,
        created-at: block-height,
        updated-at: block-height
      }
    )

    (map-set housing-units
      { housing-id: housing-id }
      (merge housing-data {
        current-occupancy: (+ (get current-occupancy housing-data) u1),
        status: (if (>= (+ (get current-occupancy housing-data) u1) (get capacity housing-data)) "occupied" "available")
      })
    )

    (var-set next-allocation-id (+ allocation-id u1))
    (ok allocation-id)
  )
)

;; Update allocation status
(define-public (update-allocation-status (allocation-id uint) (new-status (string-ascii 20)))
  (let
    (
      (allocation-data (unwrap! (map-get? housing-allocations { allocation-id: allocation-id }) ERR-NOT-FOUND))
      (housing-data (unwrap! (map-get? housing-units { housing-id: (get housing-id allocation-data) }) ERR-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    ;; If ending allocation, update housing occupancy
    (if (is-eq new-status "ended")
      (map-set housing-units
        { housing-id: (get housing-id allocation-data) }
        (merge housing-data {
          current-occupancy: (- (get current-occupancy housing-data) u1),
          status: "available"
        })
      )
      true
    )

    (map-set housing-allocations
      { allocation-id: allocation-id }
      (merge allocation-data {
        status: new-status,
        updated-at: block-height
      })
    )
    (ok true)
  )
)

;; Transfer to permanent housing
(define-public (transfer-to-permanent
  (current-allocation-id uint)
  (new-housing-id uint)
  (notes (string-ascii 500)))
  (let
    (
      (current-allocation (unwrap! (map-get? housing-allocations { allocation-id: current-allocation-id }) ERR-NOT-FOUND))
      (new-housing (unwrap! (map-get? housing-units { housing-id: new-housing-id }) ERR-NOT-FOUND))
      (new-allocation-id (var-get next-allocation-id))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get allocation-type current-allocation) "temporary") ERR-INVALID-TRANSITION)
    (asserts! (< (get current-occupancy new-housing) (get capacity new-housing)) ERR-HOUSING-UNAVAILABLE)

    ;; End current allocation
    (try! (update-allocation-status current-allocation-id "ended"))

    ;; Create new permanent allocation
    (try! (allocate-housing
      (get refugee-id current-allocation)
      new-housing-id
      "permanent"
      u0
      notes))

    (ok new-allocation-id)
  )
)

;; Update housing status
(define-public (update-housing-status (housing-id uint) (new-status (string-ascii 20)))
  (let
    (
      (housing-data (unwrap! (map-get? housing-units { housing-id: housing-id }) ERR-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set housing-units
      { housing-id: housing-id }
      (merge housing-data { status: new-status })
    )
    (ok true)
  )
)

;; Verify housing owner
(define-public (verify-housing-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set housing-owners { principal: owner } { verified: true })
    (ok true)
  )
)

;; Read-only functions

(define-read-only (get-housing-unit (housing-id uint))
  (map-get? housing-units { housing-id: housing-id })
)

(define-read-only (get-allocation (allocation-id uint))
  (map-get? housing-allocations { allocation-id: allocation-id })
)

(define-read-only (is-owner-verified (owner principal))
  (default-to false (get verified (map-get? housing-owners { principal: owner })))
)

(define-read-only (get-housing-availability (housing-id uint))
  (match (map-get? housing-units { housing-id: housing-id })
    housing-data (some {
      available-capacity: (- (get capacity housing-data) (get current-occupancy housing-data)),
      status: (get status housing-data)
    })
    none
  )
)

(define-read-only (get-next-ids)
  {
    housing-id: (var-get next-housing-id),
    allocation-id: (var-get next-allocation-id)
  }
)

### EcoCredit - Carbon Credit Trading Platform

A decentralized carbon credit trading platform built on the Stacks blockchain using Clarity smart contracts. EcoCredit enables companies to register as traders, mint carbon credits, transfer them between parties, and retire credits for carbon offset purposes.

## Overview

EcoCredit facilitates transparent and efficient carbon credit trading by providing:

- Trader registration with company verification
- Carbon credit minting and management
- Peer-to-peer credit transfers with automated commission
- Credit retirement for carbon offsetting
- Dynamic carbon rate conversion
- Emergency marketplace controls


## Key Features

### Trader Management

- **Registration**: Companies can register with company name and carbon registry ID
- **Profile Validation**: Automatic validation of company names (1-55 characters) and registry IDs (1-22 characters)
- **Unique Registration**: Prevents duplicate registrations


### Carbon Credit Operations

- **Minting**: Registered traders can mint new carbon credits
- **Transfer**: Secure peer-to-peer credit transfers with automatic commission deduction
- **Retirement**: Permanent removal of credits from circulation for offsetting
- **Balance Tracking**: Real-time tracking of credit holdings per trader


### Rate Management

- **Dynamic Pricing**: Configurable carbon conversion rates
- **Validator System**: Authorized validators can update conversion rates
- **Rate Protection**: Prevents invalid or zero rates


### Platform Controls

- **Commission System**: Configurable trading commission (default: 1.5%)
- **Emergency Suspension**: Platform owner can suspend marketplace operations
- **Access Control**: Role-based permissions for critical operations


## Contract Structure

### Constants

```plaintext
platform-owner          // Contract deployer address
error-codes             // Comprehensive error handling (300-309)
```

### State Variables

```plaintext
carbon-conversion-rate           // Current carbon credit conversion rate
trading-commission-basis-points  // Commission rate (150 = 1.5%)
marketplace-suspension-status    // Emergency suspension flag
```

### Data Maps

```plaintext
carbon-credit-holdings  // principal -> uint (credit balances)
trader-profiles        // principal -> {company-name, carbon-registry-id}
rate-validators        // principal -> bool (validator permissions)
```

## Usage Guide

### 1. Trader Registration

```plaintext
(contract-call? .ecocredit register-trader "Green Energy Corp" "GEC-2024-001")
```

### 2. Mint Carbon Credits

```plaintext
(contract-call? .ecocredit mint-carbon-credits u1000)
```

### 3. Transfer Credits

```plaintext
(contract-call? .ecocredit transfer-credits 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 u500)
```

### 4. Retire Credits

```plaintext
(contract-call? .ecocredit retire-credits u250)
```

### 5. Query Functions

```plaintext
;; Check credit balance
(contract-call? .ecocredit get-carbon-holdings 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)

;; Get trader profile
(contract-call? .ecocredit get-trader-profile 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)

;; Check current carbon rate
(contract-call? .ecocredit get-current-carbon-rate)
```

## ️ Error Codes

| Code | Error | Description
|-----|-----|-----
| 100 | `error-access-denied` | Unauthorized access to admin functions
| 101 | `error-trader-not-registered` | Trader must be registered to perform action
| 102 | `error-insufficient-credits` | Not enough credits for transaction
| 103 | `error-invalid-credit-amount` | Invalid credit amount (must be > 0)
| 104 | `error-trade-execution-failed` | Transaction execution failed
| 105 | `error-operation-forbidden` | Operation not allowed for user role
| 106 | `error-invalid-carbon-rate` | Invalid conversion rate
| 107 | `error-trader-already-registered` | Trader already has a profile
| 108 | `error-invalid-profile-data` | Invalid profile information
| 109 | `error-marketplace-suspended` | Marketplace is currently suspended

## Security Features

### Access Control

- **Platform Owner**: Full administrative control
- **Rate Validators**: Can update carbon conversion rates
- **Registered Traders**: Can trade and manage credits
- **Public**: Read-only access to public data

### Validation

- Input validation for all user data
- Balance verification before transfers
- Registration status checks
- Rate validation for conversions

### Emergency Controls

- Marketplace suspension capability
- Commission rate limits (max 100%)
- Validator management system

## ️ Deployment

### Prerequisites

- Stacks blockchain testnet/mainnet access
- Clarity CLI or compatible deployment tool
- STX tokens for deployment fees

### Deployment Steps

1. **Compile Contract**

```shellscript
clarity-cli check ecocredit.clar
```

2. **Deploy to Testnet**

```shellscript
stx deploy_contract ecocredit ecocredit.clar --testnet
```

3. **Initialize Platform**

1. Set initial carbon conversion rate
2. Add rate validators
3. Configure commission rates

### Post-Deployment Configuration

```plaintext
;; Set initial carbon rate (example: $50 per credit)
(contract-call? .ecocredit update-carbon-rate u5000000000)

;; Add rate validators
(contract-call? .ecocredit add-rate-validator 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)

;; Adjust commission if needed (example: 2%)
(contract-call? .ecocredit update-trading-commission u200)
```

## Commission Structure

The platform uses a basis points system for commission calculation:

- **Default Commission**: 150 basis points (1.5%)
- **Calculation**: `commission = (amount × commission_basis_points) ÷ 10,000`
- **Maximum Commission**: 10,000 basis points (100%)


## Rate Conversion

Carbon credits are converted using the current rate:

- **Rate Storage**: 8-decimal precision
- **Conversion Formula**: `converted_amount = (amount × rate) ÷ 100,000,000`
- **Rate Updates**: Only authorized validators can modify rates


## ️ Best Practices

### For Traders

1. Verify trader registration before attempting trades
2. Check credit balance before initiating transfers
3. Understand commission deductions in transfers
4. Keep registry IDs accurate and up-to-date


### For Platform Operators

1. Regularly monitor and update carbon conversion rates
2. Maintain a diverse set of rate validators
3. Use emergency suspension judiciously
4. Monitor commission rates for market competitiveness


### For Developers

1. Always handle error responses appropriately
2. Validate user inputs before contract calls
3. Implement proper balance checks in UI
4. Cache read-only data to reduce blockchain calls


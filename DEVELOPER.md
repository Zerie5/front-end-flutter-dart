# LulPay - Mobile Financial Platform Front End Mobile App



![LulPay Logo](assets/logos/logo1.png)

## Overview

LulPay is a secure, feature-rich mobile financial platform built with Flutter that enables seamless money transfers, payments, and financial management. The application provides both traditional wallet-based transfers and innovative non-wallet remittance solutions to serve diverse financial needs. **LulPay features complete Stellar blockchain integration for real-time cryptocurrency transactions and wallet management.**

## Key Features

### Secure Authentication
- **Multi-step Registration:** Email validation, phone verification, OTP authentication, PIN creation
- **JWT Authentication:** Secure token-based authentication with device fingerprinting
- **Session Management:** Device tracking and multi-device login support with automatic lockout
- **Security Validation:** Duplicate email/phone checking, password strength validation
- **OTP System:** SMS-based verification with retry limits and expiration
- **PIN-protected transactions and app access**
- **Biometric authentication options for enhanced security**

### Wallet Management
- **Multi-currency wallet support with real-time balance display**
- **Real Stellar Integration:** Creates actual Stellar testnet accounts with KeyPair generation
- **Encrypted Key Storage:** AES encryption for private key security
- **Auto-Funding System:** New wallets automatically funded with 10000 XLM via Friendbot
- **Multi-Currency Support:** USD/EURO (blockchain), UGX/KES/ETB/SSP (backend)
- **Balance Synchronization:** Real-time balance updates from Stellar network and sync with database
- **One-click currency switching between different available currencies**
- **Currency conversion with competitive rates**
- **Comprehensive transaction details and receipt generation**

### Payment Solutions
- **Multiple Payment Methods:** Credit/Debit Cards, Bank Transfers
- **Dynamic Fee Structure:** Based on admin changed ratings stored on the database Fee Config table
- **Unified Payment Interface:** Single endpoint routes payments based on currency type
- **Transaction Audit Trail:** Complete payment history with processor responses
- **Production-Ready Architecture:** Mock implementation with real processor integration points
- **Wallet-to-wallet transfers with instant confirmation**
- **QR code-based payments for contactless transactions**
- **Contact-based payments with recipient search functionality**
- **Non-wallet remittance for people with no app**
- **Transaction confirmation screens with detailed fee breakdowns**

### Stellar Blockchain Integration
- **Real Stellar SDK Integration:** Uses official Stellar SDK for all blockchain operations
- **Transaction Creation:** Real payment operations with proper asset specification
- **Transaction Signing:** Actual cryptographic signing with decrypted private keys
- **Network Submission:** Real transaction submission to Stellar testnet via horizon API
- **Balance Verification:** Real balance checks from Stellar network before transactions
- **P2P Blockchain Transfers:** Real Stellar payment operations between user wallets
- **Memo System:** "Lulpay-Payment Tranx" for transfers, "Lulpay-Deposit Tranx" for deposits
- **Transaction Validation:** Balance verification, PIN authentication, limit checking
- **Fee Management:** Stellar base fee (0.00001 XLM) automatically included
- **Real-time Updates:** Database synchronization after blockchain confirmation
- **Transaction History:** Complete audit trail with blockchain transaction hashes

### Non-Wallet Remittance
- **Register and track payments for remittance to people with no wallet**
- **Dynamic fee calculation based on transaction amount and type**
- **Transaction ID tracking for external payments**
- **Delayed transaction support for post-payment verification**
- **Recipient information collection with validation**
- **Multiple currency support for non-wallet transactions**
- **Customizable transaction descriptions**
- **Support for different type of Refugee documents**

### User Profile Management
- **View and edit personal information**
- **Update profile picture and contact details**
- **View account verification status**
- **Manage notification preferences**
- **Account activity dashboard and statistics**

### Multi-Currency Features
- **Support for multiple currencies with real-time balances**
- **Currency-specific transaction history**
- **Seamless switching between currencies for sending/receiving funds**
- **Currency-specific transaction limits and fee structures**
- **Currency preference settings for default transactions**

### Contact Management
- **Add and manage payment recipients**
- **QR code scanning to add contacts**
- **Recent and favorite contacts for quick access**
- **Contact search with filtering options**
- **Contact categorization and organization**

### Security Features
- **PIN Verification:** 4-digit PIN system with secure hashing and validation
- **Encrypted Key Management:** AES encryption for secret key storage and secure decryption
- **Device Security:** Device fingerprinting and suspicious activity detection
- **Transaction Limits:** User-defined and system-enforced transaction limits
- **Audit Logging:** Complete transaction audit trail with timestamps and user actions
- **Fee Calculation:** Dynamic fee calculation based on transaction type and amount
- **Transaction PIN verification with attempt limitations**
- **Automatic session timeout for enhanced security**
- **Comprehensive security settings with customization options**
- **Transaction history and access logs for security auditing**
- **Device management for tracking active sessions**
- **Access history tracking with location and device information**

## Screens and User Flow

### Authentication Screens
- **Login Screen:** Secure authentication with device tracking
- **OTP Verification:** SMS-based verification with retry limits
- **PIN Creation:** Secure PIN setup with automatic wallet creation trigger

### Wallet Screens
- **Home Dashboard:** Overview of balances across all currencies with real-time Stellar network sync
- **Currency Details:** In-depth view of specific currency activities
- **Transaction History:** Filterable list of past transactions with blockchain hash verification
- **Send Money:** Multi-step process for secure money transfers with PIN verification
- **Receive Money:** QR code and account ID generation

### Wallet Funding Screens
- **Wallet Selection:** Dynamic wallet type selection (Blockchain/Backend)
- **Payment Method Selection:** Credit card vs Bank transfer options
- **Card Details Input:** Secure credit card information collection
- **Bank Details Input:** Bank account information for transfers
- **Transaction Confirmation:** Review and confirm payment details
- **Success Display:** Real-time transaction confirmation with blockchain hash

### Transfer Screens
- **Transfer Type Selection:** Choose between wallet-to-wallet or non-wallet transfers
- **Recipient Lookup:** Search and validate recipient by worker ID
- **Contact Details:** Display and confirm recipient information
- **Multi-Currency Transfer:** Select currency and enter transfer amount
- **Transfer Confirmation:** Review transfer details with fee calculation
- **Success Display:** Real-time transaction confirmation with blockchain hash
- **Transaction History:** Complete transaction history with status tracking

### Non-Wallet Remittance Screens
- **Send for Non-LulPay:** Collect recipient personal and identity details
- **Set Amount:** Select currency and specify amount to send
- **Transaction Review:** Verify details before confirming transaction
- **Remittance Success:** Confirmation with transaction details and reference number

### Profile Management
- **User Profile:** View and edit personal information
- **Security Settings:** PIN management and security preferences
- **Access History:** Review recent account access events
- **Notification Settings:** Customize alert preferences

## Technologies Used

### Frontend
- **Flutter:** Cross-platform UI toolkit (v3.0+)
- **GetX:** State management, dependency injection, and routing
- **Dio:** HTTP client for API communication

### UI/UX
- **Custom responsive design with adaptable layouts**
- **Lottie animations for enhanced user experience**
- **Material Design components with custom styling**
- **Smooth page transitions and micro-interactions**

### Authentication & Security
- **JWT token-based authentication**
- **Secure PIN storage and verification**
- **Session management with device tracking**
- **Biometric authentication integration**
- **AES encryption for private key security**

### Payment Processing
- **Dynamic fee calculation**
- **QR code generation and scanning**
- **Real-time validation**
- **Idempotency key implementation for transaction safety**
- **Multiple payment processor integration (Stripe, Plaid, Flutterwave)**

### Blockchain Integration
- **Stellar SDK integration for real blockchain operations**
- **Cryptographic transaction signing**
- **Real-time balance synchronization**
- **Blockchain transaction hash tracking**
- **Testnet integration with Friendbot auto-funding**

### Networking
- **RESTful API integration**
- **Error handling and retry mechanisms**
- **Connectivity monitoring**
- **Background synchronization for offline actions**

### Data Management
- **Local storage with shared preferences**
- **Secure credential storage**
- **Firebase integration for push notifications**

## Architecture

The application follows a clean architecture approach with:

- **Feature-based organization (authentication, wallet, transfers)**
- **Separation of UI, business logic, and data layers**
- **Service-based API communication**
- **Controller-based state management**
- **Reactive programming patterns for state updates**
- **Unified API architecture for blockchain and backend operations**

## Key API Endpoints

### Authentication & Registration
- `POST /api/auth/login` - User login with device tracking
- `POST /api/auth/register` - User registration with OTP verification
- `POST /api/user/pin/create` - PIN creation (triggers automatic wallet creation)

### Wallet Management
- `GET /api/v1/wallets/user/{userId}/overview` - Get complete wallet overview with balances
- `GET /api/v1/wallets/user/{userId}/available` - Get available wallet options

### Payment Processing
- `POST /api/user/deposit/unified` - Unified payment processing with automatic routing
- `POST /api/user/deposit` - Legacy payment processing endpoint

### Transfers
- `POST /api/v1/unified-transfer/transfer` - Unified transfer system with smart routing
- `POST /api/v1/transfers/non-wallet` - Non-wallet transfers
- `GET /api/user/transactions` - Get user transaction history

## Getting Started

### Prerequisites
- Flutter SDK (v3.0 or higher)
- Dart SDK (v3.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure your environment variables
4. Run `flutter run` to start the application

## Contributing

Please read our contribution guidelines before submitting pull requests.

## License

This project is proprietary and confidential. All rights reserved.

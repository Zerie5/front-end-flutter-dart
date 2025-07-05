# LulPay - Mobile Financial Platform Front End Mobile App

(Backend Repo is Private But could be provided for SCF on Request)

![LulPay Logo](assets/logos/logo1.png)

## Overview

LulPay is a secure, feature-rich mobile financial platform built with Flutter that enables seamless money transfers, payments, and financial management. The application provides both traditional wallet-based transfers and innovative non-wallet remittance solutions to serve diverse financial needs.

## Key Features

### Secure Authentication
- Authentication with PIN and SMS verification
- Session management with automatic lockout
- PIN-protected transactions and app access
- Biometric authentication options for enhanced security

### Wallet Management
- Multi-currency wallet support with real-time balance display
- Stellar Testnet Integrated
- One-click currency switching between different available currencies
- Real-time balance updates and transaction history
- Currency conversion with competitive rates
- Comprehensive transaction details and receipt generation

### Payment Solutions
- Wallet-to-wallet transfers with instant confirmation
- QR code-based payments for contactless transactions
- Contact-based payments with recipient search functionality
- Non-wallet remittance for people with no app.
- Transaction confirmation screens with detailed fee breakdowns

### Non-Wallet Remittance
- Register and track payments for remittance to people with no wallet.
- Dynamic fee calculation based on transaction amount and type
- Transaction ID tracking for external payments
- Delayed transaction support for post-payment verification
- Recipient information collection with validation
- Multiple currency support for non-wallet transactions
- Customizable transaction descriptions

### User Profile Management
- View and edit personal information
- Update profile picture and contact details
- View account verification status
- Manage notification preferences
- Account activity dashboard and statistics

### Multi-Currency Features
- Support for multiple currencies with real-time balances
- Currency-specific transaction history
- Seamless switching between currencies for sending/receiving funds
- Currency-specific transaction limits and fee structures
- Currency preference settings for default transactions

### Contact Management
- Add and manage payment recipients
- QR code scanning to add contacts
- Recent and favorite contacts for quick access
- Contact search with filtering options
- Contact categorization and organization

### Security Features
- Transaction PIN verification with attempt limitations
- Automatic session timeout for enhanced security
- Comprehensive security settings with customization options
- Transaction history and access logs for security auditing
- Device management for tracking active sessions
- Access history tracking with location and device information

## Screens and User Flow

### Wallet Screens
- **Home Dashboard**: Overview of balances across all currencies
- **Currency Details**: In-depth view of specific currency activities
- **Transaction History**: Filterable list of past transactions
- **Send Money**: Multi-step process for secure money transfers
- **Receive Money**: QR code and account ID generation

### Non-Wallet Remittance Screens
- **Send for Non-LulPay**: Collect recipient personal and identity details
- **Set Amount**: Select currency and specify amount to send
- **Transaction Review**: Verify details before confirming transaction
- **Remittance Success**: Confirmation with transaction details and reference number

### Profile Management
- **User Profile**: View and edit personal information
- **Security Settings**: PIN management and security preferences
- **Access History**: Review recent account access events
- **Notification Settings**: Customize alert preferences

## Technologies Used

### Frontend
- **Flutter**: Cross-platform UI toolkit (v3.0+)
- **GetX**: State management, dependency injection, and routing
- **Dio**: HTTP client for API communication

### UI/UX
- Custom responsive design with adaptable layouts
- Lottie animations for enhanced user experience
- Material Design components with custom styling
- Smooth page transitions and micro-interactions

### Authentication & Security
- JWT token-based authentication
- Secure PIN storage and verification
- Session management
- Biometric authentication integration

### Payment Processing
- Dynamic fee calculation
- QR code generation and scanning
- Real-time validation
- Idempotency key implementation for transaction safety

### Networking
- RESTful API integration
- Error handling and retry mechanisms
- Connectivity monitoring
- Background synchronization for offline actions

### Data Management
- Local storage with shared preferences
- Secure credential storage
- Firebase integration for push notifications

## Architecture

The application follows a clean architecture approach with:

- Feature-based organization (authentication, wallet, transfers)
- Separation of UI, business logic, and data layers
- Service-based API communication
- Controller-based state management
- Reactive programming patterns for state updates

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

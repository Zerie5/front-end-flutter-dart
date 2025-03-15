# Receive Features

This directory contains features related to receiving payments in the LulPay app.

## QR Code Screen

The QR Code Screen (`qr_code_screen.dart`) displays the user's worker ID as a QR code that can be scanned by other users to send payments. The screen:

1. Fetches the user's worker ID from local storage or from the server
2. Displays it as a QR code
3. Allows the user to refresh the worker ID from the server
4. Shows whether the ID was loaded from storage or from the server

## Scan User ID Screen

The Scan User ID Screen (`scan_user_id_screen.dart`) allows users to:

1. Manually enter another user's worker ID
2. Scan a QR code containing a worker ID
3. View the user's details once found
4. Proceed to the payment screen

### How to Use

#### Displaying Your QR Code
1. Navigate to the QR Code Screen from the home screen by tapping the "Receive" button
2. Your worker ID will be displayed as a QR code
3. Share this QR code with others who want to send you money
4. Tap the refresh button to fetch the latest worker ID from the server

#### Scanning Someone's QR Code
1. From the QR Code Screen, tap the floating action button with the scan icon
2. On the Scan User ID Screen, you can either:
   - Manually enter the worker ID in the text field
   - Tap the scan button to open the camera and scan a QR code
3. Once a valid worker ID is entered or scanned, the app will automatically search for the user
4. If the user is found, their details will be displayed
5. Tap on the user's details to proceed to the payment screen

## Implementation Details

- The QR code is generated using the `qr_flutter` package
- QR code scanning is implemented using the `mobile_scanner` package
- The worker ID is fetched from the server using the `/api/user-info/worker-id` endpoint
- User lookup is performed using the `UserLookupService` 
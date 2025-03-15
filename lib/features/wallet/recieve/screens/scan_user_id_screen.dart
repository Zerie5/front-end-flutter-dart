import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/features/wallet/send/send_contact_detail.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/features/wallet/contacts/models/contact_model.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_textformfield.dart';
import 'package:lul/utils/validators/validation.dart';
import 'package:lul/services/user_lookup_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:iconsax/iconsax.dart';

class ScanUserIdScreen extends StatefulWidget {
  const ScanUserIdScreen({super.key});
  @override
  State<ScanUserIdScreen> createState() => _ScanUserIdScreenState();
}

class _ScanUserIdScreenState extends State<ScanUserIdScreen> {
  final _formKey = GlobalKey<FormState>();
  final LanguageController _languageController = Get.find<LanguageController>();
  final UserLookupService _userLookupService = Get.find<UserLookupService>();
  final TextEditingController _idController = TextEditingController();
  final FocusNode _idFocusNode = FocusNode();

  ContactModel? _foundContact;
  bool _showContactInfo = false;
  bool _isSearching = false;
  bool _isScanning = false;

  // Scanner controller
  MobileScannerController? _scannerController;

  void _resetContactInfo() {
    setState(() {
      _showContactInfo = false;
      _foundContact = null;
    });
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _scannerController = MobileScannerController();
    });
  }

  void _stopScanning() {
    _scannerController?.dispose();
    setState(() {
      _isScanning = false;
      _scannerController = null;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    // Process the first valid barcode
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final String scannedCode = barcode.rawValue!;
        print('Scanned code: $scannedCode');

        // Stop scanning
        _stopScanning();

        // Set the scanned code to the text field
        setState(() {
          _idController.text = scannedCode;
        });

        // Trigger search if the code is valid
        String? validationError = LValidator().validateUserIDEntry(scannedCode);
        if (validationError == null) {
          _handleSaveButtonPress();
        }

        break;
      }
    }
  }

  Future<void> _handleSaveButtonPress() async {
    if (_formKey.currentState!.validate()) {
      final workId = _idController.text;

      // Don't proceed if already searching
      if (_isSearching) return;

      _resetContactInfo();
      setState(() {
        _isSearching = true;
      });

      // Show loader
      LulLoaders.showLoadingDialog();

      try {
        // Call the API to lookup the user
        final result = await _userLookupService.lookupUser(workId);

        // Dismiss loader before showing result
        Get.back(); // Dismisses the loader

        setState(() {
          _isSearching = false;
        });

        if (result['status'] == 'success') {
          setState(() {
            _foundContact = result['contact'];
            _showContactInfo = true;
          });
        } else {
          // Handle different error codes
          switch (result['code']) {
            case 'ERR_501':
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('not_found'),
                message: _languageController.getText('user_not_found_snack'),
              );
              break;
            case 'ERR_003':
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('error'),
                message: 'Database error occurred',
              );
              break;
            case 'ERR_002':
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('error'),
                message: 'Internal server error',
              );
              break;
            case 'ERR_500':
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('error'),
                message:
                    'The server encountered an error processing your request',
              );
              break;
            case 'ERR_404':
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('not_found'),
                message: 'User with ID ${_idController.text} was not found',
              );
              break;
            case 'ERR_502':
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('error'),
                message: 'User lookup failed',
              );
              break;
            default:
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('error'),
                message: result['message'] ?? 'Unknown error occurred',
              );
          }
        }
      } catch (e) {
        // Dismiss loader if still showing
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        setState(() {
          _isSearching = false;
        });

        LulLoaders.lulerrorDialog(
          title: _languageController.getText('error'),
          message: 'An unexpected error occurred',
        );
      }
    }
  }

  // Build the contact info tile
  Widget _buildContactTile(ContactModel contact) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: TColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: () => Get.to(() => LulSendContactDetailScreen(contact: contact)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          contact.fullName,
          style: const TextStyle(
            color: TColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'ID: ${contact.id}',
              style: TextStyle(
                color: TColors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              contact.email,
              style: TextStyle(
                color: TColors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the QR code scanner overlay
  Widget _buildScannerOverlay() {
    return Stack(
      children: [
        // Scanner
        Positioned.fill(
          child: MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Camera error: ${error.errorCode.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please check camera permissions',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LulButton(
                      onPressed: _stopScanning,
                      text: 'Go Back',
                      backgroundColor: TColors.buttonPrimary,
                      height: 48,
                      width: 150,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Scan frame overlay
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: TColors.secondary, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner decorations
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: TColors.secondary, width: 3),
                        left: BorderSide(color: TColors.secondary, width: 3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: TColors.secondary, width: 3),
                        right: BorderSide(color: TColors.secondary, width: 3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: TColors.secondary, width: 3),
                        left: BorderSide(color: TColors.secondary, width: 3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: TColors.secondary, width: 3),
                        right: BorderSide(color: TColors.secondary, width: 3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Top bar with close button
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan QR Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: LulButton(
                    onPressed: _stopScanning,
                    text: '',
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    prefixIcon:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom instructions
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Position the QR code within the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The app will automatically scan when a valid code is detected',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
        body: _isScanning
            ? _buildScannerOverlay()
            : SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Bar
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: Obx(() {
                        return Text(
                          _languageController.getText('scan_or_enter_id'),
                          style: FormTextStyle.getHeaderStyle(context),
                        );
                      }),
                      centerTitle: true,
                    ),

                    // Main Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),

                              // Scan QR Code Button
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 24),
                                child: LulButton(
                                  onPressed: _startScanning,
                                  text: 'Scan QR Code',
                                  backgroundColor: TColors.buttonPrimary,
                                  height: 56,
                                  fontSize: 16,
                                  prefixIcon:
                                      const Icon(Iconsax.scan, size: 24),
                                ),
                              ),

                              // Divider with "OR" text
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: TColors.white.withOpacity(0.3),
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                        color: TColors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: TColors.white.withOpacity(0.3),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Manual ID Entry Section
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: TColors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: TColors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Obx(() => Text(
                                            _languageController
                                                .getText('contact_id'),
                                            style: FormTextStyle.getLabelStyle(
                                                context),
                                          )),
                                      const SizedBox(height: 12),
                                      Obx(() => LulGeneralTextFormField(
                                            controller: _idController,
                                            focusNode: _idFocusNode,
                                            hintText: _languageController
                                                .getText('enter_user_id'),
                                            hintStyle:
                                                FormTextStyle.getHintStyle(
                                                    context),
                                            textInputAction:
                                                TextInputAction.done,
                                            validator: (value) {
                                              _resetContactInfo();
                                              return LValidator()
                                                  .validateUserIDEntry(
                                                      value ?? "");
                                            },
                                            onChanged: (value) {
                                              // This will trigger the validator and show error message
                                              _formKey.currentState?.validate();

                                              // Trigger search when ID is 10 characters long
                                              String? validationError =
                                                  LValidator()
                                                      .validateUserIDEntry(
                                                          value);
                                              if (validationError == null &&
                                                  value.length == 10) {
                                                _handleSaveButtonPress();
                                              }
                                            },
                                            suffixIcon: IconButton(
                                              icon: const Icon(
                                                  Iconsax.search_normal,
                                                  color: TColors.primary),
                                              onPressed: _handleSaveButtonPress,
                                              tooltip: 'Search',
                                            ),
                                          )),
                                      const SizedBox(height: 16),
                                      LulButton(
                                        onPressed: _handleSaveButtonPress,
                                        text: 'Search',
                                        backgroundColor: TColors.buttonPrimary,
                                        height: 50,
                                        fontSize: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Contact Info Display
                              if (_showContactInfo && _foundContact != null)
                                _buildContactTile(_foundContact!),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _idFocusNode.dispose();
    _scannerController?.dispose();
    super.dispose();
  }
}

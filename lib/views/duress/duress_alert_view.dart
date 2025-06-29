import 'package:flutter/material.dart';

class DuressAlertView extends StatelessWidget {
  const DuressAlertView({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;

    return Scaffold(
      backgroundColor: Colors.red[50],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(mediaQueryWidth * 0.05),
          child: Column(
            children: [
              SizedBox(height: mediaQueryHeight * 0.1),
              
              // Alert Icon
              Container(
                width: mediaQueryWidth * 0.3,
                height: mediaQueryWidth * 0.3,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: mediaQueryWidth * 0.15,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: mediaQueryHeight * 0.04),
              
              // Alert Title
              Text(
                'DURESS ALERT',
                style: TextStyle(
                  fontSize: textScaler.scale(mediaQueryWidth * 0.08),
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: mediaQueryHeight * 0.02),
              
              // Alert Message
              Text(
                'Emergency alert has been triggered. Your network has been notified of your situation.',
                style: TextStyle(
                  fontSize: textScaler.scale(mediaQueryWidth * 0.045),
                  color: Colors.red[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: mediaQueryHeight * 0.06),
              
              // Status Information
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(mediaQueryWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'Alert Status: ACTIVE',
                      style: TextStyle(
                        fontSize: textScaler.scale(mediaQueryWidth * 0.05),
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    SizedBox(height: mediaQueryHeight * 0.02),
                    Text(
                      'Location tracking enabled\nNetwork notified\nEmergency contacts alerted',
                      style: TextStyle(
                        fontSize: textScaler.scale(mediaQueryWidth * 0.04),
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Instructions
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(mediaQueryWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Text(
                  'Stay calm and follow your emergency protocol. Help is on the way.',
                  style: TextStyle(
                    fontSize: textScaler.scale(mediaQueryWidth * 0.04),
                    color: Colors.amber[800],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: mediaQueryHeight * 0.04),
              
              // Cancel Alert Button (for testing)
              SizedBox(
                width: double.infinity,
                height: mediaQueryHeight * 0.06,
                child: ElevatedButton(
                  onPressed: () {
                    // In a real app, this would require additional verification
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
                    ),
                  ),
                  child: Text(
                    'Cancel Alert (Test Only)',
                    style: TextStyle(
                      fontSize: textScaler.scale(mediaQueryWidth * 0.045),
                      fontWeight: FontWeight.bold,
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
} 
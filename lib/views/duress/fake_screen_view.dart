import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';

class FakeScreenView extends StatefulWidget {
  const FakeScreenView({super.key});

  @override
  State<FakeScreenView> createState() => _FakeScreenViewState();
}

class _FakeScreenViewState extends State<FakeScreenView> {
  String _display = '0';
  String _operation = '';
  double _firstNumber = 0;
  bool _shouldResetDisplay = false;

  void _onNumberPressed(String number) {
    setState(() {
      if (_display == '0' || _shouldResetDisplay) {
        _display = number;
        _shouldResetDisplay = false;
      } else {
        _display += number;
      }
    });
  }

  void _onOperationPressed(String operation) {
    setState(() {
      _firstNumber = double.tryParse(_display) ?? 0;
      _operation = operation;
      _shouldResetDisplay = true;
    });
  }

  void _onEqualsPressed() {
    if (_operation.isEmpty) return;

    final secondNumber = double.tryParse(_display) ?? 0;
    double result = 0;

    switch (_operation) {
      case '+':
        result = _firstNumber + secondNumber;
        break;
      case '-':
        result = _firstNumber - secondNumber;
        break;
      case '×':
        result = _firstNumber * secondNumber;
        break;
      case '÷':
        result = secondNumber != 0 ? _firstNumber / secondNumber : 0;
        break;
    }

    setState(() {
      _display = result.toString();
      if (_display.endsWith('.0')) {
        _display = _display.substring(0, _display.length - 2);
      }
      _operation = '';
      _shouldResetDisplay = true;
    });
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _operation = '';
      _firstNumber = 0;
      _shouldResetDisplay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(mediaQueryWidth * 0.05),
                alignment: Alignment.bottomRight,
                child: Text(
                  _display,
                  style: TextStyle(
                    fontSize: mediaQueryWidth * 0.15,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            
            // Buttons
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.all(mediaQueryWidth * 0.02),
                child: Column(
                  children: [
                    // First row: C, +/-, %, ÷
                    _buildButtonRow([
                      _CalculatorButton(
                        text: 'C',
                        onPressed: _onClearPressed,
                        backgroundColor: Colors.grey[600]!,
                      ),
                      _CalculatorButton(
                        text: '+/-',
                        onPressed: () {
                          setState(() {
                            if (_display.startsWith('-')) {
                              _display = _display.substring(1);
                            } else if (_display != '0') {
                              _display = '-$_display';
                            }
                          });
                        },
                        backgroundColor: Colors.grey[600]!,
                      ),
                      _CalculatorButton(
                        text: '%',
                        onPressed: () {
                          setState(() {
                            final value = double.tryParse(_display) ?? 0;
                            _display = (value / 100).toString();
                            _shouldResetDisplay = true;
                          });
                        },
                        backgroundColor: Colors.grey[600]!,
                      ),
                      _CalculatorButton(
                        text: '÷',
                        onPressed: () => _onOperationPressed('÷'),
                        backgroundColor: Colors.orange,
                      ),
                    ]),
                    
                    // Second row: 7, 8, 9, ×
                    _buildButtonRow([
                      _CalculatorButton(
                        text: '7',
                        onPressed: () => _onNumberPressed('7'),
                      ),
                      _CalculatorButton(
                        text: '8',
                        onPressed: () => _onNumberPressed('8'),
                      ),
                      _CalculatorButton(
                        text: '9',
                        onPressed: () => _onNumberPressed('9'),
                      ),
                      _CalculatorButton(
                        text: '×',
                        onPressed: () => _onOperationPressed('×'),
                        backgroundColor: Colors.orange,
                      ),
                    ]),
                    
                    // Third row: 4, 5, 6, -
                    _buildButtonRow([
                      _CalculatorButton(
                        text: '4',
                        onPressed: () => _onNumberPressed('4'),
                      ),
                      _CalculatorButton(
                        text: '5',
                        onPressed: () => _onNumberPressed('5'),
                      ),
                      _CalculatorButton(
                        text: '6',
                        onPressed: () => _onNumberPressed('6'),
                      ),
                      _CalculatorButton(
                        text: '-',
                        onPressed: () => _onOperationPressed('-'),
                        backgroundColor: Colors.orange,
                      ),
                    ]),
                    
                    // Fourth row: 1, 2, 3, +
                    _buildButtonRow([
                      _CalculatorButton(
                        text: '1',
                        onPressed: () => _onNumberPressed('1'),
                      ),
                      _CalculatorButton(
                        text: '2',
                        onPressed: () => _onNumberPressed('2'),
                      ),
                      _CalculatorButton(
                        text: '3',
                        onPressed: () => _onNumberPressed('3'),
                      ),
                      _CalculatorButton(
                        text: '+',
                        onPressed: () => _onOperationPressed('+'),
                        backgroundColor: Colors.orange,
                      ),
                    ]),
                    
                    // Fifth row: 0 (double width), ., =
                    _buildButtonRow([
                      _CalculatorButton(
                        text: '0',
                        onPressed: () => _onNumberPressed('0'),
                        flex: 2,
                      ),
                      _CalculatorButton(
                        text: '.',
                        onPressed: () {
                          if (!_display.contains('.')) {
                            setState(() {
                              _display += '.';
                            });
                          }
                        },
                      ),
                      _CalculatorButton(
                        text: '=',
                        onPressed: _onEqualsPressed,
                        backgroundColor: Colors.orange,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<_CalculatorButton> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((button) {
          return Expanded(
            flex: button.flex,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: AspectRatio(
                aspectRatio: button.flex == 2 ? 2 : 1,
                child: Material(
                  color: button.backgroundColor,
                  borderRadius: BorderRadius.circular(100),
                  child: InkWell(
                    onTap: button.onPressed,
                    borderRadius: BorderRadius.circular(100),
                    child: Center(
                      child: Text(
                        button.text,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.07,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CalculatorButton {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final int flex;

  _CalculatorButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF333333),
    this.flex = 1,
  });
} 
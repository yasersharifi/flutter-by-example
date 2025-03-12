import "package:flutter/material.dart";

import "button_variants.dart";

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String number1 = ""; // . 0-9
  String operand = ""; // + - * /
  String number2 = ""; // . 0-9

  _onBtnTap(String label) {
    setState(() {
      switch (label) {

        case Btn.clr:
          number1 = "";
          number2 = "";
          operand = "";
          break;

        case Btn.n0:
        case Btn.n1:
        case Btn.n2:
        case Btn.n3:
        case Btn.n4:
        case Btn.n5:
        case Btn.n6:
        case Btn.n7:
        case Btn.n8:
        case Btn.n9:
          {
            if (operand.isEmpty) {
              number1 += label;
            } else {
              number2 += label;
            }
            break;
          }

        case Btn.divide:
        case Btn.add:
        case Btn.subtract:
        case Btn.multiply:
          {
            if (number2.isEmpty) {
              operand = label;
            }
            break;
          }

        case Btn.calculate:
          {
            if (operand == Btn.add) {
              number1 = (int.parse(number1) + int.parse(number2)).toString();
            }
            if (operand == Btn.subtract) {
              number1 = (int.parse(number1) - int.parse(number2)).toString();
            }
            if (operand == Btn.divide) {
              number1 = (int.parse(number1) / int.parse(number2)).toString();
            }
            if (operand == Btn.multiply) {
              number1 = (int.parse(number1) * int.parse(number2)).toString();
            }
            number2 = "";
            operand = "";
            break;
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        // Output
        Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '$number1$operand$number2'.isEmpty
                        ? "0"
                        : '$number1$operand$number2',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Buttons
        Wrap(
          children:
              Btn.buttonValues
                  .map(
                    (value) => SizedBox(
                      width:
                          value == Btn.n0
                              ? screenSize.width / 2
                              : screenSize.width / 4,
                      height: screenSize.width / 5,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: buildButton(context, value),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget buildButton(BuildContext context, String label) {
    return ElevatedButton(
      onPressed: () => _onBtnTap(label),
      style: ElevatedButton.styleFrom(backgroundColor: getBtnColor(label)),
      child: Text(
        label,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

Color getBtnColor(String label) {
  switch (label) {
    case Btn.n0:
      return Colors.white;

    case Btn.del:
    case Btn.clr:
      return Colors.blueGrey;

    case Btn.per:
    case Btn.multiply:
    case Btn.add:
    case Btn.subtract:
    case Btn.divide:
    case Btn.calculate:
      return Colors.orange;

    default:
      return Colors.black87;
  }
}

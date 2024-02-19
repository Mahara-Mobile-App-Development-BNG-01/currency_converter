import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

void main() {
  runApp(BlocProvider(
      create: (context) => CurrencyConverterCubit(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CurrencyConverterCubit>();

    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From:'),
              DropdownButton(
                value: cubit.state.fromCurrency,
                items: [
                  ...cubit.state.prices.keys.map(
                    (currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ),
                  ),
                ],
                onChanged: (currency) {
                  cubit.setFromCurrency(currency ?? '');
                },
              ),
              Text('TO:'),
              DropdownButton(
                value: cubit.state.toCurrency,
                items: [
                  ...cubit.state.prices.keys
                      .where((element) => cubit.state.fromCurrency != element)
                      .map(
                        (currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        ),
                      ),
                ],
                onChanged: (currency) {
                  cubit.setToCurrency(currency ?? '');
                },
              ),
              Gap(16),
              TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (text) => cubit.onAmountChanged(double.parse(text)),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              Gap(16),
              Text('Result is: ${cubit.state.result}'),
              Gap(16),
              ElevatedButton(
                onPressed: () {
                  cubit.convert();
                },
                child: Text('Convert'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrencyState {
  CurrencyState({
    this.fromCurrency = 'USD',
    this.toCurrency = 'EUR',
    this.amount = 0,
    this.result,
  });

  final prices = <String, Map<String, double>>{
    'USD': {
      'EUR': 1.1,
      'LYD': 7,
    },
    'LYD': {
      'USD': 1 / 7,
      'EUR': 0.9,
    },
    'EUR': {
      'USD': 1 / 7,
      'LYD': 0.9,
    },
  };
  final String? fromCurrency;
  final String? toCurrency;
  final double amount;
  final double? result;

  @override
  String toString() {
    return 'CurrencyState{fromCurrency: $fromCurrency, toCurrency: $toCurrency, amount: $amount, result: $result}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyState &&
          runtimeType == other.runtimeType &&
          fromCurrency == other.fromCurrency &&
          toCurrency == other.toCurrency &&
          amount == other.amount &&
          result == other.result;

  @override
  int get hashCode =>
      fromCurrency.hashCode ^
      toCurrency.hashCode ^
      amount.hashCode ^
      result.hashCode;

  CurrencyState copyWith({
    String? fromCurrency,
    String? toCurrency,
    double? amount,
    double? result,
  }) {
    return CurrencyState(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      result: result ?? this.result,
    );
  }
}

class CurrencyConverterCubit extends Cubit<CurrencyState> {
  CurrencyConverterCubit() : super(CurrencyState());

  void setFromCurrency(String currency) {
    final newToCurrency =
        state.toCurrency == currency ? null : state.toCurrency;

    final newState = CurrencyState(
      fromCurrency: currency,
      toCurrency: newToCurrency,
      amount: state.amount,
      result: state.result,
    );

    emit(newState);
  }

  void setToCurrency(String currency) {
    emit(state.copyWith(toCurrency: currency));
  }

  void onAmountChanged(double amount) {
    emit(state.copyWith(amount: amount));
  }

  void convert() {
    final prices = state.prices;
    final result =
        prices[state.fromCurrency]![state.toCurrency]! * state.amount;
    final newState = state.copyWith(result: result);
    emit(newState);
  }
}

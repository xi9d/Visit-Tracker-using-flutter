import 'package:flutter/material.dart';
import 'package:rtm/Model/Customer.dart';
import 'package:rtm/Services/ApiService.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({Key? key}) : super(key: key);

  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addCustomer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        print('Starting customer creation...');  // First test print

        final newCustomer = Customer(
          id: 0,
          name: _nameController.text.trim(),
          createdAt: DateTime.now(),
        );

        print('Customer object created');  // Second test print
        debugPrint('customer ${newCustomer.toJson()}');  // Using debugPrint

        await ApiService.addCustomer(newCustomer);
        print('API call completed');  // Third test print

        if (!mounted) return;

        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer added successfully')),
        );
      } catch (e, stack) {
        print('Full error: $e\n$stack');  // Print full stack trace
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addCustomer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text('Add Customer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String species = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pet Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Pet Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter pet name' : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Species'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter species' : null,
                onSaved: (value) => species = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Simpan ke backend / local storage di sini
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Pet "$name" added successfully')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Pet'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

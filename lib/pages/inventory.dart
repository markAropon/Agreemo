import 'package:greenhouse_monitoring_project/functions/UserFunctions.dart';
import 'package:greenhouse_monitoring_project/pages/dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../functions/maintenanceFunction.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String? _selectedGreenhouseId;

  final List<Map<String, String?>> _dropdownRows = [
    {'type': null, 'unit': null, 'count': null, 'price': null},
  ];

  final List<String> _liquidTypes = [
    'PH + Sol',
    'PH - Sol',
    'Snap A',
    'Snap B'
  ];
  final List<String> _solidTypes = ['Seedlings', 'Foam'];
  final List<String> _liquidUnits = ['ml', 'liters', 'oz'];
  final List<String> _solidUnits = ['pieces', 'kg', 'lb', 'packs'];
  final List<String> _itemTypes = [
    'PH + Sol',
    'PH - Sol',
    'Snap A',
    'Snap B',
    'Seedlings',
    'Foam'
  ];
  final TextEditingController _otherTypeController = TextEditingController();
  final TextEditingController _otherUnitController = TextEditingController();

  void _addNewRow() {
    setState(() {
      _dropdownRows
          .add({'type': null, 'unit': null, 'count': null, 'price': null});
    });
  }

  void _deleteRow(int index) {
    if (_dropdownRows.length > 1) {
      setState(() => _dropdownRows.removeAt(index));
    }
  }

  void _clearAllRows() {
    setState(() => _dropdownRows.removeRange(1, _dropdownRows.length));
    _dropdownRows[0] = {
      'type': null,
      'unit': null,
      'count': null,
      'price': null
    };
  }

  double convertToMilliliters({required String unit, required double value}) {
    const double literToMl = 1000.0;
    const double ounceToMl = 29.5735;

    switch (unit) {
      case 'liters':
        return value * literToMl;
      case 'oz':
        return value * ounceToMl;
      case 'ml':
      default:
        return value;
    }
  }

  Future<void> _selectItemType(int index) async {
    final selectedType = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Select Item Type',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: [
                  ..._itemTypes.map((type) => ListTile(
                        title: Text(type),
                        onTap: () => Navigator.pop(context, type),
                      )),
                  ListTile(
                    title: const Text('Other'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      Navigator.pop(context);
                      final customType = await _showOtherTextField('Type');
                      if (customType != null && mounted) {
                        setState(
                            () => _dropdownRows[index]['type'] = customType);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (selectedType != null && mounted) {
      setState(() {
        _dropdownRows[index]['type'] = selectedType;
        _dropdownRows[index]['unit'] = null;
      });
    }
  }

  void _selectUnit(int index) async {
    String? currentType = _dropdownRows[index]['type'];
    List<String> unitsToShow = [];

    if (_liquidTypes.contains(currentType)) {
      unitsToShow = _liquidUnits;
    } else if (_solidTypes.contains(currentType)) {
      unitsToShow = _solidUnits;
    } else {
      unitsToShow = [..._liquidUnits, ..._solidUnits];
    }

    final selectedUnit = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Select Unit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: [
                  ...unitsToShow.map((unit) => ListTile(
                        title: Text(unit),
                        onTap: () => Navigator.pop(context, unit),
                      )),
                  ListTile(
                    title: const Text('Other'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      Navigator.pop(context);
                      final customUnit = await _showOtherTextField('Unit');
                      if (customUnit != null && mounted) {
                        setState(
                            () => _dropdownRows[index]['unit'] = customUnit);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (selectedUnit != null && mounted) {
      setState(() => _dropdownRows[index]['unit'] = selectedUnit);
    }
  }

  Future<String?> _showOtherTextField(String label) async {
    String? result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Custom $label'),
        content: TextField(
          controller:
              label == 'Type' ? _otherTypeController : _otherUnitController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter $label name',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final controller =
                  label == 'Type' ? _otherTypeController : _otherUnitController;
              Navigator.pop(context, controller.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (label == 'Type') _otherTypeController.clear();
    if (label == 'Unit') _otherUnitController.clear();

    return result?.isEmpty ?? true ? null : result;
  }

  Widget _buildGreenhouseDropdown() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          child: buildGreenhouseDropdownField(
            onChanged: (value) {
              setState(() {
                _selectedGreenhouseId = value;
              });
            },
            selectedValue: _selectedGreenhouseId,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 209, 198, 198)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Column(children: [
                _buildGreenhouseDropdown(),
                const SizedBox(height: 10),
                const Text(
                  '* Inventory Selection *',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey),
                ),
              ]),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: _dropdownRows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 15),
                  itemBuilder: (context, index) => _buildRow(index),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int index) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                _buildSelectionCard(
                  context,
                  label: _dropdownRows[index]['type'] ?? 'Select Type',
                  onTap: () => _selectItemType(index),
                ),
                const SizedBox(width: 8),
                _buildSelectionCard(
                  context,
                  label: _dropdownRows[index]['unit'] ?? 'Select Unit',
                  onTap: () => _selectUnit(index),
                  isDisabled: _dropdownRows[index]['type'] == null,
                ),
                _buildRowControls(index),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildNumberField('Qty.', index, 'count')),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildNumberField('Price', index, 'price',
                        prefix: '₱')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(BuildContext context,
      {required String label,
      required VoidCallback onTap,
      bool isDisabled = false}) {
    bool isPlaceholder = label.startsWith('Select');
    Color textColor = isPlaceholder ? Colors.grey : Colors.blueGrey;
    if (isDisabled) {
      textColor = Colors.grey.shade400;
    }

    return Expanded(
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: isDisabled ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowControls(int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (index != 0)
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => _deleteRow(index),
          ),
        if (index == _dropdownRows.length - 1)
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            onPressed: _addNewRow,
          ),
      ],
    );
  }

  Widget _buildNumberField(String label, int index, String field,
      {String? prefix}) {
    return TextFormField(
      initialValue: _dropdownRows[index][field],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      onChanged: (value) => setState(() => _dropdownRows[index][field] = value),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            ),
            onPressed: _saveAllRows,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            ),
            onPressed: _clearAllRows,
          ),
        ],
      ),
    );
  }

  Future<void> _saveAllRows() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      bool firstSaveSuccess = false;

      for (final row in _dropdownRows) {
        final isPredefinedItem = row['type'] == 'PH + Sol' ||
            row['type'] == 'PH - Sol' ||
            row['type'] == 'Snap A' ||
            row['type'] == 'Snap B';

        final apiUrl = isPredefinedItem
            ? 'https://agreemo-api-v2.onrender.com/inventory'
            : 'https://agreemo-api-v2.onrender.com/inventory_items';

        Map<String, String> body = {};
        if (isPredefinedItem) {
          final count = double.tryParse(row['count'] ?? '0') ?? 0.0;
          final unit = row['unit'] ?? 'ml';
          final maxMl = convertToMilliliters(unit: unit, value: count);

          body = {
            'greenhouse_id': _selectedGreenhouseId != null &&
                    int.tryParse(_selectedGreenhouseId!) != null
                ? int.parse(_selectedGreenhouseId!).toString()
                : '0',
            'item_name': row['type'] ?? '',
            'email': prefs.getString('email') ?? '',
            'type': row['type'] ?? '',
            'max_ml': maxMl.toString(),
            'quantity': row['count'] ?? '',
            'price': row['price'] ?? '',
          };
        } else {
          body = {
            'greenhouse_id': _selectedGreenhouseId != null &&
                    int.tryParse(_selectedGreenhouseId!) != null
                ? _selectedGreenhouseId!
                : '0',
            'item_name': row['type'] ?? '',
            'unit': row['unit'] ?? '',
            'price': row['price'] ?? '',
            'item_count': row['count'] ?? '',
            'user_email': email,
          };
        }

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'x-api-key': 'AgreemoCapstoneProject',
          },
          body: body,
        );

        if (!mounted) return;

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!firstSaveSuccess) {
            showCustomDialog(
                context: context,
                title: 'Record Saved',
                message: "Items have been saved successfully.",
                icon: Icons.check_circle,
                iconColor: Colors.green,
                backgroundColor: Colors.white);
            firstSaveSuccess = true;
            await Future.delayed(const Duration(seconds: 1));
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
              (Route<dynamic> route) => false,
            );

            await Future.delayed(Duration.zero);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InventoryPage()),
            );
          }
        } else {
          // Error handling remains the same
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}

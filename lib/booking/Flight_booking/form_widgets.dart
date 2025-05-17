import 'package:flutter/material.dart';

class DetailCardWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final List<Map<String, dynamic>> savedDetails;
  final double flightPrice;
  final double hotelPrice;
  final Function calculateTotalCost; // Accept the function

  const DetailCardWidget({
    required this.onSave,
    required this.savedDetails,
    required this.flightPrice,  // Add this line
    required this.hotelPrice,
    required this.calculateTotalCost,  // Add this line
    // Default value set to 0.0
    Key? key,
  }) : super(key: key);

  @override
  _DetailCardWidgetState createState() => _DetailCardWidgetState();
}

class _DetailCardWidgetState extends State<DetailCardWidget> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String? selectedGender;

  String? focusedField;
  bool isFormFilled = false;
  int? editingIndex; // Track which detail is being edited
  String? deleteMessage; // Store delete message

  void _checkFormFilled() {
    setState(() {
      isFormFilled = nameController.text.isNotEmpty &&
          ageController.text.isNotEmpty &&
          selectedGender != null;
    });
  }

  void _saveDetail() {
    if (!isFormFilled) return;

    setState(() {
      if (editingIndex == null) {
        // Add new detail
        widget.savedDetails.add({
          'name': nameController.text,
          'age': ageController.text,
          'gender': selectedGender,
        });
      } else {
        // Update existing detail
        widget.savedDetails[editingIndex!] = {
          'name': nameController.text,
          'age': ageController.text,
          'gender': selectedGender,
        };
        editingIndex = null; // Reset edit mode
      }
      widget.calculateTotalCost(); // <-- add this here too
    });

    // Clear inputs after saving/updating
    nameController.clear();
    ageController.clear();
    selectedGender = null;

    setState(() {
      isFormFilled = false;
      focusedField = null;
    });
  }

  void _editDetail(int index) {
    setState(() {
      nameController.text = widget.savedDetails[index]['name'];
      ageController.text = widget.savedDetails[index]['age'];
      selectedGender = widget.savedDetails[index]['gender'];
      editingIndex = index; // Track index to update later
    });
  }

  void _deleteDetail(int index) {
    setState(() {
      widget.savedDetails.removeAt(index);
      deleteMessage = "Person detail deleted"; // Set message
      widget.calculateTotalCost(); // <-- add this here too=
    });
  }

  void _showDetailsBottomSheet() {
    setState(() {
      deleteMessage = null; // Reset message before opening
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(15),
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Saved Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  Expanded(
                    child: widget.savedDetails.isEmpty
                        ? Center(child: Text("No details saved yet."))
                        : ListView.builder(
                      itemCount: widget.savedDetails.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                              "${widget.savedDetails[index]['name']} - ${widget.savedDetails[index]['age']} years",
                            ),
                            subtitle: Text("Gender: ${widget.savedDetails[index]['gender']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _editDetail(index);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setModalState(() {
                                      _deleteDetail(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (deleteMessage != null) // Show delete message if exists
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        deleteMessage!,
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required String fieldName,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          if (focusedField == fieldName)
            BoxShadow(
              color: Colors.blue.withOpacity(0.6),
              blurRadius: 6,
              offset: Offset(2, 2),
            )
          else
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
        style: TextStyle(fontSize: 14),
        onChanged: (_) => _checkFormFilled(),
        onTap: () {
          setState(() {
            focusedField = fieldName;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInputField(
          controller: nameController,
          hintText: "Name",
          fieldName: "name",
        ),
        _buildInputField(
          controller: ageController,
          hintText: "Age",
          fieldName: "age",
          keyboardType: TextInputType.number,
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              if (focusedField == "gender")
                BoxShadow(
                  color: Colors.blue.withOpacity(0.6),
                  blurRadius: 6,
                  offset: Offset(2, 2),
                )
              else
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
            ],
          ),
          child: DropdownButtonFormField(
            decoration: InputDecoration(
              hintText: "Gender",
              border: InputBorder.none,
            ),
            value: selectedGender,
            items: ["Male", "Female", "Other"].map((String option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedGender = value as String?;
                _checkFormFilled();
                focusedField = "gender";
              });
            },
          ),
        ),
        SizedBox(height: 15),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Left & right alignment
              children: [
                ElevatedButton(
                  onPressed: isFormFilled ? _saveDetail : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFormFilled ? Colors.green : Colors.blueAccent,
                  ),
                  child: Text(
                    editingIndex == null ? "Save Detail" : "Edit Detail",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: _showDetailsBottomSheet,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: Text("View Details", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),

          ],
        ),

      ],
    );
  }
}
class ImageContainer extends StatelessWidget {
  final String imagePath;
  final double? height;

  const ImageContainer({
    Key? key,
    required this.imagePath,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get full screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9, // 90% of screen width
      height: height ?? 140,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
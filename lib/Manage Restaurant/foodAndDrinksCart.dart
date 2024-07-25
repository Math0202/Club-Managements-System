import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class FoodAndDrinksCart extends StatefulWidget {
  final String clubName;

  const FoodAndDrinksCart({super.key,
  required this.clubName
  });

  @override
  State<FoodAndDrinksCart> createState() => _FoodAndDrinksCartState();
}

class _FoodAndDrinksCartState extends State<FoodAndDrinksCart> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    // Retrieve the cart items from Firestore
    _fetchCartItems();
  }

  void _fetchCartItems() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final cartItemsSnapshot = await _firestore
          .collection('Order Tiles')
          .where('Selected Club Name', isEqualTo: widget.clubName)
          .get();
      final cartItems = cartItemsSnapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        this.cartItems = cartItems;
      });
    }
  }

void toggleCustomerConfirmation(String orderId, bool currentValue) async {
  try {
    // Update the Firebase document
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Order Tiles')
        .where('Order Id', isEqualTo: orderId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'Restaurant Approval': !currentValue});
      });
      print('Document with orderId $orderId successfully updated.');
        _fetchCartItems();
    } else {
      print('No document found with orderId $orderId.');
    }
  } catch (e) {
    print('Error updating document: $e');
  }

}

  Container buildSearchBar() {
    return Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: TextField(
             // controller: searchController,
                onChanged: (value) {
                  setState(() {});
                },
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search food & drinks...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green.shade100,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 95, 228, 99),
          centerTitle: true,
          title: const Text('Your Restaurant Cart'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              buildSearchBar(),
              const SizedBox(height: 10),
              SizedBox(
                 width: 340,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    return Container(
                     margin: const EdgeInsets.only( top: 10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Spacer(),
                          Column(
                            children: [
                              const Icon(Icons.fastfood, size: 30, color: Colors.white),
                              const SizedBox(height: 15),
                              GestureDetector(
            onTap: () async {
              // Show a dialog to confirm deletion
              bool deleteConfirmed = await showDialog(
                context: context,
                builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text('Do you want to delete ${cartItem['Food Name']} for N\$ ${cartItem['Price']}?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false to indicate cancel
                },
                child: Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true to indicate confirmation
                },
                child: Text('YES'),
              ),
            ],
          );
                },
              );
          
              // If deletion is confirmed, remove the item from Firestore
              if (deleteConfirmed == true) {
                String orderId = cartItem['Order Id'];
                QuerySnapshot querySnapshot = await _firestore
            .collection('Order Tiles')
            .where('Order Id', isEqualTo: orderId)
            .get();
                querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
                });
                print('$orderId Deleted');
                _fetchCartItems();
              }
            },
            child: Container(
              child: const Icon(Icons.delete, color: Colors.red,),
            ),
          ),
          
          
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 100,
                            child: Text(
                              '${cartItem['Food Name']}\n\n${cartItem['Created Time And Date']}',
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              const Text(
            "Restaurant\n approval",
            style: TextStyle(color: Colors.white, fontSize: 11),
            textAlign: TextAlign.center,
          ),
              GestureDetector(
                      onTap: () {
                       if(cartItem['Customer Confirmation']== false || cartItem['Restaurant Approval'] == false){
                        toggleCustomerConfirmation(cartItem['Order Id'], cartItem['Restaurant Approval']);
                       }
                      },
                child: cartItem['Restaurant Approval'] 
                    ? Icon(Icons.check_box, color: Colors.white, size: 20)
                   : Icon(Icons.check_box_outline_blank, color: Colors.white, size: 20),
                 ),
          Text(cartItem['Restaurant Approval']? "Done" : "Pending",
              style: TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
                          const Spacer(),
                          Column(
                            children: [
                           const   Text(
                           "Customer\n confirmation",
                            style: TextStyle(color: Colors.white, fontSize: 11),
                           textAlign: TextAlign.center,
                           ),
          
                 cartItem['Customer Confirmation'] 
                    ? const Icon(Icons.check_box, color: Colors.white, size: 20)
                   : const Icon(Icons.check_box_outline_blank, color: Colors.white, size: 20),
                   Text(cartItem['Customer Confirmation']  ? "Done" : "Pending",
                   style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              const Icon(Icons.credit_card, size: 20, color: Colors.white),
                              Text(
                                "N\$ ${cartItem['Price']}",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.confirmation_num, size: 20, color: Colors.white),
                              Text("${cartItem['Order Id']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
}

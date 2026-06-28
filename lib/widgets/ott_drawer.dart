import 'package:flutter/material.dart';  
import 'package:go\_router/go\_router.dart';  
import 'package:netmirror/data/options.dart'; 

class OTTModel {  
final String name;  
final String image;  
final String route;  
const OTTModel({  
required this.name,  
required this.image,  
required this.route,  
});  
} 

const ottList = \[  
OTTModel(  
name: "Netflix",  
image: "assets/ott-list/nf.webp",  
route: "/nf-home",  
),  
OTTModel(  
name: "Prime Video",  
image: "assets/ott-list/pv.jpg",  
route: "/pv-home",  
),  
OTTModel(  
name: "Jio Hotstar",  
image: "assets/ott-list/jio-hotstar.jpg",  
route: "/hotstar-home",  
),  
\]; 

int getOttIndexFromRoute(String route) {  
for (int i = 0; i < ottList.length; i++) {  
if (ottList\[i\].route == route) {  
return i;  
}  
}  
return -1;  
} 

class OttDrawer extends StatefulWidget {  
final int selectedOtt;  
const OttDrawer({super.key, this.selectedOtt = 0}); 

@override  
State createState() => \_OttDrawerState();  
} 

class \_OttDrawerState extends State {  
// Variabile per memorizzare quale elemento ha il focus del telecomando  
int? \_focusedIndex; 

@override  
Widget build(BuildContext context) {  
// Ottimizzato per TV: rimosso il foglio trascinabile e usato un Dialog/Menu fisso  
return Container(  
color: Colors.black.withValues(alpha: 0.95),  
padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),  
child: Column(  
mainAxisSize: MainAxisSize.min,  
children: \[  
const Padding(  
padding: EdgeInsets.only(bottom: 20),  
child: Text(  
"Seleziona una Piattaforma",  
style: TextStyle(  
color: Colors.white,  
fontSize: 24,  
fontWeight: FontWeight.bold,  
),  
),  
),  
Expanded(  
child: GridView.builder(  
itemCount: ottList.length,  
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(  
crossAxisCount: 3, // Portato a 3 colonne per il formato 16:9 delle TV  
childAspectRatio: 1.5,  
crossAxisSpacing: 15,  
mainAxisSpacing: 15,  
),  
itemBuilder: (context, index) {  
final isSelected = widget.selectedOtt == index;  
final isFocused = \_focusedIndex == index; 

return Focus(  
onFocusChange: (hasFocus) {  
setState(() {  
if (hasFocus) {  
\_focusedIndex = index;  
} else if (\_focusedIndex == index) {  
\_focusedIndex = null;  
}  
});  
},  
child: GestureDetector(  
onTap: () {  
Navigator.of(context).pop(); // Chiude il menu sulla TV  
if (widget.selectedOtt != index) {  
SettingsOptions.currentScreen = ottList\[index\].route;  
GoRouter.of(context).go(ottList\[index\].route);  
}  
},  
child: AnimatedContainer(  
duration: const Duration(milliseconds: 200),  
// Selezionato o Evidenziato dal telecomando, si ingrandisce leggermente  
transform: isFocused  
? Matrix4.identity().scaled(1.05)  
: Matrix4.identity(),  
decoration: BoxDecoration(  
borderRadius: BorderRadius.circular(12),  
border: Border.all(  
color: isFocused  
? Colors.yellow // Bordo Giallo quando ci sei sopra col telecomando  
: isSelected  
? Colors.white // Bordo Bianco se è quella attiva  
: Colors.transparent,  
width: isFocused ? 4 : 2,  
),  
boxShadow: isFocused  
? \[  
BoxShadow(  
color: Colors.yellow.withValues(alpha: 0.3),  
blurRadius: 10,  
spreadRadius: 2,  
)  
\]  
: \[\],  
),  
child: ClipRRect(  
borderRadius: BorderRadius.circular(10),  
child: Image.asset(  
ottList\[index\].image,  
fit: BoxFit.cover,  
),  
),  
),  
),  
);  
},  
),  
),  
\],  
),  
);  
}  
}
import 'package:flutter/cupertino.dart';

//ΑΥΤΟ ΤΟ ΚΟΜΜΑΤΙ ΑΦΟΡΑ ΤΙΣ ΣΥΝΘΕΣΕΙΣ ΠΟΥ ΘΑ ΕΜΦΑΝΙΖΟΝΤΑΙ ΓΙΑ ΤΗΝ ΚΑΘΕ ΟΜΆΔΑ

class Starting11Display extends StatelessWidget {
  const Starting11Display({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text("Coming Soon...",style: TextStyle(fontSize: 25),),
    );
  }
}

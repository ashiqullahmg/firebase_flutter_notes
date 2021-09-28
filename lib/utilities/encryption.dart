import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_flutter_notes/networking/database.dart';
class Encryption{
final key = encrypt.Key.fromLength(32);


   doEncryption (String text){
     final iv = encrypt.IV.fromUtf8(getKey());
     final encryptor = encrypt.Encrypter(encrypt.AES(key));
     return encryptor.encrypt(text, iv: iv);
   }

    doDecryption (String query){
      final iv = encrypt.IV.fromUtf8(getKey());
      final encryptor = encrypt.Encrypter(encrypt.AES(key));
      return encryptor.decrypt64(query, iv: iv);
   }

   String getKey(){
     String modifiedKey = "";
     for( int i = 0 ; i < 16 ; i++){
       modifiedKey = modifiedKey+ Database.userUid.toString()[i];
     }
     return modifiedKey;
   }
}
import 'package:objectbox/objectbox.dart';

@Entity()
class Person {
  @Id()
  int id;
  String name;
  String location;

  Person({this.id = 0, required this.name, required this.location});
}

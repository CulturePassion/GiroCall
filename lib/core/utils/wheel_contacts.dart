import '../../shared/models/contact.dart';
import '../constants.dart';
import 'weighting_utils.dart';

/// Picks up to [Constants.maxWheelSlices] contacts, preferring overdue people.
List<Contact> selectWheelContacts(List<Contact> contacts) {
  if (contacts.length <= Constants.maxWheelSlices) return contacts;

  final weights = computeWheelWeights(contacts);
  final indices = List.generate(contacts.length, (index) => index);
  indices.sort((a, b) => weights[b].compareTo(weights[a]));

  return indices
      .take(Constants.maxWheelSlices)
      .map((index) => contacts[index])
      .toList();
}

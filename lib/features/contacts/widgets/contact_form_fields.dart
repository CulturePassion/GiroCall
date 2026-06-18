import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/constants.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/models/contact_tag.dart';
import '../../../shared/widgets/phone_formatter.dart';
import '../../../shared/widgets/tag_selector.dart';

/// iPhone-style contact form shared across add, edit, and QR scan flows.
class ContactFormData {
  String firstName = '';
  String lastName = '';
  String phone = '';
  String secondaryPhone = '';
  String email = '';
  String company = '';
  String jobTitle = '';
  String website = '';
  String notes = '';
  String addressLine1 = '';
  String addressLine2 = '';
  String city = '';
  String state = '';
  String postalCode = '';
  String country = '';
  DateTime? birthday;
  ContactTag? tag;
  int frequencyDays = Constants.defaultTargetFrequencyDays;
  int? relationshipScore;
  bool syncToDevice = true;
  bool isFavorite = false;

  void applyFromDraft({
    String? firstName,
    String? lastName,
    String? phone,
    String? secondaryPhone,
    String? email,
    String? company,
    String? jobTitle,
    String? website,
    String? notes,
    String? addressLine1,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    DateTime? birthday,
  }) {
    if (firstName != null) this.firstName = firstName;
    if (lastName != null) this.lastName = lastName;
    if (phone != null) this.phone = phone;
    if (secondaryPhone != null) this.secondaryPhone = secondaryPhone;
    if (email != null) this.email = email;
    if (company != null) this.company = company;
    if (jobTitle != null) this.jobTitle = jobTitle;
    if (website != null) this.website = website;
    if (notes != null) this.notes = notes;
    if (addressLine1 != null) this.addressLine1 = addressLine1;
    if (city != null) this.city = city;
    if (state != null) this.state = state;
    if (postalCode != null) this.postalCode = postalCode;
    if (country != null) this.country = country;
    if (birthday != null) this.birthday = birthday;
  }

  void applyFromContact(Contact contact) {
    firstName = contact.firstName ?? '';
    lastName = contact.lastName ?? '';
    phone = contact.phone;
    secondaryPhone = contact.secondaryPhone ?? '';
    email = contact.email ?? '';
    company = contact.company ?? '';
    jobTitle = contact.jobTitle ?? '';
    website = contact.website ?? '';
    notes = contact.notes ?? '';
    addressLine1 = contact.addressLine1 ?? '';
    addressLine2 = contact.addressLine2 ?? '';
    city = contact.city ?? '';
    state = contact.state ?? '';
    postalCode = contact.postalCode ?? '';
    country = contact.country ?? '';
    birthday = contact.birthday;
    tag = contact.tag;
    frequencyDays = contact.targetFrequencyDays;
    relationshipScore = contact.relationshipScore;
    syncToDevice = contact.syncToDevice;
    isFavorite = contact.isFavorite;
  }

  String? validate() {
    if (firstName.trim().isEmpty && lastName.trim().isEmpty) {
      return 'Please enter a first or last name.';
    }
    if (!PhoneFormatter.looksValid(PhoneFormatter.normalize(phone.trim()))) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }

  String get displayName => Contact.buildDisplayName(
        firstName: firstName,
        lastName: lastName,
      );

  Contact toContact({
    required String userId,
    String? id,
    String? deviceNativeId,
    DateTime? lastCalledAt,
    int? relationshipScoreOverride,
  }) {
    final normalized = PhoneFormatter.normalize(phone.trim());
    return Contact(
      id: id,
      userId: userId,
      name: displayName,
      phone: normalized,
      firstName: firstName.trim().isEmpty ? null : firstName.trim(),
      lastName: lastName.trim().isEmpty ? null : lastName.trim(),
      email: email.trim().isEmpty ? null : email.trim(),
      company: company.trim().isEmpty ? null : company.trim(),
      jobTitle: jobTitle.trim().isEmpty ? null : jobTitle.trim(),
      birthday: birthday,
      secondaryPhone: secondaryPhone.trim().isEmpty
          ? null
          : PhoneFormatter.normalize(secondaryPhone.trim()),
      website: website.trim().isEmpty ? null : website.trim(),
      notes: notes.trim().isEmpty ? null : notes.trim(),
      addressLine1: addressLine1.trim().isEmpty ? null : addressLine1.trim(),
      addressLine2: addressLine2.trim().isEmpty ? null : addressLine2.trim(),
      city: city.trim().isEmpty ? null : city.trim(),
      state: state.trim().isEmpty ? null : state.trim(),
      postalCode: postalCode.trim().isEmpty ? null : postalCode.trim(),
      country: country.trim().isEmpty ? null : country.trim(),
      tag: tag,
      targetFrequencyDays: frequencyDays,
      relationshipScore: relationshipScoreOverride ?? relationshipScore,
      deviceNativeId: deviceNativeId,
      syncToDevice: syncToDevice,
      lastCalledAt: lastCalledAt,
      isFavorite: isFavorite,
    );
  }
}

class ContactFormFields extends StatefulWidget {
  final ContactFormData data;
  final VoidCallback onChanged;
  final bool showRelationshipExtras;
  final bool showSyncToggle;

  const ContactFormFields({
    super.key,
    required this.data,
    required this.onChanged,
    this.showRelationshipExtras = true,
    this.showSyncToggle = true,
  });

  @override
  State<ContactFormFields> createState() => _ContactFormFieldsState();
}

class _ContactFormFieldsState extends State<ContactFormFields> {
  late final Map<String, TextEditingController> _controllers;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      'firstName': TextEditingController(text: widget.data.firstName),
      'lastName': TextEditingController(text: widget.data.lastName),
      'phone': TextEditingController(text: widget.data.phone),
      'secondaryPhone': TextEditingController(text: widget.data.secondaryPhone),
      'email': TextEditingController(text: widget.data.email),
      'company': TextEditingController(text: widget.data.company),
      'jobTitle': TextEditingController(text: widget.data.jobTitle),
      'website': TextEditingController(text: widget.data.website),
      'notes': TextEditingController(text: widget.data.notes),
      'addressLine1': TextEditingController(text: widget.data.addressLine1),
      'addressLine2': TextEditingController(text: widget.data.addressLine2),
      'city': TextEditingController(text: widget.data.city),
      'state': TextEditingController(text: widget.data.state),
      'postalCode': TextEditingController(text: widget.data.postalCode),
      'country': TextEditingController(text: widget.data.country),
    };
    _initialized = true;
  }

  @override
  void didUpdateWidget(ContactFormFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_initialized) return;
    _syncController('firstName', widget.data.firstName);
    _syncController('lastName', widget.data.lastName);
    _syncController('phone', widget.data.phone);
  }

  void _syncController(String key, String value) {
    final controller = _controllers[key]!;
    if (controller.text != value) {
      controller.text = value;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _update(String field, String value) {
    switch (field) {
      case 'firstName':
        widget.data.firstName = value;
      case 'lastName':
        widget.data.lastName = value;
      case 'phone':
        widget.data.phone = value;
      case 'secondaryPhone':
        widget.data.secondaryPhone = value;
      case 'email':
        widget.data.email = value;
      case 'company':
        widget.data.company = value;
      case 'jobTitle':
        widget.data.jobTitle = value;
      case 'website':
        widget.data.website = value;
      case 'notes':
        widget.data.notes = value;
      case 'addressLine1':
        widget.data.addressLine1 = value;
      case 'addressLine2':
        widget.data.addressLine2 = value;
      case 'city':
        widget.data.city = value;
      case 'state':
        widget.data.state = value;
      case 'postalCode':
        widget.data.postalCode = value;
      case 'country':
        widget.data.country = value;
    }
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(title: 'Name', icon: Icons.person_outline),
        TextField(
          controller: _controllers['firstName'],
          decoration: const InputDecoration(labelText: 'First name'),
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => _update('firstName', v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controllers['lastName'],
          decoration: const InputDecoration(labelText: 'Last name'),
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => _update('lastName', v),
        ),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'Phone', icon: Icons.phone_outlined),
        TextField(
          controller: _controllers['phone'],
          decoration: const InputDecoration(labelText: 'Mobile'),
          keyboardType: TextInputType.phone,
          onChanged: (v) => _update('phone', v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controllers['secondaryPhone'],
          decoration: const InputDecoration(labelText: 'Work / other'),
          keyboardType: TextInputType.phone,
          onChanged: (v) => _update('secondaryPhone', v),
        ),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'Email', icon: Icons.email_outlined),
        TextField(
          controller: _controllers['email'],
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => _update('email', v),
        ),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'Work', icon: Icons.business_outlined),
        TextField(
          controller: _controllers['company'],
          decoration: const InputDecoration(labelText: 'Company'),
          onChanged: (v) => _update('company', v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controllers['jobTitle'],
          decoration: const InputDecoration(labelText: 'Job title'),
          onChanged: (v) => _update('jobTitle', v),
        ),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'Birthday', icon: Icons.cake_outlined),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            data.birthday == null
                ? 'Add birthday'
                : '${data.birthday!.month}/${data.birthday!.day}/${data.birthday!.year}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: data.birthday ?? DateTime(1990, 1, 1),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => data.birthday = picked);
              widget.onChanged();
            }
          },
        ),
        const SizedBox(height: 16),
        const _SectionHeader(
            title: 'Address', icon: Icons.location_on_outlined),
        TextField(
          controller: _controllers['addressLine1'],
          decoration: const InputDecoration(labelText: 'Street'),
          onChanged: (v) => _update('addressLine1', v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controllers['addressLine2'],
          decoration: const InputDecoration(labelText: 'Apt / suite'),
          onChanged: (v) => _update('addressLine2', v),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controllers['city'],
                decoration: const InputDecoration(labelText: 'City'),
                onChanged: (v) => _update('city', v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controllers['state'],
                decoration: const InputDecoration(labelText: 'State'),
                onChanged: (v) => _update('state', v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controllers['postalCode'],
                decoration: const InputDecoration(labelText: 'ZIP'),
                onChanged: (v) => _update('postalCode', v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controllers['country'],
                decoration: const InputDecoration(labelText: 'Country'),
                onChanged: (v) => _update('country', v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'More', icon: Icons.notes_outlined),
        TextField(
          controller: _controllers['website'],
          decoration: const InputDecoration(labelText: 'Website'),
          keyboardType: TextInputType.url,
          onChanged: (v) => _update('website', v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controllers['notes'],
          decoration: const InputDecoration(
            labelText: 'Notes',
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          onChanged: (v) => _update('notes', v),
        ),
        if (widget.showRelationshipExtras) ...[
          const SizedBox(height: 24),
          Text('Relationship', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TagSelector(
            selected: data.tag,
            onChanged: (tag) {
              setState(() => data.tag = tag);
              widget.onChanged();
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Call every ${data.frequencyDays} days',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Slider(
            value: data.frequencyDays.toDouble(),
            min: 7,
            max: 365,
            divisions: 358,
            activeColor: AppColors.primaryTeal,
            label: '${data.frequencyDays} days',
            onChanged: (value) {
              setState(() => data.frequencyDays = value.round());
              widget.onChanged();
            },
          ),
        ],
        if (widget.showSyncToggle) ...[
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sync to phone contacts'),
            subtitle: const Text(
              'Keep this person in your iPhone or Android address book',
            ),
            value: data.syncToDevice,
            onChanged: (value) {
              setState(() => data.syncToDevice = value);
              widget.onChanged();
            },
          ),
        ],
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Add to favorites'),
          secondary: Icon(
            data.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: data.isFavorite ? Colors.red : null,
          ),
          value: data.isFavorite,
          onChanged: (value) {
            setState(() => data.isFavorite = value);
            widget.onChanged();
          },
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryTeal),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

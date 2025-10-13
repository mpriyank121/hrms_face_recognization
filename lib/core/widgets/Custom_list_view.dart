// widgets/universal_section_list.dart
import 'package:flutter/material.dart';

class CustomListView<T> extends StatelessWidget {
  final Map<String, List<T>> groupedItems;
  final String Function(T item) getName;
  final String Function(T item) getRole;
  final String Function(T item) getSalary;
  final String Function(T item) getImage;
  final void Function(T item)? onTap;

  const CustomListView({
    Key? key,
    required this.groupedItems,
    required this.getName,
    required this.getRole,
    required this.getSalary,
    required this.getImage,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: groupedItems.keys.length,
      itemBuilder: (context, sectionIndex) {
        String sectionTitle = groupedItems.keys.elementAt(sectionIndex);
        List<T> items = groupedItems[sectionTitle]!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sectionTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...items.map((item) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(getImage(item)),
                  ),
                  title: Text(getName(item), style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(getRole(item)),
                  trailing: Text(getSalary(item), style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () => onTap?.call(item),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

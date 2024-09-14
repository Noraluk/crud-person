import 'package:flutter/material.dart';
import 'package:flutter_app/models/person.dart';

class PeopleWidget extends StatefulWidget {
  const PeopleWidget({super.key});

  @override
  State<PeopleWidget> createState() => _PeopleWidgetState();
}

class _PeopleWidgetState extends State<PeopleWidget> {
  final _scrollController = ScrollController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final List<PersonModel> _items = [];
  final List<PersonModel> _displayItems = [];
  bool _isLoadingMore = false;
  bool _hasNext = true;
  int offset = 0;
  int limit = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkIfMoreItemsNeeded() {
    if (_scrollController.position.maxScrollExtent <=
        _scrollController.position.viewportDimension) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() async {
    if (_isLoadingMore || !_hasNext) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      if (_items.length > offset) {
        if (offset + limit > _items.length) {
          _displayItems.addAll(_items.sublist(offset, _items.length));
          offset = _items.length;
        } else {
          _displayItems.addAll(_items.sublist(offset, offset + limit));
          offset += limit;
        }
      }

      _isLoadingMore = false;
    });

    if (_displayItems.length < _items.length) {
      _checkIfMoreItemsNeeded();
    } else {
      setState(() {
        _hasNext = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreItems();
    }
  }

  void _createItem() async {
    setState(() {
      _items.add(
        PersonModel(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
        ),
      );
      _hasNext = true;
    });

    _checkIfMoreItemsNeeded();
  }

  void _updateItem(int index) async {
    PersonModel person = PersonModel(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );

    setState(() {
      _displayItems[index] = person;
      _items[index] = person;
    });
  }

  void _removeItem(int index) async {
    setState(() {
      _displayItems.removeAt(index);
      _items.removeAt(index);
      offset = _displayItems.length;
    });
  }

  void _showInputDialog(void Function() submitFn) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Alert'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                  ),
                ),
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  submitFn();
                  _firstNameController.clear();
                  _lastNameController.clear();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _showInputDialog(() => _createItem()),
          icon: const Icon(Icons.add),
        ),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
          controller: _scrollController,
          itemCount: _displayItems.length + 1,
          itemBuilder: (context, index) {
            if (index == _displayItems.length) {
              return _isLoadingMore
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox();
            } else if (_displayItems.length <= _items.length) {
              return ListTile(
                onLongPress: () => _removeItem(index),
                onTap: () => _showInputDialog(() => _updateItem(index)),
                title: Center(
                  child: Text(
                    '${_displayItems[index].firstName} ${_displayItems[index].lastName}',
                  ),
                ),
              );
            }
            return const SizedBox();
          }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_town/screens/issues/bloc/issues_bloc.dart';

class FilterResults extends StatelessWidget {
  const FilterResults({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> _chips = [
      InputChip(
        label: const Text('Current Location'),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (sheetContext) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Issues at'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          RaisedButton.icon(
                            icon: Icon(Icons.home),
                            label: Text('Home'),
                            onPressed: () {
                              BlocProvider.of<IssuesBloc>(context)
                                  .add(GetIssuesAtHomeLocation());
                              Navigator.pop(context);
                            },
                          ),
                          RaisedButton.icon(
                            icon: Icon(Icons.location_on),
                            label: Text('Current Location'),
                            onPressed: () {
                              BlocProvider.of<IssuesBloc>(context)
                                  .add(GetIssuesAtCurrentLocation());
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                );
              });
        },
      ),
      Chip(
        label: Text('hello'),
      ),
      Chip(
        label: Text('hello'),
      ),
      Chip(
        label: Text('hello'),
      ),
      Chip(
        label: Text('hello'),
      ),
      Chip(
        label: Text('hello'),
      ),
    ];
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(10),
        shrinkWrap: true,
        itemCount: _chips.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: _chips[index]);
        },
      ),
    );
  }
}

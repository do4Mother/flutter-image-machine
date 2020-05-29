import 'package:barcode_scan/platform_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_machine/components/listmachine.dart';
import 'package:image_machine/models/machine.dart';
import 'package:image_machine/pages/add_machine.dart';
import 'package:image_machine/pages/detail.dart';
import 'package:image_machine/provider/machine_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context){
        return CupertinoAlertDialog(
          title: Text('Something Wrong'),
          content: Text('No barcode / qr code number exists in App'),
          actions: <Widget>[
            CupertinoButton(
              child: Text('Ok'),
              onPressed: (){
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }

  Future<void> scanBarcode(BuildContext context) async {
    var state = Provider.of<MachineProvider>(context, listen: false);
    try {
      var result = await BarcodeScanner.scan();
      print(result.rawContent);
      List<Machine> machine = await state.readBarcode(result.rawContent);
      if(machine.isNotEmpty){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Detail(data: machine[0])),
        );
      } else {
        Navigator.pop(context);
        showAlert(context);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxisScrolled){
          return <Widget> [
            SliverAppBar(
              expandedHeight: 200.0,
              pinned: true,
              leading: IconButton(
                icon: Icon(CupertinoIcons.ellipsis),
                onPressed: (){
                  Scaffold.of(context).openDrawer();
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text('Image Machine', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24
                ),),
              ),
            )
          ];
        }, 
        body: HomePageBody()
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddMachine()));
        },
        child: Icon(Icons.add),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: Column(
            children: <Widget>[
              DrawerHeader(
                child: Center(
                  child: Text('Created by Singgih Putra'),
                ),
              ),
              ListTile(
                title: Text('List Machine'),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Scan Barcode'),
                onTap: (){
                  scanBarcode(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<MachineProvider>(
        builder: (context, state, child) {
          return FutureBuilder<List<Machine>>(
            future: state.read(),
            builder: (context, snapshot){
              if(snapshot.hasData){
                if(snapshot.data.length == 0){
                  return Center(
                    child: Text('No Data'),
                  );
                }
                return listMachines(snapshot.data);
              }

              return Center(
                child: Text('loading..'),
              );
            },
          );
        },
      ),
    );
  }

  Widget listMachines(List<Machine> data) {
    return ListView(
      padding: EdgeInsets.all(8.0),
      children: List.generate(data.length, (index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListMachine(data: data[index]),
      )),
    );
  }
}
// ignore_for_file: prefer__literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_books/helper/dbhelper.dart';

class PelangganForm extends StatefulWidget {
  PelangganForm({Key? key}) : super(key: key);

  @override
  State<PelangganForm> createState() => _PelangganFormState();
}

class _PelangganFormState extends State<PelangganForm> {
  late TextEditingController txtID, txtNama, txtTgllhr;
  String gender = '';

  _PelangganFormState() {
    txtID = TextEditingController();
    txtNama = TextEditingController();
    txtTgllhr = TextEditingController();

    lastID().then((value) {
      txtID.text = '${value + 1}';
    });
  }

  Widget txtInputID() => TextFormField(
      controller: txtID,
      readOnly: true,
      decoration: InputDecoration(labelText: 'ID Pelanggan'));

  Widget txtInputNama() => TextFormField(
      controller: txtNama,
      readOnly: false,
      decoration: InputDecoration(labelText: 'Nama Pelanggan'));
  Widget dropDownGender() => DropdownButtonFormField(
          decoration: InputDecoration(labelText: 'Jenis Kelamin'),
          isExpanded: true,
          value: gender,
          onChanged: (g) {
            gender = '$g';
          },
          items: [
            DropdownMenuItem(child: Text('Pilih Gender'), value: ''),
            // ignore: prefer__ructors
            DropdownMenuItem(
              child: Text('Laki-laki'),
              value: 'L',
            ),
            DropdownMenuItem(
              child: Text('Perempuan'),
              value: 'P',
            ),
          ]);

  DateTime initTgllhr() {
    try {
      return DateFormat('yyyy-mm-dd').parse(txtTgllhr.value.text);
    } catch (e) {}
    return DateTime.now();
  }

  Widget txtInputTglLhr() => TextFormField(
        readOnly: true,
        decoration: InputDecoration(labelText: 'Tanggal Lahir'),
        controller: txtTgllhr,
        onTap: () async {
          final tgl = await showDatePicker(
              context: context,
              initialDate: initTgllhr(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now());
          if (tgl != null) {
            txtTgllhr.text = DateFormat('yyyy-mm-dd').format(tgl);
          }
        },
      );
  Widget aksiSimpan() => TextButton(
        onPressed: () {
          simpanData().then((h) {
            var pesan = h == true ? 'Sukses Simpan' : 'Gagal Simpan';

            showDialog(
                context: context,
                builder: (bc) => AlertDialog(
                      title: Text('Simpan Pelanggan'),
                      content: Text('$pesan'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Oke'))
                      ],
                    ));
          });
        },
        child: Text('Simpan', style: TextStyle(color: Colors.white)),
      );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Pelanggan'),
        actions: [aksiSimpan()],
      ),
      body: Padding(
        padding: EdgeInsets.all(18.0),
        child: Column(children: [
          txtInputID(),
          txtInputNama(),
          dropDownGender(),
          txtInputTglLhr()
        ]),
      ),
    );
  }

  Future<int> lastID() async {
    try {
      final _db = await DBHelper.db();
      final query = 'SELECT MAX(id) as id FROM pelanggan';
      final ls = (await _db?.rawQuery(query))!;
      if (ls.length > 0) {
        return int.tryParse('${ls[0]['id']}') ?? 0;
      }
    } catch (e) {
      print('error lastid $e');
    }
    return 0;
  }

  Future<bool> simpanData() async {
    try {
      final _db = await DBHelper.db();
      var data = {
        'id': txtID.value.text,
        'nama': txtNama.value.text,
        'gender': gender,
        'tgl_lhr': txtTgllhr.value.text
      };
      final id = await _db?.insert('pelanggan', data);
      return id! > 0;
    } catch (e) {
      return false;
    }
  }
}

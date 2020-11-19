import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static String tag = '/home';

  @override
  Widget build(BuildContext context) {
    var snapshots = Firestore.instance
        .collection('todo')
        .where('excluido', isEqualTo: false)
        .orderBy('data')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('JOBZ HOME'),
      ),
      backgroundColor: Colors.grey[200],
      body: StreamBuilder(
        stream: snapshots,
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.documents.length == 0) {
            return Center(child: Text('Nenhuma jobz ainda'));
          }

          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (BuildContext context, int i) {
              var doc = snapshot.data.documents[i];
              var item = doc.data;

              // print('todo/${doc.reference.documentID}');

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(5),
                child: ListTile(
                  isThreeLine: true,
                  leading: IconButton(
                    icon: Icon(
                      item['favorito']
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      size: 32,
                    ),
                    onPressed: () => doc.reference.updateData({
                      'favorito': !item['favorito'],
                    }),
                  ),
                  title: Text(item['titulo']),
                   
                  subtitle: Text(item['descricao']),
                  trailing: CircleAvatar(
                    backgroundColor: Colors.red[300],
                    foregroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => doc.reference.updateData({
                        'excluido': true,
                      }),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => modalCreate(context),
        tooltip: 'Adicionar novo',
        child: Icon(Icons.add),
      ),
    );
  }

  modalCreate(BuildContext context) {
    var form = GlobalKey<FormState>();

    var titulo = TextEditingController();
    var descricao = TextEditingController();
    var resumo = TextEditingController();


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cadastrar novo serviço'),
          content: Form(
            key: form,
            child: Container(
              //height: MediaQuery.of(context).size.height / 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Título'),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Ex.: Manutenção Predial',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    controller: titulo,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Este campo não pode ser vazio';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),
                  Text('Descrição'),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '(Opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    controller: descricao,
                  ),




Text('Resumo'),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '(Opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    controller: resumo,
                  ),








                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            FlatButton(
              onPressed: () async {
                if (form.currentState.validate()) {
                  await Firestore.instance.collection('todo').add({
                    'titulo': titulo.text,
                    'descricao': descricao.text,
                    'resumo' : resumo.text,
                    'favorito': false,
                    'data': Timestamp.now(),
                    'excluido': false,
                  });

                  Navigator.of(context).pop();
                }
              },
              color: Colors.green,
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}

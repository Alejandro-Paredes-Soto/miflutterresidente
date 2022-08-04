import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showOptionPhoto(
    BuildContext context, Function() onPressedTake, Function() onPressedGalery) {
  showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                  child: Text(
                    'Tomar fotografía',
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).iconTheme.color),
                    textScaleFactor: 1.0,
                  ),
                  onPressed: onPressedTake),
              CupertinoActionSheetAction(
                child: Text(
                  'Escoger de la galería',
                  style: TextStyle(
                      fontSize: 20.0, color: Theme.of(context).iconTheme.color),
                  textScaleFactor: 1.0,
                ),
                onPressed: onPressedGalery,
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textScaleFactor: 1.0,
              ),
            ),
          ));
}

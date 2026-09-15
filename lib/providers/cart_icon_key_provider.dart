import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Clé de l'icône panier de la barre de navigation, pour l'animation d'ajout.
final cartIconKeyProvider = Provider<GlobalKey>((ref) => GlobalKey());

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/view-models/app_vm.dart';
import 'package:memo/core/faults/exceptions/base_exception.dart';
import 'package:memo/domain/services/collection_purchase_services.dart';

final collectionPurchaseVM = StateNotifierProvider.family.autoDispose<CollectionPurchaseVM, PurchaseState, String>(
  (ref, collectionId) => CollectionPurchaseVMImpl(
    collectionId: collectionId,
    collectionPurchaseServices: ref.read(purchaseServices),
  ),
);

abstract class CollectionPurchaseVM extends StateNotifier<PurchaseState> {
  CollectionPurchaseVM(super._state);

  /// Purchases a collection.
  Future<void> purchase();
}

class CollectionPurchaseVMImpl extends CollectionPurchaseVM {
  CollectionPurchaseVMImpl({
    required this.collectionId,
    required this.collectionPurchaseServices,
  }) : super(PurchaseInfoLoading()) {
    _loadDependencies();
  }

  final String collectionId;
  final CollectionPurchaseServices collectionPurchaseServices;

  Future<void> _loadDependencies() async {
    state = PurchaseInfoLoading();

    try {
      final isPurchased = await collectionPurchaseServices.isPurchased(id: collectionId);
      state = PurchaseInfoLoaded(isPurchased: isPurchased);
    } on BaseException catch (exception) {
      state = PurchaseInfoLoadingFailed(exception);
    }
  }

  @override
  Future<void> purchase() async {
    state = ProcessingPurchase();

    try {
      await collectionPurchaseServices.purchaseCollection(id: collectionId);
      state = PurchaseSuccess();
    } on BaseException catch (exception) {
      state = PurchaseFailed(exception);
    }
  }
}

abstract class PurchaseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PurchaseInfoLoading extends PurchaseState {}

class PurchaseInfoLoadingFailed extends PurchaseState {
  PurchaseInfoLoadingFailed(this.exception);

  final BaseException exception;

  @override
  List<Object?> get props => [exception];
}

class PurchaseInfoLoaded extends PurchaseState {
  PurchaseInfoLoaded({required this.isPurchased});

  final bool isPurchased;

  @override
  List<Object?> get props => [isPurchased];
}

class ProcessingPurchase extends PurchaseInfoLoaded {
  ProcessingPurchase() : super(isPurchased: false);
}

class PurchaseSuccess extends PurchaseInfoLoaded {
  PurchaseSuccess() : super(isPurchased: true);
}

class PurchaseFailed extends PurchaseInfoLoaded {
  PurchaseFailed(this.exception) : super(isPurchased: false);

  final BaseException exception;

  @override
  List<Object?> get props => [exception, ...super.props];
}

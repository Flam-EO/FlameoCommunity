import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/transaction.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';


class TransactionStatusTimeline extends StatefulWidget {

  final MyTransaction transaction;

  const TransactionStatusTimeline({super.key, required this.transaction});

  @override
  State<TransactionStatusTimeline> createState() => _TransactionStatusTimelineState();
}

class _TransactionStatusTimelineState extends State<TransactionStatusTimeline> {

  TransactionStatus? currentTransactionStatus;

  @override
  void initState() {
    super.initState();
    currentTransactionStatus = widget.transaction.status;
  }
  TimelineTile customTimelineTile(TimelineAxis axis, int tileIndex) {
    List<TransactionStatus> statusValues = TransactionStatus.values;
    Color unselectedColor = Theme.of(context).colorScheme.primary;
    Color selectedColor = Theme.of(context).colorScheme.onTertiary;
    bool indicatorSelected = currentTransactionStatus!.index >= tileIndex;
    bool linesSelected = indicatorSelected;

    return TimelineTile(
      axis: axis,
      isFirst: tileIndex == statusValues.indexOf(TransactionStatus.pending),
      isLast: tileIndex == statusValues.indexOf(TransactionStatus.pickedup)
              || tileIndex == statusValues.indexOf(TransactionStatus.delivered),
      alignment: TimelineAlign.center,
      endChild: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(transactionStatusName(statusValues[tileIndex])),
      ),
      indicatorStyle: indicatorSelected 
      ? IndicatorStyle(color: selectedColor)
      : IndicatorStyle(color: unselectedColor),
      beforeLineStyle: linesSelected
      ? LineStyle(color: selectedColor)
      : LineStyle(color: unselectedColor),
      afterLineStyle: linesSelected
      ? LineStyle(color: selectedColor)
      : LineStyle(color: unselectedColor),
    );
  }

  Widget stateChangeButtons(bool layoutIsThin) {

    // Buttons
    Widget buttonBackward = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
          )
        )
      ),
      onPressed: () async {
        TransactionStatus newStatus = getPreviousStatus(widget.transaction.shippingMethod,
                                                      currentTransactionStatus!);
        bool changeConfirmed = await confirmStateChange(newStatus);

        if (changeConfirmed) {
          setState(() => currentTransactionStatus = newStatus);
          widget.transaction.submitStatus(currentTransactionStatus!);
        }
      },
      child: Text(
        'Volver a ${transactionStatusName(
          getPreviousStatus(widget.transaction.shippingMethod, currentTransactionStatus!)
        )}',
        style: const TextStyle(
          color: Colors.black
        )
      )
    );

    Widget buttonForward = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
          )
        )
      ),
      onPressed: () async {
        TransactionStatus newStatus = getNextStatus(widget.transaction.shippingMethod, currentTransactionStatus!);
        bool changeConfirmed = await confirmStateChange(newStatus);

        if (changeConfirmed) {
          setState(() => currentTransactionStatus = newStatus);
          widget.transaction.submitStatus(currentTransactionStatus!);
        }
      },
      child: Text(
        'Marcar como ${transactionStatusName(
          getNextStatus(widget.transaction.shippingMethod, currentTransactionStatus!)
        )}',
        style: const TextStyle(
          color: Colors.black
        )
      )
    );

    if (layoutIsThin) {
      return Column(
        children: [
          if (currentTransactionStatus!.index != TransactionStatus.pending.index)
            buttonBackward,
          const SizedBox(height: 8.0),
          if (currentTransactionStatus!.index != TransactionStatus.pickedup.index
            && currentTransactionStatus!.index != TransactionStatus.delivered.index)
            Padding(
              padding: const EdgeInsets.only(bottom:8),
              child: buttonForward,
            ),
          const SizedBox(height: 8.0),
        ],
      );
    } else {
      return Row(
        children: [
          if (currentTransactionStatus!.index != TransactionStatus.pending.index)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buttonBackward,
            ),
          const Expanded(child: SizedBox()),
          if (currentTransactionStatus!.index != TransactionStatus.pickedup.index
              && currentTransactionStatus!.index != TransactionStatus.delivered.index)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buttonForward,
            )
        ],
      );
    }
  }

  SizedBox thinLayoutTimeline(ScreenSize screenSize) => SizedBox(
    height: 400,
    width: screenSize.width - 16.0,
    child: Column(
      children: [
        customTimelineTile(TimelineAxis.vertical, TransactionStatus.pending.index),
        if (widget.transaction.shippingMethod == ShippingMethod.pickUp)
          customTimelineTile(TimelineAxis.vertical, TransactionStatus.prepared.index),
        if (
          widget.transaction.shippingMethod == ShippingMethod.sellerShipping
          || widget.transaction.shippingMethod == ShippingMethod.flameoShipping
        )
          customTimelineTile(TimelineAxis.vertical, TransactionStatus.sent.index),
        if (widget.transaction.shippingMethod == ShippingMethod.pickUp)
          customTimelineTile(TimelineAxis.vertical, TransactionStatus.pickedup.index),
        if (
          widget.transaction.shippingMethod == ShippingMethod.sellerShipping
          || widget.transaction.shippingMethod == ShippingMethod.flameoShipping
        )
          customTimelineTile(TimelineAxis.vertical, TransactionStatus.delivered.index),
        const Expanded(child: SizedBox()),
        stateChangeButtons(true)
      ]),
  );

  SizedBox wideLayoutTimeline() => SizedBox(
    height: 170,
    width: 800,
    child: Column(
      children: [
        SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customTimelineTile(TimelineAxis.horizontal, TransactionStatus.pending.index),
              if (widget.transaction.shippingMethod == ShippingMethod.pickUp)
                customTimelineTile(TimelineAxis.horizontal, TransactionStatus.prepared.index),
              if  (
                widget.transaction.shippingMethod == ShippingMethod.sellerShipping
                || widget.transaction.shippingMethod == ShippingMethod.flameoShipping
              )
                customTimelineTile(TimelineAxis.horizontal, TransactionStatus.sent.index),
              if (widget.transaction.shippingMethod == ShippingMethod.pickUp)
                customTimelineTile(TimelineAxis.horizontal, TransactionStatus.pickedup.index),
              if (
                widget.transaction.shippingMethod == ShippingMethod.sellerShipping
                || widget.transaction.shippingMethod == ShippingMethod.flameoShipping
              )
                customTimelineTile(TimelineAxis.horizontal, TransactionStatus.delivered.index),
            ]
          ),
        ),
        const Expanded(child: SizedBox()),
        stateChangeButtons(false)
      ],
    ),
  );

  Future<bool> confirmStateChange(TransactionStatus newStatus) async {
    bool changeConfirmed = await showDialog(context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) => AlertDialog(
            title: Text(
              'Seguro que quieres cambiar el estado a ${transactionStatusName(newStatus)}?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15)
            ),
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: Text('Cancelar', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: Text('OK', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    onPressed: () {
                      Navigator.of(builderContext).pop(true);
                    },
                  ),
                ],
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Personaliza el radio de borde
            ),
          ),
        );
      }
    );
    return changeConfirmed;
  }

  @override
  Widget build(BuildContext context) {

    ScreenSize screenSize = ScreenSize(context);

    return currentTransactionStatus == null
    ? const Loading()
    : screenSize.width <= 816
    ? thinLayoutTimeline(screenSize)
    : wideLayoutTimeline();
  }
}
import 'package:flutter/material.dart';
import 'package:antrun_game/models/stock_model.dart';

class ItemWidget extends StatelessWidget {
  final String stockId;
  final bool isCollected;

  const ItemWidget({
    Key? key,
    required this.stockId,
    this.isCollected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stock = StockDatabase.findById(stockId);

    if (stock == null) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.question_mark, color: Colors.white),
      );
    }

    // 아이템이 이미 수집된 경우 투명하게 표시
    if (isCollected) {
      return Opacity(
        opacity: 0.3,
        child: _buildItemContent(stock),
      );
    }

    return _buildItemContent(stock);
  }

  Widget _buildItemContent(StockModel stock) {
    // 종목 유형에 따른 색상
    Color itemColor;
    IconData itemIcon;

    switch (stock.type) {
      case StockType.stock:
        itemColor = Colors.blue;
        itemIcon = Icons.trending_up;
        break;
      case StockType.crypto:
        itemColor = Colors.orange;
        itemIcon = Icons.currency_bitcoin;
        break;
      case StockType.bond:
        itemColor = Colors.green;
        itemIcon = Icons.account_balance;
        break;
      case StockType.commodity:
        itemColor = Colors.amber;
        itemIcon = Icons.diamond;
        break;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: itemColor.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: itemColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: itemColor.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            itemIcon,
            color: itemColor,
            size: 24,
          ),
          Text(
            stock.symbol,
            style: TextStyle(
              color: itemColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
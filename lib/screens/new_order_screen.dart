import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/customer_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/order_controller.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/payment_condition.dart';
import '../models/order.dart';
import '../utils/formatters.dart';

// ── Cart item ─────────────────────────────────────────────────────────────────

class _CartItem {
  final Product product;
  double quantity = 1;
  double discountPercent = 0;

  _CartItem({required this.product});

  double get subtotal =>
      product.price * quantity * (1 - discountPercent / 100);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  Customer? _customer;
  final List<_CartItem> _items = [];
  PaymentCondition? _paymentCondition;
  double _orderDiscount = 0;
  double _orderSurcharge = 0;
  final _discountCtrl = TextEditingController();
  final _surchargeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // totals
  double get _itemsTotal =>
      _items.fold(0.0, (s, i) => s + i.subtotal);
  double get _discountAmount => _itemsTotal * _orderDiscount / 100;
  double get _surchargeAmount =>
      (_itemsTotal - _discountAmount) * _orderSurcharge / 100;
  double get _total =>
      _itemsTotal - _discountAmount + _surchargeAmount;

  bool get _canSave =>
      _customer != null &&
      _items.isNotEmpty &&
      _paymentCondition != null;

  @override
  void dispose() {
    _discountCtrl.dispose();
    _surchargeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final orderCtrl = context.read<OrderController>();
    final order = Order(
      createdAt: DateTime.now(),
      customerId: _customer!.id,
      customerName: _customer!.name,
      items: _items
          .map((ci) => OrderItem(
                productId: ci.product.id,
                productName: ci.product.name,
                productCode: ci.product.code,
                productUnit: ci.product.unit,
                quantity: ci.quantity,
                unitPrice: ci.product.price,
                discountPercent: ci.discountPercent,
              ))
          .toList(),
      paymentConditionId: _paymentCondition!.id,
      paymentConditionName: _paymentCondition!.name,
      discountPercent: _orderDiscount,
      surchargePercent: _orderSurcharge,
      notes: _notesCtrl.text.trim(),
    );
    orderCtrl.add(order);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido criado com sucesso!')),
    );
  }

  // ── Builder ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Novo Pedido'),
        actions: [
          if (_canSave)
            FilledButton(
              onPressed: _save,
              child: const Text('Salvar'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
            children: [
              // ── Cliente ───────────────────────────────────────────────────
              const _SectionHeader(title: 'Cliente'),
              _CustomerSelector(
                selected: _customer,
                onTap: () => _pickCustomer(),
              ),
              const SizedBox(height: 20),

              // ── Produtos ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _SectionHeader(title: 'Produtos'),
                  TextButton.icon(
                    onPressed: () => _pickProduct(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),
              if (_items.isEmpty)
                _EmptyItemsHint(onTap: _pickProduct)
              else
                ..._items.map((item) => _CartItemTile(
                      item: item,
                      onRemove: () =>
                          setState(() => _items.remove(item)),
                      onChanged: () => setState(() {}),
                    )),
              const SizedBox(height: 20),

              // ── Desconto / Acréscimo ──────────────────────────────────────
              const _SectionHeader(title: 'Ajustes no Pedido'),
              Row(
                children: [
                  Expanded(
                    child: _PercentField(
                      controller: _discountCtrl,
                      label: 'Desconto (%)',
                      icon: Icons.discount_outlined,
                      onChanged: (v) => setState(() =>
                          _orderDiscount = double.tryParse(v) ?? 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PercentField(
                      controller: _surchargeCtrl,
                      label: 'Acréscimo (%)',
                      icon: Icons.add_circle_outline,
                      onChanged: (v) => setState(() =>
                          _orderSurcharge = double.tryParse(v) ?? 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Condição de pagamento ─────────────────────────────────────
              const _SectionHeader(title: 'Condição de Pagamento'),
              _PaymentSelector(
                selected: _paymentCondition,
                onSelect: (pc) =>
                    setState(() => _paymentCondition = pc),
              ),
              const SizedBox(height: 20),

              // ── Observações ───────────────────────────────────────────────
              const _SectionHeader(title: 'Observações'),
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Instruções de entrega, referências...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
              ),
            ],
          ),

          // ── Bottom total bar ──────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _TotalBar(
              itemsTotal: _itemsTotal,
              discount: _orderDiscount,
              discountAmount: _discountAmount,
              surcharge: _orderSurcharge,
              surchargeAmount: _surchargeAmount,
              total: _total,
              canSave: _canSave,
              onSave: _save,
            ),
          ),
        ],
      ),
    );
  }

  // ── Pickers ───────────────────────────────────────────────────────────────

  void _pickCustomer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CustomerPickerSheet(
        onSelect: (c) => setState(() => _customer = c),
      ),
    );
  }

  void _pickProduct() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ProductPickerSheet(
        already: _items.map((i) => i.product.id).toSet(),
        onAdd: (p) => setState(() => _items.add(_CartItem(product: p))),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ── Customer selector ─────────────────────────────────────────────────────────

class _CustomerSelector extends StatelessWidget {
  final Customer? selected;
  final VoidCallback onTap;
  const _CustomerSelector({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
              color: selected != null
                  ? colors.primary
                  : colors.outlineVariant),
          borderRadius: BorderRadius.circular(12),
          color: selected != null
              ? colors.primaryContainer.withOpacity(0.3)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_outline,
              color:
                  selected != null ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: selected == null
                  ? Text('Selecionar cliente',
                      style: TextStyle(color: colors.onSurfaceVariant))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selected!.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        if (selected!.document.isNotEmpty)
                          Text(selected!.document,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant)),
                      ],
                    ),
            ),
            Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Cart item tile ────────────────────────────────────────────────────────────

class _CartItemTile extends StatefulWidget {
  final _CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  const _CartItemTile(
      {required this.item, required this.onRemove, required this.onChanged});

  @override
  State<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<_CartItemTile> {
  late final _qtyCtrl =
      TextEditingController(text: widget.item.quantity.toStringAsFixed(0));
  late final _discCtrl = TextEditingController(
      text: widget.item.discountPercent > 0
          ? widget.item.discountPercent.toStringAsFixed(2)
          : '');

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _discCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final item = widget.item;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.product.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(
                          '${formatCurrency(item.product.price)} / ${item.product.unit}',
                          style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Qty
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    onChanged: (v) {
                      item.quantity = double.tryParse(v) ?? 1;
                      widget.onChanged();
                    },
                    decoration: InputDecoration(
                      labelText: 'Qtd.',
                      suffixText: item.product.unit,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Item discount
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _discCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    onChanged: (v) {
                      item.discountPercent = double.tryParse(v) ?? 0;
                      widget.onChanged();
                    },
                    decoration: InputDecoration(
                      labelText: 'Desc. item',
                      suffixText: '%',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Subtotal
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Subtotal',
                          style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant)),
                      Text(formatCurrency(item.subtotal),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty items hint ──────────────────────────────────────────────────────────

class _EmptyItemsHint extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyItemsHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
              color: colors.outlineVariant, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_shopping_cart_outlined,
                color: colors.primary),
            const SizedBox(width: 8),
            Text('Adicionar produtos',
                style: TextStyle(
                    color: colors.primary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Percent field ─────────────────────────────────────────────────────────────

class _PercentField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const _PercentField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        suffixText: '%',
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }
}

// ── Payment selector ──────────────────────────────────────────────────────────

class _PaymentSelector extends StatelessWidget {
  final PaymentCondition? selected;
  final ValueChanged<PaymentCondition> onSelect;

  const _PaymentSelector(
      {required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final conditions = context.read<OrderController>().paymentConditions;
    final colors = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: conditions.map((pc) {
        final isSel = selected?.id == pc.id;
        return ChoiceChip(
          label: Text(pc.name),
          selected: isSel,
          selectedColor: colors.primaryContainer,
          labelStyle: TextStyle(
            color: isSel ? colors.onPrimaryContainer : colors.onSurface,
            fontWeight:
                isSel ? FontWeight.w600 : FontWeight.normal,
          ),
          onSelected: (_) => onSelect(pc),
        );
      }).toList(),
    );
  }
}

// ── Bottom total bar ──────────────────────────────────────────────────────────

class _TotalBar extends StatelessWidget {
  final double itemsTotal;
  final double discount;
  final double discountAmount;
  final double surcharge;
  final double surchargeAmount;
  final double total;
  final bool canSave;
  final VoidCallback onSave;

  const _TotalBar({
    required this.itemsTotal,
    required this.discount,
    required this.discountAmount,
    required this.surcharge,
    required this.surchargeAmount,
    required this.total,
    required this.canSave,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (discount > 0 || surcharge > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal',
                    style: TextStyle(
                        color: colors.onSurfaceVariant, fontSize: 13)),
                Text(formatCurrency(itemsTotal),
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
            if (discount > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Desconto ${formatPercent(discount)}',
                      style: TextStyle(
                          color: Colors.green.shade700, fontSize: 13)),
                  Text('−${formatCurrency(discountAmount)}',
                      style: TextStyle(
                          color: Colors.green.shade700, fontSize: 13)),
                ],
              ),
            ],
            if (surcharge > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Acréscimo ${formatPercent(surcharge)}',
                      style: TextStyle(
                          color: Colors.orange.shade700, fontSize: 13)),
                  Text('+${formatCurrency(surchargeAmount)}',
                      style: TextStyle(
                          color: Colors.orange.shade700, fontSize: 13)),
                ],
              ),
            ],
            const Divider(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              Text(formatCurrency(total),
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: canSave ? onSave : null,
              child: const Text('Confirmar Pedido',
                  style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Customer picker sheet ─────────────────────────────────────────────────────

class _CustomerPickerSheet extends StatefulWidget {
  final ValueChanged<Customer> onSelect;
  const _CustomerPickerSheet({required this.onSelect});

  @override
  State<_CustomerPickerSheet> createState() =>
      _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = context.read<CustomerController>().search(_query);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: colors.outlineVariant,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const Text('Selecionar Cliente',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                SearchBar(
                  hintText: 'Buscar...',
                  leading: const Icon(Icons.search),
                  onChanged: (v) =>
                      setState(() => _query = v.toLowerCase()),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              controller: scroll,
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16),
              itemBuilder: (ctx, i) {
                final c = filtered[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colors.primaryContainer,
                    child: Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                      style: TextStyle(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  title: Text(c.name,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: c.document.isNotEmpty
                      ? Text(c.document)
                      : null,
                  onTap: () {
                    widget.onSelect(c);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product picker sheet ──────────────────────────────────────────────────────

class _ProductPickerSheet extends StatefulWidget {
  final Set<String> already;
  final ValueChanged<Product> onAdd;

  const _ProductPickerSheet(
      {required this.already, required this.onAdd});

  @override
  State<_ProductPickerSheet> createState() =>
      _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = context.read<ProductController>().search(_query);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: colors.outlineVariant,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const Text('Adicionar Produto',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                SearchBar(
                  hintText: 'Buscar produto...',
                  leading: const Icon(Icons.search),
                  onChanged: (v) =>
                      setState(() => _query = v.toLowerCase()),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              controller: scroll,
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16),
              itemBuilder: (ctx, i) {
                final p = filtered[i];
                final added = widget.already.contains(p.id);
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: added
                          ? colors.secondaryContainer
                          : colors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      added
                          ? Icons.check
                          : Icons.inventory_2_outlined,
                      size: 18,
                      color: added
                          ? colors.onSecondaryContainer
                          : colors.onPrimaryContainer,
                    ),
                  ),
                  title: Text(p.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  subtitle: Text(
                      p.code.isNotEmpty ? 'Cód. ${p.code}' : p.unit,
                      style: const TextStyle(fontSize: 12)),
                  trailing: Text(
                    formatCurrency(p.price),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.primary),
                  ),
                  enabled: !added,
                  onTap: added
                      ? null
                      : () {
                          widget.onAdd(p);
                          Navigator.pop(context);
                        },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

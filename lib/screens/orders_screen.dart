import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/order_controller.dart';
import '../models/order.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import 'new_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<OrderController>();
    final orders = ctrl.filtered(_filter);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Pedidos'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _openNewOrder,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _FilterChip(label: 'Todos', selected: _filter == null,
                      onTap: () => setState(() => _filter = null)),
                  const SizedBox(width: 8),
                  ...OrderStatus.values.map((s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: s.label,
                          selected: _filter == s,
                          color: Color(s.colorValue),
                          onTap: () =>
                              setState(() => _filter = _filter == s ? null : s),
                        ),
                      )),
                ],
              ),
            ),
          ),
          if (orders.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Nenhum pedido',
                subtitle: 'Toque em + para criar seu primeiro pedido',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList.separated(
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) =>
                    _OrderCard(order: orders[i]),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewOrder,
        child: const Icon(Icons.add)
      ),
    );
  }

  void _openNewOrder() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NewOrderScreen()),
      );
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final c = color ?? colors.primary;
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: c.withOpacity(0.15),
      checkmarkColor: c,
      labelStyle: TextStyle(
        color: selected ? c : colors.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

// ── Order card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = Color(order.status.colorValue);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                  _StatusBadge(status: order.status, color: statusColor),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 13, color: colors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(formatDateTime(order.createdAt),
                      style: TextStyle(
                          fontSize: 12, color: colors.onSurfaceVariant)),
                  const SizedBox(width: 16),
                  Icon(Icons.shopping_bag_outlined,
                      size: 13, color: colors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${order.items.length} ${order.items.length == 1 ? 'item' : 'itens'}',
                    style: TextStyle(
                        fontSize: 12, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.paymentConditionName,
                    style: TextStyle(
                        fontSize: 12,
                        color: colors.primary,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    formatCurrency(order.total),
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _OrderDetailSheet(order: order),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ── Order detail bottom sheet ──────────────────────────────────────────────────

class _OrderDetailSheet extends StatelessWidget {
  final Order order;

  const _OrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pedido #${order.id?.toString().padLeft(6, '0') ?? '---'}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              _StatusBadge(
                  status: order.status,
                  color: Color(order.status.colorValue)),
            ],
          ),
          const SizedBox(height: 4),
          Text(formatDateTime(order.createdAt),
              style:
                  TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
          const SizedBox(height: 20),
          _Row('Cliente', order.customerName),
          _Row('Pagamento', order.paymentConditionName),
          const Divider(height: 28),
          Text('Itens',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                  fontSize: 13)),
          const SizedBox(height: 8),
          ...order.items.map((item) => _ItemRow(item: item)),
          const Divider(height: 28),
          if (order.discountPercent > 0)
            _TotalRow(
                label: 'Subtotal antes do desconto',
                value: formatCurrency(order.itemsTotal)),
          if (order.discountPercent > 0)
            _TotalRow(
                label:
                    'Desconto (${formatPercent(order.discountPercent)})',
                value: '−${formatCurrency(order.discountAmount)}',
                valueColor: Colors.green.shade700),
          if (order.surchargePercent > 0)
            _TotalRow(
                label:
                    'Acréscimo (${formatPercent(order.surchargePercent)})',
                value: '+${formatCurrency(order.surchargeAmount)}',
                valueColor: Colors.orange.shade700),
          _TotalRow(
              label: 'Total',
              value: formatCurrency(order.total),
              bold: true),
          if (order.notes.isNotEmpty) ...[
            const Divider(height: 28),
            Text('Observações',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                    fontSize: 13)),
            const SizedBox(height: 6),
            Text(order.notes,
                style: const TextStyle(fontSize: 14)),
          ],
          if (order.status == OrderStatus.pending) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final nav = Navigator.of(context);
                  nav.pop();
                  nav.push(MaterialPageRoute(
                    builder: (_) => NewOrderScreen(orderToEdit: order),
                  ));
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar Pedido'),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: order.id == null ? null : () {
                      context.read<OrderController>().updateStatus(
                          order.id!, OrderStatus.cancelled);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: order.id == null ? null : () {
                      context.read<OrderController>().updateStatus(
                          order.id!, OrderStatus.confirmed);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Text(
                  '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 2)}'
                  ' ${item.productUnit} × ${formatCurrency(item.unitPrice)}'
                  '${item.discountPercent > 0 ? '  −${formatPercent(item.discountPercent)}' : ''}',
                  style: TextStyle(
                      fontSize: 12, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(formatCurrency(item.subtotal),
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: bold ? 15 : 13,
                  fontWeight:
                      bold ? FontWeight.w700 : FontWeight.normal,
                  color: bold
                      ? colors.onSurface
                      : colors.onSurfaceVariant)),
          Text(value,
              style: TextStyle(
                  fontSize: bold ? 18 : 13,
                  fontWeight:
                      bold ? FontWeight.w700 : FontWeight.w500,
                  color: valueColor ??
                      (bold ? colors.primary : colors.onSurface))),
        ],
      ),
    );
  }
}

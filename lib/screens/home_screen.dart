import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../controllers/customer_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/order_controller.dart';
import '../models/order.dart';
import '../utils/formatters.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = context.watch<AppController>();
    final customerCtrl = context.watch<CustomerController>();
    final productCtrl = context.watch<ProductController>();
    final orderCtrl = context.watch<OrderController>();
    final colors = Theme.of(context).colorScheme;
    final isDark = appCtrl.isDark;

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            actions: [
              IconButton(
                tooltip: isDark ? 'Tema claro' : 'Tema escuro',
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    key: ValueKey(isDark),
                    color: colors.onPrimary,
                  ),
                ),
                onPressed: appCtrl.toggleTheme,
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'Landix Basic',
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
              ),
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo do mês',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                        label: 'Clientes',
                        value: customerCtrl.customers.length.toString(),
                        icon: Icons.people_outline_rounded,
                        color: const Color(0xFF3B82F6),
                      ),
                      _StatCard(
                        label: 'Produtos',
                        value: productCtrl.products.length.toString(),
                        icon: Icons.inventory_2_outlined,
                        color: const Color(0xFF8B5CF6),
                      ),
                      _StatCard(
                        label: 'Pedidos',
                        value: orderCtrl.monthlyOrdersCount.toString(),
                        icon: Icons.receipt_long_outlined,
                        color: const Color(0xFFF59E0B),
                      ),
                      _StatCard(
                        label: 'Faturamento',
                        value: formatCurrency(orderCtrl.monthlyRevenue),
                        icon: Icons.trending_up_rounded,
                        color: const Color(0xFF10B981),
                        smallValue: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Pedidos recentes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (orderCtrl.recentOrders.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Nenhum pedido ainda.\nCrie seu primeiro pedido!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    ...orderCtrl.recentOrders.map((o) => _RecentOrderTile(order: o)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool smallValue;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.smallValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: smallValue ? 14 : 22,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Recent order tile ─────────────────────────────────────────────────────────

class _RecentOrderTile extends StatelessWidget {
  final Order order;
  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = Color(order.status.colorValue);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatDateTime(order.createdAt),
                  style:
                      TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(order.total),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

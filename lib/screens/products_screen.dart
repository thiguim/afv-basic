import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ProductController>();
    final filtered = ctrl.search(_query);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Produtos')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SearchBar(
                controller: _search,
                hintText: 'Buscar produtos...',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_query.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    )
                ],
                onChanged: (v) =>
                    setState(() => _query = v.toLowerCase()),
              ),
            ),
          ),
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.inventory_2_outlined,
                title: _query.isEmpty
                    ? 'Nenhum produto'
                    : 'Nenhum resultado',
                subtitle: _query.isEmpty
                    ? 'Toque em + para cadastrar um produto'
                    : 'Tente outra busca',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) =>
                    _ProductCard(product: filtered[i]),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openForm(BuildContext context, Product? product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ProductForm(product: product),
    );
  }
}

// ── Product card ──────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => _ProductForm(product: product),
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.inventory_2_outlined,
                    color: colors.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      product.code.isNotEmpty
                          ? 'Cód. ${product.code}  ·  ${product.unit}'
                          : product.unit,
                      style: TextStyle(
                          fontSize: 12, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(product.price),
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.primary),
                  ),
                  Text(
                    '/ ${product.unit}',
                    style: TextStyle(
                        fontSize: 11, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Product form ──────────────────────────────────────────────────────────────

class _ProductForm extends StatefulWidget {
  final Product? product;
  const _ProductForm({this.product});

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _price;
  String _unit = 'UN';

  static const _units = ['UN', 'PC', 'CX', 'KG', 'LT', 'MT', 'SC'];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _code = TextEditingController(text: p?.code ?? '');
    _price = TextEditingController(
        text: p != null ? p.price.toStringAsFixed(2).replaceAll('.', ',') : '');
    _unit = p?.unit ?? 'UN';
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _price.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = context.read<ProductController>();
    final price =
        double.tryParse(_price.text.replaceAll(',', '.')) ?? 0.0;
    final isEdit = widget.product != null;
    final product = Product(
      id: widget.product?.id ?? ctrl.generateId(),
      name: _name.text.trim(),
      code: _code.text.trim(),
      price: price,
      unit: _unit,
    );
    if (isEdit) {
      ctrl.update(product);
    } else {
      ctrl.add(product);
    }
    Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir produto?'),
        content:
            Text('${widget.product!.name} será removido permanentemente.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              context.read<ProductController>().delete(widget.product!.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                      isEdit ? 'Editar Produto' : 'Novo Produto',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (isEdit)
                    IconButton(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _name,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nome obrigatório' : null,
                decoration: const InputDecoration(
                  labelText: 'Nome do produto *',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(12))),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _code,
                      decoration: const InputDecoration(
                        labelText: 'Código',
                        prefixIcon: Icon(Icons.qr_code_outlined),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: const InputDecoration(
                        labelText: 'Unidade',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      items: _units
                          .map((u) => DropdownMenuItem(
                              value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _unit = v ?? 'UN'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Preço obrigatório';
                  }
                  if (double.tryParse(v.replaceAll(',', '.')) == null) {
                    return 'Preço inválido';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Preço de venda *',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(12))),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: _save,
                    child: Text(isEdit ? 'Salvar alterações' : 'Cadastrar')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

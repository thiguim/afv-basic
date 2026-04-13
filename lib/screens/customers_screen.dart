import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/customer_controller.dart';
import '../models/customer.dart';
import '../widgets/empty_state.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CustomerController>();
    final filtered = ctrl.search(_query);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Clientes')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SearchBar(
                controller: _search,
                hintText: 'Buscar clientes...',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_query.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    ),
                ],
                onChanged: (v) =>
                    setState(() => _query = v.toLowerCase()),
              ),
            ),
          ),
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.people_outline,
                title: _query.isEmpty
                    ? 'Nenhum cliente'
                    : 'Nenhum resultado',
                subtitle: _query.isEmpty
                    ? 'Toque em + para adicionar seu primeiro cliente'
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
                    _CustomerCard(customer: filtered[i]),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, null),
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }

  void _openForm(BuildContext context, Customer? customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CustomerForm(customer: customer),
    );
  }
}

// ── Customer card ─────────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  final Customer customer;

  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initials = customer.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

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
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primaryContainer,
                child: Text(initials,
                    style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    if (customer.document.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(customer.document,
                          style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant)),
                    ],
                    if (customer.phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(customer.phone,
                          style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: colors.onSurfaceVariant),
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
      builder: (_) => _CustomerDetailSheet(customer: customer),
    );
  }
}

// ── Customer detail sheet ─────────────────────────────────────────────────────

class _CustomerDetailSheet extends StatelessWidget {
  final Customer customer;

  const _CustomerDetailSheet({required this.customer});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initials = customer.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2)),
            ),
            CircleAvatar(
              radius: 36,
              backgroundColor: colors.primaryContainer,
              child: Text(initials,
                  style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 22)),
            ),
            const SizedBox(height: 12),
            Text(customer.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _InfoTile(icon: Icons.badge_outlined, label: 'CPF/CNPJ', value: customer.document),
            _InfoTile(icon: Icons.phone_outlined, label: 'Telefone', value: customer.phone),
            _InfoTile(icon: Icons.email_outlined, label: 'E-mail', value: customer.email),
            _InfoTile(icon: Icons.location_on_outlined, label: 'Endereço', value: customer.address),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24))),
                        builder: (_) => _CustomerForm(customer: customer),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir cliente?'),
        content: Text('${customer.name} será removido permanentemente.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              context.read<CustomerController>().delete(customer.id);
              Navigator.pop(ctx);     // fecha dialog
              Navigator.pop(context); // fecha sheet
            },
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: colors.onSurfaceVariant)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Customer form ─────────────────────────────────────────────────────────────

class _CustomerForm extends StatefulWidget {
  final Customer? customer;
  const _CustomerForm({this.customer});

  @override
  State<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<_CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _document;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _name = TextEditingController(text: c?.name ?? '');
    _document = TextEditingController(text: c?.document ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _address = TextEditingController(text: c?.address ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _document.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = context.read<CustomerController>();
    final isEdit = widget.customer != null;
    final customer = Customer(
      id: widget.customer?.id ?? ctrl.generateId(),
      name: _name.text.trim(),
      document: _document.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      address: _address.text.trim(),
    );
    if (isEdit) {
      ctrl.update(customer);
    } else {
      ctrl.add(customer);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;
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
              Text(
                isEdit ? 'Editar Cliente' : 'Novo Cliente',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              _Field(
                  controller: _name,
                  label: 'Nome *',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nome obrigatório' : null),
              _Field(
                  controller: _document,
                  label: 'CPF / CNPJ',
                  icon: Icons.badge_outlined),
              _Field(
                  controller: _phone,
                  label: 'Telefone',
                  icon: Icons.phone_outlined,
                  type: TextInputType.phone),
              _Field(
                  controller: _email,
                  label: 'E-mail',
                  icon: Icons.email_outlined,
                  type: TextInputType.emailAddress),
              _Field(
                  controller: _address,
                  label: 'Endereço',
                  icon: Icons.location_on_outlined),
              const SizedBox(height: 8),
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

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType type;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.type = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
          isDense: true,
        ),
      ),
    );
  }
}

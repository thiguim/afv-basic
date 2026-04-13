# CLAUDE.md — Landix Basic (AFV-Basico)

Guia de referência completo para o projeto. Leia este arquivo antes de qualquer tarefa de desenvolvimento.

---

## 1. Visão Geral do Projeto

**Nome:** Landix Basic  
**Tipo:** Aplicativo de Força de Vendas (AFV) — mobile Flutter  
**Descrição:** App simples e robusto para vendedores realizarem as operações essenciais de campo: cadastro de clientes, catálogo de produtos, criação de pedidos e acompanhamento de status.  
**Público-alvo:** Vendedores externos / representantes comerciais.  
**Status:** Protótipo funcional — dados em memória (sem persistência real ainda).

---

## 2. Stack Tecnológica

| Item | Detalhe |
|---|---|
| Framework | Flutter (SDK ≥ 3.0.0) |
| Linguagem | Dart |
| State Management | Provider 6.x — `ChangeNotifier` + `MultiProvider` |
| Internacionalização | `intl 0.19` — locale `pt_BR` |
| ID geração | `uuid 4.x` — método `v4()` |
| Design System | Material 3 (`useMaterial3: true`) |
| Seed color | `Color(0xFF2563EB)` — azul |
| Orientação | Portrait only (portrait up + portrait down) |
| Plataforma-alvo | Android / iOS |

---

## 3. Arquitetura: MVC com Provider

O projeto segue **MVC** rigoroso com Provider como mecanismo de injeção de dependência e reatividade.

```
┌─────────────────────────────────────────────────┐
│  View (screens/)                                │
│  • Só renderiza UI                              │
│  • context.watch<>() para reatividade           │
│  • context.read<>() em callbacks/ações          │
└──────────────┬──────────────────────────────────┘
               │ lê e chama
               ▼
┌─────────────────────────────────────────────────┐
│  Controller (controllers/)                      │
│  • ChangeNotifier                               │
│  • Lógica de negócio + estado + CRUD            │
│  • Chama notifyListeners() ao mudar estado      │
└──────────────┬──────────────────────────────────┘
               │ manipula
               ▼
┌─────────────────────────────────────────────────┐
│  Model (models/)                                │
│  • Classes Dart puras — sem dependências        │
│  • Imutabilidade via copyWith()                 │
└─────────────────────────────────────────────────┘
```

### Regra de ouro
- **View NÃO contém lógica de negócio.** Cálculos, regras, CRUD → sempre no Controller.
- **Controller NÃO importa widgets Flutter.** Apenas `package:flutter/foundation.dart` (ChangeNotifier).
- **context.watch** apenas no método `build()`. **context.read** apenas em callbacks (`onPressed`, `onTap`, `_save()`, etc.).

---

## 4. Estrutura de Arquivos

```
lib/
├── controllers/
│   ├── app_controller.dart        # Tema claro/escuro
│   ├── auth_controller.dart       # Login — isLoading, login(), clearError()
│   ├── customer_controller.dart   # CRUD clientes + search()
│   ├── product_controller.dart    # CRUD produtos + search()
│   └── order_controller.dart      # CRUD pedidos + condições de pagamento + stats mensais
│
├── models/
│   ├── customer.dart              # Customer — id, name, document, phone, email, address
│   ├── product.dart               # Product — id, name, code, price, unit
│   ├── payment_condition.dart     # PaymentCondition — id, name, days, interestRate (const)
│   └── order.dart                 # Order, OrderItem, OrderStatus enum
│
├── screens/
│   ├── login_screen.dart          # Tela de login com animação
│   ├── main_nav.dart              # NavigationBar + IndexedStack (4 tabs)
│   ├── home_screen.dart           # Dashboard — estatísticas mensais + pedidos recentes
│   ├── customers_screen.dart      # Lista + CRUD de clientes
│   ├── products_screen.dart       # Lista + CRUD de produtos
│   ├── orders_screen.dart         # Lista + detalhes + status de pedidos
│   └── new_order_screen.dart      # Wizard de criação de pedido
│
├── utils/
│   └── formatters.dart            # formatCurrency(), formatPercent(), formatDate(), formatDateTime()
│
├── widgets/
│   └── empty_state.dart           # Widget reutilizável de lista vazia
│
└── main.dart                      # MultiProvider + AFVApp + MaterialApp
```

### Arquivo legado (NÃO usar, NÃO excluir)
- `lib/store/app_store.dart` — AppStore monolítico substituído pelos controllers. Manter para referência histórica.

---

## 5. Controllers — API de Referência

### AppController
```dart
ThemeMode get themeMode
bool get isDark
void toggleTheme()
```

### AuthController
```dart
bool get isLoading
String? get errorMessage
Future<bool> login(String email, String password)
void clearError()
```

### CustomerController
```dart
List<Customer> get customers          // unmodifiable
List<Customer> search(String query)   // filtra por name, document, phone
String generateId()
void add(Customer)
void update(Customer)
void delete(String id)
```

### ProductController
```dart
List<Product> get products            // unmodifiable
List<Product> search(String query)    // filtra por name, code
String generateId()
void add(Product)
void update(Product)
void delete(String id)
```

### OrderController
```dart
List<Order> get orders                     // unmodifiable
List<PaymentCondition> get paymentConditions  // 6 condições estáticas
List<Order> filtered(OrderStatus? status)  // null = todos
double get monthlyRevenue
int get monthlyOrdersCount
List<Order> get recentOrders               // últimos 5
String generateId()
void add(Order)
void updateStatus(String id, OrderStatus status)
void delete(String id)
```

---

## 6. Models — Referência

### Customer
```dart
final String id;
String name;       // obrigatório
String document;   // CPF/CNPJ — livre
String phone;
String email;
String address;
Customer copyWith({...})
```

### Product
```dart
final String id;
String name;       // obrigatório
String code;       // código interno
double price;      // preço de venda
String unit;       // UN | PC | CX | KG | LT | MT | SC
Product copyWith({...})
```

### PaymentCondition (const — não editável pelo usuário)
```dart
final String id;      // pc1..pc6
final String name;
final int days;
final double interestRate;
```

**Condições cadastradas:** À Vista, 30 dias, 2x sem juros, 3x com juros (2%), 6x com juros (3,5%), 30/60/90 dias.

### Order
```dart
final String id;
final DateTime createdAt;
final String customerId;
final String customerName;    // denormalizado
final List<OrderItem> items;
final String paymentConditionId;
final String paymentConditionName;  // denormalizado
double discountPercent;       // desconto sobre itensTotal
double surchargePercent;      // acréscimo após desconto
OrderStatus status;           // mutable — pending | confirmed | cancelled
final String notes;

// Calculados:
double get itemsTotal        // soma dos subtotais dos itens
double get discountAmount
double get surchargeAmount
double get total             // itemsTotal - discount + surcharge
```

### OrderItem
```dart
final String productId;
final String productName;    // denormalizado
final String productCode;
final String productUnit;
final double quantity;
final double unitPrice;
final double discountPercent; // desconto por item (independente do desconto do pedido)
double get subtotal          // price * qty * (1 - discount/100)
```

### OrderStatus (enum)
```dart
OrderStatus.pending    // label: 'Pendente', color: 0xFFF59E0B (âmbar)
OrderStatus.confirmed  // label: 'Confirmado', color: 0xFF10B981 (verde)
OrderStatus.cancelled  // label: 'Cancelado', color: 0xFFEF4444 (vermelho)
```

---

## 7. Fluxo de Navegação

```
LoginScreen
    │ (login ok → pushReplacement + FadeTransition)
    ▼
MainNav (IndexedStack — 4 tabs)
    ├── [0] HomeScreen       — dashboard
    ├── [1] OrdersScreen     — lista + novo pedido → NewOrderScreen (push)
    ├── [2] CustomersScreen  — lista + bottom sheets (form/detalhe)
    └── [3] ProductsScreen   — lista + bottom sheets (form)
```

**Padrões de navegação:**
- Telas principais: `IndexedStack` (mantém estado ao trocar aba)
- Sub-telas (ex.: NewOrderScreen): `Navigator.push` com `MaterialPageRoute`
- Formulários e detalhes: `showModalBottomSheet` com `isScrollControlled: true, useSafeArea: true`
- Login → MainNav: `pushReplacement` com `FadeTransition` (400ms)

---

## 8. Padrões de UI/UX

### AppBar
- Telas principais usam `SliverAppBar.large(title: Text('...'))`
- HomeScreen usa `SliverAppBar` com `expandedHeight: 120` e `flexibleSpace`

### Bottom Sheets (formulários e detalhes)
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,  // SEMPRE — permite teclado não sobrepor
  useSafeArea: true,
  shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  builder: (_) => Widget(),
);
```
- Sempre com `EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)` no filho
- Indicador de drag: Container 40×4px cor `outlineVariant`

### Cards de lista
```dart
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: colors.outlineVariant),
  ),
  child: InkWell(borderRadius: BorderRadius.circular(16), ...)
)
```

### Campos de formulário
```dart
InputDecoration(
  labelText: '...',
  prefixIcon: Icon(...),
  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  isDense: true,
)
```

### Busca
- `SearchBar` do Material 3 (não `TextField`)
- `leading: Icon(Icons.search)`
- `trailing: [IconButton(Icons.close)]` quando há texto

### Cores semânticas (não hardcode — usar sempre ColorScheme)
```dart
final colors = Theme.of(context).colorScheme;
colors.primary, colors.onPrimary
colors.primaryContainer, colors.onPrimaryContainer
colors.surface, colors.surfaceContainerLow
colors.onSurface, colors.onSurfaceVariant
colors.outlineVariant
```

### Cores de status (hardcoded — exceção justificada)
```dart
Color(order.status.colorValue)  // vem do enum OrderStatus
Colors.green.shade700           // desconto
Colors.orange.shade700          // acréscimo
Colors.red                      // ações destrutivas
```

### Formatação
```dart
formatCurrency(double)    // → "R$ 1.234,56"
formatPercent(double)     // → "10,00%"
formatDate(DateTime)      // → "31/12/2025"
formatDateTime(DateTime)  // → "31/12/2025 14:30"
```
Sempre importar de `'../utils/formatters.dart'`.

---

## 9. Convenções de Código

### Nomenclatura de controllers
- Métodos CRUD: `add()`, `update()`, `delete()` — **não** `addCustomer()`, `updateProduct()`
- Busca: `search(String query)` — retorna lista filtrada sem modificar estado
- Stats: getters computados (sem cache)

### Nomenclatura de widgets privados
- Prefixo `_` — classes privadas do arquivo: `_CustomerCard`, `_OrderDetailSheet`, `_Field`
- Nunca extrair para arquivos separados até que seja reutilizado em 2+ telas

### ID de entidades
- Gerado pelo controller: `ctrl.generateId()` — usa UUID v4
- **Nunca** instanciar `Uuid()` diretamente nas telas

### Imports nas telas
```dart
import 'package:provider/provider.dart';
import '../controllers/[nome]_controller.dart';
import '../models/[nome].dart';
// utils e widgets conforme necessário
```

### Imports nos controllers
```dart
import 'package:flutter/foundation.dart';  // ChangeNotifier
import 'package:uuid/uuid.dart';
import '../models/[nome].dart';
// NUNCA importar package:flutter/material.dart nos controllers
```

---

## 10. Localização

- Locale: `pt_BR`
- Separador decimal: vírgula (`,`) — inputs de preço aceitam vírgula, fazem `replaceAll(',', '.')`
- Moeda: Real brasileiro — prefixo `R$`
- Datas: formato `dd/MM/yyyy`

---

## 11. main.dart — MultiProvider

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AppController()),
    ChangeNotifierProvider(create: (_) => AuthController()),
    ChangeNotifierProvider(create: (_) => CustomerController()),
    ChangeNotifierProvider(create: (_) => ProductController()),
    ChangeNotifierProvider(create: (_) => OrderController()),
  ],
  child: const AFVApp(),
)
```

Para adicionar um novo controller: registrar aqui **e** criar o arquivo em `lib/controllers/`.

---

## 12. O que NÃO existe (ainda) e pontos de extensão

| Funcionalidade | Onde adicionar |
|---|---|
| Persistência local (SQLite) | Criar `lib/services/database_service.dart` — injetado nos controllers |
| API REST | Criar `lib/services/api_service.dart` — controllers delegam ao service |
| Autenticação real | `AuthController.login()` — trocar `Future.delayed` por chamada HTTP |
| Relatórios PDF | `lib/services/report_service.dart` |
| Push notifications | `lib/services/notification_service.dart` |
| Paginação de listas | Nos controllers — adicionar `page`/`offset` ao `search()` |
| Múltiplos vendedores | `AuthController` — adicionar modelo `User` |

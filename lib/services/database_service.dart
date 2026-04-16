import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

/// Gerencia a conexão com o banco SQLite local.
///
/// Caminho no aparelho: /storage/emulated/0/landix/dados/afvbasico.db
/// A pasta é criada automaticamente na primeira inicialização.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  /// Injeta um banco já aberto — usar apenas em testes.
  @visibleForTesting
  static void overrideForTesting(Database db) => instance._db = db;

  // ── Abertura ──────────────────────────────────────────────────────────────

  static const _dbPath = '/storage/emulated/0/landix/dados';
  static const _dbFile = 'afvbasico.db';
  static const _dbVersion = 1;

  Future<Database> _open() async {
    await _ensurePermission();
    final dir = Directory(_dbPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return openDatabase(
      '$_dbPath/$_dbFile',
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  /// Habilita suporte a chaves estrangeiras (desativado por padrão no SQLite).
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ── Permissões ────────────────────────────────────────────────────────────

  Future<void> _ensurePermission() async {
    if (Platform.isAndroid) {
      final manageStatus = await Permission.manageExternalStorage.status;
      if (manageStatus.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      // Fallback para Android ≤ 9
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isDenied) {
        await Permission.storage.request();
      }
    }
  }

  // ── Schema ────────────────────────────────────────────────────────────────

  Future<void> _onCreate(Database db, int version) async {
    await applySchema(db);
    await _seedData(db);
  }

  // ── Seed ──────────────────────────────────────────────────────────────────

  /// Insere dados iniciais de exemplo — executado apenas na criação do banco.
  static Future<void> _seedData(Database db) async {
    await _seedClientes(db);
    await _seedProdutos(db);
    await _seedCondicoesPagamento(db);
    await _seedPedidoExemplo(db);
  }

  // ── Clientes (33 registros) ───────────────────────────────────────────────

  static Future<void> _seedClientes(Database db) async {
    final clientes = [
      {'IDCLIE': 'cli-001', 'NMCLIE': 'Mercado Central Ltda',           'CDDOCU': '12.345.678/0001-90', 'NRFONE': '(11) 98765-4321', 'TXEMAI': 'compras@mercadocentral.com.br',    'TXENDE': 'Av. Paulista, 1000 - Bela Vista, São Paulo/SP'},
      {'IDCLIE': 'cli-002', 'NMCLIE': 'Distribuidora Norte S.A.',        'CDDOCU': '98.765.432/0001-10', 'NRFONE': '(21) 99001-2345', 'TXEMAI': 'pedidos@distrnorte.com.br',        'TXENDE': 'Rua das Flores, 250 - Centro, Rio de Janeiro/RJ'},
      {'IDCLIE': 'cli-003', 'NMCLIE': 'Supermercado Bom Preço',          'CDDOCU': '45.678.901/0001-55', 'NRFONE': '(31) 97654-3210', 'TXEMAI': 'gerencia@bompreco.com.br',         'TXENDE': 'Rua Tupinambás, 80 - Floresta, Belo Horizonte/MG'},
      {'IDCLIE': 'cli-004', 'NMCLIE': 'Atacadão Real Comércio Ltda',     'CDDOCU': '23.456.789/0001-01', 'NRFONE': '(41) 98800-1122', 'TXEMAI': 'compras@atacadaoreal.com.br',      'TXENDE': 'Rod. BR-116, km 14 - Curitiba/PR'},
      {'IDCLIE': 'cli-005', 'NMCLIE': 'Padaria & Confeitaria Doce Mel',  'CDDOCU': '34.567.890/0001-12', 'NRFONE': '(51) 99312-5678', 'TXEMAI': 'docempel@gmail.com',               'TXENDE': 'Rua Voluntários da Pátria, 340 - Porto Alegre/RS'},
      {'IDCLIE': 'cli-006', 'NMCLIE': 'Restaurante e Lanchonete Sabor',  'CDDOCU': '56.789.012/0001-34', 'NRFONE': '(85) 98123-4567', 'TXEMAI': 'contato@restaurantesabor.com.br', 'TXENDE': 'Av. Beira Mar, 2200 - Meireles, Fortaleza/CE'},
      {'IDCLIE': 'cli-007', 'NMCLIE': 'Mini Mercado Vila Verde',         'CDDOCU': '67.890.123/0001-45', 'NRFONE': '(62) 99456-7890', 'TXEMAI': 'minivilaverde@outlook.com',        'TXENDE': 'Rua 10, 180 - Setor Marista, Goiânia/GO'},
      {'IDCLIE': 'cli-008', 'NMCLIE': 'Comercial Três Irmãos',           'CDDOCU': '78.901.234/0001-56', 'NRFONE': '(92) 98234-5678', 'TXEMAI': 'tres.irmaos@comercial.com.br',    'TXENDE': 'Rua Recife, 55 - Adrianópolis, Manaus/AM'},
      {'IDCLIE': 'cli-009', 'NMCLIE': 'Rede Econômica Supermercados',    'CDDOCU': '89.012.345/0001-67', 'NRFONE': '(71) 97345-6789', 'TXEMAI': 'compras@redeeconomica.com.br',    'TXENDE': 'Av. Suburbana, 4500 - Lobato, Salvador/BA'},
      {'IDCLIE': 'cli-010', 'NMCLIE': 'Mercearia São José',              'CDDOCU': '90.123.456/0001-78', 'NRFONE': '(86) 99567-8901', 'TXEMAI': 'mersaojose@hotmail.com',           'TXENDE': 'Rua Coelho Rodrigues, 210 - Centro, Teresina/PI'},
      {'IDCLIE': 'cli-011', 'NMCLIE': 'Hortifruti Campo Verde',          'CDDOCU': '01.234.567/0001-89', 'NRFONE': '(27) 98678-9012', 'TXEMAI': 'campoverde@hortifruti.com.br',    'TXENDE': 'Av. Fernando Ferrari, 900 - Goiabeiras, Vitória/ES'},
      {'IDCLIE': 'cli-012', 'NMCLIE': 'Distribuidora Alimentos Sul',     'CDDOCU': '11.111.111/0001-11', 'NRFONE': '(48) 99789-0123', 'TXEMAI': 'vendas@alimentossul.com.br',      'TXENDE': 'Rod. SC-401, 1500 - Saco Grande, Florianópolis/SC'},
      {'IDCLIE': 'cli-013', 'NMCLIE': 'Empório Gourmet & Vinhos',        'CDDOCU': '22.222.222/0001-22', 'NRFONE': '(11) 97890-1234', 'TXEMAI': 'emporio@gourmetvinhos.com.br',    'TXENDE': 'Rua Oscar Freire, 700 - Jardins, São Paulo/SP'},
      {'IDCLIE': 'cli-014', 'NMCLIE': 'Supermercado Familiar Ltda',      'CDDOCU': '33.333.333/0001-33', 'NRFONE': '(61) 98901-2345', 'TXEMAI': 'familiar@supermercado.com.br',   'TXENDE': 'SCIA Qd. 14 Conj. D - Guará, Brasília/DF'},
      {'IDCLIE': 'cli-015', 'NMCLIE': 'Bar e Botequim do Zé',            'CDDOCU': '44.444.444/0001-44', 'NRFONE': '(21) 97012-3456', 'TXEMAI': 'botequimze@gmail.com',            'TXENDE': 'Rua Visconde de Pirajá, 330 - Ipanema, Rio de Janeiro/RJ'},
      {'IDCLIE': 'cli-016', 'NMCLIE': 'Atacado Nordeste Comércio',       'CDDOCU': '55.555.555/0001-55', 'NRFONE': '(83) 99123-4567', 'TXEMAI': 'atacado@nordestecom.com.br',     'TXENDE': 'Av. Epitácio Pessoa, 1800 - Bessa, João Pessoa/PB'},
      {'IDCLIE': 'cli-017', 'NMCLIE': 'Quitanda Dona Maria',             'CDDOCU': '66.666.666/0001-66', 'NRFONE': '(82) 98234-5678', 'TXEMAI': 'donamaria.quit@gmail.com',        'TXENDE': 'Rua do Comércio, 45 - Centro, Maceió/AL'},
      {'IDCLIE': 'cli-018', 'NMCLIE': 'Supri Alimentos Industriais',     'CDDOCU': '77.777.777/0001-77', 'NRFONE': '(35) 99345-6789', 'TXEMAI': 'suprimento@suprialimentos.com.br','TXENDE': 'Rua Rio de Janeiro, 500 - Centro, Varginha/MG'},
      {'IDCLIE': 'cli-019', 'NMCLIE': 'Rede Poupança Supermercados',     'CDDOCU': '88.888.888/0001-88', 'NRFONE': '(91) 97456-7890', 'TXEMAI': 'compras@redepoupanca.com.br',    'TXENDE': 'Av. Nazaré, 1200 - Nazaré, Belém/PA'},
      {'IDCLIE': 'cli-020', 'NMCLIE': 'Mercearia e Açougue Gaúcho',      'CDDOCU': '99.999.999/0001-99', 'NRFONE': '(54) 98567-8901', 'TXEMAI': 'acougue.gaucho@hotmail.com',     'TXENDE': 'Rua Flores da Cunha, 90 - Centro, Caxias do Sul/RS'},
      {'IDCLIE': 'cli-021', 'NMCLIE': 'Comercial Alves & Filhos',        'CDDOCU': '10.101.010/0001-01', 'NRFONE': '(16) 99678-9012', 'TXEMAI': 'alves.filhos@comercial.com.br',  'TXENDE': 'Av. Independência, 2200 - Jardim América, Ribeirão Preto/SP'},
      {'IDCLIE': 'cli-022', 'NMCLIE': 'Depósito de Bebidas Refrescante', 'CDDOCU': '20.202.020/0001-02', 'NRFONE': '(79) 98789-0123', 'TXEMAI': 'deposito@refrescante.com.br',    'TXENDE': 'Rua Laranjeiras, 300 - Siqueira Campos, Aracaju/SE'},
      {'IDCLIE': 'cli-023', 'NMCLIE': 'Hipermercado do Povo',            'CDDOCU': '30.303.030/0001-03', 'NRFONE': '(98) 97890-1234', 'TXEMAI': 'hiper@hiperdopovo.com.br',        'TXENDE': 'Av. dos Africanos, 3000 - Cohama, São Luís/MA'},
      {'IDCLIE': 'cli-024', 'NMCLIE': 'Cooperativa Agro Serra',          'CDDOCU': '40.404.040/0001-04', 'NRFONE': '(67) 99901-2345', 'TXEMAI': 'cooperativa@agroserra.com.br',   'TXENDE': 'Rod. MS-080, km 3 - Campo Grande/MS'},
      {'IDCLIE': 'cli-025', 'NMCLIE': 'Distribuidora Moura & Cia',       'CDDOCU': '50.505.050/0001-05', 'NRFONE': '(65) 98012-3456', 'TXEMAI': 'moura@distribuidora.com.br',     'TXENDE': 'Av. do CPA, 750 - CPA I, Cuiabá/MT'},
      {'IDCLIE': 'cli-026', 'NMCLIE': 'Supermercado Pantanal',           'CDDOCU': '60.606.060/0001-06', 'NRFONE': '(67) 97123-4567', 'TXEMAI': 'pantanal@supermercado.com.br',   'TXENDE': 'Rua 14 de Julho, 1500 - Amambaí, Campo Grande/MS'},
      {'IDCLIE': 'cli-027', 'NMCLIE': 'Armazém Central das Gerais',      'CDDOCU': '70.707.070/0001-07', 'NRFONE': '(34) 99234-5678', 'TXEMAI': 'armazem@dasgerais.com.br',       'TXENDE': 'Av. Rondon Pacheco, 4600 - Tibery, Uberlândia/MG'},
      {'IDCLIE': 'cli-028', 'NMCLIE': 'Loja de Conveniência 24h Express', 'CDDOCU': '80.808.080/0001-08', 'NRFONE': '(11) 96345-6789', 'TXEMAI': 'express24h@conveniencia.com.br', 'TXENDE': 'Rua Augusta, 150 - Consolação, São Paulo/SP'},
      {'IDCLIE': 'cli-029', 'NMCLIE': 'Frigorífico Santa Cruz',          'CDDOCU': '90.909.090/0001-09', 'NRFONE': '(47) 98456-7890', 'TXEMAI': 'frigorifico@santacruz.com.br',   'TXENDE': 'Rod. BR-470, km 62 - Blumenau/SC'},
      {'IDCLIE': 'cli-030', 'NMCLIE': 'Empório Natural Orgânicos',       'CDDOCU': '13.131.313/0001-10', 'NRFONE': '(41) 97567-8901', 'TXEMAI': 'natural@emporioorganicos.com.br', 'TXENDE': 'Rua Mateus Leme, 400 - São Francisco, Curitiba/PR'},
      {'IDCLIE': 'cli-031', 'NMCLIE': 'Rede Atacarejo Nordestão',        'CDDOCU': '14.141.414/0001-11', 'NRFONE': '(84) 99678-9012', 'TXEMAI': 'nordestao@atacarejo.com.br',     'TXENDE': 'Av. Prudente de Morais, 4000 - Lagoa Nova, Natal/RN'},
      {'IDCLIE': 'cli-032', 'NMCLIE': 'Mercadinho Bairro Feliz',         'CDDOCU': '15.151.515/0001-12', 'NRFONE': '(77) 98789-0123', 'TXEMAI': 'bairrofeliz@mercadinho.com.br',  'TXENDE': 'Rua Mato Grosso, 600 - Candeias, Vitória da Conquista/BA'},
      {'IDCLIE': 'cli-033', 'NMCLIE': 'Supri Cozinha Industrial',        'CDDOCU': '16.161.616/0001-13', 'NRFONE': '(19) 97890-1234', 'TXEMAI': 'cozinha@supriindustrial.com.br', 'TXENDE': 'Rua José Paulino, 1300 - Bonfim, Campinas/SP'},
    ];
    for (final c in clientes) {
      await db.insert('TMVOCLI', c);
    }
  }

  // ── Produtos (25 registros) ───────────────────────────────────────────────

  static Future<void> _seedProdutos(Database db) async {
    final produtos = [
      // Mercearia / grãos
      {'IDPROD': 'prod-001', 'NMPROD': 'Arroz Tipo 1 Branco',               'CDPROD': 'ARR-001', 'VLPREC': 28.90,  'CDUNID': 'SC'},
      {'IDPROD': 'prod-002', 'NMPROD': 'Feijão Carioca',                    'CDPROD': 'FEI-001', 'VLPREC': 12.50,  'CDUNID': 'SC'},
      {'IDPROD': 'prod-003', 'NMPROD': 'Óleo de Soja Refinado 900ml',       'CDPROD': 'OLE-001', 'VLPREC': 8.75,   'CDUNID': 'UN'},
      {'IDPROD': 'prod-004', 'NMPROD': 'Açúcar Cristal',                    'CDPROD': 'ACU-001', 'VLPREC': 22.00,  'CDUNID': 'SC'},
      {'IDPROD': 'prod-005', 'NMPROD': 'Macarrão Espaguete 500g',           'CDPROD': 'MAC-001', 'VLPREC': 4.30,   'CDUNID': 'CX'},
      {'IDPROD': 'prod-006', 'NMPROD': 'Sal Refinado Iodado 1kg',           'CDPROD': 'SAL-001', 'VLPREC': 2.50,   'CDUNID': 'CX'},
      {'IDPROD': 'prod-007', 'NMPROD': 'Farinha de Trigo 5kg',              'CDPROD': 'FAR-001', 'VLPREC': 18.40,  'CDUNID': 'SC'},
      {'IDPROD': 'prod-008', 'NMPROD': 'Feijão Preto',                      'CDPROD': 'FEI-002', 'VLPREC': 13.80,  'CDUNID': 'SC'},
      {'IDPROD': 'prod-009', 'NMPROD': 'Lentilha 500g',                     'CDPROD': 'LEN-001', 'VLPREC': 7.90,   'CDUNID': 'CX'},
      {'IDPROD': 'prod-010', 'NMPROD': 'Grão-de-Bico 500g',                 'CDPROD': 'GRA-001', 'VLPREC': 8.60,   'CDUNID': 'CX'},
      // Bebidas
      {'IDPROD': 'prod-011', 'NMPROD': 'Refrigerante Cola 2L',              'CDPROD': 'REF-001', 'VLPREC': 9.50,   'CDUNID': 'CX'},
      {'IDPROD': 'prod-012', 'NMPROD': 'Água Mineral sem Gás 500ml',        'CDPROD': 'AGU-001', 'VLPREC': 12.00,  'CDUNID': 'CX'},
      {'IDPROD': 'prod-013', 'NMPROD': 'Suco de Laranja Integral 1L',       'CDPROD': 'SUC-001', 'VLPREC': 7.20,   'CDUNID': 'CX'},
      {'IDPROD': 'prod-014', 'NMPROD': 'Cerveja Lager Lata 350ml',          'CDPROD': 'CER-001', 'VLPREC': 58.00,  'CDUNID': 'CX'},
      {'IDPROD': 'prod-015', 'NMPROD': 'Leite Integral UHT 1L',             'CDPROD': 'LEI-001', 'VLPREC': 5.90,   'CDUNID': 'CX'},
      // Laticínios e frios
      {'IDPROD': 'prod-016', 'NMPROD': 'Manteiga com Sal 200g',             'CDPROD': 'MAN-001', 'VLPREC': 9.80,   'CDUNID': 'CX'},
      {'IDPROD': 'prod-017', 'NMPROD': 'Queijo Mussarela Fatiado 150g',     'CDPROD': 'QUE-001', 'VLPREC': 11.50,  'CDUNID': 'CX'},
      {'IDPROD': 'prod-018', 'NMPROD': 'Iogurte Natural Integral 170g',     'CDPROD': 'IOG-001', 'VLPREC': 3.40,   'CDUNID': 'CX'},
      // Higiene e limpeza
      {'IDPROD': 'prod-019', 'NMPROD': 'Sabão em Pó Multiação 1kg',         'CDPROD': 'SAB-001', 'VLPREC': 14.90,  'CDUNID': 'CX'},
      {'IDPROD': 'prod-020', 'NMPROD': 'Detergente Líquido 500ml',          'CDPROD': 'DET-001', 'VLPREC': 3.20,   'CDUNID': 'CX'},
      {'IDPROD': 'prod-021', 'NMPROD': 'Desinfetante Pinho 1L',             'CDPROD': 'DES-001', 'VLPREC': 6.50,   'CDUNID': 'CX'},
      {'IDPROD': 'prod-022', 'NMPROD': 'Papel Higiênico Folha Dupla 12un',  'CDPROD': 'PAP-001', 'VLPREC': 22.90,  'CDUNID': 'PC'},
      // Padaria / biscoitos
      {'IDPROD': 'prod-023', 'NMPROD': 'Biscoito Cream Cracker 400g',       'CDPROD': 'BIS-001', 'VLPREC': 4.90,   'CDUNID': 'CX'},
      {'IDPROD': 'prod-024', 'NMPROD': 'Biscoito Recheado Chocolate 130g',  'CDPROD': 'BIS-002', 'VLPREC': 3.80,   'CDUNID': 'CX'},
      // Hortifruti / conservas
      {'IDPROD': 'prod-025', 'NMPROD': 'Tomate Pelado em Lata 400g',        'CDPROD': 'TOM-001', 'VLPREC': 5.10,   'CDUNID': 'CX'},
    ];
    for (final p in produtos) {
      await db.insert('TMVOPROD', p);
    }
  }

  // ── Condições de pagamento (26 registros) ─────────────────────────────────

  static Future<void> _seedCondicoesPagamento(Database db) async {
    // pc1–pc6: espelham a lista estática do OrderController (obrigatórios)
    // pc7–pc26: condições extras armazenadas no banco para uso futuro
    final condicoes = [
      {'IDCPGT': 'pc1',  'NMCPGT': 'À Vista',                   'NRPRAZ': 0,   'PCTAXA': 0.0},
      {'IDCPGT': 'pc2',  'NMCPGT': '30 dias',                   'NRPRAZ': 30,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc3',  'NMCPGT': '2x sem juros',              'NRPRAZ': 30,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc4',  'NMCPGT': '3x com juros (2%)',         'NRPRAZ': 30,  'PCTAXA': 2.0},
      {'IDCPGT': 'pc5',  'NMCPGT': '6x com juros (3,5%)',       'NRPRAZ': 30,  'PCTAXA': 3.5},
      {'IDCPGT': 'pc6',  'NMCPGT': '30/60/90 dias',             'NRPRAZ': 30,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc7',  'NMCPGT': '45 dias',                   'NRPRAZ': 45,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc8',  'NMCPGT': '60 dias',                   'NRPRAZ': 60,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc9',  'NMCPGT': '90 dias',                   'NRPRAZ': 90,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc10', 'NMCPGT': '4x sem juros',              'NRPRAZ': 30,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc11', 'NMCPGT': '5x sem juros',              'NRPRAZ': 30,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc12', 'NMCPGT': '4x com juros (1,5%)',       'NRPRAZ': 30,  'PCTAXA': 1.5},
      {'IDCPGT': 'pc13', 'NMCPGT': '5x com juros (1,99%)',      'NRPRAZ': 30,  'PCTAXA': 1.99},
      {'IDCPGT': 'pc14', 'NMCPGT': '8x com juros (2,5%)',       'NRPRAZ': 30,  'PCTAXA': 2.5},
      {'IDCPGT': 'pc15', 'NMCPGT': '10x com juros (3%)',        'NRPRAZ': 30,  'PCTAXA': 3.0},
      {'IDCPGT': 'pc16', 'NMCPGT': '12x com juros (3,5%)',      'NRPRAZ': 30,  'PCTAXA': 3.5},
      {'IDCPGT': 'pc17', 'NMCPGT': '18x com juros (4%)',        'NRPRAZ': 30,  'PCTAXA': 4.0},
      {'IDCPGT': 'pc18', 'NMCPGT': '24x com juros (4,5%)',      'NRPRAZ': 30,  'PCTAXA': 4.5},
      {'IDCPGT': 'pc19', 'NMCPGT': '28/56 dias',                'NRPRAZ': 28,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc20', 'NMCPGT': '30/60 dias',                'NRPRAZ': 30,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc21', 'NMCPGT': '30/60/90/120 dias',         'NRPRAZ': 30,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc22', 'NMCPGT': 'Boleto 15 dias',            'NRPRAZ': 15,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc23', 'NMCPGT': 'Boleto 21 dias',            'NRPRAZ': 21,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc24', 'NMCPGT': 'Boleto 45 dias c/ juros',   'NRPRAZ': 45,  'PCTAXA': 1.0},
      {'IDCPGT': 'pc25', 'NMCPGT': 'Cheque pré 30 dias',        'NRPRAZ': 30,  'PCTAXA': 0.0},
      {'IDCPGT': 'pc26', 'NMCPGT': 'Cheque pré 60 dias',        'NRPRAZ': 60,  'PCTAXA': 0.0},
    ];
    for (final pc in condicoes) {
      await db.insert('TMVOCNDPGTO', pc);
    }
  }

  // ── Pedido de exemplo ─────────────────────────────────────────────────────

  static Future<void> _seedPedidoExemplo(Database db) async {
    final idPedi = await db.insert('TMVOCAB', {
      'DTCRIA': DateTime(2026, 4, 15, 9, 30).toIso8601String(),
      'IDCLIE': 'cli-001',
      'NMCLIE': 'Mercado Central Ltda',
      'IDCPGT': 'pc2',
      'NMCPGT': '30 dias',
      'PCDSCT': 5.0,
      'PCACRE': 0.0,
      'STPEDI': 'confirmed',
      'TXOBSE': 'Entrega na quinta-feira no período da manhã.',
    });
    await db.insert('TMVOITE', {
      'IDPEDI': idPedi,
      'IDPROD': 'prod-001',
      'NMPROD': 'Arroz Tipo 1 Branco',
      'CDPROD': 'ARR-001',
      'CDUNID': 'SC',
      'QTITEM': 10.0,
      'VLPREC': 28.90,
      'PCDSCT': 0.0,
    });
    await db.insert('TMVOITE', {
      'IDPEDI': idPedi,
      'IDPROD': 'prod-003',
      'NMPROD': 'Óleo de Soja Refinado 900ml',
      'CDPROD': 'OLE-001',
      'CDUNID': 'UN',
      'QTITEM': 24.0,
      'VLPREC': 8.75,
      'PCDSCT': 0.0,
    });
  }

  /// Cria todas as tabelas — exposto para ser reutilizado nos testes.
  static Future<void> applySchema(Database db) async {
    await db.execute('''
      CREATE TABLE TMVOCLI (
        IDCLIE  TEXT PRIMARY KEY,
        NMCLIE  TEXT NOT NULL,
        CDDOCU  TEXT,
        NRFONE  TEXT,
        TXEMAI  TEXT,
        TXENDE  TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TMVOPROD (
        IDPROD  TEXT PRIMARY KEY,
        NMPROD  TEXT NOT NULL,
        CDPROD  TEXT,
        VLPREC  REAL NOT NULL,
        CDUNID  TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE TMVOCNDPGTO (
        IDCPGT  TEXT PRIMARY KEY,
        NMCPGT  TEXT NOT NULL,
        NRPRAZ  INTEGER NOT NULL,
        PCTAXA  REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE TMVOCAB (
        IDPEDI  INTEGER PRIMARY KEY AUTOINCREMENT,
        DTCRIA  TEXT    NOT NULL,
        IDCLIE  TEXT    NOT NULL,
        NMCLIE  TEXT    NOT NULL,
        IDCPGT  TEXT    NOT NULL,
        NMCPGT  TEXT    NOT NULL,
        PCDSCT  REAL    NOT NULL DEFAULT 0,
        PCACRE  REAL    NOT NULL DEFAULT 0,
        STPEDI  TEXT    NOT NULL,
        TXOBSE  TEXT,
        FOREIGN KEY (IDCLIE) REFERENCES TMVOCLI(IDCLIE),
        FOREIGN KEY (IDCPGT) REFERENCES TMVOCNDPGTO(IDCPGT)
      )
    ''');

    await db.execute('''
      CREATE TABLE TMVOITE (
        IDITEM  INTEGER PRIMARY KEY AUTOINCREMENT,
        IDPEDI  INTEGER NOT NULL,
        IDPROD  TEXT    NOT NULL,
        NMPROD  TEXT    NOT NULL,
        CDPROD  TEXT,
        CDUNID  TEXT    NOT NULL,
        QTITEM  REAL    NOT NULL,
        VLPREC  REAL    NOT NULL,
        PCDSCT  REAL    NOT NULL DEFAULT 0,
        FOREIGN KEY (IDPEDI) REFERENCES TMVOCAB(IDPEDI) ON DELETE CASCADE,
        FOREIGN KEY (IDPROD) REFERENCES TMVOPROD(IDPROD)
      )
    ''');
  }
}

import pytest
from pages.orders_page import OrdersPage
from pages.new_order_page import NewOrderPage

# Dados dos clientes/produtos pré-cadastrados no AppStore
CUSTOMER = "Ana Silva"
PRODUCT_1 = "Café Premium"
PRODUCT_2 = "Arroz Integral"
PAYMENT = "À Vista"


class TestOrders:

    @pytest.fixture(autouse=True)
    def setup(self, driver):
        self.orders = OrdersPage(driver)
        self.new_order = NewOrderPage(driver)
        self.orders.open()

    # ── Listagem e Filtros ────────────────────────────────────────────────────

    def test_tela_pedidos_carrega(self):
        """Tela de Pedidos deve ser carregada corretamente."""
        self.orders.assert_page_loaded()

    def test_filtro_pendente_exibe_chip_ativo(self):
        """Chip 'Pendente' deve ser selecionável."""
        self.orders.filter_by_status("Pendente")
        assert self.orders.is_text_visible("Pendente"), \
            "Chip 'Pendente' não encontrado"

    def test_filtro_confirmado(self):
        """Chip 'Confirmado' deve ser selecionável."""
        self.orders.filter_by_status("Confirmado")
        assert self.orders.is_text_visible("Confirmado"), \
            "Chip 'Confirmado' não encontrado"

    def test_filtro_cancelado(self):
        """Chip 'Cancelado' deve ser selecionável."""
        self.orders.filter_by_status("Cancelado")
        assert self.orders.is_text_visible("Cancelado"), \
            "Chip 'Cancelado' não encontrado"

    # ── Criar Pedido ──────────────────────────────────────────────────────────

    def test_abrir_tela_novo_pedido(self):
        """FAB deve abrir a tela de Novo Pedido."""
        self.orders.tap_new_order_button()
        self.new_order.assert_page_loaded()
        self.new_order.go_back()

    def test_botao_confirmar_desabilitado_sem_dados(self):
        """Botão Confirmar deve estar desabilitado sem cliente/produtos/pagamento."""
        self.orders.tap_new_order_button()
        self.new_order.assert_save_disabled()
        self.new_order.go_back()

    def test_criar_pedido_completo(self):
        """Deve criar um pedido com cliente, produto e pagamento."""
        self.orders.tap_new_order_button()

        # Cliente
        self.new_order.select_customer(CUSTOMER)

        # Produto
        self.new_order.add_product(PRODUCT_1)

        # Pagamento
        self.new_order.select_payment_condition(PAYMENT)

        # Salvar
        self.new_order.save()

        # Snackbar de confirmação
        self.new_order.assert_success_snackbar()

        # Pedido aparece na lista
        self.orders.assert_order_visible(CUSTOMER)

    def test_criar_pedido_com_multiplos_produtos(self):
        """Deve criar pedido com mais de um produto."""
        self.orders.tap_new_order_button()

        self.new_order.select_customer(CUSTOMER)
        self.new_order.add_product(PRODUCT_1)
        self.new_order.add_product(PRODUCT_2)
        self.new_order.select_payment_condition(PAYMENT)
        self.new_order.save()

        self.new_order.assert_success_snackbar()

    def test_criar_pedido_com_desconto(self):
        """Deve criar pedido aplicando desconto no pedido."""
        self.orders.tap_new_order_button()

        self.new_order.select_customer(CUSTOMER)
        self.new_order.add_product(PRODUCT_1)
        self.new_order.set_order_discount("10")
        self.new_order.select_payment_condition(PAYMENT)

        # Desconto deve aparecer no total bar
        self.new_order.assert_total_visible("Desconto")

        self.new_order.save()
        self.new_order.assert_success_snackbar()

    # ── Ações no Pedido ───────────────────────────────────────────────────────

    def test_confirmar_pedido_pendente(self):
        """Deve confirmar um pedido com status Pendente."""
        # Garante que há ao menos um pedido pendente
        all_orders = self.orders.get_all_orders()
        if len(all_orders) == 0:
            pytest.skip("Nenhum pedido disponível para confirmar")

        self.orders.filter_by_status("Pendente")
        pedidos = self.orders.get_all_orders()
        if len(pedidos) == 0:
            pytest.skip("Nenhum pedido pendente disponível")

        self.orders.tap_order(CUSTOMER)
        self.orders.confirm_order()
        self.orders.assert_order_status(CUSTOMER, "Confirmado")

    def test_cancelar_pedido_pendente(self):
        """Deve cancelar um pedido com status Pendente."""
        self.orders.filter_by_status("Pendente")
        pedidos = self.orders.get_all_orders()
        if len(pedidos) == 0:
            pytest.skip("Nenhum pedido pendente disponível para cancelar")

        self.orders.tap_order(CUSTOMER)
        self.orders.cancel_order()
        self.orders.assert_order_status(CUSTOMER, "Cancelado")

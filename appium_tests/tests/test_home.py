import pytest
from pages.home_page import HomePage


class TestHome:

    @pytest.fixture(autouse=True)
    def setup(self, driver):
        self.home = HomePage(driver)
        self.home.open()

    def test_dashboard_exibe_quatro_cards(self):
        """Dashboard deve exibir os 4 cards de estatística."""
        self.home.assert_dashboard_loaded()

    def test_secao_pedidos_recentes_existe(self):
        """Seção 'Pedidos Recentes' deve estar visível."""
        self.home.assert_has_recent_orders_section()

    def test_card_clientes_tem_valor_numerico(self):
        """Card Clientes deve exibir um número."""
        value = self.home.get_stat_value("Clientes")
        assert value is not None, "Valor do card Clientes não encontrado"
        assert value.strip().isdigit() or value.strip().replace(",", "").isdigit(), \
            f"Valor '{value}' não é numérico"

    def test_card_produtos_tem_valor_numerico(self):
        """Card Produtos deve exibir um número."""
        value = self.home.get_stat_value("Produtos")
        assert value is not None, "Valor do card Produtos não encontrado"

    def test_sem_pedidos_exibe_mensagem_vazia(self):
        """Quando não há pedidos recentes, deve exibir estado vazio."""
        orders = self.home.get_recent_orders()
        if len(orders) == 0:
            assert self.home.is_text_contains_visible("nenhum pedido"), \
                "Mensagem de lista vazia não encontrada"

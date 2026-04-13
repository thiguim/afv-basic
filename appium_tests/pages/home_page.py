from .base_page import BasePage


class HomePage(BasePage):

    # ── Navegação ─────────────────────────────────────────────────────────────

    def open(self):
        self.navigate_to_tab("Início")
        return self

    # ── Elementos ─────────────────────────────────────────────────────────────

    def get_stat_value(self, label):
        """Retorna o texto do valor de um card de estatística pelo label."""
        # Os cards ficam próximos — busca o container pelo label
        label_el = self.find_by_text_contains(label)
        # O valor numérico fica no elemento pai
        parent = label_el.find_element("xpath", "./..")
        children = parent.find_elements("xpath", ".//*")
        for child in children:
            text = child.text
            if text and text != label and text.strip():
                return text
        return None

    def get_recent_orders(self):
        return self.find_all_by_text_contains("Pedido #")

    # ── Assertions ────────────────────────────────────────────────────────────

    def assert_dashboard_loaded(self):
        assert self.is_text_contains_visible("Clientes"), "Card 'Clientes' não encontrado"
        assert self.is_text_contains_visible("Produtos"), "Card 'Produtos' não encontrado"
        assert self.is_text_contains_visible("Pedidos"), "Card 'Pedidos' não encontrado"
        assert self.is_text_contains_visible("Faturamento"), "Card 'Faturamento' não encontrado"

    def assert_has_recent_orders_section(self):
        assert self.is_text_visible("Pedidos Recentes"), "Seção 'Pedidos Recentes' não encontrada"

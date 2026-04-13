from .base_page import BasePage


class OrdersPage(BasePage):

    # ── Navegação ─────────────────────────────────────────────────────────────

    def open(self):
        self.navigate_to_tab("Pedidos")
        return self

    # ── Ações ─────────────────────────────────────────────────────────────────

    def tap_new_order_button(self):
        self.find_by_description("Novo Pedido").click()

    def filter_by_status(self, status):
        """status: 'Pendente' | 'Confirmado' | 'Cancelado'"""
        self.tap_by_text(status)

    def tap_order(self, customer_name):
        self.find_by_text_contains(customer_name).click()

    def confirm_order(self):
        self.tap_by_text("Confirmar Pedido")

    def cancel_order(self):
        self.tap_by_text("Cancelar Pedido")

    def get_all_orders(self):
        return self.find_all_by_text_contains("Pedido #")

    # ── Assertions ────────────────────────────────────────────────────────────

    def assert_page_loaded(self):
        assert self.is_text_visible("Pedidos"), "Título 'Pedidos' não encontrado"

    def assert_order_visible(self, customer_name):
        assert self.is_text_visible(customer_name), \
            f"Pedido do cliente '{customer_name}' não encontrado"

    def assert_order_status(self, customer_name, status):
        order_el = self.find_by_text(customer_name)
        parent = order_el.find_element("xpath", "./../..")
        assert status in parent.text, \
            f"Status '{status}' não encontrado no pedido de '{customer_name}'"

    def assert_empty_list(self):
        assert self.is_text_contains_visible("nenhum pedido", timeout=5) or \
               len(self.get_all_orders()) == 0, "Lista de pedidos deveria estar vazia"

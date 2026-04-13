from .base_page import BasePage


class CustomersPage(BasePage):

    # ── Navegação ─────────────────────────────────────────────────────────────

    def open(self):
        self.navigate_to_tab("Clientes")
        return self

    # ── Ações ─────────────────────────────────────────────────────────────────

    def tap_add_button(self):
        """Toca no FAB para adicionar novo cliente."""
        self.find_by_description("Adicionar").click()

    def search(self, query):
        search_field = self.find_by_text("Buscar clientes...")
        self.type_in_field(search_field, query)

    def clear_search(self):
        search_field = self.find_by_text_contains("Buscar")
        self.type_in_field(search_field, "")

    def fill_customer_form(self, name, document="", phone="", email="", address=""):
        self.type_in_field(self.find_by_text("Nome *"), name)
        if document:
            self.type_in_field(self.find_by_text("CPF / CNPJ"), document)
        if phone:
            self.type_in_field(self.find_by_text("Telefone"), phone)
        if email:
            self.type_in_field(self.find_by_text("E-mail"), email)
        if address:
            self.type_in_field(self.find_by_text("Endereço"), address)

    def save_customer(self):
        self.tap_by_text("Salvar")

    def cancel_form(self):
        self.tap_by_text("Cancelar")

    def tap_customer(self, name):
        self.find_by_text(name).click()

    def tap_edit_in_detail(self):
        self.tap_by_text("Editar")

    def tap_delete_in_detail(self):
        self.tap_by_text("Excluir")

    def confirm_delete(self):
        self.tap_by_text("Excluir")

    # ── Assertions ────────────────────────────────────────────────────────────

    def assert_page_loaded(self):
        assert self.is_text_visible("Clientes"), "Título 'Clientes' não encontrado"

    def assert_customer_visible(self, name):
        assert self.is_text_visible(name), f"Cliente '{name}' não encontrado na lista"

    def assert_customer_not_visible(self, name):
        assert not self.is_text_visible(name, timeout=3), f"Cliente '{name}' ainda aparece na lista"

    def assert_form_error(self, message):
        assert self.is_text_contains_visible(message), f"Mensagem de erro '{message}' não encontrada"

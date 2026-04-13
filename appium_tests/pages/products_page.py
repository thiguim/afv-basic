from .base_page import BasePage


class ProductsPage(BasePage):

    # ── Navegação ─────────────────────────────────────────────────────────────

    def open(self):
        self.navigate_to_tab("Produtos")
        return self

    # ── Ações ─────────────────────────────────────────────────────────────────

    def tap_add_button(self):
        self.find_by_description("Adicionar").click()

    def search(self, query):
        search_field = self.find_by_text("Buscar produtos...")
        self.type_in_field(search_field, query)

    def fill_product_form(self, name, code="", price="", unit="UN"):
        self.type_in_field(self.find_by_text("Nome *"), name)
        if code:
            self.type_in_field(self.find_by_text("Código"), code)
        if price:
            price_field = self.find_by_text("Preço (R$) *")
            self.type_in_field(price_field, price)
        if unit and unit != "UN":
            self.find_by_text(unit).click()

    def save_product(self):
        self.tap_by_text("Salvar")

    def tap_product(self, name):
        self.find_by_text(name).click()

    def tap_delete_in_form(self):
        self.tap_by_text("Excluir Produto")

    def confirm_delete(self):
        self.tap_by_text("Excluir")

    # ── Assertions ────────────────────────────────────────────────────────────

    def assert_page_loaded(self):
        assert self.is_text_visible("Produtos"), "Título 'Produtos' não encontrado"

    def assert_product_visible(self, name):
        assert self.is_text_visible(name), f"Produto '{name}' não encontrado na lista"

    def assert_product_not_visible(self, name):
        assert not self.is_text_visible(name, timeout=3), f"Produto '{name}' ainda aparece na lista"

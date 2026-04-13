from .base_page import BasePage


class NewOrderPage(BasePage):

    # ── Seção: Cliente ────────────────────────────────────────────────────────

    def select_customer(self, name):
        self.tap_by_text("Selecionar cliente")
        self.find_by_text(name).click()

    # ── Seção: Produtos ───────────────────────────────────────────────────────

    def tap_add_product(self):
        self.tap_by_text("Adicionar")

    def add_product(self, product_name):
        self.tap_add_product()
        self.find_by_text(product_name).click()

    def set_product_quantity(self, product_name, qty):
        # Busca o card do produto e preenche o campo Qtd.
        items = self.driver.find_elements(
            "xpath",
            f'//*[contains(@text, "{product_name}")]/../..//*[@text="Qtd."]/..'
        )
        if items:
            self.type_in_field(items[0], str(qty))

    def set_product_discount(self, product_name, discount):
        items = self.driver.find_elements(
            "xpath",
            f'//*[contains(@text, "{product_name}")]/../..//*[@text="Desc. item"]/..'
        )
        if items:
            self.type_in_field(items[0], str(discount))

    def remove_product(self, product_name):
        # Toca no ícone de remover do card do produto
        product_el = self.find_by_text(product_name)
        parent = product_el.find_element("xpath", "./../..")
        remove_btn = parent.find_element(
            "xpath", './/*[@content-desc="Remove"]'
        )
        remove_btn.click()

    # ── Seção: Ajustes ────────────────────────────────────────────────────────

    def set_order_discount(self, percent):
        field = self.find_by_text("Desconto (%)")
        self.type_in_field(field, str(percent))

    def set_order_surcharge(self, percent):
        field = self.find_by_text("Acréscimo (%)")
        self.type_in_field(field, str(percent))

    # ── Seção: Pagamento ──────────────────────────────────────────────────────

    def select_payment_condition(self, name):
        self.tap_by_text(name)

    # ── Seção: Observações ────────────────────────────────────────────────────

    def set_notes(self, text):
        field = self.find_by_text("Instruções de entrega, referências...")
        self.type_in_field(field, text)

    # ── Salvar / Cancelar ─────────────────────────────────────────────────────

    def save(self):
        self.tap_by_text("Confirmar Pedido")

    def go_back(self):
        self.driver.back()

    # ── Assertions ────────────────────────────────────────────────────────────

    def assert_page_loaded(self):
        assert self.is_text_visible("Novo Pedido"), "Tela 'Novo Pedido' não encontrada"

    def assert_save_disabled(self):
        btn = self.find_by_text("Confirmar Pedido")
        assert not btn.is_enabled(), "Botão 'Confirmar Pedido' deveria estar desabilitado"

    def assert_total_visible(self, amount_contains):
        assert self.is_text_contains_visible(amount_contains), \
            f"Total contendo '{amount_contains}' não encontrado"

    def assert_success_snackbar(self):
        assert self.is_text_visible("Pedido criado com sucesso!"), \
            "Snackbar de sucesso não apareceu"

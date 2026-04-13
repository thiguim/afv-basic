import pytest
from pages.products_page import ProductsPage

PRODUCT_NAME = "Produto Teste Appium"
PRODUCT_CODE = "TST-001"
PRODUCT_PRICE = "49.90"


class TestProducts:

    @pytest.fixture(autouse=True)
    def setup(self, driver):
        self.page = ProductsPage(driver)
        self.page.open()

    # ── Listagem ──────────────────────────────────────────────────────────────

    def test_tela_produtos_carrega(self):
        """Tela de Produtos deve ser carregada corretamente."""
        self.page.assert_page_loaded()

    def test_produtos_pre_cadastrados_visiveis(self):
        """Produtos pré-cadastrados no AppStore devem aparecer na lista."""
        # O AppStore inicializa com 8 produtos
        assert self.page.is_text_contains_visible("Café") or \
               self.page.is_text_contains_visible("Arroz") or \
               self.page.is_text_contains_visible("Feijão"), \
               "Nenhum produto pré-cadastrado encontrado"

    # ── Busca ─────────────────────────────────────────────────────────────────

    def test_busca_por_nome_filtra_lista(self):
        """Busca por nome deve filtrar os produtos."""
        self.page.search("Café")
        assert self.page.is_text_contains_visible("Café"), \
            "Produto 'Café' não apareceu após busca"

    def test_busca_por_codigo_filtra_lista(self):
        """Busca por código deve filtrar os produtos."""
        self.page.search("001")
        results = self.page.find_all_by_text_contains("001")
        assert len(results) > 0, "Nenhum produto com código '001' encontrado"

    # ── Criar ─────────────────────────────────────────────────────────────────

    def test_criar_produto_com_sucesso(self):
        """Deve criar um novo produto e exibir na lista."""
        self.page.tap_add_button()
        self.page.fill_product_form(
            name=PRODUCT_NAME,
            code=PRODUCT_CODE,
            price=PRODUCT_PRICE,
            unit="UN",
        )
        self.page.save_product()
        self.page.assert_product_visible(PRODUCT_NAME)

    def test_criar_produto_sem_nome_nao_salva(self):
        """Formulário não deve salvar produto sem nome."""
        self.page.tap_add_button()
        self.page.fill_product_form(name="", price=PRODUCT_PRICE)
        self.page.save_product()
        # Modal deve permanecer aberto
        assert self.page.is_text_visible("Salvar"), "Modal fechou sem nome preenchido"
        self.page.driver.back()

    def test_criar_produto_sem_preco_nao_salva(self):
        """Formulário não deve salvar produto sem preço."""
        self.page.tap_add_button()
        self.page.fill_product_form(name="Produto Sem Preco", price="")
        self.page.save_product()
        assert self.page.is_text_visible("Salvar"), "Modal fechou sem preço preenchido"
        self.page.driver.back()

    # ── Editar ────────────────────────────────────────────────────────────────

    def test_editar_produto_atualiza_dados(self):
        """Deve editar o produto criado."""
        self.page.tap_product(PRODUCT_NAME)
        name_field = self.page.find_by_text(PRODUCT_NAME)
        self.page.type_in_field(name_field, PRODUCT_NAME + " Edit")
        self.page.save_product()
        self.page.assert_product_visible(PRODUCT_NAME + " Edit")

    # ── Excluir ───────────────────────────────────────────────────────────────

    def test_excluir_produto_remove_da_lista(self):
        """Deve excluir o produto editado."""
        edited = PRODUCT_NAME + " Edit"
        name = edited if self.page.is_text_visible(edited, timeout=3) else PRODUCT_NAME
        self.page.tap_product(name)
        self.page.tap_delete_in_form()
        self.page.confirm_delete()
        self.page.assert_product_not_visible(PRODUCT_NAME)

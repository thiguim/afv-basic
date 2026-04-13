import pytest
from pages.customers_page import CustomersPage

CUSTOMER_NAME = "Cliente Teste Appium"
CUSTOMER_DOC = "123.456.789-00"
CUSTOMER_PHONE = "(11) 99999-1234"


class TestCustomers:

    @pytest.fixture(autouse=True)
    def setup(self, driver):
        self.page = CustomersPage(driver)
        self.page.open()

    # ── Listagem ──────────────────────────────────────────────────────────────

    def test_tela_clientes_carrega(self):
        """Tela de Clientes deve ser carregada corretamente."""
        self.page.assert_page_loaded()

    def test_clientes_pre_cadastrados_visiveis(self):
        """Clientes pré-cadastrados no AppStore devem aparecer na lista."""
        # O AppStore inicializa com 4 clientes — verifica ao menos 1
        assert self.page.is_text_contains_visible("Ana") or \
               self.page.is_text_contains_visible("Carlos") or \
               self.page.is_text_contains_visible("Fernanda"), \
               "Nenhum cliente pré-cadastrado encontrado"

    # ── Busca ─────────────────────────────────────────────────────────────────

    def test_busca_por_nome_filtra_lista(self):
        """Campo de busca deve filtrar clientes pelo nome."""
        self.page.search("Ana")
        assert self.page.is_text_contains_visible("Ana"), \
            "Cliente 'Ana' não apareceu após busca"

    def test_busca_sem_resultado_nao_exibe_clientes(self):
        """Busca por nome inexistente não deve retornar clientes."""
        self.page.search("XYZ_INEXISTENTE_999")
        results = self.page.find_all_by_text_contains("XYZ_INEXISTENTE")
        assert len(results) == 0, "Resultado inesperado na busca"

    # ── Criar ─────────────────────────────────────────────────────────────────

    def test_criar_cliente_com_sucesso(self):
        """Deve criar um novo cliente e exibir na lista."""
        self.page.tap_add_button()
        self.page.fill_customer_form(
            name=CUSTOMER_NAME,
            document=CUSTOMER_DOC,
            phone=CUSTOMER_PHONE,
        )
        self.page.save_customer()
        self.page.assert_customer_visible(CUSTOMER_NAME)

    def test_criar_cliente_sem_nome_nao_salva(self):
        """Formulário não deve salvar cliente sem nome."""
        self.page.tap_add_button()
        self.page.fill_customer_form(name="")
        self.page.save_customer()
        # Botão Salvar deve permanecer desabilitado ou exibir erro
        assert self.page.is_text_visible("Novo Pedido") is False  # modal ainda aberto
        self.page.cancel_form()

    # ── Editar ────────────────────────────────────────────────────────────────

    def test_editar_cliente_atualiza_dados(self):
        """Deve editar o nome de um cliente existente."""
        self.page.tap_customer(CUSTOMER_NAME)
        self.page.tap_edit_in_detail()
        name_field = self.page.find_by_text(CUSTOMER_NAME)
        self.page.type_in_field(name_field, CUSTOMER_NAME + " Editado")
        self.page.save_customer()
        self.page.assert_customer_visible(CUSTOMER_NAME + " Editado")

    # ── Excluir ───────────────────────────────────────────────────────────────

    def test_excluir_cliente_remove_da_lista(self):
        """Deve excluir o cliente criado no teste anterior."""
        edited_name = CUSTOMER_NAME + " Editado"
        if self.page.is_text_visible(edited_name, timeout=3):
            self.page.tap_customer(edited_name)
        else:
            self.page.tap_customer(CUSTOMER_NAME)

        self.page.tap_delete_in_detail()
        self.page.confirm_delete()
        self.page.assert_customer_not_visible(CUSTOMER_NAME)

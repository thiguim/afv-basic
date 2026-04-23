"""Page Object — Tela de Login (Landix Basic)

Locators baseados no dump de UI (UiAutomator2) do dispositivo Moto G04.
A tela de login é um widget Flutter sem resource-ids; os seletores usam
XPath por classe/índice e AccessibilityId (content-desc) onde disponível.
"""

from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException


# ── Locators ──────────────────────────────────────────────────────────────
class LoginLocators:
    # Campos de entrada
    EMAIL_FIELD    = (AppiumBy.XPATH,          "//android.widget.EditText[1]")
    PASSWORD_FIELD = (AppiumBy.XPATH,          "//android.widget.EditText[2]")
    EYE_TOGGLE     = (AppiumBy.XPATH,          "//android.widget.EditText[2]//android.widget.Button")

    # Botões e links
    ENTRAR_BTN     = (AppiumBy.ACCESSIBILITY_ID, "Entrar")
    FORGOT_LINK    = (AppiumBy.ACCESSIBILITY_ID, "Esqueci minha senha")

    # Textos de referência (View com content-desc)
    APP_TITLE      = (AppiumBy.ACCESSIBILITY_ID, "Landix Basic\nForça de Vendas")
    SUBTITLE       = (AppiumBy.ACCESSIBILITY_ID, "Acesse sua conta para continuar")

    # Mensagem de erro (exibida no mesmo container do formulário)
    ERROR_MSG      = (AppiumBy.XPATH, "//*[contains(@content-desc,'Preencha') or contains(@content-desc,'campos')]")


# ── Page Object ───────────────────────────────────────────────────────────
class LoginPage:
    def __init__(self, driver):
        self.driver = driver
        self.wait   = WebDriverWait(driver, 10)

    # ── queries ──────────────────────────────────────────────────────────

    def is_displayed(self) -> bool:
        """Retorna True se a tela de login está visível."""
        try:
            self.wait.until(EC.presence_of_element_located(LoginLocators.ENTRAR_BTN))
            return True
        except Exception:
            return False

    def get_email_field(self):
        return self.wait.until(EC.presence_of_element_located(LoginLocators.EMAIL_FIELD))

    def get_password_field(self):
        return self.wait.until(EC.presence_of_element_located(LoginLocators.PASSWORD_FIELD))

    def get_entrar_button(self):
        return self.wait.until(EC.element_to_be_clickable(LoginLocators.ENTRAR_BTN))

    def get_forgot_link(self):
        return self.wait.until(EC.element_to_be_clickable(LoginLocators.FORGOT_LINK))

    def get_eye_toggle(self):
        return self.wait.until(EC.element_to_be_clickable(LoginLocators.EYE_TOGGLE))

    def element_exists(self, locator) -> bool:
        try:
            self.driver.find_element(*locator)
            return True
        except NoSuchElementException:
            return False

    def get_error_message(self):
        """Retorna o texto do erro exibido após ação inválida."""
        try:
            el = self.wait.until(EC.presence_of_element_located(LoginLocators.ERROR_MSG))
            return el.get_attribute("content-desc") or el.text
        except Exception:
            return None

    def is_password_masked(self) -> bool:
        """Retorna True se o campo senha está com máscara (password=true)."""
        field = self.get_password_field()
        return field.get_attribute("password") == "true"

    # ── actions ──────────────────────────────────────────────────────────

    def enter_email(self, email: str):
        field = self.get_email_field()
        field.clear()
        field.send_keys(email)

    def enter_password(self, password: str):
        field = self.get_password_field()
        field.clear()
        field.send_keys(password)

    def tap_entrar(self):
        self.get_entrar_button().click()

    def tap_forgot_password(self):
        self.get_forgot_link().click()

    def tap_eye_toggle(self):
        self.get_eye_toggle().click()

    def dismiss_keyboard(self):
        self.driver.hide_keyboard()

    def do_login(self, email: str, password: str):
        """Atalho: preenche credenciais e toca em Entrar."""
        self.enter_email(email)
        self.dismiss_keyboard()
        self.enter_password(password)
        self.dismiss_keyboard()
        self.tap_entrar()

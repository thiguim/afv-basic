import pytest
from appium import webdriver
from appium.options.android.uiautomator2.base import UiAutomator2Options


APPIUM_SERVER = "http://127.0.0.1:4723"


@pytest.fixture(scope="function")
def driver():
    """Inicia o driver Appium e garante que a tela de login está visível."""
    options = UiAutomator2Options()
    options.device_name          = "0086380343"
    options.platform_version     = "14"
    options.app_package          = "com.example.afv_basico"
    options.app_activity         = "com.example.afv_basico.MainActivity"
    options.no_reset             = True
    options.new_command_timeout  = 60
    options.auto_grant_permissions = True

    d = webdriver.Remote(APPIUM_SERVER, options=options)
    d.implicitly_wait(10)

    # Força retorno à tela de login a cada teste
    d.activate_app("com.example.afv_basico")

    yield d

    d.quit()

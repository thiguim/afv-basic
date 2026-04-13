import pytest
from appium import webdriver
from appium.options import UiAutomator2Options


DEVICE_ID = "0086380343"
APP_PACKAGE = "com.example.afv_basico"
APP_ACTIVITY = "com.example.afv_basico.MainActivity"
APPIUM_SERVER = "http://127.0.0.1:4723"


def pytest_addoption(parser):
    parser.addoption("--device-id", default=DEVICE_ID, help="Android device ID (adb devices)")
    parser.addoption("--appium-url", default=APPIUM_SERVER, help="Appium server URL")


@pytest.fixture(scope="session")
def driver(request):
    device_id = request.config.getoption("--device-id")
    appium_url = request.config.getoption("--appium-url")

    options = UiAutomator2Options()
    options.platform_name = "Android"
    options.udid = device_id
    options.app_package = APP_PACKAGE
    options.app_activity = APP_ACTIVITY
    options.no_reset = True          # mantém dados entre sessões
    options.auto_grant_permissions = True
    options.new_command_timeout = 60

    driver = webdriver.Remote(appium_url, options=options)
    driver.implicitly_wait(10)

    yield driver

    driver.quit()


@pytest.fixture(autouse=True)
def reset_app_state(driver):
    """Volta para a tela inicial antes de cada teste."""
    driver.activate_app(APP_PACKAGE)
    yield

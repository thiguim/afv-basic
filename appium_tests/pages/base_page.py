from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException


class BasePage:
    DEFAULT_TIMEOUT = 10

    def __init__(self, driver):
        self.driver = driver
        self.wait = WebDriverWait(driver, self.DEFAULT_TIMEOUT)

    # ── Finders ───────────────────────────────────────────────────────────────

    def find_by_text(self, text, timeout=None):
        timeout = timeout or self.DEFAULT_TIMEOUT
        return WebDriverWait(self.driver, timeout).until(
            EC.presence_of_element_located(
                (AppiumBy.ANDROID_UIAUTOMATOR,
                 f'new UiSelector().text("{text}")'))
        )

    def find_by_text_contains(self, text, timeout=None):
        timeout = timeout or self.DEFAULT_TIMEOUT
        return WebDriverWait(self.driver, timeout).until(
            EC.presence_of_element_located(
                (AppiumBy.ANDROID_UIAUTOMATOR,
                 f'new UiSelector().textContains("{text}")'))
        )

    def find_by_description(self, desc, timeout=None):
        timeout = timeout or self.DEFAULT_TIMEOUT
        return WebDriverWait(self.driver, timeout).until(
            EC.presence_of_element_located(
                (AppiumBy.ACCESSIBILITY_ID, desc))
        )

    def find_all_by_text_contains(self, text):
        return self.driver.find_elements(
            AppiumBy.ANDROID_UIAUTOMATOR,
            f'new UiSelector().textContains("{text}")'
        )

    # ── Actions ───────────────────────────────────────────────────────────────

    def tap_by_text(self, text):
        self.find_by_text(text).click()

    def tap_by_text_contains(self, text):
        self.find_by_text_contains(text).click()

    def tap_by_description(self, desc):
        self.find_by_description(desc).click()

    def type_in_field(self, element, text):
        element.clear()
        element.send_keys(text)

    def scroll_down(self):
        size = self.driver.get_window_size()
        start_x = size["width"] // 2
        start_y = int(size["height"] * 0.8)
        end_y = int(size["height"] * 0.2)
        self.driver.swipe(start_x, start_y, start_x, end_y, 600)

    def scroll_up(self):
        size = self.driver.get_window_size()
        start_x = size["width"] // 2
        start_y = int(size["height"] * 0.2)
        end_y = int(size["height"] * 0.8)
        self.driver.swipe(start_x, start_y, start_x, end_y, 600)

    # ── Checks ────────────────────────────────────────────────────────────────

    def is_text_visible(self, text, timeout=5):
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located(
                    (AppiumBy.ANDROID_UIAUTOMATOR,
                     f'new UiSelector().text("{text}")'))
            )
            return True
        except TimeoutException:
            return False

    def is_text_contains_visible(self, text, timeout=5):
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located(
                    (AppiumBy.ANDROID_UIAUTOMATOR,
                     f'new UiSelector().textContains("{text}")'))
            )
            return True
        except TimeoutException:
            return False

    # ── Navigation ────────────────────────────────────────────────────────────

    def navigate_to_tab(self, tab_name):
        """Navega para uma aba da bottom navigation bar."""
        self.find_by_text(tab_name).click()

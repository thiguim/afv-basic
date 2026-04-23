const pptxgen = require("pptxgenjs");
const fs = require("fs");

const C = {
  blue:      "2563EB",
  darkBlue:  "1E3A8A",
  midBlue:   "1D4ED8",
  lightBlue: "DBEAFE",
  navy:      "0F172A",
  white:     "FFFFFF",
  bg:        "F0F4FF",
  text:      "1E293B",
  muted:     "64748B",
  border:    "BFDBFE",
  green:     "059669",
  greenBg:   "D1FAE5",
  amber:     "D97706",
  amberBg:   "FEF3C7",
  red:       "DC2626",
  redBg:     "FEE2E2",
  purple:    "7C3AED",
  purpleBg:  "EDE9FE",
};
const F = "Calibri";

const pres = new pptxgen();
pres.layout = "LAYOUT_16x9";
pres.title  = "Automação Mobile — Appium + Python";

const makeShadow = () => ({ type: "outer", color: "000000", blur: 8, offset: 2, angle: 135, opacity: 0.12 });

// ══════════════════════════════════════════════════════════════════════════
// SLIDE 1 — STACK & ARQUITETURA
// ══════════════════════════════════════════════════════════════════════════
{
  const s = pres.addSlide();
  s.background = { color: C.navy };

  // ── left panel (dark) ──────────────────────────────────────────────────
  // header strip
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 0, w: 5.1, h: 0.78,
    fill: { color: C.blue }, line: { color: C.blue },
  });
  s.addText("Automação Mobile", {
    x: 0.3, y: 0, w: 4.6, h: 0.78,
    fontFace: F, fontSize: 22, bold: true, color: C.white, valign: "middle", margin: 0,
  });

  // subtitle
  s.addText("Appium  +  Python  ·  Android (UiAutomator2)", {
    x: 0.3, y: 0.9, w: 4.6, h: 0.35,
    fontFace: F, fontSize: 13, color: C.lightBlue,
  });

  // stack cards
  const stack = [
    { icon: "🤖", name: "Appium 2.x",        desc: "Server WebDriver — protocolo W3C",     color: C.blue },
    { icon: "🐍", name: "Python 3.x",         desc: "appium-python-client 3.1",              color: "059669" },
    { icon: "📱", name: "UiAutomator2",        desc: "Driver Android — sem root necessário", color: C.purple },
    { icon: "✅", name: "pytest",              desc: "Framework de testes + relatório HTML",  color: C.amber },
    { icon: "📐", name: "Page Object Model",   desc: "LoginPage · locators centralizados",   color: "0891B2" },
  ];

  stack.forEach((item, i) => {
    const y = 1.35 + i * 0.83;
    s.addShape(pres.shapes.RECTANGLE, {
      x: 0.25, y, w: 4.6, h: 0.7,
      fill: { color: "1E293B" }, line: { color: "334155" },
    });
    s.addShape(pres.shapes.RECTANGLE, {
      x: 0.25, y, w: 0.07, h: 0.7,
      fill: { color: item.color }, line: { color: item.color },
    });
    s.addText(item.icon, {
      x: 0.35, y, w: 0.55, h: 0.7,
      fontSize: 20, align: "center", valign: "middle",
    });
    s.addText(item.name, {
      x: 0.95, y: y + 0.06, w: 3.8, h: 0.3,
      fontFace: F, fontSize: 13, bold: true, color: C.white,
    });
    s.addText(item.desc, {
      x: 0.95, y: y + 0.36, w: 3.8, h: 0.25,
      fontFace: F, fontSize: 10, color: "94A3B8",
    });
  });

  // ── right panel (light) ────────────────────────────────────────────────
  s.addShape(pres.shapes.RECTANGLE, {
    x: 5.1, y: 0, w: 4.9, h: 5.625,
    fill: { color: C.bg }, line: { color: C.bg },
  });

  // right header
  s.addShape(pres.shapes.RECTANGLE, {
    x: 5.1, y: 0, w: 4.9, h: 0.78,
    fill: { color: C.darkBlue }, line: { color: C.darkBlue },
  });
  s.addText("Arquitetura & Fluxo", {
    x: 5.4, y: 0, w: 4.4, h: 0.78,
    fontFace: F, fontSize: 20, bold: true, color: C.white, valign: "middle", margin: 0,
  });

  // flow diagram
  const flow = [
    { icon: "🧪", label: "pytest",         sub: "test_login.py" },
    { icon: "📄", label: "LoginPage",      sub: "Page Object Model" },
    { icon: "🔌", label: "Appium Client",  sub: "appium-python-client" },
    { icon: "⚙️",  label: "Appium Server", sub: "localhost:4723" },
    { icon: "📱", label: "Dispositivo",    sub: "Moto G04 · Android 14" },
  ];

  flow.forEach((f, i) => {
    const fy = 0.95 + i * 0.88;
    s.addShape(pres.shapes.RECTANGLE, {
      x: 5.3, y: fy, w: 4.5, h: 0.62,
      fill: { color: C.white }, line: { color: C.border, pt: 1 },
      shadow: makeShadow(),
    });
    s.addText(f.icon, {
      x: 5.35, y: fy, w: 0.6, h: 0.62,
      fontSize: 18, align: "center", valign: "middle",
    });
    s.addText(f.label, {
      x: 6.0, y: fy + 0.06, w: 3.7, h: 0.26,
      fontFace: F, fontSize: 13, bold: true, color: C.darkBlue,
    });
    s.addText(f.sub, {
      x: 6.0, y: fy + 0.32, w: 3.7, h: 0.22,
      fontFace: F, fontSize: 10, color: C.muted,
    });
    if (i < flow.length - 1) {
      s.addShape(pres.shapes.LINE, {
        x: 7.5, y: fy + 0.63, w: 0, h: 0.23,
        line: { color: C.blue, width: 1.5 },
      });
      s.addText("▼", {
        x: 7.3, y: fy + 0.72, w: 0.4, h: 0.2,
        fontSize: 9, color: C.blue, align: "center", margin: 0,
      });
    }
  });
}

// ══════════════════════════════════════════════════════════════════════════
// SLIDE 2 — CASOS DE TESTE
// ══════════════════════════════════════════════════════════════════════════
{
  const s = pres.addSlide();
  s.background = { color: C.bg };

  // header
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 0, w: 10, h: 0.7,
    fill: { color: C.blue }, line: { color: C.blue },
  });
  s.addText("Casos de Teste — Tela de Login  ·  Landix Basic", {
    x: 0.35, y: 0, w: 7.0, h: 0.7,
    fontFace: F, fontSize: 20, bold: true, color: C.white, valign: "middle", margin: 0,
  });
  // badge total
  s.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x: 8.4, y: 0.12, w: 1.25, h: 0.46,
    fill: { color: C.darkBlue }, line: { color: C.darkBlue }, rectRadius: 0.08,
  });
  s.addText("12 CTs", {
    x: 8.4, y: 0.12, w: 1.25, h: 0.46,
    fontFace: F, fontSize: 14, bold: true, color: C.white, align: "center", valign: "middle",
  });

  // ── CT cards (2 columns × 6 rows) ─────────────────────────────────────
  // Layout math:
  //   header = 0.70", bottom bar starts at 5.25"  → available = 4.55"
  //   startY = 0.76", usable = 5.25 - 0.76 = 4.49"
  //   rowSlot = 4.49 / 6 = 0.748"  |  gapY = 0.06"  |  cardH = 0.688"
  //   last card bottom = 0.76 + 6×0.748 = 5.248"  ✓ fits before 5.25"

  const cts = [
    { id: "CT-1",  title: "Exibir tela de login",           steps: 3, tag: "UI",          tagC: "0891B2",  tagBg: "E0F2FE" },
    { id: "CT-2",  title: "Login com credenciais válidas",  steps: 3, tag: "Happy Path",   tagC: C.green,   tagBg: C.greenBg },
    { id: "CT-3",  title: "Login com senha inválida",       steps: 3, tag: "Negativo",     tagC: C.red,     tagBg: C.redBg },
    { id: "CT-4",  title: "Login sem informar e-mail",      steps: 3, tag: "Validação",    tagC: C.amber,   tagBg: C.amberBg },
    { id: "CT-5",  title: "Login sem informar senha",       steps: 3, tag: "Validação",    tagC: C.amber,   tagBg: C.amberBg },
    { id: "CT-6",  title: "Campos em branco",               steps: 2, tag: "Validação",    tagC: C.amber,   tagBg: C.amberBg },
    { id: "CT-7",  title: "Exibir e ocultar senha",         steps: 3, tag: "UI",           tagC: "0891B2",  tagBg: "E0F2FE" },
    { id: "CT-8",  title: "Máscara no campo Senha",         steps: 3, tag: "Segurança",    tagC: C.purple,  tagBg: C.purpleBg },
    { id: "CT-9",  title: "E-mail com formato inválido",    steps: 3, tag: "Negativo",     tagC: C.red,     tagBg: C.redBg },
    { id: "CT-10", title: "Toque em Esqueci minha senha",   steps: 2, tag: "Navegação",    tagC: "0891B2",  tagBg: "E0F2FE" },
    { id: "CT-11", title: "Indicador de carregamento",      steps: 3, tag: "UI",           tagC: "0891B2",  tagBg: "E0F2FE" },
    { id: "CT-12", title: "E-mail com espaços (trim)",      steps: 3, tag: "Dados",        tagC: C.green,   tagBg: C.greenBg },
  ];

  const startX  = 0.18;
  const startY  = 0.76;
  const cardW   = 4.72;
  const cardH   = 0.688;
  const gapX    = 0.18;
  const rowSlot = 0.748;   // cardH + gapY (= 0.06)

  // Right-column widths inside each card
  const tagW    = 1.22;
  const tagX    = (ct_x) => ct_x + cardW - tagW - 0.12;   // right-aligned with 0.12" margin
  const badgeW  = 0.78;
  const badgeX  = (ct_x) => ct_x + cardW - badgeW - 0.12; // same right margin

  cts.forEach((ct, i) => {
    const col = i % 2;
    const row = Math.floor(i / 2);
    const x   = startX + col * (cardW + gapX);
    const y   = startY + row * rowSlot;

    // ── card background ──
    s.addShape(pres.shapes.RECTANGLE, {
      x, y, w: cardW, h: cardH,
      fill: { color: C.white }, line: { color: C.border, pt: 1 },
      shadow: makeShadow(),
    });

    // ── left accent bar ──
    s.addShape(pres.shapes.RECTANGLE, {
      x, y, w: 0.07, h: cardH,
      fill: { color: C.blue }, line: { color: C.blue },
    });

    // ── CT-N badge (vertically centered) ──
    const badgeH = 0.30;
    const badgeY = y + (cardH - badgeH) / 2;
    s.addShape(pres.shapes.ROUNDED_RECTANGLE, {
      x: x + 0.13, y: badgeY, w: 0.74, h: badgeH,
      fill: { color: C.lightBlue }, line: { color: C.border }, rectRadius: 0.05,
    });
    s.addText(ct.id, {
      x: x + 0.13, y: badgeY, w: 0.74, h: badgeH,
      fontFace: F, fontSize: 10, bold: true, color: C.darkBlue,
      align: "center", valign: "middle", margin: 0,
    });

    // ── Title (vertically centered, between badge and right column) ──
    s.addText(ct.title, {
      x: x + 0.95, y, w: 2.65, h: cardH,
      fontFace: F, fontSize: 12, bold: true, color: C.text,
      valign: "middle",
    });

    // ── Tag badge (top-right, inside card) ──
    const tagH    = 0.26;
    const tagTopY = y + 0.10;
    s.addShape(pres.shapes.ROUNDED_RECTANGLE, {
      x: tagX(x), y: tagTopY, w: tagW, h: tagH,
      fill: { color: ct.tagBg }, line: { color: ct.tagC, pt: 1 }, rectRadius: 0.05,
    });
    s.addText(ct.tag, {
      x: tagX(x), y: tagTopY, w: tagW, h: tagH,
      fontFace: F, fontSize: 9, bold: true, color: ct.tagC,
      align: "center", valign: "middle", margin: 0,
    });

    // ── "X passos" (bottom-right, below tag, muted) ──
    const stepsY = tagTopY + tagH + 0.05;
    s.addText(`${ct.steps} passos`, {
      x: tagX(x), y: stepsY, w: tagW, h: 0.20,
      fontFace: F, fontSize: 9, color: C.muted, align: "center",
    });
  });

  // ── bottom bar ─────────────────────────────────────────────────────────
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 5.25, w: 10, h: 0.375,
    fill: { color: C.darkBlue }, line: { color: C.darkBlue },
  });

  const summary = [
    { label: "Happy Path", count: "1", color: C.green },
    { label: "Negativo",   count: "2", color: C.red },
    { label: "Validação",  count: "3", color: C.amber },
    { label: "UI",         count: "4", color: "38BDF8" },
    { label: "Segurança",  count: "1", color: "A78BFA" },
    { label: "Navegação",  count: "1", color: "38BDF8" },
  ];
  summary.forEach((sm, i) => {
    s.addText(`${sm.count}x  ${sm.label}`, {
      x: 0.3 + i * 1.6, y: 5.26, w: 1.5, h: 0.34,
      fontFace: F, fontSize: 11, bold: true, color: sm.color,
      align: "center", valign: "middle",
    });
    if (i < summary.length - 1) {
      s.addShape(pres.shapes.LINE, {
        x: 1.72 + i * 1.6, y: 5.3, w: 0, h: 0.25,
        line: { color: "334155", width: 0.8 },
      });
    }
  });
}

// ── write ──────────────────────────────────────────────────────────────────
pres.writeFile({ fileName: "D:/afv-basic/automacao_appium_python.pptx" })
  .then(() => console.log("Saved OK — automacao_appium_python.pptx"))
  .catch(e => { console.error(e); process.exit(1); });

/* =========================================================
   NEXO — lógica de chat compartida por TODOS los menús
   (estudiante, profesor, coordinador, administración).
   Usa window.NEXO = { grupos: [...], vacioGlobal: "" }
   y la API  /api/canales/<id>/mensajes
   ========================================================= */

(function () {
  "use strict";

  var CONFIG = window.NEXO || { grupos: [], vacioGlobal: "" };
  var INTERVALO_MS = 3000;

  var COLORES = ["#1F5D50", "#4A3B7A", "#8A1F2B", "#B5824A",
                 "#2F6690", "#5B7B3A", "#9A4C7A", "#3D5A80"];

  var $ = function (id) { return document.getElementById(id); };

  var estado = {
    canal: null,        // item del canal abierto
    ultimoId: 0,        // id del último mensaje mostrado
    temporizador: null,
    enviando: false,
    archivo: null       // archivo elegido para adjuntar (aún sin enviar)
  };

  var NOTIF_MS = 5000;
  var CLAVE_ULTIMO = "nexo_ultimo_notif";

  var notif = {
    ultimo: null,        // id del último mensaje ya avisado
    temporizador: null,
    noLeidos: {},        // canal_id -> cantidad
    tituloBase: document.title
  };

  // ---------- utilidades ----------

  function colorDe(texto) {
    var h = 0;
    for (var i = 0; i < texto.length; i++) {
      h = (h * 31 + texto.charCodeAt(i)) >>> 0;
    }
    return COLORES[h % COLORES.length];
  }

  function el(tag, clase, texto) {
    var e = document.createElement(tag);
    if (clase) e.className = clase;
    if (texto !== undefined && texto !== null) e.textContent = texto;
    return e;
  }

  function normalizar(s) {
    return (s || "").toLowerCase()
      .normalize("NFD").replace(/[\u0300-\u036f]/g, "");
  }

  function enModoEscritorio() {
    return window.matchMedia("(min-width: 860px)").matches;
  }

  // ---------- lista de canales ----------

  function pintarLista(filtro) {
    var lista = $("salonList");
    if (!lista) return;

    lista.innerHTML = "";
    filtro = normalizar(filtro || "");

    var grupos = (CONFIG && CONFIG.grupos) || [];
    var totalItems = 0;
    var mostrados = 0;

    grupos.forEach(function (g) { totalItems += (g.items || []).length; });

    if (CONFIG.vacioGlobal && totalItems === 0) {
      lista.appendChild(el("div", "pending-db", CONFIG.vacioGlobal));
      return;
    }

    grupos.forEach(function (grupo) {
      var items = (grupo.items || []).filter(function (it) {
        if (!filtro) return true;
        return normalizar(it.nombre + " " + (it.sub || "")).indexOf(filtro) !== -1;
      });

      if (grupo.titulo && (items.length || (!filtro && grupo.vacio))) {
        lista.appendChild(el("div", "section-label", grupo.titulo));
      }

      if (!items.length) {
        if (!filtro && grupo.vacio) {
          lista.appendChild(el("div", "section-pending", grupo.vacio));
        }
        return;
      }

      items.forEach(function (it) {
        lista.appendChild(crearFila(it));
        mostrados++;
      });
    });

    if (filtro && mostrados === 0) {
      lista.appendChild(el("div", "no-results", "No se encontraron resultados"));
    }

    marcarActivo();
  }

  function crearFila(it) {
    var fila = el("button", "salon-row");
    fila.type = "button";
    fila.setAttribute("data-canal", it.id);

    var avatar = el("div", "avatar", it.avatarText || "?");
    avatar.style.background = colorDe(it.nombre || "");
    fila.appendChild(avatar);

    var main = el("div", "salon-main");
    var top = el("div", "salon-top");
    top.appendChild(el("span", "salon-name", it.nombre));
    top.appendChild(el("span", "salon-time", it.hora || ""));
    main.appendChild(top);
    main.appendChild(el("div", "salon-preview", it.ultima || it.sub || ""));
    fila.appendChild(main);

    ponerBadge(fila, notif.noLeidos[it.id] || 0);

    fila.addEventListener("click", function () { abrirChat(it); });
    return fila;
  }

  function marcarActivo() {
    var filas = document.querySelectorAll(".salon-row");
    for (var i = 0; i < filas.length; i++) {
      var activo = estado.canal &&
        String(filas[i].getAttribute("data-canal")) === String(estado.canal.id);
      filas[i].classList.toggle("active", !!activo);
    }
  }

  function actualizarVistaPrevia(item, mensaje) {
    var fila = document.querySelector('.salon-row[data-canal="' + item.id + '"]');
    if (!fila) return;
    var prev = fila.querySelector(".salon-preview");
    var hora = fila.querySelector(".salon-time");
    if (prev) prev.textContent = mensaje.texto.replace(/\s+/g, " ").slice(0, 80);
    if (hora) hora.textContent = mensaje.hora;
  }

  // ---------- abrir / cerrar chat ----------

  function abrirChat(item) {
    detenerPolling();

    estado.canal = item;
    estado.ultimoId = 0;
    limpiarAdjunto();

    delete notif.noLeidos[item.id];
    actualizarBadges();
    actualizarTitulo();

    var vacio = $("emptyState");
    var contenido = $("chatContent");
    if (vacio) vacio.style.display = "none";
    if (contenido) contenido.classList.add("visible");

    var avatar = $("chatAvatar");
    if (avatar) {
      avatar.textContent = item.avatarText || "?";
      avatar.style.background = colorDe(item.nombre || "");
    }
    if ($("chatName")) $("chatName").textContent = item.nombre;
    if ($("chatSub")) $("chatSub").textContent = item.sub || "";

    aplicarPermiso(!!item.puedeEscribir);

    var cont = $("messages");
    if (cont) {
      cont.innerHTML = "";
      cont.appendChild(el("div", "no-messages", "Cargando mensajes..."));
    }

    var frame = $("frame");
    if (frame) frame.classList.add("chat-open");

    marcarActivo();
    cargarMensajes(true);

    estado.temporizador = setInterval(function () {
      cargarMensajes(false);
    }, INTERVALO_MS);
  }

  function cerrarChat() {
    detenerPolling();
    estado.canal = null;
    estado.ultimoId = 0;
    limpiarAdjunto();

    var frame = $("frame");
    if (frame) frame.classList.remove("chat-open");

    var vacio = $("emptyState");
    var contenido = $("chatContent");
    if (vacio) vacio.style.display = "";
    if (contenido) contenido.classList.remove("visible");

    marcarActivo();
  }

  function detenerPolling() {
    if (estado.temporizador) {
      clearInterval(estado.temporizador);
      estado.temporizador = null;
    }
  }

  function aplicarPermiso(puedeEscribir) {
    var composer = $("composer");
    var footer = $("readonlyFooter");

    if (composer) composer.style.display = puedeEscribir ? "" : "none";
    if (footer) footer.style.display = puedeEscribir ? "none" : "";
  }

  // ---------- mensajes ----------

  function manejarErrorHttp(respuesta) {
    if (respuesta.status === 401) {
      window.location.href = "/login";
      return true;
    }
    return false;
  }

  function leerJson(respuesta) {
    return respuesta.json().catch(function () {
      return { ok: false, error: "Respuesta inesperada del servidor." };
    });
  }

  function cargarMensajes(primeraVez) {
    var canal = estado.canal;
    if (!canal) return;

    var url = "/api/canales/" + canal.id + "/mensajes";
    if (!primeraVez && estado.ultimoId) {
      url += "?despues=" + estado.ultimoId;
    }

    fetch(url, { credentials: "same-origin" })
      .then(function (r) {
        if (manejarErrorHttp(r)) return null;
        return leerJson(r);
      })
      .then(function (datos) {
        // si el usuario cambió de canal mientras llegaba la respuesta, se ignora
        if (!datos || estado.canal !== canal) return;

        if (!datos.ok) {
          if (primeraVez) mostrarAviso(datos.error || "No se pudieron cargar los mensajes.");
          return;
        }

        if (typeof datos.puedeEscribir === "boolean") {
          aplicarPermiso(datos.puedeEscribir);
        }

        if (primeraVez) {
          var cont = $("messages");
          if (cont) cont.innerHTML = "";
        }

        agregarMensajes(datos.mensajes || []);

        if (primeraVez && !estado.ultimoId) {
          mostrarAviso("Aún no hay mensajes en este canal.");
        }
      })
      .catch(function () {
        if (primeraVez) mostrarAviso("No se pudo conectar con el servidor.");
      });
  }

  function mostrarAviso(texto) {
    var cont = $("messages");
    if (!cont) return;
    cont.innerHTML = "";
    cont.appendChild(el("div", "no-messages", texto));
  }

  function agregarMensajes(mensajes) {
    var cont = $("messages");
    if (!cont || !mensajes.length) return;

    var aviso = cont.querySelector(".no-messages");
    if (aviso) cont.removeChild(aviso);

    var pegado = cont.scrollHeight - cont.scrollTop - cont.clientHeight < 80;

    mensajes.forEach(function (m) {
      if (m.id <= estado.ultimoId) return;       // evita duplicados

      var burbuja = el("div", "bubble " + (m.propio ? "out" : "in"));
      burbuja.appendChild(el("span", "sender", m.de));
      if (m.archivo) {
        burbuja.appendChild(crearAdjunto(m.archivo, function () {
          if (pegado) cont.scrollTop = cont.scrollHeight;   // la foto cargó y creció
        }));
      }
      if (m.texto) burbuja.appendChild(document.createTextNode(m.texto));
      burbuja.appendChild(el("span", "time", m.hora));
      cont.appendChild(burbuja);

      estado.ultimoId = m.id;
      if (estado.canal) {
        actualizarVistaPrevia(estado.canal, {
          texto: m.texto || (m.archivo ? "Archivo: " + m.archivo.nombre : ""),
          hora: m.hora
        });
      }
    });

    if (pegado || estado.ultimoId === mensajes[mensajes.length - 1].id) {
      cont.scrollTop = cont.scrollHeight;
    }
  }

  function enviarMensaje() {
    var canal = estado.canal;
    var input = $("msgInput");
    var boton = $("sendBtn");

    if (!canal || !input || estado.enviando) return;

    var texto = input.value.trim();
    var archivo = estado.archivo;
    if (!texto && !archivo) return;

    estado.enviando = true;
    if (boton) boton.disabled = true;

    var opciones = { method: "POST", credentials: "same-origin" };

    if (archivo) {
      // con archivo se envía como formulario (el navegador pone el Content-Type)
      var datosForm = new FormData();
      datosForm.append("contenido", texto);
      datosForm.append("archivo", archivo, archivo.name);
      opciones.body = datosForm;
    } else {
      opciones.headers = { "Content-Type": "application/json" };
      opciones.body = JSON.stringify({ contenido: texto });
    }

    fetch("/api/canales/" + canal.id + "/mensajes", opciones)
      .then(function (r) {
        if (manejarErrorHttp(r)) return null;
        return leerJson(r);
      })
      .then(function (datos) {
        if (!datos) return;
        if (!datos.ok) {
          alert(datos.error || "No se pudo enviar el mensaje.");
          return;
        }
        input.value = "";
        limpiarAdjunto();
        if (estado.canal === canal) agregarMensajes([datos.mensaje]);
      })
      .catch(function () {
        alert("No se pudo conectar con el servidor.");
      })
      .then(function () {
        estado.enviando = false;
        if (boton) boton.disabled = false;
        input.focus();
      });
  }

  // ---------- archivos adjuntos (fotos y documentos) ----------

  var MAX_BYTES = 10 * 1024 * 1024;
  var EXT_PERMITIDAS = ["png", "jpg", "jpeg", "gif", "webp", "pdf", "doc", "docx",
                        "xls", "xlsx", "ppt", "pptx", "txt", "csv", "odt", "ods",
                        "odp", "rtf"];
  var EXT_IMAGEN = ["png", "jpg", "jpeg", "gif", "webp"];

  var adj = { chip: null, input: null, urlVista: null };

  function extensionDe(nombre) {
    var i = (nombre || "").lastIndexOf(".");
    return i < 0 ? "" : nombre.slice(i + 1).toLowerCase();
  }

  function tamanoLegible(bytes) {
    if (bytes < 1024) return bytes + " B";
    if (bytes < 1048576) return Math.round(bytes / 1024) + " KB";
    return (bytes / 1048576).toFixed(1) + " MB";
  }

  function inyectarEstilosAdjuntos() {
    if ($("nexoAdjuntosCss")) return;
    var css = el("style");
    css.id = "nexoAdjuntosCss";
    css.textContent =
      ".clip-btn{width:38px;height:38px;border-radius:50%;border:none;background:none;" +
      "color:var(--ink-soft);display:flex;align-items:center;justify-content:center;" +
      "cursor:pointer;flex-shrink:0;}" +
      ".clip-btn:hover{color:var(--accent);background:var(--bg);}" +
      ".adjunto-chip{display:none;align-items:center;gap:10px;padding:8px 14px;" +
      "border-top:1px solid var(--line);background:var(--surface);font-size:13px;}" +
      ".adjunto-chip.visible{display:flex;}" +
      ".adjunto-chip img{width:38px;height:38px;object-fit:cover;border-radius:8px;}" +
      ".adjunto-chip .info{flex:1;min-width:0;}" +
      ".adjunto-chip .info b{display:block;white-space:nowrap;overflow:hidden;" +
      "text-overflow:ellipsis;font-weight:600;}" +
      ".adjunto-chip .info small{color:var(--ink-soft);}" +
      ".adjunto-chip button{border:none;background:var(--bg);color:var(--ink);" +
      "width:26px;height:26px;border-radius:50%;cursor:pointer;font-size:15px;line-height:1;}" +
      ".adjunto{display:block;margin:2px 0 6px;color:inherit;text-decoration:none;}" +
      ".adjunto-img img{display:block;max-width:100%;max-height:260px;border-radius:8px;}" +
      ".adjunto-doc{display:flex;align-items:center;gap:10px;padding:8px 10px;" +
      "border-radius:10px;background:rgba(0,0,0,.06);min-width:190px;}" +
      ".bubble.out .adjunto-doc{background:rgba(255,255,255,.18);}" +
      ".adjunto-ext{flex-shrink:0;min-width:38px;height:38px;border-radius:8px;" +
      "background:var(--accent);color:#fff;font-size:10.5px;font-weight:700;" +
      "display:flex;align-items:center;justify-content:center;padding:0 4px;}" +
      ".bubble.out .adjunto-ext{background:#fff;color:var(--accent);}" +
      ".adjunto-info{min-width:0;display:flex;flex-direction:column;}" +
      ".adjunto-info strong{font-size:13px;word-break:break-word;}" +
      ".adjunto-info small{font-size:11px;opacity:.7;}";
    document.head.appendChild(css);
  }

  function crearAdjunto(a, alCargar) {
    var enlace = el("a");
    enlace.href = a.url;
    enlace.target = "_blank";
    enlace.rel = "noopener";

    if (a.esImagen) {
      enlace.className = "adjunto adjunto-img";
      var img = el("img");
      img.alt = a.nombre;
      img.loading = "lazy";
      img.addEventListener("load", alCargar);
      img.src = a.url;
      enlace.appendChild(img);
    } else {
      enlace.className = "adjunto adjunto-doc";
      enlace.setAttribute("download", a.nombre);
      enlace.appendChild(el("span", "adjunto-ext", (a.ext || "").toUpperCase().slice(0, 4)));
      var info = el("span", "adjunto-info");
      info.appendChild(el("strong", null, a.nombre));
      info.appendChild(el("small", null, tamanoLegible(a.tam || 0)));
      enlace.appendChild(info);
    }
    return enlace;
  }

  function limpiarAdjunto() {
    estado.archivo = null;
    if (adj.input) adj.input.value = "";
    if (adj.urlVista) {
      URL.revokeObjectURL(adj.urlVista);
      adj.urlVista = null;
    }
    if (adj.chip) {
      adj.chip.classList.remove("visible");
      adj.chip.innerHTML = "";
    }
  }

  function elegirArchivo(archivo) {
    if (!archivo) return;

    var ext = extensionDe(archivo.name);

    if (EXT_PERMITIDAS.indexOf(ext) === -1) {
      alert("Tipo de archivo no permitido. Puedes enviar fotos (png, jpg, gif, webp) " +
            "y documentos (pdf, Word, Excel, PowerPoint, txt, csv).");
      limpiarAdjunto();
      return;
    }
    if (archivo.size === 0) {
      alert("El archivo está vacío.");
      limpiarAdjunto();
      return;
    }
    if (archivo.size > MAX_BYTES) {
      alert("El archivo supera el máximo de 10 MB.");
      limpiarAdjunto();
      return;
    }

    limpiarAdjunto();
    estado.archivo = archivo;
    mostrarChip(archivo, ext);
  }

  function mostrarChip(archivo, ext) {
    if (!adj.chip) return;

    adj.chip.innerHTML = "";

    if (EXT_IMAGEN.indexOf(ext) !== -1) {
      adj.urlVista = URL.createObjectURL(archivo);
      var miniatura = el("img");
      miniatura.alt = "";
      miniatura.src = adj.urlVista;
      adj.chip.appendChild(miniatura);
    } else {
      adj.chip.appendChild(el("span", "adjunto-ext", ext.toUpperCase().slice(0, 4)));
    }

    var info = el("div", "info");
    info.appendChild(el("b", null, archivo.name));
    info.appendChild(el("small", null, tamanoLegible(archivo.size)));
    adj.chip.appendChild(info);

    var quitar = el("button", null, "\u00d7");
    quitar.type = "button";
    quitar.setAttribute("aria-label", "Quitar archivo");
    quitar.addEventListener("click", limpiarAdjunto);
    adj.chip.appendChild(quitar);

    adj.chip.classList.add("visible");
  }

  function montarAdjuntos() {
    var composer = $("composer");
    if (!composer) return;            // canales de solo lectura no tienen caja

    inyectarEstilosAdjuntos();

    adj.input = el("input");
    adj.input.type = "file";
    adj.input.style.display = "none";
    adj.input.accept = EXT_PERMITIDAS.map(function (e) { return "." + e; }).join(",");
    adj.input.addEventListener("change", function () {
      elegirArchivo(adj.input.files && adj.input.files[0]);
    });
    composer.appendChild(adj.input);

    var clip = el("button", "clip-btn");
    clip.type = "button";
    clip.setAttribute("aria-label", "Adjuntar foto o documento");
    clip.title = "Adjuntar foto o documento";
    clip.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" ' +
      'stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
      '<path d="M21.4 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66' +
      'l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg>';
    clip.addEventListener("click", function () { adj.input.click(); });
    composer.insertBefore(clip, composer.firstChild);

    adj.chip = el("div", "adjunto-chip");
    composer.parentNode.insertBefore(adj.chip, composer);

    // pegar una captura o imagen del portapapeles en la caja de texto
    var caja = $("msgInput");
    if (caja) {
      caja.addEventListener("paste", function (e) {
        var archivos = e.clipboardData && e.clipboardData.files;
        if (archivos && archivos.length) {
          e.preventDefault();
          elegirArchivo(archivos[0]);
        }
      });
    }
  }

  // ---------- notificaciones ----------
  // El servidor solo devuelve mensajes de canales que ESTE usuario puede
  // ver, así que cada notificación llega únicamente a quien corresponde.

  function guardarUltimo() {
    try { sessionStorage.setItem(CLAVE_ULTIMO, String(notif.ultimo)); } catch (e) {}
  }

  function ponerBadge(fila, cantidad) {
    var viejo = fila.querySelector(".badge");
    if (viejo) fila.removeChild(viejo);
    if (cantidad > 0) {
      fila.appendChild(el("div", "badge", cantidad > 99 ? "99+" : String(cantidad)));
    }
  }

  function actualizarBadges() {
    var filas = document.querySelectorAll(".salon-row");
    for (var i = 0; i < filas.length; i++) {
      ponerBadge(filas[i], notif.noLeidos[filas[i].getAttribute("data-canal")] || 0);
    }
  }

  function actualizarTitulo() {
    var total = 0;
    for (var k in notif.noLeidos) { total += notif.noLeidos[k]; }
    document.title = (total > 0 ? "(" + total + ") " : "") + notif.tituloBase;
  }

  function inyectarEstilosToast() {
    if ($("nexoToastCss")) return;
    var css = el("style");
    css.id = "nexoToastCss";
    css.textContent =
      "#nexoToasts{position:fixed;top:56px;right:14px;z-index:50;display:flex;" +
      "flex-direction:column;gap:8px;max-width:min(340px,calc(100vw - 28px));}" +
      ".nexo-toast{background:#1C211E;color:#fff;border-radius:12px;padding:10px 14px;" +
      "box-shadow:0 8px 24px rgba(0,0,0,.25);cursor:pointer;font-size:13.5px;" +
      "line-height:1.35;animation:nexoIn .25s ease;}" +
      ".nexo-toast strong{display:block;font-size:12px;opacity:.75;margin-bottom:2px;}" +
      ".nexo-toast span{display:block;overflow:hidden;text-overflow:ellipsis;" +
      "white-space:nowrap;}" +
      "@keyframes nexoIn{from{opacity:0;transform:translateY(-6px);}to{opacity:1;transform:none;}}";
    document.head.appendChild(css);
  }

  function mostrarToast(n) {
    inyectarEstilosToast();

    var cont = $("nexoToasts");
    if (!cont) {
      cont = el("div");
      cont.id = "nexoToasts";
      document.body.appendChild(cont);
    }

    var t = el("div", "nexo-toast");
    t.appendChild(el("strong", null, n.titulo));
    t.appendChild(el("span", null, n.de + ": " + n.texto));

    function quitar() { if (t.parentNode) t.parentNode.removeChild(t); }

    t.addEventListener("click", quitar);
    cont.appendChild(t);
    setTimeout(quitar, 6000);
  }

  // ---- sonido (se genera con Web Audio: no hace falta ningún archivo) ----

  var audioCtx = null;

  function desbloquearAudio() {
    try {
      var AC = window.AudioContext || window.webkitAudioContext;
      if (!AC) return;
      if (!audioCtx) audioCtx = new AC();
      if (audioCtx.state === "suspended") audioCtx.resume();
    } catch (e) {}
  }

  function sonarAviso() {
    try {
      if (!audioCtx) return;
      if (audioCtx.state === "suspended") audioCtx.resume();
      var t0 = audioCtx.currentTime;
      [[880, 0], [1175, 0.14]].forEach(function (nota) {
        var osc = audioCtx.createOscillator();
        var vol = audioCtx.createGain();
        var ini = t0 + nota[1];
        osc.type = "sine";
        osc.frequency.value = nota[0];
        vol.gain.setValueAtTime(0.0001, ini);
        vol.gain.exponentialRampToValueAtTime(0.28, ini + 0.02);
        vol.gain.exponentialRampToValueAtTime(0.0001, ini + 0.24);
        osc.connect(vol);
        vol.connect(audioCtx.destination);
        osc.start(ini);
        osc.stop(ini + 0.26);
      });
    } catch (e) {}
  }

  // ---- notificaciones PUSH: llegan con la página o el navegador cerrados ----
  // El navegador se suscribe una vez; el servidor manda cada aviso a través del
  // servicio de push del navegador y static/sw.js lo muestra.

  var push = { activo: false, registrando: false };

  function base64AUint8(b64) {
    var relleno = "=".repeat((4 - (b64.length % 4)) % 4);
    var base = (b64 + relleno).replace(/-/g, "+").replace(/_/g, "/");
    var crudo = atob(base);
    var salida = new Uint8Array(crudo.length);
    for (var i = 0; i < crudo.length; i++) salida[i] = crudo.charCodeAt(i);
    return salida;
  }

  function claveIgual(suscripcion, clave) {
    try {
      var actual = suscripcion.options && suscripcion.options.applicationServerKey;
      if (!actual) return true;
      var a = new Uint8Array(actual);
      if (a.length !== clave.length) return false;
      for (var i = 0; i < a.length; i++) if (a[i] !== clave[i]) return false;
      return true;
    } catch (e) { return true; }
  }

  function registrarPush() {
    if (push.registrando || push.activo) return;
    if (!("serviceWorker" in navigator) || !("PushManager" in window) ||
        !("Notification" in window) || Notification.permission !== "granted") return;

    push.registrando = true;
    var registro = null;
    var clave = null;

    navigator.serviceWorker.register("/sw.js")
      .then(function () { return navigator.serviceWorker.ready; })
      .then(function (reg) {
        registro = reg;
        return fetch("/api/push/clave", { credentials: "same-origin" });
      })
      .then(function (r) {
        if (manejarErrorHttp(r)) return null;
        return leerJson(r);
      })
      .then(function (datos) {
        if (!datos || !datos.ok || !datos.clave) throw new Error("push no disponible");
        clave = base64AUint8(datos.clave);
        return registro.pushManager.getSubscription();
      })
      .then(function (sub) {
        if (sub && claveIgual(sub, clave)) return sub;
        // si la clave del servidor cambió, se renueva la suscripción
        var quitar = sub ? sub.unsubscribe() : Promise.resolve();
        return quitar.then(function () {
          return registro.pushManager.subscribe({
            userVisibleOnly: true,
            applicationServerKey: clave
          });
        });
      })
      .then(function (sub) {
        return fetch("/api/push/suscribir", {
          method: "POST",
          credentials: "same-origin",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(sub.toJSON())
        });
      })
      .then(function (r) {
        if (manejarErrorHttp(r)) return null;
        return leerJson(r);
      })
      .then(function (datos) { push.activo = !!(datos && datos.ok); })
      .catch(function () { push.activo = false; })
      .then(function () { push.registrando = false; });
  }

  // ---- notificación del sistema creada por la página (si no hay push) ----

  function notificarSistema(n) {
    if (!("Notification" in window) || Notification.permission !== "granted") return;

    try {
      var nt = new Notification(n.titulo, {
        body: n.de + ": " + n.texto,
        tag: "nexo-canal-" + n.canal,
        renotify: true,
        silent: false
      });
      nt.onclick = function () { nt.close(); };     // al tocarla solo se cierra
    } catch (e) {}
  }

  function pedirPermisoNotificaciones() {
    if (!("Notification" in window) || Notification.permission !== "default") return;

    var respuesta = Notification.requestPermission(function () { registrarPush(); });
    if (respuesta && respuesta.then) respuesta.then(function () { registrarPush(); });
  }

  function procesarNotificacion(n) {
    var abierto = estado.canal && String(estado.canal.id) === String(n.canal);

    // si ya está viendo ese chat, el propio chat muestra el mensaje
    if (abierto && !document.hidden) return;

    notif.noLeidos[n.canal] = (notif.noLeidos[n.canal] || 0) + 1;
    actualizarBadges();
    actualizarTitulo();
    actualizarVistaPrevia({ id: n.canal }, { texto: n.texto, hora: n.hora });

    var permiso = "Notification" in window && Notification.permission === "granted";

    // con push, la notificación del sistema la muestra el service worker;
    // sin push, la crea la página. El aviso emergente sale si la página se ve.
    if (permiso && !push.activo) notificarSistema(n);
    if (!document.hidden && (!permiso || push.activo)) mostrarToast(n);

    sonarAviso();
  }

  function consultarNotificaciones() {
    var url = "/api/notificaciones";
    if (notif.ultimo !== null) url += "?despues=" + notif.ultimo;

    fetch(url, { credentials: "same-origin" })
      .then(function (r) {
        if (manejarErrorHttp(r)) return null;
        return leerJson(r);
      })
      .then(function (datos) {
        if (!datos || !datos.ok) return;
        notif.ultimo = datos.ultimo;
        guardarUltimo();
        (datos.notificaciones || []).forEach(procesarNotificacion);
      })
      .catch(function () { /* sin conexión: se reintenta en el próximo ciclo */ });
  }

  function iniciarNotificaciones() {
    try {
      var guardado = sessionStorage.getItem(CLAVE_ULTIMO);
      if (guardado !== null && guardado !== "") notif.ultimo = parseInt(guardado, 10);
    } catch (e) {}

    consultarNotificaciones();
    notif.temporizador = setInterval(consultarNotificaciones, NOTIF_MS);

    registrarPush();        // si ya diste permiso antes, se suscribe de nuevo en silencio

    // los navegadores exigen un gesto del usuario para pedir el permiso
    document.addEventListener("click", pedirPermisoUnaVez);
    document.addEventListener("keydown", pedirPermisoUnaVez);
  }

  function pedirPermisoUnaVez() {
    desbloquearAudio();
    document.removeEventListener("click", pedirPermisoUnaVez);
    document.removeEventListener("keydown", pedirPermisoUnaVez);
    pedirPermisoNotificaciones();
  }

  // ---------- arranque ----------

  // los botones del HTML llaman a estas funciones globales
  window.closeChat = cerrarChat;
  window.sendMessage = enviarMensaje;

  document.addEventListener("DOMContentLoaded", function () {
    pintarLista("");
    montarAdjuntos();
    iniciarNotificaciones();

    var buscador = $("searchInput");
    if (buscador) {
      buscador.addEventListener("input", function () {
        pintarLista(buscador.value);
      });
    }

    var input = $("msgInput");
    if (input) {
      input.addEventListener("keydown", function (e) {
        if (e.key === "Enter" && !e.shiftKey) {
          e.preventDefault();
          enviarMensaje();
        }
      });
    }
  });

  // dejar de consultar el servidor cuando la pestaña no se ve
  document.addEventListener("visibilitychange", function () {
    if (document.hidden) {
      detenerPolling();
    } else if (estado.canal && !estado.temporizador) {
      cargarMensajes(false);
      estado.temporizador = setInterval(function () {
        cargarMensajes(false);
      }, INTERVALO_MS);
    }
  });
})();

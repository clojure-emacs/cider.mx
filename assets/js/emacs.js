// The Emacs bits of the page: a mode line that knows where you are, an echo
// area, M-x, a few keys, and a second window that follows along.
(function () {
  "use strict";

  var root = document.documentElement;
  var $ = function (sel) { return document.querySelector(sel); };
  var $$ = function (sel) { return Array.prototype.slice.call(document.querySelectorAll(sel)); };
  var reduceMotion = matchMedia("(prefers-reduced-motion: reduce)").matches;

  // --- The echo area -------------------------------------------------------

  var echoArea = $("[data-echo-area]");
  var defaultEcho = echoArea.textContent;
  var echoTimer;

  function echo(message, sticky) {
    clearTimeout(echoTimer);
    echoArea.textContent = message;
    if (!sticky) {
      echoTimer = setTimeout(function () { echoArea.textContent = defaultEcho; }, 3000);
    }
  }

  // Like help-echo: hovering something says what it does.
  document.addEventListener("mouseover", function (e) {
    var el = e.target.closest("a, button");
    if (!el || el.closest(".completions")) return;
    var text = el.dataset.echo ||
        (el.tagName === "A" ? "mouse-1: visit " + el.href : null);
    if (text) echo(text, true);
  });
  document.addEventListener("mouseout", function (e) {
    if (e.target.closest("a, button")) echo(echoArea.textContent);
  });

  // --- Themes --------------------------------------------------------------

  function currentTheme() {
    return root.dataset.theme ||
      (matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
  }

  function loadTheme(theme) {
    root.dataset.theme = theme;
    try { localStorage.setItem("theme", theme); } catch (e) {}
    echo("Loading theme modus-" + (theme === "dark" ? "vivendi" : "operandi") + "...done");
  }

  function toggleTheme() {
    loadTheme(currentTheme() === "dark" ? "light" : "dark");
  }

  $(".load-theme").addEventListener("click", toggleTheme);

  // --- The kill ring -------------------------------------------------------

  function copyInstall() {
    var box = $(".minibuffer");
    navigator.clipboard.writeText(box.dataset.copy).then(function () {
      echo("Copied “" + box.dataset.copy + "” to the kill ring");
    });
  }

  $(".minibuffer button").addEventListener("click", copyInstall);

  // --- Headings, folding and the mode line ---------------------------------

  var headings = $$(".buffer-text h2, .buffer-text h3");
  var position = $("[data-position]");
  var crumbs = $("[data-crumbs]");
  var panes = $$("[data-pane]");
  var headerHeight = function () { return $(".header-line").offsetHeight; };
  // The reading line: whatever crosses it is "the current section", for the
  // breadcrumbs and the other window alike, so the two always agree.
  var readingLine = function () { return headerHeight() + window.innerHeight * 0.2; };

  function reveal(el) {
    var details = el.closest("details");
    if (details && !details.open) details.open = true;
  }

  function goTo(el) {
    reveal(el);
    var top = el.getBoundingClientRect().top + window.scrollY - headerHeight() - 12;
    window.scrollTo({ top: top, behavior: reduceMotion ? "auto" : "smooth" });
  }

  // The last heading above the reading line, like which-function-mode.
  function currentHeading() {
    var limit = readingLine();
    var current = null;
    headings.forEach(function (h) {
      if (h.offsetParent && h.getBoundingClientRect().top <= limit) current = h;
    });
    return current;
  }

  function headingText(h) {
    return h.firstChild.textContent.trim();
  }

  function updateModeLine() {
    var max = document.documentElement.scrollHeight - window.innerHeight;
    var y = window.scrollY;
    position.textContent = max <= 0 ? "All" : y <= 0 ? "Top" : y >= max - 2 ? "Bot" :
      Math.round(100 * y / max) + "%";

    var h = currentHeading();
    var trail = [];
    if (h) {
      if (h.tagName === "H3") {
        var parent = h.closest("details");
        if (parent) trail.push(headingText(parent.querySelector("h2")));
      }
      trail.push(headingText(h));
    }
    crumbs.textContent = trail.map(function (t) { return " › " + t; }).join("");
  }

  // --- The other window ----------------------------------------------------

  var paneById = {};
  $$(".media-window .pane").forEach(function (p) { paneById[p.dataset.paneId] = p; });
  var shownPane = null;

  function updatePane() {
    var mark = readingLine();
    var current = null;
    panes.forEach(function (section) {
      if (section.offsetParent && section.getBoundingClientRect().top <= mark) current = section;
    });
    var id = current ? current.dataset.pane : "hero";
    var pane = paneById[id];
    if (!pane || pane === shownPane) return;
    if (shownPane) shownPane.classList.remove("shown");
    pane.classList.add("shown");
    shownPane = pane;
  }

  var ticking = false;
  function onScroll() {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(function () {
      updateModeLine();
      updatePane();
      ticking = false;
    });
  }
  window.addEventListener("scroll", onScroll, { passive: true });
  window.addEventListener("resize", onScroll);
  $$("details.org").forEach(function (d) { d.addEventListener("toggle", onScroll); });

  function foldAll(open) {
    $$("details.org").forEach(function (d) { d.open = open; });
    echo(open ? "SHOW ALL" : "OVERVIEW");
  }

  // --- M-x -----------------------------------------------------------------

  var completions = $("[data-completions]");
  var input = $("[data-mx-input]");
  var list = $("[data-candidates]");
  var selected = 0;
  var matches = [];

  function commands() {
    var cmds = headings.map(function (h) {
      return { name: "goto " + headingText(h), note: h.tagName === "H2" ? "section" : "subsection",
               run: function () { goTo(h); } };
    });
    return cmds.concat([
      { name: "load-theme modus-operandi", note: "light", run: function () { loadTheme("light"); } },
      { name: "load-theme modus-vivendi", note: "dark", run: function () { loadTheme("dark"); } },
      { name: "cider-copy-install-command", note: "copy M-x package-install RET cider RET", run: copyInstall },
      { name: "org-fold-all", note: "fold every section", run: function () { foldAll(false); } },
      { name: "org-unfold-all", note: "unfold every section", run: function () { foldAll(true); } },
      { name: "browse-manual", note: "docs.cider.mx", run: function () { location.href = $(".header-line a[href*='docs']").href; } },
      { name: "browse-github", note: "clojure-emacs/cider", run: function () { location.href = $(".header-line a[href*='github']").href; } },
      { name: "describe-bindings", note: "the keys on this page", run: function () { toggleWhichKey(true); } }
    ]);
  }

  // Orderless: every space-separated word has to match, in any order.
  function filter(query) {
    var words = query.toLowerCase().split(/\s+/).filter(Boolean);
    return commands().filter(function (c) {
      var name = c.name.toLowerCase();
      return words.every(function (w) { return name.indexOf(w) !== -1; });
    });
  }

  function render() {
    matches = filter(input.value).slice(0, 10);
    selected = Math.min(selected, Math.max(matches.length - 1, 0));
    list.innerHTML = "";
    matches.forEach(function (c, i) {
      var li = document.createElement("li");
      li.setAttribute("role", "option");
      if (i === selected) li.setAttribute("aria-selected", "true");
      var name = document.createElement("span");
      name.textContent = c.name;
      var note = document.createElement("span");
      note.className = "note";
      note.textContent = c.note;
      li.appendChild(name);
      li.appendChild(note);
      li.addEventListener("mousedown", function (e) { e.preventDefault(); run(c); });
      list.appendChild(li);
    });
    if (!matches.length) {
      var none = document.createElement("li");
      none.className = "none";
      none.textContent = "[No match]";
      list.appendChild(none);
    }
  }

  function openMx() {
    toggleWhichKey(false);
    completions.hidden = false;
    input.value = "";
    selected = 0;
    render();
    input.focus();
  }

  function closeMx() {
    completions.hidden = true;
    input.blur();
  }

  function run(c) {
    closeMx();
    c.run();
  }

  input.addEventListener("input", function () { selected = 0; render(); });
  input.addEventListener("keydown", function (e) {
    var down = e.key === "ArrowDown" || (e.ctrlKey && e.key === "n");
    var up = e.key === "ArrowUp" || (e.ctrlKey && e.key === "p");
    if (down || up) {
      e.preventDefault();
      if (matches.length) selected = (selected + (down ? 1 : -1) + matches.length) % matches.length;
      render();
    } else if (e.key === "Enter") {
      e.preventDefault();
      if (matches[selected]) run(matches[selected]);
    } else if (e.key === "Escape" || (e.ctrlKey && e.key === "g")) {
      e.preventDefault();
      closeMx();
      echo("Quit");
    }
  });
  input.addEventListener("blur", function () { setTimeout(closeMx, 100); });

  // --- which-key -----------------------------------------------------------

  var whichKey = $("[data-which-key]");
  function toggleWhichKey(show) {
    whichKey.hidden = show === undefined ? !whichKey.hidden : !show;
  }

  // --- Keys ----------------------------------------------------------------

  function typing(e) {
    var t = e.target;
    return t.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(t.tagName);
  }

  function nextHeading(direction) {
    var visible = headings.filter(function (h) { return h.offsetParent; });
    var limit = headerHeight() + 30;
    var target = null;
    if (direction > 0) {
      target = visible.find(function (h) { return h.getBoundingClientRect().top > limit; });
    } else {
      visible.forEach(function (h) { if (h.getBoundingClientRect().top < limit - 10) target = h; });
    }
    if (target) goTo(target);
    else echo(direction > 0 ? "End of buffer" : "Beginning of buffer");
  }

  document.addEventListener("keydown", function (e) {
    // M-x works everywhere, even with the physical Option key on a Mac.
    if (e.altKey && e.code === "KeyX") {
      e.preventDefault();
      openMx();
      return;
    }
    if (typing(e) || e.ctrlKey || e.metaKey || e.altKey) return;
    switch (e.key) {
      case ":": e.preventDefault(); openMx(); break;
      case "n": nextHeading(1); break;
      case "p": nextHeading(-1); break;
      case "t": toggleTheme(); break;
      case "?": toggleWhichKey(); break;
      case "q":
      case "Escape": toggleWhichKey(false); break;
    }
  });

  onScroll();
})();

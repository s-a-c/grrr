/*
 * Shared Interactive UI Engine for the `grrr` Gleam/Glimr/Lustre Course
 * - Catppuccin Latte / Mocha / System theme toggle (persisted)
 * - Glow & Motion accessibility toggles
 * - Pure Web Audio API tactile sound synthesizer (lazy AudioContext)
 * - 3D pointer-tilt cards with dynamic specular sheen
 * - Interactive 3D Orbital Constellation Stage builder
 * - Scroll progress bar, reveal animations, and copy-code buttons
 */
(function () {
  const STORE_KEY = 'grrr-course-prefs-v1';
  const root = document.documentElement;
  const $ = (sel, ctx = document) => ctx.querySelector(sel);
  const $$ = (sel, ctx = document) => Array.from(ctx.querySelectorAll(sel));

  const store = {
    read() {
      try { return JSON.parse(localStorage.getItem(STORE_KEY) || '{}'); }
      catch (_) { return {}; }
    },
    write(patch) {
      try {
        const next = Object.assign(this.read(), patch);
        localStorage.setItem(STORE_KEY, JSON.stringify(next));
      } catch (_) {}
    }
  };

  /* 1. Synthesized Web Audio Sound Engine */
  const sfx = {
    on: true,
    ctx: null,
    ensure() {
      if (!this.on) return null;
      if (!this.ctx) {
        const AC = window.AudioContext || window.webkitAudioContext;
        if (!AC) return null;
        this.ctx = new AC();
      }
      if (this.ctx.state === 'suspended') this.ctx.resume().catch(() => {});
      return this.ctx;
    },
    tone(freq, dur = 0.08, type = 'sine', gain = 0.06, delay = 0) {
      const ctx = this.ensure();
      if (!ctx) return;
      const now = ctx.currentTime + delay;
      const osc = ctx.createOscillator();
      const amp = ctx.createGain();
      osc.type = type;
      osc.frequency.setValueAtTime(freq, now);
      amp.gain.setValueAtTime(0.0001, now);
      amp.gain.exponentialRampToValueAtTime(gain, now + 0.012);
      amp.gain.exponentialRampToValueAtTime(0.0001, now + dur);
      osc.connect(amp).connect(ctx.destination);
      osc.start(now);
      osc.stop(now + dur + 0.02);
    },
    click()  { this.tone(540, 0.055, 'triangle', 0.05); },
    tick()   { this.tone(720, 0.04, 'sine', 0.04); },
    gleam()  { this.tone(587.33, 0.11, 'triangle', 0.055); this.tone(880, 0.14, 'sine', 0.045, 0.05); },
    glimr()  { this.tone(440, 0.11, 'sine', 0.055); this.tone(659.25, 0.14, 'triangle', 0.045, 0.05); },
    lustre() { this.tone(523.25, 0.10, 'triangle', 0.055); this.tone(783.99, 0.14, 'sine', 0.045, 0.05); },
    beam()   { this.tone(392, 0.11, 'sine', 0.055); this.tone(587.33, 0.15, 'triangle', 0.045, 0.06); },
    pass()   { this.tone(523.25, 0.09, 'triangle', 0.06); this.tone(659.25, 0.12, 'triangle', 0.06, 0.07); },
    fail()   { this.tone(240, 0.12, 'sawtooth', 0.045); this.tone(185, 0.16, 'sawtooth', 0.045, 0.09); },
    win()    { [523.25, 659.25, 783.99, 1046.5].forEach((f, i) => this.tone(f, 0.14, 'triangle', 0.055, i * 0.07)); },
    sweep(up = true) {
      const ctx = this.ensure();
      if (!ctx) return;
      const now = ctx.currentTime;
      const osc = ctx.createOscillator();
      const amp = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(up ? 340 : 620, now);
      osc.frequency.exponentialRampToValueAtTime(up ? 660 : 320, now + 0.14);
      amp.gain.setValueAtTime(0.0001, now);
      amp.gain.exponentialRampToValueAtTime(0.05, now + 0.02);
      amp.gain.exponentialRampToValueAtTime(0.0001, now + 0.16);
      osc.connect(amp).connect(ctx.destination);
      osc.start(now);
      osc.stop(now + 0.18);
    }
  };
  window.GrrrSFX = sfx;

  /* 2. Theme / Glow / Motion / Audio Controller */
  const sysLightMql = window.matchMedia('(prefers-color-scheme: light)');
  const sysReduceMql = window.matchMedia('(prefers-reduced-motion: reduce)');

  const env = {
    scheme: 'system',
    glow: true,
    motion: true,
    resolveTheme(scheme) {
      if (scheme === 'light') return 'latte';
      if (scheme === 'dark') return 'mocha';
      return sysLightMql.matches ? 'latte' : 'mocha';
    },
    applyScheme(scheme, persist = true) {
      this.scheme = scheme;
      const theme = this.resolveTheme(scheme);
      root.dataset.theme = theme;
      const meta = $('meta[name="color-scheme"]');
      if (meta) meta.content = scheme === 'system' ? 'light dark' : scheme;
      $$('[data-scheme-btn]').forEach((b) => {
        b.setAttribute('aria-pressed', String(b.dataset.schemeBtn === scheme));
      });
      if (persist) store.write({ scheme });
    },
    setGlow(on, persist = true) {
      this.glow = on;
      root.dataset.glow = on ? 'on' : 'off';
      const btn = $('#glow-toggle');
      if (btn) btn.setAttribute('aria-pressed', String(on));
      if (persist) store.write({ glow: on ? 'on' : 'off' });
    },
    setMotion(on, persist = true) {
      this.motion = on;
      root.dataset.motion = on ? 'on' : 'off';
      const btn = $('#motion-toggle');
      if (btn) btn.setAttribute('aria-pressed', String(on));
      if (persist) store.write({ motion: on ? 'on' : 'off' });
      window.dispatchEvent(new CustomEvent('grrr:motion', { detail: { motion: on } }));
    },
    setSound(on, persist = true) {
      sfx.on = on;
      const btn = $('#sound-toggle');
      const lbl = $('#sound-label');
      if (btn) btn.setAttribute('aria-pressed', String(on));
      if (lbl) lbl.textContent = on ? 'Audio' : 'Muted';
      if (persist) store.write({ sound: on });
    },
    init() {
      const saved = store.read();
      this.applyScheme(saved.scheme || 'system', false);
      this.setGlow(saved.glow !== 'off', false);
      const motionDef = saved.motion ? saved.motion === 'on' : !sysReduceMql.matches;
      this.setMotion(motionDef, false);
      this.setSound(saved.sound !== false, false);

      $$('[data-scheme-btn]').forEach((btn) => {
        btn.addEventListener('click', () => {
          const next = btn.dataset.schemeBtn;
          this.applyScheme(next, true);
          sfx.sweep(this.resolveTheme(next) === 'latte');
        });
      });

      const glowBtn = $('#glow-toggle');
      if (glowBtn) glowBtn.addEventListener('click', () => { this.setGlow(!this.glow, true); sfx.click(); });

      const motionBtn = $('#motion-toggle');
      if (motionBtn) motionBtn.addEventListener('click', () => { this.setMotion(!this.motion, true); sfx.click(); });

      const soundBtn = $('#sound-toggle');
      if (soundBtn) soundBtn.addEventListener('click', () => {
        const next = !sfx.on;
        this.setSound(next, true);
        if (next) sfx.pass();
      });

      sysLightMql.addEventListener('change', () => {
        if (this.scheme === 'system') this.applyScheme('system', false);
      });

      document.addEventListener('keydown', (e) => {
        if (e.metaKey || e.ctrlKey || e.altKey) return;
        const tag = (e.target && e.target.tagName || '').toLowerCase();
        if (tag === 'input' || tag === 'textarea' || tag === 'select') return;
        if (e.key === 't') {
          const next = root.dataset.theme === 'mocha' ? 'light' : 'dark';
          this.applyScheme(next, true);
          sfx.sweep(next === 'light');
        } else if (e.key === 'g') {
          this.setGlow(!this.glow, true);
          sfx.click();
        } else if (e.key === 'm') {
          const next = !sfx.on;
          this.setSound(next, true);
          if (next) sfx.pass();
        }
      });
    }
  };
  window.GrrrEnv = env;

  /* 3. 3D Pointer-Tilt Cards */
  function initTiltCards() {
    $$('.tilt-card').forEach((card) => {
      card.addEventListener('pointermove', (e) => {
        if (!env.motion) return;
        const rect = card.getBoundingClientRect();
        const nx = (e.clientX - rect.left) / rect.width;
        const ny = (e.clientY - rect.top) / rect.height;
        const rotY = (nx - 0.5) * 14;
        const rotX = (0.5 - ny) * 14;
        card.style.transform = `perspective(920px) rotateX(${rotX.toFixed(2)}deg) rotateY(${rotY.toFixed(2)}deg) translateY(-3px)`;
        card.style.setProperty('--mx', `${(nx * 100).toFixed(1)}%`);
        card.style.setProperty('--my', `${(ny * 100).toFixed(1)}%`);
      });
      card.addEventListener('pointerleave', () => { card.style.transform = ''; });
      card.addEventListener('click', () => {
        const key = card.dataset.sound || 'click';
        if (sfx[key]) sfx[key](); else sfx.click();
      });
    });
  }

  /* 4. Reusable 3D Orbital Constellation Stage */
  window.GrrrOrbit = {
    mount(nodes) {
      const shell = $('#orbit-shell');
      const stage = $('#orbit-stage');
      const svg = $('#orbit-edges');
      if (!shell || !stage || !svg) return;

      const ns = 'http://www.w3.org/2000/svg';
      let yaw = 0.35, pitch = 0.26, paused = false, dragging = false, rafId = 0;
      const els = [], lines = [];

      nodes.forEach((n) => {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'orbit-node';
        btn.style.setProperty('--n-c', `var(${n.col})`);
        btn.style.setProperty('--n-glow', `var(${n.glow})`);
        btn.innerHTML = `${n.label}<span>${n.sub}</span>`;
        btn.addEventListener('click', () => {
          if (sfx[n.snd]) sfx[n.snd](); else sfx.click();
          const dest = n.target ? $(n.target) : null;
          if (dest) dest.scrollIntoView({ behavior: env.motion ? 'smooth' : 'auto' });
        });
        stage.appendChild(btn);
        const line = document.createElementNS(ns, 'line');
        line.setAttribute('class', 'orbit-edge');
        svg.appendChild(line);
        els.push(btn);
        lines.push(line);
      });

      const render = () => {
        const w = shell.clientWidth || 480;
        const h = shell.clientHeight || 380;
        const cx = w / 2, cy = h / 2;
        const rx = Math.min(w * 0.36, 195);
        const ry = Math.min(h * 0.33, 136);
        const rz = 115;

        const prism = $('#prism-core');
        if (prism) {
          prism.style.transform = `rotateX(${(-pitch * 55).toFixed(1)}deg) rotateY(${(yaw * 57.3).toFixed(1)}deg)`;
        }

        const cosY = Math.cos(yaw), sinY = Math.sin(yaw);
        const cosP = Math.cos(pitch), sinP = Math.sin(pitch);

        nodes.forEach((n, i) => {
          const ring = n.ring || 0;
          const count = n.ringCount || 4;
          const angle = (n.idx / count) * Math.PI * 2 + ring * 0.65;
          const tilt = ring === 0 ? 0.42 : -0.44;
          const lx = Math.cos(angle) * rx;
          const ly = Math.sin(angle) * Math.sin(tilt) * ry;
          const lz = Math.sin(angle) * Math.cos(tilt) * rz;

          const x1 = lx * cosY - lz * sinY;
          const z1 = lx * sinY + lz * cosY;
          const y2 = ly * cosP - z1 * sinP;
          const z2 = ly * sinP + z1 * cosP;

          const depth = (z2 + rz) / (2 * rz);
          const scale = 0.78 + depth * 0.30;
          els[i].style.transform = `translate(-50%, -50%) translate3d(${x1.toFixed(1)}px, ${y2.toFixed(1)}px, 0) scale(${scale.toFixed(3)})`;
          els[i].style.zIndex = String(Math.round(10 + depth * 40));
          els[i].style.opacity = (0.60 + depth * 0.40).toFixed(2);

          lines[i].setAttribute('x1', cx.toFixed(1));
          lines[i].setAttribute('y1', cy.toFixed(1));
          lines[i].setAttribute('x2', (cx + x1).toFixed(1));
          lines[i].setAttribute('y2', (cy + y2).toFixed(1));
        });
      };

      const stop = () => { if (rafId) { cancelAnimationFrame(rafId); rafId = 0; } };
      const start = () => {
        stop();
        if (paused || !env.motion) return;
        const tick = () => {
          if (!dragging && !paused && env.motion) { yaw += 0.0045; render(); }
          rafId = requestAnimationFrame(tick);
        };
        rafId = requestAnimationFrame(tick);
      };

      let lx = 0, ly = 0;
      shell.addEventListener('pointerdown', (e) => {
        if (e.target.closest('button')) return;
        dragging = true; lx = e.clientX; ly = e.clientY;
        shell.setPointerCapture(e.pointerId);
      });
      shell.addEventListener('pointermove', (e) => {
        if (!dragging) return;
        yaw += (e.clientX - lx) * 0.009;
        pitch = Math.max(-0.85, Math.min(0.85, pitch + (e.clientY - ly) * 0.008));
        lx = e.clientX; ly = e.clientY;
        render();
      });
      const endDrag = () => { dragging = false; };
      shell.addEventListener('pointerup', endDrag);
      shell.addEventListener('pointercancel', endDrag);

      shell.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowLeft')  { e.preventDefault(); yaw -= 0.14; render(); sfx.tick(); }
        if (e.key === 'ArrowRight') { e.preventDefault(); yaw += 0.14; render(); sfx.tick(); }
        if (e.key === 'ArrowUp')    { e.preventDefault(); pitch = Math.max(-0.85, pitch - 0.14); render(); sfx.tick(); }
        if (e.key === 'ArrowDown')  { e.preventDefault(); pitch = Math.min(0.85, pitch + 0.14); render(); sfx.tick(); }
      });

      const pauseBtn = $('#orbit-pause');
      if (pauseBtn) {
        pauseBtn.addEventListener('click', () => {
          paused = !paused;
          pauseBtn.setAttribute('aria-pressed', String(paused));
          pauseBtn.textContent = paused ? 'Resume' : 'Pause';
          sfx.click();
          if (paused) stop(); else start();
        });
      }
      const resetBtn = $('#orbit-reset');
      if (resetBtn) {
        resetBtn.addEventListener('click', () => {
          yaw = 0.35; pitch = 0.26; render(); sfx.sweep(true);
        });
      }

      window.addEventListener('grrr:motion', () => { if (env.motion) start(); else stop(); });
      window.addEventListener('resize', render);
      render();
      start();
    }
  };

  /* 5. Scroll Progress, Reveals & Copy Buttons */
  function initEnhancements() {
    const bar = $('#scroll-progress');
    if (bar) {
      const onScroll = () => {
        const max = Math.max(1, document.documentElement.scrollHeight - window.innerHeight);
        bar.style.transform = `scaleX(${Math.min(1, Math.max(0, window.scrollY / max))})`;
      };
      window.addEventListener('scroll', onScroll, { passive: true });
      onScroll();
    }

    if ('IntersectionObserver' in window) {
      const obs = new IntersectionObserver((entries) => {
        entries.forEach((e) => { if (e.isIntersecting) e.target.classList.add('is-visible'); });
      }, { threshold: 0.06 });
      $$('.reveal').forEach((el) => obs.observe(el));
    } else {
      $$('.reveal').forEach((el) => el.classList.add('is-visible'));
    }

    $$('pre > code').forEach((codeEl) => {
      const pre = codeEl.parentElement;
      if (pre.querySelector('.copy-btn')) return;
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'copy-btn';
      btn.textContent = 'Copy';
      btn.addEventListener('click', () => {
        navigator.clipboard?.writeText(codeEl.textContent || '').then(() => {
          btn.textContent = 'Copied!';
          btn.classList.add('is-copied');
          sfx.pass();
          setTimeout(() => { btn.textContent = 'Copy'; btn.classList.remove('is-copied'); }, 1500);
        });
      });
      pre.appendChild(btn);
    });

    $$('a[href^="http://"], a[href^="https://"]').forEach((a) => {
      if (!a.getAttribute('target')) a.setAttribute('target', '_blank');
      const rel = new Set((a.getAttribute('rel') || '').split(/\s+/).filter(Boolean));
      rel.add('noopener');
      rel.add('noreferrer');
      a.setAttribute('rel', Array.from(rel).join(' '));
      a.classList.add('ext-link');
    });
  }

  document.addEventListener('DOMContentLoaded', () => {
    env.init();
    initTiltCards();
    initEnhancements();
  });
})();

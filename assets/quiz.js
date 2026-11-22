/*
 * Reusable randomized retrieval-practice quiz engine for `grrr` lessons
 * - Supports a pool of 7..13 `.quiz-card` questions inside `.quiz-pool`
 * - Randomly selects `data-quiz-count` (3..7) questions on page load AND on Reset Quiz
 * - Shuffles answer options within each visible card to prevent position memorization
 * - Integrates with `window.GrrrSFX` and the topbar `#mastery-fill` / `#mastery-count`
 */
(function () {
  function shuffle(arr) {
    const a = arr.slice();
    for (let i = a.length - 1; i > 0; i -= 1) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  }

  function initQuizzes() {
    const allCards = Array.from(document.querySelectorAll('.quiz-card'));
    if (!allCards.length) return;

    const poolEl = document.querySelector('.quiz-pool');
    const requested = poolEl ? parseInt(poolEl.dataset.quizCount || '4', 10) : allCards.length;
    const drawCount = Math.max(3, Math.min(7, Math.min(requested, allCards.length)));

    const scoreEl = document.querySelector('[data-quiz-score]');
    const resetBtn = document.querySelector('[data-quiz-reset]');
    const masteryFill = document.getElementById('mastery-fill');
    const masteryCount = document.getElementById('mastery-count');

    let activeCards = [];
    const state = new Map();

    // Preserve original unnumbered prompt HTML once so renumbering stays clean across resets
    allCards.forEach((card) => {
      const prompt = card.querySelector('.quiz-prompt');
      if (prompt && !prompt.dataset.rawPrompt) {
        prompt.dataset.rawPrompt = prompt.innerHTML.replace(/^\s*\d+\.\s*/, '');
      }
    });

    function sfx() {
      return window.GrrrSFX || { pass() {}, fail() {}, win() {}, sweep() {} };
    }

    function renderScore() {
      const total = activeCards.length;
      let correct = 0;
      state.forEach((isRight) => { if (isRight) correct += 1; });

      if (scoreEl) {
        const poolNote = allCards.length > total ? ` · Pool: ${total} of ${allCards.length}` : '';
        scoreEl.textContent = `Answered ${state.size} / ${total} · Correct ${correct} / ${total}${poolNote}`;
      }
      if (masteryFill) {
        masteryFill.style.transform = `scaleX(${total ? (correct / total).toFixed(3) : 0})`;
      }
      if (masteryCount) {
        masteryCount.textContent = `${correct}/${total}`;
      }
      return correct;
    }

    function dealQuestions() {
      state.clear();
      const picked = new Set(shuffle(allCards).slice(0, drawCount));
      activeCards = shuffle(Array.from(picked));

      // Hide all cards first, reset their UI
      allCards.forEach((card) => {
        card.hidden = !picked.has(card);
        card.classList.remove('is-cleared');
        card.querySelectorAll('.quiz-option').forEach((opt) => {
          opt.disabled = false;
          opt.classList.remove('is-correct', 'is-wrong');
        });
        const feedback = card.querySelector('.quiz-feedback');
        if (feedback) {
          feedback.textContent = '';
          feedback.classList.remove('show', 'ok', 'err');
        }
      });

      // Reorder visible cards in DOM, renumber 1..N, and shuffle their options
      const parent = activeCards[0]?.parentElement;
      const summary = parent ? parent.querySelector('.quiz-summary') : null;
      activeCards.forEach((card, idx) => {
        const prompt = card.querySelector('.quiz-prompt');
        if (prompt && prompt.dataset.rawPrompt) {
          prompt.innerHTML = `${idx + 1}. ${prompt.dataset.rawPrompt}`;
        }
        const optWrap = card.querySelector('.quiz-options');
        if (optWrap) {
          shuffle(Array.from(optWrap.querySelectorAll('.quiz-option'))).forEach((opt) => {
            optWrap.appendChild(opt);
          });
        }
        if (parent && summary) {
          parent.insertBefore(card, summary);
        }
      });

      renderScore();
    }

    // Bind option click handlers once
    allCards.forEach((card) => {
      const answer = card.dataset.answer;
      const options = Array.from(card.querySelectorAll('.quiz-option'));
      const feedback = card.querySelector('.quiz-feedback');

      options.forEach((btn) => {
        btn.addEventListener('click', () => {
          const choice = btn.dataset.choice;
          const isCorrect = choice === answer;

          options.forEach((opt) => {
            opt.disabled = true;
            if (opt.dataset.choice === answer) opt.classList.add('is-correct');
          });
          if (!isCorrect) btn.classList.add('is-wrong');
          if (isCorrect) card.classList.add('is-cleared');

          state.set(card, isCorrect);
          if (feedback) {
            const msg = btn.dataset.explain || card.dataset.explain || '';
            feedback.textContent = (isCorrect ? 'Correct. ' : 'Not quite. ') + msg;
            feedback.classList.remove('ok', 'err');
            feedback.classList.add('show', isCorrect ? 'ok' : 'err');
          }

          const correct = renderScore();
          if (isCorrect) {
            if (correct === activeCards.length) sfx().win();
            else sfx().pass();
          } else {
            sfx().fail();
          }
        });
      });
    });

    if (resetBtn) {
      resetBtn.addEventListener('click', () => {
        dealQuestions();
        sfx().sweep(false);
      });
    }

    dealQuestions();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initQuizzes);
  } else {
    initQuizzes();
  }
})();

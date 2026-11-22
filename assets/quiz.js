/* Reusable immediate-feedback retrieval-practice quiz widget with SFX + mastery bar */
(function () {
  function initQuizzes() {
    const cards = Array.from(document.querySelectorAll('.quiz-card'));
    if (!cards.length) return;

    const scoreEl = document.querySelector('[data-quiz-score]');
    const resetBtn = document.querySelector('[data-quiz-reset]');
    const masteryFill = document.getElementById('mastery-fill');
    const masteryCount = document.getElementById('mastery-count');
    const state = new Map();

    function sfx() {
      return window.GrrrSFX || { pass() {}, fail() {}, win() {}, sweep() {} };
    }

    function renderScore() {
      let correct = 0;
      state.forEach((isRight) => { if (isRight) correct += 1; });
      if (scoreEl) {
        scoreEl.textContent = `Answered ${state.size} / ${cards.length} · Correct ${correct} / ${cards.length}`;
      }
      if (masteryFill) {
        masteryFill.style.transform = `scaleX(${(correct / cards.length).toFixed(3)})`;
      }
      if (masteryCount) {
        masteryCount.textContent = `${correct}/${cards.length}`;
      }
      return correct;
    }

    cards.forEach((card, idx) => {
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

          state.set(idx, isCorrect);
          if (feedback) {
            const msg = btn.dataset.explain || card.dataset.explain || '';
            feedback.textContent = (isCorrect ? 'Correct. ' : 'Not quite. ') + msg;
            feedback.classList.remove('ok', 'err');
            feedback.classList.add('show', isCorrect ? 'ok' : 'err');
          }

          const correct = renderScore();
          if (isCorrect) {
            if (correct === cards.length) sfx().win();
            else sfx().pass();
          } else {
            sfx().fail();
          }
        });
      });
    });

    if (resetBtn) {
      resetBtn.addEventListener('click', () => {
        state.clear();
        cards.forEach((card) => {
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
        renderScore();
        sfx().sweep(false);
      });
    }

    renderScore();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initQuizzes);
  } else {
    initQuizzes();
  }
})();

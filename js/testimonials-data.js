// js/testimonials-data.js
// Single source of truth for seeded testimonials shown on both Home and Testimonials pages.
// These match exactly what is inserted into the database via supabase_schema.sql.

const SEED_TESTIMONIALS = [
  {
    reviewer_name: 'Sarah K.',
    review_date: '2026-03-12',
    content: 'This app really helped me stay on track with my pregnancy. The weekly updates and symptom tracking made me feel more prepared and less anxious throughout my journey.',
    rating: 5
  },
  {
    reviewer_name: 'Michael L.',
    review_date: '2026-04-16',
    content: 'I love how easy it is to find reliable information. The articles and tips are simple to understand, and I always feel more confident after reading them.',
    rating: 5
  },
  {
    reviewer_name: 'Lauren M.',
    review_date: '2026-05-10',
    content: 'The personalised tracking feature is so helpful. It feels like the app understands what stage I\'m in and gives me the right guidance at the right time.',
    rating: 5
  }
];

function renderTestimonialCard(t) {
  const dateStr = new Date(t.review_date).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
  const avatarUrl = t.reviewer_image_url
    || `https://api.dicebear.com/7.x/personas/svg?seed=${encodeURIComponent(t.reviewer_name)}`;
  return `
    <div class="testimonial-card">
      <img src="${avatarUrl}" alt="${t.reviewer_name}" class="testimonial-avatar"
           onerror="this.src='https://api.dicebear.com/7.x/initials/svg?seed=${encodeURIComponent(t.reviewer_name)}'">
      <div class="testimonial-name">${t.reviewer_name}</div>
      <div class="testimonial-date">${dateStr}</div>
      <p class="testimonial-text">${t.content}</p>
      <div class="stars">${'★'.repeat(t.rating)}${'☆'.repeat(5 - t.rating)}</div>
    </div>`;
}

// Load from DB, fall back to seeds if DB unreachable or empty
async function loadTestimonialsInto(containerId, limit = null) {
  const container = document.getElementById(containerId);
  if (!container) return;
  try {
    let query = supabaseClient
      .from('testimonials')
      .select('*')
      .eq('is_published', true)
      .order('review_date', { ascending: false });
    if (limit) query = query.limit(limit);
    const { data } = await query;
    if (data && data.length > 0) {
      container.innerHTML = data.map(renderTestimonialCard).join('');
    } else {
      const items = limit ? SEED_TESTIMONIALS.slice(0, limit) : SEED_TESTIMONIALS;
      container.innerHTML = items.map(renderTestimonialCard).join('');
    }
  } catch {
    const items = limit ? SEED_TESTIMONIALS.slice(0, limit) : SEED_TESTIMONIALS;
    container.innerHTML = items.map(renderTestimonialCard).join('');
  }
}

// Load from DB (most recent first) showing pageSize at a time, with a button to reveal more.
async function loadPaginatedTestimonialsInto(containerId, buttonId, pageSize = 9) {
  const container = document.getElementById(containerId);
  const button = document.getElementById(buttonId);
  if (!container) return;

  let allItems = SEED_TESTIMONIALS;
  try {
    const { data } = await supabaseClient
      .from('testimonials')
      .select('*')
      .eq('is_published', true)
      .order('review_date', { ascending: false });
    if (data && data.length > 0) allItems = data;
  } catch { }

  let shown = 0;
  function renderNextPage() {
    const next = allItems.slice(shown, shown + pageSize);
    container.insertAdjacentHTML('beforeend', next.map(renderTestimonialCard).join(''));
    shown += next.length;
    if (button) button.style.display = shown < allItems.length ? 'inline-block' : 'none';
  }

  container.innerHTML = '';
  renderNextPage();
  if (button) button.onclick = renderNextPage;
}

// PackVerse service worker — keeps the app working offline, but always prefers a fresh
// build when there is a connection, so a new deploy shows up on the next open.
const VERSION = '20260902-1137';
const CACHE = 'packverse-' + VERSION;
const FILES = ['./', './index.html', './manifest.webmanifest', './icon-192.png', './icon-512.png', './apple-touch-icon.png'];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => Promise.all(FILES.map(u =>
      // bypass the HTTP cache so the precache never holds a stale copy
      fetch(new Request(u, { cache: 'reload' })).then(r => { if (r && r.ok) return c.put(u, r); }).catch(() => {})
    ))).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
      // pages still showing an older build reload once so they pick this one up
      .then(() => self.clients.matchAll({ type: 'window' }))
      .then(cs => Promise.all(cs.map(c => c.navigate(c.url).catch(() => {}))))
  );
});

self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  const url = new URL(e.request.url);
  if (url.origin !== location.origin) return; // Supabase and other hosts go straight to the network

  const isShell = e.request.mode === 'navigate' || /\/(index\.html)?$/.test(url.pathname);
  if (isShell) {
    // network first for the app itself; the cached copy is only the offline fallback
    e.respondWith(
      fetch(new Request(e.request, { cache: 'no-cache' })).then(res => {
        if (res && res.ok) {
          const a = res.clone(), b = res.clone();
          caches.open(CACHE).then(c => { c.put('./index.html', a); c.put('./', b); });
        }
        return res;
      }).catch(() => caches.match('./index.html').then(hit => hit || caches.match('./')))
    );
    return;
  }

  // everything else: cache first, refresh in the background
  e.respondWith(
    caches.match(e.request, { ignoreSearch: true }).then(hit => {
      const net = fetch(e.request).then(res => {
        if (res && res.ok) { const copy = res.clone(); caches.open(CACHE).then(c => c.put(e.request, copy)); }
        return res;
      }).catch(() => hit);
      return hit || net;
    })
  );
});

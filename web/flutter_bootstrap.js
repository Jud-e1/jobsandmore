{{flutter_js}}
{{flutter_build_config}}

// No service worker: it cached old builds and hid new deploys. Remove any
// worker and cache left by earlier versions of the site.
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations()
    .then((regs) => regs.forEach((r) => r.unregister()))
    .catch(() => {});
}
if (window.caches && caches.keys) {
  caches.keys().then((keys) => keys.forEach((k) => caches.delete(k))).catch(() => {});
}

_flutter.loader.load();

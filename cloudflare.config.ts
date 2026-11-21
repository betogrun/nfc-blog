// Cloudflare Worker that serves the built site (output/) as static assets, read by the cf CLI.
// The default html_handling (auto-trailing-slash) serves posts/slug.html at /posts/slug and
// tag/x/index.html at /tag/x/, which is what the legacy URLs need.
export default {
  worker: {
    name: "blog",
    compatibilityDate: "2026-11-21",
    assets: { notFoundHandling: "404-page" },
  },
};

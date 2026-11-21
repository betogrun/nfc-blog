// Cloudflare Worker that serves the built site (output/) as static assets, read by the cf CLI.
// The default html_handling (auto-trailing-slash) serves posts/slug.html at /posts/slug and
// tag/x/index.html at /tag/x/, which is what the legacy URLs need.
//
// The custom domain (blog.albertorocha.me) is attached to the Worker but deliberately not
// listed here: cf only touches domains that the config declares, and outside a terminal (CI)
// it would overwrite conflicting DNS records without asking. workersDev and previewUrls are
// explicit because declaring a domain turns both off by default.
export default {
  worker: {
    name: "blog",
    compatibilityDate: "2026-11-21",
    assets: { notFoundHandling: "404-page" },
    workersDev: true,
    previewUrls: true,
  },
};

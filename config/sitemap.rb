SitemapGenerator::Sitemap.default_host = "https://mvpscaler.com"
SitemapGenerator::Sitemap.create do
  add "/", changefreq: "weekly", priority: 0.9
end

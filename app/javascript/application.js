import "@hotwired/turbo-rails"

// Re-trigger the page entrance animation after Turbo navigation.
document.addEventListener("turbo:load", () => {
  const page = document.getElementById("page-transition")

  if (!page) return

  page.classList.remove("page-transition")

  // Force the browser to register the animation reset.
  void page.offsetWidth

  page.classList.add("page-transition")
})

// Remove animation state before Turbo caches a page.
document.addEventListener("turbo:before-cache", () => {
  const page = document.getElementById("page-transition")

  if (page) {
    page.classList.remove("page-transition")
  }
})

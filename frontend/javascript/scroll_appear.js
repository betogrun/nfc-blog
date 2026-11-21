// Fades elements in as they enter the viewport (styles in modules/_scrollappear.scss).
export function setupScrollAppear() {
  const observer = new IntersectionObserver((entries) => {
    entries.filter((entry) => entry.isIntersecting).forEach(({ target }) => {
      target.classList.add("appeared")
      observer.unobserve(target)
    })
  })

  document.querySelectorAll(".scrollappear").forEach((element) => {
    element.classList.add("appear")
    observer.observe(element)
  })
}

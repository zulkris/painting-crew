// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}

Hooks.DarkMode = {
  mounted() {
    const root = document.documentElement
    const saved = localStorage.getItem('theme')
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
    this.applyTheme(saved || (prefersDark ? 'dark' : 'light'))

    this.el.addEventListener('click', () => {
      const isDark = root.classList.contains('dark')
      const next = isDark ? 'light' : 'dark'
      localStorage.setItem('theme', next)
      this.applyTheme(next)
    })
  },
  applyTheme(theme) {
    const root = document.documentElement
    const iconSun = this.el.querySelector('.icon-sun')
    const iconMoon = this.el.querySelector('.icon-moon')
    if (theme === 'dark') {
      root.classList.add('dark')
      if (iconSun) iconSun.classList.remove('hidden')
      if (iconMoon) iconMoon.classList.add('hidden')
    } else {
      root.classList.remove('dark')
      if (iconSun) iconSun.classList.add('hidden')
      if (iconMoon) iconMoon.classList.remove('hidden')
    }
  }
}

Hooks.MobileMenu = {
  mounted() {
    const menu = document.getElementById('mobile-menu')
    const menuOpen = this.el.querySelector('.menu-open')
    const menuClose = this.el.querySelector('.menu-close')

    this.el.addEventListener('click', () => {
      const expanded = this.el.getAttribute('aria-expanded') === 'true'
      this.el.setAttribute('aria-expanded', String(!expanded))
      menu.classList.toggle('hidden')
      if (menuOpen) menuOpen.classList.toggle('hidden')
      if (menuClose) menuClose.classList.toggle('hidden')
    })

    if (menu) {
      menu.querySelectorAll('a').forEach(link => {
        link.addEventListener('click', () => {
          menu.classList.add('hidden')
          this.el.setAttribute('aria-expanded', 'false')
          if (menuOpen) menuOpen.classList.remove('hidden')
          if (menuClose) menuClose.classList.add('hidden')
        })
      })
    }
  }
}

Hooks.SpeedBar = {
  mounted() {
    const bars = this.el.querySelectorAll('.speed-bar')
    if (!bars.length) return

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.style.animationPlayState = 'running'
          observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.3 })

    bars.forEach(bar => observer.observe(bar))
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


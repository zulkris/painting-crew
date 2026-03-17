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

Hooks.SprayPainter = {
  mounted() {
    this.img = this.el.querySelector('img')
    this.currentFrame = -1
    this.ticking = false

    // Preload all frames
    const urls = JSON.parse(this.el.dataset.frameUrls)
    this.frames = urls.map(url => {
      const img = new Image()
      img.src = url
      return img
    })

    // Collect all paintable sections in DOM order
    this.sections = Array.from(document.querySelectorAll('[data-spray-section]'))
    this.overlays = this.sections.map(s => s.querySelector('.spray-overlay'))
    this.directions = this.sections.map(s => s.dataset.sprayDir || 'rtl')

    this.activeIndex = -1
    this.rectsValid = false

    this.onScroll = () => {
      if (!this.ticking) {
        requestAnimationFrame(() => {
          this.update()
          this.ticking = false
        })
        this.ticking = true
      }
    }

    this._onResize = () => { this.rectsValid = false }
    window.addEventListener('scroll', this.onScroll, { passive: true })
    window.addEventListener('resize', this._onResize, { passive: true })
    window.addEventListener('load', this._onResize, { once: true })

    // Cursor proximity: hide painter when mouse gets close
    this._onMouseMove = (e) => {
      const imgRect = this.img.getBoundingClientRect()
      const cx = imgRect.left + imgRect.width / 2
      const cy = imgRect.top + imgRect.height / 2
      const dx = e.clientX - cx
      const dy = e.clientY - cy
      const dist = Math.sqrt(dx * dx + dy * dy)
      const fadeStart = 250 // start fading
      const fadeEnd = 80   // fully hidden
      if (dist < fadeStart) {
        const opacity = Math.max(0, (dist - fadeEnd) / (fadeStart - fadeEnd))
        this.el.style.opacity = opacity
      } else {
        this.el.style.opacity = 1
      }
    }
    window.addEventListener('mousemove', this._onMouseMove, { passive: true })

    // Re-cache after fonts/images settle
    setTimeout(() => { this.rectsValid = false }, 1000)
    setTimeout(() => { this.rectsValid = false }, 3000)

    this.update()
  },

  cacheRects() {
    if (this.rectsValid) return
    const scrollTop = window.scrollY
    const pageH = document.documentElement.scrollHeight
    this.maxScroll = pageH - window.innerHeight

    this.sectionRects = this.sections.map((s, i) => {
      const rect = s.getBoundingClientRect()
      const top = rect.top + scrollTop
      // Set CSS vars for continuous gradient position
      if (this.overlays[i]) {
        this.overlays[i].style.setProperty('--section-top', `${top}px`)
        this.overlays[i].style.setProperty('--page-h', `${pageH}px`)
      }
      return {
        top: top,
        bottom: rect.bottom + scrollTop,
        height: rect.height
      }
    })
    this.rectsValid = true
  },

  update() {
    this.cacheRects()

    const scrollTop = window.scrollY
    const vh = window.innerHeight
    const triggerY = scrollTop + vh * 0.35

    let activeIdx = -1
    let activeProgress = 0

    for (let i = 0; i < this.sections.length; i++) {
      const rect = this.sectionRects[i]
      let progress

      if (i === this.sections.length - 1) {
        // Last section: ensure painting completes at page bottom
        const enterPoint = rect.top - vh * 0.65
        progress = Math.max(0, Math.min(1,
          (scrollTop - enterPoint) / Math.max(1, this.maxScroll - enterPoint)
        ))
      } else {
        progress = Math.max(0, Math.min(1, (triggerY - rect.top) / rect.height))
      }

      this.setOverlayProgress(i, progress)

      if (progress > 0 && progress < 1) {
        activeIdx = i
        activeProgress = progress
        this.sections[i].classList.add('spray-active')
        this.sections[i].classList.remove('spray-done')
        if (this.overlays[i]) this.overlays[i].classList.remove('painted')
      } else if (progress >= 1) {
        this.sections[i].classList.remove('spray-active')
        this.sections[i].classList.add('spray-done')
        if (this.overlays[i]) this.overlays[i].classList.add('painted')
      } else {
        this.sections[i].classList.remove('spray-active', 'spray-done')
        if (this.overlays[i]) this.overlays[i].classList.remove('painted')
      }
    }

    this.activeIndex = activeIdx

    // Position the spray painter
    if (activeIdx >= 0) {
      this.positionPainter(activeIdx, activeProgress)
    } else {
      let lastDone = -1
      for (let i = this.sections.length - 1; i >= 0; i--) {
        if (this.sections[i].classList.contains('spray-done')) { lastDone = i; break }
      }
      this.positionPainter(lastDone >= 0 ? lastDone : 0, lastDone >= 0 ? 1 : 0)
    }

    this.updateFrame(activeIdx >= 0 ? activeProgress : 0)
  },

  setOverlayProgress(index, progress) {
    const overlay = this.overlays[index]
    if (!overlay) return

    const dir = this.directions[index]
    const gradDir = dir === 'rtl' ? 'to left' : 'to right'
    const hide = 'linear-gradient(to right, transparent, transparent)'

    if (progress <= 0) {
      overlay.style.setProperty('--spray-solid-mask', hide)
      overlay.style.setProperty('--spray-edge-mask', hide)
      return
    }

    if (progress >= 1) {
      // Fully painted: solid fill only, no noise edge
      overlay.style.setProperty('--spray-solid-mask', 'linear-gradient(to right, black, black)')
      overlay.style.setProperty('--spray-edge-mask', hide)
      return
    }

    const pct = progress * 100
    const edgeWidth = 25 // % of section width for spray edge
    const solidEnd = Math.max(0, pct - edgeWidth)
    const blend = edgeWidth * 0.35 // overlap zone where solid fades into noisy edge

    // Solid mask: covers already-painted area, fades out gradually into the edge zone
    const solidMask = `linear-gradient(${gradDir}, ` +
      `black 0%, ` +
      `black ${solidEnd}%, ` +
      `rgba(0,0,0,0.7) ${solidEnd + blend * 0.3}%, ` +
      `rgba(0,0,0,0.35) ${solidEnd + blend * 0.6}%, ` +
      `rgba(0,0,0,0.1) ${solidEnd + blend * 0.85}%, ` +
      `transparent ${solidEnd + blend}%)`

    // Edge mask: starts before solidEnd fades out, creating a smooth overlap
    // The inner part blends with solid, the outer part is pure noisy spray
    const edgeMask = `linear-gradient(${gradDir}, ` +
      `transparent 0%, ` +
      `transparent ${Math.max(0, solidEnd - 1)}%, ` +
      `rgba(0,0,0,0.5) ${solidEnd + blend * 0.15}%, ` +
      `rgba(0,0,0,0.85) ${solidEnd + blend * 0.4}%, ` +
      `black ${solidEnd + blend}%, ` +
      `rgba(0,0,0,0.88) ${solidEnd + edgeWidth * 0.3}%, ` +
      `rgba(0,0,0,0.72) ${solidEnd + edgeWidth * 0.45}%, ` +
      `rgba(0,0,0,0.5) ${solidEnd + edgeWidth * 0.58}%, ` +
      `rgba(0,0,0,0.3) ${solidEnd + edgeWidth * 0.7}%, ` +
      `rgba(0,0,0,0.14) ${solidEnd + edgeWidth * 0.8}%, ` +
      `rgba(0,0,0,0.05) ${solidEnd + edgeWidth * 0.9}%, ` +
      `transparent ${Math.min(pct + 3, 100)}%)`

    overlay.style.setProperty('--spray-solid-mask', solidMask)
    overlay.style.setProperty('--spray-edge-mask', edgeMask)
  },

  positionPainter(sectionIndex, progress) {
    const rect = this.sectionRects[sectionIndex]
    const dir = this.directions[sectionIndex]
    const scrollTop = window.scrollY
    const vh = window.innerHeight

    // Vertical: center of visible portion of the section
    const visTop = Math.max(rect.top, scrollTop)
    const visBot = Math.min(rect.bottom, scrollTop + vh)
    const topPercent = ((visTop + visBot) / 2 - scrollTop) / vh * 100

    // Horizontal: interpolate based on direction
    let leftPercent, scaleX
    if (dir === 'rtl') {
      leftPercent = 85 - (progress * 70)
      scaleX = -1
    } else {
      leftPercent = 15 + (progress * 70)
      scaleX = 1
    }

    this.img.style.top = `${topPercent}%`
    this.img.style.left = `${leftPercent}%`
    this.img.style.transform = `translate(-50%, -50%) scaleX(${scaleX})`
  },

  updateFrame(progress) {
    const n = this.frames.length
    let idx
    if (progress <= 0 || progress >= 1) {
      idx = 0
    } else {
      const cycleProgress = (progress * 2.5) % 1
      idx = Math.min(Math.floor(cycleProgress * n), n - 1)
    }
    if (idx !== this.currentFrame) {
      this.currentFrame = idx
      this.img.src = this.frames[idx].src
    }
  },

  destroyed() {
    window.removeEventListener('scroll', this.onScroll)
    window.removeEventListener('resize', this._onResize)
    window.removeEventListener('mousemove', this._onMouseMove)
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


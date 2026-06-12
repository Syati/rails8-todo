import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "drawer"]

  connect() {
    this.desktopQuery = window.matchMedia("(min-width: 1024px)")
    this.handleBreakpointChange = this.handleBreakpointChange.bind(this)
    this.handleOutsidePointerDown = this.handleOutsidePointerDown.bind(this)
    this.connected = true

    this.desktopQuery.addEventListener("change", this.handleBreakpointChange)
    document.addEventListener("turbo:load", this.handleTurboLoad)
    document.addEventListener("pointerdown", this.handleOutsidePointerDown)

    this.refreshDrawerState()
  }

  disconnect() {
    this.connected = false
    this.desktopQuery.removeEventListener("change", this.handleBreakpointChange)
    document.removeEventListener("turbo:load", this.handleTurboLoad)
    document.removeEventListener("pointerdown", this.handleOutsidePointerDown)
  }

  sync() {
    window.requestAnimationFrame(() => this.syncContentOffset())
  }

  handleBreakpointChange() {
    this.setOpen(this.desktopQuery.matches)
  }

  handleTurboLoad = () => {
    this.refreshDrawerState()
  }

  handleOutsidePointerDown(event) {
    if (this.desktopQuery.matches || !this.isOpen()) return
    if (this.drawerTarget.contains(event.target)) return
    if (event.target.closest(`[data-drawer-toggle="${this.drawerTarget.id}"]`)) return

    this.setOpen(false)
  }

  refreshDrawerState() {
    this.initializeDrawer()
    this.handleBreakpointChange()

    window.requestAnimationFrame(() => {
      if (!this.connected) return

      this.initializeDrawer()
      this.handleBreakpointChange()
      this.drawerTarget.classList.remove("lg:translate-x-0")

      window.requestAnimationFrame(() => {
        this.drawerTarget.classList.add("transition-transform")
      })
    })
  }

  initializeDrawer() {
    if (window.FlowbiteInstances?.instanceExists("Drawer", this.drawerTarget.id)) {
      this.drawer = window.FlowbiteInstances.getInstance("Drawer", this.drawerTarget.id)
    }
  }

  setOpen(open) {
    if (this.drawer && open) {
      this.drawer?.show()
    } else if (this.drawer) {
      this.drawer.hide()
    } else if (open) {
      this.drawerTarget.classList.add("transform-none")
      this.drawerTarget.classList.remove("-translate-x-full")
    } else {
      this.drawerTarget.classList.remove("transform-none")
      this.drawerTarget.classList.add("-translate-x-full")
    }

    this.syncContentOffset(open)
  }

  syncContentOffset(open = this.drawerTarget.classList.contains("transform-none")) {
    this.contentTarget.classList.toggle("lg:pl-64", open)
  }

  isOpen() {
    return this.drawer?.isVisible() || this.drawerTarget.classList.contains("transform-none")
  }
}

import "$styles/index.scss"
import Zooming from "zooming"

import { setupThemeToggle } from "./theme"
import { setupScrollAppear } from "./scroll_appear"
import { setupSharePopups } from "./share"

setupThemeToggle()
setupScrollAppear()
setupSharePopups()

new Zooming({ customSize: "100%", scaleBase: 0.9, scaleExtra: 0 }).listen(".zooming")

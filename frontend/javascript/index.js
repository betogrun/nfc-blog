import "$styles/index.scss"
import Zooming from "zooming"

import { setupThemeToggle } from "./theme"
import { setupShareButtons } from "./share"
import { setupDisqus } from "./disqus"

setupThemeToggle()
setupShareButtons()
setupDisqus()

new Zooming({ customSize: "100%", scaleBase: 0.9, scaleExtra: 0 }).listen(".zooming")

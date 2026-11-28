import "$styles/index.scss"
import Zooming from "zooming"

import { setupThemeToggle } from "./theme"
import { setupShareButtons } from "./share"
import { setupCopyButtons } from "./copy_code"
import { setupDisqus } from "./disqus"
import { setupLanguageChoice } from "./language"

setupThemeToggle()
setupShareButtons()
setupCopyButtons()
setupDisqus()
setupLanguageChoice()

new Zooming({ customSize: "100%", scaleBase: 0.9, scaleExtra: 0 }).listen(".zooming")

let toPageString = pageNumber => pageNumber < 10000 ? `00${pageNumber}` : `0${pageNumber}`

module.exports = {
  title: "Ultimate Viewport", 
  author: "<a href='https://github.com/madman-bob/Homestuck-POV-Cam'>madman-bob</a>, ported by <a href='https://flaringk.github.io/Portfolio/'>FlaringK</a>, forked by Harry Hinderson",
  modVersion: "1.0",

  summary: "A port of madman-bob's Homestuck POV Cam Chrome extension",
  description: `A port of <a href='https://github.com/madman-bob/Homestuck-POV-Cam'>madman-bob</a>'s Homestuck POV Cam Chrome extension to the UHC. <a href='https://github.com/FlaringK/UHC-POV-Cam'>Github</a><br />
  <br />
  You can check out the beginnings of all the timelines here: <a href='/viewport'>Homestuck POV Timeline Map</a><br />
  <b>Warning! Some part of the map will contain spoilers if you have not read all of Homestuck.</b><br />
  <h3>Changing the below options will require a full reload [ctrl + r]</h3>`,

  // Add images to UHC
  trees: {
    './icons/': 'assets://images/'
  },

  // Turn on and off each page group
  settings: {
    boolean: [
    {
      model: "disableHover",
      label: "Always display character names",
      desc: "Always display each timeline's character name instead of viewing them by hovering with your mouse."
    },
    {
      model: "hideOriginalLink",
      label: "Hide original next page link",
      desc: "If one or more characters link to the next page, hide the original link to the next page."
    },
    {
      model: "Beta Kids",
      label: "Disable Beta Kids timelines",
    },
    {
      model: "Alpha Kids",
      label: "Disable Alpha Kids timelines",
    },
    {
      model: "Beta Trolls",
      label: "Disable Beta Trolls timelines",
    },
    {
      model: "Beta Kids' Guardians",
      label: "Disable Beta Kids' Guardians timelines",
    },
    {
      model: "Alpha Kids' Guardians",
      label: "Disable Alpha Kids' Guardians timelines",
    },
    {
      model: "Trolls' Ancestors",
      label: "Disable Trolls' Ancestors timelines",
    },
    {
      model: "Beta Kids' Exiles",
      label: "Disable Beta Kids' Exiles timelines",
    },
    {
      model: "Midnight Crew",
      label: "Disable Midnight Crew timelines",
    },
    {
      model: "Beta Kids' Agents",
      label: "Disable Beta Kids' Agents timelines",
    },
    {
      model: "Alpha Kids' Agents",
      label: "Disable Alpha Kids' Agents timelines",
    },
    {
      model: "Cherubs' Agents",
      label: "Disable Cherubs' Agents timelines",
    },
    {
      model: "Beta Kids' Sprites",
      label: "Disable Beta Kids' Sprites timelines",
    },
    {
      model: "Alpha Kids' Sprites",
      label: "Disable Alpha Kids' Sprites timelines",
    },
    {
      model: "Miscellaneous",
      label: "Disable Miscellaneous timelines",
    },
    {
      model: "Cherubs",
      label: "Disable Cherubs timelines",
    },
    {
      model: "The Felt",
      label: "Disable The Felt timelines",
    },
    {
      model: "Alpha Trolls",
      label: "Disable Alpha Trolls timelines",
    },
    {
      model: "Meta",
      label: "Disable Meta timelines",
    }],
  },

  edit: true,

  computed(api) {
    // Load Json
    const povData = api.readJson('./timelines.json')
    api.logger.info(povData)

    const povPage = api.readFile("./homepage.html")
    
    return {

      browserPages: {
        "VIEWPORT": {
          component: {
            title: () => "See into Eternity. Forever.", // Title on tab
            next: () => `/VIEWPORT`, // URL (Doesn't really matter)
            template: povPage
          },
          scss: ""
        }
      },
      
      styles: [
        {
          // Set collide & act 7 style manually
          body: api.store.get("collideAct7CreditsStyle", "a") // mod must be restarted twice to update; fallback is "a" since "" crashes TUHC
        },
        {
          source: "./povmap.css"
        },
        {
          source: "./homepage.css"
        }
      ],

      edit(archive) {

        let collideStyle = ""
        let act7Style = ""
        let creditsStyle = ""
        let hideOriginalLink = api.store.get("hideOriginalLink", false)
        const tereziRetconPages = [8948, 8132, 3938, 4476, 5270, 5610, 5622, 5736].map(page => toPageString(page))

        // For each page in homestuck
        for (let i = 1901; i < 10028; i++) {
          const pageString = toPageString(i)
          // if the page exists (prevents certain errors)
          if (archive.mspa.story[pageString] && povData.timelines[String(i)]) {

            let pageLinkDataList = povData.timelines[String(i)]
            let LinkStyle = ""

            let x2ComboLeftPage = ((pageString >= 7688) && (pageString <= 7825)) && (pageString % 2) == 0
            let x2ComboRightPage = ((pageString >= 7688) && (pageString <= 7825)) && (pageString % 2) == 1
            let x2Combo = x2ComboRightPage || x2ComboLeftPage

            let collide = pageString == 9987
            let act7 = pageString == 10027
            let credits = pageString == 10030

            let characterNextLinks = []
            let originalNextLinks = archive.mspa.story[pageString].next
            let originalNextLink
            let hideOriginalLinkWithCSS = false

            let tereziRetconPage = tereziRetconPages.includes(pageString)

            let linkIndex = 1   // Initialize to 1, then subtract 1 at start of for loop below

            if (tereziRetconPage)
              originalNextLink = originalNextLinks.length == 2 ? archive.mspa.story[pageString].next[1] : false
            else
              originalNextLink = originalNextLinks.length == 1 ? archive.mspa.story[pageString].next[0] : false

            // Add character links to page
            for (let j = 0; j < pageLinkDataList.length; j++) {
              let linkData = pageLinkDataList[j]

              // If character group is not hidden, add character's next links to next pages array
              if (!api.store.get(povData.groups[linkData[3]])) {
                // Add in missing pageNext
                if (!linkData[4][0]) linkData[4][0] = [parseInt(pageString)]
                for (let k = 0; k < linkData[4].length; k++) {
                  linkIndex += 1
                  characterNextLinks.push(toPageString(linkData[4][k][0]))
                  archive.mspa.story[pageString].next.push(toPageString(linkData[4][k][0]))
                }
              }
            }

            if (hideOriginalLink && characterNextLinks.includes(originalNextLink)) {
              if (x2Combo) {
                hideOriginalLinkWithCSS = true
              } else {
                let originalLinkIndex = archive.mspa.story[pageString].next.indexOf(originalNextLink)
                archive.mspa.story[pageString].next.splice(originalLinkIndex, 1)
              }
            }

            // Style added character links
            for (let j = 0; j < pageLinkDataList.length; j++) {
              let linkData = pageLinkDataList[j]

              for (let k = 0; k < linkData[4].length; k++) {

                // If character group is not hidden, style the previously added links
                if (!api.store.get(povData.groups[linkData[3]])) {

                  linkIndex -= 1

                  let person = povData.peoplenames[linkData[0]]
		  let colour = povData.colours[linkData[1]]
                  let caption = linkData[4][k][2]
                  let image = linkData[4][k][3]

                  if (!caption) {
                    caption = person
                  }

                  if (!image) {
                    image = povData.images[linkData[2]]
                  } else {
                    image = povData.images[image]
                  }

                if (!x2Combo && !collide && !act7 && !credits) {
                  LinkStyle += `
                      div[data-pageid*="${pageString}"] .nextArrow div:nth-last-child(${linkIndex}) {
                      position: relative;
                    }
                      div[data-pageid*="${pageString}"] .nextArrow div:nth-last-child(${linkIndex})${api.store.get("disableHover") ? "" : ":hover"}:before {
                      content: "${caption}";
                      position: absolute;
                          top: 10px;
                      right: calc(100% + 5px);
                      background: white;
                      border: solid black 1px;
                      font-size: 12px;
                      padding: 2px;
                      white-space: nowrap;
                      color: black;
                    }
                      div[data-pageid*="${pageString}"] .nextArrow div:nth-last-child(${linkIndex}) a {
                      color: ${colour} !important;
                      ${colour == "#FFFFFF" ? "text-shadow: 1px 1px 0px black;" : ""}
                      ${linkData[4][k][0] == pageString ? "display: none;" : ""}
                    }
                      div[data-pageid*="${pageString}"] .nextArrow div:nth-last-child(${linkIndex}) p::Before {
                      content: url("assets://images/${image}");
                      display: inline-block;
                      transform: translateY(5px);
                    }
                      div[data-pageid*="${pageString}"] .nextArrow div:nth-last-child(${linkIndex}) p::After {
                      ${linkData[4][k][0] == pageString ? `content: "End of ${person}'s Timeline.";` : ""}
                      color: ${colour};
                      ${colour == "#FFFFFF" ? "text-shadow: 1px 1px 0px black;" : ""}
                    }
                  `
                } else if (x2ComboLeftPage) {
                  LinkStyle += `
                    div .leftPage .nextArrow div:nth-child(1) {
                        ${hideOriginalLinkWithCSS ? "display: none;" : ""}
                    }

                    div .nextArrow div:nth-last-child(${linkIndex}) {
                        /* position: relative; */
                    }
                    div .leftPage .nextArrow div:nth-last-child(${linkIndex}) div${api.store.get("disableHover") ? "" : ":hover"}:before {
                      content: "${caption}";
                      position: absolute;
                      top: 10px;
                      right: calc(100% + 5px);
                      background: white;
                      border: solid black 1px;
                      font-size: 12px;
                      padding: 2px;
                      white-space: nowrap;
                      color: black;
                    }
                    div .leftPage .nextArrow div:nth-last-child(${linkIndex}) a {
                      color: ${colour} !important;
                      ${colour == "#FFFFFF" ? "text-shadow: 1px 1px 0px black;" : ""}
                      ${linkData[4][k][0] == pageString ? "display: none;" : ""}
                    }
                    div .leftPage .nextArrow div:nth-last-child(${linkIndex}) p::Before {
                      content: url("assets://images/${image}");
                      display: inline-block;
                      transform: translateY(5px);
                    }
                  `
                } else if (x2ComboRightPage) {
                  LinkStyle += `
                    div .rightPage .nextArrow div:nth-child(1) {
                        ${hideOriginalLinkWithCSS ? "display: none;" : ""}
                    }

                    div .rightPage .nextArrow div:nth-last-child(${linkIndex}) {
                      position: relative;
                    }
                      div .rightPage .nextArrow div:nth-last-child(${linkIndex})${api.store.get("disableHover") ? "" : ":hover"}:before {
                      content: "${caption}";
                      position: absolute;
                      top: 10px;
                      right: calc(100% + 5px);
                      background: white;
                      border: solid black 1px;
                      font-size: 12px;
                      padding: 2px;
                      white-space: nowrap;
                      color: black;
                    }
                      div .rightPage .nextArrow div:nth-last-child(${linkIndex}) a {
                      color: ${colour} !important;
                      ${colour == "#FFFFFF" ? "text-shadow: 1px 1px 0px black;" : ""}
                      ${linkData[4][k][0] == pageString ? "display: none;" : ""}
                    }
                      div .rightPage .nextArrow div:nth-last-child(${linkIndex}) p::Before {
                      content: url("assets://images/${image}");
                      display: inline-block;
                      transform: translateY(5px);
                    }
                      div .rightPage .nextArrow div:nth-last-child(${linkIndex}) p::After {
                      ${linkData[4][k][0] == pageString ? `content: "End of ${person}'s Timeline.";` : ""}
                      color: ${colour};
                      ${colour == "#FFFFFF" ? "text-shadow: 1px 1px 0px black;" : ""}
                    }
                  `
                } else if (collide) {
                  collideStyle += `
                    /* Collide */
                      div[data-pageid*="${pageString}"] .nextArrow div:nth-last-child(${linkIndex}) {
                      position: relative;
                    }
                      div[data-pageid*="009987"] .nextArrow div:nth-last-child(${linkIndex})${api.store.get("disableHover") ? "" : ":hover"}:before {
                      content: "${caption}";
                      position: absolute;
                      top: 10px;
                      right: calc(100% + 5px);
                      background: white;
                      border: solid black 1px;
                      font-size: 12px;
                      padding: 2px;
                      white-space: nowrap;
                      color: black;
                    }
                      div[data-pageid*="009987"] .nextArrow div:nth-last-child(${linkIndex}) a {
                      color: ${colour} !important;
                      ${colour == "#FFFFFF" ? "text-shadow: 1px 1px 0px black;" : ""}
                      ${linkData[4][k][0] == "009987" ? "display: none;" : ""}
                    }
                      div[data-pageid*="009987"] .nextArrow div:nth-last-child(${linkIndex}) p::Before {
                      content: url("assets://images/${image}");
                      display: inline-block;
                      transform: translateY(5px);
                    }
                      div[data-pageid*="009987"] .nextArrow div:nth-last-child(${linkIndex}) p::After {
                      ${linkData[4][k][0] == "009987" ? `content: "End of ${person}'s Timeline.";` : ""}
                      color: ${colour};
                      ${colour == "#FFFFFF" ? "text-shadow: 1px 1px 0px black;" : ""}
                    }
                  `
                } else if (act7) {
                  act7Style += `
                    /* Act 7 */
                    div[data-pageid*="010027"] .nextArrow div:first-child {
                      margin-bottom: 20px;
                    }
                    div[data-pageid*="010027"] .nextArrow div + div {
                      font-size: x-large !important;
                    }

                      div[data-pageid*="${pageString}"] .nextArrow div:nth-last-child(${linkIndex}) {
                      position: relative;
                    }
                      div[data-pageid*="010027"] .nextArrow div:nth-last-child(${linkIndex})${api.store.get("disableHover") ? "" : ":hover"}:before {
                      content: "${caption}";
                      position: absolute;
                      top: 10px;
                      right: calc(100% + 5px);
                      background: white;
                      border: solid black 1px;
                      font-size: 12px;
                      padding: 2px;
                      white-space: nowrap;
                      /* color: black; */
                    }
                      div[data-pageid*="010027"] .nextArrow div:nth-last-child(${linkIndex}) a {
                      color: ${colour} !important;
                      ${colour == "#FFFFFF" ? "text-shadow: 1px 1px 0px black;" : ""}
                      ${linkData[4][k][0] == "010027" ? "display: none;" : ""}
                    }
                      div[data-pageid*="010027"] .nextArrow div:nth-last-child(${linkIndex}) p::Before {
                      content: url("assets://images/${image}");
                      display: inline-block;
                      transform: translateY(5px);
                    }
                      div[data-pageid*="010027"] .nextArrow div:nth-last-child(${linkIndex}) p::After {
                      ${linkData[4][k][0] == "010027" ? `content: "End of ${person}'s Timeline.";` : ""}
                      color: ${colour};
                      ${colour == "#FFFFFF" ? "text-shadow: 1px 1px 0px black;" : ""}
                    }
                      `
                    } else if (credits) {
                  creditsStyle += `
                    /* Act 7 */
                    div[data-pageid*="010030"] .nextArrow div:first-child {
                      margin-bottom: 20px;
                    }
                    div[data-pageid*="010030"] .nextArrow div + div {
                      font-size: x-large !important;
                    }

                      div[data-pageid*="${pageString}"] .nextArrow div:nth-last-child(${linkIndex}) {
                      position: relative;
                    }
                      div[data-pageid*="010030"] .nextArrow div:nth-last-child(${linkIndex})${api.store.get("disableHover") ? "" : ":hover"}:before {
                      content: "${caption}";
                      position: absolute;
                      top: 10px;
                      right: calc(100% + 5px);
                      background: white;
                      border: solid black 1px;
                      font-size: 12px;
                      padding: 2px;
                      white-space: nowrap;
                      /* color: black; */
                    }
                      div[data-pageid*="010030"] .nextArrow div:nth-last-child(${linkIndex}) a {
                      color: ${colour} !important;
                      ${colour == "#FFFFFF" ? "text-shadow: 1px 1px 0px black;" : ""}
                      ${linkData[4][k][0] == "010030" ? "display: none;" : ""}
                    }
                      div[data-pageid*="010030"] .nextArrow div:nth-last-child(${linkIndex}) p::Before {
                      content: url("assets://images/${image}");
                      display: inline-block;
                      transform: translateY(5px);
                    }
                      div[data-pageid*="010030"] .nextArrow div:nth-last-child(${linkIndex}) p::After {
                      ${linkData[4][k][0] == "010030" ? `content: "End of ${person}'s Timeline.";` : ""}
                      color: ${colour};
                      ${colour == "#FFFFFF" ? "text-shadow: 1px 1px 0px black;" : ""}
                    }
                      `
                }
              }
            }
            }

            archive.mspa.story[pageString].content += `\n<style>${LinkStyle}</style>`

          }
        }

        // Store collide, credits, and act 7 style to be used on next start
        api.store.set("collideAct7Style", collideStyle + act7Style + creditsStyle)

        archive.tweaks.modHomeRowItems.push({
          href: "/viewport",
          thumbsrc: "assets://images/Icon.png",
          title: 'The Ultimate Viewport',
          description: `<p>SPOILERS AHEAD!<br /> A list of the beginnings of each Character's timeline</p>`
        });

      },

    }
  },
}
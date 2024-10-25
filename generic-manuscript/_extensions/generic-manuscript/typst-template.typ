#let article(
  // Article's Title
  title: "Article Title",
  header-title: none,

  // A dictionary of authors.
  // Dictionary keys are authors' names.
  // Dictionary values are meta data of every author, including
  // label(s) of affiliation(s), email, contact address,
  // or a self-defined name (to avoid name conflicts).
  // Once the email or address exists, the author(s) will be labelled
  // as the corresponding author(s), and their address will show in footnotes.
  //
  // Example:
  // (
  //   "Author Name": (
  //     "affiliation": "affil-1",
  //     "email": "author.name@example.com", // Optional
  //     "address": "Mail address",  // Optional
  //     "name": "Alias Name" // Optional
  //   )
  // )
  authors: (),

  // A dictionary of affiliation.
  // Dictionary keys are affiliations' labels.
  // These labels show be constent with those used in authors' meta data.
  // Dictionary values are addresses of every affiliation.
  //
  // Example:
  // (
  //   "affil-1": "Institution Name, University Name, Road, Post Code, Country"
  // )
  affiliations: (),

  // The paper's abstract.
  abstract: [],

  // The paper's keywords.
  keywords: (),

  // The path to a bibliography file if you want to cite some external
  // works.
  bib: none,
  bib-title: "References",

  // Word count
  word-count: false,

  // Line numbers
  line-numbers: false,

  // Paper's content
  body
) = {
  // Set document properties
  set bibliography(title: bib-title)

  // Line numbers have not yet been implemented in a release version, but are coming soon
  // https://github.com/typst/typst/issues/352
  // https://github.com/typst/typst/pull/4516
  //if line-numbers {
  //  set par.line(numbering: "1")
  //  show figure: set par.line(numbering: none)
  //}

  set document(title: title, author: authors.keys())
  set page(numbering: "1", number-align: center)
  set text(font: ("Linux Libertine", "STIX Two Text", "serif"), lang: "en")
  show footnote.entry: it => [
    #set par(hanging-indent: 0.7em)
    #set align(left)
    #numbering(it.note.numbering, ..counter(footnote).at(it.note.location())) #it.note.body
  ]
  show figure.caption: emph
  set table(
    fill: (x, y) => {
      if y == 0 {gray}
    }
  )
  show table.cell: it => {
    if it.y == 0 {
      strong(it)
    } else {
      it
    }
  }

  // Title block
  align(center)[
    #block(text(size: 14pt, weight: "bold", title))

    #v(1em)

    // Authors and affiliations

    // Restore affiliations' keys for looking up later
    // to show superscript labels of affiliations for each author.
    #let inst_keys = affiliations.keys()

    // Authors' block
    #block([
      // Process the text for each author one by one
      #for (ai, au) in authors.keys().enumerate() {
        let au_meta = authors.at(au)
        // Don't put comma before the first author
        if ai != 0 {
          text([, ])
        }
        // Write auther's name
        let au_name = if au_meta.keys().contains("name") {au_meta.name} else {au}
        text([#au_name])

        // Get labels of author's affiliation
        let au_inst_id = au_meta.affiliation
        let au_inst_primary = ""
        // Test whether the author belongs to multiple affiliations
        if type(au_inst_id) == "array" {
          // If the author belongs to multiple affiliations,
          // record the first affiliation as the primary affiliation,
          au_inst_primary = affiliations.at(au_inst_id.first())
          // and convert each affiliation's label to index
          let au_inst_index = au_inst_id.map(id => inst_keys.position(key => key == id) + 1)
          // Output affiliation
          super([#(au_inst_index.map(id => [#id]).join([,]))])
        } else if (type(au_inst_id) == "string") {
          // If the author belongs to only one affiliation,
          // set this as the primary affiliation
          au_inst_primary = affiliations.at(au_inst_id)
          // convert the affiliation's label to index
          let au_inst_index = inst_keys.position(key => key == au_inst_id) + 1
          // Output affiliation
          super([#au_inst_index])
        }

        // Corresponding author
        if au_meta.keys().contains("corresponding") and (au_meta.corresponding == "true" or au_meta.corresponding == true) {
          [#super[,]#footnote(numbering: "*")[
            Corresponding author. #au_name. Address:
            #if not au_meta.keys().contains("address") or au_meta.address == "" {
              [#au_inst_primary.]
            }
            #if au_meta.keys().contains("email") {
              [Email: #link("mailto:" + au_meta.email.replace("\\", "")).]
            }
          ]]
        }

        if au_meta.keys().contains("equal-contributor") and (au_meta.equal-contributor == "true" or au_meta.equal-contributor == true){
          if ai == 0 {
            [#super[,]#footnote(numbering: "*")[Equal contributors.]<ec_footnote>]
          } else {
            [#super[,]#footnote(numbering: "*", <ec_footnote>)]
          }
        }
      }
    ])

    #v(1em)

    // Affiliation block
    #align(left)[#block([
      #set par(leading: 0.4em)
      #for (ik, key) in inst_keys.enumerate() {
        text(size: 0.8em, [#super([#(ik+1)]) #(affiliations.at(key))])
        linebreak()
      }
    ])]
  ]

  if header-title == "true" {
    header-title = title
  }

  set page(
    header: [
      #set text(8pt)
      #align(right)[#header-title]
    ],
  )
  if word-count {
    import "@preview/wordometer:0.1.2": word-count, total-words
    show: word-count.with(exclude: (heading, table, figure.caption))
  }

  // Abstract and keyword block
  if abstract != [] {
    pagebreak()

    block([
        #if word-count {
        import "@preview/wordometer:0.1.2": word-count, word-count-of, total-words
        text(weight: "bold", [Word count: ])
        text([#word-count-of(exclude: (heading))[#abstract].words])
      }
      #heading([Abstract])
      #abstract

      #if keywords.len() > 0 {
        linebreak()
        text(weight: "bold", [Key words: ])
        text([#keywords.join([; ]).])
      }
    ])

    v(1em)
  }

  // Display contents

  pagebreak()

  show heading.where(level: 1): it => block(above: 1.5em, below: 1.5em)[
    #set pad(bottom: 2em, top: 1em)
    #it.body
  ]

  set par(first-line-indent: 0em)

  if word-count {
      import "@preview/wordometer:0.1.2": word-count, word-count-of, total-words
      text(weight: "bold", [Word count: ])
      text([#word-count-of(exclude: (heading, table, figure.caption))[#body].words])
  }

  body

}


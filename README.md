# UHC-POV-Cam

A port of [madman-bob](https://github.com/madman-bob/Homestuck-POV-Cam)'s Homestuck POV Cam Chrome extension to the UHC.

Download this mod as a ZIP file, extract it, and place it into your mods folder within the UHC asset pack. [Here's a guide for installing mods](https://github.com/Bambosh/unofficial-homestuck-collection/blob/main/MODDING.md#installing-mods)

## Options

### Enabled timelines

This allows you to enable and disable groups of timelines at once, which
is useful if you think the pages get a little cluttered. For example, if
you only want to follow the Beta Kids, then you can uncheck all the
timelines apart from them.

### Hide original link

This setting disables the original link on the page if a character's timeline already goes to the next page.

## Timeline language

In the `Readable Timelines`{.verbatim} folder are a number of files,
each containing the timeline data for a single person.

The files use the following format:

-   Page numbers or ranges of numbers to describe what pages a person\'s
    on. (For A6A5A1x2 COMBO, use `-2`{.verbatim} on the end to go
    through the pages two at a time) eg. `6009`{.verbatim},
    `1901-2032`{.verbatim}, or `7688-7692-2`{.verbatim}

    For example, the following will create a link from page 1 to 5, from
    5 to 9, and from 9 to 10 to 11 to 12 to 13:

    ``` example
    Name: John
    1
    5
    9-13
    ```

-   Text, with the exception of a few special characters, is ignored.

    ``` example
    Name: John
    1
    5

    This text will not affect anything,
    but it can be used to describe events
    that occur on the following pages.
    9-13
    ```

-   To create a separate timeline segment from the main one, use
    indentation. If another timeline segment is made by indenting
    further, the first segment can be continued once the indentation is
    back at its level, but each segment will end once the current
    indentation level is less than that segment\'s level.

    For example, the following will create three separate timeline
    segments:

    -   The main one, at indentation 0
        -   Pages 1 to 10
    -   A second one at indentation 1
        -   Pages 10 to 20
    -   A third one at indentation 2
        -   Pages 100 to 105

    The third segment cannot be continued after the second segment has
    been continued, and the second segment cannot be continued once the
    main segment has been continued.

    ``` example
    Name: John
    This is the main segment
    1-5
      This is the second segment
      10-15
          This is the third segment
          100-105
      This is the second segment
      16-20
    This is the main segment
    6-10
    ```

-   `!`{.verbatim}: Cut a timeline segment short, rather than reducing
    indentation to do the same.

    For example, the links for the following will be:

    -   1 to 2 to 3 to 4 to 5
    -   10 to 11

    No link will be created between 5 and 10.

    ``` example
    Name: John
    1-5
    !
    10-11
    ```

-   `==>`: Connect a timeline segment to the beginning of another
    segment.

    The resulting links for the following example will be:

    -   1 to 2 to 3 to 4 to 5

    -   5 to 60 and 5 to 100

    -   60 to 61 to 62

        ``` example
        Name: John
        1-5
        ==>
          60-62
        100
        ```

-   `<==`: Connect the end of a timeline segment to another segment.

    The resulting links for the following example will be:

    -   1 to 2 to 3 to 4 to 5

    -   5 to 100

    -   60 to 61 to 62

    -   62 to 100

        ``` example
        Name: John
        1-5
          60-62
        <==
        100
        ```

-   `@TAG`{.verbatim}: Tag the next page number with TAG, to use for
    linking to later. Tags are specific to a Named person, and you
    cannot have multiple tags with the same name for the same person.

    For example:

    ``` example
    Name: Jane
    1-5

    @important-moment
    7
    ```

-   `~ NAME`{.verbatim}: Link to the first page for Person NAME. This
    must occur at the end of a timeline segment, or put differently, no
    page numbers should be placed after this within the same timeline
    segment.

    For example, the following will create a link for Dave from page 3
    to Davesprite\'s first page:

    ``` example
    Name: Dave
    1-3
    =~ Davesprite=
    ```

-   `~ NAME @ TAG`{.verbatim}: Link to the tag TAG for the person NAME.

    For example, the following will create a link for John from page 3
    to John (Dream) at a particular tag, as well as create a link for
    John from page 3 to page 4:

    ``` example
    Name: John
    1-3
    ==>
      John (Dream) @ wake-up
    4
    ```

The following commands change properties about the current person or
timeline. Write the exact word, then `:`{.verbatim}, then the value you
wish to set it to. eg. `Name: John`{.verbatim}.

-   `Name`{.verbatim}: Change the name of the current person.
-   `Colour`{.verbatim}: Change the colour used for the links.
-   `Image`{.verbatim}: Change the image used for the links.
-   `Group`{.verbatim}: Change which group the links are a part of.
-   `Caption`{.verbatim}: Give some hover-over text to the link between
    the previous page and the next.

All lines which do not fit any of the above are ignored. This allows you
to comment on the timeline, without it effecting the resultant file.

### `timelines.js`{.verbatim}

The Ruby script `timeline_compiler.rb`{.verbatim} then takes files of
the above form to produce the Javascript file `timelines.js`{.verbatim},
which defines a variable `json`{.verbatim} containing the timeline
output. The main contents of the `json`{.verbatim} variable is:

-   `timelines`{.verbatim}: a dictionary, where the index is a page
    number as a string. eg. `timelines["1901"]`{.verbatim} contains the
    information for links on page 1901.
-   Each page, `currentPage`{.verbatim}, of `timelines`{.verbatim} is an
    array of links to the next page/pages in a person\'s timeline.
-   Each of these links is a tuple of the format
    `Link = [NameID, ColourID, ImageID, GroupID, NextPages]`{.verbatim},
    where the various IDs are indices into the appropriate arrays.
-   Each page of `NextPages`{.verbatim} is a tuple of the format
    `NextPage = [PageNumber, Index, Caption]`{.verbatim}, where
    `PageNumber`{.verbatim} is the number of the next page,
    `Index`{.verbatim} is the index of that persons position in the
    links on that page, and `Caption`{.verbatim} (if it exists) is the
    text that appears on hover-over.

## Changelog

### v1.0

### v0.9
- Far too many timeline gixes to reasonably list
- Act 6 Act 5 Act 1 x2 Combo pages fixed
- Added "Hide Original Links" option
- Added original license from madman-bob's repo

### v0.8
- Made icons change depending on story context
- New icons for B1 and B2 Jack
- Fanon icons for exiles added
- A lot of timeline fixes

### v0.7
- Better Homescreen

#### v0.6.1
- Fixed white hover text in scratch theme
- Fixed Horuss's name in the timeline povmap

### v0.6
- Redid inserting link code
- Finished Timeline map (/povmap)

### v0.5
- Added "Always display names" option
- Added Timeline Map (Unfishined)

### v0.4.1
- Updated DOTA timeline intersection

### v0.4
- Added hover text
- Fixed styling on Collide
- Fixed paths on Act 7

### v0.3

- Fixed undefined pages bug (Signaled end of a timeline)
- Added end of Timeline signals
- Fixed pages linking beyond 10000 causing errors

### v0.2

- Accounted for missing page indexes within timelines.json
- Revised john.png
- Fixed tab bug

## Harry Hinderson Additional Characters Branch

TODO:

harlequinsprite

dream-aradia
dream-tavros
prospit-sollux
derse-sollux
dream-karkat
dream-nepeta
dream-kanaya
dream-terezi
dream-vriska
dream-equius
dream-gamzee
dream-eridan
dream-feferi

fedorafreak

dream-calliope
dream-caliborn

- Update settings
- Fully update collide/act 7
- Fully update homepage

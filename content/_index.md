---
# Leave the homepage title empty to use the site title
title: ''
summary: ''
date: 2022-10-24
type: landing

# Same sections, in the same order, as the old Wowchemy homepage
sections:
  # Old `about` widget
  - block: resume-biography
    id: about
    content:
      # A profile in `data/authors/`
      username: admin
    design:
      avatar:
        size: medium
        shape: circle

  # Old `featured` widget: publications with `featured: true`
  - block: collection
    id: featured
    content:
      title: Recent Publications
      subtitle: 'See [Full Publication List](papers/)'
      filters:
        folders:
          - publication
        featured_only: true
      count: 0
      order: desc
    design:
      view: date-title-summary

  # Old `posts` widget
  - block: collection
    id: posts
    content:
      title: Recent Posts
      filters:
        folders:
          - post
      count: 5
      order: desc
    design:
      view: date-title-summary

  # Old `tag_cloud` widget (custom block in layouts/_partials/hbx/blocks/tag-cloud/)
  - block: tag-cloud
    id: tags
    content:
      title: Popular Topics
      taxonomy: tags
      count: 20
    design:
      font_size_min: 0.7
      font_size_max: 1.25

  # Old `contact` widget
  - block: contact-info
    id: contact
    content:
      title: Contact
      email: goodman@njit.edu
      phone: 973 642 4261
      address:
        lines:
          - Department of Mathematical Sciences, University Heights
          - Newark, NJ 07102
          - United States
      directions: __504A Cullimore Hall.__ If coming from Newark Penn Station, go to the Newark Light Rail, buy an Underground Fare from the machine for $0.75, validate it, and board at the far track for a train bound for Branch Brook Park or Grove Street. Get out at Warren Street/NJIT.
      office_hours:
        - 'Tuesday/Friday 2:50-3:50'
      social:
        - icon: hero/video-camera
          url: 'https://njit-edu.zoom.us/my/roygoodman?pwd=TndULzBoNGJ4UWNuaEdndmNWS2RoUT09'
          label: Zoom Room
      map_url: https://www.openstreetmap.org/?mlat=40.742700&mlon=-74.176944#map=17/40.742700/-74.176944
---

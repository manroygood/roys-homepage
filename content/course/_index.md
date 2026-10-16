---
title: Courses
type: landing
cascade:
  - target:
      path: '{/course/*/**}'
    type: docs
    params:
      show_breadcrumb: true
sections:
  - block: collection
    content:
      title: Courses
      filters:
        folders:
          - course
        kinds:
          - section
    design:
      view: article-grid
      show_read_time: false
      show_date: false
      columns: 1
---

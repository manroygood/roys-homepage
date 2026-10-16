---
# Course title, summary, and position.
linktitle: Math 676
summary: Fall 2022
weight: 676

# Page metadata.
title: Math 676 Graduate Differential Equations

draft: false # Is this a draft? true/false
toc: false  # Show table of contents? true/false
type: docs
tags: 
    - previous

---

> [!NOTE]
> **Archived course page.** I taught this course in Fall 2022. Links to Canvas only work for students who were enrolled.



### Course Info

Almost everything is on the [course Canvas page](https://njit.instructure.com/courses/25954/) or on the official Math Department [syllabus](https://docs.google.com/document/d/1OdW1ayElsS67pVct_RhMLtWu22ovh7k_ewEhhuUq9Z8). Canvas and Google Docs are bad at rendering mathematics and computer code, so I maintain this webpage to post math-heavy and code-heavy information.

#### MATLAB startup file
I use a file [`startup.m`](https://www.mathworks.com/help/matlab/ref/startup.html) to replace the default MATLAB graphing settings with something a little bit nicer. In particular, I include $\LaTeX$ formatting in my axis labels. $\LaTeX$ is a markup language that mathematicians use to typeset math. If any of my MATLAB programs give you errors, run these lines first:
```matlab
set(groot,'DefaultAxesFontSize',14)
set(groot,'DefaultLineLineWidth',2)
set(groot,'DefaultFunctionLineLineWidth',2)
set(groot,'DefaultTextInterpreter','latex')
set(groot,'DefaultAxesTickLabelInterpreter','latex')
set(groot,'DefaultLegendInterpreter','latex');
```
This changes how math is interpreted in figures and requires any $\LaTeX$ math to be enclosed between dollar signs.

#### MATLAB Dynamical Systems Software
At some point, we may want to draw direction fields and phase planes. This capability is not built into MATLAB in a simple way, so you'll have to install some [additional software](https://github.com/MathWorks-Teaching-Resources/Phase-Plane-and-Slope-Field). The site provides complete documentation and how-to videos.

#### Computational solutions to homework problems
* {{< staticref "math676/patrick3p4c.html" >}}Meiss 3.4c{{< /staticref >}}


---
# Course title, summary, and position.
linktitle: NQG_Valenciennes
summary: One week summer school on Nonlinear Quantum Graphs, Valenciennes, France, June 17-21, 2024
weight: 1000

# Page metadata.
title: Summer School on Nonlinear Quantum Graphs
draft: false # Is this a draft? true/false
toc: false  # Show table of contents? true/false
type: docs
tags: 
    - current

---

I was invited to give a series of five one-hour lectures on numerical methods for quantum graphs at a [Summer School](https://nqg.sciencesconf.org) at [Université Polytechnique Hauts-de-France](https://www.uphf.fr/en) in June, 2024. Thanks to the organizers

* Colette De Coster (UPHF, Valenciennes)
* Damien Galant (UPHF, Valenciennes and UMONS, Mons, Belgium)
* Louis Jeanjean (Université de Franche-Comté, Besançon)
* Stefan Le Coz (Université Paul Sabatier, Toulouse)

Below are my handwritten lecture notes and links to my supplementary slides with numerical examples.

## Lecture Notes
 * **Lecture 1:** Finite-difference discretization of the Poisson problem on a quantum graph.
   * {{< staticref "nqg/lecture1.pdf" >}}Handwritten notes{{< /staticref >}} 
   * [Accompanying slides](https://www.icloud.com/keynote/051bCbSl9_V2ba0xpF248YBMg#Lecture_1) (click play button to see builds and animations)
* **Lecture 2:** Rectangular Chebyshev collocation for the Poisson problem on a quantum graph.
  * {{< staticref "nqg/lecture2.pdf" >}}Handwritten notes{{< /staticref >}} 
  * [Accompanying slides](https://www.icloud.com/keynote/01dNLa4FCJl1QeChOFIHmIRkQ#Lecture_2)
* **Lecture 3:** Application of the framework to other numerical problems
  * {{< staticref "nqg/lecture3.pdf" >}}Handwritten notes{{< /staticref >}} 
  * [Accompanying slides](https://www.icloud.com/keynote/089qXHHP3CsNFUHyS_5s_HX9g#Lecture_3)
* **Lecture 4:** Implicit-explicit time stepping
  * {{< staticref "nqg/lecture4.pdf" >}}Handwritten notes{{< /staticref >}} 
  * [Accompanying slides](https://www.icloud.com/keynote/03dPy6nlokkGdRocT6kwjhTyQ#Lecture_4)
* **Lecture 5:** Continuation methods
  * {{< staticref "nqg/lecture5.pdf" >}}Handwritten notes{{< /staticref >}} 
  * [Accompanying slides](https://www.icloud.com/keynote/0deMvuJsw07Y8WLUAbehXdaoA#Lecture_5)

## Computational Examples

### Examples from Delio Mugnolo's lectures

* {{< staticref "nqg/mugnoloExample1.html" >}}Example 1{{< /staticref >}} An upper bound on the eigevalues of a quantum graph Laplacian. 
* {{< staticref "nqg/mugnoloExample2.html" >}}Example 2{{< /staticref >}} A lower bound on the eigevalues of a quantum graph Laplacian.
* {{< staticref "nqg/mugnoloExample3.html" >}}Example 3{{< /staticref >}} Monotonicity of the eigevalues of a quantum graph Laplacian as the length of an edge is increased.

### Examples from Diego Noja's lectures

* {{< staticref "nqg/orbitalStability.html" >}}Orbital Stability Example{{< /staticref >}} Considers two solutions to NLS on a dumbbell graph, one orbitally stable and the other unstable. Demonstrates what these look like in numerical simulations.

## References

### Main reference
* Goodman, Roy H, Grace Conte, and Jeremy L Marzuola. 2023.
[QGLAB: A MATLAB Package for Computations on
Quantum Graphs.]({{< relref "/publication/qglab" >}}) *arXiv 2401.00561*.

### Inspirations for this work

* Besse, Christophe, Romain Duboscq, and Stefan Le Coz. 2021.
“<span class="nocase">Numerical Simulations on Nonlinear Quantum Graphs
with the GraFiDi Library</span>.” *arXiv 2103.09650*.

* Goodman, Roy H. 2019. “<span class="nocase">NLS bifurcations on the
bowtie combinatorial graph and the dumbbell metric graph</span>.”
*Discrete & Continuous Dynamical Systems - A* 39: 2203–32.

* Kairzhan, Adilbek, Dmitry E Pelinovsky, and Roy H Goodman. 2019.
“<span class="nocase">Drift of Spectrally Stable Shifted States on Star
Graphs</span>.” *SIAM Journal on Applied Dynamical Systems* 18: 1723–55.

* Marzuola, Jeremy L, and Dmitry E Pelinovsky. 2016.
“<span class="nocase">Ground State on the Dumbbell Graph</span>.”
*Applied Mathematics Research eXpress* 2016: 98–145.

### Spectral methods for boundary value problems

* Aurentz, Jared L., and Lloyd N. Trefethen. 2017.
“<span class="nocase">Block Operators and Spectral
Discretizations</span>.” *SIAM Review* 59: 423–46.

* Boyd, John P. 2000. *<span class="nocase">Chebyshev and Fourier Spectral
Methods</span>*. Mineola, NY: Dover Publications.

* Driscoll, Tobin A, and Nicholas Hale. 2015.
“<span class="nocase">Rectangular spectral collocation</span>.” *IMA
Journal of Numerical Analysis* 38: 108–32.

* Trefethen, Lloyd N. 2000. *<span class="nocase">Spectral Methods in
Matlab</span>*. SIAM.

* Xu, Kuan, and Nicholas Hale. 2016. “<span class="nocase">Explicit
construction of rectangular differentiation matrices</span>.” *IMA
Journal of Numerical Analysis* 36: 618 - 632.

### Implicit-explict Runge-Kutta methods

* Ascher, Uri M, Steven J Ruuth, and Raymond J Spiteri. 1997.
“<span class="nocase">Implicit-explicit Runge-Kutta methods for
time-dependent partial differential equations</span>.” *Applied
Numerical Mathematics* 25: 151–67.

### Continuation Methods

* Dhooge, A, Willy J F Govaerts, Yu A Kuznetsov, H G E Meijer, and B
Sautois. 2008. “<span class="nocase">New features of the software
MatCont for bifurcation analysis of dynamical systems</span>.”
*Mathematical and Computer Modelling of Dynamical Systems* 14:
147–75.

* Dhooge, Annick, Willy J F Govaerts, and Yu A Kuznetsov. 2003.
“<span class="nocase">MATCONT: a MATLAB package for numerical
bifurcation analysis of ODEs</span>.” *ACM Transactions on Mathematical
Software* 29: 141–64.

* Doedel, Eusebius, and Bart Oldemann. “AUTO-07P : Users Manual.”

* Nayfeh, Ali Hassan, and Balakumar Balachandran. 1995.
*<span class="nocase">Applied nonlinear dynamics: analytical,
computational and experimental methods</span>*. Weinheim: Wiley VCH.

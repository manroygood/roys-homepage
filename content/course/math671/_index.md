---
# Course title, summary, and position.
linktitle: Math 671
summary: Fall 2023
weight: 671

# Page metadata.
title: Math 671–Asymptotic Methods
draft: false # Is this a draft? true/false
toc: false  # Show table of contents? true/false
type: docs
tags: 
    - previous

---

### Course Info
Almost everything is on the [course canvas page](https://njit.instructure.com/courses/31528).

### Why do I have this webpage then?

Because Canvas is not very good at typesetting long stretches of math, like this equation that may have a boundary layer

$$
\begin{gathered}
\epsilon y''(x) + y' + e^{-y} = 0, \\, 0< x< 1 \\\\
y(0)=1,   \\, y(1) = -1,
\end{gathered}
$$

and at highlighting code, like this Fibonacci sequence calculation in MATLAB

```matlab
% Good code has comments
n = 5;
a = zeros(1,n);
for k = 3:n
   a(k) = a(k-1) + a(k-2);
end
plot(1:n,a)
```
and sometimes I like to share math and computer code with my classes.
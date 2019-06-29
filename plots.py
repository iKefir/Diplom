#! /usr/bin/env python
# -*- coding: utf-8 -*-
import matplotlib
import matplotlib.pyplot as plt

fig = plt.figure()
plt.grid(True)
plt.plot(range(1000), 'r')
fig.axes[0].set_xlim(0, 100)
fig.axes[0].set_ylim(0, 100)
plt.xlabel('evaluations')
plt.ylabel('best f(x) since change')
plt.show()

plt.close('all')

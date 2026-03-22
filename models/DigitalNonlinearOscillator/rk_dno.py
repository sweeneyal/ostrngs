import numpy as np
import matplotlib.pyplot as plt
from math import ceil

import sys
sys.path.append('./python')

from abnmaker.rk import solve_abn

dt     = 30e-12
tmax   = 700.0e-9
ic     = np.zeros(shape=(4,))
tau    = np.int64(np.ceil(np.random.normal(3e-9, 1e-10, (4, 4))/dt))
tau[:, 3] = np.zeros(shape=(4,), dtype=np.int64)

tau_LP = 0.8e-9
c      = 1/tau_LP

def Xth(x):
    if x > 0.5:
        return 1
    else:
        return 0

def xor_two(X, step, tau, id):
    idx0 = master_idx[id][0]
    idx1 = master_idx[id][1]
    X0 = ic[idx0]
    X1 = ic[idx1]
    if step - tau[id, idx0] >= 0:
        X0 = Xth(X[idx0, step - tau[id, idx0]])
    if step - tau[id, idx1] >= 0:
        X1 = Xth(X[idx1, step - tau[id, idx1]])
    
    return int(X0) ^ int(X1) 

def xnor_two(X, step, tau, id):
    idx0 = master_idx[id][0]
    idx1 = master_idx[id][1]
    X0 = ic[idx0]
    X1 = ic[idx1]
    if step - tau[id, idx0] >= 0:
        X0 = Xth(X[idx0, step - tau[id, idx0]])
    if step - tau[id, idx1] >= 0:
        X1 = Xth(X[idx1, step - tau[id, idx1]])
    
    return int(not(int(X0) ^ int(X1)))

def xor_three(X, step, tau, id):
    idx0 = master_idx[id][0]
    idx1 = master_idx[id][1]
    idx2 = master_idx[id][2]
    X0 = ic[idx0]
    X1 = ic[idx1]
    X2 = ic[idx2]
    if step - tau[id, idx0] >= 0:
        X0 = Xth(X[idx0, step - tau[id, idx0]])
    if step - tau[id, idx1] >= 0:
        X1 = Xth(X[idx1, step - tau[id, idx1]])
    if step - tau[id, idx2] >= 0:
        X2 = Xth(X[idx2, step - tau[id, idx2]])
    
    return int(X0) ^ int(X1) ^ int(X2)

master_idx = [
    [0, 2],
    [1, 2],
    [0, 1, 3],
    [0]
]

f        = 300
period   = ceil((1/(f*1e6))/dt)
uptime   = int(period/2)
def pulse(X, step, tau, id):
    if step % period < uptime:
        return 0
    else:
        return 1
    
gammas = [
    xor_two,
    xnor_two,
    xor_three,
    pulse
]

def fun(X, step, tau):
    k = np.zeros(shape=(len(gammas),))
    for i in range(len(gammas)):
        k[i] = gammas[i](X, step, tau, i)
    k = -c * (np.power(-1, k))
    return k

t, y = solve_abn(fun, tau, (0, tmax), ic, dt)

plt.rcParams['figure.figsize'] = (10, 5)
plt.rcParams.update({'figure.autolayout': True})

fig, ax = plt.subplots(4)

ax[0].plot(t * 1e9, y[0, :], color="b")
# ax[0].set_xlabel('Time [ns]')
ax[0].set_ylabel('Input [V]')
ax[0].set_xlim((0, tmax * 1e9))
ax[0].set_ylim((-0.25, 1.25))
# ax[0,0].title('Slew-Rate-Based Model of Delayed Feedback XNOR Oscillator')

ax[1].plot(t * 1e9, y[1, :], color="b")
# ax[1].set_xlabel('Time [ns]')
ax[1].set_ylabel('ELB #1 [V]')
ax[1].set_xlim((0, tmax * 1e9))
ax[1].set_ylim((-0.25, 1.25))
# ax[0,0].title('Slew-Rate-Based Model of Delayed Feedback XNOR Oscillator')

ax[2].plot(t * 1e9, y[2, :], color="b")
# ax[2].set_xlabel('Time [ns]')
ax[2].set_ylabel('ELB #2 [V]')
ax[2].set_xlim((0, tmax * 1e9))
ax[2].set_ylim((-0.25, 1.25))

ax[3].plot(t * 1e9, y[3, :], color="b")
ax[3].set_xlabel('Time [ns]')
ax[3].set_ylabel('ELB #3 [V]')
ax[3].set_xlim((0, tmax * 1e9))
ax[3].set_ylim((-0.25, 1.25))
# ax[0,0].title('Slew-Rate-Based Model of Delayed Feedback XNOR Oscillator')

ax[0].set_title('Digital Nonlinear Oscillator - Slew Rate')
plt.savefig('data/figures/dno_300MHz.png')
plt.show()

from tqdm import tqdm

numcaptures = 500
bifurcation = np.zeros((numcaptures,100))
idx = 0

f0 = 300
f1 = 400
frange = np.linspace(f0, f1, numcaptures);

for f in tqdm(frange):
    period   = ceil((1/(f*1e6))/dt)
    uptime   = int(period/2)
    def pulse(X, step, tau, id):
        if step % period < uptime:
            return 0
        else:
            return 1
        
    gammas = [
        xor_two,
        xnor_two,
        xor_three,
        pulse
    ]

    def fun(X, step, tau):
        k = np.zeros(shape=(len(gammas),))
        for i in range(len(gammas)):
            k[i] = gammas[i](X, step, tau, i)
        k = -c * (np.power(-1, k))
        return k

    t, y = solve_abn(fun, tau, (0, tmax), ic, dt)

    for k in range(100,200):
        bifurcation[idx, k - 100] = y[1, ceil(k * period + 30/360 * period)]
    idx += 1

xd = frange
for i in range(numcaptures):
    y = xd[i] * np.ones(100)
    x = bifurcation[i, :]
    plt.scatter(x,y,color='b', alpha=0.3, s=10)

plt.title('Digital Nonlinear Oscillator - Slew Rate Bifurcation Diagram')
plt.xlabel(r'$z(t_k)$ [V]')
plt.ylabel(r'$\phi$ Excitation Frequency [MHz]')
plt.savefig('data/figures/dno_bifurcation.png')
plt.show()
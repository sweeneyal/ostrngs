import numpy as np
import matplotlib.pyplot as plt

import sys
sys.path.append('./python')

from abnmaker.rk import solve_abn

dt     = 30e-12
tmax   = 250.0e-9
ic     = np.zeros(shape=(16,))
tau    = np.int64(np.ceil(np.random.normal(3e-9, 1e-10, (16, 16))/dt))

tau_LP = 0.8e-9
c      = 1/tau_LP

def Xth(x):
    if x > 0.5:
        return 1
    else:
        return 0

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

def xnor_three(X, step, tau, id):
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
    
    return int(not(int(X0) ^ int(X1) ^ int(X2)))

master_idx = [
    [0, 1, 2],
    [1, 2, 3],
    [2, 3, 4],
    [3, 4, 5],
    [4, 5, 6],
    [5, 6, 7],
    [6, 7, 8],
    [7, 8, 9],
    [8, 9, 10],
    [9, 10, 11],
    [10, 11, 12],
    [11, 12, 13],
    [12, 13, 14],
    [13, 14, 15],
    [14, 15, 0],
    [15, 0, 1]
]

gammas = [
    xor_three,
    xor_three,
    xor_three,
    xor_three,
    xor_three,
    xor_three,
    xor_three,
    xor_three,
    xor_three,
    xor_three,
    xor_three,
    xor_three,
    xor_three,
    xor_three,
    xor_three,
    xnor_three
]

def fun(X, step, tau):
    k = np.zeros(shape=(len(gammas),))
    for i in range(len(gammas)):
        k[i] = gammas[i](X, step, tau, i)
    k = -c * (np.power(-1, k))
    return k

t, y = solve_abn(fun, tau, (0, tmax), ic, dt)
plt.rcParams['figure.figsize'] = (10, 2)
plt.rcParams.update({'figure.autolayout': True})

plt.plot(t * 1e9, y[1, :], color="b")
plt.xlabel('Time [ns]')
plt.ylabel('Voltage [V]')
plt.xlim((0, tmax * 1e9))
plt.title('Slew-Rate-Based Model of Mesh-Coupled XOR Entropy Source')
plt.savefig('data/figures/xorring_slewrate.png')
plt.show()
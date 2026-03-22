import numpy as np
import matplotlib.pyplot as plt

import sys
sys.path.append('./python')

from abnmaker.rk import solve_abn

dt     = 30e-12
tmax   = 250.0e-9
ic     = np.zeros(shape=(40,))
tau    = np.int64(np.ceil(np.random.normal(3e-9, 1e-10, (40, 40))/dt))

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
    if step - tau[id,idx0] >= 0:
        X0 = Xth(X[idx0, step - tau[id,idx0]])
    if step - tau[id,idx1] >= 0:
        X1 = Xth(X[idx1, step - tau[id,idx1]])
    
    return int(X0) ^ int(X1) 

def xor_four(X, step, tau, id):
    idx0 = master_idx[id][0]
    idx1 = master_idx[id][1]
    idx2 = master_idx[id][2]
    idx3 = master_idx[id][3]
    X0 = ic[idx0]
    X1 = ic[idx1]
    X2 = ic[idx2]
    X3 = ic[idx3]
    if step - tau[id, idx0] >= 0:
        X0 = Xth(X[idx0, step - tau[id, idx0]])
    if step - tau[id, idx1] >= 0:
        X1 = Xth(X[idx1, step - tau[id, idx1]])
    if step - tau[id, idx2] >= 0:
        X2 = Xth(X[idx2, step - tau[id, idx2]])
    if step - tau[id, idx3] >= 0:
        X3 = Xth(X[idx3, step - tau[id, idx3]])
    
    return int(X0) ^ int(X1) ^ int(X2) ^ int(X3)

def ring_oscillator(X, step, tau, id):
    idx0 = master_idx[id][0]
    X0 = ic[idx0]
    if step - tau[id, idx0] >= 0:
        X0 = Xth(X[idx0, step - tau[id, idx0]])

    return int(not(int(X0)))

master_idx = [
    [0],
    [0, 3, 8, 20],
    [1, 3],
    [2, 4],
    [2, 5, 9, 21],
    [5],
    [1, 8],
    [4, 9],
    [6, 11],
    [7, 14],
    [10],
    [6, 10, 13, 22],
    [11, 13],
    [12, 14],
    [7, 12, 15, 23],
    [15],
    [1, 20],
    [4, 21],
    [11, 22],
    [14, 23],
    [16, 25],
    [17, 28],
    [18, 35],
    [19, 38],
    [24],
    [16, 24, 27, 32],
    [25, 27],
    [26, 28],
    [17, 26, 29, 33],
    [29],
    [25, 32],
    [28, 33],
    [30, 35],
    [31, 38],
    [34],
    [18, 34, 30, 37],
    [35, 37],
    [36, 38],
    [19, 31, 36, 39],
    [39]
]

gammas = [
    ring_oscillator,
    xor_four,
    xor_two,
    xor_two,
    xor_four,
    ring_oscillator,
    xor_two,
    xor_two,
    xor_two,
    xor_two,
    ring_oscillator,
    xor_four,
    xor_two,
    xor_two,
    xor_four,
    ring_oscillator,
    xor_two,
    xor_two,
    xor_two,
    xor_two,
    xor_two,
    xor_two,
    xor_two,
    xor_two,
    ring_oscillator,
    xor_four,
    xor_two,
    xor_two,
    xor_four,
    ring_oscillator,
    xor_two,
    xor_two,
    xor_two,
    xor_two,
    ring_oscillator,
    xor_four,
    xor_two,
    xor_two,
    xor_four,
    ring_oscillator,
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
plt.savefig('data/figures/meshcoupledxor_slewrate.png')
plt.show()
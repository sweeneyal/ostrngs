import numpy as np
import matplotlib.pyplot as plt

dt     = 50e-12
tau_LP = 0.8e-9
tmax   = 120.0e-9
t      = np.arange(start=0.0, stop=tmax, step=dt)

ic = 0

tau = np.int64(np.ceil(np.random.normal(1e-9, 1e-10, (40))/dt))

state  = np.zeros(shape=(40, len(t)))
driver = np.zeros(shape=(40, len(t)))
x_dot  = np.zeros(shape=(40, len(t)))

def Xth(x):
    if x > 0.5:
        return 1
    else:
        return 0
    
def bound(x):
    if x >= 0 and x <= 1:
        return x
    elif x > 1:
        return 1
    else:
        return 0

def xor_two(X, step, tau, idxs):
    X0 = ic
    X1 = ic
    idx0 = idxs[0]
    idx1 = idxs[1]
    if step - tau[idx0] >= 0:
        X0 = Xth(X[idx0, step - tau[idx0]])
    if step - tau[idx1] >= 0:
        X1 = Xth(X[idx1, step - tau[idx1]])
    
    return int(X0) ^ int(X1) 

def xor_four(X, step, tau, idxs):
    X0 = ic
    X1 = ic
    X2 = ic
    X3 = ic
    idx0 = idxs[0]
    idx1 = idxs[1]
    idx2 = idxs[2]
    idx3 = idxs[3]
    if step - tau[idx0] >= 0:
        X0 = Xth(X[idx0, step - tau[idx0]])
    if step - tau[idx1] >= 0:
        X1 = Xth(X[idx1, step - tau[idx1]])
    if step - tau[idx2] >= 0:
        X2 = Xth(X[idx2, step - tau[idx2]])
    if step - tau[idx3] >= 0:
        X3 = Xth(X[idx3, step - tau[idx3]])
    
    return int(X0) ^ int(X1) ^ int(X2) ^ int(X3)

def ring_oscillator(X, step, tau, idxs):
    X0 = ic
    idx0 = idxs[0]
    if step - tau[idx0] >= 0:
        X0 = Xth(X[idx0, step - tau[idx0]])

    return int(not(int(X0)))

c = 1/tau_LP

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

for i in range(len(t) - 1):
    for j in range(40):
        gamma         = gammas[j]
        idxs          = master_idx[j]
        driver[j, i]  = gamma(state, i, tau, idxs)
        x_dot[j, i]   = -c * ((-1) ** driver[j, i])
        state[j, i+1] = bound(x_dot[j, i] * dt + state[j, i])

plt.rcParams['figure.figsize'] = (7, 2)
plt.rcParams.update({'figure.autolayout': True})

plt.plot(t * 1e9, state[1, :], color="b")
plt.xlabel('Time [ns]')
plt.ylabel('Voltage [V]')
plt.xlim((0, tmax * 1e9))
plt.title('Slew-Rate-Based Model of Mesh-Coupled XOR Entropy Source')
plt.savefig('data/figures/meshcoupledxor_slewrate.png')
plt.show()

for i in range(len(t) - 1):
    for j in range(40):
        gamma         = gammas[j]
        idxs          = master_idx[j]
        driver[j, i]  = gamma(state, i, tau, idxs)
        x_dot[j, i]   = (-state[j, i] + driver[j, i])/tau_LP
        state[j, i+1] = bound(x_dot[j, i] * dt + state[j, i])

plt.rcParams['figure.figsize'] = (7, 2)
plt.rcParams.update({'figure.autolayout': True})

plt.plot(t * 1e9, state[1, :], color="b")
plt.xlabel('Time [ns]')
plt.ylabel('Voltage [V]')
plt.xlim((0, tmax * 1e9))
plt.title('Piecewise Linear DE Model of Mesh-Coupled XOR Entropy Source')
plt.savefig('data/figures/meshcoupledxor_plde.png')
plt.show()
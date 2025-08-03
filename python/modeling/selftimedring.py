import numpy as np
import matplotlib.pyplot as plt

dt     = 50e-12
tau_LP = 0.8e-9
tmax   = 1200.0e-9
t      = np.arange(start=0.0, stop=tmax, step=dt)

ic = np.zeros(shape=(45));
for i in range(45):
    if i % 4 >= 2:
        ic[i] = 1

tau = np.int64(np.ceil(np.random.normal(1e-9, 1e-10, (45))/dt))

state  = np.zeros(shape=(45, len(t)))
driver = np.zeros(shape=(45, len(t)))
x_dot  = np.zeros(shape=(45, len(t)))

def Xth(x):
    if x > 0.5:
        return 1
    else:
        return 0

def mullerc_latch(X, step, tau, idx):
    F = ic[idx - 1]
    C = ic[idx]
    if step - tau[idx] >= 0:
        C = Xth(X[idx, step - tau[idx]])
    if step - tau[idx - 1] >= 0:
        F = Xth(X[idx - 1, step - tau[idx - 1]])

    if idx + 1 >= len(ic):
        R = ic[len(ic) - (idx + 1)]
        if step - tau[len(ic) - (idx + 1)] >= 0:
            R = Xth(X[len(ic) - (idx + 1), step - tau[len(ic) - (idx + 1)]])
    else:
        R = ic[idx + 1]
        if step - tau[idx + 1] >= 0:
            R = Xth(X[idx + 1, step - tau[idx + 1]])
    
    if int(F) ^ int(R) == 1:
        return int(F)
    else:
        return int(C)
    
def bound(x):
    if x >= 0 and x <= 1:
        return x
    elif x > 1:
        return 1
    else:
        return 0

c = 1/tau_LP

for i in range(len(t) - 1):
    for j in range(45):
        driver[j, i]  = mullerc_latch(state, i, tau, j)
        x_dot[j, i]   = -c * ((-1) ** driver[j, i])
        state[j, i+1] = bound(x_dot[j, i] * dt + state[j, i])

plt.rcParams['figure.figsize'] = (7, 2)
plt.rcParams.update({'figure.autolayout': True})

plt.plot(t * 1e9, state[0, :], color="b")
plt.xlabel('Time [ns]')
plt.ylabel('Voltage [V]')
plt.xlim((0, tmax * 1e9))
plt.title('Slew-Rate-Based Model of Self-Timed Ring Entropy Source')
plt.savefig('data/figures/selftimedring.png')
plt.show()
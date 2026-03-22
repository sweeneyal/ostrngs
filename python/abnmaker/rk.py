import numpy as np

def bound(x):
    k = np.zeros(shape=(1, len(x)))
    for i in range(len(x)):
        if x[i] >= 0 and x[i] <= 1:
            k[0, i] = x[i]
        elif x[i] > 1:
            k[0, i] = 1
        else:
            k[0, i] = 0
    return k

def rk_step(fun, step, dt, y, tau):
    state_ = y.copy()

    k1 = fun(state_, step, tau)
    state_[:, step] = y[:, step] + 0.5 * k1 * dt
    k2 = fun(state_, step, tau)
    state_[:, step] = state_[:, step] + 0.5 * k2 * dt
    k3 = fun(state_, step, tau)
    state_[:, step] = state_[:, step] + k3 * dt
    k4 = fun(state_, step, tau)

    y_dot = (k1 + 2*k2 + 2*k3 + k4)/6
    return bound(y_dot * dt + y[:, step])

def solve_abn(fun, tau, teval, ic, dt):
    t = np.arange(teval[0], teval[1], dt)
    y = np.zeros(shape=(len(ic), len(t)))
    for i in range(len(t) - 1):
        y_new     = rk_step(fun, i, dt, y, tau)
        y[:, i+1] = y_new
    return t, y
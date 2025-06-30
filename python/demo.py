import nist.estimators as nist

import time

filename = "./libraries/SP800-90B_EntropyAssessment/bin/truerand_1bit.bin"

with open(filename, "rb") as f:
    S = f.read()

    estimates = {}
    for estimator in nist.suite:
        print(estimator.__name__)
        t = time.time()
        estimates[estimator.__name__] = estimator(S, domain=[0,1])
        print(estimates[estimator.__name__])
        print(str(time.time() - t) + 's')
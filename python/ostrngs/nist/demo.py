import estimators as nist

import time

# filename = "./libraries/SP800-90B_EntropyAssessment/bin/truerand_1bit.bin"
filename = "./2025-11-21_02:48:42_collection.bin"

with open(filename, "rb") as f:
    S = f.read()
    S = list(S)

    estimates = {}
    for estimator in nist.suite:
        print(estimator.__name__)
        t = time.time()
        estimates[estimator.__name__] = estimator(S, domain=list(range(2**6)))
        print(estimates[estimator.__name__])
        print(str(time.time() - t) + 's')
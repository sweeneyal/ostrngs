from math import sqrt, log2, exp, floor, comb
from scipy.special import gammaincc, gamma
import numpy as np
import itertools

# --------------------------------------------------------------------------------------------

def MostCommonValueEstimate(dataset, domain):
    """
    
    """
    max_x = 0
    for x in domain:
        num_x = dataset.count(x)
        if num_x > max_x:
            max_x = num_x
    L     = len(dataset)
    p_hat = max_x/L
    p_u   = min(1, p_hat + 2.576*sqrt(p_hat * (1 - p_hat) / (L - 1)))
    return -log2(p_u)

# --------------------------------------------------------------------------------------------

def CollisionEstimate(dataset, domain=[0, 1]):
    """

    """
    # Domain is not allowed as an input since the domain is {0, 1}
    v     = 0
    index = 0
    L     = len(dataset)
    t     = []
    while index < L - 1:
        for j in range(index + 1, L):
            for i in range(index, j):
                if dataset[i] == dataset[j]:
                    v += 1
                    t.append(j - index + 1)
                    index = j + 1
                    break
                if i == L-2 and j == L-1:
                    index = 40
                    break

            # If the inner loop completes w/o the break, then the outer loop will continue. Otherwise, the break
            # statement will run and both loops will be broken out of.
            else:
                continue
            break
    sample_mean      = sum(t)/v
    sample_std       = sqrt((1 / (v - 1)) * sum([(ti - sample_mean)**2 for ti in t]))
    mean_lower_bound = sample_mean - 2.576*(sample_std / sqrt(v))

    # binary search here
    
    p           = 0.75;
    upper_bound = 1
    lower_bound = 0.5
    tolerance   = 0.0001
    while True:
        q = 1 - p

        z = 1/q
        F = (gamma(3) * gammaincc(3,z)) * (z**-3) * exp(z)

        estimate = p * (q**-2) * (1 + (0.5 * ((p**-1) - (q**-1)))) * F
        estimate -= p * (q**-1) * 0.5 * ((p**-1) - (q**-1))
        
        if mean_lower_bound < estimate:
            lower_bound = p
            p = upper_bound - (upper_bound - p) / 2
        elif mean_lower_bound > estimate:
            upper_bound = p
            p = (p - lower_bound) / 2 + lower_bound
        
        if abs(upper_bound - lower_bound) < tolerance:
            break;
        # TODO: Add logic for handling if no solution was found. Not sure what "no solution" looks like.
    return -log2(p);

# --------------------------------------------------------------------------------------------

def MarkovEstimate(dataset, domain=[0, 1]):
    """

    """
    L  = len(dataset)
    p0 = dataset.count(0) / L
    p1 = 1 - p0

    num_00 = 0
    num_01 = 0
    num_10 = 0
    num_11 = 0
    for i in range(L-1):
        if dataset[i] == dataset[i+1]:
            if dataset[i] == 0:
                num_00 += 1
            else:
                num_11 += 1
        else:
            if dataset[i] == 0:
                num_01 += 1
            else:
                num_10 += 1
    p00 = num_00/(num_00 + num_01)
    p01 = num_01/(num_00 + num_01)
    p10 = num_10/(num_11 + num_10)
    p11 = num_11/(num_11 + num_10)

    all_zeros        = p0 * (p00**127)
    zero_alternating = p0 * (p01**64) * (p10**63)
    leading_zero     = p0 * p01 * (p11**126)
    leading_one      = p1 * p10 * (p00**126)
    one_alternating  = p1 * (p10**64) * (p01**63)
    all_ones         = p1 * (p11**127)
    p = max(all_zeros,
        zero_alternating,
        leading_zero,
        leading_one,
        one_alternating,
        all_ones)
    
    return min(-log2(p)/128, 1)

def to_bitstring(bitlist):
    return "".join(map(str, bitlist))

# --------------------------------------------------------------------------------------------

def CompressionEstimate(dataset, domain=[0, 1], demo=False):
    """
    The compression estimate computes the entropy rate of a dataset based on how much a given dataset can be
    compressed. The dataset is portioned into a dictionary-generating dataset and test dataset, the former
    being used to compute an initial dictionary of values, and the latter used to compute the mean lower bound
    of how many samples are needed to produce an output.

    The demo flag is provided to run the function as demonstrated by specification, with an adjusted d value
    of 4 rather than 1000.
    """
    b = 6
    if demo:
        d = 4
    else:
        d = 1000
    subset = []
    L = len(dataset)
    for i in range(0, L, b):
        subset.append(dataset[i:i+b])

    first  = subset[:d]
    dict   = np.zeros(shape=(2**b))
    for i in range(d):
        bitstring = to_bitstring(first[i])
        index     = int(bitstring, 2)
        dict[index] = i + 1 # adding 1 because algorithm expects 1-indexed implementation

    v = floor(L/b) - d
    D = np.zeros(shape=(v))
    for i in range(d, floor(L/b)):
        bitstring = to_bitstring(subset[i])
        index     = int(bitstring, 2)
        
        if dict[index] != 0:
            # I add 1 here because algorithm is written with a one-indexed language in mind.
            D[i - d] = i - dict[index] + 1
        else:
            # I add 1 here because algorithm is written with a one-indexed language in mind.
            D[i - d] = i + 1
        dict[index] = i

    c = 0.5907
    sample_mean = sum(np.log2(D))/v
    sample_std  = c * sqrt((sum(np.log2(D)**2))/(v-1) - sample_mean**2)
    mean_lower_bound = sample_mean - 2.576 * sample_std/sqrt(v)

    def F(z,t,u):
        if u < t:
            return (z**2) * ((1 - z)**(u-1))
        elif u == t:
            return z * ((1 - z)**(t-1))
        
    def G(z):
        total = 0
        """
        NOTE: This is a deviation from the algorithm as written. The algorithm as written
        fails because it uses L in place of v, causing estimates to be incorrect. This is
        an errata that needs to be reported.
        """
        for t in range(d+1, v+1 + d):
            for u in range(1, t+1):
                total += log2(u) * F(z,t,u)
        return total/v
    
    p = (1 - 2**-b)/2
    upper_bound = 1
    lower_bound = 2**-b
    tolerance   = 0.0001
    while True:
        q = (1 - p)/(2**b - 1)

        estimate = G(p) + (2**b - 1)*G(q)

        if mean_lower_bound < estimate:
            lower_bound = p
            p = upper_bound - (upper_bound - p) / 2
        elif mean_lower_bound > estimate:
            upper_bound = p
            p = (p - lower_bound) / 2 + lower_bound
        
        if abs(upper_bound - lower_bound) < tolerance:
            break;
    # TODO: Add logic handling no solution. Unsure what no solution looks like (out of bounds?)
    return -log2(p)/b

# --------------------------------------------------------------------------------------------

def tTupleEstimate(dataset, domain, demo=False):
    """
    This method examines the frequency of t-tuples (pairs, triples, etc.) that appear in the input dataset
    and produces an estimate of the entropy per sample, based on the frequency of those t-tuples.

    The demo flag is provided to run the function as demonstrated by specification, with an adjusted cutoff
    of 3 rather than 35.
    """
    cutoff = 35
    if demo:
        cutoff = 3
    Q = []
    L = len(dataset)
    t = 1
    while True:
        subset = [None for _ in range(L)]
        for i in range(0, L):
            if i + t >= L:
                break
            subset[i] = tuple(dataset[i:i+t])
        unique = list(set(subset))
        count  = [0 for _ in range(len(unique))]
        for i in range(len(unique)):
            if unique[i] == None:
                continue
            count[i] = subset.count(unique[i])
        if cutoff <= max(count):
            Q.append(max(count))
            t += 1
        else:
            break
    P_max = [0 for _ in range(len(Q))]
    for i in range(len(Q)):
        # i+1 to convert from zero-indexed to one-indexed
        P = Q[i]/(L-(i+1)+1)
        P_max[i] = (P**(1/(i+1)))
    p_max = max(P_max)
    p_u = min([1, p_max + 2.576*sqrt((p_max*(1-p_max))/(L-1))])
    return -log2(p_u)

# --------------------------------------------------------------------------------------------

def LongestRepeatedSubstringEstimate(dataset, domain, demo=False):
    """
    This method estimates the collision entropy of the source, based on the number of repeated tuples within 
    the input dataset. This estimate handles tuple sizes that are too large for the t-tuple estimate, and is 
    therefore a complementary estimate.

    The demo flag is provided to run the function as demonstrated by specification, with an adjusted cutoff
    of 3 rather than 35.
    """
    cutoff = 35
    if demo:
        cutoff = 3
    L = len(dataset)
    u = 1
    u_max_count = 0
    while True:
        subset = []
        for i in range(0, L):
            if i + u >= L:
                break
            subset.append(tuple(dataset[i:i+u]))
        unique = list(set(subset))
        count  = []
        for i in range(len(unique)):
            count.append(subset.count(unique[i]))
        if cutoff <= max(count):
            u += 1
        else:
            u_max_count = max(count)
            break
    v = u
    prev_count = u_max_count
    while True:
        subset = []
        for i in range(0, L):
            if i + v >= L:
                break
            subset.append(tuple(dataset[i:i+v]))
        unique = list(set(subset))
        count  = []
        for i in range(len(unique)):
            count.append(subset.count(unique[i]))
        if max(count) == 1 and prev_count >= 2:
            break
        else:
            v += 1
    v -= 1

    """
    NOTE: Probably could rearchitect the following to fit into the above loop,
    but this more exactly follows the steps set by the spec.
    """

    P_max = []
    for w in range(u,v + 1):
        subset = []
        for i in range(0, L):
            if i + w >= L:
                break
            subset.append(tuple(dataset[i:i+w]))
        unique = list(set(subset))
        count  = []
        total  = 0
        for i in range(len(unique)):
            total += comb(subset.count(unique[i]), 2)
        P_w = total / comb(L - w + 1, 2)
        P_max.append(P_w**(1/w))

    p_max = max(P_max)
    p_u = min([1, p_max + 2.576*sqrt((p_max*(1-p_max))/(L-1))])
    return -log2(p_u)

# --------------------------------------------------------------------------------------------

def MultiMCWEstimate(dataset, domain, demo=False):
    """
    """

    w1 = 63
    w2 = 255
    w3 = 1023
    w4 = 4095

    if demo:
        w1 = 3
        w2 = 5
        w3 = 7
        w4 = 9

    w = [w1, w2, w3, w4]
    L = len(dataset)
    N = L - w1
    correct    = [0 for i in range(N)]
    scoreboard = [0, 0, 0, 0]
    frequent   = [None, None, None, None]
    winner     = 0

    for i in range(w1, L):
        for j in range(4):
            if i >= w[j]:
                max_count = 0
                window    = dataset[i-w[j]:i]

                # Over all possible items in domain, count how many
                # are in the window
                for item in domain:
                    count = window.count(item)

                    # If the count is greater than the current maximum count,
                    # then use that as the current prediction
                    if count > max_count:
                        frequent[j] = item
                        max_count   = count
                    elif count == max_count and frequent[j] != None:
                        try:
                            last_idx_prev = len(window) - 1 - window[::-1].index(frequent[j])
                            last_idx_curr = len(window) - 1 - window[::-1].index(item)
                            if last_idx_curr > last_idx_prev:
                                frequent[j] = item
                        except ValueError:
                            pass
                prediction = frequent[winner]
                if prediction == dataset[i]:
                    correct[i-w1] = 1
        for j in range(4):
            if frequent[j] == dataset[i]:
                scoreboard[j] += 1
                if scoreboard[j] >= scoreboard[winner]:
                    winner = j
    
    C = sum(correct)
    P_global = C/N
    if C == 0:
        P_prime = 1 - 0.01**(1/N)
    else:
        P_prime = min([1, P_global + 2.576*sqrt((P_global * (1 - P_global))/(N-1))])
    
    # Get the longest run of 1's in correct, plus 1
    r       = 1 + max(len(list(y)) for (c,y) in itertools.groupby(correct) if c==1)
    P_local = 0.5
    lower_bound = 0.0
    upper_bound = 1.0
    tolerance   = 0.001
    while True:
        x = 1
        for i in range(10):
            x = 1 + (1-P_local)*(P_local**r)*(x**(r+1))
        rhs = (1 - (P_local * x))/((r + 1 - r*x)*(1 - P_local)) * x**-(N+1)
        
        if rhs > 0.99:
            lower_bound = P_local
            P_local = upper_bound - (upper_bound - P_local) / 2
        elif rhs < 0.99:
            upper_bound = P_local
            P_local = (P_local - lower_bound) / 2 + lower_bound
        
        if abs(rhs - 0.99) < tolerance:
            break;
    
    return -log2(max(P_prime, P_local, 1/(len(domain))))

# --------------------------------------------------------------------------------------------

def LagPredictionEstimate(dataset, domain, demo=False):
    """
    """
    D = 128
    if demo:
        D = 3
    
    L          = len(dataset)
    N          = L-1
    lag        = [None for i in range(D)]
    correct    = [0 for i in range(N)]
    scoreboard = [0 for i in range(D)]

    winner = 0
    for i in range(1,L):
        for d in range(D):
            if (d < i):
                lag[d] = dataset[i - d - 1]
            else:
                lag[d] = None
        prediction = lag[winner]
        if prediction == dataset[i]:
            correct[i-1] = 1
        for d in range(D):
            if lag[d] == dataset[i]:
                scoreboard[d] += 1
                if scoreboard[d] >= scoreboard[winner]:
                    winner = d

    C = sum(correct)
    P_global = C/N
    if C == 0:
        P_prime = 1 - 0.01**(1/N)
    else:
        P_prime = min([1, P_global + 2.576*sqrt((P_global * (1 - P_global))/(N-1))])
    
    # Get the longest run of 1's in correct, plus 1
    r       = 1 + max(len(list(y)) for (c,y) in itertools.groupby(correct) if c==1)
    P_local = 0.5
    lower_bound = 0.0
    upper_bound = 1.0
    tolerance   = 0.001
    while True:
        x = 1
        for i in range(10):
            x = 1 + (1-P_local)*(P_local**r)*(x**(r+1))
        rhs = (1 - (P_local * x))/((r + 1 - r*x)*(1 - P_local)) * x**-(N+1)
        
        if rhs > 0.99:
            lower_bound = P_local
            P_local = upper_bound - (upper_bound - P_local) / 2
        elif rhs < 0.99:
            upper_bound = P_local
            P_local = (P_local - lower_bound) / 2 + lower_bound
        
        if abs(rhs - 0.99) < tolerance:
            break;
    
    return -log2(max(P_prime, P_local, 1/(len(domain))))

# --------------------------------------------------------------------------------------------

def MultiMMCEstimate(dataset, domain, demo=False):
    D = 16
    if demo:
        D = 3
    
    L          = len(dataset)
    N          = L-2
    subpredict = [None for i in range(D)]
    correct    = [0 for i in range(N)]
    entries    = [0 for i in range(D)]
    maxEntries = 100000

    M          = [{} for i in range(D)]
    scoreboard = [0 for i in range(D)]
    winner     = 0

    for i in range(2,L):
        for d in range(D):
            if (d < i - 1):
                before = tuple(dataset[i-d-2:i-1])
                after  = dataset[i-1]
                pair   = hash(tuple([before, after]))

                if pair in M[d].keys():
                    M[d][pair] += 1
                elif entries[d] < maxEntries:
                    M[d][pair] = 1
                    entries[d] += 1
        for d in range(D):
            if d < i:
                max_count  = 0
                ymax       = None
                before = tuple(dataset[i-d-1:i])
                for after in domain:
                    pair = hash(tuple([before, after]))
                    if pair in M[d].keys():
                        if M[d][pair] > max_count:
                            ymax = after
                            max_count = M[d][pair]
                        elif M[d][pair] == max_count:
                            if ymax < after:
                                ymax = after
                subpredict[d] = ymax
        prediction = subpredict[winner]
        if prediction == dataset[i]:
            correct[i - 2] = 1
        for d in range(D):
            if subpredict[d] == dataset[i]:
                scoreboard[d] += 1
                if scoreboard[d] >= scoreboard[winner]:
                    winner = d

    C = sum(correct)
    P_global = C/N
    if C == 0:
        P_prime = 1 - 0.01**(1/N)
    else:
        P_prime = min([1, P_global + 2.576*sqrt((P_global * (1 - P_global))/(N-1))])
    
    # Get the longest run of 1's in correct, plus 1
    r       = 1 + max(len(list(y)) for (c,y) in itertools.groupby(correct) if c==1)
    P_local = 0.5
    lower_bound = 0.0
    upper_bound = 1.0
    tolerance   = 0.001
    while True:
        x = 1
        for i in range(10):
            x = 1 + (1-P_local)*(P_local**r)*(x**(r+1))
        rhs = (1 - (P_local * x))/((r + 1 - r*x)*(1 - P_local)) * x**-(N+1)
        
        if rhs > 0.99:
            lower_bound = P_local
            P_local = upper_bound - (upper_bound - P_local) / 2
        elif rhs < 0.99:
            upper_bound = P_local
            P_local = (P_local - lower_bound) / 2 + lower_bound
        
        if abs(rhs - 0.99) < tolerance:
            break;
    
    return -log2(max(P_prime, P_local, 1/(len(domain))))

# --------------------------------------------------------------------------------------------

def L7Z8YEstimate(dataset, domain, demo=False):
    B = 16
    if demo:
        B = 4
    L = len(dataset)
    N = L-B-1

    D = {}
    dictionarySize = 0
    maxDictionarySize = 65536
    correct = [0 for i in range(N)]

    """
    NOTE: The algorithm as written makes several assumptions that are not
    easily transferrable from design to implementation. Suggest a rewrite
    to the authors. :)
    """

    for i in range(B+1, L):
        for j in range(B-1,0,-1):
            window = dataset[i-j-1:i-1]
            key    = hash(tuple(window))
            if key not in D.keys() and dictionarySize < maxDictionarySize:
                D[key] = {}
                # Starting from zero caused early prediction
                D[key][dataset[i-1]] = 1
                dictionarySize += 1
            else:
                # Needed to handle here because dictionary entry may not exist yet
                if dataset[i-1] in D[key].keys():
                    D[key][dataset[i-1]] += 1
                else:
                    D[key][dataset[i-1]] = 1
        prediction = None
        maxcount = 0
        for j in range(B-1,0,-1):
            prev = dataset[i-j:i]
            key  = hash(tuple(prev))
            if key in D.keys():
                for after in domain:
                    if after in D[key].keys():
                        if D[key][after] > maxcount:
                            prediction = after
                            maxcount = D[key][after]
                        elif D[key][after] == maxcount:
                            if prediction < after:
                                prediction = after
        if prediction == dataset[i]:
            correct[i - B - 1] = 1

    C = sum(correct)
    P_global = C/N
    if C == 0:
        P_prime = 1 - 0.01**(1/N)
    else:
        P_prime = min([1, P_global + 2.576*sqrt((P_global * (1 - P_global))/(N-1))])
    
    # Get the longest run of 1's in correct, plus 1
    r       = 1 + max(len(list(y)) for (c,y) in itertools.groupby(correct) if c==1)
    P_local = 0.5
    lower_bound = 0.0
    upper_bound = 1.0
    tolerance   = 0.0001
    while True:
        x = 1
        for i in range(10):
            x = 1 + (1-P_local)*(P_local**r)*(x**(r+1))
        rhs = (1 - (P_local * x))/((r + 1 - r*x)*(1 - P_local)) * x**-(N+1)
        
        if rhs > 0.99:
            lower_bound = P_local
            P_local = upper_bound - (upper_bound - P_local) / 2
        elif rhs < 0.99:
            upper_bound = P_local
            P_local = (P_local - lower_bound) / 2 + lower_bound
        
        if abs(rhs - 0.99) < tolerance:
            break;
    
    return -log2(max(P_prime, P_local, 1/(len(domain))))

# --------------------------------------------------------------------------------------------

suite = [
    MostCommonValueEstimate, 
    CollisionEstimate, 
    MarkovEstimate, 
    #CompressionEstimate, 
    #tTupleEstimate,
    #LongestRepeatedSubstringEstimate,
    MultiMCWEstimate,
    LagPredictionEstimate,
    MultiMMCEstimate,
    L7Z8YEstimate
]

# --------------------------------------------------------------------------------------------

if __name__ == "__main__":
    S = [0, 1, 1, 2, 0, 1, 2, 2, 0, 1, 0, 1, 1, 0, 2, 2, 1, 0, 2, 1]
    e = MostCommonValueEstimate(S, [0, 1, 2])
    print(e)
    # NOTE: Errata rounds weirdly? Found issue in example, it rounds early and then performs sqrt, thus making 
    # my number disagree. Do we need to report that since it's already an errata?

    S = [1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 
         0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0]
    e = CollisionEstimate(S)
    print(e)

    S = [1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1,
          0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0]
    e = MarkovEstimate(S)
    print(e)

    S = [1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1,
          0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1 ,1, 1, 0, 0, 0, 1, 1]
    e = CompressionEstimate(S, demo=True)
    print(e)

    S = [2, 2, 0, 1, 0, 2, 0, 1, 2, 1, 2, 0, 1, 2, 1, 0, 0, 1, 0, 0, 0]
    e = tTupleEstimate(S, domain=[0,1,2], demo=True)
    print(e)

    S = [2, 2, 0, 1, 0, 2, 0, 1, 2, 1, 2, 0, 1, 2, 1, 0, 0, 1, 0, 0, 0]
    e = LongestRepeatedSubstringEstimate(S, domain=[0,1,2], demo=True)
    print(e)

    S = [1, 2, 1, 0, 2, 1, 1, 2, 2, 0, 0, 0]
    e = MultiMCWEstimate(S, domain=[0,1,2], demo=True)
    print(e)

    S = [2, 1, 3, 2, 1, 3, 1, 3, 1, 2]
    e = LagPredictionEstimate(S, domain=[1,2,3], demo=True)
    print(e)

    S = [2, 1, 3, 2, 1, 3, 1, 3, 1]
    e = MultiMMCEstimate(S, domain=[1,2,3], demo=True)
    print(e)

    S = [2, 1, 3, 2, 1, 3, 1, 3, 1, 2, 1, 3, 2]
    e = L7Z8YEstimate(S, domain=[1,2,3], demo=True)
    print(e)
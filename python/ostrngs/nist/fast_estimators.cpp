#include <pybind11/pybind11.h>

namespace py = pybind11;

#include <vector>
#include <map>
#include <cmath>
#include <list>
#include <boost/functional/hash.hpp>

#include <iostream>

// Source: https://github.com/usnistgov/SP800-90B_EntropyAssessment/blob/master/cpp/non_iid/compression_test.h
inline void kahan_add(double &sum, double &comp, double in){
	double y, t; 

	y = in - comp;
	t = sum + y;
	comp = (t - sum) - y;
	sum = t;
}

// Source: https://github.com/usnistgov/SP800-90B_EntropyAssessment/blob/master/cpp/non_iid/compression_test.h
// The NIST implementation shown has several fancy optimizations that allow for significantly improved performance
// relative to the Python code in estimators.py
double G(double z, int d, long num_blocks){
	double Ai=0.0, Ai_comp=0.0;
	double firstSum=0.0, firstSum_comp=0.0;
	long v = num_blocks - d;
	double Ad1;

	long double Bi;
	long double Bterm;
	long double ai;
	long double aiScaled;
	bool underflowTruncate;

	assert(d>0);
	assert(num_blocks>d);

	//i=2
	Bterm = (1.0L-(long double)z);
	//Note: B_1 isn't needed, as a_1 = 0
	//B_2
	Bi = Bterm;

	//Calculate A_{d+1}
	for(int i=2; i<=d; i++) {
		//calculate the a_i term
		kahan_add(Ai, Ai_comp, log2l((long double)i)*Bi);

		//Calculate B_{i+1}
		Bi *= Bterm;
	}

	//Store A_{d+1}
	Ad1 = Ai;

	underflowTruncate = false;
	//Now calculate A_{num_blocks} and the sum of sums term (firstsum)
	for(long i=d+1; i<=num_blocks-1; i++) {
		//calculate the a_i term
		ai = log2l((long double)i)*Bi;

		//Calculate A_{i+1}
		kahan_add(Ai, Ai_comp, (double)ai);
		//Sum in A_{i+1} into the firstSum

		//Calculate the tail of the sum of sums term (firstsum)
		aiScaled = (long double)(num_blocks-i) * ai;
		if((double)aiScaled > 0.0) {
			kahan_add(firstSum, firstSum_comp, (double)aiScaled);
		} else {
			underflowTruncate = true;
			break;
		}

		//Calculate B_{i+1}
		Bi *= Bterm;
	}

	//Ai now contains A_{num_blocks} and firstsum contains the tail
	//finalize the calculation of firstsum
	kahan_add(firstSum, firstSum_comp, ((double)(num_blocks-d))*Ad1);

	//Calculate A_{num_blocks+1}
	if(!underflowTruncate) {
		ai = log2l((long double)num_blocks)*Bi;
		kahan_add(Ai, Ai_comp, (double)ai);
	}

	return 1/(double)v * z*(z*firstSum + (Ai - Ad1));
}

float compression_estimate(py::list samples, bool demo)
{
    int b = 6;
    int d = 1000;
    if (demo)
        d = 4;
    
    int L = samples.size();
    int v = int(std::floor(float(L)/float(b))) - d;

    std::vector<int> subset;
    int b_ = 0;
    int index = 0;
    for (int i = 0; i < L; i++)
    {
        int sample = samples[i].cast<int>();
        index |= sample << b_;
        b_++;
        if (b_ == b)
        {
            subset.push_back(index);
            index = 0;
            b_    = 0;
        }
    }

    std::map<int, int> dict;
    for (int i = 0; i < d; i++)
        dict[subset[i]] = i + 1;

    std::vector<int> D;
    D.reserve(v);
    for (int i = d; i < v + d; i++)
    {
        index = subset[i];
        if (dict[index] != 0)
            D[i-d] = i + 1 - dict[index];
        else
            D[i-d] = i + 1;
        dict[index] = i;
    }

    float c = 0.5907;
    float sample_mean = 0.0;
    float sample_std  = 0.0;
    for (int i = 0; i < v; i++)
    {
        sample_mean += std::log2(D[i]);
        sample_std  += pow(std::log2(D[i]), 2);
    }
    sample_mean /= v;
    sample_std  = c * sqrt(sample_std/(v-1) - pow(sample_mean, 2));
    float mean_lower_bound = sample_mean - 2.576 * sample_std/sqrt(v);

    const int MAX_ITERATIONS = 100;
    float p = (1.0 - pow(2.0, -b))/2;
    float q = 0.0;
    float upper_bound = 1.0;
    float lower_bound = pow(2.0, -b);
    float tolerance   = 0.0001;
    float estimate    = 0.0;
    for (int i = 0; i < MAX_ITERATIONS; i++)
    {
        q = (1 - p)/(pow(2.0, b) - 1);
        estimate = G(p, d, L/b) + (pow(2.0, b) - 1)*G(q, d, L/b);

        if (mean_lower_bound < estimate)
        {
            lower_bound = p;
            p = upper_bound - (upper_bound - p) / 2;
        }
        else if (mean_lower_bound > estimate)
        {
            upper_bound = p;
            p = (p - lower_bound) / 2 + lower_bound;
        }
        
        if (fabs(upper_bound - lower_bound) < tolerance)
            break;    
    }
    
    return -log2(p)/b;
}

float ttuple_estimate(py::list samples, bool demo)
{
    int cutoff = 35;
    if (demo)
        cutoff = 3;
    int L = samples.size();
    size_t t = 1;
    std::map<size_t, int> subset;
    std::vector<int> Q;
    while (true)
    {
        std::vector<uint64_t> temp;
        temp.reserve(t);
        for (size_t i = 0; i < L; i += 1)
        {
            if (i + t > L) break;

            for (size_t j = 0; j < t; j++)
                temp.push_back(samples[i + j].cast<uint64_t>());
            size_t hash = boost::hash_range(temp.begin(), temp.end());
            if (subset.find(hash) == subset.end())
                subset[hash] = 0;
            subset[hash] += 1;

            temp.clear();
        }
        
        int max = 0;
        for(auto it = subset.begin(); it != subset.end(); ++it)
        {
            if (it->second > max)
                max = it->second;
        }

        if (cutoff <= max)
        {
            Q.push_back(max);
            t += 1;
        }
        else
        {
            break;
        }
        subset.clear();
    }
    
    float p_max = 0.0;
    for (size_t i = 0; i < Q.size(); i++)
    {
        float P = float(Q[i])/float(L-(i+1)+1);
        float p_max_temp = pow(P, 1.0/float(i+1));
        if (p_max_temp > p_max)
            p_max = p_max_temp;
    }

    float p_u = p_max + 2.576*sqrt((p_max * (1.0 - p_max))/(L - 1));
    if (p_u > 1)
        p_u = 1;
    return -log2(p_u);
}

PYBIND11_MODULE(fast_estimators, m) {
    m.doc() = "pybind11 plugin implementation of NIST tests"; // optional module docstring

    m.def("compression_estimate", &compression_estimate, 
        "A function that computes the min entropy compression estimate.");

    m.def("ttuple_estimate", &ttuple_estimate,
        "A function that computes the min entropy ttuple estimate.");
}
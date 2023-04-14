import pandas as pd
import numpy as np
from sklearn.metrics import cohen_kappa_score
from math import prod

# Read Excel file
df = pd.read_excel('Data_Annotation_completed.xlsx')
lables = ['drink alcohol', 'dance', 'pee', 'Null', 'drink water', 'eat', 'leave']

result = []
Nikolaj = []
Luisa = []
Jean = []
Annotators = [Nikolaj, Luisa, Jean]

for i, (N,L,J) in enumerate(zip(df["Label Nikolaj"], df["Label Luisa"], df["Label Jean"])):
    if i in range(0,51) or i in range(140, 191) or i in range(338, 389): #filter for the agreed upon areas, where we all annotated
        if N == L and L == J and J != "nan": # check that the values have been annotated and are all equal
            result.append(1)
        else:
            result.append(0)
        # create list of annotations for each annotator
        Nikolaj.append(N)
        Luisa.append(L)
        Jean.append(J)

p0 = result.count(1)/len(result)

#accidental probabilities
pe = 0
for action in lables:
    prob = 1
    for annotator in Annotators:
        prob = prob * annotator.count(action)/len(result)
    pe += prob

kappa = (p0 - pe)/(1 - pe)
print("kappa: ", kappa)

#final result =  0.9027768548360302
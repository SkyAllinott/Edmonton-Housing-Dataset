import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
import xgboost as xgb
from matplotlib import pyplot
from sklearn.metrics import explained_variance_score


data = pd.read_csv('G:/My Drive/Python Projects/Edmonton Housing/Edmonton_Housing_2019.csv')
data.drop(['accountnumber', 'sassault', 'theftvehicle'], axis = 1, inplace= True)
data = pd.get_dummies(data, dtype = 'int8')
drop_indices = np.random.choice(data.index, 290000, replace = False)
data_subset = data.drop(drop_indices)

seed = 9
y = data_subset['realprice']
X = data_subset.drop(['realprice'], axis = 1)
train_features, test_features, train_labels, test_labels = train_test_split(X, y, test_size=0.3, random_state=seed)


iterationsTrees = 10  # input one higher than actual (3 is 2 iterations)
iterationsDepth = 4  # one higher than actual
stepTrees = 100
stepDepth = 10
errors_trees = np.zeros([(iterationsTrees-1)*(iterationsDepth-1), 3])

for trees in range(1, iterationsTrees):
    print('Completed ' + str(trees) + ' out of ' + str(iterationsTrees-1) + ' iterations.')
    for depth in range(1, iterationsDepth):
        boost = xgb.XGBRegressor(n_estimators=(stepTrees*trees), learning_rate=0.05, max_depth=(stepDepth*depth), n_jobs=-1, random_state=seed, base_score=0)
        boost.fit(train_features, train_labels)
        boost_predict = (boost.predict(test_features))
        errors_boost = (abs(boost_predict - test_labels))
        errors_trees[(trees*depth)-1, 0] = (round(np.mean(errors_boost), 2))
        errors_trees[(trees*depth)-1, 1] = trees*stepTrees
        errors_trees[(trees*depth)-1, 2] = depth*stepDepth

boost = xgb.XGBRegressor(n_estimators=500, learning_rate=0.05, max_depth=30, n_jobs=-1, random_state=seed, base_score=0)
boost.fit(train_features, train_labels)

importance = boost.feature_importances_
pyplot.bar(range(len(importance)), importance)
train_features.columns[[6, 74, 275]]

predictions = boost.predict(test_features)

print(explained_variance_score(predictions, test_labels))
# zoningA, structure size and crawford plains are the biggest factors.



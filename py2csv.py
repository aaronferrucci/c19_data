from raw_data import *

d = covid_test_data

# promote the index to a named column
d['date'] = d.index
# not interested in the 'Tested' columns
deletes = [x for x in d.columns if ' Tested' in x]
d = d.drop(columns=deletes)
d = d.melt(id_vars=['date'])

# the 'variable' column is a combination of two things: county name,
# positive/negative result. Tidy that.

# extract county names
county = d['variable']
county = [x.replace(' +Tests', '') for x in county]
county = [x.replace(' -Tests', '') for x in county]
d['county'] = county

# extract result
result = d['variable']
result = ['positive' if ' +Tests' in x else x for x in result]
result = ['negative' if ' -Tests' in x else x for x in result]
d['result'] = result

d['count'] = d['value'].astype('Int32')
d = d.drop(columns=['value', 'variable'])

filename = r'covid_test_data.csv'
print("writing reshaped covid_test_data to %s" % filename)
d.to_csv(filename, index=True, header=True)

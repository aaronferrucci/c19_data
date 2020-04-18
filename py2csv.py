from raw_data import *

filename = r'covid_case_data.csv'
print("writing covid_case_data to %s" % filename)
covid_case_data.to_csv(filename, index=True, header=True)

filename = r'covid_test_data.csv'
print("writing covid_test_data to %s" % filename)
covid_test_data.to_csv(filename, index=True, header=True)

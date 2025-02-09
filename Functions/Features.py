import numpy as np
import matplotlib.pyplot as plt
import csv
from scipy.stats import shapiro, permutation_test
import seaborn as sns
import pandas as pd


plt.rcParams['figure.figsize'] = [10, 8]

def _check_normality(data: np.ndarray, alpha:float = 0.05) -> bool:
    """
    Check if the given data follows a normal distribution
    using the Shapiro-Wilk test.

    Parameters:
        data (np.ndarray): Input data array.

    Returns:
        bool: True if data is normally distributed (p > 0.05), False otherwise.
    """
    _, p_value = shapiro(data)
    return p_value > alpha

class Features():

    upper_limit = 700
    lower_limit = 200

    def __init__(self, dataset:dict[str, list[dict]], only_physiological:bool = False):
        self.single_run_features:dict[str, dict[int, dict[str, float]]] = dict() # subject > run > feature > value
        self.single_run_features_by_type:dict[str, dict[int, dict[str, float]]] = dict() # subject > run > test_type > feature > value
        self.subject_features:dict[str, dict[str, float]] = dict() # subject > feature > value
        self.subject_features_by_type:dict[str, dict[int, dict[str, float]]] = dict() # subject > test_type > feature > value
        self.overall_features:dict[str, float] = dict() # feature > value
        self.overall_features_by_type:dict[int, dict[str, float]] = dict() # test_type > feature > value
        
        self.run_hetero_homo_ratio:dict[str, dict[str, float]] = dict() # subject > run > value
        self.subject_hetero_homo_ratio:dict[str, float] = dict() # subject > value
        self.overall_hetero_homo_ratio:float = 0

        self.dataset = dataset
        self.only_physiological = only_physiological

    def _get_full_rt(self, vb_index:list, mv_index:list, t:np.ndarray):
        return [t[abs(round(mv-vb))] if not vb == -1 and not mv == -1 else -1 for vb, mv in zip(vb_index, mv_index)]

    def calculate_single_run_features(self):
        # For each run, get all the RTs and features
        for subject in self.dataset:
            if subject not in self.single_run_features:
                self.single_run_features[subject] = dict()

            for run in self.dataset[subject]:
                if run not in self.single_run_features[subject]:
                    self.single_run_features[subject][run] = dict()

                # Simplify the variable names
                rt_acc = self.dataset[subject][run]['rt_acc'].flatten()
                if self.only_physiological:
                    rt_acc = rt_acc[(rt_acc > Features.lower_limit) & (rt_acc < Features.upper_limit)]

                if len(rt_acc) == 0:
                    rt_acc = np.array([np.nan])

                self.single_run_features[subject][run]['mean'] = np.mean(rt_acc)
                self.single_run_features[subject][run]['median'] = np.median(rt_acc)
                self.single_run_features[subject][run]['std'] = np.std(rt_acc)
                self.single_run_features[subject][run]['min'] = np.min(rt_acc)
                self.single_run_features[subject][run]['max'] = np.max(rt_acc)
                self.single_run_features[subject][run]['rt_acc'] = rt_acc

    def print_single_run_features(self):
        for subject in self.single_run_features:
            print(f'Subject: {subject}')
            for run in self.single_run_features[subject]:
                print(f'\tRun {run}:')
                for feature in self.single_run_features[subject][run]:
                    if feature == 'rt_acc':
                        continue
                    print(f'\t\t{feature}: {self.single_run_features[subject][run][feature]:.6g} ms')

    def calculate_single_run_features_by_type(self, accelerometer:bool = False):
        # For each run, get all the RTs and features
        for subject in self.dataset:
            if subject not in self.single_run_features_by_type:
                self.single_run_features_by_type[subject] = dict()
            if subject not in self.run_hetero_homo_ratio:
                self.run_hetero_homo_ratio[subject] = dict()
            rt_by_type:dict[int, np.ndarray] = dict()

            for run in self.dataset[subject]:
                # Calculate statistical features by test type for each run
                if run not in self.single_run_features_by_type[subject]:
                    self.single_run_features_by_type[subject][run] = dict()
                if run not in self.run_hetero_homo_ratio[subject]:
                    self.run_hetero_homo_ratio[subject][run] = dict()

                # Simplify the variable names
                acc_test_type = self.dataset[subject][run]['acc_test_type'].flatten()
                test_type = self.dataset[subject][run]['test_type'].flatten()
                rt_acc = self.dataset[subject][run]['rt_acc'].flatten()
                if self.only_physiological:
                    acc_test_type = acc_test_type[(rt_acc > Features.lower_limit) & (rt_acc < Features.upper_limit)]
                    rt_acc = rt_acc[(rt_acc > Features.lower_limit) & (rt_acc < Features.upper_limit)]

                for type in np.sort(np.unique(test_type[test_type > 0])):
                    if type not in rt_by_type:
                        rt_by_type[type] = np.array([])
                    if type not in self.single_run_features_by_type[subject][run]:
                        self.single_run_features_by_type[subject][run][type] = dict()

                    rt_by_type[type] = rt_acc[acc_test_type == type]

                    if len(rt_by_type[type]) == 0:
                        rt_by_type[type] = np.array([np.nan])
                    self.single_run_features_by_type[subject][run][type] = dict()
                    self.single_run_features_by_type[subject][run][type]['mean'] = np.mean(rt_by_type[type])
                    self.single_run_features_by_type[subject][run][type]['median'] = np.median(rt_by_type[type])
                    self.single_run_features_by_type[subject][run][type]['std'] = np.std(rt_by_type[type])
                    self.single_run_features_by_type[subject][run][type]['min'] = np.min(rt_by_type[type])
                    self.single_run_features_by_type[subject][run][type]['max'] = np.max(rt_by_type[type])
                    self.single_run_features_by_type[subject][run][type]['rt_acc'] = rt_by_type[type]

                    if len(rt_by_type[type]) > 3 and _check_normality(rt_by_type[type]):
                        self.single_run_features_by_type[subject][run][type]['normality'] = 'Yes'
                    else:
                        self.single_run_features_by_type[subject][run][type]['normality'] = 'No'

                hetero = rt_acc[np.logical_or(acc_test_type == 1, acc_test_type == 2)]
                homo = rt_acc[np.logical_or(acc_test_type == 3, acc_test_type == 4)]
                self.run_hetero_homo_ratio[subject][run] = np.mean(hetero) / np.mean(homo)

                # Get full rts from matlab
                if accelerometer == True:
                    vb_index = self.dataset[subject][run]['vb_index'].flatten()
                    mv_index = self.dataset[subject][run]['mv_index'].flatten()
                    t = self.dataset[subject][run]['t'].flatten()
                    self.single_run_features_by_type[subject][run]['RT'] = self._get_full_rt(vb_index, mv_index, t)
                    self.single_run_features_by_type[subject][run]['test_type'] = test_type
                else:
                    self.single_run_features_by_type[subject][run]['RT'] = self.dataset[subject][run]['all_rt_box']
                    self.single_run_features_by_type[subject][run]['test_type'] = test_type

    def get_single_run_features_by_type(self):
        return self.single_run_features_by_type

    def print_single_run_features_by_type(self):
        for subject in self.single_run_features_by_type:
            print(f'Subject: {subject}')
            for run in self.single_run_features_by_type[subject]:
                print(f'\tRun {run}:')
                for test_type in self.single_run_features_by_type[subject][run]:
                    if test_type == 'RT' or test_type == 'test_type':
                        continue
                    print(f'\t\tTest type {test_type}:')
                    for feature in self.single_run_features_by_type[subject][run][test_type]:
                        if feature == 'rt_acc':
                            continue
                        if feature == 'normality':
                            print(f'\t\t\t{feature}: {self.single_run_features_by_type[subject][run][test_type][feature]}')
                            continue
                        print(f'\t\t\t{feature}: {self.single_run_features_by_type[subject][run][test_type][feature]:.6g} ms')
                print(f'\t\tHeterotopic over homotopic ratio: {self.run_hetero_homo_ratio[subject][run]:.6g}')

    def calculate_subject_features(self):
        # For each subject, get all the RTs and features
        for subject in self.dataset:
            if subject not in self.subject_features:
                self.subject_features[subject] = dict()

            rt = np.array([])

            # Loop through the runs of each subject
            for run in self.dataset[subject]:
                # Simplify the variable names
                rt_acc = self.dataset[subject][run]['rt_acc'].flatten()
                if self.only_physiological:
                    rt_acc = rt_acc[(rt_acc > Features.lower_limit) & (rt_acc < Features.upper_limit)]

                rt = np.concatenate((rt, rt_acc), axis=None)

            if len(rt) == 0:
                rt = np.array([np.nan])

            # Calculate statistical features for each subject
            self.subject_features[subject]['mean'] = np.mean(rt)
            self.subject_features[subject]['median'] = np.median(rt)
            self.subject_features[subject]['std'] = np.std(rt)
            self.subject_features[subject]['min'] = np.min(rt)
            self.subject_features[subject]['max'] = np.max(rt)
            self.subject_features[subject]['rt_acc'] = rt

    def print_subject_features(self):
        for subject in self.subject_features:
            print(f'Subject: {subject}')
            for feature in self.subject_features[subject]:
                if feature == 'rt_acc':
                    continue
                print(f'\t{feature}: {self.subject_features[subject][feature]:.6g} ms')

    def calculate_subject_features_by_type(self, accelerometer:bool = False):
        # For each subject, get all the RTs and features
        for subject in self.dataset:
            if subject not in self.subject_features_by_type:
                self.subject_features_by_type[subject] = dict()
            if subject not in self.subject_hetero_homo_ratio:
                self.subject_hetero_homo_ratio[subject] = dict()

            rt_by_type:dict[int, np.ndarray] = dict()
            all_rt = np.array([])
            all_test_types = np.array([])
            # Loop through the runs of each subject
            for run in self.dataset[subject]:
                # Simplify the variable names
                acc_test_type = self.dataset[subject][run]['acc_test_type'].flatten()
                test_type = self.dataset[subject][run]['test_type'].flatten()
                rt_acc = self.dataset[subject][run]['rt_acc'].flatten()
                if self.only_physiological:
                    acc_test_type = acc_test_type[(rt_acc > Features.lower_limit) & (rt_acc < Features.upper_limit)]
                    rt_acc = rt_acc[(rt_acc > Features.lower_limit) & (rt_acc < Features.upper_limit)]

                # Loop through each test type and calculate the average reaction times
                for i in np.sort(np.unique(test_type[test_type > 0])):
                    if i not in rt_by_type:
                        rt_by_type[i] = np.array([])

                    rt_by_type[i] = np.concatenate((rt_by_type[i], rt_acc[acc_test_type == i]), axis=None)

                # Get full rts from matlab
                if accelerometer == True:
                    vb_index = self.dataset[subject][run]['vb_index'].flatten()
                    mv_index = self.dataset[subject][run]['mv_index'].flatten()
                    t = self.dataset[subject][run]['t'].flatten()

                    all_rt = np.concatenate((all_rt, self._get_full_rt(vb_index, mv_index, t)), axis=None)
                    all_test_types = np.concatenate((all_test_types, test_type), axis=None)
                else:
                    all_rt = np.concatenate((all_rt, self.dataset[subject][run]['all_rt_box']), axis=None)
                    all_test_types = np.concatenate((all_test_types, test_type), axis=None)

            self.subject_features_by_type[subject]['RT'] = all_rt
            self.subject_features_by_type[subject]['test_type'] = all_test_types

            # Calculate statistical features by test type for each subject
            for i in np.sort(np.unique(test_type[test_type > 0])):
                if i not in self.subject_features_by_type[subject]:
                    self.subject_features_by_type[subject][i] = dict()

                if len(rt_by_type[i]) == 0:
                    rt_by_type[i] = np.array([np.nan])
                self.subject_features_by_type[subject][i]['mean'] = np.mean(rt_by_type[i])
                self.subject_features_by_type[subject][i]['median'] = np.median(rt_by_type[i])
                self.subject_features_by_type[subject][i]['std'] = np.std(rt_by_type[i])
                self.subject_features_by_type[subject][i]['min'] = np.min(rt_by_type[i])
                self.subject_features_by_type[subject][i]['max'] = np.max(rt_by_type[i])
                self.subject_features_by_type[subject][i]['rt_acc'] = rt_by_type[i]

                if len(rt_by_type[i]) < 3:
                    self.subject_features_by_type[subject][i]['normality'] = 'Not enough data'
                elif _check_normality(rt_by_type[i]):
                    self.subject_features_by_type[subject][i]['normality'] = 'Yes'
                else:
                    self.subject_features_by_type[subject][i]['normality'] = 'No'

            hetero = np.concatenate((rt_by_type[1], rt_by_type[2]), axis=None)
            homo = np.concatenate((rt_by_type[3], rt_by_type[4]), axis=None)
            self.subject_hetero_homo_ratio[subject] = np.mean(hetero) / np.mean(homo)

    def get_subject_features_by_type(self):
        return self.subject_features_by_type

    def print_subject_features_by_type(self):
        for subject in self.subject_features_by_type:
            print(f'Subject: {subject}')
            for test_type in self.subject_features_by_type[subject]:
                if test_type == 'RT' or test_type == 'test_type':
                    continue
                print(f'\tTest type {test_type}:')
                for feature in self.subject_features_by_type[subject][test_type]:
                    if feature == 'rt_acc':
                        continue
                    if feature == 'normality':
                        print(f'\t\t{feature}: {self.subject_features_by_type[subject][test_type][feature]}')
                        continue
                    print(f'\t\t{feature}: {self.subject_features_by_type[subject][test_type][feature]:.6g} ms')
            print(f'\tHeterotopic over homotopic ratio: {self.subject_hetero_homo_ratio[subject]:.6g}')

    def calculate_overall_features(self):
        # Get all the RTs and features
        rt = np.array([])

        for subject in self.dataset:
            for run in self.dataset[subject]:
                # Simplify the variable names
                rt_acc = self.dataset[subject][run]['rt_acc'].flatten()
                if self.only_physiological:
                    rt_acc = rt_acc[(rt_acc > Features.lower_limit) & (rt_acc < Features.upper_limit)]

                rt = np.concatenate((rt, rt_acc), axis=None)

        if len(rt) == 0:
            rt = np.array(np.nan)
        # Calculate statistical features for all subjects
        self.overall_features['mean'] = np.mean(rt)
        self.overall_features['median'] = np.median(rt)
        self.overall_features['std'] = np.std(rt)
        self.overall_features['min'] = np.min(rt)
        self.overall_features['max'] = np.max(rt)
        self.overall_features['rt_acc'] = rt

    def print_overall_features(self):
        for feature in self.overall_features:
            if feature == 'rt_acc':
                continue
            print(f'{feature}: {self.overall_features[feature]:.6g} ms')
        print(' \n')

    def calculate_overall_features_by_type(self, accelerometer:bool = False):
        # Get all the RTs and features
        rt_by_type:dict[int, np.ndarray] = dict()

        all_rt = np.array([])
        all_test_types = np.array([])
        for subject in self.dataset:
            for run in self.dataset[subject]:
                # Simplify the variable names
                acc_test_type = self.dataset[subject][run]['acc_test_type'].flatten()
                test_type = self.dataset[subject][run]['test_type'].flatten()
                rt_acc = self.dataset[subject][run]['rt_acc'].flatten()
                if self.only_physiological:
                    acc_test_type = acc_test_type[(rt_acc > Features.lower_limit) & (rt_acc < Features.upper_limit)]
                    rt_acc = rt_acc[(rt_acc > Features.lower_limit) & (rt_acc < Features.upper_limit)]

                # Loop through each test type and calculate the average reaction times
                for i in np.sort(np.unique(test_type[test_type > 0])):
                    if i not in rt_by_type:
                        rt_by_type[i] = np.array([])

                    rt_by_type[i] = np.concatenate((rt_by_type[i], rt_acc[acc_test_type == i]), axis=None)

                # Get full rts from matlab
                if accelerometer == True:
                    vb_index = self.dataset[subject][run]['vb_index'].flatten()
                    mv_index = self.dataset[subject][run]['mv_index'].flatten()
                    t = self.dataset[subject][run]['t'].flatten()

                    all_rt = np.concatenate((all_rt, self._get_full_rt(vb_index, mv_index, t)), axis=None)
                    all_test_types = np.concatenate((all_test_types, test_type), axis=None)
                else:
                    all_rt = np.concatenate((all_rt, self.dataset[subject][run]['all_rt_box']), axis=None)
                    all_test_types = np.concatenate((all_test_types, test_type), axis=None)

        self.overall_features_by_type['RT'] = all_rt
        self.overall_features_by_type['test_type'] = all_test_types

        # Calculate statistical features by test type for all subjects
        for i in np.sort(np.unique(test_type[test_type > 0])):
            if i not in self.overall_features_by_type:
                self.overall_features_by_type[i] = dict()

            if len(rt_by_type[i]) == 0:
                rt_by_type[i] = np.array([np.nan])

            self.overall_features_by_type[i]['mean'] = np.mean(rt_by_type[i])
            self.overall_features_by_type[i]['median'] = np.median(rt_by_type[i])
            self.overall_features_by_type[i]['std'] = np.std(rt_by_type[i])
            self.overall_features_by_type[i]['min'] = np.min(rt_by_type[i])
            self.overall_features_by_type[i]['max'] = np.max(rt_by_type[i])
            self.overall_features_by_type[i]['rt_acc'] = rt_by_type[i]

            if _check_normality(rt_by_type[i]):
                self.overall_features_by_type[i]['normality'] = 'Yes'
            else:
                self.overall_features_by_type[i]['normality'] = 'No'

        hetero = np.concatenate((rt_by_type[1], rt_by_type[2]), axis=None)
        homo = np.concatenate((rt_by_type[3], rt_by_type[4]), axis=None)
        self.overall_hetero_homo_ratio = np.mean(hetero) / np.mean(homo)

    def get_overall_features_by_type(self):
        return self.overall_features_by_type

    def print_overall_features_by_type(self):
        for test_type in self.overall_features_by_type:
            if test_type == 'RT' or test_type == 'test_type':
                continue
            print(f'Test type {test_type}:')
            for feature in self.overall_features_by_type[test_type]:
                if feature == 'rt_acc':
                    continue
                if feature == 'normality':
                        print(f'\t{feature}: {self.overall_features_by_type[test_type][feature]}')
                        continue
                print(f'\t{feature}: {self.overall_features_by_type[test_type][feature]:.6g} ms')
        print(f'Heterotopic over homotopic ratio: {self.overall_hetero_homo_ratio:.6g}')

    def save_single_run_features(self, folder:str = './Export/'):
        # Save single run features
        path = folder + 'single_run_features.csv'
        with open(path, 'w', newline='', encoding='utf-8-sig') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['Subject', 'Run', 'Mean', 'Median', 'Standard Deviation', 'Minimum', 'Maximum'])
            for subject in self.single_run_features:
                for run in self.single_run_features[subject]:
                    writer.writerow([subject, run, self.single_run_features[subject][run]['mean'], self.single_run_features[subject][run]['median'], self.single_run_features[subject][run]['std'], self.single_run_features[subject][run]['min'], self.single_run_features[subject][run]['max']])
    
    def save_single_run_features_by_type(self, folder:str = './Export/'):
        # Save single run features by type
        path = folder + 'single_run_features_by_type.csv'
        with open(path, 'w', newline='', encoding='utf-8-sig') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['Subject', 'Run', 'Test Type', 'Mean', 'Median', 'Standard Deviation', 'Minimum', 'Maximum', 'Normality'])
            for subject in self.single_run_features_by_type:
                for run in self.single_run_features_by_type[subject]:
                    for test_type in self.single_run_features_by_type[subject][run]:
                        if test_type == 'RT' or test_type == 'test_type':
                            continue

                        writer.writerow([subject, run, test_type, self.single_run_features_by_type[subject][run][test_type]['mean'], self.single_run_features_by_type[subject][run][test_type]['median'], self.single_run_features_by_type[subject][run][test_type]['std'], self.single_run_features_by_type[subject][run][test_type]['min'], self.single_run_features_by_type[subject][run][test_type]['max'], self.single_run_features_by_type[subject][run][test_type]['normality']])

            writer.writerow([])

            writer.writerow(['Subject', 'Run', 'Heterotopic over homotopic ratio'])
            for subject in self.single_run_features_by_type:
                for run in self.single_run_features_by_type[subject]:
                    writer.writerow([subject, run, self.run_hetero_homo_ratio[subject][run]])
    
    def save_subject_features(self, folder:str = './Export/'):
        # Save subject features
        path = folder + 'subject_features.csv'
        with open(path, 'w', newline='', encoding='utf-8-sig') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['Subject', 'Mean', 'Median', 'Standard Deviation', 'Minimum', 'Maximum'])
            for subject in self.subject_features:
                writer.writerow([subject, self.subject_features[subject]['mean'], self.subject_features[subject]['median'], self.subject_features[subject]['std'], self.subject_features[subject]['min'], self.subject_features[subject]['max']])

    def save_subject_features_by_type(self, folder:str = './Export/'):
        # Save subject features by type
        path = folder + 'subject_features_by_type.csv'
        with open(path, 'w', newline='', encoding='utf-8-sig') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['Subject', 'Test Type', 'Mean', 'Median', 'Standard Deviation', 'Minimum', 'Maximum', 'Normality'])
            for subject in self.subject_features_by_type:
                for test_type in self.subject_features_by_type[subject]:
                    if test_type == 'RT' or test_type == 'test_type':
                        continue
                    writer.writerow([subject, test_type, self.subject_features_by_type[subject][test_type]['mean'], self.subject_features_by_type[subject][test_type]['median'], self.subject_features_by_type[subject][test_type]['std'], self.subject_features_by_type[subject][test_type]['min'], self.subject_features_by_type[subject][test_type]['max'], self.subject_features_by_type[subject][test_type]['normality']])

            writer.writerow([])
            
            writer.writerow(['Subject', 'Heterotopic over homotopic ratio'])
            for subject in self.single_run_features_by_type:
                writer.writerow([subject, self.subject_hetero_homo_ratio[subject]])

    def save_overall_features(self, folder:str = './Export/'):
        # Save overall features
        path = folder + 'overall_features.csv'
        with open(path, 'w', newline='', encoding='utf-8-sig') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['Mean', 'Median', 'Standard Deviation', 'Minimum', 'Maximum'])
            # print(self.overall_features.keys())
            writer.writerow([self.overall_features['mean'], self.overall_features['median'], self.overall_features['std'], self.overall_features['min'], self.overall_features['max']])

    def save_overall_features_by_type(self, folder:str = './Export/'):
        # Save overall features by type
        path = folder + 'overall_features_by_type.csv'
        with open(path, 'w', newline='', encoding='utf-8-sig') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['Test Type', 'Mean', 'Median', 'Standard Deviation', 'Minimum', 'Maximum', 'Normality'])
            for test_type in self.overall_features_by_type:
                if test_type == 'RT' or test_type == 'test_type':
                    continue
                writer.writerow([test_type, self.overall_features_by_type[test_type]['mean'], self.overall_features_by_type[test_type]['median'], self.overall_features_by_type[test_type]['std'], self.overall_features_by_type[test_type]['min'], self.overall_features_by_type[test_type]['max'], self.overall_features_by_type[test_type]['normality']])

            writer.writerow([])
            
            writer.writerow(['Heterotopic over homotopic ratio'])
            writer.writerow([self.overall_hetero_homo_ratio])

    def save_all_to_csv(self, folder:str = './Export/'):
        self.save_single_run_features(folder)
        self.save_single_run_features_by_type(folder)
        self.save_subject_features(folder)
        self.save_subject_features_by_type(folder)
        self.save_overall_features(folder)
        self.save_overall_features_by_type(folder)

class FeaturePlotter():
    def __init__(self, features:Features):
        self.features = features

    def plot_single_run_features_by_type(self):
        features = self.features.single_run_features_by_type
        
        for subject in features:
            for run in features[subject]:
                print(f'Subject: {subject}, Run: {run}')
                plt.figure()

                fig, axs = plt.subplots(2, 2)

                for i, ax in enumerate(axs.flatten()):
                    test_type = i + 1
                    if test_type not in features[subject][run]:
                        continue
                    rt_acc = features[subject][run][test_type]['rt_acc']
                    x_axis = np.arange(len(rt_acc))

                    # Perform linear regression
                    slope, intercept = np.polyfit(x_axis, rt_acc, 1)
                    regression_line = slope * x_axis + intercept

                    ax.scatter(x_axis, rt_acc, label='Data', marker = 's', s=10)
                    ax.plot(x_axis, regression_line, color = 'red', linestyle = '--', label = 'Linear regression')
                    ax.plot(x_axis, np.ones_like(x_axis) * np.mean(rt_acc), color = 'orange', linestyle = '--', label = 'Mean')

                    ax.set_title(f'Test Type {test_type}')
                    ax.set_xlabel('Data #')
                    ax.set_ylabel('RT (ms)')
                    ax.grid()
                    ax.legend()
                
                plt.tight_layout()
                plt.show()

    def plot_subject_features_by_type(self):
        features = self.features.subject_features_by_type
        
        for subject in features:
            print(f'Subject: {subject}')
            plt.figure()

            fig, axs = plt.subplots(2, 2)

            for i, ax in enumerate(axs.flatten()):
                test_type = i + 1
                if test_type not in features[subject]:
                    continue
                rt_acc = features[subject][test_type]['rt_acc']
                x_axis = np.arange(len(rt_acc))

                # Perform linear regression
                slope, intercept = np.polyfit(x_axis, rt_acc, 1)
                regression_line = slope * x_axis + intercept

                ax.scatter(x_axis, rt_acc, label='Data', marker = 's', s=10)
                ax.plot(x_axis, regression_line, color = 'red', linestyle = '--', label = 'Linear regression')
                ax.plot(x_axis, np.ones_like(x_axis) * np.mean(rt_acc), color = 'orange', linestyle = '--', label = 'Mean')

                ax.set_title(f'Test Type {test_type}')
                ax.set_xlabel('Data #')
                ax.set_ylabel('RT (ms)')
                ax.grid()
                ax.legend()
            
            plt.tight_layout()
            plt.show()

    def plot_overall_features_by_type(self):
        features = self.features.overall_features_by_type
        
        print('Overall features by type')
        plt.figure()

        fig, axs = plt.subplots(2, 2)

        for i, ax in enumerate(axs.flatten()):
            test_type = i + 1
            if test_type not in features:
                continue
            rt_acc = features[test_type]['rt_acc']
            x_axis = np.arange(len(rt_acc))

            # Perform linear regression
            slope, intercept = np.polyfit(x_axis, rt_acc, 1)
            regression_line = slope * x_axis + intercept

            ax.scatter(x_axis, rt_acc, label='Data', marker = 's', s=10)
            ax.plot(x_axis, regression_line, color = 'red', linestyle = '--', label = 'Linear regression')
            ax.plot(x_axis, np.ones_like(x_axis) * np.mean(rt_acc), color = 'orange', linestyle = '--', label = 'Mean')

            ax.set_title(f'Test Type {test_type}')
            ax.set_xlabel('Data #')
            ax.set_ylabel('RT (ms)')
            ax.grid()
            ax.legend()
        
        plt.tight_layout()
        plt.show()

class FeatureComparator():
    def __init__(self, feature_acc:Features, feature_box:Features, features_to_compare:list[str] = ['mean', 'median', 'std', 'min', 'max']):
        self.feature_acc = feature_acc
        self.feature_box = feature_box
        self.features_to_compare = features_to_compare

        self.test_types = [key for key in self.feature_box.overall_features_by_type if key != 'test_type' and key != 'RT']

        # Get common subjects and runs between the two datasets
        self.common_subjects = list(set(self.feature_acc.dataset.keys()) & set(self.feature_box.dataset.keys()))
        self.common_runs = dict()
        for subject in self.common_subjects:
            self.common_runs[subject] = list(set(self.feature_acc.dataset[subject].keys()) & set(self.feature_box.dataset[subject].keys()))

    def compare_single_run_features_by_type(self):
        for subject in self.common_subjects:
            print(f'Subject: {subject}')
            for run in self.common_runs[subject]:
                print(f'\tRun {run}:')
                for test_type in self.feature_acc.single_run_features_by_type[subject][run]:
                    print(f'\t\tTest type {test_type}:')
                    for feature in self.features_to_compare:
                        if feature not in self.feature_acc.single_run_features_by_type[subject][run][test_type]:
                            continue
                        print(f'\t\t\t{feature}: {self.feature_acc.single_run_features_by_type[subject][run][test_type][feature]:.6g} (acc) ms vs {self.feature_box.single_run_features_by_type[subject][run][test_type][feature]:.6g} (box) ms')
                        if feature == 'mean' or feature == 'median':
                            print(f'\t\t\t\tdifference: {self._compute_difference(self.feature_acc.single_run_features_by_type[subject][run][test_type][feature], self.feature_box.single_run_features_by_type[subject][run][test_type][feature]):.6g} ms, Percentage difference: {self._compute_percentage_difference(self.feature_acc.single_run_features_by_type[subject][run][test_type][feature], self.feature_box.single_run_features_by_type[subject][run][test_type][feature]):.6g}%')

    def compare_subject_features_by_type(self):
        for subject in self.common_subjects:
            print(f'Subject: {subject}')
            for test_type in self.feature_acc.subject_features_by_type[subject]:
                print(f'\tTest type {test_type}:')
                for feature in self.features_to_compare:
                    if feature not in self.feature_acc.subject_features_by_type[subject][test_type]:
                        continue
                    print(f'\t\t{feature}: {self.feature_acc.subject_features_by_type[subject][test_type][feature]:.6g} (acc) ms vs {self.feature_box.subject_features_by_type[subject][test_type][feature]:.6g} (box) ms')
                    if feature == 'mean' or feature == 'median':
                        print(f'\t\t\tdifference: {self._compute_difference(self.feature_acc.subject_features_by_type[subject][test_type][feature], self.feature_box.subject_features_by_type[subject][test_type][feature]):.6g} ms, Percentage difference: {self._compute_percentage_difference(self.feature_acc.subject_features_by_type[subject][test_type][feature], self.feature_box.subject_features_by_type[subject][test_type][feature]):.6g}%')

    def compare_overall_features_by_type(self):
        print('Overall features by type')
        for test_type in self.feature_acc.overall_features_by_type:
            print(f'\tTest type {test_type}:')
            for feature in self.features_to_compare:
                if feature not in self.feature_acc.overall_features_by_type[test_type]:
                    continue
                print(f'\t\t{feature}: {self.feature_acc.overall_features_by_type[test_type][feature]:.6g} (acc) ms vs {self.feature_box.overall_features_by_type[test_type][feature]:.6g} (box) ms')
                if feature == 'mean' or feature == 'median':
                    print(f'\t\t\tdifference: {self._compute_difference(self.feature_acc.overall_features_by_type[test_type][feature], self.feature_box.overall_features_by_type[test_type][feature]):.6g} ms, Percentage difference: {self._compute_percentage_difference(self.feature_acc.overall_features_by_type[test_type][feature], self.feature_box.overall_features_by_type[test_type][feature]):.6g}%')

    def _compute_difference(self, value_1:float, value_2:float) -> float:
        return abs(value_1 - value_2)
    
    def _compute_percentage_difference(self, value_1:float, value_2:float) -> float:
        return self._compute_difference(value_1=value_1, value_2=value_2) / value_2 * 100
    
    def _calculate_correlation(self, data_1, data_2):
        # Determine the maximum length
        max_length = max(len(data_1), len(data_2))

        # Pad both lines to the same length
        data_1_padded = np.pad(data_1, (0, max_length - len(data_1)), constant_values=np.nan)
        data_2_padded = np.pad(data_2, (0, max_length - len(data_2)), constant_values=np.nan)

        # Fit polynomials to the padded data (ignoring NaN during fit) >> fit not working

        valid_mask = ~np.isnan(data_1_padded) & ~np.isnan(data_2_padded)
        correlation_original = np.corrcoef(data_1_padded[valid_mask], data_2_padded[valid_mask])[0, 1]

        return correlation_original
    
    def _iterate_test_types(self, data_1, data_2, all_test_types):
        # Substitute -1 with NaN
        data_1 = [el if el != -1 else np.nan for el in data_1]
        data_2 = [el if el != -1 else np.nan for el in data_2]

        for test_type in self.test_types:
            data_1_tt = [el for tt,el in zip(all_test_types, data_1) if tt == test_type and not np.isnan(el)]
            data_2_tt = [el for tt,el in zip(all_test_types, data_2) if tt == test_type and not np.isnan(el)]

            correlation = self._calculate_correlation(data_1_tt, data_2_tt)
            print(f'\tCorrelation for test type {test_type}: {correlation:.6g}')

    def calculate_correlation_per_subject(self)->None:
        for subject in self.common_subjects:
            print(f"Subject {subject}")

            data_1 = self.feature_acc.subject_features_by_type[subject]['RT']
            data_2 = self.feature_box.subject_features_by_type[subject]['RT']
            all_test_types = self.feature_acc.subject_features_by_type[subject]['test_type']

            self._iterate_test_types(data_1, data_2, all_test_types)

    def calculate_correlation_per_run(self)->None:
        for subject in self.common_subjects:
            print(f"Subject {subject}")
            for run in self.common_runs[subject]:
                print(f"\tRun {run}")

                data_1 = self.feature_acc.single_run_features_by_type[subject][run]['RT']
                data_2 = self.feature_box.single_run_features_by_type[subject][run]['RT']
                all_test_types = self.feature_acc.subject_features_by_type[subject]['test_type']

                self._iterate_test_types(data_1, data_2, all_test_types)

    def _do_permutation_test(self, data_1, data_2, n_permutations, test_type, avg_r, avg_p):
        def correlation_statistic(x, y):
                    return np.corrcoef(x, y)[0, 1]
        # Perform the permutation test
        result = permutation_test(
            (data_1, data_2),  # Paired data
            correlation_statistic,               # Statistic function
            n_resamples=n_permutations,          # Number of permutations
            alternative='two-sided'              # Test for positive or negative correlation
        )

        # Extract observed correlation and p-value
        observed_correlation = result.statistic
        p_value = result.pvalue

        avg_r.append(observed_correlation)
        avg_p.append(p_value)

        if p_value < 0.05:
            print(f"\tTest type {test_type}: |r| = {observed_correlation:.3f} - n = {len(data_1)} - p = {p_value:.6f} > The trends are significantly correlated.")
        else:
            print(f"\tTest type {test_type}: |r| = {observed_correlation:.3f} - {len(data_1)} - p = {p_value:.6f} > The trends are not significantly correlated.")

    def _iterate_test_type_permutation(self, rt_acc, rt_box, n_permutations, all_test_types, avg_r, avg_p):
        for test_type in self.test_types:
                # Remove NaN values to handle missing data keeping it paired
                filtered_data = [
                    (acc, box, tt) 
                    for (acc, box, tt) in zip(rt_acc, rt_box, all_test_types) 
                    if not np.isnan(acc) and not np.isnan(box) and tt == test_type
                ]
                if not filtered_data:
                    rt_acc_nones = [el for el, tt in zip(rt_acc, all_test_types) if np.isnan(el) and tt == test_type]
                    rt_box_nones = [el for el, tt in zip(rt_box, all_test_types) if np.isnan(el) and tt == test_type]
                    print(f"\tTest type {test_type}: No data for this test type. Not found: {len(rt_acc_nones)} acc - {len(rt_box_nones)} box")
                    continue

                filtered_rt_acc, filtered_rt_box, _ = zip(*filtered_data)

                self._do_permutation_test(filtered_rt_acc, filtered_rt_box, n_permutations, test_type, avg_r, avg_p)

    def subject_permuations(self, n_permutations):
        avg_r = []
        avg_p = []
        for subject in self.common_subjects:
            print(f"Subject {subject}")

            rt_acc = self.feature_acc.subject_features_by_type[subject]['RT']
            rt_box = self.feature_box.subject_features_by_type[subject]['RT']
            test_types = self.feature_acc.subject_features_by_type[subject]['test_type']

            # Substitute -1 with NaN
            rt_acc = [el if el != -1 else np.nan for el in rt_acc]
            rt_box = [el if el != -1 else np.nan for el in rt_box]
            
            self._iterate_test_type_permutation(rt_acc, rt_box, n_permutations, test_types, avg_r, avg_p)

        return avg_r, avg_p

    def run_permutations(self, n_permutations):
        avg_r = []
        avg_p = []
        for subject in self.common_subjects:
            print(f"Subject {subject}")
            for run in self.common_runs[subject]:
                print(f"\tRun {run}")

                rt_acc = self.feature_acc.single_run_features_by_type[subject][run]['RT']
                rt_box = self.feature_box.single_run_features_by_type[subject][run]['RT']
                test_types = self.feature_acc.single_run_features_by_type[subject][run]['test_type']

                # Substitute -1 with NaN
                rt_acc = [el if el != -1 else np.nan for el in rt_acc]
                rt_box = [el if el != -1 else np.nan for el in rt_box]
                
                self._iterate_test_type_permutation(rt_acc, rt_box, n_permutations, test_types, avg_r, avg_p)

        return avg_r, avg_p
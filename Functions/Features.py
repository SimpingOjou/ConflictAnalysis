import numpy as np
import matplotlib.pyplot as plt
import csv
from scipy.stats import shapiro
import seaborn as sns
import pandas as pd

plt.rcParams['figure.figsize'] = [10, 8]

def _check_normality(data: np.ndarray) -> bool:
    _, p_value = shapiro(data)
    return p_value > 0.05

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

    def calculate_single_run_features_by_type(self):
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

                for type in np.sort(np.unique(test_type)):
                    if type not in rt_by_type:
                        rt_by_type[type] = np.array([])
                    if type not in self.single_run_features_by_type[subject][run]:
                        self.single_run_features_by_type[subject][run][type] = dict()

                    rt_by_type[type] = rt_acc[acc_test_type == type]

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

    def print_single_run_features_by_type(self):
        for subject in self.single_run_features_by_type:
            print(f'Subject: {subject}')
            for run in self.single_run_features_by_type[subject]:
                print(f'\tRun {run}:')
                for test_type in self.single_run_features_by_type[subject][run]:
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

    def calculate_subject_features_by_type(self):
        # For each subject, get all the RTs and features
        for subject in self.dataset:
            if subject not in self.subject_features_by_type:
                self.subject_features_by_type[subject] = dict()
            if subject not in self.subject_hetero_homo_ratio:
                self.subject_hetero_homo_ratio[subject] = dict()

            rt_by_type:dict[int, np.ndarray] = dict()

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
                for i in np.sort(np.unique(test_type)):
                    if i not in rt_by_type:
                        rt_by_type[i] = np.array([])

                    rt_by_type[i] = np.concatenate((rt_by_type[i], rt_acc[acc_test_type == i]), axis=None)

            # Calculate statistical features by test type for each subject
            for i in np.sort(np.unique(test_type)):
                if i not in self.subject_features_by_type[subject]:
                    self.subject_features_by_type[subject][i] = dict()

                self.subject_features_by_type[subject][i]['mean'] = np.mean(rt_by_type[i])
                self.subject_features_by_type[subject][i]['median'] = np.median(rt_by_type[i])
                self.subject_features_by_type[subject][i]['std'] = np.std(rt_by_type[i])
                self.subject_features_by_type[subject][i]['min'] = np.min(rt_by_type[i])
                self.subject_features_by_type[subject][i]['max'] = np.max(rt_by_type[i])
                self.subject_features_by_type[subject][i]['rt_acc'] = rt_by_type[i]

                if _check_normality(rt_by_type[i]):
                    self.subject_features_by_type[subject][i]['normality'] = 'Yes'
                else:
                    self.subject_features_by_type[subject][i]['normality'] = 'No'

            hetero = np.concatenate((rt_by_type[1], rt_by_type[2]), axis=None)
            homo = np.concatenate((rt_by_type[3], rt_by_type[4]), axis=None)
            self.subject_hetero_homo_ratio[subject] = np.mean(hetero) / np.mean(homo)

    def print_subject_features_by_type(self):
        for subject in self.subject_features_by_type:
            print(f'Subject: {subject}')
            for test_type in self.subject_features_by_type[subject]:
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

    def calculate_overall_features_by_type(self):
        # Get all the RTs and features
        rt_by_type:dict[int, np.ndarray] = dict()

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
                for i in np.sort(np.unique(test_type)):
                    if i not in rt_by_type:
                        rt_by_type[i] = np.array([])

                    rt_by_type[i] = np.concatenate((rt_by_type[i], rt_acc[acc_test_type == i]), axis=None)

        # Calculate statistical features by test type for all subjects
        for i in np.sort(np.unique(test_type)):
            if i not in self.overall_features_by_type:
                self.overall_features_by_type[i] = dict()

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

    def print_overall_features_by_type(self):
        for test_type in self.overall_features_by_type:
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
                        writer.writerow([subject, run, test_type, self.single_run_features_by_type[subject][run][test_type]['mean'], self.single_run_features_by_type[subject][run][test_type]['median'], self.single_run_features_by_type[subject][run][test_type]['std'], self.single_run_features_by_type[subject][run][test_type]['min'], self.single_run_features_by_type[subject][run][test_type]['max'], self.single_run_features_by_type[subject][run][test_type]['normality']])

            writer.writerow([])

            writer.writerow(['Subject', 'Run', 'Heterotopic over homotopic ratio'])
            for subject in self.single_run_features_by_type:
                for run in self.single_run_features_by_type[subject]:
                    writer.writerow([subject, run, self.run_hetero_homo_ratio[subject][run]])

        # TODO: Add ratio and distribution feature in csv
    
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
            writer.writerow([self.overall_features['mean'], self.overall_features['median'], self.overall_features['std'], self.overall_features['min'], self.overall_features['max']])

    def save_overall_features_by_type(self, folder:str = './Export/'):
        # Save overall features by type
        path = folder + 'overall_features_by_type.csv'
        with open(path, 'w', newline='', encoding='utf-8-sig') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['Test Type', 'Mean', 'Median', 'Standard Deviation', 'Minimum', 'Maximum', 'Normality'])
            for test_type in self.overall_features_by_type:
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
    def __init__(self, feature_1:Features, feature_2:Features, features_to_compare:list[str] = ['mean', 'median', 'std', 'min', 'max']):
        self.feature_1 = feature_1
        self.feature_2 = feature_2
        self.features_to_compare = features_to_compare

        # Get common subjects and runs between the two datasets
        self.common_subjects = list(set(self.feature_1.dataset.keys()) & set(self.feature_2.dataset.keys()))
        self.common_runs = dict()
        for subject in self.common_subjects:
            self.common_runs[subject] = list(set(self.feature_1.dataset[subject].keys()) & set(self.feature_2.dataset[subject].keys()))

    def compare_single_run_features_by_type(self):
        for subject in self.common_subjects:
            print(f'Subject: {subject}')
            for run in self.common_runs[subject]:
                print(f'\tRun {run}:')
                for test_type in self.feature_1.single_run_features_by_type[subject][run]:
                    print(f'\t\tTest type {test_type}:')
                    for feature in self.features_to_compare:
                        if feature not in self.feature_1.single_run_features_by_type[subject][run][test_type]:
                            continue
                        print(f'\t\t\t{feature}: {self.feature_1.single_run_features_by_type[subject][run][test_type][feature]:.6g} (acc) ms vs {self.feature_2.single_run_features_by_type[subject][run][test_type][feature]:.6g} (box) ms')
                        if feature == 'mean' or feature == 'median':
                            print(f'\t\t\t\tdifference: {self._compute_difference(self.feature_1.single_run_features_by_type[subject][run][test_type][feature], self.feature_2.single_run_features_by_type[subject][run][test_type][feature]):.6g} ms, Percentage difference: {self._compute_percentage_difference(self.feature_1.single_run_features_by_type[subject][run][test_type][feature], self.feature_2.single_run_features_by_type[subject][run][test_type][feature]):.6g}%')

    def compare_subject_features_by_type(self):
        for subject in self.common_subjects:
            print(f'Subject: {subject}')
            for test_type in self.feature_1.subject_features_by_type[subject]:
                print(f'\tTest type {test_type}:')
                for feature in self.features_to_compare:
                    if feature not in self.feature_1.subject_features_by_type[subject][test_type]:
                        continue
                    print(f'\t\t{feature}: {self.feature_1.subject_features_by_type[subject][test_type][feature]:.6g} (acc) ms vs {self.feature_2.subject_features_by_type[subject][test_type][feature]:.6g} (box) ms')
                    if feature == 'mean' or feature == 'median':
                        print(f'\t\t\tdifference: {self._compute_difference(self.feature_1.subject_features_by_type[subject][test_type][feature], self.feature_2.subject_features_by_type[subject][test_type][feature]):.6g} ms, Percentage difference: {self._compute_percentage_difference(self.feature_1.subject_features_by_type[subject][test_type][feature], self.feature_2.subject_features_by_type[subject][test_type][feature]):.6g}%')

    def compare_overall_features_by_type(self):
        print('Overall features by type')
        for test_type in self.feature_1.overall_features_by_type:
            print(f'\tTest type {test_type}:')
            for feature in self.features_to_compare:
                if feature not in self.feature_1.overall_features_by_type[test_type]:
                    continue
                print(f'\t\t{feature}: {self.feature_1.overall_features_by_type[test_type][feature]:.6g} (acc) ms vs {self.feature_2.overall_features_by_type[test_type][feature]:.6g} (box) ms')
                if feature == 'mean' or feature == 'median':
                    print(f'\t\t\tdifference: {self._compute_difference(self.feature_1.overall_features_by_type[test_type][feature], self.feature_2.overall_features_by_type[test_type][feature]):.6g} ms, Percentage difference: {self._compute_percentage_difference(self.feature_1.overall_features_by_type[test_type][feature], self.feature_2.overall_features_by_type[test_type][feature]):.6g}%')

    def _compute_difference(self, value_1:float, value_2:float) -> float:
        return abs(value_1 - value_2)
    
    def _compute_percentage_difference(self, value_1:float, value_2:float) -> float:
        return self._compute_difference(value_1=value_1, value_2=value_2) / value_2 * 100
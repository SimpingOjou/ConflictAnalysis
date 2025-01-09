import numpy as np
import csv

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

    def print_single_run_features(self):
        for subject in self.single_run_features:
            print(f'Subject: {subject}')
            for run in self.single_run_features[subject]:
                print(f'\tRun {run}:')
                for feature in self.single_run_features[subject][run]:
                    print(f'\t\t{feature}: {self.single_run_features[subject][run][feature]:.6g} ms')

    def calculate_single_run_features_by_type(self):
        # For each run, get all the RTs and features
        for subject in self.dataset:
            if subject not in self.single_run_features_by_type:
                    self.single_run_features_by_type[subject] = dict()
            rt_by_type:dict[int, np.ndarray] = dict()

            for run in self.dataset[subject]:
                # Simplify the variable names
                acc_test_type = self.dataset[subject][run]['acc_test_type'].flatten()
                test_type = self.dataset[subject][run]['test_type'].flatten()
                rt_acc = self.dataset[subject][run]['rt_acc'].flatten()
                if self.only_physiological:
                    acc_test_type = acc_test_type[(rt_acc > Features.lower_limit) & (rt_acc < Features.upper_limit)]
                    rt_acc = rt_acc[(rt_acc > Features.lower_limit) & (rt_acc < Features.upper_limit)]

                # Calculate statistical features by test type for each run
                if run not in self.single_run_features_by_type[subject]:
                    self.single_run_features_by_type[subject][run] = dict()

                for type in range(1, len(np.unique(test_type))):
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

    def print_single_run_features_by_type(self):
        for subject in self.single_run_features_by_type:
            print(f'Subject: {subject}')
            for run in self.single_run_features_by_type[subject]:
                print(f'\tRun {run}:')
                for test_type in self.single_run_features_by_type[subject][run]:
                    print(f'\t\tTest type {test_type}:')
                    for feature in self.single_run_features_by_type[subject][run][test_type]:
                        print(f'\t\t\t{feature}: {self.single_run_features_by_type[subject][run][test_type][feature]:.6g} ms')

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

    def print_subject_features(self):
        for subject in self.subject_features:
            print(f'Subject: {subject}')
            for feature in self.subject_features[subject]:
                print(f'\t{feature}: {self.subject_features[subject][feature]:.6g} ms')

    def calculate_subject_features_by_type(self):
        # For each subject, get all the RTs and features
        for subject in self.dataset:
            if subject not in self.subject_features_by_type:
                self.subject_features_by_type[subject] = dict()

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
                for i in range(1, len(np.unique(test_type))):
                    if i not in rt_by_type:
                        rt_by_type[i] = np.array([])

                    rt_by_type[i] = np.concatenate((rt_by_type[i], rt_acc[acc_test_type == i]), axis=None)

            # Calculate statistical features by test type for each subject
            for i in range(1, len(np.unique(test_type))):
                if i not in self.subject_features_by_type[subject]:
                    self.subject_features_by_type[subject][i] = dict()

                self.subject_features_by_type[subject][i]['mean'] = np.mean(rt_by_type[i])
                self.subject_features_by_type[subject][i]['median'] = np.median(rt_by_type[i])
                self.subject_features_by_type[subject][i]['std'] = np.std(rt_by_type[i])
                self.subject_features_by_type[subject][i]['min'] = np.min(rt_by_type[i])
                self.subject_features_by_type[subject][i]['max'] = np.max(rt_by_type[i])

    def print_subject_features_by_type(self):
        for subject in self.subject_features_by_type:
            print(f'Subject: {subject}')
            for test_type in self.subject_features_by_type[subject]:
                print(f'\tTest type {test_type}:')
                for feature in self.subject_features_by_type[subject][test_type]:
                    print(f'\t\t{feature}: {self.subject_features_by_type[subject][test_type][feature]:.6g} ms')

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

    def print_overall_features(self):
        for feature in self.overall_features:
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
                for i in range(1, len(np.unique(test_type))):
                    if i not in rt_by_type:
                        rt_by_type[i] = np.array([])

                    rt_by_type[i] = np.concatenate((rt_by_type[i], rt_acc[acc_test_type == i]), axis=None)

        # Calculate statistical features by test type for all subjects
        for i in range(1, len(np.unique(test_type))):
            if i not in self.overall_features_by_type:
                self.overall_features_by_type[i] = dict()

            self.overall_features_by_type[i]['mean'] = np.mean(rt_by_type[i])
            self.overall_features_by_type[i]['median'] = np.median(rt_by_type[i])
            self.overall_features_by_type[i]['std'] = np.std(rt_by_type[i])
            self.overall_features_by_type[i]['min'] = np.min(rt_by_type[i])
            self.overall_features_by_type[i]['max'] = np.max(rt_by_type[i])

    def print_overall_features_by_type(self):
        for test_type in self.overall_features_by_type:
            print(f'Test type {test_type}:')
            for feature in self.overall_features_by_type[test_type]:
                print(f'\t{feature}: {self.overall_features_by_type[test_type][feature]:.6g} ms')

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
            writer.writerow(['Subject', 'Run', 'Test Type', 'Mean', 'Median', 'Standard Deviation', 'Minimum', 'Maximum'])
            for subject in self.single_run_features_by_type:
                for run in self.single_run_features_by_type[subject]:
                    for test_type in self.single_run_features_by_type[subject][run]:
                        writer.writerow([subject, run, test_type, self.single_run_features_by_type[subject][run][test_type]['mean'], self.single_run_features_by_type[subject][run][test_type]['median'], self.single_run_features_by_type[subject][run][test_type]['std'], self.single_run_features_by_type[subject][run][test_type]['min'], self.single_run_features_by_type[subject][run][test_type]['max']])
    
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
            writer.writerow(['Subject', 'Test Type', 'Mean', 'Median', 'Standard Deviation', 'Minimum', 'Maximum'])
            for subject in self.subject_features_by_type:
                for test_type in self.subject_features_by_type[subject]:
                    writer.writerow([subject, test_type, self.subject_features_by_type[subject][test_type]['mean'], self.subject_features_by_type[subject][test_type]['median'], self.subject_features_by_type[subject][test_type]['std'], self.subject_features_by_type[subject][test_type]['min'], self.subject_features_by_type[subject][test_type]['max']])

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
            writer.writerow(['Test Type', 'Mean', 'Median', 'Standard Deviation', 'Minimum', 'Maximum'])
            for test_type in self.overall_features_by_type:
                writer.writerow([test_type, self.overall_features_by_type[test_type]['mean'], self.overall_features_by_type[test_type]['median'], self.overall_features_by_type[test_type]['std'], self.overall_features_by_type[test_type]['min'], self.overall_features_by_type[test_type]['max']])

    def save_all_to_csv(self, folder:str = './Export/'):
        self.save_single_run_features(folder)
        self.save_single_run_features_by_type(folder)
        self.save_subject_features(folder)
        self.save_subject_features_by_type(folder)
        self.save_overall_features(folder)
        self.save_overall_features_by_type(folder)
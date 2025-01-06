import numpy as np

class Features():
    def __init__(self, dataset:dict[str, list[dict]]):
        self.single_run_features:dict[str, dict[int, dict[str, float]]] = dict() # subject > run > feature > value
        self.single_run_features_by_type:dict[str, dict[int, dict[str, float]]] = dict() # subject > run > test_type > feature > value
        self.subject_features:dict[str, dict[str, float]] = dict() # subject > feature > value
        self.subject_features_by_type:dict[str, dict[int, dict[str, float]]] = dict() # subject > test_type > feature > value
        self.overall_features:dict[str, float] = dict() # feature > value
        self.overall_features_by_type:dict[int, dict[str, float]] = dict() # test_type > feature > value
        
        self.dataset = dataset

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
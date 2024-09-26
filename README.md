# EMG_Analysis

The objective of this project is to analyze and correlate different kinds of data to look for a quantification of task conflict in a patient.

# Introduction

Cognitive control is defined as the set of abilities that allow for the effortful application and maintenance of goal-directed behaviors. Task conflict emerges when stimulus-driven behaviors are incongruent with current goals, necessitating the activation of a task control mechanism.

An example where task conflict can be seen is the Stroop Task, where participants name the ink color of words while ignoring the word itself. This task creates conflict between the automatic reading behavior and the goal-directed task of color naming. Two types of conflict emerge from this task: 
- Information conflict: occurs when the incongruent word and ink color lead to different responses.
- Task conflict: occurs when the task demands (color naming) conflict with the automatic response (word reading).

Task control can be observed through reaction times (RTs). When task control fails, RTs in congruent trials slow down, leading to a reversed facilitation effect. Therefore, understanding task conflict can help in interpreting cognitive control mechanisms and in developing interventions for related pathological behaviors.

The conflict task approached in this study is explained as follows: the task consists of 200 trials that start with a visual stimulus of either a yellow circle or a blue triangle, followed by a vibration of either the index (D2) or the little finger (D5). Based on the visual stimuli and the vibration position, the response of the subject will be either homotopic (vibration and moving finger align) or heterotopic (vibration and moving finger not aligned). The subject is wearing an electrode on FDI (D2 abductor) and ADM (D5 abductor) as well as accelerometers on D2 and D5.

# Methods

The project is divided into 3 main parts: EMG analysis, accelerometer analysis, and summary statistics of the results. Implementations are mostly in Matlab since the input data is Matlab-specific. An exception is made for the response box data since it had a different data structure that is easy to access with Python's libraries.

All the signals have been preprocessed by:
- filtering on certain frequencies
- eliminating noise
- enveloping 

# Credits

## Author
Chang Hui Simone Lin s232963 - bjg199

# Fitelligence

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview

### Description

Fitelligence elevates the standard workout log by placing a personal AI trainer right inside your tracking app. Instead of following static, pre-made plans, users can instantly generate a workout by simply typing a request in plain language. You can command the AI to create a session tailored to specific criteria and receive a complete, personalized routine instantly. This dynamic tool saves time, reduces decision fatigue, and ensures your training evolves precisely to match your goals, available equipment, and daily energy levels. It’s the ultimate solution for taking the guesswork out of effective, adaptive strength training.

### App Evaluation
- **Category:** Health & Fitness
- **Mobile:** This app is inherently mobile. Users will use their phone to easily track their exercises. Can also utilize push notifications for workout reminders and/or integrate with smartwatches.
- **Story:**  A personal trainer in your pocket. Can help users who struggle to plan their workouts accordingly, or just save time by already having a personalized plan.
- **Market:**  Those who are or are getting into fitness.
- **Habit:**  High potential for near daily use as this app plans to be the go-to fitness app.
- **Scope:** The scope of this app is defintely challenging. While the core features of a workout tracker are manageable, incorporating AI in a way that the app can consistely and reliably use may prove difficult.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can register for an account so that they can access their tracker across devices.
* User can log back in to their account.
* User can track an individual exercise by the category (abs, chest, legs, etc.), weight, reps, and set. 
* User can view their exercises so that they can see their progress. 
* User can type in a simple request to the AI and the AI will generate a complete workout plan that fits the user's needs and constraints. The user can then import the given exercises to their workout log. 
* User can modify and update previous exercises. 
* User can add new custom exercises if a desired exercise is not already an option.

**Optional Nice-to-have Stories**

* User can utilize an in-app rest timer between sets.
* User can view their previous workouts in a nice calendar view for easier tracking.
* User can view a graph of a given exercise to visually see their progress over time. 
* User can have a "conversation" with the AI, meaning it can continue talking to the AI to tweak the plan until desired. 

### 2. Screen Archetypes

- [ ] [**Login Screen**]
* User can login.
- [ ] [**Registration Screen**]
* User can register for an account using an email and a password.
- [ ] [**AI Screen**]
* User can type in a simple request to the AI and the AI will generate a complete workout plan that fits the user's needs and constraints.
* The user can then import the given exercises to their workout log.
* (optional) User can have a "conversation" with the AI, meaning it can continue talking to the AI to tweak the plan until desired.
- [ ] [**Previous Workouts Screen**]
* User can view their exercises so that they can see their progress. 
* User can modify and update previous exercises. 
* (optional) User can view their previous workouts in a nice calendar view for easier tracking.
- [ ] [**Current Workout Screen**]
* User can track an individual exercise by the category (abs, chest, legs, etc.), weight, reps, and set. 
- [ ] [**Add Custom Workout Form/Screen**]
* User can add new custom exercises if a desired exercise is not already an option. 
### 3. Navigation

**Tab Navigation** (Tab to Screen)


- [ ] AI Screen
- [ ] Previous Workouts Screen
- [ ] Current Workout Screen

**Flow Navigation** (Screen to Screen)

- [ ] **Login Screen**
  * Leads to **Previous Workouts Screen**
- [ ] **Registration Screen**
  * Leads to **Previous Workouts Screen**


## Wireframes

[![20251028-215534.jpg](https://i.postimg.cc/J7s21qzb/20251028-215534.jpg)](https://postimg.cc/w3dV2DJv)

### [BONUS] Digital Wireframes & Mockups
<img width="375" height="667" alt="Login" src="https://github.com/user-attachments/assets/52c9a5df-d3e1-4a5d-97ae-4c55140a2263" />
<img width="375" height="667" alt="Calendar" src="https://github.com/user-attachments/assets/7a7c85b6-1b52-4028-9693-98b33602c3f1" />
<img width="375" height="667" alt="AI Prompt" src="https://github.com/user-attachments/assets/401ad643-3bf5-49e6-83fd-498ab7c30c47" />
<img width="375" height="667" alt="Exercises" src="https://github.com/user-attachments/assets/6fe55807-c375-40db-8052-ce05b8f39247" />
<img width="401" height="860" alt="Wireframe Sign up Page -- Fitelligence - JakeC" src="https://github.com/user-attachments/assets/6cfbc2dd-d2ae-41ce-bf19-8bd6522bc1c6" />


### [BONUS] Interactive Prototype

## Schema 


### Models

User
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| uid | String | The unique ID provided by Firebase Auth (the document ID)   |
| email | Email | User's email (used for login).      |

Exercise Library
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| id | String | Unique ID (e.g., barbell_bench_press).   |
| name | String | Name of exercise      |
| category      | String    | Muscle group of workout (e.g., abs, chest, legs, etc.)

Workout
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| id | String | Unique ID for the workout (document ID).   |
| userID | String | Links the workout back to the specific user (uid).     |
| date      | datetime    | The exact date and time the workout was performed
| name      | String    | Name of the workout
| isCompleted      | Boolean    | True if the workout was completed

Exercise Log
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| id | String | Unique ID for this log entry (document ID).   |
| workoutID | String | Links to the specific Workout session.     |
| exerciseID      | String    | Links to the specific Exercise Library entry.
| exerciseName      | String    | Name of the workout
| sets      | [Dictionary]    | An array of dictionaries tracking each set of the exercise (e.g., sets: [{"set": 1, "weight": 135, "reps": 10}])




---
layout: default
title: Enhancement Three - Databases
---

[Back to Home](../index.md)

# Enhancement Three: Databases

## Artifact Description

The artifact selected for this enhancement is the database schema for RateMyLandlord, a full-stack Ruby on Rails web application that allows tenants to search for landlords, create reviews, manage profiles, and share rental experiences with other users. The schema is represented through the Rails schema.rb file, which reflects the current state of all application database tables. The project was originally created outside of coursework while working professionally as a software engineer and was approved for use as my CS 499 artifact because it demonstrates a broad range of software engineering concepts and real-world application development. The schema includes tables for users, landlords, reviews, categories, messages, and support requests, all of which support the core features of the application.

## Justification for Inclusion

I selected this artifact because the database schema represents the foundation upon which the entire RateMyLandlord application is built. Every feature of the application, including user authentication, landlord management, review creation, messaging, and support requests, depends on a well-designed schema to store, connect, and retrieve data reliably. The schema demonstrates my understanding of relational database design, including how entities relate to one another and how those relationships must be enforced at the database level to maintain data integrity.

The original schema had several weaknesses that this enhancement addressed directly. Duplicate and unclear fields, such as both review_count and reviews_count on the landlords table, and both user_id and user_role on the users table, introduced the risk of inconsistent data and made the schema harder to reason about. I removed the redundant fields and standardized the users table around a single role column, which required corresponding updates to the controller, model validations, normalization logic, and profile views to ensure the application remained fully functional after the change.

I also strengthened the schema by adding required fields, default values, indexes, and foreign key relationships. Important fields such as user email, password digest, user name, review text, review stars, message content, and support request details are now required. Default values were added for fields such as user role, review counts, and review interaction counts. Foreign keys were added between categories and landlords, reviews and landlords, reviews and users, messages and users, messages and receivers, and messages and reviews, helping prevent orphaned records and ensuring related data remains connected correctly. Indexes were added to commonly queried columns such as landlord_id, user_id, receiver_id, and review_id, improving query performance when loading reviews, messages, landlords, and related records. A unique index was also added on user email addresses to prevent duplicate accounts, which is especially important since email is used as the primary login identifier.

## Artifact Files

- **Before Enhancements:** [View original files](before-enhancements/)
- **After Enhancements:** [View enhanced files](after-enhancements/)

## Course Outcomes

This enhancement supports **Course Outcome 4** because it demonstrates the use of database design and Rails database tools to implement a full-stack application that delivers value to users. The schema supports landlord management, review creation, messaging, authentication, role-based account behavior, and support request functionality.

This enhancement also supports **Course Outcome 5** because the database includes fields related to secure authentication, including password_digest, password_reset_token_digest, and password_reset_sent_at. These fields support secure password storage and password reset workflows. The addition of a unique email index also improves account security and data integrity by preventing duplicate login identities.

**Course Outcome 3** is also addressed because the schema reflects design decisions about how data should be structured, related, and accessed. The relationships between users, landlords, reviews, messages, categories, and support requests required trade-offs about how to organize information while keeping the application maintainable and scalable. The enhancement also required refactoring the application from user_role to role, which shows the connection between database design and software maintainability.

At this time, my outcome coverage remains consistent with the plan established in Module One. This milestone strengthens my database enhancement category by showing clear improvements to data integrity, relational structure, query performance, and maintainability.

## Reflection

Reviewing and improving the database schema helped me better understand how important database design is to the success of a full-stack application. While users interact mostly with the interface, the database controls how information is stored, connected, retrieved, and protected. A well-designed schema makes the rest of the application easier to maintain and extend.

One important lesson I learned is that database enhancements should not only focus on adding new tables or fields. Sometimes the most valuable improvements come from cleaning up existing structures, removing duplicate fields, enforcing stronger constraints, and making relationships more explicit. In this enhancement, removing user_role and standardizing the application around the role field made the user model cleaner and easier to understand.

Another lesson I learned is that schema changes often require updates throughout the rest of the application. After removing the old user_role column, I had to update the controller, model validations, model normalization method, and profile view so the application would use role consistently. This showed me how closely the database, model layer, controller logic, and views are connected in a Rails application.

The main challenge was handling existing data while adding stricter database rules. When I added null: false constraints, the migration had to account for existing records with blank values. I resolved this by updating or cleaning existing data before applying the new constraints. This helped me better understand why database migrations need to be planned carefully, especially when a database already contains records.

Overall, this enhancement strengthened my understanding of relational database design, schema management, data integrity, indexing, foreign keys, and the role of databases in full-stack software development. The RateMyLandlord schema now better demonstrates the database foundation of a real application and supports my long-term goal of becoming a stronger software engineer and AI solutions architect.

---

[Back to Home](../index.md) | [Enhancement One: Software Design and Engineering](../Enhancement%20One/enhancement-one.md) | [Enhancement Two: Algorithms and Data Structure](../Enhancement%20Two/enhancement-two.md)

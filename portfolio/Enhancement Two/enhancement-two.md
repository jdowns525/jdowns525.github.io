---
layout: default
title: Enhancement Two - Algorithms and Data Structure
---

[Back to Home](../index.md)

# Enhancement Two: Algorithms and Data Structure

## Artifact Description

The artifact selected for this enhancement is RateMyLandlord, a full-stack Ruby on Rails web application that allows tenants to search for landlords, create reviews, manage profiles, and share rental experiences with other users. The application includes user authentication, landlord management, review creation, search functionality, and database integration. The project was originally created outside of coursework while working professionally as a software engineer and was approved for use as my CS 499 artifact because it demonstrates a broad range of software engineering concepts and real-world application development.

## Justification for Inclusion

I selected this artifact because it provided meaningful opportunities to demonstrate competency in algorithms and data structures within the context of a real-world application. Several components of the application highlight these skills, particularly the search functionality that spans both the landlord and review systems. The original search implementation was simplistic and inconsistent. In the original home_controller.rb, the search method performed a basic LIKE query against the landlord name and review text fields using raw string interpolation with the user-supplied query parameter, which produced unreliable results and introduced a potential SQL injection vulnerability.

For this enhancement, I focused on redesigning the search algorithm to be more efficient, secure, and semantically meaningful. The improvements included introducing a token-based query normalization pipeline, implementing a multi-field parameterized filtering algorithm, and building a field-weighted relevance ranking system using dynamically generated SQL CASE expressions. The normalize_query method now processes raw user input by converting it to lowercase, trimming whitespace, splitting on word boundaries, deduplicating tokens, and capping the token count at five to prevent excessive query expansion. The search methods then iterate over each token to progressively narrow the result set using AND-join logic, ensuring that multi-word queries return only results that match all provided terms rather than any single term. Results are scored using weighted CASE expressions that assign higher relevance to matches in more semantically important fields, such as a landlord's name or a review's text content, and lower scores to matches in supplementary fields like state or categorical response fields. A MAX_RESULTS constant was also introduced to bound query result sizes and prevent unbounded database fetches. Additionally, the search logic was refactored into the Landlord and Review model classes using class-level methods, keeping business logic where it belongs rather than in the controller layer.

## Artifact Files

- **Before Enhancements:** [View original files](Before%20Enhancements/)
- **After Enhancements:** [View enhanced files](After%20Enhancements/)

## Course Outcomes

The enhancement successfully addressed the course outcomes identified in Module One.

**Course Outcome 2** was demonstrated through the documentation of algorithmic design decisions and the clear organization of search logic into well-named, purposeful methods that communicate intent to other developers.

**Course Outcome 3** was demonstrated by designing and evaluating a search solution built on algorithmic principles, including token normalization, progressive AND-join filtering, field-weighted ranking, and result bounding, while managing the trade-offs between precision and recall, simplicity and scalability, and query flexibility and database performance.

**Course Outcome 4** was demonstrated through the use of well-founded Rails development techniques, parameterized query construction, frozen constant arrays for searchable field definitions, named scopes for flexible query composition, and before_validation callbacks for consistent data normalization prior to persistence.

**Course Outcome 5** was demonstrated by replacing raw string interpolation in query construction with sanitize_sql_like for LIKE metacharacter escaping and connection.quote for SQL string delimiting, directly mitigating the SQL injection risk present in the original implementation.

At this time, my outcome coverage remains consistent with the plan established in Module One and does not require significant modification.

## Reflection

Enhancing this artifact reinforced the importance of thoughtful algorithmic design and the real-world impact that search quality has on user experience. While the original application functioned correctly, the enhancement process demonstrated that a working search feature and a well-designed search algorithm are not the same thing. Precision, security, relevance, and performance all contribute to whether a search system actually serves its users effectively.

One of the most valuable lessons learned was understanding the distinction between sanitize_sql_like and connection.quote and why both are necessary when constructing dynamic LIKE expressions. Using only one of the two methods would leave either the LIKE metacharacters or the SQL string delimiters unprotected, which could lead to unexpected query behavior or security vulnerabilities. Working through this detail deepened my understanding of how Rails handles query safety at a lower level than the standard ActiveRecord query interface.

The primary challenge was designing the progressive token filtering approach while carefully considering the trade-off between AND-join and OR-join strategies. An OR-join would have returned broader results but with lower precision. The AND-join approach chosen narrows results with each additional token, which better serves the use case of a review platform where users are typically searching for a specific landlord or location rather than browsing broadly.

Overall, this enhancement provided valuable experience applying algorithmic thinking to a practical problem within a production-style application. The project strengthened my understanding of search algorithm design, secure query construction, and data structure organization while supporting my long-term goal of advancing as a software engineer and AI solutions architect.

---

[Back to Home](../index.md) | [Enhancement One: Software Design and Engineering](../Enhancement%20One/enhancement-one.md) | [Enhancement Three: Databases](../Enhancement%20Three/enhancement-three.md)

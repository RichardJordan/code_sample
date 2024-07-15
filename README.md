## Note
This code is just copy/pasted into this Github Repo for sample purposes. It isn't a gem, though
it will be turned into one for shared use.

## Description

This code is intended for use in Rails applications to help create and maintain clear boundaries
code contexts. The layers DSL provides for simple base classes for UserStory objects or UseCase
objects at the boundary of well contained and isolated areas of code. They allow for logic to be
removed from objects that inherit from Rails abstractions (such as ActiveRecord::Base or 
ActionController::Base) and into well isolated, well bounded code libraries. 

One such an approach would be to create, for example, a code library as an unbuilt gem in the 
lib folder and use the layers DSL to create a UseCase object that sits at the boundary of that
code providing for a very object oriented approach to existing the Rails layer and entering the
business logic layer.

This approach has been used successfully in many projects including the development of software
that has created hundreds of millions of dollars in value. I initially created these code 
libraries many years ago to help with my own projects and have used them in many code bases
since then with great success.

The best way to use this is probably to create a new gem in the lib folder and then copy/paste
a version of this code tweaked for the specific project.

Once implemented this library dramatically speeds up the development of Rails applications and
makes code much easier to test, maintain and understand. Much code that would otherwise be
complex and hard to test becomes declarative in nature with well tested base classes under the
hood. It works well in the context of a traditional Rails application as well as in an API 
focused application, such as a GraphQL API where the layers clean up the boundary between the
graphQL mutations and queries, and your business logic.

Happy to demonstrate how to use it.


# Home Assignment

This assignment is mostly focused on understanding a given code.

Your task is to fix existing specs (without changing existing), add new specs if needed and add new functionality to the project.

1. Run 'bundle exec rspec' and make sure Coverage is 100%, including branching. Add new specs if needed.
2. Add new Fleet model. It relates to vehicles by has_many relationship. Fleet has many Vehicles. Vehicle belong to one Fleet. This includes adding a controller, specs, rswag and anything else relevant.
3. fleets_controller should have all generic CRUD actions EXCEPT index. index action should return fleets including all vehicles per fleet.
4. Make sure 'bundle exec rubocop' return no offenses.

Do not hesitate to ask questions if something is not clear.

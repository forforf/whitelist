whitelist
=========
Very small class for filtering by a whitelist



Usage
-----

Basic end to end example

```ruby
#set up

my_list = %w{ admin@example.com *admin.com }

whitelist = Whitelist::List.new(my_list)

#checking

whitelist.check("admin@example.com")
#=> "admin@example.com"

whitelist.check("phineas@admin.com")
#=> "phineas@admin.com"

whitelist.check("ferb@admin.com")
#=> "ferb@admin.com"

whitelist.check("candace@example.com"
#=> false

```

### A Note on Configuration


Whitelist will use either an array or a function (Proc) that returns an array.
The main use case for the proc (for me anyway) is reading a file at the time of the check, rather than at initialization.

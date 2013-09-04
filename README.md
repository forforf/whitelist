whitelist
=========
Very small class for filtering by a whitelist



Usage
-----

Basic end to end example

```ruby
#set up

my_list = %w{ admin@example.com *@admin.com }

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


Example Usage with Proc
-----------------------

Useful for changing configuration files without needing to re-initialize a new object


```yaml
#=> config.yml
---
- admin@example.com
- '*@admin.com'
```


```ruby
#set up

my_list = ->(){ Psych.load_file(config.yml)

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


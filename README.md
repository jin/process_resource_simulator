# process_resource_simulator for CS2106

A simulator representing the process & resource managers in an OS kernel.

Written in Ruby, because Ruby.

## Building

```ruby
bundle
```

That is all.

## Usage

There are various test cases in `test_files/`. 

```shell
ruby app.rb < test_files/input > test_files/actual_output
diff test_files/actual_output test_files/output
```

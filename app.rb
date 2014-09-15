# 1. Process cannot have the same name
# 2. Priority cannot be other than 1, 2
# 3. Process cannot release resources which he doesn't own
# 4. Process cannot release more resources than what he owns 
# 5. Process cannot request for more resources than the max
# 6. Cannot destroy non existing
# 7. Cannot request non existing resource

# when deleting process in waiting list, release all resources

#!/usr/bin/env ruby
require_relative 'ProcessBlockManager'

class App
  attr_accessor :process_manager

  def initialize
    super
    $process_manager = ProcessBlockManager.new
    $resource_manager = ResourceBlockManager.new(4)
  end

  def loop
    ARGF.each do |line|
      unless line == "\n"
        response = process_input(line)
        if response and !$process_manager.has_error
          print "#{$process_manager.active_process.name} "
        else
          print "error "
          $process_manager.has_error = false
        end
        # show_debug_info
      else
        print "\n\n"
      end
    end
  end

  def process_input(line)
    $process_manager.parse(line)
  end

  def show_debug_info
    $process_manager.show_ready_list
    $process_manager.show_blocked_list
    $process_manager.show_tree
    $resource_manager.show_resources
  end
end

app = App.new
app.loop

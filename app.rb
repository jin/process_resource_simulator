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
    print "init "
  end

  def loop
    ARGF.each do |line|
      # puts
      # puts line
      line == "\n" ? print("\n\n") : display(process_input(line))
      # show_debug_info
    end

    print "\n"
  end

  def process_input(line)
    $process_manager.parse(line)
  end

  def display(response)
    if $process_manager.active_process
      message = response ? "#{$process_manager.active_process.name} " : "error " 
    else
      message = "error "
    end
    print message
  end

  def show_debug_info
    puts "<- context. --- Debug ----"
    $process_manager.show_ready_list
    $process_manager.show_blocked_list
    $process_manager.show_tree
    $resource_manager.show_resources
  end
end

app = App.new
app.loop

#!/usr/bin/env ruby
require_relative 'ProcessBlockManager'

class App
  attr_accessor :process_manager

  def initialize
    super
    $process_manager = ProcessBlockManager.new
    $resource_manager = ResourceBlockManager.new(4)
    
    puts "init"
  end

  def loop
    ARGF.each do |line| 
      response = $process_manager.parse(line)
      puts "Instruction: #{line}"
      puts "Context: #{$process_manager.active_process.name}" if response
      $process_manager.show_ready_list
      $process_manager.show_blocked_list
      $process_manager.show_tree
      $resource_manager.show_resources
      puts "--------------"
    end 
  end
end

app = App.new
app.loop

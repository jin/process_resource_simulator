require_relative 'ProcessBlock'
require_relative 'ResourceBlockManager'

require 'tree'

class ProcessBlockManager 

  attr_accessor :ready_list, :blocked_list
  attr_accessor :root_process, :active_process

  def initialize()
    super
    init
  end

  def parse(instruction)
    instr_type, *args = instruction.split 
    return false if instr_type.nil?

    case instr_type.to_sym
    when :init then init
    when :cr   then create_process(args)
    when :de   then destroy_process(args)
    when :to   then timeout
    when :req  then request_resource(args)
    when :rel  then release_resource(args)
    end

    true
  end

  def scheduler
    @active_process = @root_process unless process_exists?(@active_process.name)

    p = highest_ready_priority_process

    if @active_process.content.priority < p.content.priority
      @active_process.content.scheduler_ready
      @active_process = p 
    elsif @active_process.content.state == "blocked"
      @active_process = p
    elsif @active_process.content.state == "ready"
      @active_process = p
    end

    preempt(@active_process)
  end

  def highest_ready_priority_process
    [ready_list[2].detect { |p| p.content.state == "ready"}, 
     ready_list[1].detect { |p| p.content.state == "ready"}, 
     ready_list[0].first].compact.first
  end

  def preempt(p)
    p.content.scheduler_run
  end

  def init
    init_process = ProcessBlock.new(:name => :init, :priority => 0)
    @active_process = @root_process = Tree::TreeNode.new(:init, init_process)
    @ready_list = {
      0 => [@root_process],
      1 => [],
      2 => []
    }

    @blocked_list = {
      1 => [],
      2 => []
    }
  end

  # Create a process control block
  def create_process(args)
    name, priority = get_name(args), get_priority(args)

    # Linear search for any existing process with the same name
    unless process_exists?(name)
      p_node = spawn_child_process(name, priority)
      move_to_ready_list(p_node)
    end

    scheduler
  end

  def destroy_process(args)
    name = get_name(args)

    if @active_process.name == name
      @active_process.each do |child|
        child.content.list.delete(child)
      end
      @active_process.remove_all!
      @active_process.remove_from_parent!

    elsif process_exists?(name)
      p = get_process(name)
      unless @active_process.parentage.include?(p)
        p.each do |child|
          child.content.list.delete(child)
        end

        p.remove_all!
        p.remove_from_parent!
      else 
        puts "Unable to destroy process in ancestors"
      end
    end

    scheduler
  end

  def timeout
    @active_process.content.timeout
    @ready_list[@active_process.content.priority].rotate!(1)

    scheduler
  end

  def request_resource(args)
    rid = args[0]
    requested_count = args[1].to_i
    unless @active_process.content.request_for(rid, requested_count)
      move_to_blocked_list(@active_process)
      $resource_manager.enqueue(rid, @active_process)
    end
    
    scheduler
  end

  def release_resource(args)
    rid = args[0]
    released_count = args[1].to_i
    @active_process.content.release_for(rid, released_count)

    scheduler
  end

  def move_to_blocked_list(p_node)
    p_node.content.block
    @blocked_list[p_node.content.priority] << p_node
    p_node.content.list = @blocked_list
    @ready_list[p_node.content.priority].delete(p_node)
  end

  def move_to_ready_list(p_node)
    p_node.content.unblock
    @ready_list[p_node.content.priority] << p_node
    p_node.content.list = @ready_list
    @blocked_list[p_node.content.priority].delete(p_node)
  end

  def get_name(args)
    args[0].to_sym if args.length > 0
  end

  def get_priority(args)
    args[1].to_i if args.length > 1
  end

  def process_exists?(p_name)
    (@ready_list[1] + @ready_list[2]).any? { |p| p.name == p_name }
  end

  def get_process(p_name)
    (@ready_list[1] + @ready_list[2]).detect { |p| p.name == p_name }
  end

  def spawn_child_process(name, priority) 
    p = ProcessBlock.new(:name => name, :priority => priority, :list => @ready_list[priority])
    @active_process << Tree::TreeNode.new(p.name, p)
  end

  # Debug methods

  def show_ready_list
    p "ready priority 2: #{@ready_list[2].collect { |p| [p.name, p.content.state] }}" 
    p "ready priority 1: #{@ready_list[1].collect { |p| [p.name, p.content.state] }}" 
  end

  def show_blocked_list
    p "blocked priority 2: #{@blocked_list[2].collect { |p| [p.name, p.content.state] }}" 
    p "blocked priority 1: #{@blocked_list[1].collect { |p| [p.name, p.content.state] }}" 
  end

  def show_tree
    @root_process.print_tree
  end

end

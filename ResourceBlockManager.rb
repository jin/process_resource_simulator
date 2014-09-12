require_relative 'ResourceBlock'
require 'PP'

class ResourceBlockManager

  attr_accessor :resource_pool

  def initialize(block_qty)
    @resource_pool = {}
    1.upto block_qty do |i|
      @resource_pool["R#{i}"] = ResourceBlock.new(i)
    end
  end

  def request(rid, count)
    response = resource(rid).request(count)
    response
  end

  def release(rid, count)
    response = resource(rid).release(count)
    resource(rid).check_waiting_list if response == :success
    response
  end

  def enqueue(rid, p_node, requested_count)
    resource(rid).waiting_list << [p_node, requested_count]
  end

  def dequeue(rid, p_node)
    resource(rid).waiting_list.shift
  end

  def resource(rid)
    @resource_pool[rid]
  end

  def remove_from_waiting_lists(p_node)
    @resource_pool.each do |k, v|
      v.waiting_list.delete_if { |p| p.first == p_node }
    end
  end

  def show_resources
    @resource_pool.each do |k, v|
      puts "#{k}: #{v.available_resource}, #{v.waiting_list.map { |p| p[0].name }}"
    end
  end

end

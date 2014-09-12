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
    resource(rid).request(count)
  end

  def release(rid, count)
    resource(rid).release(count)
  end

  def enqueue(rid, p_node)
    resource(rid).waiting_list << p_node
  end

  def dequeue(rid, p_node)
    resource(rid).waiting_list.shift
  end

  def resource(rid)
    @resource_pool[rid]
  end


  def show_resources
    @resource_pool.each do |k, v|
      puts "#{k}: #{v.available_resource}, #{v.waiting_list.map { |p| p.name }}"
    end
  end

end

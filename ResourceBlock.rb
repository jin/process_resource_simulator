class ResourceBlock
  attr_accessor :rid, :waiting_list
  attr_reader :status
  attr_reader :capacity

  def initialize(capacity)
    @rid = "R#{capacity}"
    @waiting_list = [] # Contains pairs of p_nodes and their requested count
    @capacity = @status = capacity
  end

  def available_resource
    @status
  end

  def request(requested_count)
    if available_resource - requested_count >= 0
      decrement(requested_count)
      :success
    elsif requested_count > @capacity
      :error
    else
      :failure
    end
  end

  def release(released_count)
    if available_resource + released_count <= capacity
      increment(released_count)
      :success
    else 
      :failure
    end
  end

  def check_waiting_list
    unless @waiting_list.empty?
      p_node, requested_count = @waiting_list.first

      if requested_count <= available_resource
        @waiting_list.shift
        $process_manager.move_to_ready_list(p_node)
        p_node.content.request_for(@rid, requested_count)
      end
    end
  end

  private

  def decrement(count)
    @status -= count
  end

  def increment(count)
    @status += count
  end

end

class ResourceBlock
  attr_accessor :rid, :waiting_list
  attr_reader :status

  attr_reader :capacity

  def initialize(capacity)
    @rid = "R#{capacity}"
    @waiting_list = []
    @capacity = @status = capacity
  end

  def available_resource
    @status
  end

  def request(requested_count)
    if available_resource - requested_count >= 0
      decrement(requested_count)
    else false
    end
  end

  def release(released_count)
    if available_resource + released_count <= capacity
      increment(released_count)
      true
    else false
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

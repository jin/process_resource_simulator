# 1) ID is a unique process identifier by which the process may be referred to 
# by other processes.
#
# 2) Memory is a linked list of pointers to memory blocks requested by and 
# currently allocated to the process. This field is used only if memory management 
# is incorporated into this project (see Section 5, extension 2.)
#
# 3) Other Resources jointly represents all resources other than main memory 
# that have been requested by and currently allocated to the process. It is 
# implemented as a linked list.
#
# 4) Status consists of two subfields, Status.Type and Status.List. Their meaning 
# is explained in Section 4.4.1 (Chapter 4).
#
# 5) Creation Tree also consist of two subfields, Creation Tree.Parent and Creation 
# Tree. Child. Their meaning also is explained in Section 4.4.1 (Chapter 4).
#
# 6) Priority is the process priority and is used by the Scheduler to decide which 
# process should be running next. We assume that priority is represented by an integer and is static.

require 'state_machine'

class ProcessBlock
  PROPERTIES = [:name, :memory, :other_resources, :list, :creation_tree, :priority]
  PROPERTIES.each { |prop| attr_accessor prop } 
 
  state_machine :state, :initial => :ready do
    event :create do
      transition :none => :ready
    end

    event :destroy do
      transition all => :none
    end

    event :block do
      transition :running => :blocked
    end

    event :unblock do
      transition :blocked => :ready
    end

    event :scheduler_run do
      transition :ready => :running
    end

    event :scheduler_ready do
      transition :running => :ready
    end

    event :timeout do
      transition :running => :ready
    end

    state :none do
    end
    
    state :ready do
    end

    state :blocked do
    end

    state :running do
    end
  end

  def initialize(attributes = {})
    attributes.each { |key, value|
      self.send("#{key}=", value) if PROPERTIES.member? key
    }

    super() # Required to initialize states for state_machine
  end

  def request_for(resource_name, requested_count)
    $resource_manager.request(resource_name, requested_count)
  end

  def release_for(resource_name, released_count)
    $resource_manager.release(resource_name, released_count)
  end

end

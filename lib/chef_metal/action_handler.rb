# -*- encoding: utf-8 -*-
#
# Author:: Douglas Triggs (<doug@getchef.com>)
#
# Copyright (C) 2014, Chef, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This is the generic action handler
module ChefMetal
  class ActionHandler

    # This should be replaced with whatever records the update; by default it
    # essentially does nothing here.
    def updated!
      @updated = true
    end

    def should_perform_actions
      true
    end

    def performed_action(description)
      puts description
    end

    # This should perform the actual action (e.g., converge) if there is an
    # action that needs to be done.
    def perform_action(description)
      if should_perform_actions
        yield
      end
      performed_action(description)
    end

    # This is the name that will show up in the output, so should be something
    # like a cookbook or driver name
    def debug_name
      raise ActionFailed, "ActionHandler behavior requires a debug_name"
    end

    # Open a stream which can be printed to and closed
    def open_stream(name)
      if block_given?
        yield STDOUT
      else
        STDOUT
      end
    end
  end
end

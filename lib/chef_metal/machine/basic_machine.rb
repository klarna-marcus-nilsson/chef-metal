require 'chef_metal/machine'

module ChefMetal
  class Machine
    class BasicMachine < Machine
      def initialize(node, transport, convergence_strategy)
        super(node)
        @transport = transport
        @convergence_strategy = convergence_strategy
      end

      attr_reader :transport
      attr_reader :convergence_strategy

      # Sets up everything necessary for convergence to happen on the machine.
      # The node MUST be saved as part of this procedure.  Other than that,
      # nothing is guaranteed except that converge() will work when this is done.
      def setup_convergence(action_handler, machine_resource)
        convergence_strategy.setup_convergence(action_handler, self, machine_resource)
      end

      def converge(action_handler, chef_server)
        convergence_strategy.converge(action_handler, self, chef_server)
      end

      def execute(action_handler, command, options = {})
        action_handler.perform_action "run '#{command}' on #{node['name']}" do
          result = transport.execute(command, options)
          result.error!
          result
        end
      end

      def execute_always(command, options = {})
        transport.execute(command, options)
      end

      def read_file(path)
        transport.read_file(path)
      end

      def download_file(action_handler, path, local_path)
        if files_different?(path, local_path)
          action_handler.perform_action "download file #{path} on #{node['name']} to #{local_path}" do
            transport.download_file(path, local_path)
          end
        end
      end

      def write_file(action_handler, path, content, options = {})
        if files_different?(path, nil, content)
          if options[:ensure_dir]
            create_dir(action_handler, dirname_on_machine(path))
          end
          action_handler.perform_action "write file #{path} on #{node['name']}" do
            transport.write_file(path, content)
          end
        end
      end

      def upload_file(action_handler, local_path, path, options = {})
        if files_different?(path, local_path)
          if options[:ensure_dir]
            create_dir(action_handler, dirname_on_machine(path))
          end
          action_handler.perform_action "upload file #{local_path} to #{path} on #{node['name']}" do
            transport.upload_file(local_path, path)
          end
        end
      end

      def make_url_available_to_remote(local_url)
        transport.make_url_available_to_remote(local_url)
      end

      def disconnect
        transport.disconnect
      end
    end
  end
end

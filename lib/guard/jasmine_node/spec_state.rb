module Guard
  class JasmineNode
    class SpecState
      STDIN  = 0
      STDOUT = 1
      STDERR = 2
      THREAD = 3

      SUCCESS_CODE = 0
      ERROR_CODE   = 1

      attr_accessor :failing_paths

      def initialize
        clear!
      end

      def update(run_paths = [], options = {})
        @run_paths = run_paths
        @io = Runner.run(@run_paths, options)
        @stdout     = @io[STDOUT]
        @stderr     = @io[STDERR]
        @exitstatus = @io[THREAD].value.to_s.split(' ').last rescue ERROR_CODE
        @stderr.lines { |line| print line }
        #@stdout.lines { |line| print line }
        build_result
        close_io
        update_passed_and_fixed
        update_failing_paths
        passing?
      end

      def passing?
        @passed
      end

      def fixed?
        @fixed
      end

      def clear!
        @passed = true
        @fixed  = false
        @failing_paths = []
      end

      def result_info
        @result
      end
      def build_result
        @stdout.lines do |line|
          print line
          #if line.include? 'Finished'
          # @result = @result + line

          if ((line.include? 'tests') && (line.include? 'assertions'))
            @result = line.strip
          end
        end
      end
      
      private

      def close_io
        @io[STDIN..STDERR].each { |s| s.close }
      end

      def update_passed_and_fixed
        previously_failed = !passing?
        @passed = (@exitstatus.to_i == SUCCESS_CODE)
        @fixed  = @passed && previously_failed 
      end

      def update_failing_paths
        if @run_paths.any?
          @failing_paths = if passing?
                             @failing_paths - @run_paths
                           else
                             @failing_paths + @run_paths
                           end.uniq
        end
      end
    end
  end    
end

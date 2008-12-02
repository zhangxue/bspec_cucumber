require 'cucumber/formatters/ansicolor'
module Cucumber
  module Formatters
    class ReportFormatter
      include ANSIColor

      INDENT = "\n      "
      BACKTRACE_FILTER_PATTERNS = [/vendor\/rails/, /vendor\/plugins\/cucumber/, /spec\/expectations/, /spec\/matchers/]
      MODULES = ['api', 'bvi', 'ui', 'unknown']
      STATUSES = %w(passed failed pending skipped)

      REPORT_FOLDER = File.join(File.dirname(__FILE__),"../../../../../../features/report/") ## 'RAILS_ROOT/features/report'
      def initialize(io, step_mother, options={})

        ## we are going to have three ios,
        ## one for email, containing only statics info, such as ** API features executed,** API scenarios executed, ....
        ## one for report, almost the same as html formatter, but containing only status of scenarios, whether passed or failed, no detailed steps shown
        ## and one for debug, same as html formatter
        ## we are going to store email, report, and debug file in RAILS_ROOT/features/report/***

        # @email_io = Kernel
#        @io = File.open("#{REPORT_FOLDER}/email.txt",'w')
        @io = (io == STDOUT) ? Kernel : io
        @email_io = File.open("#{REPORT_FOLDER}/email.txt",'a')
        @report_io = File.open("#{REPORT_FOLDER}/report.html",'w')
        @debug_io = File.open("#{REPORT_FOLDER}/debug.html",'w')

        @report_formatter = Cucumber::Formatters::SimpleHtmlFormatter.new(@report_io, step_mother)
        @debug_formatter = Cucumber::Formatters::FWHtmlFormatter.new(@debug_io,step_mother)
        @progress_formatter = Cucumber::Formatters::ProgressFormatter.new(@io)

        @options = options
        @step_mother = step_mother
#        @formatters = [@debug_formatter]
        initialize_values
      end
#      def delegate(formatters, method_name, *args)
#        method_name = method_name.to_sym
#        formatters.each{|f|
#          f.send(method_name, *args) if f.respond_to? method_name
#        }
#      end
      def visit_features(features)
        @debug_formatter.visit_features(features)
        @report_formatter.visit_features(features)
      end

      def visit_feature(feature)
        @debug_formatter.visit_feature(feature)
        @report_formatter.visit_feature(feature)
      end

      def visit_header(header)
        @debug_formatter.visit_header(header)
        @report_formatter.visit_header(header)
      end

      def visit_regular_scenario(scenario)
        @debug_formatter.visit_regular_scenario(scenario)
      end

      def visit_row_scenario(scenario)
        @debug_formatter.visit_row_scenario(scenario)
        @report_formatter.visit_row_scenario(scenario)
      end

      def visit_row_step(step)
        @debug_formatter.visit_row_step(step)
        @report_formatter.visit_row_step(step)
      end

      def visit_regular_step(step)
        @debug_formatter.visit_regular_step(step)
        @report_formatter.visit_regular_step(step)
      end

      def feature_executing(feature)
        @feature_failed = false
        @mod = MODULES.detect{|m| feature.file.include?("features/#{m}/")} || "unknown"
        @debug_formatter.feature_executing(feature)
        @report_formatter.feature_executing(feature)
      end

      def feature_executed(feature)
        count_features_by_module(feature, @feature_failed ? "failed" : "passed")
        @debug_formatter.feature_executed(feature)
        @report_formatter.feature_executed(feature)
      end

      def header_executing(header)
      end

      def scenario_executing(scenario)
        @scenario_failed = false
        @debug_formatter.scenario_executing(scenario)
        @report_formatter.scenario_executing(scenario)
        @progress_formatter.scenario_executing(scenario)
      end

      def scenario_executed(scenario)
        count_scenarios_by_module(scenario, @scenario_failed ? "failed" : "passed")
        @feature_failed = true if @scenario_failed
        @debug_formatter.scenario_executed(scenario)
        @report_formatter.scenario_executed(scenario)
      end

      def step_passed(step, regexp, args)
        count_steps_by_module(step,"passed")
        @debug_formatter.step_passed(step,regexp,args)
        @report_formatter.step_passed(step,regexp,args)
        @progress_formatter.step_passed(step,regexp,args)
      end

      def step_failed(step, regexp, args)
        count_steps_by_module(step,"failed")
        @scenario_failed = true
        @debug_formatter.step_failed(step,regexp,args)
        @report_formatter.step_failed(step,regexp,args)
        @progress_formatter.step_failed(step,regexp,args)
      end

      def step_skipped(step, regexp, args)
        count_steps_by_module(step,"skipped")
        @debug_formatter.step_skipped(step,regexp,args)
        @report_formatter.step_skipped(step,regexp,args)
        @progress_formatter.step_skipped(step,regexp,args)
      end

      def step_pending(step, regexp, args)
        count_steps_by_module(step,"pending")
        @debug_formatter.step_pending(step,regexp,args)
        @report_formatter.step_pending(step,regexp,args)
        @progress_formatter.step_pending(step,regexp,args)
      end

      # Sample outputs:
      # Module API
      # =================
      # features:   1 passed, 0 failed, 0 pending, 0 skipped, 1 total
      # scenarios:  19 passed, 0 failed, 0 pending, 0 skipped, 19 total
      # steps:      91 passed, 0 failed, 0 pending, 0 skipped, 91 total
      def dump
        @debug_formatter.dump
        @report_formatter.dump
#        @progress_formatter.dump
        output = ''
        MODULES.each do |m|
          next if eval("@#{m}_features.empty?")
          both_puts "\nModule #{m.upcase}"
          both_puts "================="
          ['feature','scenario','step'].each{|type|
            counters = {}
            STATUSES.each{|s| counters[s] = 0}
            eval "@#{m}_#{type}s.each{|obj,status| counters[status] += 1}"
            @io.puts("#{type}s:".ljust(12) <<
                     "#{(STATUSES.map{|status| eval("#{status}(counters[status].to_s + ' ' + status)")} <<
                            "#{counters.values.inject(0){|sum,item| sum + item}} total").map{|s| s.rjust(12)}.join(', ')}" )
            @email_io.puts("#{type}s:".ljust(12) <<
                     "#{(STATUSES.map{|status| eval("counters[status].to_s + ' ' + status")} <<
                            "#{counters.values.inject(0){|sum,item| sum + item}} total").map{|s| s.rjust(12)}.join(', ')}" )
          }
          both_puts
        end
      end

      protected

      def count_steps_by_module(step,status='pending')
        eval "@#{@mod}_steps[step] = status"
      end

      def count_features_by_module(feature,status='pending')
        eval "@#{@mod}_features[feature] = status"
      end

      def count_scenarios_by_module(scenario,status='pending')
        eval "@#{@mod}_scenarios[scenario] = status"
      end

      def initialize_values
        MODULES.each do |m|
          instance_variable_set("@#{m}_features",{}) unless m.empty?
          instance_variable_set("@#{m}_scenarios",{}) unless m.empty?
          instance_variable_set("@#{m}_steps",{}) unless m.empty?
        end
      end

      private
      def both_puts(*args)
        @email_io.puts *args
        @io.puts *args
      end
    end
  end
end

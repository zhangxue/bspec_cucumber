module Cucumber
  module Formatters
    class SimpleHtmlFormatter < Cucumber::Formatters::FWHtmlFormatter
      def visit_row_scenario(scenario)
        @io.puts %{          <dl id="scenario_#{scenario.id}" class="new">}
        @io.puts %{            <dt>#{Cucumber.language['scenario']}: <span id="scenario_case_name_#{scenario.id}">#{scenario.name}</span>, case id: <span id="scenario_case_id_#{scenario.id}">unknown</span></dt>}
        @io.puts %{            <dd>}
        scenario.accept(self)
        @io.puts %{            </dd>}
        @io.puts %{          </dl>}
      end

      def visit_row_step(step)
      end

      def visit_regular_step(step)
      end

      def step_passed(step, regexp, args)
      end

      def step_failed(step, regexp, args)
        @scenario_failed = true
      end

      def step_pending(step, regexp, args)
      end

      def step_skipped(step, regexp, args)
        # noop
      end

      def print_javascript_tag(js)
        @io.puts %{    <script type="text/javascript">#{js}</script>}
      end

      def dump
        @io.puts <<-HTML
  </body>
</html>
HTML
      end
    end
  end
end

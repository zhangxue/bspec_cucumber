%w{html pretty progress profile autotest}.each{|n| require "cucumber/formatters/#{n}_formatter"}
%w{fw_html simple_html report}.each{|n| require "cucumber/formatters/#{n}_formatter"}
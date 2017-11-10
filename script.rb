require 'timeout'

begin
  Timeout::timeout(5) do
    sleep 8
    puts "Executed"
  end
rescue Timeout::Error
  puts "Not executed"
end

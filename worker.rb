require 'simple_rabbit'
require 'json'

class Prime
  def self.prime?(number)
    return false if number <= 1
    Math.sqrt(number).to_i.downto(2) do |i|
      return false if number % i == 0
    end
  end
end

sleep 10

SimpleRabbit::Connection.get(user: "bunnyrabbit", pass: "bunnypass", host: "rabbitmq")

SimpleRabbit::ConsumerWorker.run("jobs.created") do |message|
  data = JSON.parse(message)
  SimpleRabbit::Publisher.publish("jobs.updated", {id: data["id"], status: "in_progress"}.to_json)

  begin
    Timeout::timeout(60) do
      result =
        if Prime.prime?(data["input_number"].to_i)
          "It is a PRIME"
        else
          "It is not a PRIME"
        end
      status = "done"
      SimpleRabbit::Publisher.publish("jobs.updated", {id: data["id"], status: status, result: result}.to_json)
    end
  rescue Timeout::Error
    result = "Execution expired. To long ..."
    status = "failed"
    SimpleRabbit::Publisher.publish("jobs.updated", {id: data["id"], status: status, result: result}.to_json)
  end
end

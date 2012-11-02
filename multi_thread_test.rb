require 'logger'

ENV["BUNDLE_GEMFILE"] = File.expand_path("../Gemfile", __FILE__)
puts ENV["BUNDLE_GEMFILE"]
require 'bundler'
env = ENV['RACK_ENV'] || 'development'
Bundler.setup
Bundler.require :default, env.to_sym


Encoding.default_external = 'utf-8'

require "active_record"

ActiveRecord::Base.establish_connection :adapter=>'sqlite3',
                                        :database => 'development.sqlite3',
                                        :pool => 10, :timeout => 10000




require_relative 'test_model'

# insert a record in.
a = TestModel.new
a.active = "a"
a.cluster_name = "cluster"
a.name = "aaaaa"
a.save()

b = TestModel.new
b.active = "b"
b.cluster_name = "cluster"
b.name = "bbbbb"
b.save()


def action_a()
  count = 0
  total_time_passed = 0
  begin_time = Time.now
  # logger must be on in order to see the problem.
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  500.times do
    TestModel.all.each do |s|
      s.name=rand().to_s()
      s.save()
    end
    count+=1
    end_time = Time.now
    passed = (end_time - begin_time) * 1000
    total_time_passed += passed
    begin_time = end_time
    puts "===Action a's thread: #{Thread.current.object_id}, count reaches: #{count}. each round time: #{passed}, total time passed: #{total_time_passed}"

  end
end

def action_b()
  count = 0
  total_time_passed = 0
  begin_time = Time.now
  # logger must be on in order to see problem.
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  500.times  do
    TestModel.transaction do
      TestModel.all.each do |s|
        TestModel.transaction do
          s.name=rand().to_s()
          s.save()
        end
      end
    end

    count+=1
    end_time = Time.now
    passed = (end_time - begin_time) * 1000
    total_time_passed += passed
    begin_time = end_time
    puts "===Action b's thread: #{Thread.current.object_id}, count reaches: #{count}. each round time: #{passed}, total time passed: #{total_time_passed}"
  end
end

sleep 3
require 'thread'

def run_test_all_A()
  9.times do |i|
    Thread.new do
      action_a
    end
  end
  action_a
end

def run_test_all_B()
  9.times do |i|
    Thread.new do
      action_b
    end
  end
  action_b
end

def run_mix_test_A_B()
  5.times do |i|
    Thread.new do
      action_a
    end

  end
  4.times do |i|
    Thread.new do
      action_b
    end
  end
  action_b
end

# it will throw busy exception. not always, it will, depends on ur cpu speed.
run_test_all_A

#run_test_all_B
#run_mix_test_A_B

puts "================End here"

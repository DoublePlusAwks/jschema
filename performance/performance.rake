require 'benchmark'
require 'csv'

namespace :perf do
  def json_data
    @json_data ||=
      JSON.parse File.read('test/fixtures/json_data2.json')
  end

  def schema_data
    @schema_data ||=
      JSON.parse File.read('test/fixtures/json_schema2.json')
  end

  # TODO: Move into a module and refactor
  desc 'Measure jschema parsing and validation time'
  task :measure do
    parsing = Benchmark.measure do
      1000.times { JSchema.build(schema_data) }
    end

    jschema = JSchema.build(schema_data)
    validation = Benchmark.measure do
      1000.times { jschema.valid? json_data }
    end

    hash, time = `git show --format="%H,%ct" -s HEAD`.strip.split(',')
    parsing_benchmark = parsing.total.round(3)
    validation_benchmark = validation.total.round(3)

    already_recorded = false
    performance_data_path = File.expand_path('performance_data.csv', __dir__)
    if File.exists?(performance_data_path)
      CSV.foreach(performance_data_path) do |row|
        if row.first == hash
          already_recorded = true
          break
        end
      end
    end

    unless already_recorded
      CSV.open(performance_data_path, 'a') do |csv|
        csv << [hash, time, parsing_benchmark, validation_benchmark]
      end
    end

    performance_plot = File.expand_path('performance_plot', __dir__)
    plot_args = "performance_data='#{performance_data_path}'"
    sh 'gnuplot', '-e', plot_args, performance_plot
  end

  desc 'Profile jschema initialization code'
  task :profile_build do
    require 'profile'
    10.times { JSchema.build(schema_data) }
  end

  desc 'Profile validation code'
  task :profile_validation do
    jschema = JSchema.build(schema_data)

    require 'profile'
    10.times { jschema.valid? json_data }
  end
end

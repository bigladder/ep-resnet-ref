require 'fileutils'

def compose(c)
  file_base = File.basename(c,".*")

  output_dir = 'output/' + file_base
  #Create output directory
  unless File.directory?(output_dir)
    FileUtils.mkdir_p(output_dir)
  end

  src = ['base.pxt', c]
  target = output_dir + '/in.idf'

  puts "================="
  puts "Running case " + file_base + ":"
  puts "=================\n"

  # Compose with modelkit
  success = nil
  if !(FileUtils.uptodate?(target, src))
    puts "\ncomposing...\n\n"
    success = system(%Q|modelkit template-compose -f "#{c}" -o "#{output_dir + '/in.idf'}"  base.pxt|)
  else
    puts "  ...input already up-to-date."
    success = true
  end
  return success
end

def sim(c)
  file_base = File.basename(c,".*")

  if file_base[-1] == "C"
    weather_file = "../../TMY-Colorad-v5.0.epw"
  elsif file_base[-1] == "L"
    weather_file = "../../TMY-Lasvega-v5.0.epw"
  else
    success = false
    puts "  unknown weather file."
    return success
  end

  output_dir = 'output/' + file_base

  src = [output_dir + '/in.idf']
  target = [output_dir + '/eplusout.err', output_dir + '/eplusout.csv']

  success = nil
  if !(FileUtils.uptodate?(target[0], src)) or !(FileUtils.uptodate?(target[1], src))
    puts "\nsimulating..."
    Dir.chdir(output_dir){
      success = system(%Q|/Applications/EnergyPlus-9-3-0/energyplus -r -w "#{weather_file}" in.idf|)
    }
    puts "\n"
  else
    puts "  ...output already up-to-date.\n"
    success = true
  end
  return success
end

task :sim, [:filter] do |t, args|
  args.with_defaults(:filter=>'*')
  cases = Dir['cases/' + args.filter + '.*']
  for c in cases
    if !compose(c)
      puts "\nERROR: Composition failed..."
      exit
    end
    if !sim(c)
      puts "\nERROR: Simulation failed..."
      exit
    end
  end
end

task :default, [:filter] => [:sim]

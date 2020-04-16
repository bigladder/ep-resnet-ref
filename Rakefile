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
      success = system(%Q|C:\\EnergyPlusV9-3-0\\energyplus -r -w "#{weather_file}" in.idf|)
    }
    puts "\n"
  else
    puts "  ...output already up-to-date.\n"
    success = true
  end
  return success
end

def results(cases)
  output_dir = 'results/'

  # write list of SQL output files in each location to batch files
  sql_files_CO = output_dir + 'sql-batch-CO.txt'
  sql_files_LV = output_dir + 'sql-batch-LV.txt'
  File.write(sql_files_CO, "")
  File.write(sql_files_LV, "")

  src = [output_dir + '/results.txt']

  for c in cases
    file_base = File.basename(c,".*")
    sql_file = 'output/' + file_base + '/eplusout.sql'
    src << sql_file
    if file_base[-1] == "C"
      File.write(sql_files_CO, "#{sql_file}\n", mode: "a")
    elsif file_base[-1] == "L"
      File.write(sql_files_LV, "#{sql_file}\n", mode: "a")
    else
      success = false
      puts "  can't find SQL output file."
      return success
    end
  end

  target = [output_dir + '/results_CO.csv', output_dir + '/results_LV.csv']

  puts "================="
  puts "Making results"
  puts "=================\n"

  success_CO = nil
  success_LV = nil
  if !(FileUtils.uptodate?(target[0], src))
    puts "\nResults CSVs for heating cases not up-to-date...\n"
    if File.size(sql_files_CO) > 0
      puts "  Heating cases in Colorado Springs ..."
      success_CO = system(%Q|modelkit-energyplus energyplus-sql --query=#{src[0]} --output=#{target[0]} --batch=#{sql_files_CO}|)
    else
      puts "No SQL output files for CO locations."
    end
  else
    puts "\n ...results CSVs for heating cases already up-to-date.\n"
    success_CO = true
  end
  if !(FileUtils.uptodate?(target[1], src))
    puts "\nResults CSVs for cooling cases not up-to-date...\n"
    if File.size(sql_files_LV) > 0
      puts "  Cooling cases in Las Vegas ..."
      success_LV = system(%Q|modelkit-energyplus energyplus-sql --query=#{src[0]} --output=#{target[1]} --batch=#{sql_files_LV}|)
    else
      puts "No SQL output files for LV locations."
    end
  else
    puts "\n ...results CSVs for cooling cases already up-to-date.\n"
    success_LV = true
  end

  success = success_CO and success_LV
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
  if !results(cases)
    puts "\nERROR: Making results failed..."
    exit
  end
end

task :default, [:filter] => [:sim]

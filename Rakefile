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
  target = [output_dir + '/in-out.err', output_dir + '/in-var.csv']

  success = nil
  if !(FileUtils.uptodate?(target[0], src)) or !(FileUtils.uptodate?(target[1], src))
    puts "\nsimulating..."
    Dir.chdir(output_dir){
      success = system(%Q|modelkit-energyplus energyplus-run -r -w "#{weather_file}" in.idf -o 'eplusout.err; eplusout.rdd; eplusout.sql; eplustbl.htm; eplusvar.csv; eplusvar.eso'|)
    }
    puts "\n"
  else
    puts "  ...output already up-to-date.\n"
    success = true
  end
  return success
end

def results(sql_outputs)
  # check if any file in sql_outputs is more recent that results CSVs
  output_dir = 'results/'
  target = [output_dir + 'results_CO.csv', output_dir + 'results_LV.csv']
  sql_update_CO = false
  sql_update_LV = false

  src = [output_dir + 'results.txt']
  sql_files_CO = []
  sql_files_LV = []

  for sql in sql_outputs
    case_name = File.dirname(sql)
    if case_name[-1] == "C"
      sql_files_CO << sql
    elsif case_name[-1] == "L"
      sql_files_LV << sql
    end
  end

  if !(FileUtils.uptodate?(target[0], src + sql_files_CO))
    puts "Results CSVs for heating cases not up-to-date...\n"
    sql_update_CO = true
  else
    puts "\n ...results CSVs for heating cases already up-to-date.\n"
  end
  if !(FileUtils.uptodate?(target[1], src + sql_files_LV))
    puts "Results CSVs for cooling cases not up-to-date...\n"
    sql_update_LV = true
  else
    puts "\n ...results CSVs for cooling cases already up-to-date.\n"
  end

  if sql_update_CO or sql_update_LV
    # write list of SQL output files in each location to batch files
    sql_batch_CO = output_dir + 'sql-batch-CO.txt'
    sql_batch_LV = output_dir + 'sql-batch-LV.txt'
    File.write(sql_batch_CO, "")
    File.write(sql_batch_LV, "")

    src_CO = [output_dir + 'results.txt']
    src_LV = [output_dir + 'results.txt']

    for sql in sql_outputs
      case_name = File.dirname(sql)
      if case_name[-1] == "C"
        src_CO << sql
        File.write(sql_batch_CO, "#{sql}\n", mode: "a")
      elsif case_name[-1] == "L"
        src_LV << sql
        File.write(sql_batch_LV, "#{sql}\n", mode: "a")
      else
        success = false
        puts "  can't find SQL output file."
        return success
      end
    end

    puts "================="
    puts "Making results"
    puts "=================\n"

    target = [output_dir + '/results_CO.csv', output_dir + '/results_LV.csv']
    success_CO = nil
    success_LV = nil
    if sql_update_CO
      if File.size(sql_batch_CO) > 0
        puts "  Heating cases in Colorado Springs ..."
        success_CO = system(%Q|modelkit-energyplus energyplus-sql --query=#{src[0]} --output=#{target[0]} --batch=#{sql_batch_CO}|)
      else
        puts "No SQL output files for CO locations."
      end
    else
      success_CO = true
    end
    if sql_update_LV
      if File.size(sql_batch_LV) > 0
        puts "  Cooling cases in Las Vegas ..."
        success_LV = system(%Q|modelkit-energyplus energyplus-sql --query=#{src[0]} --output=#{target[1]} --batch=#{sql_batch_LV}|)
      else
        puts "No SQL output files for LV locations."
      end
    else
      success_LV = true
    end
    success = success_CO and success_LV
    return success
  else
    puts "\n ...results CSVs for all cases already up-to-date.\n"
    return true
  end
end

desc "Compose and simulate cases"
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
  sql_outputs = Dir['output/*/in-out.sql']
  if !results(sql_outputs)
    puts "\nERROR: Making results failed..."
    exit
  end
end

task :default, [:filter] => [:sim]

desc "Clean the output directory and results CSVs"
task :clean_output, [:filter] do |t, args|
  args.with_defaults(:filter=>'*')
  outputs = Dir['output/' + args.filter]
  puts "Cleaning output..."
  # cases = Dir['cases/*']
  for o in outputs
    working_dir = File.dirname(o)
    FileUtils.remove_dir(o)
  end
  puts "Cleaning output completed."
end

desc "Clean the results CSVs"
task :clean_results do
  puts "Cleaning results CSVs..."
  results = Dir['results/*.csv']
  for csv in results
    FileUtils.rm(csv)
  end
  puts "Cleaning results CSVs completed."
end

desc "Clean outputs and results CSVs"
task :clean => [:clean_output, :clean_results]

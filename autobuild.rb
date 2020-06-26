########################################################################
# Auto Build Script for Vivado (mod.) 2020.06.26 Naoki F., AIT
# New BSD License is applied.
########################################################################
require 'fileutils'
require 'rubygems'
require 'serialport'

VIVADO_DIR   = '/tools/Xilinx/Vivado/2019.2'
PROJ_BASE    = __dir__ + '/hello_'
IMPL_PREFIX  = '/fpga/fpga.runs/impl_1'
GEN_DIR      = 'generate_log'

BIT_PREFIX   = '/serial_fpga2.bit'
LOG_FILE     = 'vivado.log'

PORT         = "/dev/ttyUSB1"

newpath = VIVADO_DIR + '/bin;' + ENV['PATH'];
newenv = {'PATH' => newpath, 'XILINX_VIVADO' => VIVADO_DIR}

########################################################################
# main loop

if ARGV.size != 2 || (ARGV[0] != 'arty' && ARGV[0] != 'nexys')
  STDERR.puts "usage: ruby autobuild.rb BOARD PREFIX"
  STDERR.puts "  - BOARD must be either arty or nexys"
  exit 1
end

proj_dir = PROJ_BASE + ARGV[0]
impl_dir = proj_dir + IMPL_PREFIX
bit_file = impl_dir + BIT_PREFIX
gen_file = GEN_DIR + "/" + ARGV[1]

# run Vivado for writing a dummy bitstream
puts "[[ writing a dummy bitstream ]]"
IO.popen([newenv, VIVADO_DIR + '/bin/vivado',
  '-mode', 'batch', '-source', "write_dummy_#{ARGV[0]}.tcl",
  '-nojournal']) do |io|
  while line = io.gets
    if line =~ /^# [a-z]/ || line =~ /: Time \(s\)/
      puts line.chomp
    end
  end
end
if ! $?.success?
puts "!! failed to write a dummy bitstream (with status %d). stop." % $?
exit 1
end
FileUtils.rm LOG_FILE

# open serial port
puts
puts "[[ opening serial port ]]"
begin
  sp = SerialPort.new(PORT, 115200, 8, 1, 0)
  sp.read_timeout = 1000
rescue => e
  STDERR.puts "!! failed to open serial port (%s). stop." % e.message
  exit 1
end

# run Vivado
puts
puts "[[ synthesizing Hello FPGA ]]"
IO.popen([newenv, VIVADO_DIR + '/bin/vivado',
         '-mode', 'batch', '-source', "build_vivado_#{ARGV[0]}.tcl",
         '-nojournal']) do |io|
  while line = io.gets
    if line =~ /^# [a-z]/ || line =~ /: Time \(s\)/
      puts line.chomp
    end
  end
end
if ! $?.success?
  puts "!! failed to build the core (with status %d). stop." % $?
  exit 1
end

# copy relavant file
FileUtils.mv LOG_FILE, gen_file + '.log'
FileUtils.cp bit_file, gen_file + '.bit'

# remove webtalk log (if any)
Dir.glob("webtalk*.*") {|x| FileUtils.rm x }

# read from serial port
data = sp.read(20)
puts
puts "Data from serial port: #{data}"
sp.close

########################################################################

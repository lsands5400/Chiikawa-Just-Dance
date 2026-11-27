if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2026.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/lindz/my_designs/testLCD"
if {![file exists {C:/Users/lindz/my_designs/testLCD/testLCD}]} {
  file mkdir {C:/Users/lindz/my_designs/testLCD/testLCD}
}
cd {C:/Users/lindz/my_designs/testLCD/testLCD}
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- testLCD_testLCD_cpe.ldc
::radiant::runengine::run_engine_newmsg cpe -syn lse -f "testLCD_testLCD.cprj" -a "iCE40UP"  -o testLCD_testLCD_cpe.ldc
# synthesize top design
file delete -force -- testLCD_testLCD.vm testLCD_testLCD.ldc
::radiant::runengine::run_engine_newmsg synthesis -f "C:/Users/lindz/my_designs/testLCD/testLCD/testLCD_testLCD_lattice.synproj" -logfile "testLCD_testLCD_lattice.srp"
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o testLCD_testLCD_syn.udb testLCD_testLCD.vm] [list testLCD_testLCD.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}

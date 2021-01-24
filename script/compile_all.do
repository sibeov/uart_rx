package require fileutil

if {[batch_mode]} {
  onerror {abort all; exit -f -code 1}
  onbreak {abort all; exit -f}
} else {
  onerror {abort all}
}

# ---------- Fileutil example -----------
# foreach file [fileutil::findByPattern $basepath *.tcl] {
#     source $file
# }

quit -sim

# Path and dir vars
quietly set prj_path ".."
quietly set root_lib "../../../lib"
quietly set lib_path "$prj_path/lib"
quietly set src_path "$prj_path/src"
quietly set tb_path "$prj_path/tb"

# ---------- Compilation -----------
# Lib files
foreach lib_file [fileutil::findByPattern $lib_path *.vhd] {
  vcom -2008 $lib_file
}

foreach root_lib_file [fileutil::findByPattern $root_lib *.vhd] {
  vcom -2008 $root_lib_file
}

# Src files
foreach src_file [fileutil::findByPattern $src_path *.vhd] {
  vcom -2008 -check_synthesis $src_file
}
# Testbench files
foreach tb_file [fileutil::findByPattern $tb_path *.vhd] {
  vcom -2008 $tb_file
}
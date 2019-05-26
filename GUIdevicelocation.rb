#!/usr/bin/ruby -w

require "pp"
require "gtk2"
require "yaml"
require "bigdecimal"

PI = BigDecimal(Math::PI.to_s())
EARTH_RADIUS = BigDecimal("6356752.314")
EARTH_CIRCUIT = BigDecimal("2") * PI * EARTH_RADIUS
METER_PER_LATI = EARTH_CIRCUIT / BigDecimal("360")
LATI_PER_METER = BigDecimal("1") / METER_PER_LATI

def meter_to_lati(sMeter)
  return BigDecimal(sMeter) * LATI_PER_METER
end

def meter_to_long(sMeter)
  cTargetRadius = EARTH_RADIUS * Math.cos((BigDecimal($cLatiC.text).abs() / BigDecimal("180")) * PI)
  cTargetCircuit = BigDecimal("2") * PI * cTargetRadius
  cMeterPerLati = cTargetCircuit / BigDecimal("360")
  cLatiPerMeter = BigDecimal("1") / cMeterPerLati
  return BigDecimal(sMeter) * cLatiPerMeter
end

STDOUT.sync = true
SAVE_FILE = "#{File.expand_path("..", __FILE__)}/.position.yaml"
hSaveData = {}
if (File.exist?(SAVE_FILE))
  hSaveData = YAML.load(File.read(SAVE_FILE))
else
  hSaveData[:LATI_C] = "35.68123"
  hSaveData[:LONG_C] = "139.76493"
  hSaveData[:LATI_S] = []
  hSaveData[:LONG_S] = []
  hSaveData[:LATI_S][0] = "35.17091"
  hSaveData[:LONG_S][0] = "136.87935"
  hSaveData[:LATI_S][1] = "34.70249"
  hSaveData[:LONG_S][1] = "135.49376"
  hSaveData[:LATI_S][2] = "36.70830"
  hSaveData[:LONG_S][2] = "136.92981"
end



$cWindow = Gtk::Window.new()
$cWindow.set_size_request(460, 460)
$cWindow.title = "GUIdevicelocation"
$cWindow.signal_connect("destroy") {Gtk.main_quit}

$cTable = Gtk::Table.new(16, 10, true)
$cWindow.add($cTable)

def create_label(sLabel, start_x, start_y, end_x, end_y)
  $cTable.attach(Gtk::Label.new(sLabel), start_x, start_y, end_x, end_y, Gtk::EXPAND, Gtk::EXPAND, 0, 0)
end

create_label("Lati(N/S)", 1, 3, 1, 2)
create_label("Long(E/W)", 1, 3, 2, 3)
$cLatiC = Gtk::Entry.new()
$cLatiC.set_xalign(1)
$cLatiC.max_length = 10
$cLatiC.text = hSaveData[:LATI_C]
$cTable.attach($cLatiC, 3, 7, 1, 2, Gtk::FILL, Gtk::FILL, 0, 0)
$cLongC = Gtk::Entry.new()
$cLongC.set_xalign(1)
$cLongC.max_length = 10
$cLongC.text = hSaveData[:LONG_C]
$cTable.attach($cLongC, 3, 7, 2, 3, Gtk::FILL, Gtk::FILL, 0, 0)

$cComboBox = Gtk::ComboBox.new()
$cTable.attach($cComboBox, 3, 10, 3, 4, Gtk::FILL, Gtk::FILL, 0, 0)

def exec_idevicelocation()
  sCommand = "idevicelocation -u #{$cComboBox.active_text()} -- #{$cLatiC.text} #{$cLongC.text}"
  puts(sCommand)
  system(sCommand)
end

def get_idevicelocation()
  aList = []
  IO.popen("idevice_id -l") do |io|
    while io.gets()
      aList.push($_.gsub("\n",""))
    end
  end
  return aList
end



cButton = Gtk::Button.new("Stop Simu")
cButton.signal_connect("clicked") {
  sCommand = "idevicelocation -u #{$cComboBox.active_text()} --stop"
  puts(sCommand)
  system(sCommand)
}
$cTable.attach(cButton, 11, 14, 1, 3, Gtk::FILL, Gtk::FILL, 0, 5)
create_label(" ", 12, 15, 1, 3)



create_label("UUID", 1, 3, 3, 4)

cButton = Gtk::Button.new("Get UUID")
cButton.signal_connect("clicked") {
  aList = get_idevicelocation()
  aList.each{|sUUID|
    $cComboBox.append_text(sUUID)
  }
  $cComboBox.set_active(0)
}
$cTable.attach(cButton, 11, 14, 3, 4, Gtk::FILL, Gtk::FILL, 0, 0)


def get_sqrt(sLength)
  return (BigDecimal(sLength) / BigDecimal(Math.sqrt(2).to_s())).to_f().to_s()
end

B1_START_X = 1
B1_START_Y = 6
B1_MOVE_SIZE = "2"
B1_SKEW_SIZE = get_sqrt(B1_MOVE_SIZE)

create_label("Move #{B1_MOVE_SIZE}m", B1_START_X, B1_START_X + 3, B1_START_Y - 1, B1_START_Y)

cButton = Gtk::Button.new("^")
cButton.signal_connect_after("clicked") {
  $cLatiC.text = (BigDecimal($cLatiC.text) + meter_to_lati(B1_MOVE_SIZE)).to_f().to_s()
  exec_idevicelocation()
}
$cTable.attach(cButton, B1_START_X + 1, B1_START_X + 2, B1_START_Y, B1_START_Y + 1, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new(" ")
cButton.signal_connect("clicked") {
  $cLatiC.text = (BigDecimal($cLatiC.text) + meter_to_lati(B1_SKEW_SIZE)).to_f().to_s()
  $cLongC.text = (BigDecimal($cLongC.text) + meter_to_long(B1_SKEW_SIZE)).to_f().to_s()
  exec_idevicelocation()
}
$cTable.attach(cButton, B1_START_X + 2, B1_START_X + 3, B1_START_Y, B1_START_Y + 1, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new(">")
cButton.signal_connect("clicked") {
  $cLongC.text = (BigDecimal($cLongC.text) + meter_to_long(B1_MOVE_SIZE)).to_f().to_s()
  exec_idevicelocation()
}
$cTable.attach(cButton, B1_START_X + 2, B1_START_X + 3, B1_START_Y + 1, B1_START_Y + 2, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new(" ")
cButton.signal_connect("clicked") {
  $cLatiC.text = (BigDecimal($cLatiC.text) - meter_to_lati(B1_SKEW_SIZE)).to_f().to_s()
  $cLongC.text = (BigDecimal($cLongC.text) + meter_to_long(B1_SKEW_SIZE)).to_f().to_s()
  exec_idevicelocation()
}
$cTable.attach(cButton, B1_START_X + 2, B1_START_X + 3, B1_START_Y + 2, B1_START_Y + 3, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new("v")
cButton.signal_connect("clicked") {
  $cLatiC.text = (BigDecimal($cLatiC.text) - meter_to_lati(B1_MOVE_SIZE)).to_f().to_s()
  exec_idevicelocation()
}
$cTable.attach(cButton, B1_START_X + 1, B1_START_X + 2, B1_START_Y + 2, B1_START_Y + 3, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new(" ")
cButton.signal_connect("clicked") {
  $cLatiC.text = (BigDecimal($cLatiC.text) - meter_to_lati(B1_SKEW_SIZE)).to_f().to_s()
  $cLongC.text = (BigDecimal($cLongC.text) - meter_to_long(B1_SKEW_SIZE)).to_f().to_s()
  exec_idevicelocation()
}
$cTable.attach(cButton, B1_START_X + 0, B1_START_X + 1, B1_START_Y + 2, B1_START_Y + 3, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new("<")
cButton.signal_connect("clicked") {
  $cLongC.text = (BigDecimal($cLongC.text) - meter_to_long(B1_MOVE_SIZE)).to_f().to_s()
  exec_idevicelocation()
}
$cTable.attach(cButton, B1_START_X + 0, B1_START_X + 1, B1_START_Y + 1, B1_START_Y + 2, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new(" ")
cButton.signal_connect("clicked") {
  $cLatiC.text = (BigDecimal($cLatiC.text) + meter_to_lati(B1_SKEW_SIZE)).to_f().to_s()
  $cLongC.text = (BigDecimal($cLongC.text) - meter_to_long(B1_SKEW_SIZE)).to_f().to_s()
  exec_idevicelocation()
}
$cTable.attach(cButton, B1_START_X + 0, B1_START_X + 1, B1_START_Y, B1_START_Y + 1, Gtk::FILL, Gtk::FILL, 0, 0)



aLatiList = []
aLongList = []
create_label("Lati", B1_START_X + 5, B1_START_X + 8, B1_START_Y - 1, B1_START_Y)
create_label("Long", B1_START_X + 8, B1_START_X + 11, B1_START_Y - 1, B1_START_Y)
(0..2).each{|nIdx|
  create_label("Fav#{nIdx + 1}", B1_START_X + 4, B1_START_X + 5, B1_START_Y + nIdx, B1_START_Y + 1 + nIdx)
  aLatiList.push(Gtk::Entry.new())
  aLatiList[nIdx].set_xalign(1)
  aLatiList[nIdx].max_length = 9
  aLatiList[nIdx].text = hSaveData[:LATI_S][nIdx]
  $cTable.attach(aLatiList[nIdx], B1_START_X + 5, B1_START_X + 8, B1_START_Y + nIdx, B1_START_Y + 1 + nIdx, Gtk::FILL, Gtk::FILL, 0, 0)
  aLongList.push(Gtk::Entry.new())
  aLongList[nIdx].set_xalign(1)
  aLongList[nIdx].max_length = 9
  aLongList[nIdx].text = hSaveData[:LONG_S][nIdx]
  $cTable.attach(aLongList[nIdx], B1_START_X + 8, B1_START_X + 11, B1_START_Y + nIdx, B1_START_Y + 1 + nIdx, Gtk::FILL, Gtk::FILL, 0, 0)
  cButton = Gtk::Button.new("Move")
  cButton.signal_connect_after("clicked") {
    $cLatiC.text = aLatiList[nIdx].text
    $cLongC.text = aLongList[nIdx].text
    exec_idevicelocation()
  }
  $cTable.attach(cButton, B1_START_X + 11, B1_START_X + 13, B1_START_Y + nIdx, B1_START_Y + 1 + nIdx, Gtk::FILL, Gtk::FILL, 0, 0)
}



B2_START_X = 1
B2_START_Y = 11

create_label("Setting", B2_START_X + 6, B2_START_X + 8, B2_START_Y - 1, B2_START_Y)
create_label("Amount", B2_START_X + 4, B2_START_X + 6, B2_START_Y + 0, B2_START_Y + 1)
create_label("Count", B2_START_X + 4, B2_START_X + 6, B2_START_Y + 1, B2_START_Y + 2)
create_label("Interval", B2_START_X + 4, B2_START_X + 6, B2_START_Y + 2, B2_START_Y + 3)

cMoveSize = Gtk::Entry.new()
cMoveSize.set_xalign(1)
cMoveSize.text = "2"
$cTable.attach(cMoveSize, B2_START_X + 6, B2_START_X + 8, B2_START_Y + 0, B2_START_Y + 1, Gtk::FILL, Gtk::FILL, 0, 0)
create_label("m", B2_START_X + 8, B2_START_X + 9, B2_START_Y + 0, B2_START_Y + 1)
cMoveCnt = Gtk::Entry.new()
cMoveCnt.set_xalign(1)
cMoveCnt.text = "10"
$cTable.attach(cMoveCnt, B2_START_X + 6, B2_START_X + 8, B2_START_Y + 1, B2_START_Y + 2, Gtk::FILL, Gtk::FILL, 0, 0)
cCntLabel = Gtk::Label.new("", true)
$cTable.attach(cCntLabel, B2_START_X + 8, B2_START_X + 9, B2_START_Y + 1, B2_START_Y + 2, Gtk::FILL, Gtk::FILL, 0, 0)
cMoveInterval = Gtk::Entry.new()
cMoveInterval.set_xalign(1)
cMoveInterval.text = "1"
$cTable.attach(cMoveInterval, B2_START_X + 6, B2_START_X + 8, B2_START_Y + 2, B2_START_Y + 3, Gtk::FILL, Gtk::FILL, 0, 0)
create_label("sec.", B2_START_X + 8, B2_START_X + 9, B2_START_Y + 2, B2_START_Y + 3)


$cCurThread = nil
cButton = Gtk::Button.new("Stop!")
cButton.signal_connect_after("clicked") {
  if (!$cCurThread.nil?)
    Thread.kill($cCurThread)
    cCntLabel.text = ""
    $cCurThread = nil
  end
}
$cTable.attach(cButton, B2_START_X + 9, B2_START_X + 11, B2_START_Y + 1, B2_START_Y + 2, Gtk::FILL, Gtk::FILL, 0, 0)

def error_message()
  cDialog = Gtk::MessageDialog.new($cWindow, Gtk::Dialog::MODAL, Gtk::MessageDialog::WARNING, Gtk::MessageDialog::BUTTONS_OK, "a thread already running")
  cDialog.run
  cDialog.destroy
end

create_label("Move as Setting", B2_START_X, B2_START_X + 3, B2_START_Y - 1, B2_START_Y)

cButton = Gtk::Button.new("^")
cButton.signal_connect_after("clicked") {
  if (!$cCurThread.nil?)
    error_message()
  else
    $cCurThread = Thread.new {
      nTime = cMoveCnt.text.to_i()
      nTime.times{|nCnt|
        cCntLabel.set_text((nCnt + 1).to_s())
        $cLatiC.text = (BigDecimal($cLatiC.text) + meter_to_lati(cMoveSize.text)).to_f().to_s()
        exec_idevicelocation()
        sleep(cMoveInterval.text.to_i())
      }
      cCntLabel.text = ""
      $cCurThread = nil
    }
  end
}
$cTable.attach(cButton, B2_START_X + 1, B2_START_X + 2, B2_START_Y, B2_START_Y + 1, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new(" ")
cButton.signal_connect("clicked") {
  if (!$cCurThread.nil?)
    error_message()
  else
    $cCurThread = Thread.new {
      nTime = cMoveCnt.text.to_i()
      nTime.times{|nCnt|
        cCntLabel.set_text((nCnt + 1).to_s())
        $cLatiC.text = (BigDecimal($cLatiC.text) + meter_to_lati(get_sqrt(cMoveSize.text))).to_f().to_s()
        $cLongC.text = (BigDecimal($cLongC.text) + meter_to_long(get_sqrt(cMoveSize.text))).to_f().to_s()
        exec_idevicelocation()
        sleep(cMoveInterval.text.to_i())
      }
      cCntLabel.text = ""
      $cCurThread = nil
    }
  end
}
$cTable.attach(cButton, B2_START_X + 2, B2_START_X + 3, B2_START_Y, B2_START_Y + 1, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new(">")
cButton.signal_connect("clicked") {
  if (!$cCurThread.nil?)
    error_message()
  else
    $cCurThread = Thread.new {
      nTime = cMoveCnt.text.to_i()
      nTime.times{|nCnt|
        cCntLabel.set_text((nCnt + 1).to_s())
        $cLongC.text = (BigDecimal($cLongC.text) + meter_to_long(cMoveSize.text)).to_f().to_s()
        exec_idevicelocation()
        sleep(cMoveInterval.text.to_i())
      }
      cCntLabel.text = ""
      $cCurThread = nil
    }
  end
}
$cTable.attach(cButton, B2_START_X + 2, B2_START_X + 3, B2_START_Y + 1, B2_START_Y + 2, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new(" ")
cButton.signal_connect("clicked") {
  if (!$cCurThread.nil?)
    error_message()
  else
    $cCurThread = Thread.new {
      nTime = cMoveCnt.text.to_i()
      nTime.times{|nCnt|
        cCntLabel.set_text((nCnt + 1).to_s())
        $cLatiC.text = (BigDecimal($cLatiC.text) - meter_to_lati(get_sqrt(cMoveSize.text))).to_f().to_s()
        $cLongC.text = (BigDecimal($cLongC.text) + meter_to_long(get_sqrt(cMoveSize.text))).to_f().to_s()
        exec_idevicelocation()
        sleep(cMoveInterval.text.to_i())
      }
      cCntLabel.text = ""
      $cCurThread = nil
    }
  end
}
$cTable.attach(cButton, B2_START_X + 2, B2_START_X + 3, B2_START_Y + 2, B2_START_Y + 3, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new("v")
cButton.signal_connect("clicked") {
  if (!$cCurThread.nil?)
    error_message()
  else
    $cCurThread = Thread.new {
      nTime = cMoveCnt.text.to_i()
      nTime.times{|nCnt|
        cCntLabel.set_text((nCnt + 1).to_s())
        $cLatiC.text = (BigDecimal($cLatiC.text) - meter_to_lati(cMoveSize.text)).to_f().to_s()
        exec_idevicelocation()
        sleep(cMoveInterval.text.to_i())
      }
      cCntLabel.text = ""
      $cCurThread = nil
    }
  end
}
$cTable.attach(cButton, B2_START_X + 1, B2_START_X + 2, B2_START_Y + 2, B2_START_Y + 3, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new(" ")
cButton.signal_connect("clicked") {
  if (!$cCurThread.nil?)
    error_message()
  else
    $cCurThread = Thread.new {
      nTime = cMoveCnt.text.to_i()
      nTime.times{|nCnt|
        cCntLabel.set_text((nCnt + 1).to_s())
        $cLatiC.text = (BigDecimal($cLatiC.text) - meter_to_lati(get_sqrt(cMoveSize.text))).to_f().to_s()
        $cLongC.text = (BigDecimal($cLongC.text) - meter_to_long(get_sqrt(cMoveSize.text))).to_f().to_s()
        exec_idevicelocation()
        sleep(cMoveInterval.text.to_i())
      }
      cCntLabel.text = ""
      $cCurThread = nil
    }
  end
}
$cTable.attach(cButton, B2_START_X + 0, B2_START_X + 1, B2_START_Y + 2, B2_START_Y + 3, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new("<")
cButton.signal_connect("clicked") {
  if (!$cCurThread.nil?)
    error_message()
  else
    $cCurThread = Thread.new {
      nTime = cMoveCnt.text.to_i()
      nTime.times{|nCnt|
        cCntLabel.set_text((nCnt + 1).to_s())
        $cLongC.text = (BigDecimal($cLongC.text) - meter_to_long(cMoveSize.text)).to_f().to_s()
        exec_idevicelocation()
        sleep(cMoveInterval.text.to_i())
      }
      cCntLabel.text = ""
      $cCurThread = nil
    }
  end
}
$cTable.attach(cButton, B2_START_X + 0, B2_START_X + 1, B2_START_Y + 1, B2_START_Y + 2, Gtk::FILL, Gtk::FILL, 0, 0)

cButton = Gtk::Button.new(" ")
cButton.signal_connect("clicked") {
  if (!$cCurThread.nil?)
    error_message()
  else
    $cCurThread = Thread.new {
      nTime = cMoveCnt.text.to_i()
      nTime.times{|nCnt|
        cCntLabel.set_text((nCnt + 1).to_s())
        $cLatiC.text = (BigDecimal($cLatiC.text) + meter_to_lati(get_sqrt(cMoveSize.text))).to_f().to_s()
        $cLongC.text = (BigDecimal($cLongC.text) - meter_to_long(get_sqrt(cMoveSize.text))).to_f().to_s()
        exec_idevicelocation()
        sleep(cMoveInterval.text.to_i())
      }
      cCntLabel.text = ""
      $cCurThread = nil
    }
  end
}
$cTable.attach(cButton, B2_START_X + 0, B2_START_X + 1, B2_START_Y, B2_START_Y + 1, Gtk::FILL, Gtk::FILL, 0, 0)



$cWindow.signal_connect(:destroy) {
  hSaveData[:LATI_C] = $cLatiC.text
  hSaveData[:LONG_C] = $cLongC.text
  (0..2).each{|nIdx|
    hSaveData[:LATI_S][nIdx] = aLatiList[nIdx].text
    hSaveData[:LONG_S][nIdx] = aLongList[nIdx].text
  }
  open(SAVE_FILE, "w") do |cIO|
    YAML.dump(hSaveData, cIO)
  end
}



$cWindow.show_all
Gtk.main

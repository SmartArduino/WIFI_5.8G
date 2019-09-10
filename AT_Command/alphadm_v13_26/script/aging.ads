#// con/discon aging test "AP:INC-AP-6F R"
loop 0 10000000
iwconfig disconn
wait 3000
iwconfig conn "INC-AP-6F R" 11 wpa2 ccmp ccmp incqwe!@#
wait 10000
endloop 0
#// Set signal detector threshold to minumum
#
#   This is an AlphaDM example Script
#
#       dedicated scripti function list
#           1. wait [ms]
#

# 802.11b Threshold: (default 0x4c00 <= 0x7c00)
mem set 90003684 5bf3 16 
mem set 9000368A 5b00 16 
wait 1

# OFDM STF Threshold (Xcorr): (default: 10'd 75 < 0x1FF)
mem set 900036a4 4B 16 

wait 1

# OFDM STF Threshold (Acorr): (default: 8'd 31 < 0x7F)
mem set 900036a2 1F 16

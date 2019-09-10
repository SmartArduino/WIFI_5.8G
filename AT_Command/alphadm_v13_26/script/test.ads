#// TxEND RxClear CCA Test
# Common Setting
  # MonSel PAD Setting
  mlme regw 0x84060056 0x803
  wait 10
  
  # MonSel PAD Setting
# mlme regw 0x84060058 0xf00f
  mlme regw 0x84060058 0xf00c
  wait 10
  # Monitor Enable[14], AFE Mux Sel:Rx[3], Tx[2]
  mlme regw 0x84060064 0x4009
  wait 10

# CCA[7], TopState[6:2], TxPE[1], FCS[0]
#  mlme regw 0x8406005c 0x7654
#  wait 10
#  mlme regw 0x8406005a 0x3210
#  wait 10
#  mlme regw 0x840600f0 0x0110
#  wait 10
#  mlme regw 0x90003530 0x0009
#  wait 10
  
# RxClr[7], TopState[6:2], TxPE[1], TxEnd[0]
#  mlme regw 0x8406005c 0x0654
#  wait 10
#  mlme regw 0x8406005a 0x321a
#  wait 10
#  mlme regw 0x840600f0 0x2510
#  wait 10
#  mlme regw 0x90003530 0xd
#  wait 10

# CCA[7], TopState[6:2], TxPE[1], TxEnd[0]
#  mlme regw 0x8406005c 0x7654
#  wait 10
#  mlme regw 0x8406005a 0x321a
#  wait 10
#  mlme regw 0x840600f0 0x2510
#  wait 10
#  mlme regw 0x90003530 0xd
#  wait 10

# CCA[7], TopState[6:2], TxPE[1], RxClr[0]
#  mlme regw 0x8406005c 0x7654
#  wait 10
#  mlme regw 0x8406005a 0x3210
#  wait 10
#  mlme regw 0x840600f0 0x2510
#  wait 10

# TxEnd[7], TopState[6:2], TxPE[1], TxEnd[0]
  mlme regw 0x8406005c 0xa654
  wait 10
  mlme regw 0x8406005a 0x321a
  wait 10
  mlme regw 0x840600f0 0x2510
  wait 10
  mlme regw 0x90003530 0xd
  wait 10

mem cget 84020000,840B0004,8406005c  32 1

# RxClear[7], TopState[6:2], TxPE[1], TxEnd[0]
  mlme regw 0x8406005c 0x0654
  wait 10
  mlme regw 0x8406005a 0x321a
  wait 10
  mlme regw 0x840600f0 0x2510
  wait 10
  mlme regw 0x90003530 0xd
  wait 10

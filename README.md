<b>purchase address：</b>http://www.esp8266module.com/24g58g-dual-band-wifi-module-internet-of-things-wifi-analysis-smart-home-industrial-grade-5g-module-p2119397.html<br>
<h3>WF6000 SDK Development Environment Composition</h3>

<h4>1.1.0 Firmware Build Environment (Linux OS)</h4>

The following information is based on Ubuntu 14.04.
After installing Ubuntu on VirtualBox, set shared folders or install Samba for the convenience of Windows and moving files, Firmware Build and Download.

<h4>1.1.1 Shared Folder Set</h4>

<b>-Select Shared Folder</b>



<p>-Reboot after setting Group to access Shared Folder. [User account: inc]</p>
<p>$ cd /media</p>
<p>$ ls </p>
<p>sf_share</p>
<p>$ sudo usermod –aG vboxsf inc</p>
<p>$ sudo shutdown –r now</p>

<p>-Go to Shared Folder after Rebooting.</p>
<p>$ cd /media/sf_share</p>
<p>$ ls</p>
<p>wf6000_sdk.tar.gz</p>

<h4>1.1.2 VirtualBox Network Setting and Samba Installation</h4>

<h5>a、Set Ubuntu Network</h5>
<h5>b、Install and Set Samba</h5>
<p>$ sudo apt-get install samba samba-common</p>
<p>$ sudo apt-get install system-config-samba cifs-utils</p>
<p>$ cd ~</p>
<p>$ mkdir wf6000</p>
<p>$ sudo vi /etc/samba/smb.conf</p>
<p>[wf6000] </p>
<p>comment = ubuntu samba</p>
<p>read only = no</p>
<p>writable = yes</p>
<p>path = /home/inc/wf6000</p>
<p>guest ok = no</p>
<p>browseable = yes</p>
<p>public = yes</p>
<p>writable = yes</p>

<p>$ sudo smbpasswd -a wf6000</p>
<p>…</p>
<p>$ sudo /etc/init.d/samba restart</p>

<h4>1.1.3 Xtensa toolchain Setting</h4>
<h5>a、Change Permission of xtensa-IncCacheV7-elf.tar.gz.</h5>
<p>$ cd /home/inc</p>
<p>$ sudo tar xfz xtensa-IncCacheV7-elf.tar.gz</p>
<p>$ sudo chmod –R +x xtensa-IncCacheV7-elf</p>
<h5>b、2.Append the following Path to ~./bashrc on the last line</h5>
<p>$ cd ~</p>
<p>$ vi .bashrc</p>
<p>…</p>
<p>export PATH=${PATH}:~/xtensa-IncCacheV7-elf/bin</p>
<p>$ source .bashrc</p>

<h4>1.2 WF6000 SDK Build</h4>
<h4>1.2.1 Copy wf6000_sdk.tar.gz to the working location (samba directory), decompress it, and change Permission</h4>
<p>$ cp wf6000_sdk.tar.gz /home/inc/wf6000</p>
<p>$ sudo tar xfz wf6000_sdk.tar.gz</p>
<p>$ chmod –R +x wf6000_sdk</p>

<h4>1.2.2 Go to examples of wf6000_sdk and proceed with firmware Build. If Build is normal, you can check the below Massage without error.</h4>

<p>$ cd ./wf6000_sdk/examples</p>
<p>$ ls</p>
<p>at_command 、 ping  、  sample   、 sniffer、 wdt</p>
<p>gpio_ext_intr 、  pwm  、  scan   、   socket、 wlan_operation</p>
<p>gpio_led_blink 、 rf_tuning 、 security_engine 、 sw_timer</p>
<p>$ cd ping</p>
<p>$ ls</p>
<p>build.sh  inc 、 src</p>
<p>$ ./build.sh </p>
<p>======================================= CONFIG</p>
<p>CURR_DIR: /home/kdk/kdk_sb/wf6000/release_sdk/wf6000_sdk/examples/ping</p>
<p>USER_DIR: ping</p>
<p>======================================= CLEAN</p>
<p>rm: cannot remove ‘*.bin’: No such file or directory</p>
<p>sf_loader/Makefile:139: bin_info_cfg: No such file or directory</p>
<p>make: *** No rule to make target `bin_info_cfg'.  Stop.</p>
<p>======================================= COMPILE</p>

<p>DRAM code offset : 0x28000</p>
<p>SF code MAX size : 1024 KB</p>
<p>Enable a IRAM OVERLAP in SF_Loader, change a MAX_TEXT_SIZE from 118783 to 131072 bytes</p>
<p>DRAM : starting from 0x3ffa8000 to 0x3ffbffff, length(0x18000)</p>
<p>       (rodata+data: 96KB/160KB) + (bss: 144KB) + (mac_buff: 160KB) = 400KB</p>
<p>IRAM : starting from 0x40000000 to 0x40013fff, length(0x14000)</p>
<p>SROM_CODE : srom_text_size : 0x000909f0 hdr->srom_size : 0x244</p>
<p>SROM_RO_DATA : srom_ro_data_size : 0x00000000 hdr->srom_size : 0x244</p>

<p>FW INFO : AB5 version(0x1A651140:V4416) for SF_LOADER (align 0x1000)</p>
     <p> DRAM 0x3ffa8000 (0096KB:0160KB), CRC16(0xc6c5)</p>
     <p> IRAM 0x40000000 (0080KB:0128KB), CRC16(0xd155)</p>
     <p> SROM 0x5004c000 (0580KB:1024KB), CRC16(0xb2ba)</p>
    <p>  Total sizes : 888832 (0xd9000) Bytes.</p>
<p>4+0 records in</p>
<p>4+0 records out</p>
<p>16384 bytes (16 kB) copied, 0.00353527 s, 4.6 MB/s</p>
<p>217+0 records in</p>
<p>217+0 records out</p>
<p>888832 bytes (889 kB) copied, 0.000856974 s, 1.0 GB/s</p>
<p>======================================= END</p>
<p>$</p>

<h4>1.3 Firmware Download</h4>
<h5>1.Connect the UART0 of WF6000 SFP2501 EVB to PC and run Update Tool.</h5>
<h5>2.When Update Tool is executed, check Uart Port of the connected PC.</h5>
<h5>3.Check UART0 Baudrate of the WF6000 SFP2501 EVB in operation and select it.</h5>
<h5>4.Click FIRMWARE to select the bin file to download</h5>
<p>a、FW_xxxx_AA0_SC0_S401N_MC400D_6L3T_6000.bin (Firmware)
	Select BANK1 or BANK2 to download Firmware</p>
<p>b、FW_xxxx_AA0_SC0_S401N_MC400D_6L3T_6000_ROM.bin (SF_Loader + Firmware)
	If you select BANK0 to download, SF_Loader is downloaded to BANK0 and Firmware is downloaded to Bank1.</p>
<h5>5.Select file and press START to download Firmware.</h5>
<h5>6.When Firmware is normally downloaded, Firmware transfer successful Massage is displayed on the right side. After this, COM Port is automatically closed.</h5>

<h4>1.4 MAC Address Read/Write</h4>
<h5>1.Click Read to read MAC Address.</h5>
<h5>2.If you change the current MAC Address, click WRITE to change MAC Address after editing MAC Address at the bottom</h5>

<h4>1.5 Download with SF_Loader of Mask Rom</h4>
<p>If WF6000 SFP2501 EVB is not operated and Firmware is not downloaded to DM, select MASK ROM to download Firmware</p>
<h5>1.Select Mask Rom</h5>
<h5>2.Baudrate 115200</h5>
<h5>3.Click Firmware</h5>
<h5>4.Select file (FW_xxxx_AA0_SC0_S401N_MC400D_6L3T_6000_ROM.bin)</h5>
<h5>5.After clicking START, if the following dialog box is displayed, power off WF6000 SFP2501 EVB and then on again, Firmware proceeds when Rebooting is detected.</h5>
<h5>6.When Firmware transfer successful Massage is displayed, reset to restart WF6000 SFP2501 EVB.</h5>

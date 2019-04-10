/'
    
    vgmfile.bi
    
    VGMPlay's VGMFile.h translated to FB by Lisa.
    
'/

#Pragma Once
#Include Once "windows.bi"

#Define FCC_VGM                     &h206D6756 '' "Vgm "
#Define FCC_GD3                     &h20336447 '' "Gd3 "
'#Define VOLUME_MODIF_WRAP   &hC0

#Define VGM_DEF_LOOPMOD             &h10 ''default loop modifier

''vgm versions in BCD-code
#Define VGM_VER_100                 &h00000100 ''v1.00
#Define VGM_VER_101                 &h00000101 ''v1.01
#Define VGM_VER_110                 &h00000110 ''v1.10
#Define VGM_VER_150                 &h00000150 ''v1.50
#Define VGM_VER_151                 &h00000151 ''v1.51
#Define VGM_VER_160                 &h00000160 ''v1.60
#Define VGM_VER_161                 &h00000161 ''v1.61
#Define VGM_VER_170                 &h00000170 ''v1.70
#Define VGM_VER_171                 &h00000171 ''v1.71

''VGM offset value pointers
#Define VGM_OFF_EOF                 &h04
#Define VGM_OFF_GD3                 &h14
#Define VGM_OFF_LOOP                &h1C
#Define VGM_OFF_DATA                &h34
#Define VGM_OFF_EXTRA               &hBC

''Sega PSG feedback patterns
#Define VGM_PSGFBP_SN76489          &h0009  ''TI SN76489
#Define VGM_PSGFBP_SN76496          &h0009  ''TI SN76496
#Define VGM_PSGFBP_SMS2             &h0009  ''Sega Master System 2
#Define VGM_PSGFBP_GG               &h0009  ''Sega Game Gear
#Define VGM_PSGFBP_MD               &h0009  ''Sega MegaDrive
#Define VGM_PSGFBP_SN76489AN        &h0003  ''TI SN76489AN
#Define VGM_PSGFBP_SC3000H          &h0003  
#Define VGM_PSGFBP_BBCMICRO         &h0003  ''BBC Micro
#Define VGM_PSGFBP_SN76494          &h0006  ''Texas Instruments SN76494
'#Define VGM_PSGFBP_SN76496          &h0006

''Sega PSG shift register width
#Define VGM_PSGSRW_SN76489          &h0F    ''TI SN76489
#Define VGM_PSGSRW_SN76496          &h0F    ''TI SN76496
#Define VGM_PSGSRW_SMS2             &h0F    ''Sega Master System 2
#Define VGM_PSGSRW_GG               &h0F    ''Sega Game Gear
#Define VGM_PSGSRW_MD               &h0F    ''Sega MegaDrive
#Define VGM_PSGSRW_SN76489AN        &h0E    ''TI SN76489AN
#Define VGM_PSGSRW_SC3000H          &h0E
#Define VGM_PSGSRW_BBCMICRO         &h0E    ''BBC Micro

''Sega PSG flags
#Define VGM_PSGFLAG_FREQ0           &h01    ''frequency 0 is 0x400
#Define VGM_PSGFLAG_NEGATE          &h02    ''output negate flag
#Define VGM_PSGFLAG_NOSTEREO        &h04    ''stereo on/off (on when bit clear)
#Define VGM_PSGFLAG_NOCLOCKDIVIDE   &h08    ''/8 clock divider on/off (on when bit clear)
#Define VGM_PSGFLAG_DEFAULT         &h0C    ''VGM_PSGFLAG_NOCLOCKDIVIDE And VGM_PSGFLAG_NOSTEREO

''AY8910 chip types
#Define VGM_AYTYPE_AY8910           &h00    ''GI AY8910
#Define VGM_AYTYPE_AY8912           &h01    ''GI AY8912
#Define VGM_AYTYPE_AY8913           &h02    ''GI AY8913
#Define VGM_AYTYPE_AY8930           &h03    ''GI AY8930
#Define VGM_AYTYPE_YM2149           &h10    ''Yamaha YM2149
#Define VGM_AYTYPE_YM3439           &h11    ''Yamaha YM3439
#Define VGM_AYTYPE_YMZ284           &h12    ''Yamaha YMZ284
#Define VGM_AYTYPE_YMZ294           &h13    ''Yamaha YMZ294

''Misc AY8910 flags
#Define VGM_AYFLAG_LEGACY           &h00
#Define VGM_AYFLAG_SINGLE           &h01
#Define VGM_AYFLAG_DISCRETE         &h02
#Define VGM_AYFLAG_RAW              &h04
#Define VGM_AYFLAG_DEFAULT          &h01

''Misc flags for the OKIM6258
#Define VGM_OKIMFLAG_CLKDIV0        &h00    ''clock divider setting 0
#Define VGM_OKIMFLAG_CLKDIV1        &h01    ''clock divider setting 1
#Define VGM_OKIMFLAG_CLKDIV2        &h02    ''clock divider setting 2
#Define VGM_OKIMFLAG_CLKDIV3        &h03    ''clock divider setting 3
#Define VGM_OKIMFLAG_ADPCMSEL       &h04    ''3/4-bit ADPCM select
#Define VGM_OKIMFLAG_OUTPUTSEL      &h08    ''10/12-bit output
#Define VGM_OKIMFLAG_DEFAULT        &h00

''Misc flags for the K054539
#Define VGM_K054FLAG_STEREOREVERSE  &h00    ''reverse stereo
#Define VGM_K054FLAG_NOREVERB       &h01    ''disable reverb
#Define VGM_K054FLAG_UPDATEKEYON    &h02    ''update on KeyOn
#Define VGM_K054FLAG_DEFAULT        &h01

''C140 chip types
#Define VGM_C140TYPE_NS2            &h00    ''C140 in Namco System 2
#Define VGM_C140TYPE_NS21A          &h01    ''C140 in Namco System 21a
#Define VGM_C140TYPE_NS21B          &h02    ''C140 in Namco System 21b
#Define VGM_C140TYPE_219ASIC        &h03    ''219 ASIC in Namco NA-1/2

Type VGM_HEADER Field = 1
    fccVGM As DWORD32
    dwEOFOffset As DWORD32
    dwVersion As DWORD32
    dwHzPSG As DWORD32
    dwHzYM2413 As DWORD32
    dwGD3Offset As DWORD32
    dwTotalSamples As DWORD32
    dwLoopOffset As DWORD32
    dwLoopSamples As DWORD32
    dwRate As DWORD32
    wPSGFeedback As WORD
    PSGSRWidth As UByte
    PSGFlags As UByte
    dwHzYM2612 As DWORD32
    dwHzYM2151 As DWORD32
    dwDataOffset As DWORD32
    dwHzSPCM As DWORD32
    dwSPCMIntf As DWORD32
    dwHzRF5C68 As DWORD32
    dwHzYM2203 As DWORD32
    dwHzYM2608 As DWORD32
    dwHzYM3812 As DWORD32
    dwHzYM3526 As DWORD32
    dwHzY8950 As DWORD32
    dwHzYMF262 As DWORD32
    dwHzYMF278B As DWORD32
    dwHzYMF271 As DWORD32
    dwHzYMZ280B As DWORD32
    dwHzRF5C164 As DWORD32
    dwHzPWM As DWORD32
    dwHzAY8910 As DWORD32
    AYType As UByte
    AYFlag As UByte
    AYFlagYM2203 As UByte
    AYFlagYM2608 As UByte
    VolumeModifier As UByte
    Reserved2 As UByte
    LoopBase As Byte
    LoopModifier As Byte
    dwHzGBDMG As DWORD32
    dwHzNESAPU As DWORD32
    dwHzMultiPCM As DWORD32
    dwHzUPD7759 As DWORD32
    dwHzOKIM6258 As DWORD32
    OKI6258Flags As UByte
    K054539Flags As UByte
    C140Type As UByte
    ReservedFlags As UByte
    dwHzOKIM6295 As DWORD32
    dwHzK051649 As DWORD32
    dwHzK054539 As DWORD32
    dwHzHuC6280 As DWORD32
    dwHzC140 As DWORD32
    dwHzK053260 As DWORD32
    dwHzPokey As DWORD32
    dwHzQSound As DWORD32
    dwHzSCSP As DWORD32
    dwExtraOffset As DWORD32
    'dwHzWSwan As DWORD32
End Type

''VGM 1.71 extra header
Type VGMX_HEADER Field = 1
    cbDataSize As SIZE_T        ''size of the extra header in bytes
    dwChp2ClkOffset As DWORD32  ''offset to a VGMX_CLK_HDR
    dwChpVolOffset As DWORD32   ''offset to a VGMX_VOL_HDR
End Type

''VGM 1.71 extra clock header data entry
Type VGMX_CLK_HDR_DATA Field = 1
    chipId As UByte     ''chip type
    dwClock As DWORD32  ''chip's clock
End Type

''VGM 1.71 extra volume header data entry
Type VGMX_VOL_HDR_DATA Field = 1
    chipId As UByte     ''chip type
    uFlags As UByte     ''misc flags
    wVolume As WORD     ''chip's volume
End Type

''VGM 1.71 extra clock header
Type VGMX_CLK_HDR Field = 1
    cEntry As UByte                 ''count of entries
    pEntry As VGMX_CLK_HDR_DATA Ptr ''entries
End Type

''VGM 1.71 extra volume header
Type VGMX_VOL_HDR Field = 1
    cEntry As UByte                 ''count of entries
    pEntry As VGMX_VOL_HDR_DATA Ptr ''entries
End Type


Type VGM_PCM_DATA Field = 1
    cbData As SIZE_T        ''size of lpData in bytes
    lpData As LPBYTE        ''PCM data
    dwDataStart As DWORD32  ''
End Type

Type VGM_PCM_BANK Field = 1
    cBank As ULONG32
    lpBank As VGM_PCM_DATA Ptr
    cbData As SIZE_T
    pData As LPBYTE
    dwDataPos As DWORD32
    dwBankPos As DWORD32
End Type

Type VGM_DATA_BLOCK Field = 1
    wCommand As WORD    ''data block command (0x67 0x66)
    bType As UByte      ''data block type
    cbSize As SIZE_T    ''data block size in bytes
    lpData As LPBYTE    ''data
End Type

Declare Function ReadVGMHead (ByVal hFile As HANDLE, ByVal pVgmHead As VGM_HEADER Ptr) As LRESULT
Declare Function MakeVgmOffsAddrs (ByVal pVgmHead As VGM_HEADER Ptr) As LRESULT
Declare Function MakeVgmAddrsOffs (ByVal pVgmHead As VGM_HEADER Ptr) As LRESULT

''EOF

#Include 'Protheus.ch'

#DEFINE ENABLED 1
#DEFINE ENABLED_WITH_RESTRICTIONS 2
#DEFINE NOT_ENABLED 3

Function FwMdLocRUS()
Local aRet := {}

aAdd(aRet, {01, ENABLED} )  // SIGAATF
aAdd(aRet, {02, ENABLED} )  // SIGACOM
aAdd(aRet, {04, ENABLED} )  // SIGAEST
aAdd(aRet, {05, ENABLED} )  // SIGAFAT
aAdd(aRet, {06, ENABLED} )  // SIGAFIN
aAdd(aRet, {07, ENABLED} )  // SIGAGPE
aAdd(aRet, {09, ENABLED} )  // SIGAFIS
aAdd(aRet, {10, ENABLED} )  // SIGAPCP
aAdd(aRet, {13, ENABLED} )  // SIGATMK
aAdd(aRet, {16, ENABLED} )  // SIGAPON
aAdd(aRet, {19, ENABLED} )  // SIGAMNT
aAdd(aRet, {20, ENABLED} )  // SIGARSP
aAdd(aRet, {21, ENABLED} )  // SIGAQIE
aAdd(aRet, {22, ENABLED} )  // SIGAQMT
aAdd(aRet, {24, ENABLED} )  // SIGAQDO
aAdd(aRet, {25, ENABLED} )  // SIGAQIP
aAdd(aRet, {26, ENABLED} )  // SIGATRM
aAdd(aRet, {28, ENABLED} )  // SIGATEC
aAdd(aRet, {34, ENABLED} )  // SIGACTB
aAdd(aRet, {35, ENABLED} )  // SIGAMDT
aAdd(aRet, {36, ENABLED} )  // SIGAQNC
aAdd(aRet, {37, ENABLED} )  // SIGAQAD
aAdd(aRet, {39, ENABLED} )  // SIGAOMS
aAdd(aRet, {40, ENABLED} )  // SIGACSA
aAdd(aRet, {41, ENABLED} )  // SIGAPEC
aAdd(aRet, {42, ENABLED} )  // SIGAWMS
aAdd(aRet, {43, ENABLED} )  // SIGATMS
aAdd(aRet, {44, ENABLED} )  // SIGAPMS
aAdd(aRet, {45, ENABLED} )  // SIGACDA
aAdd(aRet, {46, ENABLED} )  // SIGAACD
aAdd(aRet, {47, ENABLED} )  // SIGAPPA
aAdd(aRet, {53, ENABLED} )  // SIGAAPD
aAdd(aRet, {56, ENABLED} )  // SIGASGA
aAdd(aRet, {57, ENABLED} )  // SIGAPCO
aAdd(aRet, {58, ENABLED} )  // SIGAGPR
aAdd(aRet, {69, ENABLED} )  // SIGAGCT
aAdd(aRet, {70, ENABLED} )  // SIGAORG
aAdd(aRet, {73, ENABLED} )  // SIGACRM
aAdd(aRet, {78, ENABLED} )  // SIGAGFE
aAdd(aRet, {79, ENABLED} )  // SIGASFC
aAdd(aRet, {82, ENABLED} )  // SIGADPR
aAdd(aRet, {87, ENABLED} )  // SIGAGCP
aAdd(aRet, {89, ENABLED} )  // SIGATUR
aAdd(aRet, {99, ENABLED} )  // SIGACFG

Return aRet

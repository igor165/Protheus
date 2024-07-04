#include 'Protheus.ch'

#define GUIA_CONSULTA 	'01'
#define GUIA_SADT		'02'
#define GUIA_INTERNACAO	'05'
#define GUIA_HONORARIO 	'06'

//--------------------------------------------------------------------
/*/{Protheus.doc} PLSGRVCONTA

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
function PLSGRVCONTA(cAlias, aCab, aBD6, aBD6Gen, aBX6, aB43, aTpParc, aVlr, aBD7Gen, aCodUnm, cDataPag )
local aDadRda   := PLSGETRDA()
local cNumGui   := PLSA500NUM(cAlias, BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG)
local nX        := 1
local cSequen   := '000'
local cTipAdm   := getNewPar("MV_PLSTPAD","1")

private cPLSCAUX := getNewPar("MV_PLSCAUX","AUX")

aadd(aCab, {cAlias + "_FILIAL", xfilial(cAlias)})
aadd(aCab, {cAlias + "_CODOPE", BCI->BCI_CODOPE})
aadd(aCab, {cAlias + "_CODLDP", BCI->BCI_CODLDP})
aadd(aCab, {cAlias + "_CODPEG", BCI->BCI_CODPEG})
aadd(aCab, {cAlias + "_CODRDA", BCI->BCI_CODRDA})
aadd(aCab, {cAlias + "_NOMRDA", BCI->BCI_NOMRDA})
aadd(aCab, {cAlias + "_OPERDA", BCI->BCI_CODOPE})
aadd(aCab, {cAlias + "_OPESOL", BCI->BCI_CODOPE})
aadd(aCab, {cAlias + "_OPEEXE", BCI->BCI_CODOPE})
aadd(aCab, {cAlias + "_NUMERO", cNumGui})
aadd(aCab, {cAlias + "_TIPGUI", BCI->BCI_TIPGUI })
aadd(aCab, {cAlias + "_FASE",   "1" })
aadd(aCab, {cAlias + "_SITUAC", BCI->BCI_SITUAC })
aadd(aCab, {cAlias + "_DTDIGI", date() })
aadd(aCab, {cAlias + "_MATUSA", "1" })
aadd(aCab, {cAlias + "_PACOTE", "0" })
aadd(aCab, {cAlias + "_ORIMOV", iif(BCI->BCI_TIPGUI == GUIA_INTERNACAO,'2','1') })
aadd(aCab, {cAlias + "_SITRG",  "0" })
aadd(aCab, {cAlias + "_RGIMP",  "1" })
aadd(aCab, {cAlias + "_PODRFS", "1" })
aadd(aCab, {cAlias + "_STAFAT", "1" })
aadd(aCab, {cAlias + "_BLOPAG", "0" })
aadd(aCab, {cAlias + "_TPGRV",  "4" })
aadd(aCab, {cAlias + "_MESPAG", iif( empty(cDataPag), strzero(month(date()),2), left(cDataPag,2))})
aadd(aCab, {cAlias + "_ANOPAG", iif( empty(cDataPag), cvaltochar(year(date())), right(cDataPag,4))})
aadd(aCab, {cAlias + "_TIPPRE", BAU->BAU_TIPPRE })
aadd(aCab, {cAlias + "_LOCAL ", aDadRda[13] })
aadd(aCab, {cAlias + "_CODLOC", aDadRda[12] })
aadd(aCab, {cAlias + "_SEQIMP",substr(BCI->BCI_LOTEDI, 5)  })

if BCI->BCI_TIPGUI <> GUIA_INTERNACAO
    aadd(aCab, {"BD5_DESLOC", aDadRda[19] })
    aadd(aCab, {"BD5_TIPRDA", aDadRda[8]  })
    aadd(aCab, {"BD5_GUIACO", "0" })
    aadd(aCab, {"BD5_LIBERA", "0" })
    aadd(aCab, {"BD5_ATEAMB", "1" })
    aadd(aCab, {"BD5_CPFRDA", BAU->BAU_CPFCGC })
    aadd(aCab, {"BD5_ENDLOC", aDadRda[20] })
endif

if BCI->BCI_TIPGUI == GUIA_HONORARIO
    aadd(aCab, {"BD5_REGFOR", "1"})
    aadd(aCab, {"BD5_TIPFAT", "1"})
    aadd(aCab, {"BD5_TIPCON", "4"})
    aadd(aCab, {"BD5_TIPCON", "4"})
    aadd(aCab, {"BD5_TIPATE", "05"})
    aadd(aCab, {"BD5_TIPADM", cTipAdm})
endif

if BCI->BCI_TIPGUI == GUIA_CONSULTA
    aadd(aCab, {"BD5_TIPATE", "04"})
    aadd(aCab, {"BD5_TIPADM", cTipAdm})
endif

if BCI->BCI_TIPGUI == GUIA_INTERNACAO
    aadd(aCab, {"BE4_ERRO",     "0"})
    aadd(aCab, {"BE4_AUDITO",   "0"})
    aadd(aCab, {"BE4_STATUS",   "1"})
    aadd(aCab, {"BE4_CANCEL",   "0"})
    aadd(aCab, {"BE4_DESOPE",   PLRETOPE()})
endif

commit(cAlias,aCab)

aadd(aBD6Gen, {"BD6_FILIAL", xFilial("BD6")})
aadd(aBD6Gen, {"BD6_CODOPE", BCI->BCI_CODOPE})
aadd(aBD6Gen, {"BD6_CODLDP", BCI->BCI_CODLDP})
aadd(aBD6Gen, {"BD6_CODPEG", BCI->BCI_CODPEG})
aadd(aBD6Gen, {"BD6_NUMERO", cNumGui})
aadd(aBD6Gen, {"BD6_TIPGUI", BCI->BCI_TIPGUI })
aadd(aBD6Gen, {"BD6_FASE",   "1" })
aadd(aBD6Gen, {"BD6_BLOCPA", "0" })
aadd(aBD6Gen, {"BD6_INCAUT", "1" })
aadd(aBD6Gen, {"BD6_TPGRV ", "4"})
aadd(aBD6Gen, {"BD6_ORIMOV", iif(BCI->BCI_TIPGUI == GUIA_INTERNACAO,'2','1') })
aadd(aBD6Gen, {"BD6_STATUS", "1"})
aadd(aBD6Gen, {"BD6_NUMIMP", (cAlias)->&(cAlias+"_NUMIMP")})
aadd(aBD6Gen, {"BD6_OPEUSR", (cAlias)->&(cAlias+"_OPEUSR")})
aadd(aBD6Gen, {"BD6_MATANT", (cAlias)->&(cAlias+"_MATANT")})
aadd(aBD6Gen, {"BD6_NOMUSR", (cAlias)->&(cAlias+"_NOMUSR")})
aadd(aBD6Gen, {"BD6_CODRDA", (cAlias)->&(cAlias+"_CODRDA")})
aadd(aBD6Gen, {"BD6_OPERDA", (cAlias)->&(cAlias+"_OPERDA")})
if BCI->BCI_TIPGUI <> GUIA_INTERNACAO
    aadd(aBD6Gen, {"BD6_TIPRDA", (cAlias)->BD5_TIPRDA})
    aadd(aBD6Gen, {"BD6_DESLOC", (cAlias)->BD5_DESLOC})
    aadd(aBD6Gen, {"BD6_ENDLOC", (cAlias)->BD5_ENDLOC})
    aadd(aBD6Gen, {"BD6_ATEAMB", (cAlias)->BD5_ATEAMB})
    aadd(aBD6Gen, {"BD6_CPFRDA", (cAlias)->BD5_CPFRDA})
    aadd(aBD6Gen, {"BD6_NUMATE", (cAlias)->BD5_NUMATE})
    aadd(aBD6Gen, {"BD6_SIGEXE", (cAlias)->BD5_SIGEXE})
    aadd(aBD6Gen, {"BD6_GUIACO", (cAlias)->BD5_GUIACO})
    aadd(aBD6Gen, {"BD6_QUACOB", (cAlias)->BD5_QUACOB})
    aadd(aBD6Gen, {"BD6_LIBERA", (cAlias)->BD5_LIBERA})
    aadd(aBD6Gen, {"BD6_LOCREQ", (cAlias)->BD5_LOCREQ})
    aadd(aBD6Gen, {"BD6_SOLORI", (cAlias)->BD5_SOLORI})
    aadd(aBD6Gen, {"BD6_NRLBOR", (cAlias)->BD5_NRLBOR}) 
endif
aadd(aBD6Gen, {"BD6_NOMRDA", (cAlias)->&(cAlias+"_NOMRDA")})
aadd(aBD6Gen, {"BD6_CODESP", (cAlias)->&(cAlias+"_CODESP")})
aadd(aBD6Gen, {"BD6_SUBESP", (cAlias)->&(cAlias+"_SUBESP")})
aadd(aBD6Gen, {"BD6_CID",    (cAlias)->&(cAlias+"_CID")})
aadd(aBD6Gen, {"BD6_ESTSOL", (cAlias)->&(cAlias+"_ESTSOL")})
aadd(aBD6Gen, {"BD6_SIGLA" , (cAlias)->&(cAlias+"_SIGLA")})
aadd(aBD6Gen, {"BD6_REGSOL", (cAlias)->&(cAlias+"_REGSOL")})
aadd(aBD6Gen, {"BD6_NOMSOL", (cAlias)->&(cAlias+"_NOMSOL")})
aadd(aBD6Gen, {"BD6_TIPCON", (cAlias)->&(cAlias+"_TIPCON")})
aadd(aBD6Gen, {"BD6_TIPGUI", (cAlias)->&(cAlias+"_TIPGUI")})
aadd(aBD6Gen, {"BD6_CDPFSO", (cAlias)->&(cAlias+"_CDPFSO")})
aadd(aBD6Gen, {"BD6_CODEMP", (cAlias)->&(cAlias+"_CODEMP")})
aadd(aBD6Gen, {"BD6_MATRIC", (cAlias)->&(cAlias+"_MATRIC")})
aadd(aBD6Gen, {"BD6_TIPREG", (cAlias)->&(cAlias+"_TIPREG")})
aadd(aBD6Gen, {"BD6_IDUSR" , (cAlias)->&(cAlias+"_IDUSR")})
aadd(aBD6Gen, {"BD6_DATNAS", (cAlias)->&(cAlias+"_DATNAS")})
aadd(aBD6Gen, {"BD6_SITUAC", (cAlias)->&(cAlias+"_SITUAC")})
aadd(aBD6Gen, {"BD6_DIGITO", (cAlias)->&(cAlias+"_DIGITO")})
aadd(aBD6Gen, {"BD6_CONEMP", (cAlias)->&(cAlias+"_CONEMP")})
aadd(aBD6Gen, {"BD6_VERCON", (cAlias)->&(cAlias+"_VERCON")})
aadd(aBD6Gen, {"BD6_SUBCON", (cAlias)->&(cAlias+"_SUBCON")})
aadd(aBD6Gen, {"BD6_VERSUB", (cAlias)->&(cAlias+"_VERSUB")})
aadd(aBD6Gen, {"BD6_LOCAL",  (cAlias)->&(cAlias+"_LOCAL")})
aadd(aBD6Gen, {"BD6_CODLOC", (cAlias)->&(cAlias+"_CODLOC")})
aadd(aBD6Gen, {"BD6_MATVID", (cAlias)->&(cAlias+"_MATVID")})
aadd(aBD6Gen, {"BD6_DTDIGI", (cAlias)->&(cAlias+"_DTDIGI")})
aadd(aBD6Gen, {"BD6_MATUSA", (cAlias)->&(cAlias+"_MATUSA")})
aadd(aBD6Gen, {"BD6_GUIORI", (cAlias)->&(cAlias+"_GUIORI")})
aadd(aBD6Gen, {"BD6_PACOTE", (cAlias)->&(cAlias+"_PACOTE")})
aadd(aBD6Gen, {"BD6_REGEXE", (cAlias)->&(cAlias+"_REGEXE")})
aadd(aBD6Gen, {"BD6_OPEEXE", (cAlias)->&(cAlias+"_OPEEXE")})
aadd(aBD6Gen, {"BD6_CDPFRE", (cAlias)->&(cAlias+"_CDPFRE")})
aadd(aBD6Gen, {"BD6_ESTEXE", (cAlias)->&(cAlias+"_ESTEXE")})
aadd(aBD6Gen, {"BD6_MESPAG", (cAlias)->&(cAlias+"_MESPAG")})
aadd(aBD6Gen, {"BD6_ANOPAG", (cAlias)->&(cAlias+"_ANOPAG")})
aadd(aBD6Gen, {"BD6_OPELOT", (cAlias)->&(cAlias+"_OPELOT")})
aadd(aBD6Gen, {"BD6_NUMLOT", (cAlias)->&(cAlias+"_NUMLOT")})
aadd(aBD6Gen, {"BD6_PAGATO", (cAlias)->&(cAlias+"_PAGATO")})
aadd(aBD6Gen, {"BD6_CC",     (cAlias)->&(cAlias+"_CC")})
aadd(aBD6Gen, {"BD6_RGIMP",  (cAlias)->&(cAlias+"_RGIMP")})
aadd(aBD6Gen, {"BD6_NRAEMP", (cAlias)->&(cAlias+"_NRAEMP")})
aadd(aBD6Gen, {"BD6_TPGRV",  (cAlias)->&(cAlias+"_TPGRV")})
aadd(aBD6Gen, {"BD6_SEQIMP", substr(BCI->BCI_LOTEDI, 5)})
aadd(aBD6Gen, {"BD6_OPEFAT", (cAlias)->&(cAlias+"_OPEFAT")})
aadd(aBD6Gen, {"BD6_NUMFAT", (cAlias)->&(cAlias+"_NUMFAT")})
aadd(aBD6Gen, {"BD6_STAFAT", (cAlias)->&(cAlias+"_STAFAT")})
aadd(aBD6Gen, {"BD6_INTFAT", (cAlias)->&(cAlias+"_INTFAT")})
aadd(aBD6Gen, {"BD6_BLOPAG", (cAlias)->&(cAlias+"_BLOPAG")})
aadd(aBD6Gen, {"BD6_MOTBPG", (cAlias)->&(cAlias+"_MOTBPG")})
aadd(aBD6Gen, {"BD6_DESBPG", (cAlias)->&(cAlias+"_DESBPG")})
aadd(aBD6Gen, {"BD6_LOTGUI", (cAlias)->&(cAlias+"_LOTGUI")})
aadd(aBD6Gen, {"BD6_DTRECE", (cAlias)->&(cAlias+"_DTRECE")})
aadd(aBD6Gen, {"BD6_DTANAL", (cAlias)->&(cAlias+"_DTANAL")})
aadd(aBD6Gen, {"BD6_DTPAGT", (cAlias)->&(cAlias+"_DTPAGT")})
aadd(aBD6Gen, {"BD6_SEQNFS", (cAlias)->&(cAlias+"_SEQNFS")})
aadd(aBD6Gen, {"BD6_LANCF",  (cAlias)->&(cAlias+"_LANCF")})
aadd(aBD6Gen, {"BD6_LOTEDI", (cAlias)->&(cAlias+"_LOTEDI")})
aadd(aBD6Gen, {"BD6_ESPEXE", (cAlias)->&(cAlias+"_ESPEXE")})
aadd(aBD6Gen, {"BD6_SITRG",  (cAlias)->&(cAlias+"_SITRG")})
aadd(aBD6Gen, {"BD6_ESPSOL", (cAlias)->&(cAlias+"_ESPSOL")})
if ( cAlias == "BD5" .and. BD6->(FieldPos("BD6_DATSOL")) > 0 ) //o cliente do chamado possui esse campo padrão no dicionário, confirmado pelo suporte
    aadd(aBD6Gen, {"BD6_DATSOL", (cAlias)->&(cAlias+"_DATSOL")})
endif

for nX := 1 to len(aBD6)
    if len(aBD6[nX]) > 0
        cSequen := soma1(cSequen)
        gravaEvento(aBD6[nX], aBD6Gen, aBD7Gen, aBX6[nX], aB43[nX], cSequen, cAlias, aTpParc[nX], aVlr[nX], aCodUnm)
    endif
next

//atualiza _QTDEVE para BD5/BE4
atualQTDEVE(cAlias, cNumGui)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} gravaEvento

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
static function gravaEvento(aBD6, aBD6Gen, aBD7Gen, aBX6, aB43, cSequen, cAlias, aTpParc, aVlr, aCodUnm)
local nFor      := 0
local cCdPac    := GetNewPar("MV_PLPACPT","99999998")
local aChave    := {}

commit('BD6',aBD6)
commit('BD6',aBD6Gen,.f.)

aCpoNiv := PLSUpCpoNv(BD6->BD6_CODPAD,BD6->BD6_CODPRO,"BD6")	

BR8->(MsSeek(xFilial("BR8")+BD6->BD6_CODPAD+BD6->BD6_CODPRO))	
BD6->(recLock("BD6",.f.))	
	BD6->BD6_SEQUEN := cSequen
	for nFor := 1 To Len(aCpoNiv)
		&(aCpoNiv[nFor,1]) := (aCpoNiv[nFor,2])
	next
	BD6->BD6_VLRAPR := BD6->BD6_VALORI / BD6->BD6_QTDPRO
    if empty(BD6->BD6_CD_PAC)
	    BD6->BD6_DESPRO := BR8->BR8_DESCRI
    endif
	BD6->BD6_NIVEL  := BR8->BR8_NIVEL	
	BD6->BD6_PROCCI := If(BR8->BR8_TIPEVE$"2,3","1","0")
	
	aCodTab := PLSRETTAB(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_DATPRO,;
						BD6->BD6_CODOPE,BD6->BD6_CODRDA,BD6->BD6_CODESP,BD6->BD6_SUBESP,BD6->(BD6_CODLOC+BD6_LOCAL),;
						BD6->BD6_DATPRO,"1",BD6->BD6_OPEORI,BD6->BD6_CODPLA,"2","1")
	
    cTpeVct := plTpServ(BD6->BD6_CODPAD, BD6->BD6_CODPRO, BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG), cAlias)	
	BD6->BD6_TPEVCT :=  cTpeVct	

	if aCodTab[1]
		BD6->BD6_CODTAB := aCodTab[3]
		BD6->BD6_ALIATB := aCodTab[4]
	endif
BD6->(msUnlock())

setBD7(aBD7Gen, aTpParc, aVlr, aCodUnm)

BX6->(RecLock("BX6",.t.))
//Chave da BX6
BX6->BX6_FILIAL := xFilial("BX6")
BX6->BX6_CODOPE := BD6->BD6_CODOPE
BX6->BX6_CODLDP := BD6->BD6_CODLDP
BX6->BX6_CODPEG := BD6->BD6_CODPEG
BX6->BX6_NUMERO := BD6->BD6_NUMERO
BX6->BX6_ORIMOV := BD6->BD6_ORIMOV
BX6->BX6_SEQUEN := BD6->BD6_SEQUEN
BX6->BX6_CODPAD := BD6->BD6_CODPAD
BX6->BX6_CODPRO := BD6->BD6_CODPRO
BX6->(MsUnLock())
commit("BX6",aBX6,.f.)

if len(aB43) > 0
    gravaPac(aB43)
endif

if alltrim(BD6->BD6_CODPRO) == alltrim(cCdPac)
    aChave		:= {BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV}
	if !PLSPACWEB(BD6->BD6_CODOPE,BD6->BD6_OPEORI,BD6->BD6_SEQUEN,alltrim(BD6->BD6_CD_PAC),;
						BD6->BD6_CODRDA,BD6->BD6_DATPRO,aChave,'BD6','')
        if B6L->( FieldPos("B6L_CODLDP") ) > 0 .and. B6L->( FieldPos("B6L_CODPEG") ) > 0 .and. B6L->( FieldPos("B6L_NUMERO") ) > 0 .and. B6L->( FieldPos("B6L_ORIMOV") ) > 0
            B6L->(RecLock("B6L",.T.))
            B6L->B6L_FILIAL := xFilial("B6L")
            B6L->B6L_OPEMOV := BD6->BD6_CODOPE
            B6L->B6L_CODLDP := BD6->BD6_CODLDP
            B6L->B6L_CODPEG := BD6->BD6_CODPEG
            B6L->B6L_NUMERO := BD6->BD6_NUMERO
            B6L->B6L_SEQUEN := BD6->BD6_SEQUEN
            B6L->B6L_ORIMOV := BD6->BD6_ORIMOV
            B6L->B6L_ALIAS  := "BD6"
            B6L->B6L_UNIORI := BRJ->BRJ_OPEORI
            B6L->B6L_CODRDA := BD6->BD6_RDAEDI
            B6L->B6L_DTATEN := BD6->BD6_DATPRO
            B6L->B6L_CODPAC := BD6->BD6_CD_PAC
            B6L->B6L_COMUNI := "0"
            B6L->B6L_NRTROL := ""
            B6L->( MsUnLock() )
        endif
    endif
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} setBD7

@author    Lucas Nonato
@version   V12
@since     23/09/2020
/*/
static function setBD7(aBD7Gen, aTpParc, aVlr, aCodUnm)
local aCompo    := {}
local aCompoVld := {}
local nInd      := 1
local nX        := 1
local nPos      := 1
local cHM       := aCodUnm[1] 
local cAux      := aCodUnm[2] 
local cPA       := aCodUnm[3] 
local cCO       := aCodUnm[4]
local cFIL      := aCodUnm[5]
local cUndAux   := ''
local cUnd      := ''
local cTpPart   := ''

aCompo := PLSCOMEVE(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO)

for nX := 1 to len(aCompo)
    aadd(aCompoVld,{.t.,0})
next

//Comparo as composições do arquivo com as da TDE
for nX := 1 to len(aCompo)
    cUnd    := aCompo[nX,1]
    nPos    := 0
    cTpPart := alltrim(aCompo[nX,16])
	cUndAux := iif(alltrim(cUnd) $ cPLSCAUX,strZero(aCompo[nX,3],2),"") 
    do case
        case cUnd $ cCO
            if aVlr[2] > 0
               loop
            else
                aCompoVld[nX][1] := .f.
            endif
        case cUnd $ cFIL
            if aVlr[3] > 0
                loop
            else
                aCompoVld[nX][1] := .f.
            endif            
        otherwise
            if aVlr[1] > 0 

                if len(aTpParc) == 0
                    loop
                else
                    if alltrim(aCompo[nX][1]) $ cAux
                        if (nPos := ascan(aTpParc,{|x| x[3] == strZero(aCompo[nX,3],2)})) > 0 
                            aCompoVld[nX][2] := nPos
                        else
                            aCompoVld[nX][1] := .f.
                        endif
                    elseif alltrim(aCompo[nX][1]) $ cPA
                        if (nPos := ascan(aTpParc,{|x| x[3] $ "06;07"})) > 0 
                            aCompoVld[nX][2] := nPos
                        else
                            aCompoVld[nX][1] := .f.
                        endif
                    else
                        if (nPos := ascan(aTpParc,{|x| !(x[3] $ "01;02;03;04;06;07;11")})) > 0 
                            aCompoVld[nX][2] := nPos
                        else
                            aCompoVld[nX][1] := .f.
                        endif
                    endif
                endif
            else
                aCompoVld[nX][1] := .f.
            endif
    endcase
next


/*
00    Cirurgião
01    Primeiro Auxiliar
02    Segundo Auxiliar
03    Terceiro Auxiliar
04    Quarto Auxiliar
05    Instrumentador
06    Anestesista
07    Auxiliar de Anestesista
09    Perfusionista
10    Pediatra na sala de parto
11    Auxiliar SADT
12    Clínico
13    Intensivista
*/

// Se nenhuma participação bate com a TDE e não foi informado participação eu crio tudo da TDE. 
if ascan(aCompoVld,{|x| x[1] }) == 0 

    if ascan(aTpParc,{|x| (x[3] == "")}) >0
        for nX := 1 to len(aCompoVld)
            aCompoVld[nX][1] := .t.
        next
    else
        gravaBD7({"UNL",'','',0,''},,aBD7Gen,aCodUnm,aVlr)// Se nenhuma participação bate com a TDE mas veio tp_Participacao no xml crio UNL 
    endif
endif

for nInd := 1 to len(aCompo)
    cUnd    := aCompo[nInd,1]
    nPos    := 0
    cTpPart := alltrim(aCompo[nInd,16])
	cUndAux := iif(alltrim(cUnd) $ cPLSCAUX,strZero(aCompo[nInd,3],2),"")
	if BD7->( msseek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)+cUnd+cUndAux))
		loop
	endIf

    if !aCompoVld[nInd][1]
		loop
	endIf   
               
    aRegBD7 := {cUnd,iif(alltrim(cUnd) $ cPLSCAUX,strZero(aCompo[nInd,3],2),""),aCompo[nInd,7],aCompo[nInd,3],aCompo[nInd,16]}
    gravaBD7(aRegBD7,iif(aCompoVld[nInd][2]>0,aTpParc[aCompoVld[nInd][2]],{}),aBD7Gen,aCodUnm,aVlr)
	
next

return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} gravaBD7

@author    Lucas Nonato
@version   V12
@since     23/09/2020
/*/
static function gravaBD7(aRegBD7,aTpParc,aBD7Gen,aCodUnm,aVlr)
local lGenerico  := .f.
local nPosvlapr  := 0
local nPostxapr  := 0
local nI         := 0
local nVlrUNL    := 0
local nTxUNL     := 0
local cEspExe    := ""
local cDesEspExe := ""
default aTpParc  := {}
default aBD7Gen  := {}
default aVlr     := {}

BusEspExe(@cEspExe,@cDesEspExe,aTpParc)

BD7->(recLock("BD7",.t.))
BD7->BD7_FILIAL 	:= xFilial("BD7")
BD7->BD7_CODOPE 	:= BD6->BD6_CODOPE
BD7->BD7_CODLDP 	:= BD6->BD6_CODLDP
BD7->BD7_CODPEG 	:= BD6->BD6_CODPEG
BD7->BD7_NUMERO 	:= BD6->BD6_NUMERO
BD7->BD7_SEQUEN 	:= BD6->BD6_SEQUEN
BD7->BD7_CODPRO 	:= BD6->BD6_CODPRO
BD7->BD7_CODPAD 	:= BD6->BD6_CODPAD
BD7->BD7_CODRDA     := BCI->BCI_CODRDA
BD7->BD7_NOMRDA     := BCI->BCI_NOMRDA
BD7->BD7_TIPINT     := BD6->BD6_TIPINT
BD7->BD7_LIBERA 	:= BD6->BD6_LIBERA
BD7->BD7_CC     	:= BD6->BD6_CC
BD7->BD7_NUMIMP 	:= BD6->BD6_NUMIMP
BD7->BD7_TIPUSR 	:= BD6->BD6_TIPUSR
BD7->BD7_PERHES 	:= BD6->BD6_PERHES
BD7->BD7_LOTGUI 	:= BD6->BD6_LOTGUI
BD7->BD7_NOMUSR 	:= BD6->BD6_NOMUSR
BD7->BD7_INTERC 	:= BD6->BD6_INTERC
BD7->BD7_SEQIMP 	:= BD6->BD6_SEQIMP
BD7->BD7_ESPSOL 	:= BD6->BD6_ESPSOL
BD7->BD7_TIPGUI 	:= BD6->BD6_TIPGUI
BD7->BD7_CID		:= BD6->BD6_CID
BD7->BD7_SEQNFS     := BD6->BD6_SEQNFS
BD7->BD7_OPEUSR 	:= BD6->BD6_OPEUSR
BD7->BD7_TIPREG 	:= BD6->BD6_TIPREG
BD7->BD7_MATRIC 	:= BD6->BD6_MATRIC
BD7->BD7_CODEMP 	:= BD6->BD6_CODEMP
BD7->BD7_CONEMP 	:= BD6->BD6_CONEMP
BD7->BD7_SUBCON 	:= BD6->BD6_SUBCON
BD7->BD7_VERSUB 	:= BD6->BD6_VERSUB
BD7->BD7_VERCON 	:= BD6->BD6_VERCON
BD7->BD7_BLOPAG 	:= BD6->BD6_BLOPAG
BD7->BD7_MOTBLO 	:= BD6->BD6_MOTBPG
BD7->BD7_DESBLO 	:= BD6->BD6_DESBPG
BD7->BD7_TPGRV  	:= BD6->BD6_TPGRV
BD7->BD7_CODPLA 	:= BD6->BD6_CODPLA
BD7->BD7_ANOPAG 	:= BD6->BD6_ANOPAG
BD7->BD7_MESPAG 	:= BD6->BD6_MESPAG
BD7->BD7_DATPRO 	:= BD6->BD6_DATPRO
BD7->BD7_ORIMOV 	:= BD6->BD6_ORIMOV
BD7->BD7_CODESP 	:= cEspExe
BD7->BD7_DESESP 	:= cDesEspExe
BD7->BD7_MODCOB 	:= BD6->BD6_MODCOB
BD7->BD7_CONMFT 	:= BR8->BR8_CONMFT
BD7->BD7_DTDIGI 	:= BD6->BD6_DTDIGI	
BD7->BD7_LOCATE 	:= BD6->(BD6_CODLOC+BD6_LOCAL)
BD7->BD7_LOCAL  	:= BD6->BD6_LOCAL
BD7->BD7_CODLOC 	:= BD6->BD6_CODLOC
BD7->BD7_FASE		:= BD6->BD6_FASE
BD7->BD7_SITUAC 	:= BD6->BD6_SITUAC
BD7->BD7_DESLOC 	:= BD6->BD6_DESLOC
BD7->BD7_TIPRDA     := BD6->BD6_TIPRDA
BD7->BD7_PROCCI 	:= if(BR8->BR8_TIPEVE $ "2,3","1","0")
BD7->BD7_PROBD7 	:= "1"	
BD7->BD7_CLAINS     := PLSCLAINS()	
BD7->BD7_CODUNM     := aRegBD7[1]
BD7->BD7_NLANC      := aRegBD7[2]
BD7->BD7_UNITDE     := aRegBD7[3]
BD7->BD7_REFTDE     := aRegBD7[4]
BD7->BD7_CODTPA     := aRegBD7[5]


//Posições avlr
// 1 e 4 = Valor de HM
// 2 e 5 = Valor de CO
// 3 e 6 = valor de FIL

if aRegBD7[1] == "UNL" .and. len(avlr) > 0

    for nI:=1 to 3 
        if avlr[nI] > 0 
            nVlrUNL +=avlr[nI]
        endif
    next

    for nI:=4 to 6 
        if avlr[nI] > 0 
            nTxUNL +=avlr[nI]
        endif
    next

    BD7->BD7_VLADSE     := nTxUNL 
    BD7->BD7_VLTXAP     := nTxUNL 
    BD7->BD7_VLAPAJ     := nVlrUNL - nTxUNL 
    BD7->BD7_VLRAPR     := nVlrUNL - nTxUNL
    BD7->BD7_PERCEN     := 100   //Apenas para os casos de UNl

else

    if aRegBD7[1] $ aCodUnm[4]
        nPosvlapr := 2
        nPostxapr := 5
    elseif  aRegBD7[1] $ aCodUnm[5]
        nPosvlapr := 3
        nPostxapr := 6
    else
        nPosvlapr := 1
        nPostxapr := 4
    endif            

    BD7->BD7_VLADSE     := aVlr[nPostxapr] //taxa apresentada no ajius,  esse campo se faz necessário pois é usado na exportação do a550 
    BD7->BD7_VLAPAJ     := aVlr[nPosvlapr] - aVlr[nPostxapr]//valor apresentado ajius: esse campo se faz necessário pois é usado na exportação do a550
    aVlr[nPosvlapr]     := 0
    aVlr[nPostxapr]     := 0

endif

if len(aTpParc) > 0 
    BD7->BD7_REGPRE := aTpParc[7]
	BD7->BD7_SIGLA  := aTpParc[6]
	BD7->BD7_ESTPRE := aTpParc[5]
	BD7->BD7_NOMPRE := aTpParc[8]
	BD7->BD7_CDPFPR := aTpParc[9]
elseif !empty(BD6->BD6_REGEXE)
	BD7->BD7_REGPRE := BD6->BD6_REGEXE
	BD7->BD7_SIGLA  := BD6->BD6_SIGEXE
	BD7->BD7_ESTPRE := BD6->BD6_ESTEXE
	BD7->BD7_NOMPRE := BB0->(posicione("BB0",4,xFilial("BB0")+BD7->(BD7_ESTPRE+BD7_REGPRE+BD7_SIGLA),"BB0_NOME") )		
	BD7->BD7_CDPFPR := BD6->BD6_CDPFSO
elseif len(aBD7Gen) > 0
    lGenerico := .t.
endif		

BD7->(msUnLock())

if lGenerico 
    commit('BD7',aBD7Gen,.f.)
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} commit

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
static function commit(cAlias, aDados, lNew)
local nX as numeric
default lNew := .t.

(cAlias)->(recLock(cAlias, lNew ))
for nX := 1 To Len(aDados)
	(cAlias)->(fieldPut((cAlias)->(fieldPos(aDados[nX][1])),aDados[nX][2]))	
next nX
(cAlias)->(msUnlock())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PGetBenef

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
function PGetBenef(aDados, aBD6, cMatric, cNome, cLibera, cUniInter, cUniOri)
local lRet      := .f.
local lMatric   := .f.
local cAlias    := ""
local cTipGui   := BCI->BCI_TIPGUI
local cAliasBnf	:= ""
local cCodPla	:= ""
local cMatAnt   := cMatric // salva a matricula que veio do ptu pra inserir no BD5/BE4_MATANT

default cNome   := "" 
default cLibera := "" 
default cUniInter := ""
default cUniOri := ""

if cTipGui == GUIA_INTERNACAO
    cAlias := "BE4"
else 
    cAlias := "BD5"
endif

//Se não achar eu pego a matricula da autorização, se não tiver ai crio o benef genérico.
cAliasBnf := getBenef(cMatric)
if (cAliasBnf)->(eof())
    lMatric := .t.
endif

if !empty(cLibera) .and. setGuiPri(cLibera, aDados, aBD6, lMatric, @cMatric)
    (cAliasBnf)->(dbclosearea())
    cAliasBnf := getBenef(cMatric)
elseif lMatric .and. validBenef(cNome, @cMatric, cUniInter, cUniOri)
    (cAliasBnf)->(dbclosearea())
    cAliasBnf := getBenef(cMatric)
endif

if !(cAliasBnf)->(eof())
    lRet := .t.
    aadd(aDados, {cAlias + "_MATANT", cMatAnt})
    aadd(aDados, {cAlias + "_OPEUSR", (cAliasBnf)->BA1_CODINT})
    aadd(aDados, {cAlias + "_NOMUSR", ifPls(cNome,(cAliasBnf)->BA1_NOMUSR)})
    aadd(aDados, {cAlias + "_CODEMP", (cAliasBnf)->BA1_CODEMP})
    aadd(aDados, {cAlias + "_MATRIC", (cAliasBnf)->BA1_MATRIC})
    aadd(aDados, {cAlias + "_TIPREG", (cAliasBnf)->BA1_TIPREG})
    aadd(aDados, {cAlias + "_CPFUSR", (cAliasBnf)->BA1_CPFUSR})
    aadd(aDados, {cAlias + "_IDUSR" , (cAliasBnf)->BA1_DRGUSR})
    aadd(aDados, {cAlias + "_DATNAS", (cAliasBnf)->BA1_DATNAS})
    aadd(aDados, {cAlias + "_DIGITO", (cAliasBnf)->BA1_DIGITO})
    aadd(aDados, {cAlias + "_CONEMP", (cAliasBnf)->BA1_CONEMP})
    aadd(aDados, {cAlias + "_VERCON", (cAliasBnf)->BA1_VERCON})
    aadd(aDados, {cAlias + "_SUBCON", (cAliasBnf)->BA1_SUBCON})
    aadd(aDados, {cAlias + "_VERSUB", (cAliasBnf)->BA1_VERSUB})
    aadd(aDados, {cAlias + "_MATVID", (cAliasBnf)->BA1_MATVID})
    aadd(aDados, {cAlias + "_CC",           PLSUSRCC(cMatric)})
    aadd(aDados, {cAlias + "_PADCON", PLSACOMUSR(cMatric,'2')})
    cCodPla := ifPls((cAliasBnf)->BA1_CODPLA,(cAliasBnf)->BA3_CODPLA)
    aadd(aBD6, {"BD6_CODPLA", cCodPla})    
    aadd(aBD6, {"BD6_OPEORI",(cAliasBnf)->BA1_OPEORI})   

    aDadUsr := PLSDADUSR(cMatric,,,date())
    
    if aDadUsr[1]

        if cTipGui == GUIA_INTERNACAO
            aadd(aDados, {"BE4_TIPUSR", aDadUsr[43]})
        endif

        aadd(aBD6, {"BD6_MODCOB", aDadUsr[48]})
	    aadd(aBD6, {"BD6_TIPUSR", aDadUsr[90]})
	    aadd(aBD6, {"BD6_INTERC", aDadUsr[91]})
	    aadd(aBD6, {"BD6_TIPINT", aDadUsr[43]})  
    endif
endif

(cAliasBnf)->(dbclosearea())

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getBenef

@author    Lucas Nonato
@version   V12
@since     23/09/2020
/*/
static function getBenef(cMatric)
local cAlias    := getNextAlias() 
local cSql      := ""
cSql := " SELECT BA3_CODPLA, BA3_TIPOUS, BA1_CODPLA, BA1_MATANT, BA1_CODINT, BA1_NOMUSR, BA1_CODEMP, BA1_MATRIC, BA1_MATVID, "
cSql += " BA1_TIPREG, BA1_CPFUSR, BA1_DRGUSR, BA1_DATNAS, BA1_DIGITO, BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA1_OPEORI "
cSql += " FROM " + retSqlName("BA1") + " BA1 "
cSql += " INNER JOIN " + retSqlName("BA3") + " BA3 "
cSql += " ON  BA3_FILIAL = BA1_FILIAL "
cSql += " AND BA3_CODINT = BA1_CODINT "
cSql += " AND BA3_CODEMP = BA1_CODEMP "
cSql += " AND BA3_MATRIC = BA1_MATRIC "
cSql += " AND BA3.D_E_L_E_T_ = ' ' "
cSql += " WHERE BA1.BA1_FILIAL =  '"+xfilial('BA1')+"'"
cSql += " AND BA1.BA1_CODINT = '" + substr(cMatric,1,4)  + "' "
cSql += " AND BA1.BA1_CODEMP = '" + substr(cMatric,5,4)  + "' "
cSql += " AND BA1.BA1_MATRIC = '" + substr(cMatric,9,6)  + "' "
cSql += " AND BA1.BA1_TIPREG = '" + substr(cMatric,15,2) + "' "
cSql += " AND BA1.BA1_DIGITO = '" + substr(cMatric,17,1) + "' "
cSql += " AND BA1.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} setGuiPri

@author    Lucas Nonato
@version   V12
@since     23/09/2020
/*/
static function setGuiPri(cLibera, aDados, aBD6, lMatric, cMatric)
local lFind     := .f.
local cSql      := ""
local cWhere    := ""
local cField    := ""
local cAlias    := getNextAlias()
local cAliCab   := ""

if BCI->BCI_TIPGUI == GUIA_INTERNACAO
    cAliCab := "BE4"
else 
    cAliCab := "BD5"
endif

if !(BCI->BCI_TIPGUI $ GUIA_INTERNACAO+GUIA_HONORARIO)
    cSql := " SELECT BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO MATRIC,BEA_OPESOL,BEA_ESTSOL,BEA_SIGLA,BEA_REGSOL,
    cSql += " BEA_NOMSOL,BEA_CDPFSO,BEA_NRAOPE,BEA_SENHA,BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI GUIA "
    cSql += " FROM " + retSqlName("BEA") + " BEA "
    cSql += " WHERE BEA_FILIAL =  '"+xfilial('BEA')+"'"
    cSql := PLSConSQL(cSql)
    cWhere := " AND D_E_L_E_T_ = ' ' "

    cField := " AND BEA_NRAOPE = '" + cLibera + "' "    
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql+cField+cWhere),cAlias,.F.,.T.)
    lFind := !(cAlias)->(eof())
    if !lFind
        (cAlias)->(dbclosearea())
        cField := " AND BEA_SENHA =  '" + cLibera + "' "
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql+cField+cWhere),cAlias,.F.,.T.)
        lFind := !(cAlias)->(eof())
    endif
    if !lFind
        (cAlias)->(dbclosearea())
        cField := " AND BEA_NUMIMP = '" + cLibera + "' "
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql+cField+cWhere),cAlias,.F.,.T.)
        lFind := !(cAlias)->(eof())
    endif

    if lFind
        if lMatric
            cMatric := (cAlias)->MATRIC
        endif
        if !empty((cAlias)->BEA_REGSOL)
            aadd(aDados, {"BD5_OPESOL",  (cAlias)->BEA_OPESOL}) 
            aadd(aDados, {"BD5_ESTSOL",  (cAlias)->BEA_ESTSOL}) 
            aadd(aDados, {"BD5_SIGLA",   (cAlias)->BEA_SIGLA}) 
            aadd(aDados, {"BD5_REGSOL",  (cAlias)->BEA_REGSOL}) 
            aadd(aDados, {"BD5_NOMSOL",  (cAlias)->BEA_NOMSOL}) 
            aadd(aDados, {"BD5_CDPFSO",  (cAlias)->BEA_CDPFSO})
        endif
        aadd(aDados, {"BD5_NRAOPE",  (cAlias)->BEA_NRAOPE}) 
        aadd(aDados, {"BD5_SENHA",   (cAlias)->BEA_SENHA})
    endif

    if !lFind
        (cAlias)->(dbclosearea())
    endif
endif

if !lFind
    cSql := " SELECT BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO MATRIC,BE4_OPESOL,BE4_ESTSOL,BE4_SIGLA,BE4_REGSOL,
    cSql += " BE4_NOMSOL,BE4_CDPFSO,BE4_NRAOPE,BE4_SENHA,BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO GUIA, BE4_TIPINT, "
    cSql += " BE4_HHDIGI, BE4_MSG01, BE4_COMUNI, BE4_NRTROL, BE4_DTALTA, BE4_HRALTA, BE4_STTISS, BE4_CODESP "
    cSql += " FROM " + retSqlName("BE4") + " BE4 "
    cSql += " WHERE BE4_FILIAL =  '"+xfilial('BE4')+"'"
    cSql := PLSConSQL(cSql)
    cWhere := " AND BE4_TIPGUI = '03' "
    cWhere += " AND D_E_L_E_T_ = ' ' "

    cField := " AND BE4_NRAOPE = '" + cLibera + "' "
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql+cField+cWhere),cAlias,.F.,.T.)
    lFind := !(cAlias)->(eof())
    if !lFind
        (cAlias)->(dbclosearea())
        cField := " AND BE4_SENHA =  '" + cLibera + "' "
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql+cField+cWhere),cAlias,.F.,.T.)
        lFind := !(cAlias)->(eof())
    endif
    if !lFind
        (cAlias)->(dbclosearea())
        cField := " AND BE4_NUMIMP = '" + cLibera + "' "
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql+cField+cWhere),cAlias,.F.,.T.)
        lFind := !(cAlias)->(eof())
    endif
    if !lFind
        (cAlias)->(dbclosearea())
        cField := " AND BE4_CODOPE = '" + BCI->BCI_CODOPE + "' "
        cField += " AND BE4_CODLDP = '" + substr(cLibera,1,4) + "' "
        cField += " AND BE4_CODPEG = '" + substr(cLibera,5,8) + "' "
        cField += " AND BE4_NUMERO = '" + substr(cLibera,13,8) + "' "
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql+cField+cWhere),cAlias,.F.,.T.)
        lFind := !(cAlias)->(eof())
    endif

    if lFind
        if lMatric
            cMatric := (cAlias)->MATRIC
        endif
        if !empty((cAlias)->BE4_REGSOL)
            aadd(aDados, {cAliCab + "_OPESOL",  (cAlias)->BE4_OPESOL})
            aadd(aDados, {cAliCab + "_ESTSOL",  (cAlias)->BE4_ESTSOL})
            aadd(aDados, {cAliCab + "_SIGLA",   (cAlias)->BE4_SIGLA}) 
            aadd(aDados, {cAliCab + "_REGSOL",  (cAlias)->BE4_REGSOL}) 
            aadd(aDados, {cAliCab + "_NOMSOL",  (cAlias)->BE4_NOMSOL}) 
            aadd(aDados, {cAliCab + "_CDPFSO",  (cAlias)->BE4_CDPFSO}) 

            //Guia de honorario nao tem o bloco do solicitante, 
            //por isso pegamos a especialidade da solicitação de internação
            if BCI->BCI_TIPGUI == GUIA_HONORARIO 
                aadd(aDados, {"BD5_CODESP",  (cAlias)->BE4_CODESP}) 
            endif
        endif
        aadd(aDados, {cAliCab + "_NRAOPE",  (cAlias)->BE4_NRAOPE}) 
        aadd(aDados, {cAliCab + "_SENHA",   (cAlias)->BE4_SENHA})
        aadd(aDados, {cAliCab + "_GUIINT",  (cAlias)->GUIA})
        if BCI->BCI_TIPGUI == GUIA_INTERNACAO
            aadd(aDados, {"BE4_MSG01",   (cAlias)->BE4_MSG01})
            aadd(aDados, {"BE4_HHDIGI",  (cAlias)->BE4_HHDIGI})
            aadd(aDados, {"BE4_MSG01",   (cAlias)->BE4_MSG01})
            aadd(aDados, {"BE4_COMUNI",  (cAlias)->BE4_COMUNI})
            aadd(aDados, {"BE4_NRTROL",  (cAlias)->BE4_NRTROL})
            aadd(aDados, {"BE4_DTALTA",  stod((cAlias)->BE4_DTALTA)})
            aadd(aDados, {"BE4_HRALTA",  (cAlias)->BE4_HRALTA})
            aadd(aDados, {"BE4_STTISS",  (cAlias)->BE4_STTISS})
        endif
    endif
endif

(cAlias)->(dbclosearea())
	
return

//-------------------------------------------------------------------
/*/{Protheus.doc} PGetExec

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
function PGetExec(aDados,cSgCons,cNrCons,cUFCons,cNome,cCBO,aDadBD5)
local aDadRda   := PLSGETRDA()

cNrCons := cvaltochar(val(cNrCons))

getBB0(@cSgCons,@cNrCons,@cUFCons,@cNome)

aadd(aDados, {"BD7_SIGLA", cSgCons})
aadd(aDados, {"BD7_REGPRE", cNrCons})
aadd(aDados, {"BD7_ESTPRE", cUFCons})
aadd(aDados, {"BD7_NOMPRE", cNome})

BAQ->(DbSetORder(4))
If 	BAQ->(MsSeek(xFilial("BAQ") + PlsIntPad() + cCBO))   
    aadd(aDadBD5, {"BD5_CODESP", AllTrim(BAQ->BAQ_CODESP)})
else 
    aadd(aDadBD5,  {"BD5_CODESP", aDadRda[15]})
endif
BAQ->(DbCloseArea())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PGetSolic

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
function PGetSolic(cAlias,aDados,cSgCons,cNrCons,cUFCons,cNome,cCBO)
local cCodBB0 := ""
local aDadRda   := PLSGETRDA()
cNrCons := cvaltochar(val(cNrCons))

getBB0(@cSgCons,@cNrCons,@cUFCons,@cNome,@cCodBB0)

aadd(aDados, {cAlias + "_ESTSOL",   cUFCons})
aadd(aDados, {cAlias + "_SIGLA",    cSgCons})
aadd(aDados, {cAlias + "_REGSOL",   cNrCons})
aadd(aDados, {cAlias + "_NOMSOL",   cNome})
aadd(aDados, {cAlias + "_CDPFSO",   cCodBB0})

BAQ->(DbSetORder(4))
If 	BAQ->(MsSeek(xFilial("BAQ") + PlsIntPad() + cCBO))   
    aadd(aDados, {cAlias + "_CODESP", AllTrim(BAQ->BAQ_CODESP)})
else 
    aadd(aDados, {cAlias + "_CODESP", aDadRda[15]})
endif
BAQ->(DbCloseArea())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PGetEquip

@author    Lucas Nonato
@version   V12
@since     11/09/2020
/*/
function PGetEquip(aDados,cSgCons,cNrCons,cUFCons,cNome)
local cCodBB0 :=""
cNrCons := cvaltochar(val(cNrCons))

getBB0(@cSgCons,@cNrCons,@cUFCons,@cNome,@cCodBB0)

aadd(aDados, cUFCons)
aadd(aDados, cSgCons)
aadd(aDados, cNrCons)
aadd(aDados, cNome)
aadd(aDados, cCodBB0)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} getBB0

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
static function getBB0(cSgCons,cNrCons,cUFCons,cNome,cCodBB0)
local cSqlCab   := ""
local cSql      := ""
local cAlias    := getNextAlias()
default cCodBB0    := ""

cSqlCab := " SELECT BB0_NUMCR, BB0_CODIGO FROM " + RetSqlName("BB0") + " BB0 "
cSqlCab += " WHERE BB0_FILIAL = '" + xFilial("BB0") + "' "	 

cSql := cSqlCab 
cSql += " AND BB0_ESTADO = '" + cUFCons + "' "	
cSql += " AND BB0_NUMCR = '" + cNrCons + "' "	
cSql += " AND BB0_CODSIG = '" + cSgCons + "' "	
cSql += " AND D_E_L_E_T_ = ' ' " 
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

if (cAlias)->(eof())
    (cAlias)->(dbclosearea())
    cSql := cSqlCab 
    cSql += " AND BB0_NOME = '" + alltrim(cNome) + "' "	
    cSql += " AND BB0_ESTADO = '" + cUFCons + "' "	
    cSql += " AND BB0_CODSIG = '" + cSgCons + "' "	
    cSql += " AND D_E_L_E_T_ = ' ' " 
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)
endif

if (cAlias)->(eof())  
	BB0->(RecLock("BB0",.T.))
    BB0->BB0_CODIGO := BB0->(GetSx8Num("BB0","BB0_CODIGO"))
    BB0->(confirmSx8())
    BB0->BB0_FILIAL := xFilial("BB0")
    BB0->BB0_VINC   := "2"
    BB0->BB0_NOME   := cNome
    BB0->BB0_CODSIG := cSgCons
    BB0->BB0_NUMCR  := cNrCons
    BB0->BB0_ESTADO := cUFCons
    BB0->BB0_UF     := cUFCons
    BB0->BB0_CODOPE := BCI->BCI_CODOPE 
    BB0->BB0_CODORI := BAU->BAU_CODOPE //Posicionado na criação da PEG
    BB0->(msUnLock())
else
    cNrCons := (cAlias)->BB0_NUMCR //preciso fazer isso pois o registro pode ter sido gravado com zeros a esquerda.
    cCodBB0 := (cAlias)->BB0_CODIGO
endif

(cAlias)->(dbclosearea())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} gravaPac
Grava o B43 para os itens de um pacote a partir da versão 11.3
@author Lucas Nonato
@version P12
@since 10/06/2020
/*/ 
static function gravaPac(aB43)
local nI := 1
Local lB43Qtd := B43->(FieldPos("B43_QTDPRO")) > 0

for nI := 1  To len(aB43)
	B43->(RecLock("B43",.T.))
	B43->B43_FILIAL := xFilial("B43")
	B43->B43_OPEMOV := BD6->BD6_CODOPE
	B43->B43_SEQUEN := BD6->BD6_SEQUEN
	B43->B43_CODOPE := BD6->BD6_CODOPE
	B43->B43_CODLDP := BD6->BD6_CODLDP
	B43->B43_CODPEG := BD6->BD6_CODPEG
	B43->B43_NUMERO := BD6->BD6_NUMERO
	B43->B43_ORIMOV := BD6->BD6_ORIMOV		
	B43->B43_VALCH  := 0 
	B43->B43_NIVPAC := "IMP" 
    iif(lB43Qtd,iif(len(aB43[nI])>=7,B43->B43_QTDPRO := aB43[nI][7][2], ), )
	B43->( MsUnLock() )	
    commit('B43',aB43[nI],.f.)		
next

BD6->(RecLock("BD6",.F.))
BD6->BD6_PACOTE := '1'
BD6->(MsUnLock())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} validBenef
valida nos casos que não foi encontrado beneficiario,
procurando através do nome
ou retornando beneficiario genérico
@author pablo alipio
@version P12
@since 10/2020
@param  cNome = nome do beneficiario
@param  cUniInter = unimed do intercambio
@param  cMatric = matricula do beneficiario
@param  cUniOri = unimed do beneficiario
/*/
static function validBenef(cNome, cMatric, cUniInter, cUniOri)
    local lFind     := .f.

    default cNome   := ""
    default cUniInter := ""
    default cMatric := ""
    default cUniOri := ""

    // procura pelo nome do beneficiario
    BA1->(DBSetOrder(3))
    if !(empty(cNome)) .and. ( BA1->(MsSeek(xFilial("BA1")+cNome)) )
        lFind := .t.
        cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
    endif

    // se não encontrar, utiliza beneficario genérico
    if !lFind
        getUsrGen(cUniInter, cUniOri)
        cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
        if !(empty(allTrim(cMatric)))
            lFind := .t.
        endif
    endif

return lFind


/*/{Protheus.doc} getUsrGen
cria usuario genérico ou retorna ele se já existir
@author pablo alipio
@since 10/2020
@param  cUniInter = unimed do intercambio
@param  cUniOri = unimed do beneficiario
/*/
static function getUsrGen(cUniInter, cUniOri)
    local cCodEmp   := GetNewPar("MV_PLSGEIN","0050")
    local cCodInE   := "01"
    local cConEmp   := ""
    local cVerCon   := ""
    local cSubCon   := ""
    local cVerSub   := ""
    local cSql      := ""
    local cMatrGen 	:= "999999"
    local cMatrAntGen := "99999999999999999"
    local cNomeUsr 	:= "USUARIO GENERICO"

    default cUniInter := ""
    default cUniOri := ""

    // busca o contrato de eventtual generalizado...
    cSQL := "SELECT BT5_CODINT, BT5_CODIGO, BT5_NUMCON, BT5_VERSAO, BT5_INTERC,BT5_TIPOIN,BT5_ALLOPE,BT5_OPEINT "
    cSQL += "FROM "+BT5->(RetSQLName("BT5"))+" WHERE "
    cSQL += "BT5_FILIAL = '"+xFilial("BT5")+"' AND "
    cSQL += "BT5_CODINT = '"+cUniOri+"' AND "
    cSQL += "BT5_CODIGO = '"+cCodEmp+"' AND "
    cSQL += "BT5_INTERC = '1' AND "
    cSQL += "BT5_TIPOIN = '"+Alltrim(cCodInE)+"' AND "
    cSQL += "BT5_ALLOPE = '1' AND "
    cSQL += "D_E_L_E_T_ = ' '"
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"PLSUSRIEVE",.F.,.T.)

    If ! PLSUSRIEVE->(Eof())
        cConEmp  := PLSUSRIEVE->BT5_NUMCON
        cVerCon  := PLSUSRIEVE->BT5_VERSAO
        BQC->(DbSetOrder(1))
        if ( BQC->(MsSeek(xFilial("BQC")+PLSUSRIEVE->(BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO))) )
            cSubCon  := BQC->BQC_SUBCON
            cVerSub  := BQC->BQC_VERSUB
            cNReduz  := BQC->BQC_NREDUZ
        endif
    Endif
    PLSUSRIEVE->(DbCloseArea())

    BA1->( DbSetOrder(1) )//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO
    If ! BA1->( MsSeek( xFilial("BA1")+cUniOri+cCodEmp+cMatrGen ) )

        // inclui familia
        BA3->( RecLock("BA3",.T.) )
        BA3->BA3_FILIAL := xFilial("BA3")
        BA3->BA3_CODINT := cUniOri
        BA3->BA3_CODEMP := cCodEmp
        BA3->BA3_CONEMP := cConEmp
        BA3->BA3_VERCON := cVerCon
        BA3->BA3_SUBCON := cSubCon
        BA3->BA3_VERSUB := cVerSub
        BA3->BA3_ROTINA := "PLSPORFAI"
        BA3->BA3_MATRIC := cMatrGen
        BA3->BA3_MATANT := cMatrAntGen
        BA3->BA3_HORACN := StrTran(SubStr(Time(),1,5),":","")
        BA3->BA3_COBNIV := "0"
        BA3->BA3_VENCTO := 0
        BA3->BA3_DATBAS := dDataBase
        BA3->BA3_DATCIV := dDataBase
        BA3->BA3_TIPOUS := "2"
        BA3->BA3_USUOPE := PLSRtCdUsr()
        BA3->BA3_MODPAG := "2"

        BT6->( DbSetOrder(1) )//BT6_FILIAL+BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO
        If BT6->(MsSeek(xFilial("BT6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
            BA3->BA3_CODPLA := BT6->BT6_CODPRO
            BA3->BA3_VERSAO := BT6->BT6_VERSAO
        Else
            BA3->BA3_CODPLA := GetNewPar("MV_PLSPLPE","0001")
            BA3->BA3_VERSAO := GetNewPar("MV_PLSVRPE","0001")
        EndIf
        BA3->BA3_FORPAG := GetNewPar("MV_PLSFCPE","101")
        BA3->BA3_DATCON := Date()
        BA3->BA3_HORCON := StrTran(SubStr(Time(),1,5),":","")
        BA3->(MsUnLock())

        // inclui beneficiario
        BA1->( RecLock("BA1",.T.) )
        BA1->BA1_FILIAL := xFilial("BA1")
        BA1->BA1_CODINT := BA3->BA3_CODINT
        BA1->BA1_CODEMP := BA3->BA3_CODEMP
        BA1->BA1_MATRIC := BA3->BA3_MATRIC
        BA1->BA1_CONEMP := BA3->BA3_CONEMP
        BA1->BA1_VERCON := BA3->BA3_VERCON
        BA1->BA1_SUBCON := BA3->BA3_SUBCON
        BA1->BA1_VERSUB := BA3->BA3_VERSUB
        BA1->BA1_IMAGE  := "ENABLE"
        BA1->BA1_TIPREG := GetNewPar("MV_PLTRTIT","00")
        BA1->BA1_DIGITO := Modulo11(StrTPLS(BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG))
        BA1->BA1_NOMUSR := cNomeUsr
        BA1->BA1_TIPUSU := "T"
        BA1->BA1_GRAUPA := GetMv("MV_PLCDTGP")     
        if BA1->(FieldPos("BA1_ENDCLI")) > 0   
            BA1->BA1_ENDCLI := "0" 
        endif
        BA1->BA1_MATANT := cMatrAntGen
        BA1->BA1_MATEMP := ""
        BA1->BA1_SEXO   := ""
        BA1->BA1_ESTCIV := ""
        BA1->BA1_CPFUSR := ""
        BA1->BA1_DRGUSR := ""
        BA1->BA1_DATINC := CtoD("")
        BA1->BA1_DATNAS := CtoD("")
        BA1->BA1_DATCAR := CtoD("")
        BA1->BA1_CBTXAD := "1"
        BA1->BA1_OPEORI := cUniOri
        BA1->BA1_OPEDES := cUniOri
        BA1->BA1_OPERES := cUniInter
        BA1->BA1_LOCATE := "2"
        BA1->BA1_LOCCOB := "2"
        BA1->BA1_LOCEMI := "2"
        BA1->BA1_LOCANS := "2"

        //esta funcao analise a criacao de uma nova vida ou nao...
        PLSA766ANV(nil,.F.)

        //grava no usuario a vida criada ou a ja existente...
        BA1->BA1_MATVID := BTS->BTS_MATVID
        BA1->(MsUnLock())
    EndIf

return


//-------------------------------------------------------------------
/*/ {Protheus.doc} atualQTDEVE
Atualiza o valor do campo _QTDEVE, de acordo com a soma do BD6_QTDPRO (igual ao txt)
Usa a FWPreparedStatement, conforme orientações da Engenharia. 
@since 03/2023
@version P12 
/*/
//-------------------------------------------------------------------
static function atualQTDEVE(cAliasMov, cNumGui)
local oFwQuery  := FWPreparedStatement():New()
local cAliasQry := ""

//Query de busca dos valores da BD6 para gravação do cabeçalho (BD5/BE4)
cSql := " SELECT SUM(BD6_QTDPRO) SOMAQTDPRO  "
cSql += "  FROM " + retSqlName("BD6") + " BD6 "
cSql += " WHERE BD6.BD6_FILIAL = ?  AND BD6.BD6_CODOPE = ? "
cSql += "   AND BD6.BD6_CODLDP = ?  AND BD6.BD6_CODPEG = ? "
cSql += "   AND BD6.BD6_NUMERO = ?  AND BD6.D_E_L_E_T_ = ' ' "

cSql := ChangeQuery(cSql)
oFwQuery:SetQuery(cSql)
oFwQuery:SetString(1, xFilial("BD6"))
oFwQuery:SetString(2, BCI->BCI_CODOPE)
oFwQuery:SetString(3, BCI->BCI_CODLDP)
oFwQuery:SetString(4, BCI->BCI_CODPEG)
oFwQuery:SetString(5, cNumGui)
cSql := oFwQuery:GetFixQuery()
cAliasQry := MpSysOpenQuery(cSql)

if !(cAliasQry)->(eof())
    (cAliasMov)->(recLock(cAliasMov,.f.))
        &(cAliasMov+"->"+cAliasMov+"_QTDEVE")  := (cAliasQry)->SOMAQTDPRO
    (cAliasMov)->(msUnLock())
endIf

(cAliasQry)->(dbCloseArea())

return

/*/{Protheus.doc} BusEspExe
    (Busca especialidade do profissional executante
    através  do CBOS informado no arquivo.)
    @type  Static Function
    @author Thiago
    @since 15/09/2022
    @version version
    (examples)
    @see (links_or_references)
/*/
Static Function BusEspExe(cEspExe,cDesEspExe,aTpParc)

if len(aTpParc) > 3 .and. !Empty(aTpParc[4])
    BAQ->(DbSetORder(4))
    If 	BAQ->(MsSeek(xFilial("BAQ") + BD6->BD6_CODOPE + aTpParc[4]))   
        cEspExe    := AllTrim(BAQ->BAQ_CODESP)
        cDesEspExe := BAQ->BAQ_DESCRI
     endif
    BAQ->(DbCloseArea())
endif

if Empty(cEspExe)
    cEspExe    := BD6->BD6_CODESP
    cDesEspExe := BAQ->(posicione("BAQ",1,xFilial("BAQ")+BD6->(BD6_OPERDA+BD6_CODESP),"BAQ_DESCRI"))
endif

Return

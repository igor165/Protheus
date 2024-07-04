// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 2      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "PROTHEUS.CH"
#include "fileio.ch"
#include "OFIRMT01.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |  OFIRMT01  | Autor | Luis Delorme          | Data | 25/06/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |  Geração do relatório GDS (Gestão de Departamentos de        |##
##|          |  Serviços)                                                   |##
##+----------+--------------------------------------------------------------+##
##|Uso       |  MITSUBISHI MOTORS - OFICINA                                 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIRMT01()

Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}	 	
Local aButton := {} 	
//
Private cTitulo := STR0004
Private cPerg 	:= "ORMT01"	
Private cNomRel := "OFIRMT01"	
Private nOpc
Private aErros := {}
//
CriaSX1()
//
aAdd( aSay, cDesc1 ) 
aAdd( aSay, cDesc2 ) 
aAdd( aSay, cDesc3 ) 
//
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//

FormBatch( cTitulo, aSay, aButton )
//
If nOpc <> 1
	Return
Endif
//
Pergunte(cPerg,.f.)
//
oProcTTP := MsNewProcess():New({ |lEnd| RunProc() }," ","",.f.)
oProcTTP:Activate()
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | RunProc    | Autor | André Delorme         | Data | 17/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function RunProc(lEnd)
Local nCntFor, nCntFor2
Local oPrinter

Private cAliasVV1 := "SQLVV1"
Private cAliasVV2 := "SQLVV2"
Private oVerdana9 := TFont():New( "Verdana" ,  , 10 , , .F. , , , , .T. , .F. )
Private cStrTit := STR0005 + DTOC(MV_PAR01) + STR0006 + DTOC(MV_PAR02)

lLIBVOO := (VOO->(FieldPos("VOO_LIBVOO")) <> 0)

CSTARTPATH := GETPVPROFSTRING(GETENVSERVER(),"StartPath","ERROR",GETADV97())
CSTARTPATH += IF(RIGHT(CSTARTPATH,1) <> "\","\","")
CSTARTPATH = __RELDIR

nPag = 1

aCabec := {{1,0,0,5,1,'C','@!',cStrTit}}

aRelat := {;
{1,0,0,5,1,'C','@!',STR0007},{2,1,0,1,1,'C','@!',''},{3,2,0,1,1,'C','@!',STR0008},{4,3,0,1,1,'C','@!',STR0009},;
{5,4,0,1,1,'C','@!',STR0010},{6,5,0,1,1,'C','@!',STR0011},{7,6,0,1,1,'C','@!',STR0012},;
{8,7,0,1,1,'C','@!',STR0013},{9,8,0,1,1,'C','@!',STR0014},{10,9,0,1,1,'C','@!',STR0015},;
{11,10,0,1,1,'C','@!',STR0016},{12,11,0,1,1,'C','@!',STR0017},{13,12,0,1,1,'C','@!',STR0018},;
{14,13,0,1,1,'C','@!',STR0019},{15,14,0,1,1,'C','@!',STR0020},{16,15,0,1,1,'C','@!',STR0021},{17,16,0,1,1,'C','@!',STR0022},;
{18,17,0,1,1,'C','@!',STR0023},{19,18,0,1,1,'C','@!',STR0024},{20,19,0,1,1,'C','@!',STR0025},{21,20,0,1,1,'C','@!',STR0026},;
{22,21,0,1,1,'C','@!',STR0027},{23,22,0,1,1,'C','@!',STR0028},{24,1,1,1,1,'C','@!',STR0029},;
{25,2,1,1,1,'N','@!',0},{26,3,1,1,1,'C','@!',''},{27,4,1,1,1,'C','@!',''},{28,5,1,1,1,'C','@!',''},{29,6,1,1,1,'N','@E 999,999,999.99',0},{30,7,1,1,1,'N','@E 999,999,999.99',0},;
{31,8,1,1,1,'C','@!',''},{32,9,1,1,1,'N','@E 999,999,999.99',0},{33,10,1,1,1,'C','@!',''},{34,11,1,1,1,'N','@E 999,999,999.99',0},{35,12,1,1,1,'N','@E 999,999,999.99',0},;
{36,13,1,1,1,'C','@!',''},{37,14,1,1,1,'C','@!',''},{38,15,1,1,1,'N','@E 999,999,999.99',0},{39,16,1,1,1,'N','@E 999,999,999.99',0},{40,17,1,1,1,'N','@E 999,999,999.99',0},;
{41,18,1,1,1,'N','@E 999,999,999.99',0},{42,19,1,1,1,'N','@E 999,999,999.99',0},{43,20,1,1,1,'N','@E 999,999,999.99',0},{44,21,1,1,1,'C','@!',''},;
{45,1,2,1,1,'C','@!',STR0030},{46,2,2,1,1,'C','@!',''},{47,3,2,1,1,'N','@E 999,999,999.99',0},{48,4,2,1,1,'N','@E 999,999,999.99',0},{49,5,2,1,1,'N','@E 999,999,999.99',0},;
{50,6,2,1,1,'C','@!',''},{51,7,2,1,1,'C','@!',''},{52,8,2,1,1,'C','@!',''},{53,9,2,1,1,'C','@!',''},{54,10,2,1,1,'C','@!',''},{55,11,2,1,1,'C','@!',''},;
{56,12,2,1,1,'C','@!',''},{57,13,2,1,1,'N','@E 999,999,999.99',0},{58,14,2,1,1,'C','@!',''},{59,15,2,1,1,'C','@!',''},{60,16,2,1,1,'C','@!',''},;
{61,17,2,1,1,'C','@!',''},{62,18,2,1,1,'C','@!',''},{63,19,2,1,1,'C','@!',''},{64,20,2,1,1,'C','@!',''},{65,21,2,1,1,'C','@!',''},{66,1,3,1,1,'C','@!',STR0031},;
{67,2,3,1,1,'N','@!',0},{68,3,3,1,1,'C','@!',''},{69,4,3,1,1,'C','@!',''},{70,5,3,1,1,'N','@E 999,999,999.99',0},{71,6,3,1,1,'N','@E 999,999,999.99',0},;
{72,7,3,1,1,'C','@!',''},{73,8,3,1,1,'C','@!',''},{74,9,3,1,1,'C','@!',''},{75,10,3,1,1,'C','@!',''},{76,11,3,1,1,'C','@!',''},{77,12,3,1,1,'C','@!',''},;
{78,13,3,1,1,'C','@!',''},{79,14,3,1,1,'C','@!',''},{80,15,3,1,1,'N','@E 999,999,999.99',0},{81,16,3,1,1,'C','@!',''},{82,17,3,1,1,'C','@!',''},;
{83,18,3,1,1,'C','@!',''},{84,19,3,1,1,'C','@!',''},{85,20,3,1,1,'C','@!',''},{86,21,3,1,1,'C','@!',''},{87,1,4,1,1,'C','@!',STR0032},;
{88,2,4,1,1,'N','@!',0},{89,3,4,1,1,'C','@!',''},{90,4,4,1,1,'C','@!',''},{91,5,4,1,1,'C','@!',''},{92,6,4,1,1,'C','@!',''},{93,7,4,1,1,'C','@!',''},;
{94,8,4,1,1,'C','@!',''},{95,9,4,1,1,'C','@!',''},{96,10,4,1,1,'C','@!',''},{97,11,4,1,1,'C','@!',''},{98,12,4,1,1,'C','@!',''},{99,13,4,1,1,'C','@!',''},;
{100,14,4,1,1,'C','@!',''},{101,15,4,1,1,'C','@!',''},{102,16,4,1,1,'C','@!',''},{103,17,4,1,1,'C','@!',''},{104,18,4,1,1,'C','@!',''},;
{105,19,4,1,1,'C','@!',''},{106,20,4,1,1,'C','@!',''},{107,21,4,1,1,'C','@!',''},{108,22,1,4,1,'N','@E 999,999,999,999.99',0} }

aRelat2 := {;
{1,0,0,2,1,'C','@!',STR0033},{2,1,0,1,1,'C','@!',STR0034},{3,2,0,1,1,'C','@!',STR0035},;
{4,3,0,1,1,'C','@!',STR0036},{5,4,0,1,1,'C','@!',STR0037},{6,1,1,1,1,'N','@E 999,999,999,999.99',0},;
{7,2,1,1,1,'N','@E 999,999,999,999.99',0},{8,3,1,1,1,'N','@E 999,999,999,999.99',0},{9,4,1,1,1,'C','@!',''},;
{10,0,2,2,1,'C','@!',STR0038},{11,1,2,1,1,'C','@!',STR0039},{12,1,3,1,1,'N','@E 999,999,999,999.99',0} }

aRelat3 := {;
{1,0,0,2,1,'C','@!',STR0040},{2,1,0,1,1,'C','@!',STR0041},{3,2,0,2,1,'C','@!',STR0042},;
{4,3,0,1,1,'C','@!',STR0043},{5,4,0,1,1,'C','@!',STR0044},{6,5,0,1,1,'C','@!',STR0045},;
{7,6,0,1,1,'C','@!',STR0046},{8,7,0,1,1,'C','@!',STR0047},{9,1,1,1,1,'N','@!',''},{10,3,1,1,1,'N','@!',0},;
{11,4,1,1,1,'N','@!',0},{12,5,1,1,1,'N','@!',0},{13,6,1,1,1,'N','@!',0},{14,7,1,1,1,'N','@!',0} }

aRelat4 := {;
{1,0,0,2,1,'C','@!',STR0048},{2,1,0,2,1,'C','@!',STR0049},{3,2,0,1,1,'C','@!',STR0050},;
{4,3,0,1,1,'C','@!',STR0051},{5,4,0,1,1,'C','@!',STR0052},{6,5,0,1,1,'C','@!',STR0053},;
{7,6,0,1,1,'C','@!',STR0054},{8,2,1,1,1,'N','@!',0},{9,3,1,1,1,'N','@!',0},{10,4,1,1,1,'N','@!',0},;
{11,5,1,1,1,'N','@!',0},{12,6,1,1,1,'N','@!',0} }

aRelat5 := {;
{1,0,0,2,1,'C','@!',STR0055},;
{2,1,0,1,1,'C','@!',STR0056},;
{3,2,0,1,1,'C','@!',STR0057},;
{4,3,0,1,1,'C','@!',STR0058},;
{5,1,1,1,1,'N','@!',0},;
{6,2,1,1,1,'N','@!',0},;
{7,3,1,1,1,'C','@!',''} }

aRelat6 := {;
{1,0,0,2,1,'C','@!',STR0031},;
{2,1,0,1,1,'C','@!',STR0059},;
{3,2,0,1,1,'C','@!',STR0060},;
{4,3,0,1,1,'C','@!',STR0061},;
{5,1,1,1,1,'N','@!',0},;
{6,2,1,1,1,'N','@!',0},;
{7,3,1,1,1,'C','@!',''} }


cQryAl001 := GetNextAlias()

cQuery := " SELECT DISTINCT VEC_NUMOSV NUMOSV, VEC_TIPTEM TIPTEM FROM " + RetSqlName("VEC")
cQuery += " WHERE VEC_FILIAL = '"+xFilial("VEC")+"' AND D_E_L_E_T_ = ' ' AND VEC_DATVEN BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'"
cQuery += " UNION"
cQuery += " SELECT DISTINCT VSC_NUMOSV NUMOSV, VSC_TIPTEM TIPTEM FROM " + RetSqlName("VSC")
cQuery += " WHERE VSC_FILIAL = '"+xFilial("VSC")+"' AND D_E_L_E_T_ = ' ' AND VSC_DATVEN BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
//
aOSTTP := {}
aOSTTS := {}
while !((cQryAl001)->(eof()))

	if Empty((cQryAl001)->(NUMOSV))
		(cQryAl001)->(DbSkip())
		loop
	endif
	
	If Select(cAliasVV1) > 0
		( cAliasVV1 )->( DbCloseArea() )
		DBSelectArea("VO1")
	EndIf
	
	cQuery := "SELECT VV1.VV1_CODMAR, VV1.VV1_MODVEI "
	cQuery += "FROM "+RetSqlName( "VV1" ) + " VV1 INNER JOIN " + RetSqlName( "VO1" ) + " VO1 ON "
	cQuery += "( VO1_FILIAL='"+xFIlial("VO1")+"' AND VV1.VV1_CHAINT = VO1.VO1_CHAINT AND VO1.VO1_NUMOSV='"+(cQryAl001)->(NUMOSV)+"' AND VO1.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE "
	cQuery += "VV1.VV1_FILIAL='"+ xFilial("VV1")+ "' AND "
	cQuery += "VV1.D_E_L_E_T_=' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVV1, .T., .T. )
	
	If Select(cAliasVV2) > 0
		( cAliasVV2 )->( DbCloseArea() )
		DBSelectArea("VO1")
	EndIf
	
	cQuery := "SELECT VV2.VV2_TIPVEI TIPVEI "
	cQuery += "FROM "+RetSqlName( "VV2" ) + " VV2 "
	cQuery += "WHERE "
	cQuery += "VV2.VV2_FILIAL='"+ xFilial("VV2") + "' AND VV2.VV2_CODMAR = '"+(cAliasVV1)->VV1_CODMAR+"' AND VV2.VV2_MODVEI = '"+(cAliasVV1)->VV1_MODVEI+"' AND "
	cQuery += "VV2.D_E_L_E_T_=' ' "
	cQuery += "Order By VV2_CODMAR,VV2_MODVEI"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVV2, .T., .T. )
	
	if Alltrim((cAliasVV1)->VV1_CODMAR) $ Alltrim(MV_PAR06)
		aOSTTPC := FMX_CALPEC((cQryAl001)->(NUMOSV), (cQryAl001)->(TIPTEM),,,.f.,.f.,.t.,.f.,.t.,.t.,.f.,,"VEC_DATVEN BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'" )
		aOSTTSC := FMX_CALSER((cQryAl001)->(NUMOSV), (cQryAl001)->(TIPTEM),,,.f.,.f.,.f.,.t.,.t.,.f.,,"VSC_DATVEN BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'")
		if len(aOSTTPC) > 0
			for nCntFor := 1 to Len(aOSTTPC)
				aAdd(aOSTTP,aOSTTPC[nCntFor])
			next
		endif
		if len(aOSTTSC) > 0
			for nCntFor := 1 to Len(aOSTTSC)
				aAdd(aOSTTS,aOSTTSC[nCntFor])
			next
		endif
	endif
	(cAliasVV2)->(DBCloseArea())
	(cAliasVV1)->(DBCloseArea())	
	DBSelectArea("VO1")
	(cQryAl001)->(dbSkip())
enddo
//
(cQryAl001)->(DBCloseArea())
//
DBSelectArea("VO1")
DBSetOrder(1)
DBSelectArea("VOI")
DBSetOrder(1)
dbSelectArea("VOO")
dbSetOrder(1)
//
aChassis := {} // Chassis para contagem de passagens
//
nFatSrvTot 	:= 0
nImpVdaTot 	:= 0
nFatSrvInt 	:= 0
nFatSrvFP 	:= 0
nPasOFI 	:= 0
nPassFP 	:= 0
nPassRev 	:= 0
nFatPecFP 	:= 0 
//
nCtbSalCom := 0
nCtbEncSoc := 0
nCtbInsOFI := 0
nCtbInsFP := 0
nCtbSCI := 0
nCtbESI := 0
nCtbDD := 0
nCtbRateio := 0
//
for nCntFor := 1 to Len(aOSTTS)
	if !VO1->(DBSeek(xFilial("VO1")+aOSTTS[nCntFor,3]))
		MsgInfo(STR0062+Alltrim(aOSTTS[nCntFor,3])+ STR0063)
		loop
	endif
	// Tipo de Tempo
	DBSetOrder(1)
	if !VOI->(DBSeek(xFilial("VOI")+aOSTTS[nCntFor,4]))
		MsgInfo(STR0064 + aOSTTS[nCntFor,4] + STR0065)
		loop
	endif
	if !VOO->(dbSeek(xFilial("VOO")+aOSTTS[nCntFor,3]+aOSTTS[nCntFor,4]+IIf(lLIBVOO , VFE->VFE_LIBVOO , "")))
		MsgInfo(STR0066+ aOSTTS[nCntFor,3])
		loop
	endif
	//
	nFatSrvTot += aOSTTS[nCntFor,9] 
	nImpVdaTot += aOSTTS[nCntFor,39]
	if VOI->VOI_SITTPO == "3"
		nFatSrvInt += aOSTTS[nCntFor,9]
	endif
	if aOSTTS[nCntFor,18] $ Alltrim(MV_PAR03) .or. aOSTTS[nCntFor,18] $ Alltrim(MV_PAR04)
		nFatSrvFP += aOSTTS[nCntFor,9]
	endif
	if aScan(aChassis,{|x| x[1] == VO1->VO1_CHASSI .and. x[2] == aOSTTS[nCntFor,24] }) <= 0
		aAdd(aChassis,{ VO1->VO1_CHASSI,aOSTTS[nCntFor,24] })
		nPasOFI++
		if aOSTTS[nCntFor,18] $ Alltrim(MV_PAR03) .or. aOSTTS[nCntFor,18] $ Alltrim(MV_PAR04)
			nPassFP ++
		endif
		if VOI->VOI_SITTPO == "4"
			nPassRev ++
		endif
	endif
next
//
nLucPec := 0
nPecAce := 0
nPecTot := 0
for nCntFor := 1 to Len(aOSTTP)
	if !VO1->(DBSeek(xFilial("VO1")+aOSTTP[nCntFor,4]))
		MsgInfo(STR0062+Alltrim(aOSTTP[nCntFor,4])+ STR0063)
		loop
	endif
	// Tipo de Tempo
	if !VOI->(DBSeek(xFilial("VOI")+aOSTTP[nCntFor,3]))
		MsgInfo(STR0064 + aOSTTP[nCntFor,3] + STR0065)
		loop
	endif
	//
	if !VOO->(dbSeek(xFilial("VOO")+aOSTTP[nCntFor,4]+aOSTTP[nCntFor,3]+IIf(lLIBVOO , VFE->VFE_LIBVOO , "")))
		MsgInfo(STR0066+ aOSTTP[nCntFor,3])
		loop
	endif
	if VOO->VOO_DEPTO $ MV_PAR07
		nFatPecFP +=aOSTTP[nCntFor,10]
	endif
	if aOSTTP[nCntFor,1] $ Alltrim(MV_PAR05)
		nPecTot += aOSTTP[nCntFor,10] 
		nPecAce += aOSTTP[nCntFor,10]
		nLucPec += aOSTTP[nCntFor,10] - aOSTTP[nCntFor,28]  - aOSTTP[nCntFor,7] - aOSTTP[nCntFor,31]
	endif
next
//
DBSelectArea("CT1")
DBSetOrder(1)
//
if !Empty(MV_PAR08) .and. !Empty(MV_PAR15)
	CT1->(DBSeek(xFilial("CT1")+Alltrim(MV_PAR08)))
	nTemp = SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR02,"01","1",1)
	nTemp = nTemp - SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR01 - 1,"01","1",1)
	nCtbSalCom := nTemp
endif
//
if !Empty(MV_PAR09) .and. !Empty(MV_PAR15)
	CT1->(DBSeek(xFilial("CT1")+Alltrim(MV_PAR09)))
	nTemp = SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR02,"01","1",1)
	nTemp = nTemp - SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR01 - 1,"01","1",1)
	nCtbEncSoc := nTemp
endif
//
if !Empty(MV_PAR10) .and. !Empty(MV_PAR15)
	CT1->(DBSeek(xFilial("CT1")+Alltrim(MV_PAR10)))
	nTemp = SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR02,"01","1",1)
	nTemp = nTemp - SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR01 - 1,"01","1",1)
	nCtbInsOFI := nTemp
endif
//
if !Empty(MV_PAR10) .and. !Empty(MV_PAR16)
	CT1->(DBSeek(xFilial("CT1")+Alltrim(MV_PAR10)))
	nTemp = SaldoCCus(CT1->CT1_CONTA,MV_PAR16,MV_PAR02,"01","1",1)
	nTemp = nTemp - SaldoCCus(CT1->CT1_CONTA,MV_PAR16,MV_PAR01 - 1,"01","1",1)
	nCtbInsFP := nTemp
endif
//
if !Empty(MV_PAR11) .and. !Empty(MV_PAR15)
	CT1->(DBSeek(xFilial("CT1")+Alltrim(MV_PAR11)))
	nTemp = SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR02,"01","1",1)
	nTemp = nTemp - SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR01 - 1,"01","1",1)
	nCtbSCI := nTemp  
endif
//
if !Empty(MV_PAR12) .and. !Empty(MV_PAR15)
	CT1->(DBSeek(xFilial("CT1")+Alltrim(MV_PAR12)))
	nTemp = SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR02,"01","1",1)
	nTemp = nTemp - SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR01 - 1,"01","1",1)
	nCtbESI := nTemp
endif
//
if !Empty(MV_PAR13) .and. !Empty(MV_PAR15)
	CT1->(DBSeek(xFilial("CT1")+Alltrim(MV_PAR13)))
	nTemp = SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR02,"01","1",1)
	nTemp = nTemp - SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR01 - 1,"01","1",1)
	nCtbDD := nTemp
endif
//
if !Empty(MV_PAR14) .and. !Empty(MV_PAR15)
	CT1->(DBSeek(xFilial("CT1")+Alltrim(MV_PAR14)))
	nTemp = SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR02,"01","1",1)
	nTemp = nTemp - SaldoCCus(CT1->CT1_CONTA,MV_PAR15,MV_PAR01 - 1,"01","1",1)
	nCtbRateio := nTemp
endif
//
aInfoDetalhe := {}
//
cQryAl002 := GetNextAlias()
cQuery := "SELECT VEC.VEC_VALBRU, VEC.VEC_TOTIMP, VEC.VEC_VALDES, VEC_ICMSRT, VEC_CUSTOT, SB1.B1_GRUPO, SD2.D2_CLIENTE, SD2.D2_LOJA "
cQuery += "FROM "+RetSqlName( "VEC" ) + " VEC INNER JOIN "+RetSqlName( "SB1" ) + " SB1 ON"
cQuery += "      ( SB1.B1_FILIAL='"+ xFilial("SB1")+ "' AND "
cQuery += "        SB1.B1_GRUPO = VEC.VEC_GRUITE AND "
cQuery += "        SB1.B1_CODITE = VEC.VEC_CODITE AND "
cQuery += "        SB1.D_E_L_E_T_=' ' )
cQuery += "INNER JOIN "+RetSqlName( "SD2" ) + " SD2 ON"
cQuery += "      ( SD2.D2_FILIAL='"+ xFilial("SD2")+ "' AND "
cQuery += "        SD2.D2_DOC = VEC.VEC_NUMNFI AND "
cQuery += "        SD2.D2_SERIE = VEC.VEC_SERNFI AND "
cQuery += "        SD2.D2_COD = SB1.B1_COD AND "
cQuery += "        SD2.D_E_L_E_T_=' ' )
cQuery += "WHERE "
cQuery += "VEC.VEC_FILIAL='"+ xFilial("VEC")+ "' AND "
cQuery += " VEC.VEC_DATVEN >= '"+Dtos(MV_PAR01)+"' AND "
cQuery += " VEC.VEC_DATVEN <= '"+Dtos(MV_PAR02)+"' AND "
cQuery += " VEC.VEC_BALOFI = 'B' AND VEC.D_E_L_E_T_=' '"
//
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cQryAl002, .T., .T. )
//
nFatPecBal := 0
while !((cQryAl002)->(eof()))
	nFatPecBal += (cQryAl002)->(VEC_VALBRU)
	nLucPec  += (cQryAl002)->(VEC_VALBRU) - (cQryAl002)->(VEC_TOTIMP)  -  (cQryAl002)->(VEC_VALDES)  -  (cQryAl002)->(VEC_ICMSRT) - (cQryAl002)->(VEC_CUSTOT)
	//
	if (cQryAl002)->(B1_GRUPO) $ Alltrim(MV_PAR05)
		nPecTot += aOSTTP[nCntFor,10]
		nPecAce += aOSTTP[nCntFor,10]
	endif
	//
	(cQryAl002)->(dbSkip())
enddo
//
(cQryAl002)->(DBCloseArea())
DBSelectArea("VO1")
//
oPrinter := FWMSPrinter():New("OFIRMT01", IMP_PDF, .f.,CSTARTPATH , .t.)
oPrinter:SetPortrait()
oPrinter:SetPaperSize(DMPAPER_A4)
oPrinter:SetMargin(0,0,0,0)
oPrinter:cPathPDF := CSTARTPATH

oPrinter:StartPage()

aRelat[25,8] = nPasOfi                                            
aRelat[67,8] = nPassFP 
aRelat[88,8] = nPassRev
aRelat[47,8] = nFatPecBal
aRelat[48,8] = nPecAce
aRelat[49,8] = nPecTot
aRelat[70,8] = nFatPecFP
aRelat[29,8] = nFatSrvTot
aRelat[71,8] = nFatSrvFP
aRelat[30,8] = nFatSrvInt
aRelat[32,8] = nImpVdaTot
aRelat[34,8] = nCtbSalCom
aRelat[35,8] = nCtbEncSoc
aRelat[57,8] = nLucPec
aRelat[38,8] = nCtbInsOFI
aRelat[80,8] = nCtbInsFP
aRelat[39,8] = nCtbSCI
aRelat[40,8] = nCtbESI
aRelat[41,8] = nCtbDD
aRelat[42,8] = nCtbRateio
//
aRelat2[6,8] = MV_PAR17
aRelat2[7,8] = MV_PAR18 
aRelat2[8,8] = MV_PAR19
aRelat2[9,8] = MV_PAR20
aRelat2[12,8] = MV_PAR21
//
aRelat3[9,8] = MV_PAR22
aRelat3[10,8] = MV_PAR23 
aRelat3[11,8] = MV_PAR24
aRelat3[12,8] = MV_PAR25
aRelat3[13,8] = MV_PAR26
aRelat3[14,8] = MV_PAR23 + MV_PAR24 + MV_PAR25 + MV_PAR26
//
aRelat5[5,8] = MV_PAR27
aRelat5[6,8] = MV_PAR28 
aRelat5[7,8] = MV_PAR29
//
aRelat6[5,8] = MV_PAR30
aRelat6[6,8] = MV_PAR31 
aRelat6[7,8] = dtoc(MV_PAR32)
//
cQryAl003 := GetNextAlias()
cQuery := "SELECT COUNT(VO1.R_E_C_N_O_) CONT "
cQuery += "FROM "+RetSqlName( "VO1" ) + " VO1 "
cQuery += "WHERE "
cQuery += "VO1.VO1_FILIAL = '"+ xFilial("VO1")+ "' AND "
cQuery += " VO1.VO1_DATABE >= '"+Dtos(MV_PAR01)+"' AND "
cQuery += " VO1.VO1_DATABE <= '"+Dtos(MV_PAR02)+"' AND "
cQuery += " VO1.D_E_L_E_T_=' '"
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cQryAl003, .T., .T. )
nEntradas := (cQryAl003)->(CONT)
(cQryAl003)->(DBCloseArea())
DBSelectArea("VO1")

//
cQryAl004 := GetNextAlias()
cQuery := "SELECT COUNT(VO1.R_E_C_N_O_) CONT "
cQuery += "FROM "+RetSqlName( "VO1" ) + " VO1 "
cQuery += "WHERE "
cQuery += "VO1.VO1_FILIAL = '"+ xFilial("VO1")+ "' AND "
cQuery += " VO1.VO1_DATSAI >= '"+Dtos(MV_PAR01)+"' AND "
cQuery += " VO1.VO1_DATSAI <= '"+Dtos(MV_PAR02)+"' AND "
cQuery += " VO1.D_E_L_E_T_=' '"
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cQryAl004, .T., .T. )
nFechadas := (cQryAl004)->(CONT)
(cQryAl004)->(DBCloseArea())
DBSelectArea("VO1")


cQryAl005 := GetNextAlias()
cQuery := "SELECT COUNT(VO1.R_E_C_N_O_) CONT "
cQuery += "FROM "+RetSqlName( "VO1" ) + " VO1 "
cQuery += "WHERE "
cQuery += "VO1.VO1_FILIAL = '"+ xFilial("VO1")+ "' AND "
cQuery += " VO1.VO1_DATSAI >= '"+Dtos(MV_PAR01)+"' AND "
cQuery += " VO1.VO1_DATSAI <= '"+Dtos(MV_PAR02)+"' AND "
cQuery += " VO1.VO1_DATSAI <> VO1.VO1_DATABE AND "
cQuery += " VO1.D_E_L_E_T_=' '"
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cQryAl005, .T., .T. )
nPernoite := (cQryAl005)->(CONT)                       
(cQryAl005)->(DBCloseArea())
DBSelectArea("VO1")

aRelat4[9,8] = nEntradas
aRelat4[10,8] = nFechadas 
aRelat4[11,8] = nPernoite

nMax := FGX_MntTab(oPrinter, aCabec, 12, 20, {}, 110,10)
nMax += 2
nMax := FGX_MntTab(oPrinter, aRelat, nMax, 20, {}, 110,10)
nMax += 2
nMax := FGX_MntTab(oPrinter, aRelat2, nMax, 20, {}, 137.5,10)
nMax += 2
nMax := FGX_MntTab(oPrinter, aRelat3, nMax, 20, {}, 275,10)
nMax += 2
nMax := FGX_MntTab(oPrinter, aRelat4, nMax, 20, {}, 275,10)
nMax += 2
nMax := FGX_MntTab(oPrinter, aRelat5, nMax, 20, {}, 275,10)
nMax += 2
nMax := FGX_MntTab(oPrinter, aRelat6, nMax, 20, {}, 275,10)
//
oPrinter:EndPage()
oPrinter:Setup()
if oPrinter:nModalResult == PD_OK
	oPrinter:Preview()
EndIf
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1    | Autor | André Delorme         | Data | 17/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.
//
if cPerg == ""
	return 
endif
//
aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}
//################################################################
//# aAdd a Pergunta                                              #
//################################################################

aAdd(aSX1,{cPerg,"01",STR0067,STR0067,STR0067,"MV_CH1","D",8 ,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"02",STR0068,STR0068,STR0068,"MV_CH2","D",8 ,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"03",STR0069,STR0069,STR0069,"MV_CH2","C",40,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"04",STR0070,STR0070,STR0070,"MV_CH3","C",40,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"05",STR0071,STR0071,STR0071,"MV_CH4","C",40,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"06",STR0072,STR0072,STR0072,"MV_CH5","C",40,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"07",STR0073,STR0073,STR0073,"MV_CH6","C",40,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"08",STR0074,STR0074,STR0074,"MV_CH7","C",20,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","CT1","","S"})
aAdd(aSX1,{cPerg,"09",STR0075,STR0075,STR0075,"MV_CH8","C",20,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","CT1","","S"})
aAdd(aSX1,{cPerg,"10",STR0076,STR0076,STR0076,"MV_CH9","C",20,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","CT1","","S"})
aAdd(aSX1,{cPerg,"11",STR0077,STR0077,STR0077,"MV_CHA","C",20,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","CT1","","S"})
aAdd(aSX1,{cPerg,"12",STR0078,STR0078,STR0078,"MV_CHB","C",20,0,0,"G","","MV_PAR12","","","","","","","","","","","","","","","","","","","","","","","","","CT1","","S"})
aAdd(aSX1,{cPerg,"13",STR0079,STR0079,STR0079,"MV_CHC","C",20,0,0,"G","","MV_PAR13","","","","","","","","","","","","","","","","","","","","","","","","","CT1","","S"})
aAdd(aSX1,{cPerg,"14",STR0080,STR0080,STR0080,"MV_CHD","C",20,0,0,"G","","MV_PAR14","","","","","","","","","","","","","","","","","","","","","","","","","CT1","","S"})
aAdd(aSX1,{cPerg,"15",STR0081,STR0081,STR0081,"MV_CHE","C",9,0,0,"G","","MV_PAR15","","","","","","","","","","","","","","","","","","","","","","","","","CTT","","S"})
aAdd(aSX1,{cPerg,"16",STR0082,STR0082,STR0082,"MV_CHF","C",9,0,0,"G","","MV_PAR16","","","","","","","","","","","","","","","","","","","","","","","","","CTT","","S"})
aAdd(aSX1,{cPerg,"17",STR0083,STR0083,STR0083,"MV_CHG","N",1,0,0,"C","","MV_PAR17","Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"18",STR0084,STR0084,STR0084,"MV_CHH","N",10,2,0,"G","","MV_PAR18","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"19",STR0085,STR0085,STR0085,"MV_CHI","N",10,2,0,"G","","MV_PAR19","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"20",STR0086,STR0086,STR0086,"MV_CHJ","C",20,0,0,"G","","MV_PAR20","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"21",STR0087,STR0087,STR0087,"MV_CHK","N",10,2,0,"G","","MV_PAR21","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"22",STR0088,STR0088,STR0088,"MV_CIL","N",1,0,0,"C","","MV_PAR22","Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"23",STR0089,STR0089,STR0089,"MV_CIM","N",4,0,0,"C","","MV_PAR23","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"24",STR0090,STR0090,STR0090,"MV_CIN","N",4,0,0,"C","","MV_PAR24","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"25",STR0091,STR0091,STR0091,"MV_CIO","N",4,0,0,"C","","MV_PAR25","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"26",STR0092,STR0092,STR0092,"MV_CIP","N",4,0,0,"C","","MV_PAR26","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"27",STR0093,STR0093,STR0093,"MV_CIQ","N",1,0,0,"C","","MV_PAR27","Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"28",STR0094,STR0094,STR0094,"MV_CIR","N",10,2,0,"C","","MV_PAR28","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"29",STR0095,STR0095,STR0095,"MV_CIS","C",20,0,0,"G","","MV_PAR29","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"30",STR0096,STR0096,STR0096,"MV_CIT","N",1,0,0,"C","","MV_PAR30","Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"31",STR0097,STR0097,STR0097,"MV_CIU","C",20,0,0,"G","","MV_PAR31","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"32",STR0098,STR0098,STR0098,"MV_CIV","D",8,0,0,"G","","MV_PAR32","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
//
ProcRegua(Len(aSX1))
//
dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		lAchou := dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
		lSX1 := .T.
		RecLock("SX1",!lAchou)
		For j:=1 To Len(aSX1[i])
			If !Empty(FieldName(FieldPos(aEstrut[j])))
				if !lAchou .or. (Left(aEstrut[j],6) != "X1_CNT" .and. aEstrut[j] !="X1_PRESEL")
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				endif
			EndIf
		Next j
		dbCommit()
		MsUnLock()
	EndIf
Next i
//
return

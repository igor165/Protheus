#include "protheus.ch"
#include "OFIOC490.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OFIOC490 บAutor  ณ Takahashi          บ Data ณ  21/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta de Garantia Mutua                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOC490()

// Declara็ใo das variแveis
Local aFilAtu		:= FWArrFilAtu() // carrega os dados da Filial logada ( Grupo de Empresa / Empresa / Filial )
Local aSM0			:= FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)
Local nCont			:= 0
Local nPos			:= 0
Local cBkpFilAnt	:= cFilAnt // salvar cFilAnt

Local cQuery := ""

Local cAliasVDF := GetNextAlias()

Local aSizeAut	:= MsAdvSize(.t.)
Local aObjects	:= {} // Objetos Principal da Tela
Local aPosObj 	:= {}
Local aBotEnc	:= {}

Local cAuxPedGar := ""

Private nPerDecor
Private cCodConPgt

Private aConsulta := {}
Private cTTPeca := ""
Private cTTSrvc := ""


VDF->(dbGoTop())
cFilAnt := xFilial("VDF")
M->VV1_CODMAR := FM_SQL("SELECT VV1_CODMAR FROM " + RetSQLName("VV1") + " WHERE VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1_CHAINT = '" + VDF->VDF_CHAINT + "' AND D_E_L_E_T_ = ' '")
cFilAnt := cBkpFilAnt

If !Pergunte("OFC490",.t.)
	Return .f.
EndIf

nPerDecor  := MV_PAR06
cCodConPgt := MV_PAR09

cTTPeca := ""
aAuxTT := STRTOKARR( AllTrim(MV_PAR07) , "/" )
aEval( aAuxTT , { |x| cTTPeca += IIf( !Empty(x) , x + "/" , "" ) } )
If !Empty(cTTPeca)
	cTTPeca := FormatIN( Left(cTTPeca,Len(cTTPeca)-1) , "/" )
EndIf

cTTSrvc := ""
aAuxTT := STRTOKARR( AllTrim(MV_PAR08) , "/" )
aEval( aAuxTT , { |x| cTTSrvc += IIf( !Empty(x) , x + "/" , "" ) } )
If !Empty(cTTSrvc)
	cTTSrvc := FormatIN( Left(cTTSrvc,Len(cTTSrvc)-1) , "/" )
EndIf
 
// Levanta as Filiais
For nCont := 1 to Len(aSM0)

	// Filtro por Filial 
	If !(aSM0[nCont] >= MV_PAR01 .and. aSM0[nCont] <= MV_PAR02)
		Loop
	EndIf
	//

	cAuxPedGar := ""

	cFilAnt := aSM0[nCont]
	cQuery := "SELECT DISTINCT "
	cQuery += 		" VDF_ANOPED , VDF_NUMPED , VDF_NUMOSV , VDF_CODCON , VDF_CODCLI , VDF_LOJA , VDF_STATUS "
	cQuery += 		" , VO1_CODMAR , VO1_PLAVEI "
	cQuery += 		" , A1_NOME "
	cQuery += 		" , VOO_TIPTEM "
	cQuery +=  " FROM " + RetSQLName("VDF") + " VDF "
	cQuery +=  		" JOIN " + RetSQLName("VO1") + " VO1 ON VO1.VO1_FILIAL = '" + xFilial("VO1") + "' "
	cQuery +=										  " AND VO1.VO1_NUMOSV = VDF.VDF_NUMOSV "
	cQuery +=										  " AND VO1.D_E_L_E_T_ = ' ' "
	cQuery +=  		" JOIN " + RetSQLName("VOO") + " VOO ON VOO.VOO_FILIAL = '" + xFilial("VOO") + "' "
	cQuery +=										  " AND VOO.VOO_NUMOSV = VDF.VDF_NUMOSV "
	cQuery +=										  " AND VOO.D_E_L_E_T_ = ' ' "
	cQuery +=  		" JOIN " + RetSQLName("SF2") + " F2  ON F2.F2_FILIAL = '" + xFilial("SF2") + "' "
	cQuery +=										  " AND F2.F2_DOC = VOO.VOO_NUMNFI "
	cQuery +=										  " AND F2.F2_SERIE = VOO.VOO_SERNFI "
	cQuery +=										  " AND F2.F2_CLIENTE = VOO.VOO_FATPAR "
	cQuery +=										  " AND F2.F2_LOJA = VOO.VOO_LOJA "
	cQuery +=										  " AND F2.D_E_L_E_T_ = ' ' "
	cQuery +=  		" JOIN " + RetSQLName("SA1") + " A1 ON A1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += 										" AND A1.A1_COD	= VDF_CODCLI "
	cQuery += 										" AND A1.A1_LOJA = VDF_LOJA "
	cQuery += 										" AND A1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VDF.VDF_FILIAL = '" + xFilial("VDF") + "'"
	cQuery +=   " AND VDF.VDF_STATUS = 'L'" // S๓ exibe pedidos de garantia liberados 
	If !Empty(MV_PAR05)
		cQuery += " AND VDF.VDF_CODCON = '" + MV_PAR05 + "'"
	EndIf
	cQuery +=   " AND VDF.D_E_L_E_T_ = ' '"
	cQuery += 	" AND F2.F2_EMISSAO >= '" + DtoS(MV_PAR03) + "'"
	cQuery +=   " AND F2.F2_EMISSAO <= '" + DtoS(MV_PAR04) + "'"
	
	// Filtra por Tipo de Tempo de Peca/Srvc
	If !Empty(cTTPeca) .or. !Empty(cTTSrvc)
		cQuery += " AND ( "
		
		If !Empty(cTTPeca)
			cQuery += " ( VOO_TIPTEM IN " + cTTPeca + " AND VOO_TOTPEC <> 0 ) "
		EndIf
			
		If !Empty(cTTSrvc)
			cQuery += IIf( !Empty(cTTPeca) , " OR " , "" ) 
			cQuery += " ( VOO_TIPTEM IN " + cTTSrvc + " AND VOO_TOTSRV <> 0 ) "
		EndIf		
	
		cQuery += " ) "
	EndIf 
	
	cQuery += " ORDER BY VDF.VDF_ANOPED, VDF.VDF_NUMPED "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVDF , .F., .T. ) 
	While !(cAliasVDF)->(Eof())
	
		If cAuxPedGar <> (cAliasVDF)->VDF_ANOPED + (cAliasVDF)->VDF_NUMPED
			AADD( aConsulta , Array(17) )
			nPos := Len(aConsulta)
			aConsulta[nPos,01] := cFilAnt
			aConsulta[nPos,02] := FWFilialName()
			aConsulta[nPos,03] := (cAliasVDF)->VDF_ANOPED
			aConsulta[nPos,04] := (cAliasVDF)->VDF_NUMPED
			aConsulta[nPos,05] := (cAliasVDF)->VDF_CODCON
			aConsulta[nPos,06] := (cAliasVDF)->VDF_STATUS
			aConsulta[nPos,07] := (cAliasVDF)->VDF_NUMOSV
			aConsulta[nPos,08] := 0	// Total de Pecas 
			aConsulta[nPos,09] := 0	// Total de Servicos 
			aConsulta[nPos,10] := 0	// Total Geral 
			aConsulta[nPos,11] := 0	// Total de Decorrencia 
			aConsulta[nPos,12] := xFilial("VVK")	// Filial do Cadastro de Concessionarias 
			aConsulta[nPos,13] := (cAliasVDF)->VO1_CODMAR
			aConsulta[nPos,14] := (cAliasVDF)->VDF_CODCLI
			aConsulta[nPos,15] := (cAliasVDF)->VDF_LOJA  
			aConsulta[nPos,16] := (cAliasVDF)->A1_NOME
			aConsulta[nPos,17] := (cAliasVDF)->VO1_PLAVEI

			cAuxPedGar := (cAliasVDF)->VDF_ANOPED + (cAliasVDF)->VDF_NUMPED			
			
		EndIf
	
		If Empty(cTTPeca) .or. (cAliasVDF)->VOO_TIPTEM $ cTTPeca
			aAuxValor := FMX_CALPEC((cAliasVDF)->VDF_NUMOSV , (cAliasVDF)->VOO_TIPTEM /* cTipTem */ , /* cGruIte */ , /* cCodIte */ , .F. /* lMov */ , .T. /* lNegoc */ , .T. /* lReqZerada */ , .T. /* lRetAbe */ , .T. /* lRetLib */ , .T. /* lRetFec */ , .F. /* lRetCan */ )
			aEval( aAuxValor , { |x| aConsulta[nPos,08] += x[10] - x[07] } )
		EndIf
				
		If Empty(cTTSrvc) .or. (cAliasVDF)->VOO_TIPTEM $ cTTSrvc
			aAuxValor := FMX_CALSER((cAliasVDF)->VDF_NUMOSV , (cAliasVDF)->VOO_TIPTEM /* cTipTem */ , /* cGruSer */ , /* cCodSer */ , .F. /* lApont */ , .T. /* lNegoc */ , .T. /* lRetAbe */ , .T. /* lRetLib */ , .T. /* lRetFec */ , .F. /* lRetCan */ )
			aEval( aAuxValor , { |x| aConsulta[nPos,09] += x[09] } )
		EndIf
		
		(cAliasVDF)->(dbSkip())
	End
	(cAliasVDF)->(dbCloseArea())

Next

dbSelectArea("VDF")

// Atualiza os totais 
For nPos := 1 to Len(aConsulta)
	aConsulta[nPos,10] += aConsulta[nPos,08] + aConsulta[nPos,09]
	aConsulta[nPos,11] += Round(aConsulta[nPos,10] * ( nPerDecor / 100 ),2)
Next nPos
//

cFilAnt := cBkpFilAnt // voltar cFilAnt salvo anteriormente


AADD( aObjects, { 100,  005, .T., .F. } )
AADD( aObjects, { 100,  100, .T., .T. } )
AADD( aObjects, { 100,  005, .T., .F. } )

aPosObj := MsObjSize( { aSizeAut[ 1 ] , aSizeAut[ 2 ] ,aSizeAut[ 3 ] , aSizeAut[ 4 ] , 2 , 2 } , aObjects , .T. )


oDlgOC490 := MSDIALOG():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],STR0012,,,,128,,,,,.t.)

oLbConsulta := TWBrowse():New(aPosObj[2,1]+2,aPosObj[2,2]+2,(aPosObj[2,4]-aPosObj[2,2]-4),(aPosObj[2,3]-aPosObj[2,1]-4),,,,oDlgOC490,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbConsulta:nAT := 1
oLbConsulta:SetArray(aConsulta)
oLbConsulta:AddColumn( TCColumn():New( RetTitle("VDF_FILIAL")	, { || aConsulta[oLbConsulta:nAt,01] }	,,,,"LEFT" ,10,.F.,.F.,,,,.F.,) )
oLbConsulta:AddColumn( TCColumn():New( STR0008					, { || aConsulta[oLbConsulta:nAt,02] }	,,,,"LEFT" ,60,.F.,.F.,,,,.F.,) )
oLbConsulta:AddColumn( TCColumn():New( RetTitle("VDF_ANOPED")	, { || aConsulta[oLbConsulta:nAt,03] }	,,,,"LEFT" ,15,.F.,.F.,,,,.F.,) )
oLbConsulta:AddColumn( TCColumn():New( RetTitle("VDF_NUMPED")	, { || aConsulta[oLbConsulta:nAt,04] }	,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) )
oLbConsulta:AddColumn( TCColumn():New( RetTitle("VDF_CODCON")	, { || aConsulta[oLbConsulta:nAt,05] }	,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) )
oLbConsulta:AddColumn( TCColumn():New( RetTitle("VDF_NUMOSV")	, { || aConsulta[oLbConsulta:nAt,07] }	,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) )
oLbConsulta:addColumn( TCColumn():New( RetTitle("VOO_TOTPEC")	, { || Transform(aConsulta[oLbConsulta:nAt,08],"@E 9,999,999.99") }		,,,,"RIGHT",45,.F.,.F.,,,,.F.,) )
oLbConsulta:addColumn( TCColumn():New( RetTitle("VOO_TOTSRV")	, { || Transform(aConsulta[oLbConsulta:nAt,09],"@E 9,999,999.99") }		,,,,"RIGHT",45,.F.,.F.,,,,.F.,) )
oLbConsulta:addColumn( TCColumn():New( STR0009					, { || Transform(aConsulta[oLbConsulta:nAt,10],"@E 9,999,999.99") }		,,,,"RIGHT",45,.F.,.F.,,,,.F.,) )
oLbConsulta:addColumn( TCColumn():New( STR0010					, { || Transform(aConsulta[oLbConsulta:nAt,11],"@E 9,999,999.99") }		,,,,"RIGHT",45,.F.,.F.,,,,.F.,) )
oLbConsulta:Refresh()

If ExistBlock("OC490IMP")
	AADD(aBotEnc, { "IMPRESSAO" ,{ || OC490IMP() }, STR0011 } )
EndIf

ACTIVATE MSDIALOG oDlgOC490 ON INIT ( EnchoiceBar(oDlgOC490, { || oDlgOC490:End() }, { || oDlgOC490:End() },, aBotEnc ) )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OC490IMP บAutor  ณ Takahashi          บ Data ณ  21/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressao de Carta de Decorrencia                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC490IMP()

Local aCabImp := {}
Local aDetImp := {}
Local nCont
Local nPos

Local cPulaOS := ""
Local cPulaNF := ""
Local cAliasNF := "TNF"
Local cBkpFilAnt	:= cFilAnt // salvar cFilAnt
Local aSM0FilAtu 

If Len(aConsulta) == 0
	MsgStop(STR0016,STR0017)
	Return
EndIf

aSort(aConsulta,,, {|x,y| x[01]+x[12]+x[05]+x[03]+x[04] < y[01]+y[12]+y[05]+x[03]+x[04] } )

// Verifica se existe concessionarias misturadas ...
// S๓ ้ possivel gerar relatorio de uma concessionaria 
cAuxPesq := aConsulta[01,12] + aConsulta[01,05]
If aScan( aConsulta , { |x| x[12] + x[05] <> cAuxPesq } ) <> 0
	MsgInfo(STR0001)	// "S๓ ้ possivel gerar a carta quando a consulta possuir somente uma concessionaria"
	Return .f.
EndIf
//

If !Pergunte("OFC490I")
	Return
EndIf

// Procura informacoes da filial ... 
cFilAnt := aConsulta[01,01]
aSM0FilAtu := FWArrFilAtu()	
SA1->(dbSetOrder(3))
SA1->(dbSeek( xFilial("SA1") + aSM0FilAtu[SM0_CGC] ))
//	

aCabImp := Array(12)
aCabImp[01] := aConsulta[01,01]
aCabImp[02] := SA1->A1_NOME	// Nome da Filial
aCabImp[03] := FM_SQL("SELECT CC2_MUN FROM " + RetSQLName("CC2") + " WHERE CC2_FILIAL = '" + xFilial("CC2") + "' AND CC2_CODMUN = '" + SA1->A1_COD_MUN + "' AND CC2_EST = '" + SA1->A1_EST + "' AND D_E_L_E_T_ = ' '")
aCabImp[04] := MV_PAR05
aCabImp[05] := nPerDecor
aCabImp[06] := 0
aCabImp[07] := 0
aCabImp[08] := FM_SQL("SELECT VVK_RAZSOC FROM " + RetSQLName("VVK") + " WHERE VVK_FILIAL = '" + aConsulta[01,12] + "' AND VVK_CODMAR = '" + aConsulta[01,13] + "' AND VVK_CODCON = '" + aConsulta[01,05] + "' AND D_E_L_E_T_ = ' '")
aCabImp[09] := AllTrim(MV_PAR01) + " - " + AllTrim(MV_PAR04) // Nome do banco
aCabImp[10] := AllTrim(MV_PAR02) // Agencia
aCabImp[11] := AllTrim(MV_PAR03) // Conta
aCabImp[12] := cCodConPgt

For nCont := 1 to Len(aConsulta)

	cFilAnt := aConsulta[nCont,01]
	
	// Filial + OS
	If cPulaOS == aConsulta[nCont,01] + aConsulta[nCont,07]
		aDetImp[nPos,03] += IIf( !Empty(aDetImp[nPos,03]) , ", " , "" ) + aConsulta[nCont,04] + "/" + aConsulta[nCont,03] // Pedido da Garantia
		Loop
	EndIf
	cPulaOS := aConsulta[nCont,01] + aConsulta[nCont,07]
	//

	aCabImp[07] += aConsulta[nCont,10]	// Valor Total
	
	AADD( aDetImp, Array(07) )
	nPos := Len(aDetImp)	
	aDetImp[nPos,01] := aConsulta[nCont,16]	// Nome do Cliente
	aDetImp[nPos,02] := aConsulta[nCont,17]	// Placa do Veiculo
	aDetImp[nPos,03] := aConsulta[nCont,04] + "/" + aConsulta[nCont,03]	// Pedido da Garantia
	aDetImp[nPos,04] := "" // Relacao de NF 
	aDetImp[nPos,05] := "" // Relacao de Titulos 
	aDetImp[nPos,06] := "" // Relacao de Vencimentos 
	aDetImp[nPos,07] := 0  // Total Faturado  
	
	cPulaNF := ""
	
	cQuery := "SELECT * "
	cQuery +=  " FROM " + RetSQLName("VOO") + " VOO JOIN " + RetSQLName("SF2") + " F2 ON F2_FILIAL = '" + xFilial("SF2") + "' AND F2_SERIE = VOO_SERNFI AND F2_DOC = VOO_NUMNFI AND F2.D_E_L_E_T_ = ' '"
	cQuery +=         " JOIN " + RetSQLName("SE1") + " E1 ON E1_FILIAL = '" + xFilial("SE1") + "' AND E1_PREFIXO = F2_PREFIXO AND E1_NUM = F2_DOC AND E1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE VOO_FILIAL = '" + xFilial("VOO") + "'"
	cQuery +=   " AND VOO_NUMOSV = '" + aConsulta[nCont,07] + "'"
	// Filtra por Tipo de Tempo de Peca/Srvc
	If !Empty(cTTPeca) .or. !Empty(cTTSrvc)
		cQuery += " AND ( "
		
		If !Empty(cTTPeca)
			cQuery += " ( VOO_TIPTEM IN " + cTTPeca + " AND VOO_TOTPEC <> 0 ) "
		EndIf
			
		If !Empty(cTTSrvc)
			cQuery += IIf( !Empty(cTTPeca) , " OR " , "" ) 
			cQuery += " ( VOO_TIPTEM IN " + cTTSrvc + " AND VOO_TOTSRV <> 0 ) "
		EndIf		
	
		cQuery += " ) "
	EndIf	
	cQuery +=   " AND VOO.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VOO_SERNFI , VOO_NUMNFI "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasNF , .F., .T. ) 
	While !(cAliasNF)->(Eof())
		If cPulaNF <> (cAliasNF)->VOO_SERNFI + (cAliasNF)->VOO_NUMNFI
			aDetImp[nPos,04] += (cAliasNF)->VOO_NUMNFI + ", "	// Relacao de NF 
			aDetImp[nPos,07] += (cAliasNF)->F2_VALBRUT  		// Total Faturado 
			cPulaNF := (cAliasNF)->VOO_SERNFI + (cAliasNF)->VOO_NUMNFI
		EndIf
		
		aDetImp[nPos,05] += (cAliasNF)->E1_NUM + "/" + (cAliasNF)->E1_PARCELA + ", "	// Relacao de Titulos 
		aDetImp[nPos,06] += DtoC(Stod((cAliasNF)->E1_VENCTO)) + ", " 					// Relacao de Vencimentos 
		
		(cAliasNF)->(dbSkip())
	End
	(cAliasNF)->(dbCloseArea())

Next nCont

aCabImp[06] := Round( aCabImp[07] * ( nPerDecor / 100 ) , 2) // Valor da Decorrencia 

For nPos := 1 to Len(aDetImp)
	aDetImp[nPos,04] := Left(AllTrim(aDetImp[nPos,04]),Len(AllTrim(aDetImp[nPos,04]))-1)
	aDetImp[nPos,05] := Left(AllTrim(aDetImp[nPos,05]),Len(AllTrim(aDetImp[nPos,05]))-1)
	aDetImp[nPos,06] := Left(AllTrim(aDetImp[nPos,06]),Len(AllTrim(aDetImp[nPos,06]))-1)
Next nPos

dbSelectArea("VDF")
cFilAnt := cBkpFilAnt

ExecBlock("OC490IMP",.f.,.f.,{aCabImp,aDetImp})

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OC490BCO บAutor  ณ Takahashi          บ Data ณ  02/09/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca nome do banco se encontrar na SA6                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OC490BCO(cCodBco)

Local cAuxNome 

Default cCodBco := MV_PAR01 

cAuxNome := FM_SQL("SELECT A6_NOME FROM " + RetSQLName("SA6") + " WHERE A6_FILIAL = '" + xFilial("SA6") + "' AND A6_COD = '" + cCodBco + "' AND D_E_L_E_T_ = ' '")
If !Empty(cAuxNome)
	MV_PAR04 := cAuxNome
EndIf

Return .T. 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OC490SX1 บAutor  ณ Takahashi          บ Data ณ  21/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gerar pergunte padrao                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//Static Function OC490SX1()
//
////ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
////ณ Pergunte para Configuracao da Rotina ณ
////ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//AADD(aRegs,{ STR0002 , STR0002 , STR0002 , "mv_ch1", "C", FWSizeFilial()				, 0, 0, "G", , "mv_par01", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , cF3SM0 , "" , "" , "" ,{},{},{}})	// "Filial de ?"
//AADD(aRegs,{ STR0003 , STR0003 , STR0003 , "mv_ch2", "C", FWSizeFilial()				, 0, 0, "G", , "mv_par02", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , cF3SM0 , "" , "" , "" ,{},{},{}})	// "Filial at้ ?"
//AADD(aRegs,{ STR0004 , STR0004 , STR0004 , "mv_ch3", "D", 8								, 0, 0, "G", , "mv_par03", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""     , "" , "" , "" ,{},{},{}})	// "Data de ?"
//AADD(aRegs,{ STR0005 , STR0005 , STR0005 , "mv_ch4", "D", 8								, 0, 0, "G", , "mv_par04", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""     , "" , "" , "" ,{},{},{}})	// "Data at้ ?"
//AADD(aRegs,{ RetTitle("VDF_CODCON")	, RetTitle("VDF_CODCON") , RetTitle("VDF_CODCON"), "mv_ch5", "C", SFM->(TamSx3("VDF_CODCON")[1])	, 0, 0, "G", , "mv_par05", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "VKV"	 , "" , "" , "" ,{},{},{}})
//AADD(aRegs,{ STR0006 , STR0006 , STR0006 , "mv_ch6", "N", 5								, 2, 0, "G", , "mv_par06", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""     , "" , "" , "" ,"@E 99.99" ,{},{},{}})	// "Perc. Decorr๊ncia"
//AADD(aRegs,{ STR0013 , STR0013 , STR0013 , "mv_ch7", "C",40								, 0, 0, "G", , "MV_PAR07", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,"VOI"   , "" , "" , "" ,"!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/",{},{},{}})
//AADD(aRegs,{ STR0014 , STR0014 , STR0014 , "mv_ch8", "C",40								, 0, 0, "G", , "MV_PAR08", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,"VOI"   , "" , "" , "" ,"!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/",{},{},{}})
//AADD(aRegs,{ STR0015 , STR0015 , STR0015 , "mv_ch9", "C", TamSx3("VDF_CODCON")[1]		, 0, 0, "G", , "MV_PAR09", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "VKV"	 , "" , "" , "" ,{},{},{}})
//
//aRegs := {}
//AADD(aRegs,{ RetTitle("A6_COD")		, RetTitle("A6_COD")	, RetTitle("A6_COD")	, "mv_ch1", "C", SA6->(TamSx3("A6_COD")[1])		, 0, 0, "G", "OC490BCO()"		, "mv_par01", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{},{},{}})
//AADD(aRegs,{ RetTitle("A6_AGENCIA")	, RetTitle("A6_AGENCIA"), RetTitle("A6_AGENCIA"), "mv_ch2", "C", SA6->(TamSx3("A6_AGENCIA")[1])	, 0, 0, "G", ""					, "mv_par02", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{},{},{}})
//AADD(aRegs,{ RetTitle("A6_NUMCON")	, RetTitle("A6_NUMCON")	, RetTitle("A6_NUMCON")	, "mv_ch3", "C", SA6->(TamSx3("A6_NUMCON")[1])	, 0, 0, "G", ""					, "mv_par03", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{},{},{}})
//AADD(aRegs,{ RetTitle("A6_NOME")	, RetTitle("A6_NOME")	, RetTitle("A6_NOME")	, "mv_ch4", "C", SA6->(TamSx3("A6_NOME")[1])	, 0, 0, "G", ""					, "mv_par04", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{},{},{}})
//AADD(aRegs,{ STR0007 				, STR0007 				, STR0007 				, "mv_ch5", "D", 8								, 0, 0, "G", "!Empty(MV_PAR05)"	, "mv_par05", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{},{},{}})
//
//Return

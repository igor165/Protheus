#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSAF64.CH'

Static lTMSExp    := SuperGetMv("MV_TMSEXP", .F., .F.)

//-------------------------------------------------------------------
/*{Protheus.doc} TMSAF64NFC
Valida a chamada da Rotina P/Entrada da NFiscal do Cliente
@type Function
@author Katia
@since 3108/2020
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Function TMSAF64NFC()
Local lRet      := .T.
Local aArea     := GetArea()
Local aSetKey   := {}
Local nOpcx     := 4
Local cLote     := ""
Local cFiltro	:= ""
Local cPerg     := "TMSAF60"

Aadd(aSetKey,{VK_F12,{|| Pergunte(cPerg,.T.)}})

TmsKeyOff(aSetKey)

//-- Valida alteração da viagem
lRet:= TF64VldAlt(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)

If lRet
	lRet:= VldTipVia(DTQ->DTQ_SERTMS,DTQ->DTQ_TIPVIA)
EndIf

If lRet 
	lRet:= VldRota(DTQ->DTQ_ROTA)
EndIf

If lRet
	lRet := NfCliBut( DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM , nOpcx , DTQ->DTQ_STATUS )	
EndIf

If lRet
	lRet:= VldPtoApo(nOpcx)
EndIf

If lRet
	lRet:= VldRecurso(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM )
EndIf

//---- Seleciona os Lotes da Viagem para Filtrar no Browse do TMSA050
If lRet
	TF64ELote(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,@cLote)
EndIf

//---- Digitacação da Nota
If lRet
	cFiltro	:= FiltroDTC( DTQ->DTQ_FILORI,  DTQ->DTQ_VIAGEM )
	SaveInter()
	//-- Inclusao documentos clientes p/ transporte
	M->DTQ_FILORI:= DTQ->DTQ_FILORI
	M->DTQ_VIAGEM:= DTQ->DTQ_VIAGEM
	M->DTQ_SERTMS:= DTQ->DTQ_SERTMS
	dbSelectArea("DTC")	
	lRet   := TMSA050(, , , , , , cFiltro)
	RestInter()
EndIf

RestArea(aArea)

TmsKeyOn(aSetKey)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldTipVia
Valida o Tipo de Viagem 
@type Static Function
@author Katia
@since 3108/2020
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Static Function  VldTipVia(cSerTmsVge,cTipVia)
Local lRet        := .T.
Default cSerTmsVge:= ""
Default cTipVia   := ""

If Empty(cSerTmsVge) .Or. Empty(cTipVia)
	lRet:= .F.
Else
	If cTipVia == "2" .Or. cTipVia == "4"	//-- Vazia ou Socorro
		Help("",1,"TMSAF6414")	//-- Em viagem do tipo vazia ou de socorro não pode digitar notas fiscais.
		lRet:= .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldTipVia
Valida o Tipo de Viagem 
@type Static Function
@author Katia
@since 3108/2020
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldRota(cRota)
Local lRet   := .T.
Default cRota:= ""
Default nOpcx:= 3

If Empty(cRota) 
	Help(' ', 1, 'TMSA14016')	//-- Nenhuma rota selecionada !
	lRet:= .F.
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} NfCliBut()
Valida a opção  do botao do NF Cliente
@type Static Function
@author Katia
@since 31/08/2020
@return lRet
//Funçao do TMSA144 
-----------------------------------------------------------/*/
Static Function NfCliBut(cFilOri , cViagem , nOpcx , cStatus )
Local lRet			:= .F. 
Local aOperDTW		:= {} 
Local cAtvChgCli	:= SuperGetMV('MV_ATVCHGC',,'')
Local nCount		:= 1 
Local nPos			:= 0 

Default cFilOri	:= ""
Default cViagem	:= ""
Default nOpcx	:= 3
Default cStatus	:= ""

If lTMSExp
	lRet	:= .T. 
Else
	If nOpcx == 4 
		If ( cStatus == '2' .Or. cStatus == '4' ) //-- 2=Em trânsito;4=Chegada em Filial/Cliente
			aOperDTW	:= aClone( A350RetDTW( cFilOri, cViagem , "2" , "2" ) ) 

			If Len(aOperDTW) > 0 
				For nCount := 1 To Len(aOperDTW)
					nPos := aScan(aOperDTW[nCount] , { |x| x[1] == "DTW_ATIVID" })
					If nPos > 0 
				
						If aOperDTW[nCount, nPos][2] == cAtvChgCli
							lRet	:= .T. 
						Else
							lRet	:= .F. 
							Help("", 1, "TMSA144L0") //-- Para habilitar a opção Nf.Cliente para viagens em trânsito, é necessário que exista alguma operação de chegada de cliente apontada e a saída desse mesmo cliente não deve estar apontada
						EndIf
					EndIf
				Next nCount
			EndIf
		ElseIf  cStatus == "1" //-- Em aberto
			lRet	:= .T. 
		EndIf
	EndIf	
EndIf

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} VldPtoApo
Valida o Ponto de Apoio
@type Static Function
@author Katia
@since 31/08/2020
@return lRet
*/
//-------------------------------------------------------------------
//Existindo o Ponto de Apoio a inclusão de documentos na viagem, somente será permitida qdo a operação da chegada no ponto estiver apontada
Static Function VldPtoApo(nOpcx)
Local lRet    := .T.
Local aAreaAnt:= GetArea()

Default nOpcx:= 0

If nOpcx == 4 .And. DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) //Em Transito
	If ExistFunc('TM350Apoio')  
		aAreaAnt:= GetArea()
		lRet:= Tm350Apoio(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)
		RestArea(aAreaAnt)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldRecurso
Valida o Recurso da Viagem (Veiculo e Motorista)
@type Static Function
@author Katia
@since 31/08/2020
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldRecurso(cFilOri,cViagem)
Local lRet     := .T.
Local aArea    := GetArea()

Default cFilOri:= ""
Default cViagem:= ""

//---- Veiculo
DTR->(dbSetOrder(1))
If !DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
	Help( ' ', 1, 'TMSA24002') //-- Complemento de viagem nao informado (DTR)
	lRet := .F.
EndIf

//----- Motorista
If lRet	
	DUP->(dbSetOrder(1))
	If !DUP->(MsSeek(xFilial("DUP")+cFilOri+cViagem))
		Help('',1,'TMSA24041') //"Informe um Motorista para esta viagem ..."
		lRet:= .F.
	EndIf
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TF64VldLot
Valida os Lotes da Viagem para efetuar o Calculo
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Function TF64VldLot(cFilOri,cViagem,cStatus)
Local aAreaDTP := DTP->(GetArea())
Local cQuery   := ""
Local cAliasDTP := GetNextAlias()
Local lRet      := .T.

Default cFilOri := ""
Default cViagem := ""
Default cStatus := ""

cQuery := "SELECT COUNT(*) NLOTE FROM " + RetSqlName("DTP") + " DTP " 
cQuery += " WHERE DTP_FILIAL = '" + xFilial("DTP") + "'"
cQuery += " AND DTP_FILORI = '" + cFilOri + "' " 
cQuery += " AND DTP_VIAGEM = '" + cViagem + "' " 
cQuery += " AND DTP_STATUS NOT IN (" + cStatus + ") " 
cQuery += " AND DTP_TIPLOT <> '5' "
cQuery += " AND D_E_L_E_T_ = ' ' " 					
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cAliasDTP, .F., .T. )
dbSelectArea((cAliasDTP))
If (cAliasDTP)->(!Eof())
	If (cAliasDTP)->NLOTE > 0
		lRet:= .F.
	EndIf
EndIf
(cAliasDTP)->(DbCloseArea())

RestArea(aAreaDTP)
FwFreeArray(aAreaDTP)
Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} TF64ELote
Seleciona os Lotes da Viagem
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Function TF64ELote(cFilOri,cViagem,cLote)
Local aArea    := GetArea()
Local aAreaDTP := DTP->(GetArea())
Local cQuery   := ""
Local cAliasDTP := GetNextAlias()
Local lRet      := .F.

Default cFilOri := ""
Default cViagem := ""

cQuery := "SELECT DTP_FILORI, DTP_LOTNFC, DTP_STATUS, DTP.R_E_C_N_O_ RECNO FROM " + RetSqlName("DTP") + " DTP " 
cQuery += " WHERE DTP_FILIAL = '" + xFilial("DTP") + "'"
cQuery += " AND DTP_FILORI = '" + cFilOri + "' " 
cQuery += " AND DTP_VIAGEM = '" + cViagem + "' " 
cQuery += " AND D_E_L_E_T_ = ' ' " 					
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cAliasDTP, .F., .T. )
dbSelectArea((cAliasDTP))
While (cAliasDTP)->(!Eof())
	lRet:= .T.

	If Empty(cLote)
		cLote:= '(' + (cAliasDTP)->DTP_LOTNFC
	Else
		cLote+= ', ' + (cAliasDTP)->DTP_LOTNFC
	EndIf		

	(cAliasDTP)->(dbSkip())
	If !Empty(cLote)
		cLote+= ')' 
	EndIf
EndDo
(cAliasDTP)->(DbCloseArea())

RestArea(aAreaDTP)
RestArea(aArea)
FwFreeArray(aAreaDTP)
FwFreeArray(aArea)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TF64VgMod3
Seleciona os Lotes da Viagem
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Function TF64VgMod3(cFilOri,cLotNfc,cViagem)
Local lRet    := .T.
Local lVgeMod3:= .T.

Default cFilOri:= ""
Default cLotNfc:= ""
Default cViagem:= ""

//-- Verifica se a Viagem é Modelo 3
lVgeMod3:= TF64Modelo3(cFilOri,cViagem)

If lVgeMod3
	//-- Busca o Nro da Viagem a partir do Lote
	If Empty(cViagem)
		cViagem:= RetVgeLote(cFilOri,cLotNfc)
	EndIf

	If !Empty(cViagem)
		//Executa a Viagem Modelo 3
		lRet:= IncVgeMod3(cFilOri,cViagem,cLotNfc)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} RetVgeLote
Retorna o Nro da Viagem do Lote
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Function RetVgeLote(cFilOri,cLotNfc)
Local cRet    := ""
Local aAreaDTP:= DTP->(GetArea())

Default cFilOri:= ""
Default cLotNfc:= ""

DTP->(DbSetOrder(2)) //DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
If	DTP->(MsSeek( xFilial('DTP') + cFilOri + cLotNfc ))
	cRet:= DTP->DTP_VIAGEM
EndIf

RestArea(aAreaDTP)
Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} VgeModelo3
Verifica se é uma viagem modelo 3
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Function VgeModelo3(cFilOri,cViagem)
Local lRet:= .F.
Local aArea:= GetArea()

Default cFilOri:= ""
Default cViagem:= ""

DM4->(dbSetOrder(1))
If DM4->(MsSeek(xFilial("DM4")+cFilOri+cViagem))
	lRet:= .T.
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} IncVgeMod3
Inclui documentos na Viagem Modelo 3
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Static Function IncVgeMod3(cFilOri,cViagem,cLotNfc)
Local nOpc      := 0
Local lRet      := .T. 
Local aArea     := GetArea()

SaveInter()

DBSelectArea('DTQ')
DTQ->( dbSetOrder(2))
If DTQ->( MsSeek( xFilial("DTQ") + cFilOri + cViagem ) )
	lRet:= .T.
	nOpc:= 4
EndIf

If lRet
    FwMsgRun( ,{|| TmsCmpMdl3( nOpc )} , STR0008 , STR0010 )  //Aguarde... Gerando a viagem modelo 3    
EndIf

RestInter()
RestArea(aArea)
Return lRet


//-----------------------------------------
/*/{Protheus.doc} TMVldLotM3()
Valida se o Lote é da Viagem Modelo 3
@type 		: Function
@autor		: Katia
@since		: 04/09/2020
@version 	: 12.1.30
Executado pelo TMSA200
/*/
//-------------------------------
Function TMVldLotM3(cFilOri,cViagem,cLote)
Local lRet     := .T.
Local cStatus  := "'2','3'"   //2- Digitado, 3-Calculado
Local lVgeMod3 := .T.
Local lTMSAF60 := IsInCallStack("TMSAF60")

Default cFilOri   := ""
Default cViagem   := ""
Default cLote     := ""

//--- Valida se é viagem Modelo 3
lVgeMod3:= TF64Modelo3(cFilOri,cViagem)

If lVgeMod3
	//--- Se executado pela rotina TMSAF60(express) verifica a Qtde Digitada para Fechar o Lote
	If lTMSAF60
		lRet:= TF64ChkLot(cFilOri,cLote)	
	EndIf

	If lRet
		//--- Verificar se existe Lote diferente de Digitado para a Viagem Modelo 3
		lRet:= TF64VldLot(cFilOri,cViagem,cStatus) 
	EndIf
	
	If !lRet
		Help(' ', 1, 'TMSAF6413')	//-- Calculo do Frete não pode ser executado, pois existem Lotes pendentes para essa Viagem.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} FiltroDTC
Filtra DTC
@type Static Function
@author Caio
@since 04/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Static Function FiltroDTC(cFilOri,cViagem)
Local aArea			:= GetArea()
Local cFiltro		:= ""


Default cFilOri		:= ""
Default cViagem		:= ""

If !Empty(cViagem)

	cFiltro:= " EXISTS (SELECT 1 FROM " + RetSqlName( "DTP" ) + " DTP "
	cFiltro+= " WHERE DTP_FILIAL = '" + xFilial("DTP") + "'" 
	cFiltro+= " AND DTP_FILORI= '" + cFilOri + "' AND DTP_VIAGEM = '" + cViagem + "' 
	cFiltro+= " AND DTP.D_E_L_E_T_= ' ' "
	cFiltro+= " AND DTP_FILORI = DTC_FILORI AND DTP_LOTNFC = DTC_LOTNFC ) "	

EndIf

RestArea(aArea)
Return cFiltro


//-------------------------------------------------------------------
/*{Protheus.doc} TF64Modelo3
Verifica se a Viagem é modelo 3
@type Static Function
@author Katia
@since 02/09/2020
@return lRet
*/
//-------------------------------------------------------------------
Function TF64Modelo3(cFilOri,cViagem)
Local lRet       := .T.
Local lVgeAntiga := (Left(FunName(),7) == "TMSA140" .Or. Left(FunName(),7) == "TMSA141" .Or. ;
					 Left(FunName(),7) == "TMSA143" .Or. Left(FunName(),7) == "TMSA144")

Default cFilOri:= ""
Default cViagem:= ""

If lVgeAntiga .And. !lTMSExp
	lRet:= .F.
Else
	lRet:= TmsVgeMod3()  //Chamada pela Viagem Modelo 3
	If !lRet	
		lRet:= VgeModelo3(cFilOri,cViagem)  //Viagem gerada pela Modelo 3
	EndIf
EndIf
Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} TF64VldCTE
Valida todos os documentos do Lote se estão transmitidos
@type Static Function
@author Katia
@since 22/12/2020
@return lRet
*/
//-------------------------------------------------------------------
Function TF64VldCTE(cFilOri,cViagem)
Local aAreaDTP := DTP->(GetArea())
Local aAreaDT6 := DT6->(GetArea())
Local cQuery   := ""
Local cAliasDTP := GetNextAlias()
Local lRet      := .T.

Default cFilOri := ""
Default cViagem := ""

cQuery := "SELECT COUNT(*) NLOTE FROM " + RetSqlName("DTP") + " DTP " 

cQuery += "  INNER JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += "    ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "   AND DT6.DT6_FILORI = DTP.DTP_FILORI"
cQuery += "   AND DT6.DT6_LOTNFC = DTP.DTP_LOTNFC"
cQuery += "   AND (DT6.DT6_IDRCTE NOT IN  ('100','136') AND DT6.DT6_CHVCTG = '" + Space(Len(DT6->DT6_CHVCTG)) + "')"
cQuery += "	  AND DT6.DT6_DOCTMS IN ('2','6','7','8','9','A','E','M','P') "
cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "

cQuery += " WHERE DTP.DTP_FILIAL = '" + xFilial("DTP") + "'"
cQuery += " AND DTP.DTP_FILORI = '" + cFilOri + "' " 
cQuery += " AND DTP.DTP_VIAGEM = '" + cViagem + "' " 
cQuery += " AND DTP.DTP_TIPLOT IN ('" + StrZero(3,Len(DTP->DTP_TIPLOT)) + "', '" + StrZero(4,Len(DTP->DTP_TIPLOT)) + "') "  //-- 3 - Eletronico -- 4 CTe Unico
cQuery += " AND DTP.D_E_L_E_T_ = ' ' " 					

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cAliasDTP, .F., .T. )
dbSelectArea((cAliasDTP))
If (cAliasDTP)->(!Eof())
	If (cAliasDTP)->NLOTE > 0
		lRet:= .F.
	EndIf
EndIf
(cAliasDTP)->(DbCloseArea())

RestArea(aAreaDTP)
RestArea(aAreaDT6)
FwFreeArray(aAreaDTP)
FwFreeArray(aAreaDT6)
Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} TF64ChkLot
Verifica a quantidade de Notas digitadas no Lote antes do Calculo
@type Static Function
@author Katia
@since 29/12/2020
@return lRet
*/
//-------------------------------------------------------------------
Static Function TF64ChkLot(cFilOri,cLote)
Local aAreaDTP:= DTP->(GetArea())
Local lRet    := .T.

DTP->(DbSetOrder(2)) //DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
If DTP->(MsSeek(xFilial("DTP")+cFilOri+cLote))
	If DTP->DTP_QTDDIG > 0 .And. DTP->DTP_QTDDIG < DTP->DTP_QTDLOT
		RecLock("DTP",.F.)
		DTP->DTP_STATUS := "2"
		DTP->DTP_QTDLOT := DTP->DTP_QTDDIG
		DTP->(MsUnLock())
	EndIf
EndIf

RestArea(aAreaDTP)
Return( lRet )


/*{Protheus.doc} TF64EstExp
Estorno da Viagem Express 
@type Function
@author Katia
@since 05/07/2021
@version version
*/
Function TF64EstExp(cFilOri,cViagem)
Local aAreas     := {DTC->(GetArea()),DT6->(GetArea()),DUD->(GetArea()),DTA->(GetArea()),DTX->(GetArea()),DTQ->(GetArea()),DTY->(GetArea()),;
                     DTP->(GetArea()),GetArea()}
Local aDocExcMot := {}
Local aDelDUD    := {}
Local aCabDTP    := {}
Local aCabDTC    := {}
Local aItemDTC   := {}
Local aItem      := {}
Local lCont      := .F.
Local lProcessa  := .T.
Local cQuery     := ""
Local cAliasDTP  := ""
Local nLote      := 0
						
Private aRotina     := {}
Private lMsErroAuto := .F.

Default cFilOri := ""
Default cViagem := ""

DTQ->(DbSetOrder(2))
If DTQ->(DbSeek(xFilial('DTQ') + cFilOri + cViagem))		
	lCont:= DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) .Or. DTQ->DTQ_STATUS == StrZero(5,Len(DTQ->DTQ_STATUS))
	If !lCont
		Help( ,, 'HELP',, STR0023, 1, 0) //"Estorno permitido apenas para vigem em aberto ou fechada
	EndIf
EndIf

If lCont
	cAliasDTP := GetNextAlias()
	cQuery := "SELECT DTP.R_E_C_N_O_ RECNO FROM " + RetSqlName("DTP") + " DTP " 
	cQuery += " WHERE DTP_FILIAL = '" + xFilial("DTP") + "'"
	cQuery += " AND DTP_FILORI = '" + cFilOri + "' " 
	cQuery += " AND DTP_VIAGEM = '" + cViagem + "' " 
	cQuery += " AND D_E_L_E_T_ = ' ' " 					
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cAliasDTP, .F., .T. )
	While (cAliasDTP)->(!Eof())	
		DTP->(dbGoTo((cAliasDTP)->RECNO))

		//--- Valida os Acessos
		lCont:= TMAcessExp(DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA)

		//--- Fechamento da Viagem
		If lCont .And. DTQ->DTQ_STATUS == StrZero(5,Len(DTQ->DTQ_STATUS))  //Fechada
			FWMsgRun(, {|| lCont:= EstFechto() }, STR0021 + STR0015 )  //processando o estorno - Fechato 
		EndIf
					
		//--- Contrato de Carreteiro
		If lCont				
			FWMsgRun(, {|| lCont:= EstContra()}, STR0021 + STR0016 )  //processando o estorno - Contrato
		EndIf

		//--- Manifesto da Viagem
		If lCont	
			FWMsgRun(, {|| lCont:= EstManife()}, STR0021 + STR0017 )  //Processando o estorno -  Manifesto
		EndIf
			
		//--- Carregamento da Viagem
		If lCont
			FWMsgRun(, {|| lCont:= EstCarrega()}, STR0021 + STR0018 )  //rocessando o estorno -  Carregamento
		EndIf

		//--- Altera a viagem, excluindo os doctos
		If lCont
			FWMsgRun(, {|| lCont:= AltViagem(cFilOri,cViagem)},  STR0019 )  //Excluindo os Documentos da Viagem
		EndIf

		//-- Cálculo do Frete
		If lCont
			FWMsgRun(, {|| lCont:= EstCalculo()},  STR0021 + STR0020 + STR0012 + DTP->DTP_LOTNFC )  //Processando o estorno - Calculo do Frete
		EndIf

		//-- Nota Fiscal
		If lCont 
			FWMsgRun(, {|| lCont:= EstNota()},  STR0021 + STR0022 )  //Processando o estorno - Nota
		EndIf
		//-- Estorno do Lote -> sendo excluido pelo TMSA200 qdo Viagem Modelo3
			
		If !lCont
			lProcessa:= .F.
			Exit			
		EndIf

		nLote:= 1
		(cAliasDTP)->(dbSkip())		
	EndDo
	(cAliasDTP)->(dbCloseArea())		
		
	If lProcessa   //Exclui a Viagem apos todo o processo de estorno concluido
		If nLote == 0
			Help("",1,"TMSAF6803",,,03,00)	//-- "Viagem não é Express."
			lCont:= .F.
		Else
			FWMsgRun(, {|| lCont:= EstViagem(cFilOri,cViagem)},  STR0021 + STR0002 + DTQ->DTQ_VIAGEM )  //Processando o estorno - viagem
			If lCont
				Help("",1,"TMSAF6804",,,03,00)	//-- Estorno da viagem realizado com sucesso. ### Total ### Parcial
			EndIf
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aRotina)
FwFreeArray(aDocExcMot)
FwFreeArray(aDelDUD)
FwFreeArray(aCabDTP)
FwFreeArray(aCabDTC)
FwFreeArray(aItemDTC)
FwFreeArray(aItem)

Return( Nil )


/*{Protheus.doc} TMAcessExp
Valida acesso a rotina - Funçao removida do TMSAF68
@type Function
@author Katia
@since 06/07/2021
@version version
*/
Static Function TMAcessExp(cSerTMS,cTipTra)
Local lCont    := .F.
Local lCTeUnico:= .F.

	If cSerTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) 
		If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
			lCont := TmsAcesso(,"TMSA310B",,4,.F.)	//-- Fechamento
		ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Aereo
			lCont := TmsAcesso(,"TMSA310C",,4,.F.)	//-- Fechamento
		EndIf
		If lCont
			lCont := TmsAcesso(,"TMSAF90",,4,.F.)	//-- Carregamento
		EndIf
	ElseIf cSerTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) 
		If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
			If DTP->DTP_TIPLOT == "4"    
				lCTeUnico := .T.		
			EndIf
			lCont := TmsAcesso(,"TMSA310D",,4,.F.)	//-- Fechamento		
		ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Aereo
			lCont := TmsAcesso(,"TMSA310F",,4,.F.)	//-- Fechamento	
		EndIf

		If lCont
			lCont := TmsAcesso(,"TMSAF90",,4,.F.)	//-- Carregamento
		EndIf
	EndIf

	If lCont
		lCont := TmsAcesso(,"TMSA250",,5,.F.)	//-- Contrato Carreteiro
	EndIf
	If lCont
		lCont := TmsAcesso(,"TMSA190",,4,.F.)	//-- Manifesto
	EndIf

	If !lCont
		Help("",1,"SEMPERM",,,03,00)
	Else
		lCont := TmsAcesso(,"TMSA200",,3,.F.)	.And. TmsAcesso(,"TMSA050",,4,.F.) .And. TmsAcesso(,"TMSA170",,5,.F.)	//-- Calculo do Frete / NF / Lote
	
		If lCont
			If cSerTms == StrZero(2,Len(DTQ->DTQ_SERTMS)) 
				If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
					lCont := TmsAcesso(,"TMSA144B",,5,.F.)
				ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Aereo
					lCont := TmsAcesso(,"TMSA144C",,5,.F.)
				EndIf
			ElseIf cSerTms == StrZero(3,Len(DTQ->DTQ_SERTMS)) 
				If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
					lCont := TmsAcesso(,"TMSA144D",,5,.F.)
				ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Aereo
					lCont := TmsAcesso(,"TMSA144F",,5,.F.)
				EndIf
			EndIf
		EndIf
	
		If !lCont
			Help("",1,"SEMPERM",,,03,00)
		EndIf
	EndIf

Return lCont

/*{Protheus.doc} EstFechto
Estorno do Fechamento da Viagem
@type Function
@author Katia
@since 06/07/2021
@version version
*/
Static Function EstFechto()
Local lCont  := .T.
Local aAreas := {DTQ->(GetArea()), GetArea()}

	//-- Fechamento de Viagem
	SetFunName("TMSA310")
	aRotina := {{"","",0,1},;
				{"","",0,2},;
				{"","",0,3},;
				{"","",0,5}}
	lCont := TMSA310Mnt("DTQ",DTQ->(Recno()),4,,.F.)
	SetFunName("TMSAF60")
	
AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lCont


/*{Protheus.doc} EstManife
Estorno do Manifesto da Viagem
@type Function
@author Katia
@since 06/07/2021
@version version
*/
Static Function EstManife()
Local lCont := .T.
Local aAreas:= {DTQ->(GetArea()), GetArea()}

DTX->(DbSetOrder(3))
If DTX->(DbSeek(xFilial("DTX") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
	SetFunName("TMSA190")
	aRotina := {{"","",0,1},;
				{"","",0,2},;
				{"","",0,3},;
				{"","",0,5}}
	lCont := TmsA190Mnt("DTX",DTX->(Recno()),4,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,,.F.)
	SetFunName("TMSAF60")
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lCont


/*{Protheus.doc} EstContra
Estorno do Contrato de Carreteiro
@type Function
@author Katia
@since 06/07/2021
@version version
*/
Static Function EstContra()
Local lCont  := .T.
Local aAreas := {DTQ->(GetArea()), GetArea()}

	DTY->(DbSetOrder(2))
	If DTY->(DbSeek(xFilial("DTY") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
		lCont := TMSA250Mnt("DTY",DTY->(Recno()),5,,.F.)
	EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lCont

/*{Protheus.doc} EstCarrega
Estorno do Carregamento da Viagem
@type Function
@author Katia
@since 06/07/2021
@version version
*/
Static Function EstCarrega()
Local oModelCar:= Nil
Local lCont    := .T.
Local aAreas   := {DTQ->(GetArea()), GetArea()}

DM6->(dbSetOrder(1))
If DM6->(MsSeek(xFilial("DM6")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
    //-- Carrega o Model do Carregamento
    oModelCar := FWLoadModel("TMSAF90")
    oModelCar:SetOperation(5)	//-- Exclusão
    oModelCar:Activate()

    //-- Valida a Exclusão do Carregamento
    If (lCont := oModelCar:VldData())
        oModelCar:CommitData()
    EndIf

    //-- Se Ocorreu Algum Erro Exibe Mensagem
    If !lCont
        TF67MntErr(oModelCar)
        MostraErro()
    EndIf
                    
    oModelCar:DeActivate()
    oModelCar:Destroy()
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lCont

/*{Protheus.doc} AltViagem
Altera a viagem excluindo os doctos
@type Function
@author Katia
@since 06/07/2021
@version version
*/
Static Function AltViagem(cFilOri, cViagem)
Local lCont    := .T.
Local oModelVia:= Nil
Local oModelDM3:= Nil
Local aAreas   := {DTP->(GetArea()), GetArea()}

Default cFilOri:= ""
Default cViagem:= ""

DTQ->(DbSetOrder(2))
If DTQ->(DbSeek(xFilial('DTQ') + cFilOri + cViagem))
	oModelVia:= FWLoadModel("TMSAF60")
	oModelVia:SetOperation( 4 )
	If oModelVia:Activate()
		oModelDM3:= oModelVia:GetModel('MdGridDM3')	
		If  oModelDM3:Length() > 0 .And. !oModelDM3:IsDeleted()
			oModelDM3:DelAllLine()

			If (lCont := oModelVia:VldData())
				oModelVia:CommitData()
			EndIf
							
			If !lCont
				TF67MntErr(oModelVia)			
				MostraErro()
			EndIf
		EndIf
	Else
		Help(,,'HELP',, oModelVia:GetErrorMessage()[6],1,0)
		lCont:= .F.
	EndIf
	oModelVia:DeActivate()
	oModelVia:Destroy()
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lCont

/*{Protheus.doc} EstCalculo
Estorno do Calculo do Frete
@type Function
@author Katia
@since 06/07/2021
@version version
*/
Static Function EstCalculo()
Local lCont      := .T.
Local aLotes     := {}
Local aAreas     := {DTQ->(GetArea()),DTP->(GetArea()), GetArea()}

aAdd(aLotes,{'1',;
             Nil,;
            DTP->DTP_FILORI,;
            DTP->DTP_LOTNFC,;
            DTP->DTP_DATLOT,;
            Transform(DTP->DTP_HORLOT,X3Picture("DTP_HORLOT")),;
            DTP->DTP_QTDLOT,;
            '',;
            DTP->DTP_STATUS,;
            ,;
            ,;
            ,;
            ,;
            ,;
            ,;
            ,;
            ,;
            DTP->DTP_TIPLOT  })

lConf:= T200AProc(aLotes,2,5,.T.)

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lCont

/*{Protheus.doc} EstNota
Estorno da Nota Fiscal
@type Function
@author Katia
@since 06/07/2021
@version version
*/
Static Function EstNota()	
Local aCabDTC   := {}
Local aItem     := {}
Local aItemDTC  := {}
Local cAliasDTC := ""
Local cQuery    := ""
Local lCont     := .T.
Local aAreas    := {DTQ->(GetArea()),DTP->(GetArea()), GetArea()}

cAliasDTC := GetNextAlias()
cQuery := " SELECT * "
cQuery += "   FROM " + RetSQLName("DTC") + " DTC "
cQuery += "  WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "'"
cQuery += "    AND DTC.DTC_FILORI = '" + DTP->DTP_FILORI + "'"
cQuery += "    AND DTC.DTC_LOTNFC = '" + DTP->DTP_LOTNFC + "'"
cQuery += "    AND DTC.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasDTC,.F.,.T.)
While (cAliasDTC)->(!Eof())
	aCabDTC := {{"DTC_FILIAL",(cAliasDTC)->(DTC_FILIAL),Nil},;
				{"DTC_FILORI",(cAliasDTC)->(DTC_FILORI),Nil},;
				{"DTC_LOTNFC",(cAliasDTC)->(DTC_LOTNFC),Nil},;
				{"DTC_CLIREM",(cAliasDTC)->(DTC_CLIREM),Nil},;
				{"DTC_LOJREM",(cAliasDTC)->(DTC_LOJREM),Nil},;
				{"DTC_DATENT",(cAliasDTC)->(DTC_DATENT),Nil},;
				{"DTC_CLIDES",(cAliasDTC)->(DTC_CLIDES),Nil},;
				{"DTC_LOJDES",(cAliasDTC)->(DTC_LOJDES),Nil},;
				{"DTC_CLIDEV",(cAliasDTC)->(DTC_CLIDEV),Nil},;
				{"DTC_LOJDEV",(cAliasDTC)->(DTC_LOJDEV),Nil},;
				{"DTC_CLICAL",(cAliasDTC)->(DTC_CLICAL),Nil},;
				{"DTC_LOJCAL",(cAliasDTC)->(DTC_LOJCAL),Nil},;
				{"DTC_DEVFRE",(cAliasDTC)->(DTC_DEVFRE),Nil},;
				{"DTC_SERTMS",(cAliasDTC)->(DTC_SERTMS),Nil},;
				{"DTC_TIPTRA",(cAliasDTC)->(DTC_TIPTRA),Nil},;
				{"DTC_SERVIC",(cAliasDTC)->(DTC_SERVIC),Nil},;
				{"DTC_TIPNFC",(cAliasDTC)->(DTC_TIPNFC),Nil},;
				{"DTC_TIPFRE",(cAliasDTC)->(DTC_TIPFRE),Nil},;
				{"DTC_SELORI",(cAliasDTC)->(DTC_SELORI),Nil},;
				{"DTC_CDRORI",(cAliasDTC)->(DTC_CDRORI),Nil},;
				{"DTC_CDRDES",(cAliasDTC)->(DTC_CDRDES),Nil},;
				{"DTC_DISTIV",(cAliasDTC)->(DTC_DISTIV),Nil},;
				{"DTC_CODPRO",(cAliasDTC)->(DTC_CODPRO),Nil},;
				{"DTC_NUMNFC",(cAliasDTC)->(DTC_NUMNFC),Nil},;
				{"DTC_SERNFC",(cAliasDTC)->(DTC_SERNFC),Nil}}

		aItem := {{"DTC_NUMNFC",(cAliasDTC)->(DTC_NUMNFC),Nil},;
				  {"DTC_SERNFC",(cAliasDTC)->(DTC_SERNFC),Nil},;
				  {"DTC_CODPRO",(cAliasDTC)->(DTC_CODPRO),Nil},;
				  {"DTC_CODEMB",(cAliasDTC)->(DTC_CODEMB),Nil},;
				  {"DTC_EMINFC",(cAliasDTC)->(DTC_EMINFC),Nil},;
				  {"DTC_QTDVOL",(cAliasDTC)->(DTC_QTDVOL),Nil},;
				  {"DTC_PESO"  ,(cAliasDTC)->(DTC_PESO)  ,Nil},;
				  {"DTC_PESOM3",(cAliasDTC)->(DTC_PESOM3),Nil},;
				  {"DTC_VALOR" ,(cAliasDTC)->(DTC_VALOR) ,Nil},;
				  {"DTC_BASSEG",(cAliasDTC)->(DTC_BASSEG),Nil},;
				  {"DTC_QTDUNI",(cAliasDTC)->(DTC_QTDUNI),Nil},;
				  {"DTC_EDI"   ,(cAliasDTC)->(DTC_EDI)   ,Nil},;
				  {"DTC_ESTORN","1"                      ,Nil}}
	
		Aadd(aItemDTC,aClone(aItem))

		If !Empty(aCabDTC) .And. !Empty(aItemDTC)
			lMsErroAuto := .F.
			MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,5)
			If lMsErroAuto
				MostraErro()
				lCont := .F.
			EndIf
		EndIf
						
	(cAliasDTC)->(DbSkip())
EndDo
(cAliasDTC)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lCont

/*{Protheus.doc} EstViagem
Estorno da Viagem
@type Function
@author Katia
@since 06/07/2021
@version version
*/
Static Function EstViagem(cFilOri,cViagem)
Local lCont    := .T.
Local oModelVia:= Nil
Local aAreas   := GetArea()

	DTQ->(DbSetOrder(2))
	If DTQ->(DbSeek(xFilial('DTQ') + cFilOri + cViagem))
		//-- Carrega o Model da Viagem
		oModelVia := FWLoadModel("TMSAF60")
		oModelVia:SetOperation(5)	//-- Exclusão
		If oModelVia:Activate()

			//-- Valida a Exclusão da Viagem
			If (lCont := oModelVia:VldData())
				oModelVia:CommitData()
			EndIf
			//-- Se Ocorreu Algum Erro Exibe Mensagem
			If !lCont
				//-- Monta mensagem de erro
				TF67MntErr(oModelVia)
				MostraErro()
			EndIf

			oModelVia:DeActivate()
			oModelVia:Destroy()
		Else
			Help(,,'HELP',, oModel:GetErrorMessage()[6],1,0)
			lCont:= .F.
		EndIf
	EndIf

RestArea(aAreas)
FwFreeArray(aAreas)
Return lCont

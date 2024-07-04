#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSAF69.CH"

//-----------------------------------------------
/* {Protheus.doc} TMSAF69
Rotina que administra as execuções automáticas
@type Function
@author Valdemar Roberto Mognon
@since 02/09/2020
@version P12 R12.1.29
@param nAção 1=Carregamento / 2=Fechamento
@return lRet
*///---------------------------------------------    

Function TMSAF69(nAcao,cPerg,nOpcx,oModel)
Local lRet       := .T.
Local oMdlFldDTQ := Nil
Local oMdlFldDM6 := Nil
Local lLoteVge   := .F.
Local lLoteOk    := .F.
Local lCarAut    := .T.
Local lFecAut    := .T.
Local aAreas     := {DTQ->(GetArea()),GetArea()}
Local aLotes     := {}
Local cViagem    := ""
Local cFilOri    := ""
Local lRotVgmG	:= .F.

Default nAcao  := 0
Default cPerg  := ""
Default nOpcx  := 0
Default oModel := FWModelActive()

If nAcao == 1	//-- Carregamento
	oMdlFldDTQ := oModel:GetModel("MdFieldDTQ") 

	//-- Verifica se todos os Lotes da Viagem estao calculados para efetuar o carregamento (EXPRESS)
	lLoteVge:= TF64ELote(oMdlFldDTQ:GetValue('DTQ_FILORI'),oMdlFldDTQ:GetValue('DTQ_VIAGEM'))
	If lLoteVge
		lLoteOk:= TF64VldLot(oMdlFldDTQ:GetValue('DTQ_FILORI'),oMdlFldDTQ:GetValue('DTQ_VIAGEM'),"'3'")  //3-Calculado
		If lLoteOk .And. FindFunction('TF64VldCTE')
			lLoteOk:= TF64VldCTE(oMdlFldDTQ:GetValue('DTQ_FILORI'),oMdlFldDTQ:GetValue('DTQ_VIAGEM'))  
			If !lLoteOk
				lRet:= .F.  //Lote da viagem, so carrega automatico se todos os doctos estiverem transmitidos
				aLotes := TMSAF69Lot(oMdlFldDTQ:GetValue('DTQ_FILORI'),oMdlFldDTQ:GetValue('DTQ_VIAGEM'))
				If !Empty(aLotes[1]) .And. !Empty(aLotes[2]) .And. !FwIsInCallStack("TMSA200S")
					TMSAE70(1,cFilAnt,aLotes[1],,,,,.T.,aLotes[2]) //--Monitor Cte.
					lRet := .T.
					lLoteOk:= TF64VldCTE(oMdlFldDTQ:GetValue('DTQ_FILORI'),oMdlFldDTQ:GetValue('DTQ_VIAGEM'))  
					If !lLoteOk
						lRet:= .F.  //Lote da viagem, so carrega automatico se todos os doctos estiverem transmitidos
					EndIf
				EndIF
			EndIf
		EndIf
	EndIf
	
	If lLoteOk
		lRotVgmG	:= oMdlFldDTQ:GetValue("DTQ_ROTA") == SuperGetMV("MV_ROTGENT")
		lLoteOk		:= If(lRotVgmG, .F., lLoteOk )
	EndIf

	Pergunte(cPerg,.F.)
	If ExistFunc("TmsAutViag")
		If !lRotVgmG .AND. TmsAutViag(oMdlFldDTQ:GetValue("DTQ_FILORI"),oMdlFldDTQ:GetValue("DTQ_VIAGEM"),FwFldGet("DTQ_CODAUT"),"TMSAF90")
			lCarAut := .T.
		Else
			lCarAut := (MV_PAR01 == 2)
		EndIf
	Else
		lCarAut := (MV_PAR01 == 2)
	EndIf
	
	If (lCarAut .Or. lLoteOk) .And. !TMFGetStat("lIncMot")	//-- Carregamento automático ### Não é inclusão de condutor

		If lRet
			If !IsBlind()	//-- Processo não sendo executado de forma automática
				FWMsgRun(,{|| lRet := TF67AtuCar(oModel,nOpcx)},STR0001,STR0002)	//-- "Processando" ### "Executando Carregamento Automático ..."
			Else
				lRet := TF67AtuCar(oModel,nOpcx)
			EndIf
			
			If !lRet			
				Help("",1,"TMSAF6701",,,3,1)	//-- "Carregamento automático não efetuado. Execute o carregamento manualmente."
			EndIf			
		EndIf				
	EndIf
ElseIf nAcao == 2	//-- Fechamento
	oMdlFldDM6:= oModel:GetModel ("MdFieldDM6")

	If oMdlFldDM6 != Nil
		cFilOri := oMdlFldDM6:GetValue("DM6_FILORI")
		cViagem := oMdlFldDM6:GetValue("DM6_VIAGEM")
	Else
		oMdlFldDTQ:= oModel:GetModel ("MdFieldDTQ")
		cFilOri := oMdlFldDTQ:GetValue("DTQ_FILORI")
		cViagem := oMdlFldDTQ:GetValue("DTQ_VIAGEM")
	EndIf
	
	Pergunte(cPerg,.F.)

	If ExistFunc("TmsAutViag") .And. DTQ->(ColumnPos("DTQ_CODAUT")) > 0
		DTQ->(DbSetOrder(2))
		If DTQ->(DbSeek(xFilial("DTQ") + cFilOri + cViagem))
			If TmsAutViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_CODAUT,"TMSA310")
				lFecAut := .T.
			Else
				lFecAut := (MV_PAR01 == 1)
			EndIf
		Else
			lFecAut := (MV_PAR01 == 1)
		EndIf
	Else
		lFecAut := (MV_PAR01 == 1)
	EndIf

	If lFecAut	//--Fechamento Automático
		If !IsBlind()	//-- Processo não sendo executado de forma automática
			FWMsgRun(,{|| lRet := TMSA310Mnt("DTQ",DTQ->(Recno()),nOpcx,,.F.)},STR0001,STR0003)	//-- "Processando" ### "Executando Fechamento Automático ..."
		Else
			lRet := TMSA310Mnt("DTQ",DTQ->(Recno()),nOpcx,,.F.)
		EndIf

		If !lRet
			Help("",1,"TMSAF9006",,,3,1)	//-- "Fechamento automático não efetuado. Execute o fechamento manualmente."
		EndIf
	EndIf

EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

//-----------------------------------------------
/* {Protheus.doc} TMSAF69GMC
Executa a gravação e envio do manifesto automaticamente
@type Function
@author Valdemar Roberto Mognon
@since 12/02/2021
@version P12 R12.1.29
@param 
@return
*///---------------------------------------------    
Function TMSAF69GMC()
Local cAliasNew := GetNextAlias()
Local cQuery    := ""
Local cFilBack  := cFilAnt
Local lRet      := .T.
Local lUFAtiv   := DTX->(ColumnPos("DTX_UFATIV")) > 0
Local lMdfeAut  := SuperGetMV("MV_MDFEAUT",,.F.)  .And. ExistFunc("TmsMDFeAut") //--MDFe Automatico
Local aArea     := GetArea()
Local aAreaSM0  := SM0->(GetArea())
Local aMDFe     := {}
Local nCnt      := 0

If (lMdfeAut .Or. ExistFunc("TmsAutViag")) .And. FindFunction("TMA190Srv")	//-- Verifica o serviço de transporte da viagem
	lMdfeAut:= TMA190Srv(M->DTQ_FILORI,M->DTQ_VIAGEM)
EndIf

If lMdfeAut
	//-- Verifica se há manifestos para encerrar
	cQuery := " SELECT DTX_FILMAN, DUD_MANIFE, DTX_SERMAN, DTX_VIAGEM, DTX_TIPMAN, DTX_STFMDF"
	If lUfAtiv 							
		cQuery += ", DTX_UFATIV"	
	EndIf
	cQuery += " FROM " + RetSQLName("DUD") + " DUD "
	cQuery += " JOIN " + RetSQLName("DTX") + " DTX "
	cQuery += " 	 ON DTX_FILIAL = '" + xFilial("DTX") +"'"
	cQuery += "     AND DTX_FILORI = DUD.DUD_FILORI " 
	cQuery += "     AND DTX_VIAGEM = DUD.DUD_VIAGEM "	
	cQuery += "     AND DTX_TIPMAN =  '2'  "
	cQuery += "     AND DTX_IDFMDF <> '132'"	
	cQuery += "     AND DTX.D_E_L_E_T_ =  ' ' "
	cQuery += "	WHERE   DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"	
	cQuery += "     AND DUD.DUD_VIAGEM = '" + M->DTQ_VIAGEM  + "' "
	cQuery += "     AND DUD.DUD_FILORI = '" + M->DTQ_FILORI  + "' "
	cQuery += "     AND DUD.DUD_MANIFE <> ' ' "	
	cQuery += "     AND DUD.DUD_STATUS <> '4' "
	cQuery += "     AND DUD.D_E_L_E_T_ =  ' ' "
	cQuery += "     AND EXISTS "
	cQuery += " (SELECT 1   "
	cQuery += "    FROM " + RetSQLName("DUD") + " AUX " 
	cQuery += "	  WHERE AUX.DUD_FILIAL = '" + xFilial("DUD") +"'"	
	cQuery += "     AND AUX.DUD_VIAGEM = '" + M->DTQ_VIAGEM  + "' "
	cQuery += "     AND AUX.DUD_FILORI = '" + M->DTQ_FILORI  + "' "
	cQuery += "     AND AUX.DUD_STATUS <> '4' "
	cQuery += "     AND AUX.DUD_MANIFE = ' '  "	
	//-- MDF-e Automático: apenas documentos autorizados serão manifestados
	cQuery += "     AND EXISTS (SELECT 1 FROM "+ RetSqlName("DT6") + " DT6AUX "
	cQuery += "	                    WHERE DT6AUX.DT6_FILIAL = '" + xFilial("DT6") +"'"	
	cQuery += "                       AND DT6AUX.DT6_FILDOC =  AUX.DUD_FILDOC "
	cQuery += "                       AND DT6AUX.DT6_DOC    =  AUX.DUD_DOC "
	cQuery += "                       AND DT6AUX.DT6_SERIE  =  AUX.DUD_SERIE "
	cQuery += "                       AND DT6AUX.DT6_IDRCTE =  '100' " 
	cQuery += "                       AND DT6AUX.D_E_L_E_T_ =  ' ' )"
	//-- DOCUMENTOS NÃO-MANIFESTADOS DA VIAGEM, COM ESTADO DE DESTINO OU DESCARGA IGUAIS À DOCTOS JÁ MANIFESTADOS (E NÃO ENCERRADOS) NA VIAGEM
	cQuery += "     AND ( (SELECT DUY_EST FROM "+ RetSqlName("DUY") + " DES_SMAN " // estado de Destino - docto SEM manifesto da viagem
	cQuery += "            WHERE DES_SMAN.DUY_FILIAL = '" + xFilial("DUY") + "'" 
	cQuery += "              AND DES_SMAN.DUY_GRPVEN = AUX.DUD_CDRDES "
	cQuery += "              AND DES_SMAN.D_E_L_E_T_ = ' ')" 
	cQuery += "           = " 
	cQuery += "           (SELECT DUY_EST FROM "+ RetSqlName("DUY") + " DES_CMAN " // estado de Destino - docto COM manifesto da viagem
	cQuery += "            WHERE DES_CMAN.DUY_FILIAL = '" + xFilial("DUY") + "'" 
	cQuery += "              AND DES_CMAN.DUY_GRPVEN = DUD.DUD_CDRDES "
	cQuery += "              AND DES_CMAN.D_E_L_E_T_ = ' ')" 
	cQuery += "           OR " 
	cQuery += "           (SELECT DUY_EST FROM "+ RetSqlName("DUY") + " DCA_SMAN " // Estado de descarga - docto SEM manifesto da viagem
	cQuery += "            WHERE DCA_SMAN.DUY_FILIAL = '" + xFilial("DUY") + "'" 
	cQuery += "              AND DCA_SMAN.DUY_FILDES = AUX.DUD_FILDCA "
	cQuery += "              AND DCA_SMAN.DUY_CATGRP = '" + StrZero(2,Len(DUY->DUY_CATGRP)) + "'"
	cQuery += "              AND DCA_SMAN.D_E_L_E_T_ = ' ')" 
	cQuery += "           = " 
	cQuery += "           (SELECT DUY_EST FROM "+ RetSqlName("DUY") + " DCA_CMAN " // Estado de descarga - docto COM manifesto da viagem
	cQuery += "            WHERE DCA_CMAN.DUY_FILIAL = '" + xFilial("DUY") + "'" 
	cQuery += "              AND DCA_CMAN.DUY_FILDES = DUD.DUD_FILDCA "
	cQuery += "              AND DCA_CMAN.DUY_CATGRP = '" + StrZero(2,Len(DUY->DUY_CATGRP)) + "'"
	cQuery += "              AND DCA_CMAN.D_E_L_E_T_ = ' ')" 
	cQuery += "         )" 
	cQuery += "     AND AUX.D_E_L_E_T_ =  ' '  "				
	cQuery += "  )" 
	cQuery += " GROUP BY DTX_FILMAN, DUD_MANIFE, DTX_SERMAN, DTX_VIAGEM, DTX_TIPMAN, DTX_STFMDF "
	If lUfAtiv 							
		cQuery += ", DTX_UFATIV"	
	EndIf		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.F.,.T.)		
		
	aMDFe := {} //-- só inicializa aqui para não  alocar memória caso não utilize MDFe Automático

	//-- Verifica DUD DIPONIVEL PARA MANIFESTAR		
	Do While (cAliasNew)->(!Eof())
		If (cAliasNew)->DTX_TIPMAN  == "2" .And.  (cAliasNew)->DTX_STFMDF <> "2"
			Aadd(aMDFe,{(cAliasNew)->DTX_FILMAN,;
						(cAliasNew)->DUD_MANIFE,;
						(cAliasNew)->DUD_MANIFE,;
						(cAliasNew)->DTX_SERMAN,;
						(cAliasNew)->DTX_VIAGEM,;
						Iif(lUFAtiv, (cAliasNew)->DTX_UFATIV, '')})
		EndIf
		(cAliasNew)->(DbSkip())	
	EndDo
	(cAliasNew)->(DbCloseArea())	

	If !Empty(aMDFe) .And. !Empty(aMDFe[Len(aMDFe),2])
		//-- Alterar o conteudo da variavel cFilAnt													
		cFilAnt := Posicione("SM0",1,cEmpAnt + aMDFe[Len(aMDFe),1],"FWCODFIL()")
		lContinua := TmsMDFeAut(aMDFe,2)	//-- Encerra o Manifesto
		If lContinua
			TmsLimpDUD(M->DTQ_FILORI,M->DTQ_VIAGEM,aMdfe)	//-- Limpar a DUD				
		EndIf 								         
		cFilAnt := Posicione("SM0",1,cEmpAnt + cFilBack,"FWCODFIL()") 
		RestArea(aAreaSM0)
	EndIf
EndIf

//-- Query para verificar se Existem Doctos Vinculados a viagem que nao estejam manifestados ou deletados
//-- Esta query pega os documentos que foram carregados.  
cQuery := " SELECT COUNT(DUD.DUD_FILIAL) CNT "
cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
cQuery += "   WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "     AND DUD.DUD_FILORI = '" + M->DTQ_FILORI  + "' "
cQuery += "     AND DUD.DUD_VIAGEM = '" + M->DTQ_VIAGEM  + "' "
cQuery += "     AND DUD.DUD_SERTMS <> '" + StrZero(1,Len(DUD->DUD_SERTMS)) + "' " //--não considera a documentos de Solicitações de Coletas.
If M->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transferência
	cQuery += "     AND DUD.DUD_FILDCA <> '" + cFilBack +"'"
EndIf
cQuery += "     AND DUD.DUD_MANIFE = ' ' "
cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "

//-- MDF-e Automático: apenas documentos autorizados serão manifestados
If lMdfeAut
	cQuery += " AND EXISTS( SELECT 1 FROM " + RetSqlName("DT6") + " DT6 "
	cQuery += "             WHERE DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
	cQuery += "               AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
	cQuery += "               AND DT6.DT6_DOC    = DUD.DUD_DOC"
	cQuery += "               AND DT6.DT6_SERIE  = DUD.DUD_SERIE"
	cQuery += "               AND DT6.DT6_IDRCTE = '100' "
	cQuery += "               AND DT6.D_E_L_E_T_ = ' ') "	
EndIf

cQuery := ChangeQuery( cQuery )
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasNew,.F.,.T.)
(cAliasNew)->(DbGoTop())
nCnt := (cAliasNew)->CNT
(cAliasNew)->(DbCloseArea())
RestArea(aArea)

If nCnt > 0	//-- Informa se existem doctos para manifestar
	SetMVValue("TMA190","MV_PAR01",M->DTQ_FILORI)	
	SetMVValue("TMA190","MV_PAR02",M->DTQ_VIAGEM)
	Pergunte("TMSA190",.F.)
	mv_par01  := M->DTQ_FILORI
	mv_par02  := M->DTQ_VIAGEM
        
	cCadastro := STR0004	//-- "Manifesto de Carga"
	lRet      := TmsA190Mnt("DTX",0,3,M->DTQ_FILORI,M->DTQ_VIAGEM,.F.,.F.,.F.,lMdfeAut,"")	//-- Geração do manifesto.
	DTX->(DbSetOrder(3))
	DTX->(DbSeek(FwxFilial("DTX") + M->DTQ_FILORI + M->DTQ_VIAGEM))
	If !lRet .And. DTX->DTX_TIPMAN == "2"
		Help("",1,"TMSA14416")	//-- Nao foi possivel gerar o Manifesto", "processamento interrompido!!!
	EndIf
Else
	Help("",1,"TMSA19005")	//-- "Nenhum Documento foi encontrado para esta Viagem!"
	lRet := .F.
EndIf

Return lRet

//-----------------------------------------------
/* {Protheus.doc} TMSAF69Lot
Busca o primeiro e o último lote da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 05/01/2022
@version P12 R12.1.29
@param 
@return
*///---------------------------------------------    
Static Function TMSAF69Lot(cFilOri,cViagem)
Local aAreas    := {GetArea()}
Local aRet      := {"",""}
Local cQuery    := ""
Local cAliasDTP := ""
Local lPrimeiro := .T.

Default cFilOri := ""
Default cViagem := ""

If !Empty(cFilOri) .And. !Empty(cViagem)
	cAliasDTP := GetNextAlias()
	cQuery := "SELECT DTP_LOTNFC "
	cQuery += "  FROM " + RetSqlName ("DTP") + " DTP "

	cQuery += "  JOIN " + RetSqlName ("DT6") + " DT6 "
	cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
	cQuery += "   AND DT6_FILORI = DTP_FILORI "
	cQuery += "   AND DT6_LOTNFC = DTP_LOTNFC "
	cQuery += "   AND (DT6_IDRCTE <> '100' OR (DT6_IDRCTE = '136' AND DT6_CHVCTG = ' ')) "
	cQuery += "   AND DT6.D_E_L_E_T_ = ' '"

	cQuery += "  JOIN " + RetSqlName ("DM3") + " DM3 "
	cQuery += "    ON DM3_FILIAL = '" + xFilial("DM3") + "' "
	cQuery += "   AND DM3_FILDOC = DT6_FILDOC "
	cQuery += "   AND DM3_DOC    = DT6_DOC "
	cQuery += "   AND DM3_SERIE  = DT6_SERIE "
	cQuery += "   AND DM3_FILORI = '" + cFilOri + "' "
	cQuery += "   AND DM3_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND DM3.D_E_L_E_T_ = ' '"

	cQuery += " WHERE DTP_FILIAL = '" + xFilial("DTP") + "' "
	cQuery += "   AND DTP_FILORI = '" + cFilOri + "' "
	cQuery += "   AND DTP_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND DTP.D_E_L_E_T_ = ' '"

	cQuery += " GROUP BY DTP_LOTNFC "
	cQuery += " ORDER BY DTP_LOTNFC "
		
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTP)
	
	While (cAliasDTP)->(!Eof())
		If lPrimeiro
			aRet[1] := (cAliasDTP)->DTP_LOTNFC
			lPrimeiro := .F.
		EndIf
		aRet[2] := (cAliasDTP)->DTP_LOTNFC
		(cAliasDTP)->(DbSkip())
	EndDo
	
	(cAliasDTP)->(DbCloseArea())
EndIf

AEval(aAreas,{|x| RestArea(x)})

Return aRet

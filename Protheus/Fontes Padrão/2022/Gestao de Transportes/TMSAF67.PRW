#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSAF67.CH"

Static lTmsCFec := TmsCFec()
Static lTMS3GFE := TmsIntGFE('02')
Static lTmsRdpU	:= SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho
Static lTmsRRE  := SuperGetMv("MV_TMSRRE",.F.,"") == "3"	//-- 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza

//-----------------------------------------------
/* {Protheus.doc} TMSAF67
Rotina da Gravação da Viagem Modelo 3 
@type Function
@author Katia
@since 29/06/2020
@version P12 R12.1.29
@param oModel,nTipCar Tipo de carregamento 1=Manual / 2=Automático
@return lRet
*///---------------------------------------------    

Function TMSAF67(oModel,lCommit)
Local oMdlFldDTQ := oModel:GetModel("MdFieldDTQ") 
Local oMdlFldDM4 := oModel:GetModel("MdFieldDM4") 
Local nOperation := oMdlFldDTQ:GetOperation()
Local aNewDoc    := {}
Local nAltViagem := 0
Local lRet       := .T.
Local cFilOri    := ""
Local cViagem    := ""
Local cRota      := ""
Local lGerOper	 := SuperGetMV("MV_GEROPER",,.T.)	//-- Verifica se devera gerar as operacoes
Local lVgeAntiga := (Left(FunName(),7) == "TMSA140" .Or. Left(FunName(),7) == "TMSA141" .Or. ;
					 Left(FunName(),7) == "TMSA143" .Or. Left(FunName(),7) == "TMSA144" .Or. Left(FunName(),7) == "TMSA210")

Default oModel		:= FWModelActive()
Default lCommit		:= .T. 

If lCommit

	Begin Transaction

		cFilOri	:= oMdlFldDTQ:GetValue("DTQ_FILORI") 
		cViagem	:= oMdlFldDTQ:GetValue("DTQ_VIAGEM")
		cRota   := oMdlFldDTQ:GetValue("DTQ_ROTA")
	
		If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
			
			If nOperation == MODEL_OPERATION_INSERT  
				//-- Atualiza a database do sistema na virada do dia considerando permissão de troca de dias do usuário até 00:30
				oMdlFldDTQ:LoadValue("DTQ_DATGER", dDataBase             )
				oMdlFldDTQ:LoadValue("DTQ_HORGER", TMSAF66("DTQ_HORGER") )
			EndIf 

			//-- Atualiza as Datas Inicio/Fim na Viagem.
			oMdlFldDTQ:SetValue("DTQ_DATINI", oMdlFldDM4:GetValue("DM4_DATINI"))
			oMdlFldDTQ:SetValue("DTQ_HORINI", oMdlFldDM4:GetValue("DM4_HORINI"))
			oMdlFldDTQ:SetValue("DTQ_DATFIM", oMdlFldDM4:GetValue("DM4_DATFIM"))
			oMdlFldDTQ:SetValue("DTQ_HORFIM", oMdlFldDM4:GetValue("DM4_HORFIM"))
		EndIf

		//-- Atualiza SDG
		AF67AtuSDG(oModel,nOperation)

		//-- Exclui Adiantamento
		If nOperation == MODEL_OPERATION_DELETE .Or. nOperation == MODEL_OPERATION_UPDATE .And. FwFldGet("DTQ_STATUS") == StrZero(1,Len(DTQ->DTQ_STATUS))
			lRet	:= TF67GerAdt(cFilOri , cViagem, oModel, nOperation)
		EndIf 

		//-- Retira locks da viagem
		AF67UnLock( oModel, cFilOri , cViagem )
		
		If lRet
			If nOperation == MODEL_OPERATION_UPDATE    
				//-- Gera operacoes de transporte para documentos novos
				nAltViagem := TF64GetSt("nTipAltVia")
				If lGerOper .And. DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_SERADI == StrZero(1,Len(DTQ->DTQ_SERADI)) .And. ;
				nOperation == MODEL_OPERATION_UPDATE .And. (nAltViagem == 1 .Or. nAltViagem == 2 .Or. nAltViagem == 3)	//-- É processo de mercadoria (COL) não prevista, passagem em cliente ou ponto de apoio
					aNewDoc := TF67NewDoc(oModel)
				EndIf
			EndIf

			lRet:= FwFormCommit(oModel)

			If nOperation == MODEL_OPERATION_INSERT .Or.  nOperation == MODEL_OPERATION_UPDATE
				//-- Liberação da RRE
				If lTmsRRE .And. !lVgeAntiga
					TF67AtuDJA(oModel,nOperation)	//-- Atualiza tabela de liberação da RRE
				EndIf

				//-- Grava campos memo
				TF67GrvMem(oModel,nOperation)
				
				//-- Atualiza DUD a partir da DM3
				TF67GrvDM3(oModel,nOperation,lVgeAntiga,nOperation)

				//-- Verifica se alguma linha foi deletada para limpar o DUD
				TF67DelDM3(oModel,lVgeAntiga)
				
				//-- Atualiza DTR
				TF67GrvDTR(oModel)

				//-- Gera Adiantamento
				If FwFldGet("DTQ_STATUS") == StrZero(1,Len(DTQ->DTQ_STATUS))
					lRet	:= TF67GerAdt( cFilOri , cViagem, oModel, 3 )
				EndIf

				//-- Mercadoria não prevista, passagem em cliente ou ponto de apoio
				If lRet .And. !Empty(aNewDoc) .And. (nAltViagem == 1 .Or. nAltViagem == 2 .Or. nAltViagem == 3)
					TF90GerOpe(cFilOri,cViagem,aNewDoc)
				EndIf
			ElseIf nOperation == MODEL_OPERATION_DELETE		

				//-- Cancela Programação de Carregamento
				TF67ProCa( cFilOri, cViagem )
				//-- Atualiza campos memo
				TF67GrvMem(oModel,nOperation)
				//-- Atualiza DUD a partir da DM3
				TF67DelDM3(oModel,lVgeAntiga)	

				//-- Atualiza DTP
				TF67GrvDTP(cFilOri,cViagem)   //Lote da Viagem	
			EndIf
		Endif

		If lRet
			//--------------------------------------
			//-- Bloqueios de viagem - DUC
			//--------------------------------------
			If lRet .And. !lVgeAntiga
				A67BlqViag( cFilOri, cViagem, oModel , nOperation, cRota )
			EndIf
		Endif

		If lRet .And. nOperation == MODEL_OPERATION_UPDATE
			//---Alteração da viagem executa a integração com o GFE caso a viagem ja tenha sido integrada (Fechamento, Chegada ou Saida)
			If (lTMS3GFE .Or. lTmsRdpU) .And. !lVgeAntiga
				lRet:= TF67IntGFE(.T.,,,,oModel)
			EndIf
		EndIf

		If lRet .And. AliasInDic("DN1") .And. ExistFunc("TMAltColEn")
			lRet := TMAltColEn( cFilOri, cViagem )
		EndIf

		If !lRet	
			DisarmTransaction()
			Break
		EndIf

	End Transaction

	//-- Reposiciona na viagem criada quando a atualização do SDG desposicionou-a
	If DTQ->(DTQ_FILORI + DTQ_VIAGEM) != cFilOri + cViagem
		DTQ->(DbSetOrder(2))
		If DTQ->(DbSeek(xFilial("DTQ") + cFilOri + cViagem))
			//-- Ativa o Model da Viagen
			oModel:Activate()
		EndIf
	EndIf

	If lRet .And. !lVgeAntiga
		If (DTQ->DTQ_TIPVIA != StrZero(2,Len(DTQ->DTQ_TIPVIA)) .And. DTQ->DTQ_TIPVIA != StrZero(4,Len(DTQ->DTQ_TIPVIA)))	//-- Viagem diferente de vazia e socorro
			//-- Carregamento automático
			TMSAF69(1,"TMSAF60",nOperation,oModel)
		Else
			//-- Fechamento automático
			TMSAF69(2,"TMSAF90",nOperation,)
		EndIf
	EndIf

Else

	//--------------------------------------
	//-- Retira locks da viagem
	//--------------------------------------
	AF67UnLock( oModel, cFilOri , cViagem )
	If	__lSX8
		RollBackSX8()
	EndIf
Endif

//-- Seta Variavel para 0
TF64SetSt("nTipAltVia",0)

FwFreeArray(aNewDoc)

Return lRet
//-----------------------------------------------
/* {Protheus.doc} TF67GrvDM3
Gravação dos dados da Grid de Documentos 
@author Katia
@since 01/07/2020
@version P12 R12.1.29
@return Nil
*///---------------------------------------------    
Static Function TF67GrvDM3(oModel,nOperation,lVgeAntiga,nOpcx)
Local oMdlGridDTQ := oModel:GetModel("MdFieldDTQ")
Local aAreas      := {GetArea()}
Local cJoin       := ""
Local cWhere      := ""

Default lVgeAntiga:= .F.

cJoin  := " AND ((DUD_STATUS = '1') OR (DUD_NUMRED <> ' ' AND DUD_STATUS <> '9')) "
If nOpcx == MODEL_OPERATION_UPDATE
	cWhere := " AND NOT EXISTS (SELECT 1 "
	cWhere += "                   FROM " + RetSQLName("DUD") + " DUD1 "
	cWhere += "                  WHERE DUD1.DUD_FILIAL = '" + xFilial("DUD") + "' "
	cWhere += "                    AND DUD1.DUD_FILDOC = DM3.DM3_FILDOC "
	cWhere += "                    AND DUD1.DUD_DOC    = DM3.DM3_DOC "
	cWhere += "                    AND DUD1.DUD_SERIE  = DM3.DM3_SERIE "
	cWhere += "                    AND DUD1.DUD_FILORI = '" + oMdlGridDTQ:GetValue("DTQ_FILORI") + "' "
	cWhere += "                    AND DUD1.DUD_VIAGEM = '" + oMdlGridDTQ:GetValue("DTQ_VIAGEM") + "' "
	cWhere += "                    AND DUD1.D_E_L_E_T_ = ' ') "
EndIf

cAliasQry := TF67QryDUD(oMdlGridDTQ:GetValue("DTQ_FILORI"),oMdlGridDTQ:GetValue("DTQ_VIAGEM"),cJoin,cWhere)

While (cAliasQry)->(!Eof())
	TF67AtuDUD((cAliasQry)->REGISTRO,(cAliasQry)->DM3_SEQUEN,nOpcx)
	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

//-----------------------------------------------
/* {Protheus.doc} TF67DelDM3
Deleção dos dados da Grid de Documentos 
@author Katia
@since 01/07/2020
@version P12 R12.1.29
@return Nil
*///--------------------------------------------- 
Static Function TF67DelDM3(oModel,lVgeAntiga)
Local aAreas      := {GetArea()}
Local cQuery      := ""
Local cAliasQry   := ""

Default lVgeAntiga := .F.

cAliasQry := GetNextAlias()

cQuery += "SELECT DUD.R_E_C_N_O_ REGISTRO "
cQuery += "  FROM " + RetSqlName("DUD") + " DUD "
cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") +  "' "
cQuery += "   AND DUD_VIAGEM = '" + FwFldGet("DTQ_VIAGEM") + "' "
cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
cQuery += "   AND NOT EXISTS (SELECT 1 "
cQuery += "                     FROM " + RetSqlName("DM3") + " DM3 "
cQuery += "                    WHERE DM3_FILIAL = '" + xFilial("DM3") + "' "
cQuery += "                      AND DM3_FILDOC = DUD_FILDOC "
cQuery += "                      AND DM3_DOC    = DUD_DOC "
cQuery += "                      AND DM3_SERIE  = DUD_SERIE "
cQuery += "                      AND DM3_VIAGEM = DUD_VIAGEM "
cQuery += "                      AND DM3.D_E_L_E_T_ = ' ')"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

While (cAliasQry)->(!Eof())
	TF67DelDUD((cAliasQry)->REGISTRO,lVgeAntiga)
	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return

//-----------------------------------------------
/* {Protheus.doc} TF67AtuDUD
Atualiza dados da DUD
@type Function
@author Katia
@since 29/06/2020
@version P12 R12.1.29
@return Nil
*///---------------------------------------------    
Function TF67AtuDUD(nRegistro,cSequen,nOpcx)
Local aArea      := GetArea()
Local aAreaDUD   := DUD->(GetArea())
Local lTmsCFec   := TmsCFec()
Local lTMSDCol   := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.
Local cHoraReg   := StrTran(Left(Time(),5),':','')
Local lStatus    := .F.
Local cZona      := ""
Local cSetor     := ""

Default nRegistro := 0
Default cSequen   := ""
Default nopcx     := 0

DUD->(DbGoTo(nRegistro))
							
//-- Atualiza status da solitacao da coleta
If DUD->DUD_SERTMS == StrZero( 1, Len( DUD->DUD_SERTMS ) ) 
	lStatus:= TF67AtuDT5(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,nOpcx)
EndIf
			
RecLock('DUD',.F.)
If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) .Or. lTMSDCol 
	DUD->DUD_FILORI := M->DTQ_FILORI  // Para os casos de documentos de outra filial
EndIf

DUD->DUD_VIAGEM := M->DTQ_VIAGEM			
DUD->DUD_GERROM := StrZero(1,Len(DUD->DUD_GERROM))
DUD->DUD_STROTA := StrZero(1,Len(DUD->DUD_STROTA))

If DUD->DUD_SERTMS == StrZero( 3, Len( DUD->DUD_SERTMS ) ) 
	lRet:= TMSAF62DA7(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,StrZero(1,Len(DUD->DUD_STROTA)),.F.,@cZona,@cSetor)
	If lRet
		DUD->DUD_ZONA   := cZona
		DUD->DUD_SETOR  := cSetor
	EndIf
EndIf
				
DUD->DUD_SEQUEN := cSequen
				
If lTmsCFec .And. DUD->DUD_SERTMS == StrZero( 3, Len( DUD->DUD_SERTMS ) )  
	DUD->DUD_SEQENT:= StrZero(Val(cSequen),Len(DUD->DUD_SEQENT))
EndIf

If lStatus
	DUD->DUD_STATUS := StrZero( 2, Len(DTQ->DTQ_STATUS)) // Em transito
EndIf

If nOpcx == 4  .And. DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) //-- Em Transito
	cHoraReg	    := StrTran(Left(Time(),5),':','')
	DUD->DUD_DTRNPR := dDataBase
	DUD->DUD_HRRNPR := cHoraReg
	DUD->DUD_USURNP := __cUserID
EndIf

If (lTMS3GFE .Or. lTmsRdpU) .And. Empty(DUD->DUD_NUMRED)
	DM8->(DbSetOrder(1))
	If DM8->(dBSeek(xFilial('DM8')+ DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE + DUD->DUD_FILORI + DUD->DUD_VIAGEM ))
		DUD->DUD_UFORI  := DM8->DM8_UFORI 
		DUD->DUD_CDMUNO := DM8->DM8_CDMUNO 
		DUD->DUD_CEPORI := DM8->DM8_CEPORI 
		DUD->DUD_UFDES  := DM8->DM8_UFDES 
		DUD->DUD_CDMUND := DM8->DM8_CDMUND 
		DUD->DUD_CEPDES := DM8->DM8_CEPDES 
		DUD->DUD_TIPVEI := DM8->DM8_TIPVEI 
		DUD->DUD_CDTPOP := DM8->DM8_CDTPOP 
		DUD->DUD_CDCLFR := DM8->DM8_CDCLFR 
	EndIf 
EndIf

DUD->(MsUnLock())
			
RestArea(aArea)
RestArea(aAreaDUD)
FwFreeArray(aArea)
FwFreeArray(aAreaDUD)

Return Nil

//-----------------------------------------------
/* {Protheus.doc} TF67DelDUD
Apaga o numero da viagem, dos documentos.  
@type Function
@author Katia
@since 01/07/2020
@version P12 R12.1.29
@return Nil
//Funcionalidade da função TMSA141Del()
*///---------------------------------------------    
Function TF67DelDUD(nRegistro,lVgeAntiga)
Local aAreas := {DUD->(GetArea()),DT5->(GetArea()),DT6->(GetArea()),GetArea()}

Default nRegistro  := 0
Default lVgeAntiga := .F.

DUD->(DbGoTo(nRegistro))

//-- Estorno da Integração do GFE
If !lVgeAntiga .And. (lTMS3GFE .Or. lTmsRdpU)
	TF67IntGFE(.F.,DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE)
EndIf

//-- Atualiza DFV
TF67AtuDFV(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE)

RecLock('DUD',.F.)
DUD->DUD_SEQUEN := Space(Len(DUD->DUD_SEQUEN))
If lTmsCFec .And. DTQ->DTQ_SERTMS == StrZero(3,Len(DUD->DUD_SERTMS)) 
	DUD->DUD_SEQENT := Space(Len(DUD->DUD_SEQENT))
EndIf
DUD->DUD_VIAGEM := Space(Len(DUD->DUD_VIAGEM))

If !Tmsa141Red(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE) 
	DUD->DUD_STATUS := StrZero(1,Len(DUD->DUD_STATUS))		//-- Em aberto
EndIf

DUD->DUD_STROTA := Space(Len(DUD->DUD_STROTA))
DUD->DUD_ZONA   := Space(Len(DUD->DUD_ZONA))
DUD->DUD_SETOR  := Space(Len(DUD->DUD_SETOR))
DUD->DUD_FILDCA := Space(Len(DUD->DUD_FILDCA))
DUD->DUD_GERROM := StrZero(2,Len(DUD->DUD_GERROM))

If	DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) .And. DUD->DUD_FILDOC == cFilAnt  //-- Transporte
	DUD->DUD_FILORI := DUD->DUD_FILDOC // Para os casos de documentos de outra filial
EndIf

If lTMS3GFE .Or. lTmsRdpU
	DUD->DUD_UFORI  := Space(Len(DUD->DUD_UFORI))
	DUD->DUD_CDMUNO := Space(Len(DUD->DUD_CDMUNO))
	DUD->DUD_CEPORI := Space(Len(DUD->DUD_CEPORI))
	DUD->DUD_UFDES  := Space(Len(DUD->DUD_UFDES))
	DUD->DUD_CDMUND := Space(Len(DUD->DUD_CDMUND))
	DUD->DUD_CEPDES := Space(Len(DUD->DUD_CEPDES))
	DUD->DUD_TIPVEI := Space(Len(DUD->DUD_TIPVEI))
	DUD->DUD_CDTPOP := Space(Len(DUD->DUD_CDTPOP))
	DUD->DUD_CDCLFR := Space(Len(DUD->DUD_CDCLFR))
	DUD->DUD_CHVEXT := Space(Len(DUD->DUD_CHVEXT))
EndIf

DUD->(MsUnLock())
	
//-- Atualiza status da solitacao da coleta
If DUD->DUD_SERTMS == StrZero(1,Len(DUD->DUD_SERTMS))
	DT5->(DbSetOrder(4))
	If DT5->(dbSeek(xFilial('DT5')+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))
		RecLock('DT5',.F.)
		DT5->DT5_STATUS := StrZero(1,Len(DT5->DT5_STATUS)) //-- Em Aberto
		MsUnLock()
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return( Nil )


//---------------------------------------------------------------------------------------
/* {Protheus.doc} TF67AtuDT5
Atualiza o status da Solicitacao de Coleta e valida o Status para atualizar no DUD_STATUS
@type Function
@author Katia
@since 01/07/2020
@version P12 R12.1.29
@return lStatus - T em Transito
//Funcionalidade da função TMSA141Del()
*///-------------------------------------------------------------------------------------

Function TF67AtuDT5(cFilDoc,cDoc,cSerie,nOperation)

Local aArea    := GetArea()
Local lStatus  := .F.

Default cFilDoc   := ""
Default cDoc      := ""
Default cSerie     := ""
Default nOperation := 0

DT5->(DbSetOrder(4))
If DT5->(MsSeek(xFilial("DT5")+cFilDoc+cDoc+cSerie))
	RecLock("DT5",.F.)
	If nOperation == 3
		DT5->DT5_STATUS := StrZero( 2, Len( DT5->DT5_STATUS ) ) // Indicada para Coleta
	ElseIf nOperation == 4 .And. DTQ->DTQ_STATUS == StrZero( 1, Len( DTQ->DTQ_STATUS ) )
		DT5->DT5_STATUS := StrZero( 2, Len( DT5->DT5_STATUS ) ) // Indicada para Coleta
	ElseIf nOperation == 4 .And. DTQ->DTQ_STATUS == StrZero( 2, Len( DTQ->DTQ_STATUS ) )
		DT5->DT5_STATUS := StrZero( 3, Len( DT5->DT5_STATUS ) ) // Em transito
  		lStatus := .T.
	EndIf
	DT5->(MsUnLock())				
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return lStatus

//----------------------------------------------------------------
/* {Protheus.doc} TF67GrvDTR
Atualiza dados da Grid Veiculos (DTR) com os dados do Planejamento
@author Katia
@since 08/07/2020
@version P12 R12.1.29
@return Nil
*///--------------------------------------------------------------
Function TF67GrvDTR(oModel)  
Local oMdlFldDTQ := oModel:GetModel("MdFieldDTQ")
Local oMdlFldDM4 := oModel:GetModel("MdFieldDM4")
Local oMdlFldDM5 := oModel:GetModel("MdFieldDM5")
Local cSeekDTR   := ""
Local aAreaDTR   := DTR->(GetArea())

Default oModel   := FWModelActive()

DTR->(DbSetOrder(1))
DTR->(MsSeek(cSeekDTR:= xFilial('DTR') + oMdlFldDTQ:GetValue('DTQ_FILORI') + oMdlFldDTQ:GetValue('DTQ_VIAGEM'),.F.))
While DTR->(!Eof() .And. DTR_FILIAL+DTR_FILORI+DTR_VIAGEM == cSeekDTR)
	RecLock('DTR',.F.)
	
	DTR->DTR_DATINI := oMdlFldDM4:GetValue('DM4_DATINI') 
	DTR->DTR_HORINI := oMdlFldDM4:GetValue('DM4_HORINI') 
	DTR->DTR_DATFIM := oMdlFldDM4:GetValue('DM4_DATFIM') 
	DTR->DTR_HORFIM := oMdlFldDM4:GetValue('DM4_HORFIM') 
	DTR->DTR_FILVGE := oMdlFldDM4:GetValue('DM4_FILVGE') 
	DTR->DTR_NUMVGE := oMdlFldDM4:GetValue('DM4_NUMVGE') 

	DTR->DTR_CODOPE := oMdlFldDM5:GetValue('DM5_CODOPE') 
	DTR->DTR_TPSPDG := oMdlFldDM5:GetValue('DM5_TPSPDG') 
	DTR->DTR_QTDSAQ := oMdlFldDM5:GetValue('DM5_QTDSAQ') 
	DTR->DTR_QTDTRA := oMdlFldDM5:GetValue('DM5_QTDTRA') 
	DTR->DTR_PRCTRA := oMdlFldDM5:GetValue('DM5_PRCTRA') 

	DTR->(MsUnLock())
	DTR->(DbSkip())
EndDo

RestArea(aAreaDTR)
FwFreeArray(aAreaDTR)
Return 

/* ------------------------------------------------------------------------------------
{Protheus.doc} A67BlqViag
Efetua bloquei de viagem pelo TMSBLQVIAG
@type Function
@author Caio Murakami
@since 08/07/2020
@version P12 R12.1.29
@return lRet - T , se for efetuado com sucesso
---------------------------------------------------------------------------------------*/
Static Function A67BlqViag( cFilOri, cViagem, oModel , nOperation, cRota )
Local lRet			:= .T. 
Local aArea			:= GetArea()
Local aLimite		:= {} 
Local nCapacM		:= 0 
Local cSerTms		:= ""
Local nCapCav		:= 0 
Local nTotFreRec	:= 0 
Local nContAux		:= 0 
Local oModelDM3		:= Nil
Local cFilDoc		:= ""
Local cDoc			:= ""
Local cSerie		:= ""
Local aVeiculos		:= {} 
Local aBlqAnoVei	:= {}
Local aBlqFrtCar	:= {}
Local oModelDTR		:= Nil 
Local aRetAux		:= {} 
Local cTipTra		:= ""
Local cCodVei		:= ""
Local cCodRb1		:= ""
Local cCodRb2		:= ""
Local cCodRb3		:= ""
Local cTpOpVge		:= ""
Local nQtdEix		:= 0 
Local nQtdEixV		:= 0 
Local nValFrePag	:= 0 
Local nTotFrePag	:= 0 
Local oModelDUP		:= Nil 
Local aValSeg		:= {} 
Local aBlqCarPer	:= {}
Local nAux			:= 0 
Local aBlqDoctos 	:= {{},{},{}}
Local oModelDUQ		:= Nil
Local aSaveLine		:= FWSaveRows() 
Local nCountAux		:= 0 
Local cCodMot		:= ""
Local lTela			:= .F.
Local oModelDTQ		:= Nil 

Default cFilOri		:= ""
Default cViagem		:= ""
Default oModel		:= FWModelActive()
Default nOperation	:= 3 
Default cRota       := ""

If nOperation == MODEL_OPERATION_INSERT .Or.  nOperation == MODEL_OPERATION_UPDATE

	AF67DelBlq( cFilOri, cViagem  )

	oModelDM3	:= oModel:GetModel("MdGridDM3")
	oModelDTR	:= oModel:GetModel("MdGridDTR")
	oModelDUP	:= oModel:GetModel("MdGridDUP")
	oModelDUQ	:= oModel:GetModel("MdGridDUQ")
	oModelDTQ	:= oModel:GetModel("MdFieldDTQ")

	cSerTms		:= oModelDTQ:GetValue("DTQ_SERTMS")
	cTipTra		:= oModelDTQ:GetValue("DTQ_TIPTRA")
	cTpOpVge	:= oModelDTQ:GetValue("DTQ_TPOPVG")

	DTC->(DbSetOrder(3)) //Fil.Docto. + No.Docto. + Serie Docto. + Servico + Cod. Produto
	For nContAux := 1 To oModelDM3:Length()
		oModelDM3:GoLine(nContAux)

		If !oModelDM3:IsDeleted() .And. !oModelDM3:IsEmpty()
			cFilDoc		:= oModelDM3:GetValue("DM3_FILDOC")
			cDoc		:= oModelDM3:GetValue("DM3_DOC")
			cSerie		:= oModelDM3:GetValue("DM3_SERIE")
			
			aRetAux		:=  RetLimite( aClone(aLimite), cSerTms , cFilDoc , cDoc , cSerie ) 
			
			FwFreeArray( aLimite )
			aLimite		:= {}

			For nAux := 1 To Len(aRetAux)
				Aadd( aLimite , aClone(aRetAux[nAux]) )
			Next nAux

			nTotFreRec	+= RetValFre( cFilDoc , cDoc , cSerie  )

			FwFreeArray( aRetAux )
		EndIf

	Next nContAux


	For nCountAux := 1 To oModelDTR:Length()
		oModelDTR:GoLine(nCountAux)

		If !oModelDTR:IsDeleted()
			cCodVei		:= oModelDTR:GetValue("DTR_CODVEI")
			nQtdEix		:= oModelDTR:GetValue("DTR_QTDEIX")
			nQtdEixV	:= oModelDTR:GetValue("DTR_QTEIXV")
			nValFrePag	:= oModelDTR:GetValue("DTR_VALFRE")
			
			cCodRb1		:= oModelDTR:GetValue("DTR_CODRB1")
			cCodRb2		:= oModelDTR:GetValue("DTR_CODRB2")
			cCodRb3		:= oModelDTR:GetValue("DTR_CODRB3")
			
			aRetAux	:= RetInfoVei( cRota, cSerTms, cTipTra, cTpOpVge,  cCodVei , cCodRb1, cCodRb2, cCodRb3, nQtdEix , nQtdEixV )
			If Len(aRetAux) > 0 
				If Len(aRetAux[1]) > 0  
					Aadd( aVeiculos , aClone(aRetAux[1][1]) )
				EndIf
				If Len(aRetAux[2]) > 1 
					Aadd( aBlqAnoVei, aClone(aRetAux[2][1]) )
					Aadd( aBlqFrtCar, aClone(aRetAux[3][1]) )
				EndIf
				
				nTotFrePag	+= nValFrePag
				nCapaCm		+= aRetAux[4]
				nCapCav		+= aRetAux[5]
			Endif

			FwFreeArray( aRetAux )
			aRetAux	:= {} 
			
			If !Empty( cCodVei )
				Aadd( aBlqDoctos[1] , cCodVei )
			Endif
			If !Empty( cCodRB1 )
				Aadd( aBlqDoctos[1] , cCodRB1 )
			Endif
			If !Empty( cCodRB2 )
				Aadd( aBlqDoctos[1] , cCodRB2 )
			Endif
			If !Empty( cCodRB3 )
				Aadd( aBlqDoctos[1] , cCodRB3 )
			Endif
		Endif

	Next nCountAux

	For nCountAux := 1  To oModelDUP:Length() 
		oModelDUP:GoLine(nCountAux)

		If !oModelDUP:IsDeleted()
			cCodMot	:= oModelDUP:GetValue("DUP_CODMOT")

			aRetAux	:= RetInfoMot(cCodMot)

			If Len(aRetAux[1]) > 1 
				Aadd( aValSeg 		, aClone(aRetAux[1]) )
			Endif
			If Len(aRetAux[2]) > 1 
				Aadd( aBlqCarPer 	, aClone(aRetAux[2]) )
			EndIf
			
			FwFreeArray( aRetAux )
			aRetAux	:= {} 

			If !Empty(cCodMot)
				AAdd(aBlqDoctos[2], cCodMot ) 
			Endif
		Endif

	Next nCountAux

	For nCountAux := 1 to oModelDUQ:Length()
		oModelDUQ:GoLine(nCountAux)

		If !oModelDUQ:IsDeleted()
			AAdd(aBlqDoctos[3] , oModelDUQ:GetValue("DUQ_CODAJU") )
		EndIf

	Next nCountAux

	TmsBlqViag( cFilOri , cViagem , aLimite, nCapacM, aValSeg, cSerTms, , aBlqAnoVei, aBlqCarPer, nCapCav, aBlqFrtCar, nTotFrePag, nTotFreRec, aBlqDoctos ,,, lTela, cRota )

ElseIf nOperation == MODEL_OPERATION_DELETE
	
	lRet	:= AF67DelBlq( cFilOri  , cViagem  )

EndIf


FWRestRows( aSaveLine )
RestArea( aArea )
Return lRet

/* ------------------------------------------------------------------------------------
{Protheus.doc} RetLimite
Efetua bloquei de viagem pelo TMSBLQVIAG
@type Function
@author Caio Murakami
@since 08/07/2020
@version P12 R12.1.29
@return lRet - T , se for efetuado com sucesso
---------------------------------------------------------------------------------------*/
Static Function RetLimite( aLimite ,cSerTms , cFilDoc , cDoc , cSerie   )
Local nPos			:= 0 
Local cCliente   	:= Space( Len( DTC->DTC_CLIREM ) )
Local cLoja      	:= Space( Len( DTC->DTC_LOJREM ) )
Local cProduto   	:= Space( Len( DTC->DTC_CODPRO ) )

Default aLimite		:= {} 
Default cSerTms		:= ""
Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""

//-------------------------------------------------------------------------
//- Formato do vetor aLimite                                              -
//-------------------------------------------------------------------------
//- [01] = Codigo do cliente remetente                                    -
//- [02] = Loja                                                           -
//- [03] = Codigo do produto                                              -
//- [04] = Valor da Mercadoria                                            -
//- [05] = Peso Real                                                      -
//- [06] = Peso Cubado                                                    -
//-------------------------------------------------------------------------

If cSerTms == StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) .Or. ; //-- Transporte
	cSerTms == StrZero( 3, Len( DTQ->DTQ_SERTMS ) ) //-- Entrega
	If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4( cFilDoc , cDoc  , cSerie )
		dbSelectArea("DTC")
		DTC->(DbSetOrder(3)) //Fil.Docto. + No.Docto. + Serie Docto. + Servico + Cod. Produto
		If DTC->(MsSeek( xFilial('DTC') + cFilDoc + cDoc + cSerie ))
			While DTC->(!Eof()) .And. DTC->DTC_FILIAL + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE == xFilial('DTC') + cFilDoc + cDoc + cSerie
				
				cCliente	:= DTC->DTC_CLICAL
				cLoja		:= DTC->DTC_LOJCAL
				cProduto	:= DTC->DTC_CODPRO

				If (nPos := Ascan( aLimite, { |x| x[1] + x[2] + x[3] == cCliente + cLoja + cProduto } )) == 0							
					AAdd( aLimite,{ DTC->DTC_CLICAL , DTC->DTC_LOJCAL, DTC->DTC_CODPRO, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3, Iif(DTC->DTC_VALSEG<> 0, DTC->DTC_VALSEG, DTC->DTC_VALOR)  } )
				Else	
					aLimite[nPos,4] += DTC->DTC_VALOR
					aLimite[nPos,5] += DTC->DTC_PESO
					aLimite[nPos,6] += DTC->DTC_PESOM3
				EndIf
				DTC->(DbSkip())
			EndDo
		EndIf
	Else
		dbSelectArea("DY4")
		DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
		If DY4->(MsSeek( xFilial('DY4') + cFilDoc  + cDoc + cSerie ))
			While DY4->(!Eof()) .And. DY4->DY4_FILIAL + DY4->DY4_FILDOC + DY4->DY4_DOC + DY4->DY4_SERIE == xFilial('DY4') + cFilDoc + cDoc + cSerie						
				DbSelectArea("DTC")
				DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto
				If DTC->(MsSeek(xFilial("DTC")+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM+DY4->DY4_CODPRO+DY4->DY4_FILORI+DY4->DY4_LOTNFC))	
					
					cCliente	:= DTC->DTC_CLIREM 
					cLoja		:= DTC->DTC_LOJREM
					cProduto	:= DTC->DTC_CODPRO

					If (nPos := Ascan( aLimite, { |x| x[1] + x[2] + x[3] == cCliente + cLoja + cProduto } )) == 0
						AAdd( aLimite,{ DTC->DTC_CLIREM , DTC->DTC_LOJREM, DTC->DTC_CODPRO, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3 } )
					Else
						aLimite[nPos,4] += DTC->DTC_VALOR
						aLimite[nPos,5] += DTC->DTC_PESO
						aLimite[nPos,6] += DTC->DTC_PESOM3
					EndIf
				Endif							
				DY4->(DbSkip())
			EndDo
		Endif
	Endif
ElseIf cSerTms == StrZero( 1, Len( DTQ->DTQ_SERTMS ) )  //-- Coleta
	DUM->(DbSetOrder(1))
	DT5->(DbSetOrder(4))
	If DT5->(MsSeek( xFilial('DT5') + cFilDoc + cDoc + cSerie ))
		If DUM->(MsSeek( xFilial('DUM') + DT5->DT5_FILORI + DT5->DT5_NUMSOL ))
			While DUM->(!Eof()) .And. DUM->DUM_FILIAL + DUM->DUM_FILORI + DUM->DUM_NUMSOL == xFilial('DUM') + DT5->DT5_FILORI + DT5->DT5_NUMSOL
				
				cCliente := DT5->DT5_CLIDEV
				cLoja    := DT5->DT5_LOJDEV
				cProduto := DUM->DUM_CODPRO
				
				If (nPos := Ascan( aLimite, { |x| x[1] + x[2] + x[3] == cCliente + cLoja + cProduto } )) == 0
					AAdd( aLimite,{ DT5->DT5_CLIDEV, DT5->DT5_LOJDEV, DUM->DUM_CODPRO, DUM->DUM_VALMER, DUM->DUM_PESO, DUM->DUM_PESOM3, DUM->DUM_VALMER } )
				Else 
					aLimite[nPos,4] += DUM->DUM_VALMER
					aLimite[nPos,5] += DUM->DUM_PESO
					aLimite[nPos,6] += DUM->DUM_PESOM3
					aLimite[nPos,7] += DUM->DUM_VALMER
				EndIf	

				DUM->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIf

Return aLimite 

/* ------------------------------------------------------------------------------------
{Protheus.doc} RetValFre
Efetua bloquei de viagem pelo TMSBLQVIAG
@type Function
@author Caio Murakami
@since 08/07/2020
@version P12 R12.1.29
@return lRet - T , se for efetuado com sucesso
---------------------------------------------------------------------------------------*/
Static Function RetValFre( cFilDoc , cDoc , cSerie  )
Local nTotFreRec	:= 0 

Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""

DT6->(DbSetOrder(1))
If DT6->(MsSeek(xFilial('DT6')+ cFilDoc + cDoc + cSerie ))
	nTotFreRec := DT6->DT6_VALFRE // Total do Frete a Receber dos Documentos da viagem
EndIf

Return nTotFreRec

/* ------------------------------------------------------------------------------------
{Protheus.doc} RetInfoVei
Efetua bloquei de viagem pelo TMSBLQVIAG
@type Function
@author Caio Murakami
@since 08/07/2020
@version P12 R12.1.29
@return lRet - T , se for efetuado com sucesso
---------------------------------------------------------------------------------------*/
Static Function RetInfoVei( cRota, cSerTms, cTipTra, cTpOpVge,  cCodVei , cCodRb1, cCodRb2, cCodRb3, nQtdEix , nQtdEixV )
Local aArea		:= GetArea()
Local cChave	:= ""
Local cCodFor	:= ""
Local cLojFor	:= ""
Local cVeiRas	:= ""
Local aVeiculos	:= {} 
Local nContAux	:= 0 
Local cCatVei	:= ""
Local nCapCav	:= 0 
Local nCapaCm	:= 0 
Local aBlqAnoVei	:= {}
Local aBlqFrtCar	:= {}
Local aFretCar		:= {} 

Default cRota		:= ""
Default cSerTms		:= ""
Default cTipTra		:= ""
Default cCodVei		:= ""
Default cTpOpVge	:= ""
Default cCodRb1		:= ""
Default cCodRb2		:= ""
Default cCodRb3		:= ""
Default nQtdEix		:= 0
Default nQtdEixV	:= 0  

DA3->( dbSetOrder(1) )		
If	DA3->( MsSeek( xFilial('DA3') + cCodVei ) ) .And. DA3->DA3_ATIVO == StrZero( 1, Len( DA3->DA3_ATIVO ) )	
	AAdd( aVeiculos, { cCodVei, nQtdEix ,nQtdEixV } )
		
	If !Empty( cCodRb1 )
		AAdd(aVeiculos, {cCodRB1, 0, 0 } )
	Endif

	If !Empty( cCodRb2 )
		AAdd(aVeiculos, {cCodRB2, 0, 0 } )
	Endif

	If !Empty( cCodRb3 )
		AAdd(aVeiculos, {cCodRB3, 0, 0 } )
	Endif

	AAdd( aBlqAnoVei, { DA3->DA3_COD, DA3->DA3_ANOFAB } )
EndIf

DA3->(dbSetOrder(1))
For nContAux := 1 To Len(aVeiculos)

	If DA3->( MsSeek( xFilial("DA3") + aVeiculos[nContAux,1] )) .And. DA3->DA3_ATIVO == StrZero( 1, Len( DA3->DA3_ATIVO ) )
		
		//-- Veiculo principal
		If nContAux == 1 
			
			cChave 	:= DA3->DA3_TIPVEI
			cCodFor	:= DA3->DA3_CODFOR
			cLojFor := DA3->DA3_LOJFOR
			cVeiRas := DA3->DA3_VEIRAS
			cCatVei	:= Posicione('DUT',1,xFilial('DUT')+DA3->DA3_TIPVEI,'DUT_CATVEI') 

			If cCatVei == StrZero(2, Len(DUT->DUT_CATVEI)) //-- Se o Tipo do Veiculo for 'Cavalo'
				nCapCav += DA3->DA3_CAPACM
			Else
				nCapaCm += DA3->DA3_CAPACM
			EndIf
		Else
			nCapaCm += DA3->DA3_CAPACM
			cChave	+= DA3->DA3_FROVEI
		EndIf
				
	Else
		cChave	+= StrZero(0, Len(DA3->DA3_FROVEI))
	Endif
	
Next nContAux

cChave	+= cVeiRas

//-- Verifica se existe a Tabela de Carreteiro por Rota
aFretCar := TMSFretCar(cRota, cCodFor, cLojFor, aVeiculos, cChave, cSerTms , cTipTra ,,,,,, cTpOpVge )

//-- Bloqueia a Viagem se o Valor do Frete a Pagar for Maior que o valor do frete Calculado
If !Empty(aFretCar) .And. !Empty(aFretCar[2]) .And. nValFrePag > aFretCar[2]
	AAdd(aBlqFrtCar, { nValFrePag, aFretCar[2] })
EndIf

RestArea( aArea )
Return { aVeiculos, aBlqAnoVei , aBlqFrtCar , nCapacM , nCapCav  }

/* ------------------------------------------------------------------------------------
{Protheus.doc} RetInfoMot
Efetua bloquei de viagem pelo TMSBLQVIAG
@type Function
@author Caio Murakami
@since 08/07/2020
@version P12 R12.1.29
@return lRet - T , se for efetuado com sucesso
---------------------------------------------------------------------------------------*/
Static Function RetInfoMot(cCodMot)
Local aArea			:= GetArea() 
Local aValSeg		:= {} 
Local aBlqCarPer	:= {}

Default cCodMot		:= ""

If DA4->( MsSeek( xFilial("DA4") + cCodMot ) ) .And. DA4->DA4_BLQMOT == StrZero( 2, Len( DA4->DA4_BLQMOT ) )
	/* Obtem o valor de marcadoria que o motorista tem permissao para carregar. */
	AAdd(aValSeg,    { DA4->DA4_COD, DA4->DA4_VALSEG })
	AAdd(aBlqCarPer, { DA4->DA4_COD, DA4->DA4_CARPER })
EndIf

RestArea( aArea )
Return { aValSeg , aBlqCarPer }

/* ------------------------------------------------------------------------------------
{Protheus.doc} AF67DelBlq
Deleta bloquei de viagem gerado pelo TMSBLQVIAG
@type Function
@author Caio Murakami
@since 08/07/2020
@version P12 R12.1.29
@return lRet - T , se for efetuado com sucesso
---------------------------------------------------------------------------------------*/
Static Function AF67DelBlq( cFilOri , cViagem )
Local aArea			:= GetArea()
Local lRet			:= .T. 
Local aAvaliaBlq	:= {} 
Local lTmsa029   	:= FindFunction("TMSA029USE")
Local nOpcx			:= 5 

Default cFilOri	:= ""
Default cViagem	:= ""

//-- Exclui bloqueio da viagem
DUC->( DbSetOrder( 1 ) )
While DUC->( MsSeek( xFilial('DUC') + cFilOri + cViagem ) )
	If	(DUC->DUC_CODBLQ == PadR('D1', Len(DUC->DUC_CODBLQ)) .Or.;
			DUC->DUC_CODBLQ == PadR('D2', Len(DUC->DUC_CODBLQ)) .Or.;
			DUC->DUC_CODBLQ == PadR('D3', Len(DUC->DUC_CODBLQ)) .Or.;
			DUC->DUC_CODBLQ == PadR('D4', Len(DUC->DUC_CODBLQ)))
		
		AAdd(aAvaliaBlq ,{	DUC->DUC_CODBLQ,;
							DUC->DUC_CODFOR,;
							DUC->DUC_LOJFOR,;
							DUC->DUC_CODMOT,;
							DUC->DUC_DTAAPR,;
							DUC->DUC_DTAAFA,;
							DUC->DUC_DTARET,;
							.F. } )
	EndIf
	RecLock('DUC',.F.,.T.)
	DUC->(DbDelete())
	MsUnLock()
EndDo

//-- Ajusta o Status das Tabelas referentes ao Controle de Documentos de Terceiros
TMSAvlBlqDoc( aAvaliaBlq, .T. )

// Exclui Registro De Bloqueio Por Incompatibilidade De Produtos.
If lTmsa029  
	If Tmsa029Use("TMSA140")

		// Caso Existam Bloqueios, Limpa Referencia
		Tmsa029Blq( 5  ,;								// 01 - nOpc
					'TMSA140',;							// 02 - Rotina
					Nil,;								// 03 - Tipo Bloq (Nil Apaga Todos Codigos de Bloqueio da Viagem
					cFilOri ,;							// 04 - Filial Origem
					'DUC',;								// 05 - Tabela Referencial
					'1',;								// 06 - Indice Da Tabela
					xFilial('DUC') + cFilOri + cViagem,;	// 07 - Chave Indexação
					"",;									// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
					"",;									// 09 - Detalhes Adicionais a Respeito Do Bloqueio
					nOpcx)									// 10 - Opcao da Rotina 
	EndIf
	
	If Tmsa029Use("TMSA310")				
		// Caso Existam Bloqueios, Limpa Referencia
		Tmsa029Blq( 5  ,;					// 01 - nOpc
					'TMSA310',;				// 02 - Rotina
					Nil,;					// 03 - Tipo Bloq (Nil Apaga Todos Codigos de Bloqueio da Viagem
					cFilOri	,;				// 04 - Filial Origem
					'DTQ',;					// 05 - Tabela Referencial
					'1',;					// 06 - Indice Da Tabela
					xFilial('DTQ') + cFilOri + cViagem ,;	// 07 - Chave Indexação
					"",;				// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
					"",;				// 09 - Detalhes Adicionais a Respeito Do Bloqueio
					nOpcx)				// 10 - Opcao da Rotina			
						
	EndIf

EndIf

RestArea( aArea )
Return lRet

/* ------------------------------------------------------------------------------------
{Protheus.doc} AF67UnLock
Tratamento dos locks de viagem no commit
@type Function
@author Caio Murakami
@since 13/07/2020
@version P12 R12.1.29
@return lRet - T , se for efetuado com sucesso
---------------------------------------------------------------------------------------*/
Static Function AF67UnLock( oModel, cFilOri , cViagem )
Local lRet		:= .F.
Local aArea		:= GetArea()
Local aSaveLine	:= FWSaveRows() 
Local oModelDM3	:= Nil
Local oModelDTR	:= Nil
Local oModelDUQ	:= Nil
Local nCount	:= 1 
Local cFilDoc	:= ""
Local cDoc		:= ""
Local cSerie	:= ""
Local cCodVei	:= ""
Local cCodRB1	:= ""
Local cCodRb2	:= ""
Local cCodRB3	:= ""
Local cCodAju	:= ""

Default oModel	:= FWModelActive()
Default cFilOri	:= ""
Default cViagem	:= ""

oModelDM3	:= oModel:GetModel("MdGridDM3")
oModelDTR	:= oModel:GetModel("MdGridDTR")
oModelDUQ	:= oModel:GetModel("MdGridDUQ")

//------------------------------------------
//-- Controla desbloqueio dos documentos
//------------------------------------------
For nCount := 1 To oModelDM3:Length()
	oModelDM3:GoLine(nCount)

	cFilDoc	:= oModelDM3:GetValue("DM3_FILDOC")
	cDoc	:= oModelDM3:GetValue("DM3_DOC")
	cSerie	:= oModelDM3:GetValue("DM3_SERIE")

	TF67BlqDoc( cFilDoc , cDoc , cSerie , .F. , .F.  )	
Next nCount 

//------------------------------------------
//-- Controla desbloqueio dos veículos
//------------------------------------------
For nCount := 1 To oModelDTR:Length()
	oModelDTR:GoLine(nCount)

	cCodVei		:= oModelDTR:GetValue("DTR_CODVEI")
	cCodRB1		:= oModelDTR:GetValue("DTR_CODRB1")
	cCodRB2		:= oModelDTR:GetValue("DTR_CODRB2")
	cCodRB3		:= oModelDTR:GetValue("DTR_CODRB3")

	TF67BlqVei( cCodVei , cCodRB1 , cCodRB2, cCodRB3 , .F. , .F. )
Next nCount 

//------------------------------------------
//-- Controla desbloqueio dos ajudantes
//------------------------------------------
For nCount := 1 To oModelDUQ:Length()
	
	oModelDUQ:GoLine(nCount)

	cCodAju		:= oModelDUQ:GetValue("DUQ_CODAJU")

	TF67BlqAju( cCodAju , .F. , .F. )
Next nCount


FWRestRows(aSaveLine)
RestArea( aArea )
Return lRet

/* ------------------------------------------------------------------------------------
{Protheus.doc} TF67BlqDoc
Tratamento dos Locks documentos da viagem
@type Function
@author Caio Murakami
@since 13/07/2020
@version P12 R12.1.29
@return lRet - T , se for efetuado com sucesso
---------------------------------------------------------------------------------------*/
Function TF67BlqDoc( cFilDoc , cDoc , cSerie , lBloqueia , lShowErr )
Local lRet		:= .T. 

Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""
Default lBloqueia	:= .T.
Default lShowErr	:= .F. 

If !Empty(cDoc)
	If lBloqueia
		lRet	:= TmsConTran( cFilDoc , cDoc , cSerie , .T. )

		If !lRet
			Help(' ',1,'TMSA14105',, cFilDoc + " " + cDoc + "-" + cSerie ,3,1) //--"O documento foi selecionado em outra viagem." ### "Docto."
		EndIf

	Else
		lRet	:= TmsConTran( cFilDoc , cDoc , cSerie , .F. )
	EndIf
Endif

Return lRet 

/* ------------------------------------------------------------------------------------
{Protheus.doc} TF67BlqVei
Tratamento dos Locks para veículos da viagem
@type Function
@author Caio Murakami
@since 13/07/2020
@version P12 R12.1.29
@return lRet - T , se for efetuado com sucesso
---------------------------------------------------------------------------------------*/
Function TF67BlqVei( cCodVei , cCodRB1 , cCodRB2, cCodRB3 , lBloqueia , lShowErr )
Local lRet		:= .T. 
Local lEmViag 	:= SuperGetMV('MV_EMVIAG',,.F.)
Local lContVei  := SuperGetMv("MV_CONTVEI")

Default cCodVei		:= ""
Default cCodRB1		:= ""
Default cCodRB2		:= ""
Default cCodRb3		:= ""
Default lBloqueia	:= .F. 
Default lShowErr	:= .F. 

If lEmViag .Or. lContVei
	If lBloqueia

		If !Empty(cCodVei)
			lRet	:= LockByName("VGEVEI" + cCodVei ,.T.,.F.)
			
			If !lRet .And. lShowErr
				Help( ' ', 1, 'TMSA24050', , RetTitle("DA3_COD") + ": " + cCodVei ,3 ,0) //"O Veiculo esta sendo utilizado por outra viagem." ### "Veiculo: "
			EndIf
		Endif

		If !Empty(cCodRB1)
			lRet	:= LockByName("VGERB1" + cCodRB1 ,.T.,.F.)
			If !lRet .And. lShowErr
				Help( ' ', 1, 'TMSA24050', , RetTitle("DA3_COD") + ": " + cCodRB1 ,3 ,0) //"O Veiculo esta sendo utilizado por outra viagem." ### "Veiculo: "
			EndIf
		Endif
		If !Empty(cCodRB2)
			lRet	:= LockByName("VGERB2" + cCodRB2 ,.T.,.F.)
			If !lRet .And. lShowErr
				Help( ' ', 1, 'TMSA24050', , RetTitle("DA3_COD") + ": " + cCodRB2 ,3 ,0) //"O Veiculo esta sendo utilizado por outra viagem." ### "Veiculo: "
			EndIf
		Endif
		If !Empty(cCodRB3)
			lRet	:= LockByName("VGERB3" + cCodRB3 ,.T.,.F.)
			If !lRet .And. lShowErr
				Help( ' ', 1, 'TMSA24050', , RetTitle("DA3_COD") + ": " + cCodRB3 ,3 ,0) //"O Veiculo esta sendo utilizado por outra viagem." ### "Veiculo: "
			EndIf
		EndIf

		If !lRet	
			//------------------------------------------
			//-- Se ocorreu erro deve desbloquear demais
			//------------------------------------------
			TF67BlqVei( cCodVei , cCodRB1 , cCodRB2, cCodRB3 , .F. , .F. )
		Endif

	Else
		If !Empty(cCodVei)
			UnLockByName("VGEVEI" + cCodVei ,.T.,.F.)
		Endif
		If !Empty(cCodRB1)
			UnLockByName("VGERB1" + cCodRB1 ,.T.,.F.)
		Endif
		If !Empty(cCodRB2)
			UnLockByName("VGERB2" + cCodRB2 ,.T.,.F.)
		Endif
		If !Empty(cCodRB3)
			UnLockByName("VGERB3" + cCodRB3 ,.T.,.F.)
		EndIf
	Endif
Endif

Return lRet 

/* ------------------------------------------------------------------------------------
{Protheus.doc} TF67BlqAju
Tratamento dos Locks para ajudantes da viagem
@type Function
@author Caio Murakami
@since 15/07/2020
@version P12 R12.1.29
@return lRet - T , se for efetuado com sucesso
---------------------------------------------------------------------------------------*/
Function TF67BlqAju( cCodAju , lBloqueia , lShowErr ) 
Local lRet		:= .T.

Default cCodAju		:= ""
Default lBloqueia	:= .F.
Default lShowErr	:= .F. 

If !Empty(cCodAju)
	If lBloqueia
		If !LockByName("VGEAJU" + cCodAju ,.T.,.F.)
			Help( ' ', 1, 'TMSA24048', , RetTitle("DUQ_CODAJU") + ": " + cCodAju ,3 ,0) //"O Ajudante esta sendo utilizado por outra viagem." ### "Ajudante: "
			lRet := .F.
		EndIf
	Else
		UnLockByName("VGEAJU" + cCodAju ,.T.,.F.)
	EndIf
EndIf

Return lRet

/* ------------------------------------------------------------------------------------
{Protheus.doc} AF67AtuSDG
Tratamento para atualizar SDG na gravação
@type Function
@author Caio Murakami
@since 28/07/2020
@version P12 R12.1.29
@return lRet - T , se for efetuado com sucesso
---------------------------------------------------------------------------------------*/
Static Function AF67AtuSDG( oModel , nOperation )
Local lRet		:= .T. 
Local aArea		:= GetArea()
Local aSaveLine	:= FWSaveRows() 
Local oMdlGrid	:= Nil 
Local nCount	:= 1 
Local cDoc      := ""
Local cCodFor	:= ""
Local cLojFor	:= ""
Local cSeqOri	:= ""
Local dDataBaix	:= CToD("")
Local cMotBaix	:= ""
Local cStatus	:= ""
Local cNumSeq	:= ""
Local oMdlDTR	:= ""
Local nContDTR	:= 0 
Local cCodVei	:= ""
Local aCotacao  := {1,RecMoeda(dDataBase,2),RecMoeda(dDataBase,3),RecMoeda(dDataBase,4),RecMoeda(dDataBase,5)}
Local nValor	:= 0

Default oModel		:= FWModelActive()
Default nOperation	:= 3

oMdlDTR		:= oModel:GetModel("MdGridDTR")

If nOperation == MODEL_OPERATION_INSERT .Or.  nOperation == MODEL_OPERATION_UPDATE
	
	DA3->(dbSetOrder(1))
	For nContDTR := 1 To oMdlDTR:Length()
		If !oMdlDTR:IsDeleted()
			oMdlDTR:GoLine(nContDTR)
			cCodVei		:= oMdlDTR:GetValue("DTR_CODVEI")
			cDoc		:= ""
			oMdlGrid	:= oModel:GetModel("MdGridSDG")
	
			If !oMdlGrid:IsDeleted() 
				oMdlGrid:SetNoUpdateLine(.F.)
				
				For nCount := 1 To oMdlGrid:Length()
					oMdlGrid:GoLine(nCount)
					
					If !oMdlGrid:IsDeleted() .And. !Empty(oMdlGrid:GetValue("DG_CODDES")) 
						cCodFor		:= ""
						cLojFor		:= ""
						cSeqOri		:= ""
						dDataBaix	:= CToD("")
						cMotBaix	:= ""
						cStatus		:= ""
						cNumSeq		:= oMdlGrid:GetValue("DG_NUMSEQ")
						nValor		:= oMdlGrid:GetValue("DG_TOTAL")
	
						If Empty(cDoc)
							If !Empty( oMdlGrid:GetValue("DG_DOC") ) 
								cDoc 	:= oMdlGrid:GetValue("DG_DOC")
							Else	
								cDoc	:= 	 NextNumero("SDG",1,"DG_DOC",.T.)
							EndIf 
						EndIf
	
						If Empty(cNumSeq)
							cNumSeq	:= StrZero( Val(ProxNum()),TamSX3("DG_NUMSEQ")[1] )		
						Endif
	
						If oMdlGrid:GetValue("DG_SALDO") == 0
							cSeqOri		:= cNumSeq
							dDataBaix	:= dDataBase 
							cMotBaix	:= StrZero(1,Len(SDG->DG_MOTBAI)) //-- Normal
							cStatus		:= StrZero(3,Len(SDG->DG_STATUS)) //-- Baixa Total
						Elseif oMdlGrid:GetValue("DG_SALDO") == oMdlGrid:GetValue("DG_VALCOB")
							cStatus		:= StrZero(1,Len(SDG->DG_STATUS)) //-- Em aberto
						Endif
						
						If DA3->(dbSeek(FwxFilial("DA3") + cCodVei ))
							cCodFor := DA3->DA3_CODFOR
							cLojFor := DA3->DA3_LOJFOR
						EndIf
	
						oMdlGrid:LoadValue("DG_DOC"		, cDoc )
						oMdlGrid:LoadValue("DG_NUMSEQ"	, cNumSeq )
						oMdlGrid:LoadValue("DG_EMISSAO"	, dDataBase )
						oMdlGrid:LoadValue("DG_CODFOR"	, cCodFor )
						oMdlGrid:LoadValue("DG_LOJFOR"	, cLojFor ) 
						oMdlGrid:LoadValue("DG_SEQORI"	, cSeqOri )
						oMdlGrid:LoadValue("DG_CUSTO1" 	, nValor )
						oMdlGrid:LoadValue("DG_CUSTO2" 	, If(aCotacao[2]>0,nValor/aCotacao[2],0) )
						oMdlGrid:LoadValue("DG_CUSTO3" 	, If(aCotacao[3]>0,nValor/aCotacao[3],0) )
						oMdlGrid:LoadValue("DG_CUSTO4" 	, If(aCotacao[4]>0,nValor/aCotacao[4],0) )
						oMdlGrid:LoadValue("DG_CUSTO5" 	, If(aCotacao[5]>0,nValor/aCotacao[5],0) )
						oMdlGrid:LoadValue("DG_DATBAI"	, dDataBaix )
						oMdlGrid:LoadValue("DG_MOTBAI"	, cMotBaix )
						oMdlGrid:LoadValue("DG_STATUS"	, cStatus )
	
						If AllTrim( Upper(oMdlGrid:GetValue("DG_ORITIT"))) == "TMSAF60"
							oMdlGrid:LoadValue("DG_TITGER"	, "2" )
							oMdlGrid:LoadValue("DG_ORITIT"	, "" )
							oMdlGrid:LoadValue("DG_PARC"	, "" )
						EndIf
	
					EndIf
	
				Next nCount
			EndIf
		EndIf
	Next nContDTR
Endif

FWRestRows(aSaveLine)
RestArea( aArea )
Return lRet 

/* ------------------------------------------------------------------------------------
{Protheus.doc} TF67GerAdt
Geração de adiantamento
@type Function
@author Caio Murakami
@since 31/07/2020
@version P12 R12.1.29
@return lRet - T , se for efetuado com sucesso
---------------------------------------------------------------------------------------*/
Function TF67GerAdt( cFilOri, cViagem , oModel , nOperation )
Local aArea		:= GetArea()
Local cCodVei	:= ""
Local oMdlGrid	:= Nil
Local oMdlSDG	:= Nil 
Local nAux		:= 1 
Local nAuxSDG	:= 1 
Local cCodDes	:= ""
Local lRet		:= .T. 
Local aSaveLine	:= FWSaveRows(oModel) 
Local lExclui	:= .F. 

Default cFilOri		:= ""
Default cViagem		:= ""
Default oModel		:= FwModelActive()
Default nOperation	:= 3 

If nOperation == MODEL_OPERATION_INSERT 
	oMdlGrid	:= oModel:GetModel("MdGridDTR")

	For nAux := 1 To oMdlGrid:Length()
		oMdlGrid:GoLine(nAux)
		If !oMdlGrid:IsDeleted()
			cCodVei	:= oMdlGrid:GetValue("DTR_CODVEI")
			BEGIN TRANSACTION
			lRet	:= TMSA070Prc( cFilOri, cViagem , cCodVei, 3 )
			END TRANSACTION
		EndIf
	Next nAux 

ElseIf nOperation == MODEL_OPERATION_UPDATE
	oMdlGrid	:= oModel:GetModel("MdGridDTR")

	For nAux := 1 To oMdlGrid:Length()
		oMdlGrid:GoLine(nAux)
		lExclui	:= .F. 

		oMdlSDG	:= oModel:GetModel("MdGridSDG")
		For nAuxSDG := 1 To oMdlSDG:Length()
			oMdlSDG:GoLine(nAuxSDG)
			cCodDes	:= oMdlSDG:GetValue("DG_CODDES")
			If ( ( oMdlSDG:IsUpdated() .And. !oMdlSDG:IsInserted() ).Or. oMdlSDG:IsDeleted() ) .And. lRet
				lExclui	:= .T. 
			EndIf 
		Next nAuxSDG

		cCodVei	:= oMdlGrid:GetValue("DTR_CODVEI")
		
		If lRet
			If ( oMdlGrid:IsUpdated() .And. !oMdlGrid:IsInserted() ) .Or. oMdlGrid:IsDeleted() .Or. lExclui
				lRet	:= TMA070DelTit( cFilOri , cViagem , cCodVei )	
			EndIf
		EndIf 

		If !lRet
			Exit
		EndIf
	Next nAux 

ElseIf nOperation == MODEL_OPERATION_DELETE
	lRet	:= TMA070DelTit( cFilOri , cViagem )
EndIf

oModel:Activate()

FWRestRows(aSaveLine)
RestArea(aArea)
Return lRet

/*{Protheus.doc} TF67AtuCar
Inclui, altera e exclui o carregamento dos documentos
@type Function
@author Valdemar Roberto Mognon
@since 10/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TF67AtuCar(oModel,nOperation)
Local lCont      := .T.
Local lTemDTA    := .T.
Local aAreas     := {DM6->(GetArea()),DTA->(GetArea()),GetArea()}
Local aDadosDM6  := {}
Local aDadosDTA  := {}
Local aLinhaDTA  := {}
Local nCntFor1   := 0
Local nCntFor2   := 0
Local nCntFor3   := 0
Local nPos       := 0
Local oMdlGrdDM3

//-- Variaveis do carregamento
Local aCamposDM6 := {}
Local aCamposDTA := {}
Local oModelCar  := Nil
Local oMdlFldDM6 := Nil
Local oMdlGrdDM7 := Nil
Local oMdlGrdDTA := Nil
Local oStruDM6   := Nil
Local oStruDTA   := Nil
Local nOperCar   := 0

Default oModel     := FWModelActive()
Default nOperation := 0

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

	DTA->(DbSetOrder(1))

	TMSAF90Set("lPosVia",.F.)
	
	//-- Carrega vetor da viagem
	Aadd(aDadosDM6,{"DM6_FILORI",FwFldGet("DTQ_FILORI")})
	Aadd(aDadosDM6,{"DM6_VIAGEM",FwFldGet("DTQ_VIAGEM")})

	//-- Carrega vetor dos Documentos
	oMdlGrdDM3 := oModel:GetModel("MdGridDM3")
	For nCntFor1 := 1 To oMdlGrdDM3:Length()
		oMdlGrdDM3:GoLine(nCntFor1)
		If !oMdlGrdDM3:IsDeleted() .And. !oMdlGrdDM3:IsEmpty()
			//-- Monta Linha para cada Veículo
			lTemDTA := .F.
			If FwFldGet("DM3_SERIE") == "COL"
				lTemDTA := .T.
			ElseIf nOperation == MODEL_OPERATION_UPDATE
				lTemDTA := (DTA->(DbSeek(xFilial("DTA") + FwFldGet("DM3_FILDOC") + FwFldGet("DM3_DOC") + FwFldGet("DM3_SERIE") + ;
														  FwFldGet("DTQ_FILORI") + FwFldGet("DTQ_VIAGEM"))))
			EndIf
			If !lTemDTA
				aLinhaDTA := {}
				Aadd(aLinhaDTA,{"DTA_FILDOC",FwFldGet("DM3_FILDOC")})
				Aadd(aLinhaDTA,{"DTA_DOC"   ,FwFldGet("DM3_DOC")})
				Aadd(aLinhaDTA,{"DTA_SERIE" ,FwFldGet("DM3_SERIE")})
				Aadd(aLinhaDTA,{"DTA_SERTMS",FwFldGet("DTQ_SERTMS")})
				Aadd(aLinhaDTA,{"DTA_TIPTRA",FwFldGet("DTQ_TIPTRA")})
				Aadd(aLinhaDTA,{"DTA_FILATU",cFilAnt})
				Aadd(aLinhaDTA,{"DTA_TIPCAR","2"})
				Aadd(aLinhaDTA,{"DTA_CODVEI",FwFldGet("DTR_CODVEI")})
				Aadd(aLinhaDTA,{"DTA_SEQDTW",StrZero(1,Len(DTA->DTA_SEQDTW))})
				Aadd(aLinhaDTA,{"DTA_VEICAR",})
				Aadd(aLinhaDTA,{"DTA_ORIGEM",FwFldGet("DM3_ORIGEM")})
				Aadd(aDadosDTA,Aclone(aLinhaDTA))
			EndIf
		EndIf
	Next nCntFor1

	If Len(aDadosDTA) > 0
		nOperCar:= 3

		//-- Se for alteração posiciona no carregamento
		If nOperation == 4
			DM6->(DbSetOrder(1))
			If DM6->(DbSeek(xFilial("DM6") + FwFldGet("DTQ_FILORI") + FwFldGet("DTQ_VIAGEM")))
				nOperCar:= 4  //nOperation de Alteração do Carregamento 
			EndIf
		EndIf
		
		If lCont
			//-- Carrega o Model de Carregamento
			oModelCar := FWLoadModel("TMSAF90")
			oModelCar:SetOperation(nOperCar)	//-- Inclusão ou Alteração
	
			//-- Ativa o Model de Carregamento
			oModelCar:Activate()
	
			//-- Carrega o Modelo da Viagem
			oMdlFldDM6 := oModelCar:GetModel("MdFieldDM6")
			oStruDM6   := oMdlFldDM6:GetStruct()
			aCamposDM6 := oStruDM6:GetFields()
	
			//-- Carrega o Modelo dos Veículos
			oMdlGrdDM7 := oModelCar:GetModel("MdGridDM7")
	
			//-- Carrega o Model dos Documentos
			oMdlGrdDTA := oModelCar:GetModel("MdGridDTA")
			oStruDTA   := oMdlGrdDTA:GetStruct()
			aCamposDTA := oStruDTA:GetFields()

			If nOperCar != 4
				//-- Preenche os Valores no Cabeçalho do Carregamento
				For nCntFor1 := 1 To Len(aDadosDM6)
					If AScan(aCamposDM6,{|x| AllTrim(x[3]) == AllTrim(aDadosDM6[nCntFor1,1])}) > 0
						If !oMdlFldDM6:SetValue(aDadosDM6[nCntFor1,1],aDadosDM6[nCntFor1,2])
							lCont := .F.
							Exit
						EndIf
					EndIf
				Next nCntFor1
			EndIf
				
			//-- Carrega os Documentos do Carregamento
			If lCont
				//-- Carrega os Documentos para Todos os Veículos da Viagem
				For nCntFor1 := 1 To oMdlGrdDM7:Length()
					oMdlGrdDM7:GoLine(nCntFor1)
	
					//-- Adiciona Nova Linha de Documento
					For nCntFor2 := 1 To Len(aDadosDTA)
						If !oMdlGrdDTA:IsEmpty()
							oMdlGrdDTA:GoLine(oMdlGrdDTA:Length())
							If !oMdlGrdDTA:AddLine()
								lCont := .F.
								Exit
							EndIf
						EndIf
				
						//-- Preenche os Valores nos Documentos do Carregamento
						If lCont
							//-- Define Veículo de Carregamento
							If (nPos := AScan(aDadosDTA[nCntFor2],{|x| AllTrim(x[1]) == "DTA_VEICAR"})) > 0
								aDadosDTA[nCntFor2,nPos,2] := Iif(Empty(FwFldGet("DM7_CODRB1")),"0","1")
							EndIf
	
							For nCntFor3 := 1 To Len(aDadosDTA[nCntFor2])
								If AScan(aCamposDTA,{|x| AllTrim(x[3]) == AllTrim(aDadosDTA[nCntFor2,nCntFor3,1])}) > 0
									If !oMdlGrdDTA:SetValue(aDadosDTA[nCntFor2,nCntFor3,1],aDadosDTA[nCntFor2,nCntFor3,2])
										lCont := .F.
										Exit
									EndIf
								EndIf
							Next nCntFor3
						EndIf
					Next nCntFor2
	
				Next nCntFor1
			EndIf
	
			//-- Grava os Dados
			If lCont
				If (lCont := oModelCar:VldData())
					oModelCar:CommitData()
				EndIf
			EndIf
	
			//-- Se Ocorreu Algum Erro Exibe Mensagem
			If !lCont
				//-- Monta mensagem de erro
				TF67MntErr(oModelCar)
			
				If !FWGetRunSchedule()
					MostraErro()
				EndIf
			EndIf
	
			//-- Desativa o Model do Carregamnto
			oModelCar:DeActivate()
	
			//-- Ativa o Model da Viagem
			oModel:Activate()
		EndIf
    Else
		If DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))
	    	//-- Fechamento automático
			//-- passar o nOpc da rotina que iremos chamar
			//-- No caso do Fechamento de Viagem o nOpc é 3
			//-- 3 Fechamento		5 Estorno de Fechamento
			TMSAF69( 2, "TMSAF90", 3, )
		EndIf
	EndIf

	TMSAF90Set("lPosVia",.T.)

EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lCont

/*{Protheus.doc} TF67GrvDM8
Grava campos da Integração TMS x GFE
@type Function
@author Katia
@since 13/08/2020
@version version
*/
Function TF67AtuDM8(cFilDoc,cDoc,cSerie,cFilOri,cViagem)
Local aAreas     := {DUD->(GetArea()),DM8->(GetArea()),GetArea()}

Local cQuery    := ""
Local cAliasDUD := ""

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default cFilOri := ""
Default cViagem := ""

cAliasDUD := GetNextAlias()
cQuery += "SELECT R_E_C_N_O_ REGISTRO "
cQuery += "  FROM " + RetSQLName("DUD") + " DUD "
cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "   AND DUD_FILDOC = '" + cFilDoc + "' "
cQuery += "   AND DUD_DOC    = '" + cDoc + "' "
cQuery += "   AND DUD_SERIE  = '" + cSerie + "' "
cQuery += "   AND DUD_VIAGEM = '" + cViagem + "' "
cQuery += "   AND DUD_STATUS <> '9' "
cQuery += "   AND D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDUD,.F.,.T.)

If (cAliasDUD)->(!Eof())
	DUD->(DbGoTo((cAliasDUD)->REGISTRO))

	DM8->(DbSetOrder(1))
	If DM8->(dBSeek(xFilial('DM8')+ DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE + DUD->DUD_FILORI + DUD->DUD_VIAGEM ))
		Reclock("DM8",.F.)
		DM8->DM8_UFDES  := DUD->DUD_UFDES
		DM8->DM8_CDMUND := DUD->DUD_CDMUND
		DM8->DM8_CEPDES := DUD->DUD_CEPDES
		DM8->(MsUnlock())
	EndIf
EndIf

(cAliasDUD)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})	  
Return

/*{Protheus.doc} TF67MntErr
Monta mensagem de erro
@type Function
@author Valdemar Roberto Mognon
@since 17/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TF67MntErr(oModel)
Local aMsgErr := {}

aMsgErr := oModel:GetErrorMessage()

AutoGrLog(STR0003 + " [" + AllToChar(aMsgErr[1]) + "]" )	//-- "Id do formulário de origem:"
AutoGrLog(STR0004 + " [" + AllToChar(aMsgErr[2]) + "]" )	//-- "Id do campo de origem:"
AutoGrLog(STR0005 + " [" + AllToChar(aMsgErr[3]) + "]" )	//-- "Id do formulário de erro:"
AutoGrLog(STR0006 + " [" + AllToChar(aMsgErr[4]) + "]" )	//-- "Id do campo de erro:"
AutoGrLog(STR0007 + " [" + AllToChar(aMsgErr[5]) + "]" )	//-- "Id do erro:"
AutoGrLog(STR0008 + " [" + AllToChar(aMsgErr[6]) + "]" )	//-- "Mensagem do erro:"
AutoGrLog(STR0009 + " [" + AllToChar(aMsgErr[7]) + "]" )	//-- "Mensagem da solução:"
AutoGrLog(STR0010 + " [" + AllToChar(aMsgErr[8]) + "]" )	//-- "Valor atribuído:"
AutoGrLog(STR0011 + " [" + AllToChar(aMsgErr[9]) + "]" )	//-- "Valor anterior:"

Return

//-----------------------------------------------
/* {Protheus.doc} TF67GrvDTP
Retira a Viagem do Lote
@author Katia
@since 08/09/2020
@version P12 R12.1.29
@return Nil
*///---------------------------------------------    
Static Function TF67GrvDTP(cFilOri,cViagem)  

Default cFilOri:= ""
Default cViagem:= ""

If !Empty(cViagem)
	DTP->( DbSetOrder( 3 ) )
	While DTP->( MsSeek( xFilial('DTP') + cFilOri + cViagem ) )
		RecLock('DTP',.F.,.T.)
		DTP->DTP_VIAGEM := ""
		MsUnLock()
	EndDo
EndIf

Return Nil
/*{Protheus.doc} TF67GrvMem
Grava Memo
@type Function
@author Caio Murakami
@since 09/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF67GrvMem(oModel , nOpc)
Local cMemo		:= ""
Local cCodObs	:= ""
Local oModelDTQ	:= Nil 
Local nTamObs	:= TamSx3("DTQ_OBS")[1]

Default oModel	:= FWModelActive()
Default nOpc	:= 3 

oModelDTQ	:= oModel:GetModel("MdFieldDTQ")
cMemo 		:= oModelDTQ:GetValue("DTQ_OBS")

If nOpc == 3		
	MSMM(,nTamObs,,cMemo,1,,,'DTQ',"DTQ_CODOBS")
ElseIf nOpc == 4 
	cCodObs	:= oModelDTQ:GetValue("DTQ_CODOBS")
	MSMM(cCodObs ,nTamObs,,cMemo,1,,,'DTQ',"DTQ_CODOBS" )
ElseIf nOpc == 5 
	cCodObs	:= oModelDTQ:GetValue("DTQ_CODOBS")
	MSMM(cCodObs ,nTamObs,,cMemo,2,,,'DTQ',"DTQ_CODOBS" )
EndIf

Return

/*{Protheus.doc} TF67IntGFE
Atualiza a integração com GFE
@type Function
@author Katia
@since 17/09/2020
@version 12.1.30
Função extraida do TMSA141.PRW (TMSA141GRV)
*/
Static Function TF67IntGFE(lIncDoc,cFilDoc,cDoc,cSerie,oModel)
Local aSaveLine:= FWSaveRows() 
Local lRet     := .T.
Local aAreas   := {DUD->(GetArea()),DTQ->(GetArea()),GetArea()}
Local oModelDTQ:= Nil
Local cFilOri  := ""
Local cViagem  := ""

Default lIncDoc:= .T.  //Inclusao de Documento na Alteração da Viagem
Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""
Default oModel := FwModelActive()

oModelDTQ := oModel:GetModel ("MdFieldDTQ") 
cFilOri:= oModelDTQ:GetValue('DTQ_FILORI')
cViagem:= oModelDTQ:GetValue('DTQ_VIAGEM')

DTQ->(DbSetOrder(2))
If DTQ->(DbSeek(xFilial("DTQ") + cFilOri + cViagem))
	If  DTQ->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE)) .And. !Empty(DTQ->DTQ_CHVEXT)
		If !lIncDoc  
			lRet:= Tms3GfeInt(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .F., .T., cFilDoc , cDoc , cSerie )
		Else 
			//---Alteração da viagem executa a integração com o GFE caso a viagem ja tenha sido integrada (Fechamento, Chegada ou Saida)
			lRet:= Tms3GfeInt(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .F., .F.)
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})	  
FWRestRows( aSaveLine )
Return lRet

/*{Protheus.doc} TF67NewDoc
Monta Vetor de Novos Documentos na Alteração da Viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 19/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF67NewDoc(oModel)
Local aRet       := {}
Local aAreas     := {DUL->(GetArea()),DT6->(GetArea()),DM3->(GetArea()),GetArea()}
Local oMdlFldDTQ := oModel:GetModel("MdFieldDTQ")
Local oMdlGrdDM3 := oModel:GetModel("MdGridDM3")
Local nCntFor1   := 0
Local cFilOri    := oMdlFldDTQ:GetValue("DTQ_FILORI")
Local cViagem    := oMdlFldDTQ:GetValue("DTQ_VIAGEM")
Local cCliRem    := ""
Local cLojRem    := ""
Local cCliDes    := ""
Local cLojDes    := ""

DM3->(DbSetOrder(1))
DT6->(dbSetOrder(1))
DUL->(DbSetOrder(2))

If DTQ->DTQ_STATUS == "2"	//-- Viagem em Trânsito
	For nCntFor1 := 1 To oMdlGrdDM3:Length()
		oMdlGrdDM3:GoLine(nCntFor1)
		//-- Pesquisa se o documento do grid já estava na viagem
		If Ascan(aRet,{|x| x[1] + x[2] + x[3] == FwFldGet("DM3_FILDOC") + FwFldGet("DM3_DOC") + FwFldGet("DM3_SERIE")}) == 0
			If !DM3->(MsSeek(xFilial("DM3") + FwFldGet("DM3_FILDOC") + FwFldGet("DM3_DOC") + FwFldGet("DM3_SERIE") + cFilOri + cViagem ))
			    If DT6->(MsSeek(xFilial("DT6") + FwFldGet("DM3_FILDOC") + FwFldGet("DM3_DOC") + FwFldGet("DM3_SERIE")))
					//-- Busca remetente
			        If !Empty(DT6->DT6_CLIEXP) .AND. !Empty(DT6->DT6_LOJEXP)
			            cCliRem	:= DT6->DT6_CLIEXP
			            cLojRem	:= DT6->DT6_LOJEXP
			        Else
			            cCliRem	:= DT6->DT6_CLIREM
			            cLojRem	:= DT6->DT6_LOJREM
			        EndIf
					//-- Busca destinatário	        
			        cCliDes	:= DT6->DT6_CLIDES	
			        cLojDes	:= DT6->DT6_LOJDES
			    	If !Empty(DT6->DT6_SQEDES)
			            If DUL->(MsSeek(xFilial("DUL") + cCliDes + cLojDes + DT6->DT6_SQEDES)) .And. !Empty(DUL->DUL_CODRED)
							cCliDes := DUL->DUL_CODRED
							cLojDes := DUL->DUL_LOJRED
			            EndIf
			        EndIf
	                //-- Armazena o novo documento
					Aadd(aRet,{cCliRem,cLojRem,cCliDes,cLojDes,FwFldGet("DM3_FILDOC"),FwFldGet("DM3_DOC"),FwFldGet("DM3_SERIE"),DT6->DT6_CLIEXP,DT6->DT6_LOJEXP})
    			EndIf
			EndIf
		EndIf
	Next nCntFor1
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return Aclone(aRet)


/*{Protheus.doc} TF67AtuDFV
Atualiza Status do Documento do Redespacho 
@type Static Function
@author Katia
@since 24/09/2020
@version 12.1.30
@param cFilDoc, cDoc, cSerie
@return Nil
*/

Function TF67AtuDFV( cFilDoc, cDoc, cSerie) 	
Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""
				
DFV->( DbSetOrder( 2 ) )
If DFV->( MsSeek( xFilial('DFV') + cFilDoc + cDoc + cSerie ) )
	RecLock('DFV',.F.)
	DFV->DFV_STATUS := StrZero( 1, Len( DFV->DFV_STATUS ) )
	MsUnLock()
EndIf

Return

/*{Protheus.doc} TF67AtuDJA
Atualiza tabela de liberação da RRE
@type Static Function
@author Valdemar Roberto Mognon
@since 06/10/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF67AtuDJA(oModel,nOperation)
Local aAreas    := {DA3->(GetArea()),DA4->(GetArea()),DJA->(GetArea()),GetArea()}
Local aDTRVia   := TMFGetStat("aVeiVia")
Local aDUPVia   := TMFGetStat("aMotVia")
Local cChave    := ""
Local nCntFor1  := 0
Local oModelDTQ := Nil
Local oModelDTR := Nil

Default oModel     := Nil
Default nOperation := 0

oModelDTQ := oModel:GetModel("MdGridDTQ")
oModelDTR := oModel:GetModel("MdGridDTR")
oModelDUP := oModel:GetModel("MdGridDUP")

If nOperation == 3 .Or. nOperation == 4	//-- Inclusão ou Alteração
	DJA->(DbSetOrder(1))
	DA3->(DbSetOrder(1))
	DA4->(DbSetOrder(1))
	
	//-- Exclui DJA na alteração da linha
	For nCntFor1 := 1 To Len(aDTRVia)
		If !oModelDTR:SeekLine({{"DTR_CODVEI",aDTRVia[nCntFor1]}})
			cChave := Padr(xFilial("DA3") + aDTRVia[nCntFor1],Len(DJA->DJA_CHAVE))
			If DJA->(DbSeek(xFilial("DJA") + FwFldGet("DTQ_FILORI") + FwFldGet("DTQ_VIAGEM") + "DA3" + cChave))
				RecLock("DJA",.F.)
				DJA->(DbDelete())
				DJA->(MsUnlock())
				If DA3->(DbSeek(cChave))
					RecLock("DA3",.F.)
					DA3->DA3_LIBSEG := Space(Len(DA3->DA3_LIBSEG))
					DA3->DA3_DTIVSG := CToD("")
					DA3->DA3_DTFVSG := CToD("")
					DA3->(MsUnlock())
				EndIf
			EndIf
		EndIf
	Next nCntFor1

	//-- Liberação do Veículo
	For nCntFor1 := 1 To oModelDTR:Length()
		oModelDTR:GoLine(nCntFor1)
		cChave := Padr(xFilial("DA3") + FwFldGet("DTR_CODVEI"),Len(DJA->DJA_CHAVE))

		If nOperation == 4 .And. oModelDTR:IsDeleted()
			If DJA->(DbSeek(xFilial("DJA") + FwFldGet("DTQ_FILORI") + FwFldGet("DTQ_VIAGEM") + "DA3" + cChave))
				RecLock("DJA",.F.)
				DJA->(DbDelete())
				DJA->(MsUnlock())
				If DA3->(DbSeek(cChave))
					RecLock("DA3",.F.)
					DA3->DA3_LIBSEG := Space(Len(DA3->DA3_LIBSEG))
					DA3->DA3_DTIVSG := CToD("")
					DA3->DA3_DTFVSG := CToD("")
					DA3->(MsUnlock())
				EndIf
			EndIf
		ElseIf !oModelDTR:IsDeleted() .And. !Empty(FwFldGet("DTR_LIBRRE"))
			If DJA->(DbSeek(xFilial("DJA") + FwFldGet("DTQ_FILORI") + FwFldGet("DTQ_VIAGEM") + "DA3" + cChave))
				RecLock("DJA",.F.)
			Else
				RecLock("DJA",.T.)
				DJA->DJA_FILIAL := xFilial("DJA")
				DJA->DJA_FILORI := FwFldGet("DTQ_FILORI")
				DJA->DJA_VIAGEM := FwFldGet("DTQ_VIAGEM")
				DJA->DJA_ITEM   := TF67PrxDJA(FwFldGet("DTQ_FILORI"),FwFldGet("DTQ_VIAGEM"),"DA3")
				DJA->DJA_ALIAS  := "DA3"
				DJA->DJA_CHAVE  := cChave
			EndIf
			DJA->DJA_LIBSEG := FwFldGet("DTR_LIBRRE")
			DJA->DJA_DTIVSG := FwFldGet("DTR_INIRRE")
			DJA->DJA_DTFVSG := FwFldGet("DTR_FIMRRE")
			DJA->(MsUnlock())
			If DA3->(DbSeek(cChave))
				RecLock("DA3",.F.)
				DA3->DA3_LIBSEG := DJA->DJA_LIBSEG
				DA3->DA3_DTIVSG := DJA->DJA_DTIVSG
				DA3->DA3_DTFVSG := DJA->DJA_DTFVSG
				DA3->(MsUnlock())
			EndIf
		EndIf
	Next nCntFor1

	//-- Exclui DJA na alteração da linha
	For nCntFor1 := 1 To Len(aDUPVia)
		If !oModelDUP:SeekLine({{"DUP_CODMOT",aDUPVia[nCntFor1]}})
			cChave := Padr(xFilial("DA4") + aDUPVia[nCntFor1],Len(DJA->DJA_CHAVE))
			If DJA->(DbSeek(xFilial("DJA") + FwFldGet("DTQ_FILORI") + FwFldGet("DTQ_VIAGEM") + "DA4" + cChave))
				RecLock("DJA",.F.)
				DJA->(DbDelete())
				DJA->(MsUnlock())
				If DA4->(DbSeek(cChave))
					RecLock("DA4",.F.)
					DA4->DA4_LIBSEG := Space(Len(DA4->DA4_LIBSEG))
					DA4->DA4_DTIVSG := CToD("")
					DA4->DA4_DTFVSG := CToD("")
					DA4->(MsUnlock())
				EndIf
			EndIf
		EndIf
	Next nCntFor1

	//-- Liberação do Motorista
	For nCntFor1 := 1 To oModelDUP:Length()
		oModelDUP:GoLine(nCntFor1)
		cChave := Padr(xFilial("DA4") + FwFldGet("DUP_CODMOT"),Len(DJA->DJA_CHAVE))

		If nOperation == 4 .And. oModelDUP:IsDeleted()
			If DJA->(DbSeek(xFilial("DJA") + FwFldGet("DTQ_FILORI") + FwFldGet("DTQ_VIAGEM") + "DA4" + cChave))
				RecLock("DJA",.F.)
				DJA->(DbDelete())
				DJA->(MsUnlock())
				If DA4->(DbSeek(cChave))
					RecLock("DA4",.F.)
					DA4->DA4_LIBSEG := Space(Len(DA4->DA4_LIBSEG))
					DA4->DA4_DTIVSG := CToD("")
					DA4->DA4_DTFVSG := CToD("")
					DA4->(MsUnlock())
				EndIf
			EndIf
		ElseIf !oModelDUP:IsDeleted() .And. !Empty(FwFldGet("DUP_LIBRRE"))
			If DJA->(DbSeek(xFilial("DJA") + FwFldGet("DTQ_FILORI") + FwFldGet("DTQ_VIAGEM") + "DA4" + cChave))
				RecLock("DJA",.F.)
			Else
				RecLock("DJA",.T.)
				DJA->DJA_FILIAL := xFilial("DJA")
				DJA->DJA_FILORI := FwFldGet("DTQ_FILORI")
				DJA->DJA_VIAGEM := FwFldGet("DTQ_VIAGEM")
				DJA->DJA_ITEM   := TF67PrxDJA(FwFldGet("DTQ_FILORI"),FwFldGet("DTQ_VIAGEM"),"DA4")
				DJA->DJA_ALIAS  := "DA4"
				DJA->DJA_CHAVE  := cCHave
			EndIf
			DJA->DJA_LIBSEG := FwFldGet("DUP_LIBRRE")
			DJA->DJA_DTIVSG := FwFldGet("DUP_INIRRE")
			DJA->DJA_DTFVSG := FwFldGet("DUP_FIMRRE")
			DJA->(MsUnlock())
			If DA4->(DbSeek(cChave))
				RecLock("DA4",.F.)
				DA4->DA4_LIBSEG := DJA->DJA_LIBSEG
				DA4->DA4_DTIVSG := DJA->DJA_DTIVSG
				DA4->DA4_DTFVSG := DJA->DJA_DTFVSG
				DA4->(MsUnlock())
			EndIf
		EndIf
	Next nCntFor1
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aDTRVia)
FwFreeArray(aDUPVia)

Return

/*{Protheus.doc} TF67PrxDJA
Localiza proxima sequencia da DJA
@type Static Function
@author Valdemar Roberto Mognon
@since 07/10/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF67PrxDJA(cFilOri,cViagem,cAlias)
Local cRet      := ""
Local cQuery    := ""
Local cAliasDJA := ""
Local aAreas    := {GetArea()}

Default cFilOri := ""
Default cViagem := ""
Default cAlias  := ""

cAliasDJA := GetNextAlias()
cQuery += "SELECT MAX(DJA_ITEM) ULTITEM"
cQuery += "  FROM " + RetSqlName("DJA") + " DJA "
cQuery += " WHERE DJA_FILIAL = '" + xFilial("DJA") +  "' "
cQuery += "   AND DJA_FILORI = '" + cFilOri + "' "
cQuery += "   AND DJA_VIAGEM = '" + cViagem + "' "
cQuery += "   AND DJA_ALIAS  = '" + cAlias + "' "
cQuery += "   AND DJA.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDJA,.F.,.T.)

If (cAliasDJA)->(EoF()) .Or. Empty((cAliasDJA)->ULTITEM)
	cRet := Soma1((cAliasDJA)->ULTITEM,Len(DJA->DJA_ITEM))
Else
	cRet := StrZero(1,Len(DJA->DJA_ITEM))
EndIf

(cAliasDJA)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})	  

Return cRet


/*{Protheus.doc} TmsAjuMod3
Atualiza os dados da viagem modelo 3 com base na viagem modelo 2
(** Nao será via execauto TMSAF60 ** )
@type Function
@author Katia
@since 16/12/2020
@version version
@param cFilOri, cViagem, nOpcx
@return lRet
*/
Function TmsAjuMod3(cFilOri,cViagem,nOpcVge,lRotVge)
Local aAreaDTQ:= DTQ->(GetArea())
Local aAreaDTR:= DTR->(GetArea())
Local aArea   := GetArea()

Default cFilOri:= ""
Default cViagem:= ""
Default nOpcVge:= 0
Default lRotVge:= .T.   //Rotina da Viagem atualiza todos as Tabelas,
                        //Complemento da Viagem somente DM4/DM5

If !Empty(cFilOri) .And. !Empty(cViagem)
	If nOpcVge == 5  .Or. nOpcVge == 4  //Excluir ou Alterar
		If lRotVge
			TmsDelDM3(cFilOri,cViagem)
			TmsDelDM8(cFilOri,cViagem)
		EndIf
		TmsDelDM4(cFilOri,cViagem)
		TmsDelDM5(cFilOri,cViagem)
		
	EndIf

	If nOpcVge == 3 .Or. nOpcVge == 4	 //Incluir - Alterar
		DTQ->(DbSetOrder(2))
		If DTQ->(DbSeek(xFilial("DTQ") + cFilOri + cViagem))
			If lRotVge
				TmsIncDM3()
			EndIf

			DTR->(dbSetOrder(1))	
			If 	DTR->(DbSeek(FwxFilial('DTR')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM)) 
				TmsIncDM4()	
				
				If !Empty(DTR->DTR_CODOPE)			
					TmsIncDM5()
				EndIf
			EndIf
		EndIf
	EndIf

EndIf

RestArea(aArea)
RestArea(aAreaDTR)
RestArea(aAreaDTQ)
Return

/*{Protheus.doc} TmsDelDM3
Exclui os documentos da viagem Modelo 3 (DM3)
@type Function
@author Katia
@since 16/12/2020
@version version
@param cFilOri, cViagem
*/
Static Function TmsDelDM3(cFilOri,cViagem)
Local cAliasQry:= GetNextAlias()
Local cQuery   := ""

cQuery := " SELECT R_E_C_N_O_ DM3_RECNO "
cQuery += "   FROM " + RetSqlName("DM3") + " DM3 "
cQuery += "  WHERE DM3.DM3_FILIAL = '" + xFilial('DM3') + "' "
cQuery += "    AND DM3.DM3_FILORI = '" + cFilOri + "' "
cQuery += "    AND DM3.DM3_VIAGEM = '" + cViagem + "' "
cQuery += "    AND DM3.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
While (cAliasQry)->(!Eof())
	DM3->(DbGoTo((cAliasQry)->DM3_RECNO))
	RecLock('DM3',.F.)
	DM3->(DbDelete())
	MsUnLock()
		
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

Return 

/*{Protheus.doc} TmsDelDM4
Exclui os Recursos da viagem Modelo 3 (DM4)
@type Function
@author Katia
@since 16/12/2020
@version version
@param cFilOri, cViagem
*/
Static Function TmsDelDM4(cFilOri,cViagem)

DM4->( DbSetOrder( 1 ) )
If	DM4->( DbSeek( xFilial('DM4') + cFilOri + cViagem ) )
	RecLock('DM4',.F.,.T.)
	DM4->(DbDelete())
	MsUnLock()
EndIf

Return 

/*{Protheus.doc} TmsDelDM5
Exclui a Operadora Frota da viagem Modelo 3 (DM5)
@type Function
@author Katia
@since 16/12/2020
@version version
@param cFilOri, cViagem
*/
Static Function TmsDelDM5(cFilOri,cViagem)

DM5->( DbSetOrder( 1 ) )
If	DM5->( DbSeek( xFilial('DM5') + cFilOri + cViagem ) )
	RecLock('DM5',.F.,.T.)
	DM5->(DbDelete())
	MsUnLock()
EndIf

Return 

/*{Protheus.doc} TmsDelDM8
Exclui a Operadora Frota da viagem Modelo 3 (DM8)
@type Function
@author Katia
@since 16/12/2020
@version version
@param cFilOri, cViagem
*/
Static Function TmsDelDM8(cFilOri,cViagem)
Local cAliasQry:= GetNextAlias()
Local cQuery   := ""

cQuery := " SELECT R_E_C_N_O_ DM8_RECNO "
cQuery += "   FROM " + RetSqlName("DM8") + " DM8 "
cQuery += "  WHERE DM8.DM8_FILIAL = '" + xFilial('DM8') + "' "
cQuery += "    AND DM8.DM8_FILORI = '" + cFilOri + "' "
cQuery += "    AND DM8.DM8_VIAGEM = '" + cViagem + "' "
cQuery += "    AND DM8.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
While (cAliasQry)->(!Eof())
	DM8->(DbGoTo((cAliasQry)->DM8_RECNO))
	RecLock('DM8',.F.)
	DM8->(DbDelete())
	MsUnLock()
		
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

Return 


/*{Protheus.doc} TmsIncDM3
Inclui os Documentos da viagem Modelo 3 (DM3) a partir da viagem Modelo 2
@type Function
@author Katia
@since 16/12/2020
@version version
@param cFilOri, cViagem
*/
Static Function TmsIncDM3()
Local cAliasQry  := GetNextAlias()
Local cQuery     := ""
Local lGerDM8    := .F.
Local cSequen    := StrZero(0,Len(DUD->DUD_SEQUEN))
Local nSeqDUD    := 0

Local lDM3ORIGEM := DM3->(ColumnPos("DM3_ORIGEM")) > 0

//--- Busca a Ultima Sequencia do DUD da Viagem
nSeqDUD:= TmsSeqDUD(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
If nSeqDUD > 0
	cSequen:= StrZero(nSeqDUD,Len(DUD->DUD_SEQUEN))
EndIf

//--- Integração com GFE
If (lTMS3GFE .Or. lTmsRdpU) 
	lGerDM8:= DTQ->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE)) 
EndIf

cQuery := " SELECT R_E_C_N_O_ DUD_RECNO "
cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
cQuery += "  WHERE DUD.DUD_FILIAL = '" + xFilial('DUD') + "' "
cQuery += "    AND DUD.DUD_FILORI = '" + DTQ->DTQ_FILORI + "' "
cQuery += "    AND DUD.DUD_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
cQuery += "    AND DUD.D_E_L_E_T_ = ' ' "
cQuery += "  ORDER BY DUD_FILORI, DUD_VIAGEM, DUD_SEQUEN, DUD_FILDOC, DUD_DOC, DUD_SERIE "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
While (cAliasQry)->(!Eof())
	DUD->(DbGoTo((cAliasQry)->DUD_RECNO))

	DM3->( DbSetOrder( 1 ) )	
	If DM3->(DbSeek( xFilial('DM3') + DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM) ))
		RecLock('DM3',.F.)		
	Else
		RecLock('DM3',.T.)
		DM3->DM3_FILIAL := xFilial('DM3')
		DM3->DM3_FILORI := DUD->DUD_FILORI 
		DM3->DM3_VIAGEM := DUD->DUD_VIAGEM
		DM3->DM3_FILDOC := DUD->DUD_FILDOC 
		DM3->DM3_DOC    := DUD->DUD_DOC 
		DM3->DM3_SERIE  := DUD->DUD_SERIE 
		If lDM3ORIGEM
			DM3->DM3_ORIGEM := CriaVar("DM3_ORIGEM")
		EndIf
	EndIf

	//--- Tratar as Sequencias da DUD em Branco (ex.Viagem de Transferencia)
	If Empty(DUD->DUD_SEQUEN)
		cSequen := Soma1(cSequen,Len(DUD->DUD_SEQUEN))
	EndIf	
	DM3->DM3_SEQUEN := Iif(Empty(DUD->DUD_SEQUEN),cSequen,DUD->DUD_SEQUEN)

	DM3->(MsUnlock())

	//--- Integração com GFE
	If lGerDM8
		TmsIncDM8()
	EndIf
		
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

Return 

/*{Protheus.doc} TmsIncDM8
Grava Documentos referente a Integração TMS x GFE (DM8)
@type Function
@author Katia
@since 16/12/2020
@version version
@param cFilOri, cViagem
*/
Static Function TmsIncDM8()

DM8->(DbSetOrder(1))
If DM8->(DbSeek(xFilial('DM8')+ DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM )))
	RecLock('DM8',.F.)	
Else
	RecLock('DM8',.T.)	
	DM8->DM8_FILIAL := xFilial("DM8")
	DM8->DM8_FILORI := DUD->DUD_FILORI
	DM8->DM8_VIAGEM := DUD->DUD_VIAGEM
	DM8->DM8_FILDOC := DUD->DUD_FILDOC 
	DM8->DM8_DOC    := DUD->DUD_DOC
	DM8->DM8_SERIE  := DUD->DUD_SERIE
EndIf

DM8->DM8_UFORI  := DUD->DUD_UFORI
DM8->DM8_CDMUNO := DUD->DUD_CDMUNO
DM8->DM8_CEPORI := DUD->DUD_CEPORI
DM8->DM8_UFDES  := DUD->DUD_UFDES
DM8->DM8_CDMUND := DUD->DUD_CDMUND
DM8->DM8_CEPDES := DUD->DUD_CEPDES
DM8->DM8_TIPVEI := DUD->DUD_TIPVEI
DM8->DM8_CDTPOP := DUD->DUD_CDTPOP
DM8->DM8_CDCLFR := DUD->DUD_CDCLFR
DM8->DM8_CHVEXT := DUD->DUD_CHVEXT
DM8->(MsUnlock())

Return 


/*{Protheus.doc} TmsIncDM4
Inclui os Recursos da viagem Modelo 3 (DM3) a partir da viagem Modelo 2
@type Function
@author Katia
@since 16/12/2020
@version version
@param cFilOri, cViagem
*/
Static Function TmsIncDM4()
	
	DM4->(DbSetOrder(1)) //Validação devido a rotina do Express
	If DM4->(DbSeek(xFilial("DM4") + DTR->DTR_FILORI + DTR->DTR_VIAGEM))
		RecLock('DM4',.F.)	
	Else
		RecLock('DM4',.T.)	
		DM4->DM4_FILIAL := xFilial("DM4")
		DM4->DM4_FILORI := DTR->DTR_FILORI
		DM4->DM4_VIAGEM := DTR->DTR_VIAGEM
	EndIf
	DM4->DM4_FILVGE := DTR->DTR_FILVGE
	DM4->DM4_NUMVGE := DTR->DTR_NUMVGE
	DM4->DM4_DATINI := DTR->DTR_DATINI
	DM4->DM4_HORINI := DTR->DTR_HORINI
	DM4->DM4_DATFIM := DTR->DTR_DATFIM
	DM4->DM4_HORFIM := DTR->DTR_HORFIM
	DM4->(MsUnlock())

Return

/*{Protheus.doc} TmsIncDM5
Grava os Operadora de Frotas da viagem Modelo 3 (DM3) a partir da viagem Modelo 2
@type Function
@author Katia
@since 16/12/2020
@version version
@param cFilOri, cViagem
*/
Static Function TmsIncDM5()

If !Empty(DTR->DTR_CODOPE)
	DM5->(DbSetOrder(1))
	If DM5->(DbSeek(xFilial("DM5") + DTR->DTR_FILORI + DTR->DTR_VIAGEM))
		RecLock('DM5',.F.)	
	Else
		RecLock('DM5',.T.)	
		DM5->DM5_FILIAL := xFilial("DM5")
		DM5->DM5_FILORI := DTR->DTR_FILORI
		DM5->DM5_VIAGEM := DTR->DTR_VIAGEM
	EndIf
	DM5->DM5_CODOPE := DTR->DTR_CODOPE
	DM5->DM5_TPSPDG := DTR->DTR_TPSPDG
	DM5->DM5_QTDSAQ := DTR->DTR_QTDSAQ
	DM5->DM5_QTDTRA := DTR->DTR_QTDTRA
	DM5->DM5_PRCTRA := DTR->DTR_PRCTRA
	DM5->(MsUnlock())
EndIf

Return

/*{Protheus.doc} TF67QryDUD
Busca os documentos da viagem que devem ser atualizados (DUD e DM3)
@type Static Function
@author Valdemar Roberto Mognon
@since 02/03/2021
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF67QryDUD(cFilOri,cViagem,cJoin,cWhere)
Local cQuery    := ""
Local cAliasQry := ""

Default cFilOri := ""
Default cViagem := ""
Default cJoin   := ""
Default cWhere  := ""

cAliasQry := GetNextAlias()
cQuery := "SELECT DUD.R_E_C_N_O_ REGISTRO, DM3.DM3_SEQUEN "
cQuery += "  FROM " + RetSQLName("DM3") + " DM3 "

cQuery += "  JOIN " + RetSQLName("DUD") + " DUD "
cQuery += "    ON DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "   AND DUD.DUD_FILDOC = DM3_FILDOC "
cQuery += "   AND DUD.DUD_DOC    = DM3_DOC "
cQuery += "   AND DUD.DUD_SERIE  = DM3_SERIE "
cQuery += cJoin
cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "

cQuery += " WHERE DM3.DM3_FILIAL = '" + xFilial("DM3") + "' "
cQuery += "   AND DM3.DM3_FILORI = '" + cFilOri + "' "
cQuery += "   AND DM3.DM3_VIAGEM = '" + cViagem + "' "
cQuery += cWhere
cQuery += "   AND DM3.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

Return cAliasQry

//-----------------------------------------------------------
/* {Protheus.doc} TF67ProCa
Realiza o cancelamento da Programação de Carregamento se 
existir para essa viagem.

@author		Rodrigo.Pirolo
@since		26/02/2021
@version	1.0
*/
//-----------------------------------------------------------

Static Function TF67ProCa( cFilOri, cViagem )

Local aArea			:= GetArea()
Local aAreaDTQ		:= DTQ->( GetArea() )

Default cFilOri		:= ""
Default cViagem		:= ""

DbSelectArea("DF8")
DF8->( DbSetOrder( 2 ) ) //-- DF8_FILIAL+DF8_FILORI+DF8_VIAGEM

If DF8->( DbSeek( xFilial("DF8") + cFilOri + cViagem ) )
	
	RecLock( "DF8", .F. )
		DF8->DF8_STATUS:= '9'   //Cancelada
	DF8->( MsUnLock() )

EndIf

RestArea(aArea)
RestArea(aAreaDTQ)

Return

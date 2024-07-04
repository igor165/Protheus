#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "TECA520.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA520()
Agendamento dos Atendentes - ABB
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA520(xAutoItens,nOpcAuto)

Default xAutoItens	:= {}
Default nOpcAuto		:= MODEL_OPERATION_VIEW

If !Empty(xAutoItens)
	FWMVCRotAuto(ModelDef(),"ABB",nOpcAuto,{{"ABBDETAIL",xAutoItens}})
Else
	DEFINE FWMBROWSE oMBrowse ALIAS "ABB" DESCRIPTION STR0001 //"Agendamentos"
	ACTIVATE FWMBROWSE oMBrowse
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do Model 
@return ExpO:oModel
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruCab	:= FWFormStruct(1,'ABB',{|cCampo| AllTrim(cCampo)+"|" $ "ABB_CODTEC|ABB_NOMTEC|"})
Local oStruGrid	:= FWFormStruct(1,'ABB')
Local aAux			:= {}						// Auxiliar para criar a trigger

//Ajustes do Dicionario
aAux := FwStruTrigger('ABB_CODTEC',;
                      'ABB_NOMTEC',;
                      'AA1->AA1_NOMTEC',;
                      .T.,;
                      'AA1',;
                      1,;
                      'xFilial("AA1")+FwFldGet("ABB_CODTEC")')
oStruCab:AddTrigger(aAux[1],;	// [01] identificador (ID) do campo de origem
                    aAux[2],;	// [02] identificador (ID) do campo de destino
                    aAux[3],;	// [03] Bloco de código de validação da execução do gatilho
                    aAux[4])	// [04] Bloco de código de execução do gatilho

//Ajustes do Dicionario
aAux := FwStruTrigger('ABB_ENTIDA',;
                      'ABB_CHAVE',;
                      'Space(TamSX3("ABB_CHAVE")[1])',;
                      .F.,;
                      ,;
                      ,;
                      )
oStruGrid:AddTrigger(aAux[1],;	// [01] identificador (ID) do campo de origem
                     aAux[2],;	// [02] identificador (ID) do campo de destino
                     aAux[3],;	// [03] Bloco de código de validação da execução do gatilho
                     aAux[4])	// [04] Bloco de código de execução do gatilho 	 		

oStruCab:SetProperty("ABB_NOMTEC",MODEL_FIELD_INIT,{|| If(!INCLUI,(POSICIONE("AA1", 1, XFilial("AA1")+ABB->ABB_CODTEC, "AA1_NOMTEC")),AA1->AA1_NOMTEC)})
oStruCab:SetProperty("ABB_CODTEC",MODEL_FIELD_INIT,{|| AA1->AA1_CODTEC })

oStruGrid:RemoveField('ABB_CODTEC')
oStruGrid:RemoveField('ABB_NOMTEC')

oStruGrid:SetProperty("ABB_DTINI", MODEL_FIELD_INIT,   {|| If(Type("dData") != "U",dData,dDatabase)})
oStruGrid:SetProperty("ABB_DTFIM", MODEL_FIELD_INIT,   {|| If(Type("dData") != "U",dData,dDatabase)})
oStruGrid:SetProperty("ABB_NUMOS", MODEL_FIELD_OBRIGAT,.F.)
oStruGrid:SetProperty("ABB_ENTIDA",MODEL_FIELD_OBRIGAT,.F.)
oStruGrid:SetProperty("ABB_CHAVE", MODEL_FIELD_OBRIGAT,.F.)
oStruGrid:SetProperty("ABB_ENTIDA",MODEL_FIELD_WHEN,{|| IIf(oModel:GetOperation()==4 .AND. ("CN9" $ M->ABB_IDCFAL), .F., .T.) })
oStruGrid:SetProperty("ABB_CHAVE", MODEL_FIELD_WHEN,{|| IIf(oModel:GetOperation()==4 .AND. ("CN9" $ M->ABB_IDCFAL), .F., .T.) })
 
oModel := MPFormModel():New('TECA520',/*bPre*/,{|oMdl| Ta520PosVld(oMdl)}/*bPosValidacao*/,{|oMdl| Ta520Comm(oMdl)},/*bCancel*/)
oModel:AddFields('ABBCAB',/*cOwner*/,oStruCab,{|oMdl,cAcao,cCampo,xValue| Ta520PreVl(oMdl,cAcao,cCampo,xValue)},/*pos*/,/* load */)
oModel:AddGrid('ABBGRID','ABBCAB',oStruGrid,/*bLinePre*/,{|oMdl| Ta520LPos(oMdl)},/*bPreVal*/,/*bPosVal*/,{|oMdl,lCopy| TA520Load(oMdl,lCopy)})
oModel:GetModel("ABBGRID"):SetOptional(.T.)
oModel:GetModel("ABBGRID"):SetUseOldGrid()

oModel:SetVldActivate( { |oModel| At510FPGrl(oModel) } )

//ABB_FILIAL+ABB_CODTEC+DTOS(ABB_DTINI)+ABB_HRINI+DTOS(ABB_DTFIM)+ABB_HRFIM 
oModel:SetRelation("ABBGRID",{{"ABB_FILIAL",'xFilial("ABB")'},{"ABB_CODTEC","ABB_CODTEC"}},ABB->(IndexKey(1)))

oModel:SetPrimaryKey({'ABB_FILIAL','ABB_CODTEC'})
                                     
Return(oModel)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ta520PosVld()
Pos Validação Model
@param ExpO:oModel
@return ExpL:.T. quando válido
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Ta520PosVld(oModel)
Local nOpc			:= oModel:GetOperation()
Local lRet			:= .T.
Local nCntFor		:= 1
Local aSaveLines	:= {}
Local oMdl			:= oModel:GetModel("ABBGRID")
Local nI

If nOpc == MODEL_OPERATION_INSERT
	//Inicializador padrao da inclusao diz q o model principal precisa de modificação :-(
	oModel:GetModel("ABBCAB"):ADATAMODEL[1][1][3] := .T.

	lRet := .F.
	aSaveLines := FWSaveRows()
	
	For nI := 1 To oMdl:Length()
		oMdl:GoLine(nCntFor)
		If !oMdl:IsDeleted() .AND. !Empty(FwFldGet("ABB_CHAVE"))
			lRet := .T.
			Exit
		EndIf
	Next nCntFor
	
	FwRestRows(aSaveLines)
EndIf

If !lRet
	Help("",1,"TA520POSVLD",,STR0003,2,0) //"É necessário incluir ao menos um agendamento."
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da View 
@return ExpO:oView
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView

Local oModel		:= FWLoadModel('TECA520')
Local oStruCab	:= FWFormStruct(2,'ABB',{|cCampo| AllTrim(cCampo)+"|" $ "ABB_FILIAL|ABB_CODTEC|ABB_NOMTEC|"})
Local oStruGrid	:= FWFormStruct(2,'ABB')

oStruGrid:RemoveField('ABB_CODTEC')
oStruGrid:RemoveField('ABB_NOMTEC')
oStruGrid:RemoveField('ABB_NUMOS')

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_CAB',oStruCab,'ABBCAB')
oView:AddGrid('VIEW_GRID',oStruGrid,'ABBGRID' )

oView:CreateHorizontalBox('SUPERIOR',12)
oView:CreateHorizontalBox('INFERIOR',88)

oView:SetOwnerView( 'VIEW_CAB','SUPERIOR' )
oView:SetOwnerView( 'VIEW_GRID','INFERIOR' )

Return(oView)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Opções da Rotina
@return ExpA:aRotina
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "TECA520" )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TA520Load()
Load dos dados para o grid 
@param ExpO:Model do Grid
@param ExpL:Se é ou nao copia.
@return ExpA:Acols no Formato da função FormLoadGrid
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TA520Load(oMdlGrid,lCopy)

Local aColsGrid	:= {}
Local aLinha		:= {}
Local cAlias		:= GetNextAlias()
Local nX			:= 0
Local nY			:= 0
Local cInit		:= ""

If IsInCallStack("TECA500") .AND. Type("dData") == "D"
	BeginSQL alias cAlias
		SELECT ABB.R_E_C_N_O_ REC
		  FROM %table:ABB% ABB
		 WHERE ABB.ABB_FILIAL = %xfilial:ABB%
		   AND ABB.ABB_CODTEC = %exp:AA1->AA1_CODTEC%
		   AND %exp:dData% BETWEEN ABB.ABB_DTINI AND ABB.ABB_DTFIM
		   AND ABB.%notDel%
	EndSQL

	DbSelectArea(cAlias)
	While (cAlias)->(!Eof())
		nX++
		aLinha := {{},{}}
		ABB->(DbGoTo((cAlias)->REC))
		For nY := 1 To Len(oMdlGrid:aHeader)
			If oMdlGrid:aHeader[nY][10] == "V"
				cInit := Posicione("SX3",2,oMdlGrid:aHeader[nY][2],"X3_RELACAO")
				If !Empty(cInit)
					AAdd(aLinha[2],InitPad(cInit))
				Else
					If oMdlGrid:aHeader[nY][2] == "ABB_NOMTEC"
						AAdd(aLinha[2],POSICIONE("AA1", 1, XFilial("AA1")+ABB->ABB_CODTEC, "AA1_NOMTEC"))
					Else
						AAdd(aLinha[2],"")
					EndIf
				EndIf
			Else
				AAdd(aLinha[2],&("ABB->"+oMdlGrid:aHeader[nY][2]))
			EndIf
		Next nY
		AAdd(aLinha[2],.F.)
		aLinha[1] := (cAlias)->REC
		Aadd(aColsGrid,aLinha)
		DbSkip()
	EndDo
	(cAlias)->(DbCloseArea())

Else
	aColsGrid := FormLoadGrid(oMdlGrid,lCopy)
EndIf

ABB->(DbGoBottom())
ABB->(DbSkip())

Return aColsGrid 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ta520LPos()
Linha OK do Grid do TECA520 e TECA521
@param ExpO:Model do Grid
@return ExpL:.T. quando linha valida
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Ta520LPos(oMdl)
Return Ta520VlDt(.T.,oMdl:GetDataId(),oMdl) //Valida Se já há agendamento para o técnico

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ta520Comm()
Commit do Teca520 e Teca521
@param ExpO:Model
@return ExpL:.T. quando sucesso no commit
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Ta520Comm(oMdl)

Local nX			:= 0
Local lAT500Alt	:= ExistBlock("AT500ALT")
Local lAT500Grv	:= ExistBlock("AT500GRV")
Local lAT500Del	:= ExistBlock("AT500DEL")
Local oMdlGrid	:= oMdl:GetModel("ABBGRID")
Local cEventID
Local cMensagem
Local cTecnico
Local nOpc			:= oMdl:GetOperation()
Local bBeforeLin	:= NIL
Local bAfterLin	:= NIL
Local lRet			:= .F.

If ExistBlock("AT500OK")
	ExecBlock("AT500OK", .F., .F.)
EndIf

For nX := 1 To oMdlGrid:Length()

	oMdlGrid:GoLine(nX)
	//Corrige Filial - Por algum motivo o MVC as vezes grava errado
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
		oMdlGrid:SetValue("ABB_FILIAL",XFilial("ABB"))
	ElseIf nOpc == MODEL_OPERATION_DELETE		
		If lAT500Del
			bBeforeLin := {|| ExecBlock( "AT500DEL", .F., .F.,{oMdl}) }
		EndIf
		
		DbSelectArea("AAT")
		DbSetOrder(1)
		If AAT->(DbSeek(xFilial("AAT")+ALLTRIM(oMdlGrid:GetValue("ABB_CHAVE"))))
			RecLock("AAT",.F.)
			AAT->AAT_STATUS	:= "1"
			AAT->AAT_DTINI	:= CTOD("  /  /  ")
			AAT->AAT_HRINI	:= ""
			AAT->AAT_DTFIM	:= CTOD("  /  /  ")
			AAT->AAT_HRFIM	:= ""
			MsUnLock()
		EndIf
	EndIf

	If !Empty(oMdlGrid:GetValue("ABB_NUMOS"))
		If nOpc != MODEL_OPERATION_DELETE

			AB6->( DbSetOrder( 1 ) )
			AB6->( DbSeek( xFilial( "AB6" ) + oMdlGrid:GetValue("ABB_NUMOS") ) )

			SA1->( DbSetOrder( 1 ) )
			SA1->( DbSeek( xFilial( "SA1" ) + AB6->AB6_CODCLI + AB6->AB6_LOJA ) )

			ABB->( DbSetOrder( 1 ) )
			ABB->( DbGoTo(oMdlGrid:GetDataId()) )

			// "Cliente: ", "Endereco: ", "Municipio: ", "UF: ", "Telefone: " 
			cCorpo 	:=	AllTrim(RetTitle( "A1_COD" ))+ ": " + SA1->A1_COD + " - " + SA1->A1_NOME + CRLF +;
							AllTrim(RetTitle( "A1_END" ))+ ": " + SA1->A1_END + CRLF +;
							AllTrim(RetTitle( "A1_MUN" ))+ ": " + SA1->A1_MUN + CRLF +;
							AllTrim(RetTitle( "A1_EST" ))+ ": " + SA1->A1_EST + CRLF +;
							AllTrim(RetTitle( "A1_TEL" )) +": " + SA1->A1_TEL

			If ( !oMdlGrid:IsDeleted() .And. !Empty(oMdlGrid:GetValue("ABB_HRINI")) )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia o e-Mail caso um campo importante tenha sido alterado            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				If	ABB->ABB_DTINI <> oMdlGrid:GetValue("ABB_DTINI") .Or. ABB->ABB_HRINI <> oMdlGrid:GetValue("ABB_HRINI") .Or. ;
						ABB->ABB_DTFIM <> oMdlGrid:GetValue("ABB_DTFIM") .Or. ABB->ABB_HRFIM <> oMdlGrid:GetValue("ABB_HRFIM") .Or. ;
						ABB->ABB_NUMOS <> oMdlGrid:GetValue("ABB_NUMOS")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Event Viewer - Envia e-mail ou RSS para    ³
					//| Alocacao de Tecnicos - Field Service.      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					cEventID  := "009"
					cMensagem := RetTitle("ABB_NUMOS") + " - " + oMdlGrid:GetValue("ABB_NUMOS") + " " + cCorpo
					cTecnico  := RetTitle("ABB_CODTEC") + " - " + AllTrim( AA1->AA1_NOMTEC )
					EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID, FW_EV_LEVEL_INFO,""/*cCargo*/,cTecnico,cMensagem)

				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Event Viewer - Envia e-mail ou RSS para    ³
				//| Alocacao de Tecnicos - Field Service.      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cEventID  := "009"
				cMensagem := RetTitle("ABB_NUMOS") + " - " + oMdlGrid:GetValue("ABB_NUMOS") + " " + cCorpo
				cTecnico  := RetTitle("ABB_CODTEC") + " - " + AllTrim( AA1->AA1_NOMTEC )
				EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID, FW_EV_LEVEL_INFO,""/*cCargo*/,cTecnico,cMensagem)
			EndIf
		EndIf
	EndIf

	If oMdlGrid:IsDeleted()
		If lAT500Del
			bBeforeLin := {|| ExecBlock( "AT500DEL", .F., .F.,{oMdl}) }
		EndIf
	Else
		If oMdlGrid:IsUpdated() .And. lAT500Alt
			bBeforeLin := {|| ExecBlock( "AT500ALT", .F., .F.,{oMdl}) }
		EndIf

		If oMdlGrid:IsInserted() .And. lAT500Grv
			bAfterLin := {|| ExecBlock( "AT500GRV", .F., .F.,{oMdl}) }
		EndIf
	EndIf

Next nX

lRet := FwFormCommit(oMdl,bBeforeLin,bAfterLin)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ta520VlDt()
Validação das Datas Iniciais e Finais (Acionada pelo LinhaOk do Grid).
@param ExpL:Quanto .T. checará se existem alocações para o período.
@param ExpN:nRecno atual (quando alteração) para ignorar o registro atual 
@return ExpL:.T. quando sucesso no commit
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Ta520VlDt(lCheckAloc,nRecno,oMdl,cCodTec)

Local cReadVar		:= ""
Local lRetorno		:= .T.
Local lLibAgenRH    :=  SuperGetMv("MV_GSAGTRH",.F.,.F.) // Define se verifica conflitos de RH para geração da agenda do Técnico (.F. = Não verifica, .T. = Verifica)
Local dDtIni
Local dDtFim
Local cHrIni
Local cHrFim
Local cCodigo		:= ""
Local cCodEnt		:= TxGetVar("ABB_ENTIDA")
Local cNumOS		:= TxGetVar("ABB_NUMOS")
Local cHrVazio		:= "  :  |" + Space( 5 )
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local nI			:= 0
Local nLinha		:= oMdl:GetLine()
Local lAlocAtiv		:= ( !oMdl:IsDeleted() .And. TxGetVar("ABB_ATIVO")=='1' )
Local cDtHrIni		:= ""
Local cDtHrFim		:= ""
Local cDtHrIniTmp	:= ""
Local cDtHrFimTmp	:= ""
Local aRes          := {}
Local lContinua     := .F.
Local cDtIniAnt     := ""
Local cDtFimAnt     := ""
Local cHrIniAnt     := ""
Local cHrFimAnt     := ""
Local aRecno        := {}
Local aAreaABB      := {}

Default lCheckAloc := .F.
Default cCodTec	   := TxGetVar("ABB_CODTEC")

cReadVar := AllTrim( ReadVar() )

dDtIni := TxGetVar( "ABB_DTINI" )
dDtFim := TxGetVar( "ABB_DTFIM" )
cHrIni := TxGetVar( "ABB_HRINI" )
cHrFim := TxGetVar( "ABB_HRFIM" )

If  lLibAgenRH 
    aRes :=  ChkCfltAlc(dDtIni,dDtFim,cCodTec,cHrIni,cHrFim) 
    If  aRes[1]  .or. aRes[2] .or. aRes[3] .or. aRes[6] 		     
		lContinua := .T.
    Endif
	If aRes[4]
		Help("",1,"TA520VLDT",,STR0002,2,0) //"O Técnico já possui alocação no período escolhido."
		Return .F.
	EndIf	  
Endif

//Verifica status do atendente
If !Ta520StAte(cCodTec) 
	Return .F.
EndIf

Do Case
	Case "ABB_DTINI" $ cReadVar
		dDtIni := oMdl:GetValue("ABB_DTINI")
	Case "ABB_DTFIM" $ cReadVar
		dDtFim := oMdl:GetValue("ABB_DTFIM")
	Case "ABB_HRINI" $ cReadVar
		cHrIni := oMdl:GetValue("ABB_HRINI")
	Case "ABB_HRFIM" $ cReadVar
		cHrFim := oMdl:GetValue("ABB_HRFIM")
EndCase

lRetorno := AtVldDiaHr( dDtIni, dDtFim, cHrIni, cHrFim )

If !lRetorno
	Do Case
		Case ( "ABB_DTINI"$cReadVar )
			Help(" ",1,"AT500DATA1")
		Case ( "ABB_DTFIM"$cReadVar )
			Help(" ",1,"AT500DATA2")
	EndCase
EndIf

If lCheckAloc .AND. lRetorno .AND. !Empty(dDtIni) .AND. !Empty(dDtFim) .AND. !(cHrIni $ cHrVazio) .AND. !(cHrFim $ cHrVazio)

	cDtHrIni := DtoS(dDtIni)+cHrIni
	cDtHrFim := DtoS(dDtFim)+cHrFim

	If lAlocAtiv
		//Verifica se há superalocação no proprio grid
		For nI := 1 To oMdl:Length()
			oMdl:GoLine(nI)
			cDtHrIniTmp := DtoS(oMdl:GetValue("ABB_DTINI"))+oMdl:GetValue("ABB_HRINI")
			cDtHrFimTmp := DtoS(oMdl:GetValue("ABB_DTFIM"))+oMdl:GetValue("ABB_HRFIM")
	
			If !oMdl:IsDeleted() .And. nLinha != oMdl:GetLine() .AND. !Empty(cDtHrIni) .AND. !Empty(cDtHrFim) .AND. ;
				cCodTec == TxGetVar("ABB_CODTEC") .AND. TxGetVar("ABB_ATIVO")=='1' .AND. (;
					(cDtHrIni		>=	cDtHrIniTmp	.AND.	cDtHrIni		<=	cDtHrFimTmp)	.OR.;
					(cDtHrFim		>=	cDtHrIniTmp	.AND.	cDtHrFim		<=	cDtHrFimTmp)	.OR.;
					(cDtHrIniTmp	>=	cDtHrIni		.AND.	cDtHrIniTmp	<=	cDtHrFim)		.OR.;
					(cDtHrFimTmp	>=	cDtHrIni		.AND.	cDtHrFimTmp	<=	cDtHrFim)		.OR.;
					(cDtHrIni		<=	cDtHrIniTmp	.AND.	cDtHrFim		>=	cDtHrFimTmp)  )
					
				lRetorno := .F.
				Exit
			EndIf

			If IsInCallStack("TECA500") .AND. !oMdl:IsDeleted();
			.AND. !Empty(cDtHrIni) .AND. !Empty(cDtHrFim) .AND. oMdl:GetValue("ABB_ATIVO") == "1"

				cDtIniTmp := DtoS(oMdl:GetValue("ABB_DTINI"))
				cDtFimTmp := DtoS(oMdl:GetValue("ABB_DTFIM"))
				cHrIniTmp := oMdl:GetValue("ABB_HRINI")
				cHrFimTmp := oMdl:GetValue("ABB_HRFIM")

				cCodigo := oMdl:GetValue("ABB_CODIGO")
				cDtIniAnt := DtoS(Posicione("ABB",8,xFilial("ABB")+cCodigo,"ABB_DTINI"))
				cDtFimAnt := DtoS(Posicione("ABB",8,xFilial("ABB")+cCodigo,"ABB_DTFIM"))
				cHrIniAnt := Posicione("ABB",8,xFilial("ABB")+cCodigo,"ABB_HRINI")
				cHrFimAnt := Posicione("ABB",8,xFilial("ABB")+cCodigo,"ABB_HRFIM")

				If (cDtFimTmp == cDtFimAnt .AND. cHrFimTmp < cHrFimAnt) .OR. (cDtIniTmp == cDtIniAnt .AND. cHrIniTmp > cHrIniAnt)
			
					aAreaABB := Getarea() // Armazena o ambiente do arquivo ABB
					Dbselectarea("ABB")					
					ABB->(dbsetorder(8))
					If ABB->(dbseek(oMdl:GetValue("ABB_FILIAL")+oMdl:GetValue("ABB_CODIGO")))
						AADD(aRecno, ABB->(Recno()))
					EndIf
					Restarea(aAreaABB) // Restaura o ambiente do arquivo ABB
				EndIf
			EndIf
		Next nI

		If lRetorno
			lRetorno := ! TxExistAloc( cCodTec,dDtIni, cHrIni, dDtFim , cHrFim, nRecno,,,,aRecno)
			lRetorno := lRetorno .And. !At520CkAg(cCodTec,dDtIni,cHrIni,dDtFim,cHrFim,nRecno,aRecno)
		EndIf
		
	EndIf
	
	If !lRetorno
		Help("",1,"TA520VLDT",,STR0002,2,0) //"O Técnico já possui alocação no período escolhido."
	Elseif lContinua 
        lRetorno := .F. 
		Help("",1,"TA520VLDT",,STR0004,2,0) //"O Técnico possui Conflito de Alocação com o RH. Verifique com o Departamento de recursos humanos e tente novamente"
	Else
		If cCodEnt == "AAT"
			lRetorno := At510GrAAt(cCodTec,dDtIni, cHrIni, dDtFim , cHrFim)
		EndIf
	EndIf

	If lRetorno .And. (cCodEnt == "AB6" .Or. cCodEnt = "AB7") .And. !At520VlEnt(cCodEnt,cNumOS)
		lRetorno := .F. 
		Help("",1,"TA520VLDT",,STR0005, 1, 0,,,,,,{STR0006} )//"Não é possivel realizar agendamento de ordem de serviço com uma entidade diferente"##"Altere o campo Cod.Entidade(ABB_ENTIDA) para a mesma entidade do agendamento anterior"
	EndIf

EndIf

FwRestRows(aSaveLines)
	
RestArea(aArea)
Return(lRetorno)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ta520StAte()
Validação do técnico a ser alocado
@param ExpC: Codigo do Técnico a ser validado
@return ExpL:.T. quando sucesso na validação
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Ta520StAte(cCodTec)
Local lRet 		:= .T.

//Verifica se o técnico está bloqueado
lRet := RegistroOk("AA1")

//Verifica se o técnico está disponivel para alocação
If lRet .And. !(AA1->AA1_TIPO $ "13" .And. AA1->AA1_ALOCA == "1")
	Help( " ", 1, "AT500VISU" ) // 	Nao e permitida a alteracao deste tecnico
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At520VlEnt()
Validação da ordem de serviço, verificando se há um agendamento com entidade diferente
@param ExpC: Codigo da entidade do agendamento
@param ExpC: Numero da ordem de serviço
@return ExpL:.F. Quando encontra um agendamento com entidade diferente
@author Luiz Gabriel
@since 09/12/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At520VlEnt(cCodEnt,cNumOS)
Local lRet 	:= .T.
Local cTemp	:= GetNextAlias()

cQuery := "SELECT ABB.ABB_NUMOS,ABB.ABB_ENTIDA "
cQuery += "FROM " + RetSqlName('ABB') + " ABB "
cQuery += "WHERE ABB.ABB_FILIAL = '"+xFilial("ABB") + "' "
cQuery += " AND ABB.ABB_ENTIDA != '"+ cCodEnt + "' "
cQuery += " AND ABB.ABB_NUMOS = '" + cNumOs + "' "
cQuery += " AND ABB.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTemp, .F., .T.)

While ( cTemp )->( !Eof() )
	If Alltrim(( cTemp )->ABB_ENTIDA) != Alltrim(cCodEnt)
		lRet := .F.
		Exit
	EndIf 
	( cTemp )->( DBSkip() )
EndDo
( cTemp )->(dbCloseArea())
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At520CkAg()
Validação da agenda para verificar se há agendamento exatamente no mesmo horario
@param ExpC:Codigo do Tecnico (ABB_CODTEC)
@param ExpD:Data Inicial (ABB_DTINI)
@param ExpC:Hora Inicial (ABB_HRINI)
@param ExpD:Data Final (ABB_DTFIM)
@param ExpC:Hora Final (ABB_HRFIM)
@param ExpN:Recno da ABB a ser Ignorado (Caso seja uma alteração, informe o recno para ignorar o proprio na consulta)
@return ExpL: Retorna .T. quando há alocação
@author Luiz Gabriel
@since 09/03/2022
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At520CkAg(cCodTec,dDtIni,cHrIni,dDtFim,cHrFim,nRecno,aRecno)
Local aOldArea	:= GetArea()
Local cAlias	:= GetNextAlias()
Local lRet		:= .F.
Local cExpConc	:= If(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","%ABB.ABB_DTINI||ABB.ABB_HRINI%","%ABB.ABB_DTINI+ABB.ABB_HRINI%") //Sinal de concatenação (Igual ao ADMXFUN)
Local cExpConcF	:= If(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","%ABB.ABB_DTFIM||ABB.ABB_HRFIM%","%ABB.ABB_DTFIM+ABB.ABB_HRFIM%") //Sinal de concatenação (Igual ao ADMXFUN)
Local cWhere    := ""
Local nI        := 0

Default nRecno := 0
Default aRecno := {}

If !Empty(aRecno)
	cWhere += " AND ABB.R_E_C_N_O_ NOT IN ("
	For nI := 1 To Len(aRecno)
		If nI > 1
			cWhere +=","
		EndIf
		cWhere += "'"+Alltrim(CValToChar(aRecno[nI]))+"'"
	Next nI   
	if nRecno != 0 
		cWhere += ",'"+CValToChar(nRecno)+"'"  
	endif
	cWhere += ") "	
Else
	cWhere += " AND ABB.R_E_C_N_O_ NOT IN ('"+CValToChar(nRecno)+"') " 
EndIf

cWhere		:= "%"+ cWhere + "%"

BeginSQL alias cAlias
	select COUNT(1) AS CT
	  from %table:ABB% ABB
	 where ABB.%NotDel%
	   AND ABB.ABB_CODTEC = %exp:cCodTec%
	   AND (
			 (%exp:DTOS(dDtIni)+cHrIni% = %exp:cExpConc% OR %exp:DTOS(dDtIni)+cHrIni% = %exp:cExpConcF%)
       		 OR 
			 (%exp:DTOS(dDtFim)+cHrFim% = %exp:cExpConc% OR %exp:DTOS(dDtFim)+cHrFim% = %exp:cExpConcF%)
       		 OR 
			 (%exp:cExpConc% = %exp:DTOS(dDtIni)+cHrIni% OR %exp:cExpConc% = %exp:DTOS(dDtFim)+cHrFim%)
       		 OR 
			 (%exp:cExpConc% = %exp:DTOS(dDtIni)+cHrIni% OR %exp:cExpConc% = %exp:DTOS(dDtFim)+cHrFim%)
	   		)
		%Exp:cWhere%
EndSQL

DbSelectArea(cAlias)
If (cAlias)->(!Eof()) .AND. (cAlias)->CT > 0
	lRet := .T.
EndIf
(cAlias)->(DbCloseArea())
RestArea(aOldArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ta520PreVl()
Pré validação do Field(Cabeçalho)
Valida se é possível alterar o código do atendente no cabeçalho do modelo.
@Return .T. caso não haja conflitos de alocação.
@author Jack Junior
@since 10/08/2022
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Ta520PreVl(oMdl,cAcao,cCampo,xValue)
Local aArea			:= GetArea()
Local cCodTec		:= ""
Local cDtHrIni		:= ""
Local cDtHrFim		:= ""
Local cHrIniTmp		:= ""
Local cHrFimTmp		:= ""
Local lRetorno 		:= .T.
Local nI			:= 0
Local oMdlGeral		:= Nil
Local oMdlGrid 		:= Nil

If IsInCallStack("TECA500")
	If cAcao == "SETVALUE"
		If cCampo == "ABB_CODTEC"
			oMdlGeral := oMdl:GetModel()
			oMdlGrid := oMdlGeral:GetModel("ABBGRID")
			cCodTec := xValue
			For nI := 1 to oMdlGrid:Length()
				oMdlGrid:GoLine(nI)
				If !oMdlGrid:IsDeleted()
					cDtHrIni := DtoS(oMdlGrid:GetValue("ABB_DTINI"))+oMdlGrid:GetValue("ABB_HRINI")
					cDtHrFim := DtoS(oMdlGrid:GetValue("ABB_DTFIM"))+oMdlGrid:GetValue("ABB_HRFIM")
					If !Empty(cDtHrIni) .AND. !Empty(cDtHrFim) .AND. oMdlGrid:GetValue("ABB_ATIVO") == "1"
						cHrIniTmp 	:= oMdlGrid:GetValue("ABB_HRINI")
						cHrFimTmp 	:= oMdlGrid:GetValue("ABB_HRFIM")

						lRetorno := !TxExistAloc(cCodTec,oMdlGrid:GetValue("ABB_DTINI"),cHrIniTmp,oMdlGrid:GetValue("ABB_DTFIM"),cHrFimTmp,oMdlGrid:GetDataId())
						lRetorno := lRetorno .And. !At520CkAg(cCodTec,oMdlGrid:GetValue("ABB_DTINI"),cHrIniTmp,oMdlGrid:GetValue("ABB_DTFIM"),cHrFimTmp,oMdlGrid:GetDataId())
							
						If !lRetorno
							Exit
						EndIf
					EndIf
				EndIf
			Next nI
		EndIf
	EndIf
EndIf

If !lRetorno
	Help("",1,"TA520PREVL",,STR0002,2,0) //"O Técnico já possui alocação no período escolhido."
EndIf

RestArea(aArea)
Return (lRetorno)

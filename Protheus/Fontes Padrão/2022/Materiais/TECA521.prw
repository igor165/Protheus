#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TECA521.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA521()

Agendamento dos Atendentes - ABB

/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA521(xAutoItens,nOpcAuto)

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
Local oStruCab	:= FWFormStruct(1,'ABB',{||.F.})//{|cCampo| AllTrim(cCampo)+"|" $ "ABB_FILIAL|"})
Local oStruGrid	:= FWFormStruct(1,'ABB')
Local aAux 		:= {}						// Auxiliar para criar a trigger

oStruCab:AddField( ; 
AllTrim( 'Dia ' ) , ;											// [01] C Titulo do campo
AllTrim( 'Dia ' ) , ;											// [02] C ToolTip do campo
'ABB_DIAREF' , ;													// [03] C identificador (ID) do Field
'C' , ;															// [04] C Tipo do campo
10 , ;																// [05] N Tamanho do campo
0 , ;																// [06] N Decimal do campo
FwBuildFeature( STRUCT_FEATURE_VALID,".T."), ;				// [07] B Code-block de validação do campo
NIL , ; 															// [08] B Code-block de validação When do campo
NIL , ;				 											// [09] A Lista de valores permitido do campo
NIL , ; 															// [10] L Indica se o campo tem preenchimento obrigatório
FwBuildFeature( STRUCT_FEATURE_INIPAD, "TA521Dt()" ) , ; 	// [11] B Code-block de inicializacao do campo
NIL , ; 															// [12] L Indica se trata de um campo chave
NIL , ; 															// [13] L Indica se o campo pode receber valor em uma operação de update.
.T. ) 																// [14] L Indica se o campo é virtual

//Ajustes do Dicionario
aAux := FwStruTrigger(;
'ABB_CODTEC',;
'ABB_NOMTEC',;
'AA1->AA1_NOMTEC',;
.T.,;
'AA1',;
1,;
'xFilial("AA1")+FwFldGet("ABB_CODTEC")')
oStruGrid:AddTrigger( ;
aAux[1] , ; 	// [01] identificador (ID) do campo de origem
aAux[2] , ; 	// [02] identificador (ID) do campo de destino
aAux[3] , ; 	// [03] Bloco de código de validação da execução do gatilho
aAux[4] ) 		// [04] Bloco de código de execução do gatilho 	


//Ajustes do Dicionario
aAux := FwStruTrigger(;
'ABB_ENTIDA',;
'ABB_CHAVE',;
'Space(TamSX3("ABB_CHAVE")[1])',;
.F.,;
,;
,;
)
oStruGrid:AddTrigger( ;
aAux[1] , ; 	// [01] identificador (ID) do campo de origem
aAux[2] , ; 	// [02] identificador (ID) do campo de destino
aAux[3] , ; 	// [03] Bloco de código de validação da execução do gatilho
aAux[4] ) 		// [04] Bloco de código de execução do gatilho 	 

oStruGrid:SetProperty("ABB_NOMTEC",MODEL_FIELD_INIT,{|| If(!INCLUI,POSICIONE("AA1", 1, XFilial("AA1")+ABB->ABB_CODTEC, "AA1_NOMTEC"),"")})
oStruGrid:SetProperty("ABB_DTINI",MODEL_FIELD_INIT,{|| If(Type("dData") != "U",dData,dDatabase)})
oStruGrid:SetProperty("ABB_DTFIM",MODEL_FIELD_INIT,{|| If(Type("dData") != "U",dData,dDatabase)})
oStruGrid:SetProperty("ABB_NUMOS",MODEL_FIELD_OBRIGAT,.F.)
oStruGrid:SetProperty("ABB_ENTIDA",MODEL_FIELD_OBRIGAT,.F.)
oStruGrid:SetProperty("ABB_CHAVE",MODEL_FIELD_OBRIGAT,.F.)

oModel := MPFormModel():New('TECA521',/*bPre*/,/*bPosValidacao*/,{|oMdl| Ta520Comm(oMdl)},/*bCancel*/)
oModel:AddFields('ABBCAB',/*cOwner*/,oStruCab,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:AddGrid( 'ABBGRID','ABBCAB',oStruGrid,/*bLinePre*/,{|oMdl| Ta520LPos(oMdl)},/*bPreVal*/,/*bPosVal*/,{|oMdl,lCopy|TA521Load(oMdl,lCopy)})

//ABB_FILIAL+ABB_CODTEC+DTOS(ABB_DTINI)+ABB_HRINI+DTOS(ABB_DTFIM)+ABB_HRFIM 
oModel:SetRelation("ABBGRID",{{"ABB_FILIAL","xFilial('ABB')"},{"ABB_CODTEC","ABB_CODTEC"}},ABB->(IndexKey(1)))

oModel:SetPrimaryKey({'ABB_FILIAL','ABB_CODTEC'})

oModel:SetVldActivate({|oMdl| Ta521VlAct(oMdl)})
oModel:SetDeActivate({|oMdl| Ta521Dt(NIL,.T.)})  //Reseta a Data de Referencia para pegar a do browse (caso venha de outras rotinas)       
   
Return(oModel)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

Definição da View 

@return ExpO:oView

/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView

Local oModel		:= FWLoadModel('TECA521')
Local oStruCab	:= FWFormStruct(2,'ABB',{||.F.})//{|cCampo| AllTrim(cCampo)+"|" $ "ABB_FILIAL|"})
Local oStruGrid	:= FWFormStruct(2,'ABB')

oStruGrid:RemoveField('ABB_NUMOS')

oStruCab:AddField( ; 				// Ord. Tipo Desc.
'ABB_DIAREF' , ; 						// [01] C Nome do Campo
'1' , ; 								// [02] C Ordem
AllTrim( STR0002 ) , ; 			// [03] C Titulo do campo 'Agendamentos da Data'
AllTrim( STR0002 ) , ; 	// [04] C Descrição do campo
{ STR0002 } , ; // [05] A Array com Help
'C' , ; // [06] C Tipo do campo
NIL , ; // [07] C Picture
NIL , ; // [08] B Bloco de Picture Var
'' , ; // [09] C Consulta F3
.F. , ; // [10] L Indica se o campo é evitável
NIL , ; // [11] C Pasta do campo
NIL , ; // [12] C Agrupamento do campo
NIL , ; // [13] A Lista de valores permitido do campo (Combo)
NIL , ; // [14] N Tamanho Maximo da maior opção do combo
NIL , ; // [15] C Inicializador de Browse
.T. , ; // [16] L Indica se o campo é virtual
NIL ) // [17] C Picture Variável

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_CAB',oStruCab,'ABBCAB')
oView:AddGrid('VIEW_GRID',oStruGrid,'ABBGRID' )

oView:CreateHorizontalBox('SUPERIOR',8)
oView:CreateHorizontalBox('INFERIOR',92)

oView:SetOwnerView( 'VIEW_CAB','SUPERIOR' )
oView:SetOwnerView( 'VIEW_GRID','INFERIOR' )

Return(oView)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TA521Load()

Load dos dados para o grid 

@param ExpO:Model do Grid
@param ExpL:Se é ou nao copia.

@return ExpA:Acols no Formato da função FormLoadGrid

/*/
//--------------------------------------------------------------------------------------------------------------------
Function TA521Load(oMdlGrid,lCopy)

Local aColsGrid	:= {}
Local aLinha		:= {}
Local cAlias		:= GetNextAlias()
Local nX			:= 0
Local nY			:= 0
Local cInit		:= ""
Local nRecno		:= If(IsInCallStack("TECA510") .AND. !ABB->(EOF()),ABB->(Recno()),0)
Local cExp			:= "%%"

If nRecno > 0
	cExp := "% AND ABB.R_E_C_N_O_ = '"+cValToChar(nRecno)+"' %"
EndIf

BeginSQL alias cAlias		
	SELECT ABB.R_E_C_N_O_ REC FROM
		%table:ABB% ABB
	WHERE
		ABB.ABB_FILIAL = %xfilial:ABB%
		AND
		%exp:TA521Dt()% BETWEEN ABB.ABB_DTINI AND	ABB.ABB_DTFIM
		AND
		ABB.%notDel%
		%exp:cExp%
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
				AAdd(aLinha[2],"")
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

ABB->(DbGoBottom())
ABB->(DbSkip())

Return aColsGrid 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Opções da Rotina

@return ExpA:aRotina

/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina	:= FWMVCMenu( "TECA521" )
	aAdd( aRotina, { STR0003, 'Ta521Mover', 0, 7, 0, NIL } ) //'Mover'
Return aRotina

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ta521VlAct()

Validação de Ativação do Model. Seta a Data de Referencia de acordo com a data carregada em Ta521Dt() ou a posição 
do grid (ABB). 

@return ExpL:.T.

/*/
//--------------------------------------------------------------------------------------------------------------------
Function Ta521VlAct(oMdl)
           
Local lRet := .T.

If ValType(Ta521Dt()) != "D"
	TA521Dt(ABB->ABB_DTINI)
EndIf

If lRet
	lRet := At510FPGrl(oMdl)
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ta521Dt()

Set/Get da Data de Referencia.

@param dData: (Opcional) Data de Referencia. Sera utilizada para filtrar o Load. Quando nao informada, retornara a 
data de referencia atual
@param lForce: (Opcional) Passando .T. e NIL no parametro dData limpará a data de referencia

@return ExpD:dData
/*/
//-------------------------------------------------------------------------------------------------------------------- 
Function Ta521Dt(dData,lForce)
Default dData		:= NIL
Default lForce	:= .F.
Static dDataRet	:= NIL
	
If ValType(dData) == "D" .OR. lForce
	dDataRet := dData	
EndIf

Return dDataRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ta521Mover()

Move o periodo do Agendamento para a data escolhida

@return NIL
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Ta521Mover()
Local oDlgMov 
Local oPanel
Local oCalend
Local oFooter
Local oOk
Local oCancel
Local dRet	:= Ta521Dt()
Local nDif	:= 0
Local lTecXRh	:= SuperGetMV( 'MV_TECXRH',, .F. )	//Indica se há integração com o RH

Define MsDialog oDlgMov TITLE STR0004 FROM 000, 000 To 200, 300 Pixel //"Mover Agendamento Para"

@ 000, 000 MsPanel oPanel Of oDlgMov Size 100, 100
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

oCalend := MsCalend():New( 01, 01, oPanel, .T. )
oCalend:Align   := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define o dia a ser exibido no calendário    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCalend:dDiaAtu := dRet

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Code-Block para Duplo Clik              	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCalend:bLDblClick := { || dRet :=  oCalend:dDiaAtu, oDlgMov:End() }

oCalend:CanMultSel := .F.

@ 000, 000 MsPanel oFooter Of oDlgMov Size 000, 010
oFooter:Align   := CONTROL_ALIGN_BOTTOM

@ 000, 000 Button oCancel Prompt STR0005  Of oFooter Size 030, 000 Pixel //Cancelar
oCancel:bAction := { || oDlgMov:End() }
oCancel:Align   := CONTROL_ALIGN_RIGHT

@ 000, 000 Button oOk     Prompt STR0006 Of oFooter Size 030, 000 Pixel //Confirmar
oOk:bAction     := { || dRet := oCalend:dDiaAtu, oDlgMov:End() }
oOk:Align       := CONTROL_ALIGN_RIGHT

Activate MsDialog oDlgMov Centered

If ValType(dRet) == "D" .AND. Ta521Dt() != dRet .AND. !ABB->(EOF())
	nDif := ABB->ABB_DTFIM - ABB->ABB_DTINI
	
	If TxExistAloc(ABB->ABB_CODTEC,dRet,ABB->ABB_HRINI,(dRet + nDif),ABB->ABB_HRFIM,ABB->(Recno()))
		Help("",1,"Ta521Mover",,STR0007,2,0) //"O Técnico já possui alocação no período escolhido."
	ElseIf lTecXRh .AND. !At570VldRh(ABB->ABB_CODTEC,dRet, (dRet + nDif) )	
			Help("",1,"Ta521Mover",,STR0008,2,0) //"O Técnico possui bloqueio no RH."
	Else	
		RecLock("ABB",.F.)	
		ABB->ABB_DTINI := dRet
		ABB->ABB_DTFIM := (dRet + nDif)
		MsUnlock()
	EndIf
					
EndIf
	
Return
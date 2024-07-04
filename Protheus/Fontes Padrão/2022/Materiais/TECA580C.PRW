#include "TECA580C.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//----------------------------------------------------------
/*/{Protheus.doc} TECA580C()
Relacionamentos - Gestão de Escalas 

@Return 	nil
@author 	Serviços
@since 		15/05/2014
/*/
//----------------------------------------------------------
Function TECA580C() 
Local oBrowse 

oBrowse := FwMBrowse():New()
oBrowse:SetAlias("TFF")
oBrowse:SetDescription(STR0001) // STR0001//"Relacionamento"
oBrowse:DisableDetails()
oBrowse:Activate()

Return(Nil) 

//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Relacionamentos - Gestão de Escalas 

@Return 	MenuDef
@author 	Serviços
@since 		14/05/2014
/*/
//----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aRotina := FWMVCMenu( 'TECA580C' )

Return(aRotina)

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Relacionamentos - Gestão de Escalas 

@Return 	model
@author 	Serviços
@since 		14/05/2014
/*/
//----------------------------------------------------------
Static Function ModelDef()
Local oModel		:= Nil
Local oStrTFF 	:= FWFormStruct(1,"TFF") 
Local bCommit		:= {|oModel|Tec580GrvC(oModel)}

oModel := MPFormModel():New("TECA580C", /*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/ )

oStrTFF:SetProperty('TFF_PRODUT',MODEL_FIELD_WHEN ,{||.F.})
oStrTFF:SetProperty('TFF_ESCALA',MODEL_FIELD_WHEN ,{||At680Perm( Nil, __cUserID, "014" )})
oStrTFF:SetProperty("TFF_DESCRI",MODEL_FIELD_INIT,{||Posicione("SB1",1,xFilial("SB1")+TFF->TFF_PRODUT,"B1_DESC")})
oStrTFF:SetProperty("TFF_NOMESC",MODEL_FIELD_INIT,{||POSICIONE("TDW",1,xFilial("TDW")+TFF->TFF_ESCALA,"TDW_DESC") })
oStrTFF:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)

oModel:AddFields("TFFMASTER",/*cOwner*/,oStrTFF, /*bPreValidacao*/,{|oMd|AT580CKABB(oMd)} /*bPosValidacao*/, /*bCarga*/ )

oModel:SetDescription(STR0002) // STR0002 									  //"Relacionamento"

Return(oModel)


//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Relacionamentos - Gestão de Escalas 

@Return 	view
@author 	Serviços
@since 		15/05/2014
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel   	:= FWLoadModel("TECA580C")  
Local oStrTFF	:= FwFormStruct(2,"TFF", {|cCpo| AllTrim(cCpo)$'TFF_COD+TFF_CONTRT+TFF_PRODUT+TFF_DESCRI+TFF_LOCAL+TFF_ESCALA+TFF_NOMESC+TFF_PROCP' } )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_TFF",oStrTFF,"TFFMASTER")

oView:CreateHorizontalBox( "TELA" , 100 )
oView:SetOwnerView( "VIEW_TFF", "TELA" ) 

//Fechar a janela apos a gravação
oView:SetCloseOnOk({|| .T.} )

Return(oView)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tec580GrvC

Gravação do Model

@author 	Serviços
@since 		08/04/2014
@version 	P12

/*/
//--------------------------------------------------------------------------------------------------------------------
Function Tec580GrvC(oModel)
Local nOpcx		:= oModel:GetOperation()
Local aArea		:= GetArea()
Local lRet			:= .T.
Local lRecLock	:= .F.
Local aItemRH		:= {}
Local lAtuSaldo	:= .T.

If nOpcx == MODEL_OPERATION_UPDATE .And. (IsInCallStack('Tx580PxE') .OR. isInCallStack("AjustaTGY"))
	
	//Contrato não é recorrente, gera o saldo
	If At740Recor(TFF->TFF_CONTRT)
		//Verifica se existe configuração de alocação criado para o contrato
		lRecLock := At580VldTFF(	TFF->TFF_CONTRT, TFF->TFF_COD, TFF->TFF_FILIAL ) 
	
		//Calcula o saldo para atualizar a ABQ
		nHoras := TecCalcEsc(oModel:GetModel("TFFMASTER"):GetValue("TFF_ESCALA"))
		
		//Atualiza a ABQ
		lRet := Tec580GrABQ(nHoras,lRecLock)
	EndIf
	
	If lRet
		lRet := FwFormCommit( oModel )
	EndIf
	
EndIf

RestArea(aArea)

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At580VldTFF
	
Valida se existe o recurso ja criado na configuração de alocação do atendente

@sample 	At580VldTFF(cContrato,cCodTFF,cFilTFF)

@since		26/06/2014      
@version	P119

@return 	lRet, Lógico, retorna .T. se data for válida.

@param  	cContrato, Caracter, Numero do contrato para a consistencia.
@param  	cCodTFF, Caracter, codigo do recurso para a consistencia.
@param  	cFilTFF, Caracter, filial do recurso para a consistencia.

/*/
//------------------------------------------------------------------------------
Static Function At580VldTFF( cContrato, cCodTFF, cFilTFF )

Local lRet    := .T.
Local aArea   := GetArea()

dbSelectArea("ABQ")
ABQ->(dbSetOrder(3)) //ABQ_FILIAL + ABQ_CODTFF  + ABQ_FILTFF

lRet :=  !ABQ->(dbSeek(xFilial("ABQ")+cCodTFF+cFilTFF))

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tx580PxE

Realiza o Calculo das horas comparando a escala com o criacalend

@author 	Serviços
@since 		08/04/2014
@version 	P12

/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecCalcEsc(cEscala, dDtIni, dDtFim, cCalend)
Local nHoras		:= 0
Local aTurno		:= {}
Local nX			:= 0
Local nI			:= 0
Local nTotHrsEst	:= 0
Local nTotHrEsc		:= 0
Local aHoraEsc		:= {}
Local lReturn		:= .F.
Local aTabPadrao	:= {}
Local aTabCalend	:=	{}
Local aExcePer		:=	{}
Local nPos			:= 0
Local lTecPnm	:= FindFunction( "TecExecPNM" ) .AND. TecExecPNM()

Default cEscala 	:= ""
Default dDtIni		:= sToD("")
Default dDtFim		:= sToD("")
Default cCalend		:= ""

//Verificar quais os turnos estão configurados na escala
DbSelectArea("TDW")
TDW->(DbSetOrder(1))
	
If TDW->(DbSeek(xFilial("TDW") + cEscala ))
	DbSelectArea("TDX")
	TDX->(DbSetOrder(2))
	If TDX->(DbSeek(xFilial("TDX") + TDW->TDW_COD))
		While !TDX->(Eof()) .AND. TDX->TDX_FILIAL == xFilial("TDX") .AND. TDX->TDX_CODTDW == TDW->TDW_COD .AND. TDX->TDX_TIPO == "1"
			Aadd(aTurno,{TDX->TDX_COD,TDX->TDX_TURNO,TDX->TDX_SEQTUR})
			TDX->(DbSkip())
		End
	EndIf
		
EndIf
	
DbSelectArea("TGW")
TGW->(DbSetOrder(2))	
	
For nI := 1 To Len(aTurno)
	//Calcula o intervalo e a folga na escala
	If TGW->(DbSeek(xFilial("TGW") + aTurno[nI][1]))
		While !TGW->(Eof()) .AND. TGW->TGW_FILIAL == xFilial("TGW") .AND. TGW->TGW_EFETDX == aTurno[nI][1]
			If (TGW->TGW_STATUS == "2" .Or. TGW->TGW_STATUS == "3") .And. !Empty(TGW_COBTDX)
				Aadd(aHoraEsc,{TGW->TGW_DIASEM,TxAjtHoras((TGW->TGW_HORFIM - TGW->TGW_HORINI))})
			EndIF
				
			TGW->(DbSkip())	
		End
			
	EndIf
	
	If Empty(dDtIni) .AND. Empty(dDtFim)
		lReturn := CriaCalend(TFF->TFF_PERINI,TFF->TFF_PERFIM,aTurno[nI][2],aTurno[nI][3],@aTabPadrao,@aTabCalend,xFilial("SR6"),,,,aExcePer)
	Else
		If !EMPTY(cCalend) .AND. lTecPnm
            TecPNMSCal( cCalend )
			TecPNMSEsc( cEscala )
		EndIf
		lReturn := CriaCalend(dDtIni,dDtFim,aTurno[nI][2],aTurno[nI][3],@aTabPadrao,@aTabCalend,xFilial("SR6"),,,,aExcePer)
		If !EMPTY(cCalend) .AND. lTecPnm
			TecPNMSCal(Nil)
			TecPNMSEsc(Nil)
		EndIf
	EndIf
	If lReturn
		For nX := 1 To Len(aTabCalend)
			If aTabCalend[nX][4] == "1E"
				nPos := Ascan(aHoraEsc,{ |x| x[1] == cValToChar(Dow(aTabCalend[nX][1])) })
				If nPos > 0
					nTotHrEsc += aHoraEsc[nPos][2]
				EndIf
			EndIf
				
			If aTabCalend[nX][6] == "S"					
				If Substr(aTabCalend[nX][4],2,1) == "E"
					nTotHrsEst += TxAjtHoras(aTabCalend[nX][7])
				ElseIf Substr(aTabCalend[nX][4],2,1) == "S" .AND. !isInCallStack("At930CaRH")
					nTotHrsEst += TxAjtHoras(aTabCalend[nX][9])	
				EndIf
			EndIf	
		Next nX
	EndIf
	
Next nI
	
nHoras := nTotHrEsc + nTotHrsEst

Return(nHoras)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tx580PxE

Atualiza a Tabela ABQ - Configuração de Alocação

@author 	Serviços
@since 		08/04/2014
@version 	P12

/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Tec580GrABQ(nHoras,lRecLock)
Local lRet 	:= .F.
Local nSaldo := 0

Default nHoras := 0

If !lRecLock
	//Calcula o Saldo
	nSaldo := ABQ->ABQ_TOTAL - ABQ->ABQ_SALDO
	
	BEGIN TRANSACTION
		RecLock("ABQ", lRecLock)
			ABQ->ABQ_HRSEST	:=	nHoras
			ABQ->ABQ_TOTAL	:= ABQ->ABQ_FATOR*nHoras
			ABQ->ABQ_SALDO	:= ABQ->ABQ_TOTAL - nSaldo
		ABQ->(MsUnlock())	
	END TRANSACTION
	
	lRet := .T.
	
EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT580CKABB

Verifica se existe agenda ativa para um determinado Local (TFF)

@author 	Diego Bezerra
@since 		18/02/2019
@version 	P12

/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT580CKABB(oModel)

Local lRet 			:= .T.
Local lFound		:= .F.
Local cAliasHAbb 	:= GetNextAlias()
Local cOldEscala	:= oModel:GetValue('TFF_ESCALA')
Local lChanged		:= Iif (TFF->TFF_ESCALA != cOldEscala, .T., .F.)

If !Empty(TFF->TFF_ESCALA) .AND. TFF->TFF_ESCALA != Nil .OR. lChanged
	DbSelectArea("ABQ")
	ABQ->( DbSetOrder( 3 ) )//ABQ_FILIAL+ABQ_CODTFF+ABQ_FILTFF  
	If DbSeek(xFilial("ABQ") + TFF->TFF_COD + TFF->TFF_FILIAL) 
		BeginSql Alias cAliasHAbb
			SELECT 1 ABB_GERADO 
				FROM %table:ABB% ABB 
					WHERE 
						ABB.ABB_FILIAL = %xFilial:ABB% AND 
						ABB.ABB_IDCFAL = %Exp:ABQ->ABQ_CONTRT+ABQ->ABQ_ITEM+ABQ->ABQ_ORIGEM% AND
						ABB.ABB_ATIVO = '1' AND
						ABB.%NotDel%
		EndSql
		lFound := (cAliasHAbb)->(!EOF())
		(cAliasHAbb)->(DbCloseArea())
	EndIf
EndIf

If lChanged .AND. lFound
	If !(isInCallStack("AjustaTGY")) .AND. !(lRet := MsgYesNo(STR0006)) // "Já existem agendas geradas para esse local, utilizando outra escala. Deseja mesmo alterar a escala?"
		Help(,,"AT580CKABB",,STR0007,1,0) //"A alteração na escala não foi efetivada."
	Endif
EndIf

Return lRet

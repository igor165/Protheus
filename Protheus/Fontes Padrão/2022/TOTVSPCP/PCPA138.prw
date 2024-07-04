
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PCPA138.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA138
Tela para visualização e reprocessamento de apontamentos pendentes
@author Gustavo Baptista
@since 12/04/2019
/*/
//-------------------------------------------------------------------
Function PCPA138()
	
	Local aStrFields := {"T4K_FILIAL","T4K_SEQ","T4K_COD","T4K_DATA","T4K_HORA","T4K_USER"}
	Local nX := 1
	Local cQuery := ""

	Private oMark
	Private aRotina	:= MenuDef()
	Private aBrowse     := {}
	Private cAliasTmp := GetNextAlias() 
	PRIVATE lSched	  := .F. 

	IF isblind()
		lSched := .T. 
		reproc250(lSched)
		return
	eNDIF 

	cMarca := GetMark()

	oMark := FWMarkBrowse():New()
	oMark:SetAlias("T4K")
	oMark:AddLegend( "T4K_STATUS == '1' "	,"GREEN"	,STR0009  ) //"A Processar" 
	oMark:AddLegend( "T4K_STATUS == '2' " 	,"RED" 		,STR0010 ) //"Processado Com erros"
	oMark:SetFieldMark('T4K_MARK')	
	oMark:SetMark(cMarca)
	oMark:SetDescription(STR0001) //'Apontamentos Pendentes'
	oMark:Activate()

Return NIL


Static Function MenuDef()
	Local aRotina := {}
	
	aAdd(aRotina, {STR0002, 'VIEWDEF.PCPA138', 0, 2, 0, NIL}) //Visualizar
	aAdd(aRotina, {STR0003, 'reproc250', 0, 3, 0, NIL}) 	  //Reprocessa Movimento
	aAdd(aRotina, {STR0011, 'A138EXC', 0, 5, 0, NIL}) 	  //Excluir

Return aRotina

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados 
@author Gustavo Baptista
@since 12/04/2019
/*/
//-------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel    := Nil
	Local oStruT4K  := FWFormStruct(1, 'T4K')

	oModel := MPFormModel():New( 'PCPA138M',/*bPost*/,,/*Commit*/, /*Cancel*/ )
	oModel:SetDescription(STR0001)
	oModel:AddFields('MASTER_T4K',nil,oStruT4K)
	oModel:SetPrimaryKey({"T4K_FILIAL","T4K_SEQ"})

Return oModel

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Estrutura de dados 
@author Gustavo Henrique Baptista
@since 12/04/2019
/*/
//-------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('PCPA138')
	Local oStruT4K := FWFormStruct(2, 'T4K')
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oStruT4K:RemoveField('T4K_MARK')
	oView:AddField( 'VIEW_T4K', oStruT4K, 'MASTER_T4K' )
Return oView

/*/{Protheus.doc} reproc250
//Função de reprocessamento das pendências de apontamento
@author Thiago.Zoppi
@since 10/05/2019
/*/
Function reproc250()

	Local nX := 0
	Local aRotAuto 	:= {}
	Local nOpc   	:= 3 
	Local aRecNo	:= {}
	Local nY 		:= 0
	Local cMark   	:= IIF(lSched,"",oMark:mark())
	Local lRet 		:= .T.
	Local cErro 	:= ""
	Local aErro		:= {}
	Local lErros 	:= .F. 
	Local cOpc      := ""

	Private LMSERROAUTO 	:= .F.
	Private lMsHelpAuto		:= .T.   
	Private lAutoErrNoFile 	:= .T. 
	Default lSched			:=  .F. 
	//Verifica se vei do schedule
	If lSched 
	 // 1 - Processa Todos
	 // 2 - Somente os A Processar
	 // 3 - Reprocessar os apontamentos ja reprocessado e que conitnuam com erros.

		lSched := .T. 
		coPc := IF(EMPTY(MV_PAR01),"", MV_PAR01)
		DbSelectArea("T4K")
		T4K->(DbSetOrder(1))
		T4K->(DbgoTop())
	Else 
		T4K->(DbSetOrder(2))
		If !T4K->(dbSeek(xFilial("T4K")+cMark))
			msginfo(STR0005)  //"Nenhum registro selecionado"
			lRet:= .F.
		Endif
	Endif
	
	If lRet
		
		while !EOF() .AND. T4K->T4K_FILIAL == xFilial("T4K") 
			
			IF lSched 
				IF coPc = 2 // Somente o A processar 
					IF T4K->T4K_STATUS <> "1" // Status A Processar
						Loop 
					endIf
				ElseIF coPc = 3
					IF T4K->T4K_STATUS <> "3" // Status Processado com Erros
						Loop 
					endIf
				EndIF	
			Else
				IF  cMark # T4K->T4K_MARK
					T4K->(dbSkip())
					Loop 
				endIf
			endIf


			IF T4K->T4K_ORIGEM = "MATA250"
				//Transforma de Json para Array
				FWJsonDeserialize(T4K->T4K_STRAUT,aRotAuto) 
				
				nPos := aScan(aRotAuto,{|x| x[1] == "PENDENTE" })
				IF nPos > 0
				   aRotAuto[nPos,2] := "4" // Seta array - para reprocessamento 	 
				EndIf
				nPos := aScan(aRotAuto,{|x| x[1] == "D3_EMISSAO" })
				IF nPos > 0
				   aRotAuto[nPos,2] := dDataBase // Seta data do Apontamento para data Base
				EndIf 
								
				MSExecAuto({|x, y| mata250(x, y)},aRotAuto, nOpc ) 
			
			ELSEIF  T4K->T4K_ORIGEM = "MATA681" .OR. T4K->T4K_ORIGEM = "MATA680" .OR. T4K->T4K_ORIGEM = "ACDA080"
				
				//Transforma de Json para Array
				FWJsonDeserialize(T4K->T4K_STRAUT,aRotAuto)
			
				nPos := aScan(aRotAuto,{|x| x[1] == "PENDENTE" })
				IF nPos > 0
				   aRotAuto[nPos,2] := "4" // Seta array - para reprocessamento 	 
				EndIf
				nPos := aScan(aRotAuto,{|x| x[1] == "H6_DTAPONT" })
				IF nPos > 0
				   aRotAuto[nPos,2] := dDataBase // Seta data do Apontamento para data Base
				EndIf 
				
				IF T4K->T4K_ORIGEM = "MATA681" 
					MSExecAuto({|x| mata681(x)},aRotAuto ) 
				ELSE 	
					MsExecAuto({|x,y|MATA680(x,y)},aRotAuto,3) //inclusão
				EndIf 
				
			EndIf
			
			If lMsErroAuto
				lRet:= .F.
				aErro := GetAutoGRLog()
				For nX := 1 To Len(aErro)
					cErro += aErro[nX] + Chr(13)+Chr(10)
				Next nX
				
				Reclock("T4K",.F.)
					REPLACE T4K_MENSAG WITH cErro
					REPLACE T4K_STATUS WITH "2" // Processado com erros
				T4K->(MsUnlock())
				//Mostraerro()
			Else
				aAdd(aRecNo,T4K->(Recno()))
			EndIf
			
			lMsErroAuto 	:= .F.
			lMsHelpAuto		:= .T.   
			aRotAuto		:= {}
			cErro			:= ""
			T4K->(dbSkip())
		
		enddo
		
		for ny:= 1 to Len(aRecno)
			T4K->(dbSetOrder(1))
			T4K->(dbGoTo(aRecno[ny]))
			Reclock("T4K",.F.)
			T4K->(dbDelete())
			T4K->(MsUnlock())
		next

		IF ! lSched 
			If lRet
				msginfo(STR0006) //"Processamento finalizado."
			Else 
				msginfo(STR0012) //"Existem registro com problemas, verifique no campo mensagens!"
			endIf
		Endif 
			
	endIf

T4K->(dbSetOrder(1))
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A138EXC
Rotina para exclusão dos itens Pendentes
@author  Thiago.Zoppi
@since   03/05/2019
/*/
//-------------------------------------------------------------------
Function A138EXC()
	Local cMark   	:= oMark:mark()
	local lRet		:= .T. 

	T4K->(DbSetOrder(2))
	If !T4K->(dbSeek(xFilial("T4K")+cMark))
		msginfo(STR0005)  //"Nenhum registro selecionado"
		lRet:= .F.
	Endif
	
	If lRet
		While T4K->T4K_FILIAL == xFilial("T4K") .AND. cMark == T4K->T4K_MARK
			Reclock("T4K",.F.)
			T4K->(dbDelete())
			T4K->(MsUnlock())
			T4K->(dbSkip())
		End		
	EndIf
Return

//-------------------------------------------------------
//Função SchedDef
//-------------------------------------------------------
Static Function SchedDef()
Local aParam 	:= {}
Local aOrd 		:= {}
	  aParam 	:= {"P","PCPA138A","T4K",aOrd,nil,}   
Return aParam

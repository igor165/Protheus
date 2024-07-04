#INCLUDE "JURA090.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA090
Configuração de e-mail

@author Juliana Iwayama Velho
@since 05/07/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA090()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NSX" )
oBrowse:SetLocate()
//oBrowse:DisableDetails()
JurSetLeg( oBrowse, "NSX" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Juliana Iwayama Velho
@since 05/07/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA090", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA090", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA090", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA090", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA090", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Configuração de e-mail

@author Juliana Iwayama Velho
@since 05/07/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA090" )
Local oStructMaster := FWFormStruct( 2, "NSX" )
Local oStructDetail := FWFormStruct( 2, "NT8" )
oStructDetail:RemoveField( "NT8_CODCAB" )

JurSetAgrp( 'NSX',, oStructMaster )

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( "JURA090_VIEW", oStructMaster, "NSXMASTER"  )
oView:AddGrid ( "JURA090_GRID", oStructDetail, "NT8DETAIL"  ) 

oView:AddIncrementField( "NT8DETAIL", 'NT8_CODITE')

oView:CreateHorizontalBox( "FORMFIELD", 60 )
oView:CreateHorizontalBox( "FORMGRID" , 40 )

oView:SetOwnerView( "JURA090_VIEW", "FORMFIELD" )
oView:SetOwnerView( "JURA090_GRID", "FORMGRID" )

oView:SetDescription( STR0007 ) 
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Configuração de e-mail

@author Juliana Iwayama Velho
@since 05/07/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructMaster    := FWFormStruct( 1, "NSX" )
Local oStructDetail    := FWFormStruct( 1, "NT8" )
oStructDetail:RemoveField( "NT8_CODCAB" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA090", /*Pre-Validacao*/, {|oX| JURA090TOK(oX)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Configuração de e-mail"

oModel:AddFields( "NSXMASTER", NIL, oStructMaster, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:GetModel( "NSXMASTER" ):SetDescription( STR0009 ) // "Dados de Configuração de e-mail"

oModel:AddGrid( "NT8DETAIL", "NSXMASTER" /*cOwner*/, oStructDetail, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

oModel:SetRelation( "NT8DETAIL", { { "NT8_FILIAL", "XFILIAL('NT8')" }, { "NT8_CODCAB", "NSX_COD" } }, NT8->( IndexKey( 1 ) ) )
oModel:GetModel( "NT8DETAIL" ):SetDescription( STR0010 ) 

JurSetRules( oModel, 'NSXMASTER',, 'NSX' )
JurSetRules( oModel, 'NT8DETAIL',, 'NT8' )

Return oModel                    

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA090TOK
Valida informações ao salvar.

@param 	oModel  	Model a ser verificado	
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 05/07/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA090TOK(oModel)
Local lRet := .T.
Local nOpc := oModel:GetOperation()                

If nOpc == 3 .Or. nOpc == 4      

	lRet := JA090VQRY(oModel:GetValue('NSXMASTER','NSX_QUERY'))
	
	If lRet
		lRet := JA090VQRY(oModel:GetValue('NSXMASTER','NSX_EMAIL'))	
	EndIf   
	
	If lRet .And. cVersao = '10' 
		lRet := JA090VTmp(oModel:GetValue('NSXMASTER','NSX_HRINI'),oModel:GetValue('NSXMASTER','NSX_HRFIM'),;
						  oModel:GetValue('NSXMASTER','NSX_INTERV'))	
	EndIf

	If lRet
		lRet := JA090VNT8(oModel)
	EndIf
EndIf

If lRet .And. nOpc == 3 
	Begin Transaction
		MsgRun(STR0013,STR0014,{||CursorWait(),lRet:= JA090Agend(nOpc,oModel),CursorArrow()})//"Gravando Agendamento"#"Processando..."				
		If !lRet
			DisarmTransaction()
			While __lSX8
				RollBackSX8()
			EndDo
			JurMsgErro(STR0030)//"Não foi possivel efetuar o agendamento do e-mail no Schedule. Favor verificar !"
		EndIF
	End Transaction
	
				
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA090Agend
Grava os dados na rotina de schedule

@param 	nOpc  	Código da operação
@param 	oModel  Model a ser verificado

@author Juliana Iwayama Velho
@since 05/07/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA090Agend(nOpc,oModel)
Local aParams := {}  
Local cAgend  := ''
Local lRet := .T.

if cVersao = '10'

	oWF := TWFObj()
	oSXMTable := oWF:oScheduler:oSXMTable
	
	If !oSXMTable:lIsOpen()
		If !oSXMTable:lOpen()
			oWF:Free()
			return
		Endif
	Endif
	
	If nOpc > 3
		DbSelectArea("SXM")
		Do While SXM->(!Eof()) .And. !lAchou
			If UPPER(Alltrim(SXM->XM_CODIGO))=="JUR"+oModel:GetValue('NSXMASTER','NSX_COD')
				RecLock("SXM",.F.)
				DbDelete()
				SXM->(MsUnlock())
				lAchou:=.T.
			Endif
			SXM->(DbSkip())
		End
	EndIf 
	
	If nOpc==3 .Or. nOpc==4 .Or. !lAchou
		RecLock("SXM",.T.)
		SXM->XM_CODIGO:="JUR"+oModel:GetValue('NSXMASTER','NSX_COD')
		SXM->XM_NOME  :="JUR"+oModel:GetValue('NSXMASTER','NSX_COD')
		SXM->XM_DESCR :=oModel:GetValue('NSXMASTER','NSX_ASSUNT')
		SXM->XM_TIPO  :=1
		SXM->XM_DTINI :=Date()
		SXM->XM_HRINI :=oModel:GetValue('NSXMASTER','NSX_HRINI')
		SXM->XM_DTFIM :=YEARSUM(Date(),10)
		SXM->XM_HRFIM :=oModel:GetValue('NSXMASTER','NSX_HRFIM')
		SXM->XM_INTERV:=oModel:GetValue('NSXMASTER','NSX_INTERV')
		SXM->XM_AMBIENT:=GETENVSERVER()//Retorna o ambiente
		SXM->XM_ACAO   :="JURA091({'"+oModel:GetValue('NSXMASTER','NSX_COD')+"','"+cEmpAnt+"','"+cFilAnt+"'}) "
		SXM->XM_ATIVO  :=Iif(oModel:GetValue('NSXMASTER','NSX_ATIVO'),"T","F")
		SXM->XM_TIMEOUT:="F"
		SXM->XM_NUMTENT:=0
		SXM->XM_TENTEXE:=0
		SXM->(MsUnlock())
	Endif 

	oSXMTable:_First()
	oSXMTable:lClose() 

Else

	if nOpc == 3 
	                                                                                           
		aAdd( aParams, { oModel:GetValue('NSXMASTER','NSX_COD'), cEmpAnt, cFilAnt })	 
		cAgend := FWAddSchedule( 'JURA091', aParams)
		oModel:SetValue('NSXMASTER','NSX_AGEND', cAgend)
		
		if Empty(cAgend)
			lRet := .F.	
		EndIf
  Elseif nOpc == 4
  
		FWDelSchedule( oModel:GetValue('NSXMASTER','NSX_AGEND') ) 
		aAdd( aParams, { oModel:GetValue('NSXMASTER','NSX_COD'), cEmpAnt, cFilAnt })	 
	  cAgend := FWAddSchedule( 'JURA091', aParams)
	  oModel:SetValue('NSXMASTER','NSX_AGEND', cAgend)	  
    	
    	if Empty(cAgend)
			lRet := .F.	
		EndIf
		
  Elseif nOpc == 5
  
	  FWDelSchedule( oModel:GetValue('NSXMASTER','NSX_AGEND') )                
	  
	Endif  
	
Endif	
  
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA090VNT8
Valida os campos do grid

@param 	oModel  Model a ser verificado

@Return lRet	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 05/07/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA090VNT8(oModel)
Local lRet		:=.T.
Local oModelNT8 := oModel:GetModel('NT8DETAIL')
Local nCt       := 0

For nCt := 1 To oModelNT8:GetQtdLine()
	
	oModelNT8:GoLine( nCt )        
	
	If !oModelNT8:IsDeleted()
		If !Empty(oModelNT8:GetValue('NT8_CAMPO'))
			If Alltrim(UPPER(oModelNT8:GetValue('NT8_CAMPO')))$STR0015//"SELECT/DISTINCT/FROM/INNER JOIN/LEFT JOIN/RIGHT JOIN/WHERE/D_E_L_E_T_"
				JurMsgErro(STR0016,STR0018)//"Campo inexistente"#"Informe um campo valido"		
				lRet:=.F.
			ElseIf !Alltrim(UPPER(oModelNT8:GetValue('NT8_CAMPO')))$UPPER(oModel:GetValue('NSXMASTER','NSX_QUERY')) 
				JurMsgErro(STR0017,STR0018)//"O campo nao consta na Sintaxe"#"Informe um campo valido"	
				lRet:=.F.
			Endif	
		EndIf
	EndIf

Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA090VQRY
Valida sintaxe da consulta

@param 	cQuery	Consulta a ser validada

@Return lOk	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 05/07/10
@version 1.0
/*/
//-------------------------------------------------------------------                                  
Static Function JA090VQRY(cQuery)
Local aArea    := GetArea()
Local lOk      := .T.
Local bOldError 

If At('*',cQuery) > 0  .Or. At('*.',cQuery) > 0
	JurMsgErro(STR0023)//"* nao permitido na Sintaxe. Deve-se informar os campos"
	lOk:=.F.
ElseIf At('FROM',Upper(cQuery)) == 0
	JurMsgErro(STR0024)//"A condicao 'FROM' deve ser informado na Sintaxe"
	lOk:=.F.
ElseIf At(CEMPANT+'0',cQuery) == 0
	JurMsgErro(STR0025)//"A Sintaxe deve utilizar tabelas da Empresa corrente"
	lOk:=.F.	
ElseIf At('WHERE',Upper(cQuery)) == 0
	JurMsgErro(STR0026)//"A condicao 'WHERE' deve ser informado na Sintaxe"
	lOk:=.F.	
ElseIf At('D_E_L_E_T_',Upper(cQuery)) == 0 
	JurMsgErro(STR0027)//"Na Sintaxe deve utilizar 'D_E_L_E_T_' para que desconsidere os registros deletados"
	lOk:=.F.	
ElseIf !Empty(cQuery) 
	 
	boldError := Errorblock( {|e| lOk := .f. , ErroQry(e) } )
	 
	BEGIN SEQUENCE
	cQuery  := ChangeQuery(cQuery)
	DbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery), 'QRYTMP', .T., .T.)
	END SEQUENCE
		 
	errorblock(boldError)
	 
	If Select("QRYTMP") > 0 
		QRYTMP->(DbCloseArea())
	Endif
	 
	If !lOk
   		JurMsgErro( STR0011 )
   		AutoGrLog(STR0012)
	   	AutoGrLog(tcsqlerror())       
	   	MostraErro()
	Endif
Endif	 

RestArea(aArea)

Return lOk                                           

Static Function ErroQry(e)
conout("ErroQry -------------------------- ")
conout(e:description)
BREAK

//-------------------------------------------------------------------
/*/{Protheus.doc} JA090VTmp
Valida os campos de hora e intervalo

@param 	cHIni	Hora inicial
@param 	cHFim	Hora final
@param 	cInt	Intervalo

@Return lRet	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 06/07/10
@version 1.0
/*/
//-------------------------------------------------------------------                                  
Static Function JA090VTmp(cHIni,cHFim,cInt)
Local lRet:=.T.
Local nSecHrIni:=0, nSecHrFim:=0, nSecHrInt:=0

If !Empty(cHIni)
	If cHIni=="24:00"
		cHIni:="00:00"
	Endif	
	nSecHrIni:=TimeToSecs(cHIni)
Endif            
If !Empty(cHFim)
	If cHFim=="00:00"
		cHFim:="24:00"
	Endif	
	nSecHrFim:=TimeToSecs(cHFim)
Endif            
If !Empty(cInt)         
	nSecHrInt:=0
	If val(Substr(cInt,1,2))>0
		nSecHrInt+=TimeToSecs(Substr(cInt,1,2)+":00")
	Endif
	If val(Substr(cInt,4,2))>0
		nSecHrInt+=61*Val(Substr(cInt,4,2))
	Endif	
Endif  

If nSecHrIni == 0 .Or. nSecHrFim == 0  .Or. nSecHrInt == 0
	JurMsgErro(STR0029)//"Campos obrigatórios"
	lRet:=.F.
EndIf

If lRet
	//86400 segundo equivale a 24 horas
	If nSecHrIni>87840
		JurMsgErro(STR0019)//"Informe um horario inicial valido"
		lRet:=.F.
	ElseIf nSecHrFim>87840
		JurMsgErro(STR0020)//"Informe um horario Final valido"
		lRet:=.F.
	ElseIf nSecHrIni>nSecHrFim
		JurMsgErro(STR0021)//"Horas Inicio maior que as Horas Fim"
		lRet:=.F.
	ElseIf nSecHrIni+nSecHrInt>nSecHrFim
		JurMsgErro(STR0022)//"A soma da Horas Inicio com o Intervalo sera maior que as Horas Fim"
		lRet:=.F.
	ElseIf nSecHrIni > nSecHrFim
		JurMsgErro(STR0028)//"A soma da Horas Inicio é maior do que a Hora Final"
		lRet:=.F.
	Endif
Endif	

Return lRet

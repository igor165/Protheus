#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA580.CH"

#DEFINE DINAMICO "1"
#DEFINE FIXO	 "2"
#DEFINE LOGICO	 "3"

#DEFINE CARACTER "1"
#DEFINE NUMERIC	 "2"
#DEFINE DATE	 "3"

Static cRoot	

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580
Cadastro de Agrupador de Registros.

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580(uAOLMaster,uA08Detail,nOperation)

Local oBrowse	:= Nil
Local oModel  	:= Nil
Local aAutoRot	:= {}    

Default uAOLMaster	:= {}
Default uA08Detail	:= {}
Default nOperation	:= MODEL_OPERATION_INSERT

If Empty( uAOLMaster )  
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("AOL")
	oBrowse:SetDescription(STR0001) //"Agrupador de Registros"
	oBrowse:DisableReport()
	oBrowse:DisableDetails()     
	oBrowse:Activate()
Else
	//---------------------------------------F
	// Rotina Automatica através do MVC  
	//---------------------------------------
	oModel := ModelDef()
	aAdd(aAutoRot,{"AOLMASTER",uAOLMaster})
	aAdd(aAutoRot,{"A08DETAIL",uA08Detail})
	
	FwMvcRotAuto(oModel,"AOL",nOperation,aAutoRot,/*lSeek*/,.T.) 
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta estrutura de funções do Browse

@return	aRotina, array, Array de Rotinas

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.CRMA580" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.CRMA580" OPERATION 3 ACCESS 0 //"Incluir" 
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CRMA580" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.CRMA580" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0012 ACTION "CRMA580FAvl" 	  OPERATION 6 ACCESS 0 //"Avaliação do Agrupador Lógico"
ADD OPTION aRotina TITLE STR0006 ACTION "CRMA580NAgru" 	  OPERATION 4 ACCESS 0 //"Níveis do Agrupador"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Monta modelo de dados do Agrupador de Registros

@return	oModel, objeto, Modelo de Dados

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oStructAOL	:= FWFormStruct(1,"AOL",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructA08	:= FWFormStruct(1,"A08",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel		:= Nil

//-------------------------------------------------------------------
// Define os gatilhos.  
//-------------------------------------------------------------------
oStructAOL:AddTrigger( "AOL_LOGTAM", "AOL_LOGPIC",, {| oModel, cField, cValue | CRM580Trigger( oModel, cField, cValue ) } )
oStructAOL:AddTrigger( "AOL_LOGDEC", "AOL_LOGPIC",, {| oModel, cField, cValue | CRM580Trigger( oModel, cField, cValue ) } )

oModel := MPFormModel():New("CRMA580",/*bPreValidacao*/,{|oModel| CRM580Pos( oModel )},/*bCommitMdl*/,/*bCancel*/)

oModel:AddFields("AOLMASTER",/*cOwner*/,oStructAOL,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:AddGrid("A08DETAIL","AOLMASTER",oStructA08,/*bLinPre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVldGrid*/,/*bLoad*/)

oModel:SetRelation("A08DETAIL",{{"A08_FILIAL","xFilial('AOL')"},{"A08_CODAGR","AOL_CODAGR"}},A08->(IndexKey(1)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
//³ Validação de linha duplicada. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:GetModel("A08DETAIL"):SetUniqueLine({"A08_ENTDOM"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
//³ Regra para Pesquisa será Opcional. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:GetModel("A08DETAIL"):SetOptional(.T.)

oModel:SetDescription(STR0001)//"Agrupador de Registros"
 
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Monta interface do Agrupador de Registros

@return	oView, objeto, Interface do Agrupador de Registros

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef() 

Local oStructAOL	:= FWFormStruct(2,"AOL",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructA08	:= FWFormStruct(2,"A08",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel   		:= FWLoadModel("CRMA580")
Local oView	 		:= Nil

//----------------------------------------------
// Remove visualização de campos da tabela A08
//----------------------------------------------
oStructA08:RemoveField("A08_CODAGR")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_AOL",oStructAOL,"AOLMASTER")
oView:AddGrid("VIEW_A08",oStructA08,"A08DETAIL")

//Painel Superior 
oView:CreateHorizontalBox("SUPERIOR",50)

//Painel Inferior
oView:CreateHorizontalBox("INFERIOR",50)

oView:EnableTitleView("VIEW_A08",STR0023) //"Regras de Pesquisa"

oView:SetOwnerView("VIEW_AOL","SUPERIOR") 
oView:SetOwnerView("VIEW_A08","INFERIOR") 

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580NAgru
Verifica o tipo do agrupador e executa o modelo referente.

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580NAgru()

Local aArea		:= GetArea()
Local cModelo	:= ""
Local aButtons	:= {}

If AOL->AOL_MSBLQL <> "1"
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
				 {.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil}			,;
				 {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	
	// Abre os Alias referente aos modelos
	DbSelectArea("AOM")
	DbSelectArea("AON")
	
	AOM->(DbSetOrder(1))
	AON->(DbSetOrder(1))
	
	//Agrupador Dinamico
	If AOL->AOL_TIPO == "1"
		cModelo := "CRMA580A"
	//Agrupador Fixo
	ElseIf AOL->AOL_TIPO == "2"
		cModelo := "CRMA580B"
	//Agrupador Logico
	Else
		cModelo := "CRMA580F"
	EndIf
	
	FWExecView(Upper(STR0004),cModelo,MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOK*/,/*bOk*/,/*nPercReducao*/,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,/*oModelAct*/) //"Alterar"
	
Else
	MsgAlert(STR0007) //"Registro Bloqueado!"
EndIf

RestArea(aArea)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580VldMdl(oModel)

Valida o Model do Agrupador de Registros.

@sample		CRMA580VldMdl(oModel)

@param		ExpO1 - MPFormModel do Agrupador de Registros
@return		ExpL - Verdadeiro / Falso

@author		Anderson Silva
@since		21/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580VldMdl(oModel)

Local lRetorno	:= .T.
Local aError	:= {}

If !oModel:VldData()
	lRetorno := .F.
	aError := oModel:GetErrorMessage()
	Help("",1,"CRMA580VLD",,aError[6],1)
EndIf

Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580MXml
Monta o XML com os filtros relacionado ao nivel do agrupador.

@param	aExpressions, array, Array com filtros criado pelo FwFilterEdit
@return	cXml, caracter, XML com todas as expressões de filtros relacionado ao nivel do agrupador.

@author		Jonatas Martins
@since		24/04/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580MXml(aExpressions,aRelSel)

Local cXML	:= ""
Local nI	:= 0
Local nX	:= 0
 
cXml +=     '<Filters>'
For nI := 1 To Len(aExpressions)
	cXml +=           '<Condition>'
	cXml +=                 '<Name>'	 + '<![CDATA[' + CRM580ToChar(aExpressions[nI][4][1]) + ']]>' + '</Name>'
	cXml +=                 '<ExpADVPL>' + '<![CDATA[' + CRM580ToChar(aExpressions[nI][4][2]) + ']]>' + '</ExpADVPL>'
	cXml +=                 '<ExpSQL>'	 + '<![CDATA[' + CRM580ToChar(aExpressions[nI][4][3]) + ']]>' + '</ExpSQL>'
	cXml +=                 '<Parser>'
	For nX := 1 To Len(aExpressions[nI][4][4])
		cXml +=                 		'<Item>'
		cXml += 							'<Name>' 	 + '<![CDATA[' + CRM580ToChar(aExpressions[nI][4][4][nX][1]) +']]>' + '</Name>'
		cXml += 							'<Type>'	 + '<![CDATA[' + CRM580ToChar(aExpressions[nI][4][4][nX][2]) +']]>' + '</Type>'
		cXml += 							'<Literal>' + '<![CDATA[' + CRM580ToChar(aExpressions[nI][4][4][nX][3]) +']]>' + '</Literal>'
		cXml += 							'<ExpADVPL>' + '<![CDATA[' + CRM580ToChar(aExpressions[nI][4][4][nX][4]) +']]>' + '</ExpADVPL>'
		cXml += 							'<ExpSQL>'	 + '<![CDATA[' + CRM580ToChar(aExpressions[nI][4][4][nX][5]) +']]>' + '</ExpSQL>'
		cXml +=                 		'</Item>'
	Next nX
	cXml +=                 	'</Parser>'
	cXml +=                 '<NoCheck>'	+ CRM580ToChar(aExpressions[nI][4][5])	+  '</NoCheck>'
	cXml +=                 '<Select>'		+ CRM580ToChar(aExpressions[nI][4][6])	+ 	'</Select>'
	cXml +=                 '<FilterAsk>'	+ CRM580ToChar(aExpressions[nI][4][7])	+ 	'</FilterAsk>'
	cXml +=                 '<Alias>'		+ CRM580ToChar(aExpressions[nI][4][8])	+ 	'</Alias>'
	cXml +=                 '<Id>'			+ CRM580ToChar(aExpressions[nI][4][9])	+ 	'</Id>'
	cXml +=                 '<FilFunct>'	+ CRM580ToChar(aExpressions[nI][4][10]) +	'</FilFunct>'
	cXml +=                 '<RelDomain>'	+ '<![CDATA[' + CRM580ToChar(aExpressions[nI][5])+ ']]>' + '</RelDomain>'
	cXml +=                 '<RelCTDomain>'+ '<![CDATA[' + CRM580ToChar(aExpressions[nI][6])+ ']]>' + '</RelCTDomain>'	
	cXml +=           '</Condition>'
Next nI
cXml +=     '</Filters>'

Return(cXml)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580ToChar
Converte qualquer valor em string para adicionar nas TAGs XML.

@param	uValor, indefinido, Valor a ser convertido
@return	cChar, caracter, Valor convertido em caracter.

@author		Jonatas Martins
@since		24/04/2015
@version	12
/*/
//------------------------------------------------------------------------------

Static Function CRM580ToChar(uValor)

Local cChar := ""

If ValType(uValor) <> "C"
	cChar := cValToChar(uValor)
Else
	cChar := uValor
EndIf

cChar := AllTrim(NoAcento(AnsiToOem(cChar)))

Return(cChar)  

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580XTA
Converte as expressões de filtro da FWFilterEdit de XML para array. 

@param cXML, caracter, Expressão retornada pelo FWFilterEdit. 
@return aExpression, array, Expressão de filtro em formato de array. 

@author	 Anderson Silva
@author	 Valdiney V GOMES
@version P12
@since	 01/10/2015   
/*/
//-------------------------------------------------------------------
Function CRMA580XTA( cXml )
	Local oXML 			:= TXMLManager():New()
	Local aCondition	:= {}
	Local aParser		:= {}
	Local aFilter		:= {}
	Local aAttribute	:= {}
	Local aExpression	:= {}
	Local nFilter		:= 0
	Local nConditon		:= 0
	 
	Default cXml		:= ""

	//-------------------------------------------------------------------
	// Parseia o XML.  
	//-------------------------------------------------------------------	
	If ( ! Empty( cXML ) .And. ( oXML:Read( cXML ) ) )
		//-------------------------------------------------------------------
		// Recupera as condições do filtro.  
		//-------------------------------------------------------------------			
		aCondition := oXML:XPathGetChildArray("/Filters")
	
		For nConditon := 1 To Len( aCondition )
			aParser	:= {}
			
			//-------------------------------------------------------------------
			// Recupera os parsers do filtro.  
			//-------------------------------------------------------------------
			aFilter := oXML:XPathGetChildArray( aCondition[nConditon][2] + "/Parser")		

			For nFilter := 1 To Len( aFilter )
				aAttribute := {}
				
				//-------------------------------------------------------------------
				// Recupera os atributos dos parsers.  
				//-------------------------------------------------------------------	
				aAdd(aAttribute, oXML:XPathGetNodeValue( aFilter[nFilter][2] +"/Name" ) ) 	
				aAdd(aAttribute, oXML:XPathGetNodeValue( aFilter[nFilter][2] +"/Type" ) ) 
				aAdd(aAttribute, oXML:XPathGetNodeValue( aFilter[nFilter][2] +"/Literal" ) )
				aAdd(aAttribute, oXML:XPathGetNodeValue( aFilter[nFilter][2] +"/ExpADVPL" ) ) 
				aAdd(aAttribute, oXML:XPathGetNodeValue( aFilter[nFilter][2] +"/ExpSQL" ) ) 
			
				aAdd( aParser, aAttribute )					
			Next nFilter

			aAttribute := {}	
				
			//-------------------------------------------------------------------
			// Recupera os atributos do filtro.  
			//-------------------------------------------------------------------	
			aAdd( aAttribute, oXML:XPathGetNodeValue( aCondition[nConditon][2] +"/Name" ) )
			aAdd( aAttribute, oXML:XPathGetNodeValue( aCondition[nConditon][2] +"/ExpADVPL" ) )			
			aAdd( aAttribute, oXML:XPathGetNodeValue( aCondition[nConditon][2] +"/ExpSQL" ) )
			aAdd( aAttribute, aParser )
			aAdd( aAttribute, &( oXML:XPathGetNodeValue( aCondition[nConditon][2] +"/NoCheck" ) ) )
			aAdd( aAttribute, &( oXML:XPathGetNodeValue( aCondition[nConditon][2] +"/Select" ) ) )
			aAdd( aAttribute, &( oXML:XPathGetNodeValue( aCondition[nConditon][2] +"/FilterAsk" ) ) )
			aAdd( aAttribute, oXML:XPathGetNodeValue( aCondition[nConditon][2] +"/Alias" ) )
			aAdd( aAttribute, oXML:XPathGetNodeValue( aCondition[nConditon][2] +"/Id" ) )
			aAdd( aAttribute, &( oXML:XPathGetNodeValue( aCondition[nConditon][2] +"/FilFunct" ) ) )
			aAdd( aAttribute, oXML:XPathGetNodeValue( aCondition[nConditon][2] +"/RelDomain" ) )
			aAdd( aAttribute, oXML:XPathGetNodeValue( aCondition[nConditon][2] +"/RelCTDomain" ) )
		
			aAdd( aExpression, aAttribute )
		Next nConditon 
	EndIf 
	
	//-------------------------------------------------------------------
	// Recupera os atributos do filtro.  
	//-------------------------------------------------------------------	
	FreeObj( oXML )
Return aExpression

//------------------------------------------------------------
/*/{Protheus.doc} CRMA580CpoEnt
Efetua validacao do campo AOL_ENTIDA

@param	cAlias, caracter, Valor de memória do campo AOL_ENTIDA
@return	lRet, lógico, Retona .T. se o registro existir na tabela AO2 e estiver ativo para agrupar

@author		Jonatas Martins
@since		15/04/2015
@version	12
@obs		Funcao executada no VALID do dicionario
/*/
//------------------------------------------------------------
Function CRMA580CpoEnt(cAlias)

Local aArea		:= GetArea()
Local aAreaAO3	:= AO3->(GetArea())
Local lRet 		:= .T.

Default cAlias := ""

DbSelectArea("AO2")
AO2->(DbSetOrder(1))
	
If !AO2->(DbSeek(xFilial("AO2")+cAlias)) .Or. AO2->AO2_AGRREG <> "1" 
	lRet := .F.
	Help("",1,"CRMA580VLD",,STR0008,1) // Entidade não encontrada ou inativa para agrupar 
EndIf

RestArea(aAreaAO3)
RestArea(aArea)
	
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580X3P
Consulta especifica montar a chave de pesquisa.

@return	lRetorno. lógico, Verdadeiro / Falso

@author		Anderson Silva
@since		14/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580X3P()
   
Local aAreaSX3  := SX3->(GetArea())
Local aArea   	:= GetArea()
Local cReadVar	:= ReadVar()
Local cCpoVar	:= SubStr(cReadVar,4,Len(cReadVar))
Local cEntidad  := ""
Local lRetorno 	:= .F.
Local aCampos	:= {}
Local oDlg      := Nil
Local oColEnt   := Nil
Local oBrwMark  := Nil
Local oPanel    := Nil
Local oFwLayer	:= Nil
Local oLineOne	:= Nil
Local oLineTwo 	:= Nil
Local oTGet		:= Nil
Local cTGet		:= ""
Local cTitulo 	:= ""
	
Static _cChvPesq := ""

If Upper(cCpoVar)=="A08_CONTEU"
	cEntidad := FwFldGet("A08_ENTDOM")
	cTitulo  := STR0024 // "Campos da Entidade de Dominio"
Else
	cEntidad := FwFldGet("AOL_ENTIDA")
	cTitulo  := STR0025 // "Campos da Entidade do Agrupador"
EndIf

DbSelectArea("SX3")
SX3->(DbSetOrder(1)) 

If !Empty(cEntidad)
	If SX3->(DbSeek(cEntidad))
	   
	 	Do While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == cEntidad
	 		If	X3Usado(SX3->X3_CAMPO) .AND. SX3->X3_CONTEXT <> "V" 
				AAdd( aCampos,{.F.,SX3->X3_CAMPO,X3Titulo()} )
			EndIf	
	 		SX3->( DbSkip())
		EndDo 
       
    	oDlg := FWDialogModal():New()
		oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela 
		oDlg:SetTitle(cTitulo)//"Campo de Retorno" 
		oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
		oDlg:SetSize(200,300) //cria a tela maximizada (chamar sempre antes do CreateDialog)
		oDlg:EnableFormBar(.T.) 
	
		oDlg:CreateDialog() //cria a janela (cria os paineis)
		oPanel := oDlg:GetPanelMain()
		oDlg:CreateFormBar()//cria barra de botoes
       	oDlg:AddYesNoButton()	

  		oFwLayer := FwLayer():New()
		oFwLayer:init(oPanel,.F.) 
		oFWLayer:AddLine("LINEONE",10, .F.)
		oFWLayer:AddLine("LINETWO",90, .F.)
		oLineOne := oFwLayer:GetLinePanel("LINEONE")
		oLineTwo := oFwLayer:GetLinePanel("LINETWO")
	
		oTGet := TGet():New( 03,05,{||cTGet},oLineOne,0290,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet,,,, )
			
       	DEFINE FWBROWSE oBrwMark  DATA ARRAY ARRAY aCampos LINE BEGIN 1 OF oLineTwo  
        	ADD MARKCOLUMN oColEnt DATA {|| IIF(aCampos[oBrwMark:At()][1],"LBOK","LBNO") } DOUBLECLICK {||aCampos[oBrwMark:At()][1] := !aCampos[oBrwMark:At()][1] ,CRM580MChv(oBrwMark,aCampos,oTGet,@cTGet)} OF oBrwMark 
			ADD COLUMN oColEnt DATA &("{ || aCampos[oBrwMark:At()][2] }") TITLE STR0017 TYPE "C" SIZE 11 OF oBrwMark		//"Campo"
			ADD COLUMN oColEnt DATA &("{ || aCampos[oBrwMark:At()][3] }") TITLE STR0018 TYPE "C" SIZE 30 OF oBrwMark	  	//"Descrição"
			oBrwMark:DisableReports()
		ACTIVATE FWBROWSE oBrwMark	

		oDlg:Activate() 
       
       If oDlg:GetButtonSelected() > 0
       	  _cChvPesq := cTGet
       	  lRetorno := .T.
       Else
       	  lRetorno := .F.	
       EndIf
        	
	EndIf
Else
	MsgAlert(STR0028) //"Problemas para identificar a entidade do agrupador."
	lRetorno := .F.
EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580MChv()
                                   
Rotina para gerar o a chave de Origem para a mesclagem

@param	  	oBrwMark = objeto do Browse que será manipulado
		  	aCampos	 = Array contendo os dados dos registros que o Browse utiliza
		  	oTGet 	 = Objeto do campo Get que será manipulado
		 	cTGet 	 = Variavel onde será atribuido o Codigo Gerado

@return	Nenhum

@author		Anderson Silva
@since		14/05/2014
@version	12.0                
/*/
//-----------------------------------------------------------------------------
Static Function CRM580MChv(oBrwMark,aCampos,oTGet,cTGet)

Local   cMais    := "+"

Default aCampos  := {}
Default oTGet    := Nil
Default oBrwMark := Nil

cTGet := Upper(cTGet)

If ValType(oBrwMark) == "O" .AND. !Empty(aCampos) 
	If aCampos[oBrwMark:At()][1] == .T.
		If At(aCampos[oBrwMark:At()][2],cTGet) <= 0 
		   If !Empty(cTGet)
		   		cTGet += cMais + AllTrim(aCampos[oBrwMark:At()][2])
		   Else
		   		cTGet += AllTrim(aCampos[oBrwMark:At()][2])
		   EndIf
		EndIf
	ElseIf aCampos[oBrwMark:At()][1] == .F.	
	 	If At(cMais+aCampos[oBrwMark:At()][2],cTGet) > 0
	 		cTGet := StrTran(cTGet,cMais+Upper(aCampos[oBrwMark:At()][2]),"",,1)
	 	ElseIf  At(aCampos[oBrwMark:At()][2]+cMais,cTGet) > 0
	 		cTGet := StrTran(cTGet,Upper(aCampos[oBrwMark:At()][2]+cMais),"",,1)
	 	ElseIf At(aCampos[oBrwMark:At()][2],cTGet) > 0
	 	 	cTGet := StrTran(cTGet,Upper(aCampos[oBrwMark:At()][2]),"",,1)
	 	EndIf 	
	EndIf		
	If ValType(oTGet) == "O"
		oTGet:CtrlRefresh() 
	EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580RetP                                
Retorna a chave de pesquisa montada pela consulta especifica.

@return	lRetorno, lógico, Verdadeiro / Falso

@author		Anderson Silva
@since		14/05/2014
@version	12.0                
/*/
//-----------------------------------------------------------------------------
Function CRMA580RetP()
Return(_cChvPesq)   
  
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580VDom()
                                   
Valida a entidade de dominio.

@sample		CRMA580VDom()

@param	  	cAlias - Entidade de Origem

@return		lRetorno - Verdadeiro / Falso

@author		Anderson Silva
@since		14/05/2014
@version	12.0                
/*/ 
//-----------------------------------------------------------------------------
Function CRMA580VDom()
Local lRetorno 	:= .T.
Local cEntDom	:= FwFldGet("A08_ENTDOM")
Local cEntAgr	:= FwFldGet("AOL_ENTIDA")

If CRMXVldAli(cEntDom)
	If cEntDom == cEntAgr
		Help("",1,"HELP","CRMA580VLD",STR0021+Chr(10)+STR0022,1) //"Entidade de origem é a mesma do agrupador."##"Selecione um outra entidade para composição da pesquisa"
		lRetorno := .F.	
	EndIf
Else
	lRetorno := .F.
EndIf

Return(lRetorno)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM580FAOL                               
Função que filtra os agrupadores quando existe subterritório

@return	lRetorno, lógico, Verdadeiro / Falso

@author	Anderson Silva
@since		25/05/2015
@version	12         
@Obs		Função utilizada na expressão da consulta padrão AOLESP
/*/ 
//-----------------------------------------------------------------------------
Function CRM580FAOL()

Local oMdlActive	:= FwModelActive()
Local cF3			:= "AOL"
Local lRetorno	:= .F.
Local aDadSX2		:= {}

Static _F3CodAOL := ""

If oMdlActive <> Nil

	If oMdlActive:GetId() == "CRMA640"
		If !Empty(FwFldGet("AOY_SUBTER"))
			cF3 := "AOZ"	
		EndIf
	EndIf

EndIf

lRetorno := Conpad1(,,,cF3)
	
If lRetorno
	_F3CodAOL	:= (cF3)->&(cF3 + "_CODAGR")
EndIf
	
Return(lRetorno)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM580RAOL                              
Função para retorno da consulta específica

@return	_F3CodAOL, caracter, Variável com valor de retorno da consulta

@author		Anderson Silva
@since		25/05/2015
@version	12         
@Obs		Função utilizada no retorno da consulta padrão AOLESP
/*/ 
//-----------------------------------------------------------------------------
Function CRM580RAOL()
Return(_F3CodAOL)

//--------------------------------------------------------------------
/*/{Protheus.doc} CRM580Pos                      
Função de pós validação do modelo de dados

@param	oModel, objeto, Objeto com a estrutura do modelo de dados do formulário 
@return	lRet, lógico, Retorno da validação

@author		Jonatas Martins
@since		15/06/2015 
/*/
//-------------------------------------------------------------------- 
Static Function CRM580Pos( oModel )
	Local lRetorno := CRM580ALVld( oModel )
Return lRetorno

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580Trigger
Trigger dos campos AOL_LOGTAM e AOL_LOGDEC. 

@param oModel, objeto, Modelo de dados. 
@param cField, caracter, Campo a ser pesquisado. 
@param cValue, caracter, Conteúdo do campo a ser pesquisado. 
@return cReturn, caracter, Descrição do campo. 

@author     Valdiney V GOMES
@since      17/06/2015
/*/
//------------------------------------------------------------------------------
Static Function CRM580Trigger( oModel, cField, xValue )
	Local cReturn 		:= ""
	Local cType 		:= oModel:GetValue("AOL_LOGTIP")

	Default oModel		:= Nil 
	Default cField		:= ""
	Default xValue		:= ""

	If ( cField == "AOL_LOGTAM" )	
		//-------------------------------------------------------------------
		// Define a picture para campos caracter. 
		//-------------------------------------------------------------------	
		If ( cType == "1" )
			cReturn := "@!"
		//-------------------------------------------------------------------
		// Define a picture para campos numéricos sem decimal. 
		//-------------------------------------------------------------------	
		ElseIf( cType == "2" )
			cReturn := FwSuggestP( xValue, oModel:GetValue("AOL_LOGDEC") ) 
		EndIf 
	ElseIf ( cField == "AOL_LOGDEC" )
		//-------------------------------------------------------------------
		// Define a picture para campos numéricos com decimal. 
		//-------------------------------------------------------------------
		If ( cType == "2" )
			cReturn := FwSuggestP( oModel:GetValue("AOL_LOGTAM"), xValue ) 
		EndIf
	EndIf 
Return cReturn   

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580Proxy
Compatibiliza o parâmetro xPool para nova interface da função CRMA580Group
de forma que seja possível informar tanto o array de retorno da função CRMA580E
quanto o ID do agrupador diretamente. 

@param xPool, indefinido, Código do agrupador ou retorno da função CRMA580E. 
@param aLevel, array, Níveis do agrupador.
@return cPool, caracter, Código do agrupador.

@author  Valdiney V GOMES
@version P12
@since   08/10/2015
/*/
//-------------------------------------------------------------------
Static Function CRMA580Proxy( xPool, aLevel )	
	Local aPool		:= ""
	Local cPool 	:= ""
	
	Default xPool	:= ""
	Default aLevel	:= {}

	//-------------------------------------------------------------------
	// Verifica se foi informado o ID ou o retorna da função CRMA580E.  
	//-------------------------------------------------------------------
	If ! ( ValType( xPool ) == "A" )	
		cPool := xPool
	Else
		//-------------------------------------------------------------------
		// Recupera a relação de agrupadores e níveis.  
		//-------------------------------------------------------------------		
		aPool 	:= xPool
		
		//-------------------------------------------------------------------
		// Recupera o código do agrupador.  
		//-------------------------------------------------------------------		
		cPool 	:= aPool[1][1]
		
		//-------------------------------------------------------------------
		// Recupera o os níveis do agrupador.  
		//-------------------------------------------------------------------			
		aLevel 	:= aPool[1][4]
	EndIf 	
Return cPool


//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580Group
Retorna Array contendo a código do nível e descrição do agrupador do qual 
a chave pesquisa pertence. Caso a chave não seja localizada, retorna INDEFINIDO.

@param xPool, indefinido, Código do agrupador ou retorno da função CRMA580E. 
@param aKey, array, Chave que será procurada no formato {{CAMPO, VALOR}, ...}. 
@param [lParent], lógico, Retorna apenas os níveis mais altos. 
@param [lTree], lógico, Retorna toda a descrição de toda hierarquia de um nível. 
@param [oMapKey], objeto, HashMap para aceleração de busca. 
@param [lMultiLevel], lógico, Identifica se deve retornar todos os níves que derem match. 
@return aPool, array, Array no formato {AGRUPADOR, NÍVEL, ID, DESCRICÃO} ou {{AGRUPADOR, NÍVEL, ID, DESCRICÃO}} quando lMultiLevel for true.

@author  Valdiney V GOMES
@version P12
@since   13/05/2015
/*/
//-------------------------------------------------------------------
Function CRMA580Group( xPool, aKey, lParent, lTree, oMapKey, lMultiLevel )
	Local aPool			:= {}
	Local aLevel		:= {}
	Local cLevel		:= CRMA580Root()
	Local cPool			:= ""
	Local cID			:= ""	

	Default oMapKey		:= Nil 
	Default xPool 		:= Nil
	Default aKey		:= {}
	Default lParent		:= .F. 
	Default lTree		:= .F.
	Default lMultiLevel	:= .F. 

	//-------------------------------------------------------------------
	// Recupera o ID do agrupador e os níveis selecionados.  
	//-------------------------------------------------------------------	
	cPool := CRMA580Proxy( xPool, aLevel )	

	If ( ! Empty( cPool ) ) 
		//-------------------------------------------------------------------
		// Realiza a busca pela chave.  
		//-------------------------------------------------------------------			
		CRMA580Search( cPool, cLevel, aKey, lParent, lTree, cID, aPool, aLevel, oMapKey, lMultiLevel )		
	EndIf
Return aPool

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580Search
Busca o agrupador e nível para uma determinada chave. 

@param cPool, caracter, Código do agrupador. 
@param cLevel, caracter, Nível do agrupador. 
@param aKey, array, Chave que será procurada no formato {{CAMPO, VALOR}, ...}. 
@param [lParent], lógico, Retorna apenas os níveis mais altos. 
@param [lTree], lógico, Retorna toda a descrição de toda hierarquia de um nível. 
@param [cID], caracter, Interno.
@param [aPool], array, Interno.
@param [aLevel], array, Interno.
@param [oMapKey], objeto, HashMap para aceleração de busca. 
@param [lMultiLevel], lógico, Identifica se deve retornar todos os níves que derem match.
@return aPool, array, Array no formato {AGRUPADOR, NÍVEL, ID, DESCRICÃO} ou {{AGRUPADOR, NÍVEL, ID, DESCRICÃO}} quando lMultiLevel for true.

@author  Valdiney V GOMES
@version P12
@since   08/10/2015
/*/
//-------------------------------------------------------------------
Function CRMA580Search( cPool, cLevel, aKey, lParent, lTree, cID, aPool, aLevel, oMapKey, lMultiLevel )
	Local cTemp			:= ""
	Local cType			:= ""
	Local cEntity		:= ""
	Local cQuery		:= ""
	Local cLevelCode	:= ""
	Local cField		:= ""
	Local cKey			:= ""
	Local cMatchPool	:= ""	
	Local cMatchID		:= ""	
	Local cMatchLevel	:= CRMA580Root()	
	Local cMatchTitle 	:= STR0009	
	Local nKey			:= 0
	Local nLevel		:= 0
	Local nPool			:= 0
	Local lMatch		:= .F.
	Local lSearch		:= .T. 	
	Local cFilAOM		:= xFilial("AOM")
	
	Default oMapKey		:= Nil 	
	Default aPool		:= {}
	Default aKey		:= {} 
	Default aLevel		:= {}  
	Default cPool		:= ""
	Default cLevel 		:= ""
	Default cID			:= ""
	Default lParent		:= .F.
	Default lTree		:= .F.
	Default lMultiLevel	:= .F. 

	//-------------------------------------------------------------------
	// Monta a chave para a busca no cache.  
	//-------------------------------------------------------------------
	For nKey := 1 To Len( aKey ) 
		cField	+= aKey[nKey][1]
		cKey	+= cBIStr( aKey[nKey][2] )
	Next nKey

	//-------------------------------------------------------------------
	// Verifica se a chave procurada está em cache.  
	//-------------------------------------------------------------------
	If ( Empty( oMapKey ) .Or. ( ! oMapKey:Get( cFilAOM + "LEVEL" + cPool + cLevel + cField + cKey, @aPool ) ) )
		//-------------------------------------------------------------------
		// Recupera um novo alias.  
		//-------------------------------------------------------------------			
		cTemp	:= GetNextAlias()
		
		//-------------------------------------------------------------------
		// Monta a instrução SQL.  
		//-------------------------------------------------------------------	
		cQuery := " SELECT " 
		cQuery += " 	AOL.AOL_CODAGR, AOL.AOL_TIPO, AOL.AOL_ENTIDA, AOM.AOM_CODNIV, AOM.AOM_NIVPAI, AOM.AOM_IDINT "
		If AOM->(FieldPos("AOM_OCORRE")) > 0 
			cQuery += ", AOM.AOM_OCORRE"    
		EndIf     
		cQuery += " FROM " 
		cQuery +=		RetSQLName("AOL") + " AOL," 
		cQuery += 		RetSQLName("AOM") + " AOM "
		cQuery += " WHERE "
		cQuery += " 	AOL.AOL_CODAGR = '" + cPool + "'"
		cQuery += " 	AND " 
		cQuery += " 	AOM.AOM_NIVPAI = '" + cLevel + "'"
		cQuery += " 	AND"	
		cQuery += " 	AOM.AOM_FILIAL = '" + xFilial( "AOM" ) + "'"
		cQuery += " 	AND "
		cQuery += " 	AOL.AOL_FILIAL = '" + xFilial( "AOL" ) + "'"
		cQuery += " 	AND " 
		cQuery += " 	AOM.AOM_CODAGR = AOL.AOL_CODAGR "
		cQuery += " 	AND"			
		cQuery += " 	AOM.D_E_L_E_T_ = ' '"
		cQuery += " 	AND"
		cQuery += " 	AOL.D_E_L_E_T_ = ' '"

		If AOM->(FieldPos("AOM_OCORRE")) > 0 
			cQuery += " ORDER BY "
			cQuery += " 	AOM.AOM_OCORRE DESC" 
		EndIf
	
		//-------------------------------------------------------------------
		// Executa a instrução SQL.  
		//-------------------------------------------------------------------	
		DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .F., .T. )

		//-------------------------------------------------------------------
		// Percorre os níveis do agrupador.  
		//-------------------------------------------------------------------		
		If ( ! (cTemp)->( Eof() ) )
			While ( ! (cTemp)->( Eof() ) )
				//-------------------------------------------------------------------
				// Recupera os atributos do nível.   
				//-------------------------------------------------------------------		
				cType		:= (cTemp)->AOL_TIPO
				cEntity		:= (cTemp)->AOL_ENTIDA
				cLevelCode	:= (cTemp)->AOM_CODNIV
				cParent		:= (cTemp)->AOM_NIVPAI
				cID			:= (cTemp)->AOM_IDINT				
				
				//-------------------------------------------------------------------
				// Controla a avaliação de níveis selecionados.   
				//-------------------------------------------------------------------
				lSearch := Empty( aLevel )
				
				If ! ( lSearch )
					nLevel 	:= aScan( aLevel, { |x|	x[1] == cLevelCode  } )
					lSearch := ! ( Empty( nLevel ) )
				EndIf

				//-------------------------------------------------------------------
				// Avalia o nível.   
				//-------------------------------------------------------------------	
				If ( lSearch )
					lMatch := CRMA580Match( cPool, cType, cEntity, cLevelCode, cParent, aKey, lParent, oMapKey, lMultiLevel  )
					
					If ( lMatch )
						AOM->( DBSetOrder( 1 ) )
						
						//-------------------------------------------------------------------
						// Posiciona no nível.  
						//-------------------------------------------------------------------
						If ( AOM->( DBSeek( cFilAOM + cPool + cLevelCode ) ) )	
							//-------------------------------------------------------------------
							// Recupera os atributos do nível.  
							//-------------------------------------------------------------------
							cMatchPool	:= cPool
							cMatchLevel := cLevelCode
							cMatchID 	:= cID
							cMatchTitle := AllTrim( If ( lTree, CRMA580Tree( cPool, cLevelCode ), AOM->AOM_DESCRI ) )
			
							//-------------------------------------------------------------------
							// Atualiza o contador de ocorrências.  
							//-------------------------------------------------------------------				
							If AOM->(FieldPos("AOM_OCORRE")) > 0 
								AOM->( RecLock( "AOM", .F. ) )
								AOM->AOM_OCORRE := Soma1( AOM->AOM_OCORRE )
								AOM->( MsUnlock() )
							EndIf 
							
							//-------------------------------------------------------------------
							// Retorna a identificação do grupo.  
							//-------------------------------------------------------------------						
							If ( lMultiLevel )
								nPool := aScan( aPool, { |x| CRMA580IsChild( x[3], cMatchID ) } )
								
								//-------------------------------------------------------------------
								// Lista o grupo mais especifico encontado. 
								//-------------------------------------------------------------------		
								If ( Empty( nPool ) )
									aAdd( aPool, { cMatchPool, cMatchLevel, cMatchID, cMatchTitle } )
								Else
									aPool[nPool] := { cMatchPool, cMatchLevel, cMatchID, cMatchTitle }
								EndIf 
								
								//-------------------------------------------------------------------
								// Procura nos subníveis do nível encontrado. 
								//-------------------------------------------------------------------							
								CRMA580Search( cPool, cLevelCode, aKey, lParent, lTree, cID, aPool, aLevel, oMapKey, lMultiLevel )
							Else
								//-------------------------------------------------------------------
								// Lista o primeiro grupo encontado.  
								//-------------------------------------------------------------------
								aPool := { cMatchPool, cMatchLevel, cMatchID, cMatchTitle }
								
								//-------------------------------------------------------------------
								// Identifica se deve ser pesquisado apenas nível superior.  
								//-------------------------------------------------------------------
								If ( ! lParent )	
									CRMA580Search( cPool, cLevelCode, aKey, lParent, lTree, cID, aPool, aLevel, oMapKey, lMultiLevel )
								EndIf 

								Exit						
							EndIf		
						EndIf 
					EndIf 
				EndIf 
				
				(cTemp)->( DBSkip() )			
			Enddo			
		EndIf
		
		//-------------------------------------------------------------------
		// Fecha a área de trabalho temporária.    
		//-------------------------------------------------------------------
		(cTemp)->( DBCloseArea() )
		
		//-------------------------------------------------------------------
		// Retorna a identificação do grupo.  
		//-------------------------------------------------------------------	
		If ( Empty( aPool ) )
			If ( lMultiLevel )
				aAdd( aPool, { cMatchPool, cMatchLevel, cMatchID, cMatchTitle } )
			Else
				aPool := { cMatchPool, cMatchLevel, cMatchID, cMatchTitle }		
			EndIf 	
		EndIf	
		
		//-------------------------------------------------------------------
		// Adiciona o resultado em cache para acelerar novas buscas.  
		//-------------------------------------------------------------------			
		If ! ( Empty( oMapKey ) )
			oMapKey:Set( cFilAOM + "LEVEL" + cPool + cLevel + cField + cKey, aPool ) 
		EndIf
	EndIf 	
Return aPool

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580Match
Avalia os níveis de acordo com cada tipo de agrupador.

@param cPool, caracter, Código do agrupador.  
@param cType, caracter, Tipo do agrupador. 
@param cEntity, caracter, Entidade principal do agrupador. 
@param cLevel, caracter, Nível para o qual a condição será retornada.
@param aKey, array, Chave que será procurada no formato {{CAMPO, VALOR}, ...}. 
@param [lParent], lógico, Retorna apenas os níveis mais altos. 
@param [oMapKey], objeto, HashMap para aceleração de busca.
@param [lMultiLevel], lógico, Identifica se deve retornar todos os níves que derem match.
@return lMatch, lógico, Indica se um nível foi encontrado.

@author  Valdiney V GOMES
@version P12
@since   13/05/2015
/*/
//-------------------------------------------------------------------
Static Function CRMA580Match( cPool, cType, cEntity, cLevel, cParent, aKey, lParent, oMapKey, lMultiLevel )
	Local bError 	:= ErrorBlock( { |oError| lMatch := .F., Conout( oError:ErrorStack ) } )
	Local cQuery	:= ""
	Local cKey		:= ""
	Local lMatch	:= .F.
	Local nKey		:= 0

	Default oMapKey		:= Nil 
	Default aKey		:= {}
	Default cPool		:= ""
	Default cType		:= ""
	Default cEntity		:= ""
	Default cLevel		:= ""
	Default cParent		:= ""
	Default lParent		:= .F.
	Default lMultiLevel := .F.

	If ! ( lParent ) .Or. ( lMultiLevel ) .Or. ( lParent .And. cParent == CRMA580Root() )
		If ( cType == LOGICO )
			//-------------------------------------------------------------------
			// Recupera a expressão AdvPL.  
			//-------------------------------------------------------------------					
			cAdvPL := CRMA580AdvPL( cPool, cType, cEntity, cLevel, aKey, oMapKey ) 

			//-------------------------------------------------------------------
			// Avalia a expressão AdvPL.    
			//-------------------------------------------------------------------
			BEGIN SEQUENCE	
				lMatch := &( cAdvPL )	
			END SEQUENCE
			
			//-------------------------------------------------------------------
			// Identifica se a chave está agrupada em um nível.      
			//-------------------------------------------------------------------			
			lMatch := If ( ValType( lMatch ) == "L", lMatch, .F. )
		ElseIf ( cType == FIXO )
			//-------------------------------------------------------------------
			// Identifica se a chave está agrupada em um nível.    
			//-------------------------------------------------------------------
			AON->( DBSetOrder( 1 ) )
			
			For nKey := 1 To Len( aKey )  
				cKey += cBIStr( aKey[nKey][2] )
			Next nKey	
			
			lMatch :=  ( AON->( DBSeek( xFilial("AON") + cPool + cLevel + cEntity + cKey ) ) )
		ElseIf ( cType == DINAMICO )
			//-------------------------------------------------------------------
			// Recupera a instrução SQL.  
			//-------------------------------------------------------------------
			cQuery 	:= CRMA580SQL( cPool, cType, cEntity, cLevel, aKey, oMapKey )
			
			//-------------------------------------------------------------------
			// Executa a instrução SQL.  
			//-------------------------------------------------------------------	
			DBUseArea( .T., "TOPCONN", TCGenQry( ,, changeQuery( cQuery ) ), "TMP", .F., .T. )

			//-------------------------------------------------------------------
			// Identifica se a chave está agrupada em um nível.     
			//-------------------------------------------------------------------
			lMatch := ! ( TMP->( Eof() ) )
			
			//-------------------------------------------------------------------
			// Fecha a área de trabalho temporária.    
			//-------------------------------------------------------------------
			TMP->( DBCloseArea() )		
		EndIf  	
	EndIf 

	ErrorBlock( bError ) 
Return lMatch


//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580Condition
Retorna Array no formato {JOINS, WHERE} contendo as regras para montagem 
da filtro na entidade principal do agrupador. 

@param cPool, caracter, Código do agrupador.  
@param cType, caracter, Tipo do agrupador. 
@param cEntity, caracter, Entidade principal do agrupador. 
@param cLevel, caracter, Nível para o qual a condição será retornada.
@param [oMapKey], objeto, HashMap para aceleração de busca.
@param aJoin, array, Uso interno. 
@param aWhere, array, Uso interno.
@return aCondition, array, Array no formato {JOINS, WHERE} 

@author  Valdiney V GOMES
@version P12
@since   13/05/2015
/*/
//-------------------------------------------------------------------
Static Function CRMA580Condition( cPool, cType, cEntity, cLevel, oMapKey, aJoin, aWhere )
	Local bError 		:= ErrorBlock( { | oError | Conout( oError:ErrorStack ) } )
	Local aCondition	:= {}
	Local aToken		:= {}
	Local aParser		:= {}
	Local aFilter		:= {}
	Local aAttribute		:= {}	
	Local cExpression	:= ""
	Local cParent		:= ""
	Local nFilter		:= 0
	Local nTable		:= 0
	Local nToken		:= 0
	Local nExpression	:= 0
	Local cFilAOM		:= xFilial("AOM")

	Default oMapKey		:= Nil
	Default aJoin 		:= {}
	Default aWhere		:= {}
	Default cPool 		:= ""
	Default cType 		:= ""
	Default cEntity		:= ""
	Default cLevel 		:= ""

	//-------------------------------------------------------------------
	// Verifica se a condição procurada está em cache.  
	//-------------------------------------------------------------------
	If ( Empty( oMapKey ) .Or. ( ! oMapKey:Get( cFilAOM + "FILTER" + cPool + cType + cEntity + cLevel , @aCondition ) ) )				
		AOM->( DBSetOrder( 1 ) )

		If ( AOM->( DBSeek( cFilAOM + cPool + cLevel ) ) )
			cFilter := AOM->AOM_FILXML
			cParent	:= AOM->AOM_NIVPAI
		EndIf 

		//-------------------------------------------------------------------
		// Parseia as expressões de filtro do nível do agrupador.  
		//-------------------------------------------------------------------
		If ! ( Empty( cFilter ) )
			aParser	:= CRMA580XTA( cFilter )
		EndIf 

		//-------------------------------------------------------------------
		// Percorre todos as expressões.  
		//-------------------------------------------------------------------
		For nFilter := 1 To Len( aParser ) 
			aAttribute := {}
		
			//-------------------------------------------------------------------
			// Recupera os atributos da expressão.  
			//-------------------------------------------------------------------
			aAdd( aAttribute, If( ! Empty( aParser[nFilter][8] ), aParser[nFilter][8], cEntity ) )
			aAdd( aAttribute, aParser[nFilter][1] )
			aAdd( aAttribute, aParser[nFilter][2] )
			aAdd( aAttribute, aParser[nFilter][3] )
			aAdd( aAttribute, aParser[nFilter][11] )
			aAdd( aAttribute, aParser[nFilter][12] )
							
			aAdd( aFilter, aAttribute )
		Next nFilter
	
		//-------------------------------------------------------------------
		// Percorre todos os filtros.  
		//-------------------------------------------------------------------
		For nFilter := 1 To Len( aFilter ) 
			If ( aFilter[nFilter][1] == cEntity .Or. cType == LOGICO )
				If ( cType == LOGICO )
					//-------------------------------------------------------------------
					// Recupera a expressão AdvPL.  
					//-------------------------------------------------------------------	
					cExpression := StrTran( aFilter[nFilter][3], '"', "'" )
				Else
					//-------------------------------------------------------------------
					// Recupera a expressão SQL.  
					//-------------------------------------------------------------------
					cExpression := aFilter[nFilter][4]
				EndIf 
	
				//-------------------------------------------------------------------
				// Recupera os camponentes da expressão.  
				//-------------------------------------------------------------------	
				If ! ( Empty( cExpression ) )
					aToken := StrTokArr( cExpression, "#" )
				EndIf 
				
				//-------------------------------------------------------------------
				// Avalia os componentes da expressão.   
				//-------------------------------------------------------------------
				BEGIN SEQUENCE	
					For nToken := 1 To Len( aToken )	
						If ( "FWMNTFILDT" $ Upper( aToken[nToken] ) )
							aToken[nToken] := &( aToken[nToken] )
						EndIf 
					Next nToken	
				END SEQUENCE	
	
				//-------------------------------------------------------------------
				// Monta a expressão.  
				//-------------------------------------------------------------------
				cExpression := cBIConcatWSep( "", aToken )
				
				//-------------------------------------------------------------------
				// Identifica se uma condição já foi definida no WHERE.  
				//-------------------------------------------------------------------
				nExpression := aScan( aWhere, { |x|	x == "(" + cExpression + ")" } )
				
				//-------------------------------------------------------------------
				// Adiciona a condição de filtro.  
				//-------------------------------------------------------------------		
				If ( Empty( nExpression ) )
					aAdd( aWhere, "(" + cExpression + ")" ) 
				EndIf
			Else
				//-------------------------------------------------------------------
				// Identifica se uma tabela já foi referenciada no INNER JOIN.  
				//-------------------------------------------------------------------
				nTable := aScan( aJoin, { |x|	x[1] == aFilter[nFilter][1] .And. x[3] == aFilter[nFilter][5] .And.	x[4] == aFilter[nFilter][6] } )
												
				//-------------------------------------------------------------------
				// Adiciona a condição para o INNER JOIN.  
				//-------------------------------------------------------------------	
				If ! ( Empty( nTable ) )
					aJoin[nTable][2] := aJoin[nTable][2] + " AND " + "(" + aFilter[nFilter][4] + ")"
				Else
					aAdd( aJoin, { aFilter[nFilter][1], "(" + aFilter[nFilter][4] + ")", aFilter[nFilter][5], aFilter[nFilter][6] } ) 
				EndIf 
			EndIf 				
		Next nFilter
		
		//-------------------------------------------------------------------
		// Recupera as condições de filtro dos pais.  
		//-------------------------------------------------------------------			
		If ! ( cParent == CRMA580Root() ) .And. ! ( Empty( cParent ) )
			CRMA580Condition( cPool, cType, cEntity, cParent, oMapKey, @aJoin, @aWhere )
		EndIf 				
			
		//-------------------------------------------------------------------
		// Retorna as condições.  
		//-------------------------------------------------------------------	
		aAdd( aCondition, aJoin )
		aAdd( aCondition, aWhere )		
	
		//-------------------------------------------------------------------
		// Adiciona o condição em cache.  
		//-------------------------------------------------------------------
		If ! ( Empty( oMapKey ) )
			oMapKey:Set( cFilAOM + "FILTER" + cPool + cType + cEntity + cLevel, aCondition ) 
		EndIf		
	EndIf

	//-------------------------------------------------------------------
	// Define a condição vazia.  
	//-------------------------------------------------------------------
	If ( Empty( aCondition ) )
		aCondition := {{},{}}
	EndIf 
	
	ErrorBlock( bError )
Return aCondition 

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580SQL
Retorna a condição SQL que atende a um filtro para um nível do agrupador. 

@param cPool, caracter, ID do agrupador.  
@param cType, caracter, Tipo do agrupador. 
@param cEntity, caracter, Entidade principal do agrupador. 
@param cLevel, caracter, Nível para o qual a condição será retornada.
@param aKey, array, Array no formato {{CAMPO, VALOR}, ...}
@param [oMapKey], objeto, HashMap para aceleração de busca.
@return cQuery, caracter, Instruçao SQL

@author  Valdiney V GOMES
@version P12
@since   13/05/2015
/*/
//-------------------------------------------------------------------
Static Function CRMA580SQL( cPool, cType, cEntity, cLevel, aKey, oMapKey, aResultset ) 
	Local aCondition	:= {}
	Local cQuery		:= ""
	Local cJoinAlias	:= ""
	Local cPrefix		:= ""
	Local nJoin 		:= 0
	Local nKey 			:= 0
	Local nField		:= 0

	Default oMapKey		:= Nil
	Default aKey		:= {}	
	Default aResultset	:= {}
	Default cPool		:= ""
	Default cType		:= ""
	Default cEntity		:= ""
	Default cLevel		:= ""

	//-------------------------------------------------------------------
	// Verifica se pode gerar expressão SQL.  
	//-------------------------------------------------------------------
	If ( cType == DINAMICO ) 
		//-------------------------------------------------------------------
		// Recupera as condições de filtro do nível analisado do agrupador.  
		//-------------------------------------------------------------------
		aCondition := CRMA580Condition(  cPool, cType, cEntity, cLevel, oMapKey )	
		
		If ! Empty( aCondition )
			//-------------------------------------------------------------------
			// Define os campos do resultset.  
			//-------------------------------------------------------------------			
			If ( Empty( aResultset ) )
				aAdd( aResultset , cEntity + ".R_E_C_N_O_"  )
			Else
				For nField := 1 To Len( aResultset )
					If ( At( ".", aResultset[nField] ) == 0 )
						aResultset[nField] := cEntity + "." + aResultset[nField]
					EndIf
				Next nField
			EndIf 
			
			//-------------------------------------------------------------------
			// Monta a instrução SQL.  
			//-------------------------------------------------------------------
			cQuery := " SELECT " + cBIConcatWSep( ",", aResultset )  + " FROM " + RetSQLName( cEntity ) + " " + cEntity
		
			//-------------------------------------------------------------------
			// Verifica se deve adicionar INNER JOIN.  
			//-------------------------------------------------------------------
			For nJoin := 1 To Len( aCondition[1] )
				//-------------------------------------------------------------------
				// Determina o prefixo dos campos da tabela.  
				//-------------------------------------------------------------------				
				If ( Substr( aCondition[1][nJoin][1], 1, 1 ) == "S" )
					cPrefix := Substr( aCondition[1][nJoin][1], 2 ) 
				Else
					cPrefix := aCondition[1][nJoin][1] 
				EndIf 			
						
				//-------------------------------------------------------------------
				// Define o alias para o INNER JOIN.  
				//-------------------------------------------------------------------		
				cJoinAlias :=  aCondition[1][nJoin][1] + AllTrim( Str( nJoin ) )
		
				//-------------------------------------------------------------------
				// Adiciona o INNER JOIN.  
				//-------------------------------------------------------------------
				cJoin 	:= " INNER JOIN " + RetSQLName( aCondition[1][nJoin][1] ) + " " + cJoinAlias
				cJoin 	+= " ON " 
				
				//-------------------------------------------------------------------
				// Relaciona as entidades pela chave estrangeira.   
				//-------------------------------------------------------------------	
				cJoin 	+= aCondition[1][nJoin][3] + " = " + aCondition[1][nJoin][4]  	
				cJoin 	+= " AND "
		
				//-------------------------------------------------------------------
				// Relaciona as entidades pelo filtro do agrupador.   
				//-------------------------------------------------------------------
				cJoin 	+= aCondition[1][nJoin][2]
				cJoin 	+= " AND "
				
				//-------------------------------------------------------------------
				// Adiciona o campo FILIAL.  
				//-------------------------------------------------------------------
				cJoin += cPrefix + "_FILIAL = '" + xFilial( aCondition[1][nJoin][1] )  + "'"
				cJoin += " AND "
		
				//-------------------------------------------------------------------
				// Adiciona o alias do INNER JOIN aos campos.  
				//-------------------------------------------------------------------
				cQuery += StrTran( cJoin, cPrefix + "_", cJoinAlias + "." + cPrefix + "_" )   		
				
				//-------------------------------------------------------------------
				// Adiciona o campo D_E_L_E_T_.   
				//-------------------------------------------------------------------
				cQuery += cJoinAlias + ".D_E_L_E_T_ = ' '" 	
			Next nJoin					
		
			//-------------------------------------------------------------------
			// Adiciona o WHERE.  
			//-------------------------------------------------------------------	
			cQuery += " WHERE "
		
			//-------------------------------------------------------------------
			// Adiciona as condições do agrupador.  
			//-------------------------------------------------------------------	
			If ! ( Len( aCondition[2] ) == 0 )
				cQuery += cBIConcatWSep( " AND ", aCondition[2] )
				cQuery += " AND "
			EndIf 	
			
			//-------------------------------------------------------------------
			// Adiciona a chave de busca.  
			//-------------------------------------------------------------------			
			For nKey := 1 To Len( aKey )
				If ( ";" $ cBIStr( aKey[nKey][2] ) ) 
					cQuery += aKey[nKey][1] + " IN " + FormatIn( aKey[nKey][2], ";" ) 
				Else
					cQuery += aKey[nKey][1] + " = '" + cBIStr( aKey[nKey][2] ) + "'"	
				EndIf
		
				cQuery += " AND "
			Next nKey
		
			//-------------------------------------------------------------------
			// Adiciona o campo FILIAL.  
			//-------------------------------------------------------------------
			If ( Substr( cEntity, 1, 1 ) == "S" )
				cQuery += cEntity + "." + Substr( cEntity, 2 ) + "_FILIAL = '" + xFilial( cEntity )  + "'"
				cQuery += " AND "
			Else
				cQuery += cEntity + "." + cEntity + "_FILIAL = '" + xFilial( cEntity )  + "'"
				cQuery += " AND "
			EndIf 	
			
			//-------------------------------------------------------------------
			// Adiciona o campo D_E_L_E_T_.   
			//-------------------------------------------------------------------
			cQuery += cEntity + ".D_E_L_E_T_ = ' '" 
			
			//-------------------------------------------------------------------
			// Define os operadores de concatenação.   
			//-------------------------------------------------------------------
			If ( ! "MSSQL" $ TCGetDB() )
				cQuery := StrTran( cQuery, "+", "||" )
			EndIf
		EndIf 	
	EndIf 
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580GetSQL
Retorna a condição SQL que atende a um filtro para um nível do agrupador 
FIXO ou DINAMICO. 

@param cPool, caracter, ID do agrupador.  
@param cLevel, caracter, Nível do agrupador. 
@param aResultset, array, lista de campos do resultset. 
@return cQuery, caracter, Instruçao SQL

@author  Valdiney V GOMES
@version P12
@since   24/11/2015
/*/
//-------------------------------------------------------------------
Function CRMA580GetSQL( cPool, cLevel, aResultset ) 
	Local aField		:= {}
	Local cConcat		:= ""
	Local cKey			:= ""
	Local cQuery		:= ""
	Local cType			:= ""
	Local cEntity		:= ""
	Local cID			:= ""
	Local nField		:= 0
	
	Default aResultset 	:= {}
	Default cPool		:= ""
	Default cLevel		:= ""

	//-------------------------------------------------------------------
	// Localiza o agrupador .  
	//-------------------------------------------------------------------
	AOL->( DBSetOrder( 1 ) )
	
	If ( AOL->( MSSeek( xFilial("AOL") + cPool ) ) )		
		cType	:= AOL->AOL_TIPO
		cEntity	:= AOL->AOL_ENTIDA
		
		//-------------------------------------------------------------------
		// Define os campos que farão parte do resultset.  
		//-------------------------------------------------------------------			
		If ( Empty( aResultset ) )
			aAdd( aResultset , cEntity + ".R_E_C_N_O_"  )
		Else
			For nField := 1 To Len( aResultset )
				If ( At( ".", aResultset[nField] ) == 0 )
					aResultset[nField] := cEntity + "." + aResultset[nField]
				EndIf
			Next nField
		EndIf 
			
		If ( cType = FIXO )		
			//-------------------------------------------------------------------
			// Localiza o nível do agrupador.  
			//-------------------------------------------------------------------
			AOM->( DBSetOrder( 1 ) )
			
			If ( AOM->( DBSeek( xFilial("AOM") + cPool + cLevel ) ) )	
				cID 	:= AOM->AOM_IDINT
				cConcat	:= If ( ! "MSSQL" $ TCGetDB(), "||", "+" )
				cKey 	:= CRMXGetSX2( cEntity, .T. )[4]

				//-------------------------------------------------------------------
				// Recupera os campos da chave única da tabela.  
				//-------------------------------------------------------------------
				aField 	:= StrToKArr( cKey, "+" )
				
				For nField := 1 To Len( aField )
					aField[nField] := cEntity + "." + aField[nField]
				Next nField	

				//-------------------------------------------------------------------
				// Monta a instrução SQL do agrupador fixo.  
				//-------------------------------------------------------------------
				cQuery += " SELECT " 
				cQuery += 		cBIConcatWSep( ",", aResultset ) 
				cQuery += " FROM " 
				cQuery +=		 RetSQLName( cEntity ) + " " + cEntity		
				cQuery += " WHERE EXISTS ( "
				cQuery += " 	SELECT " 
				cQuery += "			AON.R_E_C_N_O_"
				cQuery += "		FROM " 
				cQuery += 			RetSQLName( "AON" ) + " AON " 
				cQuery += " 	WHERE "
				cQuery += " 		AON.AON_CODAGR = '" + cPool + "'"
				cQuery += " 		AND "
				cQuery += " 		AON.AON_ENTIDA = '" + cEntity + "'"
				cQuery += " 		AND "
				cQuery += " 		AON.AON_CODNIV IN ( "
				cQuery += " 			SELECT "
				cQuery += " 				AOM.AOM_CODNIV "
				cQuery += " 			FROM " 
				cQuery += 					RetSQLName( "AOM" ) + " AOM "   
				cQuery += " 			WHERE "
				cQuery += " 				AOM.AOM_CODAGR = AON.AON_CODAGR"
				cQuery += " 				AND "
				cQuery += " 				AOM.AOM_IDINT LIKE '" + AllTrim( cID ) + "%'"
				cQuery += " 				AND "
				cQuery += " 				AOM.AOM_FILIAL = '" + xFilial( "AOM" ) + "'"	
				cQuery += " 				AND "	
				cQuery += "				AOM.D_E_L_E_T_ = ' '" 
				cQuery += " 		 )"
				cQuery += " 		AND "
				cQuery += " 		AON.AON_CHAVE = " 	+ cBIConcatWSep( cConcat , aField ) 	
				cQuery += " 		AND "
				cQuery += " 		AON.AON_FILIAL = '" + xFilial( "AON" ) + "'"	
				cQuery += " 		AND "	
				cQuery += "		AON.D_E_L_E_T_ = ' '" 
				cQuery += " )"	
				cQuery += " AND "
				cQuery += cEntity + ".D_E_L_E_T_ = ' '" 	
				cQuery += " AND "
										
				//-------------------------------------------------------------------
				// Adiciona o campo FILIAL.  
				//-------------------------------------------------------------------
				If ( Substr( cEntity, 1, 1 ) == "S" )
					cQuery += cEntity + "." + Substr( cEntity, 2 ) + "_FILIAL = '" + xFilial( cEntity )  + "'"
				Else
					cQuery += cEntity + "." + cEntity + "_FILIAL = '" + xFilial( cEntity )  + "'"
				EndIf 
			EndIf 	
		ElseIf ( cType == DINAMICO )
			//-------------------------------------------------------------------
			// Recupera a instrução SQL do agrupador dinâmico.  
			//-------------------------------------------------------------------
			cQuery := CRMA580SQL( cPool, cType, cEntity, cLevel, , , aResultset ) 	
		EndIf 
	EndIf 
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580AdvPL
Retorna a expressão AdvPL que atende a um filtro para um nível do agrupador. 

@param cPool, caracter, Código do agrupador.
@param cType, caracter, Tipo do agrupador.
@param cEntity, caracter, Entidade principal do agrupador.
@param cLevel, caracter, Nível para o qual a condição será retornada.
@param aKey, array, Array no formato {{CAMPO, VALOR}, ...}
@param [oMapKey], objeto, HashMap para aceleração de busca.
@return cQuery, caracter, Instruçao SQL

@author  Valdiney V GOMES 
@version P12
@since   18/06/2015
/*/
//-------------------------------------------------------------------
Static Function CRMA580AdvPL( cPool, cType, cEntity, cLevel, aKey, oMapKey ) 
	Local aCondition	:= {}
	Local cAdvPL		:= ""
	Local cKey			:= ""
	Local cField		:= ""
	Local nKey			:= 0
	Local xKey 			:= Nil 

	Default oMapKey		:= Nil
	Default aKey		:= {}
	Default cPool		:= ""
	Default cType		:= ""
	Default cEntity		:= ""
	Default cLevel		:= ""

	//-------------------------------------------------------------------
	// Verifica se pode gerar expressão AdvPL.  
	//-------------------------------------------------------------------
	If ( cType == LOGICO ) 
		//-------------------------------------------------------------------
		// Recupera o conteúdos dos campos.  
		//-------------------------------------------------------------------
		For nKey := 1 To Len( aKey ) 
			cKey += cBIStr( aKey[nKey][2] )
		Next nKey	
		
		//-------------------------------------------------------------------
		// Localiza o agrupador .  
		//-------------------------------------------------------------------
		AOL->( DBSetOrder( 1 ) )
		
		If ( AOL->( MSSeek( xFilial("AOL") + cPool ) ) )	
			//-------------------------------------------------------------------
			// Identifica o tipo do campo.  
			//-------------------------------------------------------------------
			cField	:= AOL->AOL_LOGTIP
				
			//-------------------------------------------------------------------
			// Converte o conteúdo para o tipo desejado.  
			//-------------------------------------------------------------------
			If ( cField == CARACTER )
				xKey := xBIConvTo("C", cKey) 
			ElseIf ( cField == NUMERIC )
				xKey := xBIConvTo("N", cKey) 
			ElseIf ( cField == DATE )
				xKey := xBIConvTo("D", cKey) 
			EndIf 		
		EndIf 

		//-------------------------------------------------------------------
		// Recupera as condições de filtro do nível analisado do agrupador.  
		//-------------------------------------------------------------------
		aCondition := CRMA580Condition( cPool, cType, cEntity, cLevel, oMapKey )	

		If ! ( Empty( aCondition ) )
			//-------------------------------------------------------------------
			// Recupera as condições do agrupador.  
			//-------------------------------------------------------------------				
			cAdvPL += cBIConcatWSep( " .AND. ", aCondition[2] )
			
			//-------------------------------------------------------------------
			// Substitui os wildcard #V. ou xCRM580WC pela chave de busca.  
			//-------------------------------------------------------------------			
			cAdvPL := StrTran( cAdvPL, "V." 		, cBIStr( xKey, .T. ) ) //Wildcard nao é mais utilizado nas novas construcoes de filtros.
			cAdvPL := StrTran( cAdvPL, "xCRM580WC"	, cBIStr( xKey, .T. ) )       
		EndIf
	EndIf 
Return cAdvPL

//-------------------------------------------------------------------
/*/{Protheus.doc} GetKey
Retorna a chave de busca que deve ser utilizada para avaliação do um
agrupador de acordo com a entidade principal do processo em execução.

@param xPool, indefinido, Código do agrupador ou retorno da função CRMA580E. 
@param cEntity, caracter, Entidade principal do agrupador. 
@param cProcess, caracter, Processo que está sendo executado. 
@return aKey, array, Lista no formato {{CHAVE, VALOR}, ...}. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Function CRMA580Key( xPool, cEntity, cProcess )
	Local oActive		:= FWModelActive()
	Local bError 		:= ErrorBlock( { | oError | Conout( oError:ErrorStack ) } )
	Local aKey			:= {}
	Local aField		:= {}
	Local aLevel		:= {}
	Local cPool			:= ""
	Local cField		:= ""
	Local cKey			:= ""
	Local nField		:= 0
	Local lMVC			:= .F. 
	Local cFilA08		:= xFilial("A08")  
	
	Static oModel		:= Nil
	
	Default xPool		:= ""
	Default cEntity		:= ""
	Default cProcess	:= ""

	//-------------------------------------------------------------------
	// Recupera o ID do agrupador e os níveis selecionados.  
	//-------------------------------------------------------------------	
	cPool := CRMA580Proxy( xPool, @aLevel )	

	If ! ( Empty ( cPool ) )	
		//-------------------------------------------------------------------
		// Localiza as regras para pesquisa para o agrupador avaliado.  
		//-------------------------------------------------------------------		
		A08->( DBSetOrder( 1 ) )
		
		If ( A08->( MSSeek( cFilA08 + cPool + cEntity ) ) )	
			//-------------------------------------------------------------------
			// Recupera o modelo de dados do processo.  
			//-------------------------------------------------------------------				
			If ( Empty( oModel ) ) .Or. ! ( oModel:GetID() == cProcess )
				oModel := FWLoadModel( cProcess ) 
			EndIf
			
			//-------------------------------------------------------------------
			// Verifica se o modelo de dados do processo foi carregado.  
			//-------------------------------------------------------------------			
			lMVC 	:= ! ( Empty ( oModel ) ) 
		
			If ( lMVC )
				//-------------------------------------------------------------------
				// Verifica se algum modelo de dados está ativo.  
				//-------------------------------------------------------------------
				lMVC := ( ! ( Empty ( oActive ) ) .And. oActive:IsActive() )
				
				If ( lMVC )
					//-------------------------------------------------------------------
					// Verifica se o modelo de dados ativo é o mesmo do processo.  
					//-------------------------------------------------------------------
					lMVC := ( oModel:GetID() == oActive:GetID() )
				EndIf
			EndIf  
			
			While ( A08->( ! Eof() ) .And. cFilA08 == A08->A08_FILIAL .And. A08->A08_CODAGR == cPool .And. A08->A08_ENTDOM == cEntity )
				cKey := "" 
				
				//-------------------------------------------------------------------
				// Avalia e adiciona a chave.  
				//-------------------------------------------------------------------
				BEGIN SEQUENCE
					//-------------------------------------------------------------------
					// Recupera cada campo do conteúdo.  
					//-------------------------------------------------------------------
					aField := StrToKArr( A08->A08_CONTEU, "+" )
					
					//-------------------------------------------------------------------
					// Percorre cada campo individualmente.  
					//-------------------------------------------------------------------	
					For nField := 1 To Len( aField )
						If ( lMVC ) 
							//-------------------------------------------------------------------
							// Recupera o valor do campo do modelo MVC ou função.  
							//-------------------------------------------------------------------
							If ( FindFunction( aField[nField] ) ) 
								cKey += cBIStr( &( aField[nField] ) )	
							Else
								If ( ( cEntity )->( FieldPos( aField[nField] ) ) > 0 )
									cKey += cBIStr( FWFldGet( aField[nField] ) )
								Else
									cKey += cBIStr( &( aField[nField] ) )		
								EndIf 
							EndIf 
						Else
							//-------------------------------------------------------------------
							// Recupera o valor do campo da memória, alias ou função.  
							//-------------------------------------------------------------------
							If ( FindFunction( aField[nField] ) ) 
								cKey += cBIStr( &( aField[nField] ) )	
							Else
								If ! ( IsMemVar( "M->" + aField[nField] ) )
									If ( ( cEntity )->( FieldPos( aField[nField] ) ) > 0 )
										cKey += cBIStr( &( cEntity + "->" + aField[nField] ) )
									Else
										cKey += cBIStr( &( aField[nField] ) )
									EndIf
								Else
									cKey += cBIStr( &( "M->" + aField[nField] ) )
								EndIf
							EndIf 					
						EndIf 
					Next nField
					
					//-------------------------------------------------------------------
					// Recupera a chave de pesquisa.  
					//-------------------------------------------------------------------
					cField 	:= AllTrim( A08->A08_CHVPES )
					
					//-------------------------------------------------------------------
					// Monta a chave de pesquisa.  
					//-------------------------------------------------------------------
					aAdd( aKey, { cField, cKey } )
				END SEQUENCE
				
				A08->( DBSkip() )
			EndDo
		EndIf
	EndIf 
	
	ErrorBlock( bError ) 
Return aKey

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580IsChild
Identifica se um nível do agrupador é filho de outro nível e qual o grau de parentesco
entre eles.

@param cLevelID, caracter, Nível conhecido. 
@param cID, caracter, Nível procurado que é possível filho do nível conhecido. 
@param [nLevel], numérico, Diferença entre nível procurado e o nível selecionado. 
@return lFound, lógico, Indentifica se o nível é filho do nível do agrupador encontrado. 

@author  Valdiney V GOMES 
@version P12
@since   19/06/2015 
/*/
//-------------------------------------------------------------------
Function CRMA580IsChild( cLevelID, cID, nLevel )
	Local lFound		:= .F. 
	
	Default cLevelID	:= ""
	Default cID			:= ""
	Default nLevel		:= 0

	//-------------------------------------------------------------------
	// Remove os espaços em branco.  
	//-------------------------------------------------------------------	
	cLevelID	:= AllTrim( cLevelID )
	cID			:= AllTrim( cID )
	
	//-------------------------------------------------------------------
	// Compara os IDs Inteligente.  
	//-------------------------------------------------------------------
	If ( ! Empty( cLevelID ) .And. Len( cID ) > Len( cLevelID ) )
		lFound := ( Substr( cID, 1, Len( cLevelID ) ) == cLevelID ) 
		
		If( lFound )
			//-------------------------------------------------------------------
			// Calcula o grau de parentesco.  
			//-------------------------------------------------------------------
			nLevel	:= ( Int( ( Len( cID ) -  Len( cLevelID ) ) / 2 ) ) * -1
		EndIf
	EndIf
Return lFound

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580Tree
Retorna a descrição de um nível do agrupador considerando toda a sua 
hierarquia. 

@param cPool, caracter, Código do agrupador.
@param cLevel, caracter, Nível do agrupador que será analisado.  
@param cTree, caracter, Uso interno. 
@return cTree, caracter, Descrição do nível do agrupador.

@author  Valdiney V GOMES
@version P12
@since   22/04/2015
/*/
//-------------------------------------------------------------------
Static Function CRMA580Tree( cPool, cLevel, cTree )
 	Local cTitle 	:= ""
 	Local cParent	:= ""
 	Local nLevel 	:= 0

 	Default cPool 	:= ""
	Default cLevel 	:= ""
	Default cTree	:= ""

	//-------------------------------------------------------------------
	// Localiza o nível do agrupador.  
	//-------------------------------------------------------------------
	AOM->( DBSetOrder( 1 ) )
	
	If ( AOM->( DBSeek( xFilial("AOM") + cPool + cLevel ) ) )	
		//-------------------------------------------------------------------
		// Recupera os atributos do nível.  
		//-------------------------------------------------------------------
		cParent := AllTrim( AOM->AOM_NIVPAI )
		cTitle 	:= AllTrim( AOM->AOM_DESCRI )
		cTree	:= If ( Empty( cTree ), cTitle, cTitle + " - " + cTree)
	EndIf 
	
	//-------------------------------------------------------------------
	// Recupera a descrição do nível superior do agrupador.  
	//-------------------------------------------------------------------			
	If ! ( cParent == CRMA580Root() ) .And. ! ( Empty( cParent ) )
		CRMA580Tree( cPool, cParent, @cTree )
	EndIf
Return cTree

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580Root
Retorna o código da raiz da árvore de níveis. 

@return cRoot, caracter, Código da raiz da árvore de níveis..

@author  Valdiney V GOMES
@version P12
@since   21/07/2015
/*/
//-------------------------------------------------------------------
Function CRMA580Root()
	//-------------------------------------------------------------------
	// Verifica se o ID do root está no cache.  
	//-------------------------------------------------------------------
	If ( Empty( cRoot ) )
		//-------------------------------------------------------------------
		// Recupera o ID do root.  
		//-------------------------------------------------------------------
		cRoot := Replicate( "0", TamSX3("AOM_CODNIV")[1] ) 
	EndIf 
Return cRoot

//--------------------------------------------------------------------
/*/{Protheus.doc} CRMA580When                      
Habilita os campos da estrutura logica.

@param	cCampo, caracter, Campo que será habilitado / desabilitado
@return	lRet, lógico, Retorno da validação

@author		Anderson Silva
@version	12  
@since		18/06/2015
/*/
//-------------------------------------------------------------------- 
Function CRMA580When(cCampo)
	Local lRetorno := .F.
	
	Do Case
		Case cCampo == "AOL_LOGTIP"
			lRetorno := INCLUI .And. FwFldGet("AOL_TIPO") == "3"                    
		Case cCampo == "AOL_LOGTAM" 
			lRetorno := FwFldGet("AOL_TIPO") == "3"	.AND. FwFldGet("AOL_LOGTIP") $ "1|2" 
		Case cCampo == "AOL_LOGDEC" 
	 		lRetorno := FwFldGet("AOL_TIPO") == "3" .AND. FwFldGet("AOL_LOGTIP") == "2"   
		Case cCampo == "AOL_LOGPIC" 
	 		lRetorno := FwFldGet("AOL_TIPO") == "3" .AND. FwFldGet("AOL_LOGTIP") $ "1|2"                           
	EndCase
Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580VRPes
Identifica se o valor de A08_CONTEU é um ou mais campos do domínio. 

@return	lOk, Identifica se o conteúdo é um campo do domínio.

@author		Anderson Silva
@version	12
@since		29/06/2015
/*/
//------------------------------------------------------------------------------
Function CRMA580VCont() 
	Local oModel	:= FwModelActive()
	Local oMdlA08	:= oModel:GetModel( "A08DETAIL" )
	Local aField	:= {}
	Local cContent	:= oMdlA08:GetValue( "A08_CONTEU" )
	Local cEntity	:= oMdlA08:GetValue( "A08_ENTDOM" )
	Local nField	:= 0
	Local lOk 		:= .T. 

	//-------------------------------------------------------------------
	// Recupera cada expressão do conteúdo.  
	//-------------------------------------------------------------------
	aField := StrToKArr( AllTrim( cContent ), "+" ) 
					
	//-------------------------------------------------------------------
	// Percorre cada expressão individualmente.  
	//-------------------------------------------------------------------	
	For nField := 1 To Len( aField )   
		//-------------------------------------------------------------------
		// Identifica se o conteúdo é uma função.  
		//-------------------------------------------------------------------
		lOk := ( FindFunction( aField[nField] ) ) 
		
		//-------------------------------------------------------------------
		// Identifica se o conteúdo é um campo do domínio.  
		//-------------------------------------------------------------------
		If ! ( lOk ) 
			lOk := ( ( cEntity )->( FieldPos( aField[nField] ) ) > 0 )
		EndIf 	

		If ! ( lOk )
			Help("", 1, "CRMA580VLD",, STR0028, 1) //"Informe um campo pertencente ao domínio ou uma função válida."
			Exit
		EndIf 
	Next nField
Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580VdPesq()                             
Identifica se o valor de A08_CHVPES é um ou mais campos da entidade do agrupador

@return	lOk, Identifica se o conteúdo é um ou mais campos da entidade do agrupador

@author		Anderson Silva
@version 	12   
@since		14/05/2014        
/*/
//-----------------------------------------------------------------------------
Function CRMA580VdPesq()
	Local oModel	:= FwModelActive()
	Local oMdlAOL	:= oModel:GetModel("AOLMASTER")
	Local oMdlA08	:= oModel:GetModel( "A08DETAIL" )
	Local aField	:= {}
	Local cEntity	:= oMdlAOL:GetValue("AOL_ENTIDA")
	Local cKey		:= oMdlA08:GetValue( "A08_CHVPES" )
	Local nField	:= 0
	Local lOk 		:= .T.

	If !Empty( cEntity )	
		//-------------------------------------------------------------------
		// Recupera cada campo da chave.  
		//-------------------------------------------------------------------
		aField := StrToKArr( AllTrim( cKey ), "+" )
						
		//-------------------------------------------------------------------
		// Percorre cada campo individualmente.  
		//-------------------------------------------------------------------	
		For nField := 1 To Len( aField )
			//-------------------------------------------------------------------
			// Identifica se o conteúdo é um campo da entidade principal.  
			//-------------------------------------------------------------------
			lOk := ( ( cEntity )->( FieldPos( aField[nField] ) ) > 0 )
	
			If ! ( lOk )
				Help("",1,"HELP","CRMA580VLD",STR0020,1) //"Chave de pesquisa inválida"
				Exit
			EndIf 
		Next nField 
	Else
		lOk := .F. 
		Help("",1,"HELP","CRMA580VLD",STR0029,1) //"Chave de pesquisa inválida, verifique se o campo Entidade foi preenchido."
	EndIf
Return lOk 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580ALVld
Função que valida o preenchimento de campos do agrupador 

@param	oModel, objeto, modelo de dados. 
@return	lOk, lógico, Valida o preenchimento de campos do agrupador. 

@author	Jonatas Martins
@since		07/07/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Static Function CRM580ALVld(oModel)
	Local cType 	:= ""
	Local cLength 	:= ""
	Local cDecimal	:= ""
	Local cPicture	:= ""
	Local lOk 		:= .T.
	
	Default oModel := Nil
	
	If ValType(oModel) == "O" .And. oModel:GetOperation() <> MODEL_OPERATION_DELETE
		//-------------------------------------------------------------------
		// Vefica se o agrupador é lógico
		//-------------------------------------------------------------------
		If ( oModel:GetValue("AOLMASTER","AOL_TIPO") == "3" )
			//-------------------------------------------------------------------
			// Recupera as propriedades do campo. 
			//-------------------------------------------------------------------		
			cType 		:= oModel:GetValue("AOLMASTER","AOL_LOGTIP")
			cLength 	:= oModel:GetValue("AOLMASTER","AOL_LOGTAM")
			cDecimal	:= oModel:GetValue("AOLMASTER","AOL_LOGDEC")
			cPicture	:= oModel:GetValue("AOLMASTER","AOL_LOGPIC")
			
			//-------------------------------------------------------------------
			// Verifica se o tipo foi informado.
			//-------------------------------------------------------------------			
			lOk := ! ( Empty( cType ) )
			
			//-------------------------------------------------------------------
			// Verifica se as demais propriedades foram informadas. 
			//-------------------------------------------------------------------			
			If ( lOk )
				If ( cType == "1" )
					lOk := ! Empty( cLength ) .And. ! Empty( cPicture )
				ElseIf( cType == "2" ) 
					lOk := ! Empty( cLength ) .And. ! Empty( cPicture )	
				ElseIf( cType == "3" ) 
					lOk := ! Empty( cLength )
				EndIf 		
			EndIf 
		
			If ! ( lOk )
				oModel:GetModel():SetErrorMessage(,, oModel:GetId(),, "FIELDSTRUCT", STR0010, STR0011,, ) //"Alguma informação da estrutura de campos não foi preenchida."###"Preencha todas as informações da estrutura de campos."
			EndIf
		Else
			//------------------------------------------------------------------
			// Valida o campo de entidade quando agrupador diferente de lógico
			//------------------------------------------------------------------	
			lOk := !Empty(oModel:GetValue("AOLMASTER","AOL_ENTIDA"))
			
			If !lOk
				oModel:GetModel():SetErrorMessage(,, oModel:GetId(),, "FIELDSTRUCT", STR0010, STR0013,, ) //"Alguma informação da estrutura de campos não foi preenchida."###"O campo de entidade deve ser preenchido para agrupador do tipo Fixo ou Dinâmico!" 
			EndIf
		EndIf
	EndIf
Return lOk
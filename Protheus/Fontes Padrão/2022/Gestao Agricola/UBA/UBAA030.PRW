#INCLUDE "UBAA030.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} UBAA030
GESTÃO DE REMESSA

@author 	marcelo.wesan
@since 		06/02/2017
@version 	1.0
*/  
Function UBAA030()
	Local oMBrowse		:= Nil

	Private _lBrowseAct	:= .F.	
	Private _oBrowseDXK := Nil
	Private nTotMalas	:= 0
	Private  lCopy      := .F.
	
	If .Not. TableInDic('N72')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N72" )
	oMBrowse:SetMenuDef( "UBAA030" )
	oMBrowse:SetDescription(STR0006)	//Gestão de Remessas
	oMBrowse:DisableDetails()
	oMBrowse:AddLegend("N72->N72_STATUS ='1'","YELLOW"    , STR0029)//INICIADA
	oMBrowse:AddLegend("N72->N72_STATUS ='2'","GREEN"     , STR0030)//ENVIADA
	oMBrowse:AddLegend("N72->N72_STATUS ='3'","BLUE"      , STR0031)//ENTREGUE
	oMBrowse:AddLegend("N72->N72_STATUS ='4'","RED"       , STR0032)//ENTREGUE PARCIAL
	oMBrowse:AddLegend("N72->N72_STATUS ='5'","BR_CANCEL" , STR0033)//CANCELADA
	oMBrowse:Activate()

Return( Nil )


/*{Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina

@author 	marcelo.wesan
@since 		06/02/2017
@version 	1.0
*/  
Static Function MenuDef()
	Local aRotina 	:= {}
	Local aRotina1 	:= {}
 
 	//*Parametros SX1
	aAdd( aRotina1, { STR0037, {|| UBAA030PAR(1)}  , 0, 7, 0, Nil } )//*Analise
	aAdd( aRotina1, { STR0038, {|| UBAA030PAR(2)}  , 0, 7, 0, Nil } )//*HVI
	
	aAdd( aRotina, { STR0001, 'VIEWDEF.UBAA030'	, 0, 2, 0, NIL } )//Visualisar
	aAdd( aRotina, { STR0002, 'VIEWDEF.UBAA030'	, 0, 3, 0, NIL } )//Incluir
	aAdd( aRotina, { STR0003, 'VIEWDEF.UBAA030'	, 0, 4, 0, NIL } )//Alterar
	aAdd( aRotina, { STR0004, 'VIEWDEF.UBAA030'	, 0, 5, 0, NIL } )//Excluir
	aAdd( aRotina, { STR0042, "UBAA030CPY"	, 0, 13, 0, Nil } )//Copiar
	aAdd( aRotina, { STR0043, "UBAF030REC"     	, 0,10, 0, NIL } )//Recebimento
	aAdd( aRotina, { "Cancelar", "UBAF030CAN(N72->N72_SAFRA, N72->N72_CODREM, N72->N72_TIPO, N72->N72_CODCLI, N72->N72_LOJCLI,N72->N72_STATUS)"   , 0,12, 0, NIL } )//"Cancelar" 
	
	aAdd( aRotina, { STR0044, 'UBAF030NFS(N72->N72_SAFRA, N72->N72_CODREM, N72->N72_TIPO, N72->N72_CODCLI, N72->N72_LOJCLI,N72->N72_STATUS)'   , 0, 6, 0, NIL } )//'Enviar NFS'
	aAdd( aRotina, { STR0045, 'UBAF030NFD(N72->N72_SAFRA, N72->N72_CODREM, N72->N72_TIPO, N72->N72_CODCLI, N72->N72_LOJCLI,N72->N72_STATUS)'   , 0, 6, 0, NIL } )//'Estorno NFS'
	aAdd( aRotina, { STR0063, "SPEDNFE"  			, 0, 9, 0, .F. } ) //"Sped NFe"
	
	//*Parametros SX1
	aAdd( aRotina, { STR0036, aRotina1	  , 0, 7, 0, Nil } )//ROTINA1 - Parametros	
	aAdd( aRotina, { STR0039, 'UBAR0301'  , 0, 8, 0, NIL } )//Imprimir Listagem de Remessa
	aAdd( aRotina, { STR0040, 'UBAR0302'  , 0, 8, 0, NIL } )//Imprimir Cod.Barras de Remessa
	aAdd( aRotina, { STR0046, 'UBAA030HIS', 0,11, 0, NIL } )//'Histórico'  
   
	aAdd( aRotina, { STR0065, 'UBAF030EST', 0, 14, 0, Nil } ) //'Cancelar Recebimento de Mala'
   
Return aRotina


/*{Protheus.doc} ModelDef
Função que retorna o MODELO padrao para a rotina

@author 	marcelo.wesan
@since 		06/02/2017
@version 	1.0
*/ 
Static Function ModelDef()
	Local oStruN72 		:= FWFormStruct( 1,"N72")
	Local oStruN73 		:= FWFormStruct( 1,"N73")
	Local oModel		:= MPFormModel():New( "UBAA030", {|oModel| UBAA030POS(oModel)} , {|oModel| UBAA030POS(oModel)} , {| oModel | UBAA030GRV( oModel ) }, /*<bCancel >*/ )
	
	// Gatilho do campo safra para gerar o codigo de barras
	
	oStruN72:AddTrigger( "N72_SAFRA" , "N72_CODBAR"	, { || .T. }, { | oModel | UBAA030BAR(oModel) } )
	oStruN73:AddTrigger( "N73_CODMAL", "N73_CODSAF"	, { || .T. }, { | oModel | UBAA030TGR(oModel, 'SAF') } )
	oStruN73:AddTrigger( "N73_CODMAL", "N73_QTDCLA"	, { || .T. }, { | oModel | UBAA030TGR(oModel, 'QTD') } )
	oStruN73:AddTrigger( "N73_CODMAL", "N73_TIPO"	, { || .T. }, { | oModel | UBAA030TGR(oModel, 'TIP') } )
	
	oStruN73:RemoveField("N73_CODREM")

	oModel:SetDescription(STR0007)//Malas
	
	oModel:AddFields( 'N72UBAA030', /*cOwner*/, oStruN72 )
	oModel:AddGrid( 'N73UBAA030', 'N72UBAA030', oStruN73 ,,,,,{ |oObj, lCopia |UBAA030NGR(oObj,lCopia)})

    oModel:GetModel( "N72UBAA030" ):SetFldNoCopy(UBAA030REE()) 	// Na função Copiar nao copia os campos de retornados em array
	oModel:GetModel( 'N72UBAA030' ):SetDescription(STR0006 )	//Malas
	oModel:GetModel( 'N73UBAA030' ):SetDescription(STR0007)		//Gestão de Remessas
	oModel:GetModel( 'N73UBAA030' ):SetUniqueLine( { 'N73_CODMAL' })
	oModel:GetModel( 'N73UBAA030' ):SetOptional( .T. )
	
	oModel:SetPrimaryKey( { "N72_FILIAL", "N72_CODREM" } )
	//------------------
	// adiciona calculo 
	//------------------
	oModel:AddCalc( 'UBAA030CALC', 'N72UBAA030', 'N73UBAA030', 'N73_CODMAL'  , 'TOTFDI'  	,'COUNT',{||.t.},, STR0035 ) //'Total Malas'
	
	oModel:SetRelation('N73UBAA030', { { 'N73_FILIAL', 'xFilial( "N73" )' }, { 'N73_CODSAF', 'N72_SAFRA' } ,{ 'N73_CODREM', 'N72_CODREM' }, { 'N73_TIPO', 'N72_TIPO' } }, N73->( IndexKey( 4 ) ) )
	
	// Valida a ativação do model
	//----------------------------
	oModel:SetVldActivate( { |oMdl| U030VLDACT( oModel ) } )
	
	oModel:SetActivate({|oModel|UBAA030SAC(oModel)})//recebe o valor do campo safra
Return ( oModel )


/*{Protheus.doc} ViewDef
Função que retorna a VISUALIZAÇÃO padrao para a rotina

@author 	marcelo.wesan
@since 		06/02/2017
@version 	1.0
*/ 
Static Function ViewDef()
	Local oStruN72	:= FWFormStruct( 2, "N72" )
	Local oStruN73	:= FWFormStruct( 2, "N73" )
	Local oModel   	:= ModelDef()
	Local oView    	:= FWFormView():New()
	Local oCalc    	:= Nil
	
	//Remove campos desnecessários para visualização
	oStruN72:RemoveField("N72_STATUS")
	oStruN73:RemoveField("N73_CODREM")
	oStruN73:RemoveField("N73_DATENV")
	oStruN73:RemoveField("N73_HORENV")
	oStruN73:RemoveField("N73_USRENV")
	oStruN73:RemoveField("N73_USRENV")
	oStruN73:RemoveField("N73_PEDREM")
	oStruN73:RemoveField("N73_DOCREM")
	oStruN73:RemoveField("N73_SERREM")
	oStruN73:RemoveField("N73_TIPO")
	
	oStruN72:RemoveField('N72_DATATU')
	oStruN72:RemoveField('N72_HORATU')		
	
	oView:SetModel( oModel )
	// Instacia FwCalEstruct
	oCalc := FWCalcStruct( oModel:GetModel( 'UBAA030CALC') )

	oView:AddField("UBAA030_N72", oStruN72, "N72UBAA030")	//Remessa
	oView:AddGrid ("UBAA030_N73", oStruN73, "N73UBAA030" , , {|| UBAA030FOC() })//Mala # Função de Foco da Grid

	oView:AddOtherObject("UBAA030_DXK", {|oPanel, oObj| UBAA030DXK(oPanel, oObj)})
	oView:AddField("UBAA030_CALC", oCalc , "UBAA030CALC" )
	
	oView:SetViewProperty("UBAA030_N73", "ENABLENEWGRID")
	oView:SetViewProperty("UBAA030_N73", "GRIDSEEK", {.T.})
	oView:SetViewProperty("UBAA030_N73", "CHANGELINE", {{ |oView, cViewID| UBAA030BRW(oView, cViewID) }} )
	
	oView:CreateHorizontalBox( 'EMCIMA' 	, 50 )//Remessa
	oView:CreateHorizontalBox( 'EMBAIXO'	, 40 )//Mala e Fardinho
	oView:CreateHorizontalBox("RODAPE" 		, 10 )//TOTAL CALC
	oView:CreateVerticalBox("ESQUERDO" 		, 50,"EMBAIXO" )//Mala
	oView:CreateVerticalBox("DIREITO" 		, 50,"EMBAIXO" )//Fardinho
		
	oView:SetOwnerView("UBAA030_N72", "EMCIMA")
	oView:SetOwnerView("UBAA030_N73", "ESQUERDO")
	oView:SetOwnerView("UBAA030_DXK", "DIREITO")
	oView:SetOwnerView("UBAA030_CALC", "RODAPE")
	
	oView:EnableTitleView("UBAA030_N72")
	oView:EnableTitleView("UBAA030_N73")
	oView:EnableTitleView("UBAA030_DXK", STR0034)

	//Adiciona o botão de vincular malas no menu da view
	oView:AddUserButton( STR0026 , '', {|oView| UBAA030VIN(oView)} ) //"Vincular Malas"
	oView:SetCloseOnOk( {||.T.} )

Return (oView)


/*{Protheus.doc} UBAA030PAR
(Função de execução do pergunte acionada pelo botão parametros em outras ações)

@author 	marcelo.wesan
@since 		07/02/2017
@version 	1.0
@param 		nTipo, numérico, (Tipo de classificação  1 - Visual, 2 - HVI)
*/
Static Function UBAA030PAR(nTipo)
	Local cPergunta := ""

	If nTipo == 1
		If ExistBlock('UB030001')
			cPergunta := ExecBlock('UB030001',.F.,.F.) //Retorna nome do pergunte especifico
			Pergunte(cPergunta,.T.)	//Pergunte Especifico para expedição de amostras visuais
		Else
			Pergunte('UBAA030I',.T.)	//Pergunte-SX1 Visual
		EndIf
	
		
	ElseIf nTipo == 2
		If ExistBlock('UB030002')
			cPergunta := ExecBlock('UB030002',.F.,.F.) //Retorna nome do pergunte especifico
			Pergunte(cPergunta,.T.)	//Pergunte Especifico para expedição de amostras HVI
		Else
			Pergunte('UBAA030E',.T.)	//Pergunte-SX1 HVI
		Endif
	EndIf
Return .T.


/** {Protheus.doc} UBAA030COP
Função que pega todos os campos do modelo e retorna-os em array unidimensional

@param:     oModel      	Objeto de Model do MVC
@return:    aFldNoCopy      Array Com os Campos do modelo de dados passado
@author 	marcelo.wesan
@since 		07/02/2017      
*/
Function UBAA030COP( oModel )
	Local nX    		:= 1
	Local aFieldsAux    	:= FwFormStruct(1, 'N73'):aFields
	Local aFldNoCopy 	:= {}
	
	For nX:=1 To Len( aFieldsAux ) Step 1
		aAdd(aFldNoCopy , aFieldsAux [nX , 3] )
	Next
Return aFldNoCopy

 /** {Protheus.doc} UBAA030SAC
Função de cópia do campo Safra

@param: 	Nil
@return:	Nil
@author: 	marcelo.wesan
@since: 	13/03/2016
*/

Static Function UBAA030SAC(oModel)

  Local oN72 := Nil

  If Type('lCopy') != 'U'
	   If lCopy
	   		oN72 := oModel:getModel("N72UBAA030")
	   		oN72:SetValue("N72_SAFRA",N72->N72_SAFRA)//Seta o valor do campo safra e dispara o gatilho do codigo de barras 
	        lCopy := .F.
	   EndIf
  endIf

Return 

 /** {Protheus.doc} AGRA35COPY
Função de cópia do modelo 

@param: 	Nil
@return:	Nil
@author: 	marcelo.wesan
@since: 	13/03/2016
*/
Function UBAA030CPY()
	lCopy := .t.

	FWExecView(STR0042,"UBAA030",9,,{|| .T.}) //"Cópiar"
Return
  
 /** {Protheus.doc} UBAA030NGR
Função de carga de dados da grid para função copiar

@param:     oObj      	
@param:     lCopia
@return:    aLoadGrid      
@author:    marcelo.wesan
@since:     22/02/2017  
*/
Static Function UBAA030NGR(oObj,lCopia) 
	Local aLoadGrid := {}
	Local nLgTam	:= 0
   	Local cStat     := N72->N72_STATUS
   	Local aMalas    := {}
   	Local nX 		:= 0
   	Local nY        := 0
   	Local nJ        := 0
   	Local aRemov    := {}
   	Local cMsg      := ""
   	Local nCount    := 0
	
	If  lCopia .AND. cStat == "5"//se a remessa tiver status = 5 reenvio e valida as malas
		aLoadGrid := FormLoadGrid(oObj, .T.) // faz a carga de dados 
		nLgTam := Len(aLoadGrid)
		aMalas := UBAA030CMA()//busca as malas disponiveis
	
		For nX := 1 To Len(aMalas) //as malas diponiveis para inclusão na remessa
		   For nY := 1 To Len(aLoadGrid)
				If aMalas[nX] == aLoadGrid[nY][2][2] //compara as malas da grid com as da consulta
					aDel(aLoadGrid, nY)//remove as malas da grid
						aSize(aLoadGrid, --nLgTam)
						aadd(aRemov, aMalas[nX])//armazena as malas removidas da grig
					Exit
				EndIf
			Next	
		Next
	ElseIf .NOT. lCopia
		aLoadGrid := FormLoadGrid(oObj, .F.)
	EndIf
	
	If Len(aRemov) <> 0 // monta a msg info para que o usuario possa saber quais malas foram removidas
	    nCount := Len(aRemov) 
		For nJ := 1 To Len(aRemov) 
		cMsg += aRemov[nJ]
		   nCount --
		   If nCount <> 0
			   cMsg += " , "
		   EndIf
		Next
		If Len(aRemov) <> 1
		    Help( ,, STR0053,, STR0058 + cMsg + STR0061, 1, 0,)//"Atenção "codmal" já possuem vinculo com outra remessa ! "
		ElseIf Len(aRemov) == 1
		    Help( ,, STR0053,, STR0059 + cMsg + STR0060, 1, 0,)//"Atenção "codmal" já possui vinculo com outra remessa!"
		EndIf
	EndIf	
	   
Return aLoadGrid // retorna as malas para a grid

 /** {Protheus.doc} UBAA030REE
Função de carga de dados da grid para função copiar reenviar malas

@param:     oModel     	
@return:    aFldNoCopy      
@author:    marcelo.wesan
@since:     07/03/2017  
*/
Static Function UBAA030REE( )
    Local aFldNoCopy 	:= {}
   	Local cFldsNCopy 	:= ''
        
	cFldsNCopy += "N72_CODBAR,N72_DATA,N72_HORA,N72_STATUS,N72_DOCREM,N72_PEDREM,N72_SERREM,N72_DATENV,N72_HORENV"
	aFldNoCopy  := Separa(cFldsNCopy,',' )
	    
Return aFldNoCopy


 /*{Protheus.doc} UBAA030CMA
(Função responsável por carregar as malas )

@author 	marcelo.wesan
@since 		08/03/2017
@version 	1.0
@return 	${return}, ${Array com as malas filtradas}
*/
Static Function UBAA030CMA()
	Local aArea			:= GetArea()
	Local aColsLoad		:= {}
	Local cAliasQry  	:= ""
	Local cQry 			:= ""
	Local cTipoClas		:= N72->N72_TIPO
	Local cSafra		:= N72->N72_SAFRA

	cAliasQry := GetNextAlias()
	
	If cTipoClas == '1'		//**Visual
		nTipoUm 	:= '1'	//Visual - Pendente
	ElseIf cTipoClas == '2'	//**HVI
		nTipoUm 	:= '4'	//HVI - Pendente
	EndIf
	
	cQry := "SELECT N73_CODMAL"
	cQry +=  " FROM "+ RetSqlName("N73") + " N73"
	cQry += " INNER  JOIN "+ RetSqlName("DXJ")+" DXJ" +" ON"
	cQry += " N73_CODMAL = DXJ_CODIGO " 
	cQry += " AND N73_CODSAF = DXJ_SAFRA "
	cQry += " AND N73_FILIAL = DXJ_FILIAL"
	cQry += " AND N73_TIPO   = DXJ_TIPO "	
	cQry += " WHERE N73.D_E_L_E_T_ <> '*'
	cQry += " AND N73_FILIAL 	= '"+xFilial("N73")+"'"
	cQry += " AND N73_CODSAF 	= '"+cSafra+"'"
	cQry += " AND N73_TIPO 	    = '"+cTipoClas+"'"
	cQry += " AND DXJ_STATUS = '"+nTipoUm+"'"
	cQry += " AND DXJ.D_E_L_E_T_ <> '*'
	cQry += " AND EXISTS (SELECT * FROM "+ retSqlName('N72') +" N72"
	cQry += " WHERE  N72_CODREM = N73_CODREM AND N72_FILIAL = N73_FILIAL "
	cQry += " AND N72.D_E_L_E_T_ <> '*'  AND N72_STATUS <> '5')" 
	cQry := ChangeQuery(cQry)
	
	If Select(cAliasQry) > 0
		(cAliasQry)->( dbCloseArea())
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof())
		aAdd( aColsLoad, (cAliasQry)->N73_CODMAL)
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return(aColsLoad)//retorna as malas disponiveis para o reenvio de remessas
    



/*{Protheus.doc} UBAA030BAR
(Função de execução de gatilho no campo N72_SAFRA para gerar o codigo de Barras no campo N72_CODBAR)

@author 	marcelo.wesan
@since 		09/02/2017
@version 	1.0
*/
Static Function UBAA030BAR(oModel)
	Local cRetorno	:= ""
	Local oModelPar	:= oModel:GetModel()
	Local oStruN72	:= oModelPar:GetModel("N72UBAA030")
 
 	//REGRA N72_CODBAR := N72_FILIAL - N72_SAFRA - N72_CODREM - RM
	cRetorno := AllTrim( xFilial("N72"))+ "-" + AllTrim(oStruN72:GetValue("N72_SAFRA"))+ "-" + AllTrim(oStruN72:GetValue("N72_CODREM"))+"-RM"
Return ( cRetorno )


/* {Protheus.doc} UBAA030GRV
Função que grava o modelo de dados após a confirmação

@author 	marcelo.wesan
@since 		09/02/2017
@version 	1.0
@param.:    oModel - Modelo de dados
@return:    lRetorno [Retorno do Commit - podendo ser .T. ou .F.]
*/
Static Function UBAA030GRV( oModel )
	Local lRetorno		:= .T.
	Local nX            := 0 
	Local nOperation	:= oModel:GetOperation()
	Local oModelN72		:= oModel:GetModel('N72UBAA030')
	Local oModelN73		:= oModel:GetModel('N73UBAA030')
	Local cSaFra		:= oModelN72:GetValue('N72_SAFRA')
	Local cCodRem		:= oModelN72:GetValue('N72_CODREM')

    If  nOperation == MODEL_OPERATION_INSERT
		For nX := 1 To  oModelN73:Length()
			oModelN73:Goline(nX)
								
			If oModelN73:IsDeleted(nX)  //Se a linha da mala foi excluída, não considera
				Loop
			EndIf
			
			If (Empty(oModelN73:GetValue("N73_CODSAF"))) //Não tem registros no browse de Malas
			   Exit
			EndIf
			//se no browse de malas existir alguma mala cuja safra seja diferente da safra da Remessa então emite msg de erro
			If (oModelN73:GetValue("N73_CODSAF") != cSaFra) 
			  oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0062, "", "", "") // "Existem malas vinculadas cuja Safra não é a mesma da Remessa."
			  lRetorno := .F.
			  Return( lRetorno )
			EndIf
		Next nX
	Endif

	If  nOperation == MODEL_OPERATION_INSERT
		lRetorno := FWFormCommit(oModel, /*[bBefore]*/, /*[bAfter]*/, /*[bAfterSTTS]*/, /*dentro*/, /*[bABeforeTTS]*/, /*<bIntegEAI >*/)
	   	If lRetorno 
	     	AGRGRAVAHIS(,,,,{"N72",xFilial("N72")+cSaFra+cCodRem,"3",STR0002}) //Incluir
	   	EndIF
	     
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		lRetorno := FWFormCommit(oModel, /*[bBefore]*/, /*[bAfter]*/, /*[bAfterSTTS]*/, /**/, /*[bABeforeTTS]*/, /*<bIntegEAI >*/)
		If lRetorno
			AGRGRAVAHIS(,,,,{"N72",xFilial("N72")+cSaFra+cCodRem,"4",STR0003}) //Alterar
		EndIf 
		
	ElseIf nOperation == MODEL_OPERATION_DELETE
		lRetorno := FWFormCommit(oModel, /*[bBefore]*/, /*[bAfter]*/, /*[bAfterSTTS]*/, /**/, /*[bABeforeTTS]*/, /*<bIntegEAI >*/)
	 	If lRetorno
	   		AGRGRAVAHIS(,,,,{"N72",xFilial("N72")+cSaFra+cCodRem,"5",STR0004}) //Excluir
	 	EndIf
	EndIf
Return( lRetorno )


/*{Protheus.doc} UBAA030BRW
(Função que carrega os fardinhos na grid direita com
base na linha posicionada na grid esquerda, pelo changeline)
@type function
@author 	roney.maia
@since 		09/02/2017
@version 	1.0
@return 	${return}, ${NIL}
*/
Static Function UBAA030BRW(oView)
	Local nLine 		:= oView:GetLine('UBAA030_N73')
	Local cCodMala 		:= oView:GetValue('N73UBAA030', 'N73_CODMAL', nLine)
	Local cTipo			:= oView:GetValue('N73UBAA030', 'N73_TIPO', nLine)
	Local cSafra			:= oView:GetValue('N73UBAA030', 'N73_CODSAF', nLine)
	Local cQry      	:= "@ DXK_CODROM = '"+ cCodMala +"' AND DXK_TIPO = '"+ cTipo +"' AND DXK_SAFRA = '"+ cSafra +"'"
	Local oViewN73		:= oView:GetViewObj('N73UBAA030')[3]
	
	If _lBrowseAct
		_oBrowseDXK:SetFilterDefault(cQry)
		_oBrowseDXK:UpdateBrowse()
		oViewN73:oBrowse:SetFocus()	
	EndIf	
Return


/*{Protheus.doc} UBAA030FOC
(Função acionada no foco da grid esquerda, para o caso
de mostrar os fardinhos quando houver apenas uma mala inclusa)
@type function
@author 	roney.maia
@since 		13/02/2017
@version 	1.0
@return 	${return}, ${Nil}
*/
Static Function UBAA030FOC()
	Local oModel	:= FwModelActive()
	Local oView	:= FwViewActive()
	Local oModelN73	:= oModel:GetModel('N73UBAA030')
	Local oModelDXK	:= Nil
	Local nLine 	:= 0
	Local cCodMala 	:= ""
	Local cTipo	:= ""
	Local cSafra	:= ""
	Local cQry      := ""
	Local oViewN73	:= ""
	
	If _lBrowseAct .AND. oModelN73:Length() == 1
		oModelDXK	:= oModel:GetModel('DXKUBAA030')
		nLine 		:= oView:GetLine('UBAA030_N73')
		cCodMala 	:= oView:GetValue('N73UBAA030', 'N73_CODMAL', nLine)
		cTipo		:= oView:GetValue('N73UBAA030', 'N73_TIPO', nLine)
		cSafra		:= oView:GetValue('N73UBAA030', 'N73_CODSAF', nLine)
		cQry      	:= "@ DXK_CODROM = '"+ cCodMala +"' AND DXK_TIPO = '"+ cTipo +"' AND DXK_SAFRA = '"+ cSafra +"'"
		oViewN73	:= oView:GetViewObj('N73UBAA030')[3] 
		_oBrowseDXK:SetFilterDefault(cQry)
		_oBrowseDXK:UpdateBrowse()
		oViewN73:oBrowse:SetFocus()	
	EndIf	
Return


/*{Protheus.doc} UBAA030DXK
(Função responsável por popular a grid direita e montar o browse)
@type function
@author 	roney.maia
@since 		13/02/2017
@version 	1.0
@param 		oPanel, objeto, (Painel onde sera incluso o browse)
@param 		oObj, objeto, (Objeto para captura da view)
@return 	${return}, ${Nil}
*/
Static Function UBAA030DXK(oPanel, oObj)	
	Local aColumns		:= {}
	Local nX		:= 0
	Local aCposBrowse	:= {}
	Local aCposQry		:= {}
	Local nAuxTam		:= 0
	
	_oBrowseDXK := FWMBrowse():New()
		
	nAuxTam := 0.40   // Indica que irei utilizar 40 % to tamanho definido no x3_tamanho para as colunas n. ficarem muito grandes

	//Define as colunas do Browse de Acordo com SX3 Para Buscar Tamanho,decimais Etc;
	aCposBrowse := {"DXK_SAFRA","DXK_ETIQ","DXK_FARDO", "DXK_CLAVIS", "DXK_PSLIQU", "DXK_PSBRUT"}
	//Define as colunas do Browse de Acordo com a Qry para Identificar os Dados
	aCposQry 	:= {"DXK_SAFRA","DXK_ETIQ","DXK_FARDO", "DXK_CLAVIS", "DXK_PSLIQU","DXK_PSBRUT"}

	
	nX := 1
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
	aColumns[Len(aColumns)]:SetTitle( AllTrim(FWX3Titulo(aCposBrowse[nX])) )
	aColumns[Len(aColumns)]:SetSize( TamSx3(aCposBrowse[nX])[1]  * nAuxTam )
	aColumns[Len(aColumns)]:SetDecimal( TamSx3(aCposBrowse[nX])[2] )
	aColumns[Len(aColumns)]:SetPicture( PesqPict("DXK", aCposBrowse[nX]) )
	aColumns[Len(aColumns)]:SetAlign( 0 )//Define alinhamento

	nX := 2
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
	aColumns[Len(aColumns)]:SetTitle( AllTrim(FWX3Titulo(aCposBrowse[nX])) )
	aColumns[Len(aColumns)]:SetSize( TamSx3(aCposBrowse[nX])[1]	)
	aColumns[Len(aColumns)]:SetDecimal( TamSx3(aCposBrowse[nX])[2] )
	aColumns[Len(aColumns)]:SetPicture( PesqPict("DXK", aCposBrowse[nX]) )
	aColumns[ Len(aColumns) ]:SetAlign( 0 )//Define alinhamento
	
	nX := 3
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
	aColumns[Len(aColumns)]:SetTitle( AllTrim(FWX3Titulo(aCposBrowse[nX])) )
	aColumns[Len(aColumns)]:SetSize( TamSx3(aCposBrowse[nX])[1]  * nAuxTam	)
	aColumns[Len(aColumns)]:SetDecimal( TamSx3(aCposBrowse[nX])[2] )
	aColumns[Len(aColumns)]:SetPicture( PesqPict("DXK", aCposBrowse[nX]) )
	aColumns[Len(aColumns)]:SetAlign( 0 )//Define alinhamento
		
	nX := 4
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||UBAA030CLS("+aCposQry[ nX ]+")}"))
	aColumns[Len(aColumns)]:SetTitle( STR0047 )	//'Classificado'
	aColumns[Len(aColumns)]:SetSize( 3 )
	aColumns[Len(aColumns)]:SetDecimal( 0 )
	aColumns[Len(aColumns)]:SetPicture( '@!' )
	aColumns[Len(aColumns)]:SetAlign( 0 )
		
	nX := 5
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
	aColumns[Len(aColumns)]:SetTitle( AllTrim(FWX3Titulo(aCposBrowse[nX])) )
	aColumns[Len(aColumns)]:SetSize( TamSx3(aCposBrowse[nX])[1]  * nAuxTam	)
	aColumns[Len(aColumns)]:SetDecimal( TamSx3(aCposBrowse[nX])[2] )
	aColumns[Len(aColumns)]:SetPicture( PesqPict("DXK", aCposBrowse[nX]) )
	aColumns[Len(aColumns)]:SetAlign( 0 )//Define alinhamento
	
	nX := 6
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||"+aCposQry[ nX ]+"}"))
	aColumns[Len(aColumns)]:SetTitle( AllTrim(FWX3Titulo(aCposBrowse[nX])) )
	aColumns[Len(aColumns)]:SetSize( TamSx3(aCposBrowse[nX])[1]  * nAuxTam	)
	aColumns[Len(aColumns)]:SetDecimal( TamSx3(aCposBrowse[nX])[2] )
	aColumns[Len(aColumns)]:SetPicture( PesqPict("DXK", aCposBrowse[nX]) )
	aColumns[Len(aColumns)]:SetAlign( 0 )//Define alinhamento
		
	_oBrowseDXK:SetDataQuery(.F.)
	_oBrowseDXK:SetDataTable(.T.)
	_oBrowseDXK:SetAlias('DXK')
	_oBrowseDXK:SetMenuDef('')
	_oBrowseDXK:SetProfileID("DXK")
	_oBrowseDXK:SetColumns( aColumns )
	_oBrowseDXK:DisableDetail()
	_oBrowseDXK:SetSeek(.T.)
	_oBrowseDXK:SetWalkThru(.F.)
	_oBrowseDXK:SetAmbiente(.F.)
	_oBrowseDXK:DisableConfig()
	_oBrowseDXK:DisableFilter()
	_oBrowseDXK:DisableReport()
	_oBrowseDXK:SetOnlyFields({'*'})
	_oBrowseDXK:SetFilterDefault("@ DXK_CODROM = ''")
	_oBrowseDXK:SetOwner(oPanel)
	_oBrowseDXK:Activate()
	_lBrowseAct := .T.	
	
Return


/*{Protheus.doc} UBAA030CLS
(Função de comparação para preencher a coluna de classificado
dependendo do tipo de classificação)
@type function
@author 	roney.maia
@since 		13/02/2017
@version 	1.0
@param 		cCampo, character, (Nome do campo a ser avaliado)
@return 	${return}, ${Retorna o valor a ser atribuido a cada linha comparada}
*/
Function UBAA030CLS(cCampo)
	Local cValor 		:= ""
	Local oModel 		:= FwModelActive()
	Local oModelN72 	:= oModel:GetModel('N72UBAA030')
	Local cTipoClas		:= oModelN72:GetValue('N72_TIPO')
	If cTipoClas == '1'
		cValor := Iif(!Empty(cCampo), 'Sim','Não')
	ElseIf cTipoClas == '2'
		cValor := Iif(Posicione("DX7", 1, xFilial("DX7") + DXK_SAFRA + DXK_ETIQ, "DX7_ATIVO") == '1', 'Sim', 'Não')
	EndIf
Return cValor


/*{Protheus.doc} UBAA030TGR
(Gatilhos para digitação manual do código da mala)
@type function
@author 	roney.maia
@since 		13/02/2017
@version 	1.0
@param 		oModel, objeto, (Modelo Ativo)
@param 		cTipGat, character, (Campo contra dominio do gatilho)
@return 	${return}, ${Retorno a ser atribuido no campo}
*/
Function UBAA030TGR(oModel, cTipGat)
	Local oModelTwo 	:= oModel:GetModel()
	Local oModelN72		:= oModelTwo:GetModel('N72UBAA030')
	Local oModelN73		:= oModelTwo:GetModel('N73UBAA030')
	Local cTipoClas		:= oModelN72:GetValue('N72_TIPO')
	Local cCodMal		:= oModelN73:GetValue('N73_CODMAL')
	Local cSafra		:= ""
	Local nValor		:= 0
	Local cValor		:= ""
	Local cQry		:= ""
	Local cAliasQry		:= GetNextAlias()
	
	If Select(cAliasQry) > 0
		(cAliasQry)->( dbCloseArea() )
	EndIf
	
	If cTipGat == 'QTD'
		cSafra := oModelN73:GetValue('N73_CODSAF')
		If cTipoClas == '1'
			nValor := 0
						
			cQry := "SELECT COUNT(DXK_CLAVIS) AS Total"
			cQry += " FROM "+ RetSqlName("DXK") + " DXK"
			cQry += " WHERE D_E_L_E_T_ <> '*'"
			cQry += " AND DXK_FILIAL = '"+xFilial("DXK")+"'"
			cQry += " AND DXK_CODROM = '"+cCodMal+"'"
			cQry += " AND DXK_SAFRA = '"+cSafra+"'"
			cQry += " AND DXK_TIPO = '" + cTipoClas + "'"
			cQry += " AND DXK_CLAVIS <> ''"		
			cQry := ChangeQuery(cQry)	
						
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
		
			//Seleciona a tabela 
			dbSelectArea(cAliasQry)
			nValor := (cAliasQry)->Total
			(cAliasQry)->(DbCloseArea())

		ElseIf cTipoClas == '2'
			nValor := 0
										
			cQry := "SELECT COUNT(DX7.DX7_ATIVO) AS Total"
			cQry += " FROM "+ RetSqlName("DX7") + " DX7"
			cQry += " INNER JOIN " + retSqlName('DXK')+" DXK" +" ON "
			cQry += " DX7_SAFRA = DXK_SAFRA"
			cQry += " AND DX7_ETIQ = DXK_ETIQ" 
			cQry += " WHERE DX7.D_E_L_E_T_ <> '*'"
			cQry += " AND DXK.D_E_L_E_T_ <> '*'"
			cQry += " AND DX7_FILIAL = '"+xFilial("DXJ")+"'"
			cQry += " AND DX7_ATIVO = '1'"
			cQry += " AND DX7_SAFRA = '"+cSafra+"'"
			cQry += " AND DXK_CODROM = '"+cCodMal+"'"
			cQry += " AND DXK_SAFRA = '"+cSafra+"'"
			cQry += " AND DXK_TIPO = '" + cTipoClas + "'"		
			cQry := ChangeQuery(cQry)				
			
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
		
			//Seleciona a tabela 
			dbSelectArea(cAliasQry)
			nValor := (cAliasQry)->Total
			(cAliasQry)->(DbCloseArea())
		EndIf
	ElseIf cTipGat == 'SAF'
		cValor := Posicione("DXJ", 1, xFilial("DXJ") + cCodMal, "DXJ_SAFRA")
	ElseIf cTipGat == 'TIP'
		cValor := Posicione("DXJ", 1, xFilial("DXJ") + cCodMal, "DXJ_TIPO")
		If	!IsBlind()
			_oBrowseDXK:SetFocus()
		EndIf
	EndIf
Return Iif(cTipGat == 'QTD', nValor, cValor)

/*{Protheus.doc} UBAA030CON
(Filtro da consulta padrão DXJN73)
@type function
@author 	roney.maia
@since 		13/02/2017
@version 	1.0
@return 	${return}, ${Filtro}
*/
Function UBAA030CON()
	Local oModel	:= FwModelActive()
	Local oModelN72	:= oModel:GetModel('N72UBAA030')
	Local cTipoClas	:= oModelN72:GetValue('N72_TIPO')
	Local cSafra	:= oModelN72:GetValue('N72_SAFRA')
	Local dTamDtEnv	:= Space( TamSX3("DXJ_DATENV")[1] ) 
	Local dTamDtRec := Space( TamSX3("DXJ_DATREC")[1] )
	Local cFiltro 	:= ""
	Local nTipoUm	:= ""
	
	If cTipoClas == '1'		//**Visual
		nTipoUm 	:= '1'		//Visual - Pendente
	ElseIf cTipoClas == '2'	//**HVI
		nTipoUm 	:= '4'		//HVI - Pendente
	EndIf
	
	//--Filtro da consulta DXJN73
	cFiltro += "@ D_E_L_E_T_ <> '*'
	cFiltro += " AND DXJ_FILIAL 	= '"+xFilial("DXJ")+"'"
	cFiltro += " AND DXJ_SAFRA 		= '"+cSafra+"'"
	cFiltro += " AND DXJ_TIPO 		= '" + cTipoClas + "'"
	cFiltro += " AND DXJ_DATENV 	= '" + dTamDtEnv + "'"
	cFiltro += " AND DXJ_DATREC 	= '" + dTamDtRec + "'"
	cFiltro += " AND DXJ_STATUS 	= '" + nTipoUm + "' " 
	cFiltro += " AND NOT EXISTS (SELECT * FROM "+ retSqlName('N73')+" N73"+", "+retSqlName('N72')+" N72" 
	cFiltro +=                    " WHERE N73.D_E_L_E_T_ <> '*'"
	cFiltro +=                    "   AND N73_FILIAL = DXJ_FILIAL "
	cFiltro +=                    "   AND N73_CODMAL = DXJ_CODIGO "
    cFiltro +=                    "   AND N73_CODSAF = DXJ_SAFRA "	
    cFiltro +=                    "   AND N73_TIPO = DXJ_TIPO "	
    cFiltro +=                    "   AND N72_FILIAL = N73_FILIAL "	
    cFiltro +=                    "   AND N72_SAFRA = N73_CODSAF "
    cFiltro +=                    "   AND N72_CODREM = N73_CODREM "
    cFiltro +=                    "   AND N72.D_E_L_E_T_ <> '*'"    	 
	cFiltro +=                    "   AND N72_STATUS <> '5') "
	//--Por se tratar de uma consulta SXB - se colocar o ChangeQuery a consulta trava.
	//--Nesse caso, utilizamos a função TamSx3() para enviar o tamanho do campo Data.
	
Return cFiltro

/*{Protheus.doc} UBAA030CDM
(Validação do Campo Cod.Mala, CODMAL)
@type function
@author roney.maia
@since 24/02/2017
@version 1.0
@return ${Lógico}, ${.T. = Valido, .F. = Inválido}
*/
Function UBAA030CDM()
	
	Local oModel	:= FwModelActive()
	Local oModelN72	:= oModel:GetModel('N72UBAA030')
	Local lRet 		:= .T.
	Local lRetN73 	:= .F. 
	Local lRetDXJ := ExistCpo("DXJ", PADR(oModelN72:GetValue("N72_SAFRA"),TAMSX3('DXJ_SAFRA')[1],' ')+FwFldGet("N73_CODMAL")+oModelN72:GetValue("N72_TIPO"), 3) // Verifica se o codigo unico existe na DXJ
	
	Local cCampo	:= ""
	Local lN72Vld	:= Iif(!Empty(oModelN72:GetValue("N72_SAFRA")) ;
							.AND. !Empty(oModelN72:GetValue("N72_TIPO")), .T., .F.)
	Local aArea		:= GetArea()
	Local cAliasQry := ""
	Local cQry 		:= ""

	cAliasQry := GetNextAlias()
	//Verifica no banco de dados se essa mala já não está relacionada à alguma remessa. A remessa não pode estar cancelada
	cQry := "SELECT DISTINCT N73_CODMAL FROM "+ retSqlName('N73')+" N73"+", "+retSqlName('N72')+" N72" 
	cQry += " WHERE N73.D_E_L_E_T_ <> '*'"
	cQry += "   AND N73_FILIAL 	= '"+xFilial("N73")+"'"
	cQry += "   AND N73_CODMAL = '"+FwFldGet("N73_CODMAL")+"'"
    cQry += "   AND N73_CODSAF = '"+oModelN72:GetValue("N72_SAFRA")+"'"
    cQry += "   AND N73_TIPO = '"+oModelN72:GetValue("N72_TIPO")+"'"	
    cQry += "   AND N72_FILIAL = N73_FILIAL "	
    cQry += "   AND N72_SAFRA = N73_CODSAF "
    cQry += "   AND N72_CODREM = N73_CODREM "
    cQry += "   AND N72.D_E_L_E_T_ <> '*'"    	 
	cQry += "   AND N72_STATUS <> '5' "
	cQry := ChangeQuery(cQry)
	
	If Select(cAliasQry) > 0
		(cAliasQry)->( dbCloseArea() )
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) //Se encontrou registros é porque a mala já está relacionada à uma remessa
		lRetN73 	:= .T.
		Exit
	EndDo

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)

	If !lN72Vld // Validação de campos obrigatórios
		If Empty(oModelN72:GetValue("N72_SAFRA"))
			cCampo := STR0054 // "Campo (Safra*) não foi preenchido."
		ElseIf  Empty(oModelN72:GetValue("N72_TIPO"))
			cCampo := STR0055 // "Campo (Tipo.Classif*) não foi selecionado."
		EndIf
		Help('', 1, STR0053, , cCampo, 1) // Atenção# ?
		Return .F.	
	EndIf
	
	If !lRetN73 .AND. lRetDXJ
		lRet := .T.
	Else
		If Vazio() .OR. !lRetDXJ // Se Vazio ou não possui mala na DXJ
			Help('', 1, STR0053, , STR0056, 1 ) // #Atenção#"Mala Inválida para essa remessa."#
		EndIf
		If lRetN73 // Se a mala ja existe vinculado a uma remessa
			Help('', 1, STR0053, , STR0057, 1 ) // #Atenção#"Mala já inclusa ou relacionada a outra remessa."#
		EndIf
		lRet := .F.
	EndIf
	
Return lRet

/*{Protheus.doc} UBAA030SAF
(Validação do Campo Safra, SAFRA)
@type function
@author janaina.duarte
@since 15/03/2017
@version 1.0
@return ${Lógico}, ${.T. = Valido, .F. = Inválido}
*/
Function UBAA030SAF()
	
	Local oModel	:= FwModelActive()
	Local oModelN72	:= oModel:GetModel('N72UBAA030')
	Local lRet 		:= .T.
	Local lRetNJU 	:= ExistCpo("NJU", FwFldGet("N72_SAFRA"), 1) // Verifica se o codigo unico existe na NJU
	Local lN72Vld	:= Iif(!Empty(oModelN72:GetValue("N72_SAFRA")), .T., .F.)

	If !lN72Vld // Validação de campos obrigatórios
		If Empty(oModelN72:GetValue("N72_SAFRA"))
			Help('', 1, STR0053, , STR0054, 1) // #Atenção#"Campo (Safra*) não foi preenchido."#
			Return .F.	
		EndIf
	EndIf
	
	If lRetNJU
		lRet := .T.
	Else
		If Vazio() .OR. !lRetNJU // Se Vazio ou não possui safra na NJU
			Help('', 1, STR0053, , STR0064, 1 ) // #Atenção#"Campo (Safra*) inválido."#
   		    lRet := .F.
		EndIf
	EndIf
	
Return lRet

/** {Protheus.doc} UBAA030HIS
Apresenta em tela de Historico do contrato

@param:     Nil
@author:    Marcelo Wesan
@since:     14/02/2017
@Uso:       UBAA030HIS
*/
Function UBAA030HIS()
	Local cChaveI := "N72->("+Alltrim(AGRSEEKDIC("SIX","N721",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("N72",cChaveA)
Return

/*{Protheus.doc} UBAA030POS
Função de ultima atualização antes do commit

@type 		function
@author 	roney.maia
@since 		17/02/2017
@version 	1.0
@param 		oModel, objeto, (oModel)
@return 	${return}, ${.T. - Valido, .F. - Inválido}
*/
Static Function UBAA030POS(oModel)
	Local lRetorno 		:= .T.
	Local lContinua		:= .T.
	Local nOperation 	:= oModel:GetOperation()
	Local oModelN72		:= oModel:GetModel('N72UBAA030')

	//*Para a rotina UBAF030 (função NFS - NFD e REC) não realizar alteração
	If IsInCallStack("UBAF030NFS") 
		lContinua := .F.
	ElseIf IsInCallStack("UBAF030NFD")
		lContinua := .F.
	ElseIf IsInCallStack("UBAF030REC")
		lContinua := .F.	
	EndIf

	If lContinua .AND. IsInCallStack("UBAA030") .And. !IsInCallStack("UBAF030EST") 
		
		//Atualiza campo Cliente/Fornecedor e Loja
		UBAA030CLI()	
 		
		// Validação para permitir alterar a remessa somente quando em status de (Iniciado)
		If nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE
			If lRetorno
			   	DbSelectArea("N73")	//Malas
			   	DbSetOrder(1)
			   	If DbSeek( xFilial("N73") + oModelN72:GetValue('N72_SAFRA') + oModelN72:GetValue('N72_CODREM') )
			   		While .Not. N73->(Eof()) .AND. N73->N73_CODSAF == oModelN72:GetValue('N72_SAFRA') .AND. N73->N73_CODREM == oModelN72:GetValue('N72_CODREM')
			   			If .NOT. Empty(N73->N73_PEDREM)
			   				lRetorno := .F.
			   				If nOperation == MODEL_OPERATION_UPDATE
			   					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0050+Alltrim(N73->N73_PEDREM), "", "", "") //"Não é possível alterar, remessa com pedido vinculado! Pedido: "
			   				ElseIf nOperation == MODEL_OPERATION_DELETE
			   					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0051+Alltrim(N73->N73_PEDREM), "", "", "") //"Não é possível exluir remessa com pedido vinculado! Pedido: "
			   				EndIf
			   				Exit
			   			EndIf 
			   			dbSkip()
			   		EndDo 	
				EndIf	//Fim Malas
			EndIf 	//Fim lRetorno			
		EndIf	//Fim Operação  
	EndIf	//Fim IsInCallStack
Return lRetorno

//-----------------------------------------------------------
/*/{Protheus.doc} U030VLDACT
Validação a inicialização do modelo de dados

@param: Nil
@author: silvana.torres
@since: 18/04/2017
@Uso: UBAA030
/*/
//-----------------------------------------------------------
Static Function U030VLDACT(oModel)
	Local lRet 		:= .T.
	Local nAcao		:= oModel:GetOperation()
	 
	// Validação para permitir alterar a remessa somente quando em status de (Iniciado)
	If IsInCallStack("UBAA030")	.And. !IsInCallStack("UBAF030EST") .And. !IsInCallStack("UBAF030REC")
		If nAcao == MODEL_OPERATION_UPDATE .OR. nAcao == MODEL_OPERATION_DELETE
			If N72->N72_STATUS != '1' .And. (N72->N72_STATUS != '4' .And. IsInCallStack("UBAF030REC"))  // Status '1' = Inciado ou (é Recebimento e Status '4' = Rec Parcial)
				If nAcao == MODEL_OPERATION_UPDATE
					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0041, "", "", "") // "Alterar a remessa somente é possível em status (Iniciado)"
				ElseIf nAcao == MODEL_OPERATION_DELETE
					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0052, "", "", "") // "Excluir a remessa somente é possível em status (Iniciado)"
				EndIf
			
				lRet := .F.
			EndIf
		endif
	endif
	
Return(lRet)


//-------------------------------------------------------------------------------
/*/{Protheus.doc} UBAA030VCL
Valida o codigo do cliente ou fornecedor

@param: Nil
@author: carlos.augusto
@since: 02/05/2017
@Uso: UBAA030
/*/
//-------------------------------------------------------------------------------
Function UBAA030VCL() 
	Local lRet 			:= .T.
	Local oModel 		:= FwModelActive()
	Local oModelN72 	:= oModel:GetModel('N72UBAA030')
	
	If oModelN72:GetValue('N72_TPDOC') == "N"
		lRet := ExistCpo('SA1', M->(N72_CODCLI), 1)		
	Else
		lRet := ExistCpo('SA2', M->(N72_CODCLI), 1) 
	EndIf
	
	If !IsInCallStack("GETLKRET")
	 	oModelN72:SetValue("N72_LOJCLI","")
	EndIf

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} UBAA030VLJ
Valida a loja do cliente ou fornecedor

@param: Nil
@author: carlos.augusto
@since: 02/05/2017
@Uso: UBAA030
/*/
//-------------------------------------------------------------------------------
Function UBAA030VLJ()
	Local lRet 			:= .T.
	Local oModel 		:= FwModelActive()
	Local oModelN72 	:= oModel:GetModel('N72UBAA030')

	If oModelN72:GetValue('N72_TPDOC') == "N"
		lRet := ExistCpo('SA1', M->(N72_CODCLI + N72_LOJCLI), 1)
		
	Else
		lRet := ExistCpo('SA2', M->(N72_CODCLI + N72_LOJCLI), 1)
	EndIf
Return lRet


//-------------------------------------------------------------------------------
/*/{Protheus.doc} UBAA030CLI
Atualiza o campo N72_LOJCLI. Cliente ou Fornecedor

@param: Nil
@author: carlos.augusto
@since: 08/05/2017
@Uso: UBAA030
/*/
//-------------------------------------------------------------------------------
Function UBAA030CLI()
	Local oViewAux    	:= FWViewActive()
	Local oModel 		:= FwModelActive()
	Local oModelN72 	:= oModel:GetModel('N72UBAA030')
	Local cTipoClas		:= oModelN72:GetValue('N72_TIPO')
	Local nOperation	:= oModel:GetOperation()

	If  nOperation == MODEL_OPERATION_INSERT	
		If cTipoClas == '1'
			If ExistBlock('UB030001')
				cPergunta := ExecBlock('UB030001',.F.,.F.) //Retorna nome do pergunte especifico
				Pergunte(cPergunta,.T.)	//Pergunte Especifico para expedição de amostras visuais
			Else
				Pergunte('UBAA030I',.F.)	//Pergunte-SX1 Visual
			EndIf
			
			If mv_par01 == 1
				oModelN72:SetValue("N72_TPDOC","N")
			Else 
				oModelN72:SetValue("N72_TPDOC","B")
				
			EndIf
		ElseIf cTipoClas == '2'
			If ExistBlock('UB030002')
				cPergunta := ExecBlock('UB030002',.F.,.F.) //Retorna nome do pergunte especifico
				Pergunte(cPergunta,.F.)	//Pergunte Especifico para expedição de amostras visuais
			Else
				Pergunte('UBAA030E',.F.)	//Pergunte-SX1 HVI
			EndIf
					
			If mv_par01 == 1
				oModelN72:SetValue("N72_TPDOC","N")
			Else 
				oModelN72:SetValue("N72_TPDOC","B")
			EndIf
		EndIf
	EndIf
	
 	oViewAux:GetViewObj("UBAA030_N72")[3]:GetFWEditCTRL("N72_CODCLI"):OCTRL:CCAPTION := ;
 		"<b>" + IIF(oModelN72:GetValue('N72_TPDOC') == "N", STR0067, STR0066)  +"<font color=red size=2 face=verdana,helvetica>*</font></b>" //Cliente, Fornecedor 
 				
 	oViewAux:GetViewObj("UBAA030_N72")[3]:GetFWEditCTRL("N72_CODCLI"):OCTRL:CF3 := IIF(oModelN72:GetValue('N72_TPDOC') == "N", "SA1", "SA2A")
 	
Return .T.

//-------------------------------------------------------------------------------
/*/{Protheus.doc} UBAA030WNM
Atualiza o campo N72_NOMCLI. Cliente ou Fornecedor

@param: Nil
@author: carlos.augusto
@since: 16/05/2017
@Uso: UBAA030
/*/
//-------------------------------------------------------------------------------
Function UBAA030WNM()
	Local oModel 		:= FwModelActive()
	Local oModelN72 	:= oModel:GetModel('N72UBAA030')
	Local cTemp := ""

	If oModelN72:GetValue('N72_TPDOC') == "N"
		If !Empty(M->N72_CODCLI) .And. !Empty(M->N72_LOJCLI)
			cTemp := Posicione("SA1",1,xFilial('SA1')+oModelN72:GetValue("N72_CODCLI")+oModelN72:GetValue("N72_LOJCLI"),"A1_NOME")
		EndIf
	Else
		If !Empty(M->N72_CODCLI) .And. !Empty(M->N72_LOJCLI)
			cTemp := Posicione("SA2",1,xFilial('SA2')+oModelN72:GetValue("N72_CODCLI")+oModelN72:GetValue("N72_LOJCLI"),"A2_NOME")
		EndIf
	EndIf

	oModelN72:SetValue("N72_NOMCLI", cTemp)

Return .T.

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "AGRX510A.CH"

Static __cAliasC	:= Nil
Static __oArqTemp	:= Nil

//===================================================
/***** AGRX510A ***** Funções da rotina AGRA510 *****/
//===================================================

/*/{Protheus.doc} AGRX510ACO  
//Função da consulta especifica N92GVI - Operações GFE x AGRO

@author		Ana Laura Olegini
@since 		28/03/2018
@return 	lRetorno, Retorno lógico - .T. = True .F. = Falso
/*/
Function AGRX510ACO()
	Local aArea     	:= GetArea()
	Local aFieldFilt 	:= {} 
	Local aSeek 		:= {}
	Local lRetorno     	:= .T.
	Local oBrowse		:= Nil
	Local oDlg	    	:= Nil
	Local oPnDown   	:= Nil
	Local oSize     	:= Nil

	Private _aColumns 	:= {}
	
	//-- Pega a proxima tabela
	__cAliasC 	:= GetNextAlias()
	
	//-- Cria tabela temporaria para browse
	__cAliasC := sFCriaTemp(@_aColumns , @__cAliasC)

	//--Verifica se a tabela temporaria foi preenchida.
	If .NOT. Empty( (__cAliasC)->GVI_CDOPER )
		oSize := FWDefSize():New(.T.)
		oSize:AddObject( "ALL", 100, 100, .T., .T. )    
		oSize:lLateral	:= .F.  	// Calculo vertical	
		oSize:Process() 			// Executa os calculos
						       /*nTop*/                  /*nLeft*/               /*nBottom*/              /*nRight*/              /*cCaption*/                  
		oDlg 	:= TDialog():New( oSize:aWindSize[1]/1.55, oSize:aWindSize[2]/1.55, oSize:aWindSize[3]/1.55, oSize:aWindSize[4]/1.55, STR0002 , , , , , CLR_BLACK, CLR_WHITE, , , .T. ) //STR0002 -'Consulta Específica Operações GFE'
		oPnDown := TPanel():New( oSize:GetDimension("ALL","LININI"), oSize:GetDimension("ALL","COLINI"), ,oDlg, ,.F. , , , ,oSize:GetDimension("ALL","COLEND")/1.57, oSize:GetDimension("ALL","LINEND")/1.90)
	
		//-- Filtros da consulta
		aAdd(aFieldFilt, {"GVI_CDOPER", AGRTITULO("GVI_CDOPER"), TamSX3("GVI_CDOPER")[3], TamSX3("GVI_CDOPER")[1], TamSX3("GVI_CDOPER")[2], PesqPict("GVI", "GVI_CDOPER")} )
		aAdd(aFieldFilt, {"GVI_SEQ",  	AGRTITULO("GVI_SEQ"), 	 TamSX3("GVI_SEQ")[3],    TamSX3("GVI_SEQ")[1],    TamSX3("GVI_SEQ")[2] ,   PesqPict("GVI", "GVI_SEQ")   } )
		
		//-- Pesquisa Indice da consulta
		nTam := TamSX3("GVI_FILIAL")[1] + TamSX3("GVI_CDOPER")[1] + TamSX3("GVI_SEQ")[1] + 3
		Aadd(aSeek,{ STR0003 ,{{"", 'C' , nTam, 0 , "@!" }}, 1, .T. } ) //'Filial + Operacao + Seq'
		
		oBrowse := FWMBrowse():New()
		oBrowse:SetDescription(STR0002)		//STR0002-'Consulta Específica Operações GFE'
		oBrowse:SetTemporary(.T.)	
		oBrowse:SetAlias(__cAliasC)
		oBrowse:SetSeek(.T.,aSeek)
		oBrowse:SetColumns(_aColumns)
		oBrowse:SetOwner(oDlg)	
		oBrowse:SetDoubleClick( {|| .T., oDlg:End() })	
		oBrowse:SetUseFilter(.T.)			//Habilita a utilização do filtro no Browse.
		oBrowse:SetdbFFilter(.T.)
		oBrowse:SetUseCaseFilter(.T.)		//Habilita a utilização do filtro case no Browse.
		oBrowse:SetFieldFilter(aFieldFilt)	//Indica os campos que serão apresentados na edição de filtros.
		oBrowse:SetMenuDef("")
		oBrowse:DisableDetails()
		oBrowse:Activate(oPnDown)
	
		oDlg:Activate( , , , .T., { || .T. }, , { || EnchoiceBar(oDlg,{|| .T., oDlg:End()},{|| oDlg:End() },,/* @aButtons */) } )
	Else
		Help(" ",1,".AGRX510A0001.")	//Não foram encontradas Conf. de Operação GFE com o Tipo de Controle informado na aba "Principal".
		lRetorno := .F.					//#Verifique o Tipo de Controle e a Config de Operação.
		
	EndIf
	RestArea(aArea)

Return lRetorno


/*{Protheus.doc} sFCriaTemp
Função cria tabela temporaria 

@author 	ana.olegini
@since 		28/03/2018
@param 		_aColumns, , descricao
@param 		__cAliasC, , descricao
@return 	return, return_description
*/
Static Function sFCriaTemp(_aColumns , __cAliasC)
	Local aIndices 	:= {}
	Local aCampIni2 := {}

	//Definindo as colunas do Browse	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))

	AAdd(_aColumns,FWBrwColumn():New())
	_aColumns[Len(_aColumns)]:SetData( &("{||"+'GVI_FILIAL'+"}"))
	_aColumns[Len(_aColumns)]:SetTitle(AGRTITULO("GVI_FILIAL"))	  
	_aColumns[Len(_aColumns)]:SetSize( TamSX3("GVI_FILIAL")[1] )
	_aColumns[Len(_aColumns)]:SetDecimal( TamSX3("GVI_FILIAL")[2] )
	_aColumns[Len(_aColumns)]:SetPicture("")
	_aColumns[Len(_aColumns)]:SetAlign( "LEFT" )//Define alinhamento	

	AAdd(_aColumns,FWBrwColumn():New())
	_aColumns[Len(_aColumns)]:SetData( &("{||"+'GVI_SEQ'+"}"))
	_aColumns[Len(_aColumns)]:SetTitle(AGRTITULO("GVI_SEQ"))	  
	_aColumns[Len(_aColumns)]:SetSize( TamSX3("GVI_SEQ")[1] )
	_aColumns[Len(_aColumns)]:SetDecimal( TamSX3("GVI_SEQ")[2] )
	_aColumns[Len(_aColumns)]:SetPicture("")
	_aColumns[Len(_aColumns)]:SetAlign( "LEFT" )//Define alinhamento	

	AAdd(_aColumns,FWBrwColumn():New())
	_aColumns[Len(_aColumns)]:SetData( &("{||"+'GVI_CDOPER'+"}"))
	_aColumns[Len(_aColumns)]:SetTitle(AGRTITULO("GVI_CDOPER"))
	_aColumns[Len(_aColumns)]:SetSize( TamSX3("GVI_CDOPER")[1] )
	_aColumns[Len(_aColumns)]:SetDecimal( TamSX3("GVI_CDOPER")[2] )
	_aColumns[Len(_aColumns)]:SetPicture("")
	_aColumns[Len(_aColumns)]:SetAlign( "LEFT" )//Define alinhamento

	AAdd(_aColumns,FWBrwColumn():New())
	_aColumns[Len(_aColumns)]:SetData( &("{||"+'GVI_DSOPER'+"}"))
	_aColumns[Len(_aColumns)]:SetTitle(AGRTITULO("GVI_DSOPER"))
	_aColumns[Len(_aColumns)]:SetSize(TamSX3("GVI_DSOPER")[1])
	_aColumns[Len(_aColumns)]:SetDecimal(TamSX3("GVI_DSOPER")[2])
	_aColumns[Len(_aColumns)]:SetPicture("")
	_aColumns[Len(_aColumns)]:SetAlign( "LEFT" )//Define alinhamento	

	AAdd(_aColumns,FWBrwColumn():New())
	_aColumns[Len(_aColumns)]:SetData( &("{||"+'GVC_SENTID'+"}"))
	_aColumns[Len(_aColumns)]:SetTitle(AGRTITULO("GVC_SENTID")) 
	_aColumns[Len(_aColumns)]:SetSize(08)
	_aColumns[Len(_aColumns)]:SetDecimal(0)
	_aColumns[Len(_aColumns)]:SetPicture("")
	_aColumns[Len(_aColumns)]:SetAlign( "LEFT" )//Define alinhamento

	//Limpando temp Table - Funcao do AGRUTIL01
	If __oArqTemp <> Nil
		AGRDLTPTB(@__oArqTemp, NIL, .T.)
	EndIf

	//Definindo as colunas na temp table
	AADD(aCampIni2,{'GVI_FILIAL', TamSX3("GVI_FILIAL")[3],TamSX3("GVI_FILIAL")[1], TamSX3("GVI_FILIAL")[2]})		 	
	AADD(aCampIni2,{'GVI_CDOPER', TamSX3("GVI_CDOPER")[3],TamSX3("GVI_CDOPER")[1], TamSX3("GVI_CDOPER")[2]})
	AADD(aCampIni2,{'GVI_SEQ'	, TamSX3("GVI_SEQ")[3]	 ,TamSX3("GVI_SEQ")[1]   , TamSX3("GVI_SEQ")[2]})
	AADD(aCampIni2,{'GVI_DSOPER', TamSX3("GVI_DSOPER")[3],TamSX3("GVI_DSOPER")[1], TamSX3("GVI_DSOPER")[2]})
	AADD(aCampIni2,{'GVC_SENTID', "C", 08, 0})	//Deixar com tamanho 10 pois o campo recebe texto - o campo GVC_SENTID somente tem tamanho de 01.

	aAdd(aIndices, {"1", "GVI_FILIAL,GVI_CDOPER,GVI_SEQ" })
	
	//-- Cria tabela temporaria - Funcao do AGRUTIL01
	__oArqTemp  := AGRCRTPTB(__cAliasC, {aCampIni2, aIndices },,,,.F. )	
	//-- Funcao cria consulta
	__cAliasC := sFCposCons( @__cAliasC )

Return __cAliasC


/*{Protheus.doc} sFCposCons
Funcao cria consulta 

@author 	ana.olegini
@since 		28/03/2018
@param 		__cAliasC, Tabela Temporaria
@return 	__cAliasC, Tabela Temporaria  
*/
Static Function sFCposCons( __cAliasC )
	Local oModel	:= FWModelActive()
	Local cAliasQry := GetNextAlias()
	Local cQuery	:= ""
	Local cSentido	:= ""
	
	//--Verifica qual o tipo do romaneio - entrada ou saída
	If oModel:GetValue('MdFieldN92', 'N92_TIPO') $ "1|3|5|7|9|A" 	//Entrada	
		cSentido := "1" //1- Entrada
	ElseIf oModel:GetValue('MdFieldN92', 'N92_TIPO') $ "2|4|6|8|B" 	//Saída
		cSentido := "2" //2- Saída
	EndIf
	/*
	//--Query para selecionar as informações da consulta especifica
	cQuery += " SELECT  GVI.GVI_FILIAL, GVI.GVI_SEQ, GVI.GVI_CDOPER, GVC.GVC_SENTID "
	cQuery +=   " FROM  "+ RetSqlName("GVI") +" GVI "
	cQuery +=  " INNER JOIN "+ RetSqlName("GVC") +" GVC ON GVC.D_E_L_E_T_ = '' " 
	cQuery +=                                       " AND GVC.GVC_FILIAL = GVI.GVI_FILIAL"
	cQuery +=                                       " AND GVC.GVC_CDOPER = GVI.GVI_CDOPER"
	cQuery +=                                       " AND GVC.GVC_SENTID = '" + cSentido + "' "
	cQuery +=  " WHERE GVI.D_E_L_E_T_ = '' "
	cQuery +=    " AND GVI.GVI_FILIAL = '" + FWxFilial('GVI') + "' "
	cQuery +=  " ORDER BY GVI.GVI_CDOPER, GVI.GVI_SEQ "
	*/
	
	//--Query para selecionar as informações da consulta especifica
	cQuery += " SELECT  GVI.GVI_FILIAL, GVI.GVI_SEQ, GVI.GVI_CDOPER, GVC.GVC_SENTID "
	cQuery +=   " FROM  "+ RetSqlName("GVI") +" GVI "
	cQuery +=  " INNER JOIN "+ RetSqlName("GVC") +" GVC ON GVC.D_E_L_E_T_ = '' " 
	cQuery +=                                       " AND GVC.GVC_FILIAL = '" + FWxFilial('GVC') + "' "
	cQuery +=                                       " AND GVC.GVC_CDOPER = GVI.GVI_CDOPER"
	cQuery +=                                       " AND GVC.GVC_SENTID = '" + cSentido + "' "
	cQuery +=  " WHERE GVI.D_E_L_E_T_ = '' "
	cQuery +=    " AND GVI.GVI_FILIAL = '" + FWxFilial('GVI') + "' "
	cQuery +=  " ORDER BY GVI.GVI_CDOPER, GVI.GVI_SEQ "
	
	
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )	
	
	//Carrega os campos da tabela selecionada
	While .NOT. (cAliasQry)->(Eof()) .AND. (cAliasQry)->GVI_FILIAL == FWxFilial("GVI")
		
		Reclock(__cAliasC, .T.)
			Replace (__cAliasC)->GVI_FILIAL	With (cAliasQry)->GVI_FILIAL
			Replace (__cAliasC)->GVI_SEQ  	With (cAliasQry)->GVI_SEQ
			Replace (__cAliasC)->GVI_CDOPER	With (cAliasQry)->GVI_CDOPER
			Replace (__cAliasC)->GVI_DSOPER With Posicione("GVI",1,FWxFilial("GVI")+(cAliasQry)->GVI_CDOPER+(cAliasQry)->GVI_SEQ,"GVI_DSCONF")
			Replace (__cAliasC)->GVC_SENTID With If( (cAliasQry)->GVC_SENTID == '1', STR0004, STR0005 )	//1- Entrada ou 2- Saída
		(__cAliasC)->(MsUnlock())
		
		(cAliasQry)->( dbSkip() )
	EndDo

Return __cAliasC


/*{Protheus.doc} AGRX510AR1
Função de retorno da consulta N92GVI
- consulta especifica de operações GFE x AGRO

@author 	ana.olegini
@since 		28/03/2018
@return 	Código da Operação
*/
Function AGRX510AR1()
	Local oModel	:= FWModelActive()

	oModel:LoadValue('MdFieldN92', 'N92_CDOPER',	(__cAliasC)->GVI_CDOPER)
	
Return oModel:getValue('MdFieldN92', 'N92_CDOPER')


/*{Protheus.doc} AGRX510AR2
Função de retorno da consulta N92GVI
- consulta especifica de operações GFE x AGRO

@author 	ana.olegini
@since 		28/03/2018
@return 	Descrição da Operação
*/
Function AGRX510AR2()
	Local oModel	:= FWModelActive()
	
	oModel:LoadValue('MdFieldN92', 'N92_DSOPER',	(__cAliasC)->GVI_DSOPER)
	
Return oModel:getValue('MdFieldN92', 'N92_DSOPER')


/*{Protheus.doc} AGRX510AR3
Função de retorno da consulta N92GVI
- consulta especifica de operações GFE x AGRO

@author 	ana.olegini
@since 		28/03/2018
@return 	Sequência da Operação
*/
Function AGRX510AR3()
	Local oModel	:= FWModelActive()
	
	oModel:LoadValue('MdFieldN92', 'N92_SEQOP',	(__cAliasC)->GVI_SEQ)
	
Return oModel:getValue('MdFieldN92', 'N92_SEQOP')


/*{Protheus.doc} AGRX510AGF
Função de validação do campo N92_CDOPER
- validação esta no SX3 - X3_VALID do campo N92_CDOPER

@author 	ana.olegini
@since 		28/03/2018
@return 	Retorno .T. para verdadeiro ou .F. para falso
*/
Function AGRX510AGF(cCodOper, cTipo) 	
	Local aArea   	:= GetArea()
	Local lRetorno	:= .T.
	Local oModel	:= FWModelActive()
	Local oGridN93 	:= oModel:GetModel('MdGridN93')
	Local nX
	Local lLimpPtCt	:= .F. 		
	Local oView 	:= FwViewActive()
	
	If Vazio() 
		//busca todos as etapas
		For nX := 1 to oGridN93:Length()
		    oGridN93:GoLine(nX)
		    
		    If !oGridN93:IsDeleted()
		    	oGridN93:LoadValue("N93_CDPTCT" , "") //limpa os pontos de controle das etapas
		    	oGridN93:LoadValue("N93_CDPERG" , "") //limpa os perguntes das etapas
		    	
		    	lLimpPtCt := .T.
		    EndIf
		Next nX		
	Else
		if ExistCpo('GVI',FwFldGet('N92_CDOPER'),1) 

			dbSelectArea("GVC")
			GVC->(dbSetOrder(1))
			
			If GVC->(MsSeek(FWxFilial("GVC") + cCodOper ))		
				
				If cTipo $ "1|3|5|7|9|A"	//Entrada
					If GVC->GVC_SENTID ==  "2" //2- saída
						lRetorno := .F.
						Help(" ",1,".AGRX510A0002.")	//A operação informada é referente a Saída.#Favor informar uma operação referente a Entrada.
					EndIf
					
				ElseIf cTipo $ "2|4|6|8|B"	//Saída
					If GVC->GVC_SENTID ==  "1" //1- entrada
						lRetorno := .F.
						Help(" ",1,".AGRX510A0003.")	//A operação informada é referente a Entrada.#Favor informar uma operação referente a Saída.			
					EndIf
				EndIf
			EndIf
			
			GVC->(DbCloseArea())
			
			If lRetorno
				//busca todos as etapas
				For nX := 1 to oGridN93:Length()
				    oGridN93:GoLine(nX)
				    
				    If !oGridN93:IsDeleted()
				    	oGridN93:LoadValue("N93_CDPTCT" , "") //limpa os pontos de controle das etapas
				    	oGridN93:LoadValue("N93_CDPERG" , "") //limpa os perguntes das etapas
				    	
				    	lLimpPtCt := .T.
				    EndIf
				Next nX		
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)
	
	If lRetorno .AND. lLimpPtCt
		oView:Refresh("VIEW_N93")
	EndIf
					
Return lRetorno


/*/{Protheus.doc} AX510AFGVF
Filtro da consulta padrão GVFN93 para considerar a operação GFE escolhida
@author silvana.torres
@since 21/05/2018
@version undefined

@type function
/*/
Function AX510AFGVF()
	Local oModel	:= FwModelActive()
	Local oModelN92	:= oModel:GetModel('MdFieldN92')
	Local cCdOper	:= oModelN92:GetValue('N92_CDOPER')
	Local cFiltro 	:= ""
	
	/*
	//--Filtro da consulta GVFN93
	cFiltro += "@ D_E_L_E_T_ <> '*'
	cFiltro += " AND GVF_CDPTCT IN (SELECT GVJ_CDPTCT FROM "+ retSqlName('GVJ')+" GVJ "
	cFiltro += "					 WHERE GVJ_FILIAL = GVF_FILIAL "
	cFiltro += "					   AND GVJ_CDOPER = '" + cCdOper + "' ) " 
	*/
	
		//--Filtro da consulta GVFN93
	cFiltro += "@ D_E_L_E_T_ <> '*'
	cFiltro += " AND GVF_CDPTCT IN (SELECT GVJ_CDPTCT FROM "+ retSqlName('GVJ')+" GVJ "
	cFiltro += "					 WHERE GVJ_FILIAL = '" + FWxFilial('GVJ') + "' "
	cFiltro += "					   AND GVJ_CDOPER = '" + cCdOper + "' ) " 
	
	
Return cFiltro

/*/{Protheus.doc} AX510AVPtC
Valida ponto de controle da etapa, de acordo com a configuração da operação no GFE
@author silvana.torres
@since 18/05/2018
@version undefined

@type function
/*/
Function AX510AVPtC()
	
	Local aArea   	:= GetArea()
	Local oModel	:= FwModelActive()
	Local oGridN93 	:= oModel:GetModel('MdGridN93')
	Local oModelN92	:= oModel:GetModel('MdFieldN92')
	Local lRet 		:= .T.
	Local nLinha	:= oGridN93:GetLine()
	Local cValor	:= FwFldGet("N93_CDPTCT")
	Local cCdOper	:= oModelN92:GetValue('N92_CDOPER')
	Local nX	
	Local cQuery	:= ""
	Local cAliasQry := GetNextAlias()
	
	If .NOT. Vazio()
		if ExistCpo('GVF',cValor,1)
		
			cQuery = " SELECT 1 "
			cQuery += "   FROM  "+ RetSqlName("GVJ") +" GVJ "
			cQuery += "  WHERE GVJ.D_E_L_E_T_ = '' "
			cQuery += "    AND GVJ.GVJ_FILIAL = '" + FWxFilial('GVJ') + "' "
			cQuery += "    AND GVJ.GVJ_CDOPER = '" + cCdOper + "' "
			cQuery += "    AND GVJ.GVJ_CDPTCT = '" + cValor + "' "
			
			cQuery := ChangeQuery( cQuery )	
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )	
			
			If (cAliasQry)->(Eof())  
				Help(" ",1,".AGRX510A0005.")	
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
							
Return lRet
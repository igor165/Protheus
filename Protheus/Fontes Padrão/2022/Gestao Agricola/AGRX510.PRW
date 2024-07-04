#INCLUDE "AGRX510.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static __cRetorno	:= ""
Static __cAliasC	:= Nil
Static __oArqTemp	:= Nil
Static __aDadBas    := {"NJJ_CODROM","NJJ_CODSAF","NJJ_CODPRO","NJJ_DESPRO","NJJ_UM1PRO","NJJ_LOCAL","NJJ_CODENT","NJJ_LOJENT","NJJ_NOMENT","NJJ_DATA","NJJ_CODUNB","NJJ_TOETAP","NJJ_QTDFAR"}
Static __aQtdCPes   := {"NJJ_PSSUBT","NJJ_PSLIQU","NJJ_PSDESC","NJJ_PSBASE","NJJ_PSEXTR","NJJ_PESEMB","NJJ_PESO3","NJJ_DIFFIS","NJJ_PESO1","NJJ_DATPS1","NJJ_HORPS1","NJJ_MODPS1","NJJ_PESO2","NJJ_DATPS2","NJJ_HORPS2","NJJ_MODPS2","NJJ_STSPES","NJJ_DATCHE","NJJ_HORCHE"}
Static __aAnaQua	:= {"NJJ_TABELA","NJJ_STSCLA","NJJ_LIBQLD","NJJ_QPAREC","NJJ_QUSUAR"}
Static __aTranspo	:= {"NJJ_CODTRA","NJJ_PLACA" ,"NJJ_CGC" ,"NJJ_NOMTRA","NJJ_CODMOT","NJJ_NOMMOT","NJJ_TPFRET","NJJ_ENTENT","NJJ_ENTLOJ"}
Static __aQtSPes	:= {"NJJ_PSSUBT","NJJ_PSLIQU","NJJ_PSDESC","NJJ_PSBASE","NJJ_PSEXTR","NJJ_PESEMB","NJJ_PESO3"}
Static __aAgend     := {"NJJ_DTAGEN","NJJ_HRAGEN","NJJ_NRAGEN"}
Static __aLavoura   := {"NJJ_ORDCLT","NJJ_FAZ","NJJ_NMFAZ","NJJ_TALHAO","NJJ_DESTAL","NJJ_CODVAR","NJJ_DESVAR"}
Static __aDadFis    := {"NJJ_TPFORM","NJJ_DOCEMI","NJJ_DOCNUM","NJJ_DOCSER","NJJ_DOCESP","NJJ_EST","NJJ_CHVNFE","NJJ_QTDFIS","NJJ_VLRUNI","NJJ_VLRTOT","NJJ_FRETE","NJJ_SEGURO","NJJ_DESPES","NJJ_NFPNUM","NJJ_NFPSER","NJJ_MSGNFS","NJJ_TES","NJJ_STAFIS"}

//===================================================
/***** AGRX510 ***** Funções da rotina AGRA510 *****/
//===================================================

/*{Protheus.doc} AGRX510CONS()
Função da consulta especifica NJJN95 - Campos do Romaneio

@author		Ana Laura Olegini
@since 		12/12/2017

@return 	lRetorno, Retorno lógico - .T. = True .F. = Falso
*/
Function AGRX510CONS()
	Local aArea     	:= GetArea()
	Local aFieFilter 	:= {} 
	Local aSeek 		:= {}
	Local lRetorno     	:= .T.
	Local oBrowse		:= Nil
	Local oDlg	    	:= Nil
	Local oPnDown   	:= Nil
	Local oSize     	:= Nil

	Private _aColumns 	:= {}

	__cRetorno 	:= ''
	__cAliasC 	:= GetNextAlias()

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  	// Calculo vertical	
	oSize:Process() 			// Executa os calculos
						   /*nTop*/                  /*nLeft*/               /*nBottom*/              /*nRight*/              /*cCaption*/                  
	oDlg := TDialog():New( oSize:aWindSize[1]/1.55, oSize:aWindSize[2]/1.55, oSize:aWindSize[3]/1.55, oSize:aWindSize[4]/1.55, STR0002 , , , , , CLR_BLACK, CLR_WHITE, , , .T. ) //STR0002-'Consulta Específica Campos do Romaneio'
	

	oPnDown := TPanel():New( oSize:GetDimension("ALL","LININI"), oSize:GetDimension("ALL","COLINI"), ,oDlg, ,.F. , , , ,oSize:GetDimension("ALL","COLEND")/1.57, oSize:GetDimension("ALL","LINEND")/1.90)

	//-- Cria tabela temporaria para browse
	__cAliasC := sFCriaTemp(@_aColumns , @__cAliasC)
	
	//-- Filtros da consulta
	Aadd(aFieFilter,{"CAMPO"	, STR0003, "C"  , 10  , 0  ,"@!" })	//STR0003 - 'Campo'   
	//Aadd(aFieFilter,{"TITULO"	, STR0004, "C"  , 12  , 0  ,"@!" })	//STR0004 - 'Título do Campo'
	
	Aadd(aSeek,{ STR0003, {{"", 'C' , 10 , 0 , "@!" }}, 1, .T. }) //STR0003 - 'Campo' 
	//Aadd(aSeek,{ STR0004, {{"", 'C' , 12 , 0 , "@!" }}, 1, .T. }) //STR0004 - 'Título do Campo'

	oBrowse := FWMBrowse():New()
	oBrowse:SetProfileID(STR0002)	//STR0002-"Consulta Específica Campos do Romaneio"
	oBrowse:SetTemporary(.T.)	
	oBrowse:SetAlias(__cAliasC)
	oBrowse:SetDescription(STR0002)	//STR0002-"Consulta Específica Campos do Romaneio"
	oBrowse:SetSeek(.T.,aSeek)
	oBrowse:SetColumns(_aColumns)
	oBrowse:SetOwner(oDlg)	
	oBrowse:DisableDetails()
	oBrowse:SetDoubleClick( {|| sFSelCons(), oDlg:End() })		
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetUseCaseFilter(.T.)	
	oBrowse:SetFieldFilter(aFieFilter)
	oBrowse:SetdbFFilter(.T.)
	oBrowse:SetMenuDef("")
	oBrowse:Activate(oPnDown)

	oDlg:Activate( , , , .T., { || .T. }, , { || EnchoiceBar(oDlg,{|| sFSelCons(), oDlg:End()},{|| oDlg:End() },,/* @aButtons */) } )
	
	RestArea(aArea)

Return lRetorno

/*{Protheus.doc} sFCriaTemp
Função cria tabela temporaria 

@author 	ana.olegini
@since 		12/12/2017
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
	_aColumns[Len(_aColumns)]:SetData( &("{||"+'CAMPO'+"}"))
	_aColumns[Len(_aColumns)]:SetTitle(STR0003)	//STR0003 - 'Campo' 
	_aColumns[Len(_aColumns)]:SetSize(10)
	_aColumns[Len(_aColumns)]:SetDecimal(0)
	_aColumns[Len(_aColumns)]:SetPicture("")
	_aColumns[Len(_aColumns)]:SetAlign( "LEFT" )//Define alinhamento

	AAdd(_aColumns,FWBrwColumn():New())
	_aColumns[Len(_aColumns)]:SetData( &("{||"+'TITULO'+"}"))
	_aColumns[Len(_aColumns)]:SetTitle(STR0004) //STR0004 - 'Título do Campo'
	_aColumns[Len(_aColumns)]:SetSize(12)
	_aColumns[Len(_aColumns)]:SetDecimal(0)
	_aColumns[Len(_aColumns)]:SetPicture("")
	_aColumns[Len(_aColumns)]:SetAlign( "LEFT" )//Define alinhamento	

	//Limpando temp Table
	If __oArqTemp <> Nil
		AGRDLTPTB(@__oArqTemp, NIL, .T.)
	EndIf

	//Definindo as colunas na temp table		 	
	AADD(aCampIni2,{'CAMPO'	, "C",10,0})
	AADD(aCampIni2,{'TITULO', "C",12,0})

	aAdd(aIndices, {"", "CAMPO" })
	aAdd(aIndices, {"", "TITULO" })
	
	//-- Cria tabela temporaria - Funcao do AGRUTIL01
	__oArqTemp  := AGRCRTPTB(__cAliasC, {aCampIni2, aIndices },,,,.F. )	
	//-- Funcao cria consulta
	__cAliasC := sFCposCons( @__cAliasC )

Return __cAliasC


/*{Protheus.doc} sFCposCons
Funcao cria consulta 

@author 	ana.olegini
@since 		12/12/2017
@param 		__cAliasC, Tabela Temporaria
@return 	__cAliasC, Tabela Temporaria  
@type function
*/
Static Function sFCposCons( __cAliasC )
	Local aBasicos	:= __aDadBas
	Local aTranspo	:= __aTranspo
	Local aQtSPes	:= __aQtSPes
	Local aLavoura  := __aLavoura
	Local aAgend	:= __aAgend
	Local aQtdCPes  := __aQtdCPes
	Local aAnaQua	:= __aAnaQua
	Local aDadFis   := __aDadFis
	Local aCampos	:= {}
	Local oHash  	:= Nil
	Local nX        := 0
	Local aCpSX3Tab	:= {} //armazena os campo da tabela no SX3
	Local aCpSX3Str	:= {} //armazena a estrutura do campo da sx3
	
	//-- Dados Básicos Selecionados = .T.
	If FWFLDGET("N94_DADAGD") == .T.
		For nX := 1 To Len(aAgend)
			AADD(aCampos, {aAgend[nX]})
		Next nX
	EndIf
	
	//-- Dados Básicos Selecionados = .T.
	If FWFLDGET("N94_DADBAS") == .T.
		For nX := 1 To Len(aBasicos)
			AADD(aCampos, {aBasicos[nX]})
		Next nX
	EndIf
	
	//-- Dados Transportador Selecionados = .T.
	If FWFLDGET("N94_DADTRA") == .T.
		For nX := 1 To Len(aTranspo)
			AADD(aCampos, {aTranspo[nX]})
		Next nX
	EndIf 
	
	//-- Quantidade Sem Pesagem Selecionados = .T.
	If FWFLDGET("N94_QTSPES") == .T.
		For nX := 1 To Len(aQtSPes)
			AADD(aCampos, {aQtSPes[nX]})
		Next nX
	EndIf

	//-- Dados Lavoura Selecionados = .T.
	If FWFLDGET("N94_DADLAV") == .T.
		For nX := 1 To Len(aLavoura)
			AADD(aCampos, {aLavoura[nX]})
		Next nX
	EndIf
	
	//-- Qtd. C/ Pesagem Selecionados = .T.
	If FWFLDGET("N94_QTCPES") == .T.
		For nX := 1 To Len(aQtdCPes)
			AADD(aCampos, {aQtdCPes[nX]})
		Next nX
	EndIf
		
	//-- Análise de qualidade Selecionados = .T.
	If FWFLDGET("N94_ANAQUA") == .T.
		For nX := 1 To Len(aAnaQua)
			AADD(aCampos, {aAnaQua[nX]})
		Next nX
	EndIf

	//-- Dados fiscal Selecionados = .T.
	If FWFLDGET("N94_DADFIS") == .T.
		For nX := 1 To Len(aDadFis)
			AADD(aCampos, {aDadFis[nX]})
		Next nX
	EndIf

	oHash := aToHM(aCampos) 
	
	aCpSX3Tab := FWSX3Util():GetAllFields( "NJJ" , .T. ) //retorna todos campos sx3, inclusive virtual

	//Carrega os campos da tabela selecionada
	For nX := 1 To Len(aCpSX3Tab)
		aCpSX3Str := FWSX3Util():GetFieldStruct( aCpSX3Tab[nX] )
		//-- Realiza procura dentro do hashmap	.OU. campos que são de propriedade do usuário
		If HMGet( oHash , Alltrim(aCpSX3Str[1]),  ) .AND. X3USADO(aCpSX3Str[1]) .OR. GetSX3Cache(aCpSX3Str[1], "X3_PROPRI") == "U" 
			Reclock(__cAliasC, .T.)
				Replace (__cAliasC)->CAMPO  With aCpSX3Str[1]
				Replace (__cAliasC)->TITULO With AllTrim(FWX3Titulo(aCpSX3Str[1]))
			(__cAliasC)->(MsUnlock())
		EndIf
	Next nX

Return __cAliasC

/*{Protheus.doc} sFSelCons
Função para seleção dos campos da consulta

@author 	ana.olegini
@since 		12/12/2017

@return 	lRetorno, Retorno lógico - .T. = True .F. = Falso
*/
Static Function sFSelCons()
	Local lRetorno	:= .T.
	Local oModel	:= FWModelActive()

	__cRetorno := (__cAliasC)->TITULO
	oModel:LoadValue('MdGridN95', 'N95_CAMPO',   (__cAliasC)->CAMPO)
	oModel:LoadValue('MdGridN95', 'N95_TITULO',  (__cAliasC)->TITULO)

	//--Para quando o campo for virtual - informar a obrigatoriedade para "Não"
	If Posicione("SX3",2,(__cAliasC)->CAMPO, "X3_CONTEXT") == 'V'
		oModel:LoadValue('MdGridN95', 'N95_OBRIGA', "2" )	//1=Sim;2=Não 
	EndIF

	SX3->(dbSetOrder(2))
	SX3->(dbSeek((__cAliasC)->CAMPO))
	
Return(lRetorno)

/*/{Protheus.doc} AGRX510TOP
//Função valida os campos obrigatórios por dados da etapa
@author marina.muller
@since 22/01/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Function AGRX510TOP(oModel)
	Local lRet	     := .T.
	Local lFirst     := .T.
	Local lmsg       := .F.
	Local nK
	Local nX
	Local nY
	Local nZ
	Local oGridN93   := oModel:GetModel('MdGridN93')
	Local oModelN94  := oModel:GetModel('MdFieldN94')
	Local oGridN95   := oModel:GetModel('MdGridN95')
	Local aCposModel := oModelN94:GetStruct():GetFields()
	Local cCampoN94  := ''
	Local cCampoN95  := '' 
	Local aCpoObrig  := {}
	Local nPosicao   := 0
	Local cMensagem  := ''
	Local aCamposN94 := {}
	Local aDescrN94  := {}
	Local aCamposN95 := {}
	
	cMensagem := STR0005 + '<br>'
	
	//busca todos as etapas
	For nX := 1 to oGridN93:Length()
	    oGridN93:GoLine(nX)
	    
	    If !oGridN93:IsDeleted()
			//busca nos dados da etapa quais checkbox foram marcados
			For nK := 5 to len(aCposModel)
			    // verifica se campo lógico (checkbox)
			    If aCposModel[nK,4] == "L"
				    //se for .T. indica que checkbox está marcado
					If oModelN94:GetValue(aCposModel[nK,3]) == .T.
					   
					   //verifica se dado da etapa já foi incluido no array para evitar de incluir mais de uma vez
					   nPosicao := Ascan(aCamposN94,{|x| ALLTRIM(x) == ALLTRIM(aCposModel[nK,3])})
					   If nPosicao == 0
					      AADD(aCamposN94, aCposModel[nK,3])
					      AADD(aDescrN94,  aCposModel[nK,1])
					   EndIf   
					EndIf
				EndIf	
			Next nK
			
			nPosicao := 0 
			//busca todos os campos foram informados no GRID para todas as etapas
			For nY := 1 to oGridN95:Length()
				oGridN95:GoLine(nY)
	
				If !oGridN95:IsDeleted()
					//verifica se campo já foi incluido no array para evitar de incluir mais de uma vez
				    nPosicao := Ascan(aCamposN95,{|x| ALLTRIM(x) == ALLTRIM(oGridN95:GetValue('N95_CAMPO'))})
					If nPosicao == 0
					   AADD(aCamposN95, oGridN95:GetValue('N95_CAMPO'))
					EndIf
				EndIf	   
			Next nY
		EndIf	
	Next nX

	//verifica o array dos checkbox marcados nos dados da etapa
	For nX := 1 to len(aCamposN94) 
	    cCampoN94 := aCamposN94[nX]
		
        Do Case
           // dados básicos campos obrigatórios
           Case cCampoN94 == 'N94_DADBAS'
                aCpoObrig = StrTokArr('NJJ_CODROM|NJJ_CODSAF|NJJ_DATA','|')
	       //dados transporte campos obrigatórios
	       Case cCampoN94 == 'N94_DADTRA'
		        aCpoObrig = StrTokArr('NJJ_CGC|NJJ_PLACA|NJJ_TPFRET','|')
		   //dados integração PIMS campos obrigatórios
	       //dados fiscais campos obrigatórios
		   Case cCampoN94 == 'N94_DADFIS'
	            aCpoObrig = StrTokArr('NJJ_TPFORM','|')     	            
		   //nenhuma das opções acima     
		   OtherWise
		EndCase
			
		//verifica o array da GRID de campos
		For nY := 1 to len(aCamposN95)
			cCampoN95 := aCamposN95[nY]
			
			//compara o array de campos obrigatórios com o array de campos informados na tela
			nPosicao := Ascan(aCpoObrig,{|x| ALLTRIM(x) == ALLTRIM(cCampoN95)})
			If nPosicao > 0   
			   // remove do array os campos obrigatórios que forem encontrados
			   ADEL(aCpoObrig,nPosicao)
			EndIf
		Next nY
			
		//verifica array de campos obrigatórios para ver se tem algum não informado tela
		For nZ := 1 to Len(aCpoObrig)
			If !Empty(aCpoObrig[nZ])
			   If lFirst
			      cMensagem := + cMensagem + '<b>' + aDescrN94[nX] + ': ' + '</b>' 
			      cMensagem := cMensagem + aCpoObrig[nZ]
			      lmsg := .T.                                
			   Else
			      cMensagem := cMensagem + ', '
			      cMensagem := cMensagem + aCpoObrig[nZ]
			   EndIf   
			   lFirst := .F.   
			EndIf
		Next nZ
		
		If lFirst == .F.
		   cMensagem := cMensagem + '<br>'
		EndIf
		   
		//inicializa as variaveis para próximo registro
		lFirst    := .T.
	    aCpoObrig := {} 
	Next nX
	
    If lmsg
	   ApMsgAlert(cMensagem)
	EndIf   
		
Return lRet


/*/{Protheus.doc} A510WHEN
* Função a qual indica se N95_OBRIGA pode ser alterado quando 
o X3_CONTEXT do campo informado for virtual.
* Para campos virtuais, se obrigar, ao fazer um romaneio o modelo nao 
permite salvar mesmo se estiver preenchido.
* Função encontra-se no X3_WHEN do campo N95_OBRIGA

@author 	ana.olegini
@since 		27/02/2018
@version 	P12

@return 	lRetorno, Retorna .T. Verdadeiro ou .F. Falso
/*/
Function AGRA510WHN()
	Local oModel	:= FWModelActive()
	Local oModelN95	:= oModel:GetModel('MdGridN95')
	Local lRetorno 	:= .T.

	If Posicione("SX3",2,oModelN95:GetValue('N95_CAMPO'), "X3_CONTEXT") == 'V'
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf
Return lRetorno


/*/{Protheus.doc} AGRX510SXB
//Filtra Tipo de Operacao relacionados ao Tipo de Controle na Aba Principal
@author carlos.augusto
@since 24/04/2018
@version undefined
@type function
/*/
Function AGRX510SXB()
	Local lRet := .F.

	If (FwFldGet("N92_TIPO") == "A" .And. N92->N92_TIPO == "B") .Or. (FwFldGet("N92_TIPO") == "B" .And. N92->N92_TIPO == "A")
		lRet := .T.
	EndIf
	
Return lRet

/*/{Protheus.doc} AGRX510SF4
//Filtra TES para Entrada ou Saida
@author carlos.augusto
@since 24/04/2018
@version undefined
@type function
/*/
Function AGRX510SF4()
	Local lRet		:= .F.
	Local oModel	:= FwViewActive()
	Local oModelN92	:= oModel:GetModel("MdFieldN92")
	Local cTPCtrl	:= oModelN92:GetValue("N92_TIPO")

	If (cTPCtrl $ "1|3|5|7|9|A" .And. SF4->F4_TIPO == "S") .Or. (cTPCtrl $ "2|4|6|8|B" .And. SF4->F4_TIPO == "E")
		lRet := .T.
	EndIf
	
Return lRet


/*/{Protheus.doc} AGRX510TES
//Validacoes da TES informada
@author carlos.augusto
@since 24/04/2018
@version undefined
@type function
/*/
Function AGRX510TES()
	Local lRet 			:= .T.

Return lRet

/*/{Protheus.doc} AGRX510OPR
//Valida o Tipo de Controle do Tipo de Operacao de Romaneio
@author carlos.augusto
@since 24/04/2018
@version undefined
@type function
/*/
Function AGRX510OPR()
	Local lRet 			:= .T.
	Local oModel		:= FwViewActive()
	Local oModelN92		:= oModel:GetModel("MdFieldN92")
	Local aArea 	 	:= GetArea()
	Local cTpOpRel		:= oModelN92:GetValue("N92_TPOPRE")
	Local cTPCtrl		:= oModelN92:GetValue("N92_TIPO")
	Local cTipo

	If Empty(cTPCtrl)
		//#O "Tipo de Controle" na aba "Principal" deve ser preenchido. -Realize o preenchimento do campo.
		Help(" ",1,".AGRX51000001.")
		lRet := .F.
	EndIf
	
	If lRet .And. .Not. Empty(cTPCtrl) .And. (cTPCtrl != "A" .And. cTPCtrl != "B")
		//#O "Tipo de Controle" na aba "Principal" deve ser preenchido como "A - Entrada por Transferência" ou "B - Saída por Transferência".
		//#Verifique o preenchimento do campo.
		Help(" ",1,".AGRX51000008.")
		lRet := .F.
	EndIf

	If lRet .And. .Not. Empty(cTpOpRel)
		DbSelectArea("N92")
		N92->(dbSetOrder(1))
		If N92->(DbSeek(FwXFilial("N92")+cTpOpRel))
			cTipo   := N92->N92_TIPO
		Else
			lRet := .F.
			//#Tipo de Operação de Romaneio não encontrado. Verifique o cadastro de Tipo de Operação de Romaneio.
			Help(" ",1,".AGRX51000005.")
		EndIf
		If lRet
			If cTPCtrl == "A" .And. cTipo != "B"
				//#O Tipo de Controle do Tipo de Operação de Romaneio selecionado é inválido.-O Tipo de Controle deve ser "B" = Saída por Transferência.
				Help(" ",1,".AGRX51000006.")
				lRet := .F.
			EndIf
			If cTPCtrl == "B" .And. cTipo != "A"
				//#O Tipo de Controle do Tipo de Operação de Romaneio selecionado é inválido.-O Tipo de Controle deve ser "A" = Entrada por Transferência.
				Help(" ",1,".AGRX51000007.")
				lRet := .F.
			EndIf
		EndIf
		N92->( DbCloseArea())
	EndIf
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} AGRX510TIP
//Validacoes de alteracao de Tipo de Controle
@author carlos.augusto
@since 24/04/2018
@version undefined
@type function
/*/
Function AGRX510TIP()
	Local lRet 			:= .T.
	Local oModel		:= FwModelActive()
	Local oModelN92		:= oModel:GetModel("MdFieldN92")
	Local aArea 	 	:= GetArea()
	Local cTpOpRel		:= oModelN92:GetValue("N92_TPOPRE")
	Local cTipoTes
	Local cSentido
	Local cTPCtrl		:= oModelN92:GetValue("N92_TIPO")
	Local cOpGFE		:= oModelN92:GetValue("N92_CDOPER")
	Local cMensagem		:= ""  //Recebe todos campos que serao removidos da tela
	
	If .Not. Empty(cTPCtrl)
		lRet :=	ExistCpo('SX5','K5'+cTPCtrl)
		
		If lRet
		
			//Validacoes Entrada por Transferencia
			If cTPCtrl == "A"
			
				If oModelN92:GetValue("N92_MOVORI")
					If .Not. MsgYesNo(STR0007) //'Deseja manter marcada a opção "Mov.Origem"?'
						oModelN92:LoadValue("N92_MOVORI", .F.)
					EndIf
				EndIf
				
				If .Not. Empty(cTpOpRel)
					DbSelectArea("N92")
					N92->(dbSetOrder(1))
					If N92->(DbSeek(FwXFilial("N92")+cTpOpRel))
						cTipoTes   := N92->N92_TIPO
					EndIf
					If cTipoTes == "B"
						If .Not. MsgYesNo(STR0008)//'Deseja manter o "Tipo de Operação de Romaneio" relacionado na aba "Transf"?'
							oModelN92:LoadValue("N92_TPOPRE", Space(TamSX3("N92_TPOPRE")[1]))
							oModelN92:LoadValue("N92_DSTPOP", Space(TamSX3("N92_DSTPOP")[1]))
						EndIf
					Else
						cMensagem += STR0009 //'O "Tipo de Operação de Romaneio" relacionado na aba "Transf".' 
						oModelN92:LoadValue("N92_TPOPRE", Space(TamSX3("N92_TPOPRE")[1]))
						oModelN92:LoadValue("N92_DSTPOP", Space(TamSX3("N92_DSTPOP")[1]))
					EndIf
				EndIf
			EndIf
			
			//Validacoes Saida por Transferencia
			If cTPCtrl == "B"
			
				//If oModelN92:GetValue("N92_PREROM") 
				If oModelN92:GetValue("N92_GERROM")	== '1'		//1="Gera Romaneio Destino"
					If .Not. MsgYesNo(STR0012) //'Deseja manter marcada a opção "Pré.Romaneio"?'
						//oModelN92:LoadValue("N92_PREROM", .F.)
						oModelN92:LoadValue("N92_GERROM", '0')	//0="Não Movimenta Destino"
					EndIf
				EndIf
				
				If .Not. Empty(cTpOpRel)
					DbSelectArea("N92")
					N92->(dbSetOrder(1))
					If N92->(DbSeek(FwXFilial("N92")+cTpOpRel))
						cTipoTes   := N92->N92_TIPO
					EndIf
					If cTipoTes == "A"
						If .Not. MsgYesNo(STR0008) //'Deseja manter o "Tipo de Operação de Romaneio" relacionado na aba "Transf"?'
							oModelN92:LoadValue("N92_TPOPRE", Space(TamSX3("N92_TPOPRE")[1]))
							oModelN92:LoadValue("N92_DSTPOP", Space(TamSX3("N92_DSTPOP")[1]))
						EndIf
					Else
						cMensagem += STR0009 //'O "Tipo de Operação de Romaneio" relacionado na aba "Transf".' 
						oModelN92:LoadValue("N92_TPOPRE", Space(TamSX3("N92_TPOPRE")[1]))
						oModelN92:LoadValue("N92_DSTPOP", Space(TamSX3("N92_DSTPOP")[1]))
					EndIf
				EndIf
			EndIf
			
			//Validacoes Conf Operacao GFE
			If .Not. Empty(cOpGFE)
				DbSelectArea("GVC")
				GVC->(dbSetOrder(1))
				If GVC->(DbSeek(FwXFilial("GVC")+cOpGFE))
					cSentido   := GVC->GVC_SENTID
				EndIf
				If (cSentido == "1" .And. cTPCtrl $ "1|3|5|7|9|A") .Or. (cSentido == "2" .And. cTPCtrl $ "2|4|6|8|B")	
					If .Not. MsgYesNo(STR0013) //'Deseja manter a "Conf. de Operação GFE" informada na aba "Int. GFE?"'
						oModelN92:LoadValue("N92_CDOPER", Space(TamSX3("N92_CDOPER")[1]))
						oModelN92:LoadValue("N92_DSOPER", Space(TamSX3("N92_DSOPER")[1]))
						oModelN92:LoadValue("N92_SEQOP", Space(TamSX3("N92_SEQOP")[1]))
					EndIf
				Else
					cMensagem += STR0014 //'A "Conf. Operação GFE" informada na aba "Int. GFE" que possuia "Sentido" diferente do Tipo de Controle.' 
					oModelN92:LoadValue("N92_CDOPER", Space(TamSX3("N92_CDOPER")[1]))
					oModelN92:LoadValue("N92_DSOPER", Space(TamSX3("N92_DSOPER")[1]))
					oModelN92:LoadValue("N92_SEQOP", Space(TamSX3("N92_SEQOP")[1]))
				EndIf
			EndIf
		EndIf
	EndIf
	
	If .Not. Empty(cMensagem)
		cMensagem := STR0015 + cMensagem //"Campos que terão seus valores removidos: "
		MsgAlert(cMensagem)
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} AGRX510PRE
//Ao deletar uma linha, validar
@author carlos.augusto
@since 16/03/2018
@version undefined
@param oMldN8O, object, descricao
@param nLine, numeric, descricao
@param cAction, characters, descricao
@param cIDField, characters, descricao
@param xValue, , descricao
@param xCurrentValue, , descricao
@type function
/*/
Function AGRX510PRE(oModelN95, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet 		  := .T.
	Local oModel	  := FwModelActive()
	Local nX
	Local oModelN95   := oModel:GetModel('MdGridN95')
	Local nLinha	  := oModelN95:GetLine()
	Local cCampo	  := oModelN95:GetValue("N95_CAMPO")
	
	FwClearHLP()
	
	If cAction == "UNDELETE" .And. .Not. Empty(oModelN95:GetValue("N95_CAMPO"))
		For nX := 1 to oModelN95:Length()
			oModelN95:GoLine(nX)
			If (nLinha != nX) .And. AllTrim(oModelN95:GetValue("N95_CAMPO")) = AllTrim(cCampo) .And. .Not. oModelN95:IsDeleted()
				Help('', 1, STR0016, , STR0017 + cValToChar(nX), 1 ) //Atencao-"Campo encontrado na linha: "
				lRet := .F.
				exit
			EndIf
		Next nX
		oModelN95:GoLine(nLinha)
	EndIf

Return lRet




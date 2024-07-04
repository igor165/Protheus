#INCLUDE 'PROTHEUS.CH'	
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PLSA09B.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA09B
Função para carregar o model da tabela BJO
Devido a limitações do modelo 3 não é possivel posicionar o item da grid somente o item do cabeçalho.

@author  José Paulo de Azevedo
@version P12
@since   02/08/2018
/*/
//------------------------------------------------------------------- 
Function PLSA09B()
Local aArea   := GetArea()
Local oBrowse

oBrowse := FWMBrowse():New()    
oBrowse:SetAlias("BJO")    
oBrowse:SetDescription(STR0001)//"Proposta de Diretrizes de Utilização para Cobertura de Procedimentos na Saúde"
//oBrowse:SetMenuDef( '' )      
oBrowse:Activate()
 
RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Criação do modelo de dados MVC 

@author  José Paulo de Azevedo
@version P12
@since   02/08/2018
/*/
//------------------------------------------------------------------- 
Static Function ModelDef()
Local oStruBJO := FWFormStruct( 1, 'BJO' )
Local oStruBKK := FWFormStruct( 1, 'BKK' )
Local oModel

// Cria o objeto do Modelo de Dados e insere a funçao de pós-validação
oModel := MPFormModel():New( 'PLSA09B', , {|| validaOk(oModel) } )
//oModel := MPFormModel():New( 'PLSA09B', , {|| .T. } )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'BJOMASTER', /*cOwner*/, oStruBJO )

// Adiciona ao modelo uma componente de grid
//oModel:AddGrid( 'BKKDETAIL', 'BJOMASTER', oStruBKK )
oModel:AddGrid( 'BKKDETAIL', 'BJOMASTER', oStruBKK, ,{ |oModel, nLine, cAction, cField| vldLinBKK(oModel, nLine, cAction, cField) } )

// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'BKKDETAIL', {{'BKK_FILIAL','xFilial( "BKK" )'},{'BKK_CODTAB','BJO_CODTAB'}},BKK->( IndexKey( 1 ) ) )

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( Fundesc() )

// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:GetModel( 'BJOMASTER' ):SetDescription( STR0002 ) // "Cabeçalho DUT"

//BKK é obrigatoria
oModel:GetModel('BKKDETAIL'):SetOptional(.F.)

oStruBKK := FWFormStruct(1, "BKK")
FWMemoVirtual( oStruBKK,{ { 'BKK_DESDUT' } } ) 

// Retorna o Modelo de dados
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Criação do menu MVC

@author  José Paulo
@version P12
@since   02/08/2018
/*/
//-------------------------------------------------------------------  
Static Function MenuDef()
Local aRotina := {} 

ADD OPTION aRotina Title STR0003   Action 'VIEWDEF.PLSA09B' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0004   Action 'VIEWDEF.PLSA09B' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title STR0005   Action 'VIEWDEF.PLSA09B' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title STR0006   Action 'VIEWDEF.PLSA09B' OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Criação da visão MVC   

@author  José Paulo de Azevedo
@version P12
@since   02/08/2018
/*/
//-------------------------------------------------------------------  
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'PLSA09B' )
// Cria as estruturas a serem usadas na View
Local oStruBJO := FWFormStruct( 2, 'BJO' )
Local oStruBKK := FWFormStruct( 2, 'BKK' )
// Interface de visualização construída
Local oView

oModel:SetPrimaryKey( { "BJO_FILIAL", "BKK_FILIAL", "BJO_CODTAB", "BKK_CODTAB" } )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField( 'VIEW_BJO', oStruBJO, 'BJOMASTER' )

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_BKK', oStruBKK, 'BKKDETAIL' )

//Informo que o campo é incremental
//oView:AddIncrementField( 'VIEW_BKK', 'BKK_CODDUT' )

//Ajusta string dos campos de codigo
oView:SetFieldAction( 'BKK_CODDUT', { |oView, cIDView, cField, xValue| ajusCodBKK( oModel, oView, cIDView, cField, xValue ) } )
oView:SetFieldAction( 'BKK_CODSUB', { |oView, cIDView, cField, xValue| ajusCodBKK( oModel, oView, cIDView, cField, xValue ) } )

//Nao deixa duplicar o campo 
oModel:GetModel( 'BKKDETAIL' ):SetUniqueLine( { 'BKK_CODDUT', 'BKK_CODSUB' } )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 25 )
oView:CreateHorizontalBox( 'INFERIOR', 75 )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_BJO', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_BKK', 'INFERIOR' )

// Retorna o objeto de View criado
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLDUTVLD
Verifica se a vigencia informada e inferior a data final de,
uma vigencia ja informada.
(Executada no valido do campo BJO_VIGINI e BJO_VIGFIM)

@author Totvs
@since 16/08/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function PLDUTVLD(dData,cTab,cOpe)
local lRet		    := .t.
local aArea 		:= BJO->(getArea())
local nRecBJO		:= iif(inclui,0,BJO->(recno()))

default dData   	:= ""
default cTab    	:= ""
default cOpe        := ""

if lRet .and. cOpe == "I" .and. !empty(dData) .and. !empty(M->BJO_VIGATE) .and. dData > M->BJO_VIGATE
	Help(,,STR0017,,STR0007, 1, 0,,,,,,{STR0027})//"Cadastro DUT"###"Não é possível excluir pois há eventos no Roll de Procedimentos com cadastro de DUT desta vigência."###"Informe uma data válida."
	lRet := .f.
elseIf lRet .and. cOpe == "F" .and. !empty(M->BD4_VIGDE) .and. !empty(dData) .and. dData < M->BD4_VIGDE
	Help(,,STR0017,,STR0008, 1, 0,,,,,,{STR0027})//"Cadastro DUT"###"A data da Vigência Fim informada é inferior a data da Vigência Início"###"Informe uma data válida."
	lRet := .f.
endIf

if lRet
	BJO->(dbSetOrder(1))//BJO_FILIAL+BJO_CODTAB
	if BJO->(msSeek(xFilial('BJO')+BJO->(BJO_CODTAB)))

	   if BJO->(recno()) <> nRecBJO
		
			while !BJO->(eof()) .and. xFilial('BJO')+BJO->BJO_CODTAB == BJO->(BJO_FILIAL+BJO_CODTAB)
				
					if PLSINTVAL("BJO","BJO_VIGDE","BJO_VIGATE",dData,M->BJO_VIGDE,M->BJO_VIGATE)
						Help(,,STR0017,,STR0009, 1, 0,,,,,,{STR0028})//"Cadastro DUT"###"A data informada está entre um intervalo de vigências já utilizado"###"Informe uma data válida ou verifique se há alguma tabela com vigência em aberto."
						lRet := .f.
						exit
					endIf
				
				BJO->(dbSkip())
			endDo
		endif
	endIf
	
endIf

BJO->(restArea(aArea))

return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLPESTAB
Verifica se a vigencia informada e inferior a data final de,
uma vigencia ja informada.
(Executada no valido do campo BJO_VIGINI e BJO_VIGFIM)

@author Totvs
@since 16/08/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function PLPESTAB(dData,cTipo,cCodDut)
Local   aAreaBJO 		:= BJO->(getArea())
Local   cVal         := ""
Local   lRet         := .F.
Default dData       	:= STOD()
Default cTipo        := ""
Default cCodDut      := ""

If !Empty(cTipo) 
	
    BJO->(dbSetOrder(1))		
	BJO->(DbGoTop())

	If cTipo == "P"
		while !BJO->(eof()) 
	
			If dData >= BJO->BJO_VIGDE .And. (dData <= BJO->BJO_VIGATE .Or. Empty(BJO->BJO_VIGATE)) 
				cVal:= BJO->BJO_CODTAB   
				EXIT
			EndIf				
			BJO->(dbSkip())
		endDo

		If !Empty(cVal) .And. !Empty(cCodDut)

			cSQLBKK := "SELECT BKK_CODDUT, BKK_CODTAB FROM "+RetSQLName("BKK")+" WHERE "
			cSQLBKK += "BKK_FILIAL = '"+xFilial("BKK")+"' AND "
			cSQLBKK += "BKK_CODTAB = '"+ alltrim(cVal) +"' AND "
			cSQLBKK += "BKK_CODDUT = '"+ alltrim(cCodDut) +"' AND "
			cSQLBKK += "D_E_L_E_T_ = '' "
			
			cSQLBKK := ChangeQuery(cSQLBKK)
		
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQLBKK),"QRYBKK",.F.,.T.) 
			
			If QRYBKK->(Eof()) 
				QRYBKK->(DBCloseArea())
				Return
			Else
				cVal:=QRYBKK->BKK_CODDUT + QRYBKK->BKK_CODTAB 
				QRYBKK->(DBCloseArea())

			EndIf		
		EndIf
	EndIf	
	If Empty(cVal)
		lRet:= .F.
	else
		BKK->(DbSeek(xFilial("BKK")+BKK->BKK_CODTAB+BKK_CODDUT))
			
	EndIf
endIf
	
BJO->(restArea(aAreaBJO))

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}) PLA095DUT
Exibe o cadastro da DUT correspondente se houver

@author  Renan Sakai 
@version P12
@since    13.02.19
/*/
//-------------------------------------------------------------------
Function PLA095DUT(cTabDut,cCodDut,cSubItem)
Local oDlg
Local cTitDUT  := ""
Local cTitSub  := ""
Local cDescDUT := ""
Local cDescSub := ""
Local cCodSub  := ""

if BRW->(FieldPos("BRW_TABDUT")) == 0 .Or. BRW->(FieldPos("BRW_CODDUT")) == 0
	Aviso( STR0017,STR0020,{ STR0019 }, 2 ) //"Cadastro DUT"###"Para utilizar este processo, é necessário criar os campos correspondentes a DUT."###"OK" 
	Return
endIf

if Empty(cSubItem) //Tramento para remover os espaços
	cSubItem := ""
endIf

BKK->(DbSetOrder(1)) //BKK_FILIAL+BKK_CODTAB+BKK_CODDUT+BKK_CODSUB
if BKK->(MsSeek(xFilial("BKK")+cTabDut+cCodDut+cSubItem))
    
	DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 

	if empty(BKK->BKK_CODSUB)

		cTitDUT  := Alltrim(BKK->BKK_TITULO)
		cDescDUT := Alltrim(BKK->BKK_DESDUT)
			
		DEFINE MSDIALOG oDlg TITLE STR0010+BRW->BRW_CODDUT FROM 008.0,010.3 TO 034.4,90 //"Cadastro DUT - Código: "
	
		@ 010,005 SAY oSay PROMPT STR0011  SIZE 100,010 OF oDlg PIXEL COLOR CLR_RED //"Título DUT"
		@ 020,005 MSGET cTitDUT  PICTURE "@" SIZE 307,007 PIXEL OF oDlg 
		
		@ 040,005 SAY oSay PROMPT STR0012  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Descrição DUT"
		@ 050,005 GET oMsg VAR cDescDUT MEMO SIZE 307,120 PIXEL OF oDlg 
	

		@ 180,274 BUTTON STR0013  SIZE 36,13 PIXEL ACTION oDlg:End() //"Fechar"
	
	else

		cTitSub  := Alltrim(BKK->BKK_TITULO)
		cDescSub := Alltrim(BKK->BKK_DESDUT)
		cCodSub  := Alltrim(BKK->BKK_CODSUB)

		//Vou buscar os dados do item pai	
		if BKK->(MsSeek(xFilial("BKK")+cTabDut+cCodDut+Space(2))) 
			cTitDUT  := Alltrim(BKK->BKK_TITULO)
			cDescDUT := Alltrim(BKK->BKK_DESDUT)
		endIf

		DEFINE MSDIALOG oDlg TITLE STR0010+BRW->BRW_CODDUT + " | Subitem: " + cCodSub FROM 008.0,010.3 TO 047,090 //"Cadastro DUT - Código: "
	
		//Item
		@ 010,005 SAY oSay PROMPT STR0011  SIZE 100,010 OF oDlg PIXEL COLOR CLR_RED //"Título DUT" 
		@ 020,005 MSGET cTitDUT  PICTURE "@" SIZE 307,007 PIXEL OF oDlg 
		
		@ 035,005 SAY oSay PROMPT STR0012  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Descrição DUT"
		@ 045,005 GET oMsg VAR cDescDUT MEMO SIZE 307,080 PIXEL OF oDlg 

		//SubItem
		@ 145,005 SAY oSay PROMPT STR0014  SIZE 100,010 OF oDlg PIXEL COLOR CLR_RED //"Título Sub-Item"
		@ 155,005 MSGET cTitSub  PICTURE "@" SIZE 307,007 PIXEL OF oDlg 
		
		@ 170,005 SAY oSay PROMPT STR0015  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Descrição Sub-item"
		@ 180,005 GET oMsg VAR cDescSub MEMO SIZE 307,080 PIXEL OF oDlg 

		@ 270,274 BUTTON STR0013  SIZE 36,13 PIXEL ACTION oDlg:End() //"Fechar"

	endIf
	// Ativa dialogo
	ACTIVATE MSDIALOG oDlg CENTERED 

else
    MsgInfo(STR0016) //"Não foi encontrado cadastro de DUT para o evento selecionado."
endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc}) PLDUTB72
Inicializador padrao do campo B72_DUT

@author  Renan Sakai 
@version P12
@since    13.02.19
/*/
//-------------------------------------------------------------------
Function PLDUTB72(cTipo,cCodPad,cCodPro)

    Local cRet := ""
    Local lDUTGrid := PlsAliasExi("BKY")

    If lDUTGrid    
        If GetQtdDutProc(cCodPro) == 1
            BKY->(DbSetOrder(1))// BKY_FILIAL+BKY_CODROL
            If BKY->(MsSeek(xFilial("BKY")+cCodPro)) .And. !Empty(BKY->BKY_TABDUT) .And. !Empty(BKY->BKY_CODDUT)
                If cTipo == '1' //Traz o codigo da DUT
                    cRet := BKY->BKY_CODDUT
                ElseIf cTipo == '2' //Traz o codigo do SubItem
                    cRet := BKY->BKY_DUTSUB
				ElseIf cTipo == '3' //Traz o codigo da Tabela DUT
                    cRet := BKY->BKY_TABDUT
                EndIf
            EndIf
        Else
            If cTipo == '1' //Traz o codigo da DUT
                cRet := Space(3)
            ElseIf cTipo == '2' //Traz o codigo do SubItem
                cRet := Space(2) 
			ElseIf cTipo == '3' //Traz o codigo da Tabela DUT
				cRet := Space(3)
            EndIf
        EndIf
    Else
        BRW->(DbSetOrder(1))//BRW_FILIAL+BRW_CODROL
        if BRW->(MsSeek(xFilial("BRW")+cCodPro)) .And. !Empty(BRW->BRW_TABDUT) .And. !Empty(BRW->BRW_CODDUT)
            if cTipo == '1' //Traz o codigo da DUT
                cRet := BRW->BRW_CODDUT
            elseIf cTipo == '2' //Traz o codigo do SubItem
                cRet := BRW->BRW_DUTSUB
            endIf
        else
            if cTipo == '1' //Traz o codigo da DUT
                cRet := Space(3)
            elseIf cTipo == '2' //Traz o codigo do SubItem
                cRet := Space(2)
            endIf
        endIf
    EndIf

Return(cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} ajusCodBKK
Completa com zeros os codigos de Dut e Subitem

@author  Renan Sakai
@version P12
@since   02/08/2018
/*/
//------------------------------------------------------------------- 
Static Function ajusCodBKK( oModel, oView, cIDView, cField, xValue )
Local oModelBKK   := oModel:GetModel('BKKDETAIL')  

if cField == 'BKK_CODDUT' .And. !Empty(xValue) .And. len(Alltrim(xValue)) < 3
	oModelBKK:SetValue("BKK_CODDUT",Strzero(Val(xValue),3))
elseIf cField == 'BKK_CODSUB' .And. !Empty(xValue) .And. len(Alltrim(xValue)) < 2
	oModelBKK:SetValue("BKK_CODSUB",Strzero(Val(xValue),2))
endIf

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} validaOk
Valida a exclusao de uma vigencia

@author  Renan Sakai
@version P12
@since   02/08/2018
/*/
//------------------------------------------------------------------- 
Static Function validaOk(oModel)
Local cSQl       := ""
Local lRet       := .T.
Local nOperation := oModel:GetOperation()
Local oModelBJO  := oModel:GetModel( 'BJOMASTER' )   
Local cCodBJO    := oModelBJO:GetValue("BJO_CODTAB")

if nOperation == MODEL_OPERATION_DELETE
	
	cSql += " SELECT BRW_CODDUT FROM " + RetSQLName("BRW") +" BRW "
	cSql += " WHERE BRW_FILIAL = '"+xFilial("BRW")+"' "
	cSql += " AND BRW_TABDUT = '"+cCodBJO+"' "	
	cSql += " AND BRW.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"BRWTRB",.F.,.T.) 
	
	if !BRWTRB->(Eof())
		Help(,,STR0017,,STR0018, 1, 0,,,,,,{STR0021})//"Cadastro DUT"###"Não é possível excluir pois há eventos no Roll de Procedimentos com cadastro de DUT desta vigência."###"Revise o vínculo desta Tabela com os eventos da rotina Roll de Procedimentos ANS."
		lRet := .F.
	endIf

	BRWTRB->(DBCloseArea())

endIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} vldLinBKK
Valida a inclusao de uma linha no Alias BKK

@author  Renan Sakai
@version P12
@since   26/03/2019
/*/
//------------------------------------------------------------------- 
Static Function vldLinBKK(oModel, nLine, cAction, cField)
Local cCodDut  := ""
Local nX       := 0
Local lRet     := .T.
Local lFindPai := .F.

//Verifica se o registro subitem tem registro pai correspondente
oModel:GoLine(nLine)
if !Empty(oModel:GetValue("BKK_CODSUB"))
	cCodDut := oModel:GetValue("BKK_CODDUT")

	oModel:GoLine(1)
	for nX := 1 to oModel:Length()
		oModel:GoLine(nX)
		if oModel:GetValue("BKK_CODDUT") == cCodDut .And. Empty(oModel:GetValue("BKK_CODSUB")) .And. !oModel:IsDeleted(nX)
			lFindPai := .T.
			exit
		endIf
	next

	if !lFindPai
		Help(,,STR0022,,STR0023, 1, 0,,,,,,{STR0024}) //"Aviso"###"Foi informado um SubItem sem o registro principal correspondente."###"Cadastre primeiramente um registro pai sem o campo SubItem preenchido."
		lRet := .F.
	endIf
	oModel:GoLine(nLine) //Retorna pra linha selecionada
endIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PL09BDatTB
Valida a vigencia ao incluir uma tabela no Rol de Procedimentos BRW

@author  Renan Sakai
@version P12
@since   26/03/2019
/*/
//------------------------------------------------------------------- 
Function PL09BDatTB(cCodTab)
Local lRet  := .T.
Local aArea := BJO->(GetArea())
Default cCodTab := ""

BJO->(DbSetOrder(1))//BJO_FILIAL+BJO_CODTAB
if BJO->(MsSeek(xFilial("BJO")+cCodTab))
	if !Empty(BJO->BJO_VIGDE) .And. dDataBase < BJO->BJO_VIGDE
		Aviso( STR0017,STR0025,{ STR0019 }, 2 ) //"Cadastro DUT"###"A database do sistema é inferior a data inicial da vigência selecionada."###"OK" 
		lRet := .F.
	elseIf !Empty(BJO->BJO_VIGATE) .And. dDataBase > BJO->BJO_VIGATE
		Aviso( STR0017,STR0026,{ STR0019 }, 2 ) //"Cadastro DUT"###"A database do sistema é superior a data final da vigência selecionada."###"OK" 
		lRet := .F.
	endIf
endIf

RestArea(aArea)

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} GetQtdDutProc
Retorna a quantidade de itens encontrados na BKY - DUT do Procedimentos 

@author  Guilherme Carreiro
@version P12
@since   01/08/2022
/*/
//---------------------------------------------------------------------------
Function GetQtdDutProc(cCodPro)

    Local nQuant := 0
    Local cSql := ""
    
    cSql := "SELECT COUNT(BKY.BKY_CODDUT) CONTADOR FROM " + RetSQLName("BKY") + " BKY"
    cSql += " WHERE BKY.BKY_FILIAL = '" + xFilial("BKY") + "'"
    cSql += "     AND BKY.BKY_CODROL = '" + cCodPro + "'"
    cSql += "     AND BKY.D_E_L_E_T_ = ' ' "

    nQuant := MPSysExecScalar(cSql, "CONTADOR")

Return nQuant
#INCLUDE "MDTA166.ch"
#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------
/*/{Protheus.doc} MDTA166
Rotina para cadastramento de Descri��o para Fun��o.

@type function

@source MDTA166.prx

@author Guilherme Freudenburg
@since 13/06/2017

@sample MDTA166()

@return L�gico, retorna sempre verdadeiro.
/*/
//-------------------------------------------------------------------------
Function MDTA166()

	// Armazena as vari�veis
	Local aNGBEGINPRM := NGBEGINPRM()
	Local oBrowse

	//|------------------------------------|
	//| Instanciamento da Classe de Browse |
	//|------------------------------------|
	oBrowse := FWMBrowse():New()

		//|---------------------------------|
		//| Defini��o da tabela do Browse   |
		//|---------------------------------|
		oBrowse:SetAlias('SRJ')

		//|--------------------------------------------|
		//| Nome do fonte onde esta a fun��o MenuDef   |
		//|--------------------------------------------|
		oBrowse:SetMenuDef( "MDTA166" )

		//|-------------------|
		//| Titulo da Browse  |
		//|-------------------|
		oBrowse:SetDescription( STR0001 ) //"Fun��es"

		//|----------------------------------|
		//| Desabilita a escolha de Filiais  |
		//|----------------------------------|
		oBrowse:SetChgAll(.F.)

		//|----------------------------|
		//| Aplica Filtro ao Browser   |
		//|----------------------------|
		oBrowse:SetFilterDefault( "SRJ->RJ_FILIAL == xFilial('SRJ')" )

		//|---------------------|
		//| Ativa��o da Classe  |
		//|---------------------|
		oBrowse:Activate()

	// Devolve as vari�veis armazenadas
	NGRETURNPRM(aNGBEGINPRM)

Return NIL

//--------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do Menu (padr�o MVC).

@type function

@source MDTA166.prx

@author Guilherme Freudenburg
@since 14/03/2017

@sample MenuDef()

@return aRotina, Array, Retorna as op��es do Menu.
/*/
//-------------------------------------------------------------------------
Static Function MenuDef( lBrwFunc )

	Local aRotina 	:= {}

	Default lBrwFunc := .T.

	If lBrwFunc
		ADD OPTION aRotina Title STR0002 Action 'AxPesqui'		  OPERATION 1 ACCESS 0 //'Pesquisar'
		ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.GPEA030' OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina Title STR0004 Action 'MDT166FUN' 	  OPERATION 3 ACCESS 0 //'Descri��o'
	Else
		ADD OPTION aRotina Title STR0002 Action 'AxPesqui'		  OPERATION 1 ACCESS 0 //'Pesquisar'
		ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.MDTA166' OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.MDTA166' OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.MDTA166' OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.MDTA166' OPERATION 5 ACCESS 0 //'Excluir'
	EndIf

Return aRotina

//--------------------------------------------------------------------------
/*/{Protheus.doc} MDT166FUN
Rotina de cadastramento de Periodos Fun��es.

@type function

@source MDTA166.prx

@author Guilherme Freudenburg
@since 13/06/2017

@sample MDTA166()

@return Vazio.
/*/
//-------------------------------------------------------------------------
Function MDT166FUN()

	Local oBrowse

	If !Empty(SRJ->RJ_FUNCAO)
		aRotina := MenuDef( .F. )
		//|------------------------------------|
		//| Instanciamento da Classe de Browse |
		//|------------------------------------|
		oBrowse := FWMBrowse():New()

			//|---------------------------------|
			//| Defini��o da tabela do Browse   |
			//|---------------------------------|
			oBrowse:SetAlias('TYA')

			//|----------------------------|
			//| Aplica Filtro ao Browser   |
			//|----------------------------|
			oBrowse:SetFilterDefault( "SRJ->RJ_FILIAL == TYA->TYA_FILIAL .And. SRJ->RJ_FUNCAO == TYA->TYA_CODFUN" )

			//|----------------------------------|
			//| Desabilita a escolha de Filiais  |
			//|----------------------------------|
			oBrowse:SetChgAll(.F.)

			//|-------------------|
			//| Titulo da Browse  |
			//|-------------------|
			oBrowse:SetDescription( STR0004 ) //"Descri��o"

			//|---------------------|
			//| Ativa��o da Classe  |
			//|---------------------|
			oBrowse:Activate()

		aRotina := MenuDef()
	EndIf

Return
//--------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Modelo (padr�o MVC).

@type function

@source MDTA166.prx

@author Guilherme Freudenburg
@since 14/03/2017

@sample ModelDef()

@return oModel, oBject, Retorna o modelo.
/*/
//-------------------------------------------------------------------------
Static Function ModelDef()

	//|-------------------------------------------------|
    //| Cria a estrutura a ser usada no Modelo de Dados |
	//|-------------------------------------------------|
	Local oStructTYA := FWFormStruct( 1 ,"TYA" , /*bAvalCampo*/ , /*lViewUsado*/ )
	Local aSX2 := { "TYA_FILIAL", "TYA_CODFUN", "TYA_PERINI" }

	//|--------------------------------------|
	//| Modelo de dados que ser� constru�do  |
	//|--------------------------------------|
	Local oModel

	If TYA->( ColumnPos( "TYA_CC" ) ) > 0
		aSX2 := { "TYA_FILIAL", "TYA_CODFUN", "TYA_CC", "TYA_DEPTO" , "TYA_PERINI" }
	EndIf

	//|------------------------------|
	//| Retira campo da estrutura    |
	//|------------------------------|
	oStructTYA:RemoveField("TYA_FILIAL")

	//|------------------------------|
	//| Tratamento para campo MEMO   |
	//|------------------------------|
	FWMemoVirtual( oStructTYA, { { 'TYA_ODESFU' , 'TYA_MDESFU', "SYP" } } )

	//|----------------------------------|
	//| Cria o objeto do Modelo de Dados |
	//|----------------------------------|
	oModel := MPFormModel():New( "MDTA166" , /*bPre*/ , /*bPos*/ , /*bCommit*/ , /*bCancel*/ )

		//|------------------------|
		//| Componentes do Modelo  |
		//|------------------------|
		oModel:AddFields( "TYAMASTER" , Nil , oStructTYA , /*bPre*/ , /*bPost*/ , /*bLoad*/ )

		//|--------------------------------------------------------|
		//| Determina chave �nica.                                 |
		//|--------------------------------------------------------|
		oModel:SetPrimaryKey( aSX2 )

		//|--------------------------------------------------|
		//| Adiciona a descri��o do Modelo de Dados (Geral)  |
		//|--------------------------------------------------|
		oModel:SetDescription( STR0004 /*cDescricao*/ ) // "Descri��o"

		//|--------------------------------------------------------|
		//| Adiciona a descricao do Componente do Modelo de Dados  |
		//|--------------------------------------------------------|
		oModel:GetModel( "TYAMASTER" ):SetDescription( STR0004 ) // "Descri��o"


Return oModel

//--------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do View (padr�o MVC).

@type function

@source MDTA166.prx

@author Guilherme Freudenburg
@since 14/03/2017d

@sample ViewDef()

@return oView, oBject, Retorna o modelo.
/*/
//-------------------------------------------------------------------------
Static Function ViewDef()

	//|------------------------------------------------------------------------------|
	//| Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado   |
	//|------------------------------------------------------------------------------|
	Local oModel := FWLoadModel( "MDTA166" )

	//|-----------------------------------------|
	//| Cria a estrutura a ser usada na View    |
	//|-----------------------------------------|
	Local oStructTYA := FWFormStruct( 2 , "TYA" , /*bAvalCampo*/ , /*lViewUsado*/ )

	//|----------------------------------------|
	//| Interface de visualiza��o constru�da   |
	//|----------------------------------------|
	Local oView

	//|------------------------------|
	//| Retira campo da estrutura    |
	//|------------------------------|
	oStructTYA:RemoveField("TYA_FILIAL")
	oStructTYA:RemoveField("TYA_ODESFU")
	oStructTYA:RemoveField("TYA_CODFUN")

	//|--------------------------|
	//| Cria o objeto de View    |
	//|--------------------------|
	oView := FWFormView():New()

		//|------------------------------------------|
		//| Objeto do model a se associar a view.    |
		//|------------------------------------------|
		oView:SetModel( oModel )

		//|---------------------------------------------------------------------|
		//| Adiciona no View um controle do tipo formul�rio (antiga Enchoice)   |
		//|---------------------------------------------------------------------|
		oView:AddField( "VIEW_TYA" , oStructTYA , "TYAMASTER" )

		//|-----------------------------------------|
		//| Adiciona um titulo para o formul�rio    |
		//|-----------------------------------------|
		oView:EnableTitleView( "VIEW_TYA" , STR0008 )	// "Descri��o da Fun��o"

		//|-------------------------------------------------------------------------|
		//| Cria os componentes "box" horizontais para receberem elementos da View  |
		//|-------------------------------------------------------------------------|
		oView:CreateHorizontalBox( "TELATYA" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

		//|----------------------------|
		//| Associa um View a um box   |
		//|----------------------------|
		oView:SetOwnerView( "VIEW_TYA" , "TELATYA" )

Return oView

//--------------------------------------------------------------------------
/*/{Protheus.doc} MDT166DT
Realiza valida��o para que n�o seja permitido incluir um periodo Inferior
a 01/01/2004, poi no PPP abaixo desta data n�o permite quebra de per�odo.

@type function

@source MDTA166.prx

@author Guilherme Freudenburg
@since 14/03/2017

@sample MDT166DT()

@return lRet, L�gico, Verdadeiro quando n�o encontrar inconsist�ncias.
/*/
//-------------------------------------------------------------------------
Function MDT166DT()

Local lRet 	:= .T.
Local oModel := FWModelActive() //Habilita o modelo utilizado.
Local nOpcx	:= oModel:GetOperation() //Op��o selecionada.

If nOpcx == MODEL_OPERATION_INSERT
	If oModel:GetValue( 'TYAMASTER', 'TYA_PERINI' ) < STOD('20040101')
		Help( , , STR0009 , , STR0010, 5 , 5 )//"ATEN��O"##"N�o � permitido informar datas menores que 01/01/2004."
		lRet := .F.
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} MDT166LDEP
Respons�vel por realizar a limpeza do campo TYA_DEPTO, ao ocorrer
a troca de Centro de Custo.

@type function

@source MDTA166.prx

@author Guilherme Freudenburg
@since 14/03/2017

@sample MDT166LDEP()

@return .T., L�gico, Sempre verdadeiro.
/*/
//-------------------------------------------------------------------------
Function MDT166LDEP()

Local oModel := FWModelActive() //Habilita o modelo utilizado.

	If !Empty(oModel:GetValue( 'TYAMASTER', 'TYA_DEPTO' )) //Caso tenha departamento preenchido.
		oModel:LoadValue( "TYAMASTER" , "TYA_DEPTO", ""  )
		oModel:LoadValue( "TYAMASTER" , "TYA_DESCDP", ""  )
	EndIf

Return .T.

//--------------------------------------------------------------------------
/*/{Protheus.doc} MDT166VDEP
Respons�vel por realizar a valida��o do campo de Departamento.

@type function

@source MDTA166.prx

@author Guilherme Freudenburg
@since 14/03/2017

@sample MDT166VDEP()

@return lRet , L�gico , Retorna verdadeiro mediante a condi��o.
/*/
//-------------------------------------------------------------------------
Function MDT166VDEP()

Local oModel := FWModelActive() //Habilita o modelo utilizado.
Local lRet 	 := .T.
Local cCentro := ""

If !Empty(oModel:GetValue( 'TYAMASTER', 'TYA_DEPTO' ))
	cCentro := Posicione( "SQB", 1, xFilial( "SQB" ) + oModel:GetValue( 'TYAMASTER', 'TYA_DEPTO' ), "QB_CC" )
	If !Empty(cCentro) .And. oModel:GetValue( 'TYAMASTER', 'TYA_CC' ) <> cCentro .And. !Empty(oModel:GetValue( 'TYAMASTER', 'TYA_CC' ))
		Help(" ",1,"REGNOIS")
		lRet := .F.
	EndIf
EndIf

Return lRet
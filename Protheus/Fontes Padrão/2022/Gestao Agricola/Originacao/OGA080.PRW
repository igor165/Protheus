#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"
#include "OGA080.ch"

/** {Protheus.doc} OGA080
Rotina para cadastro de indices de mercado

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	12/07/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA080()
Local oMBrowse

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NK0" )
oMBrowse:SetDescription( STR0001 )
oMBrowse:Activate()

Return()

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	12/07/2010
@Uso: 		OGA080 - Indices de Mercado
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002 , 'PesqBrw'        , 0, 1, 0, .T. } )
aAdd( aRotina, { STR0003 , 'ViewDef.OGA080', 0, 2, 0, Nil } )
aAdd( aRotina, { STR0004 , 'ViewDef.OGA080', 0, 3, 0, Nil } )
aAdd( aRotina, { STR0005 , 'ViewDef.OGA080', 0, 4, 0, Nil } )
aAdd( aRotina, { STR0006 , 'ViewDef.OGA080', 0, 5, 0, Nil } )
aAdd( aRotina, { STR0009 , 'OGA080AltUM', 0, 6, 0, Nil } )
aAdd( aRotina, { STR0007 , 'ViewDef.OGA080', 0, 8, 0, Nil } )
aAdd( aRotina, { STR0008 , 'ViewDef.OGA080', 0, 9, 0, Nil } )
aAdd( aRotina, { STR0022 , 'OGA011ACIM()', 0, 8, 0, Nil } ) //'Atualizar Cotação' 

Return aRotina


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	12/07/2010
@Uso: 		OGA080 - Indices de Mercado
*/
Static Function ModelDef()
Local oStruNK0 := FWFormStruct( 1, "NK0" )
Local oModel := MPFormModel():New( "OGA080M" )

oStruNK0:AddTrigger( "NK0_CODUSU", "NK0_NOMUSU", { || .t. }, { | x | fTrgNomUsu( x ) } )
oStruNK0:AddTrigger( "NK0_GRPUSU", "NK0_DGRUSU", { || .t. }, { | x | fTrgNomGrp( x ) } )

oModel:AddFields( 'NK0UNICO', Nil, oStruNK0 )
oModel:SetDescription( STR0001 )
oModel:GetModel( 'NK0UNICO' ):SetDescription( STR0010 )

Return oModel


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	12/07/2010
@Uso: 		OGA080 - Indices de Mercado
*/
Static Function ViewDef()
Local oStruNK0 := FWFormStruct( 2, 'NK0')
Local oModel   := FWLoadModel( 'OGA080' )
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_NK0', oStruNK0, 'NK0UNICO' )
oView:CreateHorizontalBox( 'UM'  , 100 )
oView:SetOwnerView( 'VIEW_NK0', 'UM'   )

Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OGA080AltUM³ Autor ³ Marlon R. Trettin   ³ Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera Unidade de Medida de um indice.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OGA080AltUM()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OGA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OGA080AltUM()

Local aSaveArea := GetArea()
Local aButtons  := {}
Local lOK 		  := .F.
Local cNovaUM   := CriaVar("NK0_UM1PRO")
Local oDlg, oSay1, oSay2, oSay3, oGet1

oDlg 	:= TDialog():New( 0, 0, 150, 350, OemToAnsi( STR0013 ),,,,,CLR_BLACK,CLR_WHITE,,,.t.)

oSay1 := TSay():New( 005, 005, {|| OemToAnsi( NK0->NK0_INDICE + " " + NK0->NK0_DESCRI ) }, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 080, 010 )
oSay1 := TSay():New( 020, 005, {|| OemToAnsi( STR0011 ) }, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 080, 010 )
oSay2 := TSay():New( 020, 060, {|| OemToAnsi( NK0->NK0_UM1PRO        ) }, oDlg, , , , , , .t., CLR_BLACK, CLR_GRAY,  030, 010 )
oSay3 := TSay():New( 035, 005, {|| OemToAnsi( STR0012 ) }, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 080, 010 )
oGet1 := TGet():New( 033, 060, {|u| If( PCount() > 0, cNovaUM := u, cNovaUM ) } , oDlg, 030, 010, "@!", { || .t. }, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || .t. }, .f., .f., , .f., .f., "SAH"	,"cNovaUM", , , , )

oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| lOK := .T., oDlg:End() },{|| lOK := .F., oDlg:End() },, @aButtons ) } )

If lOK
	If Empty(cNovaUM)
		MsgAlert(STR0014)
		Return .F.
	EndIf
	// Valida se os indices estão cadastrados na tabela de conversão de indices
	dbSelectArea('NNX')
	dbSetOrder(1)
	If !MsSeek(xFilial('NNX') + NK0->NK0_UM1PRO + cNovaUM)
	    If !MsSeek(xFilial('NNX') + cNovaUM + NK0->NK0_UM1PRO)
			Help(, , STR0015, , STR0016, 1, 0 ) 
			Return .F.	    	
    	EndIf
    EndIf
    
    // Efetua a alteração de Unidade de Medida
	Processa({|| (AlteraUM(cNovaUM)) }, )
EndIf

RestArea(aSaveArea)
Return .T.

/** {Protheus.doc} AlteraUM
Função que altera a unidade de medidas de um indice e recalcula as cotações do indice conforme a nova unidade

@param: 	Nil
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	24/06/2014
@Uso: 		OGA080 - Indices de Mercado
*/
Static Function AlteraUM(pcNovaUM)

Local nValor   := 0
Local cProduto := iif(ColumnPos( 'NK0_CODPRO' ) > 0 , NK0->NK0_CODPRO, "" )
Local cAliasNK1 := GetNextAlias()
Local cQuery := ''
ProcRegua(0)

cQuery += " SELECT *, R_E_C_N_O_ AS NK1_RECNO FROM " + RetSqlName("NK1") + " NK1 "
cQuery += " WHERE NK1.NK1_INDICE = '" + NK0->NK0_INDICE + "' AND NK1.NK1_FILIAL = '" + xFilial("NK1") + "' AND NK1.D_E_L_E_T_ = '' "

cQuery:=ChangeQuery(cQuery)

DbUseArea(.t.,"TOPCONN", TcGenQry(,,cQuery), cAliasNK1,.f.,.T.)
(cAliasNK1)->(dbGoTop())

DbSelectArea("NK1")
While (cAliasNK1)->(!Eof()) 
	IncProc(STR0017)

	// Converte a Cotação (NK1_VALOR) da unidade de medida antiga para a nova
	nValor := 	AGRX001( pcNovaUM, NK0->NK0_UM1PRO, (cAliasNK1)->NK1_VALOR, cProduto)
		
	DbGoTo((cAliasNK1)->NK1_RECNO)
	// Grava a nova cotação
	RecLock("NK1",.F.)
		NK1->NK1_VALOR := nValor
	NK1->(MsUnlock())
	
	(cAliasNK1)->(DbSkip())
EndDo	
(cAliasNK1)->( dbCloseArea() )

// Atualiza a nova Unidade de Medida no Indice
RecLock("NK0",.F.)
	NK0->NK0_UM1PRO := pcNovaUM
NK0->(MsUnlock())

MsgInfo(STR0018)

Return NIL


/** {Protheus.doc} OGA080VLMA
Função que valida o mês e ano.
Função está no dicionário SX3 -X3_VALID do campo NK0_VMESAN

@param: 	Nil
@return:	Nil
@author: 	marcelo.wesan
@since: 	08/11/2017
@Uso: 		OGA080VLMA - Indices de Mercado
*/

Function OGA080VLMA()
	Local lRet      := .F.	
	Local oModel    := FwModelActive()
	Local oModelNK0	:= oModel:GetModel("NK0UNICO")   //AGO/2017 05/2017
	Local cVMes     := oModelNK0:GetValue("NK0_VMESAN")

	   If !Empty(cVMes)
	      cMes := AGRMesAno(cVMes, 1)
	      lRet  := cVMes == cMes    //AGO/2017 
	   EndIf
	
	
	If !lRet
	   Help("",1,"OGA080MES") //formato de mes/ano incorreto. Informe o mes/ano no seguinte formato mmm/aaaa.
	EndIf
	
Return lRet


/*/{Protheus.doc} OGA011ACIM
//TODO realiza a chamada da função responsavel por atualizar os indices de mercado, atualizando a cotação do indice posicionado na tela 
@author claudineia.reinert
@since 06/09/2018
@version 1.0
@return .T., True/Verdadeiro 

@type function
/*/
Function OGA011ACIM()
	
	If !Empty(NK0->NK0_CODP2)
	
		MsgRun( STR0020+NK0->NK0_DESCRI,STR0019, {|| lRet := OGX300C(NK0->NK0_INDICE) } )//"Aguarde" #"Atualizando a cotação do indice "
	
	ElseIf  !Empty(NK0->NK0_CODBOL)
		
		MsgRun( STR0021+NK0->NK0_DESCRI,STR0019, {|| lRet := OGX300D(NK0->NK0_CODBOL,NK0->NK0_INDICE) } )//"Aguarde" #"Atualizando a cotação da bolsa de referencia do indice "
	
	EndIf
	 

Return .T.

/*/{Protheus.doc} fTrgNomUsu( x )
Gatilho para retornar o nome do usuario
@type  Function
@author rafael.kleestadt
@since 15/11/2018
@version 1.0
@param oParModel, object, objeto do modelo
@return cNomUser, caracter, nome completo do usuário
@example
(examples)
@see (links_or_references)
/*/
Static Function fTrgNomUsu( oParModel )
	Local oModel   := oParModel:GetModel()
	Local oNK0	   := oModel:GetModel( "NK0UNICO" )
	Local cNomUser := ""

	cNomUser := UsrFullName( oNK0:GetValue( "NK0_CODUSU" ) )

Return cNomUser

/*/{Protheus.doc} fTrgNomGrp( x )
Gatilho para retornar o nome do grupo de usuario
@type  Function
@author rafael.kleestadt
@since 15/11/2018
@version 1.0
@param oParModel, object, objeto do modelo
@return cNomGrp, caracter, nome completo do grupo de usuário
@example
(examples)
@see (links_or_references)
/*/
Static Function fTrgNomGrp( oParModel )
	Local oModel  := oParModel:GetModel()
	Local oNK0	  := oModel:GetModel( "NK0UNICO" )
	Local cNomGrp := ""

	cNomGrp := IIf(!Empty(oNK0:GetValue( "NK0_GRPUSU" )),GrpRetName( oNK0:GetValue( "NK0_GRPUSU" ) ),"")

Return cNomGrp
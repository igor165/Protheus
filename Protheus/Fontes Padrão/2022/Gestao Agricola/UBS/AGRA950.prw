//#INCLUDE "AGRUTIL01.CH"
#INCLUDE "AGRA950.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"
#DEFINE _CRLF CHR(13)+CHR(10)

/** {Protheus.doc} OGA030
Rotina para Regras e Funções de Aprovação 

@param: 	Nil
@author: 	Marcelo Ferrari
@since: 	29/11/2016
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function AGRA950()

	Local bKeyF12 	:= { || Pergunte('AGRA95001', .T.) }
	Local oMBrowse

	SetKey( VK_F12, bKeyF12 )
	Pergunte('AGRA95001', .F.)
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NJ3" )
	oMBrowse:SetDescription( STR0001 ) //Cadastro de Regras e Funções de Aprovação
	oMBrowse:Activate()

Return()

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Marcelo R. Ferrari
@since: 	21/12/2016
@Uso: 		
*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title OemToAnsi(STR0002)		Action 'PesqBrw'		 	OPERATION 1  ACCESS 0 //Pesquisar
	ADD OPTION aRotina Title OemToAnsi(STR0003)		Action 'VIEWDEF.AGRA950'	OPERATION 2  ACCESS 0 //Visualizar
	ADD OPTION aRotina Title OemToAnsi(STR0004)		Action 'VIEWDEF.AGRA950' 	OPERATION 3  ACCESS 0 //Incluir
	ADD OPTION aRotina Title OemToAnsi(STR0005)		Action 'VIEWDEF.AGRA950' 	OPERATION 4  ACCESS 0 //Alterar
	ADD OPTION aRotina Title OemToAnsi(STR0006)		Action 'VIEWDEF.AGRA950' 	OPERATION 5  ACCESS 0 //Excluir
	ADD OPTION aRotina Title OemToAnsi(STR0007)		Action 'VIEWDEF.AGRA950' 	OPERATION 8  ACCESS 0 //Imprimir
	ADD OPTION aRotina Title OemToAnsi(STR0008)		Action 'VIEWDEF.AGRA950' 	OPERATION 9  ACCESS 0 //Copiar
	ADD OPTION aRotina Title OemToAnsi(STR0009)		Action "AGRA950VAL('NJ5')"  OPERATION 10 ACCESS 0 //Executar

	If ExistBlock('AG950MENU')
		aRet := ExecBlock('AG950MENU',.F.,.F.,{aRotina})
		If ValType(aRet) == 'A'
			aRotina	:= aClone(aRet)
		EndIf
	EndIf

Return aRotina

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	11/10/2013
@Uso: 		OGA030 - Produtos AdicionaisRegras e Funções de Aprovação
*/
Static Function ModelDef()
	Local oStruNJ3 := FWFormStruct( 1, "NJ3" )
	Local oModel := Nil 

	oModel := MPFormModel():New( "AGRA950M", /*<bPre >*/ , /*<bPos>*/, /*<commit>*/ {| oModel | AGRA950GRV( oModel ) })

	oModel:AddFields( 'NJ3UNICO', Nil, oStruNJ3 )
	oModel:SetDescription( STR0001 ) //Cadastro de Regras e Funções de Aprovação
	oModel:GetModel( 'NJ3UNICO' ):SetDescription( STR0001 ) //Cadastro de Regras e Funções de Aprovação

Return oModel


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	11/10/2013
@Uso: 		OGA030 - Produtos Adicionais
*/
Static Function ViewDef()
	Local oStruNJ3 := FWFormStruct( 2, 'NJ3' )
	Local oModel   := FWLoadModel( 'AGRA950' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NJ3', oStruNJ3, 'NJ3UNICO' )
	oView:CreateHorizontalBox( 'UM'  , 100 )
	oView:SetOwnerView( 'VIEW_NJ3', 'UM'   )

Return oView

/** {Protheus.doc} AGRA950GRV
Funcao para gravar dados adicionais e o modelo de dados
@param:     oModel - Modelo de Dados
@return:    .t.
@author:    Equipe AgroIndustria
@since:     23/12/2016
@Uso:       AGRA950
@Ponto de Entrada:
@Data:
*/
Static Function AGRA950GRV( oModel )
	Local aArea := GetArea()
	Local cTipo := cValToChar(oModel:GetOperation())
	Local cMsg  := ""
	Local cValChave := fwXFilial("NJ3")+NJ3->NJ3_CODIGO
	Local cQry := ""
	Local cSql := ""
	Local aValores := Nil
	Local lAltera := .F.

	If cTipo = "4" //Alteração
		cQry := GetNextAlias()
		cSql := "select NJ3_INSTR, NJ3_SIT from " +RetSqlName("NJ3") +" NJ3 " +;
		"where NJ3_FILIAL = '" + fwXFilial("NJ3") + "' " +;
		"and NJ3_CODIGO= '" + NJ3->NJ3_CODIGO + "' " +;
		" and NJ3.D_E_L_E_T_ = '' "
		cSql := ChangeQuery(cSql)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cQry, .F., .T.)

		If (AllTrim((cQry)->NJ3_INSTR)) != (AllTrim(oModel:GetVAlue("NJ3UNICO", "NJ3_INSTR"))) .OR.;
		(AllTrim((cQry)->NJ3_SIT)) != (AllTrim(oModel:GetVAlue("NJ3UNICO", "NJ3_SIT")))
			cMsg := "Alteração da Regra"+_CRLF
			cMsg += "Chave......:"+cValChave+_CRLF
			cMsg += "Situacao...:"+(cQry)->NJ3_SIT+_CRLF
			cMsg += "Instrução..:"+(cQry)->NJ3_INSTR
			lAltera := .T.

			aValores := {}
			aAdd(aValores, "NJ3" )
			aAdd(aValores, cValChave )
			aAdd(aValores, cTipo )
			aAdd(aValores, cMsg )
		EndIF
	EndIf

	If ( lAltera) .OR. (oModel:GetOperation() = 5) 
		AGRGRAVAHIS(STR0010,"NJ3",cValChave, cTipo, aValores) = 1 //Histórico de Regras e Funções de Aprovação
	EndIf	

	RestArea(aArea)

	FWFormCommit(oModel)

Return( .T. )


/** {Protheus.doc} OGA250HIS
Descrição: Mostra em tela de Historico do contrato
@param: 	Nil
@author: 	Marcelo R. Ferrari
@since: 	12/05/2015
@Uso: 		AGRA950 
*/
Function AGRA950HIS()
	Local cChaveI := "NJ3->("+Alltrim(AGRSEEKDIC("SIX","NJ3",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))
	AGRHISTTABE("NJ3",cChaveA)
Return


Function AGRA950VAL(cAliasTab)
	Local aArea := GetArea()
	Local lRet  := .T.
	Local lRetFinal := .T.
	Local aParametros := {}
	Local cAliasNJ3 := GetNextAlias()
	Local cAliasSC5 := GetNextAlias()
	Local cAliasSC6 := GetNextAlias()
	Local cAliasSC9 := GetNextAlias()
	Local cAliasNJ5 := GetNextAlias()
	Local cAliasNJ6 := GetNextAlias()

	Local cSql := ""
	Local cInstr := ""

	Local cPedido := "" 
	Local cItem   := ""
	Local cSequen := ""
	Local cProdut := ""

	If cAliasTab = "NJ5"
		cPedido := (cAliasTab)->NJ5_NUMPV  
		cItem   := (cAliasTab)->NJ5_ITEM
		cSequen := (cAliasTab)->NJ5_SEQUEN
		cProdut := (cAliasTab)->NJ5_PRODUT
	ElseIf cAliasTab = "NJ6"
		cPedido := (cAliasTab)->NJ6_NUMPV 
		cItem   := (cAliasTab)->NJ6_ITEM
		cSequen := (cAliasTab)->NJ6_SEQUEN
		cProdut := (cAliasTab)->NJ6_PRODUT
	EndIf

	//Carrega os dados da SC5
	cSql := "select SC5.* from " +RetSqlName("SC5") +" SC5 "
	cSql += "where SC5.C5_FILIAL = '" + fwXFilial("SC5") + "' "
	cSql += "and SC5.C5_NUM = '" + cPedido + "' "  
	cSql += " AND SC5.D_E_L_E_T_ = '' " 

	cSql := ChangeQuery(cSql)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAliasSC5, .F., .T.)

	//Carrega os itens da SC6
	cSql := "select SC6.* from " +RetSqlName("SC6") +" SC6 "
	cSql += "where SC6.C6_FILIAL = '" + fwXFilial("SC6") + "' "
	cSql += "and SC6.C6_NUM = '" + cPedido + "' "
	cSql += "and SC6.D_E_L_E_T_ = '' " 

	cSql := ChangeQuery(cSql)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAliasSC6, .F., .T.)


	//Carrega os itens da SC9
	cSql := "select SC9.* from " +RetSqlName("SC9") +" SC9 "
	cSql += "where SC9.C9_FILIAL = '" + fwXFilial("SC9") + "' "
	cSql += "and SC9.C9_PEDIDO = '"  + cPedido + "' "
	cSql += "and SC9.C9_ITEM = '"    + cItem   + "' "
	cSql += "and SC9.C9_SEQUEN = '"  + cSequen + "' "
	cSql += "and SC9.C9_PRODUTO = '" + cProdut + "' "
	cSql += "and SC9.D_E_L_E_T_ = '' " 

	cSql := ChangeQuery(cSql)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAliasSC9, .F., .T.)

	//Carrega os itens da NJ5
	cSql := "select NJ5.* from " +RetSqlName("NJ5") +" NJ5 "
	cSql += "where NJ5.NJ5_FILIAL = '"  + fwXFilial("NJ5") + "' "
	cSql += "and   NJ5.NJ5_NUMPV = '"   + cPedido + "' "
	cSql += "and   NJ5.NJ5_ITEM = '"    + cItem   + "' "
	cSql += "and   NJ5.NJ5_SEQUEN = '"  + cSequen + "' "
	cSql += "and   NJ5.NJ5_PRODUT = '"  + cProdut + "' "
	cSql += "and   NJ5.D_E_L_E_T_ = '' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAliasNJ5, .F., .T.)

	//aAdd(aParametros, obj)
	aAdd(aParametros, cAliasSC5)
	aAdd(aParametros, cAliasSC6)
	aAdd(aParametros, cAliasSC9)
	aAdd(aParametros, cAliasNJ5)


	If cAliasTab = "NJ6"
		//Carrega os itens da NJ6.
		cSql := "select NJ6.* from " +RetSqlName("NJ6") +" NJ6 "
		cSql += "where NJ6.NJ6_FILIAL = '" + fwXFilial("NJ6") + "' "
		cSql += "and   NJ6.NJ6_NUMPV = '"  + cPedido + "' "
		cSql += "and   NJ6.NJ6_ITEM = '"   + cItem   + "' "
		cSql += "and   NJ6.NJ6_SEQUEN = '" + cSequen + "' "
		cSql += "and   NJ6.NJ6_PRODUT = '" + cProdut + "' "
		cSql += "and   NJ6.D_E_L_E_T_ = '' "

		cSql := ChangeQuery(cSql)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAliasNJ6, .F., .T.)

		aAdd(aParametros, cAliasNJ6)
	EndIF

	//Carrega os itens da NJ5
	cSql := "select NJ3.* from " +RetSqlName("NJ3") +" NJ3 "
	cSql += "where NJ3.NJ3_FILIAL = '" + fwXFilial("NJ3") + "' "
	cSql += "and   NJ3.NJ3_SIT = '1' "
	cSql += "and   NJ3.D_E_L_E_T_ = '' "
	cSql += "order by NJ3.NJ3_SEQ" 

	cSql := ChangeQuery(cSql)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAliasNJ3, .F., .T.)

	//Executa cada uma das regras e guarda o retorno para o tratamento
	While .NOT.((cAliasNJ3)->(Eof()) )
		cInstr := (cAliasNJ3)->NJ3_INSTR
		lRet := AGRA950EX( @cInstr, aParametros )
		If !lRet
			//Guarda o LOG de Erro na tabela NK9
			AGRA950LOG( cAliasTab, cInstr, cAliasNJ3 )
			lRetFinal := lRet
		EndIf 
		(cAliasNJ3)->(dBSkip())
	End

	RestArea(aArea)

Return lRetFinal


Function AGRA950EX(cInstr, aParametros)
	Local uRetExBlk	:= NIL
	Local bExecBlk	:= Nil
	Local cExecBlk	:= AllTrim(cInstr)

	If (("{" $ cExecBlk ) .AND. ( "}" $ cExecBlk ) .AND. ( "|" $ cExecBlk ) )
		//Instrução com passagem de parâmetros
		cExecBlk	:= TrataInstr(cExecBlk, aParametros)
	Else
		//cExecBlk	:= TrataInstr(cExecBlk, aParametros)
		cExecBlk	:= "{ || "+ TrataInstr(cExecBlk, aParametros) +" }"
	EndIf

	cInstr := cExecBlk

	bExecBlk	:= &( cExecBlk )
	uRetExBlk := Eval( bExecBlk )

Return( uRetExBlk )


/** {Protheus.doc} AGRA950LOG
Funcao para Tratar a instrução, substituindo as variáveis de campos pelos respectivos valores 
@param:    cAliasTab : Alias da consulta de regras que estão sendo executadas
aParametros: Array que contem o nome dos alias das tabelas que serão utilizadas para 
substituição dos valores
@return:    cInstr - Instrução modificada
@author:    Marcelo R. Ferrari
@since:     23/12/2016
@Uso:       AGRA950
@Ponto de Entrada:
@Data:
*/
Static Function TrataInstr(cInstr, aParametros)
	local cNewInstr := cInstr
	local i := 0
	local j := 0
	local aStruTMP := {}
	local cAliasTMP := ""
	local nFields   := 0
	Local cValor    := ""

	For i := 1 to len(aParametros)
		cAliasTMP := aParametros[i]
		aStruTMP := (cAliasTMP)->(DbStruct())
		nFields  := Len(aStruTMP)
		For j := 1 to nFields
			//substitui uma palavra dentro da instrução pelo valor correspondente
			//Exemplo: {|cPedido, cItem, cProd | Minhafunc( [SC5_NUM] , [SC5_ITEM] , [SC5_PRODUTO] ) }
			//Ficaria assim: {|cPedido, cItem, cProd | Minhafunc( '000001' , '01' , 'XXXXX' ) }
			If aStruTMP[j,2] $ 'CD'
				cValor := (cAliasTMP)->&(aStruTMP[j,1])
				If cNewInstr $ "[" .AND. cNewInstr $ "]"  
					cNewInstr := STRTRAN(cNewInstr, '['+aStruTMP[j,1]+']', "'"+cValor+"'" )
				Else
					cNewInstr := STRTRAN(cNewInstr, aStruTMP[j,1], "'"+cValor+"'" )
				EndIf
			else 
				If !(aStruTMP[j,2] $ 'N')
					cValor := (cAliasTMP)->&(aStruTMP[j,1])
					If cNewInstr $ "[" .AND. cNewInstr $ "]"
						cNewInstr := STRTRAN(cNewInstr, '['+aStruTMP[j,1]+']', cValor )
					Else
						cNewInstr := STRTRAN(cNewInstr, aStruTMP[j,1], cValor )
					EndIF
				Else
					//Tipo M não pode ser usado em variável
				EndIf
			EndIf
		Next j
	Next i

Return cNewInstr

/** {Protheus.doc} AGRA950LOG
Funcao para gravar o LOG da validação 
@param:    cAliasTab : Alias da tabela NJ5 - registro corrente que está sendo validado
cInstr : Instrução que foi executada 
cAliasNJ3 :  Alias da tabela de regra - registro corrente
@return:    .t.
@author:    Marcelo R. Ferrari
@since:     23/12/2016
@Uso:       AGRA950
@Ponto de Entrada:
@Data:
*/
Static Function AGRA950LOG( cAliasTab, cInstr, cAliasNJ3 )
	Local aArea := GetArea()
	Local cTipo := "V"
	Local cMsg  := ""
	Local cValChave := ""
	Local aValores := Nil

	Pergunte('AGRA95001', .F.)

	If cAliasTab = "NJ5"
		cValChave := fwXFilial(cAliasTab)+(cAliasTab)->NJ5_CODCAR+(cAliasTab)->NJ5_NUMPV+(cAliasTab)->NJ5_ITEM+(cAliasTab)->NJ5_SEQUEN+(cAliasTab)->NJ5_PRODUT
	ElseIf cAliasTab = "NJ6"
		cValChave := fwXFilial(cAliasTab)+(cAliasTab)->NJ6_CODCAR+(cAliasTab)->NJ6_NUMPV+(cAliasTab)->NJ6_ITEM+(cAliasTab)->NJ6_SEQUEN+(cAliasTab)->NJ6_PRODUT
	EndIf

	cValChave := cValChave + "VALIDACAO"//+(cAliasNJ3)->NJ3_CODIGO 

	cMsg := STR0011 +_CRLF //Validação da Regra
	cMsg += STR0012 +(cAliasNJ3)->NJ3_CODIGO+ _CRLF //REGRA.....:
	cMsg += STR0013 +(cAliasNJ3)->NJ3_DESCRI +_CRLF //DESCRICAO.:
	cMsg += STR0014 +cValToChar((cAliasNJ3)->NJ3_SEQ)+_CRLF //ORDEM.....:
	cMsg += STR0015 +_CRLF //Situacao..:.F.
	cMsg += STR0016  +cInstr+_CRLF //Instrução.:
	cMsg += STR0017 +(cAliasNJ3)->NJ3_MSG+_CRLF //Mensagem..:
	lAltera := .T.

	If mv_par01 == 2
		//PRocura se já existe um LOG para esta chave. Caso sim, deleta o registro para inserir novo
		DbSelectArea("NK9")
		If DbSeek(fwXFilial("NK9")+(cAliasTab)+cValChave)
			RecLock("NK9",.F.)
			DbDelete()
			NK9->(MsUnLock())
		EndIf
	EndIf

	aValores := {}
	aAdd(aValores, "NJ5" )
	aAdd(aValores, cValChave )
	aAdd(aValores, cTipo )
	aAdd(aValores, cMsg )

	AGRGRAVAHIS(STR0010,"NJ3",cValChave, cTipo, aValores)	= 1 //Histórico da Regra de Negócio

	RestArea(aArea)

Return( .T. )


/** {Protheus.doc} AGRA950VLG
Descrição: Mostra em tela de Historico da validação da NJ5
@param: 	Nil
@author: 	Marcelo R. Ferrari
@since: 	23/12/2016
@Uso: 		AGRA950 
*/
Function AGRA950VLG(cAliasTab)
	Local cValChave := ""

	If cAliasTab = "NJ5"
		cValChave := fwXFilial(cAliasTab)+(cAliasTab)->NJ5_CODCAR+(cAliasTab)->NJ5_NUMPV+(cAliasTab)->NJ5_ITEM+(cAliasTab)->NJ5_SEQUEN+(cAliasTab)->NJ5_PRODUT
	ElseIf cAliasTab = "NJ6"
		cValChave := fwXFilial(cAliasTab)+(cAliasTab)->NJ6_CODCAR+(cAliasTab)->NJ6_NUMPV+(cAliasTab)->NJ6_ITEM+(cAliasTab)->NJ6_SEQUEN+(cAliasTab)->NJ6_PRODUT
	EndIf

	cValChave := cValChave + "VALIDACAO"	

	AGRA950VSL(cAliasTab,cValChave)
Return


/*
+=================================================================================================+
| Programa  : AGRA950VSL                                                                         |
| Descrição : Visualisar Histórico da tabela                                                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 18/02/2015                                                                          |
+=================================================================================================+     
| Retorna   : cTabela - Código da tabela                                               Obrigatório|
|             cChave  - Chave de acesso ao registro da tabela                          Obrigatório|
|             nSubStr - Substring da cChave                                            Não Obrigat|
|=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+
*/
static Function AGRA950VSL(cTabela,cChave,nSubStr)
	Local aRot := If(ValType("aRotina") = "A",Aclone(aRotina),{})
	Local cCad := If(Type("cCadastro") <> "U",cCadastro," ")
	Local cFil := If(nSubStr = NIL,"NK9_TABLE = '"+cTabela+"' .And. NK9_CHAVE = '"+cChave+"'",;
	"NK9->NK9_TABLE = '"+cTabela+"' .And. SubStr(NK9->NK9_CHAVE,1,nSubStr) = '"+cChave+"'") 
	aRotina    := {{STR0002,"AxPesqui",0,1},; //Pesquisar
	{STR0003,"AxVisual",0,2}}  //Visualizar
	cCadastro  := AGRSX2NOME("NK9")

	oBrowse    := FWMBrowse():New()
	oBrowse:SetAlias('NK9')
	oBrowse:SetDescription(Alltrim(AGRSX2NOME(cTabela))+" - "+STR0021) //Histórico
	oBrowse:SetFilterDefault(cFil)
	oBrowse:Activate()
	aRotina   := Aclone(aRot)
	cCadastro := cCad
Return

Function AGR950VLD(cParametro, dData, cTipo, uValor )
	Local aArea := GetArea()
	local uRet := nil
	Local cQry := ""
	Local cAliasTmp := GetNextAlias()

	Default cTipo := "N"
	Default dData := dDataBase

	lTeste := .T.
	cQry := "SELECT (CASE "+;
	"WHEN (NJ4_DTINI = '' OR NJ4_DTINI IS NULL) AND "+;
	"(NJ4_DTFIM = '' OR NJ4_DTFIM IS NULL) THEN "+;
	"1 "+;
	"WHEN (NJ4_DTINI <> '' OR NJ4_DTINI IS NOT NULL) AND "+;
	"     (NJ4_DTFIM = '' OR NJ4_DTFIM IS NULL) THEN "+;
	"2 "+;
	"WHEN (NJ4_DTINI = '' OR NJ4_DTINI IS NULL) AND "+;
	"(NJ4_DTFIM <> '' OR NJ4_DTFIM IS NOT NULL) THEN "+;
	"3 "+;
	"WHEN (NJ4_DTINI <> '' OR NJ4_DTINI IS NOT NULL) AND "+;
	"(NJ4_DTFIM <> '' OR NJ4_DTFIM IS NOT NULL) THEN "+;
	" 4 "+;
	"ELSE "+;
	" 5 "+;
	"END) ORDEM "

	cQry += ", NJ4_VALOR "+;
	"FROM " + RetSqlName("NJ4") +" NJ4 "+;
	"WHERE NJ4_CHAVE = '" + cParametro + "' "+;
	"AND NJ4_SIT = '1' "+;
	"AND (   (" + dData + " BETWEEN NJ4_DTINI AND NJ4_DTFIM) "+;
	"OR "+; 
	"(NJ4_DTINI = '' OR NJ4_DTINI IS NULL ) "+;
	"OR  "+;
	"(NJ4_DTFIM = '' OR NJ4_DTFIM IS NULL ) "+;
	") "

	cQry += "ORDER BY ORDEM DESC"

	cQry := ChangeQuery(cQry)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAliasTmp, .F., .T.) 

	If !(Empty((cAliasTmp)->NJ4_VALOR))
		If cTipo = "N"
			uRet := VAL((cAliasTmp)->NJ4_VALOR)
		ElseIf cTipo = "D"
			uRet := CTOD((cAliasTmp)->NJ4_VALOR)
		Else
			uRet := (cAliasTmp)->NJ4_VALOR
		EndIf
	EndIf

	RestArea(aArea)

	If !(Empty(uValor))
		uValor := uRet
	EndIf 

Return uRet


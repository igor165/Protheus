#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA489.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA489
Cadastro MVC de Obras T157

@author Denis de Souza Naves
@since 23/01/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFA489()

Local lAtu as logical
Local oBrw as object
Local aRelacao as array

lAtu := .F.

if FwSX9Util():SearchX9Paths( 'T9C', 'C20', @aRelacao )
	if aScan( aRelacao, { |x| x[1] == 'T9C' .and. x[3] = 'C20' .and. alltrim(x[4]) == "C20_CODOBR"  } ) > 0
		lAtu := .F.
	elseif aScan( aRelacao, { |x| x[1] == 'T9C' .and. x[3] = 'C20' .and. alltrim(x[4]) == "C20_IDOBR"  }) > 0
		lAtu := .T.
	endif
endif

If lAtu
	If TAFColumnPos( "T9C_INDTER" )
		oBrw := FwMBrowse():New()
		oBrw:SetDescription( STR0001 ) //"Cadastro de Obras"
		oBrw:SetAlias("T9C")
		oBrw:SetMenuDef("TAFA489")
		
		oBrw:AddLegend( "T9C_INDTER=='1'", "BLUE"  	, STR0002) //"Obras Terceiro"
		oBrw:AddLegend( "T9C_INDTER=='2'", "YELLOW"	, STR0003) //"Minhas Obras" 
	
		oBrw:Activate()
	Else 
		MsgAlert(STR0020) //"Atenção, existe incompatibilidade de dicionário, aplique o pacote para a criação dos metadados."
	EndIf 
Else 
	TafAviso(STR0021, STR0022, {"Ok"}, 3)//"Dicionário Incompatível" "Atenção, foi identificada uma incompatibilidade em seu dicionário de dados. A execução da rotina UPDTAF é obrigatoria para utilização deste cadastro."
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis de Souza Naves
@since 23/01/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao as array
Local aRotina as array

aFuncao := {}
aRotina := {}

Aadd(aFuncao, {"", "TAFA489PRO()", "9" })

aRotina	:= xFunMnuTAF("TAFA489", , aFuncao)

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis de Souza Naves
@since 23/01/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStrT9C as object
Local oModel  as object

oStrT9C := FwFormStruct(1,"T9C")
oModel 	:= MpFormModel():New("TAFA489",,,)

oModel:AddFields("MODEL_T9C",,oStrT9C)
oModel:GetModel("MODEL_T9C"):SetPrimaryKey({"T9C_FILIAL","T9C_TPINSC","T9C_NRINSC"})

Return(oModel)

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis de Souza Naves
@since 23/01/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel   	as object
Local oStrT9Ca	as object
Local oView     as object
Local cCmpFil 	as character
Local cGrupo1	as character
Local nI       	as numeric
Local aCmpGrp   as array
oModel    	:= FWLoadModel("TAFA489")
oStrT9Ca 	:= Nil
oView     	:= FWFormView():New()

oView:SetModel(oModel)

oStrT9Ca := FwFormStruct( 2, 'T9C')

oView:AddField( 'IDVIEW_T9CA', oStrT9Ca, 'MODEL_T9C' )
oView:CreateHorizontalBox("ID_HTOP",100)
oView:SetOwnerView( "IDVIEW_T9CA", "ID_HTOP")

oStrT9Ca:RemoveField("T9C_ID")

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA489PRO
Funcao que efetua chamada da copia via processa, 
foi criado devido erro na chamada diretamente do menu.

@return Nil

@author Denis de Souza Naves
@since 24/01/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFA489PRO()
	Processa( {|| TAFA489COP() }, STR0004, STR0005,.F.)
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA489COP
Funcao Copia registros Tabela C92(estabelecimentos) - S1005 esocial 
para o modelo do T9C(obras)

@return Nil

@author Denis de Souza Naves
@since 24/01/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFA489COP()

Local cAliasQry		as character
Local cSelect		as character
Local cFrom			as character
Local cWhere		as character
Local nTotReg		as numeric
Local nCont			as numeric
Local nItem			as numeric
Local nOper			as numeric
Local oModel 		as object
Local AutoGrLog		as array
Local aErro 		as array
Local lErro 		as logical
					
cAliasQry := cSelect := cFrom := cWhere := ''
nTotReg := nCont := nItem := 1
nOper := 3
AutoGrLog := aErro := {}
oModel := Nil
lErro := .F.

If MsgYesNo(STR0007) //"Deseja realizar a importação do cadastro de estabelecimentos do esocial (S-1005) para este cadastro?"

	DbSelectArea("T9C")
	T9C->(DbSetOrder(3)) //T9C_FILIAL, T9C_TPINSC, T9C_NRINSC

	nTotReg 	:= nCont := 0
	cAliasQry	:= GetNextAlias()

	cSelect		:= " C92.C92_FILIAL, C92.C92_TPINSC, C92.C92_NRINSC, C92.C92_INDOBR "
	cFrom		:= RetSqlName( "C92" ) + " C92 "
	cWhere		:= " C92.D_E_L_E_T_ = '' "
	//cWhere	+= " AND C92.C92_FILIAL = '" + xFilial( "C92" ) + "' "
	cWhere		+= " AND C92.C92_ATIVO = '1' "

	cSelect	:= "%" + cSelect 	+ "%"
	cFrom  	:= "%" + cFrom   	+ "%"
	cWhere 	:= "%" + cWhere  	+ "%"

	BeginSql Alias cAliasQry
		SELECT %Exp:cSelect% FROM %Exp:cFrom% WHERE %EXP:cWhere%
	EndSql
	
	DBSelectArea(cAliasQry)	
	(cAliasQry )->(DBEVAL({|| ++nTotReg }))
	ProcRegua(nTotReg)
	(cAliasQry)->(DbGoTop())
	
	if (cAliasQry )->(!Eof())
		oModel := FWLoadModel("TAFA489")
		oModel:GetModel( 'MODEL_T9C' )

		While (cAliasQry )->(!Eof())			
			If !Empty((cAliasQry)->C92_TPINSC) .And. !Empty((cAliasQry)->C92_NRINSC)
			
				nOper := iif(T9C->(MsSeek( (cAliasQry)->C92_FILIAL + (cAliasQry)->C92_TPINSC + (cAliasQry)->C92_NRINSC)),4,3)
				oModel:SetOperation(nOper)

				oModel:Activate()

					oModel:LoadValue('MODEL_T9C', "T9C_FILIAL", (cAliasQry)->C92_FILIAL)
					oModel:LoadValue('MODEL_T9C', "T9C_TPINSC", (cAliasQry)->C92_TPINSC)
					oModel:LoadValue('MODEL_T9C', "T9C_NRINSC", (cAliasQry)->C92_NRINSC)
	
					if !empty( (cAliasQry)->C92_INDOBR )
						oModel:LoadValue('MODEL_T9C', "T9C_INDOBR", (cAliasQry)->C92_INDOBR)
					else
						oModel:LoadValue('MODEL_T9C', "T9C_INDOBR", " " )
					endif
	
					oModel:LoadValue('MODEL_T9C', "T9C_DSCOBR", STR0008 + (cAliasQry)->C92_NRINSC) //"Obra "

					//Nao estao no LoadValue devido o inic.padrao, os campos: T9C_INDTER- InicPradao = 2 e T9C_ID - InicPradao = GeraID
	
					If (oModel:VldData())
						oModel:CommitData()
					Else
						aErro   := oModel:GetErrorMessage() ; lErro := .T.
						AutoGrLog(STR0009 + ' [' + cValToChar(nItem++) + ']') 			//"Item: "
						AutoGrLog(STR0010 + ' [' + AllTrim(AllToChar(aErro[1])) + ']')	//"Id do formulário de origem: "
						AutoGrLog(STR0011 + ' [' + AllToChar(aErro[2]) + ']') 			//"Id do campo de origem: "
						AutoGrLog(STR0012 + ' [' + AllToChar(aErro[3]) + ']') 			//"Id do formulário de erro: "
						AutoGrLog(STR0013 + ' [' + AllToChar(aErro[4]) + ']') 			//"Id do campo de erro: "
						AutoGrLog(STR0014 + ' [' + AllToChar(aErro[5]) + ']') 			//"Id do erro: "
						AutoGrLog(STR0015 + ' [' + AllToChar(aErro[6]) + ']') 			//"Mensagem do erro: "
						AutoGrLog(STR0016 + ' [' + AllToChar(aErro[7]) + ']') 			//"Mensagem da solução: "
						AutoGrLog(STR0017 + ' [' + AllToChar(aErro[8]) + ']') 			//"Valor atribuido: "
						AutoGrLog(STR0018 + ' [' + AllToChar(aErro[9]) + ']') 			//"Valor anterior: "
					EndIf

				oModel:DeActivate()

				IncProc(STR0019 + cValTochar(nCont++) + "/" + cValTochar(nTotReg)) //"Carregando: "
			Endif
			( cAliasQry )->(DbSkip())	
		EndDo
		if lErro
			MostraErro()
		endif
	endif
	(cAliasQry)->(DbCloseArea())	
Endif
Return Nil
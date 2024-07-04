#INCLUDE "JURA195.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

Static _cSX5Tmp   := GetNextAlias()

//-------------------------------------------------------------------
/*/{Protheus.doc} Rest195
Sobreposição de métodos (Override) da classe JRestModel, 
para ser possível trabalhar com um modelo utilizado uma tabela temporária.

@author Bruno Ritter / Luciano Pereira
@since 04/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Class Rest195 From JRestModel
	Data oTmpSX5

	Method Activate()
	Method DeActivate()
	Method SetAlias()
	Method Total()
	Method Seek()
	Method Skip()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Activate()
Sobreposição do Activate() da class JRestModel

@author Bruno Ritter / Luciano Pereira
@since 04/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method Activate() Class Rest195
Local cQrySX5   := ""
Local aStruAdic := { {"REC", "REC", "N", 100, 0,""} }
Local cSX5Tab   := self:GetQSValue("SX5TAB")

	If Empty(cSX5Tab)
		cSX5Tab := "12" // Estados
	EndIf
	
	cQrySX5 := " SELECT SX5.X5_FILIAL, SX5.X5_TABELA, SX5.X5_CHAVE, SX5.X5_DESCRI, SX5.X5_DESCSPA, SX5.X5_DESCENG, SX5.R_E_C_N_O_ REC "
	cQrySX5 += " FROM " + RetSqlName("SX5") + " SX5 "
	cQrySX5 += " WHERE SX5.X5_TABELA = '" + Alltrim(cSX5Tab) + "' "

	If Select(GetSx5Tmp()) == 0
		self:oTmpSX5    := JURCRIATMP(GetSx5Tmp(), cQrySX5, "SX5", ,aStruAdic)[1]
	EndIf
	
Return _Super:Activate()

//-------------------------------------------------------------------
/*/{Protheus.doc} DeActivate()
Sobreposição do DeActivate() da class JRestModel

@author Bruno Ritter / Luciano Pereira
@since 04/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method DeActivate() Class Rest195

	If Select(GetSx5Tmp()) != 0
		self:oTmpSX5:Delete()
	EndIf

Return _Super:DeActivate()

//-------------------------------------------------------------------
/*/{Protheus.doc} SetAlias()
Sobreposição do SetAlias() da class JRestModel

@author Bruno Ritter / Luciano Pereira
@since 04/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetAlias(cAlias) Class Rest195
	self:cAlias := GetSx5Tmp()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Total()
Sobreposição do Total() da class JRestModel

@author Bruno Ritter / Luciano Pereira
@since 04/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method Total() Class Rest195
Local cSx5Tmp := GetSx5Tmp()
Local nTotal  := 0

(cSx5Tmp)->(DbEval({|| nTotal++}))
(cSx5Tmp)->(dbGoTop())

Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} Seek()
Sobreposição do Seek() da class JRestModel

@author Bruno Ritter / Luciano Pereira
@since 04/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method Seek(cPk) Class Rest195
Local lRet    := .T.
Local cSx5Tmp := GetSx5Tmp()

	If Empty(cPk)
		(cSx5Tmp)->(DbGotop())
		lRet := !(cSx5Tmp)->(Eof())
	Else
		lRet := (cSx5Tmp)->(DbSeek(cPk))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Skip()
Sobreposição do Skip() da class JRestModel

@author Bruno Ritter / Luciano Pereira
@since 04/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method Skip() Class Rest195
Local lRet    := .F.
Local cSx5Tmp := GetSx5Tmp()

	If self:HasAlias()
		(cSx5Tmp)->(DbSkip())
		lRet := !(cSx5Tmp)->(Eof())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Estados para integração com o LegalDesk.

@author Cristina Cintra
@since 02/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructSX5 := DefStrModel()
Local oModel     := NIL

oModel:= MPFormModel():New( "JURA195", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "SX5MASTER", /*cOwner*/, oStructSX5,/*Pre-Validacao*/, { |oM| J195PosVal(oM) }/*Pos-Validacao*/, { |oM| J195LOAD() })
oModel:GetModel( "SX5MASTER" ):SetDescription( STR0001 ) //"SX5 - Integração LegalDesk"
oModel:SetPrimaryKey( {"X5_FILIAL", "X5_TABELA", "X5_CHAVE"} ) 

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J195PosVal
Valida a operação permitindo apenas a visualização.

@author Bruno Ritter / Luciano Pereira
@since 04/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J195PosVal(oModel)
Local lRet := .T.

If oModel:GetOperation() != MODEL_OPERATION_VIEW
	JurMsgErro(STR0004) //"Modelo de dados apenas para visualização"
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DefStrModel
Monta manualmente a estrutura do model.

@author Bruno Ritter / Luciano Pereira
@since 04/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DefStrModel()
Local oStruct    := FWFormModelStruct():New()
Local oStructSX5 := FWFormStruct(1, "SX5")
Local aCamposSx5 := oStructSX5:GetFields()
Local aTableSx5  := oStructSX5:GetTable()
Local aIndexSx5  := oStructSX5:GetIndex()
Local nCpo       := 1
Local nIdx       := 1

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable( ;
	"   "  ,;  // [01] Alias da tabela
	aTableSx5[2] ,;  // [02] Array com os campos que correspondem a primary key
	aTableSx5[3]   ) // [03] Descrição da tabela

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	For nIdx := 1 To Len(aIndexSx5)
		oStruct:AddIndex(     ;
		aIndexSx5[nIdx][1]  , ; // [01] Ordem do indice
		aIndexSx5[nIdx][2]  , ; // [02] ID
		aIndexSx5[nIdx][3]  , ; // [03] Chave do indice
		aIndexSx5[nIdx][4]  , ; // [04] Descrição do indice
		aIndexSx5[nIdx][5]  , ; // [05] Expressão de lookUp dos campos de indice
		aIndexSx5[nIdx][6]  , ; // [06] Nickname do indice
		aIndexSx5[nIdx][7]    ) // [07] Indica se o indice pode ser utilizado pela interface
	Next nIdx

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------
	For nCpo := 1 To Len(aCamposSx5)
		oStruct:AddField( ;
		aCamposSx5[nCpo][1]  , ;  // [01] Titulo do campo
		aCamposSx5[nCpo][2]  , ;  // [02] ToolTip do campo
		aCamposSx5[nCpo][3]  , ;  // [03] Id do Field
		aCamposSx5[nCpo][4]  , ;  // [04] Tipo do campo
		aCamposSx5[nCpo][5]  , ;  // [05] Tamanho do campo
		aCamposSx5[nCpo][6]  , ;  // [06] Decimal do campo
		aCamposSx5[nCpo][7]  , ;  // [07] Code-block de validação do campo
		aCamposSx5[nCpo][8]  , ;  // [08] Code-block de validação When do campo
		aCamposSx5[nCpo][9]  , ;  // [09] Lista de valores permitido do campo
		aCamposSx5[nCpo][10] , ;  // [10] Indica se o campo tem preenchimento obrigatório
		aCamposSx5[nCpo][11] , ;  // [11] Code-block de inicializacao do campo
		aCamposSx5[nCpo][12] , ;  // [12] Indica se trata-se de um campo chave
		aCamposSx5[nCpo][13] , ;  // [13] Indica se o campo pode receber valor em uma operação de update.
		aCamposSx5[nCpo][14] , ;  // [14] Indica se o campo é virtual
		aCamposSx5[nCpo][15] , )  // [15] Valid do usuário em formato texto e sem alteração, usado para se criar o aheader de compatibilidade.
	Next nCpo

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} J193LOAD
Carrega as informações do alias temporário da SX5

@author Bruno Ritter
@since 04/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J195LOAD()
Local aRet    := {}
Local cSx5Tmp := GetSx5Tmp()

aRet := {{ (cSx5Tmp)->X5_FILIAL  ,;
           (cSx5Tmp)->X5_TABELA  ,;
           (cSx5Tmp)->X5_CHAVE   ,;
           (cSx5Tmp)->X5_DESCRI  ,;
           (cSx5Tmp)->X5_DESCSPA ,;
           (cSx5Tmp)->X5_DESCENG  } , (cSx5Tmp)->REC }

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSx5Tmp
Retorna o alias temporario da SX5

@author Bruno Ritter / Luciano Pereira
@since 04/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetSx5Tmp()
Return _cSX5Tmp

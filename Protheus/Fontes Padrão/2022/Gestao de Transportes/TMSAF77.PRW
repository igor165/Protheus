#INCLUDE "TMSAF77.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
-----------------------------------------------------------
{Protheus.doc} TMSAF77()
Tipos de Acrescimo/Decrescimo 

Uso: SIGATMS

@sample
//TMSAF77()

@author Valdemar Roberto Mognon.
@since 21/05/2015
@version 1.0
-----------------------------------------------------------
*/

Function TMSAF77()
Local oBrowse

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DDI")
oBrowse:SetMenuDef("TMSAF77")
oBrowse:SetDescription(STR0001)	//-- Tipos de Acrescimo/Decrescimo
oBrowse:Activate()

Return Nil            

/*
-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  

Uso: TMSAF77

@sample
//MenuDef()

@author Valdemar Roberto Mognon
@since 21/05/2015
@version 1.0
-----------------------------------------------------------
*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //-- Pesquisar
ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSAF77" OPERATION 2 ACCESS 0 //-- Visualizar
ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSAF77" OPERATION 3 ACCESS 0 //-- Incluir
ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSAF77" OPERATION 4 ACCESS 0 //-- Alterar
ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSAF77" OPERATION 5 ACCESS 0 //-- Excluir

Return aRotina

/*
-----------------------------------------------------------
{Protheus.doc} ModelDef()
Definição do Modelo

Uso: TMSAF77

@sample
//ModelDef()

@author Valdemar Roberto Mognon
@since 21/05/2015
@version 1.0
-----------------------------------------------------------
*/

Static Function ModelDef()
Local oModel
Local oStruDDI

oStruDDI:= FWFormStruct(1,"DDI")

oModel := MPFormModel():New("TMSAF77",,{|oModel|PosVldMdl(oModel)},/*bCommit*/, /*bCancel*/)

oModel:AddFields("MdFieldDDI",,oStruDDI,,,/*Carga*/)
oModel:GetModel("MdFieldDDI"):SetDescription(STR0001)	//-- Tipos de Acrescimo/Decrescimo
oModel:SetPrimaryKey({"DDI_FILIAL","DDI_CODNEG"})  
     
oModel:SetActivate()
     
Return oModel 

/*
-----------------------------------------------------------
{Protheus.doc} ViewDef()
Definição da View

Uso: TMSAF77

@sample
//ViewDef()

@author Valdemar Roberto Mognon
@since 21/05/2015
@version 1.0
-----------------------------------------------------------
*/

Static Function ViewDef()     
Local oModel
Local oStruDDI
Local oView

oModel   := FwLoadModel("TMSAF77")
oStruDDI := FWFormStruct(2,"DDI")

oView := FwFormView():New()

oView:SetModel(oModel)     
oView:AddField('VwFieldDDI',oStruDDI,"MdFieldDDI")
oView:CreateHorizontalBox("CABECALHO",100)  
oView:SetOwnerView("VwFieldDDI","CABECALHO")

Return oView

/*
-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
Validação do Modelo

Uso: TMSAF77

@sample
//PosVldMdl(oModel)

@author Valdemar Roberto Mognon
@since 21/05/2015
@version 1.0
-----------------------------------------------------------
*/
Static Function PosVldMdl(oModel)
Local aArea      := GetArea()
Local lRet       := .T.
Local nOperation := 0
Local cQuery     := ""
Local cAliasQry  := ""

nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_DELETE //.Or. nOperation == MODEL_OPERATION_UPDATE
	cAliasQry := GetNextAlias()
	cQuery := "SELECT COUNT(*) NTOTAL "
	cQuery += "  FROM " + RetSQLName("DDN") + " DDN "
	cQuery += " WHERE DDN.DDN_FILIAL = '" + xFilial("DDN") + "' "
	cQuery += "   AND DDN.DDN_CODAED = '" + DDI->DDI_CODAED + "' "
	cQuery += "   AND DDN.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	
	If (cAliasQry)->NTOTAL > 0                
		Help('',1,'TMSAF7701') //-- Não é permitido alterar / excluir um Tipo de Acrescimo/Decrescimo já relacionado a um contrato.
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
EndIf	

Return lRet



/*/{Protheus.doc} AF77GrvDDN
//TODO Realiza a gravação da tabela DDN - Acrescimos/Decrescimos
@author caio.y
@since 19/01/2017
@version undefined
@param nOpcx, numeric, Opção de inclusão,alteração ou exclusao
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Código da viagem
@param cNumCTC, characters, Numero do Contrato
@param cCodAED, characters, Codigo da tabela DDI
@param nValor, numeric, Valor Acrescimo / Decrescimo
@param cFilOco, characters, Filial da Ocorrencia
@param cNumOco, character, Numero da ocorrencia
@param cSeqOco, character, Sequencia da ocorrencia
@type function
/*/
Function AF77GrvDDN( nOpcx , cFilOri, cViagem , cNumCTC , cCodAED ,  nValor , cFilOco, cNumOco, cSeqOco  )
Local lRet		:= .T. 
Local aArea		:= GetArea()
Local cSequen	:= StrZero(1,Len(DDN->DDN_SEQUEN))
Local lAptOco	:= DDN->(ColumnPos('DDN_FILOCO')) > 0 

Default nOpcx	:= 3 
Default cFilOri	:= ""
Default cViagem	:= ""
Default cNumCTC	:= ""
Default cCodAED	:= ""
Default nValor	:= 0
Default cFilOco	:= ""
Default cNumOco	:= ""
Default cSeqOco	:= ""

If nOpcx == 3
	cSequen		:= GetLastSeq(cFilOri, cViagem , cNumCTC )
	
	RecLock("DDN",.T.)
	DDN->DDN_FILIAL		:= xFilial("DDN")
	DDN->DDN_FILORI		:= cFilOri
	DDN->DDN_VIAGEM		:= cViagem
	DDN->DDN_NUMCTC		:= cNumCTC	
	DDN->DDN_SEQUEN		:= cSequen
	DDN->DDN_CODAED		:= cCodAED
	DDN->DDN_VALOR		:= nValor
	DDN->DDN_DATLAN		:= dDataBase
	DDN->DDN_HORLAN		:= Left(StrTran(Time(),":",""),4)
	DDN->DDN_CODUSU 	:= __cUserID
	
	If lAptOco
		DDN->DDN_FILOCO		:= cFilOco
		DDN->DDN_NUMOCO 	:= cNumOco
		DDN->DDN_SEQOCO		:= cSeqOco		
	EndIf 
	
	DDN->(MsUnlock())
ElseIf nOpcx == 4 
	cSequen 	:= GetLastSeq(cFilOri, cViagem , cNumCTC )
	
	DDN->( dbSetOrder(1)) //-- DDN_FILIAL+DDN_FILORI+DDN_NUMCTC+DDN_SEQUEN
	If DDN->( MsSeek( xFilial("DDN") + cFilOri + cNumCTC + cSequen ))
		RecLock("DDN",.F.)
		DDN->DDN_FILIAL		:= xFilial("DDN")
		DDN->DDN_FILORI		:= cFilOri
		DDN->DDN_VIAGEM		:= cViagem
		DDN->DDN_NUMCTC		:= cNumCTC	
		DDN->DDN_CODAED		:= cCodAED
		DDN->DDN_VALOR		:= nValor
		DDN->DDN_DATLAN		:= dDataBase
		DDN->DDN_HORLAN		:= Left(StrTran(Time(),":",""),4)
		DDN->DDN_CODUSU 	:= __cUserID
		
		If lAptOco
			DDN->DDN_FILOCO		:= cFilOco
			DDN->DDN_NUMOCO 	:= cNumOco
			DDN->DDN_SEQOCO		:= cSeqOco		
		EndIf
		
		DDN->(MsUnlock())
	EndIf
	
ElseIf nOpcx == 5 
	
	If lAptOco
		DDN->( dbSetOrder(3)) //-- DDN_FILIAL+DDN_FILOCO+DDN_NUMOCO+DDN_SEQOCO
		If DDN->( MsSeek( xFilial("DDN") + cFilOco + cNumOco + cSeqOco ))
			RecLock("DDN",.F.)
			DDN->( DBDelete() )
			DDN->( MsUnlock() )		
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*/{Protheus.doc} GetLastSeq
//TODO Retorna a ultima sequencia do campo DDN_SEQUEN
@author caio.y
@since 19/01/2017
@version undefined
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@param cNumCTC, characters, Numero do Contrato
@type function
/*/
Static Function GetLastSeq(cFilOri, cViagem , cNumCTC )
Local cSeq		:= StrZero(1,Len(DDN->DDN_SEQUEN))
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()

Default cFilOri	:= ""
Default cViagem	:= ""
Default cNumCTC	:= ""

cQuery	:= " SELECT MAX(DDN_SEQUEN) SEQUEN"
cQuery	+= " FROM " + RetSQLName("DDN") + " DDN "
cQuery	+= " WHERE DDN_FILIAL = '" + xFilial("DDN") + "'  "
cQuery	+= " AND DDN_FILORI = '" + cFilOri + "' "
cQuery	+= " AND DDN_VIAGEM = '" + cViagem + "' "
cQuery	+= " AND DDN_NUMCTC = '" + cNumCTC + "' "
cQuery	+= " AND DDN.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
While (cAliasQry)->(!Eof())
	cSeq	:= Soma1( (cAliasQry)->SEQUEN )
	(cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->(dbCloseArea())

Return cSeq


/*
============================================================================================================
/{Protheus.doc} TMSA77Whn
//TODO validação de campos X3_WHEN
@author tiago.dsantos
@since 31/03/2017
@version undefined

@type function
============================================================================================================
/*/
Function TMSA77Whn()
Local oModel    := FwModelActive() //| Recebe o Modelo Ativo
Local oView     := Nil
Local oMdlField := Nil
Local cCampo    := ""
Local aSelected := ""
Local lRet      := .T.

	//| Se chamado por alguma rotina que não seja MVC trava o campo de tipo acrescimo/decrescimo
	If ValType(oModel) != "O" .Or. oModel:cId <> "TMSAF77"
		cCampo := ReadVar()
		If cCampo == "M->DDI_TIPAED" 
			lRet := .F.
		EndIf
	EndIf
	
	oView     := FwViewActive()
	oMdlField := oModel:getModel("MdFieldDDI")
	cCampo    := ReadVar()
	
	If ValType(oView) == "O"
		aSelected := oView:getCurrentSelected()
		If ValType(aSelected[2]) == "C"
			cCampo := "M->"+aSelected[2]
		EndIf
	EndIf
	
	If cCampo == "M->DDI_TPREEM"
		lRet := oMdlField:GetValue('DDI_TIPAED') == '1'		
	EndIf
Return lRet

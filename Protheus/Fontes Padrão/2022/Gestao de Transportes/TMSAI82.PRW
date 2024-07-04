#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAI82.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSAI82
Tipos de Registro
@type Function
@author Valdemar Roberto Mognon
@since 28/02/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI82()
(examples)
@see (links_or_references)
*/

Function TMSAI82()
Local oBrowse := Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DN2")
oBrowse:SetMenuDef("TMSAI82")
oBrowse:SetDescription(STR0001)	//-- Tipos de Registro
oBrowse:Activate()

Return

/*{Protheus.doc} MenuDef
    Definição do aRotina (Menu funcional)
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 28/02/2022
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example MenuDef()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0	//-- Pesquisar
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAI82" OPERATION 2 ACCESS 0	//-- Visualizar
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSAI82" OPERATION 3 ACCESS 0	//-- Incluir
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAI82" OPERATION 4 ACCESS 0	//-- Alterar
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSAI82" OPERATION 5 ACCESS 0	//-- Excluir
ADD OPTION aRotina TITLE STR0017 ACTION "TMSAI82Atv()   " OPERATION 2 ACCESS 0	//-- Ativa/Desativa
ADD OPTION aRotina TITLE STR0022 ACTION "TMSAI82Cop()   " OPERATION 2 ACCESS 0	//-- Cópia

Return (aRotina)

/*{Protheus.doc} ModelDef
Definição do Modelo
@type Static Function
@author Valdemar Roberto Mognon
@since 28/02/2022
@version P12 R12.1.20
@param param, param_type, param_descr
@return return, return_type, return_description
@example ModelDef()
(examples)
@see (links_or_references)
*/

Static Function ModelDef()
Local oModel
Local oStruDN2 := FwFormStruct(1,"DN2")
Local oStruDN3 := FwFormStruct(1,"DN3")
Local oStruDNB

oModel := MpFormModel():New("TMSAI82", /*bPreValidacao*/, {|oModel| TMSAI82Pos(oModel)} , /*bCommit*/ , /*bCancel*/ )
oModel:SetDescription(STR0001)	//-- Tipos de Registro

//-- Cabeçalho
oModel:AddFields("MdFieldDN2",,oStruDN2,,,)
oModel:SetPrimaryKey({"DN2_CODFON","DN2_CODREG"})
oModel:GetModel("MdFieldDN2"):SetDescription(STR0001)	//-- Tipos de Registro

//-- Itens
//-- Layout
oModel:AddGrid("MdGridDN3","MdFieldDN2",oStruDN3,,,,,)
oModel:SetRelation("MdGridDN3",{{"DN3_FILIAL","xFilial('DN3')"},;
								{"DN3_CODFON","DN2_CODFON"},;
								{"DN3_CODREG","DN2_CODREG"}},;
								DN3->(IndexKey(1)))
oModel:GetModel("MdGridDN3"):SetDescription(STR0007)	//-- Layout
oModel:GetModel("MdGridDN3"):SetUniqueLine({"DN3_SEQUEN"})
oModel:GetModel("MdGridDN3"):SetOptional(.T.)

If AliasInDic("DNB")
	//-- Herança Id Externo
	oStruDNB := FwFormStruct(1,"DNB")
	oModel:AddGrid("MdGridDNB","MdFieldDN2",oStruDNB,,,,,)
	oModel:SetRelation("MdGridDNB",{{"DNB_FILIAL","xFilial('DNB')"},;
									{"DNB_CODFON","DN2_CODFON"},;
									{"DNB_CODREG","DN2_CODREG"}},;
									DNB->(IndexKey(1)))
	oModel:GetModel("MdGridDNB"):SetDescription(STR0012)	//-- Herança Id Externo
	oModel:GetModel("MdGridDNB"):SetUniqueLine({"DNB_REGDES"})
	oModel:GetModel("MdGridDNB"):SetOptional(.T.)
EndIf

oModel:SetVldActivate({|oModel| TMSAI82Pre(oModel)})

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@type Static Function
@author Valdemar Roberto Mognon
@since 28/02/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example ViewDef()
(examples)
@see (links_or_references)
*/

Static Function ViewDef()
Local oModel   := FwLoadModel("TMSAI82")
Local oStruDN2 := FwFormStruct(2,"DN2")
Local oStruDN3 := FwFormStruct(2,"DN3")
Local oStruDNB
Local oView

oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define o tamanho da tela principal
oView:CreateHorizontalBox("Cabecalho",040)
oView:CreateHorizontalBox("Layout",Iif(AliasInDic("DNB"),035,060))
If AliasInDic("DNB")
	oView:CreateHorizontalBox("Heranca",025)
EndIf

//-- Cria área da tabela pai
oView:AddField("VwFieldDN2",oStruDN2,"MdFieldDN2") 
oView:EnableTitleView("VwFieldDN2",STR0001)	//-- Tipos de Registro
oView:SetOwnerView("VwFieldDN2","Cabecalho")

//-- Cria área das tabelas filhas
//-- Layout
oView:AddGrid("VwGridDN3",oStruDN3,"MdGridDN3")
oView:EnableTitleView("VwGridDN3",STR0007)	//-- Layout
oView:SetOwnerView("VwGridDN3","Layout")
oView:AddIncrementField("VwGridDN3","DN3_SEQUEN")

If AliasInDic("DNB")
	//-- Herança Id Externo
	oStruDNB := FwFormStruct(2,"DNB")
	oView:AddGrid("VwGridDNB",oStruDNB,"MdGridDNB")
	oView:EnableTitleView("VwGridDNB",STR0012)	//-- Herança Id Externo
	oView:SetOwnerView("VwGridDNB","Heranca")
EndIf

Return oView

/*{Protheus.doc} TMSAI82SX3
Retorna Campos da SX3
@type Function
@author Valdemar Roberto Mognon
@since 28/02/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI82SX3()
(examples)
@see (links_or_references)
*/

Function TMSAI82SX3(cCampo,cRetorno)
Local xRet := ""
Local nPos := 0

Default cCampo   := ""
Default cRetorno := ""

nPos := At("_",cCampo)

If (nPos == 4 .And. Left(cCampo,3) == M->DN2_ALIAS) .Or. (nPos == 3 .And. "S" + Left(cCampo,2) == M->DN2_ALIAS)
	If !Empty(cCampo)
		aStruct := FWSX3Util():GetFieldStruct(cCampo)
		If cRetorno == "DESCRIC"
			xRet := FWSX3Util():GetDescription(cCampo)
		ElseIf cRetorno == "TIPO"
			xRet := aStruct[2]
		ElseIf cRetorno == "TAMANHO"
			xRet := aStruct[3]
		ElseIf cRetorno == "DECIMAL"
			xRet := aStruct[4]
		EndIf
	EndIf
EndIf

Return xRet

/*{Protheus.doc} TMSAI82SX2
Retorna Nome da Tabela
@type Function
@author Valdemar Roberto Mognon
@since 04/03/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI82SX2()
(examples)
@see (links_or_references)
*/

Function TMSAI82SX2(cAlias)
Local cRet  := ""
Local aArea := GetArea()

Default cAlias := ""

cRet := FwSX2Util():GetX2Name(cAlias)

RestArea(aArea)
FwFreeArray(aArea)

Return cRet

/*{Protheus.doc} TMSAI82Val
Valida Existência do Campo na SX3
@type Function
@author Valdemar Roberto Mognon
@since 28/02/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI82Val()
(examples)
@see (links_or_references)
*/

Function TMSAI82Val(cAlias,cCampo)
Local lRet  := .T.
Local aArea := GetArea()
Local nPos  := 0

Default cAlias := ""
Default cCampo := ""

nPos := At("_",cCampo)

If (nPos == 4 .And. Left(cCampo,3) == cAlias) .Or. (nPos == 3 .And. "S" + Left(cCampo,2) == cAlias)
	DbSelectArea(cAlias)
	
	lRet := &(cAlias + "->(ColumnPos('" + AllTrim(cCampo) + "')) > 0")
EndIf

RestArea(aArea)
FwFreeArray(aArea)

Return lRet

/*{Protheus.doc} TMSAI82Ind
Valida a Existência do Índice na SIX
@type Function
@author Valdemar Roberto Mognon
@since 28/02/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI82Ind()
(examples)
@see (links_or_references)
*/

Function TMSAI82Ind(cAlias,cIndice,lValida)
Local aArea := GetArea()
Local xRet

Default cAlias  := ""
Default cIndice := ""
Default lValida := .F.

DbSelectArea(cAlias)

cIndice := Iif(Asc(cIndice) < 65,cIndice,AllTrim(Str(Asc(cIndice) - 55)))

If lValida
	xRet := &("!Empty(" + cAlias + "->(IndexKey(" + AllTrim(cIndice) + ")))")
Else
	xRet := &(cAlias + "->(IndexKey(" + AllTrim(cIndice) + "))")
EndIf

RestArea(aArea)
FwFreeArray(aArea)

Return xRet

/*{Protheus.doc} TMSAI82Pre
Valida a Entrada da Tela
@type Function
@author Valdemar Roberto Mognon
@since 20/05/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI82Pre()
(examples)
@see (links_or_references)
*/

Static Function TMSAI82Pre(oModel)
Local aAreas     := {DN5->(GetArea()),GetArea()}
Local lRet       := .T.
Local nOperation := 0

Default oModel := FwModelActive()

nOperation := oModel:GetOperation()

If nOperation == 4 .Or. nOperation == 5
	DN5->(DbSetOrder(1))
	If DN5->(DbSeek(xFilial("DN5") + DN2->DN2_CODFON + DN2->DN2_CODREG))
		lRet := MsgYesNo("Ja existem registro no histórico opara este layou. Confirma a alteração mesmo assim?")
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSAI82Pos
Valida a Confirmação da Tela
@type Function
@author Valdemar Roberto Mognon
@since 17/06/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI82Pos()
(examples)
@see (links_or_references)
*/

Function TMSAI82Pos(oModel)
Local aAreas     := {DN3->(GetArea()),GetArea()}
Local aMsgErr	 := {}
Local nOperation := 0
Local nPosIni    := 0
Local nPosFim    := 0
Local cBase      := ""
Local cCampo     := ""
Local oMdFldDN2

Default oModel := FwModelActive()

oMdFldDN2  := oModel:GetModel("MdFieldDN2")
nOperation := oModel:GetOperation()

If nOperation == 3 .Or. nOperation == 4
	cBase := oMdFldDN2:GetValue("DN2_BASE")

	//-- Verifica se algum campo do layout não consta na base do JSon
	DN3->(DbSetOrder(1))
	If DN3->(DbSeek(cSeekDN3 := xFilial("DN3") + DN2->(DN2_CODFON + DN2_CODREG)))
		While DN3->(!Eof()) .And. DN3->(DN3_FILIAL + DN3_CODFON + DN3_CODREG) == cSeekDN3
			If At(AllTrim(DN3->DN3_CAMPO),cBase) == 0
				AAdd(aMsgErr,{STR0013 + AllTrim(DN3->DN3_CAMPO) + STR0014,"00",""})	//-- Campo # do layout não existe na base.
			EndIf
			DN3->(DbSkip())
		EndDo
	EndIf

	//-- Verifica se alguma TAG da base não está cadastrada no layout
	DN3->(DbSetOrder(2))
	While (nPosIni := At("#",cBase)) > 0
		cBase   := Left(cBase,nPosIni - 1) + "&" + SubStr(cBase,nPosIni + 1)
		If (nPosFim := At ("#",cBase)) > 0
			cCampo  := SubStr(cBase,nPosIni + 1,nPosFim - nPosIni - 1)
			cBase   := Left(cBase,nPosIni - 1) + SubStr(cBase,nPosFim + 1)
			If !DN3->(DbSeek(cSeekDN3 := xFilial("DN3") + DN2->(DN2_CODFON + DN2_CODREG) + cCampo))
				AAdd(aMsgErr,{STR0015 + cCampo + STR0016,"00",""})	//-- TAG # " da base não existe no layout."
			EndIf
		EndIf
	EndDo
EndIf

If Len(aMsgErr) > 0
	TmsMsgErr(aMsgErr)
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return .T.

/*{Protheus.doc} TMSAI82Atv
Ativa/Desativa registro
@type Function
@author Valdemar Roberto Mognon
@since 17/06/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI82Atv()
(examples)
@see (links_or_references)
*/

Function TMSAI82Atv()
Local aAreas := {DN2->(GetArea()),GetArea()}

If MsgYesNo(STR0018 + STR0019 + "/" + STR0020 + STR0021)	//-- Confirma ativação/desativação do registro?
	RecLock("DN2",.F.)
	DN2->DN2_ATIVO := Iif(DN2->DN2_ATIVO == "1","2","1")
	DN2->(MsUnlock())
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} TMSAI82Cop
Copia registro
@type Function
@author Valdemar Roberto Mognon
@since 17/06/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI82Cop()
(examples)
@see (links_or_references)
*/

Function TMSAI82Cop()
Local nOpca   := 0
Local cRegBas := DN2->DN2_CODREG
Local cNewReg := Space(Len(DN2->DN2_CODREG))
Local oDlgCop

DEFINE MSDIALOG oDlgCop TITLE STR0023 FROM 15,20 TO 25,62	//-- Cópia de Registro
	@ 005,007 SAY STR0024 SIZE 100,15 PIXEL	//-- Registro Base:
	@ 005,050 GET cRegBas SIZE 50,10 PIXEL WHEN .F.

	@ 017,007 SAY STR0025 SIZE 100,15 PIXEL	//-- Novo Registro:
	@ 017,050 GET cNewReg SIZE 50,10 PIXEL

	DEFINE SBUTTON FROM 52,128 TYPE 1 ACTION (nOpca := 1,oDlgCop:End()) ENABLE OF oDlgCop
ACTIVATE MSDIALOG oDlgCop CENTERED

If nOpca == 1 .And. !Empty(cNewReg)
	FWMsgrun(,{|| Copiando(cRegBas,cNewReg)},STR0026,STR0027)	//-- Copiando registros. # Aguarde.
EndIf

Return

/*{Protheus.doc} Copiando
Executa cópia dos registros
@type Static Function
@author Valdemar Roberto Mognon
@since 17/06/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI82Cop()
(examples)
@see (links_or_references)
*/

Static Function Copiando(cRegBas,cNewReg)
Local aArea    := GetArea()
Local aAreaDN2 := {}
Local aAreaDN3 := {}
Local aAreaDNB := {}
Local aCampos  := {}
Local cSeekDN3 := ""
Local cSeekDNB := ""

Default cRegBas := ""
Default cNewReg := ""

//-- Copia a DN2
aAreaDN2 := DN2->(GetArea())
aCampos := {}
Aadd(aCampos,{"DN2_CODREG",cNewReg})
DN2->(TmsCopyReg(aCampos))
RestArea(aAreaDN2)

//-- Copia a DN3
DN3->(DbSetOrder(1))
If DN3->(DbSeek(cSeekDN3 := xFilial("DN3") + DN2->DN2_CODFON + cRegBas))
	While DN3->(!Eof()) .And. DN3->(DN3_FILIAL + DN3_CODFON + DN3_CODREG) == cSeekDN3
		aAreaDN3 := DN3->(GetArea())
		aCampos := {}
		Aadd(aCampos,{"DN3_CODREG",cNewReg})
		DN3->(TmsCopyReg(aCampos))
		RestArea(aAreaDN3)
		DN3->(DbSkip())
	EndDo
EndI

//-- Copia a DNB
DNB->(DbSetOrder(1))
If DNB->(DbSeek(cSeekDNB := xFilial("DNB") + DN2->DN2_CODFON + cRegBas))
	While DNB->(!Eof()) .And. DNB->(DNB_FILIAL + DNB_CODFON + DNB_CODREG) == cSeekDNB
		aAreaDNB := DNB->(GetArea())
		aCampos := {}
		Aadd(aCampos,{"DNB_CODREG",cNewReg})
		DNB->(TmsCopyReg(aCampos))
		RestArea(aAreaDNB)
		DNB->(DbSkip())
	EndDo
EndI

RestArea(aArea)

FwFreeArray(aAreaDNB)
FwFreeArray(aAreaDN3)
FwFreeArray(aAreaDN2)
FwFreeArray(aArea)

Return

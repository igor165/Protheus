#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'GCPA110.ch'

/*/{Protheus.doc} GCPA110()
Cadastro de permissões
@author antenor.silva
@since 05/09/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA110() 
Local oBrowse  

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("COT")                                          
oBrowse:SetDescription(STR0001) //"Cadastro de Permissões"
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author antenor.silva
@since 05/09/2013
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)

/*/
//-------------------------------------------------------------------
Static Function MenuDef()  

Local aRotina := {} //Array utilizado para controlar opcao selecionada


aAdd(aRotina,{STR0002,	"VIEWDEF.GCPA110",0,1,1,NIL})   //"Pesquisar"
aAdd(aRotina,{STR0003,	"VIEWDEF.GCPA110",0,2,1,NIL}) 	 //"Visualizar"
aAdd(aRotina,{STR0004,	"VIEWDEF.GCPA110",0,3,1,NIL})	 //"Incluir"
aAdd(aRotina,{STR0005,	"VIEWDEF.GCPA110",0,4,1,NIL}) 	 //"Alterar"
aAdd(aRotina,{STR0006,	"VIEWDEF.GCPA110",0,5,1,NIL}) 	 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author antenor.silva

@since 05/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel

 
Local oStr1:= FWFormStruct(1,'COT')
 
Local oStr2:= FWFormStruct(1,'COU')
oModel := MPFormModel():New('GCPA110',,{|oModel|A110TudoOk(oModel)})
oModel:SetDescription(STR0007) //'Permissões'

oModel:addFields('COTMASTER',,oStr1)
oModel:addGrid('COUDETAILS','COTMASTER',oStr2)
oModel:GetModel('COUDETAILS'):SetUniqueLine( { 'COU_ETAPA' } )

oModel:SetRelation('COUDETAILS', { { 'COU_FILIAL', 'xFilial("COU")' }, { 'COU_CODUSR', 'COT_CODUSR' }, { 'COU_CODGRP', 'COT_CODGRP' } }, COU->(IndexKey(1)) )

oModel:getModel('COTMASTER'):SetDescription(STR0008) //'Cabeçalho'
oModel:getModel('COUDETAILS'):SetDescription(STR0009) //'Etapas Permitidas'


Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface

@author antenor.silva

@since 05/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'COT')
Local oStr2:= FWFormStruct(2, 'COU')

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('oViewMaster' , oStr1,'COTMASTER' )
oView:AddGrid('oViewDetails' , oStr2,'COUDETAILS')  

oView:CreateHorizontalBox( 'BoxCima', 20)

oStr2:RemoveField( 'COU_CODGRP' )

oStr2:RemoveField( 'COU_CODUSR' )
oView:CreateHorizontalBox( 'BoxBaixo', 80)

oView:SetOwnerView('oViewMaster','BoxCima')
oView:SetOwnerView('oViewDetails','BoxBaixo')

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA110()
Verifica se o usuário ou o grupo de usuário foram informados.
@author antenor.silva
@since 09/09/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Static Function A110TudoOk(oModel)
Local lRet 		:= .T.
Local cUsuario	:= oModel:GetModel("COTMASTER"):GetValue("COT_CODUSR")
Local cGrupo	:= oModel:GetModel("COTMASTER"):GetValue("COT_CODGRP")

If Empty(cUsuario) .And. Empty(cGrupo)
	lRet := .F.
	Help(' ', 1, 'ARQVAZIO')
EndIf

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA110()
Verifica se o grupo existe na tabela de permissões.
@author antenor.silva
@since 10/09/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Function A110ExisGR(cCodUsr,cCodGrp)
Local lRet 		:= .T.
Local aAreaCOT  := COT->(GetArea())
Local aGrupo	:= {}

If Empty(cCodUsr) .And. Empty(cCodGrp)
	lRet := .F.
EndIf
If lRet
	COT->(dbSetOrder(1))
	If COT->(dbSeek(xFilial('COT') + cCodUsr + cCodGrp))
		Help(' ', 1, 'JAGRAVADO')
		lRet := .F.
	Else
		aGrupo := FWSFLoadGrp(cCodGrp)
		IF Len(aGrupo) == 0
			Help(' ', 1, 'REGNOIS')
			lRet := .F.	
		EndIf
	EndIf
EndIf
	
RestArea(aAreaCOT)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP110Doc()
Rotina que verifica a permissão do usuario para visualizar os documentos do banco de conhecimento

@author leonardo.quintania
@return cPerm
@since 13/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function GCP110Doc(cUser,aGrp)
Local cPerm	:= '0'
Local nI		:= 0

If COT->(dbSeek(xFilial('COT')+cUser))
	cPerm:= COT->COT_DOCUM 	
Else
	For nI=1 To Len(aGrp)
		If COT->(dbSeek(xFilial('COT')+Space(TamSx3('COT_CODUSR')[1])+aGrp[nI]))
			If cPerm < COT->COT_DOCUM //Verifica se a permissão atual é maior do que a encontrada.
				cPerm:= COT->COT_DOCUM
			EndIf
		EndIf
	Next nI
EndIf

Return cPerm

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP110Perm()
Rotina consulta o cadastro de permissões e verifica se o usuario tem permissão para aquela etapa

@author leonardo.quintania
@return cPerm
@since 13/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function GCP110Perm(cUser,aGrp,cEtapa) 
Local lRet	:= .F.
Local lPerArea:= SuperGetMv("MV_GCPPARE",.F.,.F.)
Local nI	:= 0

If lPerArea
	If COT->(dbSeek(xFilial('COT')+cUser))
		If COU->(dbSeek(xFilial('COU')+cUser+Space(TamSx3('COU_CODGRP')[1])+cEtapa) )
			lRet:= .T.
		EndIf
	Else
		For nI=1 To Len(aGrp)
			If COT->(dbSeek(xFilial('COT')+Space(TamSx3('COT_CODUSR')[1])+aGrp[nI]))
				If COU->(dbSeek(xFilial('COU')+Space(TamSx3('COU_CODUSR')[1])+aGrp[nI]+cEtapa) )
					lRet:= .T.
					Exit
				EndIf
			EndIf
		Next nI
	EndIf
Else
	lRet:= .T.
EndIf

Return lRet
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA808A.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 07/11/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrGIJ	:= FWFormStruct(1,'GIJ')
Local bCommit   := {|oMdl| ModelCommit(oMdl)}

SetModelStruct(oStrGIJ)

oModel := MPFormModel():New('GTPA808A', /*bPreValidacao*/, /*bPosValid*/, bCommit, /*bCancel*/ )

oModel:AddFields('GIJMASTER',/*cOwner*/,oStrGIJ,/*bPre*/,/*bPos*/,/*bLoad*/)

oModel:SetDescription(STR0001)//'Averbação'

oModel:GetModel('GIJMASTER'):SetDescription(STR0001)	//'Averbação' 

oModel:SetPrimaryKey({'GIJ_FILIAL','GIJ_CODIGO','GIJ_SEQ'})

Return oModel


//------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct

@type function
@author jacomo.fernandes
@since 10/06/2019
@version 1.0
@param oStr, character, (Descrição do parâmetro)
@return nul, nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrGIJ)
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}

oStrGIJ:AddField("G99RECNO"   ,"G99RECNO"    ,"G99RECNO"        ,"N",16,0,Nil,Nil,Nil,.F.,NIL,.F.,.T.,.T.)
oStrGIJ:AddField("GIJRECNO"   ,"GIJRECNO"    ,"GIJRECNO"        ,"N",16,0,Nil,Nil,Nil,.F.,NIL,.F.,.T.,.T.)

oStrGIJ:SetProperty("GIJ_DATEMI"    , MODEL_FIELD_INIT, bInit)
oStrGIJ:SetProperty("GIJ_HOREMI"    , MODEL_FIELD_INIT, bInit)
oStrGIJ:SetProperty("GIJ_STATUS"    , MODEL_FIELD_INIT, bInit)
oStrGIJ:SetProperty("GIJ_MSBLQL"    , MODEL_FIELD_INIT, bInit)

oStrGIJ:SetProperty("GIJ_TIPAVB"      , MODEL_FIELD_VALUES, {STR0002,STR0003 })//"1=Envio","2=Cancelado"
oStrGIJ:SetProperty("GIJ_STATUS"      , MODEL_FIELD_VALUES, {STR0004,STR0005,STR0006,STR0007 })//"0=Aguardando","1=Autorizado","2=Erro","3=Recusado" 

oStrGIJ:AddTrigger('GIJ_CODIGO'	,'GIJ_CODIGO'	,{||.T.},bTrig)

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função responsavel pelo gatilho dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

Do Case
    Case cField == 'GIJ_CODIGO'
        oMdl:SetValue('GIJ_SEQ', GetNextSeq(uVal) ) 
    
EndCase

Return uVal

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldInit
Função responsavel pelo inicializador dos campos
@type function
@author 
@since 08/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return uRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Local uRet  := nil
Do Case 
	Case cField == "GIJ_DATEMI"
		uRet := dDataBase
    Case cField == "GIJ_HOREMI"
        uRet := SubStr(StrTran(TIME(),":",""), 1, 4)
    Case cField == "GIJ_STATUS"
        uRet := "0"
    Case cField == "GIJ_MSBLQL"
        uRet := "2"
EndCase

Return uRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} GetNextSeq
Função responsavel pelo gatilho dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param cCodCte, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function GetNextSeq(cCodCte)
Local cSeq      := ""
Local cAliasTmp := GetNextAlias()


BeginSql Alias cAliasTmp
    Select 
        IsNull(Max(cast(GIJ_SEQ as int)),0) AS MAX
    From %Table:GIJ% GIJ
    Where
        GIJ.GIJ_FILIAL = %xFilial:GIJ%
        AND GIJ.GIJ_CODIGO = %Exp:cCodCte%
        AND GIJ.%NotDel%
EndSql

cSeq := StrZero((cAliasTmp)->MAX + 1, TamSx3("GIJ_SEQ")[1])

(cAliasTmp)->(DbCloseArea())


Return cSeq

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelCommit

@type Static Function
@author jacomo.fernandes
@since 07/11/2019
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function ModelCommit(oModel)
Local lRet      := .T.
Local aAreaG99  := G99->(GetArea())
Local oMdlGIJ   := oModel:GetModel("GIJMASTER")
Local nRecG99   := oMdlGIJ:GetValue("G99RECNO")
Local nRecGIJ   := oMdlGIJ:GetValue("GIJRECNO")
Local cStatus   := '2'
Local lGtpAtm	:= ExistBlock("GTPENVATM") .AND. GTP808ATM(oMdlGIJ:GetValue("GIJ_CODSEG") )
Local cTipo		:= ''
Local cFilDoc	:= ''
Local cNumDoc	:= ''
Local cSerie	:= ''
Local cCodSeg	:= ''
Local aDadosAvb	:= {}
Local nX		:= 0
Local cStsErro	:= ''
Local cMsgErro	:= ''

G99->(DbGoTo(nRecG99))

If lGtpAtm

	cTipo 	:= oMdlGIJ:GetValue("GIJ_TIPAVB")
	cFilDoc	:= xFilial('GIJ')
	cCodSeg	:= oMdlGIJ:GetValue("GIJ_CODSEG")
	cNumDoc := G99->G99_NUMDOC
	cSerie	:= G99->G99_SERIE
	
	aDadosAvb := ExecBlock("GTPENVATM",.F.,.F.,{cTipo, cFilDoc, cNumDoc, cSerie, cCodSeg})
	
	If cTipo == '1' // Envio da Averbacao
	
		If aDadosAvb[1] // Averbacao Ok
			cStatus	:= "2" //Autorizado
			For nX := 1 To Len(aDadosAvb[2])
			
				If aDadosAvb[2][nX][2] <> Nil
				
					oMdlGIJ:SetValue(aDadosAvb[2][nX][1],aDadosAvb[2][nX][2])
					
				Endif
			
			Next
		
		Else // Erro
			cStatus	:= "3" //Rejeitado
			cStsErro := Iif(aDadosAvb[2][1] $ '000/002/907/910/999','2','3') // 2=Falha de comunicacao, 3=Recusado
			
			cMsgErro := aDadosAvb[2][1] + ' - ' + aDadosAvb[2][2]
			
			oMdlGIJ:SetValue("GIJ_STATUS", cStsErro)
			oMdlGIJ:SetValue("GIJ_MSERRO", cMsgErro)
		
		Endif

	ElseIf cTipo == '2' // Envio do cancelamento da averbacao 
	
		If aDadosAvb[1] // Cancelamento Ok
			cStatus	:= "4" //Cancelado
			oMdlGIJ:SetValue("GIJ_STATUS", '1') // Cancelamento Autorizado
			oMdlGIJ:SetValue("GIJ_TPMOV", '2')	
			oMdlGIJ:SetValue("GIJ_MSERRO", '')
		
		Else // Erro
			cStatus	:= "3" //Rejeitado
			cStsErro := Iif(aDadosAvb[2][1] $ '000/002/907/910','2','3') // 2=Falha de comunicacao, 3=Cancelamento Recusado
			
			cMsgErro := aDadosAvb[2][1] + ' - ' + aDadosAvb[2][2]
			
			oMdlGIJ:SetValue("GIJ_STATUS", cStsErro)
			oMdlGIJ:SetValue("GIJ_MSERRO", cMsgErro)
		
		Endif
	
	Endif

Endif

G99->(Reclock('G99',.F.))
    G99->G99_AVERBA := cStatus
G99->(MSUNLOCK())

If nRecGIJ > 0
    GIJ->(DbGoTo(nRecGIJ))
    GIJ->(Reclock('GIJ',.F.))
        GIJ->GIJ_MSBLQL := '1'//Inativo
    GIJ->(MSUNLOCK())
Endif

FwFormCommit(oModel)

RestArea(aAreaG99)

GtpDestroy(aDadosAvb)

Return lRet
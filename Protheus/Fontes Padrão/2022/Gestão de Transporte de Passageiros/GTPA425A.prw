#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA425A.CH'

Static __oCalc      := nil

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPA425A
Função responsavel para carregar o modelo de dados do ponto
@type Function
@author jacomo.fernandes
@since 29/07/2019
@version 1.0
@param oView, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPA425A(oCalc)
Local aButtons := {	{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,NIL},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}

__oCalc   := oCalc

FWExecView( STR0001,"VIEWDEF.GTPA425A",MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/,;
            {||.T.}/*bOk*/,25/*nPercRed*/,aButtons, {||.T.}/*bCancel*/,,,/*oModel*/ ) //"Simulação do ponto"

Return nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 29/07/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrCab	:= FWFormModelStruct():New()
Local oStrDet	:= FWFormModelStruct():New()

SetModelStruct(oStrCab,oStrDet)

oModel := MPFormModel():New('GTPA425A', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('MASTER',/*cOwner*/,oStrCab,/*bPre*/,/*bPos*/,{|oMdl|ModelLoad(oMdl)}/*bLoad*/)
oModel:AddGrid('DETAIL','MASTER',oStrDet,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,{|oMdl|ModelLoad(oMdl)}/*bLoad*/)

oModel:SetDescription(STR0001) //"Simulação do ponto"

oModel:GetModel('MASTER'):SetDescription(STR0002)	//"Dados do Colaborador"
oModel:GetModel('DETAIL'):SetDescription(STR0003)	//"Dados da apuração"

oModel:SetPrimaryKey({})

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct
Função responsavel pela definição da estrutura do Modelo
@type Static Function
@author jacomo.fernandes
@since 29/07/2019
@version 1.0
@param oStrCab, object, (Descrição do parâmetro)
@param oStrDet, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrCab,oStrDet)
Local aTpDia    := nil

If ValType(oStrCab) == "O"
    GTPxCriaCpo(oStrCab,{'GYG_CODIGO','GYG_NOME','GYG_FUNCIO'},.T.)
Endif

If ValType(oStrDet) == "O"
    GTPxCriaCpo(oStrDet,{'GQE_DTREF','GQK_TPDIA'},.T.)
    
    oStrDet:AddField(STR0004 ,STR0004 ,"PRIMEIRA_DT_ENTRADA" ,"D",08,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Data 1E"
    oStrDet:AddField(STR0005 ,STR0005 ,"PRIMEIRA_HR_ENTRADA" ,"C",04,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Hora 1E"
    oStrDet:AddField(STR0006 ,STR0006 ,"PRIMEIRA_LC_ENTRADA" ,"C",50,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Localidade 1E"
    
    oStrDet:AddField(STR0007 ,STR0007 ,"PRIMEIRA_DT_SAIDA"   ,"D",08,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Data 1S"
    oStrDet:AddField(STR0008 ,STR0008 ,"PRIMEIRA_HR_SAIDA"   ,"C",04,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Hora 1S"       
    oStrDet:AddField(STR0009 ,STR0009 ,"PRIMEIRA_LC_SAIDA"   ,"C",50,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Localidade 1S" 
    
    oStrDet:AddField(STR0010 ,STR0010 ,"SEGUNDA_DT_ENTRADA"  ,"D",08,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Data 2E"       
    oStrDet:AddField(STR0011 ,STR0011 ,"SEGUNDA_HR_ENTRADA"  ,"C",04,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Hora 2E"       
    oStrDet:AddField(STR0012 ,STR0012 ,"SEGUNDA_LC_ENTRADA"  ,"C",50,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Localidade 2E" 
    
    oStrDet:AddField(STR0013 ,STR0013 ,"SEGUNDA_DT_SAIDA"    ,"D",08,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Data 2S"       
    oStrDet:AddField(STR0014 ,STR0014 ,"SEGUNDA_HR_SAIDA"    ,"C",04,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Hora 2S"       
    oStrDet:AddField(STR0015 ,STR0015 ,"SEGUNDA_LC_SAIDA"    ,"C",50,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Localidade 2S" 
    
    oStrDet:AddField("Hr Pagas"     ,"Hr Pagas"     ,"HR_PAGAS"         ,"C",05,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Hr Volante"
    
    oStrDet:AddField("Hr Volante"   ,"Hr Volante"   ,"HR_VOLANTE"       ,"C",05,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Hr Volante"
    oStrDet:AddField("Hr Fora Vol"  ,"Hr Fora Vol"  ,"HR_FORA_VOLANTE"  ,"C",05,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Hr Fora Vol"
    oStrDet:AddField("Hr Plantão"   ,"Hr Plantão"   ,"HR_PLANTAO"       ,"C",05,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Hr Plantão"

    oStrDet:AddField("Tot Interv."   ,"Tot Interv." ,"HR_INTERV_TOT"    ,"C",05,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Hr Plantão"
    oStrDet:AddField("Interv. Pgt"   ,"Interv. Pgt" ,"HR_INTERV_PGT"    ,"C",05,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Hr Plantão"

    oStrDet:AddField("Hr Extras"   ,"Hr Extras" ,"HR_EXTRAS"    ,"C",05,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Hr Plantão"
    oStrDet:AddField("Hr Negat."   ,"Hr Negat." ,"HR_NEGATIVAS"    ,"C",05,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Hr Plantão"
    oStrDet:AddField("Adc Noturno"   ,"Adc Noturno" ,"HR_ADICIONAL_NOT"    ,"C",05,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Hr Plantão"


    aTpDia	:= GTPXCBox('GQK_TPDIA')
    aAdd(aTpDia,cValTochar(Len(aTpDia)+1)+STR0016)//'=Falta'
    
    oStrDet:SetProperty('GQK_TPDIA',MODEL_FIELD_VALUES,aClone(aTpDia))

Endif

GTPDestroy(aTpDia)

Return nil

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelLoad
Função responsavel pelo retorno do array contendo os dados
@type Static Function
@author jacomo.fernandes
@since 29/07/2019
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return aRet, retorna um array contendo os dados do modelo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function ModelLoad(oModel)
Local aRet      := {}
Local aItens    := {}
Local cMdlId    := oModel:GetId()
Local oCalc     := __oCalc

If cMdlId == "MASTER"
   
    aAdd(aItens,oCalc:cColab)
    aAdd(aItens,Posicione('GYG',1,xFilial('GYG')+oCalc:cColab ,'GYG_NOME') )
    aAdd(aItens,Posicione('GYG',1,xFilial('GYG')+oCalc:cColab ,'GYG_FUNCIO') )
    aRet    := {aClone(aItens),0}
Else
    aRet    := LoadGridGQE(oCalc)    
Endif

GtpDestroy(aItens)

Return aRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} LoadGridGQE
Função responsavel pela montagem dos dados da simulação do ponto
@type Static Function
@author jacomo.fernandes
@since 30/07/2019
@version 1.0
@param oMdlGQE, object, (Descrição do parâmetro)
@return aRet, retorno Nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function LoadGridGQE(oCalc)
Local aRet          := {}
Local oCalcDia      := Nil
Local aItens        := {}
Local n1            := 0

For n1 := 1 To Len(oCalc:aDias)
    oCalcDia := oCalc:aDias[n1]

    aItens := {}
    
    aAdd(aItens, oCalcDia:dDtRef        )
    aAdd(aItens, oCalcDia:cTpDia        )
    aAdd(aItens, oCalcDia:dData_1E      )
    aAdd(aItens, oCalcDia:cHora_1E      )
    aAdd(aItens, oCalcDia:cDesLoc_1E    )
    aAdd(aItens, oCalcDia:dData_1S      )
    aAdd(aItens, oCalcDia:cHora_1S      )
    aAdd(aItens, oCalcDia:cDesLoc_1S    )
    aAdd(aItens, oCalcDia:dData_2E      )
    aAdd(aItens, oCalcDia:cHora_2E      )
    aAdd(aItens, oCalcDia:cDesLoc_2E    )
    aAdd(aItens, oCalcDia:dData_2S      )
    aAdd(aItens, oCalcDia:cHora_2S      )
    aAdd(aItens, oCalcDia:cDesLoc_2S    )

    aAdd(aItens, oCalcDia:cHrPagas      )
    aAdd(aItens, oCalcDia:cHrVolante    )
    aAdd(aItens, oCalcDia:cHrForaVol    )
    aAdd(aItens, oCalcDia:cHrPlantao    )
    aAdd(aItens, oCalcDia:cHrIntTot     )
    aAdd(aItens, oCalcDia:cHrIntPgt     )
    aAdd(aItens, oCalcDia:cHrExtra      )
    aAdd(aItens, oCalcDia:cHrNegat      )
    aAdd(aItens, oCalcDia:cHrAdnNot     )


    aAdd(aRet,{Len(aRet)+1,aClone(aItens)})
Next

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 29/07/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA425A')
Local oStrCab	:= FWFormViewStruct():New() 
Local oStrDet	:= FWFormViewStruct():New() 

SetViewStruct(oStrCab,oStrDet)

oView:SetModel(oModel)
oView:AddField('VIEW_CAB',oStrCab,'MASTER')
oView:AddGrid('VIEW_DET',oStrDet,'DETAIL')

oView:CreateHorizontalBox('UPPER', 20)
oView:CreateHorizontalBox('BOTTOM', 80)

oView:SetOwnerView('VIEW_CAB','UPPER')
oView:SetOwnerView('VIEW_DET','BOTTOM')

oView:SetDescription(STR0001) //"Simulação do ponto"

oView:AddUserButton(STR0017, '', {|oView| ImprimeSimulacao(oView) } )//"Imprimir"

Return oView


//------------------------------------------------------------------------------
/* /{Protheus.doc} SetViewStruct
Função responsavel pela estrutura da view
@type Static Function
@author jacomo.fernandes
@since 29/07/2019
@version 1.0
@param oStrDet, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrCab,oStrDet)
Local aTpDia    := NIL

If ValType(oStrCab) == "O"
    GTPxCriaCpo(oStrCab,{'GYG_CODIGO','GYG_NOME','GYG_FUNCIO'},.F.)
    oStrCab:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
    oStrCab:SetProperty('GYG_FUNCIO',MVC_VIEW_LOOKUP,'')
Endif

If ValType(oStrDet) == "O"
    GTPxCriaCpo(oStrDet,{'GQE_DTREF','GQK_TPDIA'},.F.)

    oStrDet:AddField("PRIMEIRA_DT_ENTRADA" ,"03",STR0004 ,STR0004 ,{STR0004 },"GET","@D"       ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Data 1E"
    oStrDet:AddField("PRIMEIRA_HR_ENTRADA" ,"04",STR0005 ,STR0005 ,{STR0005 },"GET","@R 99:99" ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Hora 1E"
    oStrDet:AddField("PRIMEIRA_DT_SAIDA"   ,"05",STR0007 ,STR0007 ,{STR0007 },"GET","@D"       ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Data 1S"
    oStrDet:AddField("PRIMEIRA_HR_SAIDA"   ,"06",STR0008 ,STR0008 ,{STR0008 },"GET","@R 99:99" ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Hora 1S"
    oStrDet:AddField("SEGUNDA_DT_ENTRADA"  ,"07",STR0010 ,STR0010 ,{STR0010 },"GET","@D"       ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Data 2E"
    oStrDet:AddField("SEGUNDA_HR_ENTRADA"  ,"08",STR0011 ,STR0011 ,{STR0011 },"GET","@R 99:99" ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Hora 2E"
    oStrDet:AddField("SEGUNDA_DT_SAIDA"    ,"09",STR0013 ,STR0013 ,{STR0013 },"GET","@D"       ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Data 2S"
    oStrDet:AddField("SEGUNDA_HR_SAIDA"    ,"10",STR0014 ,STR0014 ,{STR0014 },"GET","@R 99:99" ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Hora 2S"
    
    oStrDet:AddField("HR_PAGAS"            ,"11","Hr Pagas"    ,"Hr Pagas"    ,{"Hr Pagas"     },"GET","@R 99:99" ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Hora 2S"
    oStrDet:AddField("HR_VOLANTE"          ,"12","Hr Volante"  ,"Hr Volante"  ,{"Hr Volante"   },"GET","@R 99:99" ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Hora 2S"
    oStrDet:AddField("HR_FORA_VOLANTE"     ,"13","Hr Fora Vol" ,"Hr Fora Vol" ,{"Hr Fora Vol"  },"GET","@R 99:99" ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Hora 2S"
    oStrDet:AddField("HR_PLANTAO"          ,"14","Hr Plantão"  ,"Hr Plantão"  ,{"Hr Plantão"   },"GET","@R 99:99" ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Hora 2S"
    oStrDet:AddField("HR_INTERV_TOT"       ,"15","Tot Interv." ,"Tot Interv." ,{"Tot Interv."  },"GET","@R 99:99" ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Hora 2S"
    oStrDet:AddField("HR_INTERV_PGT"       ,"16","Interv. Pgt" ,"Interv. Pgt" ,{"Interv. Pgt"  },"GET","@R 99:99" ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Hora 2S"
    oStrDet:AddField("HR_EXTRAS"           ,"17","Hr Extras"   ,"Hr Extras"   ,{"Hr Extras"    },"GET","@R 99:99" ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Hora 2S"
    oStrDet:AddField("HR_NEGATIVAS"        ,"18","Hr Negat."   ,"Hr Negat."   ,{"Hr Negat."    },"GET","@R 99:99" ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Hora 2S"
    oStrDet:AddField("HR_ADICIONAL_NOT"    ,"19","Adc Noturno" ,"Adc Noturno" ,{"Adc Noturno"  },"GET","@R 99:99" ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Hora 2S"

    oStrDet:AddField("PRIMEIRA_LC_ENTRADA" ,"20",STR0006 ,STR0006 ,{STR0006 },"GET","@!"       ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Localidade 1E"
    oStrDet:AddField("PRIMEIRA_LC_SAIDA"   ,"21",STR0009 ,STR0009 ,{STR0009 },"GET","@!"       ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Localidade 1S"
    oStrDet:AddField("SEGUNDA_LC_ENTRADA"  ,"22",STR0012 ,STR0012 ,{STR0012 },"GET","@!"       ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Localidade 2E"
    oStrDet:AddField("SEGUNDA_LC_SAIDA"    ,"23",STR0015 ,STR0015 ,{STR0015 },"GET","@!"       ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)//"Localidade 2S"

    oStrDet:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
    
    aTpDia	:= GTPXCBox('GQK_TPDIA')
    aAdd(aTpDia,cValTochar(Len(aTpDia)+1)+STR0016)//'=Falta'
    
    oStrDet:SetProperty('GQK_TPDIA',MVC_VIEW_COMBOBOX,aClone(aTpDia))

Endif

GTPDestroy(aTpDia)

Return nil
//------------------------------------------------------------------------------
/* /{Protheus.doc} ImprimeSimulacao

@type Function
@author jacomo.fernandes
@since 29/07/2019
@version 1.0
@param oView, character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function ImprimeSimulacao(oView)
Local nLine 	:= oView:GetModel("DETAIL"):GetLine()

GTPR425A(__oCalc)

oView:GetModel("DETAIL"):GoLine(nLine) 

Return 
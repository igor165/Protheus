#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "GTPA425.CH"
#INCLUDE 'FWEDITPANEL.CH'

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPA425
Apuração de Colaboradores
@type Function
@author jacomo.fernandes
@since 02/09/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Function GTPA425()

If CheckAloc(.T.) 
    FWExecView( "Apuração" , 'GTPA425', MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T. } ) 
EndIf

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelDef

@type Function
@author jacomo.fernandes
@since 02/09/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel    := Nil
Local oStrCab   := FWFormModelStruct():New()
Local oStrColab := FWFormModelStruct():New()
Local oStrAloc  := FWFormModelStruct():New()
Local oStrTot   := FWFormModelStruct():New()

Local bPosVld   := {|oMdl| ModelPosVld(oMdl)}
Local bCommit   := {|oMdl| ModelCommit(oMdl)}
Local bLoad     := {|oMdl| LoadModel(oMdl) }

SetModelStruct(oStrCab, oStrColab, oStrAloc, oStrTot)

oModel := MPFormModel():New('GTPA425',/*bPreValid*/, bPosVld/*bPosValid*/ , bCommit)

oModel:SetDescription(STR0001)	//"Efetivação de Colaboradores"

oModel:AddFields("MASTER"   ,/*cOwner*/ ,oStrCab    ,/*bPre*/,/*bPos*/,{||})
oModel:AddGrid("GYGDETAIL"  ,"MASTER"   ,oStrColab  ,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,bLoad)
oModel:AddGrid("ALOCDETAIL" ,"GYGDETAIL",oStrAloc   ,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,bLoad)
oModel:AddFields("TOTDETAIL","GYGDETAIL",oStrTot    ,/*bPre*/,/*bPos*/,{||})


oModel:SetRelation("ALOCDETAIL" ,{{"GQK_RECURS","GYG_CODIGO"}},"GQK_RECURS+GQK_DTREF+GQK_DTINI+GQE_HRINTR" )
oModel:SetRelation("TOTDETAIL"  ,{{"GQK_RECURS","GYG_CODIGO"}},"GQK_RECURS" )

oModel:GetModel("MASTER"):SetPrimaryKey({})

oModel:GetModel('GYGDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('GYGDETAIL'):SetNoDeleteLine(.T.)

oModel:GetModel('ALOCDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('ALOCDETAIL'):SetNoDeleteLine(.T.)

oModel:GetModel("GYGDETAIL" ):SetOptional( .T. )
oModel:GetModel("ALOCDETAIL"):SetOptional( .T. )
oModel:GetModel("TOTDETAIL" ):SetOptional( .T. )

// Adiciona a descricao do Componente do Modelo de Dados	
oModel:GetModel('MASTER'    ):SetDescription( STR0004 ) //"Apuração e Ajustes de Horários"
oModel:GetModel('GYGDETAIL' ):SetDescription( STR0005 ) //"Colaboradores"
oModel:GetModel('ALOCDETAIL'):SetDescription( STR0006 ) //"Horários Apurados"
oModel:GetModel("TOTDETAIL" ):SetDescription( STR0007 ) //"Totalizadores"

oModel:SetActivate( { |oModel| ModelActivate(oModel)} )


Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct

@type Static Function
@author jacomo.fernandes
@since 02/09/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrCab, oStrColab, oStrAloc, oStrTot)
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bFldVld   := {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local aCpoColab := {}
Local aCpoAloc  := {}
Local aTpDia	:= GTPXCBox('GQK_TPDIA')
aAdd(aTpDia,cValTochar(Len(aTpDia)+1)+'=Falta')
		
If ValType(oStrCab) == "O"
    GTPxCriaCpo(oStrCab,{'GYT_CODIGO'},.T.)
Endif

If ValType(oStrColab) == "O"
    aAdd(aCpoColab,'GYG_CODIGO' )
    aAdd(aCpoColab,'GYG_NOME'   )
    aAdd(aCpoColab,'GYG_FILSRA' )
    aAdd(aCpoColab,'GYG_FUNCIO' )
    aAdd(aCpoColab,'GYG_RECCOD' )
    aAdd(aCpoColab,'GYG_DESREC' )
    aAdd(aCpoColab,'GYT_CODIGO' )
    aAdd(aCpoColab,'GYT_DESCRI' )
    aAdd(aCpoColab,'GYT_HRMINT' )
    
    GTPxCriaCpo(oStrColab,aCpoColab,.T.)
    
    oStrColab:AddField("Dt Ini Apu" ,"Dt Ini Apu"   ,"DTINIAPU"     ,"D",08,0,NIL,{||.T.},NIL,.F.,Nil,.F.,.T.,.T.)
    oStrColab:AddField("Dt Fim Apu" ,"Dt Fim Apu"   ,"DTFIMAPU"     ,"D",08,0,NIL,{||.T.},NIL,.F.,Nil,.F.,.T.,.T.)
    oStrColab:AddField(""           ,""             ,"GYG_LEGEND"   ,"C",20,0,NIL,{||.T.},NIL,.F.,Nil,.F.,.F.,.T.)

    oStrColab:SetProperty("*", MODEL_FIELD_OBRIGAT, .F. )

Endif

If ValType(oStrAloc) == "O"
    aAdd(aCpoAloc,'GQK_RECURS'  )
    aAdd(aCpoAloc,'GQK_DRECUR'  )
    aAdd(aCpoAloc,'GQK_CONF'    )
    aAdd(aCpoAloc,'GQK_TPDIA'   ) 
    aAdd(aCpoAloc,'GQK_DTREF'   ) 
    aAdd(aCpoAloc,'GQK_DTINI'   ) 
    aAdd(aCpoAloc,'GQK_LOCORI'  )
    aAdd(aCpoAloc,'GQK_DESORI'  )
    aAdd(aCpoAloc,'GQK_DTFIM'   ) 
    aAdd(aCpoAloc,'GQK_LOCDES'  )
    aAdd(aCpoAloc,'GQK_DESDES'  )
    aAdd(aCpoAloc,'GQE_HRINTR'  )
    aAdd(aCpoAloc,'GQK_HRINI'   ) 
    aAdd(aCpoAloc,'GQK_HRFIM'   ) 
    aAdd(aCpoAloc,'GQE_HRFNTR'  )
    If GQK->(FieldPos("GQK_INTERV")) > 0
        aAdd(aCpoAloc,'GQK_INTERV'  )
    EndIf
    aAdd(aCpoAloc,'GQK_TCOLAB'  )
    aAdd(aCpoAloc,'GQK_DCOLAB'  )
    aAdd(aCpoAloc,'GQK_CODGZS'  )
    aAdd(aCpoAloc,'GQK_DSCGZS'  )
    aAdd(aCpoAloc,'GQK_MARCAD'  )
    aAdd(aCpoAloc,'GQK_ESPHIN'  )
    aAdd(aCpoAloc,'GQK_ESPHFM'  )
    
    aAdd(aCpoAloc,'GZS_VOLANT'  )
    aAdd(aCpoAloc,'GZS_HRPGTO'  )

    GTPxCriaCpo(oStrAloc,aCpoAloc,.T.)
    oStrAloc:AddField(""        ,""         ,"GQK_LEGEND"   ,"C",20,0,NIL,Nil,NIL,.F.,Nil,.F.,.F.,.T.)
    oStrAloc:AddField("Tp Esc"  ,"Tp Esc"   ,"TPESC"        ,"C",01,0,Nil,Nil,Nil,.F.,NIL,.F.,.T.,.T.)
    oStrAloc:AddField("RECNO"   ,"RECNO"    ,"RECNO"        ,"N",16,0,Nil,Nil,Nil,.F.,NIL,.F.,.T.,.T.)

    oStrAloc:SetProperty('GQK_TPDIA'    ,MODEL_FIELD_VALUES ,aTpDia)

    oStrAloc:SetProperty("GQK_DTREF"	, MODEL_FIELD_VALID ,bFldVld)
    oStrAloc:SetProperty("GQE_HRINTR"   , MODEL_FIELD_VALID ,bFldVld)
    oStrAloc:SetProperty("GQE_HRFNTR"   , MODEL_FIELD_VALID ,bFldVld)
    
    oStrAloc:AddTrigger("GQK_CONF"      ,"GQK_CONF"     ,{||.T.}, bFldTrig)
    oStrAloc:AddTrigger("GQK_DTREF"	    ,"GQK_DTREF"	,{||.T.}, bFldTrig)
    oStrAloc:AddTrigger("GQE_HRINTR"    ,"GQE_HRINTR"   ,{||.T.}, bFldTrig)
    oStrAloc:AddTrigger("GQE_HRFNTR"    ,"GQE_HRFNTR"   ,{||.T.}, bFldTrig)
    If GQK->(FieldPos("GQK_INTERV")) > 0
        oStrAloc:AddTrigger("GQK_INTERV"    ,"GQK_INTERV"   ,{||.T.}, bFldTrig)
    EndIf
    // QUANDO FOR FALTA E NÃO FOR ENVIADO PRO PONTO, PERMITIR A EDIÇÃO
    oStrAloc:SetProperty('*',MODEL_FIELD_WHEN,{|oMdl| oMdl:GetValue('TPESC') <> '3' .AND. oMdl:GetValue('GQK_MARCAD') <> '1'  })

Endif

If ValType(oStrTot) == "O"

    GTPxCriaCpo(oStrTot,{"GQK_RECURS"},.T.)
    
    oStrTot:AddField("Hrs Não Conf."    ,"Hrs Não Conf."    ,"HRNAOCONF"	,"C",06,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("Hrs Conferida"    ,"Hrs Conferida"    ,"HRCONF"		,"C",06,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("Hrs Mensais"      ,"Hrs Mensais"      ,"HRMENSAIS"	,"C",06,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("Hrs Pagas"        ,"Hrs Pagas"        ,"HRPAGAS"		,"C",06,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("Adn Noturno"      ,"Adn Noturno"      ,"ADNOTURNO"	,"C",06,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("Hrs Extras"       ,"Hrs Extras"       ,"HREXTRAS"		,"C",06,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("Hrs Negativas"    ,"Hrs Negativas"    ,"HRNEGATIVAS"	,"C",06,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("Saldo Horas"      ,"Saldo Horas"      ,"SALDOHORAS"	,"C",07,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("Hrs Volante"      ,"Hrs Volante"      ,"HRVOLANTE"	,"C",06,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("Hrs Fora Vol."    ,"Hrs Fora Vol."    ,"HRFORAVOL"	,"C",06,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("Hrs Intev Tot"    ,"Hrs Intev Tot"    ,"HRINTTOT"		,"C",06,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("Hrs Intev Pgt"    ,"Hrs Intev Pgt"    ,"HRINTPGT"		,"C",06,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("DSR Dispon."      ,"DSR Dispon."      ,"DSRDISP"	    ,"N",03,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("DSR Utiliz."      ,"DSR Utiliz."      ,"DSRUTIL"	    ,"N",03,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("Qtd Faltas"       ,"Qtd Faltas"       ,"QTDFALTAS"	,"N",03,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)
    oStrTot:AddField("Ext - DSR"        ,"Ext - DSR"        ,"EXTMENOSDSR"	,"C",06,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)

Endif
            
Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldValid
Função responsavel pela validação dos campos
@type Static Function
@author jacomo.fernandes
@since 02/09/2019
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
@return lRet, retorno logico
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue, lAut)
Local lRet  := .T.
Local oModel	:= NIL
Local cMdlId	:= ''
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Default lAut    := .F.

if !lAut
    oModel	:= oMdl:GetModel()
    cMdlId	:= oMdl:GetId()
endif

Do Case
    Case Empty(uNewValue)
        lRet := .T.
    Case cField == "GQE_HRINTR" .OR. cField == "GQE_HRFNTR" 
        If !GxVldHora(uNewValue,.F.,.F.)
            cMsgErro	:= "Horario informado invalido"
            cMsgSol		:= "Informe uma hora entre 00:00 até 23:59"
            lRet := .F.
        Endif
        
        if !lAut
            If lRet .and. !ValidaEncavalamento(oMdl,@cMsgErro,@cMsgSol)
                lRet    := .F.
            Endif
        Endif

    Case cField == "GQK_DTREF"
        if !lAut
            If !ValidaEncavalamento(oMdl,@cMsgErro,@cMsgSol)
                lRet    := .F.
            Endif
        Endif 
EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} ValidaEncavalamento

@type Static Function
@author jacomo.fernandes
@since 04/09/2019
@version 1.0
@param oMdl, object, (Descrição do parâmetro)
@return lRet, Retorno lógico
/*/
//------------------------------------------------------------------------------
Static Function ValidaEncavalamento(oMdl,cMsgErro,cMsgSol)
Local lRet          := .T.
Local nLineAloc     := oMdl:GetLine()
Local n1            := 0
Local dDtRef        := oMdl:GetValue('GQK_DTREF')
Local cTpDia        := oMdl:GetValue('GQK_TPDIA')
Local dDtIni        := oMdl:GetValue('GQK_DTINI')
Local cHrIni        := oMdl:GetValue('GQE_HRINTR')
Local dDtFim        := oMdl:GetValue('GQK_DTFIM')
Local cHrFim        := oMdl:GetValue('GQE_HRFNTR')

Default cMsgErro    := ""
Default cMsgSol     := ""

If DtoS(dDtFim)+cHrFim < DtoS(dDtIni)+cHrIni
    dDtFim++
Endif

For n1  := 1 to oMdl:Length()
    If n1 == nLineAloc .or. oMdl:IsDeleted(n1)
        Loop
    Endif
    //Se Trabalhado ou plantão
    If cTpDia <= '2' 
        //Se a linha posicionada for diferente de plantão ou trabalhado, basta verificar a data de referencia
        If oMdl:GetValue('GQK_TPDIA',n1) > '2'
            If oMdl:GetValue('GQK_DTREF',n1) == dDtRef
                lRet := .F.
                Exit
            Endif
        Else
            // Verifica se a data e Hora informada sobrepoem um trecho por completo
            //Ex: Linha a ser validada ==> DtIni = 04/09/19, HrIni = 10:00, DtFim = 04/09/19, HrFim = 12:00
            //Linha a ser Confrontada ==> DtIni = 04/09/19, HrIni = 10:30, DtFim = 04/09/19, HrFim = 11:30
            If DtoS(dDtIni)+cHrIni < DtoS(oMdl:GetValue('GQK_DTINI',n1) )+oMdl:GetValue('GQE_HRINTR',n1) ;
                .AND.  DtoS(dDtFim)+cHrFim > DtoS(oMdl:GetValue('GQK_DTFIM',n1) )+oMdl:GetValue('GQE_HRFNTR',n1) 
                
                lRet := .F.
                Exit
            // Verifica se a data e Hora informada se encontra entre um trecho 
            //Ex: Linha a ser validada ==> DtIni = 04/09/19, HrIni = 10:30, DtFim = 04/09/19, HrFim = 11:30
            //Linha a ser Confrontada ==> DtIni = 04/09/19, HrIni = 10:00, DtFim = 04/09/19, HrFim = 12:00
            ElseIf DtoS(dDtIni)+cHrIni > DtoS(oMdl:GetValue('GQK_DTINI',n1) )+oMdl:GetValue('GQE_HRINTR',n1) ;
                 .AND.  DtoS(dDtFim)+cHrFim < DtoS(oMdl:GetValue('GQK_DTFIM',n1) )+oMdl:GetValue('GQE_HRFNTR',n1) 

                 lRet := .F.
                 Exit

            // Verifica se a data e Hora inicial esta entre um trecho mas a final passa do trecho
            //Ex: Linha a ser validada ==> DtIni = 04/09/19, HrIni = 10:30, DtFim = 04/09/19, HrFim = 11:30
            //Linha a ser Confrontada ==> DtIni = 04/09/19, HrIni = 10:00, DtFim = 04/09/19, HrFim = 11:00
            
            // A data Hora Inicial pode ser a mesma que a data e hora final do trecho confrontado
            //Ex: Linha a ser validada ==> DtIni = 04/09/19, HrIni = 11:00, DtFim = 04/09/19, HrFim = 11:30
            //Linha a ser Confrontada ==> DtIni = 04/09/19, HrIni = 10:00, DtFim = 04/09/19, HrFim = 11:00
            ElseIf DtoS(dDtIni)+cHrIni >= DtoS(oMdl:GetValue('GQK_DTINI',n1) )+oMdl:GetValue('GQE_HRINTR',n1) ;
                    .AND.  DtoS(dDtIni)+cHrIni  < DtoS(oMdl:GetValue('GQK_DTFIM',n1) )+oMdl:GetValue('GQE_HRFNTR',n1) 

                lRet := .F.
                Exit

            // Verifica se a data e Hora final esta entre um trecho mas a inicial começa antes do trecho
            //Ex: Linha a ser validada ==> DtIni = 04/09/19, HrIni = 10:00, DtFim = 04/09/19, HrFim = 11:30
            //Linha a ser Confrontada ==> DtIni = 04/09/19, HrIni = 10:30, DtFim = 04/09/19, HrFim = 12:00
            
            // A data Hora Final pode ser a mesma que a data e hora Inicial do trecho confrontado
            //Ex: Linha a ser validada ==> DtIni = 04/09/19, HrIni = 11:00, DtFim = 04/09/19, HrFim = 11:30
            //Linha a ser Confrontada ==> DtIni = 04/09/19, HrIni = 11:30, DtFim = 04/09/19, HrFim = 12:00
            ElseIf DtoS(dDtFim)+cHrFim > DtoS(oMdl:GetValue('GQK_DTINI',n1) )+oMdl:GetValue('GQE_HRINTR',n1) ;
                    .AND.  DtoS(dDtFim)+cHrFim  <= DtoS(oMdl:GetValue('GQK_DTFIM',n1) )+oMdl:GetValue('GQE_HRFNTR',n1) 

                lRet := .F.
                Exit
            Endif
        Endif

    Else
        If oMdl:GetValue('GQK_DTREF',n1) == dDtRef
            lRet := .F.
            Exit
        Endif
    Endif

Next

If !lRet
    cMsgErro    := "Alocação Informada encontra-se em conflito com outro registro"
    cMsgSol     := "Verifique os dados informados"
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função responsavel pelo gatilho dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

Local oView		:= FwViewActive()
Local oModel    := oMdl:GetModel()

Do Case
    Case cField == "GQK_CONF"
        If uVal == "1"
            oMdl:SetValue('GQK_LEGEND','BR_VERDE')
        Else
            oMdl:SetValue('GQK_LEGEND','BR_VERMELHO')
        Endif

        If oMdl:SeekLine({{'GQK_CONF','2'}},.F.,.F.)
            oModel:GetModel('GYGDETAIL'):SetValue('GYG_LEGEND','BR_VERMELHO')
        Else
            oModel:GetModel('GYGDETAIL'):SetValue('GYG_LEGEND','BR_VERDE')
        Endif
        
        If !FwIsInCallStack('CONFIRMARTODOS')
            CalculaTotais(oModel)
        Endif

    Case AllTrim(cField)+'|' $ "GQK_DTREF|GQE_HRINTR|GQE_HRFNTR|GQK_INTERV|"

        CalculaTotais(oModel)

EndCase

If !IsBlind() .and. ValType(oView) == "O" .AND. oView:IsActive()
	oView:Refresh()
Endif

Return uVal

//------------------------------------------------------------------------------
/*/{Protheus.doc} LoadModel

@type static function
@author 
@since 10/06/2019
@version 1.0
@param oMdl, object, (Descrição do parâmetro)
@return aRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function LoadModel(oMdl)
Local aRet      := {}
Local cMdlId    := oMdl:GetId()
Local oMdlGYG   := NIL
Local cColab    := Nil
Local dDtIni    := Nil
Local dDtFim    := Nil
Local cAliasTmp := NIL

If cMdlId == 'GYGDETAIL'
    CheckAloc(.F.,oMdl,aRet)
Else
    oMdlGYG := oMdl:GetModel():GetModel('GYGDETAIL')
    cColab  := oMdlGYG:GetValue('GYG_CODIGO')
    dDtIni  := oMdlGYG:GetValue('DTINIAPU')
    dDtFim  := oMdlGYG:GetValue('DTFIMAPU')
    
    cAliasTmp    := BuscaAlocacao(cColab,dDtIni,dDtFim)
    aRet := FWLoadByAlias(oMdl, cAliasTmp)
Endif

    
Return aRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} CheckAloc

@type Static Function
@author jacomo.fernandes
@since 02/09/2019
@version 1.0
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function CheckAloc(lCheck,oMdl,aRet)
Local lRet      := .T.
Local cAliasTmp := GetNextAlias()

Local cFields   := ""
Local cQryGRP   := "%%"
Local cWhenGrp  := "%%"

Local cColabIni := ""
Local cColabFim := ""
Local cSetorIni := ""
Local cSetorAte := ""
Local cGrupoIni := ""
Local cGrupoFim := ""

Local dDtIniApu := Stod('')
Local dDtFimApu := Stod('')

If Pergunte("GTPA425",lCheck) .or. !lCheck
    IF !( PerAponta(@dDtIniApu, @dDtFimApu) ) .and. (Empty(dDtIniApu) .and. Empty(dDtFimApu))
        lRet := .F.
        Help(, , "PERAPONTA", "", STR0008, , STR0009) //"Não existe período de apontamento cadastrado." //"Verifique o Período de apontamento através do módulo Ponto Eletrônico."
    EndIf
Else
    lRet := .F.
Endif

If lRet 
    cColabIni := MV_PAR01
    cColabFim := MV_PAR02
    cSetorIni := MV_PAR03
    cSetorAte := MV_PAR04
    cGrupoIni := MV_PAR05
    cGrupoFim := MV_PAR06
        
    If lCheck
        cFields := " Count(GYG_CODIGO) AS TOTAL"
    Else

        cFields += " GYG_CODIGO , "
        cFields += " GYG_NOME   , "
        cFields += " GYG_FILSRA , "
        cFields += " GYG_FUNCIO , "
        cFields += " GYG_RECCOD , "
        cFields += " IsNull(GYK_DESCRI,'') as GYG_DESREC , "
        cFields += " GYT_CODIGO , "
        cFields += " GI1_DESCRI as GYT_DESCRI , "
        cFields += " GYT_HRMINT , "
        cFields += " '"+Dtos(dDtIniApu)+"' as DTINIAPU   , "
        cFields += " '"+Dtos(dDtFimApu)+"' as DTFIMAPU   , "
        cFields += " '' as GYG_LEGEND  "
    Endif

    cFields := "%"+cFields+"%"

    //Parte da query que usará para todas as querys abaixo, essa parte representa sobre a junção do colaborador ao grupo de escala
    If !Empty(cGrupoFim)
        cQryGRP := "%"
        cQryGRP += "INNER JOIN " + RetSQLName("GZA") + " GZA ON"
        cQryGRP += "    GZA.GZA_FILIAL = '"+xFilial("GZA")+"'"
        cQryGRP += "    AND GZA.GZA_SETOR = GY2.GY2_SETOR"
        cQryGRP += "    AND GZA.GZA_CODIGO BETWEEN '" + cGrupoIni + "' AND '" + cGrupoFim + "'"
        cQryGRP += "    AND GZA.D_E_L_E_T_ = ' '" 

        cQryGRP += "INNER JOIN " + RetSQLName("GYI") + " GYI on "
        cQryGRP += "    GYI.GYI_FILIAL = '"+xFilial("GYI")+"'"
        cQryGRP += "    AND GYI.GYI_GRPCOD = GZA.GZA_CODIGO "
        cQryGRP += "    AND GYI.GYI_COLCOD = GYG_CODIGO"
        cQryGRP += "    AND GYI.D_E_L_E_T_ = ' ' "
        cQryGRP += "%"
        
        If Empty(cGrupoIni)
            cQryGRP := StrTran(cQryGRP,"INNER","LEFT")
        Else
            cWhenGrp:= "% AND GYI_COLCOD IS NOT NULL %"
        Endif

    Endif	

    BeginSql Alias cAliasTmp
        Column DTINIAPU as Date
        Column DTFIMAPU as Date

        Select 
            %Exp:cFields%

        From %Table:GYG% GYG
            INNER JOIN %Table:GYT% GYT ON
                GYT.GYT_FILIAL = %xFilial:GYT%
                AND GYT.GYT_CODIGO BETWEEN %Exp:cSetorIni% and %Exp:cSetorAte%
                AND GYT.%NotDel%
            INNER JOIN %Table:GY2% GY2 ON
                GY2.GY2_FILIAL = %xFilial:GY2%
                AND GY2.GY2_SETOR = GYT.GYT_CODIGO
                AND GY2.GY2_CODCOL = GYG.GYG_CODIGO
                AND GY2.%NotDel%
            
            %Exp:cQryGRP%

            LEFT JOIN %Table:GYK% GYK ON
                GYK_FILIAL =  %xFilial:GYK%
                AND GYK.GYK_CODIGO = GYG.GYG_RECCOD 
                AND GYK.%NotDel% 
            Inner Join %Table:GI1% GI1 on
                GI1.GI1_FILIAL = %xFilial:GI1%
                AND GI1.GI1_COD = GYT_LOCALI
                AND GI1.%NotDel%
        Where
            GYG.GYG_FILIAL = %xFilial:GYG%
            AND GYG_CODIGO BETWEEN %Exp:cColabIni% and %Exp:cColabFim% 
            AND GYG.%NotDel%
            %Exp:cWhenGrp%
            AND EXISTS (
                SELECT 1 FROM (
                    SELECT DENSE_RANK() OVER (ORDER BY GYN_FILIAL,GYN_CODIGO,GQE_RECURS,GQE_DTREF) RANK
                    FROM %TABLE:GYN% GYN
                        INNER JOIN %TABLE:GQE% GQE ON
                            GQE.GQE_FILIAL = GYN.GYN_FILIAL
                            AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
                            AND GQE.GQE_RECURS = GYG_CODIGO
                            AND GQE.GQE_DTREF BETWEEN %Exp:dDtIniApu% AND %Exp:dDtFimApu%
                            AND GQE_TRECUR = '1'
                            AND GQE_CANCEL = '1'
                            AND GQE_STATUS = '1'
                            AND GQE_TERC IN (' ','2')
                            AND GQE.%NotDel%
                    WHERE
                        GYN.GYN_FILIAL = %xFilial:GYN%
                        AND GYN.GYN_FINAL = '1'
                        AND GYN.GYN_TIPO <> '2' 
                        AND GYN.%NotDel%
                ) GQE
                WHERE
                    GQE.RANK = 1

                UNION

                SELECT 1 FROM (
                    SELECT 
                        DENSE_RANK() OVER (ORDER BY GQK_FILIAL,GQK_RECURS,GQK_DTREF) RANK
                    FROM %TABLE:GQK%  GQK
                    WHERE 
                        GQK.GQK_FILIAL = %xFilial:GYN%
                        AND GQK.GQK_RECURS = GYG.GYG_CODIGO
                        AND GQK.GQK_DTREF BETWEEN %Exp:dDtIniApu% AND %Exp:dDtFimApu%
                        AND GQK_STATUS = '1' 
                        AND GQK_TERC IN (' ','2')
                        AND GQK.%NotDel%
                ) GQK
                WHERE 
                    GQK.RANK = 1
                    
            )
    EndSql

    If lCheck
        IF (cAliasTmp)->TOTAL == 0
            lRet := .F.
            FwAlertHelp('Não Existem Dados para os Parametros Informados.',;
                        'Verifique os parametros informados ou o periodo selecionado',;
                        'Operação Não Realizada')
        EndIf
    else
        aRet := FWLoadByAlias(oMdl, cAliasTmp)
    Endif
    
    (cAliasTmp)->(DbCloseArea())
	
Endif

Return lRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} BuscaAlocacao

@type Static Function
@author jacomo.fernandes
@since 03/09/2019
@version 1.0
@return aRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function BuscaAlocacao(cColab,dDtIni,dDtFim)
Local cAliasTmp := GetNextAlias()
Local oTable    := Nil
Local cSelect1  := ""
Local cSelect2  := ""

If GQK->(FieldPos("GQK_INTERV")) > 0
    cSelect1 := "%(CASE GQE_INTERV WHEN ' ' THEN '2' ELSE GQE_INTERV END) AS GQK_INTERV ,%"
    cSelect2 := "%(CASE GQK_INTERV WHEN ' ' THEN '2' ELSE GQK_INTERV END) AS GQK_INTERV ,%"
EndIf

BeginSql Alias cAliasTmp
    
    Column GQK_DTREF as Date
    Column GQK_DTINI as Date
    Column GQK_DTFIM as Date
    Column RECNO as Numeric(16,0)
    
    SELECT 
        GYN_LINCOD AS LINHA,
        GYG_CODIGO  AS GQK_RECURS ,
        GYG_NOME    AS GQK_DRECUR ,
        (CASE GQE_CONF 
            WHEN ' ' THEN '2'
            ELSE GQE_CONF 
        END)     AS GQK_CONF   ,
        '1'         AS GQK_TPDIA  ,
        GQE_DTREF   AS GQK_DTREF  ,
        G55_DTPART  AS GQK_DTINI  ,
        G55_LOCORI  AS GQK_LOCORI ,
        GI1ORI.GI1_DESCRI AS GQK_DESORI ,
        G55_DTCHEG  AS GQK_DTFIM  ,
        G55_LOCDES  AS GQK_LOCDES ,
        GI1DES.GI1_DESCRI AS GQK_DESDES ,
        GQE_HRINTR  AS GQE_HRINTR ,
        G55_HRINI   AS GQK_HRINI  ,
        G55_HRFIM   AS GQK_HRFIM  ,
        GQE_HRFNTR  AS GQE_HRFNTR ,
        %Exp:cSelect1%
        GQE_TCOLAB  AS GQK_TCOLAB ,
        IsNull(GYK_DESCRI,'') AS GQK_DCOLAB ,
        ''          AS GQK_CODGZS ,
        ''          AS GQK_DSCGZS ,
        (CASE GQE_MARCAD 
            WHEN ' ' THEN '2'
            ELSE GQE_MARCAD 
        END) AS GQK_MARCAD ,

        (CASE GQE_ESPHIN 
            WHEN '    ' THEN GQE_HRINTR
            ELSE GQE_ESPHIN 
        END) AS GQK_ESPHIN ,
        (CASE GQE_ESPHFM 
            WHEN '    ' THEN GQE_HRFNTR
            ELSE GQE_ESPHFM 
        END) AS GQK_ESPHFM ,
        IsNull(GYK_VALCNH,'2') AS GZS_VOLANT,
        '1'         AS GZS_HRPGTO,
        (Case
            When GQE_MARCAD = '1' THEN 'BR_AZUL'
            When GQE_CONF = '1' THEN 'BR_VERDE'
            ELSE 'BR_VERMELHO'
        End)        AS GQK_LEGEND ,
        '1'		    AS TPESC      ,
        GQE.R_E_C_N_O_  AS RECNO,
        'GQE' AS ALIAS_TAB
    FROM %Table:GYG% GYG
        INNER JOIN %Table:GYN% GYN ON
            GYN.GYN_FILIAL = %xFilial:GYN%
            AND GYN.GYN_FINAL = '1'  
            AND GYN.GYN_TIPO <> '2'  
            AND GYN.%NotDel%  
        INNER JOIN %Table:G55% G55 ON
            G55.G55_FILIAL = GYN.GYN_FILIAL
            AND G55.G55_CODVIA = GYN.GYN_CODIGO
            AND G55.%NotDel%
        INNER JOIN %Table:GQE% GQE ON
            GQE.GQE_FILIAL = GYN.GYN_FILIAL
            AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
            AND GQE.GQE_SEQ = G55.G55_SEQ
            AND GQE.%NotDel%
            AND GQE.GQE_RECURS = GYG.GYG_CODIGO
            AND GQE_CANCEL = '1'  
            AND GQE_TRECUR = '1'  
            AND GQE_STATUS = '1'  
            AND GQE_TERC IN (' ','2')
            AND GQE.GQE_DTREF BETWEEN %Exp:dDtIni% and %Exp:dDtFim%
        INNER JOIN %Table:GI1% GI1ORI ON  
            GI1ORI.GI1_FILIAL = %xFilial:GI1%
            AND GI1ORI.GI1_COD = G55.G55_LOCORI  
            AND GI1ORI.%NotDel%  
        INNER JOIN %Table:GI1% GI1DES ON  
            GI1DES.GI1_FILIAL = %xFilial:GI1%  
            AND GI1DES.GI1_COD = G55.G55_LOCDES  
            AND GI1DES.%NotDel%  
        LEFT JOIN %Table:GYK% GYK ON
            GYK_FILIAL = %xFilial:GYK%
            AND GYK.GYK_CODIGO = GQE.GQE_TCOLAB
            AND GYK.%NotDel%
    WHERE
        GYG.GYG_FILIAL = %xFilial:GYG%
        AND GYG.GYG_CODIGO = %Exp:cColab%
        AND GYG.%NotDel%

    UNION

    SELECT
        '' AS LINHA, 
        GYG_CODIGO AS GQK_RECURS ,
        GYG_NOME AS GQK_DRECUR ,
        (CASE GQK_CONF 
            WHEN ' ' THEN '2'
            ELSE GQK_CONF 
        END) GQK_CONF   ,
        GQK_TPDIA  ,
        GQK_DTREF  ,
        GQK_DTINI  ,
        GQK_LOCORI ,
        GI1ORI.GI1_DESCRI AS GQK_DESORI ,
        GQK_DTFIM  ,
        GQK_LOCDES ,
        GI1DES.GI1_DESCRI AS GQK_DESDES ,
        GQK_HRINI AS GQE_HRINTR ,
        GQK_HRINI  ,
        GQK_HRFIM  ,
        GQK_HRFIM  AS GQE_HRFNTR ,
        %Exp:cSelect2%
        GQK_TCOLAB ,
        IsNull(GYK_DESCRI,'') AS GQK_DCOLAB ,
        GQK_CODGZS ,
        GZS.GZS_DESCRI AS GQK_DSCGZS ,
        (CASE GQK_MARCAD 
            WHEN ' ' THEN '2'
            ELSE GQK_MARCAD 
        END) GQK_MARCAD ,
        (CASE GQK_ESPHIN 
            WHEN '    ' THEN GQK_HRINI
            ELSE GQK_ESPHIN 
        END) AS GQK_ESPHIN ,
        (CASE GQK_ESPHFM 
            WHEN '    ' THEN GQK_HRFIM
            ELSE GQK_ESPHFM 
        END) AS GQK_ESPHFM ,
        (Case
            when GZS.GZS_CODIGO IS NOT NULL AND GZS_VOLANT <> '' THEN GZS_VOLANT
            WHEN GQK.GQK_TPDIA = '1' AND IsNull(GYK_VALCNH,'2') = '1' THEN '1'
            ELSE '2'
        End) as GZS_VOLANT,
        IsNull(GZS_HRPGTO,'1') AS GZS_HRPGTO,
        (Case
            When GQK_MARCAD = '1' THEN 'BR_AZUL'
            When GQK_CONF = '1' THEN 'BR_VERDE'
            ELSE 'BR_VERMELHO'
        End) AS GQK_LEGEND ,
        '2'		   AS TPESC      ,
        GQK.R_E_C_N_O_  AS RECNO,
        'GQK' AS ALIAS_TAB 
    FROM %Table:GYG% GYG
        INNER JOIN %Table:GQK% GQK ON
            GQK.GQK_FILIAL = %xFilial:GQK%
            AND GQK.GQK_DTREF BETWEEN %Exp:dDtIni% and %Exp:dDtFim%
            AND GQK.GQK_RECURS = GYG.GYG_CODIGO
            AND GQK.GQK_STATUS = '1' 
            AND GQK.%NotDel%
            AND GQK_TERC IN (' ','2')
        Left JOIN %Table:GI1% GI1ORI ON  
            GI1ORI.GI1_FILIAL = %xFilial:GI1% 
            AND GI1ORI.GI1_COD = GQK.GQK_LOCORI
            AND GI1ORI.%NotDel% 
        Left JOIN %Table:GI1% GI1DES ON  
            GI1DES.GI1_FILIAL = %xFilial:GI1% 
            AND GI1DES.GI1_COD = GQK.GQK_LOCDES
            AND GI1DES.%NotDel% 
        LEFT JOIN %Table:GYK% GYK ON
            GYK_FILIAL = %xFilial:GYK% 
            AND GYK.GYK_CODIGO = GQK_TCOLAB
            AND GYK.%NotDel%
        LEFT JOIN %Table:GZS% GZS ON
            GZS.GZS_FILIAL = %xFilial:GZS% 
            AND GZS.GZS_CODIGO = GQK.GQK_CODGZS
            AND GZS.%NotDel%
    WHERE
        GYG.GYG_FILIAL = %xFilial:GYG% 
        AND GYG.GYG_CODIGO = %Exp:cColab%
        AND GYG.%NotDel%
EndSql

oTable  := GtpxTmpTbl(cAliasTmp,{{"IDX",{"GQK_DTREF","GQK_DTINI","GQE_HRINTR"}}})

SetDiasFalta(oTable:GetAlias(),cColab,dDtIni,dDtFim)

Return oTable:GetAlias()

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetDiasFalta

@type Static Function
@author jacomo.fernandes
@since 03/09/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function SetDiasFalta(cAliasTmp,cColab,dDtIni,dDtFim)
Local cTpDia	:= ""
Local cPosFalta	:= cValToChar(Len(GTPXCBox('GQK_TPDIA'))+1)

Local dDtAux    := dDtIni
    
(cAliasTmp)->(DbGoTop())	

While ( dDtAux <= dDtFim )

    If !(cAliasTmp)->(DbSeek(DtoS(dDtAux) ) )

        RecLock(cAliasTmp,.T.)
			
			If !GTP409ColConf(cColab,dDtAux,/*cLinha*/,/*aConf*/,/*aRetLog*/)
				cTpDia	:= '5' // Indisponivel
			Else
				cTpDia	:= cPosFalta
            Endif
                
            (cAliasTmp)->GQK_RECURS := cColab
            (cAliasTmp)->GQK_DRECUR := Posicione('GYG',1,xFilial('GYG')+cColab,'GYG_NOME')
            (cAliasTmp)->GQK_CONF   := '1'
            (cAliasTmp)->GQK_TPDIA  := cTpDia
            (cAliasTmp)->GQK_DTREF  := dDtAux
            (cAliasTmp)->GZS_VOLANT := '2'
            (cAliasTmp)->GZS_HRPGTO := '1'
            (cAliasTmp)->GQK_LEGEND := 'BR_PRETO'
            (cAliasTmp)->TPESC      := '3'
			
		(cAliasTmp)->(MsUnlock())

    Endif
    
	dDtAux++
End

(cAliasTmp)->(DbGoTop())	

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelActivate

@type Static Function
@author jacomo.fernandes
@since 03/09/2019
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function ModelActivate(oModel)
Local oMdlGYG   := oModel:GetModel('GYGDETAIL')
Local oMdlAloc  := oModel:GetModel('ALOCDETAIL')

Local n1        := 0

For n1  := 1 To oMdlGYG:Length()
    oMdlGYG:GoLine(n1)

    If oMdlAloc:SeekLine({{'GQK_CONF','2'}},.F.,.F.)
        oMdlGYG:SetValue('GYG_LEGEND','BR_VERMELHO')
    Else
        oMdlGYG:SetValue('GYG_LEGEND','BR_VERDE')
    Endif
    
    CalculaTotais(oModel)

Next

oMdlGYG:GoLine(1)

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} ViewDef

@type Function
@author jacomo.fernandes
@since 02/09/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView     := NIL
Local oModel 	:= FWLoadModel( 'GTPA425' )
Local oStrColab := FWFormViewStruct():New()
Local oStrAloc  := FWFormViewStruct():New()
Local oStrTot   := FWFormViewStruct():New()

Local bDblClick := {{|oGrid,cField,nLineGrid,nLineModel| SetDoubleClick(oGrid,cField,nLineGrid,nLineModel)}}

SetViewStruct(oStrColab,oStrAloc,oStrTot)

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddGrid('VW_GYGDETAIL'	, oStrColab	,'GYGDETAIL')
oView:AddGrid('VW_ALOCDETAIL'	, oStrAloc	,'ALOCDETAIL')
oView:AddField('VW_TOTDETAIL' 	, oStrTot	,"TOTDETAIL")

oView:CreateHorizontalBox('SUPERIOR'	, 20)
oView:CreateHorizontalBox('MEIO'		, 55)
oView:CreateHorizontalBox('TOTAL'		, 25)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001)//"Efetivação de Colaboradores"

oView:SetOwnerView('VW_GYGDETAIL'   ,'SUPERIOR')
oView:SetOwnerView('VW_ALOCDETAIL'  ,'MEIO')
oView:SetOwnerView('VW_TOTDETAIL'   ,'TOTAL')

oView:EnableTitleView('VW_GYGDETAIL' , STR0005 ) //"Colaboradores"
oView:EnableTitleView('VW_ALOCDETAIL', STR0006 ) //"Horários Apurados"
oView:EnableTitleView('VW_TOTDETAIL' , STR0007 ) //"Totalizadores"

oView:SetViewProperty("VW_GYGDETAIL"    ,"GRIDDOUBLECLICK", bDblClick)
oView:SetViewProperty("VW_ALOCDETAIL"   ,"GRIDDOUBLECLICK", bDblClick)

oView:SetViewProperty("VW_ALOCDETAIL"   ,"GRIDFILTER", {.T.})

oView:SetViewProperty("VW_ALOCDETAIL"   , "GRIDNOORDER")

oView:AddUserButton("Confirmar Todos"       , "", {|oView| FwMsgRun(,{|| ConfirmarTodos(oView,.T.)  },,"Confirmando recurso..."             )},/*cToolTip*/ ,/*nShortCut*/)
oView:AddUserButton("Desconfirmar Todos"    , "", {|oView| FwMsgRun(,{|| ConfirmarTodos(oView,.F.)  },,"Desconfirmando recurso..."          )},/*cToolTip*/ ,/*nShortCut*/) 
oView:AddUserButton("Recarregar Dados"      , "", {|oView| FwMsgRun(,{|| RecarregaDados(oView)      },,"Recarregando dados do recurso..."   )},/*cToolTip*/ ,/*nShortCut*/)
oView:AddUserButton("Simulação do ponto"    , "", {|oView| FwMsgRun(,{|| SimulaPonto(oView)         },,"Carregando dados..."                )},/*cToolTip*/ ,VK_F8)

oView:SetViewProperty("VW_TOTDETAIL", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP,10} )

Return oView

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetViewStruct

@type Static Function
@author jacomo.fernandes
@since 02/09/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrColab, oStrAloc, oStrTot)
Local aCpoColab := {}
Local aCpoAloc  := {}
Local aTpDia	:= GTPXCBox('GQK_TPDIA')
aAdd(aTpDia,cValTochar(Len(aTpDia)+1)+'=Falta')
	
If ValType(oStrColab) == "O"
    aAdd(aCpoColab,'GYG_CODIGO' )
    aAdd(aCpoColab,'GYG_NOME'   )
    aAdd(aCpoColab,'GYG_FILSRA' )
    aAdd(aCpoColab,'GYG_FUNCIO' )
    aAdd(aCpoColab,'GYG_RECCOD' )
    aAdd(aCpoColab,'GYG_DESREC' )
    aAdd(aCpoColab,'GYT_DESCRI' )
    
    GTPxCriaCpo(oStrColab,aCpoColab,.F.)
    
    oStrColab:AddField("GYG_LEGEND" ,'00',"","",{""},'BT','@BMP' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    
    oStrColab:SetProperty("GYG_FILSRA"   , MVC_VIEW_TITULO       ,"Fil. Matricula")
    oStrColab:SetProperty("GYG_FUNCIO"   , MVC_VIEW_TITULO       ,"Matricula")
    oStrColab:SetProperty("GYT_DESCRI"   , MVC_VIEW_TITULO       ,"Setor")
    
    oStrColab:SetProperty('*'            , MVC_VIEW_CANCHANGE	, .F. )

Endif

If ValType(oStrAloc) == "O"
    aAdd(aCpoAloc,'GQK_DRECUR'  )
    aAdd(aCpoAloc,'GQK_CONF'    )
    aAdd(aCpoAloc,'GQK_TPDIA'   ) 
    aAdd(aCpoAloc,'GQK_DTREF'   ) 
    aAdd(aCpoAloc,'GQK_DTINI'   ) 
    aAdd(aCpoAloc,'GQK_DESORI'  )
    aAdd(aCpoAloc,'GQK_DTFIM'   ) 
    aAdd(aCpoAloc,'GQK_DESDES'  )
    aAdd(aCpoAloc,'GQE_HRINTR'  )
    aAdd(aCpoAloc,'GQK_HRINI'   ) 
    aAdd(aCpoAloc,'GQK_HRFIM'   ) 
    aAdd(aCpoAloc,'GQE_HRFNTR'  )
    If GQK->(FieldPos("GQK_INTERV")) > 0
        aAdd(aCpoAloc,'GQK_INTERV'  )
    EndIf
    aAdd(aCpoAloc,'GQK_DCOLAB'  )
    aAdd(aCpoAloc,'GQK_DSCGZS'  )
    aAdd(aCpoAloc,'GQK_MARCAD'  )
    
    GTPxCriaCpo(oStrAloc,aCpoAloc,.F.)
    oStrAloc:AddField("GQK_LEGEND" ,'00',"","",{""},'BT','@BMP' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )

    oStrAloc:SetProperty('GQK_TPDIA'    ,MVC_VIEW_COMBOBOX      ,aTpDia)

    oStrAloc:SetProperty("GQK_DRECUR"   , MVC_VIEW_TITULO       ,"Colaborador")
    
    oStrAloc:SetProperty('*'            , MVC_VIEW_CANCHANGE	, .F. )
    oStrAloc:SetProperty('GQK_CONF'     , MVC_VIEW_CANCHANGE	, .T. )
    oStrAloc:SetProperty('GQE_HRINTR'	, MVC_VIEW_CANCHANGE	, .T. )
    oStrAloc:SetProperty('GQE_HRFNTR'	, MVC_VIEW_CANCHANGE	, .T. )
    oStrAloc:SetProperty('GQK_DTREF'	, MVC_VIEW_CANCHANGE	, .T. )
    If GQK->(FieldPos("GQK_INTERV")) > 0
        oStrAloc:SetProperty('GQK_INTERV'	, MVC_VIEW_CANCHANGE	, .T. )
    EndIf

Endif

If ValType(oStrTot) == "O"
    oStrTot:AddField("HRNAOCONF"	,'01',"Hrs Não Conf." ,"Hrs Não Conf." ,{"Hrs Não Conf." },"C",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("HRCONF"		,'02',"Hrs Conferida" ,"Hrs Conferida" ,{"Hrs Conferida" },"C",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("HRMENSAIS"	,'03',"Hrs Mensais"   ,"Hrs Mensais"   ,{"Hrs Mensais"   },"C",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("HRPAGAS"	    ,'04',"Hrs Pagas"     ,"Hrs Pagas"     ,{"Hrs Pagas"     },"C",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("ADNOTURNO"	,'05',"Adn Noturno"   ,"Adn Noturno"   ,{"Adn Noturno"   },"C",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("HREXTRAS"	    ,'06',"Hrs Extras"    ,"Hrs Extras"    ,{"Hrs Extras"    },"C",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("HRNEGATIVAS"  ,'07',"Hrs Negativas" ,"Hrs Negativas" ,{"Hrs Negativas" },"C",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("SALDOHORAS"	,'08',"Saldo Horas"   ,"Saldo Horas"   ,{"Saldo Horas"   },"C",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("HRVOLANTE"	,'09',"Hrs Volante"   ,"Hrs Volante"   ,{"Hrs Volante"   },"C",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("HRFORAVOL"	,'10',"Hrs Fora Vol." ,"Hrs Fora Vol." ,{"Hrs Fora Vol." },"C",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("HRINTTOT"	    ,'11',"Hrs Intev Tot" ,"Hrs Intev Tot" ,{"Hrs Intev Tot" },"C",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("HRINTPGT"	    ,'12',"Hrs Intev Pgt" ,"Hrs Intev Pgt" ,{"Hrs Intev Pgt" },"C",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("DSRDISP"	    ,'13',"DSR Dispon."   ,"DSR Dispon."   ,{"DSR Dispon."   },"N",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("DSRUTIL"	    ,'14',"DSR Utiliz."   ,"DSR Utiliz."   ,{"DSR Utiliz."   },"N",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("QTDFALTAS"	,'15',"Qtd Faltas"    ,"Qtd Faltas"    ,{"Qtd Faltas"    },"N",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrTot:AddField("EXTMENOSDSR"  ,'16',"Ext - DSR"     ,"Ext - DSR"     ,{"Ext - DSR"     },"C",'' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    
    oStrTot:AddGroup( 'GP001', '', '', 2 )
    oStrTot:SetProperty( "HRNAOCONF"	 , MVC_VIEW_GROUP_NUMBER, 'GP001' )
    oStrTot:SetProperty( "HRCONF"		 , MVC_VIEW_GROUP_NUMBER, 'GP001' )
    oStrTot:SetProperty( "HRMENSAIS"	 , MVC_VIEW_GROUP_NUMBER, 'GP001' )
    oStrTot:SetProperty( "HRPAGAS"	     , MVC_VIEW_GROUP_NUMBER, 'GP001' )
    oStrTot:SetProperty( "ADNOTURNO"	 , MVC_VIEW_GROUP_NUMBER, 'GP001' )
    oStrTot:SetProperty( "HREXTRAS"	     , MVC_VIEW_GROUP_NUMBER, 'GP001' )
    oStrTot:SetProperty( "HRNEGATIVAS"   , MVC_VIEW_GROUP_NUMBER, 'GP001' )
    oStrTot:SetProperty( "SALDOHORAS"	 , MVC_VIEW_GROUP_NUMBER, 'GP001' )
    oStrTot:SetProperty( "DSRDISP"	     , MVC_VIEW_GROUP_NUMBER, 'GP001' )
    oStrTot:SetProperty( "DSRUTIL"	     , MVC_VIEW_GROUP_NUMBER, 'GP001' )
    oStrTot:SetProperty( "QTDFALTAS"	 , MVC_VIEW_GROUP_NUMBER, 'GP001' )
    
    oStrTot:AddGroup( 'GP002', '', '', 2 )
    oStrTot:SetProperty( "HRVOLANTE"	 , MVC_VIEW_GROUP_NUMBER, 'GP002' )
    oStrTot:SetProperty( "HRFORAVOL"	 , MVC_VIEW_GROUP_NUMBER, 'GP002' )
    oStrTot:SetProperty( "HRINTTOT"	     , MVC_VIEW_GROUP_NUMBER, 'GP002' )
    oStrTot:SetProperty( "HRINTPGT"	     , MVC_VIEW_GROUP_NUMBER, 'GP002' )
    oStrTot:SetProperty( "EXTMENOSDSR"   , MVC_VIEW_GROUP_NUMBER, 'GP002' )
    

Endif
            
Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetDoubleClick
(long_description)
@type function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param oGrid, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param nLineGrid, numérico, (Descrição do parâmetro)
@param nLineModel, numérico, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetDoubleClick(oGrid,cField,nLineGrid,nLineModel, lAut)
Default lAut := .F.

If cField == "GYG_LEGEND" .or. cField == "GQK_LEGEND"
    GetLegenda(cField, lAut)
Endif

Return .T. 

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetLegenda
(long_description)
@type function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param cField, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function GetLegenda(cField, lAut)
Local oLegenda  :=  FWLegend():New()
Default lAut    := .F.

Do Case
    Case cField == "GYG_LEGEND"
        oLegenda:Add("" , "BR_VERDE"	, "Apuração Confirmada"                 ) 
        oLegenda:Add("" , "BR_VERMELHO"	, "Apuração Pendente de Confirmação"    ) 
 
    Case cField == "GQK_LEGEND"
        oLegenda:Add("" , "BR_VERDE"	, "Alocação Confirmado"                 ) 
        oLegenda:Add("" , "BR_VERMELHO"	, "Alocação pendente de Confirmação"    ) 
        oLegenda:Add("" , "BR_PRETO"  	, "Sem informação cadastrada (Falta)"   )
        oLegenda:Add("" , "BR_AZUL"  	, "Alocação enviada para o ponto"       )
EndCase

If !lAut 
    oLegenda:Activate()
    oLegenda:View()
    oLegenda:DeActivate()
EndIf

GtpDestroy(oLegenda)

Return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
(long_description)
@type function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param oModel, Object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function ModelPosVld(oModel)
Local lRet      := .T.
Local oMdlGYG   := oModel:GetModel('GYGDETAIL')

If oMdlGYG:SeekLine({{'GYG_LEGEND','BR_VERMELHO'}},.F.,.F.)
    
    If !FwAlertYesNo("Foi encontrado registro sem confirmação, deseja continuar mesmo assim?","Atenção?")
        lRet := .F.
        oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"ModelPosVld","Confirmação cancelada","Confirme todos os registros ou aceite continuar o processo mesmo assim")
    Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelCommit
(long_description)
@type function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param oModel, Object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function ModelCommit(oModel)
Local lRet		:= .T.
Local aErro     := {}
Local nGYG      := 0
Local nAloc     := 0

Local oMdlGYG	:= oModel:GetModel("GYGDETAIL")
Local oMdlAloc	:= oModel:GetModel("ALOCDETAIL")

Local oMdl303A 	:= FwLoadModel("GTPA303A")
Local oFld303A	:= oMdl303A:GetModel("FIELD_GQE")

Local oMdl313 	:= FwLoadModel("GTPA313")
Local oFld313	:= oMdl313:GetModel("GQKMASTER")

DbSelectArea("GQE")
DbSelectArea("GQK")

Begin Transaction
    For nGYG := 1 To oMdlGYG:Length()
        oMdlGYG:GoLine(nGYG)
        For nAloc  := 1 To oMdlAloc:Length()
            If oMdlAloc:IsDeleted(nAloc) .or. oMdlAloc:GetValue('TPESC',nAloc) == "3" .or. oMdlAloc:GetValue('GQK_MARCAD',nAloc) == "1"
                Loop
            Endif
            
            If oMdlAloc:GetValue('TPESC',nAloc) == "1"
                GQE->(DbGoTo(oMdlAloc:GetValue('RECNO',nAloc)))
                                
                oMdl303A:SetOperation(MODEL_OPERATION_UPDATE)
                
                If oMdl303A:Activate()
                    lRet := oFld303A:LoadValue('GQE_CONF'   ,oMdlAloc:GetValue('GQK_CONF'   ,nAloc))
                    lRet := lRet .and. oFld303A:LoadValue('GQE_DTREF'  ,oMdlAloc:GetValue('GQK_DTREF'  ,nAloc))
                    lRet := lRet .and. oFld303A:LoadValue('GQE_HRINTR' ,oMdlAloc:GetValue('GQE_HRINTR' ,nAloc))
                    lRet := lRet .and. oFld303A:LoadValue('GQE_HRFNTR' ,oMdlAloc:GetValue('GQE_HRFNTR' ,nAloc))
                    If GQK->(FieldPos("GQK_INTERV")) > 0
                        lRet := lRet .and. oFld303A:LoadValue('GQE_INTERV' ,oMdlAloc:GetValue('GQK_INTERV' ,nAloc))
                    EndIf
                    lRet := lRet .and. oFld303A:LoadValue('GQE_ESPHIN' ,oMdlAloc:GetValue('GQK_ESPHIN' ,nAloc))      
                    lRet := lRet .and. oFld303A:LoadValue('GQE_ESPHFM' ,oMdlAloc:GetValue('GQK_ESPHFM' ,nAloc))
                    
                    If oMdl303A:VldData()
                        lRet := oMdl303A:CommitData()
                    Else
                        lRet := .F.
                    Endif	
                    
                Endif
                
                If !lRet
                    aErro := oMdl303A:GetErrormessage()
                Endif
                
                oMdl303A:DeActivate()
            Else
                GQK->(DbGoTo(oMdlAloc:GetValue('RECNO',nAloc)))
                                    
                oMdl313:SetOperation(MODEL_OPERATION_UPDATE)
                
                If oMdl313:Activate()
                    lRet := oFld313:LoadValue('GQK_CONF'   ,oMdlAloc:GetValue('GQK_CONF'   ,nAloc))
                    lRet := lRet .and. oFld313:LoadValue('GQK_DTREF'  ,oMdlAloc:GetValue('GQK_DTREF'  ,nAloc))
                    lRet := lRet .and. oFld313:LoadValue('GQK_HRINI'  ,oMdlAloc:GetValue('GQE_HRINTR' ,nAloc))
                    lRet := lRet .and. oFld313:LoadValue('GQK_HRFIM'  ,oMdlAloc:GetValue('GQE_HRFNTR' ,nAloc))
                    If GQK->(FieldPos("GQK_INTERV")) > 0
                        lRet := lRet .and. oFld313:LoadValue('GQK_INTERV' ,oMdlAloc:GetValue('GQK_INTERV' ,nAloc))
                    EndIf
                    lRet := lRet .and. oFld313:LoadValue('GQK_ESPHIN' ,oMdlAloc:GetValue('GQK_ESPHIN' ,nAloc))      
                    lRet := lRet .and. oFld313:LoadValue('GQK_ESPHFM' ,oMdlAloc:GetValue('GQK_ESPHFM' ,nAloc))
                    
                    If oMdl313:VldData()
                        lRet := oMdl313:CommitData()
                    Else
                        lRet := .F.
                    Endif	
                    
                Endif
                
                If !lRet
                    aErro := oMdl313:GetErrormessage()
                Endif
                
                oMdl313:DeActivate()
            Endif
            
            If !lRet
                DisarmTransaction()
                Exit
            Endif
        Next nAloc

        If !lRet
            DisarmTransaction()
            Exit
        Endif

    Next nGYG

End Transaction

If !lRet .and. Len(aErro) > 0
    JurShowErro( aErro )
Endif

oMdl303A:Destroy()
oMdl313:Destroy()

GtpDestroy(oMdl303A)
GtpDestroy(oMdl313)
GtpDestroy(aErro)

	
Return(lRet)

//------------------------------------------------------------------------------
/* /{Protheus.doc} CalculaTotais

@type Function
@author jacomo.fernandes
@since 03/09/2019
@version 1.0
@param oModel, Object, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------

Static Function CalculaTotais(oModel)
Local oMdlTot       := oModel:GetModel('TOTDETAIL')
Local oCalc         := GetDadosCalc(oModel)
Local nExtMenosDsr  := 0

If oCalc:nSaldoHora > 0 .and. oCalc:nDsrDisp > oCalc:nDsrUtil
    nExtMenosDsr    := oCalc:nSaldoHora - (oCalc:nHrsDia * (oCalc:nDsrDisp-oCalc:nDsrUtil) ) 
    If nExtMenosDsr < 0 //Ignorar quando negativo
        nExtMenosDsr    := 0
    Endif
Endif

oMdlTot:LoadValue("HRNAOCONF"	,oCalc:cHrNaoConf       )
oMdlTot:LoadValue("HRCONF"		,oCalc:cHrConf          )
oMdlTot:LoadValue("HRMENSAIS"	,oCalc:cHrPeriodo       )
oMdlTot:LoadValue("HRPAGAS"		,oCalc:cHrPagas         )
oMdlTot:LoadValue("ADNOTURNO"	,oCalc:cHrAdnNot        )
oMdlTot:LoadValue("HREXTRAS"	,oCalc:cHrExtra         )	
oMdlTot:LoadValue("HRNEGATIVAS"	,oCalc:cHrNegat         )
oMdlTot:LoadValue("SALDOHORAS"	,oCalc:cSaldoHora       )
oMdlTot:LoadValue("HRVOLANTE"	,oCalc:cHrVolante       )
oMdlTot:LoadValue("HRFORAVOL"	,oCalc:cHrForaVol       )
oMdlTot:LoadValue("HRINTTOT"	,oCalc:cHrIntTot        )	
oMdlTot:LoadValue("HRINTPGT"	,oCalc:cHrIntPgt        )	
oMdlTot:LoadValue("DSRDISP"	    ,oCalc:nDsrDisp         )
oMdlTot:LoadValue("DSRUTIL"	    ,oCalc:nDsrUtil         )
oMdlTot:LoadValue("QTDFALTAS"	,oCalc:nQtdFaltas       )
oMdlTot:LoadValue("EXTMENOSDSR"	,IntToHora(nExtMenosDsr,3)  )

oCalc:Destroy()

Return(.T.)

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetDadosCalc

@type Static Function
@author jacomo.fernandes
@since 04/09/2019
@version 1.0
@param oModel, Object, (Descrição do parâmetro)
@return oCalc, return_description
/*/
//------------------------------------------------------------------------------
Static Function GetDadosCalc(oModel)
Local oMdlGYG       := oModel:GetModel('GYGDETAIL') 
Local oMdlGQE       := oModel:GetModel('ALOCDETAIL')  
Local cSetor        := oMdlGYG:GetValue('GYT_CODIGO')
Local cColab        := oMdlGYG:GetValue('GYG_CODIGO')
Local n1			:= 0

Local oCalc         := GTPxCalcHrPeriodo():New(cSetor,cColab)
Local dDtRef        := Stod('')
Local cTpdia        := ""
Local dDtIni        := Stod('')
Local cHrIni        := ""
Local cCodOri       := ""
Local cDesOri       := ""
Local dDtFim        := Stod('')
Local cHrFim        := ""
Local cCodDes       := ""
Local cDesDes       := ""
Local lHrVol        := .T.
Local lInterv       := .F.
Local lHrPagas      := .T.
Local lConf         := .T.

For n1:= 1 To oMdlGQE:Length()
    If !oMdlGQE:IsDeleted(n1)
        dDtRef      := oMdlGQE:GetValue("GQK_DTREF"     ,n1)
        cTpdia      := oMdlGQE:GetValue("GQK_TPDIA"     ,n1)
        dDtIni      := oMdlGQE:GetValue("GQK_DTINI"     ,n1)
        cHrIni      := oMdlGQE:GetValue("GQE_HRINTR"    ,n1)
        cCodOri     := oMdlGQE:GetValue("GQK_LOCORI"    ,n1)
        cDesOri     := oMdlGQE:GetValue("GQK_DESORI"    ,n1)
        dDtFim      := oMdlGQE:GetValue("GQK_DTFIM"     ,n1)
        cHrFim      := oMdlGQE:GetValue("GQE_HRFNTR"    ,n1)
        cCodDes     := oMdlGQE:GetValue("GQK_LOCDES"    ,n1)
        cDesDes     := oMdlGQE:GetValue("GQK_DESDES"    ,n1)
        If GQK->(FieldPos("GQK_INTERV")) > 0
            lInterv     := oMdlGQE:GetValue("GQK_INTERV"    ,n1) == '1'
        EndIf
        lConf       := oMdlGQE:GetValue("GQK_CONF"      ,n1) == '1'
        lHrVol      := oMdlGQE:GetValue("GZS_VOLANT"    ,n1) == '1
        lHrPagas    := oMdlGQE:GetValue("GZS_HRPGTO"    ,n1) == '1' .AND. !lInterv
        
        oCalc:AddTrechos(dDtRef,cTpDia,;
                dDtIni,cHrIni,cCodOri,cDesOri,;
                dDtFim,cHrFim,cCodDes,cDesDes,;
                lHrVol,lHrPagas,lConf)

    Endif
Next

oCalc:Calcula()

Return oCalc

//------------------------------------------------------------------------------
/* /{Protheus.doc} SimulaPonto

@type Static Function
@author jacomo.fernandes
@since 04/09/2019
@version 1.0
@param oView, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SimulaPonto(oView)
Local oModel    := oView:GetModel()
Local oCalc     := GetDadosCalc(oModel)

GTPA425a(oCalc)

oCalc:Destroy()

GTPDestroy(oCalc)

Return 

/*/{Protheus.doc} ConfirmarTodos
Função responsavel pela confirmação de todos os registros
@type function
@author jacomo.fernandes
@since 19/01/2019
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ConfirmarTodos(oView,lConf)
Local oModel    := oView:GetModel()
Local oMdlGQE	:= oView:GetModel("ALOCDETAIL")
Local nLineAtu  := oMdlGQE:GetLine()
Local nLine		:= 0

For nLine := 1 to oMdlGQE:Length()  
	If oMdlGQE:GetValue('GQK_CONF',nLine) <> If(lConf,'1','2') ;
		.and. oMdlGQE:GetValue('TPESC',nLine) <> '3';
		.and. oMdlGQE:GetValue('GQK_MARCAD',nLine) <> '1'
		
		oMdlGQE:GoLine(nLine)
		oMdlGQE:SetValue('GQK_CONF',If(lConf,'1','2'))
	Endif
Next

CalculaTotais(oModel)

oMdlGQE:GoLine(nLineAtu)

oView:Refresh()

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} RecarregaDados
Função responsavel pela recarga dos daos na tela
@type Static Function
@author jacomo.fernandes
@since 17/06/2019
@version 1.0
@param oView, object, (Descrição do parâmetro)
@return nil, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function RecarregaDados(oView, lAut)
Local oModel	:= NIL
Local oMdlGYG   := NIL
Local oMdlAloc  := NIL
Local cColab    := ''
Local dDtIni    := cTod('')
Local dDtFim    := cTod('')
Local cAliasTmp := ""
Local aFields   := {}
Local lRet      := .T.
Local n1        := 0

Default lAut    := .F.

if !lAut
    oModel	  := oView:GetModel()
    oMdlGYG   := oModel:GetModel('GYGDETAIL')
    oMdlAloc  := oModel:GetModel('ALOCDETAIL')
    cColab    := oMdlGYG:GetValue('GYG_CODIGO')
    dDtIni    := oMdlGYG:GetValue('DTINIAPU')
    dDtFim    := oMdlGYG:GetValue('DTFIMAPU')
endif

if !lAut
    IF !FwAlertYesNo('Os dados já cadastrados não serão salvos, deseja recarregar os dados?','Atenção!!')
	    lRet    := .F.
    Endif

    If lRet
        cAliasTmp   := BuscaAlocacao(cColab,dDtIni,dDtFim)
        aFields     := (cAliasTmp)->(DbStruct())

        oMdlAloc:SetNoInsertLine(.F.)
        oMdlAloc:SetNoDeleteLine(.F.)

        GTPxClearData(oMdlAloc)

        
        While (cAliasTmp)->(!Eof())
            
            If !oMdlAloc:IsEmpty() .and. !( oMdlAloc:Length() == 1 .and. Empty(oMdlAloc:GetValue( 'GQK_RECURS' )))
                oMdlAloc:AddLine()
            Endif
            
            For n1 := 1 to Len(aFields) 	
                If oMdlAloc:HasField(aFields[n1][1])
                    oMdlAloc:LoadValue(aFields[n1][1],(cAliasTmp)->&(aFields[n1][1]))
                Endif
            Next
            
            
            (cAliasTmp)->(DbSkip())
        End

        (cAliasTmp)->(DbCloseArea())
        
        oMdlAloc:SetNoInsertLine(.T.)
        oMdlAloc:SetNoDeleteLine(.T.)
        

        CalculaTotais(oModel)
    Endif
endif
GTPDestroy(aFields)

Return

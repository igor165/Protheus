#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH" 
#INCLUDE "FWBROWSE.CH" 
#Define AQUISICAO "A"
#Define VENDAS    "V"
#DEFINE ENTER CHR(13)+CHR(10)
#Define PROCESSADO	"P"

Static aModels := {}

/*
Funcao     : ESSDC400()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Rotina de Documentos RE/DI
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 29/03/2016 :: 14:43
*/
*---------------------------------------------*
Function ESSDC400(aCabAuto,aDetAuto,nOpcAuto)      
*---------------------------------------------*
Local oBrowse, i, j
Local oAvObject    := AvObject():New()
Private lDC400Auto := ValType(aCabAuto) <> "U" .Or. ValType(aDetAuto) <> "U" .Or. ValType(nOpcAuto) <> "U"
Private lDataModel := .T., aCab := {}

If !lDC400Auto
   oBrowse := FWMBrowse():New()
   oBrowse:SetAlias("EL9")

   oBrowse:SetMenuDef("ESSDC400")
   oBrowse:SetDescription("Documentos")
   oBrowse:Activate()
Else
   Begin Sequence
      //If nOpcAuto == 5
         If !EasySeekAuto("EJY",aCabAuto,1)
            Break
         EndIf
      //EndIf

      INCLUI := nOpcAuto == INCLUIR
      ALTERA := nOpcAuto == ALTERAR
      EXCLUI := nOpcAuto == EXCLUIR
      
      aRotina := MenuDef()
      
      If (nPos := aScan(aDetAuto[1], {|x| x[1] == "EL2_TPPROC"})) # 0
         Private cTpReg := aDetAuto[1][nPos][2]
      EndIf
      
      For i := 1 To Len(aDetAuto)
         For j := 1 To Len(aDetAuto[i])
            aAdd(aCab,aDetAuto[i][j])
         Next j
      Next i
      
      lMsErroAuto := !EasyMVCAuto("ESSDC400",nOpcAuto,{{"TMPMASTER",{{"WD_INTEGRA",.T.,.T.}}},{"EL2DETAIL",aCab}},@oAvObject)
      If lMsErroAuto
         AEval(oAvObject:aError,{|X| AutoGrLog(x)})
      EndIf
  End Sequence   
EndIf

Return Nil

*------------------------*
Static Function MenuDef()
*------------------------*                                   
Local aRotina := {}

ADD OPTION aRotina TITLE "Visualizar"	ACTION "VIEWDEF.ESSDC400" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"		ACTION "VIEWDEF.ESSDC400" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"		ACTION "VIEWDEF.ESSDC400" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"		ACTION "VIEWDEF.ESSDC400" OPERATION 5 ACCESS 0

Return aRotina                  

/* // NCF - 30/12/2020 - Nopado - Modelo não utilizado
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
//Local oStruEL9 :=  FWFormStruct( 1 , "EL9",,)
Local oStruEJY :=  FWFormStruct( 1 , "EJY",,)

Local oStruCapa := DC400Struct()
Local oStruEL2 :=  FWFormStruct( 1 , "EL2",,)
Local bCommit  := {|oMdl|DC400Commit(oMdl)}
Local bPosVal  := {||DC400GravDoc()}
Local bLinePre := {|oGrid,nLine,cAction| DC400LinePre(oGrid,nLine,cAction)}
Local cTpReg   := If(Type("cTpReg")=="C",cTpReg,If( IsInCallStack("ESSRV400") ,"V", "A" ))


oModel := MPFormModel():New( "ESSDC400", , , bCommit, )                                                                               

oModel:AddFields('TMPMASTER',,oStruCapa)
oModel:AddGrid( "EL2DETAIL", "TMPMASTER", oStruEL2, bLinePre, , , ,  )

If IsInCallStack("ESSPS400")
   oModel:SetRelation( "EL2DETAIL", { {"EL2_FILIAL","xFilial('EL2')"},{"EL2_TPPROC", "cTpReg"},{"EL2_PROCES", "EJW_PROCES"},{"EL2_SEQPRC", "oModelIt:GetValue('EJX_SEQPRC')"} }, EL2->( IndexKey( 1 ) ) )
Else
   oModel:SetRelation( "EL2DETAIL", { {"EL2_FILIAL","xFilial('EL2')"},{"EL2_TPPROC", "cTpReg"},{"EL2_REGIST", "EJY_REGIST"},{"EL2_SEQPRC", "oModelIt:GetValue('EJZ_SEQPRC')"} }, EL2->( IndexKey( 1 ) ) )
EndIf

oModel:GetModel( "EL2DETAIL" ):SetOptional( .T. ) 

oModel:SetPrimaryKey({})

//oModel:SetDescription(TESX2Name("EL9") )
//oModel:GetModel( "EJYMASTER" ):SetDescription( "RAS/RVS" )
oModel:GetModel( "EL2DETAIL" ):SetDescription( "Documentos" )

Return oModel


*------------------------*
Static Function ViewDef()
*------------------------*
Local oModel := FWLoadModel("ESSDC400")
Local oStruEL2 := FWFormStruct( 2 , "EL2",,)
Local cFiltro
Local oView
Local lOk

If IsInCallStack("ESSPS400")
   cFiltro := "EL2->(EL2_FILIAL+EL2_TPPROC+EL2_PROCES+EL2_SEQPRC) =='"+ EJW->(EJW_FILIAL+EJW_TPPROC+EJW_PROCES)+EJZ->EJZ_SEQPRC +"'"
Else
   cFiltro := "EL2->(EL2_FILIAL+EL2_TPPROC+EL2_REGIST+EL2_SEQPRC) =='"+ EJY->(EJY_FILIAL+EJY_TPPROC+EJY_REGIST)+EJZ->EJZ_SEQPRC +"'"
EndIf

EL2->(dbSetFilter(&("{||"+cFiltro+"}"),cFiltro))

oView := FWFormView():New()

oView:SetModel( oModel )

oView:AddGrid("VIEW_EL2", oStruEL2, "EL2DETAIL")

oView:CreateHorizontalBox( "TOTAL"  , 100 )

oView:SetOwnerView( "VIEW_EL2" , "TOTAL")

oStruEL2:RemoveField("EL2_REGIST")
oStruEL2:RemoveField("EL2_SEQREG")
oStruEL2:RemoveField("EL2_SEQPAG")
oStruEL2:RemoveField("EL2_PROCES")
oStruEL2:RemoveField("EL2_FASE")
oStruEL2:RemoveField("EL2_SEQPRC")

oView:EnableTitleView( "VIEW_EL2","Documentos" , RGB(240, 248, 255 ))

//oView:SetViewAction("DELETELINE",{|oObj,cDetail|DC400DelDoc(cDetail)})  

oView:EnableControlBar(.T.)

//RMD - 11/04/17 - Limpa o filtro ao encerrar a tela
oView:SetViewAction("BUTTONOK", {|| EL2->(dbClearFilter()) })
oView:SetViewAction("BUTTONCANCEL", {|| EL2->(dbClearFilter()) })

Return oView
*/

/*
Programa   : DC400GravDoc()
Objetivo   : Efetuar a gravação dos Documentos relacionados aos Pagamentos apenas caso a DI ou RE tenham sido preenchido
Parametros : 
Retorno    : .T.
Autor      : Rafael Ramos Capuano
Data/Hora  : 27/08/2012 15:42 
Revisao    : 
*/
*-------------------------------*
Static Function DC400GravDoc()
*-------------------------------*
Local lRet      := .T.
Local oModel    := FWModelActive()
Local oModelEL2 := oModel:GetModel("EL2DETAIL")
Local nLinha    := 1

//RRC - 06/03/2013 - Verifica se o pagamento não possui lote gerado, mas que ainda não tenha sido registrado, neste caso, não pode alterar
If lRet := RS401VerLote(EL9->EL9_TPPROC, EL9->EL9_REGIST, EL9->EL9_SEQPAG) //FSY - 23/01/2014 - removido o 4 paremetro
   For nLinha := 1 To oModelEL2:Length()
      oModelEL2:GoLine(nLinha)
      If !oModelEL2:IsDeleted() .And. Empty(oModelEL2:GetValue("EL2_RE")) .And. Empty(oModelEL2:GetValue("EL2_DI")) 
         oModelEL2:DeleteLine()
      EndIf
   Next
Else
   EasyHelp("Não podem ser feitas alterações, pois este " + If(EL9->EL9_TPPROC=="V","faturamento","pagamento") + " possui lote não cancelado.","Aviso")      
EndIf

Return lRet

/*
Programa   : DC400DelDoc()
Objetivo   : Validar a exclusão de um Documento relacionado a um Pagamento
Parametros : 
Retorno    : Nil
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 27/08/2013 17:08 
Revisao    : 
*/ 
/*--------------------------------------*
Static Function DC400DelDoc(cDetail)
*--------------------------------------*
Local oModel    := FWModelActive()
Local oModelEL2 := oModel:GetModel("EL2DETAIL")
Local oModelUse
Local oView     := FWViewActive()
Local lRet      := .T.

If cDetail == "EL2DETAIL"
   oModelUse := oModelEL2
EndIf

If oModelUse:IsDeleted()
   oView:GETVIEWOBJ(cDetail)[3]:Refresh()
   oModelUse:UnDeleteLine()
EndIf     
Return lRet
*/
*-----------------------------*
Function DC400Commit(oModel)
*-----------------------------*
Local nOperacao := oModel:GetOperation()
/*
If cTpReg == "V"
   cCont := "V"
   cModo := "EJZ_MODVEN" 
   cCampo := "EL2_RE"        
Else   
   cCont := "A"
   cModo := "EJZ_MODAQU"
   cCampo := "EL2_DI"      
EndIf
*/
FWFormCommit(oModel)

Return .T.

*-------------------------------------------*
Function DC400LinePre(oGrid,nLine,cAction)
*-------------------------------------------*
Local aOrd  := SaveOrd({"EJY","EL2"})
Local aRows := FWSaveRows()
Local cMsg  := "", dDtEnc := CTOD("")
Local lRet  := .T.
Local oMdl := FWModelActive()

Do Case
   Case oGrid:cId == "EL2DETAIL"
      If cAction == "DELETE"
        dDtEnc := If(!IsInCallStack("ESSPS400"),oModelCap:GetValue("EJY_DTENC"),dDtEnc)
         If oGrid:GetValue("EL2_STTSIS") <> "1" .Or. !Empty(dDtEnc)
            cMsg := "Este documento não pode ser excluído pois apresenta:"
            If oGrid:GetValue("EL2_STTSIS") <> "1"
               cMsg += " Status '" + BSCXBOX('EL2_STTSIS',oGrid:GetValue("EL2_STTSIS")) + "'."
            EndIf
            If !Empty(dDtEnc)
               cMsg += " Data de Encerramento preenchida."
            EndIf
            //RRC - 14/08/2013
            If Type("cTpReg") == "C"
               cMsg += " Se necessário, apague o conteúdo do campo para posterior retificação."   
            EndIf
            If !(lRet := Empty(cMsg))
               EasyHelp(cMsg,"Aviso")
            EndIf
         EndIf
      ElseIf cAction == "SETVALUE"
         If IsInCallStack("ESSPS400")
            oGrid:LoadValue("EL2_SEQPRC",oModelIt:GetValue("EJX_SEQPRC"))
         Else
            oGrid:LoadValue("EL2_SEQPRC",oModelIt:GetValue("EJZ_SEQPRC"))
         EndIf
      EndIf
EndCase

RestOrd(aOrd,.T.)
Return lRet 

*-------------------------*
Function DC400Struct()
*-------------------------*
Local oStruct := FWFormModelStruct():New()
Local cWKFileName := ""
Local aCpos := { { 'WD_INTEGRA' ,"L", AVSX3("WD_INTEGRA",3) , 0 } }

If Select("WKEL2") # 0
   WKEL2->(DbCloseArea())
Endif

cWKFileName := E_CRIATRAB(,aCpos,"WKEL2")


// GFP - Foi informado o campo WD_INTEGRA, aleatoriamente, pertencente a SX3 para evitar validação no ExecAuto.
oStruct:AddTable('WKEL2',{'WD_INTEGRA'},'WKEL2')
oStruct:AddField('WD_INTEGRA','WD_INTEGRA' , 'WD_INTEGRA', 'L', 1, 0, , , {}, .F., , .F., .F., .F., , )
oStruct:AddIndex( 1, 'WD_INTEGRA', 'WD_INTEGRA', 'WD_INTEGRA', 'WD_INTEGRA', 'WD_INTEGRA', .F. )

Return oStruct

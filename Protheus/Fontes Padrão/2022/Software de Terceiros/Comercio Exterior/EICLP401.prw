#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "TOPCONN.CH"
#INCLUDE "AVERAGE.CH"
#Include 'EICLP401.CH'


#define ENTER CHR(13)+CHR(10)
/*---------------------------------------------------------------------*/
/*/{Protheus.doc} EICLP401
   (rotina para amarração entre Formulário LPCO x N.c.m)
   @type  Function
   @author Nilson César
   @since 04/11/2020
   @version 1
   @param param, param_type, param_descr
   @return returno,return_type, return_description
   @example
   (examples)
   #@see (lINCLUDEinks_or_references) 'TOTVS.CH'
   /*/
/*---------------------------------------------------------------------*/
Function EICLP401(xRotAuto,nOpcAuto)

Local aArea       := GetArea()
Local aAreaEKO    := EKO->(GetArea())
Local aCores      := {}
Local nX
Private cTitulo   := OemToAnsi(STR0001) //"Manutenção de LPCO"
Private lFormAuto := ValType(xRotAuto) == "A" .And. ValType(nOpcAuto) == "N"
Private aRotAuto  := iif( lFormAuto, aclone(xRotAuto) , nil )
Private aRotina   := MenuDef()
Private oBrowse
Private oBufSeqEK := tHashMap():New()
Private oPOUI
Private cHashPOUI := ""

aCores := {	{"EKO_INTEGR == '1' ","BR_VERDE"	   ,STR0002	},; //"Integrado"
            {"EKO_INTEGR == '2' ","BR_VERMELHO"	,STR0003	}}	 //"Não Integrado"

If !lFormAuto 
   oBrowse := FWMBrowse():New()
   oBrowse:SetAlias("EKO")
   oBrowse:SetMenudef("EICLP401")
   oBrowse:SetDescription(STR0001) //"Manutenção de LPCO"

   //Adiciona a legenda
   For nX := 1 To Len( aCores )   	    
      oBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
   Next nX

   //Habilita a exibição de visões e gráficos
   oBrowse:SetAttach( .T. )
   //Configura as visões padrão
   oBrowse:SetViewsDefault(LP401GetVs())
   oBrowse:CIDVIEWDEFAULT := "1" //View "1-Ativo"
   oBrowse:Activate()
Else
   FWMVCRotAuto(ModelDef(),"EKO",nOpcAuto,{{"EKOMASTER",xRotAuto}})
EndIf

RestArea(aAreaEKO)
RestArea( aArea )

Return Nil

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Menu com as rotinas                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
   Local aRot := {}

   ADD OPTION aRot TITLE STR0013 ACTION 'AxPesqui'           OPERATION 1                      ACCESS 0 //OPERATION 1 //'Pesquisar'
   ADD OPTION aRot TITLE STR0014 ACTION 'VIEWDEF.EICLP401'   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2 //'Visualizar'
   ADD OPTION aRot TITLE STR0015 ACTION 'VIEWDEF.EICLP401'   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3 //'Incluir' 
   ADD OPTION aRot TITLE STR0016 ACTION 'VIEWDEF.EICLP401'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4 //'Alterar'
   ADD OPTION aRot TITLE STR0017 ACTION 'VIEWDEF.EICLP401'   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 //'Excluir'
   ADD OPTION aRot TITLE STR0019 ACTION 'LP401Legen'         OPERATION 6                      ACCESS 0 //OPERATION 5 //'Legenda'

Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 Static Function ModelDef()

    //Criação do objeto do modelo de dados
    Local oModel    := Nil
    Local bCancel   := { || LP401CANCE("MODEL")}
    Local bPost     := {|oModel| LP401VALID("MODEL_POS") }
    Local bCommit   := {|oModel| LP401Commit(oModel) }
    Local oStEKO    := FWFormSTRuct(1, "EKO")
    Local oStEKP    := FWFormSTRuct(1, "EKP")
    Local bCodBlock := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| lineGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
    Local oMdlEvent := LP401Event():New()
    
    aRelEKP := {{"EKP_FILIAL","EKO_FILIAL"},;
                {"EKP_ID"    ,"EKO_ID"    },;
                {"EKP_VERSAO","EKO_VERSAO"}}

    oModel := MPFormModel():New("EICLP401",/*bPreV*/, bPost ,bCommit,bCancel)
    oModel:AddFields("EKOMASTER",/*cOwner*/ ,oStEKO )
    oModel:SetPrimaryKey({'EKO_FILIAL','EKO_ID','EKO_VERSAO'})
    oModel:AddGrid( "EKPDETAIL","EKOMASTER",oStEKP, bCodBlock )
    oModel:SetRelation("EKPDETAIL",aRelEKP, EKP->(IndexKey(1)))
    oModel:SetDescription(STR0004)                       
    oModel:GetModel("EKOMASTER"):SetDescription(STR0006) //"Dados da LPCO"
    oModel:GetModel("EKPDETAIL"):SetDescription(STR0005) //"Detalhes LPCO"
    oModel:GetModel("EKPDETAIL"):SetOptional( .T. )

    oModel:InstallEvent("LP401Event", , oMdlEvent)

Return oModel

/*---------------------------------------------------------------------*
 | Func:  lineGrid                                                     |
 | Autor: Miguel Prado                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Carregamento da linha do gridModel com dados chave.          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
function lineGrid(oMdl_EKP, nLine, cAction, cIDField, xValue, xCurrentValue)
   Local lRet := .T.
   Local oMdl := FWModelActive()
   Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")

      if oMdl_EKP:IsInserted()
         oMdl_EKP:LoadValue( "EKP_FILIAL" , xFilial("EKP") )
         oMdl_EKP:LoadValue( "EKP_ID"     , oMdl_EKO:GetValue("EKO_ID" )     ) 
         oMdl_EKP:LoadValue( "EKP_VERSAO" , oMdl_EKO:GetValue("EKO_VERSAO" ) )
      endif

return lRet

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ViewDef()

    Local oModel := FWLoadModel("EICLP401")
    Local oStEKO := FWFormSTRuct(2, "EKO")  
    Local oStEKP := FWFormSTRuct(2, "EKP")  
    Local oView := Nil
    Local oPanel

    oStEKP := SetRemove(oStEKP,{"EKP_ID", "EKP_VERSAO"})
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_EKO", oStEKO, "EKOMASTER")
    oView:AddOtherObject("VIEW_EKP", {|oPanel,oView| GetFormPOUI(oPanel,oView, 1)},{|oPanel,oView| GetFormPOUI(oPanel,oView, 2)},{|oPanel,oView| GetFormPOUI(oPanel,oView, 3)})
    oView:CreateHorizontalBox( 'ACIMA' , 50 )
    oView:CreateHorizontalBox( 'ABAIXO', 50 )
    oView:SetOwnerView("VIEW_EKO","ACIMA" )
    oView:SetOwnerView("VIEW_EKP","ABAIXO")
    oModel:GetModel("EKOMASTER"):SetDescription(STR0006) //"Dados da LPCO"
    oModel:GetModel("EKPDETAIL"):SetDescription(STR0007) //"Detalhes da LPCO - Dados do Formulário"
    oView:EnableTitleView('VIEW_EKO', STR0006 )
    oView:EnableTitleView('VIEW_EKP', STR0007 )

Return oView

/*---------------------------------------------------------------------*
 | Func:  LP401GetVs                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Montar e retornar as visões Default do Browse                |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function LP401GetVs()
Local aVisions    := {}
Local aColunas    := AvGetCpBrw("EKO")
Local aContextos  := {"ATIVOS","TODOS","INTEGRADOS", "NAO_INTEGRADOS"}
Local cFiltro     := ""
Local oDSView
Local i

   If aScan(aColunas, "EKO_FILIAL") == 0
      aAdd(aColunas, "EKO_FILIAL")
   EndIf

   For i := 1 To Len(aContextos)
      cFiltro := LP401GetFt(aContextos[i])            
      oDSView    := FWDSView():New()
      oDSView:SetName(AllTrim(Str(i)) + "-" + LP401GetFt(aContextos[i], .T.))
      oDSView:SetPublic(.T.)
      oDSView:SetCollumns(aColunas)
      oDSView:SetOrder(1)
      oDSView:AddFilter(AllTrim(Str(i)) + "-" + LP401GetFt(aContextos[i], .T.), cFiltro)
      oDSView:SetID(AllTrim(Str(i)))
      oDsView:SetLegend(.T.)
      aAdd(aVisions, oDSView)
   Next

Return aVisions

/*---------------------------------------------------------------------------------------------------------*
 | Func:  LP401GetFt                                                                                       |
 | Autor: Nilson César                                                                                     |
 | Data:  04/11/2020                                                                                       |
 | Desc:  Retorna a chave ou nome do filtro da tabela EKO de acordo com o contexto desejado                |
 | Obs.:  /                                                                                                |
 *--------------------------------------------------------------------------------------------------------*/
Static Function LP401GetFt(cTipo, lNome)
Local cRet     := ""
Default lNome  := .F.

   Do Case
      Case cTipo == "ATIVOS" .And. !lNome
         cRet := "EKO->EKO_ATIVO = '1' "
      Case cTipo == "ATIVOS" .And. lNome
         cRet := STR0008 //"Ativos"

      Case cTipo == "TODOS" .And. !lNome
         cRet := "AllwaysTrue() "
      Case cTipo == "TODOS" .And. lNome
         cRet := STR0009 //"Todos"

      Case cTipo == "INTEGRADOS" .And. !lNome
         cRet := "EKO->EKO_INTEGR = '1' "
      Case cTipo == "INTEGRADOS" .And. lNome
         cRet := STR0010 //"Integrados"

      Case cTipo == "NAO_INTEGRADOS" .And. !lNome
         cRet := "EKO->EKO_INTEGR = '2' "
      Case cTipo == "NAO_INTEGRADOS" .And. lNome
         cRet := STR0011 //"Não integrados"
   EndCase

Return cRet

/*---------------------------------------------------------------------*
 | Func:  LP401Legen                                                   |
 | Autor: Nilson César                                                 |
 | Data:  28/08/2020                                                   |
 | Desc:  Retorna a tela de Legendas                                   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401Legen()
Local aCores := {}

   aCores := {	{"BR_VERDE"   ,STR0002	},; //"Integrado"
               {"BR_VERMELHO",STR0003	}}	 //"Não Integrado"

   BrwLegenda(STR0001,"Legenda",aCores)

Return .T.

/*---------------------------------------------------------------------*
 | Func:  LP401Commit                                                  |
 | Autor: Nilson César                                                 |
 | Data:  28/08/2020                                                   |
 | Desc:  função de commit de capa/detalhe (EKO/EKP)                   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401Commit(oModel)
Local oMdl := FWModelActive()
Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")
Local lSeek, lRet := .T.

If lRet

   Begin Transaction

      FWFormCommit( oModel )

      If EKO->(Eof()) .Or. EKO->EKO_ID <> oMdl_EKO:GetValue("EKO_ID" ) .Or. EKO->EKO_VERSAO <> oMdl_EKO:GetValue("EKO_VERSAO" )
         EKO->( DbSetOrder(1) )
         lSeek := EKO->(DbSeek( xFilial("EKO") + oMdl_EKO:GetValue("EKO_ID" ) + oMdl_EKO:GetValue("EKO_VERSAO" ) ))
      Else
         lSeek := .T.
      EndIf

      If lSeek
         EKO->(RecLock("EKO",.F.))
         EKO->EKO_DATACR := dDataBase
         EKO->EKO_HORACR := SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)+SUBSTR(TIME(), 7, 2) //Hora(s) + Minuto(s)
         EKO->(MsUnlock())
      EndIf

      If InTransaction() .And. !lSeek
         DisarmTransaction()
         lRet := .F.
      EndIf

   End Transaction

EndIf

Return lRet

/*---------------------------------------------------------------------*
 | Func:  LP401CANCE                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Validação e execução antes do carregamento do modelo em tela |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401CANCE(cVar)
Local lRet := .T.
   If cVar == 'MODEL'
      //Limpa o ojeto das sequências para reapuração
      If IsMemVar("oBufSeqEK")
         oBufSeqEK:Clean()
      EndIf
   EndIf
Return lRet

/*---------------------------------------------------------------------*
 | Func:  LP401VALID                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Validação de campos                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401VALID(cCpo)
Local lRet := .T.
Local oMdl := FWModelActive()
Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")

Do Case
   //CAPA
   Case cCpo == 'EKO_ID'
      lRet := ExistChav( "EKO", oMdl_EKO:GetValue("EKO_ID" )+oMdl_EKO:GetValue("EKO_VERSAO" ) )

   Case cCpo == 'EKO_VERSAO'
      lRet := ExistChav( "EKO", oMdl_EKO:GetValue("EKO_ID" )+oMdl_EKO:GetValue("EKO_VERSAO" ) )

   Case cCpo == 'EKO_LPCO'
      lRet := .T.

   Case cCpo == 'EKO_ATIVO'
      lRet := oMdl_EKO:GetValue("EKO_ATIVO" ) $ "1|2"

   Case cCpo == 'EKO_ORGANU'
      lRet := ExistCpo( "SJJ", oMdl_EKO:GetValue("EKO_ORGANU" ))

   Case cCpo == 'EKO_FRMLPC'
      lRet := ExistCpo( "EKL", oMdl_EKO:GetValue("EKO_ORGANU" )+oMdl_EKO:GetValue("EKO_FRMLPC" ))
      If lRet
         lRet := HasJsForm(oMdl_EKO:GetValue("EKO_ORGANU" ),oMdl_EKO:GetValue("EKO_FRMLPC" ))
      EndIf

   Case cCpo == 'EKO_MODAL'
      lRet := oMdl_EKO:GetValue("EKO_MODAL" ) $ "1|2"

   Case cCpo == 'EKO_INTEGR'
      lRet := oMdl_EKO:GetValue("EKO_INTEGR" ) $ "1|2"

   Case cCpo == 'EKP_SQCPOF'
      lRet := .T.

   Case cCpo == 'EKP_CDCPOF'
      lRet := .T.

   Case cCpo == 'MODEL_POS'
      lRet := ExistCpo( "SJJ", oMdl_EKO:GetValue("EKO_ORGANU" ))
      If !Empty( oMdl_EKO:GetValue("EKO_FRMLPC" ) )
         lRet := ExistCpo( "EKL", oMdl_EKO:GetValue("EKO_ORGANU" )+oMdl_EKO:GetValue("EKO_FRMLPC" ))
      EndIf

End Case

Return lRet

/*---------------------------------------------------------------------*
 | Func:  LP401CONDT                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Condição para execução de Gatilho de campos                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401CONDT(cCpo)
Local oMdl := FWModelActive()
Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")
Local lValue := .F.

Do Case
   Case cCpo == 'EKO_FRMLPC'
      lValue := !Empty(oMdl_EKO:GetValue("EKO_FRMLPC" ))

End Case

Return lValue

/*---------------------------------------------------------------------*
 | Func:  LP401TRIGG                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Gatilho de campos                                            |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401TRIGG(cCpo)
Local oMdl := FWModelActive()
Local oView := FWViewActive()
Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")
Local xValue

Do Case

   Case cCpo == 'EKO_FRMLPC' //=>> 'EKO_MODAL'
      oMdl_EKO:LoadValue( "EKO_FILIAL" , xFilial("EKO") )
      xValue := If(LEFT(oMdl_EKO:GetValue("EKO_FRMLPC" ),1)=="I","1","2")
      oView:Refresh()

End Case

Return xValue

/*---------------------------------------------------------------------*
 | Func:  LP401WHEN                                                    |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Habilita/Desabilita alteração de campos                      |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401WHEN(cCpo)
Local oMdl := FWModelActive()
Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")
// Local oMdl_EKP := oMdl:GetModel():GetModel("EKPDETAIL")
Local lRet := .T.
Local aEKOWHEN

   aEKOWHEN := {"EKO_MODAL","EKO_DATACR","EKO_HORACR","EKO_DATARG", "EKO_HORARG"}

   If oMdl:GetOperation() <> 3
      If !Empty(oMdl_EKO:GetValue("EKO_ID" ))
         aAdd(aEKOWHEN,"EKO_ID")
      EndIf
      If !Empty(oMdl_EKO:GetValue("EKO_VERSAO" ))
         aAdd(aEKOWHEN,"EKO_VERSAO")
      EndIf
      If !Empty(oMdl_EKO:GetValue("EKO_ORGANU" ))
         aAdd(aEKOWHEN,"EKO_ORGANU")
      Endif
      If !Empty(oMdl_EKO:GetValue("EKO_FRMLPC" ))
         aAdd(aEKOWHEN,"EKO_FRMLPC")
      EndIf
   EndIf

   If aScan( aEKOWHEN , cCpo ) > 0
      lRet := .F.
   EndIf   

Return lRet

/*---------------------------------------------------------------------*
 | Func:  SetRemove                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Remover da estrutura campos que não devem ser exibidos       |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function SetRemove(oStruct,aCampos)
Local i := 0

For i := 1 To Len(aCampos)
   oStruct:RemoveField(aCampos[i])
Next

Return oStruct

/*---------------------------------------------------------------------*
 | Func:  LP401LOADV                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Carregar valores para determinados campos, como os virtuais  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401LOADV(cCpo)
Local oMdl := FWModelActive()
Local oMdl_EKO := oMdl:GetModel("EKOMASTER")
Local oMdl_EKP := oMdl:GetModel("EKPDETAIL")
Local cValue   := ""


   Do Case
      Case cCpo == 'EKP_ID'
         oMdl_EKP:LoadValue( "EKP_FILIAL" , xFilial("EKP") )
         oMdl_EKP:LoadValue( "EKP_ID"     , oMdl_EKO:GetValue("EKO_ID" )     )
         oMdl_EKP:LoadValue( "EKP_VERSAO" , oMdl_EKO:GetValue("EKO_VERSAO" ) )
      Case cCpo == 'EKO_ID'
         cValue := NextSeqEK("EKO_ID")
      Case cCpo == 'EKO_VERSAO'
         cValue := NextSeqEK("EKO_VERSAO")
      Case cCpo == 'EKO_MODAL' .And. ValType(oMdl_EKO) == "O" .And. oMdl:GetOperation() <> 3
         cValue := If(LEFT(oMdl_EKO:GetValue("EKO_FRMLPC"),1)=="I","1","2")
      Case cCpo == 'EKO_ATIVO'
         cValue := "1"
      Case cCpo == 'EKO_INTEGR'
         cValue := "2"
   EndCase

Return cValue

/*---------------------------------------------------------------------*
 | Func:  LP401GCBOX                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Retornar conteúdo paa campos Combobox                        |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401GCBOX(cCpo)
Local cValue   := ""

   Do Case
      Case cCpo == 'EKO_ATIVO'
         cValue := "1=Sim;2=Não"
      Case cCpo == 'EKO_MODAL'
         cValue := "1=Importação;2=Exportação"
      Case cCpo == 'EKO_INTEGR'
         cValue := "1=Sim;2=Não"
   End Case

Return cValue

/*---------------------------------------------------------------------*
 | Func:  PesqModEKP                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Encontrar entre os detalhes algum que atenda a condição      |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function PesqModEKP(oMdl_EKP,bCond,nPosAtu,cValue)
Local i, aRet := {.F.,0}

Begin Sequence
If oMdl_EKP:GetQtdLine() > 0
   For i:=1 To oMdl_EKP:GetQtdLine()
      oMdl_EKP:GoLine(i)
      If Eval(bCond)
         aRet := {.T.,i}
         Break
      EndIf
   Next i
EndIf
End Sequence

Return aRet

/*---------------------------------------------------------------------*
 | Func:  NextSeqEK                                                    |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Buscar próxima sequência dos campos sequenciais do modelo    |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function NextSeqEK(cCpo)
Local cLastSeq := "000"
Local cAlias   := Left(cCpo,3)
Local oMdl     := FWModelActive()
Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")
// Local oMdl_EKP := oMdl:GetModel():GetModel("EKPDETAIL")
Local cQryMax  := cQryWhere := cQryTab := ""
Local nOldArea, cAliasQry
local cChaveHash := ""

   If !IsMemVar("oBufSeqEK") .Or. oBufSeqEK == Nil
      oBufSeqEK:= tHashMap():New()
   EndIf

   cChaveHash := cCpo
   do case
      case cCpo == "EKO_ID"
         cChaveHash := cCpo + alltrim(xFilial("EKO")) 
      case cCpo == "EKO_VERSAO"
         cChaveHash := cCpo + alltrim(xFilial("EKO"))  + alltrim(oMdl_EKO:GetValue("EKO_ID" ))
   endcase

   If !oBufSeqEK:Get(cChaveHash, @cLastSeq)

      Do Case
         Case cCpo == "EKO_ID"
            cQryMax   := "% MAX(EKO_ID) LASTSEQ %"
            cQryWhere := "% EKO_FILIAL = '"+xFilial("EKO")+"' %" 
         Case cCpo == "EKO_VERSAO"
            cQryMax   := "% MAX(EKO_VERSAO) LASTSEQ %"
            cQryWhere := "% EKO_FILIAL = '"+xFilial("EKO")+"' AND EKO_ID = '"+oMdl_EKO:GetValue("EKO_ID" )+"' %"
         Case cCpo == "EKP_SQCPOF" 
            cQryMax   := "% MAX(EKP_SQCPOF) LASTSEQ %"
            cQryWhere := "% EKP_FILIAL = '"+xFilial("EKP")+"' AND EKP_ID = '"+oMdl_EKO:GetValue("EKO_ID" )+"' AND EKP_VERSAO = '"+oMdl_EKO:GetValue("EKO_VERSAO" )+"' %"
      End Case
      cQryTab   := "% "+RetSQLName(cAlias)+" %"

      nOldArea  := Select()
      cAliasQry := GetNextAlias()
      BeginSQL Alias cAliasQry
         SELECT %Exp:cQryMax% 
         FROM   %Exp:cQryTab%
         WHERE  %Exp:cQryWhere%
         AND    D_E_L_E_T_ = ' ' //%Exp:cAlias%.%NotDel% 
      EndSql
      If (cAliasQry)->(!Eof()) .And. (cAliasQry)->(!Bof())
         cLastSeq := (cAliasQry)->LASTSEQ
      EndIf
      (cAliasQry)->(DBCloseArea())
      If( nOldArea > 0 , DbSelectArea(nOldArea) , ) 
      
   EndIf

   cLastSeq := Soma1(cLastSeq) 
   oBufSeqEK:Set(cChaveHash, cLastSeq)

Return cLastSeq

/*---------------------------------------------------------------------*
 | Func:  GetFormPOUI                                                  |
 | Autor: Nilson César                                                 |
 | Data:  29/01/2021                                                   |
 | Desc:  Cria uma instância de tela baseado em componentes do PO-UI no|
 |        objeto passado como parâmetro, utilizando as definições de   |
 |        campos contidas no .json do formulário LPCO informado na tela|
 |        de manutenção.                                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function GetFormPOUI(oPanel,oView, nOpc)

Local cKeyForm
Local oDataForm
Local cOrgAnu   := ""
Local cFormLPCO := ""
local lActivate := .F.
local lRet := .F.

if nOpc == 1 .and. (!IsMemVar("oPOUI") .or. oPOUI == nil) // activate
   oPOUI := EasyPOUI():New(oPanel)
   lActivate := .T.
elseif nOpc == 3 // refresh
   aSize(oPOUI:oForm['listFields'], 0 )
   oPOUI:oForm['listFields'] := {}
elseif nOpc == 2 // deactivate
   fwFreeObj(oPOUI)
EndIf

if nOpc == 1 .or. nOpc == 3
   cOrgAnu := oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_ORGANU")
   cFormLPCO := oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_FRMLPC")
   oPOUI:oEasyJS:SetTimeOut(10)
   If !lActivate .or. oPOUI:oEasyJS:Activate(.T.)

      If !Empty( cOrgAnu ) .And. !Empty( cFormLPCO )

         cKeyForm := oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_ORGANU") + oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_FRMLPC")
         SetCapaLPCO(oPOUI,cKeyForm)
         SetDataLPCO(oPOUI,cKeyForm)

         oPOUI:oEasyJS:runJSsync('AppComponent.sendAlertExibe("' + STR0031 + '",true); retAdvpl("ok")',{|x| lRet := alltrim(upper(x)) == "OK"}) // 'Carregando formulário'
         oPOUI:oEasyJS:runJS('AppComponent.loadMasterByConsole('+oPOUI:oForm:ToJSON()+'); AppComponent.sendAlertEsconde(); retAdvpl("ok")',{|x| lRet := alltrim(upper(x)) == "OK"})

         // Bloco de execução específico para a automação de testes Protheus.
         If(EXISTBLOCK("EASYPOUI") .And. FindFunction('GetObjAutt') .And. ValType( oEasyAutTt := GetObjAutt() ) == "O" .And. ( oEasyAutTt:lRecord .Or. oEasyAutTt:lExecute ), EXECBLOCK("EASYPOUI",.F.,.F.,{"ACTIVATE",Self}), )  

         oDataForm := oPOUI:GetData()
         cHashPOUI := MD5( oDataForm:ToJSON() )

      Else

         oPOUI:oEasyJS:runJS('AppComponent.sendAlertExibe("' + STR0032 + '",false); retAdvpl("ok")',{|| lRet := .T.}) // 'Aguard. seleção do formulário'

      EndIf

   endif

endif

return

/*---------------------------------------------------------------------*
 | Func:  GetJsonLPCO                                                  |
 | Autor: Nilson César                                                 |
 | Data:  29/01/2021                                                   |
 | Desc:  Cria uma instância de tela baseado em componentes do PO-UI no|
 |        objeto passado como parâmetro, utilizando as definições de   |
 |        campos contidas no .json do formulário LPCO cadastrado no    |
 |         sistema e passado como parâmetro                            |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function GetJsonLPCO(cChaveFrm)

Local cTextJson
Local oJson := Nil

EKL->(DbSetOrder(1))
If EKL->(DbSeek(xFilial("EKL")+cChaveFrm))
   cTextJson := EKL->EKL_FORMJS
   oJson := JsonObject():New()
   If ValType( ret := oJson:FromJson(cTextJson) ) == "C"
      oJson := Nil
   EndIf
EndIf

Return oJson

/*---------------------------------------------------------------------*
 | Func:  SetCapaLPCO                                                  |
 | Autor: Nilson César                                                 |
 | Data:  29/01/2021                                                   |
 | Desc:  Popula o json do PO-UI atribuindo aos campos as definições   |
 |        conforme os atributos dos campos do json oficial do LPCO dis-|
 |        ponibilizado pelo Portal único siscomex e carregado no cadas-|
 |        tro do sistema.                                              |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function SetCapaLPCO(oPOUI,cKeyForm)

Local oJsonFRM, oCampo, oDePara
Local i,j
Local oView := FWViewActive()
oJsonFRM := GetJsonLPCO(cKeyForm)
oDePara  := JsonObject():New()
oDePara:fromJSON('{"types": {"NUMERO_INTEIRO": "number","NUMERO_REAL": "number","VALOR_MONETARIO": "currency","VALOR_COM_UNIDADE_MEDIDA": "number","TEXTO": "string","LISTA": "options","BOOLEANO": "boolean","DATA": "date","CRONOGRAMA": "string"}}')

Begin Sequence

   For i:=1 To Len(oJsonFRM["listaCamposFormulario"])

      oCampo  := JsonObject():New()
      oCampo['property']      :=  oJsonFRM["listaCamposFormulario"][i]["codigo"]
      oCampo['label'   ]      :=  oJsonFRM["listaCamposFormulario"][i]["nome"  ]
      If oJsonFRM["listaCamposFormulario"][i]["tipo"] == 'LISTA'
         oCampo['options'] := {}
         For j:=1 To Len(oJsonFRM["listaCamposFormulario"][i]["validacao"]["dominios"])
            Aadd(oCampo['options'],JsonObject():new())
            nPos := Len(oCampo['options'])
            oCampo['options'][nPos]['label' ] := oJsonFRM["listaCamposFormulario"][i]["validacao"]["dominios"][j]['descricao'] 
            oCampo['options'][nPos]['value' ] := oJsonFRM["listaCamposFormulario"][i]["validacao"]["dominios"][j]['id'       ]
         Next j 
         oCampo['optionsMulti'] := oJsonFRM["listaCamposFormulario"][i]["validacao"]["permiteMultiplosValores"]
      Else
         oCampo['type']          :=  oDePara['types'][oJsonFRM["listaCamposFormulario"][i]["tipo"]]
         If oCampo['type'] == "boolean"
            oCampo['booleanFalse'] := "Não"
            oCampo['booleanTrue']  := "Sim"
         EndIf
      EndIf
      oCampo['order']         :=  i
      oCampo['required']      :=  oJsonFRM["listaCamposFormulario"][i]["validacao"]["obrigatorio"]
      oCampo['optional']      := !oJsonFRM["listaCamposFormulario"][i]["validacao"]["obrigatorio"]
      oCampo['maxLength']     :=  oJsonFRM["listaCamposFormulario"][i]["validacao"]["tamanhoMaximo"]
      oCampo['mask']          :=  oJsonFRM["listaCamposFormulario"][i]["validacao"]["mascara"]
      oCampo['gridColumns']   := 6
      oCampo['gridSmColumns'] := 12
      //oCampo['value']       := ""

      If oJsonFRM["listaCamposFormulario"][i]["tipo"] == 'VALOR_MONETARIO'
         oCampo['decimalsLength'] := oJsonFRM["listaCamposFormulario"][i]["validacao"]["qtdCasasDecimais"]
      EndIf

      If oJsonFRM["listaCamposFormulario"][i]["tipo"] == "DATA"
         oCampo["format"]     := "dd/mm/yyyy"
      EndIf

      If oView:GetModel():GetOperation() == MODEL_OPERATION_DELETE .Or. oView:GetModel():GetOperation() == MODEL_OPERATION_VIEW
         oCampo["disabled"] := .T.
      EndIf

      oPOUI:SetField(oCampo)
      FreeObj(oCampo)

   Next i

End Sequence

FreeObj(oDePara)

return oPOUI

/*---------------------------------------------------------------------*
 | Func:  SetDataLPCO                                                  |
 | Autor: Nilson César                                                 |
 | Data:  05/02/2021                                                   |
 | Desc:  Carrega nos campos do objeto PO-UI os dados salvo na base de |
 |        dados em manutenção de inclusão/alteração anterior           |
 | Obs.:  Implementado apenas o carregamento dos campos de capa do mo- |
 |        delo ('listaCamposFormulario')                               |
 *---------------------------------------------------------------------*/
Static Function SetDataLPCO(oPOUI,cKeyForm)

Local oView     := FWViewActive()
Local oMdlDtLPCO:= oView:GetModel():GetModel("EKPDETAIL")
Local lRegEKP   := oMdlDtLPCO:GetQtdLine() > 0 .And. oMdlDtLPCO:GetOperation() <> 3
Local oDePara   := JsonObject():New()
Local i, nPosField

If lRegEKP
   oDePara:fromJSON('{"types": {"number": "Val(xRet)","currency": "Val(xRet)","string": "xRet","boolean": "xRet","date": "cToD(xRet)" }}')
   For i := 1 To oMdlDtLPCO:GetQtdLine()
      oMdlDtLPCO:GoLine(i)

      //Atribuição dos valores de Capa
      If Alltrim(oMdlDtLPCO:GetValue('EKP_IDCPOF')) == 'listaCamposFormulario'
         nPosField := asCan(oPOUI:oForm['listFields'], {|x| x['property'] == Alltrim(oMdlDtLPCO:GetValue('EKP_CDCPOF')) })
         xRet := oMdlDtLPCO:GetValue('EKP_VLCPOF')
         If Valtype(oPOUI:oForm['listFields'][nPosField]['type']) == "C"                //Valores únicos
            xRet := &(oDePara["types"][oPOUI:oForm['listFields'][nPosField]['type']])
            oPOUI:oForm['listFields'][nPosField]['value'] := xRet 
         ElseIf Valtype(oPOUI:oForm['listFields'][nPosField]['options']) == "A"         //Lista de valores
            xRet   := &(oDePara["types"]['string'])
            If oPOUI:oForm['listFields'][nPosField]['optionsMulti']
               If Valtype(oPOUI:oForm['listFields'][nPosField]['value']) == 'A'
                  aAdd(oPOUI:oForm['listFields'][nPosField]['value'],xRet)
               Else
                  oPOUI:oForm['listFields'][nPosField]['value'] := {xret}
               EndIf
            Else
               oPOUI:oForm['listFields'][nPosField]['value'] := xret
            EndIf             
         EndIf        
      EndIf

      //Atribuição dos valores de Itens(implementação futura)
      //If oMdlDtLPCO:GetValue('EKL_IDCPOF') == 'listaCamposNcm'    
      //EndIf
   Next i
EndIf

FreeObj(oDePara)

cPOUIJson := StrTran( oPOUI:oForm:ToJson() , '".T."' , 'true' )
cPOUIJson := StrTran( cPOUIJson , '".F."' , 'false' )
oPOUI:oForm:FromJson(cPOUIJson)

oView:GetModel():lModify := .T.
oMdlDtLPCO:lUpdateLine := .T.

Return oPOUI

/*---------------------------------------------------------------------*
 | Func:  GrvModPOUI                                                   |
 | Autor: Nilson César                                                 |
 | Data:  29/01/2021                                                   |
 | Desc:  Grava o modelo MVC conforme os campos carregados no formulá- |
 |        rio PO-UI.                                                   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function GrvModPOUI()

Local jDataEKP := oPOUI:GetData()
Local oView    := FWViewActive()
Local oMdl     := FWModelActive()
Local oMdl_EKO := oMdl:GetModel("EKOMASTER")
Local oMdl_EKP := oMdl:GetModel("EKPDETAIL")
Local cKeyForm := oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_ORGANU") + oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_FRMLPC")
Local oJsonFRM := GetJsonLPCO(cKeyForm)
Local nLinha,i,j

//Limpa todas as linhas do model 
For nLinha:=1 To oMdl_EKP:Length()
   oMdl_EKP:GoLine(nLinha)
   oMdl_EKP:DeleteLine()
Next nLinha

//Preecnhe com os dados do Json
For i:=1 To Len(oJsonFRM["listaCamposFormulario"])
   If ValType( jDataEKP[oJsonFRM["listaCamposFormulario"][i]["codigo"]] ) == "A" // Campos tipo combobox (lista) com múltipla seleção.
      For j:=1 To Len(jDataEKP[oJsonFRM["listaCamposFormulario"][i]["codigo"]])
         ForceAddLine(oMdl_EKP)
         oMdl_EKP:LoadValue( "EKP_FILIAL" , xFilial("EKP") )
         oMdl_EKP:LoadValue( "EKP_ID"     , oMdl_EKO:GetValue("EKO_ID" )     ) 
         oMdl_EKP:LoadValue( "EKP_VERSAO" , oMdl_EKO:GetValue("EKO_VERSAO" ) )
         oMdl_EKP:SetValue(  "EKP_IDCPOF" , "listaCamposFormulario" )
         oMdl_EKP:SetValue(  "EKP_CDCPOF" , oJsonFRM["listaCamposFormulario"][i]["codigo"] ) 
         oMdl_EKP:SetValue(  "EKP_VLCPOF" , cValToChar( jDataEKP[oJsonFRM["listaCamposFormulario"][i]["codigo"]][j] ) )        
      Next j
   Else
      ForceAddLine(oMdl_EKP)
      oMdl_EKP:LoadValue( "EKP_FILIAL" , xFilial("EKP") )
      oMdl_EKP:LoadValue( "EKP_ID"     , oMdl_EKO:GetValue("EKO_ID" )     ) 
      oMdl_EKP:LoadValue( "EKP_VERSAO" , oMdl_EKO:GetValue("EKO_VERSAO" ) )
      oMdl_EKP:SetValue(  "EKP_IDCPOF" , "listaCamposFormulario" )
      oMdl_EKP:SetValue(  "EKP_CDCPOF" , oJsonFRM["listaCamposFormulario"][i]["codigo"] ) 
      oMdl_EKP:SetValue(  "EKP_VLCPOF" , cValToChar( jDataEKP[oJsonFRM["listaCamposFormulario"][i]["codigo"]] ) )
   EndIf
Next i

Return

/*---------------------------------------------------------------------*
 | Func:  ForceAddLine                                                 |
 | Autor: Nilson César                                                 |
 | Data:  29/01/2021                                                   |
 | Desc:  Força a inclusão de nova linha no modelo MVC                 |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ForceAddLine(oModelGrid)
Local lDel := .F.

If oModelGrid:Length() >= oModelGrid:AddLine()
   oModelGrid:GoLine(1)
   If !oModelGrid:IsDeleted()
      oModelGrid:DeleteLine()
      lDel := .T.
   EndIf
   oModelGrid:AddLine()
   oModelGrid:GoLine(1)
   If lDel
      oModelGrid:UnDeleteLine()
   EndIf
   oModelGrid:GoLine(oModelGrid:Length())
EndIf

Return .T.

/*---------------------------------------------------------------------*
 | Func:  LP401BTNOK                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Validação própria da rotina ao clicar no botão 'Confirmar'   |
 |        antes de commitar o modelo.                                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401BTNOK(cVar,oModel,cModelId)

Local lRet := .T.
Local cHashPOUIF := ""
Local oView := FWViewActive()
Local oMdl_EKO := oView:GetModel("EKOMASTER")
Local oMdl_EKP := oView:GetModel("EKPDETAIL")

Begin Sequence 
If cVar == "VIEW"
   If isMemVar("oPOUI") .And. (cHashPOUIF := MD5( oPOUI:GetData():ToJSON() ) ) <> cHashPOUI 
      If !ValCposPOUI(oPOUI:GetData())
         MsgStop(STR0029) //"Existem campos com valor inválido no formulário! Revise os campos destacados em vermelho!"
         lRet := .F.
         Break
      Else
         GrvModPOUI()
      EndIf
   Else
      If oView:GetModel():GetOperation() == MODEL_OPERATION_UPDATE .And. !oMdl_EKO:IsModified()
         MsgInfo(STR0024) //"Não foi detectada nenhuma alteração nos dados da LPCO, capa ou detalhes do formulário!"
         lRet := .F.
         Break
      EndIf
   EndIf

ElseIf cVar == "MODEL"
   If oView:GetModel():GetOperation() == MODEL_OPERATION_INSERT
      If isMemVar("oPOUI") .And. (cHashPOUIF := MD5( oPOUI:GetData():ToJSON() ) ) <> cHashPOUI 
         If !ValCposPOUI(oPOUI:GetData())
            MsgStop(STR0029) //"Existem campos com valor inválido no formulário! Revise os campos destacados em vermelho!"
            lRet := .F.
            Break
         Else
            GrvModPOUI()
         EndIf
      EndIf 
      If oMdl_EKP:GetQtdLine() < 2
         MsgStop(STR0025) //"Não é possível gravar o registro de LPCO sem os campos do formulário carregados e informados nos detalhes!"
         lRet := .F.
         Break
      EndIf
   EndIf
EndIf
End Sequence

Return lRet

/*---------------------------------------------------------------------*
 | Func:  HasJsForm                                                    |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Validar se há modelo cadastrado para o formulário do órgão   |
 |        anuente informado e se o mesmo é válido para carregamento dos|
 |        campos no objeto PO-UI.                                      |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function HasJsForm(cOrgAnu,cFormLPCO)
Local lRet      := .F.
Local oJsonForm
Local cChaveEKL := xFilial("EKL") + cOrgAnu + cFormLPCO

   If ( EKL->( xFilial("EKL") + EKL_CODIGO + EKL_CODFOR ) == cChaveEKL )  .Or. EKL->(DbSeek(xFilial("EKL") + cOrgAnu + cFormLPCO ))
      If !Empty(EKL->EKL_FORMJS)
         oJsonForm := JsonObject():New()
         xRet := oJsonForm:FromJson(EKL->EKL_FORMJS)
         If ValType(xRet) == "C"
            MsgStop(STR0026+STR0028) //"Não foi possível carregar o modelo deste formulário! " # "Verifique o cadastro do órgão anuente deste formulário e realize a integração com o portal único siscomex para atualizar o modelo deste formulário antes de utilizá-lo novamente!"
         ElseIf oJsonFoRM["listaCamposFormulario"] == Nil .Or. Len(oJsonFoRM["listaCamposFormulario"]) == 0
            MsgStop(STR0030)//"O template disponibilizado para este formulário não possui as definições dos campos de capa para preenchimento na tela. Verifique e atualize o template na rotina de integração de formulários LPCO! (deve haver pelo ao menos uma ocorrência da palavra chave 'ListaCamposFormulario' no texto do campo 'Formul.LPCO')"
         Else
            lRet := .T.
            FreeObj(oJsonForm)
         EndIf
      Else
         MsgStop(STR0027+STR0028) //"Este formulário não possui um modelo informado! " # "Verifique o cadastro do órgão anuente deste formulário e realize a integração com o portal único siscomex para atualizar o modelo deste formulário antes de utilizá-lo novamente!"
      EndIf
   EndIf

Return lRet

/*---------------------------------------------------------------------*
 | Func:  ValCposPOUI                                                  |
 | Autor: Nilson César                                                 |
 | Data:  04/03/2021                                                   |
 | Desc:  Vericifar se existem campos com valor inválido no formulário |
 |        do PO-UI                                                     |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ValCposPOUI(jDataPOUI)
Local aCpos := jDataPOUI:GetNames()
Local i, lRet := .T.

Begin Sequence
For i := 1 To Len(aCpos)
   if ValType(jDataPOUI[aCpos[i]]) == 'C' .And. jDataPOUI[aCpos[i]] == "Valor Inválido"
      lRet := .F.
      Break
   EndIf
Next i
End Sequence

Return lRet

/*---------------------------------------------------------------------*
 | Classe:  LP401Event                                                 |
 | Autor: Nilson César                                                 |
 | Data:  04/02/2021                                                   |
 | Desc:  Classe com herança para interceptação do Commit              |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Class LP401Event FROM FWModelEvent     
   Method New()
   Method BeforeTTS()
   Method ModelPosVld()

End Class

Method New() Class LP401Event
Return

Method BeforeTTS(oModel,cModelId) Class LP401Event
   Return LP401BTNOK("VIEW",oModel,cModelId)

Method ModelPosVld(oModel,cModelId) Class LP401Event
   Return LP401BTNOK("MODEL",oModel,cModelId)




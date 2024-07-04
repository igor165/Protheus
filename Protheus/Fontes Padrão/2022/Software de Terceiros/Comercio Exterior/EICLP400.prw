#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "TOPCONN.CH"
#INCLUDE "AVERAGE.CH"
#Include 'EICLP400.CH'


#define ENTER CHR(13)+CHR(10)
/*---------------------------------------------------------------------*/
/*/{Protheus.doc} EICLP400
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
Function EICLP400(xRotAuto,nOpcAuto)

Local aArea       := GetArea()
Local aAreaEKM    := EKM->(GetArea())
Private cTitulo   := OemToAnsi(STR0001) //"NCM x Form. LPCO"
Private lFormAuto := ValType(xRotAuto) == "A" .And. ValType(nOpcAuto) == "N"
Private aRotAuto  := iif( lFormAuto, aclone(xRotAuto) , nil )
Private aRotina   := MenuDef()
Private oBrowse

If !lFormAuto 
   oBrowse := FWMBrowse():New()
   oBrowse:SetAlias("EKM")
   oBrowse:SetMenudef("EICLP400")
   oBrowse:SetDescription(STR0001)
   oBrowse:Activate()
Else
   FWMVCRotAuto(ModelDef(),"EKM",nOpcAuto,{{"EKMMASTER",xRotAuto}})
EndIf

RestArea(aAreaEKM)
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

   ADD OPTION aRot TITLE 'Pesquisar'           ACTION 'AxPesqui'           OPERATION 1                      ACCESS 0 //OPERATION 1
   ADD OPTION aRot TITLE 'Visualizar'          ACTION 'VIEWDEF.EICLP400'   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
   ADD OPTION aRot TITLE 'Incluir'             ACTION 'VIEWDEF.EICLP400'   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
   ADD OPTION aRot TITLE 'Alterar'             ACTION 'VIEWDEF.EICLP400'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
   ADD OPTION aRot TITLE 'Excluir'             ACTION 'VIEWDEF.EICLP400'   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

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
    Local bPost     := { || LP400VALID("MODEL") }
    Local bCommit   := {|oModel| LP400Commit(oModel) }
    Local oStEKM    := FWFormSTRuct(1, "EKM")
    Local oStEKN    := FWFormSTRuct(1, "EKN")
   
    aRelEKN := {{"EKN_FILIAL","EKM_FILIAL"},;
                {"EKN_ORGANU","EKM_ORGANU"},;
                {"EKN_FRMLPC","EKM_FRMLPC"},;
                {"EKN_NCM"   ,"EKM_NCM"}}

    oModel := MPFormModel():New("EICLP400",/*bPre*/, bPost ,bCommit,/*bCancel*/)
    oModel:AddFields("EKMMASTER",/*cOwner*/ ,oStEKM )
    oModel:SetPrimaryKey({'EKM_FILIAL','EKM_ORGANU','EKM_FRMLPC','EKM_NCM'})
    oModel:AddGrid(  "EKNDETAIL","EKMMASTER",oStEKN )
    oModel:SetRelation("EKNDETAIL",aRelEKN, EKN->(IndexKey(1)))
    oModel:SetDescription(STR0001)
    oModel:GetModel("EKMMASTER"):SetDescription(STR0001)
    oModel:GetModel("EKNDETAIL"):SetDescription(STR0007) //"Detalhes Formulário x N.c.m"
    oModel:GetModel("EKNDETAIL"):SetOptional( .T. )
    oModel:GetModel("EKNDETAIL"):SetUniqueLine({"EKN_FILIAL" ,"EKN_ORGANU" ,"EKN_FRMLPC","EKN_NCM" ,"EKN_COD_I"} )  //MFR 25/02/2022 OSSME-6621  

Return oModel

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ViewDef()

    Local oModel := FWLoadModel("EICLP400")
    Local oStEKM := FWFormSTRuct(2, "EKM")  
    Local oStEKN := FWFormSTRuct(2, "EKN")  
    Local oView := Nil
    //Campos que serão omitidos no view - Grid de detalhes
    oStEKN := SetRemove(oStEKN,{"EKN_ORGANU", "EKN_FRMLPC", "EKN_NCM"})
 
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_EKM", oStEKM, "EKMMASTER")
    oView:AddGrid( "VIEW_EKN", oStEKN, "EKNDETAIL")
    oView:CreateHorizontalBox( 'ACIMA' , 50 )
    oView:CreateHorizontalBox( 'ABAIXO', 50 )
    oView:SetOwnerView("VIEW_EKM","ACIMA" )
    oView:SetOwnerView("VIEW_EKN","ABAIXO")
    oModel:GetModel("EKMMASTER"):SetDescription(STR0001)
    oModel:GetModel("EKNDETAIL"):SetDescription(STR0002)
    oView:EnableTitleView('VIEW_EKM', STR0001 )
    oView:EnableTitleView('VIEW_EKN', STR0002 )
    
Return oView
/*---------------------------------------------------------------------*
 | Func:  LP400Commit                                                  |
 | Autor: Nilson César                                                 |
 | Data:  28/08/2020                                                   |
 | Desc:  função de commit de capa/detalhe (EKM/EKN)                   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP400Commit(oModel)

   FWFormCommit( oModel )

Return .t.

/*---------------------------------------------------------------------*
 | Func:  LP400VALID                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Validação de campos                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP400VALID(cCpo)
Local lRet := .T.
Local oMdl := FWModelActive()
Local oMdl_EKM := oMdl:GetModel():GetModel("EKMMASTER")
Local oMdl_EKN := oMdl:GetModel():GetModel("EKNDETAIL")

Do Case
   Case cCpo == 'EKM_ORGANU'
      lRet := ExistCpo( "SJJ", oMdl_EKM:GetValue("EKM_ORGANU" ))

   Case cCpo == 'EKM_FRMLPC'
      lRet := ExistCpo( "EKL", oMdl_EKM:GetValue("EKM_ORGANU" )+oMdl_EKM:GetValue("EKM_FRMLPC" ))

   Case cCpo == 'EKM_MODAL'
      lRet := oMdl_EKM:GetValue("EKM_MODAL" ) $ "1|2"

   Case cCpo == 'EKM_NCM'
      lRet := ExistCpo( "SYD", oMdl_EKM:GetValue("EKM_NCM" )) 
                                                  //MFR 25/02/2022 OSSME-622
      If lRet .And. (oMdl:GetOperation() == 3 .or. oMdl:GetOperation() == 4) .And. EKM->(DbSeek( xFilial("EKM") + oMdl_EKM:GetValue("EKM_ORGANU") +  oMdl_EKM:GetValue("EKM_FRMLPC" ) + oMdl_EKM:GetValue("EKM_NCM" )   ) )
         MsgStop(STR0009,STR0003) //"Já existe vinculação da n.c.m informada ao formulário atual deste órgão anuente!" # "Aviso"
         lRet := .F.
      EndIf
      //Verificar se há alguma linha no grid não deletada com associação de produto à ncm atual para não permitir modificar a n.c.m caso exista.
      If lRet .And. ( aRet := PesqModEKN(oMdl_EKN,{|| !oMdl_EKN:IsDeleted() .And. !Empty(oMdl_EKN:GetValue("EKN_NCM" )) .And. oMdl_EKN:GetValue("EKN_NCM" ) # oMdl_EKM:GetValue("EKM_NCM") }) )[1]
         MsgStop( STR0005 , STR0003 ) //"Não é possível alterar a N.c.m associada quando há um ou mais produtos já associados com esta N.c.m !" # "Aviso" 
         lRet := .F.
      EndIf

   Case cCpo == 'EKM_OBRIGA'
      lRet := Empty(oMdl_EKM:GetValue("EKM_OBRIGA" )) .Or. oMdl_EKM:GetValue("EKM_OBRIGA" ) $ "1|2"

   Case cCpo == 'EKN_ORGANU'
      lRet := ExistCpo( "SJJ", oMdl_EKN:GetValue("EKN_ORGANU" ))

   Case cCpo == 'EKN_FRMLPC'
      lRet := ExistCpo( "EKL", oMdl_EKN:GetValue("EKN_ORGANU" )+oMdl_EKN:GetValue("EKN_FRMLPC" ) )

   Case cCpo == 'EKN_NCM'
      lRet := ExistCpo( "SYD", oMdl_EKN:GetValue("EKN_NCM" ) )

   Case cCpo == 'EKN_COD_I'
      lRet := ExistCpo( "SB1", oMdl_EKN:GetValue("EKN_COD_I" ) )
      If lRet
         If !Empty(oMdl_EKM:GetValue("EKM_NCM")) .And. Posicione("SB1",1,xFilial("SB1")+ oMdl_EKN:GetValue("EKN_COD_I"),"B1_POSIPI" ) # oMdl_EKM:GetValue("EKM_NCM")
            MsgStop( STR0004 , STR0003 ) //"Produto informado possui N.c.m diferente da associada ao formulário LPCO." # "Aviso"
            lRet := .F. 
         EndIf
      EndIf

   Case cCpo == 'EKN_OBRIGA'
      lRet := Empty(oMdl_EKN:GetValue("EKN_OBRIGA" )) .Or. oMdl_EKN:GetValue("EKN_OBRIGA" ) $ "1|2"

   Case cCpo == 'MODEL'
      If oMdl:GetOperation() <> 5 //Exclusão
         If !EKL->( DbSeek( xFilial("EKL") + oMdl_EKM:GetValue("EKM_ORGANU")  + oMdl_EKM:GetValue("EKM_FRMLPC" ) ) )
            MSgStop(STR0008) //"Não existe este formulário cadastrado para o órgão anuente informado!" # "Aviso"
            lRet := .F.
         else
            If lRet .And. ( aRet := PesqModEKN(oMdl_EKN,{|| Empty(oMdl_EKN:GetValue("EKN_OBRIGA" )) .And. !Empty( oMdl_EKN:GetValue("EKN_ORGANU" ) + oMdl_EKN:GetValue("EKN_FRMLPC" ) + oMdl_EKN:GetValue("EKN_NCM" ) ) }) )[1] 
               MsgStop( StrTran(STR0010,"###",StrZero(aRet[2],3,0) ),STR0003) // "O campo 'Obrigatório?' na linha ### de registro dos produtos associados não foi definido!" # "Aviso"
               lRet := .F.
            EndIf
         EndIf
      Else
         If !Empty(oMdl_EKM:GetValue("EKM_DATA" )) .Or. !Empty(oMdl_EKM:GetValue("EKM_HORA" ))
            MsgStop( STR0006 , STR0003 ) //"Não é possível excluir registro de Formulário x Órgão Anuente integrado!" # "Aviso"
            lRet := .F.
         EndIf
      EndIf

End Case

Return lRet

/*---------------------------------------------------------------------*
 | Func:  LP400CONDT                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Condição para execução de Gatilho de campos                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP400CONDT(cCpo)
Local oMdl := FWModelActive()
Local oMdl_EKM := oMdl:GetModel():GetModel("EKMMASTER")
Local lValue := .F.

Do Case
   Case cCpo == 'EKM_FRMLPC'
      lValue := !Empty(oMdl_EKM:GetValue("EKM_FRMLPC" ))
End Case

Return lValue

/*---------------------------------------------------------------------*
 | Func:  LP400TRIGG                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Gatilho de campos                                            |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP400TRIGG(cCpo)
Local oMdl := FWModelActive()
Local oMdl_EKM := oMdl:GetModel():GetModel("EKMMASTER")
Local oMdl_EKN := oMdl:GetModel():GetModel("EKNDETAIL")
Local xValue

Do Case
   Case cCpo == 'EKN_COD_I'
      oMdl_EKN:LoadValue( "EKN_FILIAL" , xFilial("EKN") )
      oMdl_EKN:LoadValue( "EKN_ORGANU" , oMdl_EKM:GetValue("EKM_ORGANU" ) )
      oMdl_EKN:LoadValue( "EKN_FRMLPC" , oMdl_EKM:GetValue("EKM_FRMLPC" ) )
      oMdl_EKN:LoadValue( "EKN_NCM"    , oMdl_EKM:GetValue("EKM_NCM"    ) )
      If Empty(oMdl_EKN:GetValue("EKN_OBRIGA" ))
         oMdl_EKN:LoadValue( "EKN_OBRIGA" , oMdl_EKM:GetValue("EKM_OBRIGA" ) )
      EndIf
      xValue := Posicione("SB1",1,xFilial("SB1")+ oMdl_EKN:GetValue("EKN_COD_I"),"B1_DESC" )
   Case cCpo == 'EKM_FRMLPC'
      xValue := If(LEFT(oMdl_EKM:GetValue("EKM_FRMLPC" ),1)=="I","1","2")
End Case

Return xValue

/*---------------------------------------------------------------------*
 | Func:  LP400WHEN                                                    |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Habilita/Desabilita alteração de campos                      |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP400WHEN(cCpo)
Local oMdl := FWModelActive()
Local oMdl_EKM := oMdl:GetModel():GetModel("EKMMASTER")
Local oMdl_EKN := oMdl:GetModel():GetModel("EKNDETAIL")
Local lRet := .T.
Local aEKMWHEN

   aEKMWHEN := {"EKM_MODAL","EKM_FRMDEF","EKM_DATA","EKM_HORA"}

   If oMdl:GetOperation() <> 3
      If !Empty(oMdl_EKM:GetValue("EKM_ORGANU" ))
         aAdd(aEKMWHEN,"EKM_ORGANU")
      EndIf
      If !Empty(oMdl_EKM:GetValue("EKM_FRMLPC" ))
         aAdd(aEKMWHEN,"EKM_FRMLPC")
      EndIf
      If !Empty(oMdl_EKM:GetValue("EKM_NCM" )) .And. oMdl_EKN:GetQtdLine() > 0 .And. !Empty( oMdl_EKN:GetValue("EKN_ORGANU" ) + oMdl_EKN:GetValue("EKN_FRMLPC" ) + oMdl_EKN:GetValue("EKN_NCM" ) )
         aAdd(aEKMWHEN,"EKM_NCM")
      EndIf
   EndIf

   If aScan( aEKMWHEN , cCpo ) > 0
      lRet := .F.
   EndIf   

Return lRet

/*---------------------------------------------------------------------*
 | Func:  LP400F3EKL                                                   |
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
 | Func:  LP400LOADV                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Carregar valores para determinados campos, como os virtuais  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP400LOADV(cCpo)
Local oMdl := FWModelActive()
Local oMdl_EKM := oMdl:GetModel("EKMMASTER")
Local oMdl_EKN := oMdl:GetModel("EKNDETAIL")
Local cValue   := ""

If oMdl:GetOperation() <> 3 
   Do Case
      Case cCpo == 'EKN_B1DESC' .And. ValType(oMdl_EKN) == "O" //.And. oMdl_EKN:GetLine() <> 0
         cValue := Posicione("SB1",1,xFilial("SB1") + AvKey( EKN->EKN_COD_I , "B1_COD"),"B1_DESC" )
      Case cCpo == 'EKM_MODAL' .And. ValType(oMdl_EKM) == "O"
         cValue := If(LEFT(oMdl_EKM:GetValue("EKM_FRMLPC"),1)=="I","1","2")
   EndCase
EndIf

Return cValue


Static Function PesqModEKN(oMdl_EKN,bCond)
Local i, aRet := {.F.,0}

Begin Sequence
If oMdl_EKN:GetQtdLine() > 0
   For i:=1 To oMdl_EKN:GetQtdLine()
      oMdl_EKN:GoLine(i)
      If Eval(bCond)
         aRet := {.T.,i}
         Break
      EndIf
   Next i
EndIf
End Sequence

Return aRet

/*---------------------------------------------------------------------*
 | Func:  LP400FilF3                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Filtrar os registros da consulta padrão EKL                  |
 | Obs.:  Function com chamadas externas de outros fontes              |
 *---------------------------------------------------------------------*/
Function LP400FilF3()
Local oMdl := FWModelActive()
Local lRet := .T.

If ValType(oMdl:GetModel("EKMMASTER")) == "O"
   lRet := EKL_CODIGO == oMdl:GetModel("EKMMASTER"):GetValue("EKM_ORGANU" )
ElseIf ValType(oMdl:GetModel("EKOMASTER")) == "O"
   lRet := EKL_CODIGO == oMdl:GetModel("EKOMASTER"):GetValue("EKO_ORGANU" )
ElseIf ValType(oMdl:GetModel("EKQDETAIL")) == "O"
   lRet := EKL_CODIGO == oMdl:GetModel("EKQDETAIL"):GetValue("EKQ_ORGANU" ) .And. Left(EKL_CODFOR,1) == "I"
EndIf

Return lRet




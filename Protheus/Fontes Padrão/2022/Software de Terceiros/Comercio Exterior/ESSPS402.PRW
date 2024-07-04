#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH" 
#INCLUDE "FWBROWSE.CH" 
#Define AQUISICAO "A"
#Define VENDAS    "V"
#Define PROCESSADO	"P"


/*
Programa   : ESSPS402
Objetivo   : 
Retorno    : Nil
Autor      : 
Data/Hora  : 05/10/2012 15:14 
Revisao    : 
*/

Static aModels := {}
                                                               
Function ESSPS402(aCapaAuto,aItensAuto,nOpcAuto, cTipo)
Local oBrowse
Local oAvObject := AvObject():New()
Local lRet := .T.
Local aOrd
Local nPos

//Private aRotina //FSY-17/01/2014-Nopado
Private lPS402Auto := ValType(aCapaAuto) == "A" .And. ValType(nOpcAuto) == "N"
Private cTpReg := cTipo
Private aModelAuto
Private lGeraNovo := .F.
//Private cTipoProc := cTipo

//Default cTipoProc := cTipo

If !lPS402Auto
   oBrowse := FWMBrowse():New() //Instanciando a Classe
   oBrowse:SetAlias("EL9") //Informando o Alias 
   oBrowse:SetMenuDef("ESSPS402") //Nome do fonte do MenuDef
   oBrowse:SetDescription(If(cTpReg=="A","Pagamentos","Faturamentos"))
   oBrowse:Activate()
Else
   //aAutoPS402    := aClone(aCapaAuto)
   //aAutoItPS402  := aClone(aItensAuto)
   //nAutoOpcPS402 := nOpcAuto
   
   Begin Sequence
   
   //If ValidaIntegracao(nOpcAuto, aCapaAuto, aItensAuto)
   If ValidaIntegracao(@nOpcAuto,aCapaAuto,aItensAuto)
      
      If nOpcAuto == 0
         lMsErroAuto := .F.
         Break
      EndIf
      
      //Definições de WHEN dos campos
      INCLUI := nOpcAuto == INCLUIR
      ALTERA := nOpcAuto == ALTERAR
      EXCLUI := nOpcAuto == EXCLUIR

      Private aAutoPS402 := aClone(aCapaAuto)
      Private aAutoItPS402 := aClone(aItensAuto)
      Private nAutoOpc := nOpcAuto
   
      aRotina := MenuDef()
      
      If (nPos := aScan(aModels,{|X| X[1] == cTipo})) == 0
         aAdd(aModels,{cTipo,ModelDef()})
         nPos := Len(aModels)
      EndIf
      oModelAuto := aModels[nPos][2]
      
      lMsErroAuto := !EasyMVCAuto("ESSPS402",nAutoOpc,{{"EL9MASTER" ,aAutoPS402},{"EL1DETAIL" ,aAutoItPS402}},@oAvObject)
      If lMsErroAuto
         AEval(oAvObject:aError,{|X| AutoGrLog(x)})
      EndIf
      
      If !lMsErroAuto .AND. lGeraNovo
         If (nPos := aScan(aCapaAuto,{|X| X[1] == "EL9_SEQPAG"})) > 0
            aCapaAuto[nPos][2] := ""
         EndIf
         
         ESSPS402(aCapaAuto,aItensAuto,3, cTipo)
      EndIf
   Else
      lMsErroAuto := .T.
      AEval(oAvObject:aError,{|X| AutoGrLog(x)})
   EndIf
   
   End Sequence
   
   lRet := lMsErroAuto
EndIf

If IsInCallStack("ESSPS500")
   aOrd := SaveOrd({"ELA","EL9"})
   PS500Atua()
   RestOrd(aOrd,.T.)
EndIf

Return lRet

*------------------------*
Static Function MenuDef()
*------------------------*

Local aRotina := {}
If Type("lPS402Auto") == "L" .And. lPS402Auto
   ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"     OPERATION 1 ACCESS 0  
EndIf

ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ESSPS402" OPERATION 2 ACCESS 0

If Type("lPS402Auto") == "L" .And. lPS402Auto
   ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ESSPS402" OPERATION 3 ACCESS 0
   ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ESSPS402" OPERATION 4 ACCESS 0
   ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ESSPS402" OPERATION 5 ACCESS 0
EndIf

ADD OPTION aRotina TITLE "Manutenção"    ACTION "VIEWDEF.ESSPS402" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Legenda"       ACTION "PS402Legenda"     OPERATION 8 ACCESS 0   
If EasyGParam("MV_ESS0027",,9) >= 10
   ADD OPTION aRotina TITLE "Cancelar"    ACTION "PS402Cancel" OPERATION 4 ACCESS 0
EndIf
Return aRotina

*------------------------*
Static Function ModelDef()
*------------------------*
Local oModel
Local oStruEL9 := FWFormStruct(1,"EL9")
Local oStruEL1 := FWFormStruct(1,"EL1")
Local oStruEL2 := FWFormStruct(1,"EL2") //RRC - 27/08/2013 - Vinculação dos documentos a pagamentos/faturamentos
Local bPos     := {|oMdl| PS402VldPos(oMdl) }
Local bCommit  := {|oMdl| PS402Grava(oMdl)}
Local bPosVal  := {||PS402GravDoc()}
Local cTpReg   := If( Type("cTpReg") == "C" , cTpReg , If( IsInCallStack("ESSRV400") ,"V", "A" ) )

oModel := MPFormModel():New("ESSPS402", /*bGridValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/)
//Modelo para criação da antiga Enchoice com a estrutura da tabela
oModel:AddFields("EL9MASTER", /*nOwner*/, oStruEL9, /*bPre*/ ,bPos)  
oModel:AddGrid("EL1DETAIL", "EL9MASTER", oStruEL1, /*bLinePre*/ , /*bLinePos*/ , /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
oModel:AddGrid("EL2DETAIL", "EL9MASTER", oStruEL2,  /*bLinePre*/ ,/*bLinePos*/ , /*bPreVal*/,bPosVal,/*bLoad*/ )

/*If cTipoProc == "V"
   oStruEL1:RemoveField("EL1_PARC")
EndIf*/

If EasyGParam("MV_ESS0027",,9) >= 10 .AND. (Type("lPS402Auto") <> "L" .OR. !lPS402Auto)
   oStruEL9:SetProperty( '*' , MODEL_FIELD_WHEN,{|| .F.})
   oStruEL2:SetProperty( '*' , MODEL_FIELD_WHEN,{|| .F.})
   oStruEL1:SetProperty( 'EL1_VLCAMB', MODEL_FIELD_WHEN,{|| .F.})
   oStruEL1:SetProperty( 'EL1_VLEXT' , MODEL_FIELD_WHEN,{|| .F.})
EndIf

//If Type("cTpReg") == "C"
  //Modelo de relação entre Capa e Detalhe
  oModel:SetRelation("EL1DETAIL",{{"EL1_FILIAL", "xFilial('EL1')"}, {"EL1_TPPROC","'"+cTpReg+"'"}, {"EL1_REGIST", "EL9_REGIST"}, {"EL1_SEQPAG", "EL9_SEQPAG"}} ,EL1->(IndexKey(3)) )

  //Modelo de relação entre Capa e Detalhe
  oModel:SetRelation("EL2DETAIL",{{"EL2_FILIAL", "xFilial('EL2')"}, {"EL2_TPPROC","'"+cTpReg+"'"}, {"EL2_REGIST", "EL9_REGIST"}, {"EL2_SEQPAG", "EL9_SEQPAG"}} , EL2->(IndexKey(4)))
//EndIf

oModel:SetPrimaryKey( {"EL9_FILIAL", "EL9_TPPROC", "EL9_REGIST", "EL9_SEQPAG"}) 

//Informa grid não pussui preenchimento obrigátorio
oModel:GetModel( "EL2DETAIL" ):SetOptional( .T. ) 

oModel:GetModel("EL2DETAIL"):SetUniqueLine({ "EL2_RE", "EL2_DI"})

//Definição da Chave Primária
oModel:GetModel("EL1DETAIL"):SetUniqueLine({ "EL1_SEQREG"} )
If Type("lPS402Auto") <> "L" .Or. !lPS402Auto
   oModel:GetModel("EL1DETAIL"):SetNoInsertLine( .T. )
EndIf

oModel:GetModel("EL2DETAIL"):SetUniqueLine({ "EL2_RE", "EL2_DI" })

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription("Pagamentos")
oModel:GetModel("EL9MASTER"):SetDescription(If(Type("cTpReg") == "C" .And. cTpReg=="A","Pagamentos","Faturamentos")) // Título da Capa
oModel:GetModel("EL1DETAIL"):SetDescription("Serviços") //Título do Detalhe
oModel:GetModel("EL2DETAIL"):SetDescription("Documentos") //Título do Detalhe  

Return oModel

*------------------------*
Static Function ViewDef()
*------------------------*

//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("ESSPS402")
//Cria a estrutura a ser usada na View 
Local oStruEL9  := FWFormStruct(2,"EL9",{|cCpo| MostrCpo(cCpo)},)
Local oStruEL1  := FWFormStruct(2,"EL1",{|cCpo| MostrCpo(cCpo)},)
Local oStruEL2  := FWFormStruct(2,"EL2",{|cCpo| MostrCpo(cCpo)},)
Local oView

//Cria o objeto de View      
oView := FWFormView():New()
//Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)
//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_EL9",oStruEL9, "EL9MASTER")
oView:AddGrid( "VIEW_EL1",oStruEL1, "EL1DETAIL" )
If !(EasyGParam("MV_ESS0027",,9) >= 10)
   oView:AddGrid( "VIEW_EL2", oStruEL2, "EL2DETAIL" )
EndIf

If !(EasyGParam("MV_ESS0027",,9) >= 10 .AND. EasyGParam("MV_ESS0004",,.F.))
   oStruEL1:RemoveField("EL1_MOVTEM")
Endif

//Criar "box" horizontal para receber algum elemento da view 
oView:CreateHorizontalBox( 'EMCIMA' , 50 )
If !(EasyGParam("MV_ESS0027",,9) >= 10)
   oView:CreateVerticalBox( 'EMCIMAESQ' , 65, 'EMCIMA' )
   oView:CreateVerticalBox( 'EMCIMADIR' , 35, 'EMCIMA' )
Else
   oView:CreateVerticalBox( 'EMCIMAESQ' , 100, 'EMCIMA' )
EndIf
oView:CreateHorizontalBox( 'EMBAIXO', 50 )

//Relaciona o ID da View com o "box" para exibição 
//oView:SetOwnerView("VIEW_EL9", "EMCIMA")
oView:SetOwnerView("VIEW_EL9", "EMCIMAESQ")
If !(EasyGParam("MV_ESS0027",,9) >= 10)
   oView:SetOwnerView("VIEW_EL2", "EMCIMADIR")
EndIf
oView:SetOwnerView("VIEW_EL1", "EMBAIXO")

//Ação executada ao deletar uma linha 
oView:SetViewAction("DELETELINE",{|oObj,cDetail|PS402DelDoc(cDetail)})  

oView:EnableTitleView("VIEW_EL9", If(cTpReg=="A","Pagamentos","Faturamentos"), RGB(240,248,255))
oView:EnableTitleView("VIEW_EL1", "Serviços", RGB(240,248,255))
If !(EasyGParam("MV_ESS0027",,9) >= 10)
   oView:EnableTitleView("VIEW_EL2", "Documentos", RGB(240,248,255))
EndIf
//oView:AddUserButton("Conhecimento"        , "CLIPS",{|| EL9MsDocument() })
oView:bCanActivate := {|oView| AtuView(oView)}
Return oView

Static Function MostrCpo(cCpo)
Local lRet := .T.           

//RRC - 27/08/2013 - Atualização para vinculação de documentos a pagamentos ou faturamentos                                                                           
If !Alltrim(cCpo) == "EL2_RE" .And. Alltrim(cCpo) $ "EL1_PROCES/EL1_SEQREG/EL1_SEQPAG/EL9_TPPROC/EL9_PROCES/EL1_REGIST/EL2_REGIST/EL2_SEQREG/EL2_PROCES/EL2_FASE/EL2_SEQPRC/EL2_SEQPAG/EL2_STTSIS"
   lRet := .F.
EndIf
   
If Type("cTpReg") == "C"
   If cTpReg == "V" .And. Alltrim(cCpo) $ "EL1_PARC"
      lRet := .F.
   EndIf
   If cTpReg == "A" .And. Alltrim(cCpo) $ ""
      lRet := .F.
   EndIf
EndIf
   
Return lRet

Function PS402Valid(cCampo)
Local lRet := .F.
Local cCpo := ""
Local oModel := FWModelActive()
Local oModelEL1
Local cSeqPag := ""



Default cCampo := ""

cCpo := AllTrim(Upper(cCampo))

If ValType(oModel) == "O"
   oModelEL9 := oModel:GetModel("EL9MASTER")
   oModelEL1 := oModel:GetModel("EL1DETAIL")
EndIf

Begin Sequence

   If Empty(cCpo)
      Break
   EndIf

   Do Case
      /*Case cCpo == "EL1_SEQPAG"
         If ValType(oModelEL1) == "O" .And. ValType(oModelEL9) == "O"
            cSeqPag := oModelEL9:GetValue("EL9_SEQPAG")
            If !Empty(cSeqPag)
               oModelEL1:SetValue("EL1_SEQPAG",cSeqPag)
            EndIf
         EndIf*/
      
      //RRC - 30/08/2013
      Case cCpo == "EL1_VLEXT" .Or. cCpo == "EL1_VLCAMB"
         If !(Type("lPS402Auto") == "L" .And. lPS402Auto)
            EasyHelp("Este valor não poderá ser alterado pois foi gerado " + If(Type("cTpReg")=="C".And.cTpReg=="V","pelo faturamento.","pelo câmbio."))
            lRet := .F.
            Break 
         EndIf    
            
   End Case
   
   lRet := .T.

End Sequence

Return lRet

Static Function PS402VldPos()
Local lRet := .F.
Local oModel := FWModelActive()
Local oModelEL1
Local nValorCam := 0
Local nValorExt := 0
Local nSldVlCam := 0
Local nSldVlExt := 0
Local i

If ValType(oModel) == "O"
   oModelEL9 := oModel:GetModel("EL9MASTER")
   oModelEL1 := oModel:GetModel("EL1DETAIL")
EndIf

Begin Sequence
   
   If ValType(oModelEL1) == "O" .And. ValType(oModelEL9) == "O"
      nValorCam := oModelEL9:GetValue("EL9_VLCAMB")
      nValorExt := oModelEL9:GetValue("EL9_VLEXT")
      
      For i := 1 to oModelEL1:Length()
         oModelEL1:GoLine(i)
         If !oModelEL1:IsDeleted()// .And. oModelEL9:GetValue("EL9_REGIST") == oModelEL1:GetValue("EL1_REGIST") 
            nSldVlCam += oModelEL1:GetValue("EL1_VLCAMB")
            nSldVlExt += oModelEL1:GetValue("EL1_VLEXT")
         EndIf
      Next

      If (nSldVlCam > nValorCam) .Or. (nSldVlExt > nValorExt)
         EasyHelp("O valor do item está maior que valor do pagamento total.")
         Break
      EndIf
   EndIf

   //FSY 21/01/2014 - Não poderá permitir a edição de um pagamento caso tenha lote gerado com o mesmo, alteravel quando for processado ou cancelado
   If RS401VerLote(cTpReg, oModelEL9:GetValue("EL9_REGIST"), oModelEL9:GetValue("EL9_SEQPAG"))
      lRet := .T.
   Else
      EasyHelp("Alteração não é permitida. Registro com Lote gerado só poderá ser alterado quando estiver com o status Processado ou Cancelado")
   End 
   //FSY 21/01/2014
End Sequence
         
Return lRet

Function PS402Info(cInfo)
Local cRet    := ""
Default cInfo := ""

Do Case
   Case cInfo == "EL1_TPPROC"
      If Type("cTpReg") == "C" .And. cTpReg == "V"
         cRet := "V"  
      ElseIf Type ("cTpReg") == "C" .And. cTpReg == "A"
         cRet := "A"
      Endif
End Case

Return cRet

Function PS402Relacao(cCampo)
Local nPosCpo := 0
Local cInfo := ""
Local nOperation
Default cCampo   := "" 

Begin Sequence 

   If Empty(cCampo) 
      Break
   EndIf
   
   Do Case
      Case "EL9_SEQPAG" == AllTrim(Upper(cCampo))
         /*If Type("aAutoPS402") == "A" .And. Len(aAutoPS402) > 0
            nPosCpo := aScan(aAutoPS402,{ |X| X[1] == "EL9_SEQPAG" })
            If nPosCpo > 0 .And. !Empty(aAutoPS402[nPosCpo][2])
               cInfo := aAutoPS402[nPosCpo][2]
            Else
               cInfo := PS402SeqPag(aAutoPS402)
            EndIf
         EndIf*/
      Case cCampo == "EL9_DIAS"
         If !Empty(M->EL9_PRAZO)
            cInfo := M->EL9_PRAZO-If(Empty(M->EL9_DTREG),dDatabase,M->EL9_DTREG)
         Else
            cInfo := 0
         EndIf
  
   EndCase

End Sequence

Return cInfo

Function PS402SeqPag(aDados,aChave)
Local cInfo := ""
Local nPrxSeq := 1
Local lRegistrado := .F. // Verificando se a sequencia de pagamento para o mesmo contrato, data e moeda está registrado
Local lPgto := .F. // Verificando se foi realizado o pagamento para o mesmo contrato, data e moeda.
Local aOrd  := SaveOrd({"EL9"})
   If ValType(aChave) == "U"
      aChave := PS402MontaChave(aDados) // Monta a chave com base do vetor aDados
   EndIf

   // Caso não tenha sido realizado o pagamento para o contrato, data de liquidação e moeda
   // ou caso a contrato, a data de liquidaçao e a mesma moeda ja foram registrado
   // nesses dois cenarios será gerado uma nova sequencia de pagamento
   If !lPgto .Or. lRegistrado
      // Procura pela ultima sequencia gerada
      EL9->(DbSetOrder(1)) //EL9_FILIAL+EL9_TPPROC+EL9_REGIST+EL9_SEQPAG
      If !Empty(aChave[1]) .And. EL9->(AvSeekLast(aChave[1]))
         cInfo := StrZero(Val(EL9->EL9_SEQPAG)+1,AvSx3("EL9_SEQPAG",3))
         //RMD - 26/12/14 - Trata se a próxima sequencia ainda não existe pois houve alteração no tamanho do campo (a sequencia menor fica no final da ordenação da tabela).
         While EL9->(DbSeek(aChave[1]+cInfo)) .And. cInfo <> Repl("9",AvSx3("EL9_SEQPAG",3))
         	cInfo := StrZero(Val(EL9->EL9_SEQPAG)+1,AvSx3("EL9_SEQPAG",3))
         EndDo
      Else
      // Caso nao tenha realizado nenhum pagamento
         cInfo := StrZero(nPrxSeq,AvSx3("EL9_SEQPAG",3))
      EndIf
   EndIf
RestOrd(aOrd,.T.)              
Return cInfo

Static Function PS402MontaChave(aDados)
Local aChaveEL9 := {}
Local nPosTpProc := 0
Local cTpProc := ""
//Local nPosProcesso := 0
//Local cProcesso := ""
Local cRegist   := ""
Local nPosRegist := 0
Local nPosParc := 0
Local nPosNrOp := 0
Local cNrOp := ""
Local nPosDtPag := 0
Local cDtPag := ""
Local nPosSeqPag := 0
Local cSeqPag := ""
Local nMoeda := 0
Local cMoeda := ""
      
Begin Sequence

   If ValType(aDados) <> "A"
      Break
   EndIf

   If (nPosTpProc := aScan(aDados,{ |X| X[1] == "EL9_TPPROC" })) > 0 .And. !Empty(aDados[nPosTpProc][2])
      cTpProc := AvKey(aDados[nPosTpProc][2],"EL9_TPPROC")
   EndIf  
  
   If (nPosRegist := aScan(aDados,{ |X| X[1] == "EL9_REGIST" })) > 0 .And. !Empty(aDados[nPosRegist][2])
      cRegist := AvKey(aDados[nPosRegist][2],"EL9_REGIST")
   EndIf
   
   If (nPosNrOp := aScan(aDados,{ |X| X[1] == "EL9_NROP" })) > 0 .And. !Empty(aDados[nPosNrOp][2])
      cNrOp := AvKey(aDados[nPosNrOp][2],"EL9_NROP")
   EndIf  

   If (nPosDtPag := aScan(aDados,{ |X| X[1] == "EL9_DTPAG" })) > 0 .And. !Empty(aDados[nPosDtPag][2])
      cDtPag := DToS(aDados[nPosDtPag][2])
   EndIf

   If (nMoeda := aScan(aDados,{ |X| X[1] == "EL9_MOEDA" })) > 0 .And. !Empty(aDados[nMoeda][2])
      cMoeda := AvKey(aDados[nMoeda][2],"EL9_MOEDA")
   EndIf
   
   aAdd(aChaveEL9,xFilial("EL9")+cTpProc+cRegist)
   aAdd(aChaveEL9,xFilial("EL9")+cTpProc+cRegist+cNrOp+cDtPag+cMoeda)

End Sequence

Return aClone(aChaveEL9)

Function PS402Pagto(nRecno,nOpc,dDtBaixa,cSegPgt,lReg)
Local aOrd      := SaveOrd({"ELA","ELB","EJZ","EL1","EL9"})
Local aItensPag := {}
Local aEL9Auto  := {}
Local aEL1Auto  := {}
Local aPreEL1   := {}
Local aTotReg   := {}
Local cChave    := ""
Local cRegist   := ""
Local cDoc      := EasyGParam("MV_AVG0224",,"EEQ_NRINVO")//Campo responsavel pelo Numero do Documento no Pagamento de Servicos.
Local cMsg     := ""
Local dPrazo
Local dBaixa
//Local nPrazo   := EasyGParam("MV_AVG0225",,30)//Prazo de Dias para registrar o pagamento no SISCOSERV.
Local nValor    := 0
Local nTaxa     := 0
Local nI        := 0
Local nJ        := 0
Local nReg      := 0
Local nVlCamb   := 0
Local nVlExt    := 0
Local nReg      := 0
Local nTotVal   := 0
Local oRateio
Local lExisteReg := .F.
Local lExistePag := .F.
Local cStatus := ""
Default lReg    := .F. //Indica se a chamada veio do RAS/RVS (ESSRS400)   

Private lMsErroAuto := .F.
Begin Sequence

If !(ValType(nRecno) == "N")
   Break
EndIf

If nOpc == 3
/*    If !"2" $ EEQ->EEQ_MODAL // a data de baixa vem da chamada anterior podendo ser a data da baixa ou a data de inicio do serviço
      dBaixa := EEQ->EEQ_PGT // caso a data de inicio seja maior que a data do pagamento deve ser a data de inicio e vice-versa
   Else                       // MPG - 07/01/2020
      dBaixa := EEQ->EEQ_DTCE
   EndIf */
   nTaxa   := EEQ->EEQ_TX
EndIf

If nOpc <> 5 .And. !Empty(dDtBaixa)
   dPrazo := dDtBaixa// + nPrazo
Else
   If !"2" $ EEQ->EEQ_MODAL 
      dPrazo := EEQ->EEQ_PGT// + nPrazo
   Else
      dPrazo := EEQ->EEQ_DTCE// + nPrazo
   EndIf
EndIf

dPrazo := RS400GetPrazo(dPrazo)     
ELA->(DbSetOrder(4))
ELB->(DbSetOrder(1))//ELB_FILIAL+ELB_TPPROC+ELB_EXPORT+ELB_LOJEXP+ELB_IMPORT+ELB_LOJIMP+ELB_NRINVO+ELB_PROCES+ELB_SEQPRC

cChave := xFilial("ELA")+AvKey(EEQ->EEQ_TPPROC,"ELA_TPPROC")+AvKey(EEQ->EEQ_PROCES,"ELA_PROCES")+AvKey(EEQ->EEQ_NRINVO,"ELA_NRINVO")
//RRC - 04/04/2013 - Verifica a origem da parcela de câmbio   
If ELA->(DbSeek(cChave)) 
   nTotVal := ELA->ELA_VL_MOE
   
   cChave := xFilial("ELB")+AvKey(ELA->ELA_TPPROC,"ELB_TPPROC")+AvKey(ELA->ELA_EXPORT,"ELB_EXPORT")+AvKey(ELA->ELA_LOJEXP,"ELB_LOJEXP")+AvKey(ELA->ELA_IMPORT,"ELB_IMPORT");
   +AvKey(ELA->ELA_LOJIMP,"ELB_LOJIMP")+AvKey(ELA->ELA_NRINVO,"ELB_NRINVO")+AvKey(ELA->ELA_PROCES,"ELB_PROCES")
   If ELB->(DbSeek(cChave))
      Do While ELB->(!Eof()) .And. ELB->(ELB_FILIAL+ELB_TPPROC+ELB_EXPORT+ELB_LOJEXP+ELB_IMPORT+ELB_LOJIMP+ELB_NRINVO+ELB_PROCES) == cChave
         If (!Empty(EEQ->EEQ_SEQPRC) .And. ELB->ELB_SEQPRC == EEQ->EEQ_SEQPRC) .Or. (Empty(EEQ->EEQ_SEQPRC) .And. ELB->ELB_VLEXT + ELB->ELB_VLCAMB > 0)
            aAdd(aItensPag,{ELB->ELB_SEQPRC,ELB->ELB_VLCAMB,ELB->ELB_VLEXT})
         EndIf
         ELB->(DbSkip())
      EndDo
   Else
      EasyHelp("Não foram encontrados os itens da invoice associada a parcela de câmbio.","Aviso")
      lMsErroAuto := .T.
      Break
   EndIf
   //Instancia classe que realiza a operação do rateio
   //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
   oRateio:= EasyRateio():New(Round(If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL)*ELA->ELA_PARIDA,AvSX3("EEQ_VLSISC",AV_DECIMAL)),ELA->ELA_VL_MOE,Len(aItensPag)		,AvSx3("EL1_VLCAMB",AV_DECIMAL))   // AAF - 03/09/2015
      
   EJZ->(DbSetOrder(3)) //EJZ_FILIAL+EJZ_TPPROC+EJZ_PROCES+EJZ_SEQPRC
   For nI := 1 To Len(aItensPag) 
      lExisteReg := .F.
      lExistePag := .F.
      //RRC - 15/10/2013 - Caso o serviço não possua mais RAS, verifica se existe o pagamento, neste caso dvee excluir pois o mesmo necessita de RAS
      //Cada pagamento (RP: Tabelas (EL9 (Capa) e EL1 (Itens))) é gerado pela liquidação da parcela de câmbio (tabela EEQ)
      If !(lExisteReg := EJZ->(DbSeek(xFilial("EJZ")+EEQ->EEQ_TPPROC+AvKey(EEQ->EEQ_PROCES,"EJZ_PROCES")+AvKey(aItensPag[nI][1],"EJZ_SEQPRC"))))
         EL1->(DbSetOrder(3)) //EL1_FILIAL+EL1_TPPROC+EL1_PROCES+EL1_SEQPAG+EL1_SEQPRC
         If EL1->(DbSeek(xFilial("EL1")+EEQ->EEQ_TPPROC+AvKey(EEQ->EEQ_PROCES,"EL1_PROCES")))
            Do While !EL1->(Eof()) .And. !lExistePag .And. EL1->(EL1_FILIAL+EL1_TPPROC+EL1_PROCES) == xFilial("EL1")+EEQ->EEQ_TPPROC+AvKey(EEQ->EEQ_PROCES,"EL1_PROCES")
               If EL1->EL1_SEQPRC == AvKey(aItensPag[nI][1],"EL1_SEQPRC") .And. EL1->EL1_PARC == EEQ->EEQ_PARC
                  If EL9->(DbSeek(xFilial("EL9")+AvKey(EL1->EL1_TPPROC,"EL9_TPPROC")+AvKey(EL1->EL1_REGIST,"EL9_REGIST")+AvKey(EL1->EL1_SEQPAG,"EL9_SEQPAG")))
                     //Verifica se o status do Pagamento está "Aguardando Registro", pois é o único caso em que pode excluir porque não está em nenhum RAS
                     If (lExistePag := EL9->EL9_STTSIS == "1")
                        cRegist := EL1->EL1_REGIST
                        Exit
                     EndIf
                  EndIf
               EndIf
               EL1->(DbSkip())               
            EndDo
         EndIf
      Else
         cRegist := EJZ->EJZ_REGIST
      EndIf
      //lExistePag será .T. apenas quando o serviço não possuir mais RAS (lExisteReg) e houver pagamento para o mesmo (neste caso, deve excluir)
      If lExisteReg .Or. lExistePag
         If aScan(aTotReg,{|X| X[1] == cRegist }) <= 0
            nReg++
            nVlCamb := 0
            nVlExt  := 0     
            Aadd(aTotReg,{cRegist,nVlCamb,nVlExt})                           
         EndIf
         If nOpc <> 5
            aEL1Info := {}
            aAdd(aEL1Info,{"EL1_FILIAL"   ,xFilial("EL1")                                                      ,Nil})
            aAdd(aEL1Info,{"EL1_TPPROC"   ,AvKey(If(lExisteReg,EJZ->EJZ_TPPROC,EL1->EL1_TPPROC)  ,"EL1_TPPROC"),Nil})
            aAdd(aEL1Info,{"EL1_REGIST"   ,AvKey(cRegist,"EL1_REGIST")                                         ,Nil})
            aAdd(aEL1Info,{"EL1_SEQREG"   ,AvKey(If(lExisteReg,EJZ->EJZ_SEQREG,EL1->EL1_SEQREG)  ,"EL1_SEQREG"),Nil})
            //A sequência de pagamento da EL1 será relacionada com a da EL9
            aAdd(aEL1Info,{"EL1_SEQPAG"   ,If(lExisteReg,AvKey(""   ,"EL1_SEQPAG"),EL1->EL1_SEQPAG) ,Nil})
            aAdd(aEL1Info,{"EL1_PROCES"   ,AvKey(EEQ->EEQ_PROCES  ,"EL1_PROCES"),Nil})
            aAdd(aEL1Info,{"EL1_SEQPRC"   ,AvKey(aItensPag[nI][1] ,"EL1_SEQPRC"),Nil})
            If !lExisteReg .And. lExistePag
               //Se o item foi excluído do RAS mas está associado a um pagamento, deve ser excluído do mesmo
               aAdd(aEL1Info,{"AUTDELETA" ,"S"    ,NIL})     
            ElseIf lExisteReg
               If !"2" $ EEQ->EEQ_MODAL
                  nVlCamb := oRateio:GetItemRateio(aItensPag[nI][2]+aItensPag[nI][3])
                  aAdd(aEL1Info,{"EL1_VLCAMB"   ,nVlCamb ,Nil})
               Else
                  nVlExt := oRateio:GetItemRateio(aItensPag[nI][2]+aItensPag[nI][3])
                  aAdd(aEL1Info,{"EL1_VLEXT"   ,nVlExt ,Nil}) 
               EndIf                                            
               aAdd(aEL1Info,{"EL1_NRINVO"   ,AvKey(EEQ->EEQ_NRINVO ,"EL1_NRINVO") ,Nil})
               aAdd(aEL1Info,{"EL1_PARC"     ,AvKey(EEQ->EEQ_PARC   ,"EL1_PARC")   ,Nil})
               aTotReg[nReg][2]+=nVlCamb //Atualiza os valores cambiais para cada Registro associado ao Pagamento/Faturamento
               aTotReg[nReg][3]+=nVlExt   
            EndIf
            aAdd(aPreEL1,aClone(aEL1Info))                     
         EndIf	
      EndIf
   Next nI
       
   For nI := 1 To Len(aTotReg)
      EEQ->(DbGoTo(nRecno))
      cRegist  := AvKey(aTotReg[nI][1],"EL9_REGIST")
      aEL1Auto := {}
      aEL9Auto := {}
      For nJ := 1 To Len(aPreEL1)
         If (nReg:= aScan(aPreEL1[nJ],{|X| X[1] == "EL1_REGIST"})) > 0 .And. aPreEL1[nJ][nReg][2] == cRegist
           aAdd(aEL1Auto,aClone(aPreEL1[nJ]))   
         EndIf
      Next j
      
      /*RRC - 15/10/2013 - Quando for alteração, posiciona na última sequência de pagamento válida referente a esta parcela caso houver, isso para evitar que posicione em um pagamento
      com status "aguardando cancelamento" ou "cancelado" por exemplo.*/
      If EasyGParam("MV_ESS0027",,9) >= 10 .OR. nOpc > 3 .Or. lReg
         EL9->(DbSetOrder(3))//EL9_FILIAL+EL9_TPPROC+EL9_REGIST+EL9_PROCES+EL9_NRINVO+EL9_PARC
         cChave := xFilial("EL9")+AvKey(EEQ->EEQ_TPPROC,"EL9_TPPROC")+AvKey(cRegist,"EL9_REGIST")+AvKey(EEQ->EEQ_PROCES,"EL9_PROCES")+AvKey(EEQ->EEQ_NRINVO,"EL9_NRINVO");
         +AvKey(EEQ->EEQ_PARC,"EL9_PARC") 
         /*Variável nOpc poderá ser 5 caso seja também seja um estorno da parcela de câmbio.
         Posiciona na última sequência de pagamento válida referente a esta parcela caso haja, para realizar o tratamento correspondente a mesma*/
         //MFR 05/06/2019 OSSME-3017 -- Opc = 7 é só para localizar o registro usado na EECAF500
         If nOpc == 5 .Or. nOpc == 7 
            EL9->(AvSeekLast(cChave))
            if nOpc == 7
               cSegPgt := EL9->EL9_STTSIS
            EndIf                                                                        
         ElseIf EasyGParam("MV_ESS0027",,9) >= 10 .AND. EL9->(AvSeekLast(cChave)) .AND. (EL9->EL9_STTSIS == "2" /* .OR. EL9->EL9_STTSIS == "3" */)
            nResult := PS402Compara(aTotReg[nI][2],aTotReg[nI][3])
            If nResult == 1  // Retificação
               nOpc := 4
               cStatus := "5"
            ElseIf nResult == 3  // Manter Registrado
               nOpc := 4
               cStatus := "2"
            Else  // Cancelar
               nOpc := 3
               IF EL9->EL9_STTSIS == '2' //LRS - 20/04/2016 - Mudando o Status caso o RP da parcela de câmbio foi estornada/excluida.
	              RecLock("EL9",.F.)
		           EL9->EL9_STTSIS := "3"
		           EL9->(MsUnlock())
               EndIF
            EndIf
         //RRC - 21/10/2013 - Não pode alterar pagamento com status "Aguardando Cancelamento" ou "Cancelado"
         ElseIf (!EL9->(AvSeekLast(cChave)) .Or. EL9->EL9_STTSIS == "3" .Or. EL9->EL9_STTSIS == "4") .And. (nOpc == 4 .Or. lReg)
            nOpc := 3
         ElseIf lReg
            nOpc := 4 
         EndIf
      EndIf 
      if nOpc <> 7
          aAdd(aEL9Auto,{'EL9_FILIAL',xFilial("EL9")                         ,NIL})
          aAdd(aEL9Auto,{'EL9_TPPROC',AvKey(EEQ->EEQ_TPPROC,"EL9_TPPROC")    ,NIL})
          aAdd(aEL9Auto,{'EL9_REGIST',AvKey(aTotReg[nI][1] ,"EL9_REGIST")    ,NIL})
          aAdd(aEL9Auto,{"EL9_SEQPAG",If(nOpc==3,"",EL9->EL9_SEQPAG) ,NIL}) 
                
          If nOpc <> 5
            aAdd(aEL9Auto,{'EL9_PROCES',AvKey(EEQ->EEQ_PROCES,"EL9_PROCES")    ,NIL})
            If !"2" $ EEQ->EEQ_MODAL 
                aAdd(aEL9Auto,{'EL9_VLCAMB',aTotReg[nI][2]                      ,NIL})
                nValor := aTotReg[nI][2]
            Else
                aAdd(aEL9Auto,{'EL9_VLEXT' ,aTotReg[nI][3]                      ,NIL})
                nValor := aTotReg[nI][3]
            EndIf
      
            If !Empty(dDtBaixa)
                aAdd(aEL9Auto,{'EL9_DTPAG' ,dDtBaixa                          ,NIL})
            EndIf
            aAdd(aEL9Auto,{'EL9_NROP'  ,AvKey(EEQ->EEQ_NROP,"EL9_NROP")       ,NIL})
            aAdd(aEL9Auto,{'EL9_MOEDA' ,AvKey(EEQ->EEQ_MOEDA,"EL9_MOEDA")     ,NIL})
          
            nTaxa := ELA->ELA_TX_PED //EEQ->EEQ_TX
          
            aAdd(aEL9Auto,{'EL9_TX_MOE',nTaxa                                 ,NIL})   
            aAdd(aEL9Auto,{'EL9_EQVL'  ,nValor*nTaxa                          ,NIL})
            aAdd(aEL9Auto,{'EL9_PRAZO' ,dPrazo                                ,NIL})
            aAdd(aEL9Auto,{'EL9_PARC'  ,AvKey(EEQ->EEQ_PARC,"EL9_PARC")       ,NIL})
            aAdd(aEL9Auto,{'EL9_NRINVO',AvKey(EEQ->EEQ_NRINVO,"EL9_NRINVO")   ,NIL})
          
            If !Empty(cDoc) /*.And. EEQ->(FieldPos(cDoc))  > 0*/ //MCF - 15/01/2016
                aAdd(aEL9Auto,{'EL9_DOC'   ,AvKey(EEQ->&(cDoc),"EL9_DOC")      ,NIL})
            EndIf          
            If EasyGParam("MV_ESS0027",,9) >= 10 .AND. nOpc == 4 .AND. !Empty(cStatus)
                aAdd(aEL9Auto,{'EL9_STTSIS' ,cStatus                           ,NIL})
            EndIf                                                            
          EndIf
          MSExecAuto({|a,b,c,d| ESSPS402(a,b,c,d)},aEL9Auto,aEL1Auto,nOpc,EEQ->EEQ_TPPROC)
          If lMsErroAuto
            If !(ValType(NomeAutoLog()) == "U")
                cMsg := MemoRead(NomeAutoLog())
                FErase(NomeAutoLog())     
            EndIf
            EasyHelp(cMsg)
            Break
          EndIf 
      EndIf
   Next nItem
Else
   EasyHelp("Não foi encontrada a invoice associada a parcela de câmbio.","Aviso")
   lMsErroAuto := .T.
EndIf   

End Sequence
   
RestOrd(aOrd,.T.)
Return !lMsErroAuto

Static Function PS402GetItPgt(aPagamento,cSeqPed)
Local aServicos := {}
Local aPag := aClone(aPagamento)
Local nPosTpProc := 0
Local nPosProcesso := 0
Local cTpProc := ""
Local cProcesso := ""
Local nPosSeqPag := 0
Local cRegist   := ""
Local nPosRegist:=0
Local cSeqPag := ""
Local nData := 0
Local dData
Local nPosValorCam := 0
Local nValorCam := 0
Local nPosValorExt
Local nValorExt := 0
Local nPosPrazo := 0
Local dPrazo 
Local cDoc 
Local nPosDoc
Local cNrOp := ""
Local nPosNrOp := 0
Local cMoeda := ""
Local nMoeda := 0

Begin Sequence

   nPosTpProc := aScan(aPag,{ |X| X[1] == "EL9_TPPROC" })
   nPosProcesso := aScan(aPag,{ |X| X[1] == "EL9_PROCES" })
   nPosRegist := aScan(aPag,{ |X| X[1] == "EL9_REGIST" })
   If nPosTpProc > 0 .And. nPosProcesso > 0 .And. nPosRegist > 0
      cTpProc := aPag[nPosTpProc][2]
      cProcesso := aPag[nPosProcesso][2]
      cRegist := aPag[nPosRegist][2]
   EndIf
      
   If (nPosSeqPag := aScan(aPag,{ |X| X[1] == "EL9_SEQPAG" })) > 0 .And. !Empty(aPag[nPosSeqPag][2])
      cSeqPag := aPag[nPosSeqPag][2]
   EndIf 

   If (nPosValorCam := aScan(aPag,{ |X| X[1] == "EL9_VLCAMB" })) > 0 .And. aPag[nPosValorCam][2] > 0
      nValorCam := aPag[nPosValorCam][2]
   EndIf 

   If (nPosValorExt := aScan(aPag,{ |X| X[1] == "EL9_VLEXT" })) > 0 .And. aPag[nPosValorExt][2] > 0
      nValorExt := aPag[nData][2]
   EndIf 

   If !Empty(cSeqPed)
      aRateio := PS402PgSeqPed(cTpProc,cProcesso,cSeqPag,cSeqPed)
   Else
      aRateio := PS402Rateio(cTpProc,cProcesso,cSeqPag,nValorCam,nValorExt)
   EndIf
   
   aServicos := PS402Pgt(aRateio,cTpProc,cProcesso,cRegist)
   
End Sequence

Return aClone(aServicos)

Static Function PS402Rateio(cTpProc,cProcesso,cSeqPag,nValorCam,nValorExt)
Local aRateio := {} // {SEQ PED, SEQ PAG, VALOR CAM,VALOR EXT} 
Local i 
Local nTotVal := 0
Local nVlTotCam := nValorCam
Local nVlTotExt := nValorExt
Local nRateio := 0
Local nTotRateio := 0
Local aServicos := {}
Local nQtdSev := 0
Local nVlSrv := 0
Local nDec := 0
Local aPagamentos := {}

Begin Sequence

   aServicos := PS402GetQtServico(cTpProc,cProcesso)
   nQtdSev := Len(aServicos)

   If Empty(aServicos)
      Break
   EndIf

   If nQtdSev == 1 

      For i := 1 To Len(aServicos)
         aAdd(aRateio,{aServicos[i][1], cSeqPag, nVlTotCam, nValorExt,""})
      Next

   ElseIf EasyGParam("MV_ESS0002",,0) == 1 // Divide o pagamento igual para todos os serviços

      // Total do pagamento
      If nVlTotCam > 0
         nTotVal := nVlTotCam 
         nDec := AvSX3("EL1_VLCAMB",AV_DECIMAL)
      Else
         nTotVal := nVlTotExt 
         nDec := AvSX3("EL1_VLEXT" ,AV_DECIMAL)
      EndIf

      nRateio := Round(nTotVal / nQtdSev,nDec)
      nRatOriginal := nRateio
      nTotRateio := 0
      nAcres := 0

      // Ordena o serviços pelo valor em ordem crescente
      aSort(aServicos,,,{|X,Y| X[2] < Y[2]})
      For i := 1 To Len(aServicos)

         nVlSrv := Round(aServicos[i][2],nDec)
         nRateio := nRateio + nAcres
         If nRateio <= nVlSrv
            If nVlTotCam > 0
               aAdd(aRateio,{aServicos[i][1],cSeqPag,nRateio,0,""})
            Else
               aAdd(aRateio,{aServicos[i][1],cSeqPag,0,nRateio,""})
            EndIf
            nAcres := 0
            nTotRateio+=nRateio
            nRateio := nRatOriginal
         Else
            If nVlTotCam > 0
               aAdd(aRateio,{aServicos[i][1],cSeqPag,nVlSrv,0,""})
            Else
               aAdd(aRateio,{aServicos[i][1],cSeqPag,0,nVlSrv,""})
            EndIf
            nAcres := nRateio - nVlSrv
            nTotRateio+=nVlSrv
         EndIf
      Next

      If nTotRateio > nTotVal
         If nVlTotCam > 0
            aRateio[Len(aRateio)][3] := Round(aRateio[Len(aRateio)][3],nDec) - (nTotRateio - nTotVal)
         Else
            aRateio[Len(aRateio)][4] := Round(aRateio[Len(aRateio)][4],nDec) - (nTotRateio - nTotVal)         
         EndIf
      ElseIf nTotRateio < nTotVal
         If nVlTotCam > 0
            aRateio[Len(aRateio)][3] := Round(aRateio[Len(aRateio)][3],nDec) + (nTotVal - nTotRateio)     
         Else
            aRateio[Len(aRateio)][4] := Round(aRateio[Len(aRateio)][4],nDec) + (nTotVal - nTotRateio)              
         EndIf
      EndIf

   ElseIf EasyGParam("MV_ESS0002",,0) == 2 // Divide o pagamento baixando o valor total do serviço

   ElseIf EasyGParam("MV_ESS0002",,0) == 3 // Usuario define a forma de divisão do pagamento  
 
      For i := 1 To Len(aServicos)
        aAdd(aRateio,{aServicos[i][1], cSeqPag, 0, 0,""})
      Next

   EndIf

End Sequence

Return aClone(aRateio)

Static Function PS402Pgt(aRateio,cTpProc,cProcesso,cRegist)
Local aPgt     := {}
Local aEL1Info := {}
Local aOrd     := SaveOrd({"EJZ"})
Local cChave   := ""
Local i

EJZ->(DbSetOrder(3)) //EJZ_FILIAL+EJZ_TPPROC+EJZ_PROCES+EJZ_SEQPRC

Begin Sequence

   For i := 1 To Len(aRateio)
      aEL1Info := {}
      aAdd(aEL1Info,{"EL1_FILIAL"   ,xFilial("EL1")                      ,Nil})
      aAdd(aEL1Info,{"EL1_TPPROC"   ,AvKey(cTpProc         ,"EL1_TPPROC"),Nil})
      aAdd(aEL1Info,{"EL1_PROCES"   ,AvKey(cProcesso       ,"EL1_PROCES"),Nil})
      aAdd(aEL1Info,{"EL1_SEQPRC"   ,AvKey(aRateio[i][1]   ,"EL1_SEQPRC"),Nil})
      aAdd(aEL1Info,{"EL1_REGIST"   ,AvKey(cRegist         ,"EL1_REGIST"),Nil})
      
      //RRC - 04/04/2013 - Busca a Sequência do Registro em que o Processo está vinculado
      cChave := xFilial("EJZ")+AvKey(cTpProc,"EJZ_TPPROC")+AvKey(cProcesso,"EJZ_PROCES") + AvKey(aRateio[i][1],"EJZ_SEQPRC")
      EJZ->(DbSeek(cChave))
      aAdd(aEL1Info,{"EL1_SEQREG"   ,AvKey(EJZ->EJZ_SEQREG ,"EL1_SEQREG"),Nil})
      aAdd(aEL1Info,{"EL1_SEQPAG"   ,AvKey(aRateio[i][2]   ,"EL1_SEQPAG"),Nil})      
      aAdd(aEL1Info,{"EL1_VLCAMB"   ,aRateio[i][3]                       ,Nil})
      aAdd(aEL1Info,{"EL1_VLEXT"    ,aRateio[i][4]                       ,Nil})
      aAdd(aEL1Info,{'EL1_PARC'     ,AvKey(EEQ->EEQ_PARC,"EL1_PARC")     ,NIL})
      aAdd(aPgt,aEL1Info)
   Next

End Sequence
RestOrd(aOrd,.T.)
Return aClone(aPgt)

Static Function PS402GetQtServico(cTpProc,cProcesso)
Local aServicos  := {}
Local nRec := 0
Local nOrd := 0

Begin Sequence

   nRec := EJX->(Recno())
   nOrd := EJX->(IndexOrd())
   EJX->(DbSetOrder(1))
   If EJX->(DbSeek(xFilial("EL1")+AvKey(cTpProc,"EJX_TPPROC")+AvKey(cProcesso,"EJX_PROCES")))
      Do While EJX->(!Eof()) .And. EJX->(EJX_FILIAL+EJX_TPPROC+EJX_PROCES) == xFilial("EL1")+AvKey(cTpProc,"EJX_TPPROC")+AvKey(cProcesso,"EJX_PROCES")
         aAdd(aServicos,{EJX->EJX_SEQPRC,EJX->EJX_VL_MOE})
         EJX->(DbSkip())
      EndDo
   EndIf
   EJX->(DbSetOrder(nOrd))
   EJX->(DbGoTo(nRec))

End Sequence

Return aClone(aServicos)

Static Function PS402GetPgt(cTpProc,cProcesso)
Local aPagamentos := {}
Local nRec := 0
Local nOrd := 0
Local nValor := 0

Begin Sequence

   nRec := EL1->(Recno())
   nOrd := EL1->(IndexOrd())
   EL1->(DbSetOrder(3)) // EL1_FILIAL+EL1_TPPROC+EL1_PROCES+EL1_SEQPAG+EL1_SEQPRC
   If EL1->(DbSeek(xFilial("EL1") + AvKey(cTpProc,"EL1_TPPROC")+AvKey(cProcesso,"EL1_PROCES")))
      Do While EL1->(!Eof()) .And. EL1->(EL1_FILIAL+EL1_TPPROC+EL1_PROCES) == xFilial("EL1") + AvKey(cTpProc,"EL1_TPPROC")+AvKey(cProcesso,"EL1_PROCES")
         If EL1->EL1_VLCAMB > 0
            nValor := EL1->EL1_VLCAMB
         Else
            nValor := EL1->EL1_VLEXT
         EndIf
 
         If aScan(aPagamentos, {|X| AllTrim(Upper(X[1])) == AllTrim(Upper(EL1->EL1_SEQPRC))}) == 0
            aAdd(aPagamentos,{EL1->EL1_SEQPRC,nValor})
         Else
            aPagamentos[Len(aPagamentos)][2] += nValor
         EndIf

         EL1->(DbSkip())
      EndDo
   EndIf 
   EL1->(DbSetOrder(nOrd))
   EL1->(DbGoTo(nRec))

End Sequence

Return aClone(aPagamentos)

Static Function PS402PgSeqPed(cTpProc,cProcesso,cSeqPag,cSeqPed)
Local lSeqPed := ValType(cSeqPed) == "C" .And. !Empty(cSeqPed)
Local nOrd := EEQ->(IndexOrd())
Local nRec := EEQ->(Recno())
Local nPos
Local aParc := {}

Begin Sequence
   If !lSeqPed
      Break
   EndIf

   // Todas as Parcelas referente a mesma sequencia de pagamento
   EEQ->(DbSetOrder(13)) // EEQ_FILIAL+EEQ_TPPROC+EEQ_PROCES
   //RRC - 10/04/2013 - O campo EEQ_SEQPAG foi excluído
   If !Empty(cSeqPag) .And. EEQ->(DbSeek(xFilial("EL1") + AvKey(cTpProc,"EEQ_TPPROC") + AvKey(cProcesso,"EEQ_PROCES")/* + AvKey(cSeqPag,"EEQ_SEQPAG")*/))
      Do While EEQ->(!Eof()) .And. EEQ->(EEQ_FILIAL+EEQ_TPPROC+EEQ_PROCES/*+EEQ_SEQPAG*/) == xFilial("EL1") + AvKey(cTpProc,"EEQ_TPPROC") + AvKey(cProcesso,"EEQ_PROCES")/*+ AvKey(cSeqPag,"EEQ_SEQPAG")*/
         If (nPos := aScan(aParc,{|X| AllTrim(Upper(X[1])) == AllTrim(Upper(EEQ->EEQ_SEQPRC))})) == 0 
            If !"2" $ EEQ->EEQ_MODAL
               //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
               aAdd(aParc,{EEQ->EEQ_SEQPRC,cSeqPag,If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL),0}) 
            Else
               aAdd(aParc,{EEQ->EEQ_SEQPRC,cSeqPag,0,If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL)}) 
            EndIf        
         Else
            If !"2" $ EEQ->EEQ_MODAL
               //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
               aParc[nPos][3] += If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL) 
            Else
               aParc[nPos][4] += If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL) 
            EndIf
         EndIf
         EEQ->(DbSkip())
      EndDo
   EndIf 

   EEQ->(DbSetOrder(nOrd))
   EEQ->(DbGoTo(nRec))

   If (nPos := aScan(aParc,{|X| AllTrim(Upper(X[1])) == AllTrim(Upper(EEQ->EEQ_SEQPRC))})) == 0 
      If !"2" $ EEQ->EEQ_MODAL
         //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
         aAdd(aParc,{cSeqPed,cSeqPag,If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL),0}) 
      Else
         aAdd(aParc,{cSeqPed,cSeqPag,0,If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL)}) 
      EndIf        
   Else
      If !Empty(EEQ->EEQ_PGT)
         If !"2" $ EEQ->EEQ_MODAL
            //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
            aParc[nPos][3] += If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL) 
         Else
            aParc[nPos][4] += If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL)        
         EndIf
      Else
         If !"2" $ EEQ->EEQ_MODAL
            //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
            aParc[nPos][3] -= If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL) 
         Else
            aParc[nPos][4] -= If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL) 
         EndIf      
      EndIf
   EndIf

End Sequence

Return aClone(aParc)

Static Function ValidaIntegracao(nOpcAuto,aCab,aDet)
Local lRet := .T.
Local lSeek, nPos

Begin Sequence
   
   nPos := aScan(aCab,{|x|x[1]=="EL9_FILIAL"})
   If nPos == 0
      aAdd(aCab,{"EL9_FILIAL",xFilial("EL9"),NIL})
   EndIf
  
   //Adiciona Tipo de processo
   nPos := aScan(aCab,{|x|x[1]=="EL9_TPPROC"})
   If nPos == 0
      aAdd(aCab,{"EL9_TPPROC",cTpReg,NIL})
   EndIf
   
   lSeek := EasySeekAuto("EL9",aCab,1) //EL9_FILIAL + EL9_TPPROC + EL9_REGIST + EL9_SEQPAG

   /*NOPADO por RRC - 01/04/2013
   If nOpcAuto == 3 .OR. nOpcAuto == 4 //UPSERT
      nOpcNew := If(lSeek,4,3)
   EndIf
   */
   
   If nOpcAuto == 5 .AND. !lSeek
      EasyHelp("Chave não foi encontrada para exclusão.","Aviso - RP")
      lRet := .F.
      Break
   EndIf
   
   If nOpcAuto == 5 .AND. lSeek .AND. EL9->EL9_STTSIS == "2"
      RecLock("EL9",.F.)
      EL9->EL9_STTSIS := "3"
      EL9->(MsUnLock())
      
      nOpcAuto := 0
   EndIf
   
   //Exclusao tratar cenário em que o pagamento é uma consolidação de faturas/pagamentos.
   //Tratar se o pagamento precisa ser cancelado. Neste caso, também é necessário gerar um novo pagamento considerando as outras faturas/pagamentos que deram origem ao que está sendo cancelado.

   If nOpcAuto == 3
   
      nPos := aScan(aCab,{|x|x[1]=="EL9_SEQPAG"})
      If nPos == 0
         aAdd(aCab,{"EL9_SEQPAG",PS402SeqPag(aCab),NIL})
      ElseIf Empty(aCab[nPos][2])
         aCab[nPos] := {"EL9_SEQPAG",PS402SeqPag(aCab),NIL}
      EndIf
   
   EndIf

   If nOpcAuto == 4
      //Alteracao tratar cenário em que o pagamento é uma consolidação de faturas/pagamentos.
      //Tratar se o pagamento precisa ser cancelado. Neste caso, também é necessário gerar um novo pagamento considerando as outras faturas/pagamentos que deram origem ao que está sendo cancelado.EndIf
   EndIf
   
End Sequence                                                                              

Return lRet

Static Function PS402Grava(oModel)
Local lRet := .T.
Local oDados     := ERec():New()

Begin Transaction

If Type("cTpReg") == "C"
   //Salva as operações efetuadas anteriormente
   //RRC - 17/10/2013 - Deve gerar uma nova sequência de pagamento caso a última sequência gerada esteja diferente de "Aguardando Registro"
   If oModel:GetOperation() == 4 .AND. EL9->EL9_STTSIS <> "1" .AND. (ComparaCpos(oModel) .OR. EasyGParam("MV_ESS0027",,9) >= 10) //RRC - 06/08/2013 - Passa oModel para ser utilizado posteriormente
      If EasyGParam("MV_ESS0027",,9) >= 10 .AND. lPS402Auto .AND. !Empty(oModel:GetValue("EL9MASTER","EL9_STTSIS")) //.AND. (EL9->EL9_TPPROC == "V" .OR. IsInCallStack("EECAF500")) 
         If EL9->EL9_STTSIS == "2" .OR. EL9->EL9_STTSIS == "3"                                                      //NCF - 16/03/2018 - Nopado - Não gerar nova linha de RP para processo tipo Aquisição
            RecLock("EL9",.F.)     
            EL9->EL9_STTSIS := oModel:GetValue("EL9MASTER","EL9_STTSIS")
            EL9->(MsUnLock())
         EndIf
         lRet := FWFormCommit(oModel)
      Else
         lGeraNovo := .T.
         //Altera o status de "Registrado" para "Aguardando Cancelamento" caso haja alteração do pagamento
         If EL9->EL9_STTSIS == "2"
            RecLock("EL9",.F.)     
            EL9->EL9_STTSIS := "3"
            EL9->(MsUnLock())
         EndIf
      EndIf
   Else
      If (lRet := FWFormCommit(oModel)) .AND. oModel:GetOperation() != 5
         If EL9->(IsLocked()) .OR. EL9->( RECLOCK("EL9",.F.) )
            EL9->EL9_TPPROC := cTpReg
            If !Empty(EL9->EL9_DTREG) .AND. !Empty(EL9->EL9_NROREG)  // GFP - 17/02/2014
               EL9->EL9_STTSIS := "2"
            EndIf
            EL9->(MSUNLOCK())
         EndIf
      ElseIf !lRet
         DisarmTransaction()
      EndIf
   EndIf
EndIf
End Transaction

Return lRet

/*
Pagamentos EL9
Programa   : RS402Legenda()
Objetivo   : Tela de legendas das cores de marcação.
Retorno    : 
Autor      : Fabio Satoru Yamamoto
Data       : 18/03/2013
*/

Function PS402Legenda()
Local aLegenda:= {}

   AAdd(aLegenda, {"BR_VERMELHO", 'Aguardando registro no SISCOSERV'})
   AAdd(aLegenda, {"BR_VERDE"   , 'Registrado no SISCOSERV'}) 
   AAdd(aLegenda, {"BR_AMARELO" , 'Aguardando cancelamento no SISCOSERV'}) 
   AAdd(aLegenda, {"BR_AZUL"    , 'Cancelado no SISCOSERV'})
   AAdd(aLegenda, {"BR_BRANCO"  , 'Aguardando retificação no SISCOSERV'})
   BrwLegenda("Pagamentos de Serviços", 'Legendas', aLegenda) //Legenda

Return

Static Function AtuView(oView)
Local lRet := .T.
oView:aUserButtons := {} 
If Altera
   oView:AddUserButton("Conhecimento"        , "CLIPS",{|| EL9MsDocument()})   
EndIf
Return .T.

/*
Programa   : EL9MsDocument()
Objetivo   : Função utilizada para chamada da rotina de vinculo de documento no metodo "oView:AddUserButton".
Autor      : Fabio Satoru Yamamoto
Data       : 03/04/2013
*/
//Deve existir objeto OMODEL ativo.
Static Function EL9MsDocument()
Local oModel    := FWModelActive()
Local nOperacao := oModel:nOperation
Private aRotina := MenuDef()
If nOperacao == 4//4 = ALTERAÇÃO
   MsDocument( "EL9", EL9->(RecNo()), 2/*Manter o numero 2 para exibir Winzard em açoes relacionadas*/)
Else
   MsgInfo("Opção permitida apenas para alteração!")
End If 
Return .T. 

Static Function ComparaCpos(oModel)
Local lRet      := .F.
Local oModelEL9 := oModel:GetModel("EL9MASTER") //RRC - 06/08/2013 - Ativa o model
Local oModelEL1 := oModel:GetModel("EL1DETAIL") //RRC - 06/08/2013 - Ativa o model
Local aCposCapa, aCposItem
Local i, j

aCposCapa := {"EL9_DTPAG","EL9_DOC","EL9_VLCAMB","EL9_VLEXT"}
aCposItem := {"EL1_VLCAMB","EL1_VLEXT"}

Begin Sequence

For i := 1 To Len(aCposCapa)
   //NOPADO por RRC - 06/08/2013 - Não atualizava o conteúdo da memória
   //If !(&("M->"+aCposCapa[i]) == EL9->(FieldGet(FieldPos(aCposCapa[i]))))
   If !(oModelEL9:GetValue(aCposCapa[i]) == EL9->(FieldGet(FieldPos(aCposCapa[i]))))
      lRet := .T.
      Break
   EndIf
Next i

For i := 1 to oModelEL1:Length()
   oModelEL1:GoLine(i)
   //NOPADO por RRC - 06/08/2013
   //EL1->(DbSetOrder(1)) // EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQREG+EL1_SEQPAG
   EL1->(DbSetOrder(1))//EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQREG+EL1_PARC+EL1_SEQPAG
   If EL1->(DbSeek(xFilial("EL1") + AvKey(EL9->EL9_TPPROC,"EL1_TPPROC")+AvKey(EL9->EL9_REGIST,"EL1_REGIST")+AvKey(oModelEL1:GetValue("EL1_SEQREG"),"EL1_SEQREG")+AvKey(EL9->EL9_PARC,"EL1_PARC")+AvKey(EL9->EL9_SEQPAG,"EL1_SEQPAG")))
      For j := 1 To Len(aCposItem)
         If !(oModelEL1:GetValue(aCposItem[j]) == EL1->(FieldGet(FieldPos(aCposItem[j]))))
            lRet := .T.
            Break
         EndIf
      Next j
   Else
      lRet := .T.
      Break
   EndIf
Next i

End Sequence

Return lRet

/*
Programa   : PS402GravDoc()
Objetivo   : Efetuar a gravação dos Documentos relacionados aos Pagamentos apenas caso a DI ou RE tenham sido preenchido
Parametros : 
Retorno    : .T.
Autor      : Rafael Ramos Capuano
Data/Hora  : 27/08/2012 15:42 
Revisao    : 
*/

Static Function PS402GravDoc()
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
Programa   : PS402DelDoc()
Objetivo   : Validar a exclusão de um Documento relacionado a um Pagamento
Parametros : 
Retorno    : Nil
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 27/08/2013 17:08 
Revisao    : 
*/ 

Static Function PS402DelDoc(cDetail)
Local oModel    := FWModelActive()
Local oModelEL9 := oModel:GetModel("EL9MASTER")
Local oModelEL2 := oModel:GetModel("EL2DETAIL")
Local oModelEL1 := oModel:GetModel("EL1DETAIL")
Local oModelUse
Local oView     := FWViewActive()
Local lRet      := .T.

If cDetail == "EL2DETAIL"
   oModelUse := oModelEL2
ElseIf cDetail == "EL1DETAIL"
   oModelUse := oModelEL1
EndIf

If !(Type("lPS402Auto") == "L" .And. lPS402Auto)  
   If oModelEL9:GetValue("EL9_STTSIS") <> "1"
      lRet := .F.
      If cDetail == "EL2DETAIL"
         EasyHelp("Este documento não poderá ser excluído pois o " + If(Type("cTpReg")=="C".And.cTpReg=="V","faturamento","pagamento") + " referente a ele apresenta Status Siscoserv '" + BSCXBOX('EL9_STTSIS',oModelEL9:GetValue("EL9_STTSIS")) + "'.","Aviso")  
      ElseIf cDetail == "EL1DETAIL"
         EasyHelp("Este serviço não poderá ser excluído pois o " + If(Type("cTpReg")=="C".And.cTpReg=="V","faturamento","pagamento") + " referente a ele apresenta Status Siscoserv '" + BSCXBOX('EL9_STTSIS',oModelEL9:GetValue("EL9_STTSIS")) + "'.","Aviso")  
      EndIf       
   ElseIf cDetail == "EL1DETAIL"
      lRet := .F.
      EasyHelp("Este serviço não poderá ser excluído pois foi gerado " + If(Type("cTpReg")=="C".And.cTpReg=="V","pelo faturamento.","pelo câmbio."))
   EndIf
EndIf

If !lRet .And. oModelUse:IsDeleted()
   oView:GETVIEWOBJ(cDetail)[3]:Refresh() //Atualiza o objeto
   oModelUse:UnDeleteLine()
EndIf     
Return

Function PS402Cancel(cAlias, nReg, nOpc)
Local lCancelar := .F.

Begin Sequence
   If EL9->EL9_STTSIS == "2" .OR. EL9->EL9_STTSIS == "5"
      lCancelar := MsgNoYes("Deseja efetuar o cancelamento do pagamento selecionado no Siscoserv?","Aviso")
   Else
      EasyHelp("Somente é possível efetuar o cancelamento manual de um " + If(EL9->EL9_TPPROC == "A","RP","RF") + " quando este encontra-se com o status 'Registrado no Siscoserv' ou 'Aguardando Retificação no Siscoserv'.","Aviso")
   EndIf

   If lCancelar
      If EL9->(Reclock("EL9",.F.))
         EL9->EL9_STTSIS := "3"
         EL9->(MsUnlock())
      EndIf
   EndIf

End Sequence

Return NIL

/*
Programa   : PS402Compara()
Objetivo   : Comparação de valores para decisão sobre cancelar ou retificar RP/RF
Retorno    : nResult :: 1 - Retificar
                        2 - Cancelar
                        3 - Mater registrado
Autor      : Rafael Ramos Capuano
Data/Hora  : 27/08/2012 15:42 
Revisao    : 
*/
Function PS402Compara(nVlCamb,nVlExt)
Local i, aOrd := SaveOrd({"ELB","EL4"}), nResult := 3
Local aCompRetif := {}, aCompCanc := {}
Local cDoc := EasyGParam("MV_AVG0224",,"EEQ_NRINVO")

ELB->(DbSetOrder(1))
ELB->(DbSeek(xFilial("ELB")+AvKey(ELA->ELA_TPPROC,"ELB_TPPROC")+AvKey(ELA->ELA_EXPORT,"ELB_EXPORT")+AvKey(ELA->ELA_LOJEXP,"ELB_LOJEXP")+AvKey(ELA->ELA_IMPORT,"ELB_IMPORT")+AvKey(ELA->ELA_LOJIMP,"ELB_LOJIMP")+AvKey(ELA->ELA_NRINVO,"ELB_NRINVO")+AvKey(ELA->ELA_PROCES,"ELB_PROCES")))

EL4->(DbSetOrder(1))
EL4->(AVSeekLast(xFilial("EL4")+EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG)) 

aAdd(aCompRetif,{"ELB_VLCAMB", nVlCamb        , "EL9_VLCAMB", EL9->EL9_VLCAMB})
aAdd(aCompRetif,{"ELB_VLEXT" , nVlExt         , "EL9_VLEXT" , EL9->EL9_VLEXT})
aAdd(aCompRetif,{"ELA_TX_PED", ELA->ELA_TX_PED, "EL9_TX_MOE", EL9->EL9_TX_MOE})
If EL9->EL9_TPPROC == "A"
   If EEQ->EEQ_MODAL == "2"   //NCF - 16/03/2018
      aAdd(aCompRetif,{"EEQ_DTCE", EEQ->EEQ_DTCE , "EL9_DTPAG" , EL9->EL9_DTPAG})
   Else
      aAdd(aCompRetif,{"EEQ_PGT" , EEQ->EEQ_PGT  , "EL9_DTPAG", EL9->EL9_DTPAG}) 
   EndIf
   aAdd( aCompRetif,{cDoc     , Alltrim(EEQ->&(cDoc))   , "EL9_DOC"  , Alltrim(EL9->EL9_DOC)} )
EndIf

For i := 1 To Len(aCompRetif)
   If AvSX3(aCompRetif[i][1],2) == "C"
      If AllTrim(aCompRetif[i][2]) <> AllTrim(aCompRetif[i][4])
         nResult := 1
         Exit
      EndIf
   Else
      If AvKey(aCompRetif[i][2],aCompRetif[i][1]) <> AvKey(aCompRetif[i][4],aCompRetif[i][3])
         nResult := 1
         Exit
      EndIf
   EndIf
Next i

aAdd(aCompCanc,{EJZ->EJZ_NBS  , EL4->EL4_NBS})
If EL9->EL9_TPPROC == "A"
   aAdd(aCompCanc,{EEQ->EEQ_MOEDA, EL9->EL9_MOEDA})
EndIf

For i := 1 To Len(aCompCanc)
   If Alltrim(aCompCanc[i][1]) <> Alltrim(aCompCanc[i][2])
      nResult := 2
      Exit
   EndIf
Next i

RestOrd(aOrd,.T.)
Return nResult

#Include "Average.ch"
#Include "FWMVCDEF.CH"

/*
Programa   : ESSIS400
Objetivo   : Manutenção de Invoice de Serviço
Retorno    : Nil
Autor      : Alessandro Alves Ferreira - AAF
Data/Hora  : 09/03/2013
Revisao    :
*/

Static aModels := {}

Function ESSIS400(cAlias, nReg, nOpc, cTipo, aCab, aItens, nOpcAuto, lAtuTit)
Local oBrowse
Local oAvObject    := AvObject():New()
Local nPos
Local nProces
Local cProc   := ""
Local lRet := .T.
Default cTipo := ""
//RRC - 12/07/2013
//Quando lAtuTit for .F., significa que os títulos a pagar ou a receber foram atualizados primeiro no SIGAFIN, neste caso, ao atualizar a invoice e as parcelas de câmbio, o sistema não chamará a integração
//variável utilizada também para não permitir alteração na invoice com origem do SIGACOM ou SIGAFAT caso o parâmetro MV_ESS0008 estiver desabilitado
Default lAtuTit := .T.
Private lIntFin := lAtuTit

If Type("cPed") == "C"
   cTipo := cPed
EndIf

Private nRegEJW    := nReg
Private cTpInvoice := cTipo
Private cBrwInvFil := "ELA->ELA_TPPROC=='"+cTpInvoice+"' .AND. ELA->ELA_PROCES == EJW->EJW_PROCES"
Private aRotina  //FSY-17/01/2014
Private lIS400Auto := ValType(aCab) == "A" .Or. ValType(aItens) == "A" .Or. ValType(nOpcAuto) == "N"
Private lFaturaTod := .F.
Private aValFatura := {0,0}
Private oModelAuto

Begin Sequence

//RRC - 12/11/2013 - Caso o compartilhamento entre ELA e EEQ sejam diferentes, não deve prossguir, uma vez que existe um relacionamento entre elas
If (!Empty(xFilial("ELA")) .And. Empty(xFilial("EEQ"))) .Or. (Empty(xFilial("ELA")) .And. !Empty(xFilial("EEQ")))
   If !lIS400Auto
      EasyHelp("O Compartilhamento das tabelas EEQ (Parcelas de Câmbio) e ELA (Invoices de Serviços) são diferentes, essa rotina não poderá ser executada.","Aviso")
   Else
      If Type("lMsErroAuto") == "L"
         lMsErroAuto := .T.
      EndIf
      oAvObject:Error("O Compartilhamento das tabelas EEQ (Parcelas de Câmbio) e ELA (Invoices de Serviços) são diferentes, essa rotina não poderá ser executada.")
      AEval(oAvObject:aError,{|X| AutoGrLog(x)})
   EndIf
   Break
EndIf

If Empty(cTipo)
   EasyHelp("Informe o tipo de processo.")
   Break
EndIf

If lIS400Auto .And. ValType(nReg) == "U"
   nProces := aScan(aCab,{|X| AllTrim(Upper(X[1])) == "ELA_PROCES"})
   If nProces > 0
      cProc := aCab[nProces][2]
   EndIf

   EJW->(DbSetOrder(1))//EJW_FILIAL+EJW_TPPROC+EJW_PROCES
   If !Empty(cProc) .And. EJW->(DbSeek(xFilial("EJW") + AvKey(cTipo,"EJW_TPPROC") + AvKey(cProc,"EJW_PROCES") ))
      nRegEJW := EJW->(Recno())
   Else
      EasyHelp("Não foi encontrado o processo referente a invoice.")
      Break
   EndIf
EndIf

If !lIS400Auto

   oBrowse := FWMBrowse():New() //Instanciando a Classe
   oBrowse:SetAlias("ELA") //Informando o Alias
   oBrowse:SetMenuDef("ESSIS400") //Nome do fonte do MenuDef
   oBrowse:SetDescription("Invoice de Serviços") //Descrição a ser apresentada no Browse
   oBrowse:SetFilterDefault(cBrwInvFil) //Filtro dos registros a serem exibidos
   
   //THTS - 18/07/2017 - Criada a funcao AvGetCpBrw() para retirar do Browse campos que nao querem que sejam exibidos
   If Upper(cTipo) == "A"
     //aMostra := {"ELA_EXPORT", "ELA_LOJEXP", "ELA_DSCEXP"}
     //aEsconde := {"ELA_IMPORT", "ELA_LOJIMP", "ELA_DSCIMP"}
     oBrowse:SetOnlyFields(AvGetCpBrw("ELA",{"ELA_IMPORT", "ELA_LOJIMP", "ELA_DSCIMP"}))
   ElseIf Upper(cTipo) == "V"
     //aMostra := {"ELA_IMPORT", "ELA_LOJIMP", "ELA_DSCIMP"}
     //aEsconde := {"ELA_EXPORT", "ELA_LOJEXP", "ELA_DSCEXP"}
     oBrowse:SetOnlyFields(AvGetCpBrw("ELA",{"ELA_EXPORT", "ELA_LOJEXP", "ELA_DSCEXP"}))
   EndIf

   oBrowse:Activate()

   ELA->(dbClearFilter())
Else

   Private aOrderAuto

   If cTpInvoice == "A"
      aOrderAuto := {{"ELA",3},{"ELB",3}}
   ElseIf cTpInvoice == "V"
      aOrderAuto := {{"ELA",2},{"ELB",2}}
   EndIf

   Begin Sequence

   If ValidaIntegracao(@nOpcAuto, aCab, aItens)
      //RRC - 28/06/2013 - Caso seja uma exclusão, não precisa passar os itens
      If nOpcAuto <> 5 .And. Len(aItens) == 0
         lFaturaTod := .T.
      EndIf


      //Definições de WHEN dos campos
      INCLUI := nOpcAuto == INCLUIR
      ALTERA := nOpcAuto == ALTERAR
      EXCLUI := nOpcAuto == EXCLUIR

      aRotina := MenuDef()

      If (nPos := aScan(aModels,{|X| X[1] == cTipo})) == 0
         aAdd(aModels,{cTipo,ModelDef()})
         nPos := Len(aModels)
      EndIf
      oModelAuto := aModels[nPos][2]

      lMsErroAuto := !EasyMVCAuto("ESSIS400",nOpcAuto,{{"ELAMASTER" ,aCab},{"ELBDETAIL",aItens},{"FATURA_TODOS",{|| if(lFaturaTod,IS400FaturaTodos(),)}}},@oAvObject)
      If lMsErroAuto
          AEval(oAvObject:aError,{|X| AutoGrLog(x)})
      EndIf
   Else
      lMsErroAuto := .T.
      AEval(oAvObject:aError,{|X| AutoGrLog(x)})
   EndIf

   End Sequence
   lRet := lMsErroAuto
EndIf

End Sequence

//RRC - 28/03/2013
If IsInCallStack("ESSPS400")
   aOrd := SaveOrd({"ELA","EEQ"})
   PS500Atua()
   RestOrd(aOrd,.T.)
EndIf

Return lRet

*------------------------*
Static Function MenuDef()
*------------------------*
Local aRotina := {}

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"       ACTION "AxPesqui"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"      ACTION "VIEWDEF.ESSIS400" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"         ACTION "VIEWDEF.ESSIS400" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"         ACTION "VIEWDEF.ESSIS400" OPERATION 4 ACCESS 0
//ADD OPTION aRotina TITLE "Excluir"       ACTION "FWExecView('EXCLUIR','VIEWDEF.ESSIS400', 5,,,{|| IS400DelInv()})" OPERATION 5 ACCESS 0
If EasyGParam("MV_ESS0027",,9) >= 10
   ADD OPTION aRotina TITLE "Excluir"      ACTION "IS400Exclu"       OPERATION 5 ACCESS 0
   ADD OPTION aRotina TITLE "Alterar Número de Invoice" ACTION "IS400Filt"        OPERATION 6 ACCESS 0
Else
   ADD OPTION aRotina TITLE "Excluir"      ACTION "VIEWDEF.ESSIS400" OPERATION 5 ACCESS 0
EndIf
Return aRotina


*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruELA := FWFormStruct(1,"ELA",{|cCpo| MostrCpo(cCpo)},)
Local oStruELB := FWFormStruct(1,"ELB",{|cCpo| MostrCpo(cCpo)},)
//Local bLinePos := {|| PS400GridVal()}
//Local bPosVal  := {|| SomaVal()}
Local bCommit        := {|oMdl| IS400Grava(oMdl)}
Local bLinePre       := {|oModelGrid, nLine, cAction, cField| IS400LinePre(oModelGrid, nLine, cAction, cField) }
Local bPosValidacao  := {|oMdl| If(oMdl:GetOperation() == 5 .Or. oMdl:GetOperation() == 4,IS400DelInv(oMdl:GetOperation()),.T.)}
Local nI
//Local bPreValidacao  := {|oMdl| if(lIS400Auto .AND. lFaturaTod,IS400FaturaTodos(),)}
Local cTpInvoice     := IF( Type("cTpInvoice") == "C" , cTpInvoice , If( IsInCallStack("ESSRV400") ,"V", "A" ) )
oModel := MPFormModel():New("ESSIS400", /*bPreValidacao*/,bPosValidacao,bCommit,/*bCancel*/)

//Modelo para criação da antiga Enchoice com a estrutura da tabela
oModel:AddFields("ELAMASTER", /*nOwner*/, oStruELA, /*bPre*/,/*bPos*/)

//bPosVal := {|oModelGrid, nLinha, cAcao, cCampo| If(cAcao=="DELETE" .And. IsDeleted(),ItemDel(),)}
//Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid("ELBDETAIL", "ELAMASTER", oStruELB,  bLinePre, /*bLinePos*/ , /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )

//Modelo de relação entre Capa e Detalhe
  If cTpInvoice == "A"
    ELB->(dbSetOrder(3))
    oModel:SetRelation("ELBDETAIL",{{"ELB_FILIAL", "xFilial('ELB')"}, {"ELB_TPPROC", "cTpInvoice"}, {"ELB_EXPORT", "ELA_EXPORT"}, {"ELB_LOJEXP","ELA_LOJEXP"}, {"ELB_NRINVO", "ELA_NRINVO"}, {"ELB_PROCES", "ELA_PROCES"} } , ELB->(IndexKey(3)))
    oModel:SetPrimaryKey( { "ELA_FILIAL", "ELA_TPPROC", "ELA_EXPORT","ELA_LOJEXP","ELA_NRINVO", "ELA_PROCES"})
  ElseIf cTpInvoice == "V"
    ELB->(dbSetOrder(2))
    oModel:SetRelation("ELBDETAIL",{{"ELB_FILIAL", "xFilial('ELB')"}, {"ELB_TPPROC", "cTpInvoice"}, {"ELB_IMPORT", "ELA_IMPORT"}, {"ELB_LOJIMP","ELA_LOJIMP"}, {"ELB_NRINVO", "ELA_NRINVO"}, {"ELB_PROCES", "ELA_PROCES"} } , ELB->(IndexKey(2)))
    oModel:SetPrimaryKey( { "ELA_FILIAL", "ELA_TPPROC", "ELA_IMPORT","ELA_LOJIMP","ELA_NRINVO", "ELA_PROCES"})
  EndIf

//Definição da Chave Primária
oModel:GetModel("ELBDETAIL"):SetUniqueLine({"ELB_SEQPRC"})
//RRC - 25/11/2013 - Alteração para permitir que seja incluído um novo item na invoice quando chamada ocorrer por execução automática
//Essa alteração também ocorreu na função IS400AtuItens()
If !(Type("lIS400Auto") == "L" .And. lIS400Auto)
   oModel:GetModel("ELBDETAIL"):SetNoInsertLine(.T.)
EndIf
//Adiciona a descrição do Modelo de Dados
oModel:SetDescription("Invoice de Serviços")
oModel:GetModel("ELAMASTER"):SetDescription("Invoice") //Título da Capa
oModel:GetModel("ELBDETAIL"):SetDescription("Itens")   //Título do Detalhe

IF IsInCallStack("IS400Filt")

	For nI:=1 to len(oStruELA :AFIELDS)
	   cCpo:= oStruELA:AFIELDS[nI][3]
	   IF cCpo <> 'ELA_NRINVO'
	      oStruELA:SetProperty(cCpo,MODEL_FIELD_WHEN ,{|| .F. })
	   Else
	      oStruELA:SetProperty(cCpo,MODEL_FIELD_WHEN ,{|| .T. })
	   ENDIF
	Next

	For nI:=1 to len(oStruELB :AFIELDS)
	   cCpo:= oStruELB:AFIELDS[nI][3]
	   oStruELB:SetProperty(cCpo,MODEL_FIELD_WHEN ,{|| .F. })
	Next
EndIF

Return oModel

*------------------------*
Static Function ViewDef()
*------------------------*
//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("ESSIS400")

//Cria a estrutura a ser usada na View
Local oStruELA    := FWFormStruct(2,"ELA",{|cCpo| MostrCpo(cCpo)},)
Local oStruELB    := FWFormStruct(2,"ELB",{|cCpo| MostrCpo(cCpo)},)
Local oView
If Type("cBrwInvFil") <> "O"
   cBrwInvFil :=  "ELA->ELA_TPPROC == EJW->EJW_TPPROC .AND. ELA->ELA_PROCES == EJW->EJW_PROCES"
EndIf
//É necessário filtrar a tabela para que o MVC não permite navegar pelos registros inválidos nas operações de visualização/alteração.
ELA->(dbSetFilter(&("{||"+cBrwInvFil+"}"),cBrwInvFil))

//Cria o objeto de View
oView := FWFormView():New()

//Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_ELA", oStruELA, "ELAMASTER")
oView:AddGrid( "VIEW_ELB", oStruELB, "ELBDETAIL" )

//Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'EMCIMA' , 50 )
oView:CreateHorizontalBox( 'EMBAIXO', 50 )

//Relaciona o ID da View com o "box" para exibição
oView:SetOwnerView("VIEW_ELA", "EMCIMA")
oView:SetOwnerView("VIEW_ELB", "EMBAIXO")

//Remove campo da view
If !lPS400Auto
   oStruELA:RemoveField("ELA_INT")
   oStruELA:RemoveField("ELA_ORIGEM")
EndIf

//Liga a identificação do componente
oView:EnableTitleView("VIEW_ELA", "Invoice", RGB(240,248,255))
oView:EnableTitleView("VIEW_ELB", "Itens", RGB(240,248,255))

oView:bAfterViewActivate := {|oView| ViewAtu(oView)}

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

oView:SetCloseOnOk({||.T.})
oView:bCanActivate := {|oView| AtuView(oView)}//FSY-17/01/2014-botao conhecimento


Return oView

Static Function MostrCpo(cCpo)
Local lRet := .T.

If Type("cTpInvoice") == "C"
   //If cTpInvoice == "V" .And. Alltrim(cCpo) $ "ELA_EXPORT/ELA_LOJEXP/ELA_DSCEXP/ELB_CONDPG"
   If cTpInvoice == "V" .And. Alltrim(cCpo) $ "ELA_EXPINV/ELA_ELJINV/ELA_EDSCIN/ELA_EXPORT/ELA_LOJEXP/ELA_DSCEXP/ELB_CONDPG"
      lRet := .F.
   EndIf
   If cTpInvoice == "A" .And. Alltrim(cCpo) $ "ELA_IMPINV/ELA_ILJINV/ELA_IDSCIN/ELA_IMPORT/ELA_LOJIMP/ELA_DSCIMP/ELB_CONDPG"
      lRet := .F.
   EndIf
EndIf

Return lRet

Static Function ViewAtu(oView)
Local oModel := FWModelActive()
Local nLinha := 0
Local oMdlCap, oMdlDet

If oModel:GetOperation() == 3
    EJW->(dbGoTo(nRegEJW))

	oMdlCap := oModel:GetModel("ELAMASTER")
	oMdlCap:SetValue("ELA_PROCES", EJW->EJW_PROCES)
	//oMdlCap:SetValue("ELA_STTPED", "1")

	/*oMdlDet := oModel:GetModel("EJXDETAIL")
	For nLinha:=1 To oMdlDet:Length()
		oMdlDet:GoLine(nLinha)
		oMdlDet:SetValue("EJX_STTPED", "1")
	Next
	oMdlDet:GoLine(1)*/

	oView:Refresh()
EndIf

Return .T.

Function IS400Relacao(cCampo)
Local uRet   := CriaVar(cCampo,.F.)
Local cAlias := Left(cCampo,3)
Local cInfo  := SubStr(cCampo,5)
Local aOrd   := SaveOrd({"EJW","EJX"})
Local oModel    := FWModelActive()
Local oModelELB := oModel:GetModel("ELBDETAIL")

EJW->(dbGoTo(nRegEJW))
If cCampo == "ELA_INT"
   If Type("lIS400Auto") == "L" .And. lIS400Auto
      cRet := "S"
   Else
      cRet := "N"
   EndIf
EndIf

If cAlias == "ELA" .AND. EJW->(FieldPos("EJW_"+cInfo)) > 0
   uRet := EJW->(FieldGet(FieldPos("EJW_"+cInfo)))
ElseIf cAlias == "ELB" .AND. EJX->(FieldPos("EJX_"+cInfo)) > 0
   If oModelELB:nLine > 0
      uRet := Posicione("EJX",1,xFilial("EJX")+cTpInvoice+EJW->EJW_PROCES+oModelELB:GetValue("ELB_SEQPRC"),"EJX_"+cInfo)
   ElseIf !INCLUI .AND. ELB->(!Eof())
      uRet := Posicione("EJX",1,xFilial("EJX")+cTpInvoice+EJW->EJW_PROCES+ELB->ELB_SEQPRC,"EJX_"+cInfo)
      //MFR 21/11/2019 OSSME-4063   
      if cCampo="ELB_SLDINV" 
        uRet := uRet * if(M->ELA_MOEDA == M->ELA_MOEPD,1,M->ELA_TX_PED/M->ELA_TX_MOE) //SALDO ATUAL                                                                                             
      Endif      
   EndIf
EndIf

RestOrd(aOrd,.T.)
Return uRet

Function IS400Valid(cCampo)
Local lRet := .T.
Local cAlias := Left(cCampo,3)
Local cInfo  := SubStr(cCampo,5)
Local aOrd   := SaveOrd({"EJW","EJX","EEQ"})
Local oModel := FWModelActive()
Local oModelELA := oModel:GetModel("ELAMASTER")
Local oModelELB := oModel:GetModel("ELBDETAIL")
Local aValues
Local cChave    := ""
Local aOrdAlt    := {},cQuery := "" //LRS

Do Case
  Case cCampo $ "ELB_VLCAMB/ELB_VLEXT"
     If (lRet := Positivo())
        EJX->(dbSetOrder(1))
        EJX->(dbSeek(xFilial("EJX")+cTpInvoice+oModelELA:GetValue("ELA_PROCES")+oModelELB:GetValue("ELB_SEQPRC")))

        aValues := aClone(oModel:GetErrorMessage())

        //If (oModelELB:GetValue("ELB_VLCAMB")+oModelELB:GetValue("ELB_VLEXT"))*M->ELA_PARIDA > EJX->EJX_SLDINV .AND. !lIS400Auto
        If !lIS400Auto .AND. (oModelELB:GetValue("ELB_SLDINV") + aValues[9]-aValues[8] < 0 )
           lRet := MsgYesNo("Valor na invoice está maior que o saldo no Processo. Deseja prosseguir?","Aviso")
        EndIf

        If lRet
           IS400SetDiff("ELA_VL_MOE",aValues)
           IS400SetDiff("ELA_"+SubStr(cCampo,5),aValues)
        EndIf
      EndIf
   //RRC - 22/03/2013 - Inserida validação para não permitir gravar chave duplicada
   Case cCampo == "ELA_NRINVO"
      If Type("cTpInvoice") == "C"
         If cTpInvoice == "V"
            cChave := cTpInvoice+Space(AvSx3("ELA_EXPORT",AV_TAMANHO))+Space(AvSx3("ELA_LOJEXP",AV_TAMANHO))+M->ELA_IMPORT+M->ELA_LOJIMP+M->ELA_NRINVO+M->ELA_PROCES
         Else
            cChave := cTpInvoice+M->ELA_EXPORT+M->ELA_LOJEXP+Space(AvSx3("ELA_IMPORT",AV_TAMANHO))+Space(AvSx3("ELA_LOJIMP",AV_TAMANHO))+M->ELA_NRINVO+M->ELA_PROCES
         EndIf
         lRet := ExistChav("ELA",cChave)

		   IF IsInCallStack("IS400Filt")

			   aOrdAlt :=SaveOrd({"ELA","ELB","EL1","EEQ"})

			   If Select("WKELA") > 0
			      WKELA->(DbCloseArea())
			   EndIF

			   If Select("WKELB") > 0
			      WKELB->(DbCloseArea())
			   EndIF

			   If Select("WKEL1") > 0
			      WKEL1->(DbCloseArea())
			   EndIF

			   If Select("WKEEQ") > 0
			      WKEEQ->(DbCloseArea())
			   EndIF

			   If Select("WKEL9") > 0
			      WKEL9->(DbCloseArea())
			   EndIF
			   cQuery := " SELECT ELA_NRINVO "
			   cQuery += " FROM " + RetSqlName("ELA")  + " ELA "
			   cQuery += " Where D_E_L_E_T_ <> '*'"
			   cQuery += " AND ELA_FILIAL = '" + xFilial("ELA") + "'"
			   cQuery += " AND ELA_NRINVO = '" + M->ELA_NRINVO + "'"
			   cQuery += " AND ELA_PROCES = '" + M->ELA_PROCES + "'"
			   If cTpInvoice == "A"
			     cQuery += " AND ELA_EXPORT = '" + M->ELA_EXPORT + "'"
			     cQuery += " AND ELA_LOJEXP = '" + M->ELA_LOJEXP + "'"
			   Else
			     cQuery += " AND ELA_IMPORT = '" + M->ELA_IMPORT + "'"
			     cQuery += " AND ELA_LOJIMP = '" + M->ELA_LOJIMP + "'"
			   EndIF

			   cQuery := ChangeQuery(cQuery)
			   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WKELA", .T., .T.)

			   cQuery := ""

			   cQuery := " SELECT ELB_NRINVO "
			   cQuery += " FROM " + RetSqlName("ELB")  + " ELB "
			   cQuery += " Where D_E_L_E_T_ <> '*'"
			   cQuery += " AND ELB_FILIAL = '" + xFilial("ELB") + "'"
			   cQuery += " AND ELB_NRINVO = '" + M->ELA_NRINVO + "'"
			   cQuery += " AND ELB_PROCES = '" + M->ELA_PROCES + "'"
			   If cTpInvoice == "A"
			     cQuery += " AND ELB_EXPORT = '" + M->ELA_EXPORT + "'"
			   Else
			     cQuery += " AND ELB_IMPORT = '" + M->ELA_IMPORT + "'"
			   EndIF

			   cQuery := ChangeQuery(cQuery)
			   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WKELB", .T., .T.)

			   cQuery := ""

			   cQuery := " SELECT EL1_NRINVO "
			   cQuery += " FROM " + RetSqlName("EL1")  + " EL1 "
			   cQuery += " Where D_E_L_E_T_ <> '*'"
			   cQuery += " AND EL1_FILIAL = '" + xFilial("EL1") + "'"
			   cQuery += " AND EL1_NRINVO = '" + M->ELA_NRINVO + "'"
			   cQuery += " AND EL1_PROCES = '" + M->ELA_PROCES + "'"

			   cQuery := ChangeQuery(cQuery)
			   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WKEL1", .T., .T.)

			   cQuery := ""

			   cQuery := " SELECT EL9_NRINVO "
			   cQuery += " FROM " + RetSqlName("EL9")  + " EL9 "
			   cQuery += " Where D_E_L_E_T_ <> '*'"
			   cQuery += " AND EL9_FILIAL = '" + xFilial("EL9") + "'"
			   cQuery += " AND EL9_NRINVO = '" + M->ELA_NRINVO + "'"
			   cQuery += " AND EL9_PROCES = '" + M->ELA_PROCES + "'"

			   cQuery := ChangeQuery(cQuery)
			   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WKEL9", .T., .T.)

			   cQuery := ""

			   cQuery := " SELECT EEQ_NRINVO "
			   cQuery += " FROM " + RetSqlName("EEQ")  + " EEQ "
			   cQuery += " Where D_E_L_E_T_ <> '*'"
			   cQuery += " AND EEQ_FILIAL = '" + xFilial("EEQ") + "'"
			   cQuery += " AND EEQ_NRINVO = '" + M->ELA_NRINVO + "'"
			   cQuery += " AND EEQ_PROCES = '" + M->ELA_PROCES + "'"

			   cQuery := ChangeQuery(cQuery)
			   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WKEEQ", .T., .T.)

			   If !(WKELA->(Eof()) .AND. WKELA->(Bof())) .OR. !(WKEL1->(Eof()) .AND. WKEL1->(Bof())) .OR.;
			      !(WKEEQ->(Eof()) .AND. WKEEQ->(Bof())) .OR. !(WKELB->(Eof()) .AND. WKELB->(Bof())) .OR.;
			      !(WKEL9->(Eof()) .AND. WKEL9->(Bof()))
			      EasyHelp("Não é possível utilizar este número de invoice, pois já esta cadastrado.","Atenção")
			      lRet := .F.
			   EndIF

			   RestOrd(aOrdAlt,.T.)
		   EndIF

      EndIf

   //Não permite a alterar a moeda caso tenha gerado parcelas pois isso afetaria os pagamentos/faturamentos
   Case cCampo == "ELA_MOEDA"
      lRet := EXISTCPO("SYF",M->ELA_MOEDA,1) //THTS - 17/11/2017 - Foi necessario informar o indice para a funcao, pois quando nao informado ela assume o ultimo indice utilizado
      If Type("cTpInvoice") == "C" .And. lRet
         If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015
            EEQ->(DbSetOrder(4)) //EEQ->EEQ_FILIAL + EEQ->EEQ_NRINVO + EEQ->EEQ_PREEMB + EEQ->EEQ_PARC
            lOk := EEQ->(DbSeek( xFilial("EEQ") + AvKey(M->ELA_NRINVO,"EEQ_NRINVO") + AvKey(cTpInvoice+M->ELA_PROCES,"EEQ_PREEMB")))
         Else
            EEQ->(DbSetOrder(15)) //EEQ_FILIAL+EEQ_TPPROC+EEQ_PROC+EEQ_NRINVO+EEQ_PARC  // GFP - 26/05/2015
            lOk := EEQ->(DbSeek( xFilial("EEQ") + AvKey(cTpInvoice,"EEQ_TPPROC") + AvKey(M->ELA_PROCES,"EEQ_PROCES") + AvKey(M->ELA_NRINVO,"EEQ_NRINVO")))  // GFP - 26/05/2015
         EndIf
         If lOk
            EasyHelp("Já existem parcelas associadas a esta invoice. Não é permitido alterar a moeda.")
            lRet := .F.
         EndIf
      EndIf



   Case cCampo == "ELA_IMPINV"      
      If !(lRet := EXISTCPO("SA1",oModelELA:GetVAlue("ELA_IMPINV")))
         EasyHelp("O código do importador informado não é um registro válido")
      EndIf
      If lRet .And. SA1->(DbSeek(xFilial("SA1")+oModelELA:GetVAlue("ELA_IMPINV")+IF(!Empty(oModelELA:GetVAlue("ELA_ILJINV")), oModelELA:GetVAlue("ELA_ILJINV"), "" )))
         //RRC - 21/08/2013 - Criado MV_ESS0015 para permitir ou não a inclusão do processo com cliente ou fornecedor nacional, fazendo neste caso,
         //a validação apenas no RAS ou RVS
         If !EasyGParam("MV_ESS0015",,.T.)            
            If !Empty(oModelELA:GetVAlue("ELA_ILJINV")) .And. !IsForeign("SA1", oModelELA:GetVAlue("ELA_IMPINV")+oModelELA:GetVAlue("ELA_ILJINV"))
               lRet := .F.
               EasyHelp("Só é permitido utilizar cliente estrangeiro para exportação de serviço.","Aviso")            
            EndIf                       
         EndIf
         If lRet
            oModelELA:SetValue("ELA_IDSCIN", SA1->A1_NOME)               
         EndIf   
      EndIf
   Case cCampo == "ELA_ILJINV"
      If !Vazio()
         If !(lRet := EXISTCPO("SA1",oModelELA:GetVAlue("ELA_IMPINV")+oModelELA:GetVAlue("ELA_ILJINV")))
            EasyHelp("O código do importador informado não é um registro válido")
         EndIf
         If lRet .And. SA1->(DbSeek(xFilial("SA1")+oModelELA:GetVAlue("ELA_IMPINV")+IF(!Empty(oModelELA:GetVAlue("ELA_ILJINV")), oModelELA:GetVAlue("ELA_ILJINV"), "" )))
            //RRC - 21/08/2013 - Criado MV_ESS0015 para permitir ou não a inclusão do processo com cliente ou fornecedor nacional, fazendo neste caso,
            //a validação apenas no RAS ou RVS
            If !EasyGParam("MV_ESS0015",,.T.)            
               If !IsForeign("SA1", oModelELA:GetVAlue("ELA_IMPINV")+oModelELA:GetVAlue("ELA_ILJINV"))
                  lRet := .F.
                  EasyHelp("Só é permitido utilizar cliente estrangeiro para exportação de serviço.","Aviso")                 
               EndIf            
            EndIf
            If lRet
               oModelELA:SetValue("ELA_IDSCIN", SA1->A1_NOME)               
            EndIf                        
         EndIf
      EndIf
   Case cCampo == "ELA_EXPINV"
      //RRC - 21/08/2013 - Criado MV_ESS0015 para permitir ou não a inclusão do processo com cliente ou fornecedor nacional, fazendo neste caso,
      //a validação apenas no RAS ou RVS
      If !EasyGParam("MV_ESS0015",,.T.)
         //A validação por ExistCpo() está seperada para que caso esta retorna .F., exiba a mensagem de que o item não existe
         If (lRet := EXISTCPO("SA2",M->ELA_EXPINV)) //.AND. !Empty(PS400Info("EJW_LOJEXP")) .And. !IsForeign("SA2", M->EJW_EXPORT+PS400Info("EJW_LOJEXP"))
            lRet := .F.
            EasyHelp("Só é permitido utilizar fornecedor estrangeiro para importação de serviço.","Aviso")
         EndIf
      Else
         IF lRet := EXISTCPO("SA2",M->ELA_EXPINV) //MCF - 11/03/2015
            IF SA2->(DbSeek(xFilial("SA2")+M->ELA_EXPINV+M->ELA_ELJINV))
               M->ELA_EDSCIN := SA2->A2_NOME
            ENDIF
         ENDIF
      EndIf
   Case cCampo == "ELA_ELJINV"
      If !Vazio()
         //RRC - 21/08/2013 - Criado MV_ESS0015 para permitir ou não a inclusão do processo com cliente ou fornecedor nacional, fazendo neste caso,
         //a validação apenas no RAS ou RVS
         If !EasyGParam("MV_ESS0015",,.T.)
             //A validação por ExistCpo() está seperada para que caso esta retorna .F., exiba a mensagem de que o item não existe
            If (lRet := EXISTCPO("SA2",M->ELA_EXPINV+M->ELA_ELJINV)) .AND. !IsForeign("SA2", M->ELA_EXPINV+M->ELA_ELJINV)
               lRet := .F.
               EasyHelp("Só é permitido utilizar fornecedor estrangeiro para importação de serviço.","Aviso")
            EndIf
         Else
            IF lRet := EXISTCPO("SA2",M->ELA_EXPINV+M->ELA_ELJINV) //MCF - 11/03/2015
               IF SA2->(DbSeek(xFilial("SA2")+M->ELA_EXPINV+M->ELA_ELJINV))
                  M->ELA_EDSCIN := SA2->A2_NOME
               ENDIF
            ENDIF
         EndIf
      EndIf




EndCase
RestOrd(aOrd,.T.)
Return lRet

Function IS400AtuItens()
Local oModel    := FWModelActive()
Local oView     := FWViewActive()
Local oModelELA := oModel:GetModel("ELAMASTER")
Local oModelELB := oModel:GetModel("ELBDETAIL")
Local aOrd      := SaveOrd({"EJX","EJW"}) //Guarda índices da capa e da origem dos campos cujos conteúdos serão retornados ao grid
Local nCont

EJW->(dbSetOrder(1))
If EJW->(DbSeek(xFilial("EJW") + cTpInvoice + AvKey(M->ELA_PROCES,"EJW_PROCES")))
   //RRC - 21/08/2013
   //RMD - Verifica se, quando veio do EEC, o ambiente está configurado para gerar cambio. Se não estiver, utiliza a condição de pagamento para criar o câmbio do SISCOSERV
   //If Type("lIS400Auto") == "L" .And. !lIS400Auto .And. (oModel:GetOperation() == 3 .Or. Empty(ELA->ELA_CONDPG))
   If Type("lIS400Auto") == "L" .And. (!lIS400Auto .Or. (IsInCallStack("AE100ESS") .And. !AvFlags("FRESEGCOM"))) .And. (oModel:GetOperation() == 3 .Or. Empty(ELA->ELA_CONDPG))
      oModelELA:SetValue("ELA_CONDPG",EJW->EJW_CONDPG)
   EndIf
   oModelELB:SetNoInsertLine(.F.)
   EJX->(DbSetOrder(1))
   EJX->(DbSeek(xFilial("EJX")+cTpInvoice+AvKey(M->ELA_PROCES,"EJX_PROCES")))
   Do While EJX->(!EOF()) .And. xFilial("EJX") == EJX->EJX_FILIAL .And. cTpInvoice == EJX->EJX_TPPROC .And. M->ELA_PROCES == EJX->EJX_PROCES
      If !Empty(oModelELB:GetValue("ELB_SEQPRC"))
         ForceAddLine(oModelELB)
      EndIf

      oModelELB:SetValue("ELB_SEQPRC",EJX->EJX_SEQPRC)
      oModelELB:SetValue("ELB_ITEM"  ,EJX->EJX_ITEM)
      oModelELB:SetValue("ELB_NBS"   ,EJX->EJX_NBS)
      oModelELB:SetValue("ELB_QTDE"  ,EJX->EJX_QTDE)
      oModelELB:SetValue("ELB_PRCUN" ,EJX->EJX_PRCUN)
      oModelELB:SetValue("ELB_VL_MOE",EJX->EJX_VL_MOE)
      oModelELB:SetValue("ELB_SLDINV",EJX->EJX_SLDINV)

      EJX->(DbSkip())
   EndDo

   If !lIS400Auto
      //RRC - 25/11/2013 - Alteração para permitir que seja incluído um novo item na invoice quando chamada ocorrer por execução automática
      //Essa alteração também ocorreu na função modeldef()
      oModelELB:SetNoInsertLine(.T.)
      oView:GETVIEWOBJ("ELAMASTER")[3]:Refresh()
      oModelELB:GoLine(1)
   EndIf
EndIf

RestOrd(aOrd,.T.)
Return M->ELA_PROCES

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

Function IS400Get(cCampo)
Local cRet := ""
Default cCampo := ""
//RRC - 26/03/2013
Do Case
   Case cCampo == "ELA_STTPAG"
      cRet := "1" //"Em aberto"
EndCase
Return cRet

Function IS400Info(cCampo)
Local oModel    := FWModelActive()

If Left(cCampo,3) == "ELB"
   oModelData := oModel:GetModel("ELBDETAIL")
Else
   oModelData := oModel:GetModel("ELAMASTER")
EndIf

Return oModelData:GetValue(cCampo)

Function IS400Gat()
Return IsInCallStack("SETVALUE") .AND. IsInCallStack("RUNTRIGGER")

Static Function IS400Grava(oModel)
Local lRet := .T.
Local oModelELB := oModel:GetModel("ELBDETAIL")
Local i
Local aOrd := SaveOrd({"ELA","EJW","EEQ","EJZ"})
Local lGeraPagto := INCLUI .OR. (oModel:GetOperation() == EXCLUIR .AND. !EasyGParam("MV_ESS0027",,9) >= 10) .OR. ELA->ELA_DTEMIS <> M->ELA_DTEMIS
Local aProcessos := {}
Local cChave     := ""
Local lLiq       := .F.
Local lExistParc := .F.
Local aRegist    := {}
Local aCab       := {}
Local aItens     := {}
Local aItemProc  := {}
Local aItensAuto := {}
Local nOpc       := oModel:GetOperation()
Local nValDif    := 0
Local nI         := 1
Local lAtuPed    := EasyGParam("MV_ESS0005",,.T.)//Verifica se deve atualizar o Processo caso o valor da invoice seja superior
Local cCond      := ""
Local aOrdAlt    := {} //LRS
Local lIntegra   := ((EasyGParam("MV_ESS0012",,.F.) .And. EasyGParam("MV_AVG0226",,.F.)) .OR. (EasyGParam("MV_AVG0226",,.F.) .And. EasyGParam("MV_ESS0013",,.F.) ) )  //LRS
Local lTroca     := .T. //LRS
Local cAviso := ""

Private cUltParc := ""  // GFP - 22/01/2014
//RRC - 13/11/2013 - Valida a filial selecionada para incluir a invoice
If !lIS400Auto .And. xFilial("ELA") <> EJW->EJW_FILIAL
   EasyHelp("A filial selecionada para a invoice é diferente da utilizada pelo Processo relacionado.","Aviso")
   Return .F.
EndIf

Begin Transaction

IF IsInCallStack("IS400Filt")

   aOrdAlt :=SaveOrd({"ELA","ELB","EL1","EEQ"})

   If AllTrim(ELA->ELA_ORIGEM) == "SIGAESS"
      If EasyGParam("MV_ESS0016",,.F.) .OR. EasyGParam("MV_ESS0017",,.F.)
         cAviso := "A alteração do Número da Invoice ocasionará a perda de histórico dos títulos gerados no módulo Financeiro (SIGAFIN)." + ENTER +;
                   "Deseja prosseguir?"
         lTroca := MsgNoYes(cAviso,"Atenção")
      EndIf
   Else
      cAviso := "A Invoice deste processo foi gerada " + If(AllTrim(ELA->ELA_ORIGEM) == "C100","via 'Integração CSV","pelo módulo '"+AllTrim(ELA->ELA_ORIGEM)) + "'." + ENTER +;
                "Desta forma, não será possível alterá-la."
      MsgStop(cAviso,"Atenção")
      lTroca := .F.
   EndIf

	   IF lTroca

	       //LRS - 14/04/2016 - Seek tabelas ELB, EL1 e El9 com as informações da ELA.
		   If cTpInvoice == "A"
		      ELB->(dbSetOrder(3))
		      ELB->(dbSeek(xFilial("ELB")+cTpInvoice+M->ELA_EXPORT+M->ELA_LOJEXP+ELA->ELA_NRINVO+ELA->ELA_PROCES+oModelELB:GetValue("ELB_SEQPRC")))
		   ElseIf cTpInvoice == "V"
		      ELB->(dbSetOrder(2))
		      ELB->(dbSeek(xFilial("ELB")+cTpInvoice+M->ELA_IMPORT+M->ELA_LOJIMP+ELA->ELA_NRINVO+ELA->ELA_PROCES+oModelELB:GetValue("ELB_SEQPRC")))
		   EndIf

		   EL1->(DbSetOrder(3))
		   IF EL1->(DbSeek(xFilial("EL1")+cTpInvoice+AvKey(ELA->ELA_PROCES,"EL1_PROCES")))
		      EL9->(DbSetOrder(3))
		      EL9->(DbSeek(xFilial("EL9")+cTpInvoice+AvKey(EL1->EL1_REGIST,"EL9_REGIST")+AvKey(ELA->ELA_PROCES,"EL9_PROCES")+AvKey(ELA->ELA_NRINVO,"EL9_NRINVO")))
		   EndIF

	       cNumInv    := M->ELA_NRINVO
		   cOldNumInv := ELA->ELA_NRINVO

		  //LRS - 13/04/2016 - Esse Momento, todas as tabelas estão posicionadas no processo correto
		  DO While ELA->(!Eof().AND. ELA->ELA_FILIAL == xFilial("ELA") .AND. ELA->ELA_NRINVO == cOldNumInv .AND.;
		  IF(cTpInvoice == "A", ELA->ELA_EXPORT == M->ELA_EXPORT,ELA->ELA_IMPORT == M->ELA_IMPORT) .AND. ;
		  IF(cTpInvoice == "A", ELA->ELA_LOJEXP == M->ELA_LOJEXP,ELA->ELA_LOJIMP == M->ELA_LOJIMP) )
			   ELA->( RECLOCK("ELA",.F.) )
			   ELA->ELA_NRINVO := cNumInv
			   ELA->(MSUNLOCK())

			   ELA->(DbSkip())
		   EndDo

		   DO While ELB->(!Eof() .AND. ELB->ELB_FILIAL == xFilial("ELB") .AND. ELB->ELB_TPPROC == cTpInvoice .AND.;
		   ELB->ELB_PROCES == M->ELA_PROCES .AND. ELB->ELB_NRINVO == cOldNumInv .AND.;
		   IF(cTpInvoice == "A", ELB->ELB_EXPORT == M->ELA_EXPORT,ELB->ELB_IMPORT == M->ELA_IMPORT) .AND. ;
		   IF(cTpInvoice == "A", ELB->ELB_LOJEXP == M->ELA_LOJEXP,ELB->ELB_LOJIMP == M->ELA_LOJIMP) )
			   ELB->( RECLOCK("ELB",.F.) )
			   ELB->ELB_NRINVO := cNumInv
			   ELB->(MSUNLOCK())

			   ELB->(DbSkip())
		   EndDo

		   DO While EL1->(!Eof() .AND. EL1->EL1_FILIAL == xFilial("EL1") .AND. EL1->EL1_PROCES == M->ELA_PROCES .AND.;
		    EL1->EL1_NRINVO == cOldNumInv )
			   EL1->( RECLOCK("EL1",.F.) )
			   EL1->EL1_NRINVO := cNumInv
			   EL1->(MSUNLOCK())

			   EL1->(DbSkip())
		   EndDo

		   DO While EEQ->(!Eof() .AND. EEQ->EEQ_FILIAL == xFilial("EEQ") .AND. EEQ->EEQ_NRINVO == cOldNumInv .AND.;
		    EEQ->EEQ_PROCES == M->ELA_PROCES)
			   EEQ->( RECLOCK("EEQ",.F.) )
			   EEQ->EEQ_NRINVO := cNumInv
			   EEQ->(MSUNLOCK())

			   EEQ->(DbSkip())
		   EndDo

		   DO While EL9->(!Eof() .AND. EL9->EL9_FILIAL == xFilial("EL9") .AND. EL9->EL9_TPPROC == cTpInvoice .AND.;
		   EL9->EL9_PROCES == M->ELA_PROCES .AND. EL9->EL9_NRINVO == cOldNumInv )

			   EL9->( RECLOCK("EL9",.F.) )
			   EL9->EL9_NRINVO := cNumInv
			   IF EL9->EL9_STTSIS == '2'
			      EL9->EL9_STTSIS := '5'
			   EndIF
			   EL9->(MSUNLOCK())

			   EL9->(DbSkip())
		   EndDo
	   EndIF

   WKELA->(DbCloseArea())
   WKELB->(DbCloseArea())
   WKEL1->(DbCloseArea())
   WKEEQ->(DbCloseArea())
   WKEL9->(DbCloseArea())

   RestOrd(aOrdAlt,.T.)

ELSE

//RRC - 26/03/2013 - Verifica se existe parcela liquidada associada a invoice, caso não haja e seja uma alteração, deleta e gere as parcelas novamente
If nOpc != EXCLUIR
   If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015
      EEQ->(DbSetOrder(4)) //EEQ->EEQ_FILIAL + EEQ->EEQ_NRINVO + EEQ->EEQ_PREEMB + EEQ->EEQ_PARC
      cChave := xFilial("EEQ") + AvKey(M->ELA_NRINVO,"EEQ_NRINVO") + AvKey(cTpInvoice+M->ELA_PROCES,"EEQ_PREEMB")
      cCond := 'xFilial("EEQ") + EEQ->EEQ_NRINVO + EEQ->EEQ_PREEMB'
   Else
      EEQ->(DbSetOrder(15)) //EEQ_FILIAL+EEQ_TPPROC+EEQ_PROC+EEQ_NRINVO+EEQ_PARC  // GFP - 26/05/2015
      cChave := xFilial("EEQ") + AvKey(cTpInvoice,"EEQ_TPPROC") + AvKey(M->ELA_PROCES,"EEQ_PROCES") + AvKey(M->ELA_NRINVO,"EEQ_NRINVO")  // GFP - 26/05/2015
      cCond := 'EEQ->(xFilial("EEQ") + EEQ_TPPROC + EEQ->EEQ_PROCES + EEQ_NRINVO)'
   EndIf
   If (lExistParc := EEQ->(DbSeek(cChave)))
      Do While !lLiq .And. EEQ->(!Eof()) .And. cChave == &cCond  // GFP - 26/05/2015
         lLiq := !Empty(EEQ->EEQ_PGT)
         EEQ->(DbSkip())
      EndDo
   EndIf
EndIf
If Type("lIS400Auto") == "U" .Or. !lIS400Auto
   If lLiq
      EasyHelp("Já existem parcelas liquidadas associadas a essa invoice, o sistema não fará a atualização automática das parcelas.","Aviso")
   ElseIf lExistParc
      EasyHelp("Já existem parcelas associadas a essa invoice, o sistema não fará a atualização automática das parcelas.","Aviso")
   EndIf
EndIf

EJX->(DbSetOrder(1))
If cTpInvoice == "A"
   ELB->(dbSetOrder(3))//ELB_FILIAL+ELB_TPPROC+ELB_EXPORT+ELB_LOJEXP+ELB_NRINVO+ELB_PROCES+ELB_SEQPRC
ElseIf cTpInvoice == "V"
   ELB->(dbSetOrder(2))//ELB_FILIAL+ELB_TPPROC+ELB_IMPORT+ELB_LOJIMP+ELB_NRINVO+ELB_PROCES+ELB_SEQPRC
EndIf

For i := 1 To oModelELB:Length()
   oModelELB:GoLine(i)
   If EJX->(dbSeek(xFilial("EJX") + AvKey(cTpInvoice,"EJX_TPPROC") + M->ELA_PROCES + oModelELB:GetValue("ELB_SEQPRC")))
      EJX->(RecLock("EJX",.F.))

      If nOpc != INCLUIR
         If cTpInvoice == "A"
            ELB->(dbSeek(xFilial("ELB")+cTpInvoice+M->ELA_EXPORT+M->ELA_LOJEXP+M->ELA_NRINVO+M->ELA_PROCES+oModelELB:GetValue("ELB_SEQPRC")))
         ElseIf cTpInvoice == "V"
            ELB->(dbSeek(xFilial("ELB")+cTpInvoice+M->ELA_IMPORT+M->ELA_LOJIMP+M->ELA_NRINVO+M->ELA_PROCES+oModelELB:GetValue("ELB_SEQPRC")))
         EndIf
         EJX->EJX_SLDINV += (ELB->ELB_VLCAMB+ELB->ELB_VLEXT)*ELA->ELA_PARIDA
      EndIf

      If !lGeraPagto
         lGeraPagto := (ELB->ELB_VLCAMB+ELB->ELB_VLEXT)*ELA->ELA_PARIDA <> (oModelELB:GetValue("ELB_VLCAMB")+oModelELB:GetValue("ELB_VLEXT"))*M->ELA_PARIDA
      EndIf

      If nOpc != EXCLUIR
         //RRC - Caso o valor da invoice seja maior que do processo, altera no processo
         If lAtuPed .And. Round((oModelELB:GetValue("ELB_VLCAMB")+oModelELB:GetValue("ELB_VLEXT"))*M->ELA_PARIDA,AvSx3("EJX_SLDINV",AV_DECIMAL)) > EJX->EJX_SLDINV
            //RRC - 30/10/2013 - Atualização para considerar a quantidade do serviço (EJX_QTDE)
            nValDif := ((oModelELB:GetValue("ELB_VLCAMB")+oModelELB:GetValue("ELB_VLEXT"))*M->ELA_PARIDA - EJX->EJX_SLDINV)/EJX->EJX_QTDE
            aAdd(aItemProc,{EJX->EJX_SEQPRC,Round(EJX->EJX_PRCUN+nValDif,AvSx3("EJX_PRCUN",AV_DECIMAL)),EJX->EJX_MODO})
         EndIf
            EJX->EJX_SLDINV -= (oModelELB:GetValue("ELB_VLCAMB")+oModelELB:GetValue("ELB_VLEXT"))*M->ELA_PARIDA
            //MFR 21/11/2109 OSSME-4063
            oModelELB:SetValue("ELB_SLDINV",EJX->EJX_SLDINV*if(M->ELA_MOEDA == M->ELA_MOEPD,1,M->ELA_TX_PED/M->ELA_TX_MOE)) //SALDO ATUAL

      EndIf

      EJX->(aAdd(aProcessos,{EJX_PROCES,EJX_SEQPRC,.F.}))
      EJX->(MsUnlock())
   EndIf
Next i

//Salva as operações efetuadas anteriormente
lRet := FWFormCommit(oModel)

ELA->( RECLOCK("ELA",.F.) )
ELA->ELA_TPPROC := cTpInvoice
//LRS - 26/04/2016
IF Type("lIS400Auto") == "L" .And. lIS400Auto

ENDIF
ELA->(MSUNLOCK())

If !lRet
   DisarmTransaction()
Else
   //RRC - 26/03/2013 - Deleta as parcelas associadas a invoice caso não haja nenhuma liquidada, depois gera novas parcelas
   If lExistParc .And. !lLiq
      If cTpInvoice == "V" .And. lGeraPagto
         //RRC - 02/04/2013
         //Para vendas, a invoice gera um faturamento, sendo assim, deve alterá-lo também
         If !IS400GeraPgto(nOpc,ELA->ELA_TPPROC,ELA->ELA_PROCES,ELA->ELA_NRINVO)
            DisarmTransaction()
            Break
         EndIf
      EndIf
   ElseIf cTpInvoice == "V" .And. lGeraPagto .And. nOpc == ALTERAR
      //RRC - 28/03/2013 - Tratamento para Incluir/Alterar os pagamentos (EL9) com base nos Registros (EJY - capa e EJZ - Itens) em que estão associados ao Processo (EJW)
      //Se for uma exclusão, esta operação é realizada durante a função IS400DelInv(), sendo assim, esta condição é válida apenas para alteração
      If !IS400GeraPgto(nOpc,ELA->ELA_TPPROC,ELA->ELA_PROCES,ELA->ELA_NRINVO)
         DisarmTransaction()
         Break
      EndIf
      //RS400AssociaPed(aProcessos,cTpInvoice)
   EndIf
EndIf
EndIF

End Transaction

IF !IsInCallStack("IS400Filt")
If cTpInvoice == "V" .And. lGeraPagto .And. nOpc == INCLUIR
	   //RRC - 28/03/2013 - Tratamento para Incluir os pagamentos (EL9) com base nos Registros (EJY - capa e EJZ - Itens) em que estão associados ao Processo (EJW)
	   IS400GeraPgto(nOpc,ELA->ELA_TPPROC,ELA->ELA_PROCES,ELA->ELA_NRINVO)
	   //RS400AssociaPed(aProcessos,cTpInvoice)
	EndIf

	//RRC - 25/03/2013 - Gera automaticamente as parcelas de uma invoice com a condição de pagamento
	If nOpc!= EXCLUIR .And. !lExistParc .And. !Empty(ELA->ELA_CONDPG)
	   IS400GerParc()
	EndIf

	If nOpc!=EXCLUIR
	   IS400StaInv()
	EndIf
	//Atualiza a capa do processo se necessário
	For nI := 1 To Len(aItemProc)
	   aItens := {}
	   aAdd(aItens,{"EJX_FILIAL" , ELA->ELA_FILIAL  , Nil })
	   aAdd(aItens,{"EJX_TPPROC" , ELA->ELA_TPPROC  , Nil })
	   aAdd(aItens,{"EJX_PROCES" , ELA->ELA_PROCES  , Nil })
	   aAdd(aItens,{"EJX_SEQPRC" , aItemProc[nI][1] , Nil })
	   aAdd(aItens,{"EJX_PRCUN"  , aItemProc[nI][2] , Nil })
	   If ELA->ELA_TPPROC == "A"
	      aAdd(aItens,{"EJX_MODAQU"  , aItemProc[nI][3] , Nil })
	   ElseIf ELA->ELA_TPPROC == "V"
	      aAdd(aItens,{"EJX_MODVEN"  , aItemProc[nI][3] , Nil })
	   EndIf
	   aAdd(aItensAuto,aClone(aItens))
	Next nI

	If Len(aItemProc) > 0
	   aCab := {}
	   aAdd(aCab,{"EJW_FILIAL"   , ELA->ELA_FILIAL , Nil })
	   aAdd(aCab,{"EJW_TPPROC"   , ELA->ELA_TPPROC , Nil })
	   aAdd(aCab,{"EJW_PROCES"   , ELA->ELA_PROCES , Nil })

	   If cTpInvoice == "A"
	      MSExecAuto({|a,b,c,d,e| EICPS400(a,b,c,d,e)},aCab,aItensAuto,,ALTERAR,.T.)
	   ElseIf cTpInvoice == "V"
	      MSExecAuto({|a,b,c,d,e| EECPS400(a,b,c,d,e)},aCab,aItensAuto,,ALTERAR,.T.)
	   EndIf
	EndIf

	//RRC - 20/05/2013 - Caso já tenha atualizado os dados do processo, já executou a função PS400StaPag() pela chamada do fonte ESSPS400.PRW
	If Len(aItemProc) == 0
	   //RRV - 02/04/2013 - Atualiza o status de pagamento.
	   PS400StaPag(cTpInvoice, M->ELA_PROCES)
	EndIf

	RestOrd(aOrd,.T.)
EndIF

Return lRet

Function IS400SetDiff(cDestino,aErrMsg)
Local oModel    := FWModelActive()
Default aErrMsg   := oModel:GetErrorMessage()

If Valtype(aErrMsg[8]) == AvSx3(cDestino,2) .And. Valtype(aErrMsg[9]) == AvSx3(cDestino,2)
   //Atualiza conteúdo de campo de Processo de Serviços
   oModel:SetValue("ELAMASTER",cDestino,oModel:GetValue("ELAMASTER",cDestino)+aErrMsg[8]-aErrMsg[9])
EndIf

Function IS400Gatilho(cCampoOrigem,cCampoDest)
Local uRet
Local oModel    := FWModelActive()
Local oModelELB := oModel:GetModel("ELBDETAIL")

If cCampoDest == "ELB_SLDINV" .AND. oModelELB:nLine > 0
   uRet := EJX->EJX_SLDINV*if(M->ELA_MOEDA == M->ELA_MOEPD,1,M->ELA_TX_PED/M->ELA_TX_MOE) //SALDO ATUAL

   If cTpInvoice == "A"
      ELB->(dbSetOrder(3))
      ELB->(dbSeek(xFilial("ELB")+cTpInvoice+M->ELA_EXPORT+M->ELA_LOJEXP+M->ELA_NRINVO+M->ELA_PROCES+oModelELB:GetValue("ELB_SEQPRC")))
   ElseIf cTpInvoice == "V"
      ELB->(dbSetOrder(2))
      ELB->(dbSeek(xFilial("ELB")+cTpInvoice+M->ELA_IMPORT+M->ELA_LOJIMP+M->ELA_NRINVO+M->ELA_PROCES+oModelELB:GetValue("ELB_SEQPRC")))
   EndIf

   uRet += ELB->(ELB_VLCAMB+ELB_VLEXT) //ESTORNO DO VALOR ANTERIOR  
   If cCampoOrigem == "ELB_VLCAMB"
      uRet -= M->ELB_VLCAMB+oModelELB:GetValue("ELB_VLEXT") //BAIXA DO VALOR ATUAL
   ElseIf cCampoOrigem == "ELB_VLEXT"
      uRet -= M->ELB_VLEXT+oModelELB:GetValue("ELB_VLCAMB") //BAIXA DO VALOR ATUAL
      //MFR 21/11/2019 OSSME-4063
   ElseIf cCampoOrigem == ""
      oModelELB:SetValue("ELB_SLDINV",uRet)
   EndIf   
EndIf

Return uRet

Static Function IS400FaturaTodos()
Local i
Local nValorCamb, nValorExt
Local oModel    := FWModelActive()
Local oModelELB := oModel:GetModel("ELBDETAIL")
Local nOldLine  := oModelELB:nLine
Local oDlg
Local nValorItem
//Local cCriterio := "SLDINV"
Local cCriterio := "VL_MOE"
Local oUpdEs400 //THTS - 19/07/2017

cSelect := "SELECT SUM(EJX_"+cCriterio+") AS TOTAL "
cSelect += "FROM "+RetSqlName("EJX")+" EJX "                                                  //RRC - 29/07/2013 - Adicionada condição para buscar o Tipo de Processo
cSelect += "WHERE EJX.EJX_FILIAL = '"+xFilial("EJX")+"' AND EJX.EJX_PROCES = '"+M->ELA_PROCES+If(Type("cTpInvoice")=="C","' AND EJX.EJX_TPPROC = '"+cTpInvoice,"")+"' AND EJX.D_E_L_E_T_ = ''"

If Select("WKTOTAL") > 0
   WKTOTAL->(dbCloseArea())
EndIf

cSelect := ChangeQuery(cSelect) //RRC - 04/11/2013 - Necessário devido a diferença entre sintaxe requerida pelo SQL Server e o Oracle
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSelect),"WKTOTAL",.F.,.F.)
TcSetField("WKTOTAL","TOTAL","N",AVSX3("ELB_SLDINV",3),AVSX3("ELB_SLDINV",4))

nSldTot := nSldCamb := WKTOTAL->TOTAL * if(M->ELA_MOEDA <> M->ELA_MOEPD,M->ELA_TX_PED / M->ELA_TX_MOE,1)
nSldExt  := 0

WKTOTAL->(dbCloseArea())

If ALTERA .AND. cCriterio == "SLDINV"
   nSldTot += ELA->ELA_VL_MOE
EndIf

If lIS400Auto
   nSldCamb := aValFatura[1]
   nSldExt  := aValFatura[2]
EndIf

//THTS - 19/07/2017 - Atualiza o conteudo das perguntas do SX1
If FindFunction("AvUpdate01")
   oUpdEs400 := AvUpdate01():New()
EndIf

If ValType(oUpdEs400) == "O"
  oUpdEs400:aChamados := {{nModulo,{|o| UPDX1ES400(o)},.F.}}
  oUpdEs400:Init(,.T.)
EndIf

If Pergunte("ESSIS400",!lIS400Auto)
   nValorCamb := if(MV_PAR01>0,MV_PAR01,0)
   nValorExt  := if(MV_PAR02>0,MV_PAR02,0)

   oRatCamb := EasyRateio():New(nValorCamb,nSldTot,oModelELB:Length(),AvSX3("ELB_VLCAMB",AV_DECIMAL))
   oRatExt  := EasyRateio():New(nValorExt ,nSldTot,oModelELB:Length(),AvSX3("ELB_VLEXT" ,AV_DECIMAL))

   For i := 1 To oModelELB:Length()
      oModelELB:GoLine(i)

      if cCriterio == "SLDINV"
         nValorItem := oModelELB:GetValue("ELB_SLDINV")+oModelELB:GetValue("ELB_VLCAMB")+oModelELB:GetValue("ELB_VLEXT")
      else
         nValorItem := oModelELB:GetValue("ELB_"+cCriterio)
      EndIf

      oModelELB:SetValue("ELB_VLCAMB", oRatCamb:GetItemRateio(nValorItem))
      oModelELB:SetValue("ELB_VLEXT" , oRatExt:GetItemRateio(nValorItem))

   Next i

EndIf

oModelELB:GoLine(nOldLine)

Return .T.

Static Function ValidaIntegracao(nOpcAuto,aCab,aDet)
Local lRet := .T.

Begin Sequence

   //Campo obrigatório apenas para inclusão via ExecAuto
   If nOpcAuto == 3
      nPos := aScan(aCab,{|x|x[1]=="ELA_ORIGEM"})
      If nPos == 0 .OR. Empty(aCab[nPos])
         EasyHelp("A origem da integração deve ser informada.","Aviso")
         lRet := .F.
         Break
      EndIf
   EndIf

   //CodToMoney(aCab) - LGS

   nPos := aScan(aCab,{|x|x[1]=="ELA_EXPORT"})
   If nPos > 0 .AND. cTpInvoice == "V"
      EasyHelp("Integração não permitida. O exportador não deve ser informado para processo de venda de serviço.","Aviso")
      lRet := .F.
      Break
   EndIf

   nPos := aScan(aCab,{|x|x[1]=="ELA_IMPORT"})
   If nPos > 0 .AND. cTpInvoice == "A"
      EasyHelp("Integração não permitida. O importador não deve ser informado para processo de aquisição de serviço.","Aviso")
      lRet := .F.
      Break
   EndIf

   //Retira do Array caso os campos a seguir sejam previamentes informados, estes campos não são editáveis e serão preenchidos automaticamente
   nPos := aScan(aCab,{|x|x[1]=="ELA_VL_MOE"})
   If nPos > 0
      aDel(aCab,nPos)
      aSize(aCab,Len(aCab)-1)
   EndIf

   nPos := aScan(aCab,{|x|x[1]=="ELA_VL_REA"})
   If nPos > 0
      aDel(aCab,nPos)
      aSize(aCab,Len(aCab)-1)
   EndIf

   nPos := aScan(aCab,{|x|x[1]=="ELA_FILIAL"})
   If nPos == 0
      aAdd(aCab,{"ELA_FILIAL",xFilial("ELA"),NIL})
      /*aDel(aCab,nPos)
      aSize(aCab,Len(aCab)-1)*/
   EndIf

   nPos := aScan(aCab,{|x|x[1]=="ELA_INT"})
   If nPos == 0
      aAdd(aCab,{"ELA_INT","S",NIL})
      /*aDel(aCab,nPos)
      aSize(aCab,Len(aCab)-1)*/
   EndIf

   //Adiciona Tipo de processo
   nPos := aScan(aCab,{|x|x[1]=="ELA_TPPROC"})
   If nPos == 0
      aAdd(aCab,{"ELA_TPPROC",cTpInvoice,NIL})
      /*aDel(aCab,nPos)
      aSize(aCab,Len(aCab)-1)*/
   EndIf

   nPos := aScan(aCab,{|x|x[1]=="ELA_MOEDA"})
   If nPos > 0
      //RRC - 04/09/2013 - Tratamento para permitir a inclusão da moeda de acordo com o código do SIGAFIN para integração de arquivo texto (ESSIN100)
      If (ValType(aCab[nPos][2]) == "N" .Or. (ValType(aCab[nPos][2]) == "C" .And. IsInCallStack("ESSIN100")))
         If ValType(aCab[nPos][2]) == "C"
			IF Val(aCab[nPos][2]) > 0 .OR. Upper(AllTrim(aCab[nPos][2])) == Replicate("0",Len(Upper(AllTrim(aCab[nPos][2]))))
			   aCab[nPos][2] := Val(aCab[nPos][2])
			EndIf
         EndIf

         //RMD - 26/11/14 - Somente volta para caracter se o campo for do tipo numérico.
		 If ValType(aCab[nPos][2]) == "N"
			If !Empty(EasyConvCod(Alltrim(Str(aCab[nPos][2])),"SYF"))
				aCab[nPos][2] := EasyConvCod(Alltrim(Str(aCab[nPos][2])),"SYF")
			ElseIf !Empty(EasyGParam("MV_SIMB"+Alltrim(Str(aCab[nPos][2])),,""))
				aCab[nPos][2] := Left(EasyGParam("MV_SIMB"+Alltrim(Str(aCab[nPos][2])),,""),AvSX3("ELA_MOEDA",AV_TAMANHO))
			EndIf
		 EndIf
      EndIf
   EndIf

   //RRC - 28/06/2013 - Caso seja uma exclusão, não precisa passar os itens
   If nOpcAuto <> 5
      ValidaItensEAuto(aDet)
   EndIf

   //RRC - 04/10/2013 - Criado parâmetro para caso o usuário tente incluir um processo já existente por execauto, o sistema bloqueie, e não entenda que é alteração.
   If (nOpcAuto == 3 .And. !EasyGParam("MV_ESS0006",,.F.)) .OR. nOpcAuto == 4 //UPSERT
      nOpcAuto := If(EasySeekAuto("ELA",aCab,if(cTpInvoice=="A",3,2)),4,3)
   EndIf

   If nOpcAuto == 5 .AND. !EasySeekAuto("ELA",aCab,if(cTpInvoice=="A",3,2))
      EasyHelp("Não foi encontrada a invoice de serviço para exclusão.","Aviso")
      lRet := .F.
   EndIf

End Sequence

Return lRet

Static Function CodToMoney(aCab)
Local y
//RRC - 04/09/2013 - Incluída condição para permitir a inclusão da moeda de acordo com o código do SIGAFIN para integração de arquivo texto (ESSIN100)
If (y := aScan(aCab, {|x| x[1]== "ELA_MOEDA"})) > 0 .And. (ValType(aCab[y][2]) == "N" .Or. (ValType(aCab[y][2]) == "C" .And. IsInCallStack("ESSIN100") .And. Val(aCab[y][2]) > 0))
   If ValType(aCab[y][2]) == "C"
      aCab[y][2] := Val(aCab[y][2])
   EndIf
   aCab[y][2] := Left(EasyGParam("MV_SIMB"+Alltrim(Str(aCab[y][2]))),AvSX3("ELA_MOEDA",AV_TAMANHO))
EndIf

Return aClone(aCab)

Static Function ValidaItensEAuto(aItens)
Local i, j, nPos, nPos2

i := 1
Do While i <= Len(aItens)
   If (nPos := aScan(aItens[i],{|X| X[1] == "ELB_SEQPRC"})) == 0 .OR. Empty(aItens[i][nPos][2])

      If (nPos := aScan(aItens[i],{|X| X[1] == "ELB_VLCAMB"})) > 0 .AND. !Empty(aItens[i][nPos][2]) .AND. ValType(aItens[i][nPos][2]) == "N"
         aValFatura[1] += aItens[i][nPos][2]
      EndIf

      If (nPos := aScan(aItens[i],{|X| X[1] == "ELB_VLEXT"})) > 0 .AND. !Empty(aItens[i][nPos][2]) .AND. ValType(aItens[i][nPos][2]) == "N"
         aValFatura[2] += aItens[i][nPos][2]
      EndIf

      aDel(aItens,i)
      aSize(aItens,Len(aItens)-1)
      i--
   EndIf

   i++
EndDo

Return Len(aItens)>0

Function IS400GeraPgto(nOpc,cTipo,cProces,cInvoice,lReg)
Local aEL9Auto    := {}
Local aEL1Auto    := {}
Local aPreEL1     := {}
Local aTotReg     := {}
Local i,j,nReg := 0,nVlCamb := 0, nVlExt := 0, nSeqPag := 0
Local aEL1Info
Local aOrd        := SaveOrd({"EJZ","ELA","ELB","EL9","EL1"})
Local cRegist     := ""
Local cChave      := ""
Local cMsg        := ""
Local cRegist     := ""
Local cStatus := ""
Local lExisteReg  := .F.
Local lExistePag  := .F.
Local nVLCAMB:= 0
Local VLEXT:= 0
Default nOpc      := 0
Default cTipo     := "", cProces := "", cInvoice := ""
Default lReg      := .F. //Indica se a chamada veio da rotina de Registro de Aquisição ou Venda de Serviços (ESSRS400)
Private lMsErroAuto := .F.
/*
Local nOrdem := 0
Local cSeqPag := ""
Local cMsg := ""
Local nValor := 0
Local nOrd := 0
Local nRec := 0
Local nTaxa := 0
Local nPrazo := EasyGParam("MV_AVG0225",,30)//Prazo de Dias para registrar o pagamento no SISCOSERV.
Local cDoc   := EasyGParam("MV_AVG0224",,"EEQ_NRINVO")//Campo responsavel pelo Numero do Documento no Pagamento de Servicos.
Local cStatus := ""
Local dPrazo
Local dBaixa
Local cTitulo := "Registro de "+if(cTpProc == "A","Pagamento","Faturamento")



Begin Sequence
*/
/*
If nOpc == 4
   EL9->(dbSetOrder(1))//EL9_FILIAL+EL9_TPPROC+EL9_PROCES+EL9_SEQPAG
   If !EL9->(DbSeek(xFilial("EL9")+AvKey(cTpProc,"EL9_TPPROC")+AvKey(cProcesso,"EL9_PROCES")+AvKey(cSeqPgt,"EL9_SEQPAG")))
      EasyHelp("Não foi possível localizar o "+cTitulo+" associado. O mesmo não foi atualizado.")
      lMsErroAuto := .T.
      Break
   EndIf
EndIf
*/
/*If !"1" $ EL9->EL9_STTSIS
//Não será mais possível alterar o registro pois foi enviado ao Siscoserv. Necessário cancelar este e gerar um novo.
nOpc := 3
EndIf*/

/*RRC - 01/04/2013 - Tratamento para gerar a EL9 (Faturamento) e EL1 (Itens do Faturamento) por Invoice e Registro de Venda de serviços nas seguintes possibilidades:
1 - Atualização nos itens de uma invoice que já estejam em fase de registro
2 - Atualização do Registro de Venda de Serviços (ESSRS400), contendo vínculo com serviços do processo utilizado já com uma invoice
3 - Grava EL9 para cada Registro vinculado a invoice, além da EL1 contendo os itens do Registro utilizado na invoice
*/

Begin Sequence
//Cada Faturamento (RF: Tabelas EL9 (Capas) e EL1 (Itens)) é gerado pela Invoice(Fatura: Tabelas ELA (Capa) e ELB (Itens))
If !Empty(cTipo) .And. !Empty(cProces) .And. !Empty(cInvoice)
   ELA->(DbSetOrder(4)) //ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO
   If ELA->(DbSeek(xFilial("ELA")+AvKey(cTipo,"ELA_TPPROC")+AvKey(cProces,"ELA_PROCES")+AvKey(cInvoice,"ELA_NRINVO")))
      ELB->(DbSetOrder(1)) //ELB_FILIAL+ELB_TPPROC+ELB_EXPORT+ELB_LOJEXP+ELB_IMPORT+ELB_LOJIMP+ELB_NRINVO+ELB_PROCES+ELB_SEQPRC
      cChave := xFilial("ELB")+AvKey(ELA->ELA_TPPROC,"ELB_TPPROC")+AvKey(ELA->ELA_EXPORT,"ELB_EXPORT")+AvKey(ELA->ELA_LOJEXP,"ELB_LOJEXP")+AvKey(ELA->ELA_IMPORT,"ELB_IMPORT");
      +AvKey(ELA->ELA_LOJIMP,"ELB_LOJIMP")+AvKey(ELA->ELA_NRINVO,"ELB_NRINVO")+AvKey(ELA->ELA_PROCES,"ELB_PROCES")
      If ELB->(DbSeek(cChave))
         EJZ->(DbSetOrder(3)) //EJZ_FILIAL+EJZ_TPPROC+EJZ_PROCES+EJZ_SEQPRC
         Do While ELB->(!Eof()).And.cChave == ELB->ELB_FILIAL+ELB->ELB_TPPROC+ELB->ELB_EXPORT+ELB->ELB_LOJEXP+ELB->ELB_IMPORT+ELB->ELB_LOJIMP+ELB->ELB_NRINVO+ELB->ELB_PROCES
            lExisteReg := .F.
            lExistePag := .F.
            If nOpc == 5 .AND. EasyGParam("MV_ESS0027",,9) >= 10 .And. ELB->ELB_TPPROC == "V"
               Exit
            EndIf
            If ELB->ELB_VLCAMB+ELB->ELB_VLEXT > 0 .Or. nOpc == 4
               //RRC - 16/10/2013 - Caso o serviço não possua mais RVS, verifica se existe o faturamento com status "aguardando registro", deve excluir o mesmo, pois é necessário ter o RVS
               If !(lExisteReg := EJZ->(DbSeek(xFilial("EJZ")+AvKey(cTipo,"EJZ_TPPROC")+AvKey(ELB->ELB_PROCES,"EJZ_PROCES")+AvKey(ELB->ELB_SEQPRC,"EJZ_SEQPRC"))))
                  EL1->(DbSetOrder(3)) //EL1_FILIAL+EL1_TPPROC+EL1_PROCES+EL1_SEQPAG+EL1_SEQPRC
                  If EL1->(DbSeek(xFilial("EL1")+ELB->ELB_TPPROC+AvKey(ELB->ELB_PROCES,"EL1_PROCES")))
                     Do While !EL1->(Eof()) .And. !lExistePag .And. EL1->(EL1_FILIAL+EL1_TPPROC+EL1_PROCES) == xFilial("EL1")+ELB->ELB_TPPROC+AvKey(ELB->ELB_PROCES,"EL1_PROCES")
                        If EL1->EL1_SEQPRC == ELB->ELB_SEQPRC .And. EL1->EL1_NRINVO == ELB->ELB_NRINVO
                           If EL9->(DbSeek(xFilial("EL9")+AvKey(EL1->EL1_TPPROC,"EL9_TPPROC")+AvKey(EL1->EL1_REGIST,"EL9_REGIST")+AvKey(EL1->EL1_SEQPAG,"EL9_SEQPAG")))
                              //Verifica se o status do Faturamento é "Aguardando Registro", pois é o único caso em que pode excluir porque não está em nenhum RVS
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
                  EL1->(DbSetOrder(4))//EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQREG+EL1_PROCES+EL1_NRINVO+EL1_PARC
                  /*RRC - 16/07/2013 Posiciona na última sequência de faturamento (EL1_SEQPAG) incluída para esta invoice para fazer o tratamento correspondente a mesma*/
                  lExistePag := (EL1->(AvSeekLast(xFilial("EL1")+AvKey(cTipo,"EL1_TPPROC")+AvKey(EJZ->EJZ_REGIST,"EL1_REGIST")+AvKey(EJZ->EJZ_SEQREG,"EL1_SEQREG");
                  +AvKey(ELA->ELA_PROCES,"EL1_PROCES")+AvKey(ELA->ELA_NRINVO,"EL1_NRINVO")+Space(AvSx3("EL1_PARC",AV_TAMANHO)))))
                  cRegist := EJZ->EJZ_REGIST
               EndIf
               If lExisteReg .Or. lExistePag
                  //RRC - 01/04/2013
                  /*Se for uma exclusão, apenas posiciona na EL1 (Itens do Faturamento), se a chamada vier da rotina de Registro de Venda de Serviços (ESSRS400)
                  deve sempre analisar os dados da EL1*/
                  aEL1Info := {}
                  //Quando lReg for .T., a chamada veio do RVS (ESSRS400)
                  If !(EasyGParam("MV_ESS0027",,9) >= 10) .AND. (nOpc > 3 .Or. lReg)
                     If lExistePag
                        //Exclui item de faturamento que não possua RVS vinculado, ou caso seja uma alteração zerando o valor do item do faturamento
                        If (nOpc == 4 .And. ELB->ELB_VLCAMB+ELB->ELB_VLEXT == 0) .Or. !lExisteReg
                           aAdd(aEL1Info,{"AUTDELETA" ,"S"    ,NIL})
                        EndIf
                     ElseIf ELB->ELB_VLCAMB+ELB->ELB_VLEXT == 0 .Or. nOpc == 5
                        ELB->(DbSkip())
                        Loop
                     EndIf
                  EndIf
                  //Grava os registros aonde estão vinculados os itens da invoice
                  If (nIndReg := aScan(aTotReg,{|X| X[1] == cRegist })) <= 0
                     nReg++
                     nVlCamb := 0
                     nVlExt  := 0
                     nIndReg := nReg
                     Aadd(aTotReg,{EJZ->EJZ_REGIST,nVlCamb,nVlExt})
                  EndIf
                  aAdd(aEL1Info,{"EL1_FILIAL"   ,xFilial("EL1")                                       ,Nil})
                  aAdd(aEL1Info,{"EL1_TPPROC"   ,AvKey(cTipo           ,"EL1_TPPROC")                 ,Nil})
                  aAdd(aEL1Info,{"EL1_PROCES"   ,AvKey(ELB->ELB_PROCES ,"EL1_PROCES")                 ,Nil})
                  aAdd(aEL1Info,{"EL1_SEQPRC"   ,AvKey(ELB->ELB_SEQPRC ,"EL1_SEQPRC")                 ,Nil})
                  aAdd(aEL1Info,{"EL1_REGIST"   ,AvKey(cRegist         ,"EL1_REGIST")                 ,Nil})
                  aAdd(aEL1Info,{"EL1_SEQREG"   ,AvKey(EJZ->EJZ_SEQREG ,"EL1_SEQREG")                 ,Nil})
                  aAdd(aEL1Info,{"EL1_SEQPAG"   ,AvKey(If(!lExistePag,"",EL1->EL1_SEQPAG),"EL1_SEQPAG")   ,Nil})
                  
                  nVLCAMB:= Round(ELB->ELB_VLCAMB * ELA->ELA_PARIDA, AvSx3("EL1_VLCAMB", AV_DECIMAL))
                  nVLEXT:= Round(ELB->ELB_VLEXT * ELA->ELA_PARIDA, AvSx3("EL1_VLEXT", AV_DECIMAL))

                  If lExisteReg
                     aAdd(aEL1Info,{"EL1_NRINVO"   ,AvKey(ELA->ELA_NRINVO,"EL1_NRINVO")   ,Nil})
                     aAdd(aEL1Info,{"EL1_VLCAMB"   ,nVLCAMB                               ,Nil})
                     aAdd(aEL1Info,{"EL1_VLEXT"    ,nVLEXT                                ,Nil})
                     aTotReg[nIndReg][2]+=nVLCAMB //Atualiza os valores cambiais para cada Registro associado ao Faturamento
                     aTotReg[nIndReg][3]+=nVLEXT
                  EndIf
                  aAdd(aPreEL1,aClone(aEL1Info))
               EndIf
            EndIf
            ELB->(DbSkip())
         EndDo
      EndIf
      For i := 1 To Len(aTotReg)
         nOpcAux  := nOpc
         cRegist  := AvKey(aTotReg[i][1],"EL9_REGIST")
         aEL1Auto := {}
         aEL9Auto := {}
         For j := 1 To Len(aPreEL1)
            If (nReg:= aScan(aPreEL1[j],{|X| X[1] == "EL1_REGIST"})) > 0 .And. aPreEL1[j][nReg][2] == cRegist
               aAdd(aEL1Auto,aClone(aPreEL1[j]))
            EndIf
         Next j
         //Quando lReg for .T., a chamada veio do RVS (ESSRS400)
         /*RRC - 16/07/2013 - Quando for alteração, exclusão ou chamada do RVS, posiciona na última sequência de faturamento incluída para esta invoice, para realizar
         o tratamento correspondente*/

         If EasyGParam("MV_ESS0027",,9) >= 10 .OR. nOpcAux > 3 .Or. lReg
            EL9->(DbSetOrder(3))//EL9_FILIAL+EL9_TPPROC+EL9_REGIST+EL9_PROCES+EL9_NRINVO+EL9_PARC
            cChave := xFilial("EL9")+AvKey(ELA->ELA_TPPROC,"EL9_TPPROC")+AvKey(cRegist,"EL9_REGIST")+AvKey(ELA->ELA_PROCES,"EL9_PROCES")+AvKey(ELA->ELA_NRINVO,"EL9_NRINVO");
            +Space(AvSx3("EL9_PARC",AV_TAMANHO))
            If EasyGParam("MV_ESS0027",,9) >= 10 .AND. EL9->(AvSeekLast(cChave)) .AND. (EL9->EL9_STTSIS == "2" .OR. EL9->EL9_STTSIS == "3")
               If PS402Compara()
                  nOpcAux := 4
                  cStatus := "5"
               Else
                  nOpcAux := 3
               EndIf
            ElseIf nOpc == 5
               EL9->(AvSeekLast(cChave))
               //RRC - 21/10/2013 - Não pode alterar pagamento com status "Aguardando Cancelamento" ou "Cancelado"
            ElseIf (!EL9->(AvSeekLast(cChave)) .Or. EL9->EL9_STTSIS == "3" .Or. EL9->EL9_STTSIS == "4") .And. (nOpcAux == 4 .Or. lReg)
               nOpcAux := 3
            ElseIf lReg
               nOpcAux := 4
            EndIf
         EndIf

         aAdd(aEL9Auto,{'EL9_FILIAL',xFilial("EL9"),NIL})
         aAdd(aEL9Auto,{'EL9_TPPROC',cTipo         ,NIL})
         aAdd(aEL9Auto,{'EL9_REGIST',cRegist,NIL})
         aAdd(aEL9Auto,{"EL9_SEQPAG",If(nOpcAux==3,"",EL9->EL9_SEQPAG) ,NIL})
         //Se os valores atuais para o Registro valem zero, está excluindo o faturamento do RVS
         If aTotReg[i][2] + aTotReg[i][3] == 0
            nOpcAux := 5
         EndIf

         If nOpcAux <> 5
            aAdd(aEL9Auto,{'EL9_PROCES',ELA->ELA_PROCES ,NIL})
            aAdd(aEL9Auto,{'EL9_VLCAMB',aTotReg[i][2] ,NIL})
            aAdd(aEL9Auto,{'EL9_VLEXT' ,aTotReg[i][3] ,NIL})
            aAdd(aEL9Auto,{'EL9_DTPAG' ,ELA->ELA_DTEMIS ,NIL})

            If !Empty(ELA->ELA_DOC)
               aAdd(aEL9Auto,{'EL9_NROP'  ,ELA->ELA_DOC   ,NIL})
            Else
               aAdd(aEL9Auto,{'EL9_NROP'  ,ELA->ELA_NRINVO,NIL})
            EndIf

            aAdd(aEL9Auto,{'EL9_MOEDA' , Posicione("EJW", 1, xFilial("EJW") + ELA->ELA_TPPROC + ELA->ELA_PROCES, "EJW_MOEDA"), NIL})
            aAdd(aEL9Auto,{'EL9_TX_MOE',ELA->ELA_TX_PED   ,NIL})
            aAdd(aEL9Auto,{'EL9_EQVL'  ,ELA->ELA_TX_PED*aTotReg[i][2] ,NIL})
            aAdd(aEL9Auto,{'EL9_NRINVO',ELA->ELA_NRINVO   ,NIL})
            If !Empty(ELA->ELA_DOC)
               aAdd(aEL9Auto,{'EL9_DOC'  ,ELA->ELA_DOC   ,NIL})
            Else
               aAdd(aEL9Auto,{'EL9_DOC'  ,ELA->ELA_NRINVO,NIL})
            EndIf
            If EasyGParam("MV_ESS0027",,9) >= 10 .AND. nOpcAux == 4 .AND. !Empty(cStatus)
               aAdd(aEL9Auto,{'EL9_STTSIS' ,cStatus                           ,NIL})
            EndIf
         EndIf
         MSExecAuto({|a,b,c,d| ESSPS402(a,b,c,d)},aEL9Auto,aEL1Auto,nOpcAux,cTipo)

         If lMsErroAuto
            If !(ValType(NomeAutoLog()) == "U")
               cMsg := MemoRead(NomeAutoLog())
               FErase(NomeAutoLog())
            EndIf
            EasyHelp(cMsg)
            Break
         EndIf
      Next i
   EndIf
EndIf
End Sequence
RestOrd(aOrd,.T.)
Return !lMsErroAuto

/*
Função     : IS400GerParc()
Parâmetros : -
Retorno    : -
Objetivos  : Gerar automaticamente as parcelas de câmbio quando a condição de pagamento estiver preenchida.
Autor      : Rafael Ramos Capuano - Adaptado do original - RS401GerPagto() - Allan Oliveira Monteiro - AOM
Data/Hora  : 25/05/2013
Revisao    :
Obs.       :
*/
*------------------------*
Static Function IS400GerParc()
*------------------------*
Local i
Local cMsg := ""
Local aEEQAuto := {}
Local lRet:=.T.
// Utilizado no ponto de entrada
Local aParc := {}
Local nPrxParc := 0
Local nRecno := EEQ->(Recno())
Local aOrd   := SaveOrd({"EEQ"})
Private lMSErroAuto := .F.

//Verifica se já existe uma parcela gerada para este processo, caso exista, não pode gerá-la como um número sequencial por processo
EEQ->(DbSetOrder(13))//EEQ->EEQ_FILIAL + EEQ->EEQ_TPPROC + EEQ->EEQ_PROCES
If EEQ->(AvSeekLast(xFilial("EEQ")+AvKey(ELA->ELA_TPPROC,"EEQ_TPPROC")+AvKey(ELA->ELA_PROCES,"EEQ_PROCES")))
   cPrxParc := EEQ->EEQ_PARC //nPrxParc := Val(EEQ->EEQ_PARC)  // GFP - 22/01/2014
EndIf
EEQ->(DbGoTo(nRecno))
RestOrd(aOrd,.T.)
Begin Sequence

   aParc := Condicao(ELA->ELA_VL_MOE,ELA->ELA_CONDPG,,ELA->ELA_DTEMIS,,,,,,)

   For i := 1 To Len(aParc)
      nPrxParc++
      aEEQAuto := {}
      aAdd(aEEQAuto,{"EEQ_FILIAL", AvKey(xFilial("EEQ"),"EEQ_FILIAL")                    , Nil })
      //RRC -27/03/2013 - Considera apenas o Tipo de Processo e o Processo para montar o EEQ_PREEMB
      aAdd(aEEQAuto,{"EEQ_PREEMB", AvKey(ELA->ELA_TPPROC+ELA->ELA_PROCES/*+ELA->ELA_NRINVO*/ ,"EEQ_PREEMB")   , Nil })
      aAdd(aEEQAuto,{"EEQ_EVENT" , IF(ELA->ELA_TPPROC == "A","001","501")                , Nil })
      aAdd(aEEQAuto,{"EEQ_NRINVO", ELA->ELA_NRINVO                                       , Nil })
      aAdd(aEEQAuto,{"EEQ_PARC"  , StrZero(nPrxParc, AvSx3("EEQ_PARC", AV_TAMANHO))      , Nil })
      aAdd(aEEQAuto,{"EEQ_VCT"   , aParc[i][1]                                           , Nil })
      aAdd(aEEQAuto,{"EEQ_MOEDA" , ELA->ELA_MOEDA                                        , Nil })
      //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
      If EEQ->(FieldPos("EEQ_VLSISC")) > 0
         aAdd(aEEQAuto,{"EEQ_VLSISC", aParc[i][2]                                        , Nil })
      EndIf
      aAdd(aEEQAuto,{"EEQ_VL"    , aParc[i][2]                                           , Nil })
      aAdd(aEEQAuto,{"EEQ_FASE"  , AvKey(IF(ELA->ELA_TPPROC == "A","4","3"),"EEQ_FASE")  , Nil })
      aAdd(aEEQAuto,{"EEQ_TIPO"  , IF(ELA->ELA_TPPROC == "A","P","R")                    , Nil }) //Aquisiçao == "A" == "P" -> Cambio a Pagar, Venda == "V" == "R" -> Cambio a Receber
      If EEQ->(FieldPos("EEQ_PARVIN")) > 0
         aAdd(aEEQAuto,{"EEQ_PARVIN" , STRZERO(i,Len(AllTrim(STR(i)))+1,0)               , Nil })
      EndIf

      If ELA->ELA_TPPROC == "A" //Na Aquisição será necessario gravar dados do Fornecedor

         If ELA->(FieldPos("ELA_EXPINV"))>0 .And. ELA->(FieldPos("ELA_ELJINV"))>0 .And. !Empty(ELA->ELA_EXPINV) .And. !Empty(ELA->ELA_ELJINV)
            aAdd(aEEQAuto,{"EEQ_FORN"   , ELA->ELA_EXPINV                                   , Nil })
            aAdd(aEEQAuto,{"EEQ_FOLOJA" , ELA->ELA_ELJINV                                   , Nil })
         Else
            aAdd(aEEQAuto,{"EEQ_FORN"   , ELA->ELA_EXPORT                                   , Nil })
            aAdd(aEEQAuto,{"EEQ_FOLOJA" , ELA->ELA_LOJEXP                                   , Nil })
         End If
      Else //Caso seja Venda será necessario gravar dados do Importador
         If ELA->(FieldPos("ELA_IMPINV"))>0 .And. ELA->(FieldPos("ELA_ILJINV"))>0  .And. !Empty(ELA->ELA_IMPINV) .And. !Empty(ELA->ELA_ILJINV)
            aAdd(aEEQAuto,{"EEQ_IMPORT" , ELA->ELA_IMPINV                                   , Nil })
            aAdd(aEEQAuto,{"EEQ_IMLOJA" , ELA->ELA_ILJINV                                   , Nil })
         Else
            aAdd(aEEQAuto,{"EEQ_IMPORT" , ELA->ELA_IMPORT                                   , Nil })
            aAdd(aEEQAuto,{"EEQ_IMLOJA" , ELA->ELA_LOJIMP                                   , Nil })
         End If

      EndIf

      If EEQ->(FieldPos("EEQ_HVCT")) > 0
         aAdd(aEEQAuto,{"EEQ_HVCT"   , aParc[i][1]                                       , Nil })
      EndIf
      aAdd(aEEQAuto,{"EEQ_TPPROC"    , ELA->ELA_TPPROC                                   , Nil })
      aAdd(aEEQAuto,{"EEQ_PROCES"    , ELA->ELA_PROCES                                   , Nil })
      aAdd(aEEQAuto,{"EEQ_MODAL"     , If(!Empty(ELA->ELA_VLCAMB),"1","2")               , Nil })  // GFP - 02/09/2014
      If IsInCallStack("ESSPS400")
         cModulo := "ESS"
         aAdd(aEEQAuto,{"EEQ_SOURCE" , cModulo                                           , Nil })
      EndIf
      If EEQ->(FieldPos("EEQ_EMISSA")) > 0
         aAdd(aEEQAuto,{"EEQ_EMISSA"   , ELA->ELA_DTEMIS                                 , Nil })
      EndIf
      aAdd(aEEQAuto,{"EEQ_TP_CON"    , IF(ELA->ELA_TPPROC == "A","4","3")                , Nil })

      MsExecAuto({|l,y,z,w,x,k| EECAF500(l,y,z,w,x,k)},"EEQ", , ,aEEQAuto,3,ELA->ELA_TPPROC)
      If lMsErroAuto
         //RRC - 20/02/2013
         /*Para casos de execauto do Siscoserv com chamada direta da função RS400GerParc(), mesmo com a chamada do EasyHelp() na função AF500AtuaEEQ(),
         a função NomeAutoLog() não retornava a mensagem de erro após uma tentativa inválida de inclusão*/
         If ValType(cMsg := NomeAutoLog()) == "U"
            cMsg := "A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
         Else
            cMsg := MemoRead(NomeAutoLog())
            FErase(NomeAutoLog())
         EndIf
         EasyHelp(cMsg)
         lRet := .F.
         Break
      EndIf

   Next i

End Sequence

Return lRet

/*
Programa   : IS400DelParc()
Objetivo   : Exclui as parcelas de câmbio geradas para os serviços
Retorno    : Lógico
Autor      : Rafael Ramos Capuano
Data/Hora  : 26/03/2013 08:52
Revisao    :
*/
Static Function IS400DelParc(cOrigem,lDelTit)
Local lRet      := .T.
Local cMsg      := ""
Local aEEQAuto  := {}
Local aOrd      := SaveOrd({"EEQ"})
Local cCond     := ""
Local cChaveOld := ""
Default cOrigem := ""
Default lDelTit := .T.
Private lMSErroAuto := .F.

Begin Sequence
   //RRC - Se a invoice não foi gerada diretamente pelo SIGAESS, as parcelas associadas a ela serão excluídas, porém, não irão excluir o título no SIGAFIN
   cOrigem:= AllTrim(cOrigem)
   If cOrigem == "SIGACOM" .Or. cOrigem == "SIGAFAT"
      lDelTit := .F.
   EndIf
   If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015
      EEQ->(DbSetOrder(4)) //EEQ->EEQ_FILIAL + EEQ->EEQ_NRINVO + EEQ->EEQ_PREEMB + EEQ->EEQ_PARC
      cChave := xFilial("EEQ") + AvKey(ELA->ELA_NRINVO,"EEQ_NRINVO") + AvKey(ELA->ELA_TPPROC+ELA->ELA_PROCES/*+ELA->ELA_NRINVO*/,"EEQ_PREEMB")
      cCond := 'cChave == xFilial("EEQ") + EEQ->EEQ_NRINVO + EEQ->EEQ_PREEMB'
   Else
      EEQ->(DbSetOrder(15))  //EEQ_FILIAL+EEQ_TPPROC+EEQ_PROC+EEQ_NRINVO+EEQ_PARC  // GFP - 26/05/2015
      cChave := xFilial("EEQ") + AvKey(ELA->ELA_TPPROC,"EEQ_TPPROC") + AvKey(ELA->ELA_PROCES,"EEQ_PROCES") + AvKey(ELA->ELA_NRINVO,"EEQ_NRINVO")  // GFP - 26/05/2015
      cCond := 'cChave == EEQ->(xFilial("EEQ") + EEQ_TPPROC + EEQ_PROCES + EEQ_NRINVO)'
   EndIf
   If EEQ->(DbSeek(cChave))
      Do While EEQ->(!Eof()) .And. &cCond
         aEEQAuto := {}
         aAdd(aEEQAuto,{"EEQ_FILIAL"  , EEQ->EEQ_FILIAL   , Nil })
         aAdd(aEEQAuto,{"EEQ_NRINVO", EEQ->EEQ_NRINVO , Nil })
         aAdd(aEEQAuto,{"EEQ_PREEMB", EEQ->EEQ_PREEMB , Nil })
         aAdd(aEEQAuto,{"EEQ_PARC"  , EEQ->EEQ_PARC   , Nil })
         aAdd(aEEQAuto,{"EEQ_FASE"  , EEQ->EEQ_FASE   , Nil })
         aAdd(aEEQAuto,{"EEQ_PROCES", EEQ->EEQ_PROCES , Nil })

         IF SIX->(dbSeek("EEQF")) //LRS 17/11/2016 - Caso tiver o indice EEQF, adicionar o EEQ_TPPROC para funcionar o DBSEEK
            aAdd(aEEQAuto,{"EEQ_TPPROC"  , EEQ->EEQ_TPPROC   , Nil })
         EndIF
         //RRC - 16/07/2013 - Verifica se a parcela já está liquidada, neste caso realiza o estorno da liquidação para depois excluir a parcela de câmbio
         cChaveOld := cChave

         If (EEQ->EEQ_MODAL == "2" .And. !Empty(EEQ->EEQ_DTCE)) .Or. (EEQ->EEQ_MODAL == "1" .And. !Empty(EEQ->EEQ_PGT))
            aAdd(aEEQAuto,{"EEQ_DTCE"    , CTOD("  /  /  ") , Nil })
            aAdd(aEEQAuto,{"EEQ_PGT"     , CTOD("  /  /  ") , Nil })
            MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)},"EEQ", , ,aEEQAuto,ALTERAR,EEQ->EEQ_TPPROC,lDelTit)
         EndIf
         If !lMsErroAuto
            MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)},"EEQ", , ,aEEQAuto,EXCLUIR,EEQ->EEQ_TPPROC,lDelTit)
         EndIf

         cChave := cChaveOld

         If lMsErroAuto
            /*Para casos de execauto do Siscoserv, mesmo com a chamada do EasyHelp() na função AF500AtuaEEQ(), a função NomeAutoLog()
            não retornava a mensagem de erro após uma inclusão com sucesso e tentativa inválida de exclusão logo em seguida*/
            If ValType(cMsg := NomeAutoLog()) == "U"
               cMsg := "A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
            Else
               cMsg := MemoRead(NomeAutoLog())
               FErase(NomeAutoLog())
            EndIf
            EasyHelp(cMsg)
            lRet := .F.
            Break
         Else
            EEQ->(DbSkip())
         EndIf
      EndDo
   EndIf

End Sequence
RestOrd(aOrd,.T.)
Return lRet


/*
Programa   : IS400DelInv()
Objetivo   : Validar a exclusão da invoice
Retorno    : Lógico
Autor      : Rafael Ramos Capuano
Data/Hora  : 26/03/2013 10:02
Revisao    :
*/

Function IS400DelInv(nOper)
Local lRet      := .T.
Local lIntTit   := .T.
Default nOper   := 4
If Type("lIntFin") == "L"
   lIntTit := lIntFin //Caso seja .F., a atualização de se deu primeiro no SIGAFIN, sendo assim, o SIGAESS não precisa a integração com o SIGAFIN
EndIf

Begin Transaction
SF2->(DbSetOrder(1)) //MCF - 15/01/2015 //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
SF1->(DBSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
//Verifica se não houve nenhuma baixa realiza
If nOper == 5
   If Type("lIS400Auto") == "L" .And. !lIS400Auto .And. !EasyGParam("MV_ESS0008",,.F.) .And.;
          ((AllTrim(ELA->ELA_ORIGEM) == "SIGACOM" .And. SF1->(DBSeek(xFilial() + AvKey(ELA->ELA_DOC, "F1_DOC") + AvKey(ELA->ELA_SERIE, "F1_SERIE") + AvKey(ELA->ELA_EXPORT, "F1_FORNECE") + AvKey(ELA->ELA_LOJEXP, "F1_LOJA")))) .Or.;           
           (AllTrim(ELA->ELA_ORIGEM) == "SIGAFAT" .And. SF2->(DbSeek(xFilial() + AvKey(ELA->ELA_DOC, "F2_DOC") + AvKey(ELA->ELA_SERIE, "F2_SERIE") + AvKey(ELA->ELA_IMPORT, "F2_CLIENTE") + AvKey(ELA->ELA_IMPORT, "F2_LOJA"))))) //LGS-23/07/2015
      EasyHelp("Esta invoice foi integrada e só poderá ser excluída pelo " + AllTrim(ELA->ELA_ORIGEM) + ".","Aviso")
      lRet := .F.
      //Realiza a exclusão das parcelas de câmbio associadas a invoice
   ElseIf !(lRet := IS400DelParc(ELA->ELA_ORIGEM,lIntTit))
      DisarmTransaction()
      Break
      //Realiza a exclusão dos faturamentos associados a invoice
   ElseIf ELA->ELA_TPPROC == "V" .And. !(lRet := IS400GeraPgto(EXCLUIR, ELA->ELA_TPPROC, ELA->ELA_PROCES, ELA->ELA_NRINVO))
      DisarmTransaction()
      Break
   EndIf

ElseIf nOper == 4

   //Quando lDelTit for .T., será uma chamada de ExecAuto para atualizar o SIGAFIN, neste caso, se o parâmetro MV_ESS0008 estiver .F., não fará alteração para invoices originadas pelo SIGACOM ou SIGAFAT
   If Type("lIS400Auto") == "L" .And. (!lIS400Auto .Or. lIntTit) .And. !EasyGParam("MV_ESS0008",,.F.) .And. (AllTrim(ELA->ELA_ORIGEM) == "SIGACOM" .Or. AllTrim(ELA->ELA_ORIGEM) == "SIGAFAT")
      EasyHelp("Esta invoice foi integrada e só poderá ser alterada pelo " + AllTrim(ELA->ELA_ORIGEM) + ".","Aviso")
      lRet := .F.
   EndIf

EndIf

If lRet .And. EL9->EL9_STTSIS == "2" //.And. !(EasyGParam("MV_ESS0027",,9) >= 10)//MCF-15/01/2015 Caso ocorra a exclusão, o status será alterado para 2=Parcialmente em fase de registro
	RecLock("EL9",.F.)                 // NCF - 27/03/2018 - Também no manual 10 o status do RF passa para "Aguardando cancelamento" quando exclusa a invoice, dentre os status possíveis:
	EL9->EL9_STTSIS := "3"             // "1=Aguardando registro no SISCOSERV;2=Registrado no SISCOSERV;3=Aguardando cancelamento no SISCOSERV;4=Cancelado no SISCOSERV;5=Aguardando Retificação no SISCOSERV"
	EL9->(MsUnlock())
Endif

End Transaction

If !lRet
   ELinkClearID()
EndIf
Return lRet

/*
Programa   : IS400StaInv()
Objetivo   : Atualiza o status da baixa da invoice
Parâmetros :
Retorno    : Lógico
Autor      : Rafael Ramos Capuano - (Adaptado do original RS401STTPAG() - Alan Oliveira Monteiro - AOM)
Data/Hora  : 26/03/2013 14:38
Revisao    :
*/
Function IS400StaInv()
Local lRet      := .T.
Local aOrd      := SaveOrd({"EEQ"})
Local cChave    := ""
Local cStatInv  := ""
Local nValor    := 0
Local cCond     := ""
If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015
   EEQ->(DbSetOrder(4)) //EEQ->EEQ_FILIAL + EEQ->EEQ_NRINVO + EEQ->EEQ_PREEMB + EEQ->EEQ_PARC
   cChave := xFilial("EEQ") + AvKey(ELA->ELA_NRINVO,"EEQ_NRINVO") + AvKey(ELA->ELA_TPPROC+ELA->ELA_PROCES/*+ELA->ELA_NRINVO*/,"EEQ_PREEMB")
   cCond := 'xFilial("EEQ") + EEQ->EEQ_NRINVO + EEQ->EEQ_PREEMB'
Else
   EEQ->(DbSetOrder(15))  //EEQ_FILIAL+EEQ_TPPROC+EEQ_PROC+EEQ_NRINVO+EEQ_PARC  // GFP - 26/05/2015
   cChave := xFilial("EEQ") + AvKey(ELA->ELA_TPPROC,"EEQ_TPPROC") + AvKey(ELA->ELA_PROCES,"EEQ_PROCES") + AvKey(ELA->ELA_NRINVO,"EEQ_NRINVO")  // GFP - 26/05/2015
   cCond := 'EEQ->(xFilial("EEQ") + EEQ_TPPROC + EEQ_PROCES + EEQ_NRINVO)'
EndIf

If EEQ->(DbSeek(cChave))
   Do While EEQ->(!Eof()) .And. cChave == &cCond
      //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
      //If !Empty(EEQ->EEQ_PGT) //wfs - baixa no exterior
      If !Empty(EEQ->EEQ_PGT) .Or. (EasyVerModal().And. !Empty(EEQ->EEQ_DTCE))
         nValor += If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL)
      EndIf
      EEQ->(DbSkip())
   EndDo
EndIf

If nValor > 0 .And. nValor < ELA->ELA_VL_MOE
   cStatInv := "2" //"Parcialmente Liquidado"
ElseIf nValor == 0
   cStatInv := "1" //"Em aberto"
Else
   cStatInv := "3" //"Liquidado"
EndIf

If Reclock("ELA",.F.)
   ELA->ELA_STTPAG := cStatInv
   ELA->(MsUnLock())
EndIf

RestOrd(aOrd,.T.)
Return lRet

/*
Programa   : IS400Trigger()
Objetivo   : Verificar a condição para os gatilhos dos campos da invoice
Retorno    : Lógico
Autor      : Rafael Ramos Capuano
Data/Hora  : 10/04/2013 14:03
Revisao    :
*/

Function IS400Trigger(cCampo)
Local lRet     := .F.
Default cCampo := ""

If !Empty(cCampo)
   Do Case
      Case cCampo == "ELA_DTEMIS"
         lRet := Empty(M->ELA_TX_MOE).AND.!Empty(M->ELA_MOEDA)

      Case cCampo == "ELA_MOEDA"
         lRet := Empty(M->ELA_TX_MOE).AND.!Empty(M->ELA_DTEMIS)
   EndCase
EndIf
Return lRet


/*
Programa   : AtuView()
Objetivo   : Verificar se oView é alteração
Retorno    : Lógico
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 17/01/2014
Revisao    :
*/
Static Function AtuView(oView)
Local lRet := .T.
oView:aUserButtons := {}
If Inclui .OR. Altera  // GFP - 30/05/2014
   oView:AddUserButton("Faturar Todos", "CLIPS",{|oView| IS400FaturaTodos()})
EndIf
If Altera
   oView:AddUserButton("Conhecimento"        , "CLIPS",{|| GetMsDocument()})
EndIf
Return .T.


/*
Programa   : GetMsDocument()
Objetivo   : Chamada do MsDocument()
Retorno    : Lógico
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 17/01/2014
Revisao    :
*/
//Deve existir objeto OMODEL ativo.
Static Function GetMsDocument()
Local oModel    := FWModelActive()
Local nOperacao := oModel:nOperation
Private aRotina := MenuDef() //FSY-17/01/2014
If nOperacao == 4//4 = ALTERAÇÃO
   MsDocument( "ELA", ELA->(RecNo()), 1,)//ELA
Else
   MsgInfo("Opção permitida apenas para alteração!")
End If
Return .T.

/*
Programa   : IS400LinePre()
Objetivo   : Validação de itens da Invoice.
Retorno    : Lógico
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/11/2015 :: 10:02
*/
Function IS400LinePre(oModelGrid,nLine,cAction,cField)
Local lRet := .T.

Begin Sequence

   Do Case
      Case oModelGrid:cId == "ELBDETAIL"
         If cAction == "DELETE"
            lRet := .F.
            EasyHelp("Não é possível efetuar a exclusão dos itens da Invoice.","Aviso")
            Break
         EndIf
   End Do

End Sequence

Return lRet

Function IS400Exclu(cAlias, nReg, nOpc)
Local aOrd := SaveOrd({"EJY","EL9"})

Begin Sequence

   EJY->(DbSetOrder(1))
   EJY->(DbSeek(xFilial("EJY")+AvKey(ELA->ELA_TPPROC,"EJY_TPPROC")+AvKey(ELA->ELA_PROCES,"EJY_REGIST")))

   EL9->(DbSetOrder(3))//EL9_FILIAL+EL9_TPPROC+EL9_REGIST+EL9_PROCES+EL9_NRINVO+EL9_PARC
   cChave := xFilial("EL9")+AvKey(ELA->ELA_TPPROC,"EL9_TPPROC")+AvKey(EJY->EJY_REGIST,"EL9_REGIST")+AvKey(ELA->ELA_PROCES,"EL9_PROCES")+AvKey(ELA->ELA_NRINVO,"EL9_NRINVO")
   If EL9->(AvSeekLast(cChave))
      Do While EL9->(!Eof()) .AND. EL9->(EL9_FILIAL+EL9_TPPROC+EL9_REGIST+EL9_PROCES+EL9_NRINVO) == cChave
         If EL9->EL9_STTSIS == "2"
            If MsgNoYes("Esta invoice possui " + If(EL9->EL9_TPPROC == "A","RPs","RFs") + " vinculados e registrados. Esta exclusão ocasionará na perda de referência entre Invoice e " + If(EL9->EL9_TPPROC == "A","RP.","RF.") + ENTER +;
                        "Caso desejar manter a referência, uma nova invoice deverá ser incluída com o mesmo número no campo 'Nro. Invoice' (ELA_NROINVO) que esta possui." + ENTER +;
                        "Caso esta nova invoice possuir número diferente desta, será necessário efetuar o cancelamento manual dos " + If(EL9->EL9_TPPROC == "A","RPs","RFs") + " já registrados para este processo." + ENTER +;
                        "Deseja prosseguir com a exclusão desta invoice?","Aviso")
               Exit
            Else
               Break
            EndIf
         EndIf
         EL9->(DbSkip())
      EndDo
   EndIf
   FWExecView('EXCLUIR','VIEWDEF.ESSIS400', 5,,,{|| IS400DelInv()})
End Sequence

RestOrd(aOrd,.T.)
Return NIL

/*
Programa   : IS400Filt()
Objetivo   : Chamado da Alteração de Invoice
Retorno    : Nil
Autor      : Lucas Raminelli
Data/Hora  : 13/04/2016
Revisao    :
*/
Function IS400Filt()
Local lOk := .F.
Local oModel := FWModelActive()

lOk := ( FWExecView('Altera Num.Invoice','VIEWDEF.ESSIS400', MODEL_OPERATION_UPDATE,, { || .T. } ) == 0 )

Return Nil

/*
Programa   : UPDX1ES400()
Objetivo   : Carga para o SX1 chamada atraves do AvUpdate01
Retorno    : Nil
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 19/07/2017
Revisao    :
*/
Static Function UPDX1ES400(o)

o:TableStruct('SX1',{'X1_GRUPO','X1_ORDEM','X1_CNT01'  },1)
o:TableData(  'SX1',{'ESSIS400','01'      ,Str(nSldCamb) })
o:TableData(  'SX1',{'ESSIS400','02'      ,Str(nSldExt)  })

Return

/*
Programa   : IsForeign()
Objetivo   : Verificação se o registro da tabela é do extrangeiro
Retorno    : Nil
Autor      : Retirado de fonte ESSRS400
Data/Hora  : 01/02/2021
*/
Static Function IsForeign(cTabela, cChave)
Local cAbrev := Right(cTabela,2)
Local lRet   := .F.
Local aOldOrd

aOldOrd := (cTabela)->({IndexOrd(),RecNo()})

(cTabela)->(dbSetOrder(1))
lRet    := (cTabela)->(dbSeek(xFilial()+cChave) .AND. (&(cAbrev+"_EST") == "EX" .OR. !Empty(&(cAbrev+"_PAIS")) .AND. !&(cAbrev+"_PAIS") == "105"))

(cTabela)->(dbSetOrder(aOldOrd[1]),dbGoTo(aOldOrd[2]))

Return lRet
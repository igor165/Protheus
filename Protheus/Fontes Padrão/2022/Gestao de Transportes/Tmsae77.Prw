#INCLUDE "TMSAE77.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSAE77  � Autor � Valdemar Roberto    � Data � 11.01.2017 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Browse da tabela de controle de envio ao EAI               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE77()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSAE77()
Local cTMSERP := AllTrim(SuperGetMV("MV_TMSERP",," "))	//-- Condi��o de integra��o com ERP (0 - Protheus, 1 - Datasul)
Local oBrowse
Local nX	  := 0
Local aStatus := {}

Private aRotina := MenuDef()
Private cReturn := ''
If cTMSERP != "1"
	Aviso(STR0008,STR0005,{STR0006},3)
Else
	oBrowse:= FWMBrowse():New()   
	oBrowse:SetAlias("DJQ")
	oBrowse:SetMenuDef("TMSAE77")
	oBrowse:SetDescription(STR0001)	//-- "Registros enviados ao EAI"

	aLegenda := TMSAE77Leg('DJQ')
	For nX := 1 To Len(aLegenda)
		oBrowse:AddLegend( aLegenda[nX,1],aLegenda[nX,2])	
	Next nX
	
	oBrowse:Activate()
EndIf

Return Nil            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Menudef  � Autor � Valdemar Roberto   � Data � 11/01/2017  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do menu                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Menudef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE77                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //-- "Pesquisar"
ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSAE77" OPERATION 4 ACCESS 0 //-- "Visualizar"
ADD OPTION aRotina TITLE STR0004  ACTION "TMSAE77Fis"      OPERATION 3 ACCESS 0 //-- "Reenvio Fiscal"
ADD OPTION aRotina TITLE 'Legenda' ACTION 'TMSAE77Leg'	   OPERATION 6 ACCESS 0//-- "Legenda"

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ModelDef � Autor � Valdemar Roberto   � Data � 11/01/2017  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o da modeldef                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE77                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ModelDef()
Local oStruDJQ := FWFormStruct(1,"DJQ")
Local oStruDJR := FWFormStruct(1,"DJR")
Local oModel

oStruDJQ:AddField(STR0009,STR0009,"_STATUS","C",40,0,,{|| .F.},{},.F.,{|| ExibeStat()},,,.T.)

oStruDJR:SetProperty("DJR_OBSERV",MODEL_FIELD_WHEN,{|| .F.})

oModel := MPFormModel():New("TMSAE77",/*bPre*/,/*bPos*/,{|| CommitDJR()},/*bCancel*/)


//-- Cabe�alho dos envios
oModel:AddFields("MdFieldDJQ",,oStruDJQ,,,/*Carga*/)
oModel:GetModel("MdFieldDJQ"):SetDescription(STR0001)	//-- "Registros enviados ao EAI"
oModel:SetPrimaryKey({"DJQ_FILIAL","DJQ_ALIAS","DJQ_INDICE","DJQ_CONTEU"})  

//-- Itens dos envios
oModel:AddGrid("MdGridDJR","MdFieldDJQ",oStruDJR,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:GetModel("MdGridDJR"):SetNoInsertLine(.T.)
oModel:GetModel("MdGridDJR"):SetNoDeleteLine(.T.)
oModel:SetRelation("MdGridDJR",{{"DJR_FILIAL","xFilial('DJR')"},;
								{"DJR_ALIAS" ,"DJQ_ALIAS"},;
								{"DJR_INDICE","DJQ_INDICE"},;
								{"DJR_CONTEU","DJQ_CONTEU"}},DJR->(IndexKey(1)))
     
oModel:SetActivate()
     
Return oModel 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ViewDef  � Autor � Valdemar Roberto   � Data � 11/01/2017  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o da viewdef                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE77                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef()     
Local oStruDJQ := FWFormStruct(2,"DJQ")
Local oStruDJR := FWFormStruct(2,"DJR")
Local oModel
Local oView

oStruDJQ:AddField("_STATUS","99",STR0009,STR0009,{" "},"C","",,"",.T.,,,{ },,,.T.,)

oStruDJQ:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
oStruDJR:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
oStruDJR:SetProperty("DJR_OBSERV",MVC_VIEW_CANCHANGE,.T.)

oModel := FwLoadModel("TMSAE77")
oView  := FwFormView():New()

oStruDJR:RemoveField("DJR_ALIAS")
oStruDJR:RemoveField("DJR_INDICE")
oStruDJR:RemoveField("DJR_CONTEU")

oView:SetModel(oModel)     
oView:AddField('VwFieldDJQ',oStruDJQ,"MdFieldDJQ")

oView:AddGrid('VwGridDJR',oStruDJR,"MdGridDJR")

oView:CreateHorizontalBox("CABECALHO",30)  
oView:CreateHorizontalBox("ITENS",70)

oView:SetOwnerView("VwFieldDJQ","CABECALHO")
oView:SetOwnerView("VwGridDJR","ITENS")

oView:SetViewAction("ASKONCANCELSHOW",{|| .F.})
oView:ShowUpdateMsg(.F.)
oView:ShowInsertMsg(.F.)
oView:SetAfterViewActivate({|oView| AfterVwAct(oView)})

oView:AddUserButton(STR0007,"DEVOLNF",{|| TMSAE77Ree()},NIL,VK_F6,{MODEL_OPERATION_VIEW,MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE})	//-- "Reenvia"

Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE77Fis � Autor � Valdemar Roberto � Data � 11/01/2017  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Prepara reenvio fiscal                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE77Fis()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE77                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSAE77Fis()
Local cPerg := "TMSAE77FIS"

If Pergunte(cPerg,.T.)
	FWExecView(,"TMSAE70",4,,{|| .T.},,20,,,,,)
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE77Ree � Autor � Valdemar Roberto � Data � 31/01/2017  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Reenvia registro                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE77Ree()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE77                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSAE77Ree()
Local aAreas   := {SF3->(GetArea()),GetArea()}
Local oModel   := FwModelActive()
Local oView    := FwViewActive()
Local oMdlDJQ  := oView:GetModel("MdFieldDJQ")
Local oMdlDJR  := oView:GetModel("MdGridDJR")
Local cFilDoc  := SubStr(oMdlDJQ:GetValue("DJQ_CONTEU"),1,TamSX3("DT6_FILDOC")[1])
Local cDoc     := SubStr(oMdlDJQ:GetValue("DJQ_CONTEU"),TamSX3("DT6_FILDOC")[1] + 1,TamSX3("DT6_DOC")[1])
Local cSerie   := SubStr(oMdlDJQ:GetValue("DJQ_CONTEU"),TamSX3("DT6_FILDOC")[1] + TamSX3("DT6_DOC")[1] + 1,TamSX3("DT6_SERIE")[1])
Local cCodOpe  := oMdlDJR:GetValue("DJR_CODOPE")
Local cCodRSEF := oMdlDJR:GetValue("DJR_CODSEF")
Local lAtuReg  := .F.
Local aVetDJR  := {}
Local lEnvEstor:= .F.

If DJQ->DJQ_ALIAS == 'DTY'
	//--Reenvia Registro para o ERP Datasul.	
	If MsgYesNo(STR0011)
		lEnvEstor := .T.		
	EndIf
	TMSAE76(.T., ,DJQ->DJQ_ALIAS,DJQ->DJQ_INDICE,DJQ->DJQ_CONTEU, lEnvEstor)	
Else
	SF3->(dbSetOrder(5))
	If SF3->(MsSeek(cFilDoc + cSerie + cDoc,.T.))	
	    //--Se cCodRSEF	= '101' (Cancelamento) e n�o possui '100' (Envio) no grid, for�ar o '100'
		If  cCodRSEF == PadR('101',TamSX3("DJR_CODSEF")[1]) .And. !oMdlDJR:SeekLine({{"DJR_CODSEF",PadR('100',TamSX3("DJR_CODSEF")[1]) }})
			cCodRSEF := PadR('100',TamSX3("DJR_CODSEF")[1])
		EndIf
		TMSAE76(.T.,cCodRSEF)
		lAtuReg := TMSIE76Sta("lAtuReg")
		aVetDJR := TMSIE76Sta("aVetDJR")
		If lAtuReg .And. !Empty(aVetDJR)
			//-- Cria nova linha e carrega dos dados
			oModel:GetModel("MdGridDJR"):SetNoInsertLine(.F.)
			oModel:GetModel("MdGridDJR"):SetNoDeleteLine(.F.)
		
			oMdlDJR:Addline()
		
			oMdlDJR:LoadValue("DJR_ALIAS" ,aVetDJR[1,1])
			oMdlDJR:LoadValue("DJR_INDICE",aVetDJR[1,2])
			oMdlDJR:LoadValue("DJR_CONTEU",aVetDJR[1,3])
			oMdlDJR:LoadValue("DJR_CODOPE",aVetDJR[1,4])
			oMdlDJR:LoadValue("DJR_DATENV",aVetDJR[1,5])
			oMdlDJR:LoadValue("DJR_HORENV",aVetDJR[1,6])
			oMdlDJR:LoadValue("DJR_USUENV",aVetDJR[1,7])
			oMdlDJR:LoadValue("DJR_TIPENV",aVetDJR[1,8])
			oMdlDJR:LoadValue("DJR_CODSEF",aVetDJR[1,9])

			oMdlDJR:GoLine(1)	
			oView:Refresh("VwGridDJR")

			oModel:GetModel("MdGridDJR"):SetNoInsertLine(.T.)
			oModel:GetModel("MdGridDJR"):SetNoDeleteLine(.T.)
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x)})

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CommitDJR  � Autor � Valdemar Roberto � Data � 03/02/2017  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava��o do registro                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CommitDJR()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE77                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function CommitDJR()
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AfterVwAct � Autor � Valdemar Roberto � Data � 03/02/2017  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Trata sa�da da tela via confirma��o sem alterar nada       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AfterVwAct()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE77                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function AfterVwAct(oView)
Local oModel

Default oView := FwViewActive()

oModel := oView:GetModel()

oModel:lModify := .T.
oView:lModify := .T.

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ExibeStat  � Autor � Valdemar Roberto � Data � 13/02/2017  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe status do documento                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExibeStat()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE77                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ExibeStat()
Local aAreas  := {DT6->(GetArea()),GetArea()}
Local oModel  := FwModelActive()
Local oView   := FwViewActive()
Local oMdlDJQ := oView:GetModel("MdFieldDJQ")
Local oMdlDJR := oView:GetModel("MdGridDJR")
Local cFilDoc := SubStr(oMdlDJQ:GetValue("DJQ_CONTEU"),1,TamSX3("DT6_FILDOC")[1])
Local cDoc    := SubStr(oMdlDJQ:GetValue("DJQ_CONTEU"),TamSX3("DT6_FILDOC")[1] + 1,TamSX3("DT6_DOC")[1])
Local cSerie  := SubStr(oMdlDJQ:GetValue("DJQ_CONTEU"),TamSX3("DT6_FILDOC")[1] + TamSX3("DT6_DOC")[1] + 1,TamSX3("DT6_SERIE")[1])
Local cRet    := ""

DT6->(DbSetOrder(1))
If DT6->(DbSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie))
	cRet := TMSValField("DT6->DT6_STATUS",.F.)
Else
	cRet := STR0010	//-- "DOCUMENTO N�O LOCALIZADO"
EndIf

AEval(aAreas,{|x,y| RestArea(x)})

Return cRet


//-----------------------------------------------------------------
/* TmSAE77Leg()
	Exibe legenda de acordo com o ultimo registro da tabela DJR
@author  	Leandro Paulino
@version 	P12 R12.1.16
@since 		22/03/2017
@return 	aRotina - Array com as op�oes de Menu */
//-----------------------------------------------------------------	
Static Function TMSAE77Leg()
Local cTitulo   := 'Status Mensagem Integra��o' // "Movimento de Custo de Transporte"
Local aStatus   := {}
Local cTxtLeg   := 'Legenda'
Local cQuery 	:= ''
Local cAliasDJR	:= GetNextAlias()

cQuery := "SELECT MAX(DJR.R_E_C_N_O_) nRecDJR"
cQuery += "  FROM " + RetSQLTab('DJR')
cQuery += " WHERE DJR.DJR_FILIAL = '" + FwxFilial('DJR') + "' AND "
cQuery += "       DJR.DJR_ALIAS  = '" + DJQ->DJQ_ALIAS 	 + "' AND "
cQuery += "       DJR.DJR_INDICE = '" + DJQ->DJQ_INDICE  + "' AND "
cQuery += "       DJR.DJR_CONTEU = '" + DJQ->DJQ_CONTEU  + "' AND "
cQuery += "       DJR.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDJR)

If (cAliasDJR)->nRecDJR > 0
	DJR->(DbGoTo((cAliasDJR)->(nRecDJR)))
	cReturn := AllTrim(DJR->DJR_STATUS)
EndIf
(cAliasDJR)->(DbCloseArea())

Aadd( aStatus, {'cReturn== "1"'   ,'BR_VERMELHO' } ) // 'Em Aberto'
Aadd( aStatus, {'cReturn== "2"'   ,'BR_AZUL' }) // 'Baixa Parcial'
Aadd( aStatus, {'cReturn== "3"'   ,'BR_AMARELO' } ) // 'Baixa Total'
Aadd( aStatus, {'cReturn== "4"'	  ,"BR_PINK" 	} )	//"Transferencia Interna de Filial"		  	

//BrwLegenda( cTitulo, cTxtLeg, aStatus ) //'Legenda'

Return aStatus

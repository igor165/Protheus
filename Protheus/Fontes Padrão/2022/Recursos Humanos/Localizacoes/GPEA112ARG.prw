#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "GPEA112ARG.CH"
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GPEA112ARG  � Autor � Raul Ortiz Medina     � Data � 15/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Menu Funcional                                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEA112ARG()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function GPEA112ARG()
Local 	oBrowse 

Private cFilInf := SQJ->QJ_FILIAL
Private cCodInf	:= SQJ->QJ_COD
Private lDesc := .F.

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SQJ')
oBrowse:SetDescription(OemToAnsi(STR0001))
	
oBrowse:DisableDetails()
oBrowse:Activate() 

Return NIL
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MenuDef     � Autor � Raul Ortiz Medina     � Data � 15/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Definici�n del Menu                                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.GPEA112ARG' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.GPEA112ARG' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.GPEA112ARG' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.GPEA112ARG' OPERATION 5 ACCESS 0
	
Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ModelDef    � Autor � Raul Ortiz Medina     � Data � 15/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Modelado del Grid                                             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Static Function ModelDef()
Local bAvalCampo          := {|cCampo| AllTrim(cCampo)+"|" $ "QJ_COD|QJ_NOMREP|"}
Local oStruSQJ := FWFormStruct(1, 'SQJ', bAvalCampo,/*lViewUsado*/)
Local oStruSQK := FWFormStruct(1, 'SQK', /*bAvalCampo*/,/*lViewUsado*/)
Local oModel
	
oStruSQK:SetProperty( 'QK_PD' , MODEL_FIELD_VALID,{|oMdl| GPEA112VLD(oMdl)}) // comentario 26/10/2015
//oStruSQK:SetProperty( 'QK_PD' , MODEL_FIELD_VALID,{|oMdl| VLDTPOCMP(oMdl)})
	
//oStruSQK:SetProperty( 'QK_DESCPD' ,MODEL_FIELD_INIT, AllTrim(POSICIONE("SRV", 1,xFilial("SRV") + FwBuildFeature( STRUCT_FEATURE_INIPAD,'SQK->QK_PD') , "RV_DESC"))  )
//oStruSQK:SetProperty( 'QK_TIPOCMP' , MODEL_FIELD_VALID,{|oMdl| VLDTPOCMP(oMdl)})
	
oModel := MPFormModel():New('GPEA112ARG', /*bPreValid*/ , /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('SQJMASTER', /*cOwner*/, oStruSQJ, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)
	
oModel:AddGrid( 'SQKDETAIL', 'SQJMASTER', oStruSQK, /*bLinePre*/,{|oMdl| VLDTPOCMP(oMdl)}/*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetRelation('SQKDETAIL', {{'QK_FILIAL', 'xFilial("SQK")'}, {'QK_COD', 'QJ_COD'}}, SQK->(IndexKey(1)))
	
oModel:GetModel('SQKDETAIL'):SetUniqueLine({'QK_COD', 'QK_PD'})
	
oModel:GetModel('SQKDETAIL'):SetOptional(.T.)

//oModel:GetModel('RVCMASTER'):SetOnlyView(.T.)
	
oModel:GetModel('SQJMASTER'):SetDescription(OemToAnsi(STR0001)) // "Funcionários"
oModel:GetModel('SQKDETAIL'):SetDescription(OemToAnsi(STR0002))
	
Return oModel

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ViewDef     � Autor � Raul Ortiz Medina     � Data � 15/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Definici�n de la vista del grid                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ViewDef()

Local oModel   := FWLoadModel('GPEA112ARG')
Local bAvalCampo          := {|cCampo| AllTrim(cCampo)+"|" $ "QJ_COD|QJ_NOMREP|"}
Local oStruSQJ := FWFormStruct(2, 'SQJ', bAvalCampo)
Local oStruSQK := FWFormStruct(2, 'SQK')
Local oView

	cFilInf := SQJ->QJ_FILIAL 
	cCodInf := SQJ->QJ_COD


	oView := FWFormView():New()

	oStruSQK:RemoveField('QK_COD')
	
	oView:SetModel(oModel)
	
	oView:AddField('VIEW_SQJ', oStruSQJ, 'SQJMASTER')

	//oStruRVC:SetNoFolder()
	
	oView:AddGrid('VIEW_SQK', oStruSQK, 'SQKDETAIL')
	
	oView:CreateHorizontalBox('SUPERIOR', 20)
	oView:CreateHorizontalBox('INFERIOR', 80)
	
	oView:SetOwnerView('VIEW_SQJ', 'SUPERIOR')
	oView:SetOwnerView('VIEW_SQK', 'INFERIOR')
	
	oView:EnableTitleView('VIEW_SQK', OemToAnsi(STR0002))
	
Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GPEA112VLD  � Autor � Raul Ortiz Medina     � Data � 15/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Valida informaci�n del detalle                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEA112VLD(oModelGrid)                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros�oModelGrid -  Objeto con el Grid                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function GPEA112VLD(oModelGrid)
Local lRet 			:= .T.
Local oModel 		:= oModelGrid:GetModel('SQKDETAIL')
Local nLinea		:= 0
Local nTotLin		:= 0
Local nLineaAt		:= 0
Local nOperation	:= oModel:GetOperation()
Local cDesc 		:= ""
	
	nLineaAt := oModelGrid:nLine
	
	If nOperation == 4 .or. nOperation == 3
		
		If VldPDEL(@cDesc, oModelGrid:GetValue('QK_PD', nLineaAt))
			nTotLin	:= oModelGrid:GetQtdLine()
			For nLinea:=1 to nTotLin
				If nLinea != nLineaAt
					If !oModelGrid:IsDeleted(nLinea)
						If oModelGrid:GetValue('QK_PD', nLinea) == oModelGrid:GetValue('QK_PD', nLineaAt)
							Alert(OemToAnsi(STR0007) + oModelGrid:GetValue('QK_PD', nLineaAt) + OemToAnsi(STR0010))
							lRet := .F.
							Return lRet
						EndIf
					EndIf
				EndIf
			Next
			oModelGrid:loadValue('QK_DESCPD', cDesc)
			oModelGrid:loadValue('QK_COD', M->QJ_COD)
		Else
			lRet := .F.
		EndIf	
	EndIf
	
Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �VLDTPOCMP   � Autor � Raul Ortiz Medina     � Data � 15/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Valida informaci�n del detalle de acuero a QK_TIPOCMP         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VLDTPOCMP(oModelGrid)                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros�oModelGrid -  Objeto con el Grid                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function VLDTPOCMP(oModelGrid)
Local lRet := .T.
Local oModel 		:= oModelGrid:GetModel('SQKDETAIL')
Local nLineaAt		:= 0
Local nOperation	:= oModel:GetOperation()
Local cAlert := ""
Local cCRLF		  	:= ( chr(13)+chr(10) )

//////
Local nlinea := 0
	nLineaAt := oModelGrid:nLine
	
	If nOperation == 4 .or. nOperation == 3
		If oModelGrid:GetValue('QK_TIPOCMP', nLineaAt) == "1" .or. oModelGrid:GetValue('QK_TIPOCMP', nLineaAt) == "3"
			If oModelGrid:GetValue('QK_IMINPOR', nLineaAt) == 0
				cAlert += Substr(STR0009,1,18) + '* ' + AllTrim(POSICIONE("SX3", 2, "QK_IMINPOR" , "X3_TITSPA"))
				cAlert += cCRLF
				lRet := .F.
			EndIf
			If oModelGrid:GetValue('QK_IMINVAL', nLineaAt) == 0
				cAlert += Substr(STR0009,1,18) + '* ' + AllTrim(POSICIONE("SX3", 2, "QK_IMINVAL" , "X3_TITSPA"))
				cAlert += cCRLF
				lRet := .F.
			EndIf
			If oModelGrid:GetValue('QK_IMAXPOR', nLineaAt) == 0
				cAlert += Substr(STR0009,1,18) + '* ' + AllTrim(POSICIONE("SX3", 2, "QK_IMAXPOR" , "X3_TITSPA"))
				cAlert += cCRLF 
				lRet := .F.
			EndIf
			If oModelGrid:GetValue('QK_IMAXVAL', nLineaAt) == 0 
				cAlert += Substr(STR0009,1,18) + '* ' + AllTrim(POSICIONE("SX3", 2, "QK_IMAXVAL" , "X3_TITSPA"))
				cAlert += cCRLF
				lRet := .F.
			EndIf
		EndIf
			
		If oModelGrid:GetValue('QK_TIPOCMP', nLineaAt) == "2" .or. oModelGrid:GetValue('QK_TIPOCMP', nLineaAt) == "3"
			If oModelGrid:GetValue('QK_CMINPOR', nLineaAt) == 0 
				cAlert += Substr(STR0009,1,18) + '* ' + AllTrim(POSICIONE("SX3", 2, "QK_CMINPOR" , "X3_TITSPA"))
				cAlert += cCRLF
				lRet := .F.
			EndIf
			If oModelGrid:GetValue('QK_CMINVAL', nLineaAt) == 0 
				cAlert += Substr(STR0009,1,18) + '* ' + AllTrim(POSICIONE("SX3", 2, "QK_CMINVAL" , "X3_TITSPA"))
				cAlert += cCRLF
				lRet := .F.
			EndIf
			If oModelGrid:GetValue('QK_CMAXPOR', nLineaAt) == 0 
				cAlert += Substr(STR0009,1,18) + '* ' + AllTrim(POSICIONE("SX3", 2, "QK_CMAXPOR" , "X3_TITSPA"))
				cAlert += cCRLF
				lRet := .F.
			EndIf
			If oModelGrid:GetValue('QK_CMAXVAL', nLineaAt) == 0 
				cAlert += Substr(STR0009,1,18) + '* ' + AllTrim(POSICIONE("SX3", 2, "QK_CMAXVAL" , "X3_TITSPA"))
				cAlert += cCRLF
				lRet := .F.
			EndIf
		EndIf

		If !lRet
			lRet:= .F.
			Help('',1,"OBRIGAT",,cAlert,1,0)
			
			
		EndIf
	EndIf
	
Return lRet
 /*
 */
Static Function ObtDesc(oModelGrid)
Local oModel 		:= oModelGrid:GetModel('SQKDETAIL')
Local nLinea		:= 0
Local nTotLin		:= 0
Local nLineaAt		:= 0
Local nOperation	:= oModel:GetOperation()

	If !lDesc
		lDesc := .T.
		If !Inclui
			
		EndIf
	EndIf


Return 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �VldCodEL    � Autor � Raul Ortiz Medina     � Data � 15/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Valida que no exista el c�digo en la tabla SQJ                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VldCodEL()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function VldCodEL()
Local lRet := .T.

	If Inclui 
		dbSelectArea("SQJ")
		dbSetOrder(1)
			If dbSeek(xFilial("SQJ")+M->QJ_COD)
				lRet := .F.
				Help('',1,"JAGRAVADO",,oemToAnsi(STR0007) + M->QJ_COD + oemToAnsi(STR0008),1,0)

			EndIf
		DbCloseArea()  
     EndIf 
	
Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �VldPDEL     � Autor � Raul Ortiz Medina     � Data � 15/10/15 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Menu Funcional                                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VldPDEL(cDesc,cCod)                                          ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cDesc - Descripci�n del concepto                             ���
���          � cCod - C�digo del concepto                                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function VldPDEL(cDesc,cCod)
Local lRet := .T.


	If empty(AllTrim(M->QJ_COD)) .and. Inclui
		Alert(oemToAnsi(STR0009))
		Help('',1,"OBRIGAT",,oemToAnsi(STR0009),1,0)
		
		lRet := .F.
	Else 
		If Inclui .or. Altera
			If !Empty(cCod)		
				dbSelectArea("SRV")
				SRV->(dbSetOrder(1))
					If !SRV->(dbSeek(xFilial("SRV")+cCod))
						lRet := .F.
						Alert(oemToAnsi(STR0007) + cCod + oemToAnsi(STR0011)) //////  25/10/2015
					Return lRet
					Else	
						cDesc := SRV->RV_DESC
					EndIf
				SRV->(DbCloseArea())
			Else
				lRet := .F.
			EndIf 
			/*dbSelectArea("RVD")AD
			RVD->(dbSetOrder(2))
				If RVD->(dbSeek(xFilial("RVD")+M->RVC_COD+M->RVD_PD))
					lRet := .F.
					Alert(oemToAnsi(STR0007) + M->RVD_COD + oemToAnsi(STR0010))
				EndIf
			RVD->(DbCloseArea())*/
		 EndIf
	EndIf

Return lRet
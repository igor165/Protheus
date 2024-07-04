#Include "protheus.ch"
#Include "fwmvcdef.ch"
#Include "rwmake.ch"
#Include "mata446.ch"
/*��������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � MATA446  �Autor  �Marco Augusto          � Data � 25/02/2016    ���
������������������������������������������������������������������������������͹��
���Desc.     � Registro de Fracciones Arancelarias (MEX)                       ���
������������������������������������������������������������������������������͹��
���Uso       � Generico                                                        ���
������������������������������������������������������������������������������͹��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
������������������������������������������������������������������������������͹��
���Programador� Data     � BOPS/FNC | Motivo da Alteracao                      ���
������������������������������������������������������������������������������͹��
���	Marco A.  �18/10/2016�PCDEF2015_� Se agrega validacion de los parametros   ���
���	          �          �2016-7825 � MV_COMPINT y MV_EASY, para su correcta   ���
���	          �          �          � configuracion. (MEX)                     ���
��� Marco A   � 29/09/17 �TSSERMI01-�Se realiza replica para V12.1.17, de la   ���
���           �          �151       �funcionalidad de Pedimentos de Importacion���
���           �          �          �para el Pais Mexico.                      ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
��������������������������������������������������������������������������������*/
Function MATA446()
	
	Local oBrowse	:= Nil
	Local lParamsOk	:= SuperGetMv("MV_COMPINT") == .F. .Or. SuperGetMv("MV_EASY") == "S"
	
	If lParamsOk
		Help(" ", 1, "COMPINT", Nil, "", 1, 0)
		Return
	Else
		oBrowse	:= FWMBrowse():New()
		oBrowse:SetAlias("RSB")
		oBrowse:SetDescription(STR0001) //"Fracciones Arancelarias"
		oBrowse:Activate()
	EndIf

Return Nil

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � MenuDef    � Autor � Marco Augusto Glz     � Data �25/02/2016���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Definicion del menu para Registro de Fracciones Arancelarias ���
���          � (MEX)                                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � MATA446                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function MenuDef()
	
	Local aRotina	:= {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.MATA446" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.MATA446" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.MATA446" OPERATION 4 ACCESS 0 // "Modificar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.MATA446" OPERATION 5 ACCESS 0 // "Eliminar"

Return aRotina

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ModelDef   � Autor � Marco Augusto Glz     � Data �25/02/2016���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Creacion del Modelo para Registro de Fracciones Arancelarias ���
���          � (MEX)                                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � MATA446                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function ModelDef()
	
	Local oStruRSB	:= FWFormStruct(1, "RSB")
	Local oModel
	
	oModel := MPFormModel():New("RSB001M", /*bPreValidacao*/, {|oMdl| MATA446Pos(oMdl)}, /*bCommit*/, /*bCancel*/ ) // Creacion del Modelo
	oModel:AddFields("RSBMASTER", /*cOwner*/, oStruRSB)
	oModel:SetPrimaryKey({"RSB_FRACC"})
	oModel:SetDescription(STR0006) // "Fracciones Arancelarias"
	oModel:GetModel("RSBMASTER"):SetDescription(STR0007) // "Datos de Fracciones Arancelarias"

Return oModel

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ViewDef    � Autor � Marco Augusto Glz     � Data �25/02/2016���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Creacion de la Vista para Registro de Fracciones Arancelarias���
���          � (MEX)                                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � MATA446                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function ViewDef()
	
	Local oModel		:= FWLoadModel("MATA446") // Se obtiene el modelo para utilizarlo en la vista
	Local oStruRSB	:= FWFormStruct(2, "RSB")
	Local oView
	
	oView	:= FWFormView():New()// Creacion de la Vista
	oView:SetModel(oModel)
	oView:AddField("VIEW_RSB", oStruRSB, "RSBMASTER")
	oView:CreateHorizontalBox("TELA", 100)
	oView:SetOwnerView("VIEW_RSB", "TELA")
	
Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun�ao    � MTA446Pos     � Autor � Marco Augusto Glz     � Data �25/02/2016���
������������������������������������������������������������������������������Ĵ��
���Descri�ao � Definicion de la logica para PosValidacion de Fracciones Aran-  ���
���          � celarias. (MEX)                                                 ���
������������������������������������������������������������������������������Ĵ��
��� Uso      � MATA446                                                         ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function MATA446Pos(oModel)

	Local lRet			:= .T.
	Local aArea			:= GetArea()
	Local nOperation	:= oModel:GetOperation() // Se obtiene la operacion seleccionada por el usuario
	Local lAutomato		:= IsBlind()	// Vari�veis utilizadas no Robo de testes
	
	If nOperation  == MODEL_OPERATION_DELETE
	
		DbSelectArea("RSG")
		RSG->(DbSetOrder(2)) // RSG_FILIAL+RSG_FRACAR
		 
		lRet := RSG->(DBSeek(xFilial("RSG")+RSB->RSB_FRACC)) // Se verifica si hay relacion de una Fraccion Arancelaria con un Pedimento
		
		If lRet 
			If !lAutomato
				msgAlert(STR0008) // "La Fraccion Arancelaria esta siendo utilizada por un Pedimento. No es posible eliminarla."
			Else
				Help( ,, "Auto01", STR0008, 1, 0 )
			EndIf
			lRet := .F.
		Else
			If !lAutomato
				If MsgYesNo(STR0009) // "�Desea confirmar la eliminacion?"
					lRet := .T.
				Else
					lRet := .F.
				EndIf
			Else
				If FindFunction( "GetParAuto" )
					aRetAuto := GetParAuto( "MATA446TESTCASE" )	
					lRet := aRetAuto[1]
				EndIf 
			EndIf
		EndIf
	
	EndIf
	
	RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun�ao    � MTA446FracVld  � Autor � Marco Augusto Glz     � Data �25/02/2016���
�������������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcion creada para validar que en la tabla RSB, no existan      ���
���          � registros con Fraccion Arancelaria repetida por Pais. (MEX)      ���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � En X3_VALID de los campos RSB_FRACC y RSB_PAIS                   ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

Function MTA446FracVld()

	Local lRet		:= .F.
	Local aArea	:= GetArea()

	If !Empty(M->RSB_FRACC)
		
		DbSelectArea("RSB")
		dbSetOrder(1) // RSB_FILIAL+RSB_FRACC+RSB_PAIS
		If !DbSeek(xFilial("RSB") + M->RSB_FRACC + M->RSB_PAIS)
			lRet := .T.
		ElseIf RSB->RSB_FILIAL == M->RSB_FILIAL .AND. RSB->RSB_FRACC == M->RSB_FRACC .AND. RSB_PAIS == M->RSB_PAIS
			lRet := .T.
		Else
			MsgInfo(STR0010) // "La Fracci�n Arancelaria ya est� relacionada a otro registro. Selecciona otro Pa�s u otra Fracci�n Arancelaria." 
		EndIf
	EndIf
	
	RestArea(aArea)

Return lRet
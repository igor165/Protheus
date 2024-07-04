#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"  
#INCLUDE "FISA016.CH"  

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � FISA016  � Autor � Felipe V. Nambara       � Data �12/01/2010���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro na tabela CCN                                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � FISA016                                                      ���
���            C�digos Industrial Internacional Uniforme                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                     				    	    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � LOCALIZADO COLOMBIA/EUA                                      ���
���������������������������������������������������������������������������Ĵ��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.            ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS     �  MOTIVO DA ALTERACAO                 ���
���������������������������������������������������������������������������Ĵ��
���Luis Enr�quez �06/12/18�DMINA-1012�Rep. DMINA-253 Se realizan cambios pa-���
���              �        �(EUA)     �localizaci�n, creaci�n de lVldRelSFF()���
���              �        �          �y se agrega como param. en AxCadastro.���
���    Marco A.  �12/06/20�DMINA-9311�Se agrega tratamiento para rutina au- ���
���              �        �          �matica (TIR) en la funcion CIIUCol.   ���
���              �        �          �(COL)                                 ���
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function FISA016()
	If cPaisLoc == "COL"
		CIIUCol()
	EndIf
	AxCadastro("CCN",IIf(cPaisLoc == "EUA", STR0008, STR0001),IIf(cPaisLoc == "EUA", "lVldRelSFF()", "IVALIDCCN()"))  //"Registro de Actividad Econ�mica" "C�digos Industrial Internacional Uniforme"
Return()      

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �IVALIDCCN �Autor  � Felipe V. Nambara    � Data � 12/01/2010  ���
���������������������������������������������������������������������������͹��
���Descricao � Valida relacion con tabla CNN y con ello determinar si el    ���
���          � registro puede ser eliminado.                                ���
���������������������������������������������������������������������������͹��
���Parametros� cExp1: Codigo de la Ciudad (CC2_CODMUN)                      ���
���������������������������������������������������������������������������͹��
���Uso       � Campos CC2_CODMUN (EUA)                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function IVALIDCCN()
	Local llFlag := .T.
	Local alAreaSF4
	Local alAreaSA2
	Local clIndexSF4 := CriaTrab(Nil,.F.)
	Local nlIndexSF4 := 0
	Local clIndexSA2 := CriaTrab(Nil,.F.)
	Local nlIndexSA2 := 0
	               
	alAreaSF4 := SF4->(GetArea())
	alAreaSA2 := SA2->(GetArea())
             
	DbSelectArea("SF4")
	
	IndRegua("SF4",clIndexSF4,"F4_FILIAL+F4_CIIU",,,"")
	
	nlIndexSF4 := RetIndex("SF4")+1		
	
	DbSetOrder(nlIndexSF4)       
	
	DbGoTop()            
	
	If DbSeek(xFilial("SF4")+CCN->CCN_AGCIIU)
		llFlag := .F.
		Aviso(STR0002,STR0004 + SF4->F4_CODIGO,{STR0003}) //"ATENCAO"###"N�o � poss�vel excluir esse c�digo de agrupamento, pois o mesmo possui relacionamento com o TES: "###"OK"
	EndIf
	
	FErase(clIndexSF4+OrdBagExt())
		
	If llFlag
		DbSelectArea("SA2")	
		
		IndRegua("SA2",clIndexSA2,"A2_FILIAL+A2_CODICA",,,"")
		
		nlIndexSA2 := RetIndex("SA2")+1		
		
		DbSetOrder(nlIndexSA2)       

		If DbSeek(xFilial("SA2")+CCN->CCN_CIIU)
			llFlag := .F.
			Aviso(STR0002,STR0006 + SA2->A2_NOME + STR0007 + SA2->A2_LOJA,{STR0003}) //"ATENCAO"###"N�o � poss�vel excluir esse c�digo de CIIU, pois o mesmo possui relacionamento com o fornecedor: "###"  Loja: "###"OK"
		EndIf
	                                  
		FErase(clIndexSA2+OrdBagExt())
	EndIf         	                  	
		                         
	RestArea(alAreaSF4)
	RestArea(alAreaSA2)	
Return(llFlag)

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �lVldRelSFF� Autor � Marco A. Gonzalez R. � Data � 12/01/2010  ���
���������������������������������������������������������������������������͹��
���Descricao � Valida si existe relacion con tabla SFF.                     ���
���������������������������������������������������������������������������͹��
���Uso       � FISA016 (EUA)                                                ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function lVldRelSFF()
	Local lRet		:= .T.
	Local cQuery	:= ""
	Local nCount	:= 0
	Local cTmpSFF	:= CriaTrab(Nil, .F.)
	Local cFilSFF	:= xFilial("SFF")

	cQuery := "SELECT FF_ZONFIS, FF_COD_TAB"
	CQuery += " FROM " + RetSqlName("SFF") + " SFF"
	cQuery += " WHERE FF_FILIAL	= '" + cFilSFF	+ "'"
	cQuery += " AND FF_ZONFIS = '" + CCN_AGCIIU + "'"
	cQuery += " AND FF_COD_TAB = '" + CCN_CIIU + "'"
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)   
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTmpSFF, .T., .T.)

	Count to nCount 

	(cTmpSFF)->(DBCloseArea())

	If nCount <> 0
		lRet := .F.
		MsgInfo(STR0009, STR0010) //"El registro no puede ser eliminado, ya que se encuentra utilizado en Zonas Fiscales vs Impuestos."  "Registro utilizado"
	EndIf
Return lRet
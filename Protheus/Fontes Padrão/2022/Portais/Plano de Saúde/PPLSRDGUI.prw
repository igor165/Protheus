#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLPEECB   � Autor � Totvs					� Data � 05/02/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Monta plano, especialidade, estado, cidade, bairro         ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function PLPEECB()
LOCAL nTp    	:= paramixb[1] 
LOCAL cCodEsp	:= paramixb[2] 
LOCAL cCodEst	:= paramixb[3] 
LOCAL cCodMun	:= paramixb[4] 
LOCAL cSql	 	:= ""
//��������������������������������������������������������������������������
//� Verifica se o registro existe
//��������������������������������������������������������������������������
Do Case
	//��������������������������������������������������������������������������
	//� Especialidades
	//��������������������������������������������������������������������������
	Case nTp == 1
		cSql := " SELECT DISTINCT BAQ_CODESP CODIGO, BAQ_DESCRI DESCRICAO"
		cSql += "  FROM " + RetSQLName("BAX") + "," + RetSQLName("BAQ")
		cSql += " WHERE BAX_FILIAL 	= '" + xFilial("BAX") + "' "
		cSql += "   AND BAX_CODINT 	= '" + PLSINTPAD() + "' "
		cSql += "   AND BAX_GUIMED	= '1' "
		cSql += "   AND BAX_DATBLO 	= '' "
		cSql += "   AND " + RetSQLName("BAX") + ".D_E_L_E_T_ = '' "
		cSql += "   AND BAQ_FILIAL 	= BAX_FILIAL "
		cSql += "   AND BAQ_CODINT	= BAX_CODINT "
		cSql += "   AND BAQ_CODESP	= BAX_CODESP "
		cSql += "   AND " + RetSQLName("BAQ") + ".D_E_L_E_T_ = '' "
		csql += "   ORDER BY BAQ_DESCRI"
		
	//��������������������������������������������������������������������������
	//� Estados dos planos x especialidades
	//��������������������������������������������������������������������������
	Case nTp == 2
		cSql := " SELECT DISTINCT X5_CHAVE CODIGO, X5_DESCRI DESCRICAO"
		cSql += "   FROM " + RetSQLName("BB8") + "," + RetSQLName("BAX")+ "," + RetSQLName("SX5")
		cSql += "  WHERE BB8_FILIAL = '" + xFilial("BB8") + "' "
		cSql += "    AND BB8_CODINT = '" + PLSINTPAD() + "' "
		cSql += "    AND BB8_DATBLO = '' "
		cSql += "    AND " + RetSQLName("BB8") + ".D_E_L_E_T_ = '' "
		cSql += "    AND BAX_FILIAL = BB8_FILIAL "
		cSql += "    AND BAX_CODINT = BB8_CODINT "
		
		If !Empty(cCodEsp)	
			cSql += "    AND BAX_CODESP = '" + cCodEsp + "' "
		EndIf	
		
		cSql += "    AND " + RetSQLName("BAX") + ".D_E_L_E_T_ = '' "
		cSql += "    AND X5_TABELA 	= '12' "
		cSql += "    AND X5_CHAVE  	= BB8_EST "
		cSql += "    AND " + RetSQLName("SX5") + ".D_E_L_E_T_ = '' "
		csql += "    ORDER BY X5_DESCRI"
		
	//��������������������������������������������������������������������������
	//� Cidades dos estados x planos x especialidades
	//��������������������������������������������������������������������������
	Case nTp == 3
		cSql := " SELECT DISTINCT BB8_CODMUN CODIGO ,BB8_MUN DESCRICAO"
		cSql += "   FROM " + RetSQLName("BB8") + "," + RetSQLName("BAX")
		cSql += "  WHERE BB8_FILIAL	= '" + xFilial("BB8") + "' "
		cSql += "    AND BB8_CODINT	= '" + PLSINTPAD() + "' "
		cSql += "    AND BB8_DATBLO	= '' "
		
		If !Empty(cCodEst)
			cSql += " AND BB8_EST = '" + cCodEst + "' "
		EndIf	                                          
		
		cSql += "    AND " + RetSQLName("BB8") + ".D_E_L_E_T_ = '' "
		cSql += "    AND BAX_FILIAL = BB8_FILIAL "
		cSql += "    AND BAX_CODINT = BB8_CODINT "

		If !Empty(cCodEsp)	
			cSql += " AND BAX_CODESP = '" + cCodEsp + "' "
		EndIf	

		cSql += "    AND " + RetSQLName("BAX") + ".D_E_L_E_T_ = '' "
		csql += "    ORDER BY BB8_MUN"

	//��������������������������������������������������������������������������
	//� Bairros das cidades x estados x planos x especialidades
	//��������������������������������������������������������������������������
	Case nTp == 4
		cSql := " SELECT DISTINCT BB8_BAIRRO CODIGO ,BB8_BAIRRO DESCRICAO"
		cSql += "   FROM " + RetSQLName("BB8") + "," + RetSQLName("BAX")
		cSql += "  WHERE BB8_FILIAL = '" + xFilial("BB8") + "' "
		cSql += "    AND BB8_CODINT = '" + PLSINTPAD() + "' "
	    cSql += "    AND BB8_DATBLO = '' "          
	    cSql += "    AND BB8_BAIRRO <> '' " 

		If !Empty(cCodEst)
			cSql += " AND BB8_EST = '" + cCodEst + "' "
		EndIf	                                          
        
		If !Empty(cCodMun)
			cSql += " AND BB8_CODMUN = '" + cCodMun + "' "
		EndIf
			
		cSql += "    AND " + RetSQLName("BB8") + ".D_E_L_E_T_ = '' "
		cSql += "    AND BAX_FILIAL = BB8_FILIAL "
		cSql += "    AND " + RetSQLName("BAX") + ".D_E_L_E_T_ = '' "
		cSql += "    AND BAX_CODINT = BB8_CODINT "

		If !Empty(cCodEsp)	
			cSql += " AND BAX_CODESP = '" + cCodEsp + "' "
		EndIf	
		cSql += "    ORDER BY BB8_BAIRRO"

EndCase		  
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( cSql )
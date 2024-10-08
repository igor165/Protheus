#Include "Protheus.Ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FISA055 �Autor  �Camila Janu�rio      � Data � 24/09/2012   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria arquivo tempor�rio de movimenta��es a serem apresenta- ���
���          �dos no CPOM-Cadastro de Prestadores de Outros do Munic�pios ���
�������������������������������������������������������������������������͹��
���Uso       �Prefeitura de SP-Cadastro de Prestadores de Servicos Outros ���
���          �munic�pios 												  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fisa055(dDataIni,dDataAte,aInfo)

Local aTemp 	 := StructTMP()
Local aAreaAtu 	 := {}
Local aArea1     := {}
Local aCod 		 := {} 
Local cQuery     := ""
Local cAliasTmp  := "SF3"
Local cMunicip   := "50308" //S�o Paulo 
Local nX		 := 1
Local nSF3 		 := 0
Local nIndex     := 1
Local lQuery	 := .F.
Local lGrava     := .F.
  

#IFDEF TOP
	Local aStruTMP	:= {}
	nX          	:= 0
#ELSE
	Local cArqInd	:= ""
	Local cChave	:= ""
	Local cFiltro	:= ""	
#ENDIF

dbSelectArea("SF3")
dbSetOrder(1)

#IFDEF TOP  
    If TcSrvType()<>"AS/400"    
	    cAliasTMP	:= GetNextAlias()
	   	lQuery    	:= .T.
		aStruTMP  	:= SF3->(dbStruct())
		//�������������������������������������������������������������Ŀ
		//�Faz a busca no livro fiscal SF3 juntamente com o SA2 para    �
		//�trazer as informa��es dos fornecedores que prestaram servicos�
		//�no periodo informado nos parametros                          �
		//���������������������������������������������������������������
		cQuery:= "SELECT DISTINCT F3_FILIAL, F3_ENTRADA, F3_TIPO, F3_CLIEFOR, "
		cQuery+= "F3_LOJA, F3_CODISS, F3_ESTADO, A2_COD, A2_LOJA, A2_EST, A2_CGC, "
		cQuery+= "A2_FILIAL, A2_NOME, A2_NR_END, A2_BAIRRO, A2_END, "
		cQuery+= "A2_COD_MUN, A2_MUN, A2_CEP, A2_COMPLEM"
		cQuery+= " , A2_TPLOGR, A2_CPOMSP"
   		cQuery+= " FROM " +RetSqlName("SF3")+ " SF3 "
   		cQuery+= "LEFT JOIN " +RetSqlName("SA2")+ " SA2 ON "
   		cQuery+= "F3_CLIEFOR = A2_COD AND F3_LOJA = A2_LOJA WHERE "	   		
   		cQuery+= "F3_FILIAL = '"+xFilial("SF3")+"' AND "
   		cQuery+= "A2_FILIAL = '"+xFilial("SA2")+"' AND " 
   		cQuery+= "A2_COD_MUN <> '"+cMunicip+"' AND "    		
   		cQuery+= "F3_ENTRADA >= '"+DTOS(dDataIni)+"' AND " 
   		cQuery+= "F3_ENTRADA <= '"+DTOS(dDataFim)+"' AND "
		cQuery+= "F3_CLIEFOR >= '"+aInfo[1][1]+"' AND "             
   		cQuery+= "F3_CLIEFOR <= '"+aInfo[1][2]+"' AND "             
		cQuery+= "F3_LOJA >= '"+aInfo[1][3]+"' AND " 
   		cQuery+= "F3_LOJA <= '"+aInfo[1][4]+"' AND "  
   		cQuery+= "F3_TIPO = 'S' AND "
	   	cQuery+= "A2_CPOMSP <> '1' AND "
   		cQuery+= "SF3.D_E_L_E_T_ = '' AND "
 		cQuery+= "SA2.D_E_L_E_T_ = '' "   
		cQuery+= "ORDER BY F3_FILIAL, F3_ENTRADA"
					
		cQuery	:= ChangeQuery(cQuery)    	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)		
		//���������������������������������������������������������om�
		//�Cria o arquivo tempor�rio baseado nas caracter�sticas da�
		//�tabela (aStruTMP) e gerando os registros de acordo com  �
		//�o resultado da query                                    �
		//���������������������������������������������������������om�
		For nSF3 := 1 To Len(aStruTMP)
			If aStruTMP[nSF3][2] <> "C" .and. FieldPos(aStruTMP[nSF3][1]) > 0
				TcSetField(cAliasTMP,aStruTMP[nSF3][1],aStruTMP[nSF3][2],aStruTMP[nSF3][3],aStruTMP[nSF3][4])
			EndIf
		Next nSF3
	Else                                        

#ENDIF            
		//��������������������������������������������������������������Ŀ
		//�Faz a busca na movimentacao do livro fiscal e traz as notas de�
		//�servico dos fornecedores e periodo informado                  �
		//����������������������������������������������������������������
		cArqInd	:=	CriaTrab(NIL,.F.)
		cChave	:=	SF3->(IndexKey())                                     
		cFiltro :=  "F3_FILIAL =='"+xFilial("SF3")+ "'.And. F3_ENTRADA >='"+DTOS(dDataIni)+"' .AND. F3_ENTRADA <='"+DTOS(dDataFim)+"' .And. "
		cFiltro +=  "F3_CLIEFOR >='"+aInfo[1][1]+"' .And. F3_CLIEFOR <='"+aInfo[1][2]+"' .AND. F3_LOJA >='"+aInfo[1][3]+"' .And. "
		cFiltro +=  "F3_LOJA <='"+aInfo[1][4]+"' .And. F3_TIPO == 'S' "
		IndRegua(cAliasTMP,cArqInd,cChave,,cFiltro,"Selecionando Registros")
	   	#IFNDEF TOP 
	   		nIndex := RetIndex("SF3")+1
			DbSetIndex(cArqInd+OrdBagExt())
			DbSelectArea("SF3")
			DbSetOrder(1)
	    	DbSelectArea("SA2")
			DbSetOrder(1)						
		#ENDIF              
		(cAliasTMP)->(dbGotop())		  
#IFDEF TOP
	Endif    
#ENDIF    

dbSelectArea(cAliasTMP)
ProcRegua(LastRec())
(cAliasTMP)->(DbGoTop())

//������������������������������������������������������Ŀ
//�Gravo no arquivo tempor�rio o conte�do dos campos que �
//�ser�o usados na leitura do arquivo CPOMSP.ini          �
//��������������������������������������������������������
While (cAliasTMP)->(!Eof())                  
	IncProc()
	//���������������������������������������������������������Ŀ
	//�Verifica se o servico esta entre os que devem gerar CPOM.�
	//�A definicao dos servicos estao no paramentro MV_CODSERV  �
	//�����������������������������������������������������������	
	If GetCodIss((cAliasTMP)->F3_CODISS) 
		lGrava := .T.
	Else
		lGrava := .F.
	Endif			
	If lGrava                      
		If lQuery
			RecLock("TMP",.T.)	
			//���������������������������������������������Ŀ
			//�Grava o tempor�rio TMP quando utilizado query�
			//�����������������������������������������������
			TMP->CNPJ      := (cAliasTMP)->A2_CGC
			TMP->NOME      := (cAliasTMP)->A2_NOME
			TMP->TPLOGR    := IIF(lTPLOGR,(cAliasTMP)->A2_TPLOGR,"")			
			TMP->NOMELOG   := (cAliasTMP)->A2_END 
			TMP->NUMIMOV   := (cAliasTMP)->A2_NR_END
			TMP->COMPLEM   := (cAliasTMP)->A2_COMPLEM
			TMP->BAIRRO    := (cAliasTMP)->A2_BAIRRO
			TMP->MUNICIP   := (cAliasTMP)->A2_MUN
			TMP->ESTADO    := (cAliasTMP)->A2_EST
			TMP->CEP       := (cAliasTMP)->A2_CEP
			TMP->SERVICO   := (cAliasTMP)->F3_CODISS						
		Else
			//���������������������������������������������Ŀ
			//�Grava o tempor�rio TMP quando utilizado dbf  �
			//�����������������������������������������������
			aArea1 := GetArea()
		    If SA2->(DbSeek(xFilial("SA2")+(cAliasTMP)->F3_CLIEFOR+(cAliasTMP)->F3_LOJA)) 
		    	If SA2->A2_CPOMSP <> "1" .AND. SA2->A2_COD_MUN <> cMunicip
	    			RecLock("TMP",.T.)
			    	TMP->CNPJ      := SA2->A2_CGC
					TMP->NOME      := SA2->A2_NOME
			   		TMP->TPLOGR    := IIF(lTPLOGR,SA2->A2_TPLOGR,"")
					TMP->NOMELOG   := SA2->A2_END 
					TMP->NUMIMOV   := SA2->A2_NR_END
					TMP->COMPLEM   := SA2->A2_COMPLEM
			   		TMP->BAIRRO    := SA2->A2_BAIRRO
			   		TMP->MUNICIP   := SA2->A2_MUN
			   		TMP->ESTADO    := SA2->A2_EST
			   		TMP->CEP       := SA2->A2_CEP
			   		TMP->SERVICO   := SF3->F3_CODISS 
			   	Endif			    
		    Endif       
		   	RestArea(aArea1) 	    	
		Endif       
		MsUnLock()
	Endif					
	(cAliasTMP)->(dbSkip())
Enddo

//������������������������������������������������������Ŀ       
//�Retira os elementos de fornecedor repetidos caso tenha�
//��������������������������������������������������������
dbSelectArea("TMP") 
("TMP")->(DbGoTop())
While ("TMP")->(!Eof())
	If AScan(aCod,TMP->CNPJ) == 0
   		AAdd(aCod,TMP->CNPJ)
   	Else
   		Reclock("TMP",.F.)
		("TMP")->(dbDelete())
		MsUnlock()
   	Endif   		
	("TMP")->(dbSkip())	
Enddo

//������������������������������������������������������Ŀ
//�Fecha os alias e limpa os filtros dos alias utilizados�
//��������������������������������������������������������
If !lQuery
	RetIndex("SF3")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasTMP)
	dbCloseArea()
Endif	

Return(aTemp)                       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �StructTMP �Autor  �Camila Janu�rio       � Data � 24/09/2012���
�������������������������������������������������������������������������͹��
���Desc.     �Cria a estrutura da tabela temporaria                       ���
���          �					                         				  ���
�������������������������������������������������������������������������͹��
���Uso       �DIA - Amazonas                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function StructTMP()

Local aTemp 	:= {}
Local aCab		:= {}
Local cArqCab	:= "" 

//���������������������������������������������������������������Ŀ
//�Cria a estrutura TMP da tabela temporaria, com suas respectivas�
//�caracter�sticas de tipo, tamanho, picture                      �
//�����������������������������������������������������������������                                     
AADD(aCab,{"CNPJ"  	    ,"C",14,0})
AADD(aCab,{"NOME"  	    ,"C",40,0})
AADD(aCab,{"TPLOGR"	    ,"C",03,0})
AADD(aCab,{"NOMELOG"	,"C",40,0})      
AADD(aCab,{"NUMIMOV"	,"C",05,0})
AADD(aCab,{"COMPLEM"    ,"C",22,0})      
AADD(aCab,{"BAIRRO"	    ,"C",22,0})
AADD(aCab,{"MUNICIP"    ,"C",30,0})
AADD(aCab,{"ESTADO"  	,"C",02,0})
AADD(aCab,{"CEP"  		,"C",08,0})
AADD(aCab,{"SERVICO"	,"C",05,0})
AADD(aCab,{"OK"     	,"C",01,0})

//������������������������������������������������������������
//�Cria o arquivo de trabalho logicamente e define o indice  �
//�processamento                                             �
//������������������������������������������������������������
cArqCab	:=	CriaTrab(aCab)
dbUseArea(.T.,__LocalDriver,cArqCab,"TMP")
IndRegua("TMP",cArqCab,"CNPJ")

aTemp	:=	{{cArqCab,"TMP"}}

Return(aTemp)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao   �Fis55Del �Autor � Camila Janu�rio    � Data � 24/09/2012     ���
�������������������������������������������������������������������������͹��
���Desc.    �Apaga arquivos temporarios criados para gerar o arquivo XML. ���
�������������������������������������������������������������������������͹��
���Uso      �CPOM-SP                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fis55Del(aDelArqs)

Local aAreaDel	:= GetArea()
Local nI 		:= 0

//������������������������������������������������������Ŀ
//�Apaga o arquivo logicamente e limpa a �rea selecionada�
//��������������������������������������������������������
For nI := 1 To Len(aDelArqs)
	If File(aDelArqs[ni,1]+GetDBExtension())
		dbSelectArea(aDelArqs[ni,2])
		dbCloseArea()
		Ferase(aDelArqs[ni,1]+GetDBExtension())
		Ferase(aDelArqs[ni,1]+OrdBagExt())
	Endif	
Next

RestArea(aAreaDel)

Return  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fis55NoAc  �Autor  �Camila Janu�rio   � Data �  24/09/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     � Formata o M0_CGC / CEP                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CPOM - SP	                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fis55NoAc(cParam)

Local cChar := ""
Local cSimb := ".-_/"
Local nX    := 1
Local nY    := 1

//�����������������������������������������������������������Ā
//�Faz a busca de caracteres e simbolos como . - _ / e suprime�
//�gerando nova string sem simbolos.                          �
//�����������������������������������������������������������Ā 
For nX := 1 To Len(cParam)
	cChar:=SubStr(cParam, nX, 1)
	IF cChar<> " "
		nY := At(cChar, cSimb)
		If nY > 0
			cParam:=StrTran(cParam,cChar,SubStr("", nY % 11,1))
		Endif
	Endif	
Next nX 

Return cParam


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCodISS   �Autor  �Camila Janu�rio     � Data �  24/09/12 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se o c�digo de ISS est� contido nos permitidos pelo��
���          � parametro MV_CODSERV                                       ���
�������������������������������������������������������������������������͹��
���Uso       � CPOMSP                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetCodIss(cCod)
Local lRet      := .F. 
Local lExiste   := GetMV("MV_CODSERV",.T.)

If lExiste
	If Alltrim(cCod) $ GetMV("MV_CODSERV")
		lRet :=.T.
	Endif
Endif

Return lRet



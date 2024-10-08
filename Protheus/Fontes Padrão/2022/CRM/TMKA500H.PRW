#INCLUDE "PROTHEUS.CH"
#DEFINE BRANCH_FIELD_NAME "_FILIAL"		//STRING Q IDENTIFICA O CAMPO FILIAL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TSTable         �Autor�Michel Mosca    � Data �  11/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Descreve uma tabela do sistema.                            ��� 
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/        
Class TSTable

Data alias 			//Alias da tabela     
Data Fields			//Campos da tabela
Data pkFields		//Chave primaria da tabela
Data iIdx			//Indice da chave primaria da tabela
Data BranchField    //Armazena o campo filial da tabela
Data Rows			//Registros da tabela 
Data oPersist		//Classe de acesso ao banco de dados

Method new() Constructor
Method addRow()
Method load(cAlias,cId,lVirtual)
Method X3ValType()
Method GetBranch()
Method GetNewRow()
Method clearRecordset()
Method getValue(cField, nRow, xValue)  
Method createPersist()  
Method free()

End Class


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Michel W. Mosca  � Data �  11/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class TSTable        

Self:alias		 := PAD("", 10, " ")
Self:Rows		 := {}  
Self:Fields		 := {}    
Self:pkFields	 := {}
Self:iIdx		 := 1
Self:BranchField := TSField():new() 
Self:oPersist    := Self:createPersist() 
Return Self                      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �addRow    �Autor  �Michel W. Mosca     � Data �  11/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Adiciona uma nova linha de tabela.                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method addRow(Row) Class TSTable  
Default Row := TSRow():new()   

aAdd(Self:Rows, Row)

Return .T.
                       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOAD      �Autor  �Michel W. Mosca     � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carregar os campos da tabela.                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(cAlias,cId,lVirtual) Class TSTable
Local lRet 		:= .F. 			//Retorno da funcao
Local oField					//Objeto do tipo campo
Local cAux						//String auxiliar
Local iAux 						//Inteiro auxiliar
Local nCount					//Contador utilizado em loop.
Local aArea		:=GetArea() 	//Armazena a area
Local cTrbQry	:= ""
Local cQuery	:= "" 
Local nAt		:= 0
Local oTmpField	:= Nil

Default cId := ""                                   
Default lVirtual := .F.	//.T. - Carrega os campos Reais e Virtuais / .F. - Somente os campos Reais

//Reinicia os parametros de campos
Self:Rows		 := {}  
Self:Fields		 := {}    
Self:pkFields	 := {}
Self:BranchField := TSField():new()

//Carrega a chave primaria da tabela
DbSelectArea("SIX")
DbSetOrder(1) //INDICE+ORDEM  
If DbSeek(cAlias + AllTrim(Str(Self:iIdx)))
	cAux := CHAVE    
	cAux += "+"
	While .T.
		iAux := At("+", cAux)
		If iAux <= 0
			Exit		
		EndIf		       
		oField := TSField():new()
		oField:name 	:= AllTrim(SubStr(cAux, 0, iAux-1))  
		aAdd(Self:pkFields, oField)	
		cAux :=	SubStr(cAux, iAux+1, len(cAux))
	End		
EndIf

//Carrega os campos da tabela do dicionario de dados
DbSelectArea("SX3")
DbSetOrder(1)
If DbSeek(cAlias)
	While ( !Eof() .AND. (SX3->X3_ARQUIVO == cAlias) )
	
		If lVirtual .OR. ( SX3->X3_CONTEXT <> "V" )
			oField := TSField():new()
			oField:name 	   		:= SX3->X3_CAMPO  
			oField:titlePor			:= SX3->X3_TITULO
			oField:titleSpa			:= SX3->X3_TITSPA
			oField:titleEng			:= SX3->X3_TITENG
			oField:value   			:= Self:X3ValType(SX3->X3_TIPO)
			oField:value:size 		:= SX3->X3_TAMANHO
			oField:value:decimal 	:= SX3->X3_DECIMAL			
			oField:level			:= SX3->X3_CAMPO		
			oField:use				:= X3Uso(SX3->X3_USADO)
			oField:required			:= X3Obrigat(SX3->X3_CAMPO)
			oField:defValue			:= SX3->X3_RELACAO
			oField:context			:= SX3->X3_CONTEXT
			aAdd(Self:Fields, oField)	
			lRet := .T.
		EndIf   
		If At(BRANCH_FIELD_NAME, SX3->X3_CAMPO) > 0        
			oField := TSField():new()
			oField:name   			:= SX3->X3_CAMPO 
			oField:titlePor			:= SX3->X3_TITULO
			oField:titleSpa			:= SX3->X3_TITSPA
			oField:titleEng			:= SX3->X3_TITENG
			oField:value  			:= Self:X3ValType(SX3->X3_TIPO)	
			oField:value:size 		:= SX3->X3_TAMANHO
			oField:value:decimal	:= SX3->X3_DECIMAL			
			oField:level			:= SX3->X3_CAMPO
			oField:use				:= X3Uso(SX3->X3_USADO)  
			oField:required			:= X3Obrigat(SX3->X3_CAMPO)
			oField:defValue			:= SX3->X3_RELACAO
			oField:context			:= SX3->X3_CONTEXT
			Self:BranchField := oField
		EndIf     
		
		#IFNDEF TOP
			//Carrega detalhes especificos do campo
			Self:oPersist:customizeField(oField,SX3->X3_CAMPO,cId)
		#ENDIF
		
		//Verifica o tipo de dado na chave primaria
		For nCount := 1 To Len(Self:pkFields)
			If AllTrim(Self:pkFields[nCount]:name) == AllTrim(SX3->X3_CAMPO)
				Self:pkFields[nCount]:value			:= Self:X3ValType(SX3->X3_TIPO)	 
				Self:pkFields[nCount]:value:size 	:= SX3->X3_TAMANHO
				Self:pkFields[nCount]:value:decimal	:= SX3->X3_DECIMAL			
				Self:pkFields[nCount]:level			:= SX3->X3_CAMPO				
			EndIf
		Next nCount
		
		DbSelectArea("SX3")
		DbSkip()
	End                
EndIf

#IFDEF TOP
	If !Empty(cId)
		cQuery := "SELECT	ADQ.ADQ_TITSPA,"
		cQuery += "		ADQ.ADQ_TITENG,"
       	cQuery += "		ADQ.ADQ_TITPOR,"
       	cQuery += "		ADQ.ADQ_INIPAD,"
		cQuery += "		ADQ.ADQ_USADO,"
		cQuery += "		ADQ.ADQ_OBRIGA," 
		cQuery += "		ADQ.ADQ_CAMPO" 		
		cQuery += "	FROM   " + RetSQLName("ADQ") + " ADQ"
		cQuery += "	WHERE  ADQ.ADQ_FILIAL = '" + xFilial("ADQ") + "' AND ADQ.ADQ_ATEND = '" + cId + "' AND ADQ.D_E_L_E_T_ = ''"
		
		cQuery := ChangeQuery( cQuery )
		
		cTrbQry := "ADQTEMP"
		DbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cTrbQry, .F., .F. )
		
		If (cTrbQry)->(!EOF())
			While (cTrbQry)->(!EOF())
				oTmpField := Nil
				If (nAt := aScan( Self:Fields, { |x| AllTrim(x:name) == AllTrim((cTrbQry)->ADQ_CAMPO) } )) > 0
					oTmpField := Self:Fields[nAt]
				ElseIf At(AllTrim(BRANCH_FIELD_NAME), AllTrim((cTrbQry)->ADQ_CAMPO)) > 0 
					oTmpField := Self:BranchField
				EndIf
				
				If oTmpField != Nil
					//Titulo
					oTmpField:titleSpa := AllTrim((cTrbQry)->ADQ_TITSPA)
					oTmpField:titleEng := AllTrim((cTrbQry)->ADQ_TITENG)
					oTmpField:titlePor := AllTrim((cTrbQry)->ADQ_TITPOR)
					
					//Inicializador
					If !Empty((cTrbQry)->ADQ_INIPAD)
						oTmpField:defValue := AllTrim((cTrbQry)->ADQ_INIPAD)
					EndIf
			
					//Propriedades
					oTmpField:use		:= (cTrbQry)->ADQ_USADO == "T"		//Uso
					oTmpField:required 	:= (cTrbQry)->ADQ_OBRIGA == "T"	//Obrigatorio
					oTmpField:Customized	:= .T.
				EndIf
				(cTrbQry)->(DbSkip())					
			End
		EndIf 
		
		(cTrbQry)->(DbCloseArea())
	EndIf
#ENDIF

If lRet
	Self:alias := cAlias
EndIf
RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �X3ValType �Autor  �Michel W. Mosca     � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorno o tipo de objeto de dado.                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method X3ValType(cX3Tipo) Class TSTable
Local oData

If cX3Tipo == "C" //CARACTER
	oData := TSCHAR():NEW() 
ElseIf cX3Tipo == "N" //NUMERICO
	oData := TSNUMBER():NEW()
ElseIf cX3Tipo == "L" //LOGICO
	oData := TSBOOLEAN():NEW()
ElseIf cX3Tipo == "D" //DATA
	oData := TSDATE():NEW()
ElseIf cX3Tipo == "M" //MEMO
	oData := TSMEMO():NEW()
Else
	oData := TSCHAR():NEW()
EndIf
Return oData      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetBranch �Autor  �Michel W. Mosca     � Data �  19/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorno o campo filial da tabela.                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/     
Method GetBranch()	Class TSTable            
Local oBranch	//Campo filial                                             

If Self:BranchField <> NIL
	oBranch := Self:BranchField  
	oBranch:value := "'" + xFilial(Self:alias) + "'"
EndIf
Return oBranch


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetNewRow �Autor  �Michel W. Mosca     � Data �  22/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorno um objeto Row preenchido com os campos da tabela.   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/     
Method GetNewRow() Class TSTable
Local oRow := TSRow():new() 	//Objeto linha da tabela  
Local nCount	:= 0 			//Contador
           
//Adiciona a chave primaria
For nCount := 1 To Len(Self:pkFields)
	oRow:addPKField(Self:pkFields[nCount]:clone())	
Next nCount

//Adiciona os dados da tabela
For nCount := 1 To Len(Self:Fields)
	oRow:addField(Self:Fields[nCount]:clone())	
Next nCount

Return oRow

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �clearRecordset�Autor�Michel W. Mosca   � Data �  24/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Limpa os registros da tabela do objeto.                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/     
Method clearRecordset() Class TSTable
Local lRet := .F.

Self:Rows := {}	 
lRet := .T.
Return lRet                          
       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �getValue      �Autor�Michel W. Mosca   � Data �  21/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o valor do campo armazenado na tabela.              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/     
Method getValue(cFieldName, nRow, xValue) Class TSTable                      
Local nCount:= 0	//Contador                          
Local lRet 	:= .F.	//Retorno da funcao
Local oRow			//Objeto Row

If nRow <= Len(Self:Rows)
	oRow := Self:Rows[nRow]
	For nCount := 1 To Len(oRow:fields)
		If AllTrim(cFieldName) == AllTrim(oRow:fields[nCount]:name)
			xValue := oRow:fields[nCount]:value:value
			lRet := .T.
			Exit
		EndIf	
	Next nCount	
EndIf                               

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �createPersist �Autor  �Vendas CRM      � Data �  30/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a classe de acesso ao banco de dados.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method createPersist() Class TsTable 
Local obj

#IFDEF TOP
	obj := TsTableTop():New()
#ELSE
	obj := TsTableCodebase():New()
#ENDIF     

Return obj   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �free       	�Autor  �Vendas Clientes � Data �  30/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Libera a mem�ria dos objetos utilizados.    			 	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method free() Class TsTable
TMKFree( Self:Rows )
TMKFree( Self:Fields )
TMKFree( Self:pkFields )
TMKFree( Self:BranchField )
TMKFree( Self:oPersist )
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA500      �Autor  �Michel W. Mosca � Data �  09/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
FUNCTION _TMKA500H()
RETURN NIL

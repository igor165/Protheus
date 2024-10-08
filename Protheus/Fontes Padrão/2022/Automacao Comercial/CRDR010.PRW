#INCLUDE "CRDR010.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDR010   � Autor � Marcos Roberto Andrade� Data � 14.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio de Questionario.                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
���ANALISTA  � DATA   � BOPS �MOTIVO DA ALTERACAO                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Crdr010()
Local oReport				// Objeto para geracao do relatorio
Local aArea := GetArea()	// Salva a area

If FindFunction("TRepInUse") .OR. TRepInUse()

	Pergunte("CRD010",.F.)
	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������
	oReport := CRD010RptDef()
	oReport:PrintDialog()
EndIf

//���������������Ŀ
//�Restaura a area�
//�����������������
RestArea( aArea )
Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �CRD010RptDeF�Autor  �Marcos R. Andrade   � Data �  14/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela  ���
���          �latorio                                                       ���
���������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function CRD010RptDef()
Local oReport											// Objeto do relatorio
Local oSection1											// Objeto da secao 1	 
Local oSection2											// Objeto da secao 2	
Local oSection3											// Objeto da secao 3	
Local cAlias1	:= "MA4"								// Pega o proximo Alias Disponivel

#IFDEF TOP
	cAlias1		:= GetNextAlias()						// Pega o proximo Alias Disponivel
#ENDIF	

DEFINE REPORT oReport 	NAME "CRDR010"		; 
						TITLE STR0001		;			//### "Relacao de Questionarios" 
	 					PARAMETER "CRD010"	;			//Arquivo de parametros			 
	 					ACTION {|oReport| CRD010PrtRpt(oReport, cAlias1)} DESCRIPTION STR0002 //##"Este programa ir� emitir uma listagem dos question�rios com suas respectivas respostas"
	//������������������������������������������Ŀ
	//�Definido a sessao PAI                     �
	//��������������������������������������������
	DEFINE SECTION oSection1 OF oReport TITLE STR0003 TABLES "MA4"    // Grupo de Perguntas
		
		DEFINE CELL NAME "MA4_QUEST" 	OF oSection1 ALIAS "MA4"
		DEFINE CELL NAME "MA4_DESCRI" 	OF oSection1 ALIAS "MA4"
		DEFINE CELL NAME "MA4_DATA"		OF oSection1 ALIAS "MA4" 

	//�����������������������������Ŀ
	//�Define a secao2 do relatorio �
	//�������������������������������
	DEFINE SECTION oSection2 OF oSection1 TITLE STR0004 TABLES "MA5" // "Pergunta S�cio-Econ�mico-Cultura�"
		DEFINE CELL NAME "MA5_PERG" 	OF oSection2 ALIAS "MA5"
		DEFINE CELL NAME "MA5_DESCR" 	OF oSection2 ALIAS "MA5" 

	DEFINE SECTION oSection3 OF oSection2 TITLE STR0005 TABLES "MAJ" // "Resposta Padr�o"
		DEFINE CELL NAME "MAJ_RESP" 	OF oSection3 ALIAS "MAJ"
		DEFINE CELL NAME "MAJ_DESCR" 	OF oSection3 ALIAS "MAJ"
		DEFINE CELL NAME "MAJ_PONTO" 	OF oSection3 ALIAS "MAJ"


Return oReport 


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �CRD010PrtRpt�Autor  �Marcos R. Andrade   � Data �  14/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio                            ���
���������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function CRD010PrtRpt(oReport, cAlias1)
Local oSection1 := oReport:Section(1)					//Define a secao 1 do relatorio        
Local oSection2 := oSection1:Section(1)					//Define que a secao 2 sera filha da secao 1 
Local oSection3 := oSection2:Section(1)					//Define que a secao 3 sera filha da secao 2
Local cQuery	:= "%%" 								//Query 1 
Local cFiltro	:= "" 									//Filtro DBF

DbSelectArea("MA4")
DbSetOrder(1)

#IFDEF TOP
	//����������������Ŀ
	//�Query da secao 1�
	//������������������
	MakeSqlExpr("CRD010")
         
	If Empty(MV_PAR01) 
	    cQuery	:= "% MA4_QUEST >='' "
	Else
	    cQuery	:= "% MA4_QUEST >='" + AllTrim(MV_PAR01) +"' "
	Endif
	
	If !Empty(MV_PAR02)
		cQuery	+= " AND MA4_QUEST <='" + AllTrim(MV_PAR02) +"' "
	Endif 
	
	cQuery	+= "%"

	BEGIN REPORT QUERY oSection1
	
		BeginSql alias cAlias1
		
			SELECT 	MA4_QUEST, 	MA4_DESCRI,	MA4_DATA,	MA5_PERG, 	
					MA5_QUEST,	MA5_DESCR,	MAJ_QUEST,	MAJ_RESP,	
					MAJ_PERG,	MAJ_DESCR,	MAJ_PONTO
			
			FROM %table:MA4% MA4, %table:MA5% MA5, %table:MAJ% MAJ
			
			WHERE 	MA4_FILIAL= %xfilial:MA4%	AND
					%exp:cQuery% 			    AND
					MA4.%notDel%				AND
					MA5_FILIAL= %xfilial:MA5%	AND
					MA5_QUEST = MA4_QUEST 		AND
					MA5.%notDel%				AND
					MAJ_FILIAL= %xfilial:MAJ%	AND
					MAJ_QUEST = MA5_QUEST 		AND
					MAJ_PERG  = MA5_PERG		AND
					MAJ.%notDel%                   
			ORDER BY %ORDER:MA4%
		EndSql
	END REPORT QUERY oSection1     
	                                                      
	//�������������������������������������������������������������������������������������������Ŀ
	//�Baseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressao�
	//���������������������������������������������������������������������������������������������
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( { | cParam | (cAlias1)->MA5_QUEST == cParam},{|| (cAlias1)->MA4_QUEST } )
	
	//�������������������������������������������������������������������������������������������Ŀ
	//�Baseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressao�
	//���������������������������������������������������������������������������������������������
	oSection3:SetParentQuery()
	oSection3:SetParentFilter( { | cParam | (cAlias1)->MAJ_QUEST+(cAlias1)->MAJ_PERG == cParam },{|| (cAlias1)->MA5_QUEST+(cAlias1)->MA5_PERG } )
	
	
	oSection1:SetHeaderSection(.T.)		//Define que o header vai ser apresentado

#ELSE
	//���������������������������������������������������������������������������������Ŀ
	//�Utilizar a funcao MakeAdvlExpr, somente quando for utilizar o range de parametros�
	//�����������������������������������������������������������������������������������
	MakeAdvplExpr("crdr010")
	
	DbSelectArea("MA4")
	DbSetOrder(1)

	cFiltro	:= "MA4_FILIAL ='"+xFilial("MA4")+"'"


	If !Empty(MV_PAR01) 
	    cFiltro	+= " .AND. MA4_QUEST >='" + AllTrim(MV_PAR01) +"' "
	Endif
	
	If !Empty(MV_PAR02)
		cFiltro	+= " .AND. MA4_QUEST <='" + AllTrim(MV_PAR02) +"' "
	Endif 

	oSection1:SetFilter( cFiltro )	        
	
	//����������������������������������������������������������������������������������Ŀ
	//� Executa a secao2, com o mesmo filtro da secao1.                                  �
	//������������������������������������������������������������������������������������
	oSection2:SetRelation({|| xFilial("MA5")+MA4->MA4_QUEST },"MA5",2,.T.)
	oSection2:SetParentFilter({|cParam| MA5_QUEST == cParam},{|| MA4->MA4_QUEST })
	
	//����������������������������������������������������������������������������������Ŀ
	//� Executa a secao2, com o mesmo filtro da secao1.                                  �
	//������������������������������������������������������������������������������������		
	oSection3:SetRelation({|| xFilial("MAJ")+MA5->MA5_QUEST+MA5->MA5_PERG},"MAJ",1,.T.)
	oSection3:SetParentFilter({|cParam| MAJ_QUEST+MAJ_PERG == cParam},{|| MA5->MA5_QUEST+MA5->MA5_PERG })
	
	oSection1:SetHeaderSection(.T.)		
	
#ENDIF	                                                                                                                
oSection1:SetLineBreak()
oSection1:Print()

Return
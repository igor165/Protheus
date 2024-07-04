#INCLUDE "CRDR050.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDR050   � Autor � Marcos Roberto Andrade� Data � 29.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio de Atendimento por Analista                       ���
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
Function CRDR050()
Local oReport				// Objeto para geracao do relatorio
Local aArea := GetArea()	// Salva a area

If FindFunction("TRepInUse") .OR. TRepInUse()

	Pergunte("CRD050",.F.)
	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������
	oReport := CRD050RptDef1()
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
���Programa  �CRD050RptDeF�Autor  �Marcos R. Andrade   � Data �  29/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela  ���
���          �latorio                                                       ���
���������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function CRD050RptDef()
Local oReport									// Objeto do relatorio
Local oSection1									// Objeto da secao 1	          
Local oSection2									// Objeto da secao 2	          
Local oSection3									// Objeto da secao 3	          
Local cAlias1	:= "MAH"						// Pega o proximo Alias Disponivel

#IFDEF TOP
	cAlias1		:= GetNextAlias()				// Pega o proximo Alias Disponivel
#ENDIF	

DEFINE REPORT oReport 	NAME "CRDR050"		; 
						TITLE STR0001		;			//"Relat�rio de An�lise de Cr�dito"
	 					PARAMETER "CRD050"	;			//Arquivo de parametros			 
	 					ACTION {|oReport| CRD050PrtRpt(oReport, cAlias1)} DESCRIPTION STR0002 //"Este programa ir� emitir o relat�rio de an�lise de cr�dito"
	 					
	//������������������������������������������Ŀ
	//�Definido a sessao PAI                     �
	//��������������������������������������������
	DEFINE SECTION oSection1 OF oReport TITLE STR0004 TABLES "MAH" 
		
		DEFINE CELL NAME "MAH_USRCRD" 	OF oSection1 ALIAS "MAH"
		DEFINE CELL NAME "cNomeUsr"		OF oSection1 ALIAS "" 	SIZE 30 BLOCK {|| CRDX050Usr( (cAlias1)->MAH_USRCRD ) } 
		

	DEFINE SECTION oSection2 OF oSection1 TITLE STR0005 TABLES "MAH"  
		DEFINE CELL NAME "MAH_EMISSA"	OF oSection2 ALIAS "MAH"                                       
		                                                                                                        
	DEFINE SECTION oSection3 OF oSection2 TITLE STR0006 TABLES "MAH", "SL1"  //Total de Or�amentos do dia
			
		DEFINE CELL NAME "MAH_CONTRA"	OF oSection3 ALIAS "MAH"    
		DEFINE CELL NAME "MAH_STATUS"	OF oSection3 ALIAS "MAH"   
		
		DEFINE CELL NAME "L1_CLIENTE"	OF oSection3 ALIAS "SL1" 
		DEFINE CELL NAME "L1_LOJA"		OF oSection3 ALIAS "SL1" 
		DEFINE CELL NAME "L1_NUM" 		OF oSection3 ALIAS "SL1"   
		DEFINE CELL NAME "MAH_VLRFIN"	OF oSection3 ALIAS "MAH"  
		                                                                                               
		//����������������������������������������������Ŀ
		//� Definicao das funcoes de totalizacao e media �
		//������������������������������������������������
		DEFINE FUNCTION FROM oSection3:Cell("MAH_VLRFIN") FUNCTION SUM TITLE STR0005 NO END REPORT  
	   	DEFINE FUNCTION FROM oSection3:Cell("MAH_VLRFIN") Of oSection1  FUNCTION SUM TITLE STR0004  

Return oReport 


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �CRD050PrtRpt�Autor  �Marcos R. Andrade   � Data �  29/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio                            ���
���������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function CRD050PrtRpt(oReport, cAlias1)
Local oSection1 	:= oReport:Section(1)				//Define a secao 1 do relatorio
Local oSection2 	:= oSection1:Section(1)				// Define que a secao 2 sera filha da secao 1
Local oSection3 	:= oSection1:Section(1):Section(1)	// Define que a secao 2 sera filha da secao 1
Local cWhere1		:= "%%" 							//Expressao 1 
Local cFiltro		:= "" 								//Filtro DBF
    
DbSelectArea("MAH")
DbSetOrder(5)

#IFDEF TOP
	//����������������Ŀ
	//�Query da secao 1�
	//������������������
		
	MakeSqlExpr("CRD050")
         
    cWhere1	:= "%MAH_USRCRD >='" + MV_PAR01 +"' "

	cWhere1	+= " AND MAH_USRCRD <='" + MV_PAR02 +"' "
	
	cWhere1	+= " AND MAH_EMISSA >='" + DTOS(MV_PAR03) +"' "
	
	cWhere1	+= " AND MAH_EMISSA <='" + DTOS(MV_PAR04) +"' "
		
	cWhere1	+= "%"

	BEGIN REPORT QUERY oSection1
	
		BeginSql alias cAlias1

		SELECT 	MAH_USRCRD, MAH_EMISSA, MAH_CONTRA, MAH_VLRFIN, 
				L1_CLIENTE, L1_LOJA,    L1_NUM,     L1_NUM

        FROM %table:MAH% MAH LEFT JOIN %table:SL1% SL1 ON	L1_CONTRA = MAH_CONTRA
        
		WHERE	MAH_FILIAL = %xfilial:MAH%	AND
				%exp:cWhere1% 			    AND				
				MAH.%notDel%				AND
				L1_FILIAL = %xfilial:SL1%	AND 
				SL1.%notDel%				
								 	                                
			ORDER BY %ORDER:MAH%
		EndSql
	END REPORT QUERY oSection1     
	                                  
	//����������������������������������Ŀ
	//� Posiciona nas tabelas auxiliares �
	//������������������������������������    
	TRPosition():New(oSection3,"SL1",10,{|| xFilial("SL1")+(cAlias1)->MAH_CONTRA }) 
		
	//�������������������������������������������������������
	//� Define que a secao 2 usara a mesma query da secao 1 �
	//�������������������������������������������������������
	oSection2:SetParentQuery()
	oSection2:SetParentFilter({|cParam| (cAlias1)->MAH_USRCRD == cParam},	{|| (cAlias1)->MAH_USRCRD }) 
								
	oSection3:SetParentQuery()
	oSection3:SetParentFilter({|cParam| DTOS((cAlias1)->MAH_EMISSA) == cParam}, {|| DTOS((cAlias1)->MAH_EMISSA) })								

#ELSE
	//���������������������������������������������������������������������������������Ŀ
	//�Utilizar a funcao MakeAdvlExpr, somente quando for utilizar o range de parametros�
	//�����������������������������������������������������������������������������������
	MakeAdvplExpr("CRD050")
	
	DbSelectArea("MAH")
	DbSetOrder(5)

	cFiltro	:= "MAH_FILIAL ='"+ xFilial("MAH")+ "'"
	    
	cFiltro	+= " .AND. MAH_USRCRD >='" + MV_PAR01 +"'"

	cFiltro	+= " .AND. MAH_USRCRD <='" + MV_PAR02 +"'"

	cFiltro	+= " .AND. DTOS(MAH_EMISSA) >='" + DTOS(MV_PAR03) +"'"
	
	cFiltro	+= " .AND. DTOS(MAH_EMISSA) <='" + DTOS(MV_PAR04) +"'"


	oSection1:SetFilter( cFiltro )	
	
	//����������������������������������Ŀ
	//� Posiciona nas tabelas auxiliares �
	//������������������������������������    
   	TRPosition():New(oSection3,"SL1",10,{|| xFilial("SL1")+MAH->MAH_CONTRA }) 
		                                                                               
	//����������������������������������������������������������������������������������Ŀ
	//� Executa a secao2, com o mesmo filtro da secao1.                                  �
	//������������������������������������������������������������������������������������
	oSection2:SetRelation({|| xFilial("MAH")+MAH->MAH_USRCRD },"MAH",5,.T.)
	oSection2:SetParentFilter({|cParam| MAH->MAH_USRCRD == cParam},	{|| MAH->MAH_USRCRD }) 
	
	//����������������������������������������������������������������������������������Ŀ
	//� Executa a secao3, com o mesmo filtro da secao1.                                  �
	//������������������������������������������������������������������������������������
//	oSection3:SetRelation({|| xFilial("MAH")+MAH_USRCRD },"MAH",5,.T.)
//	oSection3:SetParentFilter({|cParam| DTOS(MAH_EMISSA) == DTOS(cParam) },{|| MAH_EMISSA }) 
	
	
	oSection1:SetHeaderSection(.T.)		
	
#ENDIF	

oSection1:SetTotalText(STR0004)
oSection3:SetTotalText(STR0005)
oSection3:SetTotalInLine(.F.) 
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderSection(.T.)		//Define que o header vai ser apresentado

oSection1:SetLineBreak()
oSection1:Print()

Return                                   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CRDX050Usr� Autor � Marcos R. Andrade     � Data �29.08.06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o nome do usuario.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do usuario a ser verificado.                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � RetC1 = Nome do usuario.                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico.                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CRDX050Usr(cCodUser)
Local aArea		:= GetArea() 	//Salva a area atual
Local cName    	:= ""			//Nome do usuario

PswOrder(1)
If	!Empty(cCodUser) .And. PswSeek(cCodUser)
	cName := PswRet(1)[1][2]
Else
	cName := SPACE(15)
EndIf

RestArea(aArea)

Return cName


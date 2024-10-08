#INCLUDE "REPORT.CH"   
#INCLUDE "CRDR300.CH"

Static cAlias1	:= ""	// Pega o proximo Alias Disponivel
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �CRDR300   � Autor � Leandro Nogueira	    � Data � 03/01/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio de saldo fidelidade por administradora		 	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �ExpO1:=CRDR300()			 								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 		 													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �NIL														  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �SIGACRD												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function CRDR300()
Local oReport	

cAlias1	:= GetNextAlias()	// Pega o proximo Alias Disponivel

//������������������������������������������Ŀ
//�Rotina disponivel a partir do Release 11.5�
//��������������������������������������������
If !GetRpoRelease("R5")   
	Return NIL
Endif

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("CRDR300",.T.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01          // Administradora De ?   	                 �
//� MV_PAR02          // Administradora At� ?                    �
//����������������������������������������������������������������

//����������������������Ŀ
//�Interface de impressao�
//������������������������
oReport:=CRDR300Def() 
oReport:PrintDialog() 

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �CRDR300Def� Autor � Leandro Nogueira	    � Data � 03/01/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Definicoes do relatorio de saldo fidelidade de adm. fin.	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �ExpL1:=CRDR300Def()				 						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 		 													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �NIL					   									  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �SIGACRD												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/                 
Static Function CRDR300Def()
Local oReport						//Objeto relatorio TReport (Release 4)
Local oSection1 					//Objeto secao 1 do relatorio (Lista, campos das tabelas SB1) 
Local cTitulo   := ""				// Titulo do relatorio 

oReport := TReport():New("CRDR300",STR0001,"CRDR300",{|oReport| CRDR300RPT( oReport )}, STR0002 )//"Relatorio de saldo fidelidade por administradora financeira	"#"Saldo Fidelidade"


//�����������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal �
//�������������������������������������������������������������������
oSection1 := TRSection():New( oReport,STR0002,{ "SAE","MBO","MBP" } )//"Saldo Fidelidade"
                                
//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//����������������������������������������������� 

#IFDEF TOP
	TRCell():New(oSection1,"AE_DESC"	,"SAE",,,50,,{||(cAlias1)->AE_COD + " - " + (cAlias1)->AE_DESC},"LEFT")	  
	TRCell():New(oSection1,"SALDO"		,"MBP",STR0003,PesqPict("MBP","MBP_SALDO"),20,,,"LEFT")	//"Saldo"
#ELSE
	TRCell():New(oSection1,"AE_DESC"	,"SAE",,,50,,{||("SAE")->AE_COD + " - " + ("SAE")->AE_DESC},"LEFT")	  
	TRCell():New(oSection1,"SALDO"		,"MBP",STR0003,PesqPict("MBP","MBP_SALDO"),20,,{||	CaSaldoAdm (("SAE")->AE_COD)},"LEFT") //"Saldo"
#ENDIF

TRFunction():New(oSection1:Cell("SALDO"),NIL,"SUM",,STR0004,,,.F.)//"Saldo Total"
                   
Return(oReport) 
Return Nil    


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CRDR300RPT   � Autor �Leandro Nogueira    � Data �16/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CRDR300RPT (oReport)
Local oSection1 := oReport:Section(1) 		//Objeto secao 1 do relatorio (Lista, campos das tabelas SB1)
Local cFiltro	:= ""   					//String contendo o filtro de busca a ser utilizado com DBF   

MakeSqlExpr("CRDR300")      



    
#IFDEF TOP 

	// ADMINISTRADORA FINANCEIRA
	If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
		cFiltro += 	" AND AE_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " 
	Endif
		
	
	cFiltro := "%"+cFiltro+"%"
	
	//��������������������Ŀ
	//�Inicializa a secao 1�
	//����������������������
	oSection1:BeginQuery()
	
		BeginSQL alias cAlias1                          	
			SELECT 
				AE_COD,
				AE_DESC,
				SUM(MBP_SALDO) AS SALDO
			FROM 
				%table:SAE% SAE
				LEFT JOIN %table:MBO% MBO ON MBO.MBO_ADMFIN = SAE.AE_COD AND MBO.%notDel%
				LEFT JOIN %table:MBP% MBP ON MBP.MBP_NUMCAR = MBO.MBO_CODBAR AND MBP.%notDel%
			WHERE SAE.%notDel% %Exp:cFiltro%
			GROUP BY 
				AE_COD,
				AE_DESC 
		  
		EndSql   	
	
	oSection1:EndQuery() 

#ELSE

	// FILIAL
	If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
		cFiltro += " AE_COD >= '" +MV_PAR01 + "' .AND. AE_COD  <= '" + MV_PAR02 + "'"           
	Else
		Return NIL
	Endif
	
	oSection1:SetFilter( cFiltro )	     
	
	DbSelectArea("SAE")
	DbSetOrder(1)   
		
	oSection1:SetLineCondition( {|| !SAE->(EOF()) } ) 				


#ENDIF		

//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection1:Print()    

Return NIL  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �CaSaldoAdm� Autor � Leandro Nogueira	    � Data � 04/01/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula saldo fidelidade de administradora financeira		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �CaSaldoAdm(cExp1)			 			 					  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cExp1 - Codigo da administradora 							  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �NIL					   									  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �SIGACRD												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/  
Function CaSaldoAdm (cAdmin)

Local nSaldo := 0 //Saldo inicial da administradora

DbSelectArea("MBO")
DbSetOrder(2)

If DbSeek(xFilial("MBO")+cAdmin)
	While !MBO->(Eof()) .AND. MBO->MBO_ADMFIN == cAdmin
		DbSelectArea("MBP")
		DbSetOrder(1)   		                        
		If DbSeek(xFilial("MBP")+MBO->MBO_CODBAR)
			While !MBP->(Eof()) .AND. MBP->MBP_NUMCAR == MBO->MBO_CODBAR
				nSaldo += MBP->MBP_SALDO					 
				MBP->(DbSkip())	
			End	
		EndIf
		MBO->(DbSkip())
	End

EndIf

Return nSaldo


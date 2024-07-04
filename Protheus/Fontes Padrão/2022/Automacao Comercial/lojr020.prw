#INCLUDE "PROTHEUS.CH"    
#INCLUDE "LOJR020.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJR020   �Autor  �Microsiga           � Data �  11/12/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Relat�rio de Recarga de Celular e Correspondente Bancario  ���
���          � TEF Dire��o                                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
Function LojR020()
Local oReport	:= Nil         //Objeto TReport
Local cPerg 	:= "LOJR020"   //Pergunta do Relat�rio

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//� CriaSx1 - Cria o Cadastro de Perguntas						 �
//� Habilita Pergunte antes dos parametros e impressao			 �
//����������������������������������������������������������������
Pergunte(cPerg,.T.)  

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01          // Filial De ?                             �
//� MV_PAR02          // Filial At� ?                            �
//� MV_PAR03          // Data de?					             �
//� MV_PAR04          // Data at�?                 				 �
//� MV_PAR05          // Tipo Operacao TEF?                      �  
//� MV_PAR06          // Formas de Pagto?                        �
//����������������������������������������������������������������
	
//����������������������Ŀ
//�Interface de impressao�
//������������������������
oReport := LjR020Rpt(cPerg)     //Funcao para impressao do relatorio onde se define Celulas e Funcoes do TReport	       
oReport:PrintDialog()           //Exibi��o da Janel TReport
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LjR020Rpt �Autor  �Microsiga           � Data �  11/12/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Relat�rio de Recarga de Celular e Correspondente Bancario  ���
���          � TEF Dire��o                                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/          
Static Function LjR020Rpt(cPerg)
Local oReport	:= NIL				// Objeto relatorio TReport (Release 4)
Local oSection1	:= NIL				// Dados da Sugestao da Lista

Local cTitulo   := IIF(MV_PAR05 == 1,STR0001, IIF(MV_PAR05 == 2,STR0002,STR0003)) // "Recarga de Celular"#"Correspondente Banc�rio" #"Rec Celular e Corres Bancario" 
Local cAlias1 	:= GetNextAlias()	// Alias para a Impress�o do Primeiro Relat�rio
Local aFormas   := {}				//Array com as formas de pagamento
Local nTamFil	:= FWGETTAMFILIAL + 30  //Tamanho do campo Filial			
Local aTamE1Valor := SE1->(TamSx3("E1_VALOR"))    //Tamanho do Campo E1_VALOR
Local aFormDgt	:= StrTokArr(AllTrim(MV_PAR06), "/")    //Array das formas de Pagamento
Local nI	:= 0		//Tamanho das formas de pagamento    
Local cDescCol	:= "" //Descricao da Coluna    
Local nMaxForm  := IIF( Len(aFormDgt) > 5, 5, Len(aFormDgt))  //Tamanho das colunas formas de pagamento
Local cPicE1_Val := PesqPict("SE1", "E1_VALOR")	   	// Picture usada para a edicao dos valores do campo E1_VALOR


For nI := 1 to Len(aFormDgt) 
	cDescCol := "TMP_FPG" + StrZero(nI,2)
	aAdd(aFormas, {cDescCol,aFormDgt[nI], 0 ,  0})
Next nI


oReport:=TReport():New("LOJR020",cTitulo,"",{|oReport| LJR020Imp(	oReport,cPerg,cAlias1, aFormas)}) 
oReport:SetLandScape()			// Escolhe o padrao de Impressao como Retrato


//���������������������������������������������������������������e
//�Secao 1 - Pai - Cabecalho da Sugestao da lista de presentes   �
//�Define a Secao que ira Imprimir o Cabecalho da Lista          �
//����������������������������������������������������������������
oSection1:=TRSection():New( oReport,cTitulo,{cAlias1} )

	//���������������������������������������������������������������e
	//�Celulas - Pai - Define Celulas Impressas no Cabecalho da lista�
	//���������������������������������������������������������������e
	TRCell():New(oSection1,"TMP_FILIAL" ,,STR0004,,nTamFil)//Filial
	TRCell():New(oSection1,"E1_VALOR" ,,STR0005,cPicE1_Val)//Valor Total
	TRCell():New(oSection1,"TMP_TOTAL" ,,STR0006,,12)//total Geral 
	
	For nI := 1 to Len(aFormas) 
		TRCell():New(oSection1,aFormas[nI][01]+"Q" ,,Left(RetDescrFP(aFormas[nI][02]),12),,12)//Descricao da Forma de Pagamento
   		TRCell():New(oSection1,aFormas[nI][01]+"V" ,,STR0007 + aFormas[nI][02] ,cPicE1_Val,aTamE1Valor[1])//"Vl" + Forma de pagamento
    Next nI

Return oReport 
 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJR020Imp �Autor  �Microsiga           � Data �  04/12/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � Relat�rio de Recarga de Celular e Correspondente Bancario  ���
���          � TEF Dire��o                                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJR020Imp(oReport, cPerg,cAlias1, aFormas)
Local oSection1	 := oReport:Section(1)                    				  	/// Secao do Cabe�alho
Local cFilRep := ""   //Filial do Relat�rio
Local cFiltro := "%SE1.E1_TIPO IN("   //Filtro do Relat�rio
Local nI		:= 0  //Contador do Relat�rio 
Local nQtdTot	:= 0 //Quantidade total da Filial
Local nValTot	:= 0 //Valor total da Filial   

MakeSqlExpr(cPerg)

if TRepInUse() 
         
    aEval(aFormas, {|f| cFiltro := cFiltro + "'" + f[2] + "',"})
    
    cFiltro := Left(cFiltro, Len(cFiltro)-1) + " ) "     
    
    If MV_PAR05 == 1  //Recarga
    	cFiltro += 	" AND SE1.E1_NATUREZ = '" + SuperGetMv("MV_NATRC",, "") + "' " 
    ElseIf MV_PAR05 == 2	//Corresp Bancario
    	cFiltro += 	" AND SE1.E1_NATUREZ = '" + SuperGetMv("MV_NATCB",, "") + "' " 
    Else //Ambos    	
    	cFiltro += 	" AND (SE1.E1_NATUREZ = '" + SuperGetMv("MV_NATRC",, "") + "' OR "  
    	cFiltro += 	" 	   SE1.E1_NATUREZ = '" + SuperGetMv("MV_NATCB",, "") + "') "
    EndIf
    
    cFiltro += " AND%" 
    
	//��������������������������������������Ŀ
	//�Query secao 1 - Cabe�alho 			 � 
	//����������������������������������������
	BEGIN REPORT QUERY oSection1
		BeginSQL alias cAlias1    
			SELECT	E1_FILIAL,
			   		E1_TIPO,
			   		COUNT(1) CONTA,
	     	   		SUM(E1_VALOR) E1_VALOR
	     	FROM %table:SE1% SE1
 	    	 		WHERE SE1.%notDel% AND %Exp:cFiltro% 
 	    	 		 SE1.E1_EMISSAO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND
 	    	 		 SE1.E1_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 
	     	GROUP BY E1_FILIAL, E1_TIPO 
	     	ORDER BY E1_FILIAL, E1_TIPO 
		EndSql 
	END REPORT QUERY oSection1 	

	
	oSection1:Init()
	//������������������������������������������������������������������Ŀ	
	//� Impressao do Relatorio enquanto nao for FIM de Arquivo - cAlias1 �
	//� e nao for cancelada a impressao									 �
	//��������������������������������������������������������������������	
	While !oReport:Cancel() .AND. (cAlias1)->(!Eof())   //Regra de impressao 

			cFilRep  := (cAlias1)->E1_FILIAL  
			
			While (cAlias1)->(!Eof())  .AND. cFilRep  == (cAlias1)->E1_FILIAL
		         nI := aScan(aFormas, { |f| f[2] == RTrim((cAlias1)->E1_TIPO) } )  
		         If nI > 0
		         	aFormas[nI][3] += (cAlias1)->CONTA
		         	nQtdTot += (cAlias1)->CONTA
		         	aFormas[nI][4] += (cAlias1)->E1_VALOR
		         	nValTot += (cAlias1)->E1_VALOR
		         EndIf
				(cAlias1)->( DbSkip() )
            End

		 	oSection1:Cell("TMP_FILIAL"):SetValue(cFilRep + " " + FWFilialName(, cFilRep,1) ) //Filial
			oSection1:Cell("E1_VALOR"):SetValue(nValTot)
			oSection1:Cell("TMP_TOTAL"):SetValue(PadL(StrZero(nQtdTot,6),12))  
			       
			For nI := 1 To Len(aFormas) 
				oSection1:Cell( aFormas[nI][1]+"Q" ):SetValue( PadL(StrZero(aFormas[nI][3],6),12) )			
				oSection1:Cell( aFormas[nI][1]+"V" ):SetValue( aFormas[nI][4] ) 
 				aFormas[nI][3] := 0
				aFormas[nI][4] := 0    
			Next nI
	
			oSection1:PrintLine()


			nQtdTot	:= 0 //Quantidade total da Filial
			nValTot	:= 0 //Valor total da Filial
			
	End  
	oSection1:Finish()
EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj020PVl()�Autor  �Microsiga           � Data �  12/04/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de valida��o da pergunta do relatorio               ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Function Lj020PVl()
Local lValid := .F.   //Retorno da Fun��o
Local aFormDgt := {} //formas de pagamento informadas
Local nI	:= 0 //Contador das formas  
Local cFormOpe := ""//formas de pagamento da operacao
     

If !Empty(MV_PAR06)
	
	If MV_PAR05 == 1  //Operacao de Recarga de Celular
		cFormOpe := SuperGetMv("MV_LJRCFPG",,"")
	ElseIf  MV_PAR05 == 2
		cFormOpe := SuperGetMv("MV_LJCBFPG",,"")
	ElseIf MV_PAR05 == 3
		//Correspondente bancario
		cFormOpe := AllTrim(SuperGetMv("MV_LJCBFPG",,"")) + "/" +AllTrim(SuperGetMv("MV_LJCBFPG",,""))
	EndIf
	
	aFormDgt := StrTokArr(AllTrim(MV_PAR06), "/")  
	
	If Len(aFormDgt) > 0
		lValid := .T.
		For nI := 1 to Len(aFormDgt)
			lValid := AllTrim(aFormDgt[nI]) $ cFormOpe
			If !lValid
				Exit
			EndIf
		Next nI
	EndIf
EndIf

Return lValid

/*


Return    

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �RetDescrFP�Autor  �Vendas Clientes       � Data �  21/09/12   ���
���������������������������������������������������������������������������͹��
���Desc.     �Retorna a descricao da forma de pagamento.                    ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �                                                              ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function RetDescrFP(cForma)

Local cChave	:= ""		//Chave de pesquisa
Local cRet		:= ""		//Retorno

DEFAULT cForma := ""

cChave := xFilial("SX5") + "24" + AllTrim(cForma)
dbSelectArea("SX5")
SX5->(dbSetOrder(1))
SX5->(dbSeek(cChave))
If SX5->(Found())
	cRet := SX5->X5_DESCRI
Endif

Return cRet
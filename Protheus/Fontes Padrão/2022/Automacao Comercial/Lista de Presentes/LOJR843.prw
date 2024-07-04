#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "LOJR843.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � LOJR843  �Autor  �Vendas Cliente      � Data �  18/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Imprime o Relatorio de Sugestao de Listas de Presente      ���
���          � Relat�rio derivado da Rotina de Cadastro de Sugest�o       ���
�������������������������������������������������������������������������͹��
���Parametro � 														      ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJR843() 
Local oReport                  	// Variavel para Impressao
Local cPerg	:= "LOJR843"     	// Variavel para localizar o cadastro de pergunta 
Local lLstPre := SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)    //Verifica se a Lista de Presentes ja esta Ativa 
//��������������������������������������������������������������Ŀ
//� Verifica se a Lista de Presentes ja esta Ativa               �
//����������������������������������������������������������������
If !lLstPre
   MsgAlert(STR0001)	//"O recurso de lista de presente n�o est� ativo ou n�o foi devidamente aplicado e/ou configurado, imposs�vel continuar!"
   Return .F.
Endif

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//� CriaSx1 - Cria o Cadastro de Perguntas						 �
//� Habilita Pergunte antes dos parametros e impressao			 �
//����������������������������������������������������������������
Pergunte(cPerg,.T.)        

//����������������������Ŀ
//�Interface de impressao�
//������������������������
oReport := LJR843Rpt(cPerg)     //Funcao para impressao do relatorio onde se define Celulas e Funccos do TReport
oReport:PrintDialog()	           

Return 




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJR843Rpt �Autor  �Microsiga           � Data �  02/28/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina que define os itens que serao apresentados           ���
���          �Relatorio composto por 4 secoes - Cabecalho, Categoria,	  ���
���          �sub-categoria e itens de produtos							  ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJR843Rpt(cPerg)
Local oReport	 := NIL				// Objeto relatorio TReport (Release 4)
Local oSection1	 := NIL				// Dados da Sugestao da Lista
Local oSection2	 := NIL				// Objeto secao 1 do relatorio - Secao por Categoria
Local oSection3	 := NIL				// Objeto secao 2 do relatorio - Secao por Sub-Categoria

Local cTitulo    := STR0002 	    	// Titulo do Relatorio   # STR0002 - "Sugestao de Lista de Presentes"
Local cAlias1 	 := GetNextAlias()	// Sugestao da Lista	- Alias do Select para Secao 1 - Cabecalho
Local cAlias2  	 := GetNextAlias()	// Categoria			- Alias do Select para Secao 2
Local cAlias3  	 := GetNextAlias()	// Produtos				- Alias do Select para Secao 3

Local oBreak1                   	// Breca a Secao 2 do relatorio - Quebra por Categoria
Local oBreak2                   	// Breca a Secao 1 do relatorio - Quebra por Lista
Local lPageBreak := .T.				// Pular pagina

Default	cPerg	 := ""

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01          // Tipo de Evento De		                 �
//� MV_PAR02          // Tipo de Evento Ate                      �
//� MV_PAR03          // Codigo da Sugest�o da Lista             �
//����������������������������������������������������������������
//Define o Relatorio - TReport
oReport:=TReport():New("LOJR843",cTitulo,"",{|oReport| LJR843Imp(	oReport,cPerg,cAlias1,cAlias2,cAlias3)}) 
oReport:SetPortrait()			// Escolhe o padrao de Impressao como Retrato
oReport:nFontBody  := 9			// Tamanho da fonte inicial do Reltorio
oReport:nLineHeight:= 40		// Largura da Linha

//���������������������������������������������������������������e
//�Secao 1 - Pai - Cabecalho da Sugestao da lista de presentes   �
//�Define a Secao que ira Imprimir o Cabecalho da Lista          �
//����������������������������������������������������������������
oSection1:=TRSection():New( oReport,STR0002,{"ME7","ME8","ME3"} )//"Sugestao de Lista de Presentes"  
oSection1:SetLineStyle()			// Tipo de impressao - Impressao em linha
oSection1:PageBreak (lPageBreak)
	//���������������������������������������������������������������e
	//�Celulas - Pai - Define Celulas Impressas no Cabecalho da lista�
	//���������������������������������������������������������������e
	TRCell():New(oSection1,"ME7_CODIGO" ,"ME7",STR0003,,45)//"Codigo da Lista"
	TRCell():New(oSection1,"ME7_TIPLIS" ,"ME3",STR0004,,45,,{|| Alltrim((cAlias1)->ME7_TIPLIS) + " - " + (cAlias1)->ME3_DESCRI})//"Tipo de Evento"
	TRCell():New(oSection1,"ME7_STATUS" ,"ME7",STR0005,,45,,{|| LJR843X3Bx((cAlias1)->ME7_STATUS,"ME7_STATUS")})//"Status da Lista"

	//���������������������������������������������������������������������������������������Ŀ
	//�Secao 2 - Filha - Categoria		                                                      �
	//�Imprime as Categorias dos Produtos                                                     �
	//�Secao para quebra e Ordem do relat�rio                                                 �
	//�����������������������������������������������������������������������������������������
	oSection2 :=TRSection():New( oSection1,STR0006,{"ME8","ME7"} )//"Categoria"
	oSection2 :SetLineStyle() // Tipo de impressao - Impressao em linha
		//����������������������������������������������������������������������e
		//�Celulas - Filha - Define Celulas Impressas na Secao Categoria	 	�
		//�����������������������������������������������������������������������
		TRCell():New(oSection2,"ME8_DESFAC","ME8" ,"")//"Tipo Lista"      //"Categoria"  STR0006  
		TRCell():New(oSection2,"ME8_FACIL" ,"ME8" ,"")//"Categoria"  	   //STR0006
		oSection2:Cell("ME8_FACIL"):hide()

		oSection3 := TRSection():New(oSection2,"Produtos",{"ME8","ME7"})
			//��������������������������������������������������������������������Ŀ
			//�Celulas - Neta- Define Celulas Impressas na Se��o Produtos	   	   �
			//����������������������������������������������������������������������
			TRCell():New(oSection3,"ME8_CODPRO" ,"ME8",STR0007)		//"Produto"
			TRCell():New(oSection3,"ME8_DESPRO" ,"ME8",STR0008)		//"Descricao"
			TRCell():New(oSection3,"ME8_QTDPRO" ,"ME8",STR0009)		//"Qtde"
 			TRCell():New(oSection3,"ME8_VALPRO" ,"ME8",STR0010,STR0017,20,,{||Lj843PrcV((cAlias3)->ME8_CODPRO)},'RIGHT',,'RIGHT') //  STR0010 - "Valor"  //  STR0017 "@E 999,999.99"

	        //Totalizador por quebra de categoria
			oBreak1 := TRBreak():New(oSection2,oSection2:Cell("ME8_FACIL"),STR0011,.F.)				//"TOTAL DA CATEGORIA"
			TRFunction():New(oSection3:Cell("ME8_QTDPRO"),NIL,"SUM",oBreak1,STR0012,,,.F.,.F.,.F.)	//"Quantidade"
			TRFunction():New(oSection3:Cell("ME8_VALPRO"),NIL,"SUM",oBreak1,STR0010,,,.F.,.F.,.F.)	//"Valor"

Return(oReport) 






/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � LJR843Imp�Autor  �Vendas Cliente      � Data �  18/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Imprime o Relatorio de Sugestao de Listas de Presente      ���
���          � Relat�rio derivado da Rotina de Cadastro de Sugest�o       ���
�������������������������������������������������������������������������͹��
���Sintaxe	 � LJR843Imp(oReport, cPerg, cAlias1,cAlias2,cAlias3)		  ���
�������������������������������������������������������������������������͹��
���Parametro � oReport  - Objeto da impressao							  ���
���			 � cPerg    - Grupo de Perguntas					          ���
���			 � cAlias1 - Area para o Select da Primeira Secao - Cabecalho ���
���			 � cAlias2 - Area para o Select da Segunda  Secao - Categoria ���
���			 � cAlias3 - Area para o Select da Terceira Secao - Produtos  ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJR843Imp(oReport, cPerg, cAlias1,cAlias2,;
						  cAlias3)
Local oSection1	 := oReport:Section(1)                    				  	/// Secao do Cabe�alho
Local oSection2	 := oReport:Section(1):Section(1)							/// Secao do Cateforia
Local oSection3  := oReport:Section(1):Section(1):Section(1)				/// Secao do Produtos
Local lFooter  	 := .T.														// Variavel para pular a pagina na quebra da secao 1

Local cFiltro    := ""     /// Vari�vel que Filtrara o Select Principal - Secao 1 
						   /// e a partir deste Select ser�o feitos os das outras secoes
Local nValor 			 	// Variavel para o Valor Total da Lista
Local nQtde  				// Variavel para a Qtde Total da Lista

Default oReport	:= NIL
Default cPerg	:= ""
Default cAlias1	:= ""
Default cAlias2	:= ""
Default cAlias3	:= ""

MakeSqlExpr(cPerg)

if TRepInUse() 

	// Filtro por Tipo de Evento
	If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
		cFiltro += 	" AND (ME7_TIPLIS BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "           
	Endif
	// Filtro por Codigo da Sugest�o de Lista
	If !Empty(MV_PAR03)
		cFiltro += 	" AND (ME7_CODIGO = '" + MV_PAR03 + "') "           
	Endif

	cFiltro := "%"+cFiltro+"%"    

	//��������������������������������������Ŀ
	//�Query secao 1 - Cabe�alho 			 � 
	//����������������������������������������
	BEGIN REPORT QUERY oSection1
		BeginSQL alias cAlias1    
			SELECT	ME7_FILIAL,
			   		ME7_CODIGO,
	     	   		ME7_DESCRI,
	     	   		ME7_TIPLIS,
	     	   		ME7_STATUS,
	     	   		ME3_DESCRI
	     	FROM %table:ME7% ME7
 	    	 	INNER JOIN %table:ME3% ME3 ON ME3.ME3_CODIGO = ME7.ME7_TIPLIS AND ME3.%notDel%
				WHERE ME7.%notDel%  %Exp:cFiltro%
	     	ORDER BY ME7_FILIAL,ME7_CODIGO
		EndSql 
	END REPORT QUERY oSection1 	

	//������������������������������������������Ŀ
	//�Query secao 2 - Categoria      		 	 �
	//��������������������������������������������	
	BEGIN REPORT QUERY oSection2
		BeginSQL alias cAlias2
			SELECT  ME8_FACIL,
					ME8_DESFAC,
					Count(ME8_FACIL) As TotalGRP
 	     	FROM %table:ME8% ME8
				WHERE ME8.%notDel% AND 
					  ME8.ME8_CODIGO = %report_param:(cAlias1)->ME7_CODIGO%
			GROUP BY ME8_FACIL,
					 ME8_DESFAC
	     	ORDER BY ME8_FACIL
		EndSql 	
	END REPORT QUERY oSection2
	
	//������������������������������������������Ŀ
	//�Query secao 3 - produtos       		 	 �
	//��������������������������������������������	
	BEGIN REPORT QUERY oSection3
		BeginSQL alias cAlias3
			SELECT  ME8_CODPRO,
					ME8_DESPRO,
					0 AS ME8_VALPRO,
                    1 AS ME8_QTDPRO
 	     	FROM %table:ME8% ME8
	 	    	 	INNER JOIN %table:ACV% ACV ON ACV.ACV_CODPRO = ME8.ME8_CODPRO AND ACV.%notDel%
				WHERE ME8.%notDel% AND 
					  ME8.ME8_CODIGO = %report_param:(cAlias1)->ME7_CODIGO% AND
					  ME8.ME8_FACIL  = %report_param:(cAlias2)->ME8_FACIL%
	     	ORDER BY ME8_CODPRO
		EndSql 	
	END REPORT QUERY oSection3
	//������������������������������������������������������������������Ŀ	
	//� Impressao do Relatorio enquanto nao for FIM de Arquivo - cAlias1 �
	//� e nao for cancelada a impressao									 �
	//��������������������������������������������������������������������	
	While !oReport:Cancel() .AND. (cAlias1)->(!Eof())   //Regra de impressao 
		nValor := 0
		nQtde  := 0

		oSection1:Init()
		/// Executa a Select da Se��o 2
		oSection2:ExecSql()			
		
		If  !(cAlias2)->(Eof()) 
			oSection1:PrintLine()
			oReport:FatLine()
			oReport:SkipLine()
		EndIf                         

		//IMPRESSAO SECAO 2
		While !oReport:Cancel() .And. !(cAlias2)->(Eof())

			oSection2:Init()
			/// Executa a Select da Secao 3			                    			
			oSection3:ExecSql() 	
		
			If  !(cAlias3)->(Eof())
				oSection2:PrintLine()
			EndIf
	
			//IMPRESSAO SECAO 2
			While !oReport:Cancel() .And. !(cAlias3)->(Eof())
				oSection3:Init()
				oSection3:PrintLine()
				nValor += Lj843PrcV((cAlias3)->ME8_CODPRO)
				nQtde  += (cAlias3)->ME8_QTDPRO
				(cAlias3)->(DbSkip())	
			End
			oSection3:Finish()
			(cAlias2)->(DbSkip())
		End
		oSection2:Finish()
		(cAlias1)->(DbSkip())

		oReport:PrintText(STR0013,,oSection3:Cell('ME8_CODPRO'):ColPos()) //"TOTAL DA LISTA  :"
		oReport:FatLine()
		nRow := oReport:Row()
		oReport:PrintText(transform(nQtde,STR0018),nRow,oSection3:Cell('ME8_QTDPRO'):ColPos())   //// STR0018 - "9999999"
		oReport:PrintText(transform(nValor,STR0019),nRow,oSection3:Cell('ME8_VALPRO'):ColPos())  //// STR0019 - "@e 9999,999,999,999,999.99"
        oReport:EndPage(lFooter)
		
		oSection1:Finish()
	End
EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJR843X3Bx�Autor  �Vendas Cliente		 � Data �  28/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a descri��o do combo box do campo no SX3            ���
�������������������������������������������������������������������������͹��
���Uso       �LOJR843                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJR843X3Bx(cCodigo,cCampo)                                       

Local aSX3Box	:= {}	//Array de Opcoes do Combo Box
Local cRet  	:= ""  	//Retorno
Local nPos		:= 0   	//Posicao do array    

Default cCodigo	:= ""	//Codigo da sugestao
Default cCampo	:= ""	//Campo a procurar

If !Empty(Posicione("SX3", 2, cCampo, "X3CBox()" ))
	aSX3Box	:= RetSx3Box( Posicione("SX3", 2, cCampo, "X3CBox()" ),,, 1 )
	
	nPos := Ascan(aSX3BOX,{|x| x[2]== cCodigo})
	If nPos > 0 
		cRet:= aSX3Box[nPos,3]
	Endif
Endif

If Empty(cRet)
	cRet := cCodigo
Endif

Return Rtrim(cRet)   
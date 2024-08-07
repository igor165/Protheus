#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJR802.CH"
#INCLUDE "REPORT.CH"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � LOJR802  � Autor � Vendas Crm            � Data � 28/02/11   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Motivo de descontos                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LOJR802                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function LOJR802()

Local cPerg     := "LOJR802"       	//Descricao do Pergunte
Local cAlias    := GetNextAlias()  	//Alias de uma section1
Local cAlias2   := GetNextAlias()  	//Alias de uma section2
Local oReport  	:= Nil			  	//Objeto do relatorio
Local oSection1	:= Nil				//Objeto Secao 1
Local oSection2 := Nil				//Objeto Secao 2
Local oBrkSec2	:= Nil 				//Objeto TRBreak da Secao 2      

Pergunte(cPerg,.T.)

//���������Ŀ
//�Relatorio�                                                              
//�����������
oReport:= TReport():New("LOJR802",STR0001, cPerg, {|oReport| PrintReport(oReport, cPerg, cAlias,cAlias2)}) //
oReport:nFontBody   := 8 
oReport:nLineHeight := 40


//���������������Ŀ
//�Campos Section1�
//�����������������
oSection1:= TRSection():New(oReport	,STR0021)//Dados do Pedido
oSection1:SetLineStyle(.T.)	
oSection1:SetHeaderBreak(.T.)   

TRCell():New(oSection1	,"MEM_CODIGO",,STR0009,,(TamSX3("MEM_CODIGO")[1]) + 2,.T.,,"LEFT",,,,,,,,.T.)//Codgio
TRCell():New(oSection1	,"MEM_NPEDOR",,STR0010,,(TamSX3("MEM_NPEDOR")[1]) + 2,.T.,,"LEFT",,,,,,,,.T.)//Ped. Origiem
TRCell():New(oSection1	,"MEM_FILORI",,STR0011,,(TamSX3("MEM_FILORI")[1]) + 2,.T.,,"LEFT",,,,,,,,.T.)//Filial Origem
TRCell():New(oSection1	,"MEM_NPEDDE",,STR0012,,(TamSX3("MEM_NPEDDE")[1]) + 2,.T.,,"LEFT",,,,,,,,.T.)//Ped. Destino
TRCell():New(oSection1	,"MEM_FILDES",,STR0013,,(TamSX3("MEM_FILDES")[1]) + 2,.T.,,"LEFT",,,,,,,,.T.)//Filial de Destino
TRCell():New(oSection1	,"MEM_DATTRA",,STR0014,,(TamSX3("MEM_DATTRA")[1]) + 2,.T.,,"LEFT",,,,,,,,.T.)//Data da Movimentacao		
TRCell():New(oSection1	,"MEM_MOTIVO",,STR0015,,(TamSX3("MEM_MOTIVO")[1]) + 2,.T.,,"LEFT",,,,,,,,.T.)//Motivo
TRCell():New(oSection1	,"MEM_ORCORI",,STR0016,,(TamSX3("MEM_ORCORI")[1]) + 2,.T.,,"LEFT",,,,,,,,.T.)//Orcamento de Origem

//���������������Ŀ
//�Campos Section2�
//����������������� 
oSection2:= TRSection():New(oSection1,STR0022)//Itens do Pedido
oSection2:SetHeaderBreak(.T.)
oSection2:SetLeftMargin(1)	

TRCell():New(oSection2,"C6_PRODUTO",,STR0017,,(TamSX3("C6_PRODUTO")[1]) + 2,.T.,,"LEFT")       //Cod Produto
TRCell():New(oSection2,"B1_DESC"   ,,STR0018,,(TamSX3("B1_DESC")[1])  + 2,.T.,,"LEFT")         //Descricao do Produto
TRCell():New(oSection2,"C6_QTDVEN" ,,STR0019,,(TamSX3("C6_QTDVEN")[1]) + 2,.T.,,"LEFT",,"LEFT")//Qtde. Movimentada
TRCell():New(oSection2,"C6_PRCVEN" ,,STR0020,,(TamSX3("C6_PRCVEN")[1]) + 2,.T.,,"LEFT",,"LEFT")//Pre�o

oReport:PrintDialog()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PrintReport�Autor  �Vendas Crm         � Data �  28/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Selecao dos itens a serem impressos                         ���
�������������������������������������������������������������������������͹��
���Sintaxe	 � PrintReport(oReport, cPerg, cAlias,cAlias2) 				  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  oReport	- Objeto do relatorio             				  ���
���          �  cPerg   - Descricao para o Pergunte do SX1				  ���
���          �  cAlias  - Alias com inf. para Section1					  ���
���          �  cAlias2 - Alias com inf. para Section2					  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nil        									              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGALOJA                          						  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrintReport(oReport, cPerg, cAlias, cAlias2)

Local oSection1 := oReport:Section(1)                          //Define a secao Pai (Quebra)
Local oSection2 := oReport:Section(1):Section(1)	           	//Define a secao Filha (Detalhe)  
Local cSQL		:= ""                                          	//Complemento da Query executada no banco  
Local nCount    := 0                                            //Para valida��o se consta todos os registros

Default cPerg   := "LOJR802"
Default cAlias  := ""
Default cAlias2 := ""


cSQL := "MEM.D_E_L_E_T_ = '' "
If !Empty(mv_par01)
	cSQL += "AND MEM.MEM_FILORI = '" +mv_par01+ "' "
EndIf
If !Empty(mv_par02)  
	If !(Upper(mv_par02) == Replicate("Z", (TamSX3("MEM_FILDES")[1])))
		cSQL += "AND MEM.MEM_FILDES = '" +mv_par02+ "' "
	EndIf	
EndIf 
If !Empty(mv_par03)
	cSQL += "AND MEM.MEM_NPEDOR = '" +mv_par03+ "' "  
EndIf  
If !Empty(mv_par04)
	If !(Upper(mv_par04) == Replicate("Z", (TamSX3("MEM_NPEDDE")[1])))
		cSQL += "AND MEM.MEM_NPEDDE = '" +mv_par04+ "' " 
	EndIf	
EndIf
If !Empty(DtoS(mv_par05)) .And. !Empty(DtoS(mv_par06))
	cSQL += "AND MEM.MEM_DATTRA BETWEEN '" + DtoS(mv_par05) + "' AND '" + DtoS(mv_par06) + "' "
EndIf 
If !Empty(mv_par07)
	cSQL += "AND MEM.MEM_ORCORI = '" +mv_par07+ "' "
EndIf
Do Case 
	Case mv_par08 == 1
		cSQL += "ORDER BY MEM.MEM_FILORI, MEM.MEM_NPEDOR "
	Case mv_par08 == 2     
		cSQL += "ORDER BY MEM.MEM_FILDES, MEM.MEM_NPEDDE "   
	Case mv_par08 == 3     
		cSQL += "ORDER BY MEM.MEM_FILORI, MEM.MEM_CODIGO "		
End
cSQL := "%"+cSQL+"%"

MakeSqlExpr(cPerg) 


//��������Ŀ
//�Secao 1 �
//����������
BEGIN REPORT QUERY oSection1
	BeginSQL alias cAlias    	
	    SELECT MEM.MEM_CODIGO, MEM.MEM_NPEDOR, MEM.MEM_FILORI, MEM.MEM_NPEDDE,
	   		   MEM.MEM_NPEDDE, MEM.MEM_DATTRA, MEM.MEM_MOTIVO, MEM.MEM_ORCORI,
	   		   MEM.MEM_FILDES	
		FROM %table:MEM% MEM  
  	   		WHERE %Exp:cSQL% 
	EndSql
END REPORT QUERY oSection1

//��������Ŀ
//�Secao 2 �
//����������
BEGIN REPORT QUERY oSection2
	BeginSQL alias cAlias2    
		SELECT SC6.C6_PRODUTO, SC6.C6_QTDVEN, SC6.C6_PRCVEN, SB1.B1_DESC
		FROM %table:SC6% SC6   
		INNER JOIN %Table:SB1% SB1 ON SB1.B1_COD = SC6.C6_PRODUTO
		WHERE SC6.%notDel% AND SC6.C6_NUM = %report_param: (cAlias)-> MEM_NPEDOR %	  
		AND SC6.C6_FILIAL = %report_param: (cAlias)-> MEM_FILORI %	  
		AND SB1.B1_FILIAL = %report_param: (cAlias)-> MEM_FILORI %	
		GROUP BY SC6.C6_PRODUTO, SC6.C6_QTDVEN, SC6.C6_PRCVEN, SB1.B1_DESC 		
		ORDER BY SC6.C6_PRODUTO
	EndSql
END REPORT QUERY oSection2 


//���������������������Ŀ
//�Controle de impressao�
//�����������������������
While !oReport:Cancel() .AND. (cAlias)->(!Eof()) //Regra de impressao
	nCount   := 0
	oSection1:Init() 
	oSection2:ExecSql() 		

	If  !(cAlias2)->(Eof()) 
		oSection1:PrintLine()
	EndIf
	
	While !oReport:Cancel() .And. !(cAlias2)->(Eof())
	    
		nCount++              // Adiciona mais 1 para informar que tem registros
		
		oSection2:Init()      //Cria a oSection2 e Cabe�alho de produtos
		
		oSection2:PrintLine() // Imprimi registro de produtos
			
	 	(cAlias2)->(DbSkip())	 	 		
 	
	End	 
 	oSection2:Finish() 	//Fecha o oSection2 e cria uma linha de divisao 
	(cAlias)->(DbSkip())	
	
	//nCount = 0, significa que nao existe registro na section2
	If !(cAlias)->(Eof()) .AND. nCount > 0 
		oReport:ThinLine()
 	EndIf
	oSection1:Finish()  //Fecha o oSection1 e cria uma linha de divisao
End 


Return Nil


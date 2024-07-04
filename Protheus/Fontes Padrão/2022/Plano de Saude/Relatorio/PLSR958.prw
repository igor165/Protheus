#Include "TopConn.CH"
#Include "Protheus.ch"
//#Include "PLSR958.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PLSR958   � Autor �F�bio S. dos Santos	� Data �16/11/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relat�rio de Faturas Liberadas.			                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - PLS				                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSR958()
Local oReport
Private cAlias := GetNextAlias()
Private nPagina		:= 0
oReport:= ReportDef()
oReport:PrintDialog()

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �ReportDef � Autor � F�bio S. dos Santos  	  � Data �28/07/2015���
���������������������������������������������������������������������������Ĵ��
���Descricao � Cria Celulas que serao Impressas no Relatorio                ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport

Local oSecTion1
Local oSecTion2
Local oSecTion3

Local cPerg := "PLSR958"

Pergunte(cPerg,.F.)

oReport:= TReport():New("PLSR958","Relat�rio de Faturas Liberadas",cPerg,{|oReport|PrintReport(oReport)},"Relat�rio de Faturas Liberadas")//Relat�rio de Faturas Liberadas
oReport:SetPortrait(.T.) // Imprimir relat�rio em formato retrato
oReport:SetTotalInLine(.f.)
oReport:lParamPage := .f.

oSection1 := TRSection():New(oReport,"Faturas Liberadas",{"BCI"}) //tabelas que ser�o usadas no programa
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderBreak(.F.)  
oSection1:SetHeaderPage(.F.)  
oSection1:SetHeaderSection(.T.)

TRCell():New(oSection1,"NOME","PLSR958","Responsavel pela liberacao",,,,,,,,,,,,,,.F.)
TRCell():New(oSection1,"TOTAL","PLSR958","Quantidade Protocolos Liberados" ,,,,,,,,,,,,,,.F.)

Return oReport

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Funcao    �PrintReport�Autor  � F�bio S. dos Santos	   � Data � 03/02/14 ���
����������������������������������������������������������������������������Ĵ��
���Descricao � Seleciona os dados para o Relat�rio.		                     ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/

Static Function PrintReport(oReport)
Local cQuery		:= ""
Local nRegis		:= 0
Local cNomeUsr		:= ""
Local nPageWidth  	:= oReport:PageWidth()
Local nLinhas		:= 70 // numero total de linhas
Local oSection1 	:= oReport:Section(1) 
Local cOpeInt		:= GetNewPar("MV_PLSGEIN","0050")
Local cWhere		:= ""
Private cAlias		:= "PLSR958"

If MV_PAR03 == 1
	cWhere += "% BD5.BD5_TIPATE BETWEEN '01' AND '13' AND%"
ElseIf MV_PAR03 == 2
	cWhere += "% (BD5.BD5_TIPATE > '13' OR BD5.BD5_CODEMP = '" + cOpeInt + "') AND %"	 
Else
	cWhere += "% %"		
EndIf

oSection1:BeginQuery()
BeginSql Alias cAlias
	
	SELECT BCI_USRLIB, COUNT(BCI_USRLIB) TOTAL 
	FROM %table:BCI% BCI
	WHERE 
	EXISTS (SELECT BD5.BD5_TIPATE FROM %table:BD5% BD5 
	WHERE BD5.BD5_FILIAL = %exp:xFilial("BD5")%  AND
	BD5.BD5_CODOPE = BCI.BCI_CODOPE AND
	BD5.BD5_CODLDP = BCI.BCI_CODLDP AND
	BD5.BD5_CODPEG = BCI.BCI_CODPEG AND
	%exp:cWhere%
	BD5.D_E_L_E_T_ = '') AND
	BCI.BCI_FILIAL = %exp:xFilial("BCI")%  AND 
	SubString(BCI.BCI_DTHRLB,1,8) BETWEEN %exp:Mv_PAR01% AND %exp:Mv_PAR02% AND 
	BCI.D_E_L_E_T_ = ''
	GROUP BY BCI_USRLIB
EndSql

oSection1:EndQuery()
cQuery:= oSection1:GetQuery()

//Definindo a quantidade de registro da query (nRegis)
(cAlias)->(DbGotop())
While (cAlias)->(!Eof())
	nRegis++ //Contador para determinar a quantidade de registros da query
	(cAlias)->( DbSkip() )
End

oReport:SetMeter(nRegis) //Seta com o metodo SetMeter o total de registros para controle da query

//�����������������������������������������������������������������������������������������Ŀ
//� Executa o Cabecalho para oReport:EndPage()                                              �
//�������������������������������������������������������������������������������������������
nPagina := 0
(cAlias)->(DbGotop())
If !(cAlias)->(Eof())
	ImpCabec(oReport)
EndIf
While !oReport:Cancel() .And. (cAlias)->( ! EoF() ) //Enquanto n�o for fim dos registro e o usu�rio n�o clicar em cancelar

	oReport:IncMeter()  //Incrementa +1 na regua com o metodo IncMeter
	If oReport:Cancel() //Se clicou em Cancelar, sai do relatat�rio
		Exit
	EndIf
		
	oSection1:Init()
	oSection1:Cell("NOME"):SetValue(UsrFullName((cAlias)->BCI_USRLIB))
		
	oSection1:PrintLine()
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Executa o Cabecalho para oReport:EndPage()                                              �
	//�������������������������������������������������������������������������������������������
	If oReport:Row() > oReport:LineHeight() * nLinhas
		oReport:EndPage()
	EndIf
	
	(cAlias)->( DbSkip() ) //Proximo registro do Alias

End
oSection1:Finish()
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCabec  �Autor  � Fabio S. dos Santos� Data � 30/07/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     �Imprime o cabecalho das capta��es de visitas.               ���
���          �        				                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Totvs - PLS                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpCabec(oReport)
Local nPageWidth 	:= oReport:PageWidth()
Local nRow			:= oReport:Row()
Local nCol01		:= 0060
                      
//��������������������������������������������������������������������Ŀ
//�Linha 1                                                             �
//����������������������������������������������������������������������
oReport:PrintText( "Per�odo de Libera��o para Pagamento: " + DtoC(MV_PAR01) + " a " + DtoC(MV_PAR02), oReport:Row(), nCol01 )
oReport:SkipLine(01) 
oReport:PrintText( "Tipo de Fatura: " + Iif(MV_PAR03 == 1,"Assistencial","Ocupacional"), oReport:Row(), nCol01 )

oReport:SkipLine(02)  

Return
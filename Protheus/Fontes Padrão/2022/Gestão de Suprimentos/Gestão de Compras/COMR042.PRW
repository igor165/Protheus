#Include "Protheus.Ch"
#Include "Report.Ch"
     
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �COMR042   �Autor  �Tiago Tudisco       � Data �  11/05/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio usado para exibir a data e a hora dos passos      ���
���          �utilizados durante o processo de SC. (tabela COI)           ���
�������������������������������������������������������������������������͹��
���Uso       � CNI                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function COMR042()
Local oReport
Local cPerg := "COI"                     
  
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//�						 �
//�Desabilita Pergunte antes dos parametros e impressao		 �
//����������������������������������������������������������������     
Pergunte( cPerg, .F. )

oReport := DefCell(cPerg)
oReport:PrintDialog()

Return
            
   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DefCell   �Autor  �Tiago Tudisco       � Data �  11/05/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que define as celular a serem exibidas no relatorio  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CNI                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DefCell(cPerg)
Local oReport	:= NIL
Local oSection1	:= NIL				
Local oSection2	:= NIL				

Local cTitulo := "LOG DOS PROCESSOS DE SOLICITA��O DE COMPRA"

Local cAlias1 	:= GetNextAlias()	// Sugestao da Lista	- Alias do Select para Secao 1 - Datas
Local cAlias2  	:= GetNextAlias()	// Categoria			- Alias do Select para Secao 2 - Usuarios
      
Local lPageBreak := .T.
Local aOrd := {"SOLICITAC�O DE COMPRA"}//Vetor com os tipos de ordenacao

//Define o Relatorio - TReport
oReport:=TReport():New("RelLogSC",cTitulo,cPerg,{|oReport| DefPrint(oReport,cPerg,cAlias1,cAlias2)},;
"Este relat�rio ir� imprimir informa��es referentes ao log dos processos de Solicita��o de Compras.") 
oReport:SetLandscape()			// Escolhe o padrao de Impressao como Paisagem
oReport:nFontBody  := 7			// Tamanho da fonte inicial do Reltorio
oReport:nLineHeight:= 30		// Largura da Linha

oSection1:=TRSection():New( oReport,"Log SC",{"COI"},aOrd )//"Sugestao de Lista de Presentes"  
oSection1:PageBreak (lPageBreak)
oSection1:SetHeaderPage()

TRCell():New(oSection1,"COI_NUMSC"    ,"COI","Num.SC"     ,,06)
TRCell():New(oSection1,"COI_ITEM"     ,"COI","Item"       ,,04)
TRCell():New(oSection1,"COI_DTHSOL"   ,"COI","Dt.SC"   	   ,,16)
TRCell():New(oSection1,"COI_DTHAPR"   ,"COI","Dt.Aprov"   ,,16)
TRCell():New(oSection1,"COI_DTHCOT"   ,"COI","Dt.Cotac"   ,,16)
TRCell():New(oSection1,"COI_DTHATL"   ,"COI","Dt.Atual"   ,,16)
TRCell():New(oSection1,"COI_DTHANL"   ,"COI","Dt.An�li"   ,,16)
TRCell():New(oSection1,"COI_DTHCTR"   ,"COI","Dt.Contr"   ,,16)
TRCell():New(oSection1,"COI_DTHPED"   ,"COI","Dt.Pedid"   ,,16)
TRCell():New(oSection1,"COI_DTHLIB"   ,"COI","Dt.Liber"   ,,16)
TRCell():New(oSection1,"COI_DTHLPN"   ,"COI","Dt.PreNt"   ,,16)
TRCell():New(oSection1,"COI_DTHATS"   ,"COI","Dt.Atest"   ,,16)
TRCell():New(oSection1,"COI_DTHCLS"   ,"COI","Dt.Class"   ,,16)
  
oSection2 := TRSection():New(oSection1,"",{"COI"} )
oSection2:SetHeaderPage() 
                                                          
TRCell():New(oSection2,""		  ,""	 ,""  		,,02)
TRCell():New(oSection2,"COI_USER",""    ,""			,,08)
TRCell():New(oSection2,"COI_USOL","COI" ,""			,,16)
TRCell():New(oSection2,"COI_UAPR","COI" ,""			,,16)
TRCell():New(oSection2,"COI_UCOT","COI" ,""			,,16)
TRCell():New(oSection2,"COI_UATL","COI" ,""			,,16)
TRCell():New(oSection2,"COI_UANL","COI" ,""			,,16)
TRCell():New(oSection2,"COI_UCTR","COI" ,""			,,16)
TRCell():New(oSection2,"COI_UPED","COI" ,""			,,16)
TRCell():New(oSection2,"COI_ULIB","COI" ,""			,,16)
TRCell():New(oSection2,"COI_ULPN","COI" ,""			,,16)
TRCell():New(oSection2,"COI_UATS","COI" ,""			,,16)
TRCell():New(oSection2,"COI_UCLS","COI" ,""			,,16)

Return( oReport )        
             

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DefPrint  �Autor  �Tiago Tudisco       � Data �  11/05/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao responsavel por imprimir o relatorio                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CNI                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DefPrint(oReport,cPerg,cAlias1,cAlias2)
Local oSection1	 := oReport:Section(1)                    				  	/// Secao do Cabe�alho
Local oSection2	 := oReport:Section(1):Section(1)							/// Secao do Usuario
Local lFooter  	 := .T.														// Variavel para pular a pagina na quebra da secao 1

Local cOrder := ""

//Solicitacao de Compra
If oSection1:GetOrder() == 1 
	cOrder := "%COI.COI_NUMSC,COI.COI_ITEM%"
Endif
         
//������������������������������������������
//�Query com os resultados a serem exibidos�
//�na Secao 1                              �
//������������������������������������������
	BEGIN REPORT QUERY oSection1
		BeginSQL alias cAlias1    

		SELECT SC1.C1_EMISSAO,COI.COI_DTHSOL,
			   COI.COI_DTHAPR,COI.COI_DTHCOT,
			   COI.COI_DTHATL,COI.COI_DTHANL,
			   COI.COI_DTHCTR,COI.COI_DTHPED,
			   COI.COI_DTHLIB,COI.COI_DTHLPN,
			   COI.COI_DTHATS,COI.COI_DTHCLS,
			   COI.COI_FILIAL,COI.COI_NUMSC,
			   COI.COI_ITEM,COI.COI_PNCHAV
		FROM   %Table:COI% COI, %Table:SC1% SC1 
		WHERE	COI.COI_FILIAL	= %xFilial:COI% AND
				COI.COI_NUMSC  BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
				SC1.C1_EMISSAO BETWEEN %Exp:DtoS(mv_par03)% AND %Exp:DtoS(mv_par04)% AND 
				SC1.C1_TPSC	   <> '2'			AND
				COI.COI_FILIAL	= SC1.C1_FILIAL AND
				COI.COI_NUMSC	= SC1.C1_NUM	AND
				COI.COI_ITEM	= SC1.C1_ITEM	AND
				COI.%NotDel%
		ORDER BY %Exp:cOrder%
		
	EndSQL
END REPORT QUERY oSection1 	 

//����������������������������������������Ŀ
//�Query com os resultados a serem exibidos�
//�na Secao 2                              �
//������������������������������������������
	BEGIN REPORT QUERY oSection2
		BeginSQL alias cAlias2    

		SELECT 'Usu�rio:'as COI_USER,
			   COI.COI_USOL,COI.COI_UAPR,
			   COI.COI_UCOT,COI.COI_UATL,
			   COI.COI_UANL,COI.COI_UCTR,
			   COI.COI_UPED,COI.COI_ULIB,
			   COI.COI_ULPN,COI.COI_UATS,
			   COI.COI_UCLS	
		FROM   %Table:COI% COI
		WHERE	COI.COI_FILIAL	= %report_param:(cAlias1)->COI_FILIAL% AND
				COI.COI_NUMSC   = %report_param:(cAlias1)->COI_NUMSC%  AND
				COI.COI_ITEM	= %report_param:(cAlias1)->COI_ITEM%   AND 
				COI.COI_PNCHAV	= %report_param:(cAlias1)->COI_PNCHAV% AND 
				COI.%NotDel%
		ORDER BY %Exp:cOrder%
		
	EndSQL
END REPORT QUERY oSection2

//�����������������������������������������Ŀ
//�Loop de impressao das linhas do relatorio�
//�������������������������������������������
While !oReport:Cancel() .AND. (cAlias1)->(!Eof())   //Regra de impressao 
	oSection1:Init()    
	/// Executa a query da secao 2
	oSection2:ExecSql()	
   
	If  !(cAlias2)->(Eof()) //imprime cabecalho (Secao 1)
		oSection1:PrintLine()
	EndIf                         
	//IMPRESSAO SECAO 2
	While !oReport:Cancel() .And. !(cAlias2)->(Eof())
		oSection2:Init()
		oSection2:PrintLine()
				
		(cAlias2)->(DbSkip())
	End
	oSection2:Finish()
	oReport:SkipLine()//Pula uma linha
	oReport:FatLine() //Desenha uma Linha
	(cAlias1)->(DbSkip())  
End
oSection1:Finish()
Return
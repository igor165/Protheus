#INCLUDE "PLSR955.CH"
#INCLUDE "REPORT.CH"
#include "PLSMGER.CH"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLSR955   � Autor � TOTVS                � Data � 30/07/15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Dimensionamento de Rede                                    ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR955 	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function PLSR955()
Local oReport

Pergunte("PLSR955",.F.) 
oReport := ReportDef()
oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � TOTVS            � Data � 30/07/15 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR955                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection1 
Local cTitulo:= OemToAnsi(STR0001)//"Dimensionamento de Rede"
Local cDesc1 := OemToAnsi(STR0002)//"Este relatorio ira exibir o estudo realizado para dimensionar a rede"
Local cDesc2 := OemToAnsi(STR0003)//"referente ao ano informado para consulta."

DEFINE REPORT oReport NAME "PLSR955 " TITLE (cTitulo+" "+mv_par07) PARAMETER "PLSR955" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2)
oReport:SetLandscape()

DEFINE SECTION oSection1 OF oReport TABLES "TRB" TITLE OemToAnsi(STR0004)//"Regi�o x Municipio"
DEFINE CELL NAME "cReg"    OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0005) SIZE 5//"Regi�o"
DEFINE CELL NAME "cDesReg" OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0006)SIZE 40//"Desc.Regi�o" 
DEFINE CELL NAME "cMun"    OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0007) SIZE 5//"Municipio"
DEFINE CELL NAME "cDesMun" OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0008) SIZE 40//"Desc.Municipio "


DEFINE SECTION oSection2 OF oSection1 TABLES "TRB" TITLE OemToAnsi(STR0009)//"Detalhes"
DEFINE CELL NAME "cCid"    OF oSection2 ALIAS "TRB" TITLE OemToAnsi(STR0010) SIZE 8//"Cidade"
DEFINE CELL NAME "cDesCid" OF oSection2 ALIAS "TRB" TITLE OemToAnsi(STR0011) SIZE 40//"Desc.Cidade "
DEFINE CELL NAME "cCodEsp"    OF oSection2 ALIAS "TRB" TITLE OemToAnsi(STR0012)//"Especialidade"
DEFINE CELL NAME "cDesEsp" OF oSection2 ALIAS "TRB" TITLE OemToAnsi(STR0013) SIZE 30//"Desc.Especialidade "
DEFINE CELL NAME "cCodClas"   OF oSection2 ALIAS "TRB" TITLE OemToAnsi(STR0014)//"Classifica��o"
DEFINE CELL NAME "cDesCodClas" OF oSection2 ALIAS "TRB" TITLE OemToAnsi(STR0015) SIZE 20//"Desc.Classifica��o "
DEFINE CELL NAME "cMassa"   OF oSection2 ALIAS "TRB" TITLE OemToAnsi(STR0016)//"Massa usuarios"
DEFINE CELL NAME "cCoef"   OF oSection2 ALIAS "TRB" TITLE OemToAnsi(STR0017)//"Coeficiente"
DEFINE CELL NAME "cMedNec" OF oSection2 ALIAS "TRB" TITLE OemToAnsi(STR0018)//"Qtde.Medicos Necess�rio"
DEFINE CELL NAME "cMedAtu" OF oSection2 ALIAS "TRB" TITLE OemToAnsi(STR0019)//"Qtde.Medicos Atual"

Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � TOTVS            � Data � 30/07/15 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)       	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR955                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport( oReport)
Local oSection1      := oReport:Section(1)
Local oSection2      := oReport:Section(1):Section(1)
Local cInt     	    := PlsIntPad()
Local cAlias	       := "TRB"
Local cMunicipio     := ""
Local cRegiao        := ""

DbSelectArea("BID")
dbSetOrder(1)	

#IFDEF TOP
  MakeSqlExpr(oReport:uParam)
	
  If TcSrvType() <> "AS/400"		
	
	   oSection1:BeginQuery()
		
		cAlias := GetNextAlias()
		
		BeginSQL Alias cAlias
				
			SELECT B9S_CODMUN,B9S.B9S_CODREG, BIB.BIB_DESCRI, BIB.BIB_ESPMUN, BID.BID_DESCRI,B9S.B9S_ESPECI,BAQ.BAQ_DESCRI, B9S.B9S_MEDNEC, B9S.B9S_MEDATU, 
					BIC.BIC_CODMUN,BIC.BIC_TPCLA, B9A.B9A_TPCLAS, BIC.BIC_MASSUS , BIC.BIC_COEFNA
			
			FROM %table:B9S% B9S, %table:BIB% BIB ,%table:BIC% BIC , %table:BID% BID, %table:BAQ% BAQ, %table:B9A% B9A
							
			WHERE	B9S.B9S_FILIAL = %xFilial:B9S% and 	
					B9S.B9S_CODINT = %Exp:cInt% and
			       B9S.B9S_CODREG >= %Exp:mv_par01% And B9S.B9S_CODREG <= %Exp:mv_par02% and
			       BIB.BIB_ESPMUN >= %Exp:mv_par03% And BIB.BIB_ESPMUN <= %Exp:mv_par04% and
			       B9S.B9S_ESPECI >= %Exp:mv_par07% And B9S.B9S_ESPECI <= %Exp:mv_par08% and				    
				    B9S.B9S_CODMUN >= %Exp:mv_par05% And B9S.B9S_CODMUN <= %Exp:mv_par06% and
				    B9S.B9S_ANO = %Exp:mv_par11% and
				    B9S.B9S_FILIAL = BAQ.BAQ_FILIAL and
					B9S.B9S_CODINT = BAQ.BAQ_CODINT and
					B9S.B9S_ESPECI = BAQ.BAQ_CODESP and
 					B9S.B9S_FILIAL = BIB.BIB_FILIAL and
					B9S.B9S_CODINT =  BIB.BIB_CODINT  and
 					B9S.B9S_CODREG = BIB.BIB_CODREG and
 					BIB.BIB_FILIAL = BIC.BIC_FILIAL and
 					BIB.BIB_CODINT = BIC.BIC_CODINT and
 					BIB.BIB_CODREG = BIC.BIC_CODREG and 
 					B9S.B9S_CODMUN = BIC.BIC_CODMUN  and    
 					BIC.BIC_TPCLA >= %Exp:mv_par09% And BIC.BIC_TPCLA <= %Exp:mv_par10% and
					BIC.BIC_FILIAL = BID.BID_FILIAL and
					BIB.BIB_ESPMUN = BID_CODMUN and
					BIC.BIC_FILIAL = B9A.B9A_FILIAL and
					BIC.BIC_CODINT = B9A.B9A_CODINT and
					BIC.BIC_TPCLA = B9A.B9A_COD and
					B9S.%notDel% and
					BIB.%notDel% and
					BIC.%notDel% and
					BID.%notDel%  and
					BAQ.%notDel%  and
					B9A.%notDel% 
					
			ORDER BY B9S_CODREG, BIB_ESPMUN, BIC_CODMUN
				
	    EndSql
    
	    oSection1:EndQuery()
	    
	Endif 

#ENDIF  	

	While !oReport:Cancel() .And. (cAlias)->(!Eof())
    
		If (cRegiao <> (cAlias)->B9S_CODREG) 
			oSection1:SetPageBreak(.T.)  
			oSection1:Finish()
			oSection1:Init()
			oReport:SkipLine(1)
		
		    oSection1:Cell("cReg"):SetValue((cAlias)->B9S_CODREG)
		    oSection1:Cell("cDesReg"):SetValue((cAlias)->BIB_DESCRI)
		  	
		    oSection1:Cell("cMun"):SetValue((cAlias)->BIB_ESPMUN)
		    oSection1:Cell("cDesMun"):SetValue((cAlias)->BID_DESCRI)
		
			 oSection1:PrintLine()	
			
			
			 oSection2:Finish()
			 oSection2:Init()
			 oReport:SkipLine(1)
	
		Endif    
				   
		If (cMunicipio <> (cAlias)->BIB_ESPMUN)
			oReport:SkipLine(1)
		Endif
		
		
		oSection2:Cell("cCid"):SetValue((cAlias)->BIC_CODMUN)
		If BID->(MSSEEK(xFilial("BID")+(cAlias)->BIC_CODMUN))
			oSection2:Cell("cDesCid"):SetValue(BID->BID_DESCRI)
	    Endif
		  		  	
	   	oSection2:Cell("cCodEsp"):SetValue((cAlias)->B9S_ESPECI)
	  	oSection2:Cell("cDesEsp"):SetValue((cAlias)->BAQ_DESCRI)
		  
	  	oSection2:Cell("cCodClas"):SetValue((cAlias)->BIC_TPCLA)
	  	oSection2:Cell("cDesCodClas"):SetValue((cAlias)->B9A_TPCLAS)
				
	  	oSection2:Cell("cMassa"):SetValue((cAlias)->BIC_MASSUS)
	  	oSection2:Cell("cCoef"):SetValue((cAlias)->BIC_COEFNA)
	  	oSection2:Cell("cMedNec"):SetValue((cAlias)->B9S_MEDNEC)
	  	oSection2:Cell("cMedAtu"):SetValue((cAlias)->B9S_MEDATU)
		  	
		oSection2:PrintLine()
	  	
	  	cMunicipio := (cAlias)->BIB_ESPMUN
       cRegiao := (cAlias)->B9S_CODREG

		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(DbCloseArea())	
	oSection1:Finish()
	oSection2:Finish()
Return Nil


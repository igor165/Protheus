#INCLUDE "ORGR030.CH"
#INCLUDE "PROTHEUS.CH"      
#INCLUDE "REPORT.CH"

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa     � ORGR030  � Autor � Tania Bronzeri        � Data �28/11/2006���
����������������������������������������������������������������������������Ĵ��
���Descri��o    � Relacao de Movimentacao de Postos                          ���
����������������������������������������������������������������������������Ĵ��
���Uso          � SigaOrg - Arquitetura Organizacional                       ���
����������������������������������������������������������������������������Ĵ��
���Programador  � Data   � BOPS �  Motivo da Alteracao                       ���  
����������������������������������������������������������������������������Ĵ�� 
���Cecilia Carv.�07/08/14�TQEQKP�Incluido o fonte da 11 para a 12 e efetuada ���
���             �        �      �a limpeza.                                  ���
���Renan Borges �20/06/17�DRHPON�Ajuste para que Ao gerar um relat�rio de Mo-���
���             �        �TP-981�vimento de Posto definindo uma Filial espec����
���             �        �      �fica nos Par�metros e ap�s gerar o relat�rio���
���             �        �      �sejam apresentados somente os dados relacio-���
���             �        �      �nados a filial selecionada.                 ���
���Marcos Cout. �14/07/17�DRHPON�Realizado ajustes para que o departamento   ���
���             �        �TP-126�fosse impresso corretamente quando a ordem  ���
���             �        �6     �do relat�rio fosse igual a '1' ou '2'       ���
�����������������������������������������������������������������������������ٱ� 
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function ORGR030()
	Local oReport   
	Local aArea 		:= GetArea()
	Private cAliasQry	:= "RCL"
	
	//��������������������������������������������������������������Ŀ
	//� Verifica as perguntas selecionadas                           �
	//����������������������������������������������������������������
	pergunte("ORG30R",.F.) 
	oReport := ReportDef()
	oReport:PrintDialog()
	RestArea(aArea)
Return


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Tania Bronzeri        � Data �28/11/2006���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Cadastro de Movimentos de Postos                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ORGR030                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � ORGR030 - Generico                                           ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ReportDef()
Local oReport 
Local oSection1 
Local oSection2
Local oSection3
Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0002)
	//"Cadastro de Movimentos de Postos" ### "Ser� impresso de acordo com os parametros solicitados pelo usu�rio."
Private aOrd    := {OemToAnsi(STR0003),OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006)}	
					//"Posto / Movimento" ### "Posto / Data Movimento" ### "Departamento" ### "Centro de Custo"
Private cTitulo	:= OemToAnsi(STR0001)	//"Cadastro de Movimentos de Postos"

//������������������������������������������������������������������������Ŀ
//�Criacao dos componentes de impressao                                    �
//��������������������������������������������������������������������������
DEFINE REPORT oReport NAME "ORGR030" TITLE cTitulo PARAMETER "ORG30R" ACTION {|oReport| ORG30Imp(oReport)} DESCRIPTION OemtoAnsi(STR0007)	//"Este relatorio emite relacao das Movimentacoes de Postos."

	DEFINE SECTION oSection1 OF oReport TITLE OemToAnsi(STR0008) TABLES "RCL", "SQB", "CTT" ORDERS aOrd	//"Depto / C.Custo"

		DEFINE CELL NAME "RCL_FILIAL"  	OF oSection1 ALIAS "RCL" TITLE OemToAnsi(STR0034) + " "	//Filial:
		DEFINE CELL NAME "RCL_DEPTO"  	OF oSection1 ALIAS "RCL" TITLE OemToAnsi(STR0031) + " "	//Departamento:
		DEFINE CELL NAME "QB_DESCRIC" 	OF oSection1 ALIAS "SQB" TITLE " - "
		DEFINE CELL NAME "RCL_CC"     	OF oSection1 ALIAS "RCL" TITLE OemToAnsi(STR0032) + " "	//Centro de Custo:
		DEFINE CELL NAME "CTT_DESC01"  	OF oSection1 ALIAS "CTT" TITLE " - "
		
		TRPosition():New(oSection1,"SQB", 1, {|| RhFilial("SQB",(cAliasQry)->RCL_FILIAL)+(cAliasQry)->RCL_DEPTO})
		TRPosition():New(oSection1,"CTT", 1, {|| RhFilial("CTT",(cAliasQry)->RCL_FILIAL)+(cAliasQry)->RCL_CC})

		oSection1:SetHeaderBreak(.T.)                                                                         
		oSection1:SetLineStyle()                                                                              
		oSection1:SetCharSeparator(Space(1))
		//oSection1:SetColSpace(6)		
//		Cell("RCL_FILIAL"):
		//oSection1:Cell("RCL_FILIAL"):Disable()


	DEFINE SECTION oSection2 OF oSection1 TITLE OemToAnsi(STR0009) TABLES  "RCL", "SRJ", "SQ3" ORDERS aOrd	//"Postos"
		
		DEFINE CELL NAME "RCL_POSTO"	OF oSection2 ALIAS "RCL"// TITLE OemToAnsi(STR0025) SIZE 10	//Posto
		DEFINE CELL NAME "RCL_FUNCAO"	OF oSection2 ALIAS "RCL"// TITLE OemToAnsi(STR0026) SIZE 10	//Funcao
		DEFINE CELL NAME "RJ_DESC"		OF oSection2 ALIAS "SRJ"
		DEFINE CELL NAME "RCL_CARGO"	OF oSection2 ALIAS "RCL"// TITLE OemToAnsi(STR0027) SIZE 10	//Cargo
		DEFINE CELL NAME "Q3_DESCSUM"	OF oSection2 ALIAS "SQ3"
		DEFINE CELL NAME "RCL_SALAR"	OF oSection2 ALIAS "RCL"
		DEFINE CELL NAME "RCL_BENEF"	OF oSection2 ALIAS "RCL"
		DEFINE CELL NAME "RCL_ENCARG"	OF oSection2 ALIAS "RCL"
		//DEFINE CELL NAME "RBU_FILOCU"	OF oSection2 ALIAS "RBU" TITLE OemToAnsi(STR0028)			//Fl.Oc.
		//DEFINE CELL NAME "RBU_CODOCU"	OF oSection2 ALIAS "RBU" TITLE OemToAnsi(STR0029)			//Cod.Ocup.
		/*DEFINE CELL NAME "NOMEOCU"		OF oSection2 TITLE OemToAnsi(STR0010) SIZE 40; 				//Nome Ocupante
			BLOCK{|| fPesqOcu("RD0",(cAliasQry)->RBU_FILOCU,(cAliasQry)->RBU_CODOCU) }
			
		DEFINE CELL NAME "NOMEOCU"		OF oSection2 TITLE OemToAnsi(STR0010) SIZE 40 ;				//Nome Ocupante
			BLOCK{||Iif((cAliasQry)->RBU_TIPOCU=="1",;
					fPesqOcu("SRA",(cAliasQry)->RBU_FILOCU,(cAliasQry)->RBU_CODOCU),;
					fPesqOcu("RD0",(cAliasQry)->RBU_FILOCU,(cAliasQry)->RBU_CODOCU))}*/
		DEFINE CELL NAME "RCL_STATUS" OF oSection2 ALIAS "RBU" TITLE OemToAnsi(STR0030) SIZE 18	//Status


		TRPosition():New(oSection2,"SRJ",1,{|| RhFilial("SRJ",(cAliasQry)->RCL_FILIAL)+(cAliasQry)->RCL_FUNCAO})
		TRPosition():New(oSection2,"SQ3",1,{|| RhFilial("SQ3",(cAliasQry)->RCL_FILIAL)+(cAliasQry)->RCL_CARGO})
                              
		oSection2:SetLeftMargin(5)

	DEFINE SECTION oSection3 OF oSection2 TITLE OemToAnsi(STR0011) TABLES "RBU" ORDERS aOrd	//"Movimentos"
		
		DEFINE CELL NAME "RBU_CODMOV"	OF oSection3 ALIAS "RBU"
		DEFINE CELL NAME "RBU_DTAMOV"	OF oSection3 ALIAS "RBU"
		DEFINE CELL NAME "RBU_OPERAC"	OF oSection3 ALIAS "RBU"
		DEFINE CELL NAME "RBU_DTINI"	OF oSection3 ALIAS "RBU"
		DEFINE CELL NAME "RBU_DTFIM"	OF oSection3 ALIAS "RBU"
		DEFINE CELL NAME "RBU_RESPON"	OF oSection3 ALIAS "RBU"

		TRPosition():New(oSection3, "RBU", 1, {|| RhFilial("RBU",(cAliasQry)->RCL_FILIAL)+(cAliasQry)->RCL_POSTO})

		oSection3:SetLeftMargin(10) 

	oReport:SetColSpace(4)

Return(oReport)


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ORG30Imp   � Autor � Tania Bronzeri        � Data �29/11/2006���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Movimentos de Postos                            ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ORG30Imp(oReport)
Local oSection1 := oReport:Section(1)				//Depto / C.Custo
Local oSection2 := oReport:Section(1):Section(1)  	//Postos
Local oSection3	:= oReport:Section(1):Section(1):Section(1)	//Movimentos
Local cFiltro 	:= "" 
Local cTitCC	:= ""
Local cTitDep	:= ""
//Local cTitFil	:= ""
Local cTipoMov	:= ""
Local cIndAnt	:= ""
Local cPostoAnt	:= Space(06)
Local lTotliz 	:= .T.	
Local lQuebra	:= .T. 
Local lPvz		:= .T.
Local lPmv		:= .T.
Local nReg		:= 0
Local cAliasRpt

Private cOrdem	:= ""
Private nOrdem	:= oSection1:GetOrder()
Private cMovs	:= 	mv_par06			//Tipos de Movimentos a Imprimir

lTotliz := Iif(mv_par07==1,.T.,.F.) 	//  Totaliza Sim / Nao
lQuebra	:= Iif(mv_par08==1,.T.,.F.) 	//  Quebra Pagina Sim / Nao  

If lTotliz
	If nOrdem == 4
		//-- Totalizar por Centro de Custo
		DEFINE BREAK oBreakCc OF oSection1  WHEN oSection1:Cell("RCL_CC") TITLE OemToAnsi(STR0017)	// "Total Centro de Custo"
		DEFINE FUNCTION oCcPostos     NAME "CCPOSTOS"     FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakCc TITLE OemToAnsi(STR0018) PICTURE "9999"		NO END SECTION NO END REPORT									//"Numero de Postos"
		DEFINE FUNCTION oCcVagos      NAME "CCVAGOS"      FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakCc TITLE OemToAnsi(STR0020) PICTURE "9999"		NO END SECTION NO END REPORT WHEN {||(cAliasRpt)->RCL_STATUS == "1"}	//"Vagos"
		DEFINE FUNCTION oCcOcupados   NAME "CCOCUPADOS"   FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakCc TITLE OemToAnsi(STR0019) PICTURE "9999"		NO END SECTION NO END REPORT WHEN {||(cAliasRpt)->RCL_STATUS == "2"}	//"Ocupados"
		DEFINE FUNCTION oCcCongelados NAME "CCCONGELADOS" FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakCc TITLE OemToAnsi(STR0022) PICTURE "9999"		NO END SECTION NO END REPORT WHEN {||(cAliasRpt)->RCL_STATUS == "3"}	//"Congelados"
		DEFINE FUNCTION oCcCancelados NAME "CCCANCELADOS" FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakCc TITLE OemToAnsi(STR0021) PICTURE "9999"		NO END SECTION NO END REPORT WHEN {||(cAliasRpt)->RCL_STATUS == "4"}	//"Cancelados"		
		oBreakCc:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0017)+x})	//"Total Centro de Custo"
    	oBreakCc:SetTotalText({||cTitCC})
		oCcPostos:SetTitle(OemToAnsi(STR0018))
		oCcOcupados:SetTitle(OemToAnsi(STR0019))
		oCcVagos:SetTitle(OemToAnsi(STR0020))
		oCcCancelados:SetTitle(OemToAnsi(STR0021))
		oCcCongelados:SetTitle(OemToAnsi(STR0022))
		oCcPostos:ShowHeader()                  
		oCcOcupados:ShowHeader()
		oCcVagos:ShowHeader()
		oCcCancelados:ShowHeader()
		oCcCongelados:ShowHeader()
		If lQuebra
			oBreakCC:SetPageBreak()
		EndIf
		oBreakCc:OnPrintTotal({||oReport:ThinLine()})
	ElseIf nOrdem == 3
		//-- Totalizar por Departamento
		DEFINE BREAK oBreakDep OF oSection1  WHEN oSection1:Cell("RCL_DEPTO") TITLE OemToAnsi(STR0023)	// "Total Departamento"
		DEFINE FUNCTION oDepPostos     NAME "DEPPOSTOS"     FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakDep TITLE OemToAnsi(STR0018) PICTURE "9999"	NO END SECTION NO END REPORT 									//"Numero de Postos"
		DEFINE FUNCTION oDepVagos      NAME "DEPVAGOS"      FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakDep TITLE OemToAnsi(STR0020) PICTURE "9999"	NO END SECTION NO END REPORT WHEN {||(cAliasRpt)->RCL_STATUS == "1"}	//"Vagos"
		DEFINE FUNCTION oDepOcupados   NAME "DEPOCUPADOS"   FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakDep TITLE OemToAnsi(STR0019) PICTURE "9999"	NO END SECTION NO END REPORT WHEN {||(cAliasRpt)->RCL_STATUS == "2"}	//"Ocupados"
		DEFINE FUNCTION oDepCongelados NAME "DEPCONGELADOS" FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakDep TITLE OemToAnsi(STR0022) PICTURE "9999"	NO END SECTION NO END REPORT WHEN {||(cAliasRpt)->RCL_STATUS == "3"}	//"Congelados"
		DEFINE FUNCTION oDepCancelados NAME "DEPCANCELADOS" FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakDep TITLE OemToAnsi(STR0021) PICTURE "9999"	NO END SECTION NO END REPORT WHEN {||(cAliasRpt)->RCL_STATUS == "4"}	//"Cancelados"
		oBreakDep:OnBreak({|x,y|cTitDep:=OemToAnsi(STR0023)+x})	//"Total Departamento"
    	oBreakDep:SetTotalText({||cTitDep})
		oDepPostos:SetTitle(OemToAnsi(STR0018))
		oDepOcupados:SetTitle(OemToAnsi(STR0019))
		oDepVagos:SetTitle(OemToAnsi(STR0020))
		oDepCancelados:SetTitle(OemToAnsi(STR0021))
		oDepCongelados:SetTitle(OemToAnsi(STR0022))
		oDepPostos:ShowHeader()                  
		oDepOcupados:ShowHeader()
		oDepVagos:ShowHeader()
		oDepCancelados:ShowHeader()
		oDepCongelados:ShowHeader()
		If lQuebra
			oBreakDep:SetPageBreak()
		EndIf
		oBreakDep:OnPrintTotal({||oReport:ThinLine()})
	EndIf
EndIf

DEFINE FUNCTION oFilPostos     NAME "FILPOSTOS"     FROM oSection2:Cell("RCL_POSTO") FUNCTION COUNT TITLE OemToAnsi(STR0018) PICTURE "9999"	NO END SECTION									//"Numero de Postos"
DEFINE FUNCTION oFilVagos      NAME "FILVAGOS"      FROM oSection2:Cell("RCL_POSTO") FUNCTION COUNT TITLE OemToAnsi(STR0020) PICTURE "9999"	NO END SECTION WHEN {|| (cAliasRpt)->RCL_STATUS == "1"}	//"Vagos"
DEFINE FUNCTION oFilOcupados   NAME "FILOCUPADOS"   FROM oSection2:Cell("RCL_POSTO") FUNCTION COUNT TITLE OemToAnsi(STR0019) PICTURE "9999"	NO END SECTION WHEN {|| (cAliasRpt)->RCL_STATUS == "2"}	//"Ocupados"
DEFINE FUNCTION oFilCongelados NAME "FILCONGELADOS" FROM oSection2:Cell("RCL_POSTO") FUNCTION COUNT TITLE OemToAnsi(STR0022) PICTURE "9999"	NO END SECTION WHEN {|| (cAliasRpt)->RCL_STATUS == "3"}	//"Congelados"
DEFINE FUNCTION oFilCancelados NAME "FILCANCELADOS" FROM oSection2:Cell("RCL_POSTO") FUNCTION COUNT TITLE OemToAnsi(STR0021) PICTURE "9999"	NO END SECTION WHEN {|| (cAliasRpt)->RCL_STATUS == "4"}	//"Cancelados"

oFilPostos:SetCharSeparator("")
oFilOcupados:SetCharSeparator("")
oFilVagos:SetCharSeparator("")
oFilCancelados:SetCharSeparator("")
oFilCongelados:SetCharSeparator("")

If nOrdem == 3
	oSection1:Cell("RCL_CC"):Disable()
	oSection1:Cell("CTT_DESC01"):Disable()
ElseIf nOrdem == 4
	oSection1:Cell("RCL_DEPTO"):Disable()
	oSection1:Cell("QB_DESCRIC"):Disable()
EndIf


cAliasQry := GetNextAlias()
cAliasRpt := cAliasQry

//-- Modifica variaveis para a Query 
cTipoMov := ""
For nReg:=1 to Len(cMovs)
	cTipoMov += "'"+Subs(cMovs,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cMovs)
		cTipoMov += "," 
	Endif
Next nReg        
cTipoMov := "%" + cTipoMov + "%"

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr("ORG30R")
	
BEGIN REPORT QUERY oSection1

If nOrdem == 1
	cOrdem  := "%RBU.RBU_FILIAL,RBU.RBU_POSTO,RBU.RBU_CODMOV%"
ElseIf nOrdem == 2
	cOrdem  := "%RBU.RBU_FILIAL,RBU.RBU_POSTO,RBU.RBU_DTAMOV%"
ElseIf nOrdem == 3
	cOrdem  := "%RBU.RBU_FILIAL,RBU.RBU_DEPTO,RBU.RBU_POSTO%"
Else
	cOrdem  := "%RBU.RBU_FILIAL,RBU.RBU_CC,RBU.RBU_POSTO%"
EndIf
	
BEGINSQL ALIAS cAliasQry
	SELECT
		RCL.RCL_FILIAL, 
		RCL.RCL_POSTO, 
		RCL.RCL_STATUS, 
		RCL.RCL_DEPTO, 
		RCL.RCL_CC, 
		RCL.RCL_FUNCAO, 
		RCL.RCL_CARGO, 
		RCL.RCL_SALAR, 
		RCL.RCL_BENEF, 
		RCL.RCL_ENCARG, 
		RBU.RBU_CODMOV,
		RBU.RBU_OPERAC,
		RBU.RBU_DTAMOV,
		RBU.RBU_DTINI,
		RBU.RBU_DTFIM,
		RBU.RBU_RESPON,                
		RBU.RBU_CODOCU, 
		RBU.RBU_FILOCU
	FROM 
		%table:RCL% RCL
	INNER JOIN %table:RBU% RBU ON
		RBU.RBU_OPERAC IN (%exp:Upper(cTipoMov)%) AND
		RBU.RBU_FILIAL = RCL.RCL_FILIAL AND
		RBU.RBU_POSTO = RCL.RCL_POSTO AND
		RBU.%notDel%
	WHERE
		RCL.%notDel%  
	ORDER BY 
		%exp:cOrdem%
ENDSQL

/*
Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
pela funcao MakeSqlExpr para serem adicionados a query
*/
END REPORT QUERY oSection1 PARAM mv_par01, mv_par02, mv_par03, mv_par04, mv_par05     

oSection2:SetParentQuery()
oSection3:SetParentQuery()

//�������������������������������������������Ŀ
//� Inicio da impressao do fluxo do relat�rio �
//���������������������������������������������
oReport:SetMeter( (cAliasQry)->(LastRec()) )  

(cAliasQry)->( dbGoTop() )

//-- Incializa impressao   
oSection1:Init()                              
oSection2:Init()
oSection3:Init()
	
While !(cAliasQry)->( EOF() ) 
	//��������������������������������������������������������������Ŀ
	//� Movimenta Regua de Processamento                             �
	//����������������������������������������������������������������
	oReport:IncMeter( 1 )   

	If nOrdem == 3
		If cIndAnt <> (cAliasQry)->RCL_DEPTO
			If !lPvz
				oSection1:Finish()
				oSection1:Init()
			EndIf
			oSection1:PrintLine()        
			lPvz	:= .F.
		EndIf
	ElseIf nOrdem == 4
		If cIndAnt <> (cAliasQry)->RCL_CC
			If !lPvz
				oSection1:Finish()
				oSection1:Init()
			EndIf
			oSection1:PrintLine()
			lPvz	:= .F.
		EndIf
	Else
		If cIndAnt <> (cAliasQry)->RCL_FILIAL
			If !lPvz
				oSection1:Finish()
				oSection1:Init()
			EndIf
			oSection1:PrintLine()
			lPvz	:= .F.
		Else
			oSection1:PrintLine()
		EndIf
	EndIf	
	If cPostoAnt <> (cAliasQry)->RCL_POSTO
		oSection2:PrintLine()
		oSection2:Finish()
		oSection2:Init() 
		lPmv	:= .F.
	EndIf
	
	If !lPmv
		oSection3:Finish()
		oSection3:Init()
	EndIf               
	lPmv	:= .T.
	oSection3:PrintLine()
	
	cPostoAnt	:= (cAliasQry)->RCL_POSTO
	If nOrdem == 3
		cIndAnt :=	(cAliasQry)->RCL_DEPTO
	ElseIf nOrdem == 4
		cIndAnt :=	(cAliasQry)->RCL_CC
	Else
		cIndAnt :=	(cAliasQry)->RCL_FILIAL
	EndIf			

	(cAliasQry)->( dbSkip() )
	Loop
	
EndDo

oSection3:Finish()
oSection2:Finish()
oSection1:Finish()

Return                          

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � fPesqOcu � Autor � Tania Bronzeri        � Data � 27/11/2016 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pesquisa o nome do Ocupante do Posto                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fPesqOcu(cTabOcu, cFilOcu, cCodOcu                           ���
���������������������������������������������������������������������������Ĵ��
���Par�metros� cTabOcu => Tabela do Ocupante SRA=Funcionariso/RD0=Pessoas   ���
���			 � cFilOcu => Filial do Ocupante                                ���
���			 � cCodOcu => Codigo do Ocupante ou Matricula do Funcionario    ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAORG  	 	 	 	 	 	 	 	 	 	 	 	    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
Static Function fPesqOcu(cTabOcu, cFilOcu, cCodOcu)
	Local aArea := GetArea()
	Local cNome	:= ""
	
	DbSelectArea(cTabOcu)  
	If dbSeek((cTabOcu)->(cFilOcu + cCodOcu))
		If cTabOcu == "SRA"
			cNome := (cTabOcu)->RA_NOME
		Else
			cNome := (cTabOcu)->RD0_NOME
		EndIf                                         
	EndIf
		
	RestArea( aArea )	
Return cNome
*/

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fOrg30Mov �Autor  �Tania Bronzeri      � Data � 29/11/2006  ���
�������������������������������������������������������������������������͹��
���Desc.     �Seleciona Tipos de Movimentacao de Postos para impress�o.   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SIGAORG                                             	      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fOrg30Mov()
	
	Local cTitulo	:=	""
	Local MvParDef	:=	""
	Local l1Elem 	:= .F. 
	Local MvPar		:= ""
	Local oWnd
	Local cTipoAu
	Private aResul	:={}
	
	oWnd := GetWndDefault()
	MvPar	:=	&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet	:=	Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	
	cTitulo := STR0012 //"Imprimir Tipos de Movimentacao"
	//aResul  := {STR0013,STR0014,STR0015,STR0016} //"Atualizacao" ### "Ocupacao" ### "Cancelamento" ### "Congelamento"
	aResul  := {STR0033, STR0013, STR0014, STR0016, STR0015} //"Cria��o" ### "Atualizacao" ### "Ocupacao" ### "Congelamento" ### "Cancelamento"
	 
	MvParDef	:=	"12345"
	
	f_Opcoes(@MvPar, cTitulo, aResul, MvParDef, 12, 49, l1Elem, , 5)		// Chama funcao f_Opcoes
	&MvRet := mvpar 					   	// Devolve Resultado
Return

            


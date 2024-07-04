#INCLUDE "Protheus.ch"
#INCLUDE "CSAR060.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CSAR060  � Autor � Eduardo Ju            � Data � 11.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Relatorio de Quadro de Vagas de uma empresa.               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSAR060(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.          ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�30/07/14�TPZVV4�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/ 
Function CSAR060()

Local oReport
Local aArea := GetArea()

Private cAliasQry := "RBD"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
 
Pergunte("CSR60R",.F.)
oReport := ReportDef()
oReport:PrintDialog()	              
RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 11.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Definicao do Componente de Impressao do Relatorio           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local oSection1	
Local oSection2
Local oSection3	
Local oSection4
Local aOrd	  := {STR0004}  		//"Centro de Custo"

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport:=TReport():New("CSAR060",STR0008,"CSR60R",{|oReport| PrintReport(oReport)},STR0022)	// "Quadro de Funcionarios"#"Ser� impresso de acordo com os parametros solicitados pelo usuario"
Pergunte("CSR60R",.F.)
 
//******************* Relatorio Analitico **********************
//������������������������������������������������������������Ŀ
//� Criacao da Primeira Secao: "Quadro Funcionario Por Fun��o" �
//�������������������������������������������������������������� 
oSection1 := TRSection():New(oReport,STR0015,{"RBD"},aOrd,/*Campos do SX3*/,/*Campos do SIX*/)	//Quadro Funcionario Por Fun��o
oSection1:SetHeaderBreak(.T.)   

TRCell():New(oSection1,"RBD_FILIAL","RBD")					//Filial 
TRCell():New(oSection1,"RBD_CC","RBD")						//Centro de Custo
TRCell():New(oSection1,"CTT_DESC01","CTT","")				//Descricao do Centro de Custo
TRCell():New(oSection1,"RBD_ANOMES","RBD")					//Ano/Mes

//����������������������������������������������Ŀ
//� Criacao da Segunda Secao: Aumento Programado �
//������������������������������������������������
oSection2 := TRSection():New(oSection1,STR0023,{"RBD"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//Aumento Programado
oSection2:SetTotalInLine(.F.)  
oSection2:SetHeaderBreak(.T.)
oSection2:SetLeftMargin(3)	//Identacao da Secao

TRCell():New(oSection2,"RBD_FUNCAO","RBD")					//Funcao
TRCell():New(oSection2,"RJ_DESC","SRJ","")					//Descricao da Funcao
TRCell():New(oSection2,"RBD_VLATUA","RBD")					//Valor do Salario Atual
TRCell():New(oSection2,"RBD_VLPREV","RBD")					//Valor do Salario Previsto
TRCell():New(oSection2,"ATUAENCARG","   ",STR0016,TM(99999999,12,MsDecimais(1)),,,{|| If(mv_par04 <= 0,(cAliasQry)->RBD_VLATUA,(cAliasQry)->RBD_VLATUA * (1+ (mv_par04 /100)) ) })	//Valor do Salario Atual + Encargos
TRCell():New(oSection2,"PREVENCARG","   ",STR0017,TM(99999999,12,MsDecimais(1)),,,{|| If(mv_par04 <= 0,(cAliasQry)->RBD_VLPREV,(cAliasQry)->RBD_VLPREV * (1+ (mv_par04 /100)) ) })//Valor do Salario Previsto + Encargos
TRCell():New(oSection2,"RBD_VLAPRO","RBD")					//Valor Aprovado
TRCell():New(oSection2,"RBD_QTATUA","RBD")					//Nr. Funcionario Atual
TRCell():New(oSection2,"RBD_QTPREV","RBD")					//Nr. Funcionario Previsto
TRCell():New(oSection2,"RBD_QTAPRO","RBD")					//Nr. Funcionario Aprovado

oSection2:SetTotalText({|| STR0018 + oSection1:Cell("RBD_ANOMES"):GetValue(.T.)})  

TRFunction():New(oSection2:Cell("RBD_VLATUA"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection2:Cell("RBD_VLPREV"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection2:Cell("ATUAENCARG"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection2:Cell("PREVENCARG"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection2:Cell("RBD_VLAPRO"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection2:Cell("RBD_QTATUA"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection2:Cell("RBD_QTPREV"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection2:Cell("RBD_QTAPRO"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

//********************** Relatorio Sintetico ************************
//�����������������������������������������������������������������Ŀ
//� Criacao da Primeira Secao: "Cadastro de Quadro de Funcionarios" �
//������������������������������������������������������������������� 
oSection3 := TRSection():New(oReport,STR0019,{"RB8"},/*aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)	//"Cadastro de Quadro de Funcionarios"	
oSection3:SetTotalInLine(.T.)  
oSection3:SetHeaderBreak(.T.)   

TRCell():New(oSection3,"RB8_FILIAL","RB8")					//Filial 
TRCell():New(oSection3,"RB8_CC","RB8")						//Centro de Custo
TRCell():New(oSection3,"CTT_DESC01","CTT","")					//Descricao do Centro de Custo

//����������������������������������������������Ŀ
//� Criacao da Segunda Secao: Aumento Programado �
//������������������������������������������������
oSection4 := TRSection():New(oSection3,STR0024,{"RB8"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//Aumento Programado
oSection4:SetHeaderBreak(.T.)
oSection4:SetLeftMargin(3)	//Identacao da Secao

TRCell():New(oSection4,"RB8_ANOMES","RB8")					//Ano/Mes
TRCell():New(oSection4,"RB8_VLATUA","RB8")					//Valor do Salario Atual
TRCell():New(oSection4,"RB8_VLPREV","RB8")					//Valor do Salario Previsto
TRCell():New(oSection4,"RB8_VLATUA","RB8",STR0016,,,,{|| If(mv_par04 <= 0,(cAliasQry)->RB8_VLATUA,(cAliasQry)->RB8_VLATUA * (1+ (mv_par04 /100)) ) })	//Valor do Salario Atual + Encargos
TRCell():New(oSection4,"RB8_VLPREV","RB8",STR0017,,,,{|| If(mv_par04 <= 0,(cAliasQry)->RB8_VLPREV,(cAliasQry)->RB8_VLPREV * (1+ (mv_par04 /100)) ) })	//Valor do Salario Previsto + Encargos
TRCell():New(oSection4,"RB8_NRATUA","RB8",STR0020)			//Nr. Funcionario Atual
TRCell():New(oSection4,"RB8_NRPREV","RB8",STR0021)			//Nr. Funcionario Previsto

Return oReport 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 11.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do Relatorio                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PrintReport(oReport)

Local oSection1 := If ( mv_par05 = 1,oReport:Section(1),oReport:Section(2) )	//Analitico#Sintetico
Local oSection2 := oSection1:Section(1)
Local lAcesso	:=	.F. // Tabela compartilhada ou Exclusiva
Local lGeraString	:=	.T.
Local nIni	:= 0
Local nAnd	:= 0
Local nFim	:= 0
Local cPar01	:=	""
Local nTamFil	:=	0
Local nTamPar	:= 0	
Local lQuery    := .F. 
Local cOrder	:= "" 
Local cSitQuery	:= ""

//�������������������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                                          �
//� mv_par01        //  Filial?                                                   �
//� mv_par02        //  Centro de Custo ?                                         �
//� mv_par03        //  Ano/Mes?                                                  �
//� mv_par04        // % Encargos?                                                �
//� mv_par05        //  Imprimir: 1-Analitico; 2-Sintetico?                       �
//��������������������������������������������������������������������������������� 

If mv_par05 == 1  
	cAliasQry := "RBD"
Else
	cAliasQry := "RB8"
Endif	

lAcesso	:=	FWModeAccess(cAliasQry)	== "C" // Verifica se a tabela eh compartilhada.

If ( lAcesso )
	nTamFil	:=	LEN(ALLTRIM(xFilial(cAliasQry)))
	nTamPar	:=	LEN(MV_PAR01)
	cPar01	:= 	""
	nIni	:= 0
	nFim	:= 0
	
	Do While ( lGeraString )
		nFim := IIf( Empty(nFim),1,nFim )
		nIni := nFim

		If ( (EMPTY(SUBSTR(MV_PAR01 , nFim , 1))) .OR. (nFim > nTamPar ) )
			lGeraString	:=	.F.
		Else
			nAnd	:= 0
			Do While ( (!SUBSTR(MV_PAR01 , nFim++ , 1) == ";") .AND. (nFim <= nTamPar ) )
				If ( SUBSTR(MV_PAR01 , nFim , 1) == "-")
					nAnd	:= nFim // Guarda a posicao do separador "E" da Query.
				EndIf
			EndDo
			
			If ( nAnd == 0 )
				cPar01	+=	SUBSTR( MV_PAR01 , ++nIni , nTamFil ) + ";"
			Else
				cPar01	+=	SUBSTR( MV_PAR01 , ++nIni , nTamFil ) + SUBSTR( MV_PAR01 , nAnd , nTamFil + 1 ) + ";"	
			EndIf
		EndIf
	EndDo
			
	MV_PAR01	:=	cPar01
EndIf
//����������������������������������������������Ŀ
//� Transforma parametros Range em expressao SQL �
//������������������������������������������������
MakeSqlExpr("CSR60R")    
 
cAliasQry := GetNextAlias()
//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
lQuery := .T.         
	                                           
//oReport:Section(1):BeginQuery()	
Begin Report Query oSection1

 	If mv_par05 == 1	//Analitico
 	
 		cOrder := "%RBD_FILIAL,RBD_CC%" 

	BeginSql Alias cAliasQry	
		SELECT RBD_FILIAL,RBD_CC,CTT_DESC01,RBD_ANOMES,RBD_FUNCAO,RJ_DESC,RBD_VLATUA,RBD_VLPREV,RBD_VLAPRO,RBD_QTATUA,RBD_QTPREV,RBD_QTAPRO
		FROM 	%table:RBD% RBD 
		LEFT JOIN %table:CTT% CTT
			ON CTT_FILIAL = %xFilial:CTT%
			AND CTT_CUSTO = RBD_CC
			AND CTT.%NotDel%
		LEFT JOIN %table:SRJ% SRJ
			ON RJ_FILIAL = %xFilial:SRJ%
			AND RJ_FUNCAO = RBD_FUNCAO
			AND SRJ.%NotDel%				
		WHERE RBD_FILIAL = %xFilial:RBD% AND
			RBD.%NotDel%   													
		ORDER BY %Exp:cOrder%                 				
	EndSql

Else

	cOrder := "%RB8_FILIAL,RB8_CC%" 

	BeginSql Alias cAliasQry	
		SELECT RB8_FILIAL,RB8_CC,CTT_DESC01,RB8_ANOMES,RB8_VLATUA,RB8_VLPREV,RB8_NRATUA,RB8_NRPREV
		FROM 	%table:RB8% RB8 
		LEFT JOIN %table:CTT% CTT
			ON CTT_FILIAL = %xFilial:CTT%
			AND CTT_CUSTO = RB8_CC
			AND CTT.%NotDel%
		WHERE RB8_FILIAL = %xFilial:RB8% AND
			RB8.%NotDel%   													
		ORDER BY %Exp:cOrder%                 				
	EndSql

EndIf

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�ExpA1 : Array com os parametros do tipo Range                           �
//��������������������������������������������������������������������������
//	oReport:Section(1):EndQuery({mv_par01,mv_par02})	/*Array com os parametros do tipo Range*/
END REPORT QUERY oSection1 PARAM mv_par01, mv_par02, mv_par03		
//�������������������������Ŀ
//� Utiliza a query do Pai  �
//���������������������������
oSection2:SetParentQuery()                                

//�������������������������������������������Ŀ
//� Inicio da impressao do fluxo do relat�rio �
//���������������������������������������������     
If mv_par05 == 1	//Analitico
	oSection2:SetParentFilter({|cParam| (cAliasQry)->RBD_FILIAL+(cAliasQry)->RBD_CC + (cAliasQry)->RBD_ANOMES == cParam},{|| (cAliasQry)->RBD_FILIAL+(cAliasQry)->RBD_CC + (cAliasQry)->RBD_ANOMES})
  		oReport:SetMeter((cAliasQry)->(LastRec()))
  	Else	//Sintetico
  	oSection2:SetParentFilter({|cParam| (cAliasQry)->RB8_CC == cParam},{|| (cAliasQry)->RB8_CC})
  		oReport:SetMeter((cAliasQry)->(LastRec()))	
EndIf

oSection1:Print()	 //Imprimir

Return Nil      

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Cs60rFilial � Autor � Eduardo Ju          � Data � 14/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Conteudo do X1_CNT01 do parametro mv_par01 *X1_GRUPO CSR60R ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CSAR060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function Cs60rFilial()

Local cSvAlias 	:= Alias()
Local cX1_CNT01 := ''

If mv_par05 == 1
	cX1_CNT01 := 'RBD_FILIAL'
Else 
	cX1_CNT01 := 'RB8_FILIAL'
EndIf	

DbSelectArea(cSvAlias)

Return cX1_CNT01

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Cs60rcc     � Autor � Eduardo Ju          � Data � 14/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Conteudo do X1_CNT01 do parametro mv_par02 *X1_GRUPO CSR60R ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CSAR060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function Cs60rcc()

Local cSvAlias 	:= Alias()
Local cX1_CNT01 := ''

If mv_par05 == 1
	cX1_CNT01 := 'RBD_CC'
Else 
	cX1_CNT01 := 'RB8_CC'
EndIf	

DbSelectArea(cSvAlias)

Return cX1_CNT01         

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Cs60ranomes � Autor � Eduardo Ju          � Data � 14/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Conteudo do X1_CNT01 do parametro mv_par01 *X1_GRUPO CSR60R ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CSAR060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function Cs60ranomes()

Local cSvAlias 	:= Alias()
Local cX1_CNT01 := ''

If mv_par05 == 1
	cX1_CNT01 := 'RBD_ANOMES'
Else 
	cX1_CNT01 := 'RB8_ANOMES'
EndIf	

DbSelectArea(cSvAlias)

Return cX1_CNT01   

#include "Protheus.ch"
#include "APDR050.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � APDR050  � Autor � Eduardo Ju            � Data � 27/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Relatorio de Pendencia de Avaliacoes                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APDR050(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � FNC  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�04/07/14�TPZWHD�Incluido o fonte da 11 para a 12 e efetua ���
���            �        �      �ada limpeza.                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function APDR050()

Local oReport
Local aArea := GetArea()

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("APD50R",.F.)
oReport := ReportDef()
oReport:PrintDialog()	
RestArea( aArea )

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 27.07.06 ���
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
Local cAliasQry := GetNextAlias()

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport:=TReport():New("APDR050",STR0001,"APD50R",{|oReport| PrintReport(oReport,cAliasQry)},STR0002+" "+STR0003)	//"Relatorio de Status de Avaliacoes"#"Ser� impresso de acordo com os parametros solicitados pelo usuario"
oReport:SetTotalInLine(.F.) 
Pergunte("APD50R",.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//��������������������������������������������������������������������������
//���������������������������Ŀ
//� Criacao da Primeira Secao:�
//����������������������������� 
oSection1 := TRSection():New(oReport,STR0006,{"RDC","RD6"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//Avaliacao
oSection1:SetTotalInLine(.F.) 
oSection1:SetHeaderBreak(.T.)  

TRCell():New(oSection1,"RDC_CODAVA","RDC")				//Avaliacao
TRCell():New(oSection1,"RD6_DESC","RD6","")			//Descricao da Avaliacao 
TRCell():New(oSection1,"RDC_DTIAVA","RDC",STR0018)		//Data Inicio da Avaliacao

//���������������������������Ŀ
//� Criacao da Segunda Secao: �
//�����������������������������
oSection2 := TRSection():New(oSection1,STR0025,{"RDC","RD0"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//Avaliados	
oSection2:SetTotalInLine(.F.) 
oSection2:SetHeaderBreak(.T.)  
oSection2:SetLeftMargin(2)	//Identacao da Secao

TRCell():New(oSection2,"RDC_CODADO","RDC")				//Codigo da Avaliado
TRCell():New(oSection2,"RD0_NOME","RD0","")			//Nome do Avaliado 
TRCell():New(oSection2,"RDC_CODDOR","RDC")				//Codigo da Avaliador
TRCell():New(oSection2,"RD0_NOME","RD0","",,,,{|| Fdesc("RD0",(cAliasQry)->RDC_CODDOR,"RD0_NOME",30) })	//Nome do Avaliador
TRCell():New(oSection2,"RDC_TIPOAV","RDC",STR0016)		//Tipo Avaliador
TRCell():New(oSection2,"RDC_DATENV","RDC",STR0019)		//Data de Envio 
TRCell():New(oSection2,"RDC_DATRET","RDC",STR0020)		//Data de Resposta
TRCell():New(oSection2,"RDC_DTLIMR","RDC",STR0021)	   	//Data Limite 
TRCell():New(oSection2,"ATRASO"	,"   ",STR0022,,10,,{|| Ap50rAtraso(cAliasQry) })  	//Dias Atraso
TRCell():New(oSection2,"TRANSACAO"	,"   ",STR0023,,,,{|| Ap50rTransa(cAliasQry) })	//Transacao
TRCell():New(oSection2,"STATUS"	,"   ",STR0024,,7,,{||  Ap50rStatus(cAliasQry) }) 		//Status
       
Return oReport

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 27.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do Relatorio                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PrintReport(oReport,cAliasQry)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)  
Local lQuery    := .F. 
Local cWhere	:= ""
Local i := 0
Local cSitQuery := ""
Local cOrder	:= ""
Local cFilRD6 	:= ""  
Local cFilRD0 	:= ""  

//�������������������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                                          �
//� mv_par01        //  Filial?                                                   �
//� mv_par02        //  Avaliacao ?                                               �
//� mv_par03        //  Data de Inicio?                                           �
//� mv_par04        //  Avaliado?                                                 �
//� mv_par05        //  Tipo Avaliador? 1-Avaliador; 2-Auto Avalia��o; 3-Consenso �
//� mv_par06        //  Transacao? 1-Pendente; 2-Enviado; 3-Retornado             �
//� mv_par07        //  Status? 1-Aberto; 2-Fehcado                               �
//��������������������������������������������������������������������������������� 

	//����������������������������������������������Ŀ
	//� Transforma parametros Range em expressao SQL �
	//������������������������������������������������
	MakeSqlExpr("APD50R")    
	
	//-- Filtragem do relat�rio
	//-- Query do relat�rio da secao 1
	lQuery := .T.         
	cOrder := "%RDC_FILIAL,RDC_CODAVA,RDC_CODADO%"	

	//����������������Ŀ
	//� Tipo Avaliador �
	//������������������
	mv_par05 := Alltrim(mv_par05)	
	For i:= 1 to Len(mv_par05)
		cSitQuery += "'"+Subs(mv_par05,i,1)+"'"
		If ( i+1 ) <= Len(mv_par05)
			cSitQuery += "," 
		Endif
	Next i    
	
	If !Empty(cSitQuery)
		cSitQuery := "RDC.RDC_TIPOAV IN (" + cSitQuery + ")"
	Else
		cSitQuery := "RDC.RDC_TIPOAV <>''"
	EndIf
	cSitQuery := "%" + cSitQuery + "%"    
	  
	i:= 0
	//�����������Ŀ
	//� Transacao �
	//�������������
	mv_par06 := Alltrim(mv_par06)
	For i:= 1 to Len(mv_par06)
	cWhere += "'"+Subs(mv_par06,i,1)+"'"
	If ( i+1 ) <= Len(mv_par06)
		cWhere += "," 
	Endif
	Next i 
	
	If !Empty(cWhere)
		cWhere := "RDC.RDC_TIPO IN (" + cWhere + ")"
	ELSE
		cWhere := "RDC.RDC_TIPO <> ''"
	EndIf
	cWhere	:= "%" + cWhere + "%" 	
		
	oReport:Section(1):BeginQuery()	

	cFilRD6 := If (RD6->(xFilial()) == Space(FWGETTAMFILIAL),"%AND RD6.RD6_FILIAL = '" + Space(FWGETTAMFILIAL) +"'%","%AND RD6.RD6_FILIAL = RDC.RDC_FILIAL%")
	cFilRD0 := If (RD0->(xFilial()) == Space(FWGETTAMFILIAL),"%AND RD0.RD0_FILIAL = '" + Space(FWGETTAMFILIAL) +"'%","%AND RD0.RD0_FILIAL = RDC.RDC_FILIAL%")
	
	BeginSql Alias cAliasQry
			
		SELECT	RDC.RDC_CODAVA,RD6.RD6_DESC,RDC.RDC_DTIAVA,RDC.RDC_CODADO,RDC.RDC_CODDOR,RD0.RD0_NOME,RDC.RDC_TIPOAV,RDC.RDC_DATENV,RDC.RDC_DATRET,RDC.RDC_DTLIMR,RDC.RDC_TIPO
				
		FROM 	%table:RDC% RDC  
		
		LEFT JOIN %table:RD6% RD6
			ON RD6.RD6_FILIAL = %xFilial:RD6%
			AND RD6.RD6_CODIGO = RDC.RDC_CODAVA
			AND RD6.%NotDel%
			%exp:cFilRD6%
		LEFT JOIN %table:RD0% RD0                        '
			ON RD0.RD0_FILIAL = %xFilial:RD0%
			AND RD0.RD0_CODIGO = RDC.RDC_CODADO
			AND RD0.%NotDel%   
			%exp:cFilRD0%
		WHERE //RDC_FILIAL = %xFilial:RDC% AND 
			%exp:Upper(cSitQuery)% AND
			%exp:Upper(cWhere)% AND
			RDC.%NotDel%   													
		ORDER BY %Exp:cOrder%                 		
		
	EndSql
	
	//������������������������������������������������������������������������Ŀ
	//�Metodo EndQuery ( Classe TRSection )                                    �
	//�Prepara o relat�rio para executar o Embedded SQL.                       �
	//�ExpA1 : Array com os parametros do tipo Range                           �
	//��������������������������������������������������������������������������
	oReport:Section(1):EndQuery({mv_par01,mv_par02,mv_par03,mv_par04})	/*Array com os parametros do tipo Range*/

	//�������������������������������������������Ŀ
	//� Inicio da impressao do fluxo do relat�rio �
	//���������������������������������������������
 	oReport:SetMeter(RDC->(LastRec()))

	//�������������������������Ŀ
	//� Utiliza a query do Pai  �
	//���������������������������
	oSection2:SetParentQuery()
	
	//���������������������������Ŀ
	//� Condicao para Impressao   �
	//����������������������������� 
	oSection2:SetParentFilter( { |cParam| (cAliasQry)->RDC_CODAVA == cParam },{ || (cAliasQry)->RDC_CODAVA })
	oSection2:SetLineCondition({|| If(Empty(RDC_DATRET),"1" $ mv_par07,"2" $ mv_par07) })	//Status da Avaliacao
	
	oSection1:Print()	 //Imprimir

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ap50rAtraso � Autor � Eduardo Ju          � Data � 27.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Dias de Atraso                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � APDR50                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function Ap50rAtraso(cAliasQry)

Local nAtraso 	:= 0
Local cSvAlias 	:= Alias()  

If !Empty( (cAliasQry)->RDC_DTLIMR )
	If Empty( (cAliasQry)->RDC_DATRET)
		nAtraso := If(dDataBase > (cAliasQry)->RDC_DTLIMR, dDataBase - (cAliasQry)->RDC_DTLIMR, 0)
	Else
		nAtraso	:= If( (cAliasQry)->RDC_DATRET > (cAliasQry)->RDC_DTLIMR, (cAliasQry)->RDC_DATRET - (cAliasQry)->RDC_DTLIMR, 0)
	EndIf
EndIf

DbSelectArea(cSvAlias)

Return nAtraso

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ap50rTransa � Autor � Eduardo Ju          � Data � 27.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Transacao                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � APDR50                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function Ap50rTransa(cAliasQry)

Local cTransac := Space(15)
Local cSvAlias 	:= Alias()

If (cAliasQry)->RDC_TIPO == "1"
	cTransac := STR0011+Space(15-Len(STR0011))	//"Pendente"	
ElseIf (cAliasQry)->RDC_TIPO == "2"
	cTransac := STR0012+Space(15-Len(STR0012))	//"Enviado"		
ElseIf (cAliasQry)->RDC_TIPO == "3"
	cTransac := STR0013+Space(15-Len(STR0013))	//"Retornado"		
EndIf 

DbSelectArea(cSvAlias)

Return cTransac
	
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ap50rStatus � Autor � Eduardo Ju          � Data � 27.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Status da Avaliacao                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � APDR50                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function Ap50rStatus(cAliasQry)

Local cStatus := Space(15)
Local cSvAlias 	:= Alias()

If Empty( (cAliasQry)->RDC_DATRET )
	cStatus := STR0014+Space(15-Len(STR0014))	//"Aberto"		
Else
	cStatus := STR0015+Space(15-Len(STR0015))	//"Fechado"
EndIf

DbSelectArea(cSvAlias)

Return cStatus

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �ApdTipoAv � Autor �Emerson Grassi Rocha   � Data � 28/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Selecionar Tipo de Avaliadores.						      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �ApdTipoAv() 			   									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 �Generico 					   								  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function ApdTipoAv(l1Elem)

Local cTitulo	:= ""
Local MvPar		:= ""
Local MvParDef	:= ""
Local oWnd

Local aTipo	:= {}
l1Elem := If (l1Elem = Nil , .F. , .T.)

oWnd := GetWndDefault()

cAlias 	:= Alias() 					 // Salva Alias Anterior
MvPar	:= &(Alltrim(ReadVar()))	 // Carrega Nome da Variavel do Get em Questao
mvRet	:= Alltrim(ReadVar())		 // Iguala Nome da Variavel ao Nome variavel de Retorno

aTipo:={STR0009, STR0008, STR0010}	//"Avaliador", "Auto-Avaliacao" , "Consenso"
MvParDef:="123"
cTitulo := STR0016	//"Tipo Avaliador"

f_Opcoes(@MvPar,cTitulo,aTipo,MvParDef,12,49,l1Elem) 	// Chama funcao f_Opcoes
&MvRet := mvpar										 	// Devolve Resultado
dbSelectArea(cAlias) 								 	// Retorna Alias

If oWnd != Nil
	GetdRefresh()
Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �ApdTransa � Autor �Emerson Grassi Rocha   � Data � 28/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Selecionar Status de Avaliadores.						      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �ApdTransa() 			   									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 �Generico 					   								  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function ApdTransa(l1Elem)

Local cTitulo	:= ""
Local MvPar		:= ""
Local MvParDef	:= ""
Local oWnd

Local aTipo	:= {}
l1Elem := If (l1Elem = Nil , .F. , .T.)

oWnd := GetWndDefault()

cAlias 	:= Alias() 					// Salva Alias Anterior
MvPar	:= &(Alltrim(ReadVar()))	// Carrega Nome da Variavel do Get em Questao
mvRet	:= Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno
     
aTipo	:= {	STR0011,;			//"Pendente"
				STR0012,;			//"Enviado"
				STR0013}			//"Retornado"

MvParDef:= "123"
cTitulo := STR0017	//"Status da Avaliacao"

f_Opcoes(@MvPar,cTitulo,aTipo,MvParDef,12,49,l1Elem) 	// Chama funcao f_Opcoes
&MvRet := mvpar										 	// Devolve Resultado
dbSelectArea(cAlias) 								 	// Retorna Alias

If oWnd != Nil
	GetdRefresh()
Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �ApdStatus � Autor �Emerson Grassi Rocha   � Data � 28/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Selecionar Status de Avaliadores.						      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �ApdStatus() 			   									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 �Generico 					   								  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function ApdStatus(l1Elem)

Local cTitulo	:= ""
Local MvPar		:= ""
Local MvParDef	:= ""
Local oWnd

Local aTipo	:= {}
l1Elem := If (l1Elem = Nil , .F. , .T.)

oWnd := GetWndDefault()

cAlias 	:= Alias() 					// Salva Alias Anterior
MvPar	:= &(Alltrim(ReadVar()))	// Carrega Nome da Variavel do Get em Questao
mvRet	:= Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno
     
aTipo	:= {	STR0014,;			//"Aberto"
				STR0015}			//"Fechado"  
		
MvParDef:= "123"
cTitulo := STR0017	//"Status da Avaliacao"

f_Opcoes(@MvPar,cTitulo,aTipo,MvParDef,12,49,l1Elem) 	// Chama funcao f_Opcoes
&MvRet := mvpar										 	// Devolve Resultado
dbSelectArea(cAlias) 								 	// Retorna Alias

If oWnd != Nil
	GetdRefresh()
Endif

Return .T.

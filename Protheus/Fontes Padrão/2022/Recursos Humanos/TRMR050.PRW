#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRMR050.CH" 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TRMR050  � Autor � Eduardo Ju            � Data � 13/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Cursos por Entidade.                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TRMR050(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�31/07/14�TPZWAO�AIncluido o fonte da 11 para a 12 e efetu-���
���            �        �      �ada a limpeza.                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TRMR050()

Local oReport
Local aArea 		:= GetArea()
Private Titulo 		:= oemToAnsi(STR0001) 
Private cAliasQry	:= ""

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("TR050R",.f.)
oReport := ReportDef()
oReport:PrintDialog()	

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 13.06.06 ���
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

Private aOrd    := {OemToAnsi(STR0014),OemToAnsi(STR0004) }	//--  Entidade # Curso 
					
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
	oReport:=TReport():New("TRMR050",STR0007,"TR050R",{|oReport| PrintReport(oReport)},oemtoAnsi(STR0015) )			//""Este relatorio efetua a impressao  dos cursos disponiveis por entidade "
	oReport:SetTotalInLine(.F.) //Totaliza em linha
	oReport:SetLandscape()

	//����������������������������������������������������Ŀ
	//� Tipo a imprimir: 1-Entidade/Curso                  �
	//������������������������������������������������������ 
		//���������������������������Ŀ
		//� Criacao da Primeira Secao:�
		//����������������������������� 
		oSection1 := TRSection():New(oReport,STR0017,{"RA6"},/*aOrd*/ ,/*Campos do SX3*/,/*Campos do SIX*/)	//"Por Entidade/Curso"
		oSection1:SetTotalInLine(.F.)
	
			//����������������������������������������������������Ŀ
			//� Tipo a imprimir: 1-Entidade/Curso 2-Curso/Entidade �
			//������������������������������������������������������ 
			TRCell():New(oSection1,"RA6_ENTIDA","RA6")										//Codigo da Entidade  
			TRCell():New(oSection1,"RA0_DESC"  ,"RA0")											//Descricao da Entidade 

			TRPosition():New(oSection1,"RA0",1,{|| RHFilial( "RA0", (cAliasQry)->RA6_FILIAL)  + (cAliasQry)->RA6_ENTIDA }) 
		
		//���������������������������Ŀ
		//� Criacao da Segunda Secao: �
		//�����������������������������
		oSection2 := TRSection():New(oSection1,oemtoAnsi(STR0004) ,{"RA6","RA1"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Curso"
		oSection2:SetTotalInLine(.F.)
		
			TRCell():New(oSection2,"RA6_CURSO","RA6")										//Codigo do Curso  
			TRCell():New(oSection2,"RA1_DESC" ,"RA1")										//Descricao do Curso 
			TRCell():New(oSection2,"RA6_DURACA","RA6") 				//Duracao 
			TRCell():New(oSection2,"RA6_UNID"  ,"RA6")  		//Unid. Duracao   
			TRCell():New(oSection2,"RA6_VALOR" ,"RA6")      		//Valor do Curso
			TRCell():New(oSection2,"RA6_CONTEU","RA6",,,110)		//Conteudo Programatico 

			TRPosition():New(oSection2,"RA1",1,{|| RHFilial("RA1", (cAliasQry)->RA6_FILIAL ) + (cAliasQry)->RA6_CURSO }) 

	//����������������������������������������������������Ŀ
	//� Tipo a imprimir: 2-Curso/Entidade                  �
	//������������������������������������������������������ 
		//���������������������������Ŀ
		//� Criacao da Primeira Secao:�
		//����������������������������� 
		oSection3 := TRSection():New(oReport,STR0018,{"RA1"},aOrd ,/*Campos do SX3*/,/*Campos do SIX*/)	//"Por Curso/Entidade"
		oSection3:SetTotalInLine(.F.) 
		
			TRCell():New(oSection3,"RA1_CURSO","RA1") 										//Codigo do Curso 
			TRCell():New(oSection3,"RA1_DESC" ,"RA1")										//Descricao do Curso
		
			//TRPosition():New(oSection3,"RA1",1,{|| RHFilial("RA1", RA6->RA6_FILIAL ) + RA6->RA6_CURSO }) 

		//���������������������������Ŀ
		//� Criacao da Segunda Secao: �
		//�����������������������������
		oSection4 := TRSection():New(oSection3,oemtoAnsi(STR0004) ,{"RA6","RA0"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Curso"
		oSection4:SetTotalInLine(.F.)
	
			TRCell():New(oSection4,"RA6_ENTIDA","RA6")									//Codigo da Entidade  
			TRCell():New(oSection4,"RA0_DESC"  ,"RA0")									//Descricao da Entidade 
			TRCell():New(oSection4,"RA6_DURACA","RA6")					 				//Duracao 
			TRCell():New(oSection4,"RA6_UNID"  ,"RA6")  								//Unid. Duracao   
			TRCell():New(oSection4,"RA6_VALOR" ,"RA6")      							//Valor do Curso
			TRCell():New(oSection4,"RA6_CONTEU","RA6",,,110)							//Conteudo Programatico 

			TRPosition():New(oSection4,"RA0",1,{|| RHFilial("RA0",(cAliasQry)->RA6_FILIAL ) + (cAliasQry)->RA6_ENTIDA })
		
		
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

Return oReport

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 13.06.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do Relatorio (Custo do Treinamento)               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PrintReport(oReport)

Local oSection1 := If(MV_PAR05 == 1, oReport:Section(1), oReport:Section(2))
Local oSection2 := oSection1:Section(1) 
Local cFiltro 	:= "" 
Local cFilRA1	:= ""
Local cFilRA0	:= ""
Local cFilRA6	:= ""
Local lQuery    := .F. 

oSection2:SetTotalText({|| OemToAnsi(STR0016) } )

If MV_PAR05 == 1
	TRFunction():New(oSection2:Cell("RA6_CURSO"),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
Else
	TRFunction():New(oSection2:Cell("RA6_ENTIDA"),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
EndIf                                                                                                 

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01        //  Filial?                                  �
//� MV_PAR02        //  Curso?                                   �
//� MV_PAR03        //  Entidade?                                �
//� MV_PAR04        //  Impr.1 Item p/Folha?                     �
//� MV_PAR05        //  Tipo a imprimir?                         �
//� MV_PAR06        //  Cont.Programatico?                       �
//���������������������������������������������������������������� 

//��������������������������������������������������������������Ŀ
//� Personaliza titulos                                          �
//����������������������������������������������������������������
Titulo := If(AllTrim(oReport:Title())==AllTrim(Titulo),Titulo ,oReport:Title()  ) 
oReport:SetTitle(Titulo)

//���������������������������Ŀ
//� Imprime Item por Pagina   �
//�����������������������������
If MV_PAR04 == 1   		
	If MV_PAR05 == 1  
		oBreak := TRBreak():New(oSection1,oSection1:Cell("RA6_ENTIDA"),"",.F.)
	Else
		oBreak := TRBreak():New(oSection1,oSection1:Cell("RA1_CURSO"),"",.F.) 	
	EndIf 
	oBreak:SetPageBreak(.T.) //Salta Pagina		
EndIf

//���������������������������������Ŀ
//� Suprimir Conteudo Programatico  �
//�����������������������������������
If MV_PAR06 <> 1
	oSection2:Cell("RA6_CONTEU"):Disable()
Else
	oSection2:Cell("RA6_CONTEU"):SetLineBreak()		//Impressao de campo Memo
EndIf

//����������������������������������������������Ŀ
//� Transforma parametros Range em expressao SQL �
//������������������������������������������������
MakeSqlExpr("TR050R")

cAliasQry	:= GetNextAlias()	

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
lQuery := .T. 

//����������������������������������������������������Ŀ
//� Tipo a imprimir: 1-Entidade/Curso 2-Curso/Entidade �
//������������������������������������������������������
If MV_PAR05 == 1  
	cOrder := "%RA6_FILIAL,RA6_ENTIDA,RA6_CURSO%" 
Else		
	cOrder := "%RA1_FILIAL,RA1_CURSO,RA6_ENTIDA%" 	       
EndIf		

oSection1:BeginQuery()	

cFilRA1 := "%RA1.RA1_FILIAL  = " + IIf(Empty(xFilial("RA1")), "'" + Space(FWGETTAMFILIAL) + "'", "RA6.RA6_FILIAL") + "%"
cFilRA0	:= "%RA0.RA0_FILIAL  = " + IIf(Empty(xFilial("RA0")), "'" + Space(FWGETTAMFILIAL) + "'", "RA6.RA6_FILIAL") + "%"	
cFilRA6 := "%RA6.RA6_FILIAL  = " + IIf(Empty(xFilial("RA6")), "'" + Space(FWGETTAMFILIAL) + "'", "RA1.RA1_FILIAL") + "%"

If MV_PAR05 == 1  

	BeginSql Alias cAliasQry
		SELECT	RA1_FILIAL,RA6_FILIAL,RA6_CURSO,RA1_DESC,RA6_ENTIDA,RA0_DESC,RA6_DURACA,RA6_UNID,RA6_VALOR,RA6_CONTEU	
		FROM 	%table:RA6% RA6  
		LEFT JOIN %table:RA1% RA1
		ON    %exp:cFilRA1%    					//- RA1_FILIAL = %xFilial:RA1%
			  AND RA1_CURSO = RA6_CURSO
			  AND RA1.%NotDel%
		LEFT JOIN %table:RA0% RA0               
		ON    %exp:cFilRA0%    						// RA0_FILIAL = %xFilial:RA6%
			  AND RA0_ENTIDA = RA6_ENTIDA
			  AND RA0.%NotDel%
	
		WHERE  RA6.%NotDel%
		ORDER BY %Exp:cOrder%                 		
	EndSql

Else

	BeginSql Alias cAliasQry	
		SELECT	RA1_FILIAL,RA1_CURSO,RA1_DESC,RA6_FILIAL,RA6_CURSO,RA6_ENTIDA,RA6_DURACA,RA6_UNID,RA6_VALOR,RA6_CONTEU	
		FROM 	%table:RA1% RA1  
		LEFT JOIN %table:RA6% RA6
		ON    %exp:cFilRA6%    					//- RA1_FILIAL = %xFilial:RA1%
			  AND RA1_CURSO = RA6_CURSO
			  AND RA6.%NotDel%
	
		WHERE  RA1.%NotDel%
		ORDER BY %Exp:cOrder%                 		
	EndSql
	
Endif		
		
	
//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�ExpA1 : Array com os parametros do tipo Range                           �
//��������������������������������������������������������������������������
oSection1:EndQuery({MV_PAR01,MV_PAR02,MV_PAR03})	/*Array com os parametros do tipo Range*/
	
//�������������������������Ŀ
//� Utiliza a query do Pai  �
//���������������������������
oSection2:SetParentQuery()

//���������������������������Ŀ
//� Condicao para Impressao   �
//����������������������������� 
If MV_PAR05 == 1
	oSection2:SetParentFilter({|cParam| (cAliasQry)->(RA6_FILIAL+ RA6_ENTIDA ) == cParam},{|| (cAliasQry)->(RA6_FILIAL+RA6_ENTIDA) })	
Else   
	oSection2:SetParentFilter({|cParam| (cAliasQry)->(RA6_FILIAL+RA6_CURSO)  == cParam},{|| (cAliasQry)->(RA1_FILIAL+RA1_CURSO) })
EndIf
                              
//�������������������������������������������Ŀ
//� Inicio da impressao do fluxo do relat�rio �
//���������������������������������������������
oReport:SetMeter( (cAliasQry)->(RecCount()))

oSection1:Print()	 //Imprimir

Return Nil
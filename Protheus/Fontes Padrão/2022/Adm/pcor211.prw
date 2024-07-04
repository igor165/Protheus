#INCLUDE "PCOR211.ch"
#INCLUDE "PROTHEUS.ch"

Function PCOR211(aOrigem,aComparado,cVersao1,cVersao2,aPerg)

PCOR211R4(aOrigem,aComparado,cVersao1,cVersao2,aPerg)

Return

Function PCOR211R4(aOrigem,aComparado,cVersao1,cVersao2,aPerg)
Local aArea		:= GetArea()

//OBSERVACAO NAO TIRAR A LINHA ABAIXO POIS VARIAVEL SERA UTILIZADA NA CONSULTA PADRAO AKE1
Private M->AKR_ORCAME := Replicate("Z", Len(AKR->AKR_ORCAME))

DEFAULT aOrigem   	:= {}
DEFAULT aComparado	:= {}
DEFAULT cVersao1  	:= "0001"
DEFAULT cVersao2  	:= "0001"
DEFAULT aPerg  		:= {}

dbSelectArea("AK1")
dbSetOrder(1)

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef(aOrigem,aComparado,cVersao1,cVersao2,aPerg)

oReport:PrintDialog()

RestArea(aArea)
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Paulo Carnelossi       � Data �29/05/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef(aOrigem,aComparado,cVersao1,cVersao2,aPerg)
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"Diferencas entre Versoes"
Local cTitulo        := STR0003 //"Diferencas entre Versoes"
Local cPerg          := "PCR211"

Local aOrdem := {}
Local oReport
Local oPlanilha
Local oEntidade

DEFAULT aOrigem   	:= {}
DEFAULT aComparado	:= {}
DEFAULT cVersao1  	:= "0001"
DEFAULT cVersao2  	:= "0001"
DEFAULT aPerg  		:= {}

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������

oReport := TReport():New("PCOR211",STR0003, cPerg, ;
			{|oReport| ReportPrint(oReport,aOrigem,aComparado,cVersao1,cVersao2,aPerg)},;
			STR0001+CRLF+STR0002+CRLF+STR0003 )

//������������������������������������������������������������������������Ŀ
//�Verifica as Perguntas Selecionadas                                      �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//� PARAMETROS                                                             �
//� MV_PAR01 : Projeto ?	                                                �
//� MV_PAR02 : Versao De ?		                                             �
//� MV_PAR03 : Versao Ate ?												            �
//��������������������������������������������������������������������������
Pergunte(cPerg,.F.)

If (Len(aOrigem) == 0) .Or. (Len(aComparado) == 0)
	If Len(aPerg) > 0
		aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
        oReport:ParamReadOnly()
	EndIf
Else
	//�����������������������������������������������������Ŀ
	//�Chamado atraves do programa de comparacao de versoes.�
	//�������������������������������������������������������
	Mv_Par01:= AK1->AK1_CODIGO
	Mv_Par02:= cVersao1
	Mv_Par03:= cVersao2
	oReport:ParamReadOnly()
EndIf

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//adiciona ordens do relatorio

oPlanilha := TRSection():New(oReport,STR0010,{"AK1"}, aOrdem /*{}*/, .F., .F.)
oPlanilha:SetNoFilter({"AK1"})

//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
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
//�                                                                        �
//��������������������������������������������������������������������������
TRCell():New(oPlanilha,	"AK1_CODIGO"	,"AK1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AFE_PROJET }*/)
TRCell():New(oPlanilha,	"AK1_DESCRI"	,"AK1",/*Titulo*/,/*Picture*/,50/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AF8_DESCRI }*/)
oPlanilha:SetLineStyle()
oPlanilha:SetHeaderPage()
oReport:onPageBreak({||oPlanilha:PrintLine(),oReport:ThinLine()})

oEntidade := TRSection():New(oReport,STR0016,{}, aOrdem /*{}*/, .F., .F.)  //"Entidade"
TRCell():New(oEntidade,	"DESC_ALIAS"	,/*Alias*/,STR0016+" :"/*Titulo*/,/*Picture*/,50/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AFE_PROJET }*/)  //"Entidade"
TRCell():New(oEntidade,	"CONTEUDO"	,/*Alias*/,"-->"/*Titulo*/,/*Picture*/,TamSX3("AK3_DESCRI")[1]+15/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AFE_PROJET }*/)
oEntidade:SetLineStyle()
oEntidade:SetCharSeparator("")

oCompara := TRSection():New(oReport,STR0003,{}, aOrdem /*{}*/, .F., .F.)

TRCell():New(oCompara,	"CAMPO"	,/*Alias*/,STR0017/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AFE_PROJET }*/)  //"Campos"
TRCell():New(oCompara,	"CVERSAO1"	,/*Alias*/,STR0019 /*Titulo*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AFE_PROJET }*/)
TRCell():New(oCompara,	"CVERSAO2"	,/*Alias*/,STR0020 /*Titulo*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AF8_DESCRI }*/)
oCompara:SetHeaderPage()

Return(oReport)

Static Function ReportPrint(oReport,aOrigem,aComparado,cVersao1,cVersao2,aPerg)
Local oPlanilha := oReport:Section(1)
Local oEntidade := oReport:Section(2)
Local oCompara 	:= oReport:Section(3)

Local aDestino:= {}
Local aDados  := {}
Local aAlias  := {	{"AK3",STR0006},; //"Contas Orcamentarias"
					{"AK2",STR0007}} //"Itens das CO"
Local nItem   := 0
Local nDados  := 0
Local cCodAnt := ""

oEntidade:Cell("DESC_ALIAS"):SetBlock( {|| aAlias[nIndice,2] + " (" + aDados[nDados,7] + ")" } )
oEntidade:Cell("CONTEUDO"):SetBlock( {|| aDados[nDados,3] } )

oCompara:Cell("CAMPO"):SetBlock( {|| Left(Posicione("SX3",2,aDados[nDados,4],"X3TITULO()") + Space(20),20) } )
oCompara:Cell("CVERSAO1"):SetBlock( {|| aDados[nDados,5] } )
oCompara:Cell("CVERSAO2"):SetBlock( {|| aDados[nDados,6] } )
oCompara:Cell("CVERSAO1"):SetTitle( STR0018+": "+mv_par02 )  //"Versao"
oCompara:Cell("CVERSAO2"):SetTitle( STR0018+": "+mv_par03 )  //"Versao"

If (Len(aOrigem) == 0) .Or. (Len(aComparado) == 0)

    If Len(aPerg) == 0
		If !Empty(oReport:uParam)
			Pergunte(oReport:uParam,.F.)
		EndIf
	EndIf	

	dbSelectArea("AK1")
	dbSetOrder(1)

	If !Empty(mv_par01) .And. dbSeek(xFilial("AK1") + Mv_Par01)
	
		//�����������������������������������������������������������������������
		//�Monta um array com a estrutura do tree do projeto que sera utilizado �
		//�como base na comparacao.                                             �
		//�����������������������������������������������������������������������
		Processa({||aOrigem := Pco120TreeEDT(Mv_Par02)},,STR0008) //"Selecionando Registros"
		
		//�����������������������������������������������������������������������
		//�Monta um array com a estrutura do tree do projeto que sera utilizado �
		//�como na comparacao.                                             �
		//�����������������������������������������������������������������������
		Processa({||aDestino := Pco120TreeEDT(Mv_Par03)},,STR0008) //"Selecionando Registros"
		
		//�����������������������������������������������������������������������
		//�Monta um array com a estrutura do tree do projeto da comparacao entre�
		//�as versoes.				                                            �
		//�����������������������������������������������������������������������
		aComparado:= Pco120_Compara(aOrigem,aDestino)
	EndIf	
EndIf

If (Len(aComparado) > 0)

	//���������������������������������������������������������������������Ŀ
	//� SETREGUA -> Indica quantos registros serao processados para a regua �
	//�����������������������������������������������������������������������
	oReport:SetMeter(Len(aComparado))
    oPlanilha:Init()
    
	For nItem:= 1 To Len(aComparado)

		//���������������������������������������������������������������������Ŀ
	    //� Verifica o cancelamento pelo usuario...                             �
	    //�����������������������������������������������������������������������
	    If oReport:Cancel()
	      	Exit
	   	EndIf
	   	
	   	oReport:IncMeter()
	   	
	   	//���������������������������������������������������������������������Ŀ
	   	//� Impressao do cabecalho do relatorio. . .                            �
	   	//�����������������������������������������������������������������������
	    If (aComparado[nItem,6] <> "N")

			aDados:= R211Compara(aOrigem,aComparado,nItem)			

			oEntidade:Init()
			oCompara:Init()

			For nDados:= 1 To Len(aDados)
		
				If (aDados[nDados,1] + aDados[nDados,2] <> cCodAnt)
					cCodAnt:= aDados[nDados,1] + aDados[nDados,2]
					nIndice := Ascan(aAlias,{|x|x[1] == aDados[nDados,1]})

					oReport:ThinLine()
					oEntidade:PrintLine()
					oReport:ThinLine()
					
				EndIf

				oCompara:PrintLine()

			Next nDados

			oCompara:Finish()
			oEntidade:Finish()

	    EndIf
	    
	Next nItem
	
	oPlanilha:Finish()
	 
EndIf

Return

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Fun��o    �R211Compara� Autor � Paulo Carnelossi      � Data �  04/01/2005 ���
�����������������������������������������������������������������������������͹��
���Descri��o � Verifica as diferencas entre as versoes						  ���
�����������������������������������������������������������������������������͹��
���Uso       � AP       		                                              ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Static Function R211Compara(aOrigem,aComparado,nPosComp)
Local aCampos:= {}
Local aStrut := {}
Local aDados := {}
Local nCampo := 0
Local nPosOri:= 0
Local cAlias := ""
Local cChave := ""
Local cCampo := ""
Local cDesc  := ""
Local cTipo  := ""
Local cValor := ""
Local cCO    := ""

//������������������������������������������������������������������������Ŀ
//�Analisa cada item das versoes do projeto para identificar as alteracoes.�
//��������������������������������������������������������������������������
cAlias:= aComparado[nPosComp,1]
cChave:= aComparado[nPosComp,2]
cDesc := aComparado[nPosComp,3]
cTipo := aComparado[nPosComp,6]

//�������������������������������������Ŀ
//�Verifica se o item existe no arquivo.�
//���������������������������������������
dbSelectArea(cAlias)
dbSetOrder(1)
If dbSeek(cChave,.T.)
	aStrut:= &(cAlias + "->(dbStruct())")
	aDados:= Array(1,Len(aStrut))

	AEval(aStrut,{|cValue,nIndex| aDados[1,nIndex]:= {aStrut[nIndex,1],FieldGet(FieldPos(aStrut[nIndex,1]))}})
		                                 
	//��������������������������������������������������������������������������Ŀ
	//� Guarda conta orcamentaria para inclus�o no aCampos e posterior impressao �
	//����������������������������������������������������������������������������
	nPosCO	:= aScan(aDados[1],{|x| AllTrim(Upper(x[1]))== cAlias + "_CO"})
	cCO		:= RTrim(aDados[1,nPosCO,2])

	//�����������������������������������������������������������������Ŀ
	//�Verifica o tipo da operacao I=Incluido M=Modificado e E=Excluido.�
	//�������������������������������������������������������������������
	Do Case

		//�������������Ŀ
		//�Item Incluido�
		//���������������
		Case cTipo == "I"
			For	nCampo:= 1 To Len(aDados[1])	
				cCampo:= aDados[1,nCampo,1]
				cValor:= aDados[1,nCampo,2]
	
				If !("VERSAO" $ cCampo)
					Aadd(aCampos,{	cAlias,;
									cChave,;
									cDesc,;
									cCampo,;
									Space(40),;
									Left(AllTrim(Transform(cValor,PesqPict(cAlias,cCampo))) + Space(40),40),;
									cCO})
				EndIf
			Next
	
		//���������������Ŀ
		//�Item Modificado�
		//�����������������
		Case cTipo == "M"                
			nPosOri:= Ascan(aOrigem,{|x| x[4] == aComparado[nPosComp,4]})
			If (nPosOri > 0) .And. dbSeek(aOrigem[nPosOri,2],.T.)
				For	nCampo:= 1 To Len(aDados[1])	
					cCampo:= aDados[1,nCampo,1]
					cValor:= aDados[1,nCampo,2]

					If !("VERSAO" $ cCampo) .And. (cValor <> FieldGet(nCampo))
							Aadd(aCampos,{	cAlias,;
											cChave,;
											cDesc,;
											cCampo,;
											Left(AllTrim(Transform(FieldGet(nCampo),PesqPict(cAlias,cCampo))) + Space(40),40),;
											Left(AllTrim(Transform(cValor,PesqPict(cAlias,cCampo))) + Space(40),40),;
											cCO})

					EndIf
				Next
        	EndIf
    
		//�������������Ŀ
		//�Item Excluido�
		//���������������
		Case cTipo == "E"                 
			nPosOri:= Ascan(aOrigem,{|x| x[4] == aComparado[nPosComp,4]})
			If (nPosOri > 0) .And. dbSeek(aOrigem[nPosOri,2],.T.)
				For	nCampo:= 1 To Len(aDados[1])	
					cCampo:= aDados[1,nCampo,1]
					cValor:= aDados[1,nCampo,2]

					If !("VERSAO" $ cCampo)

						Aadd(aCampos,{	cAlias,;
										cChave,;
										cDesc,;
										cCampo,;
										Left(AllTrim(Transform(cValor,PesqPict(cAlias,cCampo))) + Space(40),40),;
										Space(40),;
										cCO})
					 EndIf
				Next
			EndIf
	EndCase
EndIf
		
Return(aCampos)

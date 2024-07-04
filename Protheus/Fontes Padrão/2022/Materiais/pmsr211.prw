#INCLUDE "PMSR211.ch"
#INCLUDE "PROTHEUS.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMSR211   �Autor  �Paulo Carnelossi    � Data �  29/09/06   ���
�������������������������������������������������������������������������͹��
���Descri��o �Funcao do Relatorio para release 4 utilizando obj tReport   ���
���          �Relatorio de Comparacao entre versoes                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PMSR211(aOrigem,aComparado,cVersao1,cVersao2)
	Local oReport

	If PMSBLKINT()
		Return Nil
	EndIf
	
	oReport := ReportDef(aOrigem,aComparado,cVersao1,cVersao2)

	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf	

	oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Paulo Carnelossi       � Data �04/07/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef(aOrigem,aComparado,cVersao1,cVersao2)

Local oReport
Local oProjeto
Local oCompara

Local aOrdem := {}
Local cPerg  := "PMR21B"

DEFAULT aOrigem   := {}
DEFAULT aComparado:= {}
DEFAULT cVersao1  := "0001"
DEFAULT cVersao2  := "0001"
//���������������������������������Ŀ
//�Chamado atrav�s da opcao do menu.�
//�����������������������������������
dbSelectArea("AF8")
dbSetOrder(1)

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������
If (Len(aOrigem) == 0) .Or. (Len(aComparado) == 0)

	//������������������������������������������������������������������������Ŀ
	//�Verifica as Perguntas Selecionadas                                      �
	//��������������������������������������������������������������������������
	//������������������������������������������������������������������������Ŀ
	//� PARAMETROS                                                             �
	//� MV_PAR01 : De Projeto ?	                                               �
	//� MV_PAR02 : Ate Projeto ?	                                             �
	//� MV_PAR03 : Versao De ?		                                             �
	//� MV_PAR04 : Versao Ate ?												            �
	//��������������������������������������������������������������������������
	Pergunte(cPerg,.F.)
Else

	//�����������������������������������������������������Ŀ
	//�Chamado atraves do programa de comparacao de versoes.�
	//�������������������������������������������������������
	cPerg   := ""
	Mv_Par01:= AF8->AF8_PROJET
	Mv_Par02:= AF8->AF8_PROJET
	Mv_Par03:= cVersao1
	Mv_Par04:= cVersao2
EndIf

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

oReport := TReport():New("PMSR211",STR0003, cPerg, ;
			{|oReport| ReportPrint(oReport,aOrigem,aComparado,cVersao1,cVersao2)},;
			STR0001+CRLF+STR0002+CRLF+STR0003 )

//STR0001 //"Este programa tem como objetivo imprimir relatorio "
//STR0002 //"de acordo com os parametros informados pelo usuario."
//STR0003 //"Diferencas entre Versoes"
//STR0003 //"Diferencas entre Versoes"

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

oProjeto := TRSection():New(oReport, STR0019, {"AF8", "SA1", "AFE"}, aOrdem /*{}*/, .F., .F.)

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
TRCell():New(oProjeto,	"AF8_PROJET"	,"AF8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AFE_PROJET }*/)
TRCell():New(oProjeto,	"AF8_DESCRI"	,"AF8",/*Titulo*/,/*Picture*/,50/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AF8_DESCRI }*/)
oReport:onPageBreak({||oProjeto:PrintLine(),oReport:ThinLine()})
oProjeto:SetLineStyle()

TRPosition():New(oProjeto, "SA1", 1, {|| xFilial("SA1") + AF8->AF8_CLIENT})
TRPosition():New(oProjeto, "AFE", 1, {|| xFilial("AFE") + AF8->AF8_PROJET + AF8->AF8_REVISA})

oCompara := TRSection():New(oReport, STR0016,, aOrdem /*{}*/, .F., .F.)  //"Itens Modificados"

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
TRCell():New(oCompara,	"CAMPO"	,/*Alias*/,STR0017/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AFE_PROJET }*/)  //"Campo"
TRCell():New(oCompara,	"CVERSAO1"	,/*Alias*/,/*Titulo*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AFE_PROJET }*/)
TRCell():New(oCompara,	"CVERSAO2"	,/*Alias*/,/*Titulo*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AF8_DESCRI }*/)

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Paulo Carnelossi      � Data �29/05/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �que faz a chamada desta funcao ReportPrint()                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �ExpO1: Objeto TReport                                       ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport, aOrigem, aComparado, cVersao1, cVersao2)
Local oProjeto  := oReport:Section(1)
Local oCompara  := oReport:Section(2)

Local aDestino:= {}
Local aDados  := {}
Local aAlias  := {	{"AFA",STR0008},; //"Produto/Recurso: "
					{"AFC",STR0009},; //"EDT: "
					{"AF9",STR0010},; //"Tarefa: "
					{"AFB",STR0011},; //"Despesa: "
					{"AFD",STR0012},; //"Relacionamento: "
					{"AEN",STR0021},; //"Relacionamento: "
					{"ACB",STR0018+": "},; //"Documento"
					{"AEL",STR0020}}		//"Insumo"


Local nItem   := 0
Local nDados  := 0
Local cCodAnt := ""
Local cAliasAF8 := GetNextAlias()

oProjeto:Cell("AF8_PROJET"):SetBlock( {|| (cAliasAF8)->AF8_PROJET } )
oProjeto:Cell("AF8_DESCRI"):SetBlock( {|| (cAliasAF8)->AF8_DESCRI } )
oCompara:Cell("CAMPO"):SetBlock( {|| Left(Posicione("SX3",2,aDados[nDados,4],"X3TITULO()") + Space(20),20) } )
oCompara:Cell("CVERSAO1"):SetBlock( {|| aDados[nDados,5] } )
oCompara:Cell("CVERSAO2"):SetBlock( {|| aDados[nDados,6] } )
oCompara:Cell("CVERSAO1"):SetTitle(Alltrim(STR0007)+Space(1)+MV_PAR03)//"Versao"
oCompara:Cell("CVERSAO2"):SetTitle(Alltrim(STR0007)+Space(1)+MV_PAR04)//"Versao"
oCompara:SetHeaderPage()

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �	
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao 1                                           �
//��������������������������������������������������������������������������
oProjeto:BeginQuery()	

BeginSql Alias cAliasAF8
SELECT AF8_PROJET, AF8_DESCRI, R_E_C_N_O_

FROM %table:AF8% AF8

WHERE AF8.AF8_FILIAL = %xFilial:AF8% AND 
	AF8.AF8_PROJET >=%Exp:mv_par01% AND
	AF8.AF8_PROJET <=%Exp:mv_par02% AND 
	AF8.%NotDel%

ORDER BY %Order:AF8%
		
EndSql 
//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oProjeto:EndQuery(/*Array com os parametros do tipo Range*/)

dbSelectArea(cAliasAF8)
dbGoTop()

oProjeto:Init()
oBreak:=TRBreak():New(oProjeto,{|| (cAliasAF8)->AF8_PROJET })
oBreak:OnBreak({ || IIF(!oReport:PageBreak(),( oReport:ThinLine(), oReport:SkipLine(), oProjeto:PrintLine() ),.F.) })   \

While (cAliasAF8)->(!Eof()) .AND. !oReport:Cancel()
	aOrigem  := {}
	aComparado:= {}
	aDestino:= {}
    //se for top posiciona no recno do AF8 
    AF8->(dbGoto((cAliasAF8)->R_E_C_N_O_))

	If (Len(aOrigem) == 0) 
		//�����������������������������������������������������������������������
		//�Monta um array com a estrutura do tree do projeto que sera utilizado �
		//�como base na comparacao.                                             �
		//�����������������������������������������������������������������������
		Processa({||aOrigem := PMS210TreeEDT(Mv_Par03)},,STR0013) //"Selecionando Registros"
	EndIf
	
	If (Len(aComparado) == 0)
		//�����������������������������������������������������������������������
		//�Monta um array com a estrutura do tree do projeto que sera utilizado �
		//�como na comparacao.                                             �
		//�����������������������������������������������������������������������
		Processa({||aDestino := PMS210TreeEDT(Mv_Par04)},,STR0013) //"Selecionando Registros"

		//�����������������������������������������������������������������������
		//�Monta um array com a estrutura do tree do projeto da comparacao entre�
		//�as versoes.				                                            �
		//�����������������������������������������������������������������������
		aComparado:= PMS210Compara(aOrigem,aDestino)
	EndIf
        
	If (Len(aComparado) > 0)
	                           
		oBreak:Execute()
		oReport:SetMeter(Len(aComparado))

		oCompara:Init()

		For nItem:= 1 To Len(aComparado)

		    If oReport:Cancel()
		      	Exit
		   	EndIf
	
		    If (aComparado[nItem,6] <> "N")

				aDados:= R211Compara(aOrigem,aComparado,nItem)			
				
				For nDados:= 1 To Len(aDados)
			
					If (aDados[nDados,1] + aDados[nDados,2] <> cCodAnt)
						cCodAnt:= aDados[nDados,1] + aDados[nDados,2]

						If Ascan(aAlias,{|x|x[1] == aDados[nDados,1]}) > 0
	                        oReport:ThinLine()
							oReport:PrintText(AllTrim(aAlias[Ascan(aAlias,{|x|x[1] == aDados[nDados,1]}),2] + aDados[nDados,3]))
							oReport:ThinLine()
						EndIf
					EndIf
	
					oCompara:PrintLine()

				Next nDados

		    EndIf
		    
			oReport:IncMeter()
			
		 Next nItem
		 
		oCompara:Finish()

	EndIf

	(cAliasAF8)->(DbSkip())

End	

	// verifica o cancelamento pelo usuario..
	If oReport:Cancel()	
		oReport:SkipLine()
		oReport:PrintText(STR0014) //"*** CANCELADO PELO OPERADOR ***"
	EndIf
oProjeto:Finish()

Return

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Fun��o    �R211Compara� Autor � Fabio Rogerio Pereira � Data �  19/12/01   ���
�����������������������������������������������������������������������������͹��
���Descri��o � Verifica as diferencas entre as versoes						  ���
�����������������������������������������������������������������������������͹��
���Uso       � PMSA210			                                              ���
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
	
				If !("REVISA" $ cCampo)
					Aadd(aCampos,{	cAlias,;
									cChave,;
									cDesc,;
									cCampo,;
									Space(40),;
									Left(AllTrim(Transform(cValor,PesqPict(cAlias,cCampo))) + Space(40),40)})
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

					If !("REVISA" $ cCampo) .And. (cValor <> FieldGet(nCampo))
							Aadd(aCampos,{	cAlias,;
											cChave,;
											cDesc,;
											cCampo,;
											Left(AllTrim(Transform(FieldGet(nCampo),PesqPict(cAlias,cCampo))) + Space(40),40),;
											Left(AllTrim(Transform(cValor,PesqPict(cAlias,cCampo))) + Space(40),40)})

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

					If !("REVISA" $ cCampo)

						Aadd(aCampos,{	cAlias,;
										cChave,;
										cDesc,;
										cCampo,;
										Left(AllTrim(Transform(cValor,PesqPict(cAlias,cCampo))) + Space(40),40),;
										Space(40)})
					 EndIf
				Next
			EndIf
	EndCase
EndIf
		
Return(aCampos)
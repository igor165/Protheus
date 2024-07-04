#INCLUDE "PCOR010.CH"
#INCLUDE "PROTHEUS.CH"
/*/
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOR010  � AUTOR � Edson Maricate        � DATA � 07-01-2004 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa de impressao da planilha orcamentaria.              ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOR010                                                      ���
���_DESCRI_  � Programa de impressao da planilha orcamentaria.              ���
���_FUNC_    � Esta funcao devera ser utilizada com a sua chamada normal a  ���
���          � partir do Menu do sistema.                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PCOR010(aPerg)

PCOR010R4(aPerg)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PCOR010R4 � Autor �Paulo Carnelossi       � Data �31/05/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao do Relatorio para release 4 utilizando obj tReport   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �ExpA1: Array com conteudo dos MV_PAR do Pergunte            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PCOR010R4(aPerg)
Local aArea		:= GetArea()
Local cAliasAK1 := "AK1"
Local cAliasAKE := "AKE"
Local cAliasAK3 := "AK3"

Private cRevisa

Default aPerg := {}

//OBSERVACAO NAO TIRAR A LINHA ABAIXO POIS SERA UTILIZADA NA CONSULTA PADRAO AKE1
Private M->AKR_ORCAME := Replicate("Z", Len(AKR->AKR_ORCAME))

If Len(aPerg) >  0
	aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
EndIf

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef( @cAliasAK1, @cAliasAK3, @cAliasAKE )
If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf	
oReport:PrintDialog()

RestArea(aArea)
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PcoR010Avalia� Autor �Paulo Carnelossi    � Data �31/05/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao do botao OK da print Dialog obj tReport ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �ExpA1: Array com conteudo dos MV_PAR do Pergunte            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PcoR010Avalia()
Local lOk := .T.

	dbSelectArea("AK1")
	dbSetOrder(1)
	If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
		If  MsSeek(xFilial()+MV_PAR01)
			
			If !Empty(MV_PAR02)
				dbSelectArea("AKE")
				dbSetOrder(1)
				If ! MSSeek(xFilial()+MV_PAR01+MV_PAR02)
					MsgStop(STR0013)	// Revisao nao encontrada. Verifique!
					lOk := .F.
				Else
					cRevisa := MV_PAR02
				EndIf
				dbSelectArea("AK1")
			Else			
				While AK1->(! Eof() .And. AK1_FILIAL+AK1_CODIGO == xFilial("AK1")+MV_PAR01)
					cRevisa	:= AK1->AK1_VERSAO
					nRecAK1 := AK1->(Recno())
					AK1->(dbSkip())
				End
			AK1->(dbGoto(nRecAK1))
			EndIf      
			
			If lOk
				lOk := (PcoVerAcessoPlan(2) > 0 )
			EndIf	
		EndIf
	Else
		lOk:=.F.
	EndIf

Return(lOk)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Paulo Carnelossi       � Data �31/05/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �ExpC1: Alias da tabela de Planilha Orcamentaria (AK1)       ���
���          �ExpC2: Alias da tabela de Contas da Planilha (Ak3)          ���
���          �ExpC3: Alias da tabela de Revisoes da Planilha (AKE)        ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef(cAliasAK1, cAliasAK3, cAliasAKE)

Local oReport
Local oPlanilha
Local oContasOrc

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
oReport := TReport():New("PCOR010",STR0012,"PCR010", ;
			{|oReport| If(PcoR010Avalia(),ReportPrint(oReport, @cAliasAK1, @cAliasAK3, @cAliasAKE ),oReport:Finish())},;
			STR0012 )
//"Planilha Resumida"

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
oPlanilha := TRSection():New(oReport,STR0012,{cAliasAK1}, {}, .F., .F.)
//Nao fazer filtro no AK1 pois as perguntas so permitem um orcamento
oPlanilha:SetNoFilter({cAliasAK1})

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
TRCell():New(oPlanilha,	"AK1_CODIGO"	,cAliasAK1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAK1)->AK1_CODIGO})
TRCell():New(oPlanilha,	"AK1_VERSAO"	,cAliasAK1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cRevisa})
TRCell():New(oPlanilha,	"AK1_DESCRI"	,cAliasAK1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAK1)->AK1_DESCRI})
TRCell():New(oPlanilha,	"AK1_INIPER"	,cAliasAK1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAK1)->AK1_INIPER})
TRCell():New(oPlanilha,	"AK1_FIMPER"	,cAliasAK1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAK1)->AK1_FIMPER })
oPlanilha:SetHeaderPage()

oReport:OnPageBreak({||oPlanilha:PrintLine()})

oContaOrc := TRSection():New(oReport,STR0014  ,{cAliasAK3,"AK5"},/*aOrdem*/,.F.,.F.)//"Contas Orcamentarias"
TRCell():New(oContaOrc	,"AK3_CO"		,cAliasAK3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| PcoRetCo((cAliasAK3)->AK3_CO)})
TRCell():New(oContaOrc	,"AK3_NIVEL"	,cAliasAK3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAK3)->AK3_NIVEL})
TRCell():New(oContaOrc	,"AK3_DESCRI"	,cAliasAK3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAK3)->(REPLICATE(".",(VAL(AK3_NIVEL)-1)*3)+AK3_DESCRI)})
TRCell():New(oContaOrc	,"AK3_TIPO"		,cAliasAK3,/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,{|| (cAliasAK3)->(If(AK3_TIPO == "2",STR0011,STR0010))}) //"Analitica"###"Sintetica"
TrPosition():New(oContaOrc, "AK5", 1, {|| xFilial("AK5") + (cAliasAK3)->AK3_CO }) 

//Nao fazer filtro no AK5 
//oPlanilha:SetNoFilter({cAliasAK3,"AK5"})

//oContaOrc:SetLineCondition({||  AK5->(Found())})

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
���          �ExpC2: Alias da tabela de Planilha Orcamentaria (AK1)       ���
���          �ExpC3: Alias da tabela de Contas da Planilha (Ak3)          ���
���          �ExpC4: Alias da tabela de Revisoes da Planilha (AKE)        ���
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
Static Function ReportPrint( oReport, cAliasAK1, cAliasAK3, cAliasAKE )
Local oPlanilha := oReport:Section(1)
Local oContaOrc := oReport:Section(2)

oReport:SetMeter((cAliasAK1)->(LastRec()))
	
dbSelectArea(cAliasAK1)
oPlanilha:Init()
oContaOrc:Init()

dbSelectArea(cAliasAK3)
dbSetOrder(3)
MsSeek(xFilial()+(cAliasAK1)->AK1_CODIGO+cRevisa+"001")
While (cAliasAK3)->(!Eof() .And. 	AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_NIVEL==;
					xFilial("AK3")+(cAliasAK1)->AK1_CODIGO+cRevisa+"001")

	If oReport:Cancel()
		Exit
	EndIf
				
	(cAliasAK3)->(PCOR010_ItR4(AK3_ORCAME,AK3_VERSAO,AK3_CO,oReport,cAliasAK1,cAliasAK3))

	dbSelectArea(cAliasAK3)
	dbSkip()
	
	oReport:IncMeter()

End

oContaOrc:Finish()
oPlanilha:Finish()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOR010_ItR4� Autor � Paulo Carnelossi    � Data �31/05/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de impressao das contas da planilha orcamentaria.    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �PCOR010_It(AK3_ORCAME,AK3_VERSAO,AK3_CO,oReport)            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd - Variavel para cancelamento da impressao pelo usuario���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function PCOR010_ItR4(cOrcame, cVersao, cCO, oReport, cAliasAK1, cAliasAK3)
Local aArea		:= GetArea()
Local aAreaAK3	:= (cAliasAK3)->(GetArea())
Local oContaOrc := oReport:Section(2)

// Se o centro Orcamentario pertence ao filtro que foi selecionado
If ((cAliasAK3)->AK3_CO >= SubStr(MV_PAR03,1,TamSX3('AK3_CO')[1])) .AND. ((cAliasAK3)->AK3_CO <= SubStr(MV_PAR04,1,TamSX3('AK3_CO')[1]) )
	// Se o Nivel pertence ao filtro que foi selecionado
	If ((cAliasAK3)->AK3_NIVEL >= MV_PAR05) .AND. ((cAliasAK3)->AK3_NIVEL <= MV_PAR06 )
		
		oContaOrc:PrintLine()

	EndIf

EndIf

dbSelectArea(cAliasAK3)
dbSetOrder(2)

MsSeek(xFilial()+cOrcame+cVersao+cCO)

While (cAliasAK3)->(!Eof() .And. ;
		AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_PAI == ;
		xFilial("AK3")+cOrcame+cVersao+cCO)

	If oReport:Cancel()
		Exit
	EndIf

	(cAliasAK3)->(PCOR010_ItR4(AK3_ORCAME, AK3_VERSAO, AK3_CO, oReport, cAliasAK1, cAliasAK3))

	dbSelectArea(cAliasAK3)
	dbSkip()
	
	oReport:IncMeter()

End

RestArea(aAreaAK3)
RestArea(aArea)

Return
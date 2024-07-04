#INCLUDE "pcor550.ch"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOR550   �Autor  �Paulo Carnelossi    � Data �  20/12/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Demonstrativo de Saldos Mensal/Acumulado ate o mes          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PCOR550(aPerg)
Default aPerg	:=	{}

PCOR550R4(aPerg)

Return

/*/
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOR550R4� AUTOR � Paulo Carnelossi      � DATA � 12/12/2006 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa de impressao do dem.Resumido saldo mensal           ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOR550R4  (BASEADO NO RELATORIO PCOR520)                    ���
���_DESCRI_  � Programa de impressao do demonstrativo saldo mensal          ���
���_FUNC_    � Esta funcao devera ser utilizada com a sua chamada normal a  ���
���          � partir do Menu do sistema.                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PCOR550R4(aPerg)
Local aArea		:= GetArea()
Local lOk		:= .F.
Local dIniPer, dFimPer, dIniAno

Private cPerg := "PCR550"
Private aSavPar	
Private cCadastro := STR0001 //"Cubos Comparativos - Demonstrativo de Saldo Mensal/Acumulado (Volume Ate o Mes)"
Private cCfg01:=PadL(STR0002,20), cCfg02:=PadL(STR0003,20) //"Previsto"###"Realizado"
Private aPeriodoRef, aPeriodoAcm	

Default aPerg := {}

/*
Pergunta 01 : Codigo Cubo Gerencial? 01
Pergunta 02 : Mes? 05/2006
Pergunta 03 : Qual Moeda? Moeda I
Pergunta 04 : Configuracao do Cubo-1 ? PR
Pergunta 05 : Editar Configuracoes Cubo-1 ? Sim
Pergunta 06 : Configuracao do Cubo-2? RE
Pergunta 07 : Editar Configuracoes Cubo-2? Sim
Pergunta 08 : ConsiderarZerados? Nao
Pergunta 09 : Considerar Cfg. I Cubo? Sim
*/


If Len(aPerg) >  0
	aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
Else
	Pergunte(cPerg, .T.)
EndIf

aSavPar := {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09}

If !Empty(aSavPar[04])
	dbSelectArea("AL3")
	dbSetOrder(1)
	If MsSeek(xFilial()+aSavPar[04])
		cCfg01 := PadL(AllTrim(AL3->AL3_DESCRI),20)
	EndIf
EndIf
If !Empty(aSavPar[06])
	dbSelectArea("AL3")
	dbSetOrder(1)
	If MsSeek(xFilial()+aSavPar[06])
		cCfg02 := PadL(AllTrim(AL3->AL3_DESCRI),20)
	EndIf
EndIf


dIniPer := CTOD("01/"+aSavPar[02])
dFimPer := LastDay(dIniPer)
dIniAno := CTOD("01/01/"+Right(aSavPar[02], 4))
    
aPeriodoRef := { dIniPer, dFimPer }
aPeriodoAcm := { dIniAno, dFimPer }

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef()

If Len(aPerg) == 0 .And. !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf	
oReport:PrintDialog()

RestArea(aArea)
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Paulo Carnelossi       � Data �12/12/2006���
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
Static Function ReportDef()

Local oReport
Local oComparativo
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
oReport := TReport():New("PCOR550",STR0004,"PCR550", ; //"Cubos Comparativos - Demonstrativo de Saldos Mensais"
			{|oReport| ReportPrint(oReport) },;
			STR0004 ) //"Cubos Comparativos - Demonstrativo de Saldos Mensais"

oReport:SetLandScape()
oReport:ParamReadOnly()			

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
oComparativo := TRSection():New(oReport,STR0005 , {}, {}, .F., .F.)   //"Cubos Comparativos"

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
TRCell():New(oComparativo,	"CODIGO"	,"",STR0006/*Titulo*/		,/*Picture*/,70/*Tamanho*/,/*lPixel*/,/*{|| }*/) //"Codigo"
TRCell():New(oComparativo,	"DESCRI"	,"",STR0007/*Titulo*/	,/*Picture*/,50/*Tamanho*/,/*lPixel*/,/*{|| }*/) //"Descricao"

TRCell():New(oComparativo,	"MOVMES_P"	,"",cCfg01+CRLF+STR0008/*Titulo*/		,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT") //"Mes (Cred-Deb)"
TRCell():New(oComparativo,	"MOVMES_R"	,"",cCfg02+CRLF+STR0008/*Titulo*/		,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT") //"Mes (Cred-Deb)"
TRCell():New(oComparativo,	"MOVDIF"	,"",STR0009/*Titulo*/					,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT") //"Mes (Diferenca)"

TRCell():New(oComparativo,	"SLDACU_P"	,"",cCfg01+CRLF+STR0010/*Titulo*/		,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT") //"Acum.(Cred-Deb)"
TRCell():New(oComparativo,	"SLDACU_R"	,"",cCfg02+CRLF+STR0010/*Titulo*/		,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT") //"Acum.(Cred-Deb)"
TRCell():New(oComparativo,	"SLDDIF"	,"",STR0011/*Titulo*/				,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT") //"Acum.(Diferenca)"
oComparativo:Cell("DESCRI"):SetLineBreak()

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Paulo Carnelossi      � Data �13/12/2006���
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
Static Function ReportPrint( oReport )

Local aArea		:= GetArea()
Local aProcessa, aProcComp

aProcessa := PcoRunCube(aSavPar[1], 2, "Pcor550Sld", aSavPar[4], aSavPar[5], (aSavPar[08]==1) , /*aNiveis*/,/*aFilIni*/,/*aFilFim*/,/*lReserv*/, /*aCfgCube*/,/*lProcessa*/,.T./*lVerAcesso*/)

//If Len(aProcessa) > 0
	aProcComp := PcoRunCube(aSavPar[1], 2, "Pcor550Sld", aSavPar[6], aSavPar[7], (aSavPar[08]==1), /*aNiveis*/,/*aFilIni*/,/*aFilFim*/,/*lReserv*/, /*aCfgCube*/,/*lProcessa*/,.T./*lVerAcesso*/)
//EndIf	

Pcor550Imp(oReport, aProcessa, aProcComp)

RestArea(aArea)
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pcor550Sld� Autor � Paulo Carnelossi      � Data �13/12/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de processamento do demonstrativo saldo / mes.       ���
���          �Funcao baseada a do relatorio PCOR520                       ���
���          �sera chamada pela PcoRunCube()                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Pcor550Sld                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd - Variavel para cancelamento da impressao pelo usuario���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Pcor550Sld(cConfig,cChave)
Local aRetorno := {}
Local aRetIni,aRetFim

Local nCrdIni
Local nDebIni

Local nCrdFim
Local nDebFim
Local nMovPer

//saldo do mes
dIni := aPeriodoRef[1]
dFim := aPeriodoRef[2]

aRetIni := PcoRetSld(cConfig,cChave,dIni-1)
nCrdIni := aRetIni[1, aSavPar[3]]
nDebIni := aRetIni[2, aSavPar[3]]

aRetFim := PcoRetSld(cConfig,cChave,dFim)
nCrdFim := aRetFim[1, aSavPar[3]]
nDebFim := aRetFim[2, aSavPar[3]]

nMovCrd := nCrdFim-nCrdIni	
nMovDeb := nDebFim-nDebIni
nMovPer := nMovCrd-nMovDeb

aAdd(aRetorno,nMovPer)

//saldo acumulado
dIni := aPeriodoAcm[1]

aRetIni := PcoRetSld(cConfig,cChave,dIni-1)
nCrdIni := aRetIni[1, aSavPar[3]]
nDebIni := aRetIni[2, aSavPar[3]]

/*--desnecessario pois e igual ao final do mes
aRetFim := PcoRetSld(cConfig,cChave,dFim)
nCrdFim := aRetFim[1, aSavPar[3]]
nDebFim := aRetFim[2, aSavPar[3]]
*/

nMovCrd := nCrdFim-nCrdIni	
nMovDeb := nDebFim-nDebIni
nMovPer := nMovCrd-nMovDeb

aAdd(aRetorno,nMovPer)

Return aRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pcor550Imp   �Autor � Paulo Carnelossi    � Data �13/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de impressao Demonst.Resumido de saldos Mensais      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �PCOR550Imp(lEnd)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd - Variavel para cancelamento da impressao pelo usuario���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Pcor550Imp(oReport, aProcessa, aProcComp)

Local oComparativo := oReport:Section(1)
Local cQuebra := ""
Local nX, nY, nZ
Local nValorCf01, nValorCf02, nValorDifV
Local nValCf01Acum, nValCf02Acum, nValAcumDifV
Local aProcNew := {}
oComparativo:Cell("CODIGO")		:SetBlock({|| Alltrim(aProcessa[nX, 3])+"-"+Alltrim(aProcessa[nX, 1])})
oComparativo:Cell("CODIGO")		:SetBlock({|| Alltrim(aProcNew[nX, 3])+"-"+Alltrim(aProcNew[nX, 1])})
oComparativo:Cell("DESCRI")		:SetBlock({|| aProcNew[nX, 6] })
oComparativo:Cell("MOVMES_P")	:SetBlock({|| nValorCf01   })
oComparativo:Cell("MOVMES_R")	:SetBlock({|| nValorCf02   })
oComparativo:Cell("MOVDIF")		:SetBlock({|| nValorDifV   })
oComparativo:Cell("SLDACU_P")	:SetBlock({|| nValCf01Acum })
oComparativo:Cell("SLDACU_R")	:SetBlock({|| nValCf02Acum })
oComparativo:Cell("SLDDIF")		:SetBlock({|| nValAcumDifV })

oComparativo:Init()

//***************************************************
//Uni�o dos vetores de processameto para apresentar *
// os valores da segunda configura��o.              *
//***************************************************
For nX:= 1 to Len(aProcessa) 
	aAdd( aProcNew , aProcessa[nX])
Next
For nX:= 1 to Len(aProcComp) 

	nPosComp := ASCAN(aProcessa, { |x| x[1] == aProcComp[nx][1] })
	If nPosComp=0
		aAdd( aProcNew , aProcComp[nX])
	EndIf
Next
// Re-ordena a sequencia de chaves do cubo
aProcNew := aSort( aProcNew,,, { |x,y| x[1] < y[1] } )

For nx := 1 To Len(aProcNew)

	nValorCf01  := 0
	nValCf01Acum  := 0
	nValorCf02  := 0
	nValCf02Acum  := 0

	nPosComp := ASCAN(aProcessa, { |x| x[1] == aProcNew[nx][1] })

	If nPosComp > 0
		nValorCf01  	:= aProcessa[nPosComp,2,1]
		nValCf01Acum  	:= aProcessa[nPosComp,2,2]
	EndIf

	nPosComp := ASCAN(aProcComp, { |x| x[1] == aProcNew[nx][1] })
   	If nPosComp > 0
		nValorCf02  := aProcComp[nPosComp,2,1]
		nValCf02Acum  := aProcComp[nPosComp,2,2]
	EndIf
    
	If aSavPar[9] == 1
		nValorDifV  := nValorCf01 - nValorCf02
		nValAcumDifV  := nValCf01Acum - nValCf02Acum
	Else
		nValorDifV  := nValorCf02 - nValorCf01
		nValAcumDifV  := nValCf02Acum - nValCf01Acum
	EndIf	
    
	If (aSavPar[08]==2)
		//************************************************
		// Caso nao apresente valor zero avaliar o valor *
		//************************************************
		If nValorCf01<>0 .or. nValorCf02<>0 .or. nValCf01Acum<>0 .or. nValCf02Acum<>0
			oComparativo:PrintLine()
		EndIf
	Else
		oComparativo:PrintLine()
	EndIf

Next

oComparativo:Finish()

Return              
#INCLUDE "pcor650.ch"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOR650   ºAutor  ³Paulo Carnelossi    º Data ³  06/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Demonstrativo de Saldos Mensal/Acumulado ate o mes          º±±
±±º          ³Baseado em visao Gerencial por Cubo                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOR650(aPerg)

Default aPerg	:=	{}

PCOR650R4(aPerg)

Return

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOR650R4³ AUTOR ³ Paulo Carnelossi      ³ DATA ³ 12/12/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de impressao do dem.Resumido saldo mensal           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOR650R4  (BASEADO NO RELATORIO PCOR520)                    ³±±
±±³_DESCRI_  ³ Programa de impressao do demonstrativo saldo mensal          ³±±
±±³_FUNC_    ³ Esta funcao devera ser utilizada com a sua chamada normal a  ³±±
±±³          ³ partir do Menu do sistema.                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOR650R4(aPerg)
Local aArea		:= GetArea()
Local lOk		:= .F.
Local dIniPer
Local dFimPer
Local dIniAno
Local lOkAcc	:= .T.

Private cPerg := "PCR650"
Private aSavPar
Private aVarPriv	
Private cCadastro := STR0001 //"Comparativos - Visao Ger./Cubo - Dem.Saldo Mensal/Acumulado (Volume Ate o Mes:"
Private cCfg01:=PadL(STR0002,20), cCfg02:=PadL(STR0003,20)  //"Previsto"###"Realizado"
Private aPeriodoRef, aPeriodoAcm	

Default aPerg := {}

/*
Pergunta 01 : Visao Gerencial? 001
Pergunta 02 : Mes? 05/2006
Pergunta 03 : Qual Moeda? Moeda I
Pergunta 04 : Configuracao do Cubo-1 ? PR
Pergunta 05 : Editar Configuracoes Cubo-1 ? Sim
Pergunta 06 : Configuracao do Cubo-2? RE
Pergunta 07 : Editar Configuracoes Cubo-2? Sim
Pergunta 08 : ConsiderarZerados? Nao
Pergunta 09 : Considerar Config.1? Sim
Pergunta 10 : Detalhar Cubos ? Sim
*/

If Len(aPerg) >  0
	aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
Else
	Pergunte(cPerg, .T.)
	 lOkAcc := R650Acesso()
EndIf
If (lOkAcc)
	aSavPar := {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09, MV_PAR10}
	cCadastro := Alltrim(cCadastro)+MV_PAR02+")"
	
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	
	If Len(aPerg) == 0 .And. !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf	
	oReport:PrintDialog()
EndIf
RestArea(aArea)
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Paulo Carnelossi       ³ Data ³12/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local oComparativo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("PCOR650",cCadastro,"PCR650", ; 
			{|oReport| ReportPrint(oReport) },;
			cCadastro ) 

oReport:SetLandScape()
oReport:ParamReadOnly()			

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oComparativo := TRSection():New(oReport,STR0004 , {}, {}, .F., .F.)    //"Visao Gerencial por Cubo"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oComparativo,	"CODIGO"	,"",STR0005/*Titulo*/		,/*Picture*/,70/*Tamanho*/,/*lPixel*/,/*{|| }*/)  //"Codigo"
TRCell():New(oComparativo,	"DESCRI"	,"",STR0006/*Titulo*/	,/*Picture*/,50/*Tamanho*/,/*lPixel*/,/*{|| }*/)  //"Descricao"

TRCell():New(oComparativo,	"MOVMES_P"	,"",cCfg01+CRLF+STR0007/*Titulo*/		,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")  //"Mes (Cred-Deb)"
TRCell():New(oComparativo,	"MOVMES_R"	,"",cCfg02+CRLF+STR0007/*Titulo*/		,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")  //"Mes (Cred-Deb)"
TRCell():New(oComparativo,	"MOVDIF"	,"",STR0008/*Titulo*/					,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT") //"Mes (Diferenca)"

TRCell():New(oComparativo,	"SLDACU_P"	,"",cCfg01+CRLF+STR0009/*Titulo*/		,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")  //"Acum.(Cred-Deb)"
TRCell():New(oComparativo,	"SLDACU_R"	,"",cCfg02+CRLF+STR0009/*Titulo*/		,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT") //"Acum.(Cred-Deb)"
TRCell():New(oComparativo,	"SLDDIF"	,"",STR0010/*Titulo*/				,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT") //"Acum.(Diferenca)"
oComparativo:Cell("DESCRI"):SetLineBreak()

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Paulo Carnelossi      ³ Data ³13/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³que faz a chamada desta funcao ReportPrint()                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³ExpO1: Objeto TReport                                       ³±±
±±³          ³ExpC2: Alias da tabela de Planilha Orcamentaria (AK1)       ³±±
±±³          ³ExpC3: Alias da tabela de Contas da Planilha (Ak3)          ³±±
±±³          ³ExpC4: Alias da tabela de Revisoes da Planilha (AKE)        ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport )

Local aArea		:= GetArea()
Local aProcessa, aProcComp

dbSelectArea("AKN")
dbSetOrder(1)
If dbSeek(xFilial("AKN")+aSavPar[1])

	aVarPriv := {}
	aAdd(aVarPriv, {"aSavPar", aClone(aSavPar)})
	aAdd(aVarPriv, {"aPeriodoRef", aClone(aPeriodoRef)})
	aAdd(aVarPriv, {"aPeriodoAcm", aClone(aPeriodoAcm)})

	aProcessa := 	    PcoCubeVis(AKN->AKN_CODIGO, 2, "Pcor650Sld", aSavPar[4], aSavPar[5], aSavPar[10], , aVarPriv)
	
	If Len(aProcessa) > 0
		aProcComp := 	PcoCubeVis(AKN->AKN_CODIGO, 2, "Pcor650Sld", aSavPar[6], aSavPar[7], aSavPar[10], , aVarPriv)
	EndIf	
	
	Pcor650Imp(oReport, aProcessa, aProcComp)
EndIf

RestArea(aArea)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pcor650Sld³ Autor ³ Paulo Carnelossi      ³ Data ³13/12/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de processamento do demonstrativo saldo / mes.       ³±±
±±³          ³Funcao baseada a do relatorio PCOR520                       ³±±
±±³          ³sera chamada pela PcoRunCube()                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Pcor650Sld                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd - Variavel para cancelamento da impressao pelo usuario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Pcor650Sld(cConfig,cChave)
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pcor650Imp   ³Autor ³ Paulo Carnelossi    ³ Data ³13/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de impressao Demonst.Resumido de saldos Mensais      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOR650Imp(lEnd)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd - Variavel para cancelamento da impressao pelo usuario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pcor650Imp(oReport, aProcessa, aProcComp)

Local oComparativo := oReport:Section(1)
Local cQuebra := ""
Local nX, nY, nZ
Local nValorCf01, nValorCf02, nValorDifV
Local nValCf01Acum, nValCf02Acum, nValAcumDifV

oComparativo:Cell("CODIGO")		:SetBlock({|| Alltrim(aProcessa[nX, 3])+"-"+Alltrim(aProcessa[nX, 1])})
oComparativo:Cell("DESCRI")		:SetBlock({|| aProcessa[nX, 6] })
oComparativo:Cell("MOVMES_P")	:SetBlock({|| nValorCf01   })
oComparativo:Cell("MOVMES_R")	:SetBlock({|| nValorCf02   })
oComparativo:Cell("MOVDIF")		:SetBlock({|| nValorDifV   })
oComparativo:Cell("SLDACU_P")	:SetBlock({|| nValCf01Acum })
oComparativo:Cell("SLDACU_R")	:SetBlock({|| nValCf02Acum })
oComparativo:Cell("SLDDIF")		:SetBlock({|| nValAcumDifV })

oComparativo:Init()

For nx := 1 To Len(aProcessa)

	nPosComp := ASCAN(aProcComp, { |x| x[1] == aProcessa[nx][1] })

	nValorCf01  := aProcessa[nX,2,1]
	nValCf01Acum  := aProcessa[nX,2,2]
	nValorCf02  := 0
	nValCf02Acum  := 0
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

	oComparativo:PrintLine()

Next

oComparativo:Finish()

Return              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R650AcessoºAutor  ³Fabricio Pequeno    º Data ³  05/16/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Fução para verificar acesso a tabela AKN                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function R650Acesso()

Local lRet 		:= .T.
Local aArea		:= GetArea()

dbSelectArea("AKN")
dbSetOrder(1)
lRet := !Empty(MV_PAR01) .And. dbSeek(xFilial("AKN")+MV_PAR01)

If SuperGetMV("MV_PCO_AKN",.F.,"2")!="1"	//- 1-Verifica acesso por entidade
	lRet := .T.                        		//- 2-Nao verifica o acesso por entidade
Else
	lRet := ( PcoDirEnt_User("AKN", AKN->AKN_CODIGO, __cUserID, .F.) # 0 ) // 0=bloqueado
	If ! lRet
		Aviso(STR0013,STR0014,{STR0015},2)	//"Atenção"###"Usuario sem acesso a esta configuração de visao gerencial. "###"Fechar"
		lRet := .F.
	Else
	    lRet := .T.
	EndIf
EndIf

RestArea(aArea)
Return lRet

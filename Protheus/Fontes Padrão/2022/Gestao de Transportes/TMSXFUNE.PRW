#INCLUDE "TMSXFUNE.CH"
#INCLUDE "PROTHEUS.CH"

//-- Diretivas array aParGerNfs de parametros da funcao TmsGerNfs
#DEFINE APARCDRORI 1
#DEFINE APARCDRCAL 2
#DEFINE APARCODCLI 3
#DEFINE APARLOJCLI 4
#DEFINE APARDOCTMS 5
#DEFINE APARPRDFIS 6
#DEFINE APARSERVIC 7
#DEFINE APARQTDVOL 8
#DEFINE APARPESO   9
#DEFINE APARDADSF2 10
#DEFINE APARCPOSF2 11
#DEFINE APARCMPFRT 12
#DEFINE APARF4ISS  13
#DEFINE APARTES    14
#DEFINE APARFATSE1 15
#DEFINE APARSERNFS 16
#DEFINE APARVFCONT 17
#DEFINE APARESPECI 18

//-- Diretivas array aPontEntr de parametros da funcao TmsGerNfs
#DEFINE APERECISS 1

//-- Diretivas array aParGrvDT6 de parametros da funcao TmsGrvDT6
#DEFINE ADT6FILORI 1
#DEFINE ADT6FILDES 2
#DEFINE ADT6FILNEG 3
#DEFINE ADT6FILDEB 4
#DEFINE ADT6FILDOC 5
#DEFINE ADT6DOC    6
#DEFINE ADT6SERIE  7
#DEFINE ADT6CLIREM 8
#DEFINE ADT6LOJREM 9
#DEFINE ADT6CLIDES 10
#DEFINE ADT6LOJDES 11
#DEFINE ADT6CLIDEV 12
#DEFINE ADT6LOJDEV 13
#DEFINE ADT6CLICAL 14
#DEFINE ADT6LOJCAL 15
#DEFINE ADT6CDRORI 16
#DEFINE ADT6CDRDES 17
#DEFINE ADT6CDRCAL 18
#DEFINE ADT6CLICON 19
#DEFINE ADT6LOJCON 20
#DEFINE ADT6CLIDPC 21
#DEFINE ADT6LOJDPC 22
#DEFINE ADT6PRZENT 23
#DEFINE ADT6DATEMI 24
#DEFINE ADT6HOREMI 25
#DEFINE ADT6USRGER 26
#DEFINE ADT6DOCTMS 27
#DEFINE ADT6STATUS 28
#DEFINE ADT6BLQDOC 29
#DEFINE ADT6PRIPER 30
#DEFINE ADT6IMP    31
#DEFINE ADT6TIPFRE 32
#DEFINE ADT6DEVFRE 33
#DEFINE ADT6SERTMS 34
#DEFINE ADT6LOTNFC 35
#DEFINE ADT6MOEDA  36
#DEFINE ADT6TIPTRA 37
#DEFINE ADT6SERVIC 38
#DEFINE ADT6CODMSG 39
#DEFINE ADT6SITCTE 40
#DEFINE ADT6RETCTE 41
#DEFINE ADT6VALMER 42
#DEFINE ADT6PESOM3 43
#DEFINE ADT6PESCOB 44
#DEFINE ADT6QTDUNI 45
#DEFINE ADT6QTDVOL 46
#DEFINE ADT6VOLORI 47
#DEFINE ADT6PESO   48
#DEFINE ADT6VALFRE 49
#DEFINE ADT6VALIMP 50
#DEFINE ADT6VALTOT 51
#DEFINE ADT6VALFAT 52
#DEFINE ADT6ACRESC 53
#DEFINE ADT6DECRES 54
#DEFINE ADT6TABFRE 55
#DEFINE ADT6TIPTAB 56
#DEFINE ADT6SEQTAB 57
#DEFINE ADT6NRCONT 58
#DEFINE ADT6CODNEG 59
#DEFINE ADT6FILDCO 60
#DEFINE ADT6DOCDCO 61
#DEFINE ADT6SERDCO 62

//-- Diretivas array aPontEntr de parametros da funcao TmsGrvDT6
#DEFINE APEANTDT6 1
#DEFINE APEPOSDT6 2

//-- Diretivas array aRetDT6 de parametros da funcao TmsGrvDT6
#DEFINE RDT6FILDOC 1
#DEFINE RDT6DOC    2
#DEFINE RDT6SERIE  3
#DEFINE RDT6RECNO  4

//-- Diretivas array aRetVerImp de parametros da funcao TmsVerImpC
#DEFINE RIMPSERNFC 1
#DEFINE RIMPCMPFRT 2
#DEFINE RIMPVALFRE 3
#DEFINE RIMPVALIMP 4
#DEFINE RIMPVALTOT 5
#DEFINE RIMPCODPRO 6

Static lDUISEROUT //-- Serie Outra UF

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsGerNfs
Prepara e realiza a geração de uma nota fiscal de saída conforme parâmetros. 
 -> Monta cabeçalho e itens;
 -> Chama a função MaNfs2Nfs para geração da NFS;
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 26/01/2017
@param [aParGerNfs], Array, Contém os parâmetros necessários para a geração
@param [aPontEntr], Array, Contém o nome de funções de pontos de entrada
@return cNumNFS Retorna o número da NFS gerada
@obs INFORMAÇÕES ARRAY PARÂMETRO aParGerNfs
@obs aParGerNfs[1]  APARCDRORI	- cCdrOri (Região de origem)
@obs aParGerNfs[2]  APARCDRCAL	- cCdrCal (Região de cálculo)
@obs aParGerNfs[3]  APARCODCLI	- cCliente (Cliente pagador do frete)
@obs aParGerNfs[4]  APARLOJCLI	- cLoja (Loja do cliente pagador do frete)
@obs aParGerNfs[5]  APARDOCTMS	- cDocTMS (DOCTMS)
@obs aParGerNfs[6]  APARPRDFIS	- cCodPro (Produto de cálculo)
@obs aParGerNfs[7]  APARSERVIC	- cSrv (Serviço de negociação)
@obs aParGerNfs[8]  APARQTDVOL	- nQtdVol (Quantidade de Volume)
@obs aParGerNfs[9]  APARPESO	- nPeso (Peso)
@obs aParGerNfs[10] APARDADSF2	- aDadosSF2 (Informações SF2, opcional)
@obs aParGerNfs[11] APARCPOSF2	- cCposSF2 (Campos para acumular, opcional)
@obs aParGerNfs[12] APARCMPFRT	- aCmpFrt (Composição de frete)
@obs aParGerNfs[13] APARF4ISS	- cF4_ISS (Calculo do preco com ISS)
@obs aParGerNfs[14] APARTES		- cTES (TES)
@obs aParGerNfs[15] APARFATSE1	- bFatSE1 (Bloco de código para geração do SE1)
@obs aParGerNfs[16] APARSERNFS	- cSerNF (Série da NF)
@obs aParGerNfs[17] APARVFCONT	- aVFContr (Retorno da função TMSA491VlrC, opcional)
@obs aParGerNfs[18] APARESPECI	- cEspecie (Espécie)
@obs INFORMAÇÕES ARRAY PARÂMETRO aPontEntr
@obs aPontEntr[1] APERECISS		- Ponto de entrada que permite alterar a regra de recolhimento do ISS
/*/
//-------------------------------------------------------------------------------------------------
Function TmsGerNfs(aParGerNfs, aPontEntr,aDoctos)

	Local aCabecNF   := {}
	Local aItemNF    := {}
	Local aStruSF2   := SF2->(DbStruct())
	Local aStruSD2   := SD2->(DbStruct())
	Local aDadosSF2  := {} 
	Local aItensNF   := {}
	Local aSF2       := {}
	Local aSD2       := {}
	Local aDocOri    := {}
	Local aVFContr   := {}
	Local aAreaSB1   := SB1->(GetArea())
	Local aAreaSF4   := SF4->(GetArea())
	Local aAreaDUY   := DUY->(GetArea())
	Local aAreaSA1   := SA1->(GetArea())
	Local aAreaDUI   := DUI->(GetArea())
	Local aArea      := GetArea()
	Local cCdrOri    := ""
	Local cCdrCal    := ""
	Local cEstCal    := ""
	Local cEstOri    := ""
	Local cCliente   := ""
	Local cLoja      := ""
	Local cTipoCli   := ""
	Local cCondPag   := ""
	Local cRecISS    := ""
	Local cA1_INCISS := ""
	Local cRetPE     := ""
	Local cDocTMS    := ""
	Local cCodPro    := ""
	Local cCodISS    := ""
	Local cTipoPro   := ""
	Local cUniMed    := ""
	Local cSegUM     := ""
	Local cLocPad    := ""
	Local cCposSF2   := ""
	Local cF4_ISS    := ""
	Local cTES       := ""
	Local cSrv       := ""
	Local cItem      := ""
	Local cPERECISS  := ""
	Local cTextoSF2  := ""
	Local cNumNFS    := ""
	Local cSerNF     := ""
	Local cEspecie 	 := ""
	Local cIncISS    := Iif(SuperGetMv("MV_INCISS", , .F.), "S", "N") //-- TES Incide ISS (S/N)
	Local nAliqISS   := 0
	Local nQtdVol    := 0
	Local nPeso      := 0
	Local nCountA    := 0
	Local nCountB    := 0
	Local nPosProd   := 0
	Local nPosTes    := 0
	Local nPosItem   := 0
	Local nPosPrcVen := 0
	Local nPosTotal  := 0
	Local nPosPrUnit := 0
	Local nPrcVen    := 0
	Local lAglutCtb  := .F.
	Local lCtbOnLine := .F.
	Local lMostraCtb := .F.
	Local lCAT83     := SuperGetMV("MV_CAT8309", , .T.)
	Local lD2Aglut   := GetMV("MV_TMSAGD2", , .F.)
	Local lNoRecImp  := .F.
	Local lPERECISS  := .F. //-- PE -> Permite alterar a regra de recolhimento do ISS
	Local bFatSE1    := {|| .F.}
	Local bFiscalSF2 := Nil
	Local cConta	 := ''
	Local lDocApoio  := .F.
	
	Local nPosBasISS := 0
	Local nPosValISS := 0
	Local nPosCompTF := 0
	Local nDiferISS  := 0
	Local lPraMenos  := .T.

	Default aParGerNfs := {}
	Default aPontEntr  := {}
	Default aDoctos    := {}

	If Len(aDoctos) > 0 .And. Len(aDoctos[1]) >= 3
		lDocApoio := TMSVeApoio(aDoctos[1][2],aDoctos[1][3],aDoctos[1][4])
	EndIf

	//-- Identificacao dos parametros recebidos e para nao possuirem valores nulos
	cCdrOri   := Iif(Len(aParGerNfs) < APARCDRORI .Or. aParGerNfs[APARCDRORI] == Nil, ""      , aParGerNfs[APARCDRORI])
	cCdrCal   := Iif(Len(aParGerNfs) < APARCDRCAL .Or. aParGerNfs[APARCDRCAL] == Nil, ""      , aParGerNfs[APARCDRCAL])
	cCliente  := Iif(Len(aParGerNfs) < APARCODCLI .Or. aParGerNfs[APARCODCLI] == Nil, ""      , aParGerNfs[APARCODCLI])
	cLoja     := Iif(Len(aParGerNfs) < APARLOJCLI .Or. aParGerNfs[APARLOJCLI] == Nil, ""      , aParGerNfs[APARLOJCLI])
	cDocTMS   := Iif(Len(aParGerNfs) < APARDOCTMS .Or. aParGerNfs[APARDOCTMS] == Nil, ""      , aParGerNfs[APARDOCTMS])
	cCodPro   := Iif(Len(aParGerNfs) < APARPRDFIS .Or. aParGerNfs[APARPRDFIS] == Nil, ""      , aParGerNfs[APARPRDFIS])
	cSrv      := Iif(Len(aParGerNfs) < APARSERVIC .Or. aParGerNfs[APARSERVIC] == Nil, ""      , aParGerNfs[APARSERVIC])
	nQtdVol   := Iif(Len(aParGerNfs) < APARQTDVOL .Or. aParGerNfs[APARQTDVOL] == Nil, 0       , aParGerNfs[APARQTDVOL])
	nPeso     := Iif(Len(aParGerNfs) < APARPESO   .Or. aParGerNfs[APARPESO]   == Nil, 0       , aParGerNfs[APARPESO]  )
	aDadosSF2 := Iif(Len(aParGerNfs) < APARDADSF2 .Or. aParGerNfs[APARDADSF2] == Nil, {}      , aParGerNfs[APARDADSF2])
	cCposSF2  := Iif(Len(aParGerNfs) < APARCPOSF2 .Or. aParGerNfs[APARCPOSF2] == Nil, ""      , aParGerNfs[APARCPOSF2])
	aCmpFrt   := Iif(Len(aParGerNfs) < APARCMPFRT .Or. aParGerNfs[APARCMPFRT] == Nil, {}      , aParGerNfs[APARCMPFRT])
	cF4_ISS   := Iif(Len(aParGerNfs) < APARF4ISS  .Or. aParGerNfs[APARF4ISS]  == Nil, ""      , aParGerNfs[APARF4ISS] )
	cTES      := Iif(Len(aParGerNfs) < APARTES    .Or. aParGerNfs[APARTES]    == Nil, ""      , aParGerNfs[APARTES]   )
	bFatSE1   := Iif(Len(aParGerNfs) < APARFATSE1 .Or. aParGerNfs[APARFATSE1] == Nil, {|| .F.}, aParGerNfs[APARFATSE1])
	cSerNF    := Iif(Len(aParGerNfs) < APARSERNFS .Or. aParGerNfs[APARSERNFS] == Nil, ""      , aParGerNfs[APARSERNFS])
	aVFContr  := Iif(Len(aParGerNfs) < APARVFCONT .Or. aParGerNfs[APARVFCONT] == Nil, {}      , aParGerNfs[APARVFCONT])
	cEspecie  := Iif(Len(aParGerNfs) < APARESPECI .Or. aParGerNfs[APARESPECI] == Nil, Nil     , aParGerNfs[APARESPECI])
	cPERECISS := Iif(Len(aPontEntr)  < APERECISS  .Or. aPontEntr[APERECISS]   == Nil, ""      , aPontEntr[APERECISS]  )

	lPERECISS := ExistBlock(cPERECISS)
	
	//-- Carrega grupo de perguntas de contabilizacao
	Pergunte("TMB200", .F.)
	lAglutCtb  := (MV_PAR03 == 1)
	lCtbOnLine := (MV_PAR04 == 1)

	//-- Identifica estado de origem e calculo
	cEstOri := Posicione("DUY", 1, xFilial("DUY") + cCdrOri, "DUY_EST")
	cEstCal := Posicione("DUY", 1, xFilial("DUY") + cCdrCal, "DUY_EST")
	
	//-- Informacoes do cliente
	cTipoCli   := Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_TIPO")
	cCondPag   := Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_COND")
	cRecISS    := Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_RECISS")
	cA1_INCISS := Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_INCISS")
	
	If lPERECISS //-- PE -> Permite alterar a regra de recolhimento do ISS
		cRetPE := ExecBlock(cPERECISS, .F., .F., {cCliente, cLoja, cRecISS})
		If ValType(cRetPE) == "C"
			cRecISS := cRetPE
		EndIf
	EndIf

	//-- Tratamento: Aliquota de ISS
	DUY->(DbSetOrder(1))
	If DUY->(DbSeek(xFilial("DUY") + cCdrCal))
		//-- Verifica se foi informada a aliquota do ISS para regiao
		nAliqISS := DUY->DUY_ALQISS
		If	nAliqISS == 0
			nAliqISS := SuperGetMv("MV_ALIQISS", ,0)
		EndIf
	EndIf

	If Empty(cCodPro)
		DUI->(DbSetOrder(1))
		If DUI->(DbSeek(xFilial("DUI") + cDocTMS))
			cCodPro := Iif(! Empty(DUI->DUI_PRDCIF), DUI->DUI_PRDCIF, DUI->DUI_CODPRO)
		EndIf
	EndIf

	//-- Tratamento: Produto de Calculo (Dados do Produto)
	SB1->(DbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1") + cCodPro))
		cCodISS  := SB1->B1_CODISS
		cTipoPro := SB1->B1_TIPO
		cUniMed  := SB1->B1_UM
		cSegUM   := SB1->B1_SEGUM
		cLocPad  := SB1->B1_LOCPAD
		cConta	 := SB1->B1_CONTA
	EndIf

	//Tratamento para documentos de apoio aglutinados para ajustar arredondamentos de ISS - DLOGTMS02-18947
	If lDocApoio .And. cF4_ISS == "S" .And. nAliqISS > 0
		nPosBasISS := AScan(aDadosSF2, { |x|  AllTrim(x[1]) == "F2_BASEISS" })
		nPosValISS := AScan(aDadosSF2, { |x|  AllTrim(x[1]) == "F2_VALISS" })
		
		If nPosBasISS > 0 .And. nPosValISS > 0
			aDadosSF2[nPosValISS][2] := A410Arred( aDadosSF2[nPosBasISS][2] * (nAliqISS/100), "F2_VALISS")
			
			For nCountA := 1 To Len(aCmpFrt)
				nPosCompTF := AScan(aCmpFrt[nCountA][2], { |x|  AllTrim(x[3]) == "TF" })

				//Se tem diferenca no calculo, ajusta os valores				
				If nPosCompTF > 0 .And. aCmpFrt[nCountA][2][nPosCompTF][5] != aDadosSF2[nPosValISS][2]

					//Guarda valor da diferenca
					nDiferISS := aCmpFrt[nCountA][2][nPosCompTF][5] - aDadosSF2[nPosValISS][2]
					//Ajusta totalizador dos componetes
					aCmpFrt[nCountA][2][nPosCompTF][5] := aDadosSF2[nPosValISS][2]
					//Guarda se a diferenca é pra mais ou para menos
					lPraMenos := ( nDiferISS > 0 )
					//Tira sinal da diferenca pra facilitar entendimento da logica
					nDiferISS  := Abs(nDiferISS)

					//Rateio da diferenca pelos componentes
					For nCountB := 1 To Len(aCmpFrt[nCountA][2])
						If aCmpFrt[nCountA][2][nCountB][3] != "TF"

							//Se diferenca pra menos
							If lPraMenos
								//Se a diferenca cabe no valor atual de imposto
								If aCmpFrt[nCountA][2][nCountB][5] >= nDiferISS
									aCmpFrt[nCountA][2][nCountB][5] -= nDiferISS
									nDiferISS := 0
								//Se a diferenca for maior que o valor do imposto deste componente
								Else
									nDiferISS -= aCmpFrt[nCountA][2][nCountB][5]
									aCmpFrt[nCountA][2][nCountB][5] := 0
								Endif

							//Se diferenca pra mais
							Else
								//Se a o novo imposto + diferenca não for maior que a base de calculo docomponente
								If aCmpFrt[nCountA][2][nCountB][5] + nDiferISS <= aCmpFrt[nCountA][2][nCountB][2]
									aCmpFrt[nCountA][2][nCountB][5] += nDiferISS
									nDiferISS := 0
								//Se a base de calculo for menor ou igual a do componente
								Else
									aCmpFrt[nCountA][2][nCountB][5] := aCmpFrt[nCountA][2][nCountB][2]
									nDiferISS -= aCmpFrt[nCountA][2][nCountB][2]
								Endif
							EndIf

							//Se Zerou a diferenca sai do loop
							If nDiferISS == 0
								Exit
							EndIf
							
						EndIf
					Next
				EndIf
			Next
		EndIf
	EndIf

	//-- Monta cabecalho da Nota Fiscal
	Aadd(aCabecNF, {"F2_FILIAL" , xFilial("SF2")    , NIL})
	Aadd(aCabecNF, {"F2_CLIENTE", cCliente          , NIL})
	Aadd(aCabecNF, {"F2_LOJA"   , cLoja             , NIL})
	Aadd(aCabecNF, {"F2_TIPO"   , "N"               , NIL})
	Aadd(aCabecNF, {"F2_TIPOCLI", cTipoCli          , NIL})
	Aadd(aCabecNF, {"F2_COND"   , cCondPag          , NIL})
	Aadd(aCabecNF, {"F2_VOLUME1", nQtdVol           , NIL})
	Aadd(aCabecNF, {"F2_PLIQUI" , nPeso             , NIL})
	Aadd(aCabecNF, {"F2_PBRUTO" , nPeso             , NIL})
	Aadd(aCabecNF, {"F2_EMISSAO", dDataBase         , NIL})
	Aadd(aCabecNF, {"F2_HORA"   , SubStr(Time(),1,5), NIL})
	Aadd(aCabecNF, {"F2_REGIAO" , cCdrOri           , NIL})
	Aadd(aCabecNF, {"F2_EST"    , cEstCal           , NIL})
	Aadd(aCabecNF, {"F2_RECISS" , cRecIss           , NIL})
	Aadd(aCabecNF, {"F2_MOEDA"  , 1                 , NIL})

	//-- Ajusta o cabecalho da NF conforme necessidade da funcao MaNfs2Nfs()
	For nCountA := 1 To Len(aStruSF2)

		If Len(aDadosSF2) > 0 .And. AllTrim(aStruSF2[nCountA, 1]) $ cCposSF2
			nPos := AScan(aDadosSF2, {|x| AllTrim(x[1]) == AllTrim(aStruSF2[nCountA,1])} )
			Iif(nPos > 0, AAdd(aSF2, aDadosSF2[nPos, 2]), )
		Else
			nPos := Ascan(aCabecNF, { |x| AllTrim(x[1]) == AllTrim(aStruSF2[nCountA][1]) })
			Do Case
			Case (nPos > 0)
				AAdd(aSF2, aCabecNF[nPos, 2])
			Case (aStruSF2[nCountA][2] $ "C/M")
				AAdd(aSF2, "")
			Case (aStruSF2[nCountA][2] == "N")
				AAdd(aSF2, 0)
			Case (aStruSF2[nCountA][2] == "D")
				AAdd(aSF2, CtoD("  /  /  "))
			Case (aStruSF2[nCountA][2] == "L")
				AAdd(aSF2, .F.)
			EndCase
		EndIf
	Next nCountA

	//-- Monta itens da Nota Fiscal
	For nCountA := 1 To Len(aCmpFrt)
		//-- Percorre a composicao do frete e vincula aos itens da Nota Fiscal
		For nCountB := 1 To Len(aCmpFrt[nCountA,2])
		
			If aCmpFrt[nCountA, 2, nCountB, 3] <> "TF"

				aItemNF := {}
				nPrcVen := A410Arred(aCmpFrt[nCountA, 2, nCountB, 2], "C6_PRCVEN")

				//-- Calculo do Preco com ISS
				If cF4_ISS == "S"
					If Empty(SF4->F4_AGRISS) 
						If cIncISS == "N" .And. (cA1_INCISS == "N" .Or. Empty(cIncISS))
							nPrcVen := a410Arred(nPrcVen / (1-(nAliqISS/100)), "D2_PRCVEN")
						Else
							If aCmpFrt[nCountA, 2, nCountB, 6] > 0
								nPrcVen := A410Arred(aCmpFrt[nCountA, 2, nCountB, 6], "D2_PRCVEN")
							Else
								nPrcVen := A410Arred(aCmpFrt[nCountA, 2, nCountB, 2], "D2_PRCVEN")
							EndIf
						EndIf
					Else
						nPrcVen := A410Arred(aCmpFrt[nCountA, 2, nCountB, 2], "D2_PRCVEN")
					EndIf
				EndIf

				If lD2Aglut
					If !Empty(aItensNF)
						nPosProd := AScan(aItensNF[Len(aItensNF)] , {|x| x[1] = "D2_COD"})
						nPosTes  := AScan(aItensNF[Len(aItensNF)] , {|x| x[1] = "D2_TES"})
						nPosItem := AScan(aItensNF, {|x| x[nPosProd][2] = cCodPro .And. x[nPosTes][2] = cTES})
					EndIf

					If nPosItem > 0
						nPosPrcVen := AScan(aItensNF[nPosItem] , {|x| x[1] = "D2_PRCVEN"})
						nPosTotal  := AScan(aItensNF[nPosItem] , {|x| x[1] = "D2_TOTAL" })
						nPosPrUnit := AScan(aItensNF[nPosItem] , {|x| x[1] = "D2_PRUNIT"})
					EndIf
				EndIf

				If nPosItem == 0

					//-- Controla a numeracao dos itens da Nota Fiscal
					cItem := Soma1(cItem)

					Aadd(aItemNF, {'D2_FILIAL' , xFilial("SD2"), Nil})
					Aadd(aItemNF, {'D2_TIPO'   , 'N'           , Nil})
					Aadd(aItemNF, {'D2_CLIENTE', cCliente      , Nil})
					Aadd(aItemNF, {'D2_LOJA'   , cLoja         , Nil})
					Aadd(aItemNF, {'D2_ITEM'   , cItem         , Nil})
					Aadd(aItemNF, {'D2_COD'    , cCodPro       , Nil})
					Aadd(aItemNF, {'D2_TP'     , cTipoPro      , Nil})
					Aadd(aItemNF, {'D2_UM'     , cUniMed       , Nil})
					Aadd(aItemNF, {'D2_SEGUM'  , cSegUM        , Nil})
					Aadd(aItemNF, {'D2_LOCAL'  , cLocPad       , Nil})
					Aadd(aItemNF, {'D2_SERVIC' , cSrv          , Nil})
					Aadd(aItemNF, {'D2_QUANT'  , 1             , Nil})
					Aadd(aItemNF, {'D2_PRCVEN' , nPrcVen       , Nil})
					Aadd(aItemNF, {'D2_TOTAL'  , nPrcVen       , Nil})
					Aadd(aItemNF, {'D2_PRUNIT' , nPrcVen       , Nil})
					Aadd(aItemNF, {'D2_EMISSAO', dDataBase     , Nil})
					Aadd(aItemNF, {'D2_EST'    , cEstCal       , Nil})
					Aadd(aItemNF, {'D2_TES'    , cTES          , Nil})
					Aadd(aItemNF, {'D2_ALIQISS', nAliqISS      , Nil})
					Aadd(aItemNF, {'D2_CODISS' , cCodISS       , NIL})
					AAdd(aItemNF, {'D2_CONTA'  , cConta		   , Nil})

					//-- CAT/83
					If lCAT83
						Aadd(aItemNF, {'D2_CODLAN', Iif(cTES == SF4->F4_CODIGO,;
								                         SF4->F4_CODLAN,;
								                         Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_CODLAN")), Nil})
					EndIf

					AAdd(aItensNF, AClone(aItemNF))
					
				Else
					aItensNF[nPosItem][nPosPrcVen][2] += nPrcVen
					aItensNF[nPosItem][nPosTotal][2]  += nPrcVen
					aItensNF[nPosItem][nPosPrUnit][2] += nPrcVen
				EndIf

				//-- Vincula o item na composicao do frete
				aCmpFrt[nCountA, 2, nCountB, 4] := cItem

			EndIf
		Next nCountB
	Next nCountA

	//-- Ajusta os itens da NF conforme necessidade da funcao MaNfs2Nfs()
	For nCountA := 1 To Len(aItensNF)
	
		AAdd(aDocOri, 0)
		AAdd(aSD2, {})
		
		For nCountB := 1 To Len(aStruSD2)
			nPos := Ascan(aItensNF[nCountA], {|x| AllTrim(x[1]) == AllTrim(aStruSD2[nCountB][1])})
			Do Case
			Case (nPos > 0)
				AAdd(aSD2[nCountA], aItensNF[nCountA, nPos, 2])
			Case (aStruSD2[nCountB][2] $ "C/M")
				AAdd(aSD2[nCountA], "")
			Case (aStruSD2[nCountB][2] == "N")
				AAdd(aSD2[nCountA], 0)
			Case (aStruSD2[nCountB][2] == "D")
				AAdd(aSD2[nCountA], CtoD("  /  /  "))
			Case (aStruSD2[nCountB][2] == "L")
				AAdd(aSD2[nCountA], .F.)
			EndCase
			
		Next nCountB
	Next nCountA

	//-- Realiza a geracao da nota fiscal de saida
	If aVFContr != Nil
		If Len(aVFContr) == 0 .Or.;
		  (Len(aVFContr)  > 0 .And. (aVFContr[1] == 0 .Or. !aVFContr[2]))
		  
			//-- Se o contrato nao estiver configurado c/ valor fixo ou o contrato estiver configurado
			//-- com valor fixo (variavel), gera a nota fiscal considerando os valores acumulados
			cTextoSF2  := 'MaFisAlt("NF_UFORIGEM", cEstOri , , , , , , .F. /*lRecal*/),'
			cTextoSF2  += 'MaFisAlt("NF_UFDEST", cEstCal, , , , , , .F./*lRecal*/ ),'
			cTextoSF2  += 'MaFisAlt("NF_ESPECIE" , cEspecie, , , , , , .F. /*lRecal*/)'
			bFiscalSF2 := &('{||' + cTextoSF2 + '}')
			lNoRecImp  := .T.

		ElseIf aVFContr[2] .And. aVFContr[1] > 0
		
			//-- Se o contrato estiver configurado c/ valor fixo, gera a nota fiscal recalculando
			//-- os valores dos impostos
			bFiscalSF2 := {|| }
			lNoRecImp  := .F.

		EndIf
	EndIf
	
	cNumNFS := MaNfs2Nfs( ,;
	                      ,;
	                      cCliente,;
	                      cLoja,;
	                      cSerNf,;
	                      lMostraCtb,;
	                      lAglutCtb,;
	                      lCtbOnLine,;
	                      ,;
	                      ,;
	                      ,;
	                      ,;
	                      ,;
	                      ,;
	                      ,;
	                      ,;
	                      ,;
	                      ,;
	                      aDocOri,;
	                      aSD2,;
	                      aSF2,;
	                      .T.,;
	                      bFiscalSF2,;
	                      ,;
	                      bFatSE1)
	                      
	cNumNFS := PadR(cNumNFS, Len(SF2->F2_DOC))
	
	RestArea(aAreaSB1)
	RestArea(aAreaSF4)
	RestArea(aAreaDUY)
	RestArea(aAreaSA1)
	RestArea(aAreaDUI)
	RestArea(aArea)

Return cNumNFS

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsGrvLot
Realiza a criação de um lote (DTP) de notas fiscais
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 30/01/2017
@param [cFilOri], Caracter, Filial origem do lote (opcional, default: cFilAnt)
@param [cLotNfc], Caracter, Número do lote (opcional, default: sequência SX8)
@param [dDatLot], Data, Data do lote (opcional, default: dDataBase)
@param [cHorLot], Caracter, Hora do lote (opcional, default: Time())
@param [nQtdLot], Numérico, Quantidade total de documentos do lote (opcional, default: 1)
@param [nQtdDig], Numérico, Quantidade de documentos digitados do lote (opcional, default: 1)
@param [cStatus], Caracter, Status do lote (opcional, default: 3-Calculado)
@param [cTipLot], Caracter, Tipo do lote (opcional, default: 3-Eletronico ou 1-Normal dependendo do parâmetro MV_TMSCTE)
@return cLotNfc Número do lote criado
/*/
//-------------------------------------------------------------------------------------------------
Function TmsGrvLot(cFilOri, cLotNfc, dDatLot, cHorLot, nQtdLot, nQtdDig, cStatus, cTipLot)

	Local aArea   := GetArea()
	Local lTMSCTe := SuperGetMv("MV_TMSCTE", .F., .F.) //-- Parametro do CT-e ativo

	Default cFilOri := cFilAnt
	Default cLotNfc := ""
	Default dDatLot := dDataBase
	Default cHorLot := StrTran(Left(Time(), 5), ":", "")
	Default nQtdLot := 1
	Default nQtdDig := 1
	Default cStatus := StrZero(3, Len(DTP->DTP_STATUS)) //-- 3=Calculado
	Default cTipLot := Iif(lTMSCTe, StrZero(3, Len(DTP->DTP_TIPLOT)) /* 3=Eletronico */, StrZero(1, Len(DTP->DTP_TIPLOT)) /* 1=Normal */)

	If Empty(cLotNfc)
		cLotNfc := CriaVar("DTP_LOTNFC")
		If __lSX8
			ConfirmSX8()
		EndIf
	EndIf

	RecLock('DTP', .T.)
	DTP->DTP_FILIAL := xFilial('DTP')
	DTP->DTP_FILORI := cFilOri
	DTP->DTP_LOTNFC := cLotNfc
	DTP->DTP_DATLOT := dDatLot
	DTP->DTP_HORLOT := cHorLot
	DTP->DTP_QTDLOT := nQtdLot
	DTP->DTP_QTDDIG := nQtdDig
	DTP->DTP_STATUS := cStatus
	DTP->DTP_TIPLOT := cTipLot
	DTP->(MsUnlock())

	RestArea(aArea)

Return cLotNfc

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsGrvDT6
Realiza a gravação de um documento de transporte (DT6)
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 30/01/2017
@param [aParGrvDT6], Array, Contém os parâmetros necessários para a gravação
@param [aPontEntr], Array, Contém o nome de funções de pontos de entrada
@param [lGrvInfSE1], Lógico, Grava informações da DT6 baseadas na SE1 posicionada
@return aRetDT6 Array com informações do documento de transporte criado (DT6)
@obs INFORMAÇÕES ARRAY PARÂMETRO aParGrvDT6
@obs aParGrvDT6[1]  ADT6FILORI - cFilOri (Filial origem, opcional, Default: cFilAnt)
@obs aParGrvDT6[2]  ADT6FILDES - cFilDes (Filial destino, opcional, Default: cFilAnt)
@obs aParGrvDT6[3]  ADT6FILNEG - cFilNeg (Filial negociação, opcional, Default: cFilAnt)
@obs aParGrvDT6[4]  ADT6FILDEB - cFilDeb (Filial débito, opcional, Default: cFilAnt)
@obs aParGrvDT6[5]  ADT6FILDOC - cFilDoc (Flial documento, opcional, Default: cFilAnt)
@obs aParGrvDT6[6]  ADT6DOC    - cDoc    (Documento)
@obs aParGrvDT6[7]  ADT6SERIE  - cSerie  (Série
@obs aParGrvDT6[8]  ADT6CLIREM - cCliRem (Cliente remetente)
@obs aParGrvDT6[9]  ADT6LOJREM - cLojRem (Loja do cliente remetente)
@obs aParGrvDT6[10] ADT6CLIDES - cCliDes (Cliente destinatário)
@obs aParGrvDT6[11] ADT6LOJDES - cLojDes (Loja do cliente destinatário)
@obs aParGrvDT6[12] ADT6CLIDEV - cCliDev (Cliente devedor)
@obs aParGrvDT6[13] ADT6LOJDEV - cLojDev (Loja do cliente devedor)
@obs aParGrvDT6[14] ADT6CLICAL - cCliCal (Cliente de cálculo)
@obs aParGrvDT6[15] ADT6LOJCAL - cLojCal (Loja do cliente de cálculo)
@obs aParGrvDT6[16] ADT6CDRORI - cCdrOri (Região origem)
@obs aParGrvDT6[17] ADT6CDRDES - cCdrDes (Região destino)
@obs aParGrvDT6[18] ADT6CDRCAL - cCdrCal (Região cálculo)
@obs aParGrvDT6[19] ADT6CLICON - cCliCon (Cliente consignatário)
@obs aParGrvDT6[20] ADT6LOJCON - cLojCon (Loja do cliente consignatário)
@obs aParGrvDT6[21] ADT6CLIDPC - cCliDpc (Cliente despachante)
@obs aParGrvDT6[22] ADT6LOJDPC - cLojDpc (Loja do cliente despachante)
@obs aParGrvDT6[23] ADT6PRZENT - dPrzEnt (Prazo de entrega, opcional, Default: dDataBase)
@obs aParGrvDT6[24] ADT6DATEMI - dDatEmi (Data de emissão, opcional, Default: dDataBase)
@obs aParGrvDT6[25] ADT6HOREMI - cHorEmi (Hora de emissão, opcional, Default: Time())
@obs aParGrvDT6[26] ADT6USRGER - cUsrGer (Usuário geração, opcional, Default: RetCodUsr())
@obs aParGrvDT6[27] ADT6DOCTMS - cDocTMS (Documento de transporte)
@obs aParGrvDT6[28] ADT6STATUS - cStatus (Status, opcional, Default: 7=Entregue)
@obs aParGrvDT6[29] ADT6BLQDOC - cBlqDoc (Bloqueio documento, opcional, Default: 2=Nao)
@obs aParGrvDT6[30] ADT6PRIPER - cPriPer (Documento de 1º percurso, opcional, Default: 2=Nao)
@obs aParGrvDT6[31] ADT6IMP    - cFImp   (Impresso, opcional, Default: 0=Nao Impresso)
@obs aParGrvDT6[32] ADT6TIPFRE - cTipFre (Tipo de frete)
@obs aParGrvDT6[33] ADT6DEVFRE - cDevFre (Devedor do frete)
@obs aParGrvDT6[34] ADT6SERTMS - cSerTms (Serviço de transporte, opcional, Default: 3=Entrega)
@obs aParGrvDT6[35] ADT6LOTNFC - cLotNfc (Lote)
@obs aParGrvDT6[36] ADT6MOEDA  - nMoeda  (Moeda, opcional, Default: 1)
@obs aParGrvDT6[37] ADT6TIPTRA - cTipTra (Tipo de transporte)
@obs aParGrvDT6[38] ADT6SERVIC - cServic (Serviço de negociação)
@obs aParGrvDT6[39] ADT6CODMSG - cCodMsg (Mensagem fiscal)
@obs aParGrvDT6[40] ADT6SITCTE - cSitCte (Situação CTE, opcional, Default: Iif(lTMSCTe, "0", ""))
@obs aParGrvDT6[41] ADT6RETCTE - cRetCte (Retorno CTE, opcional, Default: Iif(lTMSCTe, STR0001, ""))
@obs aParGrvDT6[42] ADT6VALMER - nValMer (Valor da mercadoria)
@obs aParGrvDT6[43] ADT6PESOM3 - nPesoM3 (Peso M3)
@obs aParGrvDT6[44] ADT6PESCOB - nPesCob (Peso cobrado)
@obs aParGrvDT6[45] ADT6QTDUNI - nQtdUni (Quantidade unitária)
@obs aParGrvDT6[46] ADT6QTDVOL - nQtdVol (Quantidade volume)
@obs aParGrvDT6[47] ADT6VOLORI - nVolOri (Volume original)
@obs aParGrvDT6[48] ADT6PESO   - nPeso   (Peso
@obs aParGrvDT6[49] ADT6VALFRE - nValFre (Valor frete)
@obs aParGrvDT6[50] ADT6VALIMP - nValImp (Valor impostos)
@obs aParGrvDT6[51] ADT6VALTOT - nValTot (Valor total)
@obs aParGrvDT6[52] ADT6VALFAT - nValFat (Valor faturar)
@obs aParGrvDT6[53] ADT6ACRESC - nAcresc (Valor de acréscimo)
@obs aParGrvDT6[54] ADT6DECRES - nDecres (Valor de decréscimo)
@obs aParGrvDT6[55] ADT6TABFRE - cTabFre (Tabela de frete)
@obs aParGrvDT6[56] ADT6TIPTAB - cTipTab (Tipo da tabela de frete)
@obs aParGrvDT6[57] ADT6SEQTAB - cSeqTab (Sequencia da tabela)
@obs aParGrvDT6[58] ADT6NRCONT - cNrContr (Número do contrato)
@obs aParGrvDT6[59] ADT6CODNEG - cCodNeg (Código da negociação)
@obs INFORMAÇÕES ARRAY RETORNO aRetDT6
@obs aRetDT6[1] RDT6FILDOC - DT6->DT6_FILDOC (Filial do documento)
@obs aRetDT6[2] RDT6DOC    - DT6->DT6_DOC (Documento)
@obs aRetDT6[3] RDT6SERIE  - DT6->DT6_SERIE (Série)
@obs aRetDT6[4] RDT6RECNO  - DT6->(RecNo()) (Identificador RECNO)
/*/
//-------------------------------------------------------------------------------------------------
Function TmsGrvDT6(aParGrvDT6, aPontEntr, lGrvInfSE1)

	Local aArea     := GetArea()
	Local aAreaSE1  := SE1->(GetArea())
	Local aRetDT6   := {"", "", "", 0}
	Local cPEAntDT6 := ""
	Local cFilOri   := ""
    Local cFilDes   := ""
    Local cFilNeg   := ""
    Local cFilDeb   := ""
    Local cFilDoc   := ""
    Local cDoc      := ""
    Local cSerie    := ""
    Local cCliRem   := ""
    Local cLojRem   := ""
    Local cCliDes   := ""
    Local cLojDes   := ""
    Local cCliDev   := ""
    Local cLojDev   := ""
    Local cCliCal   := ""
    Local cLojCal   := ""
    Local cCdrOri   := ""
    Local cCdrDes   := ""
    Local cCdrCal   := ""
    Local cCliCon   := ""
    Local cLojCon   := ""
    Local cCliDpc   := ""
    Local cLojDpc   := ""
    Local cHorEmi   := ""
    Local cUsrGer   := ""
    Local cDocTMS   := ""
    Local cStatus   := ""
    Local cBlqDoc   := ""
    Local cPriPer   := ""
    Local cFImp     := ""
    Local cTipFre   := ""
    Local cDevFre   := ""
    Local cSerTms   := ""
    Local cLotNfc   := ""
    Local cTipTra   := ""
    Local cServic   := ""
    Local cCodMsg   := ""
    Local cSitCte   := ""
    Local cRetCte   := ""
    Local cTabFre   := ""
	Local cTipTab   := ""
	Local cSeqTab   := ""
	Local cNrContr  := ""
	Local cCodNeg   := ""
	Local cAliasQry := ""
	Local cQuery    := ""
    Local dPrzEnt   := Nil
    Local dDatEmi   := Nil
	Local dVencto   := Nil
	Local lTMSCTe   := SuperGetMv("MV_TMSCTE", .F., .F.) //-- Parametro do CT-e ativo
	Local lPEAntDT6 := .F.
	Local lPEPosDT6 := .F.
    Local nMoeda    := 1
    Local nValMer   := 0
    Local nPesoM3   := 0
    Local nPesCob   := 0
    Local nQtdUni   := 0
    Local nQtdVol   := 0
    Local nVolOri   := 0
    Local nPeso     := 0
    Local nValFre   := 0
    Local nValImp   := 0
    Local nValTot   := 0
    Local nValFat   := 0
    Local nAcresc   := 0
    Local nDecres   := 0
	Local lDT6PrzOri:= DT6->(ColumnPos("DT6_PRZORI")) > 0
	Local cFilDco   := ''
	Local cDocDco   := ''
	Local cSerDco   := ''

	Default aParGrvDT6 := {}
	Default aPontEntr  := {}
	Default lGrvInfSE1 := .F.

	//-- Identificacao dos parametros recebidos e para nao possuirem valores nulos
	cFilOri   := Iif(Len(aParGrvDT6) < ADT6FILORI .Or. aParGrvDT6[ADT6FILORI] == Nil, cFilAnt                                            , aParGrvDT6[ADT6FILORI])
	cFilDes   := Iif(Len(aParGrvDT6) < ADT6FILDES .Or. aParGrvDT6[ADT6FILDES] == Nil, cFilAnt                                            , aParGrvDT6[ADT6FILDES])
	cFilNeg   := Iif(Len(aParGrvDT6) < ADT6FILNEG .Or. aParGrvDT6[ADT6FILNEG] == Nil, cFilAnt                                            , aParGrvDT6[ADT6FILNEG])
	cFilDeb   := Iif(Len(aParGrvDT6) < ADT6FILDEB .Or. aParGrvDT6[ADT6FILDEB] == Nil, cFilAnt                                            , aParGrvDT6[ADT6FILDEB])
	cFilDoc   := Iif(Len(aParGrvDT6) < ADT6FILDOC .Or. aParGrvDT6[ADT6FILDOC] == Nil, cFilAnt                                            , aParGrvDT6[ADT6FILDOC])
	cDoc      := Iif(Len(aParGrvDT6) < ADT6DOC    .Or. aParGrvDT6[ADT6DOC]    == Nil, ""                                                 , aParGrvDT6[ADT6DOC])
	cSerie    := Iif(Len(aParGrvDT6) < ADT6SERIE  .Or. aParGrvDT6[ADT6SERIE]  == Nil, ""                                                 , aParGrvDT6[ADT6SERIE])
	cCliRem   := Iif(Len(aParGrvDT6) < ADT6CLIREM .Or. aParGrvDT6[ADT6CLIREM] == Nil, ""                                                 , aParGrvDT6[ADT6CLIREM])
	cLojRem   := Iif(Len(aParGrvDT6) < ADT6LOJREM .Or. aParGrvDT6[ADT6LOJREM] == Nil, ""                                                 , aParGrvDT6[ADT6LOJREM])
	cCliDes   := Iif(Len(aParGrvDT6) < ADT6CLIDES .Or. aParGrvDT6[ADT6CLIDES] == Nil, ""                                                 , aParGrvDT6[ADT6CLIDES])
	cLojDes   := Iif(Len(aParGrvDT6) < ADT6LOJDES .Or. aParGrvDT6[ADT6LOJDES] == Nil, ""                                                 , aParGrvDT6[ADT6LOJDES])
	cCliDev   := Iif(Len(aParGrvDT6) < ADT6CLIDEV .Or. aParGrvDT6[ADT6CLIDEV] == Nil, ""                                                 , aParGrvDT6[ADT6CLIDEV])
	cLojDev   := Iif(Len(aParGrvDT6) < ADT6LOJDEV .Or. aParGrvDT6[ADT6LOJDEV] == Nil, ""                                                 , aParGrvDT6[ADT6LOJDEV])
	cCliCal   := Iif(Len(aParGrvDT6) < ADT6CLICAL .Or. aParGrvDT6[ADT6CLICAL] == Nil, ""                                                 , aParGrvDT6[ADT6CLICAL])
	cLojCal   := Iif(Len(aParGrvDT6) < ADT6LOJCAL .Or. aParGrvDT6[ADT6LOJCAL] == Nil, ""                                                 , aParGrvDT6[ADT6LOJCAL])
	cCdrOri   := Iif(Len(aParGrvDT6) < ADT6CDRORI .Or. aParGrvDT6[ADT6CDRORI] == Nil, ""                                                 , aParGrvDT6[ADT6CDRORI])
	cCdrDes   := Iif(Len(aParGrvDT6) < ADT6CDRDES .Or. aParGrvDT6[ADT6CDRDES] == Nil, ""                                                 , aParGrvDT6[ADT6CDRDES])
	cCdrCal   := Iif(Len(aParGrvDT6) < ADT6CDRCAL .Or. aParGrvDT6[ADT6CDRCAL] == Nil, ""                                                 , aParGrvDT6[ADT6CDRCAL])
	cCliCon   := Iif(Len(aParGrvDT6) < ADT6CLICON .Or. aParGrvDT6[ADT6CLICON] == Nil, ""                                                 , aParGrvDT6[ADT6CLICON])
	cLojCon   := Iif(Len(aParGrvDT6) < ADT6LOJCON .Or. aParGrvDT6[ADT6LOJCON] == Nil, ""                                                 , aParGrvDT6[ADT6LOJCON])
	cCliDpc   := Iif(Len(aParGrvDT6) < ADT6CLIDPC .Or. aParGrvDT6[ADT6CLIDPC] == Nil, ""                                                 , aParGrvDT6[ADT6CLIDPC])
	cLojDpc   := Iif(Len(aParGrvDT6) < ADT6LOJDPC .Or. aParGrvDT6[ADT6LOJDPC] == Nil, ""                                                 , aParGrvDT6[ADT6LOJDPC])
	dPrzEnt   := Iif(Len(aParGrvDT6) < ADT6PRZENT .Or. aParGrvDT6[ADT6PRZENT] == Nil, dDataBase                                          , aParGrvDT6[ADT6PRZENT])
	dDatEmi   := Iif(Len(aParGrvDT6) < ADT6DATEMI .Or. aParGrvDT6[ADT6DATEMI] == Nil, dDataBase                                          , aParGrvDT6[ADT6DATEMI])
	cHorEmi   := Iif(Len(aParGrvDT6) < ADT6HOREMI .Or. aParGrvDT6[ADT6HOREMI] == Nil, StrTran(Left(Time(), 5), ":", "")                  , aParGrvDT6[ADT6HOREMI])
	cUsrGer   := Iif(Len(aParGrvDT6) < ADT6USRGER .Or. aParGrvDT6[ADT6USRGER] == Nil, RetCodUsr()                                        , aParGrvDT6[ADT6USRGER])
	cDocTMS   := Iif(Len(aParGrvDT6) < ADT6DOCTMS .Or. aParGrvDT6[ADT6DOCTMS] == Nil, ""                                                 , aParGrvDT6[ADT6DOCTMS])
	cStatus   := Iif(Len(aParGrvDT6) < ADT6STATUS .Or. aParGrvDT6[ADT6STATUS] == Nil, StrZero(7, Len(DT6->DT6_STATUS)) /* 7=Entregue */  , aParGrvDT6[ADT6STATUS])
	cBlqDoc   := Iif(Len(aParGrvDT6) < ADT6BLQDOC .Or. aParGrvDT6[ADT6BLQDOC] == Nil, StrZero(2, Len(DT6->DT6_BLQDOC)) /* 2=Nao */       , aParGrvDT6[ADT6BLQDOC])
	cPriPer   := Iif(Len(aParGrvDT6) < ADT6PRIPER .Or. aParGrvDT6[ADT6PRIPER] == Nil, StrZero(2, Len(DT6->DT6_PRIPER)) /* 2=Nao */       , aParGrvDT6[ADT6PRIPER])
	cFImp     := Iif(Len(aParGrvDT6) < ADT6IMP    .Or. aParGrvDT6[ADT6IMP]    == Nil, StrZero(0, Len(DT6->DT6_FIMP)) /* 0=Nao Impresso */, aParGrvDT6[ADT6IMP])
	cTipFre   := Iif(Len(aParGrvDT6) < ADT6TIPFRE .Or. aParGrvDT6[ADT6TIPFRE] == Nil, ""                                                 , aParGrvDT6[ADT6TIPFRE])
	cDevFre   := Iif(Len(aParGrvDT6) < ADT6DEVFRE .Or. aParGrvDT6[ADT6DEVFRE] == Nil, ""                                                 , aParGrvDT6[ADT6DEVFRE])
	cSerTms   := Iif(Len(aParGrvDT6) < ADT6SERTMS .Or. aParGrvDT6[ADT6SERTMS] == Nil, StrZero(3, Len(DT6->DT6_SERTMS)) /* Entrega */     , aParGrvDT6[ADT6SERTMS])
	cLotNfc   := Iif(Len(aParGrvDT6) < ADT6LOTNFC .Or. aParGrvDT6[ADT6LOTNFC] == Nil, ""                                                 , aParGrvDT6[ADT6LOTNFC])
	nMoeda    := Iif(Len(aParGrvDT6) < ADT6MOEDA  .Or. aParGrvDT6[ADT6MOEDA]  == Nil, 1                                                  , aParGrvDT6[ADT6MOEDA])
	cTipTra   := Iif(Len(aParGrvDT6) < ADT6TIPTRA .Or. aParGrvDT6[ADT6TIPTRA] == Nil, ""                                                 , aParGrvDT6[ADT6TIPTRA])
	cServic   := Iif(Len(aParGrvDT6) < ADT6SERVIC .Or. aParGrvDT6[ADT6SERVIC] == Nil, ""                                                 , aParGrvDT6[ADT6SERVIC])
	cCodMsg   := Iif(Len(aParGrvDT6) < ADT6CODMSG .Or. aParGrvDT6[ADT6CODMSG] == Nil, ""                                                 , aParGrvDT6[ADT6CODMSG])
	cSitCte   := Iif(Len(aParGrvDT6) < ADT6SITCTE .Or. aParGrvDT6[ADT6SITCTE] == Nil, Iif(lTMSCTe, "0", "")                              , aParGrvDT6[ADT6SITCTE])
	cRetCte   := Iif(Len(aParGrvDT6) < ADT6RETCTE .Or. aParGrvDT6[ADT6RETCTE] == Nil, Iif(lTMSCTe, STR0001, "")                          , aParGrvDT6[ADT6RETCTE])
	nValMer   := Iif(Len(aParGrvDT6) < ADT6VALMER .Or. aParGrvDT6[ADT6VALMER] == Nil, 0                                                  , aParGrvDT6[ADT6VALMER])
	nPesoM3   := Iif(Len(aParGrvDT6) < ADT6PESOM3 .Or. aParGrvDT6[ADT6PESOM3] == Nil, 0                                                  , aParGrvDT6[ADT6PESOM3])
	nPesCob   := Iif(Len(aParGrvDT6) < ADT6PESCOB .Or. aParGrvDT6[ADT6PESCOB] == Nil, 0                                                  , aParGrvDT6[ADT6PESCOB])
	nQtdUni   := Iif(Len(aParGrvDT6) < ADT6QTDUNI .Or. aParGrvDT6[ADT6QTDUNI] == Nil, 0                                                  , aParGrvDT6[ADT6QTDUNI])
	nQtdVol   := Iif(Len(aParGrvDT6) < ADT6QTDVOL .Or. aParGrvDT6[ADT6QTDVOL] == Nil, 0                                                  , aParGrvDT6[ADT6QTDVOL])
	nVolOri   := Iif(Len(aParGrvDT6) < ADT6VOLORI .Or. aParGrvDT6[ADT6VOLORI] == Nil, 0                                                  , aParGrvDT6[ADT6VOLORI])
	nPeso     := Iif(Len(aParGrvDT6) < ADT6PESO   .Or. aParGrvDT6[ADT6PESO]   == Nil, 0                                                  , aParGrvDT6[ADT6PESO])
	nValFre   := Iif(Len(aParGrvDT6) < ADT6VALFRE .Or. aParGrvDT6[ADT6VALFRE] == Nil, 0                                                  , aParGrvDT6[ADT6VALFRE])
	nValImp   := Iif(Len(aParGrvDT6) < ADT6VALIMP .Or. aParGrvDT6[ADT6VALIMP] == Nil, 0                                                  , aParGrvDT6[ADT6VALIMP])
	nValTot   := Iif(Len(aParGrvDT6) < ADT6VALTOT .Or. aParGrvDT6[ADT6VALTOT] == Nil, 0                                                  , aParGrvDT6[ADT6VALTOT])
	nValFat   := Iif(Len(aParGrvDT6) < ADT6VALFAT .Or. aParGrvDT6[ADT6VALFAT] == Nil, 0                                                  , aParGrvDT6[ADT6VALFAT])
	nAcresc   := Iif(Len(aParGrvDT6) < ADT6ACRESC .Or. aParGrvDT6[ADT6ACRESC] == Nil, 0                                                  , aParGrvDT6[ADT6ACRESC])
	nDecres   := Iif(Len(aParGrvDT6) < ADT6DECRES .Or. aParGrvDT6[ADT6DECRES] == Nil, 0                                                  , aParGrvDT6[ADT6DECRES])
	cTabFre   := Iif(Len(aParGrvDT6) < ADT6TABFRE .Or. aParGrvDT6[ADT6TABFRE] == Nil, ""                                                 , aParGrvDT6[ADT6TABFRE])
	cTipTab   := Iif(Len(aParGrvDT6) < ADT6TIPTAB .Or. aParGrvDT6[ADT6TIPTAB] == Nil, ""                                                 , aParGrvDT6[ADT6TIPTAB])
	cSeqTab   := Iif(Len(aParGrvDT6) < ADT6SEQTAB .Or. aParGrvDT6[ADT6SEQTAB] == Nil, ""                                                 , aParGrvDT6[ADT6SEQTAB])
	cNrContr  := Iif(Len(aParGrvDT6) < ADT6NRCONT .Or. aParGrvDT6[ADT6NRCONT] == Nil, ""                                                 , aParGrvDT6[ADT6NRCONT])                                               
	cCodNeg   := Iif(Len(aParGrvDT6) < ADT6CODNEG .Or. aParGrvDT6[ADT6CODNEG] == Nil, ""                                                 , aParGrvDT6[ADT6CODNEG])
	cPEAntDT6 := Iif(Len(aPontEntr)  < APEANTDT6  .Or. aPontEntr[APEANTDT6]   == Nil, ""                                                 , aPontEntr[APEANTDT6])
	cPEPosDT6 := Iif(Len(aPontEntr)  < APEPOSDT6  .Or. aPontEntr[APEPOSDT6]   == Nil, ""                                                 , aPontEntr[APEPOSDT6])
	cFilDco   := Iif(Len(aParGrvDT6) < ADT6FILDCO .Or. aParGrvDT6[ADT6FILDCO] == Nil, ""                                                 , aParGrvDT6[ADT6FILDCO])
	cDocDco   := Iif(Len(aParGrvDT6) < ADT6DOCDCO .Or. aParGrvDT6[ADT6DOCDCO] == Nil, ""                                                 , aParGrvDT6[ADT6DOCDCO])
	cSerDco   := Iif(Len(aParGrvDT6) < ADT6SERDCO .Or. aParGrvDT6[ADT6SERDCO] == Nil, ""                                                 , aParGrvDT6[ADT6SERDCO])

	lPEAntDT6 := ExistBlock(cPEAntDT6)
	lPEPosDT6 := ExistBlock(cPEPosDT6)

	//-- Ponto de entrada antes da gravacao do documento no DT6
	If lPEAntDT6
		ExecBlock(cPEAntDT6, .F., .F., aParGrvDT6)
	EndIf

	RecLock("DT6", .T.)
	DT6->DT6_FILIAL := xFilial("DT6")
	DT6->DT6_FILORI := cFilOri
	DT6->DT6_FILDES := cFilDes
	DT6->DT6_FILNEG := cFilNeg
	DT6->DT6_FILDEB := cFilDeb
	DT6->DT6_FILDOC := cFilDoc
	DT6->DT6_DOC    := cDoc
	DT6->DT6_SERIE  := cSerie
	DT6->DT6_CLIREM := cCliRem
	DT6->DT6_LOJREM := cLojRem
	DT6->DT6_CLIDES := cCliDes
	DT6->DT6_LOJDES := cLojDes
	DT6->DT6_CLIDEV := cCliDev
	DT6->DT6_LOJDEV := cLojDev
	DT6->DT6_CLICAL := cCliCal
	DT6->DT6_LOJCAL := cLojCal
	DT6->DT6_CDRORI := cCdrOri
	DT6->DT6_CDRDES := cCdrDes
	DT6->DT6_CDRCAL := cCdrCal
	DT6->DT6_CLICON := cCliCon
	DT6->DT6_LOJCON := cLojCon
	DT6->DT6_CLIDPC := cCliDpc
	DT6->DT6_LOJDPC := cLojDpc
	DT6->DT6_PRZENT := dPrzEnt
	DT6->DT6_DATEMI := dDatEmi
	DT6->DT6_HOREMI := cHorEmi
	DT6->DT6_USRGER := cUsrGer
	DT6->DT6_DOCTMS := cDocTMS
	DT6->DT6_STATUS := cStatus
	DT6->DT6_BLQDOC := cBlqDoc
	DT6->DT6_PRIPER := cPriPer
	DT6->DT6_FIMP   := cFImp
	DT6->DT6_TIPFRE := cTipFre
	DT6->DT6_DEVFRE := cDevFre
	DT6->DT6_SERTMS := cSerTms
	DT6->DT6_LOTNFC := cLotNfc
	DT6->DT6_MOEDA  := nMoeda
	DT6->DT6_TIPTRA := cTipTra
	DT6->DT6_SERVIC := cServic
	DT6->DT6_CODMSG := cCodMsg
	DT6->DT6_SITCTE := cSitCte
	DT6->DT6_RETCTE := cRetCte
	DT6->DT6_VALMER := nValMer
	DT6->DT6_PESOM3 := nPesoM3
	DT6->DT6_PESCOB := nPesCob
	DT6->DT6_QTDUNI := nQtdUni
	DT6->DT6_QTDVOL := nQtdVol
	DT6->DT6_VOLORI := nVolOri
	DT6->DT6_PESO   := nPeso
	DT6->DT6_VALFRE := nValFre
	DT6->DT6_VALIMP := nValImp
	DT6->DT6_VALTOT := nValTot
	DT6->DT6_VALFAT := nValFat
	DT6->DT6_ACRESC := nAcresc
	DT6->DT6_DECRES := nDecres
	DT6->DT6_TABFRE := cTabFre   
	DT6->DT6_TIPTAB := cTipTab   
	DT6->DT6_SEQTAB := cSeqTab   
	DT6->DT6_NCONTR := cNrContr
	DT6->DT6_CODNEG := cCodNeg

	DT6->DT6_NUMCMP := cLotNFC
	DT6->DT6_DATENT := dDataBase
	
	DT6->DT6_FILDCO := cFilDco
	DT6->DT6_DOCDCO := cDocDco
	DT6->DT6_SERDCO := cSerDco

	If lDT6PrzOri 
		DT6->DT6_PRZORI:= dPrzEnt
	EndIf

	If lGrvInfSE1
		If SE1->(!Eof())
			DT6->DT6_PREFIX := SE1->E1_PREFIXO
			DT6->DT6_NUM    := SE1->E1_NUM
			DT6->DT6_TIPO   := SE1->E1_TIPO

			//-- Obtem informação da última parcela para alimentar a data de vencimento DT6_VENCTO
			SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			cAliasQry := GetNextAlias()
			cQuery := " SELECT E1_VENCREA, R_E_C_N_O_ SE1_RECNO "
			cQuery += "   FROM " + RetSqlName("SE1")
			cQuery += "  WHERE E1_FILIAL  = '" + xFilial("SE1")  + "' "
			cQuery += "    AND E1_CLIENTE = '" + SE1->E1_CLIENTE + "' "
			cQuery += "    AND E1_LOJA    = '" + SE1->E1_LOJA    + "' "
			cQuery += "    AND E1_PREFIXO = '" + SE1->E1_PREFIXO + "' "
			cQuery += "    AND E1_NUM     = '" + SE1->E1_NUM     + "' "
			cQuery += "    AND D_E_L_E_T_ = ' ' "
			cQuery += "  ORDER BY " + SqlOrder(SE1->(IndexKey()))
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
			While (cAliasQry)->(!Eof())
				SE1->(MsGoto((cAliasQry)->SE1_RECNO))
				dVencto := SE1->E1_VENCREA
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
			RestArea(aAreaSE1)

			If ! Empty(dVencto) .And. ValType(dVencto) == "D"
				DT6->DT6_VENCTO := dVencto
			EndIf
		EndIf
	EndIf

	DT6->(MsUnLock())

	aRetDT6[RDT6FILDOC] := DT6->DT6_FILDOC
	aRetDT6[RDT6DOC]    := DT6->DT6_DOC
	aRetDT6[RDT6SERIE]  := DT6->DT6_SERIE
	aRetDT6[RDT6RECNO]  := DT6->(RecNo())

	//-- Ponto de entrada apos a gravacao do documento no DT6
	If lPEPosDT6
		ExecBlock(cPEPosDT6, .F., .F., aRetDT6)
	EndIf

	RestArea(aArea)

Return aRetDT6

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsVerImpC
Verifica os valores de impostos calculados a partir da geracao nota fiscal de saida, atualiza 
a composição de frete e retorna os valores totais
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 30/01/2017
@param [cNumNFS], Caracter, Número na nota fiscal de saída (NFS)
@param [cCliente], Caracter, Cliente pagador do frete
@param [cLoja], Caracter, Loja do cliente pagador do frete
@param [cDocTMS], Caracter, DOCTMS
@param [cCodPro], Caracter, Código do produto (opcional, busca do DOCTMS)
@param [aCmpFrt], Array, Composição de frete
@return aRetVerImp Array com informações do cruzamento dos dados: Composicao do Frete X Itens da Nota Fiscal
@obs INFORMAÇÕES ARRAY RETORNO aRetVerImp
@obs aRetVerImp[1]  RIMPSERNFC	- cSerNF (Série)
@obs aRetVerImp[2]  RIMPCMPFRT	- aCmpFrt (Composição de frete)
@obs aRetVerImp[3]  RIMPVALFRE	- nValFre (Valor do frete)
@obs aRetVerImp[4]  RIMPVALIMP	- nValImp (Valor de impostos)
@obs aRetVerImp[5]  RIMPVALTOT	- nValTot (Valor total)
@obs aRetVerImp[6]  RIMPCODPRO	- cCodPro (Produto de cálculo)
/*/
//-------------------------------------------------------------------------------------------------
Function TmsVerImpC(cNumNFS, cCliente, cLoja, cDocTMS, cCodPro, aCmpFrt)

	Local aArea      := GetArea()
	Local aAreaSA1   := SA1->(GetArea())
	Local aAreaSD2   := SD2->(GetArea())
	Local aAreaDUI   := DUI->(GetArea())
	Local aAreaSF4   := SF4->(GetArea())
	Local cMv_Estado := SuperGetMV("MV_ESTADO", .F., "")
	Local cSerNF     := ""
	Local cA1_INCISS := ""
	Local nCountA    := 0
	Local nCountB    := 0
	Local nValPISCOF := 0
	Local nValFre    := 0
	Local nValImp    := 0
	Local nValTot    := 0
	Local nCpoImpost := 0
	Local aRetVerImp := {"", {}, 0, 0, 0, ""}
	Local aCpoImpost := {}
	
	Default cNumNFS  := ""
	Default cCliente := ""
	Default cLoja    := ""
	Default cDocTMS  := ""
	Default cCodPro  := ""
	Default aCmpFrt  := {}

	If Type("cDUYEST") == "U"
		Private cDUYEST := ""
	EndIf

	//-- Serie Outra UF
	If Valtype(lDUISEROUT) == "U"
		lDUISEROUT := DUI->(FieldPos("DUI_SEROUT")) > 0
	EndIf

	//-- Tratamento: Produto de Calculo (Dados do Produto)
	DUI->(DbSetOrder(1))
	If DUI->(DbSeek(xFilial("DUI") + cDocTMS))

		cSerNF := DUI->DUI_SERIE

		//-- Verifica se informou serie para origem em outra filial.
		If lDUISEROUT .And. !Empty(DUI->DUI_SEROUT)
			If cMv_Estado <> cDUYEST
				cSerNF := DUI->DUI_SEROUT //-- Serie Outra UF
			EndIf
		EndIf

		If Empty(cCodPro)
			cCodPro := Iif(!Empty(DUI->DUI_PRDCIF), DUI->DUI_PRDCIF, DUI->DUI_CODPRO)
		EndIf
	EndIf

	cA1_INCISS := Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_INCISS")

	//-- Verifica os valores de impostos calculados a partir da geracao nota fiscal de saida
	For nCountA := 1 To Len(aCmpFrt)

		SD2->(DbSetOrder(3)) //-- D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		
		//-- Cruza os dados: Composicao do Frete X Itens da Nota Fiscal
		For nCountB := 1 To Len(aCmpFrt[nCountA, 2])
		
			If aCmpFrt[nCountA, 2, nCountB, 3] == "TF"
				Loop
			EndIf

			If SD2->(DbSeek(xFilial("SD2") + cNumNFS + cSerNF + cCliente + cLoja + cCodPro + aCmpFrt[nCountA, 2, nCountB, 4]))			
				
				DbSelectArea("SF4")
				SF4->(DbSetOrder(1)) //-- F4_FILIAL+F4_CODIGO
				SF4->(DbSeek(xFilial('SF4') + SD2->D2_TES))

				If SF4->F4_AGRPIS == "P" .Or. SF4->F4_AGRCOF == "C"
					aCpoImpost := TMSA200PC("TMSA491", {"SD2"})
					nValPISCOF := 0
					For nCpoImpost := 1 To Len(aCpoImpost)
						nValPISCOF += SD2->(&(aCpoImpost[nCpoImpost])) //-- Soma valor do PIS/COFINS
					Next nCpoImpost			
				EndIf						
				
				/* O valor dos impostos já estão calculado, não há necessidade de recalcular. array (aCmpFrt) já está com os impostos calculado corretamente, passou pela TMSA040IMP 
				If !(SF4->F4_ISS = "S" .And. !Empty(SF4->F4_AGRISS))
					If cIncISS     == "N" .And.;
					   cA1_INCISS  == "N" .And.;
					   AllTrim(Posicione("SF4", 1, xFilial("SF4") + SD2->D2_TES, "F4_ISS")) == "S"				
						aCmpFrt[nCountA, 2, nCountB, 5] := ((SD2->D2_VALICM + nValPISCOF) * a410Arred( aCmpFrt[nCountA, 2, nCountB, 2] / (1-(SD2->D2_PICM/100))))/SD2->D2_PRCVEN 					
					Else
						aCmpFrt[nCountA, 2, nCountB, 5] := ((SD2->D2_VALICM + nValPISCOF) * aCmpFrt[nCountA, 2, nCountB, 2])/SD2->D2_PRCVEN //a410Arred(((SD2->D2_VALICM + nValPISCOF) * aCmpFrt[nCountA, 2, nCountB, 2])/SD2->D2_PRCVEN,"D2_PRUNIT")
					EndIf
	
					If TMSSomaImp(SD2->D2_TES, If(cIncISS == "N" .And. cA1_INCISS == "N", "N", "S"))
						aCmpFrt[nCountA, 2, nCountB, 6] := aCmpFrt[nCountA, 2, nCountB, 2] + aCmpFrt[nCountA, 2, nCountB, 5]//a410Arred(aCmpFrt[nCountA, 2, nCountB, 2],"D2_PRCVEN") + a410Arred(aCmpFrt[nCountA, 2, nCountB, 5],"D2_PRCVEN")
					Else
						aCmpFrt[nCountA, 2, nCountB, 6] := aCmpFrt[nCountA, 2, nCountB, 2]
					EndIf
				EndIf
				*/
				nValFre += aCmpFrt[nCountA, 2, nCountB, 2]
				nValImp += aCmpFrt[nCountA, 2, nCountB, 5]
				nValTot += aCmpFrt[nCountA, 2, nCountB, 6]
			EndIf
		Next nCountB
	Next nCountA

	aRetVerImp[RIMPSERNFC] := cSerNF
	aRetVerImp[RIMPCMPFRT] := aClone(aCmpFrt)
	aRetVerImp[RIMPVALFRE] := nValFre
	aRetVerImp[RIMPVALIMP] := a410Arred(nValImp)
	aRetVerImp[RIMPVALTOT] := a410Arred(nValTot)
	aRetVerImp[RIMPCODPRO] := cCodPro

	RestArea(aArea)
	RestArea(aAreaSA1)
	RestArea(aAreaSD2)
	RestArea(aAreaDUI)
	RestArea(aAreaSF4)

Return aRetVerImp

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsVlStAAM
Função executada após validação da alteração do status do contrato do cliente (AAM_STATUS)
com o objetivo de ajustar o status das negociações ativas (DDC_STATUS) conforme status do contrato.
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 14/06/2017
@param [oModelCtrc], Objeto, Modelo de dados do contrato
@param [cStatAnt], Caractere, Status do contrato antes da alteração
@param [cStatAtu], Caractere, Status do contrato após a alteração
@return lRet True ou False
@obs Função utilizada no TECA250
/*/
//-------------------------------------------------------------------------------------------------
Function TmsVlStAAM(oModelCtrc, cStatAnt, cStatAtu)

	Local lRet      := .F.
	Local nX        := 0
	Local oModelDDC := Nil

	Default oModelCtrc := Nil

	If oModelCtrc == Nil .Or. ValType(oModelCtrc) != "O"
		Return lRet
	EndIf

	oModelDDC := oModelCtrc:GetModel("MdGridIDDC")
	If oModelDDC == Nil .Or. ValType(oModelDDC) != "O"
		Return lRet
	EndIf
		
	For nX := 1 To oModelDDC:Length()

		oModelDDC:GoLine(nX)
		Do Case
			Case cStatAtu == StrZero(1, Len(AAM->AAM_STATUS)) //-- Alteração do status para: "1 - Ativo"
				//-- Apenas realiza o tratamento para negociações com mesmo status do contrato
				If oModelDDC:GetValue("DDC_STATUS") == cStatAnt
					oModelDDC:SetValue("DDC_STATUS", cStatAtu)
				EndIf

			Case cStatAtu == StrZero(2, Len(AAM->AAM_STATUS)) .Or.; //-- Alteração do status para: "2 - Suspenso"
				 cStatAtu == StrZero(3, Len(AAM->AAM_STATUS)) .Or.; //-- Alteração do status para: "3 - Encerrado"
				 cStatAtu == StrZero(4, Len(AAM->AAM_STATUS))       //-- Alteração do status para: "4 - Cancelado"

				//-- Apenas realiza o tratamento para negociações ativas ou Suspensas
				If oModelDDC:GetValue("DDC_STATUS") == StrZero(1, Len(DDC->DDC_STATUS)) .Or. oModelDDC:GetValue("DDC_STATUS") == StrZero(2, Len(DDC->DDC_STATUS))
					oModelDDC:SetValue("DDC_STATUS", cStatAtu)
				EndIf
		EndCase
	Next nX

Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsVldOper
Tentará excluir o contrato na Operadora de Frete, quando for realizada alteração, exclusão ou fechamento da viagem
@type function
@author Leandro Paulino
@version 12
@since 04/07/2017
@param [nAcao]		, Caracter, 3=Fechamento da Viagem; 4=Alteração da Viagem;5=Exclusão da Viagem;
@param [cFilOri]	, Caracter, Filial de Origem da Viagem;
@param [cViagem]	, Caracter, Número da viagem;
@param [cNumIdeOpe]	, Caracter, Número do Id. da Operadora de Frete.
@param [cCodOpe]	, Caracter, Código da Operadora de Frete
@return lRet		, Lógico  , Retorna se a ação poderá ser executada(Fechamento da Viagem, Alteração ou Exclusão)
/*/
//-------------------------------------------------------------------------------------------------
Function TmsVldOper(nAcao, cFilori, cViagem, cNumIdeOpe, cCodOpe)

Local lRet 			:= .T.
Local aMsgErr		:= {}

Default nAcao		:= ''
Default cFilOri 	:= ''
Default cViagem		:= ''
Default cNumIdeOpe 	:= ''
Default cCodOpe		:= ''

lRet := RepContrat(cCodOpe, cFilOri, cViagem,,,,,,5,@aMsgErr)

If !lRet .And. nAcao == 5
	If MsgNoYes(STR0002 + chr(10)+chr(13) + STR0003 + chr(10)+chr(13) + STR0004 + "," + STR0005 + chr(10)+chr(13) + STR0010 ) //--"Não foi possível fazer o cancelamento do contrato!"//--"Entre em contato com a REPOM para que os valores do contrato não fiquem disponíveis para o fornecedor!"//--"Caso deseje interromper o contrato automaticamente" "selecione a opção SIM."//--"Após a exclusão da viagem apenas o administrador do sistema conseguirá obter o número do contrato da REPOM."
		//Chama rotina que tentará interromper o contrato	
		If RepInteRup(cFilori,cViagem,cCodOpe)
			lRet := .T.
		Else
			If MsgNoYes(STR0006 + chr(13)+ STR0003 + chr(13) + STR0007 + ","  + STR0005+ CHR(10)+CHR(13) + STR0010) //--'Não foi possível fazer a interrupção do contrato! '//--"Entre em contato com a REPOM para que os valores do contrato não fiquem disponíveis para o fornecedor!"//--" Caso deseje excluir a viagem mesmo assim"//--"selecione a opção SIM"//--"Após a exclusão da viagem apenas o administrador do sistema conseguirá obter o número do contrato da REPOM."
				lRet := .T.
			EndIf	
		EndIf
	EndIf
ElseIf !lRet
	Help("",1,"TMSXFUNE01",/*Titulo*/,STR0008 + AllTrim(DTR->DTR_PRCTRA) + STR0009) //--"A viagem não pode ser alterada, pois o contrato de numero: "//--" está ativo na Operadora de Frete e não foi possível cancelá-lo"
EndIf

If lRet
	RecLock("DTR",.F.)
		DTR->DTR_PRCTRA := ''
	MsUnLock()
EndIf

Return lRet 

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsCiotPer
Função para retornar o número do CIOT por período do veículo
@type function
@author Katia Bianchi
@version 12
@since 16/05/2018
@param [cCodVei]		, código do veículo para realizar a busca do número do CIOT
/*/
//-------------------------------------------------------------------------------------------------
Function TmsCiotPer( cCodVei, cCodOpe )

Local cRet 		:= ""
Local cQuery	:= ""
Local cAliasQry := GetNextAlias()

Default cCodVei	:= ''
Default cCodOpe := ""

cQuery := " SELECT DJL_CIOT " 
cQuery += " FROM " + RetSqlName("DJL") 
cQuery += " WHERE DJL_FILIAL = '" + xFilial("DJL") + "'" 
cQuery += 		" AND DJL_CODVEI = '" + cCodVei + "'" 
cQuery += 		" AND DJL_DATINI <= '" + DtoS(dDataBase) + "'" 
cQuery += 		" AND DJL_DATFIM >= '" + DtoS(dDataBase) + "'" 
cQuery += 		" AND DJL_STATUS = '" + StrZero( 1, Len(DJL->DJL_STATUS) ) + "'"
If !Empty( cCodOpe ) .AND. DJL->(FieldPos("DJL_CODOPE")) > 0
	cQuery += 	" AND DJL_CODOPE = '" + cCodOpe + "'"
EndIf
cQuery += 		" AND D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

If (cAliasQry)->(!Eof() .And. !Empty((cAliasQry)->DJL_CIOT))
	cRet:= (cAliasQry)->DJL_CIOT
EndIf

(cAliasQry)->(DbCloseArea())

Return cRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsMotCiot
Função para retornar os motoristas do CIOT
@type function
@author Katia Bianchi
@version 12
@since 16/05/2018
@param [CCiot]		, número do CIOT
/*/
//-------------------------------------------------------------------------------------------------
Function TmsMotCiot(cCiot, cCodMot,cForPag,cIdeOpe)

Local aRet 		:= {}
Local cQuery	:= ""
Local cAliasQry := NIL
Local lExiste	:= .F.

Default cCiot	:= ''
Default cCodMot	:= ''
Default cForPag	:= ''
Default cIdeOpe	:= ''

If !Empty(cCiot)
	If !Empty(cCodMot) //Verifica se o motorista já foi informado em alguma das viagens do CIOT por periodo e foi informado como recebedor
		cAliasQry := GetNextAlias()
		cQuery := " SELECT DUP.DUP_CODMOT, DTR.R_E_C_N_O_ " 
		cQuery += " FROM " + RetSqlName("DTR") + " DTR "
		cQuery += " JOIN " + RetSqlName("DUP") + " DUP  "
		cQuery += "  ON  DUP.DUP_FILIAL     = '"+xFilial("DUP")+"' "
		cQuery += "  AND DUP.DUP_FILORI = DTR.DTR_FILORI "
		cQuery += "  AND DUP.DUP_VIAGEM = DTR.DTR_VIAGEM "
		cQuery += "  AND DUP.DUP_CONDUT = '1' "
		cQuery += "  AND DUP.DUP_CODMOT = '"+cCodMot+"' "
		cQuery += "  AND DUP.D_E_L_E_T_ = ' '"			
		cQuery += " JOIN " + RetSqlName ("DLD") + " DLD " 
		cQuery +=  " ON  DLD.DLD_FILIAL = '" + xFilial ("DLD") + "' " 
		cQuery +=  " AND DLD.DLD_FILORI = DTR.DTR_FILORI "
		cQuery +=  " AND DLD.DLD_VIAGEM = DTR.DTR_VIAGEM "
		cQuery += "  AND DLD.DLD_RECEB = '2' "
		cQuery += "  AND DLD.DLD_FORPAG = '"+cForPag+"' "
		cQuery += "  AND DLD.DLD_IDOPE  = '"+cIdeOpe+"' "
		cQuery += "  AND DLD.D_E_L_E_T_ = ' '"	
		cQuery += " WHERE DTR.DTR_CIOT   = '"+cCiot+"'" 
		cQuery += "  AND  DTR.DTR_FILIAL = '" +xFilial("DTR") +"'"
		cQuery += "  AND  DTR.D_E_L_E_T_ = ' '"
		cQuery += "  ORDER BY DTR.R_E_C_N_O_"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		If  (cAliasQry)->(!Eof()) 
			lExiste := .T.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

	If !lExiste
		cAliasQry := GetNextAlias()
		cQuery := " SELECT DUP.DUP_CODMOT " 
		cQuery += " FROM " + RetSqlName("DTR") + " DTR "
		cQuery += " JOIN " + RetSqlName("DUP") + " DUP  "
		cQuery += "  ON  DUP.DUP_FILIAL     = '"+xFilial("DUP")+"' "
		cQuery += "  AND DUP.DUP_FILORI = DTR.DTR_FILORI "
		cQuery += "  AND DUP.DUP_VIAGEM = DTR.DTR_VIAGEM "
		cQuery += "  AND DUP.DUP_CONDUT = '1' "
		cQuery += "  AND DUP.D_E_L_E_T_ = ' '"	
		If !Empty(cCodMot)
			cQuery += "  AND  DUP.DUP_CODMOT <> '"+cCodMot+"' "
		EndIf
		cQuery += " WHERE DTR.DTR_CIOT   = '"+cCiot+"'" 
		cQuery += "  AND  DTR.DTR_FILIAL = '" +xFilial("DTR") +"'"
		cQuery += "  AND  DTR.D_E_L_E_T_ = ' '"
		cQuery += "  GROUP BY DUP.DUP_CODMOT"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		While (cAliasQry)->(!Eof()) 
			AAdd(aRet,{(cAliasQry)->DUP_CODMOT})	
			(cAliasQry)->(DbSkip())
		Enddo
		(cAliasQry)->(DbCloseArea())
	EndIf
EndIf

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsConsDTQ
Função para consulta RE da DTQ
@type function
@author Caio Murakami
@version 12
@since 14/11/2018
@param [nOpc]	
/*/
//-------------------------------------------------------------------------------------------------
Function TmsConsDTQ(nOpc)
Local lRet			:= .T. 
Local cQuery		:= ""
Local cAliasQry		:= ""
Local aTitle    	:= {}
Local aItens    	:= {}
Local aItensAux		:= {}
Local aNewButton	:= {}
Local nSelec    	:= 0
Local aArea			:= GetArea()
Local aAreaDTW		:= DTW->(GetArea())
Local cAtivCHG		:= SuperGetMV('MV_ATIVCHG',,'')
Local lContinua		:= .T.
Local cStatusDesc	:= ""

Private cSerTms 	:= ""
Private cTipTra		:= ""

Default nOpc	:= 0 

If nOpc == 1 
	
	Aadd(aTitle, RetTitle("DTQ_FILORI"))
	Aadd(aTitle, RetTitle("DTQ_VIAGEM"))
	Aadd(aTitle, RetTitle("DA8_DESC"))
	Aadd(aTitle, RetTitle("DTQ_STATUS"))
	Aadd(aTitle, RetTitle("DTQ_DATGER"))
	Aadd(aTitle, RetTitle("DTQ_SERTMS"))

	AAdd(aNewButton, {15,{| nAt | TmsVisViag(aItens[nAt, 1], aItens[nAt, 2], cSerTms := aItensAux[nAt, 1], cTipTra := aItensAux[nAt, 2]) } } )
	
	cAliasQry	:= GetNextAlias()
	
	cQuery	:= " SELECT DTQ_FILORI , DTQ_VIAGEM , DA8_DESC , DTQ_SERTMS, DTQ_TIPTRA , DTQ_STATUS , DTQ_DATGER , DTQ.R_E_C_N_O_ DTQRECNO "
	cQuery	+= " FROM " + RetSQLName("DTQ") + " DTQ "
	cQuery	+= " INNER JOIN " + RetSQLName("DA8") + " DA8 "
	cQuery	+= " 	ON DA8_FILIAL 	= '" + xFilial("DA8") + "' "
	cQuery	+= "	AND DA8_COD 	= DTQ_ROTA "
	cQuery	+= " 	AND DA8.D_E_L_E_T_ = ' ' "
	cQuery	+= " WHERE "
	cQuery	+= " 	DTQ_FILIAL 	= '" + xFilial("DTQ") + "' "
	cQuery	+= " 	AND DTQ_SERTMS IN ( '2', '3') "
	cQuery	+= " 	AND DTQ_STATUS IN ( '1', '2', '4') " //-- 1=Em Aberto;5=Fechada;2=Em Transito;4=Chegada em Filial/Cliente;3=Encerrada;9=Cancelada
	cQuery	+= " 	AND DTQ.D_E_L_E_T_= ' ' "
	cQuery += " ORDER BY DTQ.DTQ_FILORI, DTQ.DTQ_VIAGEM"

	cQuery := ChangeQuery(cQuery)
	
	cAliasQry := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry )

	If !(cAliasQry)->( Eof() )
		DTW->(dbSetOrder(4))
		While !(cAliasQry)->( Eof() )
			
			lContinua	:= .T. 
			cStatusDesc := ""

			If (cAliasQry)->DTQ_STATUS == "1" //-- Em Aberto
				lContinua	:= .T. 
				cStatusDesc := STR0011 //"Em Aberto"
			
			ElseIf (cAliasQry)->DTQ_STATUS == "2" //-- Em trânsito
				
				If (cAliasQry)->DTQ_SERTMS == '2' //-- Viagem de Trânsferencia
					lContinua	:= .F. 
				Else
					lContinua	:= .T. 
				EndIf
				cStatusDesc := STR0012 //"Em Trânsito"

			ElseIf (cAliasQry)->DTQ_STATUS == "4"//-- Chegada em Filial

				If (cAliasQry)->DTQ_SERTMS == '2' //-- Viagem de Trânsferencia
					lContinua	:= .T. 
				Else
					/* --------------------------------------------------------------------------------------------- 
					//-- Se a viagem for de entrega e a chegada ocorreu na filial prevista da rota não apresentar na tela
					//-- Se a viagem for de entrega e a chegada ocorreu na filial diferente da prevista na rota exibir na tela
					------------------------------------------------------------------------------------------------*/
					If DTW->( MsSeek( xFilial("DTW") + (cAliasQry)->DTQ_FILORI + (cAliasQry)->DTQ_VIAGEM + cAtivCHG ))
						While DTW->(!Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID) ==  xFilial("DTW") + (cAliasQry)->DTQ_FILORI + (cAliasQry)->DTQ_VIAGEM + cAtivCHG 

							If DTW->DTW_FILATI == DTW->DTW_FILATU
								lContinua	:= .F. 
							Else	
								lContinua	:= .T. 
							EndIf

							DTW->(dbSkip())
						EndDo
					EndIf
				EndIf
				cStatusDesc := STR0013 //"Chegada em Filial"

			Else
				lContinua	:= .F. 			
			EndIf

			If lContinua
				AAdd( aItens, { 	(cAliasQry)->DTQ_FILORI,;
									(cAliasQry)->DTQ_VIAGEM,;
									(cAliasQry)->DA8_DESC,;
									cStatusDesc,;
									STOD((cAliasQry)->DTQ_DATGER),;
									TMSValField((cAliasQry)+"->DTQ_SERTMS",.F.),;
									(cAliasQry)->DTQRECNO } )

				Aadd( aItensAux, {	(cAliasQry)->DTQ_SERTMS,;
									(cAliasQry)->DTQ_TIPTRA })
			EndIf

			(cAliasQry)->( DbSkip() )
		End
		(cAliasQry)->( DbCloseArea() )
	Else
		lRet := .F.
	Endif

	If lRet .AND. Len(aItens) > 0

		nSelec 	:= TmsF3Array( aTitle , aItens , RetTitle("DTQ_VIAGEM") , .T.  , aNewButton )
	
		If nSelec <> 0
			VAR_IXB := aItens[nSelec,2]
			lRet    := .T.
		Else
			lRet    := .F.
		EndIf	
	Else
		lRet    := .F.
		Help( , , "TmsConsDTQ", , STR0014, 1, 0, , , , , , {STR0015} ) //--STR0014"Não foi possivel localizar Viagens com Status: 1=Em Aberto, 2=Em Transito e 4=Chegada em Filial/Cliente." STR0015 "Para esta consulta padrão retornar registros é necessario que exista Viagens com Status: 1=Em Aberto, 2=Em Transito e 4=Chegada em Filial/Cliente."
	EndIf
	
EndIf

RestArea(aAreaDTW)
RestArea(aArea)
Return lRet


/*/-----------------------------------------------------------
{Protheus.doc} TmsOcorPR()
Verifica a ocorrencia de Prazo de Entrega por Documento
Uso: TMSA200
@author Katia
@since 27/09/2019
-----------------------------------------------------------/*/
Function TmsOcorPR(cFilDoc,cDoc,cSerie,cCodOco)
Local nRet      := 0
Local aArea     := GetArea()
Local cAliasQry := ""
Local cQuery    := ""

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default cCodOco := ""

cAliasQry := GetNextAlias()
cQuery := " SELECT DUA.R_E_C_N_O_ RECNODUA "
cQuery += "   FROM  " + RetSqlName("DUA") + " DUA "
	
cQuery += " INNER JOIN " + RetSqlName("DT2") + " DT2 "
cQuery += " 	ON DT2.DT2_FILIAL = '" + xFilial("DT2") + "' "
cQuery += "    AND DT2.DT2_CODOCO = DUA.DUA_CODOCO  "
cQuery += "    AND DT2.DT2_TIPOCO IN ('" + StrZero(4, Len(DT2->DT2_TIPOCO)) + "','" + StrZero(5, Len(DT2->DT2_TIPOCO)) + "') "   //Retorna Doc ou Informativa
cQuery += "    AND DT2.DT2_RESOCO = '" + StrZero(2, Len(DT2->DT2_RESOCO)) + "' "   //Cliente
cQuery += "    AND DT2.DT2_PRZENT = '" + StrZero(1, Len(DT2->DT2_PRZENT)) + "' "   //Prazo Entrega
cQuery += "    AND DT2.D_E_L_E_T_ = ' ' "
	
cQuery += "  WHERE DUA.DUA_FILIAL = '" + xFilial("DUA") + "' "
cQuery += "    AND DUA.DUA_FILDOC = '" + cFilDoc + "' "
cQuery += "    AND DUA.DUA_DOC    = '" + cDoc    + "' "
cQuery += "    AND DUA.DUA_SERIE  = '" + cSerie  + "' "
If !Empty(cCodOco) 
	cQuery += "    AND DUA.DUA_CODOCO =  '" + cCodOco + "' "
EndIf	
cQuery += "    AND DUA.D_E_L_E_T_ = ' ' "
cQuery += "    ORDER BY DUA.DUA_DATOCO, DUA.DUA_HOROCO, DUA.DUA_NUMOCO DESC "

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
If (cAliasQry)->(!Eof()) 
	nRet:= (cAliasQry)->RECNODUA 
EndIf	
(cAliasQry)->(DbCloseArea())  

RestArea(aArea)
Return nRet

/*/-----------------------------------------------------------
{Protheus.doc} TmsStaDDU()
Verificado se o registro DDU está bloqueado 
Uso: TMSA200
@author Katia
@since 27/09/2019
-----------------------------------------------------------/*/
Function TmsStaDDU(nRecDUA, cChave)
Local lRet   := .T.
Local aArea  := GetArea()
Local cStatus:= ""

Default nRecDUA:= 0
Default cChave := ""

If Empty(cChave) .And. nRecDUA > 0
	DUA->( dbGoto(nRecDUA) )
	cChave:= xFilial('DUA')+DUA->DUA_FILOCO+DUA->DUA_NUMOCO+DUA->DUA_FILORI+DUA->DUA_VIAGEM+DUA->DUA_SEQOCO
EndIf	

If !Empty(cChave)
	DbSelectArea("DDU")
	DDU->(DbSetOrder(2)) //-- DDU_FILIAL+DDU_ALIAS+DDU_CHAVE+DDU_TIPBLQ+STR(DDU_NIVBLQ)+DDU_FILORI                                                                                            
	If DDU->(DbSeek(xFilial("DDU") + 'DUA' + Padr(cChave,Len(DDU->DDU_CHAVE)) + 'PR' ))
		cStatus:= DDU->DDU_STATUS
	Else
		cChave:= xFilial('DUA')+DUA->DUA_FILOCO+DUA->DUA_NUMOCO+Space(Len(DUA->DUA_FILORI))+Space(Len(DUA->DUA_VIAGEM))+DUA->DUA_SEQOCO
		If DDU->(DbSeek(xFilial("DDU") + 'DUA' + Padr(cChave,Len(DDU->DDU_CHAVE)) + 'PR' ))
			cStatus:= DDU->DDU_STATUS
		EndIf
	EndIf

	If cStatus == StrZero(1, Len(DDU->DDU_STATUS)) //Bloqueado
		lRet:= .F.
	EndIf	
EndIf

RestArea(aArea)
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a545FreteP³ Autor ³Vendas Clientes        ³ Data ³07/09/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta funcao efetua o calculo do frete pauta.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Modelo da Carga                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGATMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSXFreteP(cTipCar, cEstOri, nQtdEixo, nPeso, nPesoM3)
Local aArea    := GetArea()
Local cAliasDV9:= "DV9"
Local aStruDV9 := {}
Local cQuery   := ""
Local cQryDMD  := ""
Local nScan    := 0
Local nY       := 0
Local lDV9_UF  := DV9->(ColumnPos("DV9_UF")) > 0
Local cMoeda   := SuperGetMv("MV_UFERMS",.F.," ")
Local nUFERMS  := 0
Local nUFERMSPauta := 0
Local nPercUFERMS  := 0
Local nKm          := M->C5_KM
Local aFreteP      := {}
Local cIndice	   := ""	
Local cAliasDMD	   := ""

Default cTipCar	:= ""
Default cEstOri	:= ""
Default nQtdEixo:= 0
Default nPeso	:= 0
Default nPesoM3 := 0

If ValType(aFreteP) == "A"
	M->C5_VLR_FRT := 0 //-- Var.mem. valor base icms pauta de frete
	If M->C5_KM > 0
		If Empty(aFreteP)

			DV9->(dbSetOrder(2)) //DV9_FILIAL+STR(DV9_KM,7,0)+DV9_TIPCAR
			aStruDV9 := DV9->(dbStruct())
			cAliasDV9:= GetNextAlias()
			cQuery := "SELECT DV9.*,DV9.R_E_C_N_O_ DV9RECNO "
			cQuery += "FROM "+RetSqlName("DV9")+" DV9 "
			cQuery += "WHERE DV9.DV9_FILIAL='"+xFilial("DV9")+"' AND "
			cQuery += "DV9.D_E_L_E_T_=' ' "
			If lDV9_UF
				cQuery += " AND DV9_KM >= '" + alltrim(str(nKm)) + "'"
				cQuery += " AND DV9_UF = '" + cEstOri + "'" 
				cQuery += " AND DV9_TIPCAR = '" + cTipCar + "' AND DV9_ICBASE = '2' "
				cQuery += " AND (DV9_FAIXAP >=" + alltrim(str(nPeso)) + "AND DV9_TIPVAL = '5' OR DV9_FAIXAP >=" + alltrim(str(nPesoM3)) + " AND DV9_TIPVAL <> '5')"
				cQuery += " ORDER BY DV9_KM, DV9_FAIXAP "
			Else
				cQuery += "ORDER BY "+SqlOrder(DV9->(IndexKey()))
			EndIf
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDV9,.T.,.T.)
			For nY := 1 To Len(aStruDV9)
				If aStruDV9[nY][2] <> "C"
					TcSetField(cAliasDV9,aStruDV9[nY][1],aStruDV9[nY][2],aStruDV9[nY][3],aStruDV9[nY][4])
				EndIf
			Next nY
			If lDV9_UF
				While (cAliasDV9)->(!Eof())
					aAdd(aFreteP,{(cAliasDV9)->DV9_KM     , ;  //1
									(cAliasDV9)->DV9RECNO   , ;  //2
									(cAliasDV9)->DV9_VALOR  , ;  //3
									(cAliasDV9)->DV9_TIPVAL , ;  //4
									(cAliasDV9)->DV9_ICBASE , ;  //5
									(cAliasDV9)->DV9_PERCEN , ;  //6
									(cAliasDV9)->DV9_CARGAE , ;  //7
									(cAliasDV9)->DV9_TIPCAR , ;  //8
									(cAliasDV9)->DV9_UF     , ;  //9
									(cAliasDV9)->DV9_FAIXAP , ;  //10 Faixa de Peso para a Pauta de Frete
									(cAliasDV9)->DV9_UFERMS , ;  //11 Indica se ira calcular o UFERMS do Estado do MS
									(cAliasDV9)->DV9_PERUFE } )  //12 Percentual para calculo com base na tabela de pauta de frete fornecida pela secretaria de fazenda do estado
					(cAliasDV9)->(dbSkip())
				EndDo
			Else
				While (cAliasDV9)->(!Eof())
					aAdd(aFreteP,{(cAliasDV9)->DV9_KM     , ;
									(cAliasDV9)->DV9RECNO   , ;
									(cAliasDV9)->DV9_VALOR  , ;
									(cAliasDV9)->DV9_TIPVAL , ;
									(cAliasDV9)->DV9_ICBASE , ;
									(cAliasDV9)->DV9_PERCEN , ;
									(cAliasDV9)->DV9_CARGAE , ;
									(cAliasDV9)->DV9_TIPCAR } )
					(cAliasDV9)->(dbSkip())
				EndDo
			EndIf
			(cAliasDV9)->(dbCloseArea())
			dbSelectArea("DV9")
		EndIf
		If lDV9_UF
			nScan := Ascan(aFreteP,{|x| x[1] >= M->C5_KM .And. x[5] == "2" .And. x[8] == cTipCar .And. x[9] == cEstOri })
			If nScan > 0
				If !Empty(cMoeda)
					dbSelectArea("SM2")
					SM2->(DbSetOrder(1))
					If SM2->(MsSeek(dtos(dDataBase)))
						nUFERMS :=	&('SM2->M2_MOEDA'+cMoeda) // Valor informado no cadastro de moeda, com base no site da SEFAZ do estado do MS
						If aFreteP[nScan][11] == '2'
							nPercUFERMS  := aFreteP[nScan][12]
							nUFERMSPauta := aFreteP[nScan][3]
							nUFERMSPauta := nUFERMSPauta * (nPercUFERMS / 100) * nUFERMS
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			nScan := Ascan(aFreteP,{|x| x[1] >= M->C5_KM .And. x[5] == "2" .And. x[8] == cTipCar })		
		EndIf
		If nScan > 0
			If nUFERMSPauta <> 0
				Do Case
					Case aFreteP[nScan][4] == "1"
						M->C5_VLR_FRT := NoRound((nPeso/1000) * nUFERMSPauta ,TamSX3("C5_VLR_FRT")[2])
				EndCase
			Else				
				Do Case
					Case aFreteP[nScan][4] == "1"
						M->C5_VLR_FRT := NoRound((nPeso/1000)*	 aFreteP[nScan][3] ,TamSX3("C5_VLR_FRT")[2])
					Case aFreteP[nScan][4] == "2"
						M->C5_VLR_FRT := NoRound((nPeso      *	 aFreteP[nScan][3]),TamSX3("C5_VLR_FRT")[2])
					Case aFreteP[nScan][4] == "3"
						M->C5_VLR_FRT := NoRound(						 aFreteP[nScan][3] ,TamSX3("C5_VLR_FRT")[2])
					Case aFreteP[nScan][4] == "4"
						M->C5_VLR_FRT := NoRound(Max(nQtdEixo,1) * Max(nKm,1) * aFreteP[nScan][3] ,TamSX3("C5_VLR_FRT")[2])
					Case aFreteP[nScan][4] == "5"
						M->C5_VLR_FRT := NoRound(nPesoM3 *				 aFreteP[nScan][3] ,TamSX3("C5_VLR_FRT")[2])				
				EndCase
				
				//Indice de Pauta de Frete
				If AliasIndic("DMC")
					DV9->(DBGoTo(aFreteP[nScan][2]))
					cAliasDMD := GetNextAlias()
					cQryDMD := "	SELECT DMC.DMC_VALOR, DMD.DMD_OPERAD "
					cQryDMD += " FROM " + RetSqlName("DMD") + " DMD "
					cQryDMD += " INNER JOIN " + RetSqlName("DMC") + " DMC "
					cQryDMD += " ON DMD.DMD_INDICE = DMC.DMC_INDICE AND DMC.DMC_FILIAL = DMD.DMD_FILIAL "
					cQryDMD += " WHERE DMD_FILIAL = '" +	xFilial('DMD')	+ "'	 AND "
					cQryDMD += " 	DMD.DMD_TARIFA =  '" +	DV9->DV9_TARIFA	+ "'  	 AND "
					cQryDMD += " 	DMD.DMD_KM	   =  '" +	STR(DV9->DV9_KM,7,0)	+ "'   	 AND "
					cQryDMD += " 	DMD.DMD_TIPCAR =  '" + 	DV9->DV9_TIPCAR	+ "'     AND "
					cQryDMD += " 	DMD.DMD_UF	   =  '" + 	DV9->DV9_UF     + "'     AND "
					cQryDMD += " 	(DMC.DMC_DTAVLD	   >= '" +  DtoS(Date())	+ "'	 OR " 
					cQryDMD += "    DMC.DMC_DTAVLD	   = ' ') AND "
					cQryDMD += " 	DMD.D_E_L_E_T_ =  ' ' AND "
					cQryDMD += " 	DMC.D_E_L_E_T_ =  ' ' "
					cQryDMD := ChangeQuery(cQryDMD)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryDMD),cAliasDMD)

					If (cAliasDMD)->(!Eof()) .And. !Empty((cAliasDMD)->DMC_VALOR)
						cIndice 	  := (cAliasDMD)->DMD_OPERAD + AllTrim(STR((cAliasDMD)->DMC_VALOR))
						M->C5_VLR_FRT := Round(M->C5_VLR_FRT &(cIndice),TamSX3("C5_VLR_FRT")[2])
					EndIf
					(cAliasDMD)->(dbCloseArea())
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return Nil


/*/{Protheus.doc} TMSHoraRMT(cUF,lSTKImpDoc) 
	Busca data e hora de emissao da Nota - Data / Hora
	@type		Static Function
	@since		19/07/21
	@version	1.0
	@param		cUF,lSTKImpDoc 
	@return		aDataBase	
/*/
Function TMSHoraRMT(cUF,lSTKImpDoc)
Local cHoraRMT   := SuperGetMV("MV_HORARMT",,"2")	//-- Define se obtem a hora do: 1=Horario do SmartClient; 2=Horario do servidor;  3=Fuso horário da filial corrente;
Local cHVerFil   := SuperGetMV("MV_TMSHRFL",,"" )	//-- Define Filiais que nao aderiram ao horario de verao e/ou possuem diferenca de fuso.
Local cFilCdrOri := SuperGetMV("MV_CDRORI" ,,"" )    //-- Regiao da filial logada
Local lHVerao    := SuperGetMV("MV_TMSHRVR",,.F.)	//-- Define se encontra-se no periodo de horario de verao.
Local aDataBase  := {}
Local aAreaDUY   := {}

Default cUF       := SuperGetMV("MV_ESTADO",.F.,"")
Default lSTKImpDoc:= IsInCallStack("TMSIMPDOC")

//-- Busca data e hora de emissao do conhecimento - Data / Hora
If !lSTKImpDoc  .And. (!Empty(cHVerFil) .And. cFilAnt $ cHVerFil) .Or. (cHoraRMT == "3")
	If	FindFunction("FwTimeUF")
		//-- Depois de oito anos sem adota-lo, o estado da Bahia, no Nordeste, o adotou em 2011.
		//-- Em 2012, no entanto, a Bahia voltou atras nessa decisao.
		cUF := IIF(cUF == "BA", "PE", cUF)
		If (cHoraRMT == "3")
		 	aAreaDUY   := DUY->( GetArea() )
			cUF := Posicione("DUY",1,xFilial("DUY")+cFilCdrOri,"DUY_EST")
			RestArea(aAreaDUY)
		EndIf
		aDataBase := FwTimeUF(cUF,,lHVerao)
	EndIf
EndIf

FwFreeArray(aAreaDUY)
Return aDataBase

/*/{Protheus.doc} TMSObsDoc(cDoc,cSerie,cCliev,cLojDev) 
	Retorna a descricao do campo F3_OBSERV
	@type		Function
	@since		18/10/2021
	@version	1.0
	@param		cDoc,cSerie,cCliev,cLojDev 
	@return		cRet	
/*/
Function TMSObsDoc(cDoc,cSerie,cCliev,cLojDev)
 
Local cRet     := 'CTE CANCELADO'
Local cFilDoc  := SF3->F3_FILIAL //Tabela SF3 já está posicionada chamada da funcao xFisAtuSF3 fonte IMPXFIS
Local aAreaDT6 := DT6->(GetArea())

Default cDoc    := ''
Default cSerie  := ''
Default cCliev  := ''
Default cLojDev := ''

	DT6->(DbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE                                                                                                                         
	If DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
		If (DT6->DT6_DOCTMS = '5')
			cRet := 'NF CANCELADA'
		EndIf	
	EndIf

	RestArea(aAreaDT6)

Return (cRet)

/*/{Protheus.doc} TMSVeApoio(cFilDoc,cDoc,cSerie) 
Verifica se o Documento é de Apoio e gera Fatura/Nota Fiscal
@type		Function
@since		05/11/2021
@version	1.0
@param		cFilDoc,cDoc,cSerie
@return		lRet
/*/
Function TMSVeApoio(cFilDoc,cDoc,cSerie)
Local lRet		:= .F.
Local aArea		:= GetArea()
Local aAreaDT6	:= DT6->(GetArea())
Local aAreaDUI	:= DUI->(GetArea())

	DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
		lRet := DT6->DT6_DOCTMS $ "|B|C|H|I|N|O|" .And. !Empty(Posicione('DUI',1,xFilial('DUI')+DT6->DT6_DOCTMS,'DUI_DOCFAT'))
	EndIf

	RestArea(aAreaDUI)
	RestArea(aAreaDT6)
	RestArea(aArea)

Return lRet

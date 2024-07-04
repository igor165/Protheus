#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "LOCXNF2.CH"
#INCLUDE "FWBROWSE.CH"

//Tipos de validacao de parametros
#Define SpEmpty 1

Static nFatF3TpAn := 0 // Motivo de Anulacao para Republica Dominicana gravada em MATXFIS
Static cPVOld:= ""
Static cRetOld := ""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103VFold ³ Autor ³ Edson Maricate        ³ Data ³ 10.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo de valores para campos Totalizadores.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Referencia ( vide MATXFIS)                         ³±±
±±³          ³ ExpC2 = Valor da Referencia                                ³±±
±±³          ³ ExpL3 = .T./.F.- Executa o Refresh do folder               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Campos Totalizadores do MATA103                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³24/07/15³PCREQ-4256³ Se eliminan modificaciones a         ³±±
±±³            ³        ³          ³ SX1(AjustaSX1NF2), SIX(PutIndex),    ³±±
±±³            ³        ³          ³ SX3(AjustaSX3NF2), SX7(AjustaSx7NF2) ³±±
±±³            ³        ³          ³ Y SXB(AjustaSXBNF2). adecuacion      ³±±
±±³            ³        ³          ³ estructuras SX Version 12            ³±±
±±³Alf. Medrano³19/11/15³PCREQ-4263³ se realiza merge 12.1.8              ³±±
±±³Jonathan glz³01/03/16³PCDEF2015_³ Se modifica a Funcion FiltoRemTop()  ³±±
±±³            ³        ³2016-2244 ³ Se cambia la posicion de instrucion  ³±±
±±³            ³        ³          ³ TcSetField(cAlias2...), para que se  ³±±
±±³            ³        ³          ³ haga dentro de valizdacion de aFiltro³±±
±±³            ³        ³          ³ y solo trate campos de tipo date     ³±±
±±³Marco A. Glz³01/08/16³  TVCPMZ  ³ Replica de Automaizacion de TES para ³±±
±±³            ³        ³          ³ version 12.1.7 (COL)                 ³±±
±±³Jonathan glz³01/12/16³SERINN001-³ Limpieza de uso de funcion CriaTrab. ³±±
±±³            ³        ³       384³ Se elimina AjustaSX3NF2,AjustaSX5NF2 ³±±
±±³            ³        ³          ³ y AjustaSX7NF2 para limpieza de SX.  ³±±
±±³Jonathan glz³10/02/17³  MMI-4859³ se agregan los campos f1_valadi y    ³±±
±±³            ³        ³          ³ d1_valadi en las facturas para el    ³±±
±±³            ³        ³          ³ proceso de anticipo de comprar México³±±
±±³LuisEnriquez³13/02/17³ MMI-4171 ³ Replica de llamado TUSX71. Se creo la³±±
±±³            ³        ³          ³ funcion VldNFApoc para validar si un ³±±
±±³            ³        ³          ³ cliente/proveedor pertence al padrón ³±±
±±³            ³        ³          ³ de facturas apocrifas y se eliminó la³±±
±±³            ³        ³          ³ función AjustaSX3NF2.                ³±±
±±³Dora Vega   ³15/02/17³  MMI-195 ³ Se agrega la funcion fBoxCPERNC(ARG) ³±±
±±³LuisEnriquez³22/02/17³ MMI-4171 ³ Merge 12.1.14 MI Se creo la funcion  ³±±
±±³            ³        ³          ³ VldNFApoc para validar si un cliente ³±±
±±³            ³        ³          ³ o proveedor pertence al padron de    ³±±
±±³            ³        ³          ³ facturas apocrifas.                  ³±±
±±³Laura Medina³24/05/17³MMI-5788  ³ Se agrega lectura del RFC XML Recep- ³±±
±±³            ³        ³          ³ tor y su respectiva validacion (MEX).³±±
±±³Marco A. Glz³06/07/17³ MMI-6150 ³Replica de issue MMI-5384 que consiste³±±
±±³            ³        ³          ³en colocar TES y CF en una NF creada a³±±
±±³            ³        ³          ³partir de un Pedido de Compra. (COL)  ³±±
±±³L. Samaniego³22/09/17³TSSERMI01 ³Se agregan campos para CFDI 3.3.      ³±±
±±³            ³        ³ -149     ³Mexico.                               ³±±
±±³Raul Ortiz M³22/12/17³DMICNS-652³Creacion campos F2_VALCOT,F2_ACOPLA,  ³±±
±±³            ³        ³          ³F2_VEHICL y modificacion campo        ³±±
±±³            ³        ³          ³DUT_CATVEI. - (Arg)                   ³±±
±±³M.Camargo   ³22/03/18³DMINA-2335³Se modifica VldUUId para que las vali-³±±
±±³            ³        ³          ³daciones no se realicen cuando la NF  ³±±
±±³            ³        ³          ³se genera por pedimentos(mata447)     ³±±
±±³            ³        ³          ³Se inicializan variables cNaturez y   ³±±
±±³            ³        ³          ³cCondicao en función  LXTUDOKMEX      ³±±
±±³            ³        ³          ³Se adecua función leexml para que     ³±±
±±³            ³        ³          ³detone funcionalidad para rutina      ³±±
±±³            ³        ³          ³mata447                               ³±±
±±³LuisEnríquez³26/04/18³DMINA-1766³Grabar D1_CUSTO en documentos de des- ³±±
±±³            ³        ³DMINA-2483³pacho (FOB y gastos) (MEX-COL)        ³±±
±±³Oscar Garcia³17/05/18³DMINA-2802³Se reemplaza el uso de CriTrab en la  ³±±
±±³            ³        ³          ³funcion MontaTabEspBrow, en la cual se³±±
±±³            ³        ³          ³FWTemporaryTable(). (PTG)             ³±±
±±³LuisEnriquez³25/05/18³DMINA-2717³Se crea funcionalidad para actualiza- ³±±
±±³            ³        ³          ³cion de Saldos en la tabla SCQ y SB2, ³±±
±±³            ³        ³          ³tras eliminacion de Remito que utiliza³±±
±±³            ³        ³          ³solicitud previa. (Pais: Todos)       ³±±
±±³Oscar Garcia³28/06/18³DMINA-3466³En Fun fCposNf2() se asigna condicion ³±±
±±³            ³        ³          ³cnNFTipo == 14 para activar los campos³±±
±±³            ³        ³          ³F1_UUID,F1_FECTIMB y F1_TIMBRE. MEX   ³±±
±±³Alf. Medrano³21/11/18³DMINA-4481³En fun RateioRemFac se inicializan los³±±
±±³            ³        ³          ³campos DE_EC05DB y DE_EC05CR solo si  ³±±
±±³            ³        ³          ³estos existen en array aHeadSDE. MEX  ³±±
±±³ M.Camargo  ³        ³          ³DMINA-4980 MEX                        ³±±
±±³ V. Flores  ³13/03/19³DMINA-6078³En la función fCposNf2 se modifica el ³±±
±±³            ³        ³          ³un atributo del campo F1_OBSERV       ³±±
±±³            ³        ³          ³indicando que es de tipo Memo. MEX    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function LxA103VFold(cReferencia,xValor,lRefre)
Local aArea    := GetArea()
Local lRetorno  := .T.

DEFAULT lRefre := .T.
If MaFisFound("NF") .And. !(MaFisRet(,cReferencia)==xValor)
	MaFisAlt(cReferencia,xValor)
	MaFisToCols(aHeader,aCols,,"MT100")
	If lRefre
		Eval(bRefresh)
		Eval(bGDRefresh)
	EndIf
EndIf
RestArea(aArea)
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103AtuQuali³ Rev.  ³Fernando Joly Siquini³Data  ³12.04.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Inclui/Exclui  produtos  no  CQ  (Materiais  ou  Microsiga) ³±±
±±³          ³Obs.: Para  a  Inclusao  deve-se utilizar antes as funcoes: ³±±
±±³          ³      1.A103CHKQUALI:  Verifica   se  o  Produto  deve  ser ³±±
±±³          ³        enviado ao CQ (Retorna .T. ou .F.)                  ³±±
±±³          ³      2.A103PREQUALI: Prepara o  sistema para a inclusao do ³±±
±±³          ³        Produto   no   CQ  (DEVE  ser  utilizada  antes  da ³±±
±±³          ³        A103ATUSB2)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103AtuQuali(EC1,EC2,EC3,EC4,EC5,EC6,EC7,EL1,EN2,EA1)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = 01.C¢digo                                          ³±±
±±³          ³ ExpC2 = 02.Numero do Documento                             ³±±
±±³          ³ ExpC3 = 03.S‚rie do Documento                              ³±±
±±³          ³ ExpC4 = 04.Cliente/Fornecedor                              ³±±
±±³          ³ ExpC5 = 05.Loja                                            ³±±
±±³          ³ ExpC6 = 06.Item da NF                                      ³±±
±±³          ³ ExpC7 = 07.Tipo de NF                                      ³±±
±±³          ³ ExpL1 = 09.Envia o Produto p/CQ? (.T.=Sim ou .F.=Nao)      ³±±
±±³          ³ ExpN2 = 10.Tipo de Movimentacao (1=Inclus„o/2=Estorno)     ³±±
±±³          ³ ExpA1 = 11.Array com os Recnos do SF1 ref. as NF utilizadas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 , A103Grava()                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LxA103AtuQuali(cCod, cDoc, cSerie, cCliFor, cLoja, cItem, cTipoNF, lEnviaCQ, nOpc, aRecSF1Ori)
Local aAreaAnt   := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSC7   := SC7->(GetArea())
Local aAreaSD1   := SD1->(GetArea())
Local aAreaSD5   := SD5->(GetArea())
Local aMov       := {}
Local aEnvCele   := {}
Local aRecCele   := {}
Local cSeekSD7   := ''
Local lRet       := .T.
Local nAtraso    := 0
Local nRecSD7    := 0
Local aRetQIE 	 := {"",.F.,""}
Local cSeekSD5
Local nQtd       := 0
Local lAtuSD7	 := .T.
Local cLotCtlQie := ''
Local cNumLotQie := ''


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reinicializa Variaveis passadas como Parƒmetro               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCod       := IIf(cCod==Nil,SD1->D1_COD,cCod)
cDoc       := IIf(cDoc==Nil,SD1->D1_DOC,cDoc)
cSerie     := IIf(cSerie==Nil,SD1->D1_SERIE,cSerie)
cCliFor    := IIf(cCliFor==Nil,SD1->D1_FORNECE,cCliFor)
cLoja      := IIf(cLoja==Nil,SD1->D1_LOJA,cLoja)
cItem      := IIf(cItem==Nil,SD1->D1_ITEM,cItem)
cTipoNF    := IIf(cTipoNF==Nil,IIf(Type('cTipo')=='C',cTipo,''),cTipoNF)
lEnviaCQ   := IIf(lEnviaCQ==Nil,.F.,lEnviaCQ)
nOpc       := IIf(nOpc==Nil,0,nOpc)
aRecSF1Ori := IIf(aRecSF1Ori==Nil,{},aClone(aRecSF1Ori))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona SB1   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SB1')
dbSetorder(1)
If !MsSeek(xFilial('SB1')+cCod, .F.)
	lRet := .F.
EndIf

// Posiciona SD1
dbSelectArea('SD1')
dbSetOrder(1)
If lRet .And. !MsSeek(xFilial('SD1')+cDoc+cSerie+cCliFor+cLoja+cCod+cItem, .F.)
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Tipo da NF  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. Empty(cTipoNF)
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a A103ChkQuali autorizou o envio p/o CQ          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. nOpc == 1
	lRet := lEnviaCQ
EndIf

If nOpc == 1 .And. lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a INCLUSAO no CQ                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa a Distribuicao Automatica do Produto   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Localiza(SD1->D1_COD) .And. !Empty(SuperGetMV('MV_DISTAUT'))
		A100Distri(SD1->D1_COD, SD1->D1_LOCAL, SD1->D1_NUMSEQ, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA, Nil, Nil, SD1->D1_QUANT,SD1->D1_LOTECTL,SD1->D1_NUMLOTE)
	EndIf
	nQtd := SD1->D1_QUANT
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclui o Tipo 0 (ZERO) ref. a Saldo Original no SD7          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!(cTipoNF $'CIP') .And. cPaisLoc == "BRA") .Or.;
			(cTipoNF $ "NBCD" .And. nQtd > 0 .And. cPaisLoc # "BRA")
		If fGeraCQ0('SD1', SD1->D1_COD, 'CP')
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o Numero do CQ no Item da NF / Remito                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(SD1->D1_NUMCQ==SD7->D7_NUMERO)
				RecLock('SD1',.F.)
				Replace D1_NUMCQ With SD7->D7_NUMERO
				MsUnlock()
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a Integracao com o SigaQIE							 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == 'Q'

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona o Registro do SD5, para envio do LOTECTL+NUMLOTE a ³
				//³ qAtuMatQie().												 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cLotCtlQie := ''
				cNumLotQie := ''

				If Rastro(SB1->B1_COD,"L") .Or. Rastro(SB1->B1_COD,"S")
					aAreaSD5 := SD5->(GetArea())
					SD5->(dbSetOrder(3))
					cSeekSD5:=xFilial('SD5')+SD1->D1_NUMSEQ+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_LOTECTL
					If SD5->(MsSeek(cSeekSD5, .F.))
						cLotCtlQie := SD5->D5_LOTECTL
						cNumLotQie := SD5->D5_NUMLOTE
					EndIf
					SD5->(dbSetOrder(aAreaSD5[2]))
					SD5->(MsGoto(aAreaSD5[3]))

                EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pesquisa O Pedido de Compras para calcular os dias de atraso ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SC7->(dbSetOrder(1))
				cSeekSC7 := xFilial('SC7')+SD1->D1_PEDIDO+SD1->D1_ITEMPC
				If SC7->(MsSeek(cSeekSC7, .F.))
					nAtraso := SD1->D1_DTDIGIT-SC7->C7_DATPRF
				Else
					nAtraso :=  0
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava os dados referentes ao Inspecao de Entradas (SIGAQIE)  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aEnvCele := {SD1->D1_DOC,; //Numero da Nota Fiscal
					SD1->D1_SERIE,;   		//Serie da Nota Fiscal
					SD1->D1_TIPO,;    		//Tipo da Nota Fiscal
					SD1->D1_EMISSAO,; 		//Data de Emissao da Nota Fiscal
					SD1->D1_DTDIGIT,; 		//Data de Entrada da Nota Fiscal
					"NF",; 	  				//Tipo de Documento
					SD1->D1_ITEM,; 		    //Item da Nota Fiscal
					" ",; 						//Numero do Remito (Localizacoes)
					SD1->D1_PEDIDO,; 			//Numero do Pedido de Compra
					SD1->D1_ITEMPC,; 			//Item do Pedido de Compra
					SD1->D1_FORNECE,; 		//Codigo Fornecedor/Cliente
					SD1->D1_LOJA,; 		    //Loja Fornecedor/Cliente
					SD1->D1_LOTEFOR,; 		//Numero do Lote do Fornecedor
					Space(6),; 			    //Codigo do Solicitante
					SD1->D1_COD,; 			//Codigo do Produto
					SD1->D1_LOCAL,; 			//Local Origem
					cLotCtlQie,;				//Numero do Lote
					cNumLotQie,; 				//Sequencia do Sub-Lote
					SD1->D1_NUMSEQ,; 			//Numero Sequencial
					SD7->D7_NUMERO,; 			//Numero do CQ
					SD1->D1_QUANT,; 			//Quantidade
					SD1->D1_TOTAL,; 			//Preco
					nAtraso,;		 			//Dias de atraso
					SD1->D1_TES,;				//TES
					AllTrim(FunName()),; 	//Origem
					" ",; 						//Origem TXT
					0}                      //Quantidade do Lote Original

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Realiza a integracao Materiais x Inspecao de Entradas		 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRetQIE := qAtuMatQie(aEnvCele,1)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Liberação Automatica (FREE-PASS) - Parametrizada no SigaQIE  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aRetQIE[1] == 'C' .Or. aRetQie[1] == 'L'

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Realiza Automaticamente a Libera‡„o da movimenta‡Æo no SD7   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aMov := {}
					aAdd(aMov, {})
					aAdd(aMov[Len(aMov)], 1)              		//-- Tipo da Movimentação (1=Lobera/2=Rejeita)
					aAdd(aMov[Len(aMov)], SD7->D7_SALDO)     	//-- Quantidade a ser Movimentada
					aAdd(aMov[Len(aMov)], SD7->D7_LOCDEST)  	//-- Local de Destino da Movimentação
					aAdd(aMov[Len(aMov)], SD7->D7_DATA)      	//-- Data da Movimentação
					aAdd(aMov[Len(aMov)], '')                 //-- X=Estornado
					aAdd(aMov[Len(aMov)], '')                 //-- Motivo da Rejeição
					aAdd(aMov[Len(aMov)], aRetQIE[2])        	//-- Observação
					aAdd(aMov[Len(aMov)], SD7->D7_QTSEGUM)   	//-- Quantidade na 2a Unidade de Medida
					fGravaCQ(SD7->D7_PRODUTO, SD7->D7_NUMERO, .F., aMov,PegaCMD1())
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Execblock QIEA210T apos gravacao da movim. do CQ Celerina    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock('QIEA210T')
					ExecBlock('QIEA210T', .F., .F., {'EST'})
				EndIf

			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclui o Tipo 8 (Oito) ref. a Despesas Agregadas no SD7      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If fGeraCQ8(SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_COD, SD1->D1_ITEM, 'CP', SD1->D1_LOCAL, aRecSF1Ori,,,,,SD1->D1_NFORI)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o Numero do CQ no Item da NF                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(SD1->D1_NUMCQ==SD7->D7_NUMERO)
				RecLock('SD1',.F.)
				Replace D1_NUMCQ With SD7->D7_NUMERO
				MsUnlock()
			EndIf
		EndIf
	EndIf
	If cPaisLoc == "BRA"
		Pergunte('MTA103',.F.)
	EndIf
ElseIf lRet .And. nOpc == 2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza o ESTORNO do CQ                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SD7')
	dbSetOrder(1)
	cSeekSD7 := xFilial('SD7')+SD1->D1_NUMCQ+SD1->D1_COD+SD1->D1_LOCAL
	If MsSeek(cSeekSD7, .F.)
		nRecSD7 := Recno()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Testa a possibilidade de uma NF tipo "C" com quantidade      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cTipoNF == "C" .and. cPaisLoc == "BRA") .Or. (cTipoNF $ "DC" .and. cPaisLoc # "BRA")
			If cPaisLoc == "BRA"
				lAtuSD7 := .F.
			Else
				If SD1->D1_QUANT <= 0
					lAtuSD7 := .F.
				EndIf
			Endif
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclui o Tipo 9 (Nove) ref. a ESTORNO de Desp. Agreg. no SD7 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fEstoCQ8(SD1->D1_NUMCQ, SD1->D1_COD, SD1->D1_LOCAL, If(!lAtuSD7,{SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA},Nil))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Deleta TODAS as Movimenta‡”es Referentes de CQ no SD7        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (!(cTipoNF=='C') .and. cPaisLoc == "BRA") .Or. (cPaisLoc <> "BRA" .and. lAtuSD7)
			dbSelectArea('SD7')
			dbSetOrder(1)
			MsGoto(nRecSD7)
			While !Eof() .And. cSeekSD7 == D7_FILIAL+D7_NUMERO+D7_PRODUTO+D7_LOCAL
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exclus„o do CQ no SigaQIE                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If D7_TIPO==0 .And. D7_ORIGLAN=='CP' .And. RetFldProd(SB1->B1_COD,"B1_TIPOCQ")=='Q'
					SC7->(dbSetOrder(1))
					If SC7->(MsSeek(xFilial('SC7')+SD1->D1_PEDIDO+SD1->D1_ITEMPC, .F.))
						nAtraso := SD1->D1_DTDIGIT-SC7->C7_DATPRF
					EndIf

					If RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == 'Q'
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Posiciona o registro no SD5 para que o LOTECTL+NUMLOTE seja en³
						//³viado para qAtuMatQie()										 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cLotCtlQie := ''
						cNumLotQie := ''

						If Rastro(SB1->B1_COD,"L") .Or. Rastro(SB1->B1_COD,"S")
							aAreaSD5 := SD5->(GetArea())
							cSeekSD5 := xFilial('SD5')+SD1->D1_NUMSEQ+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_LOTECTL
							SD5->(dbSetOrder(3))
							If SD5->(MsSeek(cSeekSD5, .F.))
								cLotCtlQie := SD5->D5_LOTECTL
								cNumLotQie := SD5->D5_NUMLOTE
							EndIf
							//Retorna a posicao do SD5
							SD5->(dbSetOrder(aAreaSD5[2]))
							SD5->(MsGoto(aAreaSD5[3]))

						EndIf

						aEnvCele := {SD1->D1_DOC,;  	 	//Numero da Nota Fiscal
							SD1->D1_SERIE,;   				//Serie da Nota Fiscal
							SD1->D1_TIPO,;    				//Tipo da Nota Fiscal
							SD1->D1_EMISSAO,; 				//Data de Emissao da Nota Fiscal
							SD1->D1_DTDIGIT,; 				//Data de Entrada da Nota Fiscal
							"NF",; 	  						//Tipo de Documento
							SD1->D1_ITEM,; 				  	//Item da Nota Fiscal
							SD1->D1_REMITO,; 				 	//Numero do Remito (Localizacoes)
							SD1->D1_PEDIDO,; 				  	//Numero do Pedido de Compra
							SD1->D1_ITEMPC,; 				  	//Item do Pedido de Compra
							SD1->D1_FORNECE,; 				//Codigo Fornecedor/Cliente
							SD1->D1_LOJA,; 				  	//Loja Fornecedor/Cliente
							SD1->D1_LOTEFOR,; 				//Numero do Lote do Fornecedor
							Space(6),; 					  	//Codigo do Solicitante
							SD1->D1_COD,; 					//Codigo do Produto
							SD1->D1_LOCAL,; 				  	//Local Origem
							cLotCtlQie,;				  	  	//Numero do Lote
							cNumLotQie,; 				  	  	//Sequencia do Sub-Lote
							SD1->D1_NUMSEQ,; 				  	//Numero Sequencial
							SD7->D7_NUMERO,; 				  	//Numero do CQ
							SD1->D1_QUANT,; 				  	//Quantidade
							SD1->D1_TOTAL,; 				  	//Preco
							nAtraso,;					      	//Dias de atraso
							SD1->D1_TES,;     			 	//TES
							AllTrim(FunName()),;				//Origem
							" ",; 								//Origem TXT
							0}									//Quantidade do Lote Original

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Realiza a exclusao do material enviado para Inspecao		 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRecCele := qAtuMatQie(aEnvCele,2)
					EndIf
				EndIf
				RecLock('SD7', .F.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		EndIf
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

RestArea(aAreaSD1)
RestArea(aAreaSC7)
RestArea(aAreaSB1)
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GerRE5³ Rev.  ³ Edson Maricate        ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera Req. RE5 vinculada a NF Entrada ( Apr. OP )            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103GerRE5()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103,A103Grava()                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103GerRE5(lEnviaCQ)
Local aAreaSBE := {}
Local aArea	:= GetArea()
Local nQuant
Local lLocaliza:= Localiza(SD1->D1_COD)
Local cLocaliz := ""

If SF4->F4_ESTOQUE == "S" .And. !Empty(SD1->D1_OP) .And. !lEnviaCQ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera distribuicao automatica             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLocaliza
		aAreaSBE := SBE->(GetArea())
		SBE->(dbSetOrder(1))
		If SBE->(MsSeek(xFilial("SBE")+SD1->D1_LOCAL))
			cLocaliz := SBE->BE_LOCALIZ
		EndIf
		SBE->(RestArea(aAreaSBE))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa a Distribuicao Automatica do Produto                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		A100Distri(SD1->D1_COD,SD1->D1_LOCAL,SD1->D1_NUMSEQ,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,cLocaliz,Nil,SD1->D1_QUANT,SD1->D1_LOTECTL,SD1->D1_NUMLOTE)
	EndIf
	dbSelectArea("SD3")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera requisicao automatica               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SD3",.T.)
	SD3->D3_FILIAL	:= xFilial("SD3")
	SD3->D3_COD		:= SD1->D1_COD
	SD3->D3_QUANT	:= SD1->D1_QUANT
	SD3->D3_TM		:= "999"
	SD3->D3_OP		:= SD1->D1_OP
	SD3->D3_LOCAL	:= SD1->D1_LOCAL
	SD3->D3_DOC		:= SD1->D1_DOC
	SD3->D3_EMISSAO	:= SD1->D1_DTDIGIT
	SD3->D3_NUMSEQ	:= SD1->D1_NUMSEQ
	SD3->D3_UM		:= SD1->D1_UM
	SD3->D3_GRUPO	:= SD1->D1_GRUPO
	SD3->D3_TIPO	:= SD1->D1_TP
	SD3->D3_SEGUM	:= SD1->D1_SEGUM
	SD3->D3_CONTA	:= SD1->D1_CONTA
	SD3->D3_CF		:= "RE5"
	SD3->D3_QTSEGUM	:= SD1->D1_QTSEGUM
	SD3->D3_USUARIO	:= SubStr(cUsuario,7,15)
	SD3->D3_CUSTO1	:= SD1->D1_CUSTO
	SD3->D3_CUSTO2	:= SD1->D1_CUSTO2
	SD3->D3_CUSTO3	:= SD1->D1_CUSTO3
	SD3->D3_CUSTO4	:= SD1->D1_CUSTO4
	SD3->D3_CUSTO5	:= SD1->D1_CUSTO5
	SD3->D3_NUMLOTE	:= SD1->D1_NUMLOTE
	SD3->D3_LOTECTL	:= SD1->D1_LOTECTL
	SD3->D3_DTVALID	:= SD1->D1_DTVALID
	SD3->D3_LOCALIZ := cLocaliz
	SC2->(dbSetOrder(1))
	If SC2->(MsSeek(xFilial("SC2")+SD1->D1_OP))
		SD3->D3_CC			:= SC2->C2_CC
		SD3->D3_ITEMCTA	:= SC2->C2_ITEMCTA
		SD3->D3_CLVL		:= SC2->C2_CLVL
	EndIf

	dbSelectArea("SD4")
	dbSetOrder(1)
	If dbSeek(xFilial("SD4")+SD1->D1_COD+SD1->D1_OP)
		nQuant := IIf(SD4->D4_QUANT < SD1->D1_QUANT,SD4->D4_QUANT,SD1->D1_QUANT)
		RecLock("SD4",.f.)
		SD4->D4_QUANT	:= SD4->D4_QUANT - nQuant
		SD4->D4_QTSEGUM	:= SD4->D4_QTSEGUM + ConvUM(SD4->D4_COD, nQuant, 0, 2)
		dbSelectArea("SB2")
		dbSetOrder(1)
		If MsSeek(xFilial("SB2")+SD4->D4_COD+SD4->D4_LOCAL)
			RecLock("SB2",.F.)
			nQuant := IIf(nQuant==NIL,SD1->D1_QUANT,nQuant)
			Replace B2_QEMP  With B2_QEMP - nQuant
			Replace B2_QEMP2 With B2_QEMP2 - ConvUM(SB2->B2_COD, nQuant, 0, 2)
		EndIf
	EndIf
	B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
	C2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
EndIf
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103ChkQuali³ Rev.  ³Fernando Joly Siquini³Data  ³08.06.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se o Produto em questao sera enviado ao CQ         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103ChkQuali(EC1,EC2,EC3,EC4,EC5,EC6,EC7,EL1)			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = 01.C¢digo                                          ³±±
±±³          ³ ExpC2 = 02.Numero do Documento                             ³±±
±±³          ³ ExpC3 = 03.S‚rie do Documento                              ³±±
±±³          ³ ExpC4 = 04.Cliente/Fornecedor                              ³±±
±±³          ³ ExpC5 = 05.Loja                                            ³±±
±±³          ³ ExpC6 = 06.Item da NF                                      ³±±
±±³          ³ ExpC7 = 07.Tipo de NF                                      ³±±
±±³          ³ ExpL1 = 09.Envia ao CQ? (a ser inicializado)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 , A103Grava()                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LxA103ChkQuali(cCod, cDoc, cSerie, cCliFor, cLoja, cItem, cTipoNF, lEnviaCQ)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Variaveis Locais                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAreaAnt   := GetArea()
Local aAreaSA5   := SA5->(GetArea())
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSC7   := SC7->(GetArea())
Local aAreaSD1   := SD1->(GetArea())
Local cLocCQ     := SuperGetMV('MV_CQ')
Local lRet       := .T.
Local nQtd       := 0
Local cPe76		 := LocxPE(76)
Local lPeRet	 := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reinicializa Variaveis passadas como Parƒmetro               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCod     := IIf(cCod==Nil,SD1->D1_COD,cCod)
cDoc     := IIf(cDoc==Nil,SD1->D1_DOC,cDoc)
cSerie   := IIf(cSerie==Nil,SD1->D1_SERIE,cSerie)
cCliFor  := IIf(cCliFor==Nil,SD1->D1_FORNECE,cCliFor)
cLoja    := IIf(cLoja==Nil,SD1->D1_LOJA,cLoja)
cItem    := IIf(cItem==Nil,SD1->D1_ITEM,cItem)
cTipoNF  := IIf(cTipoNF==Nil,IIf(Type('cTipo')=='C',cTipo,''),cTipoNF)
lEnviaCQ := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona SB1                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SB1')
dbSetorder(1)
If !MsSeek(xFilial('SB1')+cCod, .F.)
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona SD1                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SD1')
dbSetOrder(1)
If lRet .And. !MsSeek(xFilial('SD1')+cDoc+cSerie+cCliFor+cLoja+cCod+cItem, .F.)
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Tipo da NF                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. Empty(cTipoNF)
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o TES movimenta estoque 						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF4")
dbSetOrder(1)
MsSeek(xFilial("SF4")+SD1->D1_TES)
If SF4->F4_ESTOQUE # "S"
	lRet := .F.
EndIf

If lRet
	nQtd:=SD1->D1_QUANT
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Produto em quest„o deve ser enviado ao CQ      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cPaisLoc == "BRA" .and. cTipoNF == 'C') .Or.;
			(cPaisloc <> "BRA" .and. cTipoNF $"DC" .and. nQtd <= 0) //-- NF de Complementos de Preco
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Condições de Envio ao CQ para Notas de Complemento:          ³
		//³ *Itens  de  NF's  de  Complemento e   de  Frete  ou  Despesa de ³
		//³  Importa‡„o serão enviados ao  CQ  se  o  campo  D1_Local j  ³
		//³  estiver preechido com um Local igual ao do MV_CQ.           ³
		//³ *Itens de NF's de Complemento de Pre‡o  ser„o enviadas ao CQ ³
		//³  se o  D1_Local  do Item da NF Original pesquisada for igual ³
		//³  ao do MV_CQ.                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SD1->D1_ORIGLAN $'FRúDP' .And. SD1->D1_Local == cLocCQ
			lEnviaCQ := .T.
		ElseIf !Empty(SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_ITEMORI)
			If SD1->(MsSeek(xFilial('SD1')+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD+SD1->D1_ITEMORI, .F.)) .And. SD1->D1_LOCAL==cLocCQ
				lEnviaCQ := .T.
			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Condi‡”es de Envio ao CQ para os demais Tipos de Notas:      ³
		//³ *Itens de  NF's Normais e de devolução  com o  D1_Local		  ³
		//³ preenchido  com um Local igual ao do MV_CQ (o usuario esta   ³
		//³ for‡ando o envio).  												  ³
		//³ *Produtos com Controle de CQ (B1_CQ)MICROSIGA ser„o enviados ³
		//³  ao CQ se:                                                   ³
		//³  1.A Nota  da  Amarra‡„o  ProdutoXFornecedor  (A5_NOTA)  for ³
		//³    inferior a Nota Minima do Produto (B1_NOTAMON);           ³
		//³  2.A NF atual  for  escolhida  pelo  crit‚rio  de  SKIP-LOTE ³
		//³    parametrizado na amarra‡„o ProdutoXFornecedor.            ³
		//³ *Produtos com Controle de CQ (B1_CQ) QUALITY  ser„o enviados ³
		//³  ao CQ se a fun‡„o QAIMPENT retornar "I"(Inspecionar) ou "C" ³
		//³  (Certificar).                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipoNF $ 'N*D' .And. SD1->D1_LOCAL == cLocCQ
			lEnviaCQ := .T.
		ElseIf RetFldProd(SB1->B1_COD,"B1_TIPOCQ") $' úM' //-- Controle de CQ somente pelos m¢dulos de Materiais
			dbSelectArea('SA5')
			dbSetOrder(1)
			If MsSeek(xFilial('SA5')+cCliFor+cLoja+cCod, .F.)
				If QtdComp(A5_SKIPLOT)>QtdComp(0)
					If QtdComp(Mod(A5_ENTREGA,A5_SKIPLOT))==QtdComp(0)
						lEnviaCQ := .T.
					EndIf
					RecLock('SA5',.F.)
					Replace A5_ENTREGA With (A5_ENTREGA+1)
					MsUnlock()

				ElseIf QtdComp(A5_NOTA)<QtdComp(SB1->B1_NOTAMIN)
					lEnviaCQ := .T.
				EndIf
			EndIf
		ElseIf RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == 'Q' .And. !(cTipoNf $ 'IP') //-- Controle de CQ simuntƒneo por Materiais/SIGAQIE
			lEnviaCQ := .T.
		ElseIf RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == 'Q' .And. cTipoNf $ 'IP'
			lEnviaCQ := .T.
		EndIf
		If QieTipoNF(SD1->D1_TIPO,SD1->D1_TES)
			lEnviaCQ := .F.
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada p/ validar se o produto deve ir para o CQ ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cPe76)
	lPeRet := ExecBlock(cPE76,.F.,.F.,{lEnviaCQ,cTipoNf})
	If ValType(lPeRet) <> "L"
		lPeRet := .F.
	EndIf
	lEnviaCQ := lPeRet
EndIf

RestArea(aAreaSD1)
RestArea(aAreaSC7)
RestArea(aAreaSB1)
RestArea(aAreaSA5)
RestArea(aAreaAnt)

Return lEnviaCQ

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103PreQuali³ Rev.  ³Fernando Joly Siquini³Data  ³08.06.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Prepara os arquivos para o envio do produto ao CQ           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103PreQuali(EC1,EC2,EC3,EC4,EC5,EC6,EC7,EL1)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = 01.C¢digo                                          ³±±
±±³          ³ ExpC2 = 02.Numero do Documento                             ³±±
±±³          ³ ExpC3 = 03.S‚rie do Documento                              ³±±
±±³          ³ ExpC4 = 04.Cliente/Fornecedor                              ³±±
±±³          ³ ExpC5 = 05.Loja                                            ³±±
±±³          ³ ExpC6 = 06.Item da NF                                      ³±±
±±³          ³ ExpC7 = 07.TES                                             ³±±
±±³          ³ ExpL1 = 08.Envia ao CQ? (.T.=Sim ou .F.=Nao)               ³±±
±±³          ³ ExpC8 = 09.Almoxarifado do Item                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 , A103Grava()                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LxA103PreQuali(cCod, cDoc, cSerie, cCliFor, cLoja, cItem, cTES, lEnviaCQ, cLocal)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Variaveis Locais                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAreaAnt   := GetArea()
Local aAreaSB6   := SB6->(GetArea())
Local aAreaSD1   := SD1->(GetArea())
Local aAreaSF4   := SF4->(GetArea())
Local cLocCQ     := SuperGetMV('MV_CQ')
Local lRet       := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reinicializa Variaveis passadas como Parƒmetro               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCod     := IIf(cCod==Nil,SD1->D1_COD,cCod)
cDoc     := IIf(cDoc==Nil,SD1->D1_DOC,cDoc)
cSerie   := IIf(cSerie==Nil,SD1->D1_SERIE,cSerie)
cCliFor  := IIf(cCliFor==Nil,SD1->D1_FORNECE,cCliFor)
cLoja    := IIf(cLoja==Nil,SD1->D1_LOJA,cLoja)
cItem    := IIf(cItem==Nil,SD1->D1_ITEM,cItem)
cTES     := IIf(cTES==Nil,SD1->D1_TES,cTES)

lEnviaCQ := IIf(lEnviaCQ==Nil,.F.,lEnviaCQ)

dbSelectArea('SD1')
dbSetOrder(1)
If lRet .And. !MsSeek(xFilial('SD1')+cDoc+cSerie+cCliFor+cLoja+cCod+cItem, .F.)
	lRet := .F.
EndIf

dbSelectArea('SF4')
dbSetOrder(1)
If lRet .And. (!MsSeek(xFilial('SF4')+cTES, .F.) .Or. !(F4_ESTOQUE=='S'))
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a A103ChkQuali autorizou o envio p/o CQ          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	lRet := lEnviaCQ
EndIf

If lRet
	cLocal := SD1->D1_LOCAL
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Almoxarifado CQ no Item da NF (SD1)                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(SD1->D1_LOCAL==cLocCQ)
		RecLock('SD1', .F.)
		Replace D1_Local With cLocCQ
		MsUnlock()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava almoxarifado CQ no Contr. Poder de 3o (SB6)            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF4->F4_PODER3 $'RúD'
		If !Empty(SD1->D1_IDENTB6)
			dbSelectArea('SB6')
			dbSetOrder(3)
			If MsSeek(xFilial('SB6')+SD1->D1_IDENTB6+SD1->D1_COD+SF4->F4_PODER3, .F.)
				If !(SB6->B6_LOCAL==cLocCQ)
					RecLock('SB6', .F.)
					Replace B6_Local With cLocCQ
					MsUnlock()
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSF4)
RestArea(aAreaSD1)
RestArea(aAreaSB6)
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103SD1AtuSDE³ Autor ³ Edson Maricate     ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a atualizacao do arquivo de Rateios por CC           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lxa103SD1AtuSDE(nOpc,aRatCC,aRecSDE,aHeaderSDE,aCustoEnt)

Local aArea		:= GetArea()
Local aTotCust	:= {}
Local lVer641	:= VerPadrao('641')	// Entrada de NF Devolucao/Beneficiamento ( Cliente ) - Itens do Rateio
Local lVer651	:= VerPadrao('651')	// Entrada de NF Normal ( Fornecedor ) - Itens do Rateio
Local lVer656	:= VerPadrao('656')	// Exclusao de NF ( Fornecedor ) - Itens do Rateio
Local nP		:= 0
Local nCusto	:= 0
Local nX       := 0
Local ny       := 0
Local nz		:= 0
Local nD		:= 0
Local nM       := 0
Local aTam		:= {}
Local cFilSDE := xFilial('SDE')

cLoteCom   := If(Type('cLoteCom') == 'U',"",cLoteCom)

If nOpc == 1
	aTotCust		:= aClone(aCustoEnt)
	Afill(aTotCust,0)
	If SD1->D1_RATEIO == '1'
		nx	:= aScan(aRatCC,{|x| x[1] == SD1->D1_ITEM})
		If nx > 0
			For nD := 1 to Len(aCustoEnt)
				cVar := Trim("DE_CUSTO" + Alltrim(str(nD)))
				If SDE->(FieldPos(cVar)) > 0
					AADD(aTam,(TamSX3(cVar)[2]))
				EndIF
			Next
			For nz := 1 to Len(aRatCC[nx][2])
				dbSelectArea('SDE')
				RecLock('SDE',.T.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza os dados contidos na GetDados                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For ny := 1 to Len(aHeaderSDE)
					If aHeaderSDE[ny][10] # "V"
						cVar := Trim(aHeaderSDE[ny][2])
						If !Empty(aRatCC[nx][2][nz][ny])
							SDE->(FieldPut(FieldPos(cVar),aRatCC[nx][2][nz][ny]))
						Endif
					EndIf
				Next
				SDE->DE_FILIAL	:= cFilSDE
				SDE->DE_DOC		:= SD1->D1_DOC
				//SDE->DE_SERIE	:= SD1->D1_SERIE
				SerieNfId("SDE",1,"DE_SERIE",,,,SD1->D1_SERIE) //Projeto Chave Unica - Tiago Silva
				SDE->DE_FORNECE	:= SD1->D1_FORNECE
				SDE->DE_LOJA	:= SD1->D1_LOJA
				SDE->DE_ITEMNF	:= aRatCC[nx][1]
				nP              := 0
				For nP:= 1 to Len(aCustoEnt)
					cVar   := Trim("DE_CUSTO" + Alltrim(str(nP)))
					If SDE->(FieldPos(cVar)) > 0
						If nZ <> Len(aRatCC[nx][2])
							nCusto := NoRound(aCustoEnt[nP] * (SDE->DE_PERC/100),aTam[nP])
							SDE->(FieldPut(FieldPos(cVar),nCusto))
							aTotCust[nP] += nCusto
						Else
							SDE->(FieldPut(FieldPos(cVar),aCustoEnt[nP]-aTotCust[nP]))
						EndIf
					EndIf
				Next

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava os campos Memos Virtuais da Tabela SDE       				  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Type("aMemoSDE") == "A"
					For nM := 1 to Len(aMemoSDE)
						nPosMemo := aScan(aHeaderSDE,{|x| AllTrim(x[2])== aMemoSDE[nM][2] })
						If nPosMemo <> 0 .And. !Empty(aRatCC[nx][2][nz][nPosMemo])
							MSMM(&(aMemoSDE[nM][1]),,,aRatCC[nx][2][nz][nPosMemo],1,,,"SDE",aMemoSDE[nM][1])
						EndIf
					Next nM
				EndIf

				MsUnlock()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera Lancamento contabil 641- Devolucao / Beneficiamento ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lGeraLanc
					If cTipo $ 'BD' .And. lVer641
						nTotalLcto	+= DetProva(nHdlPrv,'641','MATA103',cLoteCom)
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Gera Lancamento contabil 651- NF Entrada- Itens          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lVer651
							nTotalLcto	+= DetProva(nHdlPrv,'651','MATA103',cLoteCom)
						EndIf
					EndIf
				EndIf
			Next
		EndIf
	EndIf
Else
	For nX	:= 1 to Len(aRecSDE)
		dbSelectArea('SDE')
		MsGoto(aRecSDE[nx])
		If SDE->DE_ITEMNF == SD1->D1_ITEM
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera Lancamento contabil 656- Exclusao - Itens       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lVer656.And.!Empty(SF1->F1_DTLANC)
				nTotalLcto += DetProva(nHdlPrv,'656','MATA103',cLoteCom)
			EndIf
			RecLock('SDE',.F.,.T.)
			dbDelete()
			MsUnlock()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui campos Memos Virtuais da tabela SYP vinculado aos memos SDE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("aMemoSDE") == "A"
				If Len(aMemoSDE) > 0
					MSMM(&("SDE->"+aMemoSDE[1][1]),,,,2)
			    EndIf
			EndIf
		EndIf
	Next nX

EndIf
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103EstSB6³ Prog. ³Edson Maricate         ³Data  ³07.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Efetua o estorno dos registros do SB6. ( Poder 3os )        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103EstSB6()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103EstSB6()
Local aArea		:= GetArea()
Local aAreaSB6	:= SB6->(GetArea())

If SF4->F4_PODER3=='R'
	dbSelectArea("SB6")
	dbSetOrder(3)
	If MsSeek(xFilial("SB6")+SD1->D1_NUMSEQ+SD1->D1_COD+"R")
		RecLock("SB6",.F.,.T.)
		dbDelete()
		MsUnlock()
	EndIf
Else
	dbSelectArea("SB6")
	dbSetOrder(3)
	If MsSeek(xFilial("SB6")+SD1->D1_IDENTB6+SD1->D1_COD+"R")
		RecLock("SB6",.F.)
		SB6->B6_UENT	:= CTOD('  /  /  ')
		SB6->B6_SALDO	:= SB6->B6_SALDO + SD1->D1_QUANT
		SB6->B6_ATEND	:= IIf(SB6->B6_SALDO <= 0,"S","N")
		MsSeek(xFilial("SB6")+SD1->D1_IDENTB6+SD1->D1_COD)
		While !Eof() .And. B6_IDENT == SD1->D1_IDENTB6
			If SD1->D1_DOC+SD1->D1_SERIE == B6_DOC+B6_SERIE
				RecLock("SB6",.F.,.T.)
				dbDelete()
				MsUnlock()
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf
EndIf

RestArea(aAreaSB6)
RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103RatCC³ Autor ³ Edson Maricate         ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a tela rateios por Conta Contabil / Centro de Custos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lxa103RatCC(cRatVld)
Local bSavKeyF4 	:= SetKey(VK_F4,Nil)
Local bSavKeyF5 	:= SetKey(VK_F5,Nil)
Local bSavKeyF6 	:= SetKey(VK_F6,Nil)
Local bSavKeyF7 	:= SetKey(VK_F7,Nil)
Local bSavKeyF8 	:= SetKey(VK_F8,Nil)
Local bSavKeyF9 	:= SetKey(VK_F9,Nil)
Local bSavKeyF10	:= SetKey(VK_F10,Nil)
Local bSavKeyF11	:= SetKey(VK_F11,Nil)
Local cPe			:= ""
Local nPosItem		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"} )
Local nPosCC		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CC"} )
Local nPosConta		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CONTA"} )
Local nPosItemCta	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMCTA"} )
Local nPosCLVL		:= Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_CLVL"} )
Local nPosRateio	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_RATEIO"} )
//Local nPosRemito	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_REMITO"	} )
//Local nPosItemRem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMREM"	} )
Local nPosRat		:= aScan(aRatCC,{|x| x[1] == aCols[n][nPosItem]})
Local aSavaRotina	:= aClone(aRotina)
Local aSavCols		:= aCols
Local aSavHeader	:= aClone(aHeader)
Local nSavN			:= n
Local nUsado		:= 0
Local nOpc			:= 0
Local nTotPerc		:= 0
Local nPosPerc		:= 0
Local nX			:= 0
Local nY			:= 0
Local oDlg
Local oGetDados
Local lContinua 	:= .T.
Local aButtons 		:= {}
Local nNewTam
Local aColsPar		:= {}
Local lNovo			:= .T.
Local oSize

Private nPercRat    := 0
Private nPercARat	:= 100
Private oPercRat
Private oPercARat

If (!l103Visual .And. CtbInUse())
	aadd(aButtons,{'AUTOM',{|| AdmRatExt(aHeader,aCols,{ |x,y,z,w| NfeCarCC(x,y,@z,w) }) },STR0001,OemToAnsi(STR0002)}) //'Escolha de Rateio Pre-Configurado' # "Rat.Pre"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

If lContinua
	If cRatVld <> Nil .And. cRatVLd == "2"
		SetKey(VK_F4,bSavKeyF4)
		SetKey(VK_F5,bSavKeyF5)
		SetKey(VK_F6,bSavKeyF6)
		SetKey(VK_F7,bSavKeyF7)
		SetKey(VK_F8,bSavKeyF8)
		SetKey(VK_F9,bSavKeyF9)
		SetKey(VK_F10,bSavKeyF10)
		SetKey(VK_F11,bSavKeyF11)
		Return .T.
	EndIf

	n       := 1
	aHeader	:= {}
	aRotina := {{"","",0,1},{"","",0,2},{"","",0,3},{"","",0,4},{"","",0,5}}
	aCols	:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SDE")
	While !EOF() .And. (x3_arquivo == "SDE")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado++
			AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
			If AllTrim(x3_campo) == "DE_PERC"
				nPosPerc	:= nUsado
			EndIf
		EndIf
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A rotina a seguir limpa o rateio digitado no item quando o mesmo for ³
	//³acionado pela validacao do campo D1_RATEIO com conteudo igual a NAO. ³
	//³Quando o rateio e disparado pela tecla F9, o D1_RATEIO sempre sera   ³
	//³igual a SIM e o lValidX3 assume o default .F., porem quando o rateio ³
	//³for acionado pela validacao do D1_RATEIO o lValidX3 sera .T. e aciona³
	//³a rotina a seguir para confirmar ou nao a exclusao do rateio no item.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPosRat > 0
		If Type("M->D1_RATEIO")#"U"
			If M->D1_RATEIO == "2"
				If Aviso(STR0003,STR0004,{STR0005,STR0006})==1 // "Beneficiamento" # "Este item possue rateio, deseja excluir o rateio digitado ?" # "Sim" # "Nao"
					nNewTam   := Len(aRatCC)-1
					aRatCC  := aSize(aDel(aRatCC,nPosRat), nNewTam)
					nPosRat := aScan(aRatCC,{|x| x[1] == aSavCols[nSavN][nPosItem]})
					aSavCols[nSavN][nPosRateio]	:= '2'
				Else
					aSavCols[nSavN][nPosRateio]	:= '1'
		        EndIF
				M->D1_RATEIO:=aSavCols[nSavN][nPosRateio]
		    EndIf
		EndIf
    EndIf

	If nPosRat > 0
		If Len(aRatCC) # 0
			If Len(aRatCC[n][2]) # 0
				lNovo:=.F.
			EndIf
		EndIf
	EndIf

	If lNovo == .T.
		aadd(aCols,Array(nUsado+1))
		For ny := 1 to Len(aHeader)
			If Trim(aHeader[ny][2]) == "DE_ITEM"
				aCols[1][ny] 	:= "01"
			Else
				aCols[1][ny] := CriaVar(aHeader[ny][2])
			EndIf
			aCols[1][nUsado+1] := .F.
		Next ny
	Else
		aCols	:= aClone(aRatCC[nPosRat][2])
	EndIf

	If lInclui
		If	aSavCols[nSavN][nPosRateio] == "1"
			For ny := 1 to Len(aHeader)
				If !Trim(aHeader[ny][2]) $ ("DE_ITEM#DE_PERC#DE_CC#DE_CONTA#DE_ITEMCTA#DE_CLVL")
					aCols[1][ny] := CriaVar(aHeader[ny][2])
				EndIf
				aCols[1][nUsado+1] := .F.
			Next ny
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Totaliza o % ja Rateado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPercRat := 0
	For nX   := 1  To  Len(aCols)
		nPercRat += aCols[nX][aScan(aHeader,{|x| AllTrim(x[2])=="DE_PERC"})]
	Next nX

	nPercARat := 100 - nPercRat

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a chamada do ponto de entrada para atualizar dados no porrateo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPe	:= LocxPE(53)
	If !Empty(cPE)
		ExecBlock(cPE,.F.,.F.,{aSavCols,aSavHeader,nSavn,lNovo})
	EndIf
	If !(Type('l103Auto') <> 'U' .And. l103Auto)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Dialog                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlg FROM 000,000 TO 250,635 TITLE OemToAnsi(STR0007) Of oMainWnd PIXEL //"Rateio por Centro de Custo"

	 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula dimensões                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSize := FwDefSize():New(.T.,,,oDlg)
		oSize:AddObject( "CABECALHO",  100, 10, .T., .T. ) // Totalmente dimensionavel
		oSize:AddObject( "GETDADOS" ,  100, 80, .T., .T. ) // Totalmente dimensionavel
		oSize:AddObject( "RODAPE"   ,  100, 10, .T., .T. ) // Totalmente dimensionavel

		oSize:lProp 	:= .T. // Proporcional
		oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

		oSize:Process() 	   // Dispara os calculos

	 	@ oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI")     SAY OemToAnsi(STR0008) Of oDlg PIXEL SIZE 56 ,9 //"Documento : "
		@ oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI")+33  SAY cSerie+" "+cNFiscal Of oDlg PIXEL SIZE 56 ,9
		@ oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI")+93  SAY OemToAnsi(STR0009) Of oDlg PIXEL SIZE 60 ,9 //"Item :"
		@ oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI")+112 SAY aSavCols[nSavN][nPosItem] Of oDlg PIXEL SIZE 37 ,9

	    oGetDados := MSGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
	     							   oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND"),;
										IIF(l103Visual,2,3),'LxA103RTELOK','LxA103RTETDK','+DE_ITEM',.T.,,,,100,,,,)

		@ oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")     Say OemToAnsi("% Rateada: ") FONT oDlg:oFont OF oDlg PIXEL	 // "% Rateada: "
		@ oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")+30  Say oPercRat VAR nPercRat Picture PesqPict("SCH","CH_PERC") FONT oDlg:oFont COLOR CLR_HBLUE OF oDlg PIXEL
		@ oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")+180  Say OemToAnsi("% A Ratear: ") FONT oDlg:oFont OF oDlg PIXEL	 // "% A Ratear: "
		@ oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")+214 Say oPercARat VAR nPercARat Picture PesqPict("SCH","CH_PERC") FONT oDlg:oFont COLOR CLR_HBLUE OF oDlg PIXEL

		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||IIF(oGetDados:TudoOk(),(nOpc:=1,oDlg:End()),(nOpc:=0))},{||oDlg:End()},, aButtons)
	Else
		nOpc := 1
	EndIf

	aColsPar :={}
	AEval( aCols, { |x| If( !x[ nUsado + 1], AAdd( aColsPar, x ), ) } )
	aCols := aClone( aColsPar )

	If nOpc == 1 .And. !l103Visual
		For nx	:= 1 to Len(aCols)
			If !aCols[nx][Len(aCols[nx])]
				nTotPerc += aCols[nx][nPosPerc]
			EndIf
		Next
		If nTotPerc > 0
			If nPosRat > 0
				aRatCC[nPosRat][2]	:= aClone(aCols)
			Else
				aADD(aRatCC,{aSavCols[nSavN][nPosItem],aClone(aCols)})
			EndIf
			aSavCols[nSavN][nPosRateio]	:= '1'
			aSavCols[nSavN][nPosCC]		:= Space(Len(aSavCols[nSavN][nPosCC]))
			aSavCols[nSavN][nPosConta]	:= Space(Len(aSavCols[nSavN][nPosConta]))
			aSavCols[nSavN][nPosItemCta]	:= Space(Len(aSavCols[nSavN][nPosItemCta]))
			aSavCols[nSavN][nPosCLVL]		:= Space(Len(aSavCols[nSavN][nPosCLVL]))
		Else
			aSavCols[nSavN][nPosRateio]	:= '2'
		EndIf
	EndIf
Endif

If nOpc == 1  //Quando era escolhido cancelar os itens do Rateio tambem era alterados
	If nPosRat > 0
		aRatCC[nPosRat][2]:=aClone( aCols )
	EndIf
EndIf

aRotina	:= aClone(aSavaRotina)
aCols	:= aSavCols
aHeader	:= aClone(aSavHeader)
n		:= nSavN

SetKey(VK_F4,bSavKeyF4)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)

Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103Financ³ Rev   ³ Edson Maricate        ³ Data ³07.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de tratamento do folder financeiro                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Condicao de Pagamento                                 ³±±
±±³          ³ExpO2: Objeto da Janela principal                            ³±±
±±³          ³ExpL3: Indica se o folder eh "somente visualizacao"          ³±±
±±³          ³ExpA4: Array com registros do SE2 quando for visualizacao    ³±±
±±³          ³ExpN5: Indica a posicao X de referencia p/ criacao da Janela ³±±
±±³          ³ExpL6: Indica que a rotina de inclusao automatica deve exibir³±±
±±³          ³       a Tela ao termino do preenchimento                    ³±±
±±³          ³ExpA7: Array com registros do SE1 quando for visualizacao    ³±±
±±³          ³ExpL8: Indica se o folder e inclusao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo exibir/controlar o folder finan³±±
±±³          ³ceiro.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function LxA103Financ(cCondicao ,oDlg,lVisual,aRecSE2,nPosX,lWhenGet,aRecSE1,lInclui,cAliasFin)
Local aTemp		:= {{"","","",CTOD("  /  /  "),0}}
//Local cMoeda    := ""
Local cDescri 	:= ""
Local nx        := 0
Local nBaseDup  := 0
//Local dDatCont	:= dDataBase
Local lDoVisual	:= !lVisual
Local cPrefFin	:= ""
Local oList
Local oMoeda
Local oNatu
Local oDescri
Local oCond
Local oNew
Local oFormC
Local nPosPerc := 0
Local nPosRatc := 0
Local nPosVal  := 0
Local cCondOld:=""
Local cNew:=" "
Local cAuxPaisL := ""
Local aCampos	:=	{"EV_NATUREZ","EV_VALOR","EV_PERC","EV_RATEICC" }	// Indica quais campos serao

DEFAULT aRecSE1	  := {}
DEFAULT cAliasFin := ""

oMultNat := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera prefixo para os alias dos titulos financeiros   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPrefFin := IIf(!Empty(cAliasFin),cAliasFin+"->"+PrefixoCpo(cAliasFin),"")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array com as duplicatas qdo. for visual      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVisual
	dbSelectArea("SE4")
	dbSetOrder(1)
	If MsSeek(xFilial("SE4")+cCondicao)
		cDescri := SE4->E4_DESCRI
	EndIf
	If cPaisLoc == "EQU" .and. Type('cFormCrbo') <> 'U' .and. SF2->(ColumnPos("F2_MODTRAD")) > 0
		cFormCrbo := SF2->F2_MODTRAD
	EndIf
	dbSelectArea("SE2")
	If !Empty(aRecSE2)
		MsGoto(aRecSE2[1])
		aTemp := {}
		cNatureza	:= SE2->E2_NATUREZ
		nMoedaCor	:= SE2->E2_MOEDA
		For nX	:= 1 To Len(aRecSE2)
			MsGoto(aRecSE2[nX])
			If SE2->E2_TIPO = 'NF ' .Or. cPaisLoc <> "BRA"
				If AllTrim(SE2->E2_TIPO) == AllTrim(aCfgNF[8]) //aCfgNF[ScEspecie]
					aAdd(aTemp,{E2_NUM,E2_PREFIXO,E2_PARCELA,E2_VENCTO,E2_VALOR})
				EndIf
			EndIf
		Next nX
	EndIf
	If !Empty(aRecSE1)
		dbSelectArea("SE1")
		MsGoto(aRecSE1[1])
		aTemp := {}
		cNatureza	:= SE1->E1_NATUREZ
		nMoedaCor	:= SE1->E1_MOEDA
		If cPaisLoc == "EUA"
			aTemp := LxAFinEUA(aCfgNF, aRecSE1, FunName())
		Else
			For nX	:= 1 To Len(aRecSE1)
				MsGoto(aRecSE1[nX])
				If SE1->E1_TIPO = 'NF ' .Or. cPaisLoc <> "BRA"
					If AllTrim(SE1->E1_TIPO) == AllTrim(aCfgNF[8]) .OR. substr( E1_ORIGEM, 1, 4 ) == "LOJA" //aCfgNF[ScEspecie]
						aAdd(aTemp,{E1_NUM,E1_PREFIXO,E1_PARCELA,E1_VENCTO,E1_VALOR})
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

   // Incluir um item vazio no array para evitar "out of bounds"
	If Len( aTemp ) == 0
		aAdd( aTemp, {"", "", "", Ctod("  /  /    "), 0 } )
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para alterar valor da Duplicata     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (ExistBlock("A103VLR"))
		nBaseDup:=ExecBlock("A103VLR",.F.,.F.)
		If nBaseDup <> MaFisRet(,"NF_BASEDUP")
			MaFisAlt("NF_BASEDUP",nBaseDup)
		EndIf
	EndIf
	If MaFisFound("NF")
		cNatureza := MaFisRet(,"NF_NATUREZA")
		lDoVisual := IIF(MaFisRet(,"NF_BASEDUP")>0.And.cTipo<>"D",.T.,.F.)
		dbSelectArea("SE4")
		dbSetOrder(1)
		If MsSeek(xFilial("SE4")+cCondicao)
			cDescri := SE4->E4_DESCRI
		Else
			cDescri := CriaVar("E4_DESCRI")
		EndIf
	EndIf
EndIf
cCondOld:=cCondicao
If ((Type('lLocxAuto') == 'U' .Or. !lLocxAuto) .And. ( Type("l103Auto") == "U" .OR. !l103Auto ) .And. 	( Type("l116Auto") == "U" .OR. !l116Auto ) ) .Or. (lWhenGet .And. oDlg<>Nil )


	bDoRefresh	:= {||  LxA103Dupl(MaFisRet(,"NF_BASEDUP"),nMoedaCor,dDEmissao,cCondicao,@aTemp,oList,@oNatu,@oDescri,@oCond,@oMoeda,@cNatureza,@cDescri,oNew )}

	@ 05,04 SAY OemToAnsi(STR0010) Of oDlg PIXEL SIZE 39 ,9 //"Condicao"

	cAuxPaisL := "ANG|ARG|AUS|BOL|CHI|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|SAL|URU|VEN"
	If cPaisLoc <> "ARG"
		@ 04,31 MSGET oCond VAR cCondicao  PICTURE PesqPict('SF1','F1_COND') OF oDlg PIXEL SIZE 22,09 ;
		F3 CpoRetF3('F1_COND') ;
		WHEN VisualSX3('F1_COND') .And. MaFisFound("NF");
		VALID ValType(Eval(bDoRefresh))=="A" .And. (Vazio().Or.(LxA103Cond(cCondicao,@oDescri,@cDescri,lInclui) .And.CheckSX3('F1_COND') .And. Iif((Type("cFunName")=="C".And.cFunName=='MATA467N'),If(cPaisLoc $ cAuxPaisL ,FaVldTabPrc(M->F2_TABELA,M->F2_EMISSAO),.T.),.T.)))
		oCond:lReadOnly := !lDoVisual
	Else
   		cCondOld:=cCondicao
   		@ 04,200 MSGET oNew  VAR cNew   PICTURE PesqPict('SF1','F1_COND') OF oDlg PIXEL SIZE 00,00
		@ 04,31 MSGET oCond VAR cCondicao  PICTURE PesqPict('SF1','F1_COND') OF oDlg PIXEL SIZE 22,09 ;
		F3 CpoRetF3('F1_COND') ;
		WHEN VisualSX3('F1_COND') .And. MaFisFound("NF");
		VALID Vazio().Or.(LxA103Cond(cCondicao,@oDescri,@cDescri,lInclui,Iif(cCondOld<>cCondicao,.T.,.F.)) .And.CheckSX3('F1_COND') .And. Iif((Type("cFunName")=="C".And.cFunName=='MATA467N'),If(cPaisLoc $ cAuxPaisL ,FaVldTabPrc(M->F2_TABELA,M->F2_EMISSAO),.T.),.T.) .And.  Eval(bDoRefresh))
   		oCond:lReadOnly := !lDoVisual
  	EndIf

	@ 19,04 SAY OemToAnsi(STR0011) Of oDlg PIXEL SIZE 19 ,9 //"Descr."
	@ 18,31 MSGET oDescri VAR cDescri  PICTURE PesqPict('SE4','E4_DESCRI') OF oDlg PIXEL SIZE 54,09
	oDescri:lReadOnly := .T.

	@ 33,04 SAY OemToAnsi(STR0012) Of oDlg PIXEL SIZE 41 ,9 //"Natureza"
	@ 33,31 MSGET oNatu VAR cNatureza  PICTURE PesqPict('SE2','E2_NATUREZ') OF oDlg PIXEL SIZE 54,09 ;
		F3 CpoRetF3("E2_NATUREZ") ;
		VALID Vazio(cNatureza).Or.(ExistCpo('SED',cNatureza) .And. LxA103VFold("NF_NATUREZA",cNatureza))
	oNatu:lReadOnly := !lDoVisual
	oNatu:bLostFocus:= { || LxA103VFold("NF_NATUREZA",cNatureza)}

	@ 48,04 SAY OemToAnsi(STR0013) Of oDlg PIXEL SIZE 30,09 //"Moeda"
	@ 47,31 MSGET oMoeda VAR nMoedaCor SIZE 12,09 PIXEL OF oDlg ;
		VALID nMoedaCor<=MoedFin() .And. Eval(bDoRefresh) PICTURE X3Picture("F1_MOEDA")
	If cPaisLoc == "RUS"
		oMoeda:lReadOnly := .T.
	Else
		oMoeda:lReadOnly := !lDoVisual
	EndIf
	If cPaisLoc =="EQU" .and. Type('cFormCrbo') <> 'U' .and. SF2->(ColumnPos("F2_MODTRAD")) > 0
		IIF(!lVisual, cFormCrbo := CriaVar("F2_MODTRAD"),)
		@ 04,340 SAY STR0265 Of oDlg PIXEL SIZE 54,09 //"Forma Cobro"
		@ 04,375 MSGET oFormC VAR cFormCrbo  OF oDlg PIXEL  SIZE 30,09 PICTURE PesqPict('SF2','F2_MODTRAD');
		F3 CpoRetF3('F2_MODTRAD') WHEN VisualSX3('F2_MODTRAD') ;
		VALID Vazio(cFormCrbo) .Or. ValidF3I("S024", cFormCrbo,1,2) HASBUTTON
		oFormC:lReadOnly := !lDoVisual 	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica multinatureza     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (SuperGetMv("MV_MULNATP") .AND. cAliasFin == "SE2") .OR. (SuperGetMv("MV_MULNATR") .AND. cAliasFin == "SE1")
		oList := TWBrowse():New( 4,95,(nPosX/2),54,,{OemToAnsi(STR0014),OemToAnsi(STR0015),OemToAnsi(STR0016),OemToAnsi(STR0017),OemToAnsi(STR0018)},{35,35,20,35,60},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) //"Numero"###"Serie"###"Parc."###"Vencto"###"Valor"

		If (cAliasFin == "SE2" .And. Len(aRecSE2) > 0) .OR. (cAliasFin == "SE1" .And. Len(aRecSE1) > 0)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Condicao para preenchimento da multinatureza ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cWhileSEV := "SEV->EV_FILIAL+SEV->EV_PREFIXO+SEV->EV_NUM+SEV->EV_PARCELA+SEV->EV_TIPO+SEV->EV_CLIFOR+SEV->EV_LOJA == xFilial('SEV')+"+cPrefFin+"_PREFIXO+"+cPrefFin+"_NUM+"+cPrefFin+"_PARCELA+"+cPrefFin+"_TIPO+"

			If cAliasFin == "SE2"
				SE2->(MsGoto(aRecSE2[1]))
				cWhileSEV += cPrefFin+"_FORNECE+"+cPrefFin+"_LOJA"
				cSeekSEV  := "'"+xFilial('SEV')+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA+"'"
			Else
				SE1->(MsGoto(aRecSE1[1]))
				cWhileSEV += cPrefFin+"_CLIENTE+"+cPrefFin+"_LOJA"
				cSeekSEV  := "'"+xFilial('SEV')+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA+"'"
			EndIf
		Else
			cWhileSEV := ""
			cSeekSEV  := ""
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera controles para getdados da multinatureza ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aGridSEV := LocxGrid("SEV",cWhileSEV,,,,cSeekSEV,1,aCampos,,,,,,,,.T.)
		aHeadSEV := aGridSEV[1]
		aColsSEV := aGridSEV[5]
		nPosPerc := aScan(aHeadSEV,{|x| AllTrim(x[2]) == "EV_PERC"})
		nPosVal  := aScan(aHeadSEV,{|x| AllTrim(x[2]) == "EV_VALOR"})
		nPosRatc := aScan(aHeadSEV,{|x| AllTrim(x[2]) == "EV_RATEICC"})
		
		IIf(nPosPerc > 0, aHeadSEV[nPosPerc][6] := "MNatCalcV()", "")
		IIf(nPosVal > 0, aHeadSEV[nPosVal][6]  := "MNatCalcP()", "")
		IIf(nPosRatc > 0, aHeadSEV[nPosRatc][6] := 'Pertence("12") .And. IIf(EV_RATEICC =="1",VldRatC(),.T.)', "")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza campo percentual ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosPerc > 0
			For nx:=1 to len(aColsSEV)
				aColsSEV[nx,nPosPerc] *= 100
			Next
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera getdados para multinatureza ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oMultNat := MsNewGetDados():New(004,(nPosX/2)+100,058,(nposx*1.5)-10,IIf(!lVisual,GD_INSERT+GD_UPDATE+GD_DELETE,0),"LxLOkSEV","LxTOkSEV",/*inicpos*/,/*aalter*/,/*freeze*/,100,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeadSEV,aColsSEV)
		oMultNat:oBrowse:bLostFocus	:= {|| oFldRodape:nOption := IIf(oMultNat:TudoOk(), oFldRodape:nOption , 4 ),aColsSEV:=aClone(oMultNat:aCols)}
	Else
		oList := TWBrowse():New( 4,95,nPosX,54,,{OemToAnsi(STR0014),OemToAnsi(STR0015),OemToAnsi(STR0016),OemToAnsi(STR0017),OemToAnsi(STR0018)},{35,35,20,35,60},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) //"Numero"###"Serie"###"Parc."###"Vencto"###"Valor"
	EndIf

	oList:SetArray(aTemp)
	oList:bLDblClick 	:= {||LxA103EditDupl(oList,aTemp,oList:nColPos)}
	oList:bLine 		:= {|| LxA103Line(oList,aTemp) }
	oList:lAutoEdit	:= !lVisual

EndIf
Return oList

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A103Del  ³ Autor ³ Edson Maricate        ³ Data ³04.03.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica a delecao da linha                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LxA103Del(o)

If !MaFisFound("IT",n)
	MaFisAdd("","",0,0,0,CriaVar("D1_NFORI"),CriaVar("D1_SERIORI"),,0,0,0,0,0)
EndIf

MaFisDel(n,aCols[n][Len(aCols[n])])
If cPaisLoc == "ARG" .and. "NC" $ cEspecie
	MaFisReprocess(2)
EndIf
Eval(bRefresh)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103AtuSC7³ Autor ³ Edson Maricate        ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a baixa do pedido de compras .                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103AtuSC7()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 , A103Grava()                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103SC7(nOpc,lAtuEstoq)
Local aArea	     := GetArea()
Local lSb1TES    := SuperGetMv("MV_SB1TES",.F.,.F.)

DEFAULT lAtuEstoq  := .T.

If Type("lFacImport")!= "L"
	lFacImport := .F.
Endif

If nOpc == 1
	If !Empty(SD1->D1_PEDIDO) .And. Empty(SD1->D1_REMITO)
		dbSelectArea("SC7")
	    dbSetOrder(19)
		If MsSeek(xFilial("SC7")+SD1->D1_COD+SD1->D1_PEDIDO+SD1->D1_ITEMPC)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza a quantidade utilizada do Pedido.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("SD1",.F.)
			SD1->D1_QTDPEDI	:= IIF(SD1->D1_QUANT>SC7->C7_QUANT-SC7->C7_QUJE,SC7->C7_QUANT-SC7->C7_QUJE,SD1->D1_QUANT)
			MsUnlock()
			dbSelectArea("SC7")
			RecLock("SC7",.F.)
			SC7->C7_QUJE 	:= SC7->C7_QUJE + SD1->D1_QTDPEDI
			SC7->C7_ENCER 	:= IIF(C7_QUANT-C7_QUJE>0," ","E")
			MsUnlock()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o Saldo em Pedido do SB2                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea('SF4')
			dbSetOrder(1)
			If MsSeek(xFilial("SF4")+SD1->D1_TES)
				dbSelectArea("SB2")
				dbSetOrder(1)
				If MsSeek(xFilial("SB2")+SC7->C7_PRODUTO+SC7->C7_LOCAL)
					If SF4->F4_ESTOQUE == "S" .Or. SB2->B2_SALPEDI > 0
						RecLock("SB2",.F.)
						If lSb1TES
							If SC7->C7_ESTOQUE=="S" .Or. Empty(SC7->C7_ESTOQUE)
								SB2->B2_SALPEDI := SB2->B2_SALPEDI - SD1->D1_QTDPEDI
								SB2->B2_SALPED2 := SB2->B2_SALPED2 - ConvUm(SD1->D1_COD,SD1->D1_QTDPEDI,0,2)
							EndIf
						Else
							dbSelectArea("SF4")
							dbSetOrder(1)
							If MsSeek(xFilial("SF4")+SD1->D1_TES) .And. SF4->F4_ESTOQUE == 'S'
								SB2->B2_SALPEDI := SB2->B2_SALPEDI - SD1->D1_QTDPEDI
								SB2->B2_SALPED2 := SB2->B2_SALPED2 - ConvUm(SD1->D1_COD,SD1->D1_QTDPEDI,0,2)
							EndIf
						EndIf
						If lFacImport
							SB2->B2_NAOCLAS := SB2->B2_NAOCLAS - SD1->D1_QTDPEDI
						Endif
						MsUnlock()
					EndIf
				EndIf
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o arquivo de pre-requisicoes.                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LxA103SCQ(SD1->D1_QUANT, nOpc)
		EndIf
	EndIf
Else
	If !Empty(SD1->D1_PEDIDO) .And. Empty(SD1->D1_REMITO)
		dbSelectArea("SC7")
	    dbSetOrder(19)
		If MsSeek(xFilial("SC7")+SD1->D1_COD+SD1->D1_PEDIDO+SD1->D1_ITEMPC)
			dbSelectArea("SC7")
			RecLock("SC7",.F.)
			SC7->C7_QUJE 	:= SC7->C7_QUJE - SD1->D1_QTDPEDI
			SC7->C7_ENCER 	:= IIF(C7_QUANT-C7_QUJE>0," ","E")
			MsUnlock()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o Saldo em Pedido do SB2                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea('SF4')
			dbSetOrder(1)
			If ( MsSeek(xFilial("SF4")+SC7->C7_TES) .And. SF4->F4_ESTOQUE == "S" ) .Or. !MsSeek(xFilial()+SC7->C7_TES)
				dbSelectArea("SB2")
				dbSetOrder(1)
				If MsSeek(xFilial("SB2")+SC7->C7_PRODUTO+SC7->C7_LOCAL)
					RecLock("SB2",.F.)
					If lSb1TES
						If SC7->C7_ESTOQUE=="S" .Or. Empty(SC7->C7_ESTOQUE)
							SB2->B2_SALPEDI := SB2->B2_SALPEDI + SD1->D1_QTDPEDI
							SB2->B2_SALPED2 := SB2->B2_SALPED2 + ConvUm(SD1->D1_COD,SD1->D1_QTDPEDI,0,2)
						EndIf
					Else
						dbSelectArea("SF4")
						dbSetOrder(1)
						If MsSeek(xFilial("SF4")+SD1->D1_TES) .And. SF4->F4_ESTOQUE == 'S'
							SB2->B2_SALPEDI := SB2->B2_SALPEDI + SD1->D1_QTDPEDI
							SB2->B2_SALPED2 := SB2->B2_SALPED2 + ConvUm(SD1->D1_COD,SD1->D1_QTDPEDI,0,2)
						EndIf
					EndIf
					If lFacImport
						SB2->B2_NAOCLAS := SB2->B2_NAOCLAS + SD1->D1_QTDPEDI
					Endif
					MsUnlock()
				Endif
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o arquivo de pre-requisicoes.                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LxA103SCQ(SD1->D1_QUANT, nOpc)
		EndIf
	EndIf
EndIf
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103AtuSF9³ Autor ³ Edson Maricate        ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o arquivo de CIAP.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103AtuSF9(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : 1 - Inclusao , 2 - Exclusao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 , A103Grava()                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103SF9(nOpc)
Local aArea	:= GetArea()
Local cFilSF9	:= xFilial("SF9")
Local cFilSFA	:= xFilial("SFA")

If nOpc == 1
	If SF4->F4_CIAP=="S" .And. SD1->D1_VALICM > 0 .And. SF4->F4_CREDICM == "S"
		dbSelectArea("SF9")
		dbSetOrder(1)
		While ( SF9->(MsSeek(cFilSF9+CriaVar("F9_CODIGO"))) )
			If __lSX8
				ConfirmSX8()
			EndIf
		EndDo
		RecLock("SF9",.T.)
		SF9->F9_FILIAL := cFilSF9
		SF9->F9_CODIGO := CriaVar("F9_CODIGO")
		SF9->F9_DESCRI := SB1->B1_DESC
		SF9->F9_FORNECE:= SD1->D1_FORNECE
		SF9->F9_LOJAFOR:= SD1->D1_LOJA
		SF9->F9_DOCNFE := SD1->D1_DOC
		//SF9->F9_SERNFE := SD1->D1_SERIE
		SerieNfId("SF9",1,"F9_SERNFE",,,,SD1->D1_SERIE) //Projeto Chave Unica -  Tiago Silva
		SF9->F9_ITEMNFE:= SD1->D1_ITEM
		SF9->F9_PROPRIO:= IIF(Empty(SD1->D1_FORMUL),"N",SD1->D1_FORMUL)
		SF9->F9_DTENTNE:= SD1->D1_DTDIGIT
		SF9->F9_DTEMINE:= SD1->D1_EMISSAO
		SF9->F9_VALICMS:= SD1->D1_VALICM+SD1->D1_ICMSCOM
		SF9->F9_ROTINA := "MATA103"
		SF9->F9_CFOENT := SD1->D1_CF
		SF9->F9_PICM   := SD1->D1_PICM
		MsUnlock()
		If __lSX8
			ConfirmSX8()
		EndIf
		dbSelectArea("SD1")
		Reclock("SD1",.F.)
		SD1->D1_CODCIAP:= SF9->F9_CODIGO
		MsUnlock()
	EndIf
Else
	If ( !Empty(SD1->D1_CODCIAP) )
		dbSelectArea("SF9")
		dbSetOrder(1)
		If ( MsSeek(cFilSF9+SD1->D1_CODCIAP) )
			dbSelectArea("SFA")
			dbSetOrder(1)
			If ( MsSeek(xFilial("SFA")+SF9->F9_CODIGO) )
				While ( !Eof() .And. cFilSFA == SFA->FA_FILIAL .And.;
						SFA->FA_CODIGO==SF9->F9_CODIGO )
					RecLock("SFA")
					dbdelete()
					dbSkip()
				EndDo
			EndIf
			RecLock("SF9")
			dbDelete()
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103Dupl  ³ Rev   ³ Edson Maricate        ³ Data ³07.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de tratamento do folder financeiro                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Valor Base das duplicatas                             ³±±
±±³          ³ExpN2: Moeda em que se encontra a Duplicata                  ³±±
±±³          ³ExpD3: Data a ser considerada para o calculo das duplicatas  ³±±
±±³          ³ExpC4: Condicao de pagamento para tratamento das duplicatas  ³±±
±±³          ³ExpA5: Array com as duplicatas a serem demonstradas          ³±±
±±³          ³ExpO6: Objeto do ListBox da lista de duplicata               ³±±
±±³          ³ExpO7: Objeto do Get da Natureza                             ³±±
±±³          ³ExpO8: Objeto do Get da Descricao                            ³±±
±±³          ³ExpO9: Objeto do Get da Condicao de Pagamento                ³±±
±±³          ³ExpOA: Objeto do Get da Moeda                                ³±±
±±³          ³ExpCB: Codigo da Natureza                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo exibir/controlar o folder finan³±±
±±³          ³ceiro.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function LxA103Dupl(nBaseDup,nMoeda,dConvert,cCondicao,aRet,oList,oNatu,oDescri,oCond,oMoeda,cNatureza,cDescri)
Local aVenc		:= {}
Local a103Cnd2  := {}
Local nX		:= 0
Local nValor	:= 0
Local nValIpi	:= 0
Local nValSol	:= 0
Local nTotDup 	:= 0
Local cParcela	:= ""
Local nDecimal	:= 0
//Local nValRetImp:= 0
//Local cImpRet	:= ""
Local clTpCF	:= ""
Local cPe		:= ""
Local lPParc	:= .F.
Local dDEmisBKP := dDEmissao
Local dDEmisPE62:= CTOD("")
//Local aAreaSE4
//Local aParcela	:= {}
Local cDupTes := ""
Local lNotDup := .F.
Local cFunName	:= FunName()

//Ajuste referente al calculo de impuestos en título financiero provisional de Remito
//Local nCount	:= 0
//Local aDupl2	:= {}
//Local aPeAnt	:= aPe
//Local cEspAnt	:= cEspecie

If cPaisLoc == "EUA"
	nBaseDup := LxDuplEUA(aCols, aPe, nBaseDup, cEspecie, cFunName)
EndIf

If cModulo $ "FAT"
	clTpCF	:= SA1->A1_TPESSOA
ElseIf cModulo $ "COM"
	clTpCF	:= SA2->A2_TPESSOA
EndIf

If Funname()=="FISA828" .And. Type("lGerDupl")!= "U" .And. !lGerDupl
	lNotDup := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para Data Emissao: LocxPE62	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPe	:= LOCXPE(62)

If !Empty(cPE)
	dDEmisPE62:=ExecBlock(cPE,.F.,.F.,{dDEmissao})
	IF ValType(dDEmisPE62) == "D"
		dDEmissao:=dDEmisPE62
	EndIf
EndIf

LxA103Cond(cCondicao,@oDescri,@cDescri)

//Si es la FINA100, carga los datos para realizar el cálculo para la condición de pago y actualiza los objetos.
If FunName() == "FINA100" .and. !empty(M->D1_TES)
	cDupTes := Posicione("SF4",1,xFilial("SF4")+M->D1_TES,"F4_DUPLIC")
	IF (cDupTes <> "N" .and. !Empty(cDupTes))
		cNFiscal := M->F1_DOC
		cSerie := M->F1_SERIE
		nBaseDup := MaFisRet(,'NF_TOTAL')
		MaFisAlt("NF_BASEDUP",nBaseDup)
	Else
		lNotDup := .T.
	ENDIF
EndIf
If !Empty(cCondicao) .And. nBaseDup> 0
	nValor:= xMoeda(nBaseDup,MaFisRet(,"NF_MOEDA"),nMoeda,dConvert,,MaFisRet(,"NF_TXMOEDA"))
	nValIpi := xMoeda(MaFisRet(,"NF_VALIPI"),MaFisRet(,"NF_MOEDA"),nMoeda,dConvert,,MaFisRet(,"NF_TXMOEDA"))
	nValSol	:= xMoeda(MaFisRet(,"NF_VALSOL"),MaFisRet(,"NF_MOEDA"),nMoeda,dConvert,,MaFisRet(,"NF_TXMOEDA"))
	nVlTit := nValor
	If cPaisLoc=='EQU'
		LxNatEqu(aCols, @lPParc, @cNatureza, MaFisRet(,"NF_OPERNF"), @nValor, @nTotDup, N)
	Else
		nValor := Iif(cPaisLoc == 'COL' .And. !(SE4->(E4_TIPO) $ "B"),ValDuplic(nValor),nValor)
	Endif
	aVenc	:= Condicao(nValor,cCondicao,nValIpi,dDEmissao,nValSol)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para alterar condicao de pagamento  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (ExistBlock("A103CND2"))
		a103Cnd2:=Aclone(aVenc)
		a103Cnd2:=ExecBlock("A103CND2",.F.,.F.,{aVenc})
		If Valtype(a103Cnd2)=="A"
			aVenc:=Aclone(a103Cnd2)
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se condicao de pagamento e' valida          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aVenc)==0 .or. lNotDup
		aVenc:={{Ctod("  /  /  "),0}}
	EndIf

	If cPaisLoc == "MEX"
		xConPagMex(cCondicao, @cParcela, @lPParc)
	EndIf

	If cPaisLoc <> "MEX"
		cParcela := IIF(Len(aVenc)>1,SuperGetMV("MV_1DUP   ")," ")
	EndIf

	If nMoeda == 1
	   nDecimal:= GetMv("MV_CENT")
	Else
	   nDecimal:= GetMv("MV_CENT" +Alltrim(str(nMoeda)))
	EndIf

	If SFB->FB_JNS $'J/S' .And. cPaisLoc == 'COL' .And. !(SE4->E4_TIPO == "B")
		nTotDup := xValDupCol(nTotDup, aHeader, acols, .T.)
	EndIf
	If  cfunname == "MATA101N" .And. cPaisLoc == "ARG"  .and. (Type('ldupli') <> 'U' .and. ldupli)
		//No hacer validacion de condicion de pago, para conservar fecha de vencimiento modificada por el usuario.
	Else
		aRet := {}
		For nX := 1 To Len(aVenc)
			If lPParc
				If nX == 1
					aADD(aRet,{cNFiscal,cSerie,cParcela,aVenc[nX][1],Round(aVenc[nX][2]-nTotDup,nDecimal)})
				Else
					aADD(aRet,{cNFiscal,cSerie,cParcela,aVenc[nX][1],Round(aVenc[nX][2],nDecimal)})
				Endif
			Else
				If nX == Len(aVenc) .And. Len(aVenc) > 1
					aADD(aRet,{cNFiscal,cSerie,cParcela,aVenc[nX][1],NoRound(nValor-nTotDup,nDecimal)})
				Else
					aADD(aRet,{cNFiscal,cSerie,cParcela,aVenc[nX][1],Round(aVenc[nX][2],nDecimal)})
					nTotDup += Round(aVenc[nX][2],nDecimal)
				EndIf
			Endif
			cParcela := IIF(cParcela==" ","A",MaParcela(cParcela))
		Next nX
	EndIf
Else
	aRet := {{"      ","   "," ",CTOD("  /  /  "),0}}
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array utilizado na geracao das duplicatas    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDupl	:= {}
For nX := 1 to Len(aRet)
	If cPaisLoc != 'RUS'
		aAdd(aDupl,aRet[nx][2]+"³"+aRet[nx][1]+"³ "+aRet[nx][3]+" ³";
			+DTOC(aRet[nx][4])+"³ "+Transform(aRet[nx][5],PesqPict("SE2","E2_VALOR")))
	Else
		aAdd(aDupl,aRet[nx][2]+CHR(124)+aRet[nx][1]+CHR(124)+" "+aRet[nx][3]+" "+CHR(124);
		+DTOC(aRet[nx][4])+CHR(124)+" "+Transform(aRet[nx][5],PesqPict("SE2","E2_VALOR")))
	EndIf
Next nX
If !(Type('lLocxAuto') <> 'U' .And. lLocxAuto) .And. !(Type('l103Auto') <> 'U' .And. l103Auto) .and. !(Type('l116Auto') <> 'U' .And. l116Auto) .And. !(lFacImport .And. lEICFinanc)
	oCond:lReadOnly  := nBaseDup == 0
	oNatu:lReadOnly  := nBaseDup == 0
	oMoeda:lReadOnly := Iif(cPaisLoc == "RUS",.T.,nBaseDup == 0)
	oNatu:Refresh()
	oDescri:Refresh()
	oCond:Refresh()
	oMoeda:Refresh()
	oList:SetArray(aRet)
	oList:bLine := {|| LxA103Line(oList,aRet) }
	oList:Refresh()
	//Atualizar dados do rodape ao atribuir desconto no item
	If MaFisRet(,"NF_DESCONTO") > 0
       If Type("__aoGets")!= "U" .And. ValType(__aoGets)=="A"
          For nX:= 1 to Len(__aoGets)
	         __aoGets[nX]:Refresh()
          Next nX
       EndIf
    EndIf
EndIf

//Restatura data emissão
dDEmissao:= dDEmisBKP

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103ForF4 ³ Autor ³ Edson Maricate        ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de importacao de Pedidos de Compra.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103Pedido()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103ForF4(lUsaFiscal,lIsRemito)

	Local nSldPed		:= 0
	Local nOpc			:= 0
	//Local nCntFor		:= 0
	//Local naCols		:= 0
	//Local nPosQUANT		:= 0
	//Local nPosVUNIT		:= 0
	//Local nPosTOTAL		:= 0
	//Local cSavScr		:= ""
	//Local cSavCur		:= ""
	//Local cSavCor		:= ""
	Local cQuery		:= ""
	Local cAliasSC7		:= "SC7"
	//Local lClass		:= .F.
	Local lQuery		:= .F.
	Local bSavSetKey	:= SetKey(VK_F4,Nil)
	Local bSavKeyF5		:= SetKey(VK_F5,Nil)
	Local bSavKeyF6		:= SetKey(VK_F6,Nil)
	Local bSavKeyF7		:= SetKey(VK_F7,Nil)
	Local bSavKeyF8		:= SetKey(VK_F8,Nil)
	Local bSavKeyF9		:= SetKey(VK_F9,Nil)
	Local bSavKeyF10	:= SetKey(VK_F10,Nil)
	Local bSavKeyF11	:= SetKey(VK_F11,Nil)
	Local bWhile
	//Local cVariavel		:= ReadVar()
	Local cChave		:= ""
	//Local cCadastro		:= ""
	Local aArea			:= GetArea()
	Local aAreaSA2		:= SA2->(GetArea())
	Local aAreaSC7		:= SC7->(GetArea())
	Local aCopia		:= aClone(aCols)
	Local aStruSC7		:= SC7->(dbStruct())
	Local aF4For		:= {}
	Local nF4For		:= 0
	Local oOk			:= LoadBitMap(GetResources(), "LBOK")
	Local oNo			:= LoadBitMap(GetResources(), "LBNO")
	Local aButtons		:= { {'PESQUISA',{||A103VisuPC(aRecSC7[oListBox:nAt])},OemToAnsi(STR0019)} } //"Visualiza Pedido"
	Local oDlg,oListBox //,cListBox
	Local cNomeFor		:= ''
	Local aRecSC7		:= {}
	Local lZeraCols		:= .T.
	Local cItem			:= StrZero(1,Len(SD1->D1_ITEM))
	Local aTitCampos	:= {}
	Local aConteudos	:= {}
	Local aUsCont		:= {}
	Local aUsTitu		:= {}
	Local bLine			:= { || .T. }
	Local cLine			:= ""
	Local lMa103F4I		:= ExistBlock('MA103F4I')
	Local lMa103F4H		:= ExistBlock('MA103F4H')
	Local nLoop			:= 0
	Local nX			:= 0
	Local nI			:= 0
	//Local lMt103Vpc		:= ExistBlock("MT103VPC")
	//Local lRet103Vpc	:= .T.
	Local lMt103Cpc		:= ExistBlock("MT103CPC")
	Local lRetMt103Cpc	:= .T.
	Local lContinua		:= .T.
	//Local lMoedaIgual	:= .T.
	Local aMoedaAux		:= {}
	Local cFiltraQry	:= ""
	Local lFiltraQry	:= .F.
	Local aPrvEnt		:= {}
	Local lConsLojaAux	:= lConsLoja
	Local lF1_PROVENT	:= .F.
	Local lC7_PROVENT	:= .F.
	Local lRestNfe		:= SuperGetMV("MV_RESTNFE") == "S"
	Local cFilSA2		:= xFilial("SA2")
	Local cFilSC7		:= xFilial("SC7")
	//Local nLenaCols		:= 0
	//Local nPosiciCF		:= aScan(aHeader, {|x| Alltrim(x[2]) == "D1_CF"})
	Local nPosiProd		:= aScan(aHeader, {|x| Alltrim(x[2]) == "D1_COD"})
    Local lConUn      	:= .F.
	Local lLegContr		:= .F.
    Local aConUn      	:= {}
	Local lCargaPerf    := (Iif(cPaisloc == "ARG" .And. Funname() == "MATA101N", .T., .F.))
	Local nAuxCNT		:= 0
	Local nFreeQT		:= 0
	Local nPosPDD     := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_PEDIDO" })
	Local nPosITM     := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_ITEMPC" })
	Local nPosQTD     := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_QUANT" })

	cPeT := LocxPET(43)
	cPe	:=	LocxPE(43)
	lFiltraQry := If(!Empty(cPe) .Or. !Empty(cPet),.T.,.F.)

	DEFAULT lUsaFiscal	:= .T.
	DEFAULT lIsRemito   := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type("InConPad") == "L"
		lContinua := !InConPad
	EndIf

	If IsInCallStack("fINA100")
		lConsLoja:=!Empty(cLoja)
	Endif

	If Type("aTESPedC") <> "U"
		aTESPedC := Array(0)
	EndIf

	If lContinua

		If MaFisFound("NF") .Or. !lUsaFiscal
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o aCols esta vazio, se o Tipo da Nota e'     ³
			//³ normal e se a rotina foi disparada pelo campo correto    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTipo == "N"
				dbSelectArea("SA2")
				dbSetOrder(1)
				MsSeek(xFilial("SA2")+cA100For+cLoja)
				cNomeFor	:= SA2->A2_NOME

				#IFDEF TOP
					If lFiltraQry
						cFiltraQry	:= ""
						If !Empty(cPet)
							cFiltraQry	+=	ExecTemplate(cPet,.F.,.F.)
						EndIf
						If !Empty(cPe)
							cFiltraQry	+=	Iif(!Empty(cFiltraQry)," AND ","")+ExecBlock(cPe,.F.,.F.)
						EndIf
						If ValType(cFiltraQry) <> 'C'
							cFiltraQry	:=	''
						Endif
					EndIf

					dbSelectArea("SC7")
					If TcSrvType() <> "AS/400"
						lQuery    := .T.
						cAliasSC7 := "QRYSC7"

						cQuery := "SELECT SC7.*, R_E_C_N_O_ RECSC7 FROM "
						cQuery += RetSqlName("SC7") + " SC7 "
						cQuery += "WHERE "
						// cQuery += "C7_FILIAL = '"+xFilEnt(xFilial("SC7"))+"' AND " // ORIGINAL
						cQuery += "C7_FILENT = '"+xFilEnt(xFilial("SC7"))+"' AND "
						cQuery += "C7_FORNECE = '"+cA100For+"' AND "
						cQuery += "C7_TIPO <> 3 AND "
						If ( lConsLoja )
							cQuery += "C7_LOJA = '"+cLoja+"' AND "
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Filtra os Pedidos Bloqueados e Previstos.                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cQuery += "C7_TPOP <> 'P' AND "
						If SuperGetMV("MV_RESTNFE") == "S"
							cQuery += "C7_CONAPRO <> 'B' AND "
						EndIf
						If cPaisLoc $ "ARG|BOL|CHI|PAR|URU"
							cQuery += "SC7.C7_CONAPRO <> 'R' AND " //Pedidos rechazados
						EndIf
						cQuery += "SC7.C7_ENCER='"+Space(Len(SC7->C7_ENCER))+"' AND "
						cQuery += "SC7.C7_RESIDUO='"+Space(Len(SC7->C7_RESIDUO))+"' AND "

						cQuery += "SC7.D_E_L_E_T_ = ' '"


					    If !Empty(cFiltraQry)
							cQuery += "AND "+cFiltraQry
						Else
							cQuery += " ORDER BY C7_NUM"
		      			EndIf
						cQuery := ChangeQuery(cQuery)

						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)

						For nX := 1 To Len(aStruSC7)
							If aStruSC7[nX,2]<>"C"
								TcSetField(cAliasSC7,aStruSC7[nX,1],aStruSC7[nX,2],aStruSC7[nX,3],aStruSC7[nX,4])
							EndIf
						Next nX

						bWhile := {|| (cAliasSC7)->(!Eof())}

					Else
				#ENDIF

					dbSelectArea("SC7")
					dbSetOrder(9)
					If ( lConsLoja )
						cChave := cA100For+CLOJA
					Else
						cChave := cA100For
					EndIf
					MsSeek(xFilEnt(xFilial("SC7"))+cChave,.T.)

					bWhile := {|| (cAliasSC7)->(!Eof()) .And. xFilEnt(xFilial()) == (cAliasSC7)->C7_FILENT .And. ;
						cA100For == (cAliasSC7)->C7_FORNECE .And. ;
						IIf(lConsLoja,CLOJA==(cAliasSC7)->C7_LOJA,.T.)}

					#IFDEF TOP
					Endif
					#ENDIF


				While Eval(bWhile)

					If cPaisLoc == "ARG"
						nFreeQT := 0
						For nAuxCNT := 1 To Len( aCols )
							If 	(aCols[ nAuxCNT,nPosiProd ] == (cAliasSC7)->C7_PRODUTO) .And. ;
									(aCols[ nAuxCNT,nPosPDD ] == (cAliasSC7)->C7_NUM) .And. ;
									(aCols[ nAuxCNT,nPosITM ] == (cAliasSC7)->C7_ITEM) .And. ;
									!ATail( aCols[ nAuxCNT ] )
								nFreeQT += aCols[ nAuxCNT,nPosQTD ]
							EndIf
						Next

						If !((nFreeQT := ((cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE-(cAliasSC7)->C7_QTDACLA-nFreeQT)) > 0)
							dbSkip()
							Loop
						EndIf
					EndIf

					cFiltraQry := "AlwaysTrue()"

					If &(cFiltraQry)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica o Saldo do Pedido de Compra                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nSldPed := (cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE-(cAliasSC7)->C7_QTDACLA
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se nao h  residuos, se possui saldo em abto e   ³
						//³ se esta liberado por alcadas se houver controle.         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lQuery
							If (lRestNfe .And. (cAliasSC7)->C7_CONAPRO == "B") .Or. ;
							   (cAliasSC7)->C7_TPOP == "P" .Or. !Empty((cAliasSC7)->C7_RESIDUO) .Or. (cAliasSC7)->C7_TIPO == 3
								dbSkip()
								Loop
							EndIf
	                    Endif

						nF4For := aScan(aF4For,{|x|x[2]==(cAliasSC7)->C7_LOJA .And. x[3]==(cAliasSC7)->C7_NUM})

						If ( nF4For == 0 )

							aConteudos := {}
							aAdd(aConteudos, .F.) //-- 01
							aAdd(aConteudos, (cAliasSC7)->C7_LOJA) //-- 02
							aAdd(aConteudos, (cAliasSC7)->C7_NUM) //-- 03
							aAdd(aConteudos, DtoC((cAliasSC7)->C7_EMISSAO)) //-- 04
							aAdd(aConteudos, If((cAliasSC7)->C7_TIPO==2, 'AE', 'PC')) //-- 05
							If cPaisLoc == 'RUS'
								aAdd(aConteudos,Posicione("CTO",1,xFilial("CTO")+StrZero((cAliasSC7)->C7_MOEDA,TamSX3("CTO_MOEDA")[1]),"CTO_SIMB"))
						    	aAdd(aConteudos, (cAliasSC7)->C7_CONUNI)
								aAdd(aConteudos, Posicione("F5Q",1,XFILIAL("F5Q")+(cAliasSC7)->C7_F5QUID,"F5Q_CODE"))
							else
						    	aAdd(aConteudos, AllTrim(GetMV('MV_MOEDA' + AllTrim(Str(Max((cAliasSC7)->C7_MOEDA,1)))))) //-- 06
							EndIf
							If cPaisLoc == "ARG" //-- Soh adiciona o 7o elemento se o campo existir na base de dados
								aAdd(aConteudos, (cAliasSC7)->C7_PROVENT) //-- 07
							EndIf
							If (cAliasSC7)->(FieldPos('C7_CODMUN')) > 0 //-- Soh adiciona o 7o elemento se o campo existir na base de dados
								aAdd(aConteudos, (cAliasSC7)->C7_CODMUN) //-- 07
							EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Ponto de Entrada para adicionar Colunas na consulta F4 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lMa103F4I
								If ValType(aUsCont:= ExecBlock('MA103F4I', .F., .F. )) == 'A'
									aEval(aUsCont, {|x| aAdd( aConteudos, x )})
								EndIf
							EndIf

							aAdd(aF4For , aConteudos)
							aAdd(aRecSC7, If(lQuery, (cAliasSC7)->RECSC7, Recno()))
						EndIf
					Endif
					(cAliasSC7)->(dbSkip())
				EndDo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exibe os dados na Tela                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( !Empty(aF4For) )

					aTitCampos := {}
					aAdd(aTitCampos, ' ') //-- 01
					aAdd(aTitCampos, OemToAnsi(STR0020)) //"Loja" //-- 02
					aAdd(aTitCampos, OemToAnsi(STR0021)) //"Pedido" //-- 03
					aAdd(aTitCampos, OemToAnsi(STR0022)) //"Emissao" //-- 04
					aAdd(aTitCampos, OemToAnsi(STR0023)) //"Origem" //-- 05
					aAdd(aTitCampos, OemToAnsi(STR0013)) //"Moeda" //-- 06
					If cPaisLoc == 'RUS'
						aAdd(aTitCampos, AllTrim(RetTitle('C7_CONUNI')))
						aAdd(aTitCampos, AllTrim(RetTitle('C7_F5QCODE')))
					EndIf
					If cPaisLoc == "ARG" //-- Soh adiciona o 7o elemento se o campo existir na base de dados
						aAdd(aTitCampos, AllTrim(RetTitle('C7_PROVENT'))) //"Moeda" //-- 07
					EndIf

					cLine := '{' //-- >>Inicio da String

					cLine += 'If(aF4For[oListBox:nAt, 01], oOk, oNo)' //-- 01
					cLine += ', aF4For[oListBox:nAT, 02]' //-- 02
					cLine += ', aF4For[oListBox:nAT, 03]' //-- 03
					cLine += ', aF4For[oListBox:nAT, 04]' //-- 04
					cLine += ', aF4For[oListBox:nAT, 05]' //-- 05
					cLine += ', aF4For[oListBox:nAT, 06]' //-- 06
					If cPaisLoc == 'RUS'
					   cLine += ', aF4For[oListBox:nAT, 07]' //--Conv.Unit
					   cLine += ', aF4For[oListBox:nAT, 08]' //--Legal Contracts
					EndIf
					If cPaisLoc == "ARG" //-- Soh adiciona o 7o elemento se o campo existir na base de dados
						cLine += ', aF4For[oListBox:nAT, 07]' //-- 07
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de Entrada para definir os Titulos das Colunas adicionadas via ponto de entrada MA103F4I ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lMA103F4H
						If ValType(aUsTitu:=ExecBlock('MA103F4H', .F., .F. )) == 'A'
							For nLoop := 1 To Len( aUsTitu )
								aAdd(aTitCampos, aUsTitu[nLoop])
								cLine += ', aF4For[oListBox:nAT, ' + AllTrim( Str( nLoop + If(cPaisLoc == "ARG", 7, 6) ) ) + ']'
							Next nLoop
						EndIf
					EndIf

					cLine += ' }' //-- <<Final da String

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta dinamicamente o bline do CodeBlock                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					bLine := &( "{ || " + cLine + " }" )

					DEFINE MSDIALOG oDlg FROM 50,40  TO 285,541 TITLE OemToAnsi(STR0024+" - <F5> ") Of oMainWnd PIXEL //"Selecionar Pedido de Compra"

					oListBox := TWBrowse():New( 27,4,243,80,,aTitCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
					oListBox:SetArray(aF4For)
					oListBox:bLDblClick := { || aF4For[oListBox:nAt,1] := !aF4For[oListBox:nAt,1] }
					oListBox:bLine := bLine

					@ 15  ,4   SAY OemToAnsi(STR0025) Of oDlg PIXEL SIZE 47 ,9 //"Fornecedor"
					@ 14  ,35  MSGET cNomeFor PICTURE PesqPict('SA2','A2_NOME') When .F. Of oDlg PIXEL SIZE 120,9

					ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIf(F4ForTOk(aF4For),(nOpc := 1,nF4For := oListBox:nAt,oDlg:End()),.F.)},{||(nOpc := 0,nF4For := oListBox:nAt,oDlg:End())},,aButtons)

					If ( nOpc == 1 )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| Ponto de entrada para nao carregar no aCols os pedidos de compra selecionados    |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lMt103Cpc
							lRetMt103Cpc:=Execblock("MT103CPC",.F.,.F.,{})
							If ValType(lRetMt103Cpc)<>"L"
								lRetMt103Cpc:=.T.
							EndIf
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Monta Array somente com os pedidos selecionados para validacao da moedados pedidos³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					    For nI := 1 To Len(aF4For)
					    	If aF4For[nI][1]
					    		AAdd(aMoedaAux,aF4For[nI])
					    	EndIf
					    Next nI

	                    If cPaisLoc == "RUS"
	                       aConUn := aClone(aMoedaAux)
							If Len(aConUn) >= 1
								Asort(aConUn,,,{|x,y| x[7] > y[7]})
								If (aConUn[1][7] <> aConUn[Len(aConUn)][7])
									lConUn := .T.
								EndIf
								Asort(aConUn,,,{|x,y| x[6] > y[6]})
								If (aConUn[1][6] <> aConUn[Len(aConUn)][6])
									lConUn := .T.
								EndIf
									Asort(aConUn,,,{|x,y| x[8] > y[8]})
								If (aConUn[1][8] <> aConUn[Len(aConUn)][8])
									lLegContr := .T.
								EndIf
							EndIf
							
                        EndIf
	                    If (cPaisLoc == "RUS" .And. !lConUn .And. !lLegContr) .Or. (cPaisLoc <> 'RUS')
					       If lRetMt103Cpc
					    	   lF1_PROVENT:= cPaisLoc == "ARG"
					    	   lC7_PROVENT:= cPaisLoc == "ARG"
								   For nx	:= 1 to Len(aF4For)
								   	If aF4For[nx][1]
								    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								    	//³ Posiciona Fornecedor                                     ³
								    	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								    	dbSelectArea("SA2")
								    	dbSetOrder(1)
									    MsSeek(cFilSA2+cA100For+cLoja)
									   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									   //³ Posiciona Pedido de Compra                               ³
									   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									   dbSelectArea("SC7")
									   dbSetOrder(9)
									   cSeek := ""
									   cSeek += xFilEnt(cFilSC7)+cA100For
									   cSeek += aF4For[nx][2]+aF4For[nx][3]
									   MsSeek(cSeek)
									   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									   //³ Determina si el pedido de Compra tiene productos bloquea2³
									   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									   If cPaisLoc=="ARG" .AND. IsInCallStack("MATA102N") .AND. valProdBloq(cSeek)
									   		If !MsgYesNo(STR0257 + " "+AllTrim(aF4For[nx][3]) +" "+ STR0258, STR0256)
												Loop
											EndIf
										EndIf
									   If lZeraCols
										   aCols		:= {}
										   lZeraCols	:= .F.
										   MaFisClear()
									   EndIf
									   If lF1_PROVENT .And. lC7_PROVENT
										  M->F1_PROVENT:= Iif(Len(aPrvEnt) > 1," ", SC7->C7_PROVENT)
									   EndIf
									   //#PORTUGAL#
									   /*If cPaisLoc == "PTG"
										  M->F1_LIQIMP:= SC7->C7_LIQIMP
									   Endif*/
									   If cPaisLoc == 'RUS'
									       M->F1_MOEDA := SC7->C7_MOEDA
										   nMoedaNF := SC7->C7_MOEDA
									       MaFisRef("NF_MOEDA","MT100",M->F1_MOEDA)
										   M->F1_TXMOEDA:=RecMoeda(M->F1_EMISSAO,M->F1_MOEDA)
										   nTaxa := RecMoeda(M->F1_EMISSAO,M->F1_MOEDA)
									       M->F1_CONUNI:= SC7->C7_CONUNI
										   M->F1_F5QUID:=SC7->C7_F5QUID
										   M->F1_F5QDESC:= Posicione("F5Q",1,XFILIAL("F5Q")+SC7->C7_F5QUID,"F5Q_DESCR")
										   M->F1_CNTID:= SC7->C7_F5QCODE
										   RunTrigger(1,Nil,Nil,,"F1_CNTID")
	                                    EndIf
									    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									    //³ Efetua a chamada do ponto de entrada (Ex. uso: Alterar Moeda)³
									    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									    cPe	:= LocxPE(52)
									    If !Empty(cPE)
										    ExecBlock(cPE,.F.,.F.)
									    EndIf

									   dbSelectArea("SC7")
									   dbSetOrder(14)

									    While ( !Eof() .And. SC7->C7_FILENT+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM==cSeek )
									    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									   		//³ Valida si el producto esta bloqueado bloqueado           ³
									   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									    	If cPaisLoc=="ARG" .AND. IsInCallStack("MATA102N") .AND. !valProd(SC7->C7_PRODUTO,.F.)
												dbSkip()
												Loop
											EndIf
									    	cFiltraQry := "AlwaysTrue()"

										    If &(cFiltraQry)
											   nSldPed := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
											   If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )
												   LxA103SC7ToaCols(SC7->(RecNo()),,nSlDPed,cItem,,,lIsRemito,lCargaPerf)
												   cItem := Soma1(cItem)
											   EndIf
										    Endif

										    dbSelectArea("SC7")
										    dbSkip()
									    EndDo
								   EndIf
							    Next
						    EndIf
					     else
					        If cPaisLoc == 'RUS'
					           Help("",1,"LxA103ForF4 01",,STR0200,1,0)
					        EndIf
					  EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Restaura o Acols caso o mesmo estiver vazio              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cPaisLoc == "ARG" .AND. IsInCallStack("MATA102N") .AND. Len(aCols) == 0
							aCols := aClone(aCopia)
						endif
						If lUsaFiscal
							If lCargaPerf
								MaFisReprocess(2)
							EndIf
							Eval(bListRefresh)
							Eval(bDoRefresh)
						EndIf
					EndIf
				Else
					Help(" ",1,"A103F4")
				EndIf
			Else
				Help('   ',1,'A103TIPON')
			EndIf
		Else
			Help('   ',1,'A103CAB')
		EndIf

	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a Integrida dos dados de Entrada                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQuery
		dbSelectArea(cAliasSC7)
		dbCloseArea()
		dbSelectArea("SC7")
	Endif
	SetKey(VK_F4,bSavSetKey)
	SetKey(VK_F5,bSavKeyF5)
	SetKey(VK_F6,bSavKeyF6)
	SetKey(VK_F7,bSavKeyF7)
	SetKey(VK_F8,bSavKeyF8)
	SetKey(VK_F9,bSavKeyF9)
	SetKey(VK_F10,bSavKeyF10)
	SetKey(VK_F11,bSavKeyF11)

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Atualiza o browse de quantidade de produtos.³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	AtuLoadQt(.T.)

	RestArea(aAreaSA2)
	RestArea(aAreaSC7)
	RestArea(aArea)
	lConsLoja:=lConsLojaAux

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103ItemPC³ Autor ³ Edson Maricate        ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tela de importacao de Pedidos de Compra por Item.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103ItemPC()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103ItemPC(lUsaFiscal,aPedido)

Local cSeek       := ""
Local nOpca 	  := 0
Local aArea		  := GetArea()
Local aAreaSA2	  := SA2->(GetArea())
Local aAreaSC7	  := SC7->(GetArea())
Local aAreaSB1	  := SB1->(GetArea())
Local aStruSC7    := SC7->(dbStruct())
Local aCab        := {}
Local aCampos     := {}
Local aNew        := {}
Local aArrSldo	  := {}
Local aArrayF4	  := {}
Local aTamCab     := {}
Local aButtons	  := { {'PESQUISA',{||A103VisuPC(aArrSldo[oQual:nAt][2])},OemToAnsi(STR0019)} } //"Visualiza Pedido"
Local bSavSetKey  := SetKey(VK_F4,Nil)
Local bSavKeyF5   := SetKey(VK_F5,Nil)
Local bSavKeyF6   := SetKey(VK_F6,Nil)
Local bSavKeyF7   := SetKey(VK_F7,Nil)
Local bSavKeyF8   := SetKey(VK_F8,Nil)
Local bSavKeyF9   := SetKey(VK_F9,Nil)
Local bSavKeyF10  := SetKey(VK_F10,Nil)
Local bSavKeyF11  := SetKey(VK_F11,Nil)
Local nFreeQt     := 0
Local nPosPRD     := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD" })
Local nPosPDD     := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_PEDIDO" })
Local nPosITM     := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_ITEMPC" })
Local nPosQTD     := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_QUANT" })
Local cVar        := aCols[n][nPosPrd]
Local cQuery      := ""
Local cAliasSC7   := "SC7"
Local cCpoObri    := ""
Local nPed        := 0
Local nX		  := 0
Local nAuxCNT	  := 0
//Local nAuxNew
//Local lMt103Vpc   :=ExistBlock("MT103VPC")
Local lMt100C7D   := ExistBlock("MT100C7D")
Local lMt100C7C   := ExistBlock("MT100C7C")
Local lContinua   := .T.
Local lQuery      := .F.
Local oQual
Local oDlg
Local bWhile
Local cFiltraQry    := ""
Local lFiltraQry    := .F.
Local lConsLojaAux	:= lConsLoja
Local lRestNfe		:= SuperGetMV("MV_RESTNFE") == "S"
Local cFilSB1		:= xFilial("SB1")
Local nQtdItMark	:= 0
Local nPosItem   	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
Local aConUn        :={}
Local lConUn        := .F.
Local lCargaPerf    := (Iif(cPaisloc == "ARG" .And. Funname() == "MATA101N", .T., .F.))

PRIVATE oOk        	:= LoadBitMap(GetResources(), "LBOK")
PRIVATE oNo        	:= LoadBitMap(GetResources(), "LBNO")

cPet := LocxPEt(43)
cPe  := LocxPE(43)
lFiltraQry := If(!Empty(cPe) .Or. !Empty(cPet),.T.,.F.)
DEFAULT lUsaFiscal:= .T.
DEFAULT aPedido	  := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

If IsInCallStack("fINA100")
	lConsLoja:=!Empty(cLoja)
Endif

If cPaisLoc == "ARG" .And. FunName() $ "MATA101N|MATA102N"
	cItem := IIf(Type("cItem") == "U", StrZero(n,TamSX3('C1_ITEM')[1]), cItem)
EndIf

If Type("aTESPedC") <> "U"
	aTESPedC := Array(0)
EndIf

If lContinua

	If MaFisFound('NF') .Or. !lUsaFiscal
		If cTipo == 'N'
			#IFDEF TOP

				If lFiltraQry
					cFiltraQry	:=	""
					cPet	:= LocxPEt(43)
					if !Empty(cPet)
						cFiltraQry	+=	ExecTemplate(cPet,.F.,.F.)
					Endif
					cPe	:= LocxPE(43)
					if !Empty(cPe)
						cFiltraQry	+= Iif(!Empty(cFiltraQry)," AND ","") + ExecBlock(cPe,.F.,.F.)
					Endif
					If ValType(cFiltraQry) <> 'C'
						cFiltraQry	:=	''
					Endif
				EndIf
				dbSelectArea("SC7")
				If TcSrvType() <> "AS/400"

					lQuery    := .T.
					cAliasSC7 := "QRYSC7"

					cQuery := "SELECT SC7.*, R_E_C_N_O_ RECSC7 FROM "
					cQuery += RetSqlName("SC7") + " SC7 "
					cQuery += "WHERE "
					cQuery += "C7_FILENT = '"+xFilEnt(xFilial("SC7"))+"' AND "
					cQuery += "C7_TIPO <> 3 AND "

					If Empty(cVar)
						If lConsLoja
							cQuery += "C7_FORNECE = '"+cA100For+"' AND "
							cQuery += "C7_LOJA = '"+cLoja+"' AND "
						Else
							cQuery += "C7_FORNECE = '"+cA100For+"' AND "
						Endif
					Else
						If lConsLoja
							cQuery += "C7_FORNECE = '"+cA100For+"' AND "
							cQuery += "C7_LOJA = '"+cLoja+"' AND "
							cQuery += "C7_PRODUTO = '"+cVar+"' AND "
						Else
							cQuery += "C7_FORNECE = '"+cA100For+"' AND "
							cQuery += "C7_PRODUTO = '"+cVar+"' AND "
						Endif
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra os Pedidos Bloqueados e Previstos.                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery += "C7_TPOP <> 'P' AND "
					If lRestNfe
						cQuery += "C7_CONAPRO <> 'B' AND "
					EndIf
					If cPaisLoc $ "ARG|BOL|CHI|PAR|URU"
						cQuery += "SC7.C7_CONAPRO <> 'R' AND " //Pedidos rechazados
					EndIf
					cQuery += "SC7.C7_ENCER='"+Space(Len(SC7->C7_ENCER))+"' AND "
					cQuery += "SC7.C7_RESIDUO='"+Space(Len(SC7->C7_RESIDUO))+"' AND "

					cQuery += "SC7.D_E_L_E_T_ = ' '"

				    If !Empty(cFiltraQry)
						cQuery += "AND "+cFiltraQry
	      			EndIf
					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)

					For nX := 1 To Len(aStruSC7)
						If aStruSC7[nX,2]<>"C"
							TcSetField(cAliasSC7,aStruSC7[nX,1],aStruSC7[nX,2],aStruSC7[nX,3],aStruSC7[nX,4])
						EndIf
					Next nX
					bWhile := {|| (cAliasSC7)->(!Eof())}
				Else
			#ENDIF
				If Empty(cVar)
					dbSelectArea("SC7")
					dbSetOrder(9)
					If lConsLoja
						cCond := "C7_FILENT+C7_FORNECE+C7_LOJA"
						cSeek := cA100For+cLoja
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					Else
						cCond := "C7_FILENT+C7_FORNECE"
						cSeek := cA100For
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					EndIf
				Else
					dbSelectArea("SC7")
					dbSetOrder(6)
					If lConsLoja
						cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE+C7_LOJA"
						cSeek := cVar+cA100For+cLoja
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					Else
						cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE"
						cSeek := cVar+cA100For
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					EndIf
				EndIf

				bWhile := {|| (cAliasSC7)->(!Eof()) .And. xFilEnt(cFilial)+cSeek == &(cCond)}

				#IFDEF TOP
				EndIf
				#ENDIF

			If Empty(cVar)
				cCpoObri := "C7_LOJA|C7_PRODUTO|C7_QUANT|C7_DESCRI|C7_TIPO|C7_LOCAL|C7_OBS"
			Else
				cCpoObri := "C7_LOJA|C7_QUANT|C7_DESCRI|C7_TIPO|C7_LOCAL|C7_OBS"
			Endif

			AAdd(aCab," ")
			Aadd(aCampos,{"MARK","L","R",""})
			aadd(aTamCab,6)


			If (cAliasSC7)->(!Eof())

				dbSelectArea("SX3")
				dbSetOrder(2)
				MsSeek("C7_NUM")

				AAdd(aCab,x3Titulo())
				Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT})
				aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

				dbSelectArea("SX3")
				dbSetOrder(1)
				MsSeek("SC7")
				While !Eof() .And. SX3->X3_ARQUIVO == "SC7"
					IF ( SX3->X3_BROWSE=="S".And.X3Uso(SX3->X3_USADO).And. AllTrim(SX3->X3_CAMPO)<>"C7_PRODUTO" .And. AllTrim(SX3->X3_CAMPO)<>"C7_NUM").Or.;
							(AllTrim(SX3->X3_CAMPO) $ cCpoObri)
						AAdd(aCab,x3Titulo())
						Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT})
						aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))
					EndIf
					dbSkip()
				Enddo


				dbSelectArea(cAliasSC7)
				While Eval(bWhile)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra os Pedidos Bloqueados e Previstos.                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lQuery
						If (lRestNfe .And. (cAliasSC7)->C7_CONAPRO == "B") .Or. ;
						   (cAliasSC7)->C7_TPOP == "P" .Or. !Empty((cAliasSC7)->C7_RESIDUO) .Or. (cAliasSC7)->C7_TIPO == 3
							dbSkip()
							Loop
						EndIf
                    Endif

					nFreeQT := 0
					nPed    := aScan(aPedido,{|x| x[1] = C7_NUM+C7_ITEM})

					nFreeQT -= If(nPed>0,aPedido[nPed,2],0)

					For nAuxCNT := 1 To Len( aCols )
						If Iif(cPaisLoc == "ARG", .T.,(nAuxCNT # n)) .And. ;
								(aCols[ nAuxCNT,nPosPRD ] == (cAliasSC7)->C7_PRODUTO) .And. ;
								(aCols[ nAuxCNT,nPosPDD ] == (cAliasSC7)->C7_NUM) .And. ;
								(aCols[ nAuxCNT,nPosITM ] == (cAliasSC7)->C7_ITEM) .And. ;
								!ATail( aCols[ nAuxCNT ] )
							nFreeQT += aCols[ nAuxCNT,nPosQTD ]
						EndIf
					Next

					cFiltraQry := "AlwaysTrue()"

					If &(cFiltraQry)
						If ((nFreeQT := ((cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE-(cAliasSC7)->C7_QTDACLA-nFreeQT)) > 0)
							Aadd(aArrayF4,Array(Len(aCampos)))
							For nX := 1 to Len(aCampos)

								If aCampos[nX][3] != "V"
									If aCampos[nX][2] == "N"
										If Alltrim(aCampos[nX][1]) == "C7_QUANT"
											aArrayF4[Len(aArrayF4)][nX] :=Transform(nFreeQt,PesqPict("SC7",aCampos[nX][1]))
										Else
											aArrayF4[Len(aArrayF4)][nX] := Transform((cAliasSC7)->(FieldGet(FieldPos(aCampos[nX][1]))),PesqPict("SC7",aCampos[nX][1]))
										Endif
									ElseIf aCampos[nX][1] == "MARK"
										aArrayF4[Len(aArrayF4)][nX] := oNo
									Else
										aArrayF4[Len(aArrayF4)][nX] := (cAliasSC7)->(FieldGet(FieldPos(aCampos[nX][1])))
									Endif
								Else
									aArrayF4[Len(aArrayF4)][nX] := CriaVar(aCampos[nX][1],.T.)
									If Alltrim(aCampos[nX][1]) == "C7_CODGRP"
										SB1->(dbSetOrder(1))
										SB1->(MsSeek(cFilSB1	+(cAliasSC7)->C7_PRODUTO))
										aArrayF4[Len(aArrayF4)][nX] := SB1->B1_GRUPO
									EndIf
									If Alltrim(aCampos[nX][1]) == "C7_CODITE"
										SB1->(dbSetOrder(1))
										SB1->(MsSeek(cFilSB1	+(cAliasSC7)->C7_PRODUTO))
										aArrayF4[Len(aArrayF4)][nX] := SB1->B1_CODITE
									EndIf
								Endif

							Next

							AAdd( aArrSldo,{nFreeQT,Iif(lQuery,(cAliasSC7)->RECSC7,RecNo())} )
							If lMT100C7D
								aNew := ExecBlock("MT100C7D", .f., .f., aArrayF4[Len(aArrayF4)])
								If ValType(aNew) = "A"
									aArrayF4[Len(aArrayF4)] := aNew
								EndIf
							EndIf
						EndIf
					Endif
					(cAliasSC7)->(dbSkip())
				EndDo

				If !Empty(aArrayF4)

					DEFINE MSDIALOG oDlg FROM 30,20  TO 265,521 TITLE OemToAnsi(STR0042+" - <F6> ") Of oMainWnd PIXEL //"Selecionar Pedido de Compra ( por item )"

					If lMT100C7C
						aNew := ExecBlock("MT100C7C", .f., .f., aCab)
						If ValType(aNew) == "A"
							aCab := aNew
						EndIf
					EndIf

					oQual := TWBrowse():New( 29,4,243,76,,aCab,aTamCab,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
					oQual:SetArray(aArrayF4)

					If (!Empty(aArrayF4))
						oQual:bLDblClick := { || aArrayF4[oQual:nAt,1] := iif(aArrayF4[oQual:nAt,1] == oNo,Iif(cPaisLoc == "ARG" .AND. IsInCallStack("MATA102N"), Iif(valProd(aArrayF4[oQual:nAt,5],.T.),oOk, oNo),oOk), oNo) }
					EndIf

					oQual:bLine := { || aArrayF4[oQual:nAT] }
					OQual:nFreeze := 1

					If !Empty(cVar)
						@ 15  ,4   SAY OemToAnsi(STR0043) Of oDlg PIXEL SIZE 47 ,9 //"Produto"
						@ 14  ,30  MSGET cVar PICTURE PesqPict('SB1','B1_COD') When .F. Of oDlg PIXEL SIZE 80,9
					Else
						@ 15  ,4   SAY OemToAnsi(STR0044) Of oDlg PIXEL SIZE 120 ,9 //"Selecione o Pedido de Compra"
					EndIf

					ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,oDlg:End()},{||oDlg:End()},,aButtons)
					
					If nOpca == 1
					    If cPaisLoc == 'RUS'
					       For nX := 1 to Len(aArrayF4)
							   If aArrayF4[nX][1] == oOk
							   	  dbSelectArea("SC7")
								  MsGoto(aArrSldo[nX][2])
								  Aadd(aConUn,{SC7->C7_MOEDA,SC7->C7_CONUNI})
							   EndIf
					       next nX
					       		Asort(aConUn,,,{|x,y| x[1] > y[1]})
					       		If (aConUn[1][1] <> aConUn[Len(aConUn)][1])
					       			lConUn := .T.
					       		EndIf

					       		Asort(aConUn,,,{|x,y| x[2] > y[2]})
					       		If (aConUn[1][2] <> aConUn[Len(aConUn)][2])
					       			lConUn := .T.
					       		EndIf
					    EndIf
					    If (cPaisLoc == 'RUS' .And. !lConUn) .Or. (cPaisLoc <> 'RUS')
						    For nX := 1 to Len(aArrayF4)
							    If aArrayF4[nX][1] == oOk
								    nQtdItMark++
								    dbSelectArea("SC7")
								    MsGoto(aArrSldo[nX][2])
									If cPaisLoc == 'RUS'
										MaFisAlt("NF_MOEDA",M->F1_MOEDA)
										nMoedaCor	:= M->F1_MOEDA
										nMoedaNF	:= M->F1_MOEDA
										M->F1_TXMOEDA:=RecMoeda(M->F1_EMISSAO,M->F1_MOEDA)
										MaFisAlt("NF_TXMOEDA",M->F1_TXMOEDA)
										M->F1_CONUNI:= SC7->C7_CONUNI
										M->F1_F5QUID:=SC7->C7_F5QUID
										M->F1_F5QDESC:= Posicione("F5Q",1,XFILIAL("F5Q")+SC7->C7_F5QUID,"F5Q_DESCR")
										M->F1_CNTID:=SC7->C7_F5QCODE
										RunTrigger(1,Nil,Nil,,"F1_CNTID")
									EndIf

								    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								    //³ Efetua a chamada do ponto de entrada (Ex. uso: Alterar Moeda)³
								    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							    	 cPe	:= LocxPE(52)
							    	 If !Empty(cPE)
								    	ExecBlock(cPE,.F.,.F.)
								     EndIf

								     If nQtdItMark == 1
									    cItem := aCols[n][nPosItem]
								      Else
									    cItem := SomaIt(aCols[Len(aCols)][nPosItem])
								     EndIf
								     If	!ATail( aCols[ n ] ) .AND. nQtdItMark == 1
									    LxA103SC7ToaCols(aArrSldo[nX][2],n,aArrSldo[nX][1],IIf(cPaisLoc == "ARG" .And. FunName() $ "MATA101N|MATA102N", cItem, ""),,,,lCargaPerf)
									Else
									     LxA103SC7ToaCols(aArrSldo[nX][2],,aArrSldo[nX][1],cItem,,,,lCargaPerf)
		        				     EndIf
							    EndIf
						    Next nX
						 Else
						 If cPaisLoc == 'RUS'
					           Help("",1,"LxA103ItemPC 01",,STR0200,1,0)
					        EndIf
						EndIf
					EndIf

					If lUsaFiscal
						If lCargaPerf
							MaFisReprocess(2)
						EndIf
						Eval(bListRefresh)
						Eval(bDoRefresh)
					EndIf
				Else
					Help(" ",1,"A103F4")
				EndIf
			Else
				Help(" ",1,"A103F4")
			EndIf
		Else
			Help('   ',1,'A103TIPON')
		EndIf
	Else
		Help('   ',1,'A103CAB')
	EndIf

Endif

If lQuery
	dbSelectArea(cAliasSC7)
	dbCloseArea()
	dbSelectArea("SC7")
Endif

SetKey(VK_F4,bSavSetKey)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Atualiza o browse de quantidade de produtos.³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
AtuLoadQt(.T.)

RestArea(aAreaSA2)
RestArea(aAreaSC7)
RestArea(aAreaSB1)
RestArea(aArea)
lConsLoja:=lConsLojaAux

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103SC7ToaCols³ Autor ³ Edson Maricate    ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega os dados do Pedido no item especificado.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Void A103SC7ToaCols(ExpN1,ExpC1)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Numero do registro do SC7                           ³±±
±±³          ³ExpN2 : Item da NF                                          ³±±
±±³          ³ExpN3 : Saldo do Pedido                                     ³±±
±±³          ³ExpC4 : Item a ser carregado no aCols ( D1_ITEM )           ³±±
±±³          ³ExpL5 : Indica se os dados da Pre-Nota devem ser preservados³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103SC7ToaCols(nRecSC7,nItem,nSalPed,cItem,lPreNota,aRateio,lIsRemito,lCargaPerf)

	Local aArea			:= GetArea()
	Local aAreaSC7		:= SC7->(GetArea())
	Local aAreaSF4		:= SF4->(GetArea())
	Local aAreaSB1		:= SB1->(GetArea())
	Local aRefSC7		:= MaFisSXRef("SC7")
	Local nX			:= 0
	Local nCntFor		:= 0
	Local nValItem		:= 0
	Local nTaxaNf		:= 0
	Local nTaxaPed		:= 0
	Local nValDesc		:= 0
	Local nDifPed		:= 0
	Local nVlTotal		:= 0
	Local lRateioPC		:= SuperGetMv("MV_NFEDAPC")
	Local cTipConv		:= GetNewPar("MV_ALTTXNF",'1')
	Local nPosQtd		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QUANT"})
	Local nPosQtd2		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QTSEGUM"})
	Local nPosTes		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})
	Local nPosPed		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO"})
	Local nPosItPC		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMPC"})
	Local nPosiCF		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CF"})
	//Local nPosiProd		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
	Local nFirstItPC	:= 0
	Local aHeaderSDE	:= {}
	Local lMT103M		:= .F.
	Local lC7_PROVENT	:= .F.
	Local lC7_CONCEPT	:= .F.
	Local lC7_RATEIO	:= .F.
	Local cCFO			:= ""
	Local lAutTES		:= SuperGetMV("MV_AUTTES", .F., .T.) //Parametro que indica activacion de TES automatizada

	Static nTD1_TOTAL	:= 0
	Static nTD1_VALDESC	:= 0
	Static nTD1_VUNIT	:= 0
	Static nTD1_BASE1	:= 0
	Static nTD1_BASE2	:= 0
	Static nTD1_BASE3	:= 0
	Static nTD1_BASE4	:= 0
	Static nTD1_BASE5	:= 0
	Static nTD1_VALI1	:= 0
	Static nTD1_VALI2	:= 0
	Static nTD1_VALI3	:= 0
	Static nTD1_VALI4	:= 0
	Static nTD1_VALI5	:= 0
	Static nTD1_ALQI1	:= 0
	Static nDecFlete	:= 0
	Static nDecGastos	:= 0
	Static nDecSeguro	:= 0

	nTD1_TOTAL  := TamSX3('D1_TOTAL'  )[2]
	nTD1_VALDESC:= TamSX3('D1_VALDESC')[2]
	nTD1_VUNIT  := TamSX3("D1_VUNIT"  )[2]
	nTD1_BASE1  := TamSX3("D1_BASIMP1")[2]
	nTD1_BASE2  := TamSX3("D1_BASIMP2")[2]
	nTD1_BASE3  := TamSX3("D1_BASIMP3")[2]
	nTD1_BASE4  := TamSX3("D1_BASIMP4")[2]
	nTD1_BASE5  := TamSX3("D1_BASIMP5")[2]
	nTD1_VALI1  := TamSX3("D1_VALIMP1")[2]
	nTD1_VALI2  := TamSX3("D1_VALIMP2")[2]
	nTD1_VALI3  := TamSX3("D1_VALIMP3")[2]
	nTD1_VALI4  := TamSX3("D1_VALIMP4")[2]
	nTD1_VALI5  := TamSX3("D1_VALIMP5")[2]
	nTD1_ALQI1  := TamSX3("D1_ALQIMP1")[2]
	nDecFlete	:= TamSX3('F1_FRETE')[2]
	nDecGastos	:= TamSX3('F1_DESPESA')[2]
	nDecSeguro	:= TamSX3('F1_SEGURO')[2]

	DEFAULT lPreNota := .F.
	DEFAULT lIsRemito:= .F.
	DEFAULT aRateio  := {0,0,0}
	DEFAULT lCargaPerf := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia do item                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nItem == Nil .Or. nItem > Len(aCols)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aCols.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aCols,Array(Len(aHeader)+1))
		For nX := 1 to Len(aHeader)
			If Trim(aHeader[nX][2]) == "D1_ITEM"
				aCols[Len(aCols)][nX] 	:= IIF(cItem<>Nil,cItem,StrZero(1,Len(SD1->D1_ITEM)))
			ElseIf ( aHeader[nX][10] <> "V") .Or. Trim(aHeader[nX][2]) == "D1_ITEMMED" .Or. Trim(aHeader[nX][2]) == "D1_OPER"
				aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2],.T.)
			EndIf
			aCols[Len(aCols)][Len(aHeader)+1] := .F.
		Next nX
		nItem := Len(aCols)
	EndIf

	If !(Type('lLocxAuto') <> 'U' .And. lLocxAuto) .And. !(Type('l103Auto') <> 'U' .And. l103Auto)
		oGetDados:lNewLine:=.F.
	EndIf

	dbSelectArea("SC7")
	MsGoto(nRecSC7)

	dbSelectArea("SB1")
	dbSetOrder(1)
	MsSeek(xFilial("SB1")+SC7->C7_PRODUTO)

	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4")+SC7->C7_TES)

	If cPaisLoc == "COL" .And. lAutTES
		cCFO := LxTESAutoCOL(M->F1_FORNECE, M->F1_LOJA, SC7->C7_PRODUTO, "CF", "")
	Else
		cCFO := SF4->F4_CF
	EndIf

	// Tratamento para nao carregar novamente o valor das despesas acessorias
	// para quando o item do pedido for quebrado em mais de um item na nota
	If nPosPed > 0 .And. nPosItPC > 0
		nFirstItPC := aScan(aCols,{ |x| x[nPosPed] == SC7->C7_NUM .And. x[nPosItPC] == SC7->C7_ITEM .And. x[Len(aHeader)+1] == .F. })
	EndIf

	If SC7->(!Eof())
		dbSelectArea("SB1")
		dbSetOrder(1)
		MsSeek(xFilial("SB1")+SC7->C7_PRODUTO)

		dbSelectArea("SF4")
		dbSetOrder(1)
		MsSeek(xFilial("SF4")+SC7->C7_TES)

		cCondicao := SC7->C7_COND
		If cPaisLoc == "RUS"
			nMoedaCor	:=	SC7->C7_MOEDA
		EndIf
		If MaFisFound()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicia a Carga do item nas funcoes MATXFIS  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisIniLoad(nItem)
			nTaxaNF		:= IIf(cPaisLoc == "RUS", RecMoeda(M->F1_EMISSAO,M->F1_MOEDA), IIf(MaFisRet(,'NF_TXMOEDA') == 0, RecMoeda(dDataBase, M->F1_MOEDA), MaFisRet(,'NF_TXMOEDA')))
			nTaxaPed	:= IIf(cTipConv == '1', IIf(SC7->C7_TXMOEDA == 0, RecMoeda(SC7->C7_EMISSAO, SC7->C7_MOEDA), SC7->C7_TXMOEDA), RecMoeda(dDataBase, SC7->C7_MOEDA))
			nValItem	:= xMoeda(LxA103CReaj(SC7->C7_REAJUST,lReajuste),SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_VUNIT,nTaxaPed,nTaxaNF)
			For nX := 1 To Len(aRefSc7)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega os valores direto do SC7.           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
				Case aRefSC7[nX][2] == "IT_QUANT"
					If !lPreNota
						MaFisLoad(aRefSc7[nX][2],nSalPed,nItem)
					EndIf
				Case aRefSc7[nX][2] == "IT_PRCUNI"
					If !lPreNota
						MaFisLoad(aRefSc7[nX][2],nValItem,nItem)
					EndIf
				Case aRefSc7[nX][2] == "IT_VALMERC"
					If !lPreNota
						MaFisLoad(aRefSc7[nX][2],NoRound(nSalPed*nValItem,nTD1_TOTAL),nItem)
					Endif
				Case aRefSc7[nX][2] == "IT_DESCONTO"
					If !lPreNota .And. ( nFirstItPC == 0 .Or. MaFisRet(nFirstItPC,"IT_DESCONTO") == 0 )
						If SC7->C7_QUJE > 0
							nValDesc:= NoRound( ( (SC7->C7_VLDESC * (SC7->C7_QUANT-SC7->C7_QUJE) )/SC7->C7_QUANT  ),nTD1_VALDESC)
						Else
							nValDesc:= SC7->C7_VLDESC
						EndIf
						MaFisLoad(aRefSc7[nX][2],xMoeda(nValDesc,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF) ,nItem)
					EndIf
				Case aRefSc7[nX][2] == "IT_VALEMB"
					MaFisLoad(aRefSc7[nX][2],xMoeda( SC7->C7_VALEMB,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF),nItem)
				Case aRefSc7[nX][2] == "IT_VALIPI"
					MaFisLoad(aRefSc7[nX][2],xMoeda(SC7->C7_VALIPI,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF),nItem)
				Case aRefSc7[nX][2] == "IT_VALICM"
					MaFisLoad(aRefSc7[nX][2],xMoeda(SC7->C7_VALICM,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF),nItem)
				Case aRefSc7[nX][2] == "IT_BASEICM"
					MaFisLoad(aRefSc7[nX][2],xMoeda( SC7->C7_BASEICM,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF),nItem)
				Case aRefSc7[nX][2] == "IT_BASEIPI"
					MaFisLoad(aRefSc7[nX][2],xMoeda(SC7->C7_BASEIPI,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF),nItem)
				Case aRefSc7[nX][2] == "IT_SEGURO"
					If lRateioPC .And. ( nFirstItPC == 0 .Or. MaFisRet(nFirstItPC,"IT_SEGURO") == 0 )
						MaFisLoad(aRefSc7[nX][2],xMoeda(SC7->C7_SEGURO,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF),nItem)
					Else
						aRateio[1] +=xMoeda(SC7->C7_SEGURO,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF )
					EndIf
				Case aRefSc7[nX][2] == "IT_DESPESA"
					If lRateioPC .And. ( nFirstItPC == 0 .Or. MaFisRet(nFirstItPC,"IT_DESPESA") == 0 )
						MaFisLoad(aRefSc7[nX][2],xMoeda(SC7->C7_DESPESA,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF),nItem)
					Else
						aRateio[2] +=xMoeda(SC7->C7_DESPESA,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF )
					EndIf
				Case aRefSc7[nX][2] == "IT_FRETE"
					If lRateioPC .And. ( nFirstItPC == 0 .Or. MaFisRet(nFirstItPC,"IT_FRETE") == 0 )
						MaFisLoad(aRefSc7[nX][2],xMoeda( SC7->C7_VALFRE,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF),nItem)
					Else
						aRateio[3] +=xMoeda( SC7->C7_VALFRE,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF )
					EndIf
				//#PORTUGAL#
				/*Case cPaisLoc == "PTG" .And. aRefSc7[nX][2] == "IT_DESNTRB"
					If lRateioPC
						MaFisLoad(aRefSc7[nX][2],xMoeda( SC7->C7_DESNTRB,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF),nItem)
					Else
						aRateio[3] +=xMoeda( SC7->C7_DESNTRB,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF )
					EndIf
				Case cPaisLoc == "PTG" .And. aRefSc7[nX][2] == "IT_TARA"
					If lRateioPC
						MaFisLoad(aRefSc7[nX][2],xMoeda( SC7->C7_TARA,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF),nItem)
					Else
						aRateio[3] +=xMoeda( SC7->C7_TARA,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,,nTaxaPed,nTaxaNF )
					EndIf*/
				OtherWise
					MaFisLoad(aRefSc7[nX][2],SC7->(FieldGet(FieldPos(aRefSc7[nX][1]))),nItem)
				EndCase
			Next nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega o CF direto do SF4                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SC7->C7_TES)
				If (cPaisLoc == "RUS")
					MaFisLoad("IT_CF",MaFisCFO(nItem,SC7->C7_CF),nItem)
				Else
					MaFisLoad("IT_CF",MaFisCFO(nItem, IIf(cPaisLoc=="COL",cCFO,SF4->F4_CF) ),nItem)
				Endif
			EndIf
			MaFisEndLoad(nItem)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os demais campos do Pedido                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		lC7_PROVENT 	:= cPaisLoc == "ARG"
		lC7_CONCEPT 	:= cPaisLoc == "EQU"
		lC7_RATEIO	 	:= .T.
		For nCntFor := 1 To Len(aHeader)
			Do Case
			Case Trim(aHeader[nCntFor,2]) == "D1_COD"
				aCols[nItem,nCntFor] := SC7->C7_PRODUTO
			Case Trim(aHeader[nCntFor,2]) == "D1_TOTAL"
				If !lPreNota
					If SC7->C7_MOEDA == nMoedaNF .And. !Empty(SC7->C7_TXMOEDA)
						aCols[nItem,nCntFor] := NoRound(nSalPed*nValItem,nTD1_TOTAL)
					Else
						aCols[nItem,nCntFor] := NoRound(nSalPed*xMoeda( LxA103CReaj(SC7->C7_REAJUST,lReajuste),SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,Max(nTD1_VUNIT,nTD1_TOTAL),nTaxaPed,nTaxaNF),nTD1_TOTAL)
					EndIf
					// Verificacao para previnir diferenca de centavos
					If nTD1_TOTAL == 2
						nVlTotal := SC7->C7_TOTAL
						nDifPed  := 0.01
						If ABS(nVlTotal - aCols[nItem][nCntFor]) == nDifPed
							aCols[nItem][nCntFor] := nVlTotal
						EndIf
					EndIf
				EndIf
			Case cPaisLoc == "RUS" .And. Trim(aHeader[nCntFor,2]) == "D1_TOTALM"
				If !lPreNota
					aCols[nItem,nCntFor] := xMoeda( SC7->C7_TOTAL,SC7->C7_MOEDA,1,dDatabase,nTD1_TOTAL,nTaxaNF)
				EndIf
		Case Trim(aHeader[nCntFor,2]) == "D1_OPER"
			aCols[nItem,nCntFor] := Space(TamSX3("D1_OPER")[1])
			Case Trim(aHeader[nCntFor,2]) == "D1_TES" .And. !Empty(SC7->C7_TES)
				aCols[nItem,nCntFor] := SC7->C7_TES
				If lCargaPerf
					MaFisLoad("IT_TES",aCols[nItem][nPosTes],nItem)
					If aScan(aTESPedC ,{|x| Alltrim(x) == aCols[nItem][nPosTes] }) == 0
						aAdd(aTESPedC, aCols[nItem][nPosTes])
					EndIf
				Endif
			Case Trim(aHeader[nCntFor,2]) == "D1_CF" .And. !Empty(SC7->C7_TES)
				If (cPaisLoc == "RUS")
					aCols[nItem,nCntFor] := SC7->C7_CF
				Else
					aCols[nItem,nCntFor] := IIf(cPaisLoc=="COL",cCFO,SF4->F4_CF)
				Endif
			Case Trim(aHeader[nCntFor,2]) == "D1_PEDIDO"
				aCols[nItem,nCntFor] := SC7->C7_NUM
			Case Trim(aHeader[nCntFor,2]) == "D1_QUANT"
				If !lPreNota
					aCols[nItem,nCntFor] := nSalPed
				EndIf
			Case Trim(aHeader[nCntFor,2]) == "D1_VUNIT"
				If !lPreNota
					If SC7->C7_MOEDA == nMoedaNF .And. !Empty(SC7->C7_TXMOEDA)
						aCols[nItem,nCntFor] := SC7->C7_PRECO
					Else
						aCols[nItem,nCntFor] := xMoeda(LxA103CReaj(SC7->C7_REAJUST,lReajuste),SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_VUNIT,nTaxaPed,nTaxaNF)
					EndIf
				EndIf
			Case Trim(aHeader[nCntFor,2]) == "D1_REVISAO"
				aCols[nItem,nCntFor] := SC7->C7_REVISAO
			Case Trim(aHeader[nCntFor,2]) == "D1_ITEMPC"
				aCols[nItem,nCntFor] := SC7->C7_ITEM
			Case Trim(aHeader[nCntFor,2]) == "D1_GRADE"
				aCols[nItem,nCntFor] := SC7->C7_GRADE
			Case Trim(aHeader[nCntFor,2]) == "D1_ITEMGRD"
				aCols[nItem,nCntFor] := SC7->C7_ITEMGRD
			Case Trim(aHeader[nCntFor,2]) == "D1_LOCAL"
				aCols[nItem,nCntFor] := SC7->C7_LOCAL
			Case Trim(aHeader[nCntFor,2]) == "D1_CC"
				aCols[nItem,nCntFor] := SC7->C7_CC
			Case Trim(aHeader[nCntFor,2]) == "D1_ITEMCTA"			// Item Contabil
				aCols[nItem,nCntFor] := Iif( Empty(SC7->C7_ITEMCTA), SB1->B1_ITEMCC, SC7->C7_ITEMCTA )
			Case Trim(aHeader[nCntFor,2]) == "D1_CONTA"			// Conta Contabil
				aCols[nItem,nCntFor] := Iif( Empty(SC7->C7_CONTA), SB1->B1_CONTA, SC7->C7_CONTA )
			Case Trim(aHeader[nCntFor,2]) == "D1_CLVL"				// Classe de Valor
				aCols[nItem,nCntFor] := Iif( Empty(SC7->C7_CLVL), SB1->B1_CLVL, SC7->C7_CLVL )
			Case Trim(aHeader[nCntFor,2]) == "D1_UM"
				aCols[nItem,nCntFor] := SC7->C7_UM
			Case Trim(aHeader[nCntFor,2]) == "D1_SEGUM"
				aCols[nItem,nCntFor] := SC7->C7_SEGUM
			Case Trim(aHeader[nCntFor,2]) == "D1_QTSEGUM"
				If !lPreNota
					If SB1->B1_CONV <> 0
						aCols[nItem,nCntFor] := ConvUm(SB1->B1_COD,aCols[nItem][nPosQtd],aCols[nItem][nPosQtd2],2)
					ElseIf SC7->C7_QTSEGUM > 0
						// "Descobre" o fator de conversao utilizado, qdo. utiliza a 2A UM no pedido, mas B1_CONV = 0
						aCols[nItem,nCntFor] :=	(SC7->C7_QTSEGUM/SC7->C7_QUANT) * nSalPed
					Else
						aCols[nItem,nCntFor] := SC7->C7_QTSEGUM
					EndIf
				EndIf
			Case Trim(aHeader[nCntFor,2]) == "D1_DESC"
				If !lPreNota
					aCols[nItem,nCntFor] := SC7->C7_DESC
				EndIf
			Case Trim(aHeader[nCntFor,2]) == "D1_VALDESC"
				If !lPreNota
					If SC7->C7_QUJE > 0
						nValDesc:= NoRound( ( (SC7->C7_VLDESC * (SC7->C7_QUANT-SC7->C7_QUJE) )/SC7->C7_QUANT  ),nTD1_VALDESC)
					Else
						nValDesc:= SC7->C7_VLDESC
					EndIf
					aCols[nItem,nCntFor] :=xMoeda(nValDesc,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_VALDESC,nTaxaPed,nTaxaNF)
				EndIf
			Case Trim(aHeader[nCntFor,2]) == "D1_SEGURO"
				aCols[nItem,nCntFor] := xMoeda(SC7->C7_SEGURO, SC7->C7_MOEDA, M->F1_MOEDA, dDataBase, nDecFlete, nTaxaPed, nTaxaNF)
			Case Trim(aHeader[nCntFor,2]) == "D1_DESPESA"
				aCols[nItem,nCntFor] := xMoeda(SC7->C7_DESPESA, SC7->C7_MOEDA, M->F1_MOEDA, dDataBase, nDecGastos, nTaxaPed, nTaxaNF)
			Case Trim(aHeader[nCntFor,2]) == "D1_VALFRE"
				aCols[nItem,nCntFor] := xMoeda(SC7->C7_VALFRE, SC7->C7_MOEDA, M->F1_MOEDA, dDataBase, nDecSeguro, nTaxaPed, nTaxaNF)
			Case Trim(aHeader[nCntFor,2]) == "D1_CODGRP"
				aCols[nItem,nCntFor] := SB1->B1_GRUPO
			Case Trim(aHeader[nCntFor,2]) == "D1_CODITE"
				aCols[nItem,nCntFor] := SB1->B1_CODITE
			Case Trim(aHeader[nCntFor,2]) == "D1_BASIMP1"
				aCols[nItem,nCntFor] :=xMoeda(SC7->C7_BASIMP1,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_BASE1,nTaxaPed,nTaxaNF)
			Case cPaisLoc == "RUS" .And. Trim(aHeader[nCntFor,2]) == "D1_BSIMP1M"
				aCols[nItem,nCntFor] :=	xMoeda(SC7->C7_BASIMP1,SC7->C7_MOEDA,1,dDatabase,nTD1_BASE1,nTaxaNF)
			Case Trim(aHeader[nCntFor,2]) == "D1_BASIMP2"
				aCols[nItem,nCntFor] :=xMoeda(SC7->C7_BASIMP2,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_BASE2,nTaxaPed,nTaxaNF)
			Case Trim(aHeader[nCntFor,2]) == "D1_BASIMP3"
				aCols[nItem,nCntFor] :=xMoeda(SC7->C7_BASIMP3,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_BASE3,nTaxaPed,nTaxaNF)
			Case Trim(aHeader[nCntFor,2]) == "D1_BASIMP4"
				aCols[nItem,nCntFor] :=xMoeda(SC7->C7_BASIMP4,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_BASE4,nTaxaPed,nTaxaNF)
			Case Trim(aHeader[nCntFor,2]) == "D1_BASIMP5"
				aCols[nItem,nCntFor] :=xMoeda(SC7->C7_BASIMP5,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_BASE5,nTaxaPed,nTaxaNF)
			Case Trim(aHeader[nCntFor,2]) == "D1_VALIMP1"
				aCols[nItem,nCntFor] :=xMoeda(SC7->C7_VALIMP1,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_VALI1,nTaxaPed,nTaxaNF)
			Case cPaisLoc == "RUS" .And. Trim(aHeader[nCntFor,2]) == "D1_VLIMP1M"
				aCols[nItem,nCntFor] :=	xMoeda(SC7->C7_VALIMP1,SC7->C7_MOEDA,1,dDatabase,nTD1_VALI1,nTaxaNF)
			Case Trim(aHeader[nCntFor,2]) == "D1_VALIMP2"
				aCols[nItem,nCntFor] :=xMoeda(SC7->C7_VALIMP2,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_VALI2,nTaxaPed,nTaxaNF)
			Case Trim(aHeader[nCntFor,2]) == "D1_VALIMP3"
				aCols[nItem,nCntFor] :=xMoeda(SC7->C7_VALIMP3,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_VALI3,nTaxaPed,nTaxaNF)
			Case Trim(aHeader[nCntFor,2]) == "D1_VALIMP4"
				aCols[nItem,nCntFor] :=xMoeda(SC7->C7_VALIMP4,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_VALI4,nTaxaPed,nTaxaNF)
			Case Trim(aHeader[nCntFor,2]) == "D1_VALIMP5"
				aCols[nItem,nCntFor] :=xMoeda(SC7->C7_VALIMP5,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_VALI5,nTaxaPed,nTaxaNF)
			Case Trim(aHeader[nCntFor,2]) == "D1_PROVENT"
				If lC7_PROVENT .and. !(Type('lLocxAuto') <> 'U' .And. lLocxAuto)
					aCols[nItem,nCntFor] := SC7->C7_PROVENT
				Endif
		Case Trim(aHeader[nCntFor,2]) == "D1_ALQIMP1" .And. cPaisLoc == "RUS"
			aCols[nItem,nCntFor] :=xMoeda(SC7->C7_ALQIMP1,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,nTD1_ALQI1,nTaxaPed,nTaxaNF)
		    Case cPaisLoc == "RUS" .And. Trim(aHeader[nCntFor,2]) == "D1_DESCRI"
				aCols[nItem,nCntFor] :=SC7->C7_DESCRI
			Case cPaisLoc == "RUS" .And. Trim(aHeader[nCntFor,2]) == "D1_FDESC"
		   	    aCols[nItem,nCntFor] :=SC7->C7_FDESC
			Case Trim(aHeader[nCntFor,2]) == "D1_RATEIO"
				aCols[nItem,nCntFor] := IIf( lC7_RATEIO,SC7->C7_RATEIO,"")
			Case cPaisLoc=="EQU" .And. Trim(aHeader[nCntFor,2]) == "D1_CONCEPT"
				M->F1_NATUREZA:=SC7->C7_NATUREZA
				If lC7_CONCEPT
					aCols[nItem,nCntFor] := SC7->C7_CONCEPT
				Endif
			EndCase
		Next nCntFor

		// Atualiza o aRatCC com rateio do PC
		aHeaderSDE:=HeaderSDE(aHeaderSDE)
		RatPed2NF(aHeaderSDE,@aRatCC,cItem,nRecSC7)

		// 1 - utilização a associação automática com o PMS
		// 2 - não utiliza a associação automática com o PMS

		// default: não utilizar a associação automatica
		If GetNewPar("MV_PMSIPC", 2) == 1
			PMS103IPC(nItem)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a chamada do ponto de entrada                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock( "MT103IPC" )
			lMT103M:=ExecBlock( "MT103IPC", .F., .F.,{nItem})
			If ValType(lMT103M)<>"L"
				lMT103M:=.F.
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizar os arrays do Fiscal (Matxfis)                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lCargaPerf
		If lIsRemito
			// Para remitos nao e necessario calcular por TOTAL
			MaColsToFis(aHeader,aCols,nItem,"MT100",,,,.T.)
		Else
		MaColsToFis(aHeader,aCols,nItem,"MT100", Iif(cPaisLoc == "RUS", .F., .T.))
			Eval(bDoRefresh) //Atualiza o folder financeiro.
			Eval(bListRefresh)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto possui TE Padrao                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MaFisFound()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetua tratamento se a Tes do Acols será mantida  		 ³
			//³ ou Carregada através do Produto / Pedido                 |
			//| - Se não existir o Pe: MT103IPC não existir, carrega 	 ³
			//|   do Pedido / Cadastro                                   |
			//| - Se existir o Pe: MT103IPC                              |
			//|      .T. = Manter o aCols com o que foi carregado no PE  |
			//|            Mesmo assim se a Tes estiver vazia, faz a     |
			//|            carga do Pedido / Cadastro                    |
			//|      .F. = Carregar do Pedido / Cadastro.      			 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lMT103M
				If Empty(aCols[nItem][nPosTes])
					lMT103M:=.F.
				Else
					MaFisAlt("IT_TES",aCols[nItem][nPosTes],nItem)
					MaFisToCols(aHeader,aCols,IIf(lIsRemito,Len(aCols),Nil),"MT100")
				EndIf
			EndIf

			If !lMT103M
				Do Case
					Case Empty(SC7->C7_TES) .And. !Empty(RetFldProd(SB1->B1_COD,"B1_TE"))
						MaFisAlt("IT_TES",RetFldProd(SB1->B1_COD,"B1_TE"),nItem)
						MaFisToCols(aHeader,aCols,IIf(lIsRemito,Len(aCols),Nil),"MT100")
					Case !Empty(SC7->C7_TES)
						MaFisAlt("IT_TES",SC7->C7_TES,nItem)
						MaFisToCols(aHeader,aCols,IIf(lIsRemito,Len(aCols),Nil),"MT100")
				EndCase
			EndIf
		EndIf
	EndIf

	If cPaisLoc == "COL" .And. !(cCFO == aCols[nItem][nPosiCF])
		// Conservar CF asignado por automatización de TES o definido por el usuario
		MaFisAlt("IT_CF", cCFO, nItem)
		aCols[nItem][nPosiCF] := cCFO
	EndIf

	RestArea(aAreaSB1)
	RestArea(aAreaSF4)
	RestArea(aAreaSC7)
	RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LxA103NFORI³ Autor ³ Edson Maricate      ³ Data ³16.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a chamada da Tela de Consulta a NF original            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOCXNF                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LxA103NFORI()

Local bSavKeyF4 := SetKey(VK_F4,Nil)
Local bSavKeyF5 := SetKey(VK_F5,Nil)
Local bSavKeyF6 := SetKey(VK_F6,Nil)
Local bSavKeyF7 := SetKey(VK_F7,Nil)
Local bSavKeyF8 := SetKey(VK_F8,Nil)
Local bSavKeyF9 := SetKey(VK_F9,Nil)
Local bSavKeyF10:= SetKey(VK_F10,Nil)
Local bSavKeyF11:= SetKey(VK_F11,Nil)
Local lRusDebit	:= cPaisloc == "RUS" .And. cEspecie == "NDC"
Local nPosCod	:= Iif(lRusDebit, aScan(aHeader,{|x| AllTrim(x[2])=='D2_COD'}) ,aScan(aHeader,{|x| AllTrim(x[2])=='D1_COD'}))
Local nPosLocal := Iif(lRusDebit, aScan(aHeader,{|x| AllTrim(x[2])=='D2_LOCAL'}) ,aScan(aHeader,{|x| AllTrim(x[2])=='D1_LOCAL'}))
Local nPosTes	:= Iif(lRusDebit, aScan(aHeader,{|x| AllTrim(x[2])=='D2_TES'}) ,aScan(aHeader,{|x| AllTrim(x[2])=='D1_TES'}))
Local nPLocal	:= Iif(lRusDebit, aScan(aHeader,{|x| AllTrim(x[2])=='D2_LOCAL'}) ,aScan(aHeader,{|x| AllTrim(x[2])=='D1_LOCAL'}))
Local nRecSD1   := 0
Local nRecSD2   := 0
Local lContinua := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

If lContinua

	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4")+aCols[n][nPosTes])

	If MaFisFound("NF") .And. Empty(Readvar())
		If cPaisLoc == "COL" .And. cFunName == "MATA465N" .And. !Empty(GetMV("MV_PROVFE", .F., ""))
			If Empty(M->F1_TIPOPE)
				MsgAlert(StrTran(STR0240, '###', FWX3Titulo("F1_TIPOPE")) + "(F1_TIPOPE).") //"Es necesario informar en el encabezado el campo ###(F1_TIPOPE)."
				Return .F.
			EndIf
		EndIf
		Do Case
		Case cTipo $ "ND" .And. (SF4->(EOF()) .Or. SF4->F4_PODER3=="N")
			If F4NFORI(,,"M->D1_NFORI",cA100For,Iif(Empty(cLoja),M->F1_LOJA,cLoja),aCols[n][nPosCod],"A100",aCols[n][nPLocal],@nRecSD2,,Iif(cPaisLoc == "RUS",M->F1_EMISSAO,))
				LxA103SD2ToaCols(nRecSD2,n)
			EndIf
		Case lRusDebit .And. cTipo == "C"
			If F4NFORI(,,"M->D2_NFORI",M->F2_CLIENTE,M->F2_LOJA,aCols[n][nPosCod],"A465D",aCols[n][nPLocal],@nRecSD2,,M->F2_EMISSAO)
				LxA103SD2ToaCols(nRecSD2,n)
			EndIf
		Case cPaisloc <> "RUS" .And. cTipo$"CPI"
			If F4COMPL(,,,cA100For,Iif(Empty(cLoja),M->F1_LOJA,cLoja),aCols[n][nPosCod],"A100",@nRecSD1,"M->D1_NFORI")
				LxA103SD1ToaCols(nRecSD1,n)
			EndIf
		Case (cTipo$"NB" .Or. (cTipo$"D" .And. cPaisLoc $ "EUA")) .And. SF4->F4_PODER3=="D"
			If cPaisLoc=="BRA"
				If F4Poder3(aCols[n][nPosCod],aCols[n][nPosLocal],cTipo,"E",cA100For,Iif(Empty(cLoja),M->F1_LOJA,cLoja),@nRecSD2,SF4->F4_ESTOQUE)
					LxA103SD2ToaCols(nRecSD2,n)
				EndIf
			Else
				If A440F4("SB6",aCols[n][nPosCod],aCols[n][nPosLocal],"B6_PRODUTO","E",cA100For,Iif(Empty(cLoja),M->F1_LOJA,cLoja),.F.,.F.,@nRecSD2,IIF(cTipo=="N","F","C")) > 0
					LxA103SD2ToaCols(nRecSD2,n)
				EndIf
			EndIf
		OtherWise
			If Empty(aCols[n][nPosCod]) .Or. Empty(aCols[n][nPosTes])
				Help('   ',1,'A103TPNFOR')
			ElseIf cTipo == "D" .And. SF4->F4_PODER3 <> "N"
				Help('   ',1,'A103TESNFD')
			ElseIf cTipo$"NB" .And. SF4->F4_PODER3 <> "D"
				Help('   ',1,'A103TESNFB')
			EndIf
		EndCase
	Else
		Help('   ',1,'A103CAB')
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PNEUAC - Ponto de Entrada,gravar na coluna Lote o numero baseado na nf Original       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PNEU002")
		ExecBlock("PNEU002",.F.,.F.)
	EndIf

Endif
If cPaisLoc == "ARG"
	MaFisReprocess(2)
ENDIF
SetKey(VK_F4,bSavKeyF4)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Atualiza o browse de quantidade de produtos.³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
AtuLoadQt(.T.)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103SD2ToaC³ Autor ³ Edson Maricate       ³ Data ³24.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao do acols com base no item de saida ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103SD2ToAc(ExpN1,Expn2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Registro do item de saida                          ³±±
±±³          ³ ExpN2 = Item do Acols                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LxA103SD2ToaCols(nRecSD2,nItem)
Local aArea		:= GetArea()
Local aAreaSD2	:= SD2->(GetArea())
Local nProvEnt	:= aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) $ "PROVENT"})
Local nVUnit	:= aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) $ "VUNIT"})
//Local nCFO     	:= 0
Local nPosTes	:= 0
//Local cCFO		:= ""
Local lAutTES	:= SuperGetMV("MV_AUTTES", .F., .T.) //Parametro que indica activacion de TES automatizada
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na item da Nota Original          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SD2")
If nRecSD2 <> 0
	MsGoto(nRecSD2)
EndIf
If ((cPaisLoc=="ARG") .and. (cEspecie== "NDC"))
 	nPosTes	:=aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) $ "TES"})
 	 If nPosTes>0
 	 	aCols[n,nPosTes]:=SD2->D2_TES
 	 EndIf
EndIF
DbSelectArea("SF2")
DbSetOrder(1)
MsSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
If cPaisLoc == "RUS"
	If Empty(cCondicao) .OR. RUXXTS05()
		MaFisAlt("NF_MOEDA",SF2->F2_MOEDA)
		MaFisAlt("NF_TXMOEDA",SF2->F2_TXMOEDA)
		nMoedaCor		:= SF2->F2_MOEDA
		nMoedaNF		:= SF2->F2_MOEDA
		If cEspecie == "NDC"
			M->F2_F5QUID	:= SF2->F2_F5QUID
			M->F2_CNTID 	:= SF2->F2_CNTID
			M->F2_F5QDESC   := Iif(!EMPTY(SF2->F2_F5QUID),Posicione("F5Q",1,XFILIAL("F5Q")+SF2->F2_F5QUID,"F5Q_DESCR"),"")
			M->F2_CNORSUP	:= SF2->F2_CNORVEN
			M->F2_CNEEBUY	:= SF2->F2_CNEECLI
			M->F2_CNORCOD	:= SF2->F2_CNORCOD
			M->F2_CNORBR	:= SF1->F1_CNORBR
			M->F2_CNEECOD	:= SF1->F1_CNEECOD
			M->F2_CNEEBR	:= SF1->F1_CNEEBR

			M->F2_MOEDA 	:= SF2->F2_MOEDA
			M->F2_CONUNI	:= SF2->F2_CONUNI
			M->F2_TXMOEDA	:= SF2->F2_TXMOEDA
			M->F2_DTSAIDA	:= SF2->F2_DTSAIDA
		ElseIf cEspecie == "NCC"
			M->F1_F5QUID	:= SF2->F2_F5QUID
			M->F1_CNTID 	:= SF2->F2_CNTID
			M->F1_F5QDESC   := Iif(!EMPTY(SF2->F2_F5QUID),Posicione("F5Q",1,XFILIAL("F5Q")+SF2->F2_F5QUID,"F5Q_DESCR"),"")
			M->F1_CNORSUP	:= SF2->F2_CNORVEN
			M->F1_CNEEBUY	:= SF2->F2_CNEECLI
			M->F1_CNORCOD	:= SF2->F2_CNORCOD
			M->F1_CNORBR	:= SF2->F2_CNORBR
			M->F1_CNEECOD	:= SF2->F2_CNEECOD
			M->F1_CNEEBR	:= SF2->F2_CNEEBR

			M->F1_MOEDA 	:= SF2->F2_MOEDA
			M->F1_CONUNI	:= SF2->F2_CONUNI
			M->F1_TXMOEDA	:= SF2->F2_TXMOEDA
		EndIf
		cCondicao		:= SF2->F2_COND
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ REMITO DEV.SIMBOLICA: Converte valor caso moeda divergir com doc. origem ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc<>"BRA" .And. cTipo == "B" .And. nVunit > 0 .And. SF2->F2_MOEDA <> M->F1_MOEDA
	aCols[n,nVunit] := xMoeda(SD2->D2_PRCVEN,SF2->F2_MOEDA,MAFISRET(,'NF_MOEDA'),dDataBase,,SF2->F2_TXMOEDA,MAFISRET(,'NF_TXMOEDA'))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dispara o ponto para cada item da NF        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MT103INF" )
	ExecBlock( "MT103INF", .F., .F., { nItem } )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a Funcao Fiscal                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaColsToFis(aHeader,aCols,nItem,"MT100",.F.)
If cPaisLoc == "COL"
	xObtCFOCol(lAutTES, SD2->D2_CLIENTE, SD2->D2_LOJA, SD2->D2_COD, "", aHeader, aCols, nItem, 0, 0, .T.)
EndIf
If cPaisLoc == "ARG" .And. nProvEnt > 0
	MaFisAlt("IT_PROVENT",aCols[n,nProvEnt],nItem)
Endif
If cPaisLoc == "RUS"
	MaFisAlt("IT_VALMERC_C1",SD2->D2_TOTALM,nItem)
	MaFisAlt("IT_BASEIV1_C1",SD2->D2_BSIMP1M,nItem)
	MaFisAlt("IT_VALIV1_C1",SD2->D2_VLIMP1M,nItem)
EndIf
MaFisAlt("IT_RECORI",nRecSD2,nItem)
MaFisAlt("NF_UFORIGEM",SF2->F2_EST)
Eval(bDoRefresh) //Atualiza o folder financeiro.
Eval(bListRefresh)

RestArea(aArea)
RestArea(aAreaSD2)
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a103SD1ToaCols³ Autor ³ Edson Maricate    ³ Data ³ 01.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenche os dados da NF de Complemento na Funcao Fiscal.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LxA103SD1ToaCols(nRecSD1,nItem)

Local aArea			:= GetArea()
Local aAreaSD1		:= SD1->(GetArea())
Local nValorTotal	:= aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) == "TOTAL"})
Local nValorUnit	:= aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) $ "PRCVEN|VUNIT"})
Local nQuant		:= aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) == "QUANT"})
//Local nValorDesc	:= aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) == "DESCON" .Or. AllTrim(Subs(x[2],4)) == "VALDESC"})
Local nProvEnt		:= aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) $ "PROVENT"})
Local nConcept		:= aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) $ "CONCEPTO"})
Local nPosTes		:= iif( cPaisLoc == "RUS", aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) $ "TES"}),  aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TES"}))
Local nPNfOri		:= aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) $ "NFORI"})
Local nPSerOri		:= aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) $ "SERIORI"})
Local nPCF		:= aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) $ "CF"})
Local cPe74			:= LocxPE(74)
Local lAltProv		:= .F.
Local lAutTES		:= SuperGetMV("MV_AUTTES", .F., .T.) //Parametro que indica activacion de TES automatizada

DbSelectArea("SD1")

If nRecSD1 <> 0
	MsGoto(nRecSD1)
	//Obtem a TES padrao de Devolução
	DbSelectArea("SF4")
	DbSetOrder(1)
	MsSeek(xFilial("SF4")+SD1->D1_TES)
	If !Eof() .And. Iif(cPaisLoc == "RUS", cEspecie == "NDP",!Empty(F4_TESDV)) .And. nPosTes>0
		aCols[n,nPosTes]:=Iif(cPaisLoc == "RUS" .And. cEspecie == "NDP",SD1->D1_TES,F4_TESDV)
		MaFisAlt("IT_TES", aCols[n][nPosTes], n)
	EndIf
	DbSelectArea("SD1")
	If cPaisLoc == "RUS"
		If nPCF>0
			aCols[n,nPCF]:=SD1->D1_CF
			MaFisLoad("IT_CF",aCols[n][nPCF],nItem)
		EndIf
	EndIf
Else
	If cPaisLoc == "COL" .And. !lAutTES
		MaFisAlt("IT_TES", aCols[n][nPosTes], n)
	EndIf
EndIf

DbSelectArea("SF1")
DbSetOrder(1)
MsSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dispara o ponto para cada item da NF        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MT103INF" )
	ExecBlock( "MT103INF", .F., .F., { nItem } )
EndIf
If cPaisLoc == "RUS" .And. nRecSD1 <> 0
	If Empty(cCondicao) .OR. RUXXTS05()
		MaFisAlt("NF_MOEDA",SF1->F1_MOEDA)
		MaFisAlt("NF_TXMOEDA",SF1->F1_TXMOEDA)
		nMoedaCor		:= SF1->F1_MOEDA
		nMoedaNF		:= SF1->F1_MOEDA
		If cEspecie == "NCP"
			M->F2_F5QUID	:= SF1->F1_F5QUID
			M->F2_CNTID 	:= SF1->F1_CNTID
			M->F2_F5QDESC   := Iif(!EMPTY(SF1->F1_F5QUID),Posicione("F5Q",1,XFILIAL("F5Q")+SF1->F1_F5QUID,"F5Q_DESCR"),"")
			M->F2_CNORVEN	:= SF1->F1_CNORSUP
			M->F2_CNEECLI	:= SF1->F1_CNEEBUY
			M->F2_CNORCOD	:= SF1->F1_CNORCOD
			M->F2_CNORBR	:= SF1->F1_CNORBR
			M->F2_CNEECOD	:= SF1->F1_CNEECOD
			M->F2_CNEEBR	:= SF1->F1_CNEEBR

			M->F2_MOEDA 	:= SF1->F1_MOEDA
			M->F2_CONUNI	:= SF1->F1_CONUNI
			M->F2_TXMOEDA	:= SF1->F1_TXMOEDA
			M->F2_DTSAIDA	:= SF1->F1_EMISSAO
		ElseIf cEspecie == "NDP"
			M->F1_F5QUID	:= SF1->F1_F5QUID
			M->F1_CNTID 	:= SF1->F1_CNTID
			M->F1_F5QDESC   := Iif(!EMPTY(SF1->F1_F5QUID),Posicione("F5Q",1,XFILIAL("F5Q")+SF1->F1_F5QUID,"F5Q_DESCR"),"")
			M->F1_CNORSUP	:= SF1->F1_CNORSUP
			M->F1_CNEEBUY	:= SF1->F1_CNEEBUY
			M->F1_CNORCOD	:= SF1->F1_CNORCOD
			M->F1_CNORBR	:= SF1->F1_CNORBR
			M->F1_CNEECOD	:= SF1->F1_CNEECOD
			M->F1_CNEEBR	:= SF1->F1_CNEEBR

			M->F1_MOEDA 	:= SF1->F1_MOEDA
			M->F1_CONUNI	:= SF1->F1_CONUNI
			M->F1_TXMOEDA	:= SF1->F1_TXMOEDA
		EndIf
		cCondicao		:= SF1->F1_COND
	EndIf
EndIf

MaFisIniLoad(nItem)

If cPaisLoc == "ARG" .And. nProvEnt <> 0
	MaFisLoad("IT_PROVENT",aCols[n,nProvEnt],nItem)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada p/ permitir alterar a provincia de entrega do cabecalho c/ a prov. da NF Original ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cPe74)
		lAltProv := ExecBlock(cPE74,.F.,.F.)
		If ValType(lAltProv) <> "L"
			lAltProv := .F.
		EndIf
		If lAltProv .And. M->F2_PROVENT <> SF1->F1_PROVENT
			M->F2_PROVENT := SF1->F1_PROVENT
			MaFisAlt("NF_PROVENT",SF1->F1_PROVENT)
		EndIf
	EndIf
Endif
If cPaisLoc == "VEN" .AND. nConcept > 0
	//Para que arreglo aNfItem se inicialice con lo que contiene el campo de IT_CONCEPTO del documento origen
	MaFisLoad("IT_CONCEPT",aCols[n,nConcept],nItem)
ENDIF
If nPNfOri >	0 .And. nPSerOri > 0
	MaFisLoad("IT_NFORI",aCols[n,nPNfOri],nItem)
	MaFisLoad("IT_SERORI",aCols[n,nPSerOri],nItem)
Endif
MaFisLoad("IT_RECORI",nRecSD1,nItem)
MaFisLoad("IT_QUANT",aCols[n,nQuant],nItem)
MaFisLoad("IT_PRCUNI",aCols[n,nValorUnit],nItem)
//Apenas ira passar aqui se for form. Prop = N e importar a nota por doc. original
//o desconto do doc original tem conceito diferente de descont de credito por isso deve ser sempre 0
MaFisLoad("IT_DESCONTO",0,nItem)
MaFisEndLoad(nItem)
MaFisRef("IT_VALMERC","MT100",aCols[n,nValorTotal])

If cPaisLoc == "RUS" .And. nRecSD1 <> 0
	SD1->(DBGoto(nRecSD1))
	MaFisAlt("IT_VALMERC_C1",SD1->D1_TOTALM,nItem)
	MaFisAlt("IT_BASEIV1_C1",SD1->D1_BSIMP1M,nItem)
	MaFisAlt("IT_VALIV1_C1",SD1->D1_VLIMP1M,nItem)
EndIf
Eval(bDoRefresh) //Atualiza o folder financeiro.
Eval(bListRefresh)
ModxAtuObj()

RestArea(aArea)
RestArea(aAreaSD1)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103AtuSE2³ Autor ³ Edson Maricate        ³ Data ³11.10.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de integracao com o modulo financeiro                 ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Codigo de operacao                                    ³±±
±±³          ³       [1] Inclusao de Titulos                               ³±±
±±³          ³       [2] Exclusao de Titulos                               ³±±
±±³          ³ExpA2: Array com os recnos dos titulos financeiros. Utilizado³±±
±±³          ³       somente na exclusao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a integracao entre o   ³±±
±±³          ³documento de entrada e os titulos financeiros.               ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LxA103SE2(nOpc,aRecSE2)

Local aArea     := GetArea()
Local aRetIrrf  := {}
Local cPrefixo  := SF1->F1_PREFIXO
Local cNatureza	:= MaFisRet(,"NF_NATUREZA")
Local nValDup   := 0
Local nIrrf		:= MaFisRet(,"NF_VALIRR")
Local nItmIrrf  := 0
Local nResIrrf  := 0
Local nVlrIrrf  := 0
Local nVlrInss  := 0
Local nVlrIss   := 0
Local nValInss	:= MaFisRet(,"NF_VALINS")
Local nItmInss	:= 0
Local nResInss  := 0
Local nValIss	:= MaFisRet(,"NF_VALISS")
Local nItmIss	:= 0
Local nResIss   :=0
Local nDifTam 	:= TamSX3("F1_DOC")[1] - 6
Local nTamData 	:= IIF(__SetCentury(),10,8)
Local nX        := 0
Local cFilSED	:= xFilial("SED")
Local cFilSE2	:= xFilial("SE2")
Local lUsaNewKey:= TamSX3("F1_SERIE")[1] == 14
Local cAliasSe2 :=""
Local cQuery	:=""
Local aDupl1	:=	{}	//Alexandra Menayshina (23/04/18): FI-VAT-37-42

If cPaisLoc == "RUS"
	aDupl1	:= Condicao(SF1->F1_VLBRUTM,cCondicao,,dDEmissao)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o prefixo do titulo a ser gerado                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cPrefixo).And.!Empty(SuperGetMV("MV_2DUPREF"))
	If !lUsaNewKey
		cPrefixo := &(SuperGetMV("MV_2DUPREF"))
		cPrefixo := If(Empty(cPrefixo),CriaVar("SE2->E2_PREFIXO"),cPrefixo)
		cPrefixo += Space(Len(SE2->E2_PREFIXO) - Len(cPrefixo))
	Else
		/*CHAVE UNICA - Alterado por Tiago Silva*/
		cAliasSE2 := "LxA103SE2"
		cQuery := " SELECT MAX(E2_PREFIXO) E2PRFXMAX FROM " + RetSqlName("SE2")
		cQuery += " WHERE E2_FILIAL = '" + cFilSE2 + "'"
		cQuery += " AND E2_NUM      = '" + cNFiscal + "'"
		cQuery += " AND E2_FORNECE  = '" + SA2->A2_COD + "'"
		cQuery += " AND E2_LOJA     = '" + SA2->A2_LOJA + "'"
		cQuery += " AND D_E_L_E_T_  = ''"
	   	cQuery	  := ChangeQuery(cQuery)
		cAliasSE2 := CriaTrab(Nil,.F.)

		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasSE2, .T., .T. )
		DbSelectArea(cAliasSE2)

		If !Empty( (cAliasSE2)->E2PRFXMAX )
			cPrefixo:= Soma1( (cAliasSE2)->E2PRFXMAX , TamSX3("E2_PREFIXO")[1] )
			/*
			Devido ao projeto CHAVE ÚNICA, a consistência abaixo é necessária para
			garantir que o novo título a ser gerado não irá colidir com um título
			da base histórica do cliente criada antes do projeto chave única.
			*/
			While .T.
				SE2->(dbSetOrder(1))
				If (SE2->(dbSeek(cFilSE2+cPrefixo+cNFiscal)))
					cPrefixo:= Soma1(cPrefixo, TamSX3("E2_PREFIXO")[1])
				Else
					EXIT
			EndIf
		EndDo
		Else
			cPrefixo:=&(SuperGetMV("MV_2DUPREF"))
		EndIf
		(cAliasSE2)->(DbCloseArea())
		/*CHAVE UNICA*/
	Endif
EndIf
If nOpc == 1
	If cPaisLoc == 'BRA'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Distribuicao do valor do ISS entre as parcelas a serem geradas    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nItmISS := NoRound( ( nValIss/Len( aDupl ) ),2,@nResISS,18)
		If ( nResISS > 0.01 )
			nItmISS += NoRound(nResISS,2)
			nResISS -= NoRound(nResISS,2)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Distribuicao do valor de IRF entre as parcelas a serem geradas    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nItmIrrf := NoRound((nIrrf/Len(aDupl)),2,@nResIRRF,18)
		If ( nResIRRF > 0.01 )
			nItmIrrf += NoRound(nResIRRF,2)
			nResIRRF -= NoRound(nResIRRF,2)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Distribuicao do valor do INS entre as parcelas a serem geradas    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nItmInss := NoRound((nValInss/Len(aDupl)),2,@nResInss,18)
		If ( nResInss > 0.01 )
			nItmInss += NoRound(nResInss,2)
			nResInss -= NoRound(nResInss,2)
		EndIf
	EndIf
	For nx := 1 to Len(aDupl)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Recupera os valores do Array de duplicatas                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc <> "BRA"
			nValDup := DesTrans(Extrae(aDupl[nx],5))-nValFun
		Else
			nValDup := DesTrans(Subs(aDupl[nx],28+nDifTam,20))-nValFun
			If nx == Len(aDupl) .And. Len(aDupl) <> 1
				nItmIrrf := Abs(Round(nIrrf - nVlrIrrf,2))
				nItmIss  := Abs(Round(nValISS - nVlrIss ,2))
				nItmInss := Abs(Round(nValINSS - nVlrInss,2))
			EndIf
		EndIf
		If nValDup > 0
			dbSelectArea("SED")
			MsSeek(cFilSED+cNatureza)
			dbSelectArea("SE2")
			RecLock("SE2",.T.)
			SE2->E2_FILIAL		:= cFilSE2
			SE2->E2_PREFIXO	:= cPrefixo
			SE2->E2_NUM 	:= cNFiscal
			SE2->E2_TIPO	:= MVNOTAFIS
			SE2->E2_NATUREZ := cNatureza
			SE2->E2_EMISSAO		:= dDEmissao
			SE2->E2_EMIS1		:= dDataBase
			SE2->E2_FORNECE		:= SA2->A2_COD
			SE2->E2_LOJA		:= SA2->A2_LOJA
			SE2->E2_NOMFOR		:= SA2->A2_NREDUZ
			SE2->E2_MOEDA		:= nMoedaCor
			SE2->E2_LA			:= "S"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento para grava‡„o dos campos exclusivos  ³
			//³ para o Brasil.                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  Ponto de entrada para recalculo do IRRF e ISS  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (ExistBlock("MT100IR"))
					aRetIrrf := ExecBlock( "MT100IR",.F.,.F., {nItmIRRF,nValDup,nx} )
					If ValType(aRetIrrf)  == "N"
						nItmIRRF := aRetIrrf
					EndIf
					If ValType(aRetIrrf)  == "A"
						nItmIRRF := aRetIrrf[1]
						nItmIss  := aRetIrrf[2]
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³       Grava o valor do IRRF no titulo           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  nIrrf > 0
					SE2->E2_IRRF := Abs(nItmIrrf)
					nValDup -= SE2->E2_IRRF
					nVlrIrrf+= SE2->E2_IRRF
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³       Grava o valor do INSS no titulo           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nValInss > 0
					If ExistBlock("MT100INS")
						nItmInss := ExecBlock( "MT100INS",.F.,.F., {nItmInss} )
					EndIf
					SE2->E2_INSS  := Abs(nItmInss)
					nValDup       -= SE2->E2_INSS
					nVlrINSS      += SE2->E2_INSS
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³       Grava o valor do ISS  no titulo           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nValIss > 0
					SE2->E2_ISS := Abs(nItmIss)
					nValDup 	-= SE2->E2_ISS
					nVlrISS 	+= SE2->E2_ISS
				EndIf
			EndIf
			If cPaisLoc <> "BRA"
				SE2->E2_PARCELA := AllTrim(Extrae(aDupl[nx],3))
				SE2->E2_VENCORI := Ctod(Extrae(aDupl[nx],4))
				SE2->E2_VENCTO  := Ctod(Extrae(aDupl[nx],4))
				SE2->E2_VENCREA := DataValida(Ctod(Extrae(aDupl[nx],4)),.T.)
				SE2->E2_VALOR   := nValDup
				SE2->E2_SALDO   := nValDup
			Else
				SE2->E2_PARCELA := Subs(aDupl[nx],13+nDifTam,1)
				SE2->E2_VENCORI := Ctod(Subs(aDupl[nx],16+nDifTam,nTamData))
				SE2->E2_VENCTO  := Ctod(Subs(aDupl[nx],16+nDifTam,nTamData))
				SE2->E2_VENCREA := DataValida(Ctod(Subs(aDupl[nx],16+nDifTam,nTamData)),.T.)
				SE2->E2_VALOR   := nValDup
				SE2->E2_SALDO   := nValDup
				SE2->E2_NATUREZ := cNatureza
			EndIf
			FaAvalSE2(1,"MatA100",(nx==1),nIrrf)

			If cPaisLoc == "RUS"
				SE2->E2_VLCRUZ := aDupl1[nx][2]
			Else
				SE2->E2_VLCRUZ := Round( xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,SE2->E2_EMIS1), MsDecimais(1) )
			EndIf
			If (Existblock("MT100GE2"))
				ExecBlock("MT100GE2",.F.,.F.)
			EndIf
			nValFun	:= 0
		EndIf
	Next nx
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estorno dos titulos a pagar                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFAULT aRecSE2 := {}
	For nX := 1 To Len(aRecSE2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estorno dos titulos financeiros                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SE2")
		MsGoto(aRecSE2[nX])

		If (Existblock("M103DSE2"))
			ExecBlock("M103DSE2",.F.,.F.)
		EndIf

		RecLock('SE2',.F.)
		dbDelete()
		FaAvalSE2(2,"MatA100")
		FaAvalSE2(3,"MatA100")
	Next nX
EndIf
RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103AtuSD2³ Rev.  ³ Edson Maricate        ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza valores referentes a devolucao de mercadorias      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103AtuSD2(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Item                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103,A103Grava()                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103SD2(nOpc,nItem,aPedPV,cTipNota)

Local nRecSD2		:= MaFisRet(nItem,"IT_RECORI")
Local nPosGeraPV	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_GERAPV' })
Local cSeekSD2		:= ""
Local cCliPad    := SuperGetMv("MV_CLIPAD")
Local cLojPad    := SuperGetMv("MV_LOJAPAD")
Local lCliPad    := !(Empty(cCliPad) .Or. Empty(cLojPad))
Local lAtuSal    := .F.

DEFAULT cTipNota	:=	cTipo

If nOpc == 1
	If cTipNota == "D"
		If !Empty(SD1->D1_NFORI) .And. nRecSD2 <> Nil
			dbSelectArea("SD2")
			MsGoto(nRecSD2)
			RecLock("SD2",.F.)
			SD2->D2_QTDEDEV	:= SD2->D2_QTDEDEV + SD1->D1_QUANT
			SD2->D2_VALDEV	:= SD2->D2_VALDEV  + SD1->D1_TOTAL
		EndIf
		If nPosGeraPV > 0 .And. ;
				aCols[nItem][nPosGeraPV] == "S"
			aAdd(aPedPV,{	SD1->D1_SERIORI,;
				SD1->D1_NFORI ,;
				SD1->D1_ITEMORI,;
				SD1->D1_FORNECE+SD1->D1_LOJA,;
				SD1->D1_QUANT ,;
				SD1->(Recno()) })
		EndIf
	EndIf
Else
	If cTipNota == "D" .And. !Empty(SD1->D1_NFORI) .And. !Empty(SD1->D1_ITEMORI)
		dbSelectArea("SD2")
		dbSetOrder(3)
      //1o. Pesquisa a nota fiscal original para cliente padrao
      lAtuSal := (lCliPad .And. MsSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+cCliPad+cLojPad+SD1->D1_COD+SD1->D1_ITEMORI))
		//Senão encontrar cliente padrao pesquisa o cliente da nota fiscal de devolução
		lAtuSal := IIf(!lAtuSal,MsSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD+SD1->D1_ITEMORI),lAtuSal)
		If lAtuSal
			RecLock("SD2",.F.)
			Replace D2_QTDEDEV With IIf( D2_QTDEDEV - SD1->D1_QUANT > 0 , D2_QTDEDEV - SD1->D1_QUANT , 0 )
			Replace D2_VALDEV  With IIf( D2_VALDEV  - SD1->D1_TOTAL > 0 , D2_VALDEV  - SD1->D1_TOTAL , 0 )
			MsUnlock()
		EndIf

		If cPaisLoc <> "BRA"   //SOMENTE LOCALIZACOES
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Estorna tambem os campos QTDEDEV e VALDEV das notas ou remitos associados        ³
			//³aa nota ou remito original aqui posicionado.                                     ³
			//³Isso garante que futuras notas de credito ou remitos de devolucao considerem o   ³
			//³saldo a devolver corretamente.                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If "MATA462" $ Funname()
				// Pesquisa pela nota gerada pelo remito original
				cSeekSD2 := SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_ITEM
				DBSelectArea("SD2")
				DBSetOrder(9)
				If MsSeek(xFilial("SD2")+cSeekSD2 ,.F.)
					RecLock("SD2", .F.)
					SD2->D2_QTDEDEV := Max(0,SD2->D2_QTDEDEV-SD1->D1_QUANT)
					SD2->D2_VALDEV  := Max(0,SD2->D2_VALDEV-SD1->D1_TOTAL)
					MsUnlock()
				EndIf
			Elseif "MATA465" $ Funname()
				// Pesquisa, se houver, o remito vinculado aa nota original
				If !Empty( SD2->D2_REMITO + SD2->D2_SERIREM )
					cSeekSD2 := SD2->D2_REMITO+SD2->D2_SERIREM+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD+SD2->D2_ITEMREM
					DBSelectArea("SD2")
					DBSetOrder(3)
					If MsSeek(xFilial("SD2")+cSeekSD2 ,.F.)
						RecLock("SD2", .F.)
						SD2->D2_QTDEDEV := Max(0,SD2->D2_QTDEDEV-SD1->D1_QUANT)
						SD2->D2_VALDEV  := Max(0,SD2->D2_VALDEV-SD1->D1_TOTAL)
						MsUnlock()
					EndIf
				EndIf
			EndIf
		EndIf

	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103EstRE5³ Autor ³ Edson Maricate        ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera registro no SD3, Estorno Apropriacao Direta na Op DE5 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lxa103EstRE5()
Local aArea		:= GetArea()
Local aAreaSD4	:= SD4->(GetArea())
Local aAreaSB2	:= SB2->(GetArea())
Local lEofSD3
Local nQuant

dbSelectArea("SD3")
dbSetOrder(4)
MsSeek(xFilial("SD3")+SD1->D1_NUMSEQ)
While !Eof() .And. SD3->D3_CF # "RE5" .And. SD3->D3_NUMSEQ == SD1->D1_NUMSEQ
	dbSkip()
End

lEofSD3 := IIF(SD3->D3_NUMSEQ # SD1->D1_NUMSEQ,.t.,.f.)

If !lEofSD3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera requisicao automatica               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SD3",.F.)
	Replace  D3_ESTORNO With "S"
	RecLock("SD3",.T.)
	Replace D3_FILIAL  With xFilial("SD3")
	Replace D3_COD     With SD1->D1_COD
	Replace	D3_QUANT   With SD1->D1_QUANT
	Replace D3_TM      With "499"
	Replace	D3_OP      With SD1->D1_OP
	Replace D3_Local   With SD1->D1_LOCAL
	Replace	D3_DOC     With SD1->D1_DOC
	Replace D3_EMISSAO With SD1->D1_DTDIGIT
	Replace	D3_NUMSEQ  With SD1->D1_NUMSEQ
	Replace D3_UM      With SD1->D1_UM
	Replace	D3_GRUPO   With SD1->D1_GRUPO
	Replace D3_TIPO    With SD1->D1_TP
	Replace D3_SEGUM   With SD1->D1_SEGUM
	Replace D3_CONTA   With SD1->D1_CONTA
	Replace D3_CF      With "DE5"
	Replace D3_QTSEGUM With SD1->D1_QTSEGUM
	Replace D3_USUARIO With SubStr(cUsuario,7,15)
	Replace D3_CUSTO1  With SD1->D1_CUSTO
	Replace D3_CUSTO2  With SD1->D1_CUSTO2
	Replace D3_CUSTO3  With SD1->D1_CUSTO3
	Replace D3_CUSTO4  With SD1->D1_CUSTO4
	Replace D3_CUSTO5  With SD1->D1_CUSTO5
	Replace D3_ESTORNO With "S"

	SC2->(dbSetOrder(1))
	If SC2->(MsSeek(xFilial("SC2")+SD1->D1_OP))
		Replace	D3_CC 		With SC2->C2_CC
		Replace	D3_ITEMCTA	With SC2->C2_ITEMCTA
		Replace	D3_CLVL		With SC2->C2_CLVL
	EndIf

	dbSelectArea("SD4")
	dbSetOrder(1)
	If MsSeek(xFilial("SD4")+SD1->D1_COD+SD1->D1_OP)
		nQuant := IIf(SD4->D4_QTDEORI - SD4->D4_QUANT < SD1->D1_QUANT,SD4->D4_QTDEORI - SD4->D4_QUANT,SD1->D1_QUANT)
		RecLock("SD4",.f.)
		Replace SD4->D4_QUANT   With SD4->D4_QUANT + nQuant
		Replace SD4->D4_QTSEGUM With SD4->D4_QTSEGUM + ConvUM(SD4->D4_COD, nQuant, 0, 2)
	EndIf

	dbSelectArea("SB2")
	RecLock("SB2",.F.)
	nQuant := IIf(nQuant==NIL,SD1->D1_QUANT,nQuant)
	Replace B2_QEMP  With B2_QEMP + nQuant
	Replace B2_QEMP2 With B2_QEMP2 + ConvUM(SB2->B2_COD, nQuant, 0, 2)

	B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
	C2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
EndIf


RestArea(aAreaSB2)
RestArea(aAreaSD4)
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103AtuSB2³ Autor ³ Edson Maricate        ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o arquivo de saldos em estoque SB2                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103AtuSB2()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1  :=  nOpc  1 ou 2                                    ³±±
±±³          ³ ExpL1  :=  Classifica Item .T. ou .F.                      ³±±
±±³          ³ ExpC1  :=  Codigo do Almoxarifado                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 , A103Grava()                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103SB2(nOpc,cLocal)

DEFAULT cLocal := SD1->D1_LOCAL

dbSelectArea("SB2")
dbSetOrder(1)
If !MsSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
	CriaSB2(SD1->D1_COD,SD1->D1_LOCAL)
EndIf
RecLock("SB2",.F.)
If nOpc == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o controle de Poder de 3os.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF4->F4_ESTOQUE=='S'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o saldo atual (VATU) com os dados do SD1     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		B2AtuComD1()
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o controle de Poder de 3os.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF4->F4_ESTOQUE=='S'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o saldo atual (VATU) com os dados do SD1     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		B2AtuComD1(-1,SD1->D1_SKIPLOT,,.T.)// O ultimo parametro ".T." inverte a TES.
	EndIf
EndIf
SB2->(MsUnlock())
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103AtuAmarr³ Autor ³ Edson Maricate      ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o registro de Amarracao ProdutoxFornecedor         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103AtuAmarr()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 , A103Grava()                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103AtuAmarr(nOpc)

Local nj,nx,ny
Local cCampoWrit
Local cCampoRead
Local cFieldName
Local nValMoeda
Local nPosRef	:= 0


If nOpc == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Preco,Quant, Cond. Pgto e Data da Compra em ³
	//³ SA5 para armazenar as 12 ultimas Compras.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA5")
	dbSetOrder(1)
	If MsSeek(xFilial("SA5")+cA100For+cLoja+SD1->D1_COD)
		RecLock("SA5",.F.)
		If A5_QUANT12 <> 0
			For nj := 1 TO 11
				cCampoWrit := "A5_QUANT"+StrZero(nj,2)
				cCampoRead := "A5_QUANT"+StrZero(nj+1,2)
				cFieldName := Eval(FieldBlock(cCampoRead))
				Eval(FieldBlock(cCampoWrit),cFieldName)
				cCampoWrit := "A5_PRECO"+StrZero(nj,2)
				cCampoRead := "A5_PRECO"+StrZero(nj+1,2)
				cFieldName := Eval(FieldBlock(cCampoRead))
				Eval(FieldBlock(cCampoWrit),cFieldName)
				cCampoWrit := "A5_COND"+StrZero(nj,2)
				cCampoRead := "A5_COND"+StrZero(nj+1,2)
				cFieldName := Eval(FieldBlock(cCampoRead))
				Eval(FieldBlock(cCampoWrit),cFieldName)
				cCampoWrit := "A5_DTCOM"+StrZero(nj,2)
				cCampoRead := "A5_DTCOM"+StrZero(nj+1,2)
				cFieldName := Eval(FieldBlock(cCampoRead))
				Eval(FieldBlock(cCampoWrit),cFieldName)
			Next
		EndIf
		nValMoeda := RecMoeda(SD1->D1_EMISSAO,SuperGetMV("MV_MCUSTO"))
		Replace     A5_QUANT12  With SD1->D1_QUANT,;
			A5_COND12   With cCondicao,;
			A5_DTCOM12  With SD1->D1_EMISSAO,;
			A5_PRECO12  With IIF(SuperGetMV("MV_MCUSTO")=='1',SD1->D1_CUSTO/SD1->D1_QUANT,(&("SD1->D1_CUSTO"+SuperGetMV("MV_MCUSTO")))/SD1->D1_QUANT)
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estorna Preco,Quant, Cond. Pgto e Data da Compra em ³
	//³ SA5 para armazenar as 12 ultimas Compras.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA5")
	dbSetOrder(1)
	If MsSeek(xFilial("SA5")+cA100For+cLoja+SD1->D1_COD)
		For nx := 1 TO 12
			cCampoRead := "A5_DTCOM"+StrZero(nx,2)
			If Eval(FieldBlock(cCampoRead)) == dDEmissao
				nPosRef := nx
				Exit
			EndIf
		Next nx
		If nPosRef > 0
			RecLock("SA5",.F.)
			cCampoWrit := "A5_QUANT"+StrZero(nPosRef,2)
			Eval(FieldBlock(cCampoWrit),0 )
			cCampoWrit := "A5_PRECO"+StrZero(nPosRef,2)
			Eval(FieldBlock(cCampoWrit),0 )
			cCampoWrit := "A5_COND"+StrZero(nPosRef,2)
			Eval(FieldBlock(cCampoWrit),Space(3))
			cCampoWrit := "A5_DTCOM"+StrZero(nPosRef,2)
			Eval(FieldBlock(cCampoWrit),CTOD("  /  /  "))
			If nPosRef <> 11 .Or. nPosRef <> 12
				For ny := nPosRef + 1 TO 12
					cCampoWrit := "A5_QUANT"+StrZero(ny-1,2)
					cCampoRead := "A5_QUANT"+StrZero(ny,2)
					cFieldName := Eval(FieldBlock(cCampoRead))
					Eval(FieldBlock(cCampoWrit),cFieldName)
					cCampoWrit := "A5_PRECO"+StrZero(ny-1,2)
					cCampoRead := "A5_PRECO"+StrZero(ny,2)
					cFieldName := Eval(FieldBlock(cCampoRead))
					Eval(FieldBlock(cCampoWrit),cFieldName)
					cCampoWrit := "A5_COND"+StrZero(ny-1,2)
					cCampoRead := "A5_COND"+StrZero(ny,2)
					cFieldName := Eval(FieldBlock(cCampoRead))
					Eval(FieldBlock(cCampoWrit),cFieldName)
					cCampoWrit := "A5_DTCOM"+StrZero(ny-1,2)
					cCampoRead := "A5_DTCOM"+StrZero(ny,2)
					cFieldName := Eval(FieldBlock(cCampoRead))
					Eval(FieldBlock(cCampoWrit),cFieldName)
				Next
				cCampoWrit := "A5_QUANT12"
				Eval(FieldBlock(cCampoWrit),0 )
				cCampoWrit := "A5_PRECO12"
				Eval(FieldBlock(cCampoWrit),0 )
				cCampoWrit := "A5_COND12"
				Eval(FieldBlock(cCampoWrit),Space(3))
				cCampoWrit := "A5_DTCOM12"
				Eval(FieldBlock(cCampoWrit),CTOD("  /  /  "))
			EndIf
		EndIf
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LxVerifCC ³ Autor ³                       ³ Data ³16.01.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se a fatura gerou movimentos em uma caixinha e em  ³±±
±±³          ³caso  positivo, permite sua exclusao somente se esses       ³±±
±±³          ³movimentos puderem ser excluidos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxVerifCC(nRegSF1)

Local cCaixinha	:= ""
Local cNroAdia	:= ""
Local cNum 		:= ""
Local lRetorno	:= .T.
Local aArea		:= {}
Local aAreaSEU	:= {}
Local aAreaSF1	:= {}

Default nRegSF1	:=	0

aArea := GetArea()
DbSelectArea("SEU")
aAreaSEU := GetArea()

If nRegSF1 > 0
	DbSelectArea("SF1")
	aAreaSF1 := GetArea()
	SF1->(MsGoto(nRegSF1))
	SEU->(DbSetOrder(7))
	If SEU->(DbSeek(xFilial("SEU") + SF1->F1_FORNECE + SF1->F1_LOJA + Padr(SF1->F1_DOC,Len(EU_NRCOMP)) + SF1->F1_SERIE))
		If SEU->EU_TIPDEB == "_NF_"
			If !Empty(SEU->EU_BAIXA)
				If !Empty(SEU->EU_NROADIA)
					/*
					Se o movimento e de prestacao de contas referente a um adiantamento, verifica-se se ele e anterior a ultima abertura da caixinha. Em caso
					afirmativo, nao permite a exclusao. */
					cCaixinha := SEU->EU_CAIXA
					cNroAdia := Space(Len(SEU->EU_NROADIA))
					cNum := Soma1(SEU->EU_NUM)
					SEU->(DbSetOrder(6))
					SEU->(DbSeek(xFilial("SEU") + SEU->EU_CAIXA + "11" + cNroAdia + cNum,.T.))
					If !(SEU->(Eof()))
						If SEU->EU_CAIXA == cCaixinha
							If SEU->EU_TIPO == "11"
								lRetorno := .F.
							Endif
						Endif
					Endif
				Else
					/* Se o movimento e um gasto simples, apenas exibe a mensagem */
					lRetorno := .F.
				Endif
				If !lRetorno
					Help(,,STR0033,,STR0112,1,0)		//"A fatura não pode ser excluída, pois possui movimento em uma caixinha e esse movimento encontra-se baixado."
				Endif
			Endif
		Endif
	Endif
	RestArea(aAreaSF1)
Endif
RestArea(aAreaSEU)
RestArea(aArea)
Return(lRetorno)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaCanDelF1³ Autor ³ Edson Maricate        ³ Data ³11.10.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de validacao da exclusao de uma nota fiscal de entrada³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero do Registro do SF1.                       (OPC)³±±
±±³          ³ExpA2: Array com os pedidos de venda gerados a partir da nota³±±
±±³          ³       fiscal de entrada.                               (OPC)³±±
±±³          ³ExpA3: Array com os titulos financeiro gerados          (OPC)³±±
±±³          ³ExpL4: Indica se pode apagar notas de conhec de frete   (OPC)³±±
±±³          ³ExpL5: Indica se pode apagar notas de despesas de import(OPC)³±±
±±³          ³ExpL6: Indica se estou apagando um remito (localizacoes)(OPC)³±±
±±³          ³ExpL7: Indica se se trata de un retorno simbolico automatico,³±±
±±³          ³       no caso de ser, o retorno pode ser apagado.           ³±±
±±³          ³ExpC8: Origem a ser considerado na comparacao com registros  ³±±
±±³          ³       gerados no modulo financeiro (Opcional)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se a nota pode ser excluida                    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo validar a exclusao de uma Nota ³±±
±±³          ³fiscal de entrada/Documento de entrada.                      ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LxMaCanDelF1(nRecSF1,aRecSC5,aRecSE2,lCanDelFr,lCanDelDp,lRemito,lRSAuto,cOrigFin,lCheckFin,lRemInt)
Local lEofSD3   := .T.
Local aArea		:= GetArea()
Local aAreaSF1  := SF1->(GetArea())
Local aAreaSD1	:= SD1->(GetArea())
Local aAreaSF8	:= SF8->(GetArea())
Local aStruSD1  := {}
Local aStruSE2  := {}
Local aRemito   := {}
Local cFuncName	:= FunName()
Local lQuery    := .F.
Local lRetorno 	:= .F.
Local l100Del	:= ExistBlock('A100DEL')
Local lEstNeg   := (SuperGetMv('MV_ESTNEG')=='S')
Local lExcluiNeg:= SuperGetMV("MV_EXCLNFN")
Local lIntACD		:= SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local dDataFec	:= MVUlmes()
Local nPosLote	:= 0
Local nX		:= 0
Local nQuant	:= 0
Local cCodPro	:= ""
Local aProd	:= {}
Local nI		:= 0
Local nY		:= 0
Local aLotes	:= {}
Local cPrefixo  := ""
Local cSeekDCF  := ""
Local cQuery    := ""
Local cFornece  := ""
Local cLoja     := ""
Local cAliasSD1 := "SD1"
Local cAliasSE2 := "SE2"
//Local nRecSD1
Local lAvalBlqL := .T.
Local lIsFifoOn := .T.
Local nPLocaliz := IIf(Type("aHeader")=="U",0,aScan(aHeader,{|x| AllTrim(x[2])=='D1_LOCALIZ'}))
Local aAreaSCU  := {}
Local aAreaAtu  := {}
Local cFilDCF	:= xFilial("DCF")
Local cFilSB2	:= xFilial("SB2")
Local cFilSB6	:= xFilial("SB6")
Local cFilSC2	:= xFilial("SC2")
Local cFilSC5	:= xFilial("SC5")
Local cFilSC6	:= xFilial("SC6")
Local cFilSC7	:= xFilial("SC7")
Local cFilSDA	:= xFilial("SDA")
Local cFilSD1	:= xFilial("SD1")
Local cFilSD3	:= xFilial("SD3")
Local cFilSD7	:= xFilial("SD7")
Local cFilSE1	:= xFilial("SE1")
Local cFilSE2	:= xFilial("SE2")
Local cFilSF4	:= xFilial("SF4")
Local cFilSF9	:= xFilial("SF9")
Local cFilSN1	:= xFilial("SN1")
Local lRutAut   := IIf(Type('lLocxAuto') == 'U', .F., lLocxAuto)
Local lSaldoSB2	:= cPaisLoc $ "MEX|ARG|CHI|BOL|PAR|URU|PER" .And. SuperGetMV("MV_TPSALDO", .F., "Q") == "Q"
Local lSaldoSA	:= SuperGetMV("MV_TPSALDO", .F., "Q") == "C"
Local lValDelCP	:= .T.
Local lRetBenf  := .F. //Retorno de Beneficio - Orden de Producción

#IFNDEF TOP
	Local cIndexSD1 := ""
	Local nIndexSD1 := 0
#ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa os parametros da Rotina                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT aRecSC5    := {}
DEFAULT aRecSE2    := {}
DEFAULT lCanDelFr  := .F.
DEFAULT lCanDelDp  := .F.
DEFAULT lRemito    := .F.
DEFAULT cOrigFin   := "MATA100"
DEFAULT lCheckFin  := .T.
DEFAULT lRemInt    := .F.

If nRecSF1 <> Nil
	dbSelectArea("SF1")
	MsGoto(nRecSF1)
    aAreaSF1  := SF1->(GetArea())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no Remito Interno para validar o documento de importacao |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRemInt .And. !Empty(SF1->F1_HAWB) .And. SF1->F1_TIPO_NF == '5'
		aRemito    := LocxNrReIm(SF1->F1_HAWB,SF1->F1_DOC)
		cFornece   := If(Empty(aRemito[3]),SF1->F1_FORNECE,aRemito[3])
		cLoja      := If(Empty(aRemito[4]),SF1->F1_LOJA   ,aRemito[4])
		dbSelectArea("SF1")
		dbSetOrder(1)
		MsSeek(xFilial("SF1")+aRemito[2]+aRemito[1]+cFornece+cLoja)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta a Pesquisa das Notas de Conhecimento de Frete e D.I.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SF8->(dbSetOrder(2))
Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a NF possui NF de Conhec. e Desp. de Import.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case SF8->(MsSeek(xFilial("SF8")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	Help(' ', 1, 'A103CAGREG')
	lRetorno := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao excluir NF incluida pelo MATA910                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case SF1->F1_ORIGLAN == "LF"
	Help("  ",1,"NAOCOM")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao excluir NF nao classificada                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case Empty(SF1->F1_STATUS) .And. Empty(SF1->F1_HAWB)
	Help(" ",1,"A100NOCLAS")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificar data do ultimo fechamento em SX6                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case dDataFec>=dDataBase .Or. dDataFec>=SF1->F1_DTDIGIT
	Help( " ", 1, "FECHTO" )
	lRetorno := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica ultima data para operacoes fiscais                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case !FisChkExc(SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_FORNECE,SF1->F1_LOJA)
	lRetorno := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao com o ACD		  				  	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case lIntACD .And. !(CBANFDel())
	lRetorno := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para permitir ou nao a exclusao             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case l100Del .And. !(Execblock("A100DEL",.F.,.F.))
	lRetorno := .F.
Case SF1->F1_TIPO == "C" .And. SF1->F1_ORIGLAN == "F " 	.And. !lCanDelFr
	Help(" ",1,"A100NDELFR")
	lRetorno := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao excluir nota de Despesas de Importacao                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case SF1->F1_TIPO == "C" .And. SF1->F1_ORIGLAN == " D"	.And. !lCanDelDp
	Help(" ",1,"A100NDELDP")
	lRetorno := .F.
	//ÚLocalizacoesÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao excluir NF (de devolucao ou retorno) que gerou PV se este³
	//³ ainda existe.                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case !lRsAuto .And. !Empty(SF1->F1_PEDVEND) .And. (SF1->F1_PEDVEND == "AUTO  " .Or. Eval( {|| SC5->(DbSetORder(1)),SC5->(MsSeek(xFilial("SC5")+SF1->F1_PEDVEND) ) }) )
	If SF1->F1_PEDVEND <> "AUTO  "
		Help(" ",1,"A103PV" ,,RetTitle("C9_PEDIDO") + "  " + SF1->F1_PEDVEND,04,02)
	Else
		Help(" ",1,"A103CONS" )
	Endif
	lRetorno	:=	.F.
OtherWise
	lRetorno := .T.
EndCase

//Verifica se a factura esta "amarrada" a alguma solicitacao, caso esteja nao
//permite o seu cancelamento...
If lRetorno .And. (cPaisLoc <> "BRA") .And. SuperGetMv('MV_SOLNCP')
	aAreaSCU := SCU->(GetArea())
	SCU->(dbSetOrder(2))
	If SCU->(MsSeek(xFilial("SCU")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
		Help(" ",1,"MA055007")
		lRetorno :=	.F.
	EndIf
	RestArea(aAreaSCU)
EndIf

If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Documento de Entrada Original esta' vinculado a outros Documentos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery    := .T.
	 	cAliasSD1 := GetNextAlias()

	    If Select(cAliasSD1) > 0
           dbSelectArea(cAliasSD1)
           dbCloseArea()
        EndIf

		cQuery    := "SELECT COUNT(*) NOTAORI  "
		cQuery    += "FROM "+RetSqlName("SD1")+" SD1 "
		cQuery    += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
		cQuery    += "SD1.D1_NFORI='"+SF1->F1_DOC+"' AND "
		cQuery    += "SD1.D1_SERIORI='"+SF1->F1_SERIE+"' AND "
		cQuery    += "SD1.D1_TIPO='C' AND "
		cQuery    += "SD1.D1_FORNECE='"+SF1->F1_FORNECE+"' AND "
		cQuery    += "SD1.D_E_L_E_T_=' ' "

		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSD1, .T., .T. )

		If (cAliasSD1)->NOTAORI > 0
	   		Help(' ',1,'A103NEXCOR')
	   		lRetorno := .F.
		EndIf

		(cAliasSD1)->(dbCloseArea())
	Else
	#ENDIF
		cIndexSD1 := CriaTrab(,.f.)

		cQuery    := "D1_FILIAL=='"     +xFilial("SD1")+  "' .AND. "
		cQuery    += "D1_NFORI=='"      +SF1->F1_DOC+     "' .AND. "
		cQuery    += "D1_SERIORI=='"    +SF1->F1_SERIE+   "'"

		IndRegua("SD1",cIndexSD1,"D1_FILIAL+D1_NFORI+D1_SERIORI",, cQuery ,"")
		nIndexSD1 :=RetIndex("SD1")+1
		dbSetIndex(cIndexSD1+OrdBagExt())
		dbSetorder(nIndexSD1)
		dbGoTop()

		If (SD1->(!Eof()))
			Help(' ',1,'A103NEXCOR')
		   	lRetorno := .F.
		EndIf

		FErase(cIndexSD1 + OrdBagExt())

	#IFDEF TOP
	EndIf
	#ENDIF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa os itens da Nota fiscal de Entrada                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD1")
dbSetOrder(1)
#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery    := .T.
		cAliasSD1 := "MACANDELF1"
		aStruSD1  := SD1->(dbStruct())
		cQuery    := "SELECT SD1.*,SD1.R_E_C_N_O_ SD1RECNO "
		cQuery    += "FROM "+RetSqlName("SD1")+" SD1 "
		cQuery    += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
		cQuery    += "SD1.D1_DOC='"+SF1->F1_DOC+"' AND "
		cQuery    += "SD1.D1_SERIE='"+SF1->F1_SERIE+"' AND "
		cQuery    += "SD1.D1_FORNECE='"+SF1->F1_FORNECE+"' AND "
		cQuery    += "SD1.D1_LOJA='"+SF1->F1_LOJA+"' AND "
		cQuery    += "SD1.D1_TIPO='"+SF1->F1_TIPO+"' AND "
		cQuery    += "SD1.D_E_L_E_T_=' ' "
		cQuery    += "ORDER BY "+SqlOrder(SD1->(IndexKey()))

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)

		For nX := 1 To Len(aStruSD1)
			If aStruSD1[nX][2]<>"C"
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX
	Else
#ENDIF
	MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	#IFDEF TOP
	EndIf
	#ENDIF
While !Eof().And. (cAliasSD1)->D1_FILIAL == cFilSD1 .And.;
		(cAliasSD1)->D1_DOC == SF1->F1_DOC .And.;
		(cAliasSD1)->D1_SERIE == SF1->F1_SERIE .And.;
		(cAliasSD1)->D1_FORNECE == SF1->F1_FORNECE .And.;
		(cAliasSD1)->D1_LOJA == SF1->F1_LOJA .And. lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o Arquivo SF4.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SF4')
	dbSetOrder(1)
	MsSeek(cFilSF4+(cAliasSD1)->D1_TES)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a posicao do Pedido de Vendas  (Devolucao)          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty((cAliasSD1)->D1_NUMPV) .And. !((cAliasSD1)->D1_TIPO_NF $ "6789A")
		dbSelectArea('SC5')
		If MsSeek(cFilSC5+(cAliasSD1)->D1_NUMPV)
			aAdd(aRecSC5,SC5->(RecNo()))
		EndIf
		dbSelectArea('SC6')
		dbSetOrder(1)
		If MsSeek(cFilSC6+(cAliasSD1)->D1_NUMPV+(cAliasSD1)->D1_ITEMPV)
			If SC6->C6_QTDLIB+SC6->C6_QTDVEN+SC6->C6_QTDENT <> 0
				If Aviso(OemToAnsi(STR0029),OemToAnsi(STR0030),OemToAnsi(STR0031)) == 2 //"O pedido de vendas gerado pelo Docto. de devolucao ja foi liberado ou atendido e nao sera excluido. Deseja continuar ?"###"Continua"###"Abandona"
					lRetorno := .F.
					Exit
				EndIf
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Verifica se existe uma OP ja encerrada                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF4->F4_ESTOQUE == 'S'
		If !Empty((cAliasSD1)->D1_OP)
	    	aAreaAtu:=GetArea()
    		dbSelectArea("SC2")
   	 		dbSetOrder(1)
	    	If dbSeek(cFilSC2+(cAliasSD1)->D1_OP)
    			If !Empty(SC2->C2_DATRF)
    				MSGStop(OemToAnsi(STR0099)+(cAliasSD1)->D1_OP,OemToAnsi(STR0033)) //  "Hay una orden de producion cerrada para esta factura. Cancele la producion de la OP. :" ## Atencion
					lRetorno := .F.
				EndIf
			EndIf
			RestArea(aAreaAtu)
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trava os registros do SC7.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty((cAliasSD1)->D1_PEDIDO) .And. Empty((cAliasSD1)->D1_CONHEC) .And. !((cAliasSD1)->D1_TIPO_NF $ "6789A")
		dbSelectArea('SC7')
		dbSetOrder(14)
		If MsSeek(cFilSC7+(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC)
			If !SoftLock('SC7')
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trava os registros do SD7 e SD3                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty((cAliasSD1)->D1_NUMCQ) .And. Empty((cAliasSD1)->D1_CONHEC) .And. !((cAliasSD1)->D1_TIPO_NF $ "6789A")
		dbSelectArea("SD7")
		dbSetOrder(1)
		If dbSeek(cFilSD7+(cAliasSD1)->D1_NUMCQ+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_LOCAL)
			While !Eof() .And.lRetorno .And. cFilSD7 == SD7->D7_FILIAL .And.;
					(cAliasSD1)->D1_NUMCQ == SD7->D7_NUMERO .And.;
					(cAliasSD1)->D1_COD == SD7->D7_PRODUTO .And.;
					(cAliasSD1)->D1_LOCAL == SD7->D7_LOCAL

				If (SD7->D7_TIPO==1 .Or. SD7->D7_TIPO==2 ) .And. Empty(SD7->D7_ESTORNO)
					Help(' ',1,'A100CQ')
					lRetorno := .F.
					Exit
				ElseIf !SoftLock("SD7")
					lRetorno := .F.
					Exit
				Else
					dbSelectArea("SD3")
					dbSetOrder(4)
					If lRetorno .And. MsSeek(cFilSD3+SD7->D7_NUMSEQ)
						While !Eof() .And. lRetorno .And. SD3->D3_FILIAL == cFilSD3 .And.;
								SD3->D3_NUMSEQ == SD7->D7_NUMSEQ
							If !SoftLock("SD3")
								lRetorno := .F.
								Exit
							EndIf
							dbSelectArea("SD3")
							dbSkip()
						EndDo
					EndIf
				EndIf
				dbSelectArea("SD7")
				dbSkip()
			EndDo
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de Poder de Terceiros                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. SF4->F4_PODER3=="R" .And. !((cAliasSD1)->D1_TIPO_NF $ "6789A")
		dbSelectArea("SB6")
		dbSetOrder(3)
		MsSeek(cFilSB6 +(cAliasSD1)->D1_NUMSEQ+(cAliasSD1)->D1_COD+'R')
		While ( !Eof() .And. lRetorno .And. cFilSB6 == SB6->B6_FILIAL .And.;
				(cAliasSD1)->D1_NUMSEQ==SB6->B6_IDENT .And.;
				(cAliasSD1)->D1_COD==SB6->B6_PRODUTO .And.;
				"R"==SB6->B6_PODER3 )
			If SB6->B6_QUANT<>SB6->B6_SALDO .And. SB6->B6_TIPO=="D"
				Help(' ',1,'A520NPODER')
				lRetorno := .F.
			EndIf
			dbSelectArea("SB6")
			dbSkip()
		EndDo
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao do Ativo Fixo - Travamento                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty((cAliasSD1)->D1_CBASEAF) .And. !((cAliasSD1)->D1_TIPO_NF $ "6789A")
		dbSelectArea('SN1')
		dbSetOrder(1)
		If MsSeek(cFilSN1+(cAliasSD1)->D1_CBASEAF)
			If Af010VldDel("SN3",.T.)
				If !SoftLock('SN1')
					lRetorno := .F.
				EndIf
			Else
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia do CIAP                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty((cAliasSD1)->D1_CODCIAP) .And. !((cAliasSD1)->D1_TIPO_NF $ "6789A")
		dbSelectArea('SF9')
		dbSetOrder(1)
		If MsSeek(cFilSF9+(cAliasSD1)->D1_CODCIAP)
			If  (((!Empty((cAliasSD1)->D1_CBASEAF) .And. SF9->F9_ICMIMOB <> SN1->N1_ICMSAPR).Or.(Empty((cAliasSD1)->D1_CBASEAF) .And.SF9->F9_ICMIMOB <> 0)).Or.;
					SF9->F9_BXICMS <> 0 .Or. SF9->F9_MOTIVO <> " ")
				Help("  ",1,"A100CIAPDE")
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se algum produto esta sendo inventariado.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. BlqInvent((cAliasSD1)->D1_COD,(cAliasSD1)->D1_LOCAL)
		Help("  ",1,"BLQINVENT",,(cAliasSD1)->D1_COD+STR0032+(cAliasSD1)->D1_LOCAL,1,11) //"Armazem: "
		lRetorno := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Analisa se o tipo do armazem permite a movimentacao |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. lAvalBlqL .And. AvalBlqLoc((cAliasSD1)->D1_COD,(cAliasSD1)->D1_LOCAL,(cAliasSD1)->D1_TES)
		lRetorno := .F.
	EndIf

	/*Verifica si el documento fue generado a partir de Orden de Producción (Retorno de Beneficio)*/
	If cPaisLoc == "ARG" .And. cFuncName $ "MATA101N|MATA102N" .And. !Empty((cAliasSD1)->D1_OP) .And. !Empty((cAliasSD1)->D1_IDENTB6)
		lRetBenf := .T.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se algum produto ja foi distribuido                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Localiza((cAliasSD1)->D1_COD)
		dbSelectArea('SDA')
		dbSetOrder(1)
		If lRetorno .And. MsSeek(cFilSDA+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_LOCAL+(cAliasSD1)->D1_NUMSEQ+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
			If !(SDA->DA_QTDORI == SDA->DA_SALDO)
				Help(" ",1,"SDAJADISTR")
				lRetorno := .F.
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica saldo no endereco  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno .And. nPLocaliz > 0 .And. !Empty((cAliasSD1)->D1_LOCALIZ) .And. SF4->F4_ESTOQUE=="S" .AND. ;
		   QtdComp(SaldoSBF((cAliasSD1)->D1_LOCAL,(cAliasSD1)->D1_LOCALIZ,(cAliasSD1)->D1_COD,(cAliasSD1)->D1_NUMSERI,(cAliasSD1)->D1_LOTECTL,(cAliasSD1)->D1_NUMLOTE,,'')) < QtdComp(IIf(!lRetBenf, (cAliasSD1)->D1_QUANT, 0))
			Help(" ",1,'SALDOLCSBF')
			lRetorno := .F.
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a quantidade devolvida.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. ((cAliasSD1)->D1_QTDEDEV <> 0 .Or. (cAliasSD1)->D1_VALDEV <> 0)
		Help(' ',1,'NAOEXCL')
		lRetorno := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a quantidade clasificada (remitos de localizacoes)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. lRemito .And. (cAliasSD1)->D1_QTDACLA <> (cAliasSD1)->D1_QUANT
		Help(' ',1,'NAOEXCLREM')
		lRetorno := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o remito esta amarrada a alguma nota de Credito  ³
	//| Ambiente Portugal, verifica se a Guia esta vinculada a outro |
	//| documento...												 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. lRemito .Or. (lRetorno .And. cPaisLoc=="PTG" .aND. AllTrim((cAliasSD1)->D1_ESPECIE)$"GDN")
		SD1->(DbSetOrder(10))
		If SD1->(MsSeek(cFilSD1+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_DOC))
			Help(' ',1,'NAOEXCLREM',,SD1->D1_ESPECIE+" "+SD1->D1_SERIE+"/"+SD1->D1_DOC,1,11)
			lRetorno := .F.
		Endif
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Servico do WMS - Se necessario, trava o DCF.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty((cAliasSD1)->D1_SERVIC) .And. (SuperGetMV('MV_INTDL')=='S')
		DCF->(dbSetOrder(2)) //-- FILIAL+SERVIC+DOCTO+SERIE+CLIFOR+LOJA+CODPRO
		If DCF->(MsSeek(cSeekDCF:=cFilDCF+(cAliasSD1)->D1_SERVIC+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_COD, .F.))
			While !DCF->(Eof()) .And. cSeekDCF==DCF->DCF_FILIAL+DCF->DCF_SERVIC+DCF->DCF_DOCTO+DCF->DCF_SERIE+DCF->DCF_CLIFOR+DCF->DCF_LOJA+DCF->DCF_CODPRO
				If DCF->DCF_NUMSEQ == (cAliasSD1)->D1_NUMSEQ
					If !(DCF->DCF_STSERV=='1')
						Help(' ',1,'NAOEXCL')
						lRetorno := .F.
					ElseIf !SoftLock('DCF')
						lRetorno := .F.
					EndIf
					Exit
				EndIf
				DCF->(dbSkip())
			EndDo
		EndIf
	EndIf
	If Empty((cAliasSD1)->D1_REMITO)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Totaliza no array aLotes para validar a exclusao.            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno .And. Rastro((cAliasSD1)->D1_COD) .And. SF4->F4_ESTOQUE=='S' .And. !((cAliasSD1)->D1_TIPO_NF $ "6789A")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ aLotes[nx][1] : Codigo do Produto        ³
			//³ aLotes[nx][2] : Almoxarifado             ³
			//³ aLotes[nx][3] : Lote                     ³
			//³ aLotes[nx][4] : SubLote                  ³
			//³ aLotes[nx][5] : OP                       ³
			//³ aLotes[nx][6] : Numero Sequencial        ³
			//³ aLotes[nx][7] : Quantidade               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosLote :=Ascan(aLotes,{|x| x[1]+x[2]+x[3]+x[4]==(cAliasSD1)->D1_COD+(cAliasSD1)->D1_LOCAL+(cAliasSD1)->D1_LOTECTL+(cAliasSD1)->D1_NUMLOTE+(cAliasSD1)->D1_OP+(cAliasSD1)->D1_NUMSEQ})
			If nPosLote > 0
				aLotes[nPosLote][7] += (cAliasSD1)->D1_QUANT
			Else
				aADD(aLotes,{(cAliasSD1)->D1_COD,(cAliasSD1)->D1_LOCAL,(cAliasSD1)->D1_LOTECTL,(cAliasSD1)->D1_NUMLOTE,(cAliasSD1)->D1_OP,(cAliasSD1)->D1_NUMSEQ,(cAliasSD1)->D1_QUANT})
			EndIf
		EndIf
	EndIf

	If lRetorno .And. SF4->F4_ESTOQUE == "S" .And. !((cAliasSD1)->D1_TIPO_NF $ "6789A")
		nY := Ascan(aProd,{|X| x[1]== (cAliasSD1)->D1_COD .And. x[3] == (cAliasSD1)->D1_LOCAL})
		nQuant := IIf(cPaisloc <> "BRA" .And. cFuncName $ "MATA101N" .And. !Empty((cAliasSD1)->D1_REMITO),0, (cAliasSD1)->D1_QUANT)
		nQuant := IIf(!lRetBenf, nQuant, 0)
		If cCodPro == (cAliasSD1)->D1_COD .and. nY > 0
			aProd[nY][2]:= aProd[nY][2] + nQuant
 		Else
 			AADD(aProd,{(cAliasSD1)->D1_COD,nQuant,(cAliasSD1)->D1_LOCAL, Iif(!Empty((cAliasSD1)->D1_REMITO), .T.,.F.)})
 		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao do Custo FIFO On-Line                     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. SF4->F4_ESTOQUE == "S" .And. lIsFifoOn .And. IsFifoOnLine() .And. !((cAliasSD1)->D1_TIPO_NF $ "6789A")
		If SaldoSBD("SD1",(cAliasSD1)->D1_COD,(cAliasSD1)->D1_LOCAL,dDataBase,Rastro((cAliasSD1)->D1_COD),cAliasSD1)[1] < (cAliasSD1)->D1_QUANT
			Help(" ",1,"DIVFIFO2")
			lRetorno := .F.
		EndIf
	EndIf

	cCodPro := (cAliasSD1)->D1_COD

	dbSelectArea(cAliasSD1)
	dbSkip()

EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Sld no B2 ficar  Neg. ou Menor que Sld em Reserva³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nI := 1 to Len (aProd)
	SB2->(dbSetOrder(1))
	If SB2->(MsSeek(cFilSB2+aProd[nI][1]+aProd[nI][3], .F.))
		nSaldoB2 := (SaldoSB2(lSaldoSB2,,,,,,,,,,lSaldoSA) - aProd[nI][2])
		If QtdComp(nSaldoB2)<QtdComp(0)
			If !lEstNeg
				If !aProd[nI][4]
					Aviso(STR0033,STR0222,{"OK"}) //"¡Atencion!" //"¡Parámetro mv_estneg configurado para no aceptar stock negativo, el documento no podrá borrarse!"
					lRetorno := .F.
				EndIf
			ElseIf lExcluiNeg
				If cFuncName == "MATA486" .And. lRutAut
					lRetorno := .T.
				Else
					lRetorno := (Aviso(STR0033,STR0218 + AllTrim(aProd[nI][1])+'/'+ aProd[nI][3]+ STR0219 +'(' + AllTrim(Str(nSaldoB2)) + ').'+ STR0220,{'Aborta',STR0030}) == 2) //"Atencao"###"Continua"
				End
			Else
				If IsBlind() .And. cPaisLoc == "ARG"
					lRetorno := .T.
				Else
					Aviso(STR0033,STR0218 + AllTrim(aProd[nI][1])+'/'+ aProd[nI][3] +  STR0219 + ' (' + AllTrim(Str(nSaldoB2))+") ",{'Aborta'}) //"Atencao"
					lRetorno := .F.
				End
			EndIf
		ElseIf QtdComp(nSaldoB2)<QtdComp(SB2->B2_RESERVA)
			If lExcluiNeg
				lRetorno := (Aviso(STR0033,STR0218 + AllTrim(aProd[nI][1])+'/'+ aProd[nI][3]+ STR0219 +'(' + AllTrim(Str(nSaldoB2)) + ').'+ STR0220,{'Aborta',STR0030}) == 2) //"Atencao"###"Continua"
			Else
				Aviso(STR0033,STR0218 + AllTrim(aProd[nI][1])+'/'+ aProd[nI][3] + STR0221 +' (' + AllTrim(Str(nSaldoB2))+")",{'Aborta'}) //"Atencao"
				lRetorno := .F.
			Endif
		EndIf
	EndIf
Next

If lQuery
	dbSelectArea(cAliasSD1)
	dbCloseArea()
	dbSelectArea("SD1")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se os Lotes podem ser excluidos                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aLotes[nx][1] : Codigo do Produto        ³
	//³ aLotes[nx][2] : Almoxarifado             ³
	//³ aLotes[nx][3] : Lote                     ³
	//³ aLotes[nx][4] : SubLote                  ³
	//³ aLotes[nx][5] : OP                       ³
	//³ aLotes[nx][6] : Numero Sequencial        ³
	//³ aLotes[nx][7] : Quantidade               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aLotes)
		If SaldoLote(aLotes[nX][1],aLotes[nX][2],aLotes[nX][3],aLotes[nX][4],,,.T.) < aLotes[nX][7]
			If !Empty(aLotes[nx,5])
				dbSelectArea("SD3")
				dbSetOrder(4)
				MsSeek(cFilSD3+aLotes[nx,6])
				While !Eof() .And. SD3->D3_CF # "RE5" .And. SD3->D3_NUMSEQ == aLotes[nx,6]
					dbSkip()
				End
				lEofSD3 := IIF(SD3->D3_NUMSEQ # aLotes[nx,6],.T.,.F.)
				If lEofSD3
					Help(' ',1,'A100NOLOTE',,aLotes[nX,1]+'  '+aLotes[nX,2]+'    '+aLotes[nX,3],5,4)
					lRetorno := .F.
					Exit
				EndIf
			Else
				Help(' ',1,'A100NOLOTE',,aLotes[nX,1]+'  '+aLotes[nX,2]+'    '+aLotes[nX,3],5,4)
				lRetorno := .F.
				Exit
			EndIf
		EndIf
	Next
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se as duplicatas podem ser excluidas  SE2           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCheckFin
	If lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o Prefixo correto da Nota fiscal de Entrada         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SuperGetMV("MV_2DUPREF"))
			cPrefixo	:= &(SuperGetMV("MV_2DUPREF"))
		Endif
		cPrefixo	:= If(Empty(cPrefixo),CriaVar("SF1->F1_PREFIXO"),cPrefixo)
		cPrefixo	:= IIf(Empty(SF1->F1_PREFIXO),cPrefixo,SF1->F1_PREFIXO)
		dbSelectArea("SE2")
		dbSetOrder(6)
		#IFDEF TOP
			If TcSrvType()<>"AS/400"
				lQuery    := .T.
				aStruSE2  := SE2->(dbStruct())
				cAliasSE2 := "MACANDELF1"
				cQuery    := "SELECT SE2.*,SE2.R_E_C_N_O_ SE2RECNO "
				cQuery    += "FROM "+RetSqlName("SE2")+" SE2 "
				cQuery    += "WHERE SE2.E2_FILIAL='"+xFilial("SE2")+"' AND "
				cQuery    += "SE2.E2_FORNECE='"+SF1->F1_FORNECE+"' AND "
				cQuery    += "SE2.E2_LOJA='"+SF1->F1_LOJA+"' AND "
				cQuery    += "SE2.E2_PREFIXO='"+cPrefixo+"' AND "
				cQuery    += "SE2.E2_NUM='"+SF1->F1_DUPL+"' AND "
				cQuery    += "SE2.E2_TIPO='"+SF1->F1_ESPECIE+"' AND "
				cQuery    += "SE2.D_E_L_E_T_=' ' "
				cQuery    += "ORDER BY "+SqlOrder(SE2->(IndexKey()))

				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
				For nX := 1 To Len(aStruSE2)
					If aStruSE2[nX][2]<>"C"
						TcSetField(cAliasSE2,aStruSE2[nX][1],aStruSE2[nX][2],aStruSE2[nX][3],aStruSE2[nX][4])
					EndIf
				Next nX
			Else
		#ENDIF
			MsSeek(cFilSE2+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DUPL)
			#IFDEF TOP
			EndIf
			#ENDIF
		aRecSE2	:=	{}
		While ( !Eof() .And. lRetorno .And.;
				cFilSE2 == (cAliasSE2)->E2_FILIAL .And.;
				SF1->F1_FORNECE == (cAliasSE2)->E2_FORNECE .And.;
				SF1->F1_LOJA == (cAliasSE2)->E2_LOJA .And.;
				cPrefixo == (cAliasSE2)->E2_PREFIXO .And.;
				SF1->F1_DUPL == (cAliasSE2)->E2_NUM )
			If (cAliasSE2)->E2_TIPO $ IIf(cPaisLoc == "BRA",MVNOTAFIS,Substr(SF1->F1_ESPECIE,1,3)+ "/" + MVTAXA + "/" + MVABATIM)
				aadd(aRecSE2,If(lQuery,(cAliasSE2)->SE2RECNO,(cAliasSE2)->(RecNo())))
				lValDelCP := IIf(cPaisLoc $ "MEX|COL|PER|EQU" .And. FindFunction("LxVldBaixa"), LxVldBaixa(cAliasSE2, cOrigFin), FaCanDelCP(cAliasSE2, cOrigFin))
				If !lValDelCP
					lRetorno := .F.
					Exit
				EndIf
			EndIf
			dbSelectArea(cAliasSE2)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasSE2)
			dbCloseArea()
			dbSelectArea("SE2")
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se as duplicatas podem ser excluidas  SE1           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. cTipo == 'D'
		dbSelectArea('SE1')
		dbSetOrder(2)
		If MsSeek(cFilSE1+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DOC)
			While !Eof().And. lRetorno .And. cFilSE1+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DOC==;
					E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM
				If AllTrim(E1_TIPO) <> AllTrim(SF1->F1_ESPECIE)
					dbSelectArea('SE1')
					dbSkip()
					Loop
				EndIf
				If SE1->E1_SALDO <> SE1->E1_VALOR
					Help(' ',1,'A100FINBX')
					lRetorno := .F.
				ElseIf !SoftLock('SE1')
					lRetorno := .F.
				EndIf
				dbSelectArea('SE1')
				dbSkip()
			EndDo
		EndIf
	EndIf
EndIf
RestArea(aAreaSF1)
RestArea(aAreaSD1)
RestArea(aAreaSF8)
RestArea(aArea)
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103RTELOK³ Autor ³ Edson Maricate        ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³LinOk da GatDados da Tela de rateios por CC                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103RTELOK()

Local nPPerc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DE_PERC"} )
Local lRetorno  := .T.
Local nX        := 0

_nLinhaR		:= N

If !aCols[N][Len(aCols[N])]
	If aCols[N][nPPerc] == 0
		Help(" ",1,"A103PERC")
		lRetorno := .F.
	EndIf
EndIf

If lRetorno
	nPercRat := 0
	nPercARat:= 0
	For nX	:= 1 To Len(aCols)
		If !aCols[nX][Len(aCols[nX])]
			nPercRat += aCols[nX][nPPerc]
		EndIf
	Next
	nPercARat := 100 - nPercRat
	If Type("oPercRat")=="O"
		oPercRat:Refresh()
		oPercARat:Refresh()
	Endif
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103RTETDK³ Autor ³ Edson Maricate        ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³TudOk da GatDados da Tela de rateios por CC                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103RTETDK()
Local nPPerc   := aScan(aHeader,{|x| AllTrim(x[2]) == "DE_PERC"} )
Local nTotal   := 0
Local nX       := 0
Local lRetorno := .T.

For nX	:= 1 To Len(aCols)
	If !aCols[nX][Len(aCols[nX])]
		nTotal += aCols[nX][nPPerc]
	EndIf
Next
If lRetorno
	If nTotal > 0 .And. nTotal <> 100
		Help(" ",1,"A103TOTRAT")
		lRetorno := .F.
	EndIf
EndIf
Return lRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103Cond  ³ Rev   ³ Edson Maricate        ³ Data ³07.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de tratamento do folder financeiro                    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Condicao de Pagamento                                 ³±±
±±³          ³ExpO2: Objeto da descricao de pagamento                      ³±±
±±³          ³ExpC3: Descricao da condicao de pagamento                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo exibir/controlar o folder finan³±±
±±³          ³ceiro.                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LxA103Cond(cCondicao,oDescri,cDescri,lInclui,lAltImp)

Local lRet := Empty(cCondicao)
Default lAltImp:=.F.
cDescri	:= ""

SE4->(dbSetOrder(1))
If (SE4->(MsSeek(xFilial("SE4")+cCondicao)))
	If SE4->E4_TIPO == "9" .And. lInclui
		Help("  ",1,"A100COND")
		lRet := .F.
	Else
		cDescri	:= SE4->E4_DESCRI
		If cPaisLoc == "EQU" .and. Type('cFormCrbo') <> 'U' .and. SE4->(ColumnPos("E4_MPAGSAT")) > 0
			cFormCrbo := SE4->E4_MPAGSAT
		EndIf
		lRet := .T.
	EndIf
Else
	If !Empty(cCondicao)
		Help("  ",1,"REGNOIS")
		lRet := .F.
	Endif
Endif
If  cPaisLoc == "ARG" .And. !(Type('lLocxAuto') <> 'U' .And. lLocxAuto) .And. !(Type('l103Auto') <> 'U' .And. l103Auto);
	.And. lAltImp .And. MsgYesNo(STR0055,STR0056)
	MaFisReprocess(2)
EndIf
If !(Type('lLocxAuto') <> 'U' .And. lLocxAuto) .And. !(Type('l103Auto') <> 'U' .And. l103Auto)
	oDescri:Refresh()
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103EditDupl³ Autor ³ Edson Maricate      ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ermite a edicao doa valores das duplicatas                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103EditDupl(oList,aTemp,nCol)
Local dVenctoAnt	:= aTemp[oList:nAT][4]
Local dVencto		:= dVenctoAnt
Local nValorAnt	:= aTemp[oList:nAT][5]
Local nValor		:= nValorAnt
Local nX		:= 0

DEFAULT nCol	:=	0
If nCol == 0
	MaFisEditCell(@dVencto,oList,'',4,'LxA103VldDupl(1)')
	MaFisEditCell(@nValor,oList,PesqPict("SE2","E2_VALOR"),5,'LxA103VldDupl(2)')
ElseIf nCol	==	4
	MaFisEditCell(@dVencto,oList,'',4,'LxA103VldDupl(1)')
ElseIf nCol	==	5
	MaFisEditCell(@nValor,oList,PesqPict("SE2","E2_VALOR"),5,'LxA103VldDupl(2)')
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array utilizado na geracao das duplicatas    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDupl	:= {}
For nx := 1 to Len(aTemp)
	If cPaisLoc != 'RUS'
		aAdd(aDupl,aTemp[nx][2]+"³"+aTemp[nx][1]+"³ "+aTemp[nx][3]+" ³";
			+DTOC(aTemp[nx][4])+"³ "+Transform(aTemp[nx][5],PesqPict("SE2","E2_VALOR")) )
	Else
		aAdd(aDupl,aTemp[nx][2]+CHR(124)+aTemp[nx][1]+CHR(124)+" "+aTemp[nx][3]+" "+CHR(124);
		+DTOC(aTemp[nx][4])+CHR(124)+" "+Transform(aTemp[nx][5],PesqPict("SE2","E2_VALOR")) )
	EndIf
Next

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103Line³ Autor ³  Edson Maricate         ³ Data ³18.03.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza a linha de Dados da DoContabil.                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103Line(oList,aTemp)
Local aRet:= {aTemp[oList:nAt][1],;
	aTemp[oList:nAt][2],;
	aTemp[oList:nAt][3],;
	aTemp[oList:nAt][4],;
	TransForm(aTemp[oList:nAt][5],PesqPict("SE2","E2_VALOR")) }

Return aRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103AtuSCQ³ Autor ³ Edson Maricate        ³ Data ³ 25.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Libera as pre-requisicoes a partir da entrada de Materiais.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MatA185                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103SCQ(nQtd, nOpc)
Local nQuantLib	:= 0
Local nQempSA	:= 0
Local aAreaSC1	:= SC1->(GetArea())
Local aAreaSCQ	:= SCQ->(GetArea())
Local aAreaSB2	:= SB2->(GetArea())
Local aLibera 	:= {}
Local nx		:= 0
Local cCondicao	:= ""
Local cFilSB2	:= xFilial("SB2")
Local cFilSC1	:= xFilial("SC1")
Local cFilSCQ	:= xFilial("SCQ")

Default nOpc := 1

dbSelectArea("SCQ")
dbSetOrder(2) //CQ_FILIAL+CQ_NUMSC+CQ_ITSC
If nOpc == 1
	If !Empty(SC7->C7_NUMCOT)
		dbSelectArea("SC1")
		dbSetOrder(5)//C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT
		MsSeek(cFilSC1 + SC7->C7_NUMCOT + SC7->C7_PRODUTO)
		While !EOF() .and. cFilSC1+SC7->C7_NUMCOT+SC7->C7_PRODUTO==C1_FILIAL+C1_COTACAO+C1_PRODUTO
			AADD( aLibera, {C1_DATPRF,C1_QUJE,Recno()} )
			dbSkip()
		EndDo
		aLibera:=aSort( aLibera,,, { | x , y | x[1] < y[1] } )
		For nx:=Len(aLibera) to 1 Step -1
			MsGoto(aLibera[nx][3])
			dbSelectArea("SCQ")
			MsSeek(cFilSCQ+SC1->C1_NUM+SC1->C1_ITEM)
			nQuantLib := SD1->D1_QUANT
			While !Eof() .And. CQ_FILIAL+CQ_NUMSC+CQ_ITSC==cFilSCQ+SC1->C1_NUM+SC1->C1_ITEM
				If SCQ->CQ_QUANT > SCQ->CQ_QTDISP .And. nQuantLib > 0.And. Empty(SCQ->CQ_NUMREQ)
					RecLock("SCQ",.F.)
					If SCQ->CQ_QUANT-SCQ->CQ_QTDISP > nQuantLib
						SCQ->CQ_QTDISP := SCQ->CQ_QTDISP + nQuantLib
						nQEmpSa	 := nQuantLib
						nQuantLib := 0
					Else
						nQuantLib -= SCQ->CQ_QUANT-SCQ->CQ_QTDISP
						nQEmpSa	 :=  SCQ->CQ_QUANT-SCQ->CQ_QTDISP
						SCQ->CQ_QTDISP := SCQ->CQ_QUANT
					EndIf
					SCQ->CQ_STATUSC := " "
					dbSelectArea("SB2")
					MsSeek(cFilSB2+SCQ->CQ_PRODUTO+SCQ->CQ_LOCAL)
					Reclock("SB2",.F.)
					SB2->B2_QEMPSA := B2_QEMPSA + nQEmpSa
					MsUnlock()
				EndIf
				dbSelectArea("SCQ")
				dbSkip()
			End
			dbSelectArea("SC1")
		Next nx
	Else
		If SC7->C7_TIPO==2
			dbSelectArea("SCQ")
			dbSetOrder(3)//CQ_FILIAL+CQ_NUMAE+CQ_ITAE
			MsSeek(cFilSCQ+SC7->C7_NUM+SC7->C7_ITEM)
			nQuantLib := SD1->D1_QUANT
			cCondicao := "CQ_FILIAL+CQ_NUMAE+CQ_ITAE==xFilial()+SC7->C7_NUM+SC7->C7_ITEM"
		Else
			dbSelectArea("SC1")
			If MsSeek(cFilSC1+SC7->C7_NUMSC+SC7->C7_ITEMSC)
				dbSelectArea("SCQ")
				MsSeek(cFilSCQ+SC1->C1_NUM+SC1->C1_ITEM)
				nQuantLib := SD1->D1_QUANT
				If !Empty(SCQ->CQ_NUMAE)
					nQuantLib := SCQ->CQ_QUANT
				EndIf
				cCondicao := "CQ_FILIAL+CQ_NUMSC+CQ_ITSC==xFilial()+SC1->C1_NUM+SC1->C1_ITEM"
			EndIf
		EndIf
		While !Eof() .And. &cCondicao
			If SCQ->CQ_QUANT > SCQ->CQ_QTDISP .And. nQuantLib > 0.And. Empty(SCQ->CQ_NUMREQ)
				RecLock("SCQ",.F.)
				If SCQ->CQ_QUANT-SCQ->CQ_QTDISP > nQuantLib
					SCQ->CQ_QTDISP := SCQ->CQ_QTDISP + nQuantLib
					nQEmpSa	 := nQuantLib
					nQuantLib := 0
				Else
					nQuantLib -= SCQ->CQ_QUANT-SCQ->CQ_QTDISP
					nQEmpSa	 :=  SCQ->CQ_QUANT-SCQ->CQ_QTDISP
					SCQ->CQ_QTDISP := SCQ->CQ_QUANT
				EndIf
				SCQ->CQ_STATUSC := " "
				dbSelectArea("SB2")
				MsSeek(cFilSB2+SCQ->CQ_PRODUTO+SCQ->CQ_LOCAL)
				Reclock("SB2",.F.)
				SB2->B2_QEMPSA := B2_QEMPSA + nQEmpSa
				MsUnlock()
			EndIf
			dbSelectArea("SCQ")
			dbSkip()
		EndDo
	EndIf
ElseIf nOpc == 2
	If Empty(SC7->C7_NUMCOT)
		If SC7->C7_TIPO == 2
			dbSelectArea("SCQ")
			SCQ->(dbSetOrder(3)) //CQ_FILIAL + CQ_NUMAE + CQ_ITAE
			If SCQ->(MsSeek(cFilSCQ+SC7->C7_NUM+SC7->C7_ITEM))
				nQuantLib := SD1->D1_QUANT
			EndIf
			cCondicao := "CQ_FILIAL+CQ_NUMAE+CQ_ITAE==xFilial()+SC7->C7_NUM+SC7->C7_ITEM"
		Else
			dbSelectArea("SC1")
			SC1->(dbSelectArea(1)) //C1_FILIAL + C1_NUM + C1_ITEM + C1_ITEMGRD
			If SC1->(MsSeek(cFilSC1 + SC7->C7_NUMSC + SC7->C7_ITEMSC))
				dbSelectArea("SCQ")
				SCQ->(dbSelectArea(1)) //CQ_FILIAL + CQ_NUM + CQ_ITEM + CQ_NUMSQ
				If SCQ->(MsSeek(cFilSCQ + SC1->C1_NUM + SC1->C1_ITEM))
					nQuantLib := SD1->D1_QUANT
					If !Empty(SCQ->CQ_NUMAE)
						nQuantLib := SCQ->CQ_QUANT
					EndIf
				EndIf
				cCondicao := "CQ_FILIAL+CQ_NUMSC+CQ_ITSC==xFilial()+SC1->C1_NUM+SC1->C1_ITEM"
			EndIf
		EndIf

		While SCQ->(!Eof()) .And. IIF(cCondicao!="", &cCondicao, .t.)
			If SCQ->CQ_QTDISP > 0 .And. nQuantLib > 0.And. Empty(SCQ->CQ_NUMREQ)
				RecLock("SCQ",.F.)
				If SCQ->CQ_QTDISP - nQuantLib >= 0
					SCQ->CQ_QTDISP -= nQuantLib
				Else
					SCQ->CQ_QTDISP := SCQ->CQ_QTDISP - nQuantLib
					nQEmpSa	 := nQuantLib
					nQuantLib := 0
				EndIf
				SCQ->CQ_STATUSC := " "
				dbSelectArea("SB2")
				SB2->(dbSelectArea(1)) //B2_FILIAL + B2_COD + B2_LOCAL
				If SB2->(MsSeek(cFilSB2 + SCQ->CQ_PRODUTO + SCQ->CQ_LOCAL))
					Reclock("SB2",.F.)
					SB2->B2_QEMPSA -= nQuantLib
					SB2->(MsUnlock())
				EndIf
			EndIf
			dbSelectArea("SCQ")
			SCQ->(dbSkip())
		EndDo
	EndIf
EndIf

RestArea(aAreaSB2)
RestArea(aAreaSCQ)
RestArea(aAreaSC1)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103CReaj³ Rev.  ³ Edson Maricate         ³ Data ³28.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcular o Reajuste do Pedido na Entrada da Nota.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void A103CReaj(ExpC1,ExpL1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = C¢digo da F¢rmula do Reajuste                      ³±±
±±³          ³ ExpL1 = Aplicar ou nƒo o Reajuste                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103CReaj(cReajuste,lReajuste)
Local nPreco,dBase := dDataBase

dDataBase := dDEmissao
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Calcula o reajuste                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC7")
nPreco := SC7->C7_PRECO

If !Empty(SC7->C7_REAJUST)
	If !Empty(cReajuste) .And. lReajuste
		nPreco := Formula(cReajuste)
	EndIf
EndIf

dDataBase := dBase

Return( nPreco )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103VldDupl³ Autor ³ Edson Maricate       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida os dados digitados pelo usuario na Duplicata         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103VldDupl(nCpo)
Local lRet	:= .T.

Do Case
Case nCpo == 1
	If M->CELL < dDEmissao
		Help("   ",1,"A100DATADU")
		lRet := .F.
	EndIf
Case nCpo == 2
	If !Positivo()
		lRet := .F.
	EndIf
EndCase

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LxA103Custo³ Autor ³ Edson Maricate       ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o custo de entrada do Item                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103Custo(nItem)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Item da NF                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 , A103Grava()                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103Custo(nItem,lRemito)
Local aCusto 	:= {}
Local aRet   	:= {}
Local aCMAtu 	:= {}
Local aSD2   	:= {}
Local nPos   	:= 0
Local nValIV 	:= 0
Local nX     	:= 0
Local nZ     	:= 0
Local cItem  	:= ""
Local cFilTrf	:= ""
Local cPe	    := ""
Local cCpoCusto := GetMV("MV_CPOCUS",,"U")
Local lCustPad  := .T.
Local cAuxPaisL := ""
Local nMoedaBkp as Numeric
Local nCustoRus	as Numeric
Local aTaxesRus	as Array

DEFAULT lRemito := .F.

If (Type('l103Auto') <> 'U' .And. l103Auto) .And. Len(aAutoItens) > 0 .And. (nPos:= aScan(aAutoItens[nItem],{|x|Trim(x[1])== "D1_CUSTO" })) > 0
	 If lRemito
	  	aADD(aCusto,{aAutoItens[nItem,nPos,2],0.00,0.00,SF4->F4_CREDIPI,;
			SF4->F4_CREDICM,;
			"",;
			"",;
			SD1->D1_COD,;
			SD1->D1_LOCAL,;
			SD1->D1_QUANT,;
			0 ,;
			SF4->F4_CREDST,;
			0,;
			0,;
			SF4->F4_PISCOF,;
			SF4->F4_PISCRED,;
			;
			})
	 Else
		aADD(aCusto,{aAutoItens[nItem,nPos,2],0.00,0.00,SF4->F4_CREDIPI,;
			SF4->F4_CREDICM,;
			MaFisRet(nItem,"IT_NFORI"),;
			MaFisRet(nItem,"IT_SERORI"),;
			SD1->D1_COD,;
			SD1->D1_LOCAL,;
			SD1->D1_QUANT,;
			If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0) ,;
			SF4->F4_CREDST,;
			MaFisRet(nItem,"IT_VALSOL"),;
			MaRetIncIV(nItem,"1"),;
			SF4->F4_PISCOF,;
			SF4->F4_PISCRED,;
			MaFisRet( nItem, "IT_VALPS2" );
			})
	 EndIf
Else
	//Tirar o valor dos impostos variaveis que incidem na nota
	 If lRemito
	 	nValIV	:=0
	 Else
		nValIV	:=	MaRetIncIV(nItem,'2')
	 EndIf
	cAuxPaisL := "ANG|ARG|AUS|BOL|BRA|CHI|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|SAL|URU|VEN"
	If SD1->D1_COD == Left(SuperGetMV('MV_PRODIMP'), Len(SD1->D1_COD))
		If lRemito
			aADD(aCusto,{SD1->D1_TOTAL,;
					0,;
					0,;
					SF4->F4_CREDIPI,;
					SF4->F4_CREDICM,;
					"",;
					"",;
					SD1->D1_COD,;
					SD1->D1_LOCAL,;
					SD1->D1_QUANT,;
					0 ,;
					SF4->F4_CREDST,;
					0,;
					0,;
					SF4->F4_PISCOF,;
					SF4->F4_PISCRED,;
					0;
					})
		Else
			aADD(aCusto,{MaFisRet(nItem,"IT_TOTAL")-IIF(cTipo == "P".Or.SF4->F4_IPI=="R",0,MaFisRet(nItem,"IT_VALIPI"))+MaFisRet(nItem,"IT_VALICM")+MaFisRet(nItem,"IT_VALCMP")-If(IIf(cPaisLoc $ cAuxPaisL ,SF4->F4_INCSOL=="S",.F.),MaFisRet(nItem,"IT_VALSOL"),0)-nValIV,;
				MaFisRet(nItem,"IT_VALIPI"),;
				MaFisRet(nItem,"IT_VALICM"),;
				SF4->F4_CREDIPI,;
				SF4->F4_CREDICM,;
				MaFisRet(nItem,"IT_NFORI"),;
				MaFisRet(nItem,"IT_SERORI"),;
				SD1->D1_COD,;
				SD1->D1_LOCAL,;
				SD1->D1_QUANT,;
				If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0) ,;
				SF4->F4_CREDST,;
				MaFisRet(nItem,"IT_VALSOL"),;
				MaRetIncIV(nItem,"1"),;
				SF4->F4_PISCOF,;
				SF4->F4_PISCRED,;
				MaFisRet( nItem, "IT_VALPS2" );
				})
        EndIf
	Else
		If lRemito
			aADD(aCusto,{SD1->D1_TOTAL,;
					0,;
					0,;
					SF4->F4_CREDIPI,;
					SF4->F4_CREDICM,;
					"",;
					"",;
					SD1->D1_COD,;
					SD1->D1_LOCAL,;
					SD1->D1_QUANT,;
					0 ,;
					SF4->F4_CREDST,;
					0,;
					0,;
					SF4->F4_PISCOF,;
					SF4->F4_PISCRED,;
					0;
					})
		Else
			aADD(aCusto,{IIF (cPaisLoc=="MEX",MaFisRet(nItem,"IT_TOTAL")+MaFisRet(nItem,"IT_ADIANT"),MaFisRet(nItem,"IT_TOTAL"))-IIF(cTipo == "P".Or.SF4->F4_IPI=="R",0,MaFisRet(nItem,"IT_VALIPI"))+MaFisRet(nItem,"IT_VALCMP")-If(IIf(cPaisLoc $ cAuxPaisL ,SF4->F4_INCSOL=="S",.F.),MaFisRet(nItem,"IT_VALSOL"),0)-nValIV,;
				MaFisRet(nItem,"IT_VALIPI"),;
				MaFisRet(nItem,"IT_VALICM"),;
				SF4->F4_CREDIPI,;
				SF4->F4_CREDICM,;
				MaFisRet(nItem,"IT_NFORI"),;
				MaFisRet(nItem,"IT_SERORI"),;
				SD1->D1_COD,;
				SD1->D1_LOCAL,;
				SD1->D1_QUANT,;
				If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0) ,;
				SF4->F4_CREDST,;
				MaFisRet(nItem,"IT_VALSOL"),;
				MaRetIncIV(nItem,"1"),;
				SF4->F4_PISCOF,;
				SF4->F4_PISCRED,;
				MaFisRet( nItem, "IT_VALPS2" );
				})
        EndIf
	EndIf
	If cPaisLoc == "RUS" .And. nMoedaNF <> 1
		nCustoRus := SD1->D1_TOTALM
		aTaxesRus := MaRetIncIV(nItem,"1")

		dbSelectArea("SFB")
		SFB->(dbSetOrder(1))	//	FB_FILIAL+FB_CODIGO
		For nX :=1 to Len(aTaxesRus)
			If SFB->(dbSeek(xFilial("SFB") + aTaxesRus[nX,1]))
				If SFB->FB_CPOLVRO == "1"
					nCustoRus +=  SD1->D1_VLIMP1M * IIf(aTaxesRus[nX,2]<0,-1,1)
					aTaxesRus[nX,2] := 0
				EndIf
			EndIf
		Next nX

		aCusto[1][1] := nCustoRus
		aCusto[1][14] := aTaxesRus
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao considerar o custo de uma entrada por devolucao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Sergio Fuzinaka - 06.06.02 ÄÙ
cAuxPaisL := "ANG|ARG|AUS|BOL|BRA|CHI|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|SAL|URU|VEN"
If SD1->D1_TIPO == "D" .And. SF4->F4_DEVZERO == "2"
	aRet := {{0,0,0,0,0}}
ElseIf SD1->D1_TIPODOC == "64"  //remito de transferencia usar o mesmo custo do remito de saida
	aSD2:=SD2->(GetArea())
	SD2->(DbSetOrder(3))
	cFilTrf := If( Empty(xFilial("SD2")) , xFilial("SD2") , If( cPaisLoc $ cAuxPaisL , SF1->F1_FILORIG, F1_FILORIG ) )
	cForOri := RetForOri(cFilTrf)
	cItem:=StrZero(Val(SD1->D1_ITEMORI),TamSX3("D2_ITEM")[1])
	SD2->( MsSeek(cFilTrf+SD1->D1_DOC+SD1->D1_SERIE+cForOri+SD1->D1_COD+cItem) )
	aRet:={{SD2->D2_CUSTO1,SD2->D2_CUSTO2,SD2->D2_CUSTO3,SD2->D2_CUSTO4,SD2->D2_CUSTO5}}
	SD2->(RestArea(aSD2))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar o parametro MV_CPOCUS quando Remito nao-valorizado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf aCfgNf[18] .And. SD1->D1_TOTAL == 0
   If cCpoCusto == "M"	//considera o custo medio
	  aCMAtu := PegaCMAtu(SD1->D1_COD,SD1->D1_LOCAL)
   ElseIf cCpoCusto == "U"	//considera o ultimo preco de compra do produto
      aCMAtu  := Array(5)
      SB1->(DBSetOrder(1))
	  If SB1->(MsSeek(xFilial("SB1")+SD1->D1_COD))
	     aCMAtu[1]  := RetFldProd(SB1->B1_COD,"B1_UPRC")
	     aCMAtu[2]  := xMoeda(RetFldProd(SB1->B1_COD,"B1_UPRC"),1,2,dDatabase)
	     aCMAtu[3]  := xMoeda(RetFldProd(SB1->B1_COD,"B1_UPRC"),1,3,dDatabase)
	     aCMAtu[4]  := xMoeda(RetFldProd(SB1->B1_COD,"B1_UPRC"),1,4,dDatabase)
	     aCMAtu[5]  := xMoeda(RetFldProd(SB1->B1_COD,"B1_UPRC"),1,5,dDatabase)
	  EndIf
   EndIf
   If Len(aCMAtu) == 0
	  aRet := {{0,0,0,0,0}}
   Else
      aRet := Array(1,5)
	  For nX := 1 to 5
         aRet[1][nX]  := (aCMAtu[nX]*SD1->D1_QUANT)
	  Next nX
   EndIf
Else
	If cPaisLoc == "RUS"
		nMoedaBkp := Iif(Type("nMoedaNF")=="U",1,nMoedaNF)
		nMoedaNF:=1
	Endif
	aRet := RetCusEnt(aDupl,aCusto,cTipo)
	If cPaisLoc == "RUS"
		nMoedaNF := nMoedaBkp
	EndIf
	If SF4->F4_AGREG == "N"
		For nX := 1 to Len(aRet[1])
			aRet[1][nX] := If(aRet[1][nX]>0,aRet[1][nX],0)
		Next nX
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ LOCXPE(68)-Ponto de entrada utilizado para manipular os valores |
//|            do custo de entrada nas 5 moedas.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPe	:= LOCXPE(68)
If !Empty(cPe)
	uRet := ExecBlock(cPE,.F.,.F.,{aRet})
	If Valtype(uRet) == "A" .And. Len(uRet) > 0
		For nX := 1 To Len(uRet)
			For nZ:=1 To 5
				If Valtype(uRet[nX,nZ]) != "N"	//Uso o array original se retorno nao for numerico
					lCustPad := .F.
					Exit
				EndIf
			Next nZ
		Next nX
		If lCustPad
			aRet := aClone(uRet)
		EndIf
	EndIf
EndIf

Return aRet[1]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCXATUMOEDA ºAutor  ³Paulo Eduardo       º Data ³  25/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para limpar aCols caso a moeda seja modificada apos     º±±
±±º          ³importacao ou digitacao de um item.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LocxAtuMoeda(aHeader,aCols,lRefAnt)
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Pos. 1 Zera Dig. Cliente, Pos. 2 Zera Dig. Forn.(MV_ZERADIG)                    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cZerar 	:= SuperGetMV("MV_ZERADIG")
Local cVarCont	:= Right(aCfgNF[5],2)+"_ITEM"   // aCfgNF[SAliasCols]
Local cItem		:= ""
Local lZerar	:= .F.
Local nX		:= 0
Local lDel		:=.T.
Local nLin		:= 1
Static nMoedAnt

Default lRefAnt := .F.

If lRefAnt
	nMoedAnt := NIL //Define o valor da variavel static nMoedAnt para NIL a cada execução da rotina
	Return()
EndIf
If (aCfgNF[2]  == "SA1" .And. Right(cZerar,1) == "1") .Or.;
	   (aCfgNF[2]  == "SA2" .And. Left(cZerar,1) == "1")     // aCfgMF[ScCliFor]
	lZerar	:= (nMoedAnt <> nMoedaNF)    // verifica se alterou a moeda
	nMoedAnt := nMoedaNF
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Verifica se o acols deve ser zerado na digitacao dos doc.³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If Len(aCols) > 0 .and. !Empty(aCols[1][2]) .And. lZerar
	aCols := {}
	MaFisClear()
	aAdd(aCols,Array(Len(aHeader)+1))
	For nX := 1 to Len(aHeader)
		If Trim(aHeader[nX][2]) == cVarCont
			cVarCont := aCfgNF[5]+"->"+cVarCont  // aCfgNf[SAliasCols]
			aCols[Len(aCols)][nX] 	:= IIF(cItem<>Nil .AND. !Empty(cItem),cItem,StrZero(1,Len(&cVarCont)))
		Else//If ( aHeader[nX][10] <> "V")   // existem campos vituais que devem aparecer na tela exp. Tipo de Operacao
			aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2],.T.)
		EndIf
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
	Next nX
	oGetDados:Refresh()
    // Limpa Tela de Qtd. Total dos Produtos
    lDel := Iif(Len(oBSomaItens:AARRAY)>0,.T.,.F.)
	While lDel
		nLin:= Len(oBSomaItens:AARRAY)
		If Len(oBSomaItens:AARRAY) == 1
			oBSomaItens:AARRAY[nLin,1] := ''
			oBSomaItens:AARRAY[nLin,2] := 0
			lDel:=.F.
		Else
			Adel(oBSomaItens:AARRAY,nLin)
			ASize(oBSomaItens:AARRAY,Len(oBSomaItens:AARRAY)-1)
		EndIf
	EndDo

	nTotQtIte:= 0
	oBSomaItens:Refresh()
	ModxAtuObj()
EndIf


Return aCols
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TotalQtd  ºAutor  ³Alexandre Silva     º Data ³  20/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Adiciona o browse de contador de quantidade.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LocxGen()                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TotalQtd(oDlg,aPos)

Local oBSomaQtd 	:= 	Nil
Local aCabProd   	:= 	{RetTitle("B0_COD"),RetTitle("D1_QUANT")}
Local aLinProd		:=	{{'',0}}
Local cPictProd		:=	PesqPict("SB1","B1_COD")
Local cPictQuant	:=	PesqPict("SD1","D1_QUANT")

oBSomaQtd:= TwBrowse():New(aPos[1],aPos[2],aPos[3],aPos[4],,aCabProd,{40,40},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oBSomaQtd:SetArray(aLinProd)
oBSomaQtd:bLine := { || {Transform(aLinProd[oBSomaQtd:nAT][1],cPictProd),Transform(aLinProd[oBSomaQtd:nAT][2],cPictQuant)}}
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³CARGO e usada para controlar a exclusao da linha do acols, porque,³
  ³a funcao de exclusao executa duas vezes a mesma funcao.           ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oBSomaQtd:CARGO := .T.

Return oBSomaQtd

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuContQt ºAutor  ³Alexandre Silva     º Data ³  20/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a atualizacao do browse de contador de quantidade.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LocxGen()                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AtuContQt()
Local cPref		:= 	Right(aCfgNF[5],2)
Local nPosQtd 	:= 	aScan(aHeader,{|x| AllTrim(x[2]) == (cPref + '_QUANT')} )
Local nPosCod	:=	aScan(aHeader,{|x| AllTrim(x[2]) == (cPref + '_COD')} )
Local nIteFound :=	0
Local nNewItem	:=	0
Local nOldItem	:=	0
Local nNewQtd	:=	0
Local nOldQtd	:=	0
Local cNewPro	:=	''
Local cOldPro	:=	''
Local cMemVar	:= 	ReadVar()
Local lInclui	:=	.F.
Local lAltera	:=	.F.
Local lExclui 	:= 	.F.
Local aSB1area	:=	{}

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Verifica se alteracao esta sendo feito do campo COD,ou QUANT.³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If cMemVar == 'M->'+cPref+'_COD' .And. Type('M->'+cPref+'_COD') == "C"
	If aCols[OGETDADOS:OBROWSE:NAT,nPosCod] <> &cMemVar .And.	! aCols[OGETDADOS:OBROWSE:NAT,Len(aCols[OGETDADOS:OBROWSE:NAT])]	//Verifica se o conteudo do acols  foi alterado
		nOldItem	:= 	aScan(oBSomaItens:AARRAY,{|x| AllTrim(x[1]) == Alltrim(aCols[OGETDADOS:OBROWSE:NAT,nPosCod])})
		nNewItem	:= 	aScan(oBSomaItens:AARRAY,{|x| AllTrim(x[1]) == Alltrim(&cMemVar)})
		nOldQtd		:=	aCols[OGETDADOS:OBROWSE:NAT,nPosQtd]
		nNewQtd		:=	aCols[OGETDADOS:OBROWSE:NAT,nPosQtd]
		cOldPro		:=	aCols[OGETDADOS:OBROWSE:NAT,nPosCod]
		cNewPro		:=	&cMemVar
		If nNewItem <> 0
			lAltera		:= .T.
		Else
			aSB1area	:=	SB1->(GetArea())
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial('SB1')+cNewPro))
				lInclui		:= .T.
			EndIF
			RestArea(aSB1area)
		EndIf
		If ! aoSbx[1]:lActive .Or. ! oBSomaItens:lActive
			aoSbx[1]:Enable()
			oBSomaItens:Enable()
		EndIf
	EndIf
Else
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Se cMemVar esta em branco esta sendo chamado   a partir da funcao de³
	  ³exclusao.                                                           ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If Empty(cMemVar) .Or. (cMemVar != 'M->'+cPref+'_QUANT' .And. AtIsRotina("__MODDELOK"))
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  ³CARGO e usada para controlar a exclusao da linha do acols, porque,³
		  ³a funcao de exclusao executa duas vezes a mesma funcao.           ³
		  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If oBSomaItens:CARGO
			nIteFound := aScan(oBSomaItens:AARRAY,{|x| AllTrim(x[1]) == Alltrim(aCols[OGETDADOS:OBROWSE:NAT,nPosCod])})
			If aCols[OGETDADOS:OBROWSE:NAT,Len(aCols[OGETDADOS:OBROWSE:NAT])] //Esta retornando apos a exclusao
				nNewQtd		:= 	aCols[OGETDADOS:OBROWSE:NAT,nPosQtd]
				cNewPro     :=  aCols[OGETDADOS:OBROWSE:NAT,nPosCod]
			Else//Esta excluindo
				nOldQtd		:= 	aCols[OGETDADOS:OBROWSE:NAT,nPosQtd]
				cOldPro    	:=  aCols[OGETDADOS:OBROWSE:NAT,nPosCod]
			EndIf
			lExclui := .T.
			oBSomaItens:CARGO := .F.
		Else
			oBSomaItens:CARGO := .T.
		EndIf
	Else
		If aCols[OGETDADOS:OBROWSE:NAT,nPosQtd] <> &cMemVar .And. ! aCols[OGETDADOS:OBROWSE:NAT,Len(aCols[OGETDADOS:OBROWSE:NAT])]//Verifica se o conteudo do acols  foi alterado
			nIteFound := aScan(oBSomaItens:AARRAY,{|x| AllTrim(x[1]) == Alltrim(aCols[OGETDADOS:OBROWSE:NAT,nPosCod])})
			cOldPro := aCols[OGETDADOS:OBROWSE:NAT,nPosCod]
			If nIteFound <> 0
				nOldQtd	:= aCols[OGETDADOS:OBROWSE:NAT,nPosQtd]
				lAltera	:= .T.
	    		If cMemVar != 'M->'+cPref+'_QTSEGUM'
					nNewQtd := &cMemVar
				Else
				    // Caso fator de conversão seja ZERO, nao altera nada na qtde. acumulada
					aSB1area	:=	SB1->(GetArea())
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial('SB1')+ cOldPro )) .And. SB1->B1_CONV > 0
						nNewQtd := ConvUM(cOldPro,0,&cMemVar,1)
					Else
						lAltera := .F.
					EndIF
					RestArea(aSB1area)
				EndIf
			Else
				cNewPro := aCols[OGETDADOS:OBROWSE:NAT,nPosCod]
				lInclui	:= .T.
	    		If cMemVar != 'M->'+cPref+'_QTSEGUM'
					nNewQtd := &cMemVar
				Else
				    // Caso fator de conversão seja ZERO, nao altera nada na qtde. acumulada
					aSB1area	:=	SB1->(GetArea())
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial('SB1')+ cOldPro )) .And. SB1->B1_CONV > 0
						nNewQtd := ConvUM(cOldPro,0,&cMemVar,1)
					Else
						lInclui := .F.
					EndIF
					RestArea(aSB1area)
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Do Case
	Case lInclui
		If Len(oBSomaItens:AARRAY) == 1 .And. Empty(oBSomaItens:AARRAY[1,1])
			oBSomaItens:AARRAY[1,1] := cNewPro
			oBSomaItens:AARRAY[1,2] := nNewQtd
		Else
			AADD(oBSomaItens:AARRAY,{Alltrim(cNewPro),nNewQtd})
			If nOldItem <> 0
				oBSomaItens:AARRAY[nOldItem,2] -= aCols[OGETDADOS:OBROWSE:NAT,nPosQtd]
				If oBSomaItens:AARRAY[nOldItem,2] == 0
					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  ³Se a quantidade zerar excluo o item do array.³
					  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					Adel(oBSomaItens:AARRAY,nOldItem)
					ASize(oBSomaItens:AARRAY,Len(oBSomaItens:AARRAY)-1)
				EndIf
			EndIf
			aSort(oBSomaItens:AARRAY,,,{|cItemX,cItemY| cItemX[1] < cItemY[1]})
		EndIf
	Case lAltera
		If nNewItem <> nOldItem
			oBSomaItens:AARRAY[nNewItem,2] += aCols[OGETDADOS:OBROWSE:NAT,nPosQtd]
			If nOldItem <> 0
				oBSomaItens:AARRAY[nOldItem,2] -= aCols[OGETDADOS:OBROWSE:NAT,nPosQtd]
				If oBSomaItens:AARRAY[nOldItem,2] == 0
					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  ³Se a quantidade zerar excluo o item do array.³
					  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					Adel(oBSomaItens:AARRAY,nOldItem)
					ASize(oBSomaItens:AARRAY,Len(oBSomaItens:AARRAY)-1)
				EndIf
			EndIf
		Else
			If nNewQtd > 0
				oBSomaItens:AARRAY[nIteFound,2] += nNewQtd
			EndIf
			If nOldQtd > 0
				oBSomaItens:AARRAY[nIteFound,2] -= nOldQtd
			EndIf
		EndIf
	Case lExclui
		If aCols[OGETDADOS:OBROWSE:NAT,Len(aCols[OGETDADOS:OBROWSE:NAT])] //Voltando a exclusao do item
			If nIteFound <> 0
				oBSomaItens:AARRAY[nIteFound,2] += nNewQtd
			Else
				If Len(oBSomaItens:AARRAY) == 1 .And. Empty(oBSomaItens:AARRAY[1,1])
					oBSomaItens:AARRAY[1,1] := cNewPro
					oBSomaItens:AARRAY[1,2] := nNewQtd
				Else
					AADD(oBSomaItens:AARRAY,{Alltrim(cNewPro),nNewQtd})
					aSort(oBSomaItens:AARRAY,,,{|cItemX,cItemY| cItemX[1] < cItemY[1]})
				EndIf
			EndIf
		Else//Excluindo o item
			If nIteFound <> 0
				oBSomaItens:AARRAY[nIteFound,2] -= nOldQtd
				If oBSomaItens:AARRAY[nIteFound,2] == 0
					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  ³Se a quantidade zerar excluo o item do array.³
					  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	        		If Len(oBSomaItens:AARRAY) == 1
						oBSomaItens:AARRAY[nIteFound,1] := ''
						oBSomaItens:AARRAY[nIteFound,2] := 0
					Else
						Adel(oBSomaItens:AARRAY,nIteFound)
						ASize(oBSomaItens:AARRAY,Len(oBSomaItens:AARRAY)-1)
					EndIf
				EndIf
			EndIf
		EndIf
EndCase
/*Atualizacao da quantidade total*/
If lAltera .Or. lInclui .Or. lExclui
	nTotQtIte -= nOldQtd
	nTotQtIte += nNewQtd
	oBSomaItens:Refresh()
	ModxAtuObj()
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuLoadQt ºAutor  ³Alexandre Silva     º Data ³  01/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o browse de quantidade, nas chamadas de vizualiza- º±±
±±ºDesc.     ³cao das notas.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LocxGen()                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AtuLoadQt(lAtuTotal)
Local cPref		:= 	Right(aCfgNF[5],2)
Local nPosQtd 	:= 	aScan(aHeader,{|x| AllTrim(x[2]) == (cPref + '_QUANT')} )
Local nPosCod	:=	aScan(aHeader,{|x| AllTrim(x[2]) == (cPref + '_COD')} )
Local nItem		:=	0
Local nVlrTot	:=	0

DEFAULT lAtuTotal  := .F.

If Type("oBSomaItens")=="O"
    If lAtuTotal
       For nItem := 1 to Len(oBSomaItens:AARRAY)
          oBSomaItens:AARRAY[nItem,2]  := 0
       Next nItem
    EndIf
	For nItem := 1 to Len(aCols)
	    If !aCols[nItem][Len(aCols[nItem])]
		   nIteFound := aScan(oBSomaItens:AARRAY,{|x| AllTrim(x[1]) == Alltrim(aCols[nItem,nPosCod])})
		   If nIteFound <> 0
			  oBSomaItens:AARRAY[nIteFound,2] +=	aCols[nItem,nPosQtd]
		   Else
	   		  If Len(oBSomaItens:AARRAY) == 1 .And. Empty(oBSomaItens:AARRAY[1,1])
				 oBSomaItens:AARRAY[1,1] += aCols[nItem,nPosCod]
				 oBSomaItens:AARRAY[1,2] += aCols[nItem,nPosQtd]
			  Else
				 AADD(oBSomaItens:AARRAY,{Alltrim(aCols[nItem,nPosCod]),aCols[nItem,nPosQtd]})
				 aSort(oBSomaItens:AARRAY,,,{|cItemX,cItemY| cItemX[1] < cItemY[1]})
			  EndIf
		   EndIf
		   nVlrTot += aCols[nItem,nPosQtd]
		EndIf
	Next nItem

	nTotQtIte := nVlrTot
	oBSomaItens:Refresh()

	If ! aoSbx[1]:lActive .Or. ! oBSomaItens:lActive
		aoSbx[1]:Enable()
		oBSomaItens:Enable()
	EndIf
Endif
Return nVlrTot
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SetValItemºAutor  ³Alexandre Silva     º Data ³  26/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta o AHeader para executar uma validacao de campo via   º±±
±±ºDesc.     ³codigo.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ ExpA1 = aAlterar[1,1]:= 'Nome do campo.' 				  ³±±
±±³          ³         aAlterar[1,2]:= 'Validacao'                        ³±±
±±³          ³ ExpN1 = Onde colocar a validacao 1-Inicio,2-Final          ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Geral()                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SetValItem(aAlterar,nPos)
Local nItem		:= 0
Local nPosItem  := 0
Local cValid	:= ''
Default nPos	:= 2

For nItem := 1 to Len(aAlterar)
	cValid	 := ''
	nPosItem := aScan(aHeader,{|x| AllTrim(x[2]) == aAlterar[nItem,1]} )
	If nPosItem <> 0
		If nPos == 2
			If ! Empty(aHeader[nPosItem,6]) .And. ! Empty(aAlterar[nItem,2])
				cValid := ' .And. '
			EndIf
			cValid += Alltrim(aAlterar[nItem,2])
			aHeader[nPosItem,6]	:= Alltrim(aHeader[nPosItem,6]) + cValid
		Else
			cValid := Alltrim(aAlterar[nItem,2])
			If ! Empty(aHeader[nPosItem,6]) .And. ! Empty(aAlterar[nItem,2])
				cValid += ' .And. '
			EndIf
			aHeader[nPosItem,6]	:=  cValid  + Alltrim(aHeader[nPosItem,6])
		EndIf
	EndIf
Next nItem

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LxN466ForF6 ³ Autor ³ Gilson da Silva     ³ Data ³07.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de importacao de Nota Fiscal de Entrada/Saida para o  ³±±
±±³			 | rateio do custo dos produtos na emissao da Nota de Debito  ³±±
±±³			 | e Credito                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³LxN466ForF6()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA466N                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxN466ForF6(nTipo)
Local aRecs    		:= {}
Local aRet     		:= {}
Local aAreaSD1 		:= SD1->(GetArea())
Local aAreaSD2 		:= SD2->(GetArea())
Local nX            := 0
Local nY		    := 0
Local nSF1			:= 0
Local cWhile 		:= ""
Local cCondicao		:= ""
Local cQuery    	:= ""
Local aCposF4		:= {}
Local lQuery 		:= .F.
Local aStruSD1		:= {}
Local cAliasSD1		:= "SD1"
Local aStruSD2		:= {}
Local cAliasSD2		:= "SD2"
Local nUsado		:= Len(aHeader)
Local nVlrTotal		:= 0
Local nQuant 			:= 0
Local nValTotal		:= 0
Local nPProduto     := 0
Local nPLocal	    := 0
Local nPTes    	    := 0
Local nCfo          := 0
Local nPSegum 	    := 0
Local nPConta 		:= 0
Local nPItemCta     := 0
Local nPCCusto      := 0
Local nPPeso        := 0
Local nPUM	        := 0
Local nPTotal    	:= 0
Local nPVlUnit  	:= 0
Local nPItem        := 0
Local nPNfOrig      := 0
Local nPSeriOri     := 0
Local nPItemOri     := 0
Local nPLote 		:= 0
Local nPSubLote     := 0
Local nPDtLote      := 0
Local nPLocaliz     := 0
Local cItem	   	    := StrZero(0,TamSX3('D1_ITEM')[1])
Local nDifTotal		:= 0
Local nDecs			:= MsDecimais(MAFISRET(,'NF_MOEDA'))
Local cPerg			:= "MT466E"+Space(Len(SX1->X1_GRUPO)-6)
Local cPe			:= LocxPE(45)
Local cPe54			:= LocxPE(54)
Local cOldFilter    := ' '
Local cAlias		:= ' '
Local nIndex        := 0
Local lPerg			:= .F.
Local lPE66         := .F.
Local aColsBkp      := aCols
Local cPe74			:= LocxPE(74)
Local lAltProv	 	:= .F.
Local nPProvEn		:= 0
Local nClVal		:= 0
Local nTAFS_EDT	:= TamSx3("AFS_EDT")[1]
Local cFilSD1	:= xFilial("SD1")
Local cFilSF4	:= xFilial("SF4")
local cFilAFN	:= xFilial("AFN")
Local nFdesc		:= 0
Local nTotalM		:= 0
Local nBaseImpM		:= 0
Local nValImpM		:= 0
Local nValBrutM		:= 0
Local nDescri		:= 0
Local aAreaSF4		:= SF4->(GetArea())
Local aVatVal		:= {}
Local lNotAjus      := cPaisLoc == "COL" .AND. funname() == "MATA466N" .AND. FINDFUNCTION( "lxObtnFltr" ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_IMPPMS utiizado para Importar PMS amarrado a uma Factura de Entrada,          ³
//³               funciona se o parametro mv_par07(Agrupa produtos)=="NAO"           ³
//³  												 .T.-Ligado / .F.-Desligado"     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lMV_IMPPMS:= SuperGetMv("MV_IMPPMS",.F.,.F.)
#IFDEF TOP
	lQuery	:=	TcSrvType()<>"AS/400"
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se os campos de cabeçalho obrigatorios  ³
//³para o calculo de impostos  estão preenchidos.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->(DBSetOrder(2))
If  (StrZero(nTipo,2) $ '06/07/22')    // NCP / NDI / Not ajus NCP
	If Empty(M->F2_CLIENTE).Or.Empty(M->F2_LOJA).Or. Empty(M->F2_DOC).Or. Iif(cPaisLoc=="ARG",Empty(M->F2_SERIE),.F.)
		Return .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   01 -  Valor da nota        mv_par01            ³
	//³   02 -  Fornecedor/Cliente   mv_par02            ³
	//³   03 -  Loja                 mv_par03            ³
	//³   04 -  TES                  mv_par04            ³
	//³   05 -  Data Inicial         mv_par05            ³
	//³   06 -  Data Final           mv_par06            ³
	//³   07 -  Aglutina produtos    mv_par07 Sim x Nao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validar o TES digitado nas perguntas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !lPerg
		If cPaisLoc == "RUS"
			SetMVValue(cPerg,"MV_PAR02",MafisRet(,"NF_CODCLIFOR"))
			SetMVValue(cPerg,"MV_PAR03",MafisRet(,"NF_LOJA"))
			SetMVValue(cPerg,"MV_PAR04","")
		EndIf
		lPerg	:=	Pergunte(cPerg,.T.)
		If !lPerg
			Return
		ElseIf cPaisLoc <> "RUS"
			If mv_par04 > '500'
				SF4->(DbSetOrder(1))
				SF4->(MsSeek(cFilSF4+mv_par04))
				If SF4->F4_ESTOQUE <> "S" .Or. ( SF4->F4_QTDZERO <> "1" )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de Entrada para permitir outros tipos de TES  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cPE := LOCXPE(66)
					If !Empty(cPE)
						lPE66 := ExecBlock(cPE,.F.,.F.,{mv_par04})
						If ValType(lPE66)<>"L"
							lPE66:= .F.
						EndIf
					EndIf

					If !lPE66 .AND. !Empty(cPE)
					    //"Atenção"###"O TES selecionado nao e valido (O TES deve atualizar STOCK e permitir quantidade zero)."
					    //"Item Ped"
						Aviso(STR0033,STR0034, {STR0035},2)
						lPerg	:=	.F.
					EndIf

					cPe:=""
				Endif
			Else
			    //"Atenção"###"O sentido do movimento do TES selecionado nao e valido para o tipo de documento digitado"
			    //"Item Ped"
				Aviso(STR0033,STR0036, {STR0035},2)
				lPerg	:=	.F.
			Endif
		Endif
	Enddo

	SX3->(DbSetOrder(1))
	SX3->(DbSeek("SF1"))
	While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == "SF1"
		If SX3->X3_BROWSE == "S" .And. cNivel >= SX3->X3_NIVEL
			AAdd(aCposF4,SX3->X3_CAMPO)
		Endif
		SX3->(DbSkip())
	Enddo

	If cPaisloc <> "RUS"
		cCondicao 	+= "DTOS(F1_DTDIGIT)>='"+DTOS(mv_par05)+"'.AND."
		cCondicao 	+=	"DTOS(F1_DTDIGIT)<='"+DTOS(mv_par06)+"'.AND."
	Else
		cCondicao 	+= "DTOS(F1_EMISSAO)>='"+DTOS(mv_par05)+"'.AND."
		cCondicao 	+=	"DTOS(F1_EMISSAO)<='"+DTOS(mv_par06)+"'.AND."
		cCondicao 	+=	"DTOS(F1_EMISSAO)<='"+DTOS(M->F2_EMISSAO)+"'.And."
	EndIf
	cCondicao	+= "F1_TIPO=='N'"
	If lNotAjus  // Nota Ajuste NCP
		cCondicao += lxObtnFltr(nTipo, .F.)
	EndIf
	cSeek			:=	"xFilial('SF1')"
	cWhile 		:=	"!EOF() .And. F1_FILIAL== '" + xFilial("SF1")+"'"
	If !Empty(mv_par02).And.!Empty(mv_par03)
		cWhile	+= " .And. F1_FORNECE=='"+mv_par02+"'.AND.F1_LOJA=='"+mv_par03+"'"
		cSeek		+= "+'"+mv_par02+"'+'"+mv_par03+"'"
	EndIf

	If cPaisLoc == "RUS"
		aRet 	:= LocxF4("SF1",2,cWhile,cSeek,aCposF4,,'Facturas originales',cCondicao,.T.,,,,,,,,.T.)  // Retorna os Recnos das linhas selecionadas
	Else
		aRet 	:= LocxF4("SF1",2,cWhile,cSeek,aCposF4,,'Facturas originales',cCondicao,.T.)  // Retorna os Recnos das linhas selecionadas
	EndIf

	If ValType(aRet)=="A" .And. Len(aRet)==3
		aRecs := aRet[3]
	EndIf

	If ValType(aRecs)=="A" .And. ValType(aRecs)=="A" .And. Len(aRecs) > 0

		nPItem   :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_ITEM'})
		nPProduto:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_COD'})
		nPLocal	:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_LOCAL'})
		nPTes    :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_TES'})
		nCfo    :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_CF'})
		nPSegum  :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_SEGUM'})
		nPConta  :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_CONTA'})
		nPItemCta:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_ITEMCC'})
		nPCCusto :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_CCUSTO'})
		nPPeso	:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_PESO'})
		nQuant   :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_QUANT'})
		nPUM     :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_UM'})
		nPTotal	:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_TOTAL'})
		nPVlUnit :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_PRCVEN'})
		nPNfOri  :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_NFORI'})
		nPSeriOri:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_SERIORI'})
		nPItemOri:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_ITEMORI'})
		nPLote   :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_LOTECTL'})
		nPSubLote:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_NUMLOTE'})
		nPDtLote :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_DTVALID'})
		nPProvEn := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_PROVENT'})
		nClVal	 := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_CLVL'})
		If cPaisLoc == "RUS"
			nFdesc		:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_FDESC'})
			nDescri		:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_DESCRI'})
			nTotalM		:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_TOTALM'})
			nBaseImpM	:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_BSIMP1M'})
			nVaLImpM	:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_VLIMP1M'})
			nValBrutM	:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'D2_VLBRUTM'})
		EndIf
		aCols	 :=	{}
		For nSF1:=1 To Len(aRecs)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica os itens da nota de origem                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF1->(MsGoto(aRecs[nSF1]))
			dbSelectArea("SD1")
			dbSetOrder(1)
			If Empty(aStruSD1)
				aStruSD1 := SD1->(dbStruct())
			EndIf
			If lQuery .And. aScan(aStruSD1,{|x| x[2]=="M"})==0
				cAliasSD1 := "SD1"
				cQuery := "SELECT * "
				cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
				cQuery += "WHERE "
				cQuery += "SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
				cQuery += "SD1.D1_DOC='"+SF1->F1_DOC+"' AND "
				cQuery += "SD1.D1_SERIE='"+SF1->F1_SERIE+"' AND "
				cQuery += "SD1.D1_FORNECE='"+SF1->F1_FORNECE+"' AND "
				cQuery += "SD1.D1_LOJA='"+SF1->F1_LOJA+"' AND "
				cQuery += "SD1.D1_FORMUL='"+SF1->F1_FORMUL+"' AND "
				cQuery += "SD1.D_E_L_E_T_=' ' "
				cQuery += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
				cQuery := ChangeQuery(cQuery)

				dbSelectArea("SD1")
				dbCloseArea()
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
				For nX := 1 To Len(aStruSD1)
					If aStruSD1[nX][2] <> "C"
						TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
					EndIf
				Next nX
			Else
				MsSeek(cFilSD1+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
			EndIf
			While !Eof() .And. (cAliasSD1)->D1_FILIAL  == cFilSD1  .And.;
								(cAliasSD1)->D1_DOC 	== SF1->F1_DOC 		.And.;
								(cAliasSD1)->D1_SERIE 	== SF1->F1_SERIE 	.And.;
								(cAliasSD1)->D1_FORNECE	== SF1->F1_FORNECE 	.And.;
								(cAliasSD1)->D1_LOJA 	== SF1->F1_LOJA

				If SF1->F1_FORMUL==(cAliasSD1)->D1_FORMUL .And. ;
					( cPaisLoc == "BOL" .Or. Empty((cAliasSD1)->D1_ORIGLAN) .Or. (cAliasSD1)->D1_ORIGLAN $"FD|F | D" )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se deve aglutinar os itens da nota fiscal de entrada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If mv_par07 <> 1
						nX := 0
					Else
						nX	:= aScan(aCols, { |x| x[nPProduto] == (cAliasSD1)->D1_COD .And.;
						x[nPLocal] == (cAliasSD1)->D1_LOCAL  })
					EndIf
					If nX == 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Faz a montagem de uma linha em branco no aCols.              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Aadd(aCols,	Array(nUsado+1))
						nX	:= Len(aCols)
						For nY := 1 to Len(aHeader)
							aCols[nX][nY] := CriaVar(aHeader[nY][2])
						Next nY
						aCols[nX][nUsado+1] := .F.
						If nPItem > 0
							cItem	:=	Soma1(cItem)
							If nPItem 	<> 0	;	aCols[nX,nPItem]  := cItem	;	EndIf
						Endif
					EndIf
					If cPaisLoc == "RUS" .AND. (Empty(cCondicao) .Or. RUXXTS05())
						M->F2_F5QUID	:= SF1->F1_F5QUID
						M->F2_CNTID 	:= SF1->F1_CNTID
						M->F2_F5QDESC   := Iif(!EMPTY(SF1->F1_F5QUID),Posicione("F5Q",1,XFILIAL("F5Q")+SF1->F1_F5QUID,"F5Q_DESCR"),"")
						MaFisAlt("NF_MOEDA",SF1->F1_MOEDA)
						M->F2_MOEDA 	:= SF1->F1_MOEDA
						nMoedaCor		:= SF1->F1_MOEDA
						nMoedaNF		:= SF1->F1_MOEDA
						M->F2_CONUNI	:= SF1->F1_CONUNI
						MaFisAlt("NF_TXMOEDA",SF1->F1_TXMOEDA)
						M->F2_TXMOEDA	:= SF1->F1_TXMOEDA
						cCondicao		:= SF1->F1_COND
						M->F2_DTSAIDA	:= SF1->F1_EMISSAO
						M->F2_CNORVEN	:= SF1->F1_CNORSUP
						M->F2_CNEECLI	:= SF1->F1_CNEEBUY
						M->F2_CNORCOD	:= SF1->F1_CNORCOD
						M->F2_CNORBR	:= SF1->F1_CNORBR
						M->F2_CNEECOD	:= SF1->F1_CNEECOD
						M->F2_CNEEBR	:= SF1->F1_CNEEBR
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Preenche os campos com base nas notas originais              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aCols[nX,nPProduto] 	:= (cAliasSD1)->D1_COD
					aCols[nX,nPLocal]   	:= (cAliasSD1)->D1_LOCAL
					If cPaisLoc <> "RUS"
						aCols[nX,nPTes]      	:= MV_PAR04
						aCols[nX,nCfo]      	:= POSICIONE("SF4",1, xFilial("SF4")+MV_PAR04,"F4_CF")
					Else
						SF4->(DbSetOrder(1))
						If SF4->(MsSeek(cFilSF4+(cAliasSD1)->D1_TES)) .AND. !Empty(SF4->F4_TESDV)
							aCols[nX,nPTes]     :=  SF4->F4_TESDV
							RestArea(aAreaSF4)
						EndIf
						aCols[nX,nCfo]      	:=  (cAliasSD1)->D1_CF
					EndIf

					If mv_par01 == 0
						aCols[nX,nQuant]    := (cAliasSD1)->D1_QUANT
						aCols[nX,nPVlUnit]    := (cAliasSD1)->D1_VUNIT
					Endif

					If nPSegum 	<>	0	;	aCols[nX,nPSegum]  	:= (cAliasSD1)->D1_SEGUM	; 	EndIf
					If nPConta 	>	0	;	aCols[nX,nPConta]	:= (cAliasSD1)->D1_CONTA	; 	Endif
					If nPItemCta>	0 	; 	aCols[nX,nPItemCta]	:= (cAliasSD1)->D1_ITEMCTA	; 	Endif
					If nPCCusto >	0 	; 	aCols[nX,nPCCusto] 	:= (cAliasSD1)->D1_CC 		; 	Endif
					If nPNfOri >	0 	; 	aCols[nX,nPNfOri]	:= (cAliasSD1)->D1_DOC  	; 	Endif
					If nPSeriOri >	0 	; 	aCols[nX,nPSeriOri]	:= (cAliasSD1)->D1_SERIE	; 	Endif
  					If nPItemOri >	0 	; 	aCols[nX,nPItemOri]	:= (cAliasSD1)->D1_ITEM 	; 	Endif
					If nPPeso	<>	0	;	aCols[nX,nPPeso]  	+= (cAliasSD1)->D1_PESO		; 	EndIf
					If nPLote    >	0 	; 	aCols[nX,nPLote]	:= (cAliasSD1)->D1_LOTECTL 	; 	Endif
					If nPSubLote >	0 	; 	aCols[nX,nPSubLote]	:= (cAliasSD1)->D1_NUMLOTE	; 	Endif
  					If nPDtLote  >	0 	; 	aCols[nX,nPDtLote]	:= (cAliasSD1)->D1_DTVALID 	; 	Endif
  					If nClVal  >	0 	; 	aCols[nX,nClVal]	:= (cAliasSD1)->D1_CLVL 	; 	Endif
					If cPaisLoc == "RUS"
						If nFdesc		>	0 	; 	aCols[nX,nFdesc]	:= (cAliasSD1)->D1_FDESC 	; 	Endif
						If nDescri 		>	0 	; 	aCols[nX,nDescri]	:= (cAliasSD1)->D1_DESCRI 	; 	Endif
						If nTotalM		>	0 	; 	aCols[nX,nTotalM]	:= (cAliasSD1)->D1_TOTALM 	; 	Endif
						If nBaseImpM > 0 .And. nValImpM > 0
							aAdd(aVatVal,{nX, (cAliasSD1)->D1_BSIMP1M,(cAliasSD1)->D1_VLIMP1M})
						EndIf
					EndIf
					aCols[nX,nPUM]    := (cAliasSD1)->D1_UM
					If cPaisLoc <> "RUS"
						nValTotal    += (cAliasSD1)->D1_TOTAL
						aCols[nX,nPTotal] += xMoeda((cAliasSD1)->D1_TOTAL,SF1->F1_MOEDA,MAFISRET(,'NF_MOEDA'),dDataBase,,SF1->F1_TXMOEDA,MAFISRET(,'NF_TXMOEDA'))
					Else
						aCols[nX,nPTotal] := (cAliasSD1)->D1_TOTAL
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza os acumuladores do rateio                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nVlrTotal  += xMoeda((cAliasSD1)->D1_TOTAL,SF1->F1_MOEDA,MAFISRET(,'NF_MOEDA'),dDataBase,,SF1->F1_TXMOEDA,MAFISRET(,'NF_TXMOEDA'))

					If	!Empty(cPe)
						ExecBlock(cPe,.F.,.F.)
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de Entrada p/ permitir alterar a provincia de entrega do cabecalho c/ a prov. da NF Original ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cPaisLoc == "ARG" .And. !Empty(cPe74)
						lAltProv := ExecBlock(cPE74,.F.,.F.)
						If ValType(lAltProv) <> "L"
							lAltProv := .F.
						EndIf
						If lAltProv
							M->F2_PROVENT := SF1->F1_PROVENT
							MaFisAlt("NF_PROVENT",SF1->F1_PROVENT)
							If nPProvEn > 0
								aCols[nX,nPProvEn] := (cAliasSD1)->D1_PROVENT
							EndIf
						EndIf
					EndIf

				EndIf
				dbSelectArea(cAliasSD1)
				dbSkip()
			EndDo
			If lQuery
				dbSelectArea(cAliasSD1)
				dbCloseArea()
				ChkFile("SD1")
				dbSelectArea("SD1")
			EndIf
		Next nSF1

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o rateio dos Itens da Nota                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc <> "RUS"
			For nX	:= 1 To Len(aCols)
				aCols[nX][nPTotal]	:= NoRound((aCols[nX][nPTotal]/nVlrTotal)*Iif(mv_par01 == 0,nValTotal ,mv_par01),nDecs,@nDifTotal)
				If NoRound(nDifTotal,nDecs) >= (1/(10**nDecs))
					aCols[nX][nPTotal]	+= NoRound(nDifTotal,nDecs)
					nDifTotal 				-= NoRound(nDifTotal,nDecs)
				EndIf
				If mv_par01 == 0
					aCols[nX][nPVlUnit]	:= aCols[nX][nPVlUnit]
				Else
					aCols[nX][nPVlUnit]	:= aCols[nX][nPTotal]
				Endif
			Next nX
		EndIf
		If !Empty(cPe54)
			ExecBlock(cPe54,.F.,.F.,{nTipo})
		Endif

	Endif

ElseIf (StrZero(nTipo,2)  $ '08/09/23')     // NCI/NDP / Nota ajuste NDP
	If Empty(M->F1_FORNECE).Or.Empty(M->F1_LOJA).Or. Empty(M->F1_DOC).Or. Iif(cPaisLoc=="ARG",Empty(M->F1_SERIE),.F.)
//		Aviso(STR0038,STR0075,{STR0021})				 //"ATENCAO!"###"Preencha o campo de cabecalho : "###"OK"
		Return .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   01 -  Valor da nota        mv_par01            ³
	//³   02 -  Fornecedor/Cliente   mv_par02            ³
	//³   03 -  Loja                 mv_par03            ³
	//³   04 -  TES                  mv_par04            ³
	//³   05 -  Data Inicial         mv_par05            ³
	//³   06 -  Data Final           mv_par06            ³
	//³   07 -  Aglutina produtos    mv_par07 Sim x Nao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validar o TES digitado nas perguntas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !lPerg
		If cPaisLoc == "RUS"
			SetMVValue(cPerg,"MV_PAR02",MafisRet(,"NF_CODCLIFOR"))
			SetMVValue(cPerg,"MV_PAR03",MafisRet(,"NF_LOJA"))
		EndIf
		lPerg	:=	Pergunte(cPerg,.T.)
		If !lPerg
			Return
		ElseIf cPaisLoc <> "RUS"
			If mv_par04 <= '500'
				SF4->(DbSetOrder(1))
				SF4->(MsSeek(cFilSF4+mv_par04))
				If SF4->F4_ESTOQUE <> "S" .Or. ( SF4->F4_QTDZERO <> "1" )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de Entrada para permitir outros tipos de TES  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cPE := LOCXPE(66)
					If !Empty(cPE)
						lPE66 := ExecBlock(cPE,.F.,.F.,{mv_par04})
						If ValType(lPE66)<>"L"
							lPE66:= .F.
						EndIf
					EndIf

					If !lPE66 .AND. !Empty(cPE)
					    //"Atenção"###"O TES selecionado nao e valido (O TES deve atualizar STOCK e permitir quantidade zero)."
					    //"Item Ped"
						Aviso(STR0033,STR0034, {STR0035},2)
						lPerg	:=	.F.
					EndIf
					cPe:=""
				Endif
			Else
				Aviso(STR0033,STR0036, {STR0035},2)
				lPerg	:=	.F.
			Endif
		Endif
	EndDo

	SX3->(DbSetOrder(1))
	SX3->(DbSeek("SF1"))
	While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == "SF1"
		If SX3->X3_BROWSE == "S" .And. cNivel >= SX3->X3_NIVEL
			AAdd(aCposF4,SX3->X3_CAMPO)
		Endif
		SX3->(DbSkip())
	Enddo

	cCondicao 	+= "DTOS(F1_EMISSAO)>='"+DTOS(mv_par05)+"'.AND."
	cCondicao 	+=	"DTOS(F1_EMISSAO)<='"+DTOS(mv_par06)+"'.AND."
	cCondicao	+= "F1_TIPO=='N'"
	If lNotAjus  // Nota Ajuste NDP
		cCondicao += lxObtnFltr(nTipo, .F.)
	EndIf
	If cPaisLoc == "RUS"
		cCondicao 	+=	".And. DTOS(F1_EMISSAO)<='"+DTOS(M->F1_EMISSAO)+"'"
	EndIf
	cSeek			:=	"xFilial('SF1')"
	cWhile 		:=	"!EOF() .And. F1_FILIAL== '" + xFilial("SF1")+"'"
	If !Empty(mv_par02).And.!Empty(mv_par03)
		cWhile	+= " .And. F1_FORNECE=='"+mv_par02+"'.AND. F1_LOJA=='"+mv_par03+"'"
		cSeek		+= "+'"+mv_par02+"'+'"+mv_par03+"'"
	EndIf
	cOldFilter := SF1->(DbFilter())
	If !Empty(cOldFilter)
		SF1->(DbClearFilter())
	EndIf

	If cPaisLoc == "RUS"
		aRet 	:= LocxF4("SF1",2,cWhile,cSeek,aCposF4,,'Facturas originales',cCondicao,.T.,,,,,,,,.T.)  // Retorna os Recnos das linhas selecionadas
	Else
		aRet 	:= LocxF4("SF1",2,cWhile,cSeek,aCposF4,,'Facturas originales',cCondicao,.T.)  // Retorna os Recnos das linhas selecionadas
	ENDIF

	If !Empty(cOldFilter)
      	dbSelectArea("SF1")
 		Set Filter to &cOldFilter
   	EndIf

	If ValType(aRet)=="A" .And. Len(aRet)==3
		aRecs := aRet[3]
	EndIf

	If ValType(aRecs)=="A" .And. Len(aRecs) > 0
		nPItem   :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_ITEM'})
		nPProduto:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_COD'})
		nPLocal  :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_LOCAL'})
		nPTes    :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_TES'})
		nCfo    :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_CF'})
		nPSegum  :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_SEGUM'})
		nPConta  :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_CONTA'})
		nPItemCta:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_ITEMCTA'})
		nPCCusto :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_CC'})
		nPPeso	:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_PESO'})
		nPUM     :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_UM'})
		nPTotal	:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_TOTAL'})
		nPVlUnit :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_VUNIT'})
		nPNfOri  :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_NFORI'})
		nPSeriOri:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_SERIORI'})
		nPItemOri:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_ITEMORI'})
		nPLote   :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_LOTECTL'})
		nPSubLote:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_NUMLOTE'})
		nPDtLote :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_DTVALID'})
		nPLocaliz:=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_LOCALIZ'})
		nPProvEn := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_PROVENT'})
		nClVal	 := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_CLVL'})
		If cPaisLoc == "RUS"
			nQuant   :=	Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_QUANT'})
			nFdesc := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_FDESC'})
			nDescri := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_DESCRI'})
			nTotalM := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_TOTALM'})
			nBaseImpM	:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_BSIMP1M'})
			nVaLImpM	:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_VLIMP1M'})
			nValBrutM	:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_VLBRUTM'})
		EndIf
		aCols	 :=	{}
		For nSF1:=1 To Len(aRecs)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica os itens da nota de origem                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF1->(MsGoto(aRecs[nSF1]))
			dbSelectArea("SD1")
			dbSetOrder(1)
			If Empty(aStruSD1)
				aStruSD1 := SD1->(dbStruct())
			EndIf
			If lQuery .And. aScan(aStruSD1,{|x| x[2]=="M"})==0
				cAliasSD1 := "SD1"
				cQuery := "SELECT * "
				cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
				cQuery += "WHERE "
				cQuery += "SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
				cQuery += "SD1.D1_DOC='"+SF1->F1_DOC+"' AND "
				cQuery += "SD1.D1_SERIE='"+SF1->F1_SERIE+"' AND "
				cQuery += "SD1.D1_FORNECE='"+SF1->F1_FORNECE+"' AND "
				cQuery += "SD1.D1_LOJA='"+SF1->F1_LOJA+"' AND "
				cQuery += "SD1.D1_FORMUL='"+SF1->F1_FORMUL+"' AND "
				cQuery += "SD1.D_E_L_E_T_=' ' "
				cQuery += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
				cQuery := ChangeQuery(cQuery)

				dbSelectArea("SD1")
				dbCloseArea()
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
				For nX := 1 To Len(aStruSD1)
					If aStruSD1[nX][2] <> "C"
						TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
					EndIf
				Next nX
			Else
				MsSeek(cFilSD1+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
			EndIf

			If nPItem > 0
				cItem :=strzero(0,Len(SD2->D2_ITEM))
			EndIf

			While !Eof() .And. (cAliasSD1)->D1_FILIAL  == cFilSD1 	.And.;
								(cAliasSD1)->D1_DOC 	== SF1->F1_DOC 		.And.;
								(cAliasSD1)->D1_SERIE 	== SF1->F1_SERIE 	.And.;
								(cAliasSD1)->D1_FORNECE	== SF1->F1_FORNECE 	.And.;
								(cAliasSD1)->D1_LOJA 	== SF1->F1_LOJA

				If SF1->F1_FORMUL==(cAliasSD1)->D1_FORMUL .And. ;
					( cPaisLoc == "BOL" .Or. Empty((cAliasSD1)->D1_ORIGLAN) .Or. (cAliasSD1)->D1_ORIGLAN $"FD|F | D" )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se deve aglutinar os itens da nota fiscal de entrada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If mv_par07 <> 1
						nX := 0
					Else
						nX	:= aScan(aCols, { |x| x[nPProduto] == (cAliasSD1)->D1_COD .And.;
						x[nPLocal] == (cAliasSD1)->D1_LOCAL  })
					EndIf
					If nX == 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Faz a montagem de uma linha em branco no aCols.              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Aadd(aCols,	Array(nUsado+1))
						nX	:= Len(aCols)
						For nY := 1 to Len(aHeader)
							aCols[nX][nY] := CriaVar(aHeader[nY][2])
						Next nY
						aCols[nX][nUsado+1] := .F.
						If nPItem > 0
							cItem	:=	Soma1(cItem)
							If nPItem 	<> 0	;	aCols[nX,nPItem]  := cItem	;	EndIf
						Endif
					EndIf
					If cPaisLoc == "RUS"  .AND. (Empty(cCondicao) .Or. RUXXTS05())
						M->F1_F5QUID	:= SF1->F1_F5QUID
						M->F1_CNTID 	:= SF1->F1_CNTID
						M->F1_F5QDESC   := Iif(!EMPTY(SF1->F1_F5QUID),Posicione("F5Q",1,XFILIAL("F5Q")+SF1->F1_F5QUID,"F5Q_DESCR"),"")
						MaFisAlt("NF_MOEDA",SF1->F1_MOEDA)
						M->F1_MOEDA 	:= SF1->F1_MOEDA
						nMoedaCor		:= SF1->F1_MOEDA
						nMoedaNF		:= SF1->F1_MOEDA
						M->F1_CONUNI	:= SF1->F1_CONUNI
						MaFisAlt("NF_TXMOEDA",SF1->F1_TXMOEDA)
						M->F1_TXMOEDA	:= SF1->F1_TXMOEDA
						cCondicao		:= SF1->F1_COND
						M->F1_CNORSUP	:= SF1->F1_CNORSUP
						M->F1_CNEEBUY	:= SF1->F1_CNEEBUY
						M->F1_CNORCOD	:= SF1->F1_CNORCOD
						M->F1_CNORBR	:= SF1->F1_CNORBR
						M->F1_CNEECOD	:= SF1->F1_CNEECOD
						M->F1_CNEEBR	:= SF1->F1_CNEEBR
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Preenche os campos com base nas notas originais              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aCols[nX,nPProduto] 	:= (cAliasSD1)->D1_COD
					aCols[nX,nPLocal]   	:= (cAliasSD1)->D1_LOCAL
					aCols[nX,nPTes]      	:= IIf(cPaisLoc <> "RUS",MV_PAR04, (cAliasSD1)->D1_TES)
					aCols[nX,nCfo]      	:= Iif(cPaisLoc <> "RUS",POSICIONE("SF4",1, xFilial("SF4")+MV_PAR04,"F4_CF"),(cAliasSD1)->D1_CF)

					If nPSegum 	<>	0	;	aCols[nX,nPSegum]  	:= (cAliasSD1)->D1_SEGUM	; 	EndIf
					If nPConta 	>	0	;	aCols[nX,nPConta]	:= (cAliasSD1)->D1_CONTA	; 	Endif
					If nPItemCta>	0 	; 	aCols[nX,nPItemCta]	:= (cAliasSD1)->D1_ITEMCTA	; 	Endif
					If nPCCusto >	0 	; 	aCols[nX,nPCCusto] 	:= (cAliasSD1)->D1_CC 		; 	Endif
					If nPNfOri >	0 	; 	aCols[nX,nPNfOri]	:= (cAliasSD1)->D1_DOC  	; 	Endif
					If nPSeriOri >	0 	; 	aCols[nX,nPSeriOri]	:= (cAliasSD1)->D1_SERIE	; 	Endif
	   				If nPItemOri >	0 	; 	aCols[nX,nPItemOri]	:= (cAliasSD1)->D1_ITEM 	; 	Endif
					If nPPeso	<>	0	;	aCols[nX,nPPeso]  	+= (cAliasSD1)->D1_PESO		; 	EndIf
					If nPLote    >	0 	; 	aCols[nX,nPLote]	:= (cAliasSD1)->D1_LOTECTL	; 	Endif
					If nPSubLote >	0 	; 	aCols[nX,nPSubLote]	:= (cAliasSD1)->D1_NUMLOTE	; 	Endif
   					If nPDtLote  >	0 	; 	aCols[nX,nPDtLote]	:= (cAliasSD1)->D1_DTVALID	; 	Endif
					If nPLocaliz >	0	;	aCols[nX,nPLocaliz] := (cAliasSD1)->D1_LOCALIZ	; 	EndIf
					If nClVal     >	0	;	aCols[nX,nClVal]	:= (cAliasSD1)->D1_CLVL		; 	EndIf
					If cPaisLoc == "RUS"
						If nQuant > 0 	;	aCols[nX,nQuant] 	:= (cAliasSD1)->D1_QUANT	;	EndIf
						If nPVlUnit > 0 ;	aCols[nX,nPVlUnit] 	:= (cAliasSD1)->D1_VUNIT	;	EndIf
						If nFdesc >	0	; 	aCols[nX,nFdesc]	:= (cAliasSD1)->D1_FDESC	; 	Endif
						If nDescri > 0 	; 	aCols[nX,nDescri]	:= (cAliasSD1)->D1_DESCRI	; 	Endif
						If nTotalM > 0	;	aCols[nX,nTotalM]	:= (cAliasSD1)->D1_TOTALM	; 	EndIf
						If nBaseImpM > 0 .And. nValImpM > 0
							aAdd(aVatVal,{nX, (cAliasSD1)->D1_BSIMP1M,(cAliasSD1)->D1_VLIMP1M})
						EndIf
					EndIf
					aCols[nX,nPUM]    := (cAliasSD1)->D1_UM
					aCols[nX,nPTotal] += xMoeda((cAliasSD1)->D1_TOTAL,SF1->F1_MOEDA,MAFISRET(,'NF_MOEDA'),dDataBase,,SF1->F1_TXMOEDA,MAFISRET(,'NF_TXMOEDA'))

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza os acumuladores do rateio                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nVlrTotal  += xMoeda((cAliasSD1)->D1_TOTAL,SF1->F1_MOEDA,MAFISRET(,'NF_MOEDA'),dDataBase,,SF1->F1_TXMOEDA,MAFISRET(,'NF_TXMOEDA'))

					If	!Empty(cPe)
						ExecBlock(cPe,.F.,.F.)
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de Entrada p/ permitir alterar a provincia de entrega do cabecalho c/ a prov. da NF Original ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cPaisLoc == "ARG" .And. !Empty(cPe74)
						lAltProv := ExecBlock(cPE74,.F.,.F.)
						If ValType(lAltProv) <> "L"
							lAltProv := .F.
						EndIf
						If lAltProv
							M->F1_PROVENT := SF1->F1_PROVENT
							MaFisAlt("NF_PROVENT",SF1->F1_PROVENT)
							If nPProvEn > 0
								aCols[nX,nPProvEn] := (cAliasSD1)->D1_PROVENT
							EndIf
						EndIf
					EndIf

				    If lMV_IMPPMS .And. mv_par07==2
					    aRatDevAFS:={}
						dbSelectArea("AFN")
						dbSetOrder(2) //AFN_FILIAL+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM+AFN_PROJET+AFN_REVISA+AFN_TAREFA
						If DbSeek(cFilAFN+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM))
							While !EOF() .AND. (SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM))==(AFN->(AFN_DOC+AFN_SERIE+AFN_FORNECE+AFN_LOJA+AFN_ITEM))
								Aadd(aRatDevAFS, {AFN->AFN_PROJET,AFN->AFN_TAREFA,AFN->AFN_QUANT,Space(nTAFS_EDT),AFN->AFN_REVISA,0,AFN->AFN_ESTOQU,.F. })
								AFN->( dbSkip() )
							EndDo
							aADD(aRatAFN,{ aCols[nX,nPItemOri],aClone(aRatDevAFS)})
						ENDIF
	   			    Endif

				EndIf
				dbSelectArea(cAliasSD1)
				dbSkip()
			EndDo
			If lQuery
				dbSelectArea(cAliasSD1)
				dbCloseArea()
				ChkFile("SD1")
				dbSelectArea("SD1")
			EndIf
		Next nSF1

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o rateio dos Itens da Nota                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc <> "RUS"
			For nX	:= 1 To Len(aCols)
				aCols[nX][nPTotal]	:= NoRound((aCols[nX][nPTotal]/nVlrTotal)*mv_par01,nDecs,@nDifTotal)
				If NoRound(nDifTotal,nDecs) >= (1/(10**nDecs))
					aCols[nX][nPTotal]	+= NoRound(nDifTotal,nDecs)
					nDifTotal 				-= NoRound(nDifTotal,nDecs)
				EndIf
				aCols[nX][nPVlUnit]	:= aCols[nX][nPTotal]
			Next nX
		EndIf
		If !Empty(cPe54)
			ExecBlock(cPe54,.F.,.F.,{nTipo})
		Endif

	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o aCols esteja vazio, restaurar o backup do aCols  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) == 0
	aCols := aColsBkp
EndIf

aRecsSF1	:=	AClone(aRecs)
If cPaisLoc <> "RUS"
	MaFisClear()
EndIf
MaColsToFis(aHeader,aCols,,"MT100",.T.)
If cPaisLoc == "RUS" .And. len(aVatVal) > 0
	For nX := 1 to len(aVatVal)
		MaFisAlt("IT_BASEIV1_C1", aVatVal[nX][2],aVatVal[nX][1])
		aCols[aVatVal[nX][1]][nBaseImpM] := aVatVal[nX][2]
		MaFisAlt("IT_VALIV1_C1", aVatVal[nX][3],aVatVal[nX][1])
		aCols[aVatVal[nX][1]][nValImpM]  := aVatVal[nX][3]
		aCols[aVatVal[nX][1]][nValBrutM]  := aVatVal[nX][2] + aVatVal[nX][3]
	Next nX
EndIf
Eval(bDoRefresh) //Atualiza o folder financeiro.
oGetDados:obrowse:refresh()

RestArea(aAreaSD1)
RestArea(aAreaSD2)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LocxMotDev³ Autor ³ Fernando Machima      ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Permite indicar o motivo da devolucao - Loc. Guatemala     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                   			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOCXNF                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocxMotDev()

Local oDlgMotivo
Local oMotivo
Local oDescMot
Local cDescMot := Space(55)
Local lRet     := .T.

DEFINE MSDIALOG oDlgMotivo FROM 200,200 TO 300,500 TITLE STR0037 PIXEL //"Motivo da Devolucao"
   @ 0.5,01 SAY OemToAnsi(STR0038) SIZE 78,17 OF oDlgMotivo //"Motivo"
   @ 1.2,01 MSGET oMotivo VAR cMotivo OF oDlgMotivo SIZE 35,08 F3 "O1";
   VALID LocxDescMot(@cDescMot,oDescMot)

   @ 1.2,05 MSGET oDescMot VAR cDescMot OF oDlgMotivo SIZE 110,08 WHEN .F.

   DEFINE SBUTTON FROM 30,40 TYPE 1 ACTION {||(lRet:=.T.,oDlgMotivo:End())} ENABLE OF oDlgMotivo
   DEFINE SBUTTON FROM 30,75 TYPE 2 ACTION {||(lRet:=.F.,oDlgMotivo:End())} ENABLE OF oDlgMotivo
ACTIVATE MSDIALOG oDlgMotivo

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LocxDescMo³ Autor ³ Fernando Machima      ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca a descricao do motivo cadastrado na tabela O1 do SX5 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LocxDescMot(ExpC1,ExpO1)                   			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - descricao do motivo                 			      ³±±
±±³          ³ ExpO1 - objeto da descricao do motivo                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOCXNF                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LocxDescMot(cDescMot,oDescMot)

Local lRet  := .T.

SX5->(DbSetOrder(1))
If lRet  := (SX5->(MsSeek(xFilial("SX5")+"O1"+cMotivo)))
   cDescMot  := X5Descri()
   oDescMot:Refresh()
Else
   cDescMot  := Space(55)
   oDescMot:Refresh()
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LocxGerNCC³ Autor ³ Fernando Machima      ³ Data ³ 10/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Nota de Credito para cancelamento da NF               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LocxGerNCC()                             			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                            			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOCXNF - Loc. Guatemala                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocxGerNCC()

Local nI
Local cTesNCC  := Space(3)
Local aRet     := {}
Local aArea    := GetArea()
Local aCab     := {}
Local aItens   := {}
Local aItensTot:= {}
Local aCfgNFSalva := {}
Local lRet     := .T.
Local cFilSF4	:= xFilial("SF4")

aCfgNFSalva	:= aClone(aCfgNF)
aCfgNF 		:= MontaCfgNf(4,aCfgNF[SaPergs],.F.)

lMsErroAuto	:=	.F.

aRet  := LocXSx5NF(,,,.T.)

If lRet  := Len(aRet) > 0
    aNumNCC  := AClone(aRet)
	aCab := {}

	AADD(aCab,{"F1_FORNECE"	,aDadosSF2[1]    })
	AADD(aCab,{"F1_LOJA"   	,aDadosSF2[2]    })
	AADD(aCab,{"F1_SERIE"  	,aRet[2]		 })
	AADD(aCab,{"F1_DOC"		,aRet[1]    	 })
	AADD(aCab,{"F1_MOEDA"	,aDadosSF2[3]    })
	AADD(aCab,{"F1_TXMOEDA"	,aDadosSF2[4]    })
	AADD(aCab,{"F1_TIPODOC"	,"04"			 })
	AADD(aCab,{"F1_COND"	,aDadosSF2[5]	 })
	For nI := 1 to Len(aDadosSD2)

	    cTESNCC  := GetMV("MV_TESTROC")
	    SF4->(DbSetOrder(1))
	    If SF4->(DbSeek(cFilSF4+aDadosSD2[nI][7]))
           cTESNCC  := IIf(!Empty(SF4->F4_TESNCC),SF4->F4_TESNCC,GetMV("MV_TESTROC"))
        EndIf
        SF4->(DbSeek(cFilSF4+cTESNCC))

	    aItens  := {}
		AADD(aItens,{"D1_COD"		,aDadosSD2[nI][1]     ,NIL})
		AADD(aItens,{"D1_UM"		,aDadosSD2[nI][2]	   ,NIL})
		AADD(aItens,{"D1_QUANT"	    ,aDadosSD2[nI][3]     ,NIL})
		AADD(aItens,{"D1_VUNIT"     ,aDadosSD2[nI][4]	   ,NIL})
		AADD(aItens,{"D1_TOTAL"	    ,aDadosSD2[nI][5]	   ,NIL})
		AADD(aItens,{"D1_TES"		,cTesNCC			   ,NIL})
		AADD(aItens,{"D1_CF"		,SF4->F4_CF			   ,NIL})
		AADD(aItens,{"D1_LOCAL"	    ,aDadosSD2[nI][6]	   ,NIL})
		AADD(aItensTot, aItens)
    Next nI

	MSExecAuto({|x,y,z| MATA465N(x,y,z)}, aCab, aItensTot, 3)
	If lMsErroAuto
	    lRet  := .F.
		DisarmTransaction()
		MostraErro()
	Endif
EndIf

If lRet
	DbSelectArea("SF1")
	DbSetOrder(1)
	If DbSeek(xFilial("SF1")+aNumNCC[1]+aNumNCC[2]+aDadosSF2[1]+aDadosSF2[2]+"D")
		RecLock("SF1",.F.)
		SF1->F1_MOTIVO  := cMotivo
		MsUnlock()
	EndIf
EndIf
aCfgNF		:=	aClone(aCfgNFSalva)

RestArea(aArea)

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LocxNumSAT³ Autor ³ Fernando Machima      ³ Data ³ 16.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao valida se o numero do documento esta homologado ³±±
±±³          ³por alguma resolucao emitida pela SAT.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1:Valida se o numero esta homologado pela SAT           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Usado em: ³LOCXNF                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LocxNumSAT(cSerieDoc,cNumDoc,lDocNCC)

Local lRet     := .T.
Local cTipoDoc := ""

//Se lDocNCC = .T. indica que foi chamado da rotina para geracao de Nota de Credito no cancelamento da NF - Loc. Guatemala
DEFAULT lDocNCC  := .F.

If aCfgNf[3]   // aCfgNf[SlFormProp]
   If lDocNCC
      cTipoDoc  := "2"
   Else
      If aCfgNF[1]==1   // aCfgNF[SnTipo]
         cTipoDoc  := "1"    //Nota Fiscal
      ElseIf aCfgNF[1]==4 .Or. aCfgNF[1]==8   // aCfgNF[SnTipo]
         cTipoDoc  := "2"    //Nota de Credito
      ElseIf aCfgNF[1]==2 .Or. aCfgNF[1]==6   // aCfgNF[SnTipo]
         cTipoDoc  := "3"    //Nota de Debito
      EndIf
   EndIf

   If !Empty(cTipoDoc) .And. !ValNumSAT(cSerieDoc,cNumDoc,cTipoDoc)
      lRet  := .F.
	  //"Atenção"###"Numeracao: "###" nao autorizada por resolucao. Entre em contato com a SAT."###"Ok"
	  Aviso(STR0033,STR0039+cNumDoc+"/"+cSerieDoc+STR0040,{STR0041})
   EndIf
EndIf

Return (lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LocxSATNCC ³ Autor ³ Fernando Machima     ³ Data ³ 03.06.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida se o proximo numero da Nota de Credito e valido pela³±±
±±³          ³ SAT antes de gerar devido ao cancelamento da NF            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOCXNF                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LocxSATNCC()

Local lRet          := .T.
Local lSeqEspecie   := SuperGetMV("MV_SEQESPE",,.F.)
Local nTamDoc	    := TamSX3("F1_DOC")[1]
Local nTamSerie	    := TamSX3("F1_SERIE")[1]
Local cSerAtu       := Space(nTamSerie)
Local cNumDoc       := Space(nTamDoc)
Local cChaveSX5     := ""

If SX5->(MsSeek(xFilial("SX5")+"AB"+"NCC"))
   cSerAtu    := Padr(X5Descri(),nTamSerie)
   cChaveSX5  := IIf(lSeqEspecie,"NCC","")+Padr(X5Descri(),nTamSerie)
EndIf

If SX5->(MsSeek(xFilial("SX5")+IIf(lSeqEspecie,"AC"+cChaveSX5,"01")))
    cNumDoc  := AllTrim(X5Descri())
EndIf

If !Empty(cNumDoc)
   lRet  := LocxNumSAT(cSerAtu,cNumDoc,.T.)
EndIf

Return (lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LxLOkSEV   ³ Autor ³ Marcelo Custodio     ³ Data ³ 07.08.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida linha da getdados que controla o conceito de        ³±±
±±³          ³ multinatureza                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOCXNF                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LxLOkSEV()

If MaFisFound("NF") .And. MaFisRet(,"NF_BASEDUP")>0
	lContSEV := MaCheckCols(aHeader,aCols,N)
EndIf

Return(lContSEV)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LxTOkSEV   ³ Autor ³ Marcelo Custodio     ³ Data ³ 07.08.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida getdados que controla o conceito de multinatureza   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOCXNF                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LxTOkSEV()

Local nX       := 0
Local nUsadoSEV:= Len(aHeader)
Local nPPerc   := aScan(aHeader,{|x| AllTrim(x[2])=="EV_PERC"})
Local nSoma    := 0

lContSEV       := iif(cPaisLoc <> "BRA",.T.,lContSEV)

If MaFisFound("NF") .And. MaFisRet(,"NF_BASEDUP")>0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a soma dos percentuais eh 100%                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aCols)
		If !aCols[nX][nUsadoSEV+1]
			If aCols[nX][nPPerc]<>0
				nSoma += aCols[nX][nPPerc]
			Else
				aCols[nX][nUsadoSEV+1] := .T.
			EndIf
		EndIf
	Next nX
	If nSoma <> 100 .And. nSoma<> 0
		Help(" ",1,"A103TOKSEV",,STR0045+TransForm(nSoma,"@E 99.99%"),4,0)
		lContSEV := .F.
	EndIf
EndIf

Return(lContSEV)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LxVldSEV   ³ Autor ³ Marcelo Custodio     ³ Data ³ 07.08.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Informa se a multinatureza esta correta                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NfTudOk                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LxVldSEV()

If !lContSEV
	Help(" ",1,"A103TOKSEV")
EndIf

Return lContSEV

/*/{Protheus.doc} VldRatC
Funcion que permite validar si se usará prorrateo por item o por titulo.
@author		Eduardo Pérez Manríquez
@since		22/06/2020
@return     lContSEV variable lógica que permite validar el prorrateo.
@version	1.0
/*/
Function VldRatC()
	lContSEV := .T.
	
	If Len(aRatCC) > 0
		if len(aRatCC[1][2]) > 0
			MsgAlert(STR0243,STR0033)//"!ATENCION","No se puede activar prorrateo por titulo porque ya se cuenta activo el prorrateo por item, informar Rat. C.Costo = 2 ""
			lContSEV := .F.
		Endif
	EndIf
	
	if lContSEV
		lContSEV := MulNatCC()
	Endif

Return lContSEV

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCXPE    ºAutor  ³Bruno Sobieski      ºFecha ³  06/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define o nome do ponto de entrada que devera ser executado  º±±
±±º          ³em cada ponto.                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocXPE(nPE,cNomePE)
Local cPE		:=	""
Default cNomePE := ""

If Type("aPE")#"U"
	cNomePE	:=	aPE[nPE][1]
	If !Empty(aPE[nPE][1]) .AND. ExistBlock(aPE[nPE][1])
		cPE	:=	aPE[nPE][1]
	ElseIf ValType(aPE[nPE][2]) <> "U" .AND. ExistBlock(aPE[nPE][2])
		cPE	:=	aPE[nPE][2]
	Endif
EndIf

Return	cPE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCXPET   ºAutor  ³Carlos A. Gomes Jr. ºFecha ³  07/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define o nome do ponto de entrada que devera ser executado  º±±
±±º          ³em cada ponto. Para Template.                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocXPET(nPE)
Local cPEt	:=	""
Return	cPEt

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VLDF2LOJ  ºAutor  ³Luis Gustavo        º Data ³  09/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe Cliente/Loja ou Fornecedor/Loja         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                 	      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldF2Loj()

Local cFuncName	:= Alltrim(FunName())
Local lRet		:= .T.

Do Case
	Case cFuncName == 'MATA467N'
		Pergunte("MT467N",.F.)
		If MV_PAR01 == 1 .Or. (cPaisLoc $ "EQU|AUS|MEX|PER" .And. (MV_PAR01 == 3 .Or. MV_PAR01 == 4))	// Normal ou se for EQU -> Nota de Venta/ AUS -> RCTI
			lRet := ExistCpo("SA1",M->F2_CLIENTE+M->F2_LOJA)
		Else 				// Beneficiamento
			lRet := ExistCpo("SA2",M->F2_CLIENTE+M->F2_LOJA)
		EndIf
	Case cFuncName == 'MATA465N'
		Pergunte("MT465N",.F.) // SE FOR NDC OU NCE
		If  (MV_PAR01 == 1 .And. MV_PAR02 == 1) .OR. (MV_PAR01 == 2 .And. MV_PAR02 == 2)
			lRet := ExistCpo("SA1",M->F2_CLIENTE+M->F2_LOJA)
		Endif
	Case cFuncName == 'MATA462N'
		Pergunte("MT467N",.F.)
		If MV_PAR01 == 1	// Normal
			lRet := ExistCpo("SA1",M->F2_CLIENTE+M->F2_LOJA)
		Else 				// Beneficiamento
			lRet := ExistCpo("SA2",M->F2_CLIENTE+M->F2_LOJA)
		EndIf
	Case cFuncName == 'MATA102DN' // Remito devolucao
			 lRet := ExistCpo("SA2",M->F2_CLIENTE+M->F2_LOJA)
	Case cFuncName == 'MATA466N'
		Pergunte("MT466N",.F.) // Se for NCI ou NCP
		If (MV_PAR01 == 1 .And. MV_PAR02 == 1) .OR. (MV_PAR01 == 2 .And. MV_PAR02 == 2)
			 lRet := ExistCpo("SA2",M->F2_CLIENTE+M->F2_LOJA)
		Endif
EndCase

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a101NAdianºAutor  ³GDP Materiais       ºFecha ³ 08/09/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a regra em relacao ao Pedido de Compras quando utiliº±±
±±º          ³-za condicao de pagamento com Adiantamento.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a101NAdian(aPedidos, cCondicao, aRecs,  cFornec, cLoja, nValTot)
Local lRet := .T.
Local aAreaSC7 := SC7->(GetArea())
Local nValAdt  := 0 // Valor total do Adiantamento
Local aVenc	   := {} // Array de parcelas
Local nI 	   := 0
Default aPedidos := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O processo de Recebimento Antecipado estará disponivel ³
//³apenas para TOP no Financeiro.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If A120UsaAdi(cCondicao)
	DbSelectArea("SC7")
	DbSetOrder(1)
	For nI:= 1 to Len(aRecs)
		SC7->(MsGoto(aRecs[nI]))
		nValTot += SC7->C7_VALFRE+SC7->C7_SEGURO+SC7->C7_DESPESA
	Next
	nValTot := Iif(cPaisLoc$'COL|EQU',ValDuplic(nValTot),nValTot)
	aVenc := Condicao(nValTot,cCondicao,0.00,dDataBase,0.00,{},,0)
	If Len(aVenc) > 0
		// aVenc[1,2] - Valor da primeira parcela
		// Carrega array de Adiantamentos relacionados ao pedido
		aPedidos := FPedAdtPed("P", aPedidos, .F. )
		For nI := 1 To Len(aPedidos)
			nValAdt += aPedidos[nI][3]
		Next nI

		If aVenc[1,2] > nValAdt
			Aviso("A101NADIAN",STR0046,{"Ok"},2) // "O Documento não poderá ser Incluso pois, o montante do Adiantamento é inferior ao valor da primeira parcela do titulo."
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea(aAreaSC7)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CtrFolios ³ Autor ³ Ivan Haponczuk      ³ Data ³ 10.11.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se a serie e numero da nota esta cadastrada dentro   ³±±
±±³          ³ do range e esta ativa no controle de folios.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aFilAnt  - Filial de usada.                                 ³±±
±±³          ³ cSerie   - Serie da nota.                                   ³±±
±±³          ³ cEspecie - Especie da nota.                                 ³±±
±±³          ³ cnFiscal - Numero da nota.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. - se for valido, .F. - caso contrario                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³ Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 29.07.10 ³ Thiago Bizan  ³ Os tipos de documentos aceitos pela         ³±±
±±³          ³               ³ legislacao venezuelana nao podem ser fixos. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fiscal - Controle de Folios                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtrFolios(cFilAnt,cSerie,cEspecie,cnFiscal)

	Local lRet		:= .T.
	Local alAreaX	:= {}
	Local clEspecie := SuperGetMv("MV_ESPCF",.F.,"")
	Local alEspecie	:= {}
	Local nI		:= 0
	cEspecie := Alltrim(cEspecie)

	If cPaisLoc == "PAR"
		Return CtrFolPar(cFilAnt,cSerie,cEspecie,cnFiscal)
	EndIf

	If !Empty(cEspecie) .And. !Empty(cnFiscal)

		If Upper(Alltrim(FunName())) $ "MATA465N/MATA466N/MATA467N"
			If cPaisLoc == "VEN"
				If cEspecie $ clEspecie
					alEspecie := Separa(clEspecie,";")
					For nI := 1 to Len(alEspecie)
						If cEspecie == alEspecie[nI]
							cEspecie := nI
							Exit
						EndIF
					Next nI

					alAreaX := GetArea()

					dbSelectArea("SFP")
					SFP->(dbGoTop())
					dbSetOrder(5)
					If DbSeek(xFilial("SFP")+cFilAnt+SubStr(cSerie,1,3)+Alltrim(str(cEspecie)))
						lRet := .F.
						While AllTrim(SFP->FP_FILIAL+SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_ESPECIE) == AllTrim(xFilial("SFP")+cFilAnt+SubStr(cSerie,1,3)+Alltrim(str(cEspecie)))
							If SFP->FP_NUMINI <= cnFiscal .and. SFP->FP_NUMFIM >= cnFiscal
								lRet := .T.
							 	Exit
							Else
								lRet := .F.
							EndIf
							SFP->(dbSkip())
						EndDo
				 		If lRet
							If SFP->FP_ATIVO == "1"
								If dDataBase <= SFP->FP_DTAVAL
									lRet := .T.
								Else
									Aviso(STR0033,STR0047,{STR0041}) //"ATENCAO"###"A data de emissão deste documento está fora do limite cadastrado no controle de formulários. Portanto, não poderá ser utilizada para a emissão do documento fiscal."###"OK"
									lRet := .F.
								EndIf
							Else
								Aviso(STR0033,STR0048,{STR0041}) //"ATENCAO"###"Este range está cadastrado porém não está ativo."###"OK"
								lRet := .F.
							EndIf
						Else
							Aviso(STR0033,STR0049,{STR0041}) //"ATENCAO"###"Não existe este número cadastrado em nenhum range com esta série ou espécie."###"OK"
						EndIf
					Else
						Aviso(STR0033,STR0050,{STR0041}) //"ATENCAO"###"Esta série ou espécie não está cadastrada no controle de  formulários. Portanto, não poderá ser utilizada para a emissão do documento fiscal."###"OK"
						lRet := .F.
					EndIf
					SFP->(dbCloseArea())
					RestArea(alAreaX)
				EndIF
			Else
				If cEspecie $ "NF/NCC/NDC/NDI/NCI"

						Do Case
							Case cEspecie == "NF"
								cEspecie := "1"
							Case cEspecie == "NCC"
								cEspecie := "2"
							Case cEspecie == "NDC"
								cEspecie := "3"
							Case cEspecie == "NDI"
								cEspecie := "4"
							Case cEspecie == "NCI"
								cEspecie := "5"
						EndCase


					alAreaX := GetArea()

					dbSelectArea("SFP")
					SFP->(dbGoTop())
					dbSetOrder(5)
					If DbSeek(xFilial("SFP")+cFilAnt+SubStr(cSerie,1,3)+cEspecie)
						lRet := .F.
						While AllTrim(SFP->FP_FILIAL+SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_ESPECIE) == AllTrim(xFilial("SFP")+cFilAnt+SubStr(cSerie,1,3)+cEspecie)

								If SFP->FP_NUMINI <= cnFiscal .and. SFP->FP_NUMFIM >= cnFiscal
									lRet := .T.
							 		Exit
								Else
									lRet := .F.
								EndIf
								SFP->(dbSkip())

						EndDo
				 		If lRet
							If SFP->FP_ATIVO == "1"
								If dDataBase <= SFP->FP_DTAVAL
									lRet := .T.
								Else
									Aviso(STR0033,STR0047,{STR0041}) //"ATENCAO"###"A data de emissão deste documento está fora do limite cadastrado no controle de formulários. Portanto, não poderá ser utilizada para a emissão do documento fiscal."###"OK"
									lRet := .F.
								EndIf
							Else
								Aviso(STR0033,STR0048,{STR0041}) //"ATENCAO"###"Este range está cadastrado porém não está ativo."###"OK"
								lRet := .F.
							EndIf
						Else
							Aviso(STR0033,STR0049,{STR0041}) //"ATENCAO"###"Não existe este número cadastrado em nenhum range com esta série ou espécie."###"OK"
						EndIf
					Else
						Aviso(STR0033,STR0050,{STR0041}) //"ATENCAO"###"Esta série ou espécie não está cadastrada no controle de  formulários. Portanto, não poderá ser utilizada para a emissão do documento fiscal."###"OK"
						lRet := .F.
					EndIf

					SFP->(dbCloseArea())
					RestArea(alAreaX)
				EndIf
			EndIF
		EndIf
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValImpPer ºAutor  ³Ivan Haponczuk      º Data ³  10/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o produto pode ser adicionado a nota de acordo   º±±
±±º          ³ com a legislacao peruana.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PERU                                                	      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// aItens[]
// [x,1] = cCod. Produto;
// [x,2] = cTES;
// [x,3] = lDeletado;
Function ValImpPer(nLinha,aItens,clImp,cFunName)
Return LxVdImpPer(nLinha,aItens,clImp,cFunName)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValDuplic ºAutor  ³Bruna Zechetti      º Data ³  08/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para calcular o valor total do título para ser      º±±
±±º          ³ mandado a função de condição de pagamento (Condição).      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COLOMBIA/EQUADOR                                    	      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ValDuplic(nValor)

	If n > Len(aCols)
		n := Len(aCols)
	Endif

	If cPaisLoc == "COL"
		nValor := xValDupCol(nValor, aHeader, acols, .F.)
	ElseIf cPaisLoc=="EQU"
		nValor := xValDupEqu(aCols, nValor, N)
	EndIf

Return(nValor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aNumTRFNao³ Autor ³ Ricardo Berti         ³ Data ³ 08/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a NF existe p/ operacoes de Transferencia      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ aNumTRFNaoExiste(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpA1)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias de cabecalho de nota fiscal                  ³±±
±±³          ³ ExpC2 = Serie da NF 										  ³±±
±±³          ³ ExpC3 = Numero da nota									  ³±±
±±³          ³ ExpC4 = Cod.do cliente       	     					  ³±±
±±³          ³ ExpC5 = Loja do cliente		           					  ³±±
±±³          ³ ExpC6 = Especie da nota  	         					  ³±±
±±³          ³ ExpA1 = Array dos dados do cabecalho da nota				  ³±±
±±³          ³    [1] - campos do cabecalho								  ³±±
±±³          ³    [2] - conteudo dos campos(ou formula/Totaliz.) do cabec.³±±
±±³          ³    [3] - indica se o campo e' totalizador (Default .F.)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.(ja' existe o doc.de transf.) ou .F. (nao existe o doc.) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOCXNF                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function aNumTRFNaoExiste(cAliasC,cSerie,cNFiscal,cCliFor,cLoja,cEspecie,aCabNotaOri)
Local aArea     := getArea()
Local aFiliais  := {}
Local lRet		:= .F.
Local nPosDoc   := aScan(aCabNotaOri[1], AllTrim(PrefixoCpo(cAliasC)+"_TIPODOC"))
Local nPosEmis	:= aScan(aCabNotaOri[1], AllTrim(PrefixoCpo(cAliasC)+"_EMISSAO"))
Local nX        := 0
Local cFilSF2	:= xFilial("SF2")
Local cFilSF4	:= xFilial("SF4")
Local cFilSD2	:= xFilial("SD2")
Local lUsaNewKey:= TamSX3("F1_SERIE")[1] == 14

//Monta Array com as Filiais
DbSelectArea("SM0")
DbSetOrder(1)
DbGoTop()
Do While !Eof()
	If M0_CODFIL<>cFilSF2
    	AAdd( aFiliais, M0_CODFIL)
    EndIf
    DbSkip()
EndDo

If lUsaNewKey
	cSerie:=SerieNfId("SF1",4,"F1_SERIE",aCabNotaOri[2][nPosEmis],cEspecie,cSerie)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a numeracao do docto. de transf. nas filiais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX:=1 To Len(aFiliais)

	DbSelectArea("SF2")
	DbSetOrder(2)
	DbSeek(IIF(Empty(cFilSF2),cFilSF2,aFiliais[nX])+cCliFor+cLoja+cNFiscal+cSerie,.F.)
	If !Eof() .And. F2_TIPODOC == "54"
	    DbSelectArea("SD2")
	    DbSetOrder(3)
	    DbSeek(IIF(Empty(cFilSD2),cFilSD2,aFiliais[nX])+cNFiscal+cSerie+cCliFor+cLoja)
	    Do While !Eof();
	       .And. D2_FILIAL  = IIF(Empty(cFilSD2),cFilSD2,aFiliais[nX]) ;
	       .And. D2_DOC     = cNFiscal ;
	       .And. D2_SERIE   = cSerie ;
	       .And. D2_CLIENTE = cCliFor
	       //Verifica se a Tes e' de Transferencia
	       DbSelectArea("SF4")
	       DbSetOrder(1)
	       MsSeek(IIF(Empty(cFilSF4),cFilSF4,aFiliais[nX])+SD2->D2_TES)
	       If !Eof() .And. ((cAliasC == "SF1" .And. F4_TRANFIL == "1") .Or. (cAliasC == "SF2" ))
	           lRet:=.T.
	           Exit
	       EndIf
	       DbSelectArea("SD2")
	       DbSkip()
	    EndDo
	EndIf

	//Verifica o Tipo de Documento
	If lRet .And. nPosDoc>0 .And. Len(aCabNotaOri)>2
	    //Documento e' a Entrada da Transferencia, ignorar a consistencia
	    If (cAliasC == "SF1" .And. aCabNotaOri[2][nPosDoc]=="64")
	        lRet:= .F.
	    EndIf
	EndIf

	If lRet
		Aviso(STR0033,STR0053,{STR0041})//"ATENCION"##""Existe un documento de Transferencia con esta numeracion. ¡Numero no puede utilizarse!"##"OK"
    	Exit
	EndIf
Next nX
RestArea(aArea)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ValConcep ³ Autor ³ Marcos Kato           ³ Data ³ 20.07.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a Validacao do campo Concepto.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = campo do Concepto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 												              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ValConcept()
Local lRet:=.T.
Default n	:=0
If n>0
	If Empty(MaFisRet(N,"IT_CONCEPT"))
		lRet:=.F.
	Endif
	If !lRet
		Aviso(STR0033,STR0202,{STR0041})//"ATENCION"##"Informe el código del Concepto antes de la TES."##"OK"
	Endif
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldNFOrig ºAutor  ³Ricardo Berti       º Data ³  14/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao p/ somente haver uma nota origem informada (PERU)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF                                             	      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldNFOrig(cTipo,nI,aDadosI,nPosNFOri,nPosSerOri)
Return xNfOrigPer(cTipo,nI,aDadosI,nPosNFOri,nPosSerOri)
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FGrvSFE  ³Autor  ³ Marco Kato             ³ Data ³12/08/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava Retencao de Impostos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOpc(3-Inclui|5-Exclui)/aGrvSFE(Dados da Retencao)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Uruguay                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FGrvSFE(cOpc,aGrvSFE)
Return LxFGrvSFE(cOpc, aGrvSFE)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CheckNat	ºAutor  ³Turibio Miranda     º Data ³  24/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se utiliza Natureza no Despacho para preservar a  º±±
±±º			 ³ natureza na nota fiscal a ser gerada.					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF                                             	      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CheckNat()
//Somente verifica se for originado no despacho
If IsInCallStack("MATA143")
	If !Empty(DBB->DBB_NATURE)
		// Atualizando o array fiscal para gravar a natureza no titulo e nao consistir MV_NFENAT = T
		Mafisload("NF_NATUREZA",DBB->DBB_NATURE)
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCXLEGCOR ºAutor  ³Totvs		    	  º Data ³ 16/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adciona Status e Cor na Legenda					 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF                                             	      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocxLegCor(nTipo, cAlias, aElem)
Local aUsr:= aClone(aElem)
Local cPe := ""

If nTipo==1   // Adciona Status a Legenda - LOCXPE63
	cPe	:= LOCXPE(63)
	If !Empty(cPE)
		aUsr := ExecBlock(cPE,.F.,.F.,{aElem,cAlias})
		If ( ValType(aUsr) == "A" )
			aElem := aClone(aUsr)
		EndIf
	EndIf
EndIf

If nTipo==2  // Adciona Cores a Legenda - LOCXPE64
	cPe	:= LOCXPE(64)
	If !Empty(cPE)
		aUsr := ExecBlock(cPE,.F.,.F.,{aElem,cAlias})
		If ( ValType(aUsr) == "A" )
			aElem := aClone(aUsr)
		EndIf
	EndIf
EndIf

Return aElem

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RETVALIR  ºAutor  ³Camila Januário     º Data ³  01/05/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Busca o acumulado do imposto e o valor acumulado          º±±
±±º          ³  de retenção IRP                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Uruguai                                                    º±±
±±ºParam  	   cImp: imposto											   ±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetValIR(cImp,cTes)
Return LxRetValIR(cImp, cTes)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GravaNFGURU  ºAutor  ³ Ivan Haponczuk     º Data ³  12/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Efetua a atuaizacao de todos os arquivos que devem ser        º±±
±±º          ³  atualizados na gravacao de todos os tipos de notas fiscais.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Uruguai                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GravaNFGURU(aCfgNF, lInclui)
Return LxGrvNfUru(aCfgNF, lInclui)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PEDIDOLOCKºAutor  ³Julio Cesar Guerato º Data ³  17/06/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Bloqueia Pedidos utilizados no Acols				    	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                               		      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PedidoLock(aCpItens, aCItens)
Local nPed     := aScan(aCItens,{|x| Alltrim(x) == "D1_PEDIDO"})
Local nItPed   := aScan(aCItens,{|x| Alltrim(x) == "D1_ITEMPC"})
Local nXP      := 0
Local nBlq     := 0
Local cUnico   := ""
Local lRet     := .T.
Local aAreaAtu := GetArea()
Local cFilSC7	:= xFilial("SC7")

aRegsLock:={}

If nPed>0 .And. nItPed>0 .And. Len(aCpitens)>0

	cUnico := FWX2Unico('SC7')

   If Len(cUnico)>0
	   DbSelectArea("SC7")
	   DbSetOrder(1)
	   For nXp:=1 to Len(aCpItens)
   			If !Empty(aCpitens[nXp][nPed]) .And. !Empty(aCpitens[nXp][nItPed])
   				If DbSeek(cFilSC7+aCpitens[nXp][nPed]+aCpitens[nXp][nItPed])
					If !MultLock("SC7",{&cUnico},1,.f.,.f.)
						nBlq++
						exit
					Else
						aaDD(aRegsLock,{"SC7",Recno()})
					EndIf
   				EndIf
   			EndIf
	   Next nXp
	EndIf
EndIf

If nBlq>0
	maDestrava(aRegsLock)
EndIf

lRet:=iif(nBlq>0,.F.,.T.)
RestArea(aAreaAtu)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±³Funcao    ³Mata103N    ³ Autor ³Julio C.Guerato      ³ Data ³11.08.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Guia de Remessa					                          ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                               		      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mata103n(xAutoCab,xAutoItens,nOpcAuto,lSeek,nTipoOper)
Local nTipo		:= 0
Local nPosTipo	:= 0
Local lNfAuto 	:= ( ValType(xAutoCab) == "A"  .AND. ValType(xAutoItens) == "A" )
Local cFunName	:= IIf(Type("cFunName")=="U",Upper(Alltrim(ProcName())),cFunName)	//Funcao Origem
DEFAULT lSeek	:=	.T.

nOpcAuto := If(nOpcAuto==NIL,3,nOpcAuto)

If lNfAuto
	nPosTipo:= Ascan(xAutoCab,{|aCab| aCab[1] == "F1_TIPODOC" .OR. aCab[1] == "F2_TIPODOC"})
	nTipo	:= Val(xAutoCab[nPosTipo,2])
	If nTipo == 0
		If Pergunte("MT103N",.T.)
			If MV_PAR01 == 1
				nTipo := 65
			EndIf
		EndIf
	EndIf
Else
	If Pergunte("MT103N",.T.)
		If MV_PAR01 == 1
			nTipo := 65
		EndIf
	EndIf
EndIf

If nTipo > 0
	LocxNf(nTipo,xAutoCab,xAutoItens,nOpcAuto,cFunName,lSeek,nTipoOper)
Endif
SetKey(VK_F4	,{|| Nil })
SetKey(VK_F5	,{|| Nil })
SetKey(VK_F6	,{|| Nil })
SetKey(VK_F7	,{|| Nil })
SetKey(VK_F8	,{|| Nil })
SetKey(VK_F9	,{|| Nil })
SetKey(VK_F10	,{|| Nil })
SetKey(VK_F11	,{|| Nil })
SetKey(VK_F12	,{|| Nil })
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±³Funcao    ³Mata103CG   ³ Autor ³Julio C.Guerato      ³ Data ³16.08.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta de Guia de Remessa/Canceladas		              ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                               		      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mata103CG(xAutoCab,xAutoItens,nOpcAuto,lSeek,nTipoOper)
Local nTipo		:= 0
//Local nPosTipo	:= 0
//Local lNfAuto 	:= ( ValType(xAutoCab) == "A"  .AND. ValType(xAutoItens) == "A" )
Local cFunName	:= IIf(Type("cFunName")=="U",Upper(Alltrim(ProcName())),cFunName)	//Funcao Origem
Private aParamGer:= {}
DEFAULT lSeek	:=	.T.

nOpcAuto := If(nOpcAuto==NIL,3,nOpcAuto)


If Pergunte("MT103CG",.T.)
	nTipo := 65
	aAdd(aParamGer,MV_PAR01)
	aAdd(aParamGer,MV_PAR02)
	aAdd(aParamGer,MV_PAR03)
	aAdd(aParamGer,"F1_EMISSAO")
	aAdd(aParamGer,"F1_TIPODOC='65'")
EndIf

If nTipo > 0
	LocxNf(nTipo,xAutoCab,xAutoItens,nOpcAuto,cFunName,lSeek,nTipoOper)
Endif
SetKey(VK_F4	,{|| Nil })
SetKey(VK_F5	,{|| Nil })
SetKey(VK_F6	,{|| Nil })
SetKey(VK_F7	,{|| Nil })
SetKey(VK_F8	,{|| Nil })
SetKey(VK_F9	,{|| Nil })
SetKey(VK_F10	,{|| Nil })
SetKey(VK_F11	,{|| Nil })
SetKey(VK_F12	,{|| Nil })
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±³Funcao    ³Mata103CF   ³ Autor ³Julio C.Guerato      ³ Data ³19.08.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta de Facturas Normais / Canceladas		              ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                               		      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mata103CF(xAutoCab,xAutoItens,nOpcAuto,lSeek,nTipoOper)
Local nTipo		:= 0
//Local nPosTipo	:= 0
//Local lNfAuto 	:= ( ValType(xAutoCab) == "A"  .AND. ValType(xAutoItens) == "A" )
Local cFunName	:= IIf(Type("cFunName")=="U",Upper(Alltrim(ProcName())),cFunName)	//Funcao Origem
Private aParamGer:= {}
DEFAULT lSeek	:=	.T.

nOpcAuto := If(nOpcAuto==NIL,3,nOpcAuto)


If Pergunte("MT103CF",.T.)
	nTipo := 10
	aAdd(aParamGer,MV_PAR01)
	aAdd(aParamGer,MV_PAR02)
	aAdd(aParamGer,MV_PAR03)
	aAdd(aParamGer,"F1_EMISSAO")
	aAdd(aParamGer,"F1_TIPODOC IN('08','10','04')")
EndIf

If nTipo > 0
	LocxNf(nTipo,xAutoCab,xAutoItens,nOpcAuto,cFunName,lSeek,nTipoOper)
Endif
SetKey(VK_F4	,{|| Nil })
SetKey(VK_F5	,{|| Nil })
SetKey(VK_F6	,{|| Nil })
SetKey(VK_F7	,{|| Nil })
SetKey(VK_F8	,{|| Nil })
SetKey(VK_F9	,{|| Nil })
SetKey(VK_F10	,{|| Nil })
SetKey(VK_F11	,{|| Nil })
SetKey(VK_F12	,{|| Nil })
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CheckTable ºAutor  ³Julio C.Guerato     º Data ³ 15/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Compara Estrutura de Tabelas           	                  º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Parametros³cTabOri  = Alias Tabela Origem                              ³±±
±±³          ³cTabDest = Tabela de Destino                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. = Registro inserido ok   /  .F. = Erro ao inserir       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CheckTable(cTabOri, cTabDest)
Local lRet      := .F.
Local aArea     := GetArea()
Local aTabOri   := EstruTabela(cTabOri)
Local aTabDest  := EstruTabela(cTabDest)

lRet:=CompTabela(aTabOri, aTabDest)

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GravaTabEspelhoºAutor  ³Julio C.Guerato º Data ³ 15/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava dados em Tabela Espelho                               º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTabOri  = Alias Tabela Origem                              ³±±
±±³          ³cTabDest = Tabela de Destino                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. = Registro inserido ok   /  .F. = Erro ao inserir       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GravaTabEspelho(cTabOri, cTabDest, nRegTabOri)
Local lRet      := .F.
Local aArea     := GetArea()
Local aTabOri   := EstruTabela(cTabOri)
Local cQuery    := ""
Local cCols     := ""
Local i         := 0

For i:=1 to Len(aTabOri)
	cCols+=aTabOri[i][1]+","
Next i

cQuery := " Insert Into "+cTabDest+" ( "+cCols+" D_E_L_E_T_, R_E_C_N_O_  ) "
cQuery += " Select "+cCols+" D_E_L_E_T_, R_E_C_N_O_ "
cQuery += "   From "+RetSqlName(cTabOri)
cQuery += "  Where R_E_C_N_O_ = "+Str(nRegTabOri)

If TcSqlExec(cQuery)<0
	Hs_MsgInf(TcSqlError())
	lRet:=.F.
Else
	lRet:=.T.
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaTabEspBrowºAutor  ³Julio C.Guerato º Data ³ 16/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta visualização para MBrowse Tabela Dicionario + Espelho º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTab1   = Tabela existente SX3 	                          ³±±
±±³          ³cTab2   = Tabela espelho a existente no SX3                 ³±±
±±³          ³aCampos = Array com campos a serem visualizados pela Mbrowse³±±
±±³          ³aInd    = Array com nro de indices a serem criados          ³±±
±±³          ³cCamposAd = Campos Adicionais 						      ³±±
±±³          ³aParamGer = Tabelas a serem visualizadas			          ³±±
±±³          ³			1 -> Posicao 1 Array 					          ³±±
±±³          ³       	     1=Somente tabela existente SX3		          ³±±
±±³          ³         		 2=Somente tabela espelho			          ³±±
±±³          ³          	 3=Ambas as tabelas					          ³±±
±±³          ³          2 -> Data Inicio								  ³±±
±±³          ³          3 -> Data Fim									  ³±±
±±³          ³          4 -> Campo para Pesquisa de Data		 		  ³±±
±±³          ³          5 -> Criterio adicional para Filtro		 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cAliasFil	= Alias com a Tabela Gerada						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontaTabEspBrow(cTab1, cTab2, aCampos, aInd, cCamposAD, aParamGer)
Local aArea      := GetArea()
//Local aTabOri    := EstruTabela(cTab1)
//Local aNomInd    := {}
Local aChaveInd  := {}
Local aCamposSql := aClone(aCampos)
Local aCamposTrb := {}
Local aEstruTab  := {}
Local cAliasFil  := ""
Local cQuery     := ""
Local cQuery1    := ""
Local cQuery2    := ""
Local cCols      := ""
Local cInd       := ""
Local i          := 0
Local j          := 0

//Alias para Tabelas
cAliasTrb:=CriaTrab(Nil,.F.)
cAliasFil:=CriaTrab(Nil,.F.)

//Campos adicionais
If Len(cCamposAd)>0
	aCamposTrb:=STRTOKARR(AllTrim(cCamposAd),'+')
	For j=1 to Len(aCamposTrb)
		If aScan(aCamposSql,{|x| x[2] == aCamposTrb[j]}) == 0
			aaDD(aCamposSql,{aCamposTrb[j],aCamposTrb[j]})
		EndIf
	Next j
EndIf

//Verifica campos do indice a serem criados que nao existentem para mbrowse
//Gera array com indices que serao criados
DbSelectArea("SIX")
DbSetOrder(1)

For i=1 to Len(aInd)
	cInd:=RetAsc(Trim(Str(aInd[i])),1,.T.)
	DbSeek(cTab1+cInd)
	If !Eof()
		aCamposTrb:=STRTOKARR(AllTrim(CHAVE),'+')
		For j=1 to Len(aCamposTrb)
			If aScan(aCamposSql,{|x| x[2] == aCamposTrb[j]}) == 0
				aaDD(aCamposSql,{aCamposTrb[j],aCamposTrb[j]})
			EndIf
		Next j
		aadd(aChaveInd,Trim(CHAVE))
	EndIf
Next i

//Campos para SQL
cCols:=""
For i:=1 to Len(aCamposSQl)
	cCols+=aCamposSql[i][2]+","
Next i

//Cria tabela de trabalho
If aParamGer[1]==1 .Or. aParamGer[1]==3
	cQuery1 := "Select  "+cCols+" 0 TIPO, R_E_C_N_O_ REGISTRO"
	cQuery1 += "  From  "+RetSqlName(cTab1)
	cQuery1 += " Where D_E_L_E_T_ ='' "

	If !Empty(aParamGer[2]) .Or. !Empty(aParamGer[3])
		cQuery1 += " And "
		cQuery1 += iif(!Empty(aParamGer[2]),aParamGer[4]+">='"+DTOS(aParamGer[2])+"'","")
		cQuery1 += iif(!Empty(aParamGer[3]),iif(!Empty(aParamGer[2]), " and "," ")+aParamGer[4]+"<='"+DTOS(aParamGer[3])+"'","")
	EndIf
	cQuery1 += iif(!Empty(aParamGer[5])," and "+aParamGer[5],"")
EndIf
If aParamGer[1]==2 .Or. aParamGer[1]==3
	cQuery2 := " Select "+cCols+" 1 TIPO, R_E_C_N_O_ REGISTRO"
	cQuery2 += "   From "+RetSqlName(cTab2)+"_CANC"
	cQuery2 += " Where D_E_L_E_T_ ='' "

	If !Empty(aParamGer[2]) .Or. !Empty(aParamGer[3])
		cQuery2 += " And "
		cQuery2 += iif(!Empty(aParamGer[2]),aParamGer[4]+">='"+DTOS(aParamGer[2])+"'","")
		cQuery2 += iif(!Empty(aParamGer[3]),iif(!Empty(aParamGer[2]), " and "," ")+aParamGer[4]+"<='"+DTOS(aParamGer[3])+"'","")
	EndIf
	cQuery2 += iif(!Empty(aParamGer[5])," and "+aParamGer[5],"")
EndIf

If Len(cQuery1)>0
	cQuery:=cQuery1
EndIf
If Len(cQuery1)>0 .And. Len(cQuery2)>0
	cQuery+= " Union "
EndIf
If Len(cQuery2)>0
	cQuery+=cQuery2
EndIf

cQuery     := ChangeQuery(cQuery)
DbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery), cAliasTrb,.F., .F.)

//Equaliza Campos
DbSelectArea(cAliasTrb)
aEstruTab:=dbStruct()

oTmpTable := FWTemporaryTable():New(cAliasFil)
oTmpTable:SetFields(aEstruTab)
For i := 1 To Len(aChaveInd)
	oTmpTable:AddIndex("I"+alltrim(str(i)), STRTOKARR(AllTrim(aChaveInd[i]),'+') )
Next i
oTmpTable:Create()

(cAliasTrb)->(dbGoTop())
While !((cAliasTrb)->(EOF()))
	RecLock(cAliasFil, .T.)
	For i:= 1 To Len(aEstruTab)
		(cAliasFil)->&((aEstruTab[i,1])) := (cAliasTrb)->&((aEstruTab[i,1]))
	Next i
	(cAliasFil)->(MsUnLock())
	(cAliasTrb)->(DBSkip())
Enddo

RestArea(aArea)
Return cAliasFil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HeaderSDE    ºAutor  ³Moises Nunes     º Data ³  19/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Montagem do aHeaderSDE para utilizacao na gravacao do SDE  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HeaderSDE(aHeaderSDE)
Local aArea := GetArea()

DBSelectArea("SX3")
DBSetOrder(1)
MsSeek("SDE")
While !EOF() .AND. (X3_ARQUIVO == "SDE")
	If X3uso(X3_USADO) .AND. cNivel >= X3_NIVEL
		AADD(aHeaderSDE,{ 	Trim(x3titulo())	,X3_CAMPO	,X3_PICTURE	,;
							X3_TAMANHO			,X3_DECIMAL	,X3_VALID	,;
							X3_USADO			,X3_TIPO	,X3_ARQUIVO	,;
							X3_CONTEXT 									} )
	EndIf
	DBSkip()
End

RestArea(aArea)
Return (aHeaderSDE)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RateioRemFac ºAutor  ³Moises Nunes     º Data ³  19/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega automaticamente o rateio do item do Remito         º±±
±±º          ³                                          para a Factura    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RateioRemFac(aHeadSDE,aColsSDE,cItem,nRecSD1)
Local aArea      := GetArea()
Local nPosItem   := Ascan(aHeadSDE,{|x| AllTrim(x[2]) == "DE_ITEM"} )
Local nPosPerc   := Ascan(aHeadSDE,{|x| AllTrim(x[2]) == "DE_PERC"} )
Local nPosCC     := Ascan(aHeadSDE,{|x| AllTrim(x[2]) == "DE_CC"} )
Local nPosConta  := Ascan(aHeadSDE,{|x| AllTrim(x[2]) == "DE_CONTA"} )
Local nPosItCta  := Ascan(aHeadSDE,{|x| AllTrim(x[2]) == "DE_ITEMCTA"} )
Local nPosCLVL   := Ascan(aHeadSDE,{|x| AllTrim(x[2]) == "DE_CLVL"} )
Local nPos05DB 	 := Ascan(aHeadSDE,{|x| AllTrim(x[2]) == "DE_EC05DB"} )
Local nPos05CR   := Ascan(aHeadSDE,{|x| AllTrim(x[2]) == "DE_EC05CR"} )
Local nPosACols	 := Ascan(aColsSDE,{|x| AllTrim(x[1]) == Alltrim(cItem) } )
Local nCt        := 0
Local nLinha	 := 0
Local nTDE_ITEM := TamSX3("DE_ITEM")[1]
Local cFilSDE	:= xFilial("SDE")

SD1->(MsGoTo(nRecSD1))
dbSelectArea("SDE")
SDE->(dbSetOrder(1))//DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF+DE_ITEM
If SDE->(DbSeek(cFilSDE+SD1->( D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_ITEM ) ))
	While SD1->(!Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM)==cFilSDE+SDE->(DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF)
		If nCt == 0
			If nPosACols <= 0
				aAdd(aColsSDE,{ cItem,{} } )
				nPosACols := Len(aColsSDE)
				nCt+=1
			EndIf
		EndIF

		aAdd(aColsSDE[nPosACols][2],Array( Len(aHeadSDE) + 1 ) )
		nLinha++
		aColsSDE[nPosACols][2][nLinha][nPosItem]  := StrZero(nLinha,nTDE_ITEM)
		aColsSDE[nPosACols][2][nLinha][nPosPerc]  := SDE->DE_PERC
		aColsSDE[nPosACols][2][nLinha][nPosCC]    := SDE->DE_CC
		aColsSDE[nPosACols][2][nLinha][nPosConta] := SDE->DE_CONTA
		aColsSDE[nPosACols][2][nLinha][nPosItCta] := SDE->DE_ITEMCTA
		aColsSDE[nPosACols][2][nLinha][nPosCLVL]  := SDE->DE_CLVL
		IIf (nPos05DB > 0, aColsSDE[nPosACols][2][nLinha][nPos05DB]  := SDE->DE_EC05DB, )
		IIf (nPos05CR > 0, aColsSDE[nPosACols][2][nLinha][nPos05CR]  := SDE->DE_EC05CR, )
		aColsSDE[nPosACols][2][nLinha][Len(aHeadSDE)+1] := .F.
		SDE->(dbSkip())
	EndDo

	lLeSDE:= .F.
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LxGrvAutoCab  ³ Autor ³ Jose Lucas         ³ Data ³04/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar os campos de impostos de SF1 e SF2 à partir da gera- ³±±
±±³          ³ ção de documento por MsExecAuto.			                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LxGrvAutoCab()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LxGrvAutoCab()
Local nC := 0
Local cAlias := If(Subs(aAutoCab[1][1],1,2)=="F1","SF1","SF2")
RecLock(cAlias,.F.)
For nC := 1 To Len(aAutoCab)
   	If Subs(aAutoCab[nC][1],4,6) $ "BASIMP|ALQIMP|VALIMP|SEGURO"
		(cAlias)->(FieldPut( FieldPos( aAutoCab[nC][1]), aAutoCab[nC][2]))
   	EndIf
   	If Subs(aAutoCab[nC][1],4,5) $ "FRETE"
 		(cAlias)->(FieldPut( FieldPos( aAutoCab[nC][1]), aAutoCab[nC][2]))
 	EndIf
   	If aAutoCab[nC][1] $ "cNatureza"
   		If cAlias == "SF1"
 			SF1->F1_NATUREZ := aAutoCab[nC][2]
 		Else
 			SF2->F2_NATUREZ := aAutoCab[nc][2]
 		EndIf
 	EndIf
Next nC
MsUnLock()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LxGrvAutoItem ³ Autor ³ Jose Lucas         ³ Data ³04/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar os campos de impostos de SD1 e SD2 à partir da gera- ³±±
±±³          ³ ção de documento por MsExecAuto.			                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LxGrvAutoItem(cAlias,aRecno)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC := Alias do Item (SD1 e SD2).                          ³±±
±±³          ³ ExpA := Array com numero do registro.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LxGrvAutoItem(cAliasI,aRecnoI)
Local nC := 0
Local nZ := 0
Local nY := 0
Local nX := 0
Local nPosSD1 := 0
Local aCusto := {}
Local aCustoEnt := {}
Local aImpostos := {}
Local cTESAuto := CriaVar("D1_TES")
Local lQtdZero := .F.
Local lD1_PROVENT := (cPaisLoc $ "ARG|PER|COL|")

For nC := 1 To Len(aAutoItens)
	&(cAliasI+"->(MsGoTo("+AllTrim(Str(aRecnoI[nC,1]))+"))")
	RecLock(cAliasI,.F.)
   	For nZ := 1 To Len(aAutoItens[nC])
   		If Subs(aAutoItens[1][nZ][1],4,6) $ "BASIMP|ALQIMP|VALIMP"
   			&(aAutoItens[nC][nZ][1]) := aAutoItens[nC][nZ][2]
   		EndIf
   	Next nZ
   	If cAliasI == "SD1" .and. lD1_PROVENT
   		D1_PROVENT := SF1->F1_EST
   		//Atualizar o Custo de Entrada.
        aCusto := {{SD1->D1_TOTAL,{},0.00,"N","N","","",;
 		SD1->D1_COD,;
		SD1->D1_LOCAL,;
		SD1->D1_QUANT,;
		0.00,;
		"N",;
		0.00,;
		0.00,;
		"3",;
		"1",;
		0.00,0.00,0.00,0.00}}

		cTESAuto  := SD1->D1_TES
		aImpostos := DefImposto(cTESAuto)
		For nY:=1 to Len(aImpostos)
			nPosSD1 := SD1->(FieldPos("D1_"+Subs(aImpostos[nY][2],1,7)))
			If nPosSD1 > 0
			    If ( aImpostos[nY][5] $ "S1" )
			    	aCusto[1][1] += SD1->(FieldGet(nPosSD1))
			    ElseIf ( aImpostos[nY][5] $ "R2" )
			    	aCusto[1][1] -= SD1->(FieldGet(nPosSD1))
				EndIf
			EndIf
		Next nY
		aCustoEnt := RetCusEnt(,aCusto)
		If Len(aCustoEnt) > 0
			If (cPaisLoc $ "ARG|PER|COL|EQU" .AND. IsInCallStack("MATA143") .AND. DBB->DBB_TIPONF == "A")

				If RecLock("SD1",.F.)
					SD1->D1_CUSTO  := aCustoEnt[1,1]
					SD1->D1_CUSTO2 := aCustoEnt[1,2]
					SD1->D1_CUSTO3 := aCustoEnt[1,3]
					SD1->D1_CUSTO4 := aCustoEnt[1,4]
					SD1->D1_CUSTO5 := aCustoEnt[1,5]
					SD1->(MsUnlock())
				Endif
			Else
				For nX:=1 to Len(aCustoEnt[1]) 								// Alterado para que o aCustoEnt seja montado com o CM
					aCustoEnt[1][nX] := aCustoEnt[1][nX]/SD1->D1_QUANT		// que sera passado na funcao GravaCusD1() na sequencia
				Next nX
				aCusto := GravaCusD1(aCustoEnt[1],"N",,,lQtdZero)
			EndIf
		EndIf
	EndIf
	MsUnLock()
Next nC
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaLocAtuSF3³ Autor ³ Jose Lucas             ³ Data ³04/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Esta rotina tem como objetivo atualizar os livros fiscais à ³±±
±±³          ³ da geração dos documentos por MsExecAuto.                   ³±±
±±³          ³ Exemplo: FINA560 - Prestacao de contas do Caixinha.         ³±±
±±³          ³          FINA100 - Gastos Bancarios.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Tipo de Operacao                                     ³±±
±±³          ³        [1] Inclusao                                         ³±±
±±³          ³        [2] Exclusao                                         ³±±
±±³          ³ExpC2 : Tipo de Movimento                                    ³±±
±±³          ³        [E] Entrada                                          ³±±
±±³          ³        [S] Saida                                            ³±±
±±³          ³ExpN3 : RecNo do cabecalho da nota fiscal                    ³±±
±±³          ³ExpC4 : Alias do cabecalho da nota fiscal                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaLocAtuSF3(nCaso,cTpOper,nRecNF,cAlias,cPDV,cCNAE,cFunOrig,nCD2)

Local aSavArea	 := GetArea()
Local aAreaSF1	 := SF1->(GetArea())
Local aAreaSF2	 := SF2->(GetArea())
Local aLivro	 := {}
Local aFixos 	 := {}
Local cCFO       := ""
Local nC         := 0
Local nZ         := 0
Local cChavePesq := ""
Local cFilSF3	:= xFilial("SF3")

Local lNFEArg   := 	cAlias == "SF1" .and. cPaisLoc== "ARG"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo de Livros Fiscais (SF3)                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLivro	    := MaFisRet(,"NF_LIVRO")
aFixos		:= MatxAfixos()
lObserv		:= .F.

If Len(aLivro) > 0
	aLivro:=Adel(aLivro,1)
	aLivro:=aSize(aLivro,Len(aLivro)-1)
	nVlrTotal:=Len(aLivro)
Endif

For nC := 1 To Len(aAutoItens)
   	For nZ := 1 To Len(aAutoItens[nC])
		If AllTrim(aAutoItens[1][nZ][1]) $ "D1_CF|D2_CF"
			cCFO := aAutoItens[1][nZ][2]
		Endif
		If AllTrim(aAutoItens[1][nZ][1]) $ "D1_TES|D2_TES"
			cTES := aAutoItens[1][nZ][2]
		Endif
	Next nZ
	If cAlias == "SF1"
		cChavePesq := DTOC(SF1->F1_DTDIGIT)+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+cCFO
	Else
		cChavePesq := DTOC(SF2->F2_EMISSAO)+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+cCFO
	EndIf
	SF3->(dbSetOrder(1))
		If ! SF3->(dbSeek(cFilSF3+cChavePesq))
		RecLock("SF3",.T.)
   	 	F3_FILIAL  := cFilSF3
    	F3_ENTRADA := If(cAlias=="SF1",SF1->F1_DTDIGIT,SF2->F2_DTDIGIT)
    	F3_NFISCAL := If(cAlias=="SF1",SF1->F1_DOC,SF2->F2_DOC)
    	SerieNfId("SF3",1,"F3_SERIE",,,,If(cAlias=="SF1",SF1->F1_SERIE,SF2->F2_SERIE))//Projeto Chave Unica - Tiago Silva
    	F3_CLIEFOR := If(cAlias=="SF1",SF1->F1_FORNECE,SF2->F2_CLIENTE)
    	F3_LOJA    := If(cAlias=="SF1",SF1->F1_LOJA,SF2->F2_LOJA)
    	F3_CFO     := cCFO
    	F3_TES     := cTES
    	F3_TIPO    := "N"
    	F3_REPROC  := "S"
    	F3_TIPOMOV := If(cAlias=="SF1","C","V")
    	F3_ESTADO  := If(cAlias=="SF1",SF1->F1_EST,SF2->F2_EST)
    	F3_EMISSAO := If(cAlias=="SF1",SF1->F1_EMISSAO,SF2->F2_EMISSAO)
    	F3_VALCONT := If(cAlias=="SF1",SF1->F1_VALBRUT,SF2->F2_VALBRUT)
    	F3_DESPESA := If(cAlias=="SF1",SF1->F1_DESPESA,SF2->F2_DESPESA)
    	F3_FRETE   := If(cAlias=="SF1",SF1->F1_FRETE,SF2->F2_FRETE)
    	F3_FORMUL  := If(cAlias=="SF1",SF1->F1_FORMUL,SF2->F2_FORMUL)
    	F3_ESPECIE := IF(cAlias=="SF1",SF1->F1_ESPECIE,SF2->F2_ESPECIE)
    	//Incluir controle de Formulario.
    	F3_NFEARG  := SF3->F3_NFISCAL
		If lNFEArg
			F3_TPVENT  := SF1->F1_TPVENT
			F3_CAE     := SF1->F1_CAE
			F3_VCTOCAE := SF1->F1_VCTOCAE
		Endif
    	For nZ := 1 To Len(aAutoItens[nC])
	   		If Subs(aAutoItens[1][nZ][1],4,6) $ "BASIMP|ALQIMP|VALIMP"
	    		cCpoSF3 := "F3"+AllTrim(Subs(aAutoItens[1][nZ][1],3,8))
	   			&(cCpoSF3) := aAutoItens[nC][nZ][2]
	   		EndIf
	   	Next nZ
	   	MsUnLock()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para atualizar o livro fiscal   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("MTA920L")
			ExecBlock("MTA920L",.F.,.F.)
		EndIf
	EndIf
Next nC
RestArea(aAreaSF2)
RestArea(aAreaSF1)
RestArea(aSavArea)
Return

/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CarregaLanc   ³ Autor ³ Guilherme C. Leal      ³ Data ³ 24.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a carga dos lanç. padronizados por tipo de NF          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LocXNF                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/
Function CarregaLanc(nTipo)

Local aRet 		:= array(2)	//Retorno da funcao
/*								[1] - aLpC
								[2] - aLpI
*/

Private aLpC	:= {}			//Array com o numero dos lanç. padrao referentes a Cabecalho
Private aLpI	:= {}			//Array com o numero dos lanç. padrao referentes a Itens
Private aLpCDel:= {}			//Array com o numero dos lanç. padrao referentes a Cabecalho
Private aLpIDel:= {}			//Array com o numero dos lanç. padrao referentes a Itens

Do Case
	// EQU - Nota de Venta | AUS - RCTI | MEX - Adiantamento | Traslado
	Case nTipo == 1 .OR. nTipo == 17 .OR. nTipo == 18 .OR. nTipo == 19 .OR. nTipo == 21 //jgr
		If VerPadrao('68A') .OR. VerPadrao('68I')
			aLpC 		:= {"68A"}	;	aLpI 		:= {"68I"} // Inclusão de Notas Fiscal Man/Aut - Cab e Item
		Else
			aLpC 		:= {"620"}	;	aLpI 		:= {"610"} // Antigo
		EndIF
		If VerPadrao('68E') .OR. VerPadrao('68M')
			aLpCDel 	:= {"68E"}	;	aLpIDel 	:= {"68M"}  //Cancelar Nota de Fiscal Man/Aut - Cab e Item
		Else
			aLpCDel 	:= {"635"}	;	aLpIDel 	:= {"630"}
		EndIF
	Case nTipo == 2
		If VerPadrao('68C') .OR. VerPadrao('68K')
			aLpC 		:= {"68C"}	;	aLpI 		:= {"68K"} //Inclusão de Notas de Deb.
		Else
			aLpC 		:= {"620"}	;	aLpI 		:= {"610"}
		EndIf
		If VerPadrao('68G') .OR. VerPadrao('680')
			aLpCDel 	:= {"68G"}	;	aLpIDel 	:= {"680"}
		Else
			aLpCDel 	:= {"635"}	;	aLpIDel 	:= {"630"}
		EndIf
	Case nTipo == 3
		If VerPadrao('68B') .OR. VerPadrao('68J')
			aLpC 		:= {"68B"}	;	aLpI 		:= {"68J"} //Inclusão de Notas de Créd.
		Else
			aLpC 		:= {"620"}	;	aLpI 		:= {"610"}
		EndIf
		If VerPadrao('68F') .OR. VerPadrao('68N')
			aLpCDel 	:= {"68F"}	;	aLpIDel 	:= {"68N"}
		Else
			aLpCDel 	:= {"635"}	;	aLpIDel 	:= {"630"}
		EndIF
	Case nTipo == 4
		If VerPadrao('68B') .OR. VerPadrao('68J')
			aLpC 		:= {"68B"}	;	aLpI 		:= {"68J"}
		Else
			aLpC 		:= {"642"}	;	aLpI 		:= {"640"}
		EndIF
		If VerPadrao('68F') .OR. VerPadrao('68N')
			aLpCDel 	:= {"68F"}	;	aLpIDel 	:= {"68N"}
		Else
			aLpCDel 	:= {"665"}	;	aLpIDel 	:= {"655"}
		EndIF
	Case nTipo == 5
		If VerPadrao('68C') .OR. VerPadrao('68K')
			aLpC 		:= {"68C"}	;	aLpI 		:= {"68K"} //Inclusão de Notas de Deb.
		Else
			aLpC 		:= {"642"}	;	aLpI 		:= {"640"}
		EndIf
		If VerPadrao('68G') .OR. VerPadrao('680')
			aLpCDel 	:= {"68G"}	;	aLpIDel 	:= {"680"}
		Else
			aLpCDel 	:= {"665"}	;	aLpIDel 	:= {"655"}
		EndIf
	Case nTipo == 6
		If VerPadrao('685') .OR. VerPadrao('693')
			aLpC 		:= {"685"}	;	aLpI 		:= {"693"} //Inclusão Nota Entrada Débito
		Else
			aLpC 		:= {"620"}	;	aLpI 		:= {"610"}
		EndIf
		If VerPadrao('689') .OR. VerPadrao('697')
			aLpCDel		:= {"689"}	;	aLpIDel 	:= {"697"}
		Else
			aLpCDel		:= {"635"}	;	aLpIDel 	:= {"630"}
		EndIf
	Case nTipo == 7 .OR. nTipo == 22  
		If VerPadrao('684') .OR. VerPadrao('692')
			aLpC 		:= {"684"}	;	aLpI 		:= {"692"} //Inclusão Nota Entrada Credito
		Else
			aLpC 		:= {"620"}	;	aLpI 		:= {"610"}
		EndIF
		If VerPadrao('688') .OR. VerPadrao('696')
			aLpCDel 	:= {"688"}	;	aLpIDel 	:= {"696"}
		Else
			aLpCDel 	:= {"635"}	;	aLpIDel 	:= {"630"}
		EndIf
	Case nTipo == 8
		If VerPadrao('684') .OR. VerPadrao('692')
			aLpC 		:= {"684"}	;	aLpI 		:= {"692"} //Inclusão Nota Entrada Credito
		Else
			aLpC 		:= {"660"}	;	aLpI 		:= {"650"}
		EndIf
		If VerPadrao('688') .OR. VerPadrao('696')
			aLpCDel 	:= {"688"}	;	aLpIDel 	:= {"696"}
		Else
			aLpCDel 	:= {"665"}	;	aLpIDel 	:= {"655"}
		EndIf
	Case nTipo == 9 .OR. nTipo == 23  
		If VerPadrao('685') .OR. VerPadrao('693')
			aLpC 		:= {"685"}	;	aLpI 		:= {"693"} //Inclusão Nota Entrada Débito
		Else
			aLpC 		:= {"660"}	;	aLpI 		:= {"650"}
		EndIF
		If VerPadrao('689') .OR. VerPadrao('697')
			aLpCDel 	:= {"689"}	;	aLpIDel 	:= {"697"}
		Else
			aLpCDel 	:= {"665"}	;	aLpIDel 	:= {"655"}
		EndIf
	Case nTipo == 10
		If VerPadrao('683') .OR. VerPadrao('691')
			aLpC 		:= {"683"}	;	aLpI 	:= {"691"} // Inclusão Nota de Entrada
		Else
			aLpC 		:= {"660","950"}	;	aLpI 	:= {"650"}
		EndIf
		If VerPadrao('687') .OR. VerPadrao('695')
			aLpCDel 	:= {"687"}	;	aLpIDel := {"695"}
		Else
			aLpCDel 	:= {"665","955"}	;	aLpIDel := {"655"}
		EndIF
	Case nTipo == 11
		aLpC 		:= {"620"}			;	aLpI 		:= {"610"}
		aLpCDel 	:= {"635"}			;	aLpIDel 	:= {"630"}
	Case nTipo == 12
		aLpC 		:= {"642"}			;	aLpI 		:= {"640"}
		aLpCDel 	:= {"665"}			;	aLpIDel 	:= {"655"}
	Case nTipo == 13
		aLpC 		:= {"660"}			;	aLpI 		:= {"650"}
		aLpCDel 	:= {"665"}			;	aLpIDel 	:= {"655"}
	Case nTipo == 14
		aLpC 		:= {"660"}			;	aLpI 		:= {"650"}
		aLpCDel 	:= {"665"}			;	aLpIDel 	:= {"655"}
	Case nTipo == 15
		aLpC 		:= {"660"}			;	aLpI 		:= {"650"}
		aLpCDel 	:= {"665"}			;	aLpIDel 	:= {"655"}
	Case nTipo == 50
		If VerPadrao('68D') .OR. VerPadrao('68L')  //Inclusão de Remito de Venda.
			aLpC 		:= {"68D"}	;	aLpI 		:= {"68L"}
		Else
			aLpC 		:= {"620"}	;	aLpI 		:= {"610"}
		EndIF
		If VerPadrao('68H') .OR. VerPadrao('68L')
			aLpCDel 	:= {"68H"}	;	aLpIDel 	:= {"68L"}
		Else
			aLpCDel 	:= {"635"}	;	aLpIDel 	:= {"630"}
		EndIf
	Case nTipo == 51
		If VerPadrao('68D') .OR. VerPadrao('68L')
			aLpC 		:= {"68D"}	;	aLpI 		:= {"68L"} //Inclusão de Remito de Venda.
		Else
			aLpC 		:= {"642"}	;	aLpI 		:= {"640"}
		EndIf
		If VerPadrao('68H') .OR. VerPadrao('68P')
			aLpCDel 	:= {"68H"}	;	aLpIDel 	:= {"68P"}
		Else
			aLpCDel 	:= {"665"}	;	aLpIDel 	:= {"655"}
		EndIf
	Case nTipo == 52
		If VerPadrao('68D') .OR. VerPadrao('68L')
			aLpC 		:= {"68D"}	;	aLpI 		:= {"68L"} //Inclusão de Remito de Venda.
		Else
			aLpC 		:= {"620"}	;	aLpI 		:= {"610"}
		EndIf
		If VerPadrao('68H') .OR. VerPadrao('68P')
			aLpCDel 	:= {"68H"}	;	aLpIDel 	:= {"68P"}
		Else
			aLpCDel 	:= {"635"}	;	aLpIDel 	:= {"630"}
		EndIF
	Case nTipo == 53
		If VerPadrao('68D') .OR. VerPadrao('68L')
			aLpC 		:= {"68D"}	;	aLpI 		:= {"68L"} //Inclusão de Remito de Venda.
		Else
			aLpC 		:= {"642"}	;	aLpI 		:= {"640"}
		EndIf
		If VerPadrao('68H') .OR. VerPadrao('68P')
			aLpCDel 	:= {"68H"}	;	aLpIDel 	:= {"68P"}
		Else
			aLpCDel 	:= {"665"}	;	aLpIDel 	:= {"655"}
		EndIf
	Case nTipo == 54
		aLpC 		:= {"710"}			;	aLpI 		:= {"720"}
		aLpCDel 	:= {"650","711"}	;	aLpIDel		:= {"655","721"}
	Case nTipo == 60
		If VerPadrao('686') .OR. VerPadrao('694')
			aLpC 		:= {"686"}	;	aLpI 	:= {"694"} //Remito de Entrada
		Else
			aLpC 		:= {"660","950"}	;	aLpI 	:= {"650"}
		EndIf
		If VerPadrao('690') .OR. VerPadrao('698')
			aLpCDel 	:= {"690"}	;	aLpIDel := {"698"}
		Else
			aLpCDel 	:= {"665","955"}	;	aLpIDel := {"655"}
		EndIf
	Case nTipo == 61
		If VerPadrao('685') .OR. VerPadrao('694')
			aLpC 		:= {"685"}	;	aLpI 		:= {"694"} //Inclusão Nota Entrada Débito
		Else
			aLpC 		:= {"620"}	;	aLpI 		:= {"610"}
		EndIf
		If VerPadrao('690') .OR. VerPadrao('698')
			aLpCDel 	:= {"690"}	;	aLpIDel 	:= {"698"}
		Else
			aLpCDel 	:= {"635"}	;	aLpIDel 	:= {"630"}
		EndIf
	Case nTipo == 62
		If VerPadrao('686') .OR. VerPadrao('694')
			aLpC 		:= {"686"}	;	aLpI 		:= {"694"} //Remito de Entrada
		Else
			aLpC 		:= {"642"}	;	aLpI 		:= {"640"}
		EndIf
		If VerPadrao('690') .OR. VerPadrao('698')
			aLpCDel 	:= {"690"}	;	aLpIDel 	:= {"698"}
		Else
			aLpCDel 	:= {"665"}	;	aLpIDel 	:= {"655"}
		EndIf
	Case nTipo == 63
		If VerPadrao('68D') .OR. VerPadrao('68L')
			aLpC 		:= {"68D"}	;	aLpI 		:= {"68L"} //Inclusão de Remito de Venda.
		Else
			aLpC 		:= {"642"}	;	aLpI 		:= {"640"}
		EndIf
		If VerPadrao('68H') .OR. VerPadrao('68P')
			aLpCDel 	:= {"68H"}	;	aLpIDel	:= {"68P"}
		Else
			aLpCDel 	:= {"665"}	;	aLpIDel	:= {"655"}
		EndIf
	Case nTipo == 64
		aLpC 		:= {"750"}			;	aLpI 	:= {"650"}
		aLpCDel 	:= {"650"}			;	aLpIDel	:= {"655"}
EndCase

aRet[1] := aLpC
aRet[2] := aLpI

Return(aRet)

/*
±±ºPrograma  ³RetDiaUtilºAutor  ³Camila Januario     º Data ³  01/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna 5o dia util do mes.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Peru - Geração de título de Detração                       º±±
*/
Function RetDiaUtil(cMes, cAno)
Return LxdUtilPer(cMes, cAno)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ALocVldGrd³Autor  ³ Marco Bianchi         ³ Data ³20/10/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao dos itens do Grid na grade de produtos            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. se Valido e .F. se Invalido                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Objeto de Grade das rotinas MATA462N, MATA465N e MATA467N    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ALocVldGrd()

Local lValido := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se Houver necessidade de novas validacoes na entrada de dados nas   ³
//³ celulas do Grid elas deverao ser inseridas nessa funcao.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Positivo()
	lValido := .T.
EndIf
Return lValido

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidaIvaAdq   ºAutor  ³Julio C.Guerato º Data ³ 20/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida Iva Adquirente - Portugal                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aCabNota = Array com Cabecalho Nota                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. = Iva Adq.Ok / .F. = Iva Adq.com Problema			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ValidaIvaAdq(aCabNota)
Local nPosIva   := 0
Local nPosIvaCF := 0
Local nPosLoja  := 0
Local nPosTipo  := 0
Local nPosDocOri:= 0
Local nPosSerOri:= 0
Local nIva1     := 0
Local nIva2     := 0
Local nCompDoc  := 0
Local nX        := 0
Local cFiltroSF1 := SF1->(dbFilter())
Local lRet      := .T.
Local cFilSB1	:= xFilial("SB1")
Local cFilSF1	:= xFilial("SF1")

nPosIva   := AScan(aCabNota[1],IIF(aCfgNf[4]=="SF1","F1_IVAADQ","F2_IVAADQ"))
nPosIvaCF := AScan(aCabNota[1],IIF(aCfgNf[4]=="SF1","F1_FORNECE","F2_CLIENTE"))
nPosLoja  := AScan(aCabNota[1],IIF(aCfgNf[4]=="SF1","F1_LOJA","F2_LOJA"))
nPosPdIva := aScan(aHeader,{|x| AllTrim(x[2])==IIF(aCfgNf[4]=="SF1","D1_COD","D2_COD")})
nPosTipo  := AScan(aCabNota[1],IIF(aCfgNf[4]=="SF1","F1_TIPO","F2_TIPO"))

SF1->(dbClearFilter())

IF nPosIva>0 .And. AllTrim(cEspecie)$"NF|NDP|NCP|NDI|NCI|GDN"
	If aCabNota[2][nPosIva]=="1"
		If aCfgNf[2]=="SA1"
			//Cliente
			DbSelectArea("SA1")
			DbSetOrder(1)
			If FieldPos("A1_IVAADQ")>0
				If MsSeek(xFilial("SA1")+aCabNota[2][nPosIvaCF])
					If A1_IVAADQ=="1"
						nIva1:=1
					EndIf
				EndIf
			EndIf
		Else
			//Fornecedor
			DbSelectArea("SA2")
			DbSetOrder(1)
			If  SA2->(ColumnPos("A2_IVAADQ")) > 0
				If MsSeek(xFilial("SA2")+aCabNota[2][nPosIvaCF])
					If A2_IVAADQ=="1"
						nIva1:=1
					EndIf
				EndIf
			EndIf
		EndIf

		//Verifica Produtos se Cliente ou Fornecedor permitir IVA
		If nIva1>0
			DbSelectArea("SB1")
			DbSetOrder(1)
			If SB1->(ColumnPos("B1_IVAADQ")) > 0
				For nX := 1 to Len(aCols)
					If aCols[nX][Len(aCols[nX])]
						Loop
					EndIf
					If MsSeek(cFilSB1+aCols[nX][nPosPdIva])
						IF B1_IVAADQ=="1"
							nIva2+=1
						EndIf
					EndIf
					If nIva2>0
						Exit
					EndIf
				Next nX
			EndIf
		EndIf

		//Exibe mensagem e informa inconsistencia na configuracao do IVA //
		If nIva1==0
			Aviso(STR0033,IIF(aCfgNf[2]=="SA1",STR0057,STR0058)+"-"+STR0060,{STR0041})
			lRet := .F.
		EndIf
		If nIva1>0 .And. nIva2==0
			Aviso(STR0033,STR0059,{STR0041})
			lRet := .F.
		EndIf
	EndIf
EndIf

//Valida Documento que está sendo digitado X Documento que esta amarrado
If lRet .And. nPosIva>0
	//Valida se o Doc.vinculado a Factura possui mesma configuração de Iva Adquirente
	If AllTrim(cEspecie)$"NF|"
		 nPosDocOri:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_REMITO"})
		 nPosSerOri:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_SERIREM"})
		 If nPosDocOri>0 .And. nPosSerOri>0
		 	 For nX := 1 to Len(aCols)
		 	 	If Empty(aCols[nX][nPosDocOri])
		 	 		Loop
		 	 	EndIf
				DbSelectArea("SF1")
				DbSetOrder(1)
				DbSeek(cFilSF1+aCols[nX][nPosDocOri]+aCols[nX][nPosSerOri]+aCabNota[2][nPosIvaCF]+aCabNota[2][nPosLoja]+"N")
				If !Eof()
  				    //Considera somente os documentos que nao estao na lista
					If !AllTrim(F1_ESPECIE)$"RCN|"
						If aCabNota[2][nPosIva]<>F1_IVAADQ
							nCompDoc+=1
						EndIf
					EndIf
				EndIf
				//Achou um doc diferente, ignora os demais
				If nCompDoc>0
					exit
				EndIf
			Next nX
		 EndIf
		 If nCompDoc>0
		 	Aviso(STR0033,STR0061+CHR(13)+STR0062,{STR0041})
			lRet := .F.
		 EndIf
	EndIf
EndIf

If !Empty(cFiltroSF1)
	SF1->(dbSetFilter({||&cFiltroSF1},cFiltroSF1))
EndIF

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldForLoja() ºAutor  ³Moises Nunes     º Data ³  13/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validar Fornecedor e Loja                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldForLoja(cNomeAlias)
Local aArea := GetArea()
Local cForne:=Space(Len(M->F1_FORNECE))
Local cLoja :=Space(Len(M->F1_LOJA))
If cNomeAlias=="SA2"
	DBSelectArea("SA2")
	DBSetOrder(1)
	If !MsSeek(xFilial('SA2')+M->F1_FORNECE, .F.)
		M->F1_FORNECE:=cForne
		M->F1_LOJA   :=cLoja
	Else
		If !MsSeek(xFilial('SA2')+M->F1_FORNECE+M->F1_LOJA, .F.)
			M->F1_LOJA:=cLoja
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AltConPad    ³ Autor ³ Anieli Rodrigues        ³ Data ³01/11/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Altera a consulta padrao dos indices - Utilizado na opção Busca  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AltConPad(cCampo,cPad)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCampo - Nome Campo a ser alterado                               ³±±
±±³          |cPad   - Consulta padrão 										   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOCXNF	                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AltConPad(cCampo,cPad)
Local aInd  := {}
Local aInd1 := {}
Local aArea := GetArea()
Local cTab  := aCfgNF[4]
Local nPos  := 0
Local i     := 0
Local aDadosSM0 := FWLoadSM0()

DbSelectArea("SIX")
DbSeek(cTab)
Do While !Eof() .And. SIX->INDICE == cTab
	aInd:=STRTOKARR(AllTrim(CHAVE),'+')
	aaDD(aInd1,aInd)
   DbSkip()
EndDo

For i:=1 to Len(aInd1)
	nPos:=AScan(aInd1[i],cCampo)
	If nPos>0
		aaDD(aTrocaF3,{"aPesqVar["+STRZERO(I,2)+"]["+STRZERO(iif(Len(aDadosSM0)>1,nPos,nPos-1),2)+"]",cPad})
	EndIf
Next I

If cPad $ "SA2/SA1"
	Aadd(aTrocaF3,{"",cPad})	// Altera a consulta também nos detalhes da busca padrão da MBrowse (parte superior da tela, sem ser a busca do aRotina)
EndIf

RestArea(aArea)
Return aTrocaF3

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LcSetTAnu()  ºAutor  ³Vendas CRM       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Set da Statis para gravar tipo de anulacao Rep Dom         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATXFIS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LcSetTAnu(nVariavel)
	nFatF3TpAn := nVariavel
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LcGetTAnu()  ºAutor  ³Vendas CRM       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Get da Statis para gravar tipo de anulacao Rep Dom         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATXFIS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LcGetTAnu()
Return nFatF3TpAn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxNFOrig   ºAutor  ³Vendas/CRM         º Data ³  13/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela para escolha de item de Remito ou Nota de Origem       º±±
±±º          ³gerados a partir de pedidos de venda.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: "P" - Pedido - "NF" - Notas Fiscais                  º±±
±±º          ³ExpC2: Alias do Cabeçalho SF1/SF2                           º±±
±±º          ³ExpC3: Tipo de Documento conforme LocxNF                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxNFOrig(cBusca,nAlias,cTipoDoc)

Local cQuery   := ""
Local aPedidos := {}
Local cCliFor		:= IIf(aCfgNF[nAlias]=="SF1",M->F1_FORNECE,M->F2_CLIENTE)
Local cLoja  		:= IIf(aCfgNF[nAlias]=="SF1",M->F1_LOJA,M->F2_LOJA)
Local dInvDate	:= IIf(aCfgNF[nAlias]=="SF1",M->F1_EMISSAO,M->F2_EMISSAO)
	If Empty(cCliFor) .OR. Empty(cLoja)
		Aviso(STR0033,STR0066,{STR0041}) //"Preencha os dados do Cliente e Loja"###"OK"
		Return {}
	EndIf
	If cTipoDoc $ "51|53" // Remito - Não deixa devolver quantidade ja devolvida ou faturada.
		cQuery := "SELECT 'LBNO' OK,C9_PEDIDO DOC,C9_CLIENTE CLIENTE, C9_LOJA LOJA ,SUM(SD2.D2_QUANT - SD2.D2_QTDEDEV - SD2.D2_QTDEFAT) as QTD, SUM(D2_TOTAL) VALORBRUTO "
		If cPaisLoc == "RUS"
			cQuery += ", SF2.F2_CNTID CONTRACT, SF2.F2_MOEDA MOEDA, SF2.F2_CONUNI CONUNI "
		EndIf
		cQuery += " FROM  "+RetSQLName("SC9")+" SC9 JOIN "+RetSQLName("SD2")+" SD2 ON SD2.D2_DOC=SC9.C9_REMITO AND SD2.D2_SERIE=SC9.C9_SERIREM "
		cQuery += " AND SD2.D2_PEDIDO=SC9.C9_PEDIDO AND SD2.D2_FILIAL=SC9.C9_FILIAL AND SD2.D2_COD=SC9.C9_PRODUTO AND (SD2.D2_QUANT - SD2.D2_QTDEDEV - SD2.D2_QTDEFAT) > 0 "
		If cPaisLoc == "RUS"
			cQuery += " JOIN "+RetSQLName("SF2")+" SF2 ON (SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE) AND SD2.D2_FILIAL=SF2.F2_FILIAL"
		EndIf
		cQuery += " WHERE C9_REMITO != '"+Space(TamSX3("C9_REMITO")[1])+"' AND C9_CLIENTE='"+cCliFor+"' AND C9_LOJA='"+cLoja+"' AND C9_FILIAL='"+XFilial("SC9")+"' "
		If cPaisLoc == "RUS"
			cQuery +=	" AND C9_DATALIB <= '" + DTOS(dInvDate)+"' "
		EndIf
		cQuery += " GROUP BY C9_PEDIDO,C9_CLIENTE,C9_LOJA "
		If cPaisLoc == "RUS"
			cQuery += ",SF2.F2_CNTID, SF2.F2_MOEDA, SF2.F2_CONUNI "
		EndIf
	Else  //cTipoDoc $ "02|03|04|05" - Pedidos de Nota Fiscal
		  //"P" PEDIDO DE VENDA - "NF" Faturas de Saida (01 e 18)
		If cBusca == "P"
			cQuery := "SELECT 'LBNO' OK,C9_PEDIDO DOC,C9_CLIENTE CLIENTE, C9_LOJA LOJA,SUM(SD2.D2_QUANT - SD2.D2_QTDEDEV) as QTD, SUM(D2_TOTAL) VALORBRUTO "
			If cPaisLoc == "RUS"
				cQuery += ", SF2.F2_CNTID CONTRACT, SF2.F2_MOEDA MOEDA, SF2.F2_CONUNI CONUNI "
			EndIf
			cQuery += " FROM  "+RetSQLName("SC9")+" SC9 JOIN "+RetSQLName("SD2")+" SD2 ON SD2.D2_DOC=SC9.C9_NFISCAL AND SD2.D2_SERIE=SC9.C9_SERIENF "
			cQuery += " AND SD2.D2_PEDIDO=SC9.C9_PEDIDO AND SD2.D2_FILIAL=SC9.C9_FILIAL AND SD2.D2_COD=SC9.C9_PRODUTO AND (SD2.D2_QUANT - SD2.D2_QTDEDEV) > 0 "
			If cPaisLoc == "RUS"
				cQuery += " JOIN "+RetSQLName("SF2")+" SF2 ON (SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE) AND SD2.D2_FILIAL=SF2.F2_FILIAL"
			EndIf
			cQuery += " WHERE C9_NFISCAL != '"+Space(TamSX3("C9_NFISCAL")[1])+"' AND C9_CLIENTE='"+cCliFor+"' AND C9_LOJA='"+cLoja+"' AND C9_FILIAL='"+XFilial("SC9")+"' "
			cQuery += " GROUP BY C9_PEDIDO,C9_CLIENTE,C9_LOJA "
			If cPaisLoc == "RUS"
				cQuery += ",SF2.F2_CNTID, SF2.F2_MOEDA, SF2.F2_CONUNI "
			EndIf
		Else
			cQuery := "SELECT 'LBNO' OK,CONCAT(F2_DOC,F2_SERIE) DOC,F2_CLIENTE CLIENTE, F2_LOJA LOJA,SUM(SD2.D2_QUANT - SD2.D2_QTDEDEV) as QTD, SUM(D2_TOTAL) VALORBRUTO "
			If cPaisLoc == "RUS"
				cQuery += ", SF2.F2_CNTID CONTRACT "
			EndIf
			cQuery += " FROM "+RetSQLName("SF2")+" SF2 JOIN "+RetSQLName("SD2")+" SD2 ON (SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE) "
			cQuery += " AND SD2.D2_FILIAL=SF2.F2_FILIAL AND (SD2.D2_QUANT - SD2.D2_QTDEDEV) > 0 "
			cQuery += " WHERE F2_CLIENTE='"+cCliFor+"' AND F2_LOJA='"+cLoja+"' AND F2_FILIAL='"+XFilial("SF2")+"' AND F2_TIPODOC IN ('01','18') "
			cQuery += " GROUP BY F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA	"
			If cPaisLoc == "RUS"
				cQuery += ",SF2.F2_CNTID, SF2.F2_MOEDA, SF2.F2_CONUNI "
			EndIf
		EndIf
	EndIf
	cQuery := ChangeQuery(cQuery)
	If cPaisLoc == "RUS"
		aPedidos := LxNFBrow(cBusca,cQuery,aCfgNF[nAlias])
	Else
		aPedidos := LxNFBrow(cBusca,cQuery)
	EndIf
	If Len(aPedidos) > 0
		LxAddSDOri(cBusca,aPedidos,Iif(aCfgNF[nAlias]=="SF1","D1","D2"),cCliFor,cLoja,cTipoDoc)
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxAddSDOri ºAutor  ³Vendas/CRM         º Data ³  13/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Adiciona no grid da Locxnf os itens dos pedidos da array    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: "P" - Pedidos, "NF - Vendas                          º±±
±±º          ³ExpA2: Array contendo os Codigos de Pedido                  º±±
±±º          ³ExpC3: Alias da tabela SD, SD1 ou SD2                       º±±
±±º          ³ExpC4: Cliente                                              º±±
±±º          ³ExpC5: Loja                                                 º±±
±±º          ³ExpC5: Loja                                                 º±±
±±º          ³ExpC6: Tipodoc                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LxNFOrig                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxAddSDOri(cBusca,aPedidos,cPfx,cCliFor,cLoja,cTipoDoc)

Local aArea    		:= GetArea()
Local aSF2			:= SF2->(GetArea())
Local aSD2			:= SD2->(GetArea())
Local aSD1			:= SD1->(GetArea())
Local nI
Local nX
Local nLenAcols
Local nUm			:= 0
Local nSegUm		:= 0
Local nCod			:= 0
Local nFdesc		:= 0
Local nDescri		:= 0
Local nLocal		:= 0
Local nQuant		:= 0
Local nNfOri		:= 0
Local nSeriOri		:= 0
Local nItemOri		:= 0
Local nItem			:= 0
//Local Tes			:= 0
Local nCf			:= 0
Local nLoteCtl		:= 0
Local nNumLote		:= 0
Local nDtValid		:= 0
Local nVunit		:= 0
Local nTotal		:= 0
Local nTotalM		:= 0
Local nQTSegum		:= 0
Local nConta		:= 0
Local nCCusto		:= 0
Local nDesc			:= 0
Local nValDesc		:= 0
Local nProvEnt 		:= 0
Local nTaxaNf		:= 0
Local nQtdeDev
Local lLxDOrig		:= ExistBlock( "LXDORIG" )
Local cItem
Local nPrecio
Local nOrder
Local cSeek
Local lD2_PROVENT := .F.
Local cFilSD2	:= xFilial("SD2")
Local cFilSF2	:= xFilial("SF2")
Local cFilSB1	:= xFilial("SB1")
Local cFilSF4	:= xFilial("SF4")
Local cPrefSF	As Character
If cPaisLoc == "RUS"
	cPrefSF		:= IIf(cPfx=="D1","F1","F2")
EndIf

For nI:=1 to Len(aHeader)
	Do Case
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_UM"
			nUm      := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_SEGUM"
			nSegUm   := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_COD"
			nCod     := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_LOCAL"
			nLocal   := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_QUANT"
			nQuant   := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_NFORI"
			nNfOri  := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_SERIORI"
			nSeriOri := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_ITEMORI"
			nItemOri := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_ITEM"
			nItem    := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_TES"
			nTes     := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_CF"
			nCf      := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_LOTEFOR"
			nLoteFor := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_LOTECTL"
			nLoteCtl := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_NUMLOTE"
			nNumLote := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_DTVALID"
			nDtValid := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+IIf(cPfx=="D1", "_VUNIT", "_PRCVEN")
			nVunit   := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_TOTAL"
			nTotal   := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_QTSEGUM"
			nQTSegum := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_CONTA"
			nConta := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_CC"
			nCCusto := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_VALDESC"
			nValDesc := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_DESC"
			nDesc := nI
		Case  Alltrim(aHeader[nI][2]) == cPfx+"_PROVENT"
			nProvEnt := nI
		Case  cPaisLoc == "RUS" .And. Alltrim(aHeader[nI][2]) == cPfx+"_TOTALM"
			nTotalM   := nI
		Case cPaisLoc == "RUS" .And.  Alltrim(aHeader[nI][2]) == cPfx+"_FDESC"
			nFdesc    := nI
		Case cPaisLoc == "RUS" .And.  Alltrim(aHeader[nI][2]) == cPfx+"_DESCRI"
			nDescri    := nI
		Case cPaisLoc == "RUS" .And.  Alltrim(aHeader[nI][2]) == cPfx+"_BSIMP1M"
			nBaseImpM    := nI
		Case cPaisLoc == "RUS" .And.  Alltrim(aHeader[nI][2]) == cPfx+"_VLIMP1M"
			nValImpM    := nI
	Endcase
Next nI

DbSelectArea("SF2")
DbSelectArea("SD2")

ProcRegua(Len(aPedidos))
cItem    := aCols[Len(aCols),nItem]
lD2_PROVENT := 	If(cPaisLoc == "ARG" , .T.,.F.)

For nX := 1 To Len(aPedidos)
	DbSelectArea("SD2")
	If cBusca == "P"
		nOrder := 8
		cSeek  := cFilSD2+aPedidos[nX]
	Else
		nOrder := 3
		cSeek  := cFilSD2+aPedidos[nX]+cCliFor+cLoja
	EndIf
	DbSetOrder(nOrder)
	If !MsSeek(cSeek)
		Aviso(STR0033,STR0068+aPedidos[nX],{STR0041})//"Atenção","Pedido não Encontrado: "+aPedidos[nX],{"OK"}
	Else
		IncProc(STR0069 + "(" + SD2->D2_DOC + " " + subStr(SD2->D2_SERIE,1,3) + ")")

		While Iif(cBusca == "P",;
			  SD2->D2_FILIAL == cFilSD2 .AND. SD2->D2_PEDIDO == aPedidos[nX],;
			  cFilSD2+aPedidos[nX]+cCliFor+cLoja == SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)

			DbSelectArea("SF2")
			DbSetOrder(1)
			MSSeek(cFilSF2+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)

			If SD2->D2_QUANT > (SD2->D2_QTDEDEV + IIf(cTipoDoc$"51|53",SD2->D2_QTDEFAT,0))
		       	If Ascan(aCols,{|x| x[nNFORI] == SD2->D2_DOC .AND. x[nItemOri] == SD2->D2_ITEM .AND. !x[Len(x)]}) == 0
					nLenAcols := Len(aCols)
					If !Empty(aCols[nLenAcols,nCod])
						AAdd(aCols,Array(Len(aHeader)+1))
						nLenAcols := Len(aCols)
						cItem := Soma1(cItem)
					Endif
				 	aCols[nLenAcols][Len(aHeader)+1]:=.F.
					SB1->(MsSeek(cFilSB1+SD2->D2_COD))
					If (nUm      >  0  ,  aCOLS[nLenAcols][nUm     ] := SD2->D2_UM	,)
					If (nSegUm   >  0  ,  aCOLS[nLenAcols][nSegUm  ] := SB1->B1_SEGUM,)
					If (nCod     >  0  ,  aCOLS[nLenAcols][nCod    ] := SD2->D2_COD,)
					If (cPaisLoc == "RUS" .And. nDescri  >  0  ,  aCOLS[nLenAcols][nDescri  ] := SD2->D2_DESCRI,)
					If (cPaisLoc == "RUS" .And. nFdesc   >  0  ,  aCOLS[nLenAcols][nFdesc  ] := SD2->D2_FDESC,)
					If (nLocal   >  0  ,  aCOLS[nLenAcols][nLocal  ] := SD2->D2_LOCAL,)
					If (nNfOri   >  0  ,  aCOLS[nLenAcols][nNfOri  ] := SD2->D2_DOC,)
					If (nSeriOri >  0  ,  aCOLS[nLenAcols][nSeriOri] := SD2->D2_SERIE,)
					If (nItemOri >  0  ,  aCOLS[nLenAcols][nItemOri] := SD2->D2_ITEM,)
					If (nItem    >  0  ,  aCOLS[nLenAcols][nItem   ] := cItem,)
					If (nLoteCtl >  0  ,  aCOLS[nLenAcols][nLoteCtl] := SD2->D2_LOTECTL,)
					If (nNumLote >  0  ,  aCOLS[nLenAcols][nNumLote] := SD2->D2_NUMLOTE,)
					If (nDtValid >  0  ,  aCOLS[nLenAcols][nDtValid] := SD2->D2_DTVALID,)
					If (nQtSegUm >  0  ,  aCOLS[nLenAcols][nQtSegUm] := SD2->D2_QTSEGUM,)
					nQtdeDev := SD2->D2_QUANT - SD2->D2_QTDEDEV - IIf(cTipoDoc$"51|53",SD2->D2_QTDEFAT,0)
					If nQuant > 0
						aCols[nLenAcols,nQuant] := nQtdeDev
					Endif
					If nQtSegUm > 0
						aCols[nLenAcols,nQtSegUm] := ConvUm(SD2->D2_COD,nQtdeDev,0,2)
					Endif
					If cPaisLoc == "RUS"
						If Empty(cCondicao) .OR. RUXXTS05()
							M->&(cPrefSF + "_CNTID") 	:= SF2->F2_CNTID
							M->&(cPrefSF + "_F5QDESC")   := Iif(!EMPTY(SF2->F2_F5QUID),Posicione("F5Q",1,XFILIAL("F5Q")+SF2->F2_F5QUID,"F5Q_DESCR"),"")
							M->&(cPrefSF + "_CONUNI")	:= SF2->F2_CONUNI
							M->&(cPrefSF + "_CNORSUP")	:= SF2->F2_CNORVEN
							M->&(cPrefSF + "_CNEEBUY")	:= SF2->F2_CNEECLI
							M->&(cPrefSF + "_CNORCOD")	:= SF2->F2_CNORCOD
							M->&(cPrefSF + "_CNORBR")	:= SF2->F2_CNORBR
							M->&(cPrefSF + "_CNEECOD")	:= SF2->F2_CNEECOD
							M->&(cPrefSF + "_CNEEBR")	:= SF2->F2_CNEEBR
							MaFisAlt("NF_MOEDA",SF2->F2_MOEDA)
							M->&(cPrefSF + "_MOEDA") 	:= SF2->F2_MOEDA
							nMoedaCor		:= SF2->F2_MOEDA
							nMoedaNF		:= SF2->F2_MOEDA
							MaFisAlt("NF_TXMOEDA",SF2->F2_TXMOEDA)
							M->&(cPrefSF + "_TXMOEDA")	:= SF2->F2_TXMOEDA
							cCondicao		:= SF2->F2_COND
							If cPfx == "D2"
								M->F2_DTSAIDA := SF2->F2_DTSAIDA
							EndIf
						EndIf
					EndIf
					If nTES <> 0
						SF4->(DbSetOrder(1))
						If SF4->(MsSeek(cFilSF4+SD2->D2_TES)) .AND. !Empty(SF4->F4_TESDV)
							aCols[nLenAcols][nTES] := Iif(cPaisLoc == "RUS" .And. cPrefSF == "F2",SD2->D2_TES, SF4->F4_TESDV)
						Endif
						If cPaisloc == "RUS"
							aCols[nLenAcols][nCf] := SD2->D2_CF
						EndIf
					EndIf
					nTaxaNF := MaFisRet(,'NF_TXMOEDA')
					nTaxaNF := Iif(nTaxaNF == 0,Recmoeda(dDatabase,If(cPfx=="D1",M->F1_MOEDA,M->F2_MOEDA)),nTaxaNF)
					If SD2->D2_DESC > 0 .OR. SD2->D2_DESCON > 0
						If SD2->D2_PRUNIT <> SD2->D2_PRCVEN .And. SD2->D2_PRUNIT > 0
							nPrecio := xMoeda(SD2->D2_PRUNIT,SF2->F2_MOEDA,MAFISRET(,'NF_MOEDA'),,,,nTaxaNF)
						Else
						    nPrecio := xMoeda(SD2->D2_PRCVEN,SF2->F2_MOEDA,MAFISRET(,'NF_MOEDA'),,,,nTaxaNF)
		  				    nPrecio += ((xMoeda(SD2->D2_DESCON,SF2->F2_MOEDA,MAFISRET(,'NF_MOEDA'),,,,nTaxaNF))/nQtdeDev)
		  				EndIf
					Else
						nPrecio := xMoeda(SD2->D2_PRCVEN,SF2->F2_MOEDA,MAFISRET(,'NF_MOEDA'),,,,nTaxaNF)
					Endif
					If nVUnit   >  0
						aCols[nLenAcols,nVUnit] := nPrecio
					EndIf
					If nTotal > 0
						aCols[nLenAcols][nTotal] := (nPrecio * nQtdeDev)
					Endif
					If  cPaisLoc == "RUS" .And. nTotalM > 0
						aCols[nLenAcols][nTotalM] := SD2->D2_TOTALM
					Endif
					If nDesc > 0
						aCols[nLenAcols][nDesc] := SD2->D2_DESC
					Endif
					If nValDesc > 0
						aCols[nLenAcols][nValDesc] := xMoeda(SD2->D2_DESCON,SF2->F2_MOEDA,MAFISRET(,'NF_MOEDA'),,,,nTaxaNF)
					Endif
					If cPaisLoc == "ARG" .And. nProvEnt > 0 .And. lD2_PROVENT
						aCols[nLenAcols,nProvEnt] := SD2->D2_PROVENT
					Endif
					AEval(aHeader,{|x,y| If(aCols[nLenAcols][y]==NIL,aCols[nLenAcols][y]:=CriaVar(x[2]),) })
					MaColsToFis(aHeader,aCols,nLenAcols,"MT100",.T.)

					If cPaisLoc == "RUS" .And. nBaseImpM > 0 .And. nValImpM > 0
						MaFisAlt("IT_BASEIV1_C1", SD2->D2_BSIMP1M,nLenAcols)
						aCols[nLenAcols][nBaseImpM] := SD2->D2_BSIMP1M
						MaFisAlt("IT_VALIV1_C1", SD2->D2_VLIMP1M,nLenAcols)
						aCols[nLenAcols][nValImpM]  := SD2->D2_VLIMP1M
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Dispara o ponto para cada item da NF        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lLxDOrig
						ExecBlock( "LXDORIG", .F., .F. )
					EndIf

				EndIf
			Endif
			SD2->(DbSkip())
		End
	EndIf
Next nX


If cPaisLoc == "RUS" .And. Type("bDoRefresh") == "B"
	Eval(bDoRefresh)
EndIf
AtuLoadQt()
RestArea(aSD2)
RestArea(aSD1)
RestArea(aSF2)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxNFBrow   ºAutor  ³Vendas/CRM         º Data ³  13/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³View para Dialog de Marcação dos Pedidos                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: "P" - Pedido, "NF" - Notas Fiscais de Venda          º±±
±±º          ³ExpC2: Query utilizada para popular browse                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LxNFOrig                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxNFBrow(cBusca,cQuery,cHeadAlias)

Local aPedidos	:= {}
Local aSize		:= MsAdvSize( .F. )
Local aPosObj	:= {}
Local aObjects	:= {}
Local cAliasTRB	:= GetNextAlias()
Local nOpcA		:= 0
Local oDlgPd
Local oBrowsePd

Private cContrMem		as Character
Private cMoedaMem		as Character
Private cConuniMem		as Character
Private cContrControl	as Character
Private nMoeda 			as Numeric
Private cConuni			as Character

Default cHeadAlias := ""
If cPaisLoc == "RUS"
	cContrMem		:= IIf(cHeadAlias=="SF1","F1_CNTID","F2_CNTID")
	cMoedaMem		:= IIf(cHeadAlias=="SF1","F1_MOEDA","F2_MOEDA")
	cConuniMem		:= IIf(cHeadAlias=="SF1","F1_CONUNI","F2_CONUNI")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula as coordenadas da interface                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize[1] /= 1.5
aSize[2] /= 1.5
aSize[3] /= 1.5
aSize[4] /= 1.3
aSize[5] /= 1.5
aSize[6] /= 1.3
aSize[7] /= 1.5

AAdd( aObjects, { 100, 020,.T.,.F.,.T.} )
AAdd( aObjects, { 100, 060,.T.,.T.} )
AAdd( aObjects, { 100, 020,.T.,.F.} )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgPd TITLE Iif(cBusca=="P",STR0021,STR0028) FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL	//"Pedido","Nota Fiscal"

	DEFINE FWFORMBROWSE oBrowsePd DATA QUERY ALIAS cAliasTRB QUERY cQuery OF oDlgPd
		oBrowsePd:SetCacheView(.F.)

		ADD MARKCOLUMN oColumn DATA { || OK } DOUBLECLICK { |oBrowsePd| LxNFBrMark(oBrowsePd,@aPedidos) } OF oBrowsePd

		ADD BUTTON oButton TITLE STR0041 ACTION { || nOpcA := 1 , oDlgPd:End() } OF oBrowsePd	// "OK"

		ADD COLUMN oColumn DATA { || LOJA   	} TITLE STR0057							SIZE 10 OF oBrowsePd //"Cliente"
		ADD COLUMN oColumn DATA { || CLIENTE	} TITLE RetTitle("A1_LOJA")				SIZE 4  OF oBrowsePd //"Loja"
		ADD COLUMN oColumn DATA { || DOC		} TITLE (cBusca=="P",STR0021,STR0028)	SIZE 10 OF oBrowsePd //"Pedido","Nota Fiscal"
		oColumn:SetTitle(Iif(cBusca=="P",STR0021,STR0028))
		ADD COLUMN oColumn DATA { || QTD        } TITLE RetTitle("D2_QUANT")	PICTURE "@E 999,999,999.99"	SIZE 20 OF oBrowsePd //Quantidade
		If cPaisLoc == "RUS"
			ADD COLUMN oColumn DATA { || MOEDA } TITLE RetTitle("F2_MOEDA")	PICTURE "99" SIZE 2 OF oBrowsePd	//Currency
			ADD COLUMN oColumn DATA { || CONUNI } TITLE RetTitle("F2_CONUNI")	PICTURE "@!" SIZE 3 OF oBrowsePd	//Convencial units
			oColumn:SetOptions( Separa(RTrim(X3CBox()),";") )
		EndIf
		ADD COLUMN oColumn DATA { || VALORBRUTO } TITLE RetTitle("F2_VALBRUT")	PICTURE "@E 999,999,999.99"	SIZE 20 OF oBrowsePd
		If cPaisLoc == "RUS"
			ADD COLUMN oColumn DATA { || CONTRACT } TITLE RetTitle("F2_CNTID")	PICTURE "@"	SIZE 9 OF oBrowsePd
		EndIf

	ACTIVATE FWFORMBROWSE oBrowsePd

oDlgPd:Activate(NIL,NIL,NIL,.T.,NIL, NIL,{|| Iif((cAliasTRB)->(Eof() .AND. Aviso(STR0033,STR0071,{STR0041})==1),oDlgPd:End(),NIL)}) //"Atenção","Não há informações de documentos de saída conforme pesquisa para este cliente.",{"OK"}


Return Iif(nOpca == 1,aPedidos,{})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxNFBrMark ºAutor  ³Vendas/CRM         º Data ³  13/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Marcacao de Pedidos da LxPedBrow                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpO1: Objeto do Browse                                     º±±
±±º          ³ExpA2: Array dos pedidos passada por referencia p/ atualizarº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LxNFBrow                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxNFBrMark(oBrowsePd,aPedidos)

Local nPos

If &(oBrowsePd:Alias()+"->OK") == 'LBOK'
	nPos := aScan(aPedidos, &(oBrowsePd:Alias()+"->DOC"))
	aDel(aPedidos, nPos)
	aSize(aPedidos, Len(aPedidos)-1)
	&(oBrowsePd:Alias()+"->OK") := 'LBNO'
	If cPaisLoc == "RUS" .And. Empty(aPedidos)
		cContrControl 	:= ""
		nMoeda			:= 1
		cConuni			:= "2"
	EndIf
Else
	&(oBrowsePd:Alias()+"->OK") := 'LBOK'
	If cPaisLoc != "RUS"
		aAdd(aPedidos,&(oBrowsePd:Alias()+"->DOC"))
	ElseIf cPaisLoc == "RUS" .And. Empty(aPedidos) .And. (M->&(cContrMem)/*M->F1_CNTID*/ == &(oBrowsePd:Alias()+"->CONTRACT") .Or. (Empty(M->&(cContrMem)/*M->F1_CNTID*/) .And. RUXXTS05()));
		.And. (M->&(cMoedaMem)/*M->F1_MOEDA*/ == &(oBrowsePd:Alias()+"->MOEDA") .Or. ((M->&(cMoedaMem)/*M->F1_MOEDA*/ == 1) .And. RUXXTS05()));
		.And. (M->&(cConuniMem)/*M->F1_CONUNI*/ == &(oBrowsePd:Alias()+"->CONUNI") .Or. ((M->&(cConuniMem)/*M->F1_CONUNI*/=="2") .And. RUXXTS05()))
		aAdd(aPedidos,&(oBrowsePd:Alias()+"->DOC"))
		cContrControl := &(oBrowsePd:Alias()+"->CONTRACT")
		nMoeda := &(oBrowsePd:Alias()+"->MOEDA")
		cConuni := &(oBrowsePd:Alias()+"->CONUNI")
	ElseIf cPaisLoc == "RUS" .And. !Empty(aPedidos)
		If cContrControl == &(oBrowsePd:Alias()+"->CONTRACT") .And. nMoeda == &(oBrowsePd:Alias()+"->MOEDA") .And. cConuni == &(oBrowsePd:Alias()+"->CONUNI")
			aAdd(aPedidos,&(oBrowsePd:Alias()+"->DOC"))
		ElseIf cContrControl != &(oBrowsePd:Alias()+"->CONTRACT") .Or. nMoeda != &(oBrowsePd:Alias()+"->MOEDA") .Or. cConuni != &(oBrowsePd:Alias()+"->CONUNI")
			&(oBrowsePd:Alias()+"->OK") := 'LBNO'
			Help("",1,"LocxF4",,STR0200,1,0)
		EndIf
	ElseIf cPaisLoc == "RUS"
		&(oBrowsePd:Alias()+"->OK") := 'LBNO'
		Help("",1,"LocxF4",,STR0200,1,0)
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ChiFillCorºAutor Gabriela Kamimoto     º Data ³  23/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cSerie:  Série do Documento (F1_SERIE,F2_SERIE)            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³Gatilhar o preenchimento do campo F1_NUMCOR/F2_NUMCOR de     ±±
±±º          ³acordo com a utilização da numeração de correlativo definida ±±
±±º          ³no cadastro da série. (TRATAMENTO PARA NF, NDP, NCP - CHILE) ±±
±±º          ³cNumCor: Número Correlativo                                 ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF2                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ChiFillCor(cSerie)
Return LxNCorrChi(cSerie)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³LxExibeSer   ³ Autor ³ Marco Aurelio - Mano    ³ Data ³07/10/11  ³±±
±±³			 ³			   ³ 	   ³ Julio Cesar Guerato	 ³ 		³		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Limpa o campo F1_SERIE2 ou F2_SERIE2 apos gatilhar o campo       ³±±
±±³          ³F1_SERIE ou F2_SERIE quando o conteudo informado for menor que   ³±±
±±³          ³o tamanho total do campo 										   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³LxExibeSer()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT /SIGACOM - Chamada a partir do X7_REGRA do gatilho       ³±±
±±³          ³referente ao campo F1_SERIE2 ou F2_SERIE2.            		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxExibeSer()
Local cCampo 	:= iif(aCfgNf[4]=="SF1","F1_SERIE","F2_SERIE")    //SAliasHead
Local cRet   	:= Space(Len(M->&cCampo))				   	 	  // Conteudo de retorno
Local cFunName	:= FunName()

cCampo:=cCampo+"2" //Serie2

If cFunName $ "MATA101N|MATA466N|MATA102N|MATA143"
	If Len(Alltrim(M->&cCampo)) < 4
		cRet := M->&cCampo
	Else
		cRet := Left(M->&cCampo,2) + Right(M->&cCampo,1)
	EndIf
ElseIf cFunName != "CFGA600"
	If Len(AllTrim(M->&cCampo)) < TamSX3(cCampo)[1]
		cRet := M->&cCampo
		M->&cCampo := Space(Len(M->&cCampo))
	Else
		Aviso(STR0033,STR0065,{"OK"})
	EndIf
EndIf

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldNumCor ºAutor  ³Gabriela Kamimoto   º Data ³  31/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a factura (NF, NCP e NDP) utiliza Número       º±±
±±º          ³  Correlativo e valida o campo F1_SERIE e F2_SERIE.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldNumCor(cSerie)
Local aArea 	 := GetArea()
Local SAliasHead := 4
Local lRet  	 := .T.

Default cSerie 	 := CriaVar("FY_SERIE",.F.)

If (aCfgNF[SAliasHead] == "SF1" .And. SubStr(M->F1_ESPECIE,3,1) <> "I") .Or. (aCfgNF[SAliasHead] == "SF2" .And. SubStr(M->F2_ESPECIE,3,1) <> "I")
	lRet := ExistCpo("SDV")
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A103DelTX    ³ Autor ³   Julio Saraiva         ³ Data ³11/07/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Apaga titulos do tipo TX (Peru)								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103DelTX(aRecSE2)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aRecSE2 = Array com a posicao dos registros                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOCXNF                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103DelTX(aRecSE2)

Local aArea     := GetArea()
Local nX        := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estorno dos titulos a pagar                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT aRecSE2 := {}
For nX := 1 To Len(aRecSE2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estorno dos titulos financeiros                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE2")
	MsGoto(aRecSE2[nX])
	If SE2->E2_TIPO <> "TX"
		SE2->( DbSkip() )
		Loop
	Endif
	If (Existblock("M103DSE2"))
		ExecBlock("M103DSE2",.F.,.F.)
	EndIf
	RecLock('SE2',.F.)
	SE2->( dbDelete() )
	FaAvalSE2(2,"MatA100")
	FaAvalSE2(3,"MatA100")
Next nX
RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxLOkMex   ºAutor  ³Vendas/CRM         º Data ³  01/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacoes LinhaOK para o Mexico itens do LocxNF            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Alias do Item SD2/SD1                                º±±
±±º          ³ExpA2: AHeader do grid de itens                             º±±
±±º          ³ExpA3: Acols do grid de itens                               º±±
±±º          ³ExpC4: Tipo de Documento a gerar - F2/F1_TIPO               º±±
±±º          ³ExpN5: Linha do grid de itens                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL : Falso quando houver critica na validação.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF - MEXICO                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxLOkMex(cAliasI,aCposIOri,aDadosIOri,cTipDoc,nLinha,lFormP,bDoRefresh,bListRefresh)
Return xLinOkMex(cAliasI,aCposIOri,aDadosIOri,cTipDoc,nLinha,lFormP,bDoRefresh,bListRefresh)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxTudOkMex   ºAutor  ³Vendas/CRM       º Data ³  01/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacoes Gravacao para o Mexico do LocxNF                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Tipo de Documento a gerar - F2/F1_TIPO               º±±
±±º          ³ExpC2: Alias do grid de itens                               º±±
±±º          ³ExpA2: AHeader do grid de itens                             º±±
±±º          ³ExpA3: Acols do grid de itens                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL : Falso quando houver critica na validação.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF - MEXICO                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxTudOkMex(cTipoDoc,cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1)
Return xTudOkMex(cTipoDoc,cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxVldItAnt   ºAutor  ³Vendas/CRM       º Data ³  01/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida/Calcula o Valor dos Adiantamento Relacionados ao Itemº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF - Valid de D2_VALADI - MEXICO                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxVldItAnt()
Return xVldItAnt()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxAdianMex   ºAutor  ³Vendas/CRM       º Data ³  01/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada para Tela de Vinculo de Adiantamentos ao Item       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Numero do Documento F1/F2_DOC                        º±±
±±º          ³ExpC2: Condicao de Pagamento                                º±±
±±º          ³ExpN2: Valor Limite para Relacionar Adiantamentos           º±±
±±º          ³ExpA3: Adiantamentos Ja Relacionados                        º±±
±±º          ³ExpL4: Indica se Carrega o Total automaticamente            º±±
±±º          ³ExpC5: Cliente                                              º±±
±±º          ³ExpC6: Loja                                                 º±±
±±º          ³ExpC7: Natureza de operacao                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF - MEXICO                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxAdianMex(cNum, cCondPagto, nTotal, aRecnoSE1, lCarregaTotal, cCodCli, cCodLoja, cNatureza, aHeader)
Return xAdiantMex(cNum, cCondPagto, nTotal, aRecnoSE1, lCarregaTotal, cCodCli, cCodLoja, cNatureza, aHeader)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxD2Imp      ºAutor  ³Vendas/CRM       º Data ³  01/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta Filtro em SD2 para trazer todos os itens que possuam  º±±
±±º          ³ as mesmas aliquotas de impostos de um TES                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: TES utilizada                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpC : String com o Filtro                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINXAPI - MEXICO                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxD2Imp(cTes)
Return LxAlqImp(cTes)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxTesAdi     ºAutor  ³Vendas/CRM       º Data ³  01/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impede a troca de TES após vincular adiantamentos           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL : Falso quando houver adiantamentos relacionados       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LocxNF - D2_TES - MEXICO                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxTesAdi(N)
Return xVldTesAdi(N)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxDelAdt     ºAutor  ³Vendas/CRM       º Data ³  01/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Remove adiantamentos do Item quando apagado ou Tes alterada º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1: Linha do Acols do Grid de Itens                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LocXNF - NfLinOk / LocXNF2 - LxTesAdi  - MEXICO            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxDelAdt(nItem, aCols, aRecnoSE1, N, aHeader, bDoRefresh, bListRefresh)
Return xDelAdtMx(nItem, aCols, aRecnoSE1, N, aHeader, bDoRefresh, bListRefresh)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxBaixaAdt   ºAutor  ³Vendas/CRM       º Data ³  01/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Baixa valores do titulo de adiantamento e grava vinculo da  º±±
±±           ³transacao em FR3 para possibilitar estorno                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1: Array com os titulos RA relacionados                 º±±
±±           ³ExpA2: Caixa do Financeiro, mesmo de GravaFina - LocXNF     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LocXNF - Gravafina - MEXICO                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxBaixaAdt(aRegSE1,aCaixaFin,aCols,aHeader,cNatureza)
Return xBaixaAdt(aRegSE1,aCaixaFin,aCols,aHeader,cNatureza)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxWhenAdt    ºAutor  ³Vendas/CRM       º Data ³  01/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se existem adiantamentos vinculados ao cliente/loja  º±±
±±           ³ou moeda/taxa e impede a mudança nessas situações           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LocXNF - MEXICO - Valid F2_CLIENTE/F2_LOJA                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxWhenAdt()
Return !(MaFisFound("NF") .AND. Type("aRecnoSE1") == "A" .AND. Len(aRecnoSE1) > 0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A465QtdNcc   ³ Autor ³   Vendas/CRM	         ³ Data ³ 18/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a quantidade digitada na rotina de NCC, quando possuir   ³±±
±±³			 ³ um documento original.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOCXNF - MATA465N                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A465QtdNcc()

Local aArea 	:= GetArea()
Local aAreaSD2 	:= SD2->(GetArea())
Local lRet  	:= .T.
Local nPosProd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"} )
//Local nPosQtd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QUANT"} )
Local nPosNfOri	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_NFORI"} )
Local nPosSerie	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_SERIORI"} )
Local nPosItOri	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMORI"} )
If cPaisLoc <> "RUS"
	If M->F1_ESPECIE == "NCC" .And. !Empty(aCols[N][nPosNfOri]) .And. !Empty(aCols[N][nPosSerie]) .And. !Empty(aCols[N][nPosItOri])
		dbSelectArea("SD2")
		dbSetOrder(3)	//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		If MsSeek(xFilial("SD2")+aCols[N][nPosNfOri]+aCols[N][nPosSerie]+M->F1_FORNECE+M->F1_LOJA+aCols[N][nPosProd]+aCols[N][nPosItOri])
			If M->D1_QUANT > SD2->D2_QUANT
				Help(" ",1,"A465NQTNCC")
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaSD2)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ RetForOri   ³ Autor ³   Bruno Schmidt         ³ Data ³ 18/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o Cliente do Documento de Saida						   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOCXNF - MATA465N                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RetForOri(cFilTrf)
Local cForOri	:=	''
Local nTamEmFil	:= Len(cFilTrf+cEmpAnt+cFilAnt)
Local lGestCorp	:= nTamEmFil > Len(SX5->X5_CHAVE)
Local nTA2_COD	:= TamSX3("A2_COD")[1]
Local nTA2_LOJA	:= TamSX3("A2_LOJA")[1]
Local cFilSA2		:= xFilial("SA2")

If lGestCorp // Valida conforme o padrao de inclusao do SX5 pela funcao AddFilSA2()
	If !SM0->(MsSeek(cEmpAnt+cFilTrf))
		Return cForOri
	EndIf
	If SX5->(MsSeek(PadR("",len(cFilAnt))+'75')) //Retornara o primeiro registro com o vinculo entre filial origem+filial destino+fornecedor
		While (SX5->X5_TABELA == "75")
			If (SubSTR(X5Descri(),1,len(cFilAnt)) == cFilTrf) .And. (SubSTR(X5Descri(),len(cFilAnt)+1,len(cEmpAnt)) == cEmpAnt) .And. (SubSTR(X5Descri(),len(cFilAnt+cEmpAnt)+1,len(cFilAnt)) == cFilAnt)
				If SA2->(MsSeek(cFilSA2+SubSTR(AllTrim(X5Descri()),len(cFilTrf+cEmpAnt+cFilAnt)+1,nTA2_COD+nTA2_LOJA) ))
					cForOri  := SubSTR(AllTrim(X5Descri()),len(cFilTrf+cEmpAnt+cFilAnt)+1,nTA2_COD+nTA2_LOJA)
					Exit
				EndIf
			Else
				SX5->(DbSkip())
			EndIf
		EndDo
	EndIf
Else
	If SX5->(MsSeek(xFilial("SX5")+'75'+cFilTrf+cEmpAnt+cFilAnt))  .AND. SA2->(MsSeek(xFilial('SA2')+AllTrim(X5Descri())))
		cForOri  := AllTrim(X5Descri())
	EndIf
EndIf

Return cForOri

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ LocxVLot	   ³ Autor ³   Anieli Rodrigues      ³ Data ³ 22/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega campo de validade apos digitacao do lote				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOCXNF - MATA462TN                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function LocxVLot()

Local aAreaSB8	:= {}
Local cProduto	:= ""
Local cLocal	:= ""
Local nPDtValid := GDFieldPos("D2_DTVALID")
Local nPLocal	:= GDFieldPos("D2_LOCAL")
Local nPLoteCtl := GDFieldPos("D2_LOTECTL")
Local nPNumLote := GDFieldPos("D2_NUMLOTE")
Local nPProduto := GDFieldPos("D2_COD")
Local lRet		:= .T.

cLocal		:= aCols[n][nPLocal]
cProduto 	:= aCols[n][nPProduto]

//Alimenta lote e sublote
If UPPER(ALLTRIM(Readvar())) == "M->D2_LOTECTL"
	cNumLote	:= aCols[n][nPNumLote]
	cLoteCtl 	:= &(ReadVar())
ElseIf UPPER(ALLTRIM(Readvar())) == "M->D2_NUMLOTE"
	cNumLote	:= &(ReadVar())
	cLoteCtl 	:= aCols[n][nPLoteCtl]
EndIf

//Verifica se o produto controla rastreabilidade
If !Rastro(cProduto)
	If (!Empty(&(ReadVar())))
		Help( " ", 1, "NAORASTRO" )
		aCols[n,nPNumLote] 	:= CriaVar( "D2_NUMLOTE" )
		aCols[n,nPLoteCtl]	:= CriaVar( "D2_LOTECTL" )
		aCols[n,nPDtValid]	:= CriaVar( "D2_DTVALID" )
		lRet := .F.
	Else
		aCols[n,nPNumLote]	:= CriaVar( "D2_NUMLOTE" )
		aCols[n,nPLoteCtl]	:= CriaVar( "D2_LOTECTL" )
		aCols[n,nPDtValid]	:= CriaVar( "D2_DTVALID" )
	EndIf
Else
	aAreaSB8 := GetArea()
	SB8->(dbSetOrder(3))
	If SB8->(MsSeek(xFilial("SB8")+cProduto+cLocal+cLoteCtl+IF(Rastro(cProduto,"S"),cNumLote,"")))
		If aCols[n, nPDtValid] # SB8->B8_DTVALID
			Help(" ",1,"A240DTVALI")
			M->C6_DTVALID		:= SB8->B8_DTVALID
			aCols[n,nPDtValid]	:= SB8->B8_DTVALID
		EndIf
	EndIf
	RestArea(aAreaSB8)
EndIf

Return lRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} VldNFCAEA
Função que valida os informações do CAEA, devolve o número e data de venci-
mento do CAEA caso existir.

@author Rafael Iaquinto
@since 23/01/2013
@version 1.0

@param		cFil		Filial do documento.
@param		cSerie		Serie do documento.
@param		cNFiscal	Numero da Nota Fiscal.
@param		lLocxAuto	Verifica se está rodando em rotina automática
@param		cEspecie	Espécie do documento.
@param		dEmiss		Data de emissão do documento.
@param		cCAea		Número do CAEA - Referência.
@param		dVencCaea	Data de vencimento do CAEA. - Referência.

@return	lValid		.T. quando o processo puder continuar.
/*/
//-----------------------------------------------------------------------
Function VldNFCAEA(cFil, cSerie, cNFiscal, lLocxAuto, cEspecie, dEmiss, cCAea, dVencCaea  )

local lRet  		:= .T.
local aRetCAEA		:= {}

Default dVencCaea := CTOD("//")

If cPaisLoc == "ARG"

	lRet  := ExisteCaea(cFil,cSerie,cNFiscal, lLocxAuto,cEspecie,dEmiss,@aRetCAEA)

	If len(aRetCAEA) > 0
		cCAea := aRetCAEA[01]
		dVencCaea := aRetCAEA[05]
	else
		cCAea := ""
		dVencCaea := CTOD("//")
	Endif
Endif

return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funca‡…o  ³LocXImpNF   ³ Autor ³Aline S Damasceno     ³ Data ³14/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega os valores de impostos de bases e item da NF       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocXImpNF(cAlias)
Local nA       := 0
Local aRefImp  := MaFisRelImp('MT100',{cAlias})
Local aAreaAnt := GetArea()
Local aAreaAl := (cAlias)->(GetArea())

MaFisIniLoad(1)
For nA := 1 To Len(aRefImp)
	MaFisLoad(aRefImp[nA][3],FieldGet(FieldPos(aRefImp[nA][2])),1)
Next nA

MaFisEndLoad(1)

RestArea(aAreaAl)
RestArea(aAreaAnt)

Return

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocProvEntºAutor  ³Microsiga           º Data ³  08/20/08   º±±
*/
Function LocProvEn2t()
Local lAltProv	:= .T.		//Indica se deve atualizar ou nao prov.entrega nos itens com a prov.do cabec.
Local lRet		:= .T.
Local nX		:= 0
Local nPosProv	:= 0
Local nProv		:= 0
Local cCpo		:= ""
Local cProv		:= ""
Local SAliasHead := 4

cCpo     := If(aCfgNf[SAliasHead] == "SF2","D2_TES","D1_TES")
nPosTes  := Ascan(aHeader,{|x| Alltrim(x[2]) == cCpo})
cCpo     := If(aCfgNf[SAliasHead] == "SF2","D2_PROVENT","D1_PROVENT")
nPosProv := Ascan(aHeader,{|x| Alltrim(x[2]) == cCpo})
cCpo 	 := If(aCfgNf[SAliasHead] == "SF2",M->F2_PROVENT,M->F1_PROVENT)
lRet 	 := Empty(cCpo) .Or. cCpo == "99" .Or. ExistCpo("SX5","12"+cCpo)

If lRet .And. nPosProv > 0
	If  FunName() $ "MATA143|FISA828" .or.  (Type("lLocxAuto") <> "U" .AND. lLocxAuto )
    	cProv := cCpo
    Else
		cCpo  := ReadVar()
		cProv := &cCpo
    EndIf
	//PE p/ permitir ou nao alterar as provincias dos itens/cabecalho c/ a prov. do Forn/Cli/cabec.
	cPe	:=	LocxPE(55)
	If !Empty(cPe)
		lAltProv := Execblock(cPE,.F.,.F.,{cCpo,cProv,cProv})
		If ValType(lAltProv) <> "L"
			lAltProv := .T.
		EndIf
	EndIf

	If lAltProv .and. !Empty(cProv)
		MaFisAlt("NF_PROVENT",cProv)
	EndIf

	For nX := 1 To Len(aCols)
		cTes := aCols[nX,nPosTes]
		if VerProEnIt(cProv,cTes,.F.,.F.)
			If lAltProv .Or. Empty(aCols[nX,nPosProv])
				aCols[nX,nPosProv] := cProv
			EndIf
			MaFisAlt("IT_PROVENT",aCols[nX,nPosProv],nX)
		Else
			nProv++
		Endif
	Next
	If Type('oGetDados:oBrowse') == "O"
		oGetDados:oBrowse:Refresh()
	Endif
	If nProv > 0
		MsgAlert(STR0118,STR0033) // "Algunos items no tuvieron el estado modificado pues tienen impuestos grabados en un mismo campo." ## "¡Atencion!"
	Endif
Endif
Return lRet

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocProEnItºAutor  ³Microsiga           º Data ³  08/20/08   º±±
*/
Function LocProEnI2t()
Local lRet		:= .T.
Local nPosTes	:= 0
Local cCpo		:= ""
Local cProv		:= ""
Local cTes		:= ""
Local SAliasHead := 4

cCpo  	:= ReadVar()
cProv 	:= &cCpo
cCpo	:= If(aCfgNf[SAliasHead] == "SF2","D2_TES","D1_TES")
nPosTes := Ascan(aHeader,{|x| Alltrim(x[2]) == cCpo})
cTes 	:= aCols[n,nPosTes]
lRet 	:= VerProEnIt(cProv,cTes)
Return(lRet)
/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocProvTesºAutor  ³Microsiga           º Data ³  08/20/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
Function LocProvTe2s()
Local lRet		:= .T.
Local nPosProv	:= 0
Local cCpo		:= ""
Local cProv		:= ""
Local SAliasHead := 4

cCpo  := ReadVar()
cTes := &cCpo
cCpo := If(aCfgNf[SAliasHead] == "SF2","D2_PROVENT","D1_PROVENT")
nPosProv := Ascan(aHeader,{|x| Alltrim(x[2]) == cCpo})
If nPosProv > 0
	cProv := aCols[n,nPosProv]
	lRet := VerProEnIt(cProv,cTes,.T.,.F.)
Endif
Return lRet
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³VerProEnItºAutor  ³Microsiga           º Data ³  08/20/08   º±±
Function VerProEnI2t(cProv,cTes,lMsg,lVerPro)
Local aSFC	 	:= {}
Local lRet		:= .T.
Local cCpo		:= ""
Local cFilSFC	:= ""
Local cFilSFB	:= ""
Default lMsg := .T.
Default lVerPro := .T.

If lVerPro
	lRet := Empty(cProv) .Or. cProv == "99" .Or. ExistCpo("SX5","12"+cProv)
Else
	lRet := .T.
Endif
If lRet
	If cProv == "99"
		aSFC := SFC->(GetArea())
		SFC->(DbSetOrder(2))
		cFilSFC := xFilial("SFC")
		cFilSFB := xFilial("SFB")
		SFC->(DbSeek(cFilSFC + cTes))
		cCpo := ""
		While !(SFC->(Eof())) .And. lRet .And. SFC->FC_FILIAL == cFilSFC .And. SFC->FC_TES == cTes
			If SFB->(MsSeek(cFilSFB + SFC->FC_IMPOSTO))
				If At(SFB->FB_CPOLVRO,cCpo) == 0
					cCpo += SFB->FB_CPOLVRO
				Else
					If lMsg
						MsgStop(STR0119,STR0033) //"Hay impuestos siendo grabados en el mismo campo. Para utilizar el estado 99, es necesario que los impuestos se graben en campos distintos. Verifique los impuestos utilizados en este TES."## "¡Atencion!"
					Endif
					lRet := .F.
				Endif
			Endif
			SFC->(DbSkip())
		Enddo
		SFC->(RestArea(aSFC))
	Endif
Endif
Return(lRet)
/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocEmisProºAutor  ³Microsiga           º Data ³  08/20/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
Function LocEmisPr2o()
MaColsToFis(aHeader,aCols,,"MT100",.T.,,.T.)
Return(.T.)

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValTpDocPerº Autor  ³Microsiga         º Data ³  19/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
Function ValTpDocPer()
Local aArea			:= GetArea()
Local nTamCodGov	:= TamSX3("CCL_CODGOV")[1]
Local lRet			:= .T.

dbSelectArea("SXB")
dbSetOrder(1)

If SXB->(DbSeek("CCL   501"))
	If 'CCL_CODGOV' $ SXB->XB_CONTEM
		If Len(AllTrim(M->F1_TPDOC)) > nTamCodGov
			Help("  ",1,"REGNOIS")
			lRet := .F.
		Else
			lRet := ExistCpo("CCL",M->F1_TPDOC,2)
		EndIf
	ElseIf ('F1_TPDOC' $ READVAR())
		lRet := ExistCpo("CCL",M->F1_TPDOC,2)
	EndIf
EndIf

If M->F1_TPDOC == "05" .And. !(((VAL(M->F1_SERIE) >= 1 .AND. VAL(M->F1_SERIE) <= 5)) .Or. ((VAL(M->F1_SERIE2) >= 1 .AND. VAL(M->F1_SERIE2) <= 5)))
	MsgAlert(STR0178,STR0033)
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³LxLOkPer   ºAutor  ³Laura Medina       º Data ³  11/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacoes LinhaOK para o Peru itens do LocxNF              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Alias do Item SD2/SD1                                º±±
±±º          ³ExpA2: AHeader do grid de itens                             º±±
±±º          ³ExpA3: Acols do grid de itens                               º±±
±±º          ³ExpC4: Tipo de Documento a gerar - F2/F1_TIPO               º±±
±±º          ³ExpN5: Linha do grid de itens                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL : Falso quando houver critica na validação.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF - PERU                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxLOkPer(cAliasI,aCposIOri,aDadosIOri,cTipDoc,nLinha,lFormP, aCfgNF, cEspecie, cCondicao, nSalvaN, aHeader, aCols, cFunname)
Return LxLinOkPer(cAliasI,aCposIOri,aDadosIOri,cTipDoc,nLinha,lFormP, aCfgNF, cEspecie, cCondicao, nSalvaN, aHeader, aCols, cFunname)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxTudOkPer ºAutor  ³ Laura Medina      º Data ³  11/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validaciones de grabacion para Peru en la funcion LocxNF.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Tipo de Documento a gerar - F2/F1_TIPO               º±±
±±º          ³ExpC2: Alias do grid de itens                               º±±
±±º          ³ExpA2: AHeader do grid de itens                             º±±
±±º          ³ExpA3: Acols do grid de itens                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL : Falso quando houver critica na validação.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF - PERU                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxTudOkPer(cTipoDoc,cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1)
Return CondNatPer(cTipoDoc,cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1)
//-------------------------------------------------------------------
/*/{Protheus.doc} xFilPVArg
Função utilizada para filtrar SX5 com as séries que determinado PV possui.
Essa função, a principio, será usada somente para Argentina.

@author Leandro Prado
@since 24/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function xFilPVArg()
Return FilPVArg()
//-------------------------------------------------------------------
/*/{Protheus.doc} GrvRG1415
Função utilizada para preencer o campo correspondente ao RG1415 nas
tabelas SF1 e SF2.

@author Leandro Prado
@since 24/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function GrvRG1415(aNfs)
Return ArgRG1415(aNfs)
//-------------------------------------------------------------------
/*/{Protheus.doc} LxNFRG1415
Função utilizada para preencer o campo correspondente ao RG1415 nas
tabelas SF1 e SF2.

@author Leandro Prado
@since 24/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function LxNFRG1415(cAlias, cSerie, cEspec,cPV,cSerieP,nVlrDoc,lMata468n)
Return xNFRG1415(cAlias, cSerie, cEspec,cPV,cSerieP,nVlrDoc,lMata468n)

//-------------------------------------------------------------------
/*/{Protheus.doc} LNF2VldSer
Função utilizada para validar se a série informada pode ser utilizada;
Baseando-se na regra de relacionamento entre o ponto de venda e a SFP.
Rotina usada no controle de ponto de venda - Argentina.
@author Leandro Prado
@since 10/03/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function LNF2VldSer()
Return LArgVldSer(cLocxNFPV)

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSERNF
Função utilizada para tratar a série, retirando conteúdo do ponto de venda para Argentina;
Usada no retorno da consulta padrão SERNF.
@Param cSerie - série a ser tratada.

@author Leandro Prado
@since 20/03/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function RetSERNF(cSerie)
Local cRet := ""

If cPaisLoc == "ARG"
	If Len(AllTrim(cSerie)) = 6
		cRet := SubStr(cSerie,1,3)
	ElseIf Len(AllTrim(cSerie)) = 5
		cRet := SubStr(cSerie,1,2)
	ElseIf Len(AllTrim(cSerie)) = 4
		cRet := SubStr(cSerie,1,1)
	Else
		cRet := AllTrim(cSerie)
	EndIf
Else
	cRet := Left(cSerie,3)
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CBANFDel
Faz o estorno automatico do C.Q

@author Flavio Lopes Rasta
@since 29/04/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function CBANFDel()
Local lRet 		:= .T.
Local aSD1CQ		:= {}
Local cSeek		:= ""
Local lRastro		:= Nil
Local nCounter	:= 0
Local nX			:= 0

aSD1CQ := VerifCQ(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)
If !Empty(aSD1CQ)
	nCounter := 0
	For nX := 1 to len(aSD1CQ)
		cSeek:=xFilial("SDB")+aSD1CQ[nX,1]+aSD1CQ[nX,2]+aSD1CQ[nX,3]+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
		lRastro  := Rastro(aSD1CQ[nX,1])
		SDB->(DbSetOrder(1))
		If SDB->(DbSeek(cSeek))
			Do While SDB->(!EOF()) .And. SDB->(DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA) == cSeek
				If SDB->DB_TM > "500" .Or. SDB->DB_TIPO # "D"
					SDB->(DbSkip())
					Loop
				EndIf
				If lRastro .And. !(aSD1CQ[nX,5]==SDB->DB_LOTECTL)
					SDB->(DbSkip())
					Loop
				EndIf
				If SDB->DB_ESTORNO # "S"
					nCounter++
				EndIf
				SDB->(DbSkip())
			Enddo
		EndIf
	Next

	If nCounter > 0
		If ! Empty(GetMV("MV_CBCQEND"))
			//Converter para Aviso
			If MSGBOX(STR0122,STR0033,"YESNO")//"Confirma o estorno do enderecamento de C.Q."###"Atenção!"
				Processa({||DistriCQ(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,.t.)})
			Else
				lRet := .F.
			EndIf
		EndIf
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CBSF1EXC
Faz ajuste do CB0 apos a exclusao da Nota

@author Flavio Lopes Rasta
@since 29/04/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function CBSF1EXC()

CB0->(DbSetOrder(6))
While CB0->(DbSeek(xFilial("CB0")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	CB0->(CbLog("05",{CB0_CODPRO,CB0_QTDE,CB0_LOTE,CB0_NFENT,CB0_SERIEE,CB0_FORNEC,CB0_LOJAFO,CB0_LOCAL,CB0_CODETI,"Estorno"}))
	CB0->(Reclock("CB0",.F.))
	CB0->CB0_NFENT  := " "
	CB0->CB0_SERIEE := " "
	CB0->CB0_LOTE   := " "
	CB0->CB0_LOCAL  := " "
	CB0->CB0_ITNFE  := " "
	CB0->(MsUnlock())
Enddo
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LocxConf
Cria folder de conferência fisica

@author Flavio Lopes Rasta
@since 30/04/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function LocxConf(oDlg)
Local oList
Local nQtdConf := 0
Local cStatCon := ""
Local lClaNfCfDv 	:= .F.
Local aListBox   := {}
Local oEnable    := LoadBitmap( GetResources(), "ENABLE" )
Local oDisable   := LoadBitmap( GetResources(), "DISABLE" )
Local oConf
Local oStatCon

Do Case
Case SF1->F1_STATCON $ "1 "
	cStatCon := STR0123 // "Conferido"
Case SF1->F1_STATCON == "0"
	cStatCon := STR0124 //"Não conferido"
Case SF1->F1_STATCON == "2"
	cStatCon := STR0125 // "Com divergência"
Case SF1->F1_STATCON == "3"
	cStatCon := STR0126 // "Em conferência"
Case SF1->F1_STATCON == "4"
	cStatCon := STR0127 //"Clas. C/ Diver."
EndCase
nQtdConf := SF1->F1_QTDCONF
@ 06 ,11.78709677 SAY STR0128 OF oDlg PIXEL SIZE 49,09 // "Status"
@ 05 ,66.79354839 MSGET oStatCon VAR Upper(cStatCon) COLOR CLR_RED OF oDlg PIXEL SIZE 70,9 When .F.
@ 25 ,11.78709677 SAY STR0129 OF oDlg PIXEL SIZE 49,09 // "Conferentes"
@ 24 ,66.79354839 MSGET oConf Var nQtdConf OF oDlg PIXEL SIZE 70,09 When .F.
@ 05 ,150 LISTBOX oList Fields HEADER "  ",STR0130,STR0131 SIZE 170, 48 OF oDlg PIXEL // "Codigo","Quantidade Conferida"
oList:BLDblclick := {||A103DetCon(oList,aListBox)}

@ 30 ,330 BUTTON STR0132 SIZE 40 ,11  FONT oDlg:oFont ACTION (LocxAtuCon(oList,aListBox,oEnable,oDisable,oConf,@nQtdConf,oStatCon,@cStatCon,.T.,)) OF oDlg PIXEL When SF1->F1_STATCON == '2' .And. !lClaNfCfDv // "Recontagem"
@ 42 ,330 BUTTON STR0133 SIZE 40 ,11  FONT oDlg:oFont ACTION (LocxAtuCon(oList,aListBox)) OF oDlg PIXEL // "Detalhes"

LocxAtuCon(oList,aListBox,oEnable,oDisable)

Return oList
//-------------------------------------------------------------------
/*/{Protheus.doc} LocxAtuCon
Atualiza o folder de conferência fisica

@author Flavio Lopes Rasta
@since 30/04/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function LocxAtuCon(oList,aListBox,oEnable,oDisable,oConf,nQtdConf,oStatCon,cStatCon,lReconta)

Local aArea     := {}
Local cAliasOld := Alias()


lReconta := If (lReconta == nil,.F.,lReconta)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Habilita recontagem³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lReconta .And. (Aviso(STR0134,STR0135,{STR0005,STR0006}) == 1)//"AVISO"###"Voce realmente quer fazer a recontagem?"###"Sim","Nao"
	If Reclock("SF1",.F.)
		SF1->F1_STATCON := "0"
		SF1->(msUnlock())
	EndIf
	dbSelectArea("CBE")
	dbsetOrder(2)
	MsSeek(xFilial("CBE")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	While !eof() .and. CBE->CBE_NOTA+CBE->CBE_SERIE == SF1->F1_DOC+SF1->F1_SERIE .and.;
			CBE->CBE_FORNEC+CBE->CBE_LOJA == SF1->F1_FORNECE+SF1->F1_LOJA
		If reclock("CBE",.F.)
			CBE->(dbDelete())
			CBE->(msUnlock())
		EndIf
		dbSelectArea("CBE")
		dbSkip()
	EndDo
Else
	lReconta := .F.
EndIf

aListBox := {}
dbSelectArea("SD1")
aArea := GetArea()

MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE)

While !EOF() .and. SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE == SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for a opcao RECONTAGEM, zera tudo o que foi conferido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lReconta
		Reclock("SD1",.F.)
		SD1->D1_QTDCONF := 0
		SD1->(msUnlock())
	EndIf
	aAdd(aListBox,{SD1->D1_COD,SD1->D1_QTDCONF,SD1->D1_QUANT})
	dbSkip()
End
If ValType(oList) == "O"
	oList:SetArray(aListBox)
	oList:bLine := { || {If (aListBox[oList:nAT,2] == aListBox[oList:nAT,3],oEnable,oDisable), aListBox[oList:nAT,1], aListBox[oList:nAT,2]} }
	oList:Refresh()
EndIf
RestArea(aArea)
dbSelectArea(cAliasOld)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os Gets³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(oConf) == "O"
	SF1->(dbSkip(-1))
	If !SF1->(BOF())
		SF1->(dbSkip())
	EndIf
	nQtdConf := SF1->F1_QTDCONF
	oConf:Refresh()
EndIf

If ValType(oStatCon) == "O"
	Do Case
	Case SF1->F1_STATCON == '1'
		cStatCon := STR0123 // "Conferido"
	Case SF1->F1_STATCON == "0"
		cStatCon := STR0124 //"Não conferido"
	Case SF1->F1_STATCON == "2"
		cStatCon := STR0125 // "Com divergência"
	Case SF1->F1_STATCON == "3"
		cStatCon := STR0126 // "Em conferência"
	Case SF1->F1_STATCON == "4"
		cStatCon := STR0127 //"Clas. C/ Diver."
	EndCase
	nQtdConf := SF1->F1_QTDCONF
	oStatCon:Refresh()
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} LocxVlCon
Valida ativação da conferencia fisica

@author Flavio Lopes Rasta
@since 30/04/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function LocxVlCon(lDeleta)
Local lRet := .F.

If l103Visual .AND. !lDeleta .AND. !Empty(SF1->F1_STATUS) .And. SuperGetMV("MV_CONFFIS",.F.,"N") == "S"
	lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} LoadPergs
Popula o aPergs diretamente do SX1

@author Douglas Godeguez Nunes
@since 05/05/2014
@version 1.0

/*/
//----------------------
Function LoadPergs (aPerg, aPergs)
SX1->(DbSetOrder(1))
SX1->(DbSeek(aPerg[1]))
While !SX1->(Eof()) .AND. AllTrim(SX1->X1_GRUPO) == aPerg[1]
	AAdd(aPergs, &(SX1->X1_VAR01)==1)
	SX1->(DbSkip())
EndDo
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F4ForTOk   ³ Autor ³ Manuela Cavalcante  ³ Data ³12.03.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ ±±
±±³Descri‡…o ³Função para validação ao confirmar a seleção de Pedidos de  ±±
              Compra na Factura de entrada.                               ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function F4ForTOk(aF4For)

Local lRet := .T.
Local cPe	:= ""

cPe	:=	LocxPE(78) //PE para validação da seleção de Pedidos de Compra na Factura de Entrada.
If !Empty(cPE)
	lRet := ExecBlock(cPe,.F.,.F.,{aF4For})
Endif

Return lRet

/*
±±ºPrograma  ³ VldWhen     ºAutor  ³Laura Medina        º Data ³  01/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Para permitir edita el Folio Fiscal/Timbre y Fecha            º±±*/
Function VldWhen(lTabla)
Return VldWhenMex(lTabla)

/*
±±ºPrograma  ³ F3_UUID     ºAutor  ³Laura Medina        º Data ³  01/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta especifica para los Folios Fiscales.                 º±±*/
Function F3_UUID()
Return LxUUIDMex()

/*
±±ºPrograma  ³ copyXML     ºAutor  ³Laura Medina        º Data ³  06/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Copia el NF-XML a la carpeta de procesados                    º±±*/
Function copyXML()
Return copyXMLMex()

/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FilToRemTop ³ Autor ³ Vendas/CRM		    ³ Data ³26.06.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecao de remitos para NF de entrada (TOPCONNECT)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOCXNF/MATA465N                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/
Function FilToRemTop(cCliFor,cLoja,cTipo,cTpDoc,nRemito,nSeriRem,nItemRem)

	Local aRet		:= {.T.}
	Local cQrySD1 	:= ""
	Local cQrySF1 	:= ""
	Local cAlias  	:= GetNextAlias()
	Local cAlias2 	:= GetNextAlias()
	Local cTempTab	:= "__LOCXSF1"
	Local aStruSF1	:= SF1->(dbStruct())
	Local aOrdem	:= {"F1_FILIAL", "F1_FORNECE", "F1_LOJA", "F1_DOC"}
	Local aAreaSF1	:= SF1->(GetArea())
	Local nX		:= 0

	cQrySD1 := "SELECT * FROM "+RetSqlName("SD1")+" SD1  WHERE "
	cQrySD1 += "SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND "
	cQrySD1 += "SD1.D1_FORNECE = '" + cCliFor + "' AND "
	cQrySD1 += "SD1.D1_LOJA = '" + cLoja + "' AND "
	cQrySD1 += "SD1.D1_DTDIGIT <= '" + DToS(dDataBase) + "' AND "
	cQrySD1 += "SD1.D1_QTDACLA > 0 AND "
	cQrySD1 += "SD1.D1_TIPO = '" + cTipo + "' AND "
	cQrySD1 += "SD1.D1_TIPODOC IN " + FormatIn(cTpDoc,"/") + " AND "
	cQrySD1 += "SD1.D_E_L_E_T_ = ' ' "
	cQrySD1 += "ORDER BY " + SqlOrder(SD1->(IndexKey(10)))

	cQrySD1 := ChangeQuery(cQrySD1)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQrySD1),cAlias,.T.,.T.)

	While !(cAlias)->(Eof())
		If Ascan(aColsSD1,{ |X| X[nRemito]+X[nSeriRem]+X[nItemRem] == (cAlias)->D1_DOC+(cAlias)->D1_SERIE+(cAlias)->D1_ITEM .And. !X[Len(aHeader)+1]}) == 0
			Aadd(aFiltro,{(cAlias)->D1_FILIAL+(cAlias)->D1_DOC+(cAlias)->D1_SERIE+(cAlias)->D1_FORNECE+(cAlias)->D1_LOJA+(cAlias)->D1_TIPO,(cAlias)->R_E_C_N_O_})
		EndIf
		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())

	If !Empty(aFiltro)
		If Select(cAlias2) > 0
			(cAlias2)->(dbCloseArea())
		EndIf

		cQrySF1 := "SELECT R_E_C_N_O_ RECNOSF1 FROM "+RetSqlName("SF1")+" SF1  WHERE "
		cQrySF1 += "SF1.F1_FILIAL = '" + xFilial("SF1") + "' AND "
		cQrySF1 += "SF1.F1_FORNECE = '" + cCliFor + "' AND "
		cQrySF1 += "SF1.F1_LOJA = '" + cLoja + "' AND "
		cQrySF1 += "SF1.F1_DTDIGIT <= '" + DToS(dDataBase) + "' AND "
		cQrySF1 += "SF1.F1_TIPO = '" + cTipo + "' AND "
		cQrySF1 += "SF1.F1_TIPODOC IN " + FormatIn(cTpDoc,"/") + " AND "
		cQrySF1 += "SF1.D_E_L_E_T_ = ' ' "
		cQrySF1 += "ORDER BY " + SqlOrder(SF1->(IndexKey(2)))

		cQrySF1 := ChangeQuery(cQrySF1)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQrySF1),cAlias2,.T.,.T.)

		If !(cAlias2)->(Eof())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria arquivo de dados temporário ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IIf(Select(cTempTab)>0,(cTempTab)->(dbCloseArea()),Nil)
			oTmpRemito := FWTemporaryTable():New(cTempTab)
			oTmpRemito:SetFields(aStruSF1)
			oTmpRemito:AddIndex("I1", aOrdem)
			oTmpRemito:Create()

			(cAlias2)->(dbGoTop())
			While !(cAlias2)->(Eof())
				SF1->(dbGoto((cAlias2)->RECNOSF1))
				RecLock(cTempTab, .T.)
				For nX := 1 to Len(aStruSF1)
					(cTempTab)->&(aStruSF1[nX,1]) := SF1->&(aStruSF1[nX,1])
				Next nX
				(cAlias2)->(dbSkip())
			EndDo

			(cAlias2)->(dbCloseArea())
			SF1->(RestArea(aAreaSF1))

			aAdd(aRet,cTempTab)
		EndIf
	EndIf

Return aRet

/*
±±ºPrograma  ³ AtuLotEnd   ºAutor  ³ Materiais          º Data ³  25/11/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o Lote / Endereco no Remito                          º±±*/
Function AtuLotEnd()

Local aAreaSD2		:= SD2->(GetArea())
Local aAreaSD5		:= SD5->(GetArea())

If Rastro(SD2->D2_COD) .And. Empty(SD2->D2_LOTECTL)
	SD5->(dbSetOrder(3))
	If SD5->(MsSeek(xFilial("SD5")+SD2->D2_NUMSEQ, .F.))
		Reclock("SD2",.F.)
		SD2->D2_LOTECTL := SD5->D5_LOTECTL
		SD2->D2_NUMLOTE := SD5->D5_NUMLOTE
		SD2->(MsUnlock())
	EndIf
EndIf

RestArea(aAreaSD5)
RestArea(aAreaSD2)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} a410VldPMS

Rotina para validar as colunas do browse de itens na nota de saída.
Colunas de Projeto, EDT e Tarefa referentes ao sigapms

@param cD2_PROJPMS - projeto a ser validado
@param cD2_EDTPMS  - codigo da EDT a ser validada
@param cD2_TASKPMS - codigo da tarefa a ser validada

@return lógico

@author William Pianheri
@since 01/02/2016
/*/
//-------------------------------------------------------------------
Function a467VldPMS( cD2_PROJPMS ,cD2_EDTPMS ,cD2_TASKPMS)
Local lOk   := .F.
Local aArea := GetArea()

If Empty(cD2_PROJPMS)
    //nao esta amarrado ao projeto
    lOk := .T.
Else
	dbSelectArea('AF8')
    AF8->(dbSetOrder(1))
    If AF8->(dbSeek(xFilial("AF8")+cD2_PROJPMS ))

        Do Case
            Case (!Empty(cD2_EDTPMS) .AND. !Empty(cD2_TASKPMS))
                //EDT e Tarefa preenchidas
                HELP("   ",1,"VLDPMSFAT",,STR0136 + CRLF + STR0137 ,1) //"Não pode existir referência do Código da" " EDT e Codigo da Tarefa no mesmo item."

            Case (Empty(cD2_EDTPMS) .AND. Empty(cD2_TASKPMS))
                //EDT e Tarefa não preenchidas
                HELP("   ",1,"VLDTSKEXIST",,STR0138 ,1) //"O item de venda não pode estar amarrado unicamente a um projeto!"

            Case !Empty(cD2_EDTPMS)
                //EDT preenchida
                dbSelectArea('AFC')
                AFC->(DbSetOrder(1))
                If AFC->(DbSeek(xFilial("AFC")+AF8->AF8_PROJET+AF8->AF8_REVISA+cD2_EDTPMS ))
                    // a EDT eh faturavel
                    If AFC->AFC_FATURA=="1"
                        lOk := .T.
                    Else
                        HELP("   ",1,"VLDEDTFAT",,STR0139,1) //"Esta EDT nao tem permissao para ser faturada."
                    EndIf
                Else
                    HELP("   ",1,"VLDEDTEXIST",,STR0140 ,1) //"O Código da EDT informado não existe."
                EndIf

            Case !Empty(cD2_TASKPMS)
                //Tarefa preenchida
                dbSelectArea('AF9')
                AF9->(dbSetOrder(1))
                If AF9->(dbSeek(xFilial("AF9")+AF8->AF8_PROJET+AF8->AF8_REVISA+cD2_TASKPMS ))
                    // a TAREFA eh faturavel
                    If AF9->AF9_FATURA=="1"
                        lOk := .T.
                    Else
                        HELP("   ",1,"VLDTSKRFAT",,STR0141,1) //"Esta tarefa nao tem permissao para ser faturada."
                    EndIf
                Else
                    HELP("   ",1,"VLDTSKEXIST",,STR0142 ,1) //"O Código de Tarefa informado não existe."
                EndIf
        EndCase

    Else
        //O projeto nao existe
        HELP("   ",1,"VLDPRJEXIST",,STR0143 ,1) //"O Código de Projeto informado não existe."
    EndIf
EndIf

RestArea( aArea )

Return( lOk )

/*³Fun‡…o    ³LxTESAutoCOL³ Autor ³ Marco Augusto Glz. R. ³ Data ³06/05/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Automatiza el uso de TES y CF en Compras y Facturacion. (COL)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ LxTESAutoCOL(ExpC1, ExpC2, ExpC3, ExpC4, ExpC5)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo de cliente o proveedor                        ³±±
±±³          ³ ExpC2 = Codigo de Tienda                                     ³±±
±±³          ³ ExpC3 = Codigo de Producto                                   ³±±
±±³          ³ ExpC4 = Identifica el retorno, ya sea TES o CF               ³±±
±±³          ³ ExpC5 = Identifica la tabla a utilizar, la cual es SD1 o SD2 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ cTES = Tipo de Entrada o Salida                              ³±±
±±³          ³ cCodFisc = Codigo Fiscal                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ En campos C6_PRODUTO, C7_PRODUTO, D1_COD y D2_COD            ³*/
Function LxTESAutoCOL(cClieProve, cTienda, cProducto, cTipo, cMovimiento)
Return xAutTesCOL(cClieProve, cTienda, cProducto, cTipo, cMovimiento)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³BaixaAdt    ³ Rev.  ³Jonathan Glez Rivera   ³ Data ³ 20/09/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cancela Baixa dos Adiantamentos - Mexico                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico .T. para sucesso  - .F. falha                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function BaixaAdt()
Return fxBaixaAdt()


Function nRetOrdem(cAliasEsp)
	Local cUltCpo	:= ""
	Local aCpos		:= {}
	Local nCpo		:= 0
	Local nUlt		:= 0
	Local nCpoArray	:= 1
	Local nUltTmp	:= 0
	Local aArrayTmp	:= {}
	Local nPosCpo   := 0
	Local nX		:= 0

	Default cAliasEsp := ""

	If cAliasEsp == "SF2"
		If aScan(aAutoCab,{|x| AllTrim(x[1]) == "F2_DESCONT" .and. x[2] > 0}) > 0
			aCpos := {{"D2_DESCON"},{"IT_DESCONTO"}}
		Else
			aCpos:={{"D2_TOTAL","D2_TES","D2_DESCON","D2_PROVENT"},{"IT_VALMERC","IT_TES","IT_DESCONTO","IT_PROVENT"}}
		EndIf

	Else
		If aScan(aAutoCab,{|x| AllTrim(x[1]) == "F1_DESCONT" .and. x[2] > 0}) > 0
			aCpos := {{"D1_VALDESC"},{"IT_DESCONTO"}}
		Else
			aCpos:={{"D1_TOTAL","D1_TES","D1_VALDESC","D1_PROVENT"},{"IT_VALMERC","IT_TES","IT_DESCONTO","IT_PROVENT"}}
		EndIf
	EndIf

	For nCpo := 1 To Len(aCpos[1])
		nUltTmp := Val(RetAsc(Posicione("SX3",2,aCpos[1,nCpo],"X3_ORDEM"),3,.F.))
		If nUltTmp > nUlt .and. 0 < aScan(aAutoItens[1],{|x| x[1] == aCpos[1,nCpo]})
			nCpoArray := nCpo
			nUlt := nUltTmp
		EndIf
	Next nCpo

	For nX := 1 To Len(aAutoItens)
		If !(aCpos[1,nCpoArray] == aAutoItens[nX][Len(aAutoItens[nX])][1])
			nPosCpo := aScan(aAutoItens[nX],{|x| AllTrim(x[1]) == aCpos[1,nCpoArray]})
			If nPosCpo > 0
				aArrayTmp := aAutoItens[nX][nPosCpo]
				ADEL(aAutoItens[nX], nPosCpo)
				ASIZE(aAutoItens[nX], Len(aAutoItens[nX])-1)
				AADD(aAutoItens[nX],aArrayTmp)
			EndIf
		EndIf
	Next nX

	cUltCpo := aCpos[2,nCpoArray]

Return cUltCpo

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³VldNFApoc   ³ Rev.  ³Luis Enriquez	      ³ Data ³ 08/02/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validar si el cliente o proveedor pertenece al padrón de factu  ³±±
±±³          ³ras apócrifas.                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VldNFApoc(cTipContr,cTblSF)
Return xVldNFApoc(cTipContr,cTblSF)


/*/
±±³Fun‡…o    ³ ValidaVig   ³ Autor ³ Raul Ortiz         ³ Data ³12.01.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida la vigencia de 3 meses de una NF                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M100XIBP/M460XIBP/M100XIB2/M460XIB2                        ³±±
/*/
Function ValidaVig(dFechaO,dFechaV)
Return xValidaVig(dFechaO,dFechaV)

/*
ºPrograma  ³CargaRATCCºAutor  ³Leandro C.G.        º Data ³  20/03/02   º
ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
ºDesc.     ³Chama a tela que efetua o rateio por centro de custos       º
*/
Function CargaRatCC()
Local nPosItem		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEM"   })
Local nPosCC		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_CCUSTO" })
Local nPosConta		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_CONTA"  })
Local nPosItemCta	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEMCC" })
Local nPosCLVL		:= Ascan(aHeader,{|x| AllTrim(x[2]) == "D2_CLVL"   })
Local nPosRateio	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_RATEIO" })
//Local nPosRemito	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_REMITO" })
//Local nPosItemRem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEMREM"})

If nPosItem > 0 .And. nPosCC > 0 .And. nPosConta > 0 .And. nPosItemCta > 0 .And. nPosClVl > 0 .And. nPosRateio > 0
    If !lInclui
		aRatCC := BuscaAGH()[3]
    EndIf
	NCPRatCC()
Else
	Alert(STR0177 + CHR(10) + ; //"Para utilizar esta opcion se requiere que los siguientes campos esten en uso y disponibles:"
	"D2_ITEM"    + CHR(10) + ;
	"D2_CC"      + CHR(10) + ;
	"D2_CONTA"   + CHR(10) + ;
	"D2_ITEMCTA" + CHR(10) + ;
	"D2_CLVL"    + CHR(10) + ;
	"D2_RATEIO")
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LxNCPRatCC ³ Autor ³ Edson Maricate       ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a tela rateios por Conta Contabil / Centro de Custos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NCPRATCC(cRatVld)

Local bSavKeyF4 	:= SetKey(VK_F4,Nil)
Local bSavKeyF5 	:= SetKey(VK_F5,Nil)
Local bSavKeyF6 	:= SetKey(VK_F6,Nil)
Local bSavKeyF7 	:= SetKey(VK_F7,Nil)
Local bSavKeyF8 	:= SetKey(VK_F8,Nil)
Local bSavKeyF9 	:= SetKey(VK_F9,Nil)
Local bSavKeyF10	:= SetKey(VK_F10,Nil)
Local bSavKeyF11	:= SetKey(VK_F11,Nil)
Local cPe			:= ""
Local nPosItem		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEM"} )
Local nPosCC		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_CCUSTO"} )
Local nPosConta		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_CONTA"} )
Local nPosItemCta	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEMCC"} )
Local nPosCLVL		:= Ascan(aHeader,{|x| AllTrim(x[2]) == "D2_CLVL"} )
Local nPosRateio	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_RATEIO"} )
//Local nPosRemito	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_REMITO"	} )
//Local nPosItemRem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEMREM"	} )
Local nPosRat		:= aScan(aRatCC,{|x| x[1] == aCols[n][nPosItem]})
Local aSavaRotina	:= aClone(aRotina)
Local aSavCols		:= aCols
Local aSavHeader	:= aClone(aHeader)
Local nSavN			:= n
Local nUsado		:= 0
Local nOpc			:= 0
Local nTotPerc		:= 0
Local nPosPerc		:= 0
Local nX			:= 0
Local nY			:= 0
Local oDlg
Local oGetDados
Local lContinua 	:= .T.
Local aButtons 		:= {}
Local nNewTam
Local aColsPar		:= {}
Local lNovo			:= .T.
Local oSize

Private nPercRat    := 0
Private nPercARat	:= 100
Private oPercRat
Private oPercARat

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

If lContinua
	If cRatVld <> Nil .And. cRatVLd == "2"
		SetKey(VK_F4,bSavKeyF4)
		SetKey(VK_F5,bSavKeyF5)
		SetKey(VK_F6,bSavKeyF6)
		SetKey(VK_F7,bSavKeyF7)
		SetKey(VK_F8,bSavKeyF8)
		SetKey(VK_F9,bSavKeyF9)
		SetKey(VK_F10,bSavKeyF10)
		SetKey(VK_F11,bSavKeyF11)
		Return .T.
	EndIf

	n       := 1
	aHeader	:= {}
	aRotina := {{"","",0,1},{"","",0,2},{"","",0,3},{"","",0,4},{"","",0,5}}
	aCols	:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("AGH")
	While !EOF() .And. (x3_arquivo == "AGH")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado++
			AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
			If AllTrim(x3_campo) == "AGH_PERC"
				nPosPerc	:= nUsado
			EndIf
		EndIf
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A rotina a seguir limpa o rateio digitado no item quando o mesmo for ³
	//³acionado pela validacao do campo D1_RATEIO com conteudo igual a NAO. ³
	//³Quando o rateio e disparado pela tecla F9, o D1_RATEIO sempre sera   ³
	//³igual a SIM e o lValidX3 assume o default .F., porem quando o rateio ³
	//³for acionado pela validacao do D1_RATEIO o lValidX3 sera .T. e aciona³
	//³a rotina a seguir para confirmar ou nao a exclusao do rateio no item.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPosRat > 0
		If Type("M->D2_RATEIO")#"U"
			If M->D2_RATEIO == "2"
				If Aviso(STR0003,STR0004,{STR0005,STR0006})==1 // "Beneficiamento" # "Este item possue rateio, deseja excluir o rateio digitado ?" # "Sim" # "Nao"
					nNewTam   := Len(aRatCC)-1
					aRatCC  := aSize(aDel(aRatCC,nPosRat), nNewTam)
					nPosRat := aScan(aRatCC,{|x| x[1] == aSavCols[nSavN][nPosItem]})
					aSavCols[nSavN][nPosRateio]	:= '2'
				Else
					aSavCols[nSavN][nPosRateio]	:= '1'
		        EndIF
				M->D2_RATEIO:=aSavCols[nSavN][nPosRateio]
		    EndIf
		EndIf
    EndIf

	If nPosRat > 0
		If Len(aRatCC) # 0
			If Len(aRatCC[n][2]) # 0
				lNovo:=.F.
			EndIf
		EndIf
	EndIf

	If lNovo == .T.
		aadd(aCols,Array(nUsado+1))
		For ny := 1 to Len(aHeader)
			If Trim(aHeader[ny][2]) == "AGH_ITEM"
				aCols[1][ny] 	:= "01"
			Else
				aCols[1][ny] := CriaVar(aHeader[ny][2])
			EndIf
			aCols[1][nUsado+1] := .F.
		Next ny
	Else
		aCols	:= aClone(aRatCC[nPosRat][2])
	EndIf

	If lInclui
		If	aSavCols[nSavN][nPosRateio] == "1"
			For ny := 1 to Len(aHeader)
				If !Trim(aHeader[ny][2]) $ ("AGH_ITEM#AGH_PERC#AGH_CC#AGH_CONTA#AGH_ITEMCT#AGH_CLVL")
					aCols[1][ny] := CriaVar(aHeader[ny][2])
				EndIf
				aCols[1][nUsado+1] := .F.
			Next ny
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Totaliza o % ja Rateado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPercRat := 0
	For nX   := 1  To  Len(aCols)
		nPercRat += aCols[nX][aScan(aHeader,{|x| AllTrim(x[2])=="AGH_PERC"})]
	Next nX

	nPercARat := 100 - nPercRat

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a chamada do ponto de entrada para atualizar dados no porrateo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPe	:= LocxPE(53)
	If !Empty(cPE)
		ExecBlock(cPE,.F.,.F.,{aSavCols,aSavHeader,nSavn,lNovo})
	EndIf

	If !(Type('l103Auto') <> 'U' .And. l103Auto)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Dialog                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlg FROM 000,000 TO 250,635 TITLE OemToAnsi(STR0007) Of oMainWnd PIXEL //"Rateio por Centro de Custo"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula dimensões                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSize := FwDefSize():New(.T.,,,oDlg)
		//oSize:aWorkArea := {000,000, 320, 120 }
		oSize:AddObject( "CABECALHO",  100, 10, .T., .T. ) // Totalmente dimensionavel
		oSize:AddObject( "GETDADOS" ,  100, 80, .T., .T. ) // Totalmente dimensionavel
		oSize:AddObject( "RODAPE"   ,  100, 10, .T., .T. ) // Totalmente dimensionavel

		oSize:lProp 	:= .T. // Proporcional
		oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

		oSize:Process() 	   // Dispara os calculos

	 	@ oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI")     SAY OemToAnsi(STR0008) Of oDlg PIXEL SIZE 56 ,9 //"Documento : "
		@ oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI")+33  SAY cSerie+" "+cNFiscal Of oDlg PIXEL SIZE 56 ,9
		@ oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI")+93  SAY OemToAnsi(STR0009) Of oDlg PIXEL SIZE 60 ,9 //"Item :"
		@ oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI")+112 SAY aSavCols[nSavN][nPosItem] Of oDlg PIXEL SIZE 37 ,9

	    oGetDados := MSGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
	     							   oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND"),;
										IIF(l103Visual,2,3),'LxA103RNCOK','LxA103RTEA','+AGH_ITEM',.T.,,,,100,,,,)

		@ oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")     Say OemToAnsi("% Rateada: ") FONT oDlg:oFont OF oDlg PIXEL	 // "% Rateada: "
		@ oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")+30  Say oPercRat VAR nPercRat Picture PesqPict("SCH","CH_PERC") FONT oDlg:oFont COLOR CLR_HBLUE OF oDlg PIXEL
		@ oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")+180  Say OemToAnsi("% A Ratear: ") FONT oDlg:oFont OF oDlg PIXEL	 // "% A Ratear: "
		@ oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")+214 Say oPercARat VAR nPercARat Picture PesqPict("SCH","CH_PERC") FONT oDlg:oFont COLOR CLR_HBLUE OF oDlg PIXEL

		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||IIF(oGetDados:TudoOk(),(nOpc:=1,oDlg:End()),(nOpc:=0))},{||oDlg:End()},, aButtons)
	Else
		nOpc := 1
	EndIf

	aColsPar :={}
	AEval( aCols, { |x| If( !x[ nUsado + 1], AAdd( aColsPar, x ), ) } )
	aCols := aClone( aColsPar )

	If nOpc == 1 .And. !l103Visual
		For nx	:= 1 to Len(aCols)
			If !aCols[nx][Len(aCols[nx])]
				nTotPerc += aCols[nx][nPosPerc]
			EndIf
		Next
		If nTotPerc > 0
			If nPosRat > 0
				aRatCC[nPosRat][2]	:= aClone(aCols)
			Else
				aADD(aRatCC,{aSavCols[nSavN][nPosItem],aClone(aCols)})
			EndIf
			aSavCols[nSavN][nPosRateio]	:= '1'
			aSavCols[nSavN][nPosCC]		:= Space(Len(aSavCols[nSavN][nPosCC]))
			aSavCols[nSavN][nPosConta]	:= Space(Len(aSavCols[nSavN][nPosConta]))
			aSavCols[nSavN][nPosItemCta]	:= Space(Len(aSavCols[nSavN][nPosItemCta]))
			aSavCols[nSavN][nPosCLVL]		:= Space(Len(aSavCols[nSavN][nPosCLVL]))
		Else
			aSavCols[nSavN][nPosRateio]	:= '2'
		EndIf
	EndIf
Endif

If nOpc == 1  //Quando era escolhido cancelar os itens do Rateio tambem era alterados
	If nPosRat > 0
		aRatCC[nPosRat][2]:=aClone( aCols )
	EndIf
EndIf

aRotina	:= aClone(aSavaRotina)
aCols	:= aSavCols
aHeader	:= aClone(aSavHeader)
n		:= nSavN

SetKey(VK_F4,bSavKeyF4)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LxaSD2AtuSDE ³ Autor ³                    ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a atualizacao do arquivo de Rateios por CC           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxaSD2AtuSDE(nOpc,aRatCC,aRecAGH,aHeaderAGH,aCustoEnt)

Local aArea		:= GetArea()
Local aTotCust	:= {}
//Local lVer641	:= .F. //VerPadrao('641')	// Entrada de NF Devolucao/Beneficiamento ( Cliente ) - Itens do Rateio  ('641')
Local lVer613	:= VerPadrao('613')	// Entrada de NF Normal ( Fornecedor ) - Itens do Rateio('651')
Local lVer633	:= VerPadrao('633')	// Exclusao de NF ( Fornecedor ) - Itens do Rateio('656')
Local nP		:= 0
Local nCusto	:= 0
Local nX       := 0
Local ny       := 0
Local nz		:= 0
Local nD		:= 0
Local nM       := 0
Local aTam		:= {}
Local cArquivo	:= ""
Local cFilAGH := xFilial('AGH')

cLoteCom   := If(Type('cLoteCom') == 'U',"",cLoteCom)

dbSelectArea("SX5")
dbSetOrder(1)
If MsSeek(xFilial()+"09COM")
	cLoteCom := AllTrim(X5Descri())
Else
	cLoteCom := "COM "
EndIf

If nOpc == 1
	aTotCust := aClone(aCustoEnt)
	Afill(aTotCust,0)
	If SD2->D2_RATEIO == '1'
		nx	:= aScan(aRatCC,{|x| x[1] == SD2->D2_ITEM})
		If nx > 0
			For nD := 1 to Len(aCustoEnt)
				cVar := Trim("AGH_CUSTO" + Alltrim(str(nD)))
				If AGH->(FieldPos(cVar)) > 0
					AADD(aTam,(TamSX3(cVar)[2]))
				EndIF
			Next
			For nz := 1 to Len(aRatCC[nx][2])
				dbSelectArea('AGH')
				RecLock('AGH',.T.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza os dados contidos na GetDados                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For ny := 1 to Len(aHeaderAGH)
					If aHeaderAGH[ny][10] # "V"
						cVar := Trim(aHeaderAGH[ny][2])
						AGH->(FieldPut(FieldPos(cVar),aRatCC[nx][2][nz][ny]))
					EndIf
				Next
				AGH->AGH_FILIAL	:= cFilAGH
				AGH->AGH_NUM		:= SD2->D2_DOC
				AGH->AGH_SERIE	:= SD2->D2_SERIE
				AGH->AGH_FORNEC	:= SD2->D2_CLIENTE
				AGH->AGH_LOJA	:= SD2->D2_LOJA
				AGH->AGH_ITEMPD	:= aRatCC[nx][1]
				nP              := 0
				For nP:= 1 to Len(aCustoEnt)
					cVar   := Trim("AGH_CUSTO" + Alltrim(str(nP)))
					If AGH->(FieldPos(cVar)) > 0
						If nZ <> Len(aRatCC[nx][2])
							nCusto := NoRound(aCustoEnt[nP] * (AGH->AGH_PERC/100),aTam[nP])
							AGH->(FieldPut(FieldPos(cVar),nCusto))
							aTotCust[nP] += nCusto
						Else
							AGH->(FieldPut(FieldPos(cVar),aCustoEnt[nP]-aTotCust[nP]))
						EndIf
					EndIf
				Next

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava os campos Memos Virtuais da Tabela SDE       				  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Type("aMemoSDE") == "A"
					For nM := 1 to Len(aMemoSDE)
						nPosMemo := aScan(aHeaderAGH,{|x| AllTrim(x[2])== aMemoSDE[nM][2] })
						If nPosMemo <> 0 .And. !Empty(aRatCC[nx][2][nz][nPosMemo])
							MSMM(&(aMemoSDE[nM][1]),,,aRatCC[nx][2][nz][nPosMemo],1,,,"AGH",aMemoSDE[nM][1])
						EndIf
					Next nM
				EndIf

				MsUnlock()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera Lancamento contabil 641- Devolucao / Beneficiamento ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lGeraLanc
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gera Lancamento contabil 613- NF Entrada- Itens          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lVer613
						nTotalLcto	+= DetProva(nHdlPrv,'613','MATA466N',cLoteCom)
					EndIf
				EndIf
			Next
		EndIf
	EndIf
Else
	If Empty(nHdlPrv) .OR. nHdlPrv < 0
		nHdlPrv  := HeadProva(cLoteCom,"MATA520",Subs(cUsuario,7,6),@cArquivo)
	Endif
	If nOpc == 2
		aRecAGH := {}
	EndIf
	For nX	:= 1 to Len(aRecAGH)
		dbSelectArea('AGH')
		MsGoto(aRecAGH[nx])
		If AGH->AGH_ITEMPD == SD2->D2_ITEM
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera Lancamento contabil 633- Exclusao - Itens       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lVer633 .And.!Empty(SF2->F2_DTLANC)
				nTotalLcto += DetProva(nHdlPrv,'633','MATA520',cLoteCom)
			EndIf
			RecLock('AGH',.F.,.T.)
			dbDelete()
			MsUnlock()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui campos Memos Virtuais da tabela SYP vinculado aos memos SDE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("aMemoSDE") == "A"
				If Len(aMemoSDE) > 0
					MSMM(&("AGH->"+aMemoSDE[1][1]),,,,2)
			    EndIf
			EndIf
		EndIf
	Next nX

EndIf
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103RTETDK³ Autor ³ Edson Maricate        ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³TudOk da GatDados da Tela de rateios por CC                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103RTEA()
Local nPPerc   := aScan(aHeader,{|x| AllTrim(x[2]) == "AGH_PERC"} )
Local nTotal   := 0
Local nX       := 0
Local lRetorno := .T.

For nX	:= 1 To Len(aCols)
	If !aCols[nX][Len(aCols[nX])]
		nTotal += aCols[nX][nPPerc]
	EndIf
Next
If lRetorno
	If nTotal > 0 .And. nTotal <> 100
		Help(" ",1,"A103TOTRAT")
		lRetorno := .F.
	EndIf
EndIf
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103RTELOK³ Autor ³ Edson Maricate        ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³LinOk da GatDados da Tela de rateios por CC                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxA103RNCOK()

Local nPPerc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "AGH_PERC"} )
Local lRetorno  := .T.
Local nX        := 0

_nLinhaR		:= N

If !aCols[N][Len(aCols[N])]
	If aCols[N][nPPerc] == 0
		Help(" ",1,"A103PERC")
		lRetorno := .F.
	EndIf
EndIf

If lRetorno
	nPercRat := 0
	nPercARat:= 0
	For nX	:= 1 To Len(aCols)
		If !aCols[nX][Len(aCols[nX])]
			nPercRat += aCols[nX][nPPerc]
		EndIf
	Next
	nPercARat := 100 - nPercRat
	If Type("oPercRat")=="O"
		oPercRat:Refresh()
		oPercARat:Refresh()
	Endif
EndIf

Return lRetorno

/*
ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»
ºPrograma  ³NFRATEIOCC    º Leandro C.G. ³Microsiga º Data ³  21/01/02  º
ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹
ºDesc.     ³Grava rateios por centro de custo para um item de uma NCC   º
ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
ºUso       ³ GENERICO	                                                  º

Parametros
aRatCC	- array com os rateios de cada item
		  [1] - Item da NF
		  [2] - Itens de Rateios por centro de custo
nOpc	- indicador inclusao ou exclusao -- Default 1
  		  (1) - inclusao
  		  (2) - exclusao
aCusto	- Custo de todos os itens em todas as moedas
		  [1] - Custo moeda1
		  [2] - Custo moeda2
		  [3] - Custo moeda3
		  [4] - Custo moeda4
		  [5] - Custo moeda5
_lGeraLanc	- Indica se deve gerar lanç contabil
*/
Function NCRateioCC(aRatCC,nOpc,aCusto,nItem)
Local aArea      := GetArea()
//Local nI						//flag para loop's
Local aRecAGH    := {}			//array com numero dos registros do SDE que devem ser excluidos
Local lRet       := .T.			//Indica consistencia da funcao
Local aHeaderAGH := {}			//Aheader sobre o arquivo de rateios por NF
Local aPars      := {}			//Array para a funcao de validacao de param. (Olhar funcao LocxParam())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta variavel define se dentro da rotina Lxa103SD1AtuSDE, deve gerar os lanç. contabeis ou nao³
//³Neste caso, como na rotina de NF existe uma rotina que gera todos os lanç.					 ³
//³contabeis referentes a uma NF, nao pode ser gerado nenhum lanç em outra funcao     			 ³
//³Funcao que gera os lanç. contabeis : CtbilNF											 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lGeraLanc := .F.

Default nOpc  := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Consistindo Parametros³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aPars, {"aRatCC"	, aRatCC	, SpEmpty})
lRet := LocxParam("NCRATEIOCC",aPars)
Aeval(aRatCC, { |x| Asize(x, 2) } )

If lRet //(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader para utilizacao na gravacao do SDE       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DBSelectArea("SX3")
	DBSetOrder(1)
	MsSeek("AGH")
	While !EOF() .AND. (X3_ARQUIVO == "AGH")
		If X3uso(X3_USADO) .AND. cNivel >= X3_NIVEL
			AADD(aHeaderAGH,{ 	Trim(x3titulo())	,X3_CAMPO	,X3_PICTURE	,;
								X3_TAMANHO			,X3_DECIMAL	,X3_VALID	,;
								X3_USADO			,X3_TIPO	,X3_ARQUIVO	,;
								X3_CONTEXT 										} )
		EndIf
		DBSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica inclusao ou exclusao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LxaSD2AtuSDE(nOpc,aRatCC,aRecAGH,aHeaderAGH,aCusto)

EndIf //lRet (1)

RestArea(aArea)

Return

Function CTBOFFLND2(nRecno,lVer613,nTotalLcto,cFunNam,cLote)
	dbSelectArea("SF2")
	MsGoto(nRecno)
	If Recno() == nRecno .AND. lVer613
		dbSelectArea("SD2")
		dbSetOrder(RETORDEM("SD2","D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM"))
		If dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
			While !Eof() .AND. ;
				xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
				dbSelectArea("AGH")
				dbSetOrder(RETORDEM("AGH","AGH_FILIAL+AGH_NUM+AGH_SERIE+AGH_FORNEC+AGH_LOJA+AGH_ITEMPD+AGH_ITEM"))
				If dbSeek(xFilial("AGH")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM)
					While !Eof() .AND. ;
						AGH->AGH_FILIAL+AGH->AGH_NUM+AGH->AGH_SERIE+AGH->AGH_FORNECE+AGH->AGH_LOJA+AGH->AGH_ITEMPD == xFilial("AGH")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ lanç contabil 641- Devolucao / Beneficiamento ³
						//³ lanç contabil 651- NF Entrada- Itens          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nTotalLcto	+= DetProva(nHdlPrv,"613",cFunNam,cLote)
						dbSelectArea("AGH")
						dbSkip()
					EndDo
				Endif
				dbSelectArea("SD2")
				dbSkip()
			EndDo
		EndIf
	EndIf
Return

/*
ºPrograma  ³BUSCASDE  ºAutor  ³Leandro C.G.        º Data ³  19/03/02   º
ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
ºDesc.     ³Retorna dados referentes ao Rateio por Centro de Custo      º
º          ³relacionado a uma determinada NF             				º
Obs.: Considera que o arquivo de Notas Fiscais ja esta posicionado no registro correto
aRet	- 	Retorno da funcao
			[1] - aHeader do SDE
			[2] - Recno's do SDE
			[3] - aRatCC
*/
Function BuscaAGH()
Local nItemAGH		:= 0
Local nUsadoAGH 	:= 0
Local aHeaderAGH	:= {}
Local aRecAGH		:= {}
Local aRatCC		:= {}
Local cItemAGH		:= ""
Local aRet			:= Array(3)
Local nY			:= 0
Local bWhile
Local nPosDoc		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_REMITO"	})
Local nPosSerie		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_SERIREM"})

DBSelectArea("AGH")

If (FunName() == "MATA101N" .And. !IsInCallStack("A103GRVATF")) .And. lInclui .And. !Empty(aCols[n,nPosDoc]) //Factura de Entrada
	MsSeek(xFilial("AGH")+aCols[n,nPosDoc]+aCols[n,nPosSerie])

	bWhile := { || !Eof() .AND.;
				   xFilial('AGH')	 	== AGH->AGH_FILIAL 	.AND.;
				   aCols[n,nPosDoc] 	== AGH->AGH_NUM		.AND.;
				   aCols[n,nPosSerie] 	== AGH->AGH_SERIE	.AND.;
				   M->F2_FORNECE	 	== AGH->AGH_FORNECE	.AND.;
				   M->F2_LOJA 	 	 	== AGH->AGH_LOJA }
	lBuscaAGH := .F.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona arquivo SDE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsSeek(xFilial("AGH")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)

	bWhile := { || !Eof() .AND.;
		xFilial('AGH')	== AGH->AGH_FILIAL 		.AND.;
		SF2->F2_DOC 	== AGH->AGH_NUM 			.AND.;
		SF2->F2_SERIE 	== AGH->AGH_SERIE 		.AND.;
		SF2->F2_CLIENTE	== AGH->AGH_FORNECE		.AND.;
		SF2->F2_LOJA 	== AGH->AGH_LOJA }
EndIf

While Eval(bWhile)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nUsadoAGH==0
		DBSelectArea("SX3")
		DBSetOrder(1)
		MsSeek("AGH")
		While	!EOF() .AND. SX3->X3_ARQUIVO == "AGH"
			If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
				nUsadoAGH++
				Aadd(aHeaderAGH,{ 	TRIM(X3Titulo())	,;
									SX3->X3_CAMPO		,;
									SX3->X3_PICTURE		,;
									SX3->X3_TAMANHO		,;
									SX3->X3_DECIMAL		,;
									SX3->X3_VALID		,;
									SX3->X3_USADO		,;
									SX3->X3_TIPO		,;
									SX3->X3_ARQUIVO		,;
									SX3->X3_CONTEXT 	})
			EndIf
			DBSelectArea("SX3")
			DBSkip()
		End
	EndIf

	Aadd(aRecAGH,AGH->(RecNo()))
	If cItemAGH <> 	AGH->AGH_ITEMPD
		cItemAGH	:= AGH->AGH_ITEMPD
		Aadd(aRatCC,{cItemAGH,{}})
		nItemAGH++
	EndIf
	Aadd(aRatCC[nItemAGH][2],Array(nUsadoAGH+1))

	For nY := 1 to Len(aHeaderAGH)
		If aHeaderAGH[nY][10] <> "V"
			aRatCC[nItemAGH][2][Len(aRatCC[nItemAGH][2])][nY] := AGH->(FieldGet(FieldPos(aHeaderAGH[nY][2])))
		Else
			aRatCC[nItemAGH][2][Len(aRatCC[nItemAGH][2])][nY] := AGH->(CriaVar(aHeaderAGH[nY][2]))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Lê campos Memos Virtuais da tabela SYP vinculado aos memos SDE ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("aMemoSDE") == "A"
			If Len(aMemoSDE) > 0
				If (AllTrim(aHeaderAGH[nY][2])==AllTrim(aMemoAGH[1][2]))
					aRatCC[nItemAGH][2][Len(aRatCC[nItemAGH][2])][nY]:= MSMM(&("AGH->"+aMemoSDE[1][1]))
		    	EndIf
			EndIf
		EndIf

		aRatCC[nItemAGH][2][Len(aRatCC[nItemAGH][2])][nUsadoAGH+1] := .F.
	Next nY
	DBSelectArea("AGH")
	DBSkip()
End

aRet[1] := aClone(aHeaderAGH)
aRet[2] := aClone(aRecAGH)
aRet[3] := aClone(aRatCC)

Return(aRet)

/*
ºPrograma  ³LOCXCabNf2   ºAutor  ³Emanuel Villicaña   º Data ³  10/03/15   º
ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
ºDesc.     ³Verifica si valores adicionales fueron alterados y actualiza   º
º          ³aCabNota,aCabNotaOri                                           º
*/
Function LOCXCabNf2(aCabNota,aCabNotaOri,nAliasHead,aCfgNf)
Return GrvCabDoc(@aCabNota,@aCabNotaOri,aCfgNf)

/*/{Protheus.doc} ValTipoOpe(nTipo)
Valida que para establecer un tipo de operación exista un cliente ya seleccionado y que dicho cliente cuente con el campo A1_IDFIS diferente de vacío.
@author Roberto González
@since 17/06/2016
/*/
Function ValTipoOpe(nTipo)
Return VldTipoOpe(nTipo)

/*/{Protheus.doc} ValCmObCE(nTipo)
Valida si los campos obligatorios para el comercio exterior. Cabecera y líneas.
@author Roberto González
@since 20/06/2016
/*/
Function ValCmObCE(cAliasC, nLinha, aDadosI, aDadosD)
Return xVldCmObCE(cAliasC, nLinha, aDadosI, aDadosD)

/*/{Protheus.doc} ValLinCO(nTipo)
Valida si los campos obligatorios para el comercio exterior. Líneas
@author Roberto González
@since 20/06/2016
/*/
Function ValLinCO(nTipoNF, nCanAdu, nUniAdu, nValAdu, nUsdAdu, aDadosI, nLinha, nFracca)
Return xLinComExt(nTipoNF, nCanAdu, nUniAdu, nValAdu, nUsdAdu, aDadosI, nLinha, nFracca)

/*/{Protheus.doc} DatosSpr(cTabla, cDoc, cSerie)
Valida si para la tabla cTabla existe ya un documento (vigente o suprimido) con el número de documento cDoc y la serie cSerie.
@author Roberto González
@since 03/08/2016
/*/
Function DatosSpr(cTabla, cDoc, cSerie)
	Local cQueryR:= ""
	Local nTotal := 0

	//Query para obtener los datos, incluyendo los eliminados, de la tabla correspondiente
	cQueryR := "SELECT 1"
	cQueryR += "FROM " + RetSqlName(cTabla) + " "
	cQueryR += "WHERE " + PrefixoCpo(cTabla) + "_FILIAL = '" + xFilial(cTabla) + "' AND " + PrefixoCpo(cTabla) + "_DOC = '" + cDoc + "' AND " + PrefixoCpo(cTabla) + "_SERIE = '" + cSerie + "'"

	cQueryR:=ChangeQuery(cQueryR)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryR),"TraR",.T.,.F.)

	Count To nTotal
	TraR->(dbCloseArea())
Return Iif(nTotal > 0, .F., .T.)

/*/{Protheus.doc} DatosSpr(cTabla, cDoc, cSerie)
Valida si para la tabla cTabla existe ya un documento (vigente o suprimido) con el número de documento cDoc y la serie cSerie.
@author Roberto González
@since 03/08/2016
@Parametros : 	F2_VEHICL: Vehículo seleccionado
				F2_ACOPLA: Vehículo a acoplar
				rVar: Variable que fue seleccionada para validaciones
/*/
Function F2VerVehi(F2_VEHICL, F2_ACOPLA, rVar)
	Local F2VEHICL := F2_VEHICL
	Local F2ACOPLA := F2_ACOPLA
	Local rVAr := rVar
	Local aArea := {}
	Local lRet := .T.
	Local cVehi := ""
	Local cTipVehi := ""

	If rVar == 'M->F2_ACOPLA'
		cVehi := F2ACOPLA
	Else
		cVehi := F2VEHICL
	EndIF

	aArea := GetArea()
	DbSelectArea('DA3')
	DbSetorder(1)

	If rVar == 'M->F2_ACOPLA' .And. !Empty(F2ACOPLA) .And. Empty(F2VEHICL)
		Alert(STR0179) //"Se debe primero seleccionar un Vehículo"
		M->F2_ACOPLA := ""
		lRet := .F.
		Return lRet
	EndIf

	If DbSeek(xFilial("DA3") + cVehi)
		cTipVehi := DA3->DA3_TIPVEI
		DbSelectArea('DUT')
		DUT->(DbSetOrder(1))
		If DbSeek(xFilial("DUT") + cTipVehi)
			If rVar == 'M->F2_ACOPLA'
				If DUT_CATVEI != '6'
					Alert(STR0180) //"El Tipo de Vehículo debe de ser Acoplado"
					lRet := .F.
					Return lRet
				EndIf
			Else
				If DUT_CATVEI == '6'
					Alert(STR0181) //"El Tipo de Vehículo debe de ser diferente de Acoplado"
					lRet := .F.
					Return lRet
				EndIf
			EndIf
		Else
			Alert(STR0182) //"No existe el Tipo de Vehículo"
			lRet := .F.
			Return lRet
		EndIF

	Else
		If rVar == 'M->F2_ACOPLA' .And. !Empty(F2ACOPLA)
			Alert(STR0183) //"No existe el Vehículo"
			lRet := .F.
			Return lRet
		ElseIf rVar == 'M->F2_VEHICL' .And. !Empty(F2VEHICL)
			Alert(STR0183) ////"No existe el Vehículo"
			lRet := .F.
			Return lRet
		EndIf
	EndIF
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} LxExSer2()
Validación para uso de serie 2
@author Guadalupe Santacruz
@since 20/06/2016
/*/
Function LxExSer2
Local aArea    := GetArea()
//Local cLisFun:='MATA467N/MATA462N/MATA465N' //factura de Venta/Remision de Venta/Nota de Debito/Credito
Local cVarAct:= readvar()
Local cOp := "1"
Local lRETPAR:=.F. //RTS PARAGUAY
If Type("lDocSp") == "U"
	 Private lDocSp := .F.
EndIf
If cPaisLoc == "PAR" 
	ParExSer2()
	Return .T.
ElseIf cPaisLoc == "COL" 
	ColExSer2()
	Return .T.
EndIf

If FunName() $ 'MATA467N/MATA462N' .OR. lRETPAR
	 cOp := IIF(FunName() $ 'MATA462N' .OR. lRETPAR,"6","1")
     SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
      If ALLTRIM(cVaract) $ "M->F2_DOC/M->F2_SERIE" //factura de Venta
         IF SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+M->F2_SERIE+cOp))
         	M->F2_SERIE2:= SFP->FP_SERIE2
         ELSE
         	M->F2_SERIE2:= ''
         ENDIF
      Endif
EndIf
IF FunName() $ 'MATA465N'//  Nota de Debito/Credito
     SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
            if ALLTRIM(cVaract) $ "M->F1_DOC/M->F1_SERIE"  //NCC  CREDITO

               IF SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+M->F1_SERIE+(IIf(cPaisLoc <> "PAR",'2','4')) ))
                        M->F1_SERIE2:= SFP->FP_SERIE2
                  ELSE
                        M->F1_SERIE2:= ''
                  ENDIF
            ELSE
                  if ALLTRIM(cVaract) $ "M->F2_DOC/M->F2_SERIE" //NDC  DEBITO

                     IF SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+M->F2_SERIE+(IIf(cPaisLoc <> "PAR",'3','5')) ))
                              M->F2_SERIE2:= SFP->FP_SERIE2
                        ELSE
                              M->F2_SERIE2:= ''
                        ENDIF
                  Endif
            ENDIF
ENDIF
RestArea(aArea)
Return .T.

/*/{Protheus.doc} LxExAdic()
Función para obtener datos adicionales para documentos a partir de campos DOC y SERIE.
@author Luis Eduardo Enríquez Mata
@since 12/10/2018
/*/
Function LxExAdic()
	Local aArea    := GetArea()
	Local cVarAct  := readvar()
	Local cPref    := IIf(Alltrim(cVaract) $ "M->F2_DOC/M->F2_SERIE" , "F2","F1")
	Local cEsp     := ""

	If Alltrim(&("M->" + cPref + "_ESPECIE")) == "NF" .And. !(FunName() == "MATA101N")
		cEsp := '1'
	ElseIf Alltrim(&("M->" + cPref + "_ESPECIE")) == "NCC"
		cEsp := '4'
	ElseIf Alltrim(&("M->" + cPref + "_ESPECIE")) == "NDC"
		cEsp := '5'
	ElseIf Alltrim(&("M->" + cPref + "_ESPECIE")) $ "RFN|RTS|RCD"
		cEsp := '6'
	EndIf

	If cEsp $ "1|4|5|6"
		DbSelectArea("SFP")
		SFP->(dbSetOrder(5))//FP_FILIAL + FP_FILUSO + FP_SERIE + FP_ESPECIE
		If SFP->(dbSeek(xFilial("SFP") + cFilAnt + &("M->" + cPref + "_SERIE") + cEsp))
			&("M->" + cPref + "_PTOEMIS") := SFP->FP_PTOEMIS
			&("M->" + cPref + "_ESTABL")  := SFP->FP_ESTABL
	    Else
	    	&("M->" + cPref + "_PTOEMIS") := Space(GetSX3Cache(cPref + "_PTOEMIS",	"X3_TAMANHO"))
			&("M->" + cPref + "_ESTABL")  := Space(GetSX3Cache(cPref + "_ESTABL",	"X3_TAMANHO"))
	    EndIf
    EndIf
    RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxTesTras  ºAutor  ³Jonathan Gonzalez  º Data ³  22/11/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida la TES para Facturas de Traslados.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL : Falso cuando se afecto financiero o stock.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LocxNF - D2_TES - MEXICO                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxTesTras(cTes)
Return xTesTrasdo(cTes)

/*/{Protheus.doc} ValUUIDREL
	Valida el campo F2_UUIDREL para la versión CFDI 4.0
	@type function
	@author eduardo.manriquez
	@since 20/01/2022
	@version 1.0
	@param cUUIDREL	, caracter, Cadena que contiene el Tipo de relación y los UUID Relacionados
	@return lRet,logico,verdadero si los datos del campo son correctos, falso si no son correctos.
	@example
	ValUUIDREL(cUUIDREL)
	@see (links_or_references)
/*/
Function ValUUIDREL(cUUIDREL)
Return VldUUIDRel(cUUIDREL)

/*/{Protheus.doc} LxVldF3I
Valida si un registro  para una tabla dada existe en el catálogo registrado
en f3i y f3h
@type static
@author eduardo.manriquez
@since 20/01/2022
@version 1.0
@param cCodigo	, caracter, Código de la Tabla
@param cConteudo, caracter, Cadena a buscar
@param nPos1, numérico, Posición de inicio de búsqueda
@param nPos2, numérico, Posición de fin de búsqueda
@return lRet, verdadero si encuentra el registro, falso si no lo encuentra
@example
lRet := LxVldF3I("S006", SA1->A1_TIPDOC,1,1) 
@see (links_or_references)
/*/
Function LxVldF3I(cCodigo,cConteudo,nPos1,nPos2)
Return xVldF3IMex(cCodigo,cConteudo,nPos1,nPos2)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValRetSat  ºAutor  ³Jonathan Gonzalez  º Data ³  24/11/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida Tipo de Relacion CFD y UsoCFDI.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL : True o False cuando esta vacio o no cumple condicion º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LocxNF - F2_RELSAT y F2_USOCFDI - MEXICO                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ValRetSat(cTpRel,cCpo)
Local aArea		:= GetArea()
Local lRet		:= .T.

Default cCpo	:= ""
Default cTpRel	:= ""

	If cPaisLoc == "MEX"
		lRet := xVldRetSat(cTpRel,cCpo)
	EndIf
	
	If cPaisLoc == "COL"
		lRet := LxMIVldCO(cTpRel,cCpo)
	EndIf
	If cPaisLoc == "BOL"
		lRet := M486XVldBO(cTpRel,cCpo)
	EndIf
	RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldPais    ³ Autor ³ Marco Aurelio - Mano    ³ Data ³14/06/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida codigo do pais                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³VldPais(ExpC1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Codigo do pais a ser validado                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Localizacao Portugal                                           ³±±
±±³          ³Utilizado no X3_VALID do campo A1_PAISE e ou A2_PAISE          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldPais(cPais)
Local aArea := GetArea()	// Salva area atual para posterior restauracao
Local lRet  := .t.			// Conteudo de retorno

If Empty(Posicione("SYA",1,xFilial("SYA")+cPais,"YA_DESCR"))
	Help("  ",1,"REGNOIS")
	lRet := .f.
ElseIf    SYA->(ColumnPos("YA_SGLLOC")) > 0 .and. Empty(SYA->YA_SGLLOC)
	Aviso(STR0033,STR0097,{"OK"})	//##Atenção##"Sigla do país não pode estar vazia, verifique."
	lRet := .f.
EndIf

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³MTA462Can     ³ Autor ³ Vendas e CRM            ³ Data ³12/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Consulta de Guias de transporte canceladas - Portugal            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MTA462Can()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT - Portugal                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA462Can(xAutoCab,xAutoItens,nOpcAuto,lSeek,nTipoOper)
Local nTipo		:= 0
Local nPosTipo	:= 0
Local lNfAuto 	:= ( ValType(xAutoCab) == "A"  .AND. ValType(xAutoItens) == "A" )
Local cFunName	:= IIf(Type("cFunName")=="U",Upper(Alltrim(ProcName())),cFunName)	//Funcao Origem
DEFAULT lSeek	:=	.T.

PRIVATE aParamGer := {}

//AJUSTASX3NF2()
nOpcAuto := If(nOpcAuto==NIL,3,nOpcAuto)

If lNfAuto
	nPosTipo:= Ascan(xAutoCab,{|aCab| aCab[1] == "F1_TIPODOC" .OR. aCab[1] == "F2_TIPODOC"})
	nTipo	:= Val(xAutoCab[nPosTipo,2])
	If nTipo == 0
		nTipo := 50		// Guia de Transp.
	EndIf
Else
	If Pergunte("MT462CPER",.T.)
		nTipo := 50

		aAdd(aParamGer,2)
		aAdd(aParamGer,MV_PAR01)
		aAdd(aParamGer,MV_PAR02)
		aAdd(aParamGer,"F2_EMISSAO")
		aAdd(aParamGer,"F2_TIPODOC NOT IN('55','01')")
	EndIf
EndIf

If nTipo > 0
	LocxNf(nTipo,xAutoCab,xAutoItens,nOpcAuto,cFunName,lSeek,nTipoOper)
Endif

SetKey(VK_F4	,{|| Nil })
SetKey(VK_F5	,{|| Nil })
SetKey(VK_F6	,{|| Nil })
SetKey(VK_F7	,{|| Nil })
SetKey(VK_F8	,{|| Nil })
SetKey(VK_F9	,{|| Nil })
SetKey(VK_F10	,{|| Nil })
SetKey(VK_F11	,{|| Nil })
SetKey(VK_F12	,{|| Nil })
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PesqTRB   ³ Autor ³Marco Aurelio          ³ Data ³ 06/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para pesquisa na mBrowse em tabela temporaria        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PesqTRB()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico de Guia Canceladas(Portugal)                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PesqTRB()
Local cCampo  := Space(40)		   		// Conteudo a ser pesquisado
Local oBrowse := GetObjBrow()	   		// objeto da tela da MBrowse
Local cAlias  := Alias()		  		// Numero referente a chave de indice selecionada para pesquisa
Local cOrd	  := ""				   		// Numero referente a chave de indice selecionada para pesquisa
Local nReg	  := (cAlias)->(Recno())	// Opcao selecionada para processamento
Local nOpca	  := 0				   		// Opcao selecionada para processamento
Local nOpt1	  := 1 				   		// Ordem da chave de indice a ser considerada para pesquisa
Local aOrd 	  := {}						// Texto identificador dos campos aserem utilizados na chave de indice
Local oDlg						   		// Objeto da Dialog
Local oCbx								// Objeto da ComboBox

Aadd(aOrd,AllTrim(Posicione("SIX",1,"SF2"+"1","SIXDescricao()")))
cOrd := aOrd[1]

DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 50 TITLE OemToAnsi("Pesquisar") // "Pesquisar"

	@ 0.6,1.3 COMBOBOX oCBX VAR cOrd ITEMS aOrd  SIZE 165,44 OF oDlg FONT oDlg:oFont
	@ 2.1,1.3	MSGET cCampo SIZE 165,10

	DEFINE SBUTTON FROM 055,122	  TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg 	// Botao de confirmacao
	DEFINE SBUTTON FROM 055,149.1 TYPE 2 ACTION (oDlg  :End())          ENABLE OF oDlg	// Botao de cancelamento

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1

	dbSelectArea(cAlias)

	nReg := RecNo()
	dbSetOrder(nOpt1)

	If !MsSeek(xFilial("SF2")+Alltrim(cCampo),.T.)
		Help(" ",1,"PESQ01")
		MsGoTo(nReg)
	EndIf

Else
	DbSelectArea(cAlias)
EndIf

oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³MTA462Can    ³ Autor ³ Aline S Damasceno       ³ Data ³20/05/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Consulta de Guias de devolucao canceladas - Portugal             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MTA462Can()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT - Portugal                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA462DCan(xAutoCab,xAutoItens,nOpcAuto,lSeek,nTipoOper)
Local nTipo		:= 0
Local nPosTipo	:= 0
Local lNfAuto 	:= ( ValType(xAutoCab) == "A"  .AND. ValType(xAutoItens) == "A" )
Local cFunName	:= IIf(Type("cFunName")=="U",Upper(Alltrim(ProcName())),cFunName)	//Funcao Origem

DEFAULT lSeek	:=	.T.

PRIVATE aParamGer := {}

//AJUSTASX3NF2()
nOpcAuto := If(nOpcAuto==NIL,3,nOpcAuto)

If lNfAuto
	nPosTipo:= Ascan(xAutoCab,{|aCab| aCab[1] == "F1_TIPODOC" .OR. aCab[1] == "F2_TIPODOC"})
	nTipo	:= Val(xAutoCab[nPosTipo,2])
	If nTipo == 0
		nTipo := 51		// Guia de Devol.
	EndIf
Else
	dbSelectArea("SX1")
	dbSetOrder(1)

	If !SX1->(DbSeek('MT462DCN'))
		Aviso(STR0033,OemToAnsi(STR0112),{"OK"},2)
		Return(.f.)
	EndIf

	If Pergunte("MT462DCN",.T.)

		If mv_par01 == 1
			nTipo := 51
		Else
			nTipo := 53
		Endif

		aAdd(aParamGer,2)
		aAdd(aParamGer,MV_PAR02)
		aAdd(aParamGer,MV_PAR03)
		aAdd(aParamGer,"F1_EMISSAO")
		aAdd(aParamGer,"F1_TIPODOC IN('"+Alltrim(Str(nTipo))+"')")
	EndIf
EndIf

If nTipo > 0
	LocxNf(nTipo,xAutoCab,xAutoItens,nOpcAuto,cFunName,lSeek,nTipoOper)
Endif

SetKey(VK_F4	,{|| Nil })
SetKey(VK_F5	,{|| Nil })
SetKey(VK_F6	,{|| Nil })
SetKey(VK_F7	,{|| Nil })
SetKey(VK_F8	,{|| Nil })
SetKey(VK_F9	,{|| Nil })
SetKey(VK_F10	,{|| Nil })
SetKey(VK_F11	,{|| Nil })
SetKey(VK_F12	,{|| Nil })
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³MTA462RSC    ³ Autor ³ Aline S Damasceno       ³ Data ³20/05/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Consulta de Retorno Simbolico Canceladas - Portugal              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MTA462RSC()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT - Portugal                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA462RSC(xAutoCab,xAutoItens,nOpcAuto,lSeek,nTipoOper)
Local nTipo		:= 0
Local nPosTipo	:= 0
Local lNfAuto 	:= ( ValType(xAutoCab) == "A"  .AND. ValType(xAutoItens) == "A" )
Local cFunName	:= IIf(Type("cFunName")=="U",Upper(Alltrim(ProcName())),cFunName)	//Funcao Origem
DEFAULT lSeek	:=	.T.

PRIVATE aParamGer := {}

//AJUSTASX3NF2()
nOpcAuto := If(nOpcAuto==NIL,3,nOpcAuto)

If lNfAuto
	nPosTipo:= Ascan(xAutoCab,{|aCab| aCab[1] == "F1_TIPODOC" .OR. aCab[1] == "F2_TIPODOC"})
	nTipo	:= Val(xAutoCab[nPosTipo,2])
	If nTipo == 0
		nTipo := 63		// Guia de Transp.
	EndIf
Else
	If Pergunte("MT462CPER",.T.)
		nTipo := 63

		aAdd(aParamGer,2)
		aAdd(aParamGer,MV_PAR01)
		aAdd(aParamGer,MV_PAR02)
		aAdd(aParamGer,"F1_EMISSAO")
		aAdd(aParamGer,"F1_TIPODOC IN('63')")
	EndIf
EndIf

If nTipo > 0
	LocxNf(nTipo,xAutoCab,xAutoItens,nOpcAuto,cFunName,lSeek,nTipoOper)
Endif

SetKey(VK_F4	,{|| Nil })
SetKey(VK_F5	,{|| Nil })
SetKey(VK_F6	,{|| Nil })
SetKey(VK_F7	,{|| Nil })
SetKey(VK_F8	,{|| Nil })
SetKey(VK_F9	,{|| Nil })
SetKey(VK_F10	,{|| Nil })
SetKey(VK_F11	,{|| Nil })
SetKey(VK_F12	,{|| Nil })
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MsgCanc   ºAutor  ³Marivaldo           º Data ³  15/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para gravacao da mensagem de cancelamento PTG       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MsgCanc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis da rotina                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cMesag := " "
Local cAlias := " "

If Empty(cMesag)
	cMesag = space(TamSx3("F2_MOTCANC")[1])
EndIf

If SF3->F3_TES>= "500"
	cAlias:= "SD2"
Else
	cAlias:= "SD1"
EndIf

	DEFINE MSDIALOG oDlg TITLE "Motivo Cancelamento" FROM 250,300 TO 360,520 PIXEL

	@ 003,003 TO 038,110 LABEL "" PIXEL OF oDlg

	@ 008,007 Say "Informe o motivo do cancelamento" Size 200,010 COLOR CLR_BLACK OF oDlg Pixel
	@ 017,007 MSGET oGetMsg VAR cMesag Pict "@!" Valid !Empty(cMesag) SIZE 100,009 OF oDlg PIXEL

	Define SBUTTON FROM 040, 084 Type 1  ENABLE OF oDlg Action (nOpc := 1,oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED

	If cAlias == "SD2"
   		RecLock("SF2",.F.)
			Replace SF2->F2_MOTCANC With cMesag
		MsUnlock()
	Else
		RecLock("SF1",.F.)
			Replace SF1->F1_MOTCANC With cMesag
		MsUnlock()
	EndIf

Return()

Function MSAFTAT()
Local 	cCod:=Space(TAMSX3("F2_CODEID")[1])
//Local 	dData:= dDataBAse
LOCAL 	oDlg
Local 	cAlias:=Alias()
Local	lMa:=.F.
Local	cAut:= cCod
If  cAlias=="SF2"
	If !Empty(F2_CODEID)
		cAut:=SF2->F2_CODEID
		lMa:=.T.
	EndIf
Else
	If !Empty(F1_CODEID)
		cAut:=SF1->F1_CODEID
		lMa:=.T.
	EndIf
EndIf

If lMa
	MsgStop("Doc. já possui autorizacao","HELP")
	If !MsgYesNo( "Deseja alterar a autorizacao: " + cAut )
		Return()
	EndIf
EndIf

SFP->(DbSetOrder(6)  )
lVldGuia:=.T.
cTipo:=""

DEFINE MSDIALOG oDlg FROM 00,00 TO 120,400 PIXEL TITLE  "Informe o num. de Autorização"
	@	005,003 	Say "Num. de Autorização"  OF oDlg PIXEL
	@	017,003		get cCod OF oDlg PIXEL

	DEFINE SBUTTON FROM 045,100	TYPE 1 ACTION GravaAt(cCod,oDlg) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

Return()

Function GravaAt(cCod,oDlg)
Local aArea:=GetArea()
Local cAlias:=Alias()

Default oDlg		:= Nil

If !Empty(cCod)
	If  cAlias == "SF1"
		RecLock("SF1")
		F1_CODEID:=cCod
		MsUnlock()

    Else
		RecLock("SF2")
		F2_CODEID:=cCod
		MsUnlock()
	EndIf
Else
	MSgAlert(" Documento nao Atualizado","MSG") //" Documento nao Atualizado"
EndIf

RestArea(aArea)

If oDlg <> Nil
	oDlg:End()
endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldSerTipo ³ Autor ³ Marco Aurelio - Mano    ³ Data ³09/04/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida o tipo de formulario da serie informada                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³VldSerTipo(ExpC1,ExpC2,ExpC3)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Serie da NF                                            ³±±
±±³          ³ExpC2 = Especie da NF                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Localizacao Portugal                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldSerTipo(cSerie,cEspecie)
Local aArea      := GetArea()	// Salva area atual para posterior restauracao
Local nPosIni    := 0			// Posicao inicial para busca de texto no combo do campo FP_ESPECIE
Local cEspCombo  := ""			// Texto correspondente a especie do documento
Local lRet       := .t.			// Conteudo de retorno
Local cMsg       := ""			// Mensagem de incosistencia

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca posicao da descricao da especie da nota no combo da tabela SFP ³
//³(1=Fact;2=NCI;3=NDI;4=NCC;5=NDC;6=RFN;7=GRN;8=RET;9=RFD)             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->(dbSetOrder(2))
SX3->(dbSeek("FP_ESPECIE"))

cEspCombo := Iif(AllTrim(cEspecie)=="NF","Fact",cEspecie)
nPosIni   := At(AllTrim(cEspCombo),AllTrim(SX3->X3_CBOX))
cEspCombo := Substr(AllTrim(SX3->X3_CBOX),nPosIni-2,1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a serie se refere a capacitacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFP->(ColumnPos("FP_CAPACIT")) > 0 .And.  Posicione("SFP",5,xFilial("SFP")+cFilAnt+cSerie+cEspCombo,"FP_CAPACIT") == "1"

	If ( GetMV("MV_EMPCAPA") <> cEmpAnt )
		cMsg := STR0098+" - MV_EMPCAPA"	// ##"Para geração de documentos em modo capacitação a filial logada deverá ser a mesma definida no parâmetro"
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao deve permitir informar uma serie de documento manual pela rotina de Faturas ou Guia de Transporte automaticas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cMsg) .and. AllTrim(FunName()) $ "MATA462AN|MATA468N" .and. SFP->(ColumnPos("FP_PROCMAN")) > 0

	If Posicione("SFP",5,xFilial("SFP")+cFilAnt+cSerie+cEspCombo,"FP_PROCMAN") == "1"
		cMsg := STR0117 //##"Para documentos automáticas não pode ser informada série de documentos manuais."
	EndIf

EndIf

If !Empty(cMsg)
	Aviso(STR0033,cMsg,{"OK"}) // ##"Atenção"
	lRet := .f.
EndIf

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldCtrForm ³ Autor ³ Marco Aurelio - Mano    ³ Data ³09/04/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida e atualiza tabela de controle de formularios em relacao ³±±
±±³          ³ao ultimo documento que esta sendo gerado.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³VldCtrForm(ExpC1,ExpC2,ExpC3,ExpC4)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Serie da NF                                            ³±±
±±³          ³ExpC2 = Especie da NF                                          ³±±
±±³          ³ExpC3 = Numero NF atual a ser retornada como valida            ³±±
±±³          ³ExpC4 = Tipo de processamento                                  ³±±
±±³          ³			1=Pegar Numero NF                                    ³±±
±±³          ³			2=Atualizar tabela de controle de formularios        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Localizacao Portugal                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldCtrForm(cSerie,cEspecie,cNumero,nTipo)
Local aArea     := GetArea()		// Salva area atual para posterior restauracao
Local cAliasTrb := GetNextAlias()	// Pega proxima area temporaria disponivel
Local cQuery    := ""				// Auxiliar para execucao de query
Local lRet      := .f.				// Conteudo de retorno
Local nPosIni   := 0				// Posicao inicial para busca de texto no combo do campo FP_ESPECIE
Local nInd      := 0				// Indexador de laco For/Next
Local cEspCombo := ""				// Texto correspondente a especie do documento
Local dUltNF    := CTOD("")			// Data da ultima NF gerada no periodo
Local cUltNF    := ""				// Numero da ultima NF gerada no periodo
Local cUltHora  := ""				// Hora da ultima NF gerada
Local aRegUso   := {}				// Array com numero dos registros dos periodos a serem retirados de uso
Local cMsg      := ""				// Mensagem de incosistencia ocorrido no processo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca posicao da descricao da especie da nota no combo da tabela SFP ³
//³(1=Fact;2=NCI;3=NDI;4=NCC;5=NDC;6=RFN;7=GRN;8=RET;9=RFD)             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->(dbSetOrder(2))
SX3->(dbSeek("FP_ESPECIE"))

cEspCombo := Iif(AllTrim(cEspecie)=="NF","Fact",cEspecie)
nPosIni   := At(AllTrim(cEspCombo),AllTrim(SX3->X3_CBOX))
cEspCombo := Substr(AllTrim(SX3->X3_CBOX),nPosIni-2,1)

If SFP->(ColumnPos("FP_VIGINI")) == 0 .and. SFP->(ColumnPos("FP_VIGFIN")) == 0
	Return(.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Colunas a serem exibidas como resultado da query ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SFP.*, R_E_C_N_O_ REGSFP FROM "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tabela do filtro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery += RetSqlName("SFP")+" SFP "	// Tabela de controle de formularios

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Condicoes para filtro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery += "WHERE "
cQuery += "FP_FILIAL  = '"+xFilial("SFP")+"' AND "
cQuery += "FP_FILUSO  = '"+cFilAnt       +"' AND "
cQuery += "FP_SERIE   = '"+cSerie        +"' AND "
cQuery += "FP_ESPECIE = '"+cEspCombo     +"' AND "
cQuery += "FP_ATIVO   = '1' AND "
cQuery += "SFP.D_E_L_E_T_ = ' ' "

cQuery += "ORDER BY FP_VIGINI "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.T.,.T.)

TcSetField(cAliasTrb,"FP_VIGINI","D",8,0)
TcSetField(cAliasTrb,"FP_VIGFIN","D",8,0)

(cAliasTRB)->(dbGoTop())

While !(cAliasTRB)->(EOF())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a nota gerada esta dentro de um periodo de vigencia valido no controle de formularios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	( dDataBase >= (cAliasTRB)->FP_VIGINI .and. dDataBase <= (cAliasTRB)->FP_VIGFIN )
		If nTipo == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca a data de emissao e o numero da ultima NF gerada para o periodo valido ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			UltNFSer(cSerie,cEspecie,(cAliasTRB)->FP_VIGINI,(cAliasTRB)->FP_VIGFIN,@dUltNF,@cUltHora,@cUltNF)

			If ( (dDataBase < dUltNF) .or. ( dDataBase == dUltNF .and. Time() < cUltHora ) )
				cMsg := STR0093+"("+AllTrim(cUltNF)+") "+STR0094+"("+AllTrim(DTOC(dUltNF))+"-"+cUltHora+")." // "Existe fatura gerada para esta série com data posterior a data atual: NF"###"Data de Emissão"
			ElseIf ( !Empty(cUltNF) .and. Soma1(cUltNF,TamSX3("F2_DOC")[1]) < ( Iif((dDataBase<>Date()),(cAliasTRB)->FP_NUMATU,cNumero)))
				cMsg := STR0095+"("+Iif((dDataBase<>Date()),(cAliasTRB)->FP_NUMATU,cNumero)+"/"+AllTrim(cSerie)+"), "+STR0096 	// "Numero anterior da NF"###"não existe. Por favor, verifique!"
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Determina se a serie se refere a um documento manual para permitir ou nao a edicao dos campos F2_DOCMAN/F2_SERMAN ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lDocMan := Iif( ((cAliasTRB)->FP_PROCMAN == "1") .or. ((cAliasTRB)->FP_RESTBKP == "1"),.t.,.f.)

		EndIf

		If Empty(cMsg)
			If ( nTipo == 1 ) .and. !lVldForm .and. ( dDataBase>Date() .and. ( (dUltNF<Date()) .or. (dDataBase>dUltNF) ) )
				Aviso(STR0008,STR0114+"("+DtoC(Date())+"-"+Time()+"), "+STR0115+"("+DtoC(dDataBase)+"-"+Time()+") "+STR0116+".",{"OK"}) // ##"Atenção###"Este documento esta sendo gerado em data posterior a data/hora atual##"após esta operação não será mais permitido a geração de documentos desta série para datas anteriores a data/hora"##"informada"
				lVldForm := .t.
		    EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o periodo estiver fora de uso considera como numero da NF o numero atual do periodo encontrado ³
			//³em vez da numeracao sequencial do SX5.                                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNumero := (cAliasTRB)->FP_NUMATU
			cNumero := Iif(nTipo==2,Soma1(cNumero,TamSX3("F2_DOC")[1]),cNumero)
	   		lRet    := .t.

			If nTipo == 2
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza a numeracao atual da proxima NF a ser gerada para o periodo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SFP->(dbGoTo((cAliasTRB)->REGSFP))
				RecLock("SFP",.F.)
				SFP->FP_NUMATU := cNumero

				If (  SFP->(ColumnPos("FP_DTULT")) > 0     ) .and. ( dDataBase > SFP->FP_DTULT )
					SFP->FP_DTULT := dDataBase
				EndIf
		 		SFP->(MsUnLock())
		    EndIf
		EndIf
		Exit
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda o numero dos registros dos periodos anteriores em uso que deverao ser encerrados ³
		//³caso se tratar da primeira NF gerada para o periodo vigente.                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty((cAliasTRB)->FP_USO)
			aAdd(aRegUso,(cAliasTRB)->(REGSFP))
		EndIf
	EndIf
	(cAliasTRB)->(dbSkip())
EndDo

If !lRet
	cMsg := Iif(Empty(cMsg),STR0086+"("+AllTrim(cSerie)+"/"+AllTrim(cEspecie)+").",cMsg) // ##"Não foi encontrado controle de formulário ativo para a Série/Espécie"
	Aviso(STR0008,cMsg,{"OK"}) // ##"Atenção"
ELSE
	If nTipo == 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tira de uso periodos anteriores ao periodo da NF gerada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nInd:=1 To Len(aRegUso)

			SFP->(dbGoTo(aRegUso[nInd]))

			RecLock("SFP",.F.)
			SFP->FP_USO := "2"
			MsUnLock()
		Next
	EndIf
EndIf

(cAliasTRB)->(dbCloseArea())

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³UltNfSer   ³ Autor ³ Marco Aurelio - Mano    ³ Data ³16/04/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Busca a data de emissao da ultima NF gerada no periodo         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³UltNfSer(ExpC1,ExpC2,ExpD1,ExpD2,ExpD3,ExpC3,ExpC4)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Serie da NF                                            ³±±
±±³          ³ExpC2 = Especie da NF                                          ³±±
±±³          ³ExpD1 = Data inicial do periodo                                ³±±
±±³          ³ExpD2 = Data final do periodo                                  ³±±
±±³          ³ExpD3 = Data da ultima nota do periodo retornada por referencia³±±
±±³          ³ExpC3 = Hora da ultima nota do periodo retornada por referencia³±±
±±³          ³ExpC4 = Ultima nota do periodo retornada por referencia        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Localizacao Portugal                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function UltNfSer(cSerie,cEspNF,dPerIni,dPerFin,dUltNF,cUltHora,cUltNF)
Local aArea     := GetArea()									 		// Salva area atual para posterior restauracao
Local cAliasTrb := GetNextAlias()								  		// Pega proxima area temporaria disponivel
Local cQuery    := ""											 		// Auxiliar para execucao de query
Local lGuiaTran := (AllTrim(FunName()) $ "MATA462N|MATA462AN")			// Determina se esta gerando uma Guia de Transporte
Local cAlias    := Iif(lGuiaTran,"SF2",Iif(cEspNF=="RFD","SF1","SF3"))	// Alias da tabela a ser considerado no filtro
Local cPrefTab  := Iif(lGuiaTran,"F2_",Iif(cEspNF=="RFD","F1_","F3_"))	// Prefixo da tabela da tabea a ser considerada no filtro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Colunas a serem exibidas como resultado da query ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT "+cAlias+"."+cPrefTab+"EMISSAO EMISSAO, "+cAlias+"."+cPrefTab+"HORA HORA, "+cAlias+"."+Iif(lGuiaTran,"F2_DOC",Iif(cEspNF=="RFD","F1_DOC","F3_NFISCAL"))+" NOTA FROM "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tabela do filtro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery += RetSqlName(cAlias)+" "+cAlias+" "	// Cabecalho de NFs(SF2/SF3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Condicoes para filtro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery += "WHERE "
cQuery += cPrefTab+"FILIAL='"+xFilial(cAlias)+"' AND "
cQuery += cPrefTab+"FORMUL = 'S' AND "
cQuery += cPrefTab+"HASH <> ' ' AND "
cQuery += cPrefTab+"SERIE = '"+cSerie+"' AND "
cQuery += cPrefTab+"EMISSAO BETWEEN '"+DTOS(dPerIni)+"' AND '"+DTOS(dPerFin)+"' AND "
cQuery += cPrefTab+"ESPECIE = '"+cEspNF+"' AND "
cQuery += cAlias+".D_E_L_E_T_ = ' ' "

If cAlias$"SF1|SF2"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Colunas a serem exibidas como resultado da query ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery += "UNION "
	cQuery += "SELECT "+cAlias+"CAN"+"."+cPrefTab+"EMISSAO EMISSAO, "+cAlias+"CAN"+"."+cPrefTab+"HORA HORA, "+cAlias+"CAN"+"."+Iif(lGuiaTran,"F2_DOC","F1_DOC")+" NOTA "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tabela do filtro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery += " FROM "+RetSqlName(cAlias)+"_CANC "+" "+cAlias+"CAN "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Condicoes para filtro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery += "WHERE "
	cQuery += cPrefTab+"FILIAL='"+xFilial(cAlias)+"' AND "
	cQuery += cPrefTab+"FORMUL = 'S' AND "
	cQuery += cPrefTab+"HASH <> ' ' AND "
	cQuery += cPrefTab+"SERIE = '"+cSerie+"' AND "
	cQuery += cPrefTab+"EMISSAO BETWEEN '"+DTOS(dPerIni)+"' AND '"+DTOS(dPerFin)+"' AND "
	cQuery += cPrefTab+"ESPECIE = '"+cEspNF+"' AND "
	cQuery += cAlias+"CAN"+".D_E_L_E_T_ = ' ' "

EndIf

cQuery += "ORDER BY NOTA DESC "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.T.,.T.)

TcSetField(cAliasTrb,"EMISSAO","D",8,0)

(cAliasTRB)->(dbGoTop())

dUltNF   := (cAliasTRB)->EMISSAO
cUltHora := (cAliasTRB)->HORA
cUltNF   := (cAliasTRB)->NOTA

(cAliasTRB)->(dbCloseArea())

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³PosSerForm ³ Autor ³ Marco Aurelio - Mano    ³ Data ³09/04/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Posiciona serie da tabela SFP                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PosSerForm(ExpC1,ExpC2)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Serie da NF                                            ³±±
±±³          ³ExpC2 = Especie do documento                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Localizacao Portugal                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PosSerForm(cSerie,cEspecie)
Local aArea      := GetArea()	// Salva area atual para posterior restauracao
Local nPosIni    := 0			// Posicao inicial para busca de texto no combo do campo FP_ESPECIE
Local cEspCombo  := ""			// Texto correspondente a especie do documento

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca posicao da descricao da especie da nota no combo da tabela SFP ³
//³(1=Fact;2=NCI;3=NDI;4=NCC;5=NDC;6=RFN;7=GRN;8=RET;9=RFD)             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->(dbSetOrder(2))
SX3->(dbSeek("FP_ESPECIE"))

cEspCombo := Iif(AllTrim(cEspecie)=="NF","Fact",cEspecie)
nPosIni   := At(AllTrim(cEspCombo),AllTrim(SX3->X3_CBOX))
cEspCombo := Substr(AllTrim(SX3->X3_CBOX),nPosIni-2,1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca serie na tabela SFP ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SFP->(DbSetOrder(5))
SFP->(dbSeek(xFilial("SFP")+cFilAnt+cSerie+cEspCombo))

RestArea(aArea)

Return

/*
±±³Fun‡ao    ³AlteraNIF    ³ Autor ³ Marco Aurelio - Mano    ³ Data ³03/01/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se existe documento gerado para o cliente que esta sendo³±±
±±³          ³alterado o NIF nao permitindo manutencao neste caso.             ³±±
*/
Function AlteraNIF()
Local aArea := GetArea()	// Salva area atual para posterior restauracao
Local lRet  := .T.			// Conteudo de retorno

//³Verifica se ja foi gerado algum PV ou outro documento para o cliente que esta sendo alterado ³
If (	!Empty(Posicione("SF1",2,xFilial("SF1")+M->A1_COD+M->A1_LOJA,"F1_FORNECE"))   .or. ;
		!Empty(Posicione("SF2",2,xFilial("SF2")+M->A1_COD+M->A1_LOJA,"F2_CLIENTE"))   .or. ;
		!Empty(Posicione("SC5",3,xFilial("SC5")+M->A1_COD+M->A1_LOJA,"C5_CLIENTE")) ) .and.;
		!Empty(SA1->A1_CGC)

	lRet := .F.

EndIf

RestArea(aArea)

Return(lRet)

/*/
±±³Fun‡…o    ³VldNumPTG  ³ Autor ³ Cicero J. Silva      | Data ³ 22/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava informações do SAFT na tabela SF3                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³VldNumPTG()                                                 ³±±
/*/
//cTipo - 1 - Verifica se existe HASH para esta serie, se sim retorna o Hash
//cTipo - 2 - Valida Exclusao / Cancelamento
//cTipo - 3 - Valida existencia no SF3
Function VldNumPTG(cIniNUM,cIniSER,cTipo)

Local aArea     := GetArea()
Local aAreaSF3  := SF3->(GetArea())
Local cRetHash  := ""
Local cQuery    := ""
Local cQryGrl   := ""
Local lInicial  := .F.
Local lUltNot   := .F.
Local cUltNot   := ""
Local cAliasTMP := GetNextAlias()
Local lGuiaTran := (AllTrim(FunName()) == "MATA462N")
Local cQryExHsh := "SELECT COUNT(*) NOTA "
Local cQryPgHsh := "SELECT "+Iif(lGuiaTran,"F2","F3")+"_HASH NOTA "
Local cQryPgUNf := "SELECT MAX("+Iif(lGuiaTran,"F2_DOC","F3_NFISCAL")+") NOTA "

Default cTipo := "4"

If TcSrvType()<>"AS/400"

	If lGuiaTran
		cQryGrl := "  FROM " + RetSqlName("SF2") + " SF2 "
		cQryGrl += " WHERE SF2.F2_FILIAL='"+xFilial("SF2")+"' "
		cQryGrl += "   AND SF2.D_E_L_E_T_ = ' ' "
		cQryGrl += "   AND SF2.F2_FORMUL = 'S' "
		cQryGrl += "   AND SF2.F2_ESPECIE = 'RFN' "
		cQryGrl += "   AND SF2.F2_HASH <> '' "
		cQryGrl += "   AND SF2.F2_SERIE = '"+cIniSer+"' "
	Else
		cQryGrl := "  FROM " + RetSqlName("SF3") + " SF3 "
		cQryGrl += " WHERE SF3.F3_FILIAL='"+xFilial("SF3")+"' "
		cQryGrl += "   AND SF3.D_E_L_E_T_ = ' ' "
		cQryGrl += "   AND SF3.F3_FORMUL = 'S' "
		cQryGrl += "   AND SF3.F3_HASH <> '' "
		cQryGrl += "   AND SF3.F3_SERIE = '"+cIniSer+"' "
	EndIf

	If Select(cAliasTMP) > 0
		dbSelectArea(cAliasTMP)
		dbCloseArea()
	EndIf

	If !lGuiaTran
		SF3->(dbCommit())
	EndIf

	If cTipo <> "3"
		cQuery := cQryExHsh + cQryGrl
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)

		lInicial := If((cAliasTMP)->NOTA == 0,.T.,.F.)

		(cAliasTMP)->(dbCloseArea())

		If !lInicial
			cQuery := cQryPgUNf + cQryGrl
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)

			cUltNot := (cAliasTMP)->NOTA

			(cAliasTMP)->(dbCloseArea())

			lUltNot := (cIniNUM == IIf(cTipo == "2",cUltNot,Soma1(cUltNot)))
		EndIf
		If !lInicial .And. lUltNot .And. !(cTipo $ "1/2")
			cQuery := cQryPgHsh + cQryGrl
			cQuery += "   AND "+Iif(lGuiaTran,"F2_DOC","F3_NFISCAL")+" = '"+cUltNot+"' "

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)

			cRetHash := (cAliasTMP)->NOTA

			(cAliasTMP)->(dbCloseArea())
		ElseIf !lUltNot .And. cTipo <> "2"
			cRetHash := "INICIAL"
		EndIf
		If !lInicial .And. cTipo == "1"
				cRetHash := IIf(lUltNot,cUltNot,"")
		EndIf
		If !lInicial .And. lUltNot .And. cTipo == "2"
				cRetHash := cUltNot
		EndIf
	Else
		cQuery := cQryPgUNf + cQryGrl
		cQuery += "   AND "+Iif(lGuiaTran,"F2_DOC","F3_NFISCAL")+" = '"+cIniNUM+"' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)

		cRetHash := (cAliasTMP)->NOTA

		(cAliasTMP)->(dbCloseArea())
	EndIf
EndIf
dbSelectArea("SF3")

RestArea(aAreaSF3)
RestArea(aArea)

Return( cRetHash )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³MATA467C     ³ Autor ³ Marco Aurelio - Mano    ³ Data ³12/09/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Consulta de NFs canceladas - Portugal                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MATA467C()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT - Portugal                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA467C(xAutoCab,xAutoItens,nOpcAuto,lSeek,nTipoOper)
Local nTipo		:= 0
Local nPosTipo	:= 0
Local lNfAuto 	:= ( ValType(xAutoCab) == "A"  .AND. ValType(xAutoItens) == "A" )
Local cFunName	:= IIf(Type("cFunName")=="U",Upper(Alltrim(ProcName())),cFunName)	//Funcao Origem
DEFAULT lSeek	:=	.T.

PRIVATE aParamGer := {}

//AJUSTASX3NF2()
nOpcAuto := If(nOpcAuto==NIL,3,nOpcAuto)

If lNfAuto
	nPosTipo:= Ascan(xAutoCab,{|aCab| aCab[1] == "F2_TIPODOC"})
	nTipo	:= Val(xAutoCab[nPosTipo,2])
	If nTipo == 0
		nTipo := 1		// Normal
	EndIf
Else

	If Pergunte("MT467CPER",.T.)

		nTipo := 1

		aAdd(aParamGer,2)
		aAdd(aParamGer,MV_PAR01)
		aAdd(aParamGer,MV_PAR02)
		aAdd(aParamGer,"F2_EMISSAO")
		aAdd(aParamGer,"F2_TIPODOC NOT IN('55','50')")

	EndIf
EndIf

If nTipo > 0
	LocxNf(nTipo,xAutoCab,xAutoItens,nOpcAuto,cFunName,lSeek,nTipoOper)
Endif

SetKey(VK_F4	,{|| Nil })
SetKey(VK_F5	,{|| Nil })
SetKey(VK_F6	,{|| Nil })
SetKey(VK_F7	,{|| Nil })
SetKey(VK_F8	,{|| Nil })
SetKey(VK_F9	,{|| Nil })
SetKey(VK_F10	,{|| Nil })
SetKey(VK_F11	,{|| Nil })
SetKey(VK_F12	,{|| Nil })
Return

/*
±±³Fun‡ao    ³FormLibre ³ Autor ³ Paulo              ³Data³11/05/18  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se o numero já existe e altera para o proximo ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT - Venezuela                                    ³±±
*/
Function FormLibre()
Local cCmp := ReadVar()
Local cPrefixo := SubStr(cCmp, AT("_", cCmp)-2, 2)
Local cFormLib:=""
//Local aAreaAtu:=GetArea()
Local lRetVld:=.F.
cFormLib :=PesqForm()
lRetVld:=VldFormL(cFormLib)
If lRetVld
	&('M->' + cPrefixo + '_FORMLIB') :=  cFormLib
EndIf
Return lRetVld
//Pegar prx disponivel -> Fatura manual
Function AtuNumFL(cNumFL)

Local cTabela   := ""
Local cChave    := ""
//Local cNumForm	:= ""
Local cNumAtu:= cNumFL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acertando formato da numeracao da NF ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTabela := "W1"
cChave  := "FL"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionando SX5³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSelectArea("SX5")
DBSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua atualizacao da numeracao da nota³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If DBSeek(xFilial("SX5")+cTabela+AllTrim(cChave))
	If !Empty(cNumFL) .and. Alltrim(X5Descri()) <> cNumFL
		cNumAtu:=Alltrim(X5Descri())
		lAltNum:=.T.
		While lAltNum
			If cNumAtu == Alltrim(X5Descri())
				lAltNum:=.F.
			Else
				cNumAtu:=Alltrim(X5Descri())
			EndIf
		EndDo
	EndIf
	ATuTabFL(cNumAtu)
	If cNumAtu <> cNumFL
		MsgAlert(STR0203+ cNumFL + STR0204 + cNumAtu  )
	EndIf
EndIf

Return(cNumAtu)

/*
±±³Fun‡ao    ³PesqForm ³ Autor ³Paulo   ³ Data ³11/05/18  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Pesquisa na tabela o prx numero de folio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT - Venezuela                         ³±±
*/
Function PesqForm()

//Local aAreaAtu:=GetArea()
Local cNumForm:= ""

SX5->(DBSetOrder(1))
If SX5->(MsSeek(xFilial("SX5")+"W1FL"))
	cNumForm := Alltrim(X5Descri())
EndIf

Return (cNumForm)

/*
±±³Fun‡ao    ³VldFormL ³ Autor ³Paulo   ³ Data ³11/05/18  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida seo formulario esta disponivel      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT - Venezuela                         ³±±
*/
Function VldFormL(cNumForm)
Local lFormVld:=.F.
Local aAreaAt:=GetArea()

F3L->(DbSetOrder(1))
If (F3L->(DbSeek(xFilial("F3L") + cFilAnt )))
	While F3L->F3L_FILIAL+F3L->F3L_FILUSO == xFilial("F3L")+cFilAnt .AND. !F3L->(EOF()) .And. !lFormVld
		If  F3L->F3L_STATUS == "1" .And.  Val(cNumForm) >= Val(F3L->F3L_NUMINI) .And. Val(cNumForm) <= Val(F3L->F3L_NUMFIM)
			lFormVld:=.t.
			Exit
		Endif
		F3L->(dbSkip())
	EndDo
EndIf
RestArea(aAreaAt)
If !lFormVld
	MsgStop(STR0205 + cNumForm + STR0206, STR0207)
EndIf

Return(lFormVld)

/*
±±³Fun‡ao    ³ATuTabFL ³ Autor ³Paulo    ³ Data ³11/05/18  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Atualiza a numeração dos folios na tabela sx5³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT - Venezuela                          ³±±
*/
Function ATuTabFL(cNumForm)
//Local aAreaAt:=GetArea()
Local cPrxMun:=""
SX5->(DBSetOrder(1))
If SX5->(MsSeek(xFilial("SX5")+"W1FL"))
	cPrxMun:= Soma1(aLLTRIM(cNumForm))
	RecLock("SX5",.F.)
	Replace X5_DESCRI  with cPrxMun
	Replace X5_DESCSPA with cPrxMun
	Replace X5_DESCENG with cPrxMun
	MsUnLock()
	RecLock("F3L",.F.)
	F3L->F3L_NUMATU:= cPrxMun
	MsUnLock()

EndIf
Return()

Function ArgSerPV(cSerie)
Local nAt := 0

	If cPaisLoc == "ARG" .and. Type("cIdPVARG") == "C"
		nAt := AT(cIdPVARG,cSerie)
		If nAt > 0
			cSerie := Substr(cSerie,1,nAt-1)
		EndIf
	EndIf

Return cSerie


/*/{Protheus.doc} fValDocSer
Validación de serie y núemro de documento, asignación de SERIE2 (COL).
@type function
@author arodriguez
@since 28/08/2018
@version 1.0
@param
/*/
Function fValSerDoc()
Return fSerDocCol()

/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LocNumIt ³ Autor ³ Rafael Santos       ³ Data ³ 27/12/18     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Baseada na rotina A460NumIt() - MATXFUNB                    ³±±
±±³          ³Apenas para Argentina.                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LocNumIt2(cSerie,cNomeFun)
Local cAlias :=Alias()
Local nItens :=0
Local cParam :=""
Local nItAux := 0

Default cNomeFun := FUNNAME()


nItens := GETMV("MV_NUMITEN")
cParam := "MV_ITEM" + cSerie
nItens := GetNewPar(cParam,nItens)
nItAux := nItens

If ExistBlock("LOCITEM2")
	nItens := ExecBlock("LOCITEM2",.F.,.F.,{nItens,cSerie,cNomeFun})
EndIf
IF VALTYPE(nItens) <> "N"
	nItens:=nItAux
ENDIF
DbSelectArea(cAlias)

Return(nItens)
//ºPrograma  ³Compcont  ºAutor  ³Danilo Santos        º Data ³  07/03/19   º±±
//±±ºDesc.   ³Funcao para validar a situação da nota  na AFIP              º±±
Function Compcont(cAliasC,cAliasCF,aGetsTela,aCfgNF,lvalcons)
Return VldSitComp(cAliasC,cAliasCF,aGetsTela,aCfgNF,lvalcons)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Programa  ³GetIdEnt  ³ Autor ³Danilo Santos ³ Data ³07.03.2019³		 ±
//³Descri‡…o ³Obtem o codigo da entidade apos enviar o post para o TSS ±
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static Function GetIdEnt(cCodFil,cAviso,lAviso)

Return fIdEntidad(cCodFil,cAviso,lAviso)

/*
±±ºPrograma ³Afipcons ºAutor  ³Danilo Santos º Data ³ 01/02/18 º±±
±±ºDesc.   ³Funcao para validar a situação da nota na AFIP     º±±
±±ºatraves do campo F1_VALCONS ou F2_VALCONS                   º±±
*/
Function Afipcons ()
Return fAfipCons(__aCpTela, aCfgNF)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ Rettpdoc   ³Autor ³ Danilo Santos³ Fecha ³23/02/2018       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Función para obtener el tipo de documento en base al tipo y³±±
±±³           ³ la serie.                                                  ³±±
±±³Sintaxis   ³ TpDocRET()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/
Function Rettpdoc(cSerie,cTipo,cAliasC)
Return fObtTipDoc(cSerie,cTipo,cAliasC)

/*ºPrograma  ³LxVldDocIt ºAutor  ³  Marco Augusto    º Data ³  25/04/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida documento informado en D2_NFORI/D1_NFORI con serie enº±±
±±º          ³D2_SERIORI/D1_SERIORI para NDC/NCC - Colombia.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Folio del documento                                  º±±
±±º          ³ExpC2: Serie del documento                                  º±±
±±º          ³ExpC3: Especie del documento (NDC/NCC)                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL : Verdadero cuando el documento está transmitido o se  º±±
±±º          ³       hayan informado los campos.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF - Colombia/Perú                                      º*/
Function LxVldDocIt(cNumeroDoc, cSerie, cEspecie)
	Local lRet	:= .T.
	Local lM485PE := .T.
	Local cCliForE:= IIf(cEspecie=="NDC",M->F2_CLIENTE,M->F1_FORNECE)
	Local cLojaE  := IIf(cEspecie=="NDC",M->F2_LOJA,M->F1_LOJA)

	Default cNumeroDoc	:= ""
	Default cSerie		:= ""
	Default cEspecie	:= ""
	
	If ExistBlock("M465DORIFE")
		lM485PE := ExecBlock("M465DORIFE",.F.,.F.,{xFilial("SF2"),cNumeroDoc,cSerie,cCliForE,cLojaE})
	EndIf

	If cPaisLoc == "COL"
		lRet := VdDocItCol(cNumeroDoc, cSerie, cEspecie, lM485PE)
		Return lRet
	ElseIf cPaisLoc == "PER"
		lRet := VdDocItPer(cNumeroDoc, cSerie, cEspecie, lM485PE)
		Return lRet
	ElseIf cPaisLoc == "BOL"
		lRet := VdDocItBol(cNumeroDoc, cSerie, cEspecie, lM485PE)
		Return lRet
	EndIf
	
Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcion    ³TESAutoCOL  ³ Autor ³ ARodriguez            ³ Data ³20/06/2019³
ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descripcion³ Automatiza el uso de TES y CF en Compras y Facturacion. (COL)³
ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxis   ³ TESAutoCol(ExpC1)                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros ³ ExpC1 = Tabla de actuacion                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno    ³ .T.                                                          ³
ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso        ³ SIGAFAT - Se ejecuta en Valid de campos (SX3)                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function TESAutoCol(cTabla)
Return xTesAutCol(cTabla)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ Lx2030CO   ³Autor ³ Luis Enríquez³ Fecha ³15/08/2019       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Función para agregar acciones en modificación de clientes  ³±±
±±³           ³ para colombia.                                             ³±±
±±³Sintaxis   ³ Lx2030CO()                                                 ³±±
±±³Uso        ³ MATN030                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/
Function Lx2M030CO(aButtons)
Return x2M030COL(@aButtons)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ ValIMMEX   ³Autor ³ Verónica Flores³ Fecha ³30/08/2019     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Función para validar si el cliente cuenta con Registro     ³±±
±±³           ³ IMMEX para México en Facturas de Exportación.              ³±±
±±³Sintaxis   ³ ValIMMEX(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                    ³±±
±±ºParametros ³ ExpC1   : IMMEX del documento                              ³±±
±±º           ³ ExpC2   : Cliente del documento                            ³±±
±±º           ³ ExpC3   : Sucursal del Documento                           ³±±
±±º           ³ ExpC4   : 1-X3_VALID 2- X3_WHEN                            ³±±
±±º           ³ ExpC5   : Tabla del Documento                              ³±±
±±³Uso        ³ MATA467N | MATA410                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/
Function ValIMMEX(cImmex,cCliente,cLoja,cPropiedad,cTabla)
Return xVldIMMEX(cImmex,cCliente,cLoja,cPropiedad,cTabla)

/*³Funcion    ³ lVldDesEnt ³Autor ³ Marco Augusto       ³ Fecha ³24/09/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Valida detonacion de gatillo para NCC con MV_DESCSAI = 1   ³±±
±±³Sintaxis   ³ lVldDesEnt(cExp1)                                          ³±±
±±ºParametros ³ cExp1 = Tipo de Documento                                  ³±±
±±³Uso        ³ Gatillo 001 y 002 del campo D1_DESC                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´*/
Function lVldDesEnt(cTipDoc)
	Local lRet			:= .F.
	Local lVldDescNCC	:= SuperGetMv("MV_DESCSAI", .F., "1") == "1" .And. FunName() == "MATA465N"
	
	Default cTipDoc		:= ""
	
	If IIf(cTipDoc == "NCC", lVldDescNCC, !lVldDescNCC)
		lRet := .T.
	EndIf
	
Return lRet

/*Graba la clave de la zona fiscal EUA */
Function SF3ZONFIS(aCfgNf, cFunname)
Return LxGrvLFEUA(aCfgNf, cFunname)

/*Llena Estado de Entrega, y estado Emision  EUA */
Function LlnVal()
Return LxlnValEUA()

/* Valida campos para el país Colombia. */
Function LxVldCol(cAliasSF)
Return xVldCpoCol(cAliasSF)

/*/
±±³Fun‡…o    ³ VigValida   ³ Autor ³ Marivaldo         ³ Data ³23.04.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida la vigencia de 2 meses de una NF                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M100XIBP/M460XIBP/M100XIB2/M460XIB2                        ³±±
/*/
Function VigValida(dFechaO,dFechaV)
Local nMes      := Month(dFechaO)
Local nMesD     := nMes + 2
//Local nMesAux   := 0
Local lRet:= .F.
 
If nMesD>12
    If nMesD == 13  .and. ( Month(dFechaV)  <= 12  .And. Year(dFechaV) == Year(dFechaO) )   .Or.  (Month(dFechaV)  == 1  .And.  Year(dFechaV) == Year(dFechaO) +1)
	 	lRet:= .T.
	ElseIf nMesD == 14 .And. ( (Month(dFechaV) = 12  .And. Year(dFechaV) == Year(dFechaO) )   .Or.  (Month(dFechaV)  <=2  .And.  Year(dFechaV) == Year(dFechaO) +1)  )
		lRet:= .T.
	EndIf
 ElseIf   Month(dFechaV) <=  Month(dFechaO)+2   .and. Year(dFechaO) == Year(dFechaV)
 	lRet:= .T.
 EndIf
     
Return lRet

/*/{Protheus.doc} ValSFP
Funcion que agrega los elementos 3 y 4 al arreglo aRet con el contenido de los campos FP_CAI y FP_NRCERT
utilizados en la facturacion electronica
Example:	ValSFP( @aRet )
@param		aRet = Arreglo con elementos: 1o - Cliente / 2-Numero de documento / 3o-Serie
@return		aRet =  Arreglo con elementos: 1° - Num. de documento / 2° - Serie / 3° Num. Aprobación / 4° Certificado
@author		Eduardo Pérez Manríquez
@since		04/03/2020
@version	12
/*/
Function ValSFP(aRet)
	Local cNumero := aRet[2]
	Local cSerie  := aRet[3]
	Local cFilSFP := xFilial("SFP")
	Local cCombo  := ""
	Local aEsp    := {}
	Local aDatosE := {}
	Local nX      := 0
	Local nPos    := 0
	Local aArea     := GetArea()
	
	DbSelectArea("SFP")
	DbSetOrder(5) // FP_FILIAL + FP_FILUSO + FP_SERIE + FP_ESPECIE + SP_PV
	If SFP->(ColumnPos("FP_CAI")) > 0 .AND. SFP->(ColumnPos("FP_NRCERT")) > 0
		// Busca pos. da descricao da especie da nota no combo da tabela SFP (1=NF;2=NCI;3=NDI;4=NCC;5=NDC)
		cSX3Combo := Alltrim(GetSX3Cache("FP_ESPECIE","X3_CBOX"))
		aEsp := StrTokArr(cSX3Combo, ";")
		For nX := 1 To Len(aEsp)
			aAdd(aDatosE,StrTokArr(aEsp[nX], "="))
		Next nX
		nPos := AScan(aDatosE,{|x|Alltrim(x[2])==cEspecie})
		cCombo := IIf(nPos>0,aDatosE[nPos][1],"")
	
		// Verifica se a nota selecionada esta dentro de algum range cadastrado
		// Necessario em caso de existir mais de um range com a mesma serie
		SFP->(DbSeek(cFilSFP + cFilAnt + cSerie + cCombo)) // FP_FILIAL + FP_FILUSO + FP_SERIE + FP_ESPECIE
		While SFP->FP_FILIAL + SFP->FP_FILUSO + SFP->FP_SERIE + SFP->FP_ESPECIE == cFilSFP + cFilAnt + cSerie + cCombo
			If Val(cNumero) >= Val(SFP->FP_NUMINI) .AND. Val(cNumero) <= Val(SFP->FP_NUMFIM)
				Exit
			EndIf
			SFP->(dbSkip())
		EndDo
		aRet := {cNumero, cSerie, SFP->FP_CAI, SFP->FP_NRCERT}
	Else
		aRet := {cNumero, cSerie, "", ""}
	EndIf
	RestArea(aArea)
Return aRet
/*/{Protheus.doc} FinSEVAut
Funcion que valida y genera informacion de SEV (aColsSEV y aHeadSEV) y SEZ (tabla temporal SEZTMP) para
posteriormente guardar valores en la funcion GRAVASEV (LOCXNF)
Example:	FinSEVAut( aRatEvEz,aColsSEV,aHeadSEV )
@param		aRatEvEz = Arreglo con los valores de multi naturaleza y prorrateo de centro de costo
@param		aColsSEV = Arreglo de salida. Contiene valores de multi naturaleza
@param		aHeadSEV = Arreglo de salida. contiene estructura campos SEV
@return		lRet =  Valor boleano. Validaciones.
@author		Alfredo Medrano
@since		16/02/2021
@version	12
/*/
Function FinSEVAut(aRatEvEz,aColsSEV,aHeadSEV)
Return FinSEVEUA(aRatEvEz,@aColsSEV,@aHeadSEV)

Function LxCposBol(aCposNF, cTabla)
	If  FindFunction("LxCpoBol")
		aCposNF := LxCpoBol(aCposNF, cTabla) //Se detona la función de la LOCXBOL.PRW
	Else
		Help("",1,"LxCpoBol",,STR0252 + "LxCpoBol()",1,0) //"Rutina desatualizada, solicite paquete con actualizaciones:"
	Endif
Return aCposNF

/*/{Protheus.doc} LxCposCol
Indirección -  se realiza referencia a funcion LxCpoCol
Example:	LxCposCol(aCposNF, cFunName, cTablaEnc )
@param aCposNF, Array, Array con campos del encabezado de NF
@param cFunName, Character, Codigo de rutina
@param cTablaEnc, Character, Alias del encabezado de Notas Fiscales
@return		aCposNF =  Campos para el Encabezado de Notas Fiscales.
@author		Alfredo Medrano
@since		19/03/2021
@version	12
/*/
Function LxCposCol(aCposNF, cFunName, cTablaEnc)
	If  FindFunction("LxCpoCol")
		aCposNF := LxCpoCol(aCposNF, cFunName, cTablaEnc) //Se detona la función de la LOCXCOL.PRW
	Else
		Help("",1,"LxCpoCol",,STR0252 + "LxCpoCol()",1,0) //"Rutina desatualizada, solicite paquete con actualizaciones:"
	Endif
Return aCposNF

/*/{Protheus.doc} fCposNf2
Indirección -  se realiza referencia a funcion LxCposMex

@param		aCposNF, Array, Array con campos del encabezado de NF
@param 		cFunName, Character, Codigo de rutina
@param		cTablaEnc, Character, Alias del encabezado de Notas Fiscales
@example	fCposNf2(aCposNF, cFunName, cTablaEnc )
@author		luis.enriquez
@since		05/03/2020
@version	2.0
/*/
Function fCposNf2(aCposNF, cFunName, cTablaEnc)
	If FindFunction("LxCposMex")
		LxCposMex(@aCposNF, cFunName, cTablaEnc) //Se detona la función de la LOCXMEX.PRW
	Else
		Help("",1,"LxCposMex",,STR0252 + "LxCposMex()",1,0) //"Rutina desatualizada, solicite paquete con actualizaciones:"
	Endif
Return

/*/{Protheus.doc} VldUUID
Indirección -  se realiza referencia a funcion LxVldUUID

@example	VldUUID()
@author		laura.medina
@since		01/07/2015
@version	2.0
/*/
Function VldUUID()
	Local lRet := .F.
	If FindFunction("LxVldUUID")
		lRet := LxVldUUID() //Se detona la función de la LOCXMEX
	Else
		Help("",1,"LxVldUUID",,STR0252 + "LxVldUUID()",1,0) //"Rutina desatualizada, solicite paquete con actualizaciones:"
	Endif
Return lRet

/*/{Protheus.doc} valProdBloq
	(Validacion para determinar si un pedido de venta contiene productos bloqueados)
	@type  Static Function
	@author alejandro.parrales
	@since 24/09/2021
	@version 1.0
	@param numero pedido venta
	@return .T. o .F.
	@see ( ISSUE DMICNS-12958)
/*/
Static Function valProdBloq(cSeek)
	Local aArea := GetArea()
	Local lRetorn := .F.
	Default cSeek := ""
	dbSelectArea("SC7")
	dbSetOrder(14)
    While (!Eof() .And. SC7->C7_FILENT+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM==cSeek)
		If !valProd(SC7->C7_PRODUTO,.F.)
			lRetorn := .T.
		EndIf
		dbSkip()
	EndDo
	RestArea(aArea)
Return lRetorn
/*/{Protheus.doc} valProd
	(Validacion para determinar el bloqueo de un producto)
	@type  Static Function
	@author alejandro.parrales
	@since 24/09/2021
	@version 1.0
	@param1 codigo de producto
	@param2 determina si se mostrara mensaje de alerta
	@return .T. o .F.
	@see ( ISSUE DMICNS-12958)
/*/
Static Function valProd(cCodiPro,lAlert)
	Local aArea := GetArea()
	Local lRetorn := .T.
	Default cCodiPro := ""
	Default lAlert := .F.
	DbSelectArea("SB1")
	DbSetOrder(1)
	MsSeek(xFilial("SB1")+cCodiPro, .F.)
	If !RegistroOk("SB1",.F.)
		Iif(lAlert,MsgAlert(STR0259, STR0256),.T.)
		lRetorn := .F.
	EndIf
	RestArea(aArea)
Return lRetorn

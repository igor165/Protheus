#INCLUDE "MATA143.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWLIBVERSION.CH'

#DEFINE VALMERC  	 1  // Valor total da mercadoria
#DEFINE VALDESC 	 2  // Valor total do desconto
#DEFINE FRETE   	 3  // Valor total do Frete
#DEFINE VALDESP 	 4  // Valor total da despesa
#DEFINE SEGURO		 5  // Valor total do seguro
#DEFINE VALBRU		 6  // Valor total da Invoice
#DEFINE PACKING     7  // Valor total do packing
#DEFINE TOTDESP     8  // Valor total das Despesas Acessorias
#DEFINE _D1_BASIMPA 15
#DEFINE _D1_BASIMPB 16
#DEFINE _D1_BASIMPC 17
#DEFINE _D1_BASIMPD 18
#DEFINE _D1_BASIMPE 19
#DEFINE _D1_BASIMPF 20
#DEFINE _D1_BASIMPG 21
#DEFINE _D1_BASIMPH 22
#DEFINE _D1_BASIMPI 23
#DEFINE _D1_BASIMPJ 24
#DEFINE _D1_BASIMPK 25
#DEFINE _D1_BASIMPL 26
#DEFINE _D1_BASIMPM 27
#DEFINE _D1_BASIMPN 28
#DEFINE _D1_BASIMPO 29
#DEFINE _D1_BASIMPP 30
#DEFINE _D1_BASIMPQ 31
#DEFINE _D1_BASIMPR 32
#DEFINE _D1_BASIMPS 33
#DEFINE _D1_BASIMPT 34
#DEFINE _D1_BASIMPU 35
#DEFINE _D1_BASIMPV 36
#DEFINE _D1_BASIMPW 37
#DEFINE _D1_BASIMPX 38
#DEFINE _D1_BASIMPY 39
#DEFINE _D1_BASIMPZ 40

Static _lMetric	:= Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MATA143  ³ Autor ³ Alexandre Inacio Lemes  ³Data  ³18/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Despacho do Processo de Importacao Compras Internacional     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void MATA143(ExpA1,ExpA2,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum				                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                        ACTUALIZACIONES                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Fecha  ³ BOPS ³  Comentario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Raúl Ortiz M ³12/12/17³DMICNS³Se agrega campo F1_DESCONT para tipo de    ³±±
±±³             ³        ³615   ³documento 6 - Argentina                    ³±±
±±³Marcos Aur   ³26/01/18³DMICNS³Incuido PE MT143TGV pais chile             ³±±
±±³             ³        ³818   ³                                           ³±±
±±³L. Samaniego ³13/02/18³DMICNS³Se crea el Punto de Entrada en la funcion  ³±±
±±³             ³        ³-930  ³A143GeraNF antes de la creacion de docs.   ³±±
±±³             ³        ³      ³Pais: Bolivia                              ³±±
±±³gSantacruz   ³17/04/18³DMINA-³Localizado para Colombia.                  ³±±
±±³             ³        ³-2483 ³                                           ³±±
±±³gSantacruz   ³17/04/18³DMINA-³Correccion al costo del producto, cuando   ³±±
±±³             ³        ³-2611 ³genera factura de gastos.                  ³±±
±±³LuisEnríquez ³25/04/18³DMINA-³Replica DMINA-1336 - Grabar D1_CUSTO en    ³±±
±±³             ³        ³  1766³documentos de despacho (FOB y gastos) Perú ³±±
±±³M.Camargo    ³05/06/18³DMINA-³Se agragan variables nMoedaPed y nTxMoeda  ³±±
±±³             ³        ³  3106³para que tome la moneda y tasa de la NF que³±±
±±³             ³        ³      ³está siendo capturada y realice el cálculo ³±±
±±³             ³        ³      ³del RF0 si la TES lo amerita.              ³±±
±±³  Marco A.   ³12/11/18³DMINA-³Se agrega DBCloseArea, sin Alias de tabla, ³±±
±±³             ³        ³  3974³debido a que ocasionada error con tabla DBB³±±
±±³             ³        ³      ³al visualizar, modificar, borrar y generar ³±±
±±³             ³        ³      ³documentos en Despachos.                   ³±±
±±³GSA/ARL      ³05/03/19³DMINA-³Factura de seguro. ARG                     ³±±
±±³             ³        ³  5672³- F1_DESCONT en encabezado                 ³±±
±±³             ³        ³      ³- D1_SEGUM en todos los items              ³±±
±±³             ³        ³      ³- lMSErroAuto en retorno de GravaNfGeral() ³±±
±±³Alf. Medrano ³05/03/19³DMINA-³En fun A143Produto se quita fun MaColsToFis³±±
±±³             ³        ³  5671³ésta reiniciaba el array aNfItem con la fun³±±
±±³             ³        ³      ³MaFisClear en MATXFIS por consecuencia no  ³±±
±±³             ³        ³      ³identificaba los ítems borrados, también se³±±
±±³             ³        ³      ³agrega la fun MaFisRef con IT_PRODUTO para ³±±
±±³             ³        ³      ³llenar correctamente el campo TES cuando el³±±
±±³             ³        ³      ³producto tiene TES relacionado.            ³±±
±±³             ³07/03/19³      ³En fun M143TudOk en la validación de gastos³±±
±±³             ³        ³      ³valida que el ítem a procesar este activo  ³±±
±±³             ³        ³      ³antes de validar si TES permite cant. en 0 ³±±
±±³   Marco A.  ³11/03/19³AUTMI-³Se agrega tratamiento para ejecucion de    ³±±
±±³             ³        ³  219 ³test automatizados en MATA143. (ARG)       ³±±
±±³Oscar G.     ³12/09/19³DMINA-³En la fun. A143RatDesp() se quita de la    ³±±
±±³             ³        ³ 7302 ³localización por país a Peru al agregar el ³±±
±±³             ³        ³      ³valor de V1_VALDESC. (PER)                 ³±±
±±³ARodriguez   ³18/10/19³DMINA-³Atender configuración de MV_RATDESP para   ³±±
±±³             ³        ³  7258³prorrateo de flete/gastos/seguro por peso. ³±±
±±³             ³        ³      ³M143Peso() envia peso a MatxFis. (PER)     ³±±
±±³LuisEnríquez ³11/12/19³DMINA-³Se modifica para generar Fact. de gastos   ³±±
±±³             ³        ³7767  ³llamando función GravaNfGeral en lugar de  ³±±
±±³             ³        ³      ³execauto a MATA101N. (PER)                 ³±±
±±³Eduardo Prz  ³07/05/20³DMINA-³Se agrega validación en funcion A143GeraNF ³±±
±±³             ³        ³9063  ³para considerar el campo F1_TPRENTA en el  ³±±
±±³             ³        ³      ³arreglo para proveedor no domiciliado (PER)³±±
±±³Oscar G.     ³19/06/20³DMINA-³En la fun. A143RatDesp() se crea variable  ³±±
±±³             ³        ³ 9458 ³local NPORCTOTAL. (PER)                    ³±±
±±³José González³03/08/20³DMINA-³Se Elimina la funcionalidad de lGastPER y  ³±±
±±³             ³        ³9551  ³ahora generar Fact. de gastos llamando     ³±±
±±³             ³        ³      ³execauto MATA101N.                         ³±±
±±³Vero Flores  ³05/08/20³DMINA-³Se modifica las funciones M143LOk2,M143F5PO³±±
±±³             ³        ³9578  ³M143ProcPO y se crean las funciones        ³±±
±±³             ³        ³      ³M143Busca,M143Cant,M143CantBD,A143Cant     ³±±
±±³             ³        ³      ³para muestre correctamente el saldo        ³±±
±±³             ³        ³      ³disponible en la PO.                       ³±±
±±³Oscar G.     ³09/09/20³DMINA-³En fun. M143F6PO() se usa fun. M143CantBD()³±±
±±³             ³        ³ 10069³para mostrar saldo correcto desde la opcion³±±
±±³             ³        ³      ³'Item P.O.'  (PER)                         ³±±
±±³ José Glez   ³21/09/20³DMINA-³En la Función A143GeraNF() se agregan al   ³±±
±±³             ³        ³  9638³arreglo aCabs los campos DBB_NATURE,       ³±±
±±³             ³        ³      ³DBB_TIPODO y DBB_SERIE2 (PER)              ³±±
±±³   Marco A.  ³15/10/20³DMINA-³Se agrega tratamiento para confirmar graba-³±±
±±³             ³        ³ 10107³en SF1 a pesar de error de rutina automati-³±±
±±³             ³        ³      ³ca por asientos contab. erroneos (COL|PER) ³±±
±±³   Marco A.  ³15/10/20³DMINA-³Se bifurca mensaje para que sea mostrado   ³±±
±±³             ³        ³ 10495³solo cuando no se ejecuten casos de prueba.³±±
±±³Oscar G.     ³01/09/21³DMINA-³Se ajusta Fun. M143CantBD() para no sumar  ³±±
±±³             ³        ³ 13580³los doctos. ya generados, al usar opcion   ³±±
±±³             ³        ³      ³Ítems P.O. (PER)                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Mata143()
Local aArea     := GetArea()
Local aCoresUsr := {}
Local aCores    := {{"(Empty(DBA_OK).Or.DBA_OK == '1')",'ENABLE' },;		//"Processo sem NFE Geradas"
					{ "DBA_OK == '2'",'BR_AMARELO'},;						//"Processo com NFE parcialmente Geradas"
					{ "DBA_OK == '3'.And.Empty(DBA_DT_ENC)",'DISABLE'},;	//"Processo com todas NFE Geradas"
					{ "!Empty(DBA_DT_ENC)",'BR_PRETO'}}						//"Processo encerrado"

Local lImportOk  := SuperGetMv("MV_COMPINT") == .T. .And. SuperGetMv("MV_EASY") == "N" .And. cPaisLoc <> "BRA"

PRIVATE aLegenda  := {	{'ENABLE',STR0036},;				//"Ningún Doc.de entrada generado"
						{'BR_AMARELO',STR0037},;			//"Con Doc.de entrada parcialmente generados"
						{'DISABLE',STR0038},;				//"Con todos Doc.de entradas generados"
						{'BR_PRETO',OemToAnsi(STR0102)}}	//"Con fecha de Finalización"
PRIVATE aRotina	  := MenuDef()
PRIVATE cCadastro := STR0001 //"Processo de Importação"
PRIVATE nOrigem
Private lFob     := .F.
PRIVATE aHeaderChk:= {}
PRIVATE aColsChk  := {}
Private aImpIB2:={}
Private ACPOIMP :={}
Private nMoedaPed := 0
Private nTxMoeda := 0
If cPaisLoc$ "ARG|PAR" .And. FindFunction("ACPOIMPARG") .and. ( Type("ACPOIMP")=="U" .Or. Len(ACPOIMP)== 0)
	ACPOIMP:=ACPOIMPARG()
EndIf
Private dDEmiss := dDatabase
Private c143CUSB := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza ajuste no SX6 (Obs.: O parametro MV_PCTOLER nao pode ficar com o conteudo vazio) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(AllTrim(GetMV('MV_PCTOLER')))
	PutMV('MV_PCTOLER', '0')
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para inclusão de novo STATUS da legenda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT143LEG")
	aCoresUsr := ExecBlock("MT143LEG",.F.,.F.,{aCores})
	If ValType(aCoresUsr) == "A"
		aCores := aClone(aCoresUsr)
	EndIf
EndIf

If ExistBlock("MT143BRW")
	ExecBlock("MT143BRW",.F.,.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se as condicoes de uso das funcionalidades de importacao     ³
//³ estiverem ok endereca a funcao de BROWSE.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lImportOk
	mBrowse(006,001,022,075,"DBA",,,,,,aCores)
Else
	Help(" ",1,"COMPINT")
EndIf

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A143Despac³ Autor ³ Alexandre Inacio Lemes  ³Data  ³18/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Despacho do Processo de Importacao Compras Internacional     ³±±
±±³          ³ Responsavel pela Visualizacao, Inclusao, Alteracao, Exclusao ³±±
±±³          ³ e Finalizacao do processo de despacho da importacao de Compra³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void A143Despac(ExpA1,ExpA2,ExpN1)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo                                       ³±±
±±³          ³ExpN2: Registro do Arquivo                                    ³±±
±±³          ³ExpN3: Opcao da MBrowse                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum										        	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143Despac(cAlias,nReg,nOpcx,lAutomato)

Local aSize      := MsAdvSize()
Local aArea      := GetArea()
Local aButtons   := {}
Local aButtonUsr := {}
Local aPosObj    := {}
Local aObjects   := {}
Local aCpos      := {}
Local aRefImpDBC := MaFisRelImp('MT100',{"DBC"})
Local aTitles    := {STR0010,STR0011} //'Invoices'###'Itens das Invoices'
Local aTitRdp    := {STR0056,STR0057,STR0058}  //"Totais da Invoice"
Local aObj[11]	 // Array com os objetos utilizados no Folder de Totais das Invoices
Local cOldFilter := ""
Local cQuery	 := ""
Local nSaveSX8   := GetSX8Len()
Local nPosDoc	 := 0
Local nX         := 0
Local nY         := 0
Local nOpcA      := 0
Local nUsado     := 0
Local nCntFor    := 0
Local nRecDBB	 := 0
Local lFirstFis  := .T.
Local lRet       := .T.
Local lQuery     := .F.
Local l143Visual := .F.
Local l143Inclui := .F.
Local l143Deleta := .F.
Local l143Altera := .F.
Local lAltImp	 := SuperGetMV("MV_ALTIMPD",.F.,.F.)
Local lBloqAlt	 := .T.
Local oDlg
Local oGetDad1
Local oGetDad2
Local oBntFOB
Local oBntFre
Local oBntSeg
Local oBntCIF
Local oBntDes
Local oBtnDUA
Local cActBoton := ""

Default lAutomato := .F.

PRIVATE bFolderRefresh:= {|| ((A143Refresh(@aValFld)),(A143FRefresh(aObj))) }
PRIVATE bGDRefresh    := {|| (oGetDad1:oBrowse:Refresh()),(oGetDad2:oBrowse:Refresh()) }
PRIVATE bRefresh      := {|| (Eval(bFolderRefresh)) }
PRIVATE bListRefresh  := {|| (MaFisToCols(aHeader,aCols,,"MT120")),(Eval(bRefresh),Eval(bGDRefresh)) }
PRIVATE aRefImpos  := MaFisRelImp('MT100',{"SC7"})
PRIVATE aHeader    := {}
PRIVATE aCols      := {}
PRIVATE aHeader1   := {}
PRIVATE aCols1     := {}
PRIVATE aHeader2   := {}
PRIVATE aCols2     := {}
PRIVATE aColsIt    := If(nOpcX == 3,{""},{})
PRIVATE aValFld    := {0,0,0,0,0,0,0,0}
PRIVATE aAlterDBC  := {}
PRIVATE aTela[0][0],aGets[0]
PRIVATE oFldInv
PRIVATE oGetDados
PRIVATE cCliFor    := ""
PRIVATE cLoja      := ""
PRIVATE lEnd       := .F.
PRIVATE lEditaDesp := .F.
PRIVATE nMoedaDes  := 0
PRIVATE aPO        := {}
PRIVATE aColsGrv   := {}
Private aValor     := {}
Private lValor     := .F.
Private nOpcion    := nOpcx	// 2-Visulizar, 3-Incluir, 4-Alterar, 5-Excluir, 6-Generar documentos de entrada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita as HotKeys e botoes da barra de ferramentas         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcX == 3 .Or. nOpcX == 4
	aButtons	:= {{"PEDIDO" ,{|| IIf(oFldInv:nOption==2,M143F5PO(),.F.)},STR0008+" - <F5> ",STR0044},; //"Selecionar Purchase Order"
		{"SDUPROP",{|| IIf(oFldInv:nOption==2,M143F6PO(@oGetDad2),.F.)},STR0009+" - <F6> ",STR0045} } //"Selecionar Purchase Order ( por item )"
	SetKey( VK_F5, { || IIf(oFldInv:nOption==2,M143F5PO()         ,.F.) } )
	SetKey( VK_F6, { || IIf(oFldInv:nOption==2,M143F6PO(@oGetDad2),.F.) } )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para adicionar botoes do Usuario na ToolBar  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("M143BUT") )
	aButtonUsr := ExecBlock("M143BUT",.F.,.F.,{nOpcx})
	If ( ValType(aButtonUsr) == "A" )
		For nX := 1 To Len(aButtonUsr)
			Aadd(aButtons,aClone(aButtonUsr[nX]))
		Next nX
	EndIf
EndIf

If nOpcX == 4 .And. !Empty(DBA->DBA_DT_ENC)
	Aviso("A143NOALT",STR0042 + CRLF + STR0099,{"Ok"},1) // "Este proceso de importación ya tiene todas las facturas generadas."##"No es posible modificar."
	Return(.T.)
EndIf

If nOpcX == 5 .And. DBA->DBA_OK <> "1"
	Aviso("A143NOEXCL",STR0067,{"Ok"},1) // "Existem invoices neste processo que já foram geradas, para poder excluir o desembaraço exclua as NFEs geradas para reabrir o processo"
	Return(.T.)
EndIf

If nOpcX == 6 .And. DBA->DBA_OK == "3"
	Help(" ",1,"A143ALLNFE") // "Todas as notas fiscais deste processo de importação já foram geradas.
	Return(.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAutomato
	Do Case
	Case nOpcX == 2 //Visualizacion
		l143Visual  := .T.
	Case nOpcX == 3 //Inclusion
		l143Inclui	:= .T.
	Case nOpcX == 4 //Alteracion
		l143Altera	:= .T.
	Case nOpcX == 5 //Eliminacion y Visualizacion
		l143Deleta	:= .T.
		l143Visual	:= .T.
	EndCase
Else
	Do Case
	Case aRotina[nOpcX][4] == 2
		l143Visual  := .T.
	Case aRotina[nOpcX][4] == 3
		l143Inclui	:= .T.
	Case aRotina[nOpcX][4] == 4
		l143Altera	:= .T.
	Case aRotina[nOpcX][4] == 5
		l143Deleta	:= .T.
		l143Visual	:= .T.
	EndCase
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa algum filtro do DBA                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("DBA")
cOldFilter := dbFilter()
dbClearFilter()
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem da Variaveis de Memoria                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To FCount()
	M->&(FieldName(nX)) := IIf(nOpcX == 3,CriaVar(FieldName(nX)),FieldGet(nX))
	If (FieldName(nX)) != "DBA_OK"
		Aadd(aCpos,FieldName(nX))
	EndIf
Next nX

If lAltImp
	If l143Inclui .Or. l143Altera //(l143Altera .And. DBA_OK <> '3')
		lBloqAlt := .F.
		bListRefresh  := {|| (A143FldIt(oFldInv)),(MaFisToCols(aHeader,aCols,,"MT120")),(Eval(bRefresh),Eval(bGDRefresh)) }
	Else
		lBloqAlt := .T.
	EndIf
EndIf

If nOpcX == 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do aHeader e aCols (1) usando a Funcao FillGetDados  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DBB")
	dbSetOrder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FillGetDados(nOpcX,"DBB",1,,,,{"DBB_VALEMB"},,,,,.T.,,,,,)
	aCols[1][aScan(aHeader,{|x| Trim(x[2])=="DBB_ITEM"})] := StrZero(1,Len(DBB->DBB_ITEM))

	aHeader1 := aClone(aHeader)
	aCols1   := aClone(aCols)

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("DBC")
	While ( !Eof() .And. SX3->X3_ARQUIVO == "DBC" )
		If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CAMPO <> "DBC_VALEMB" )
			If SX3->X3_VISUAL <> "V"
				Aadd(aAlterDBC, TRIM(SX3->X3_CAMPO) )
			EndIf
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do aHeader e aCols (2) usando a Funcao FillGetDados  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader:= {}
	aCols  := {}

	dbSelectArea("DBC")
	dbSetOrder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FillGetDados(nOpcX,"DBC",1,,,,{"DBC_VALEMB"},,,,,.T.,,,,,)
	aCols[1][aScan(aHeader,{|x| Trim(x[2])=="DBC_ITDOC"})]:= StrZero(1,Len(DBC->DBC_ITDOC))
	aCols[1][aScan(aHeader,{|x| Trim(x[2])=="DBC_ITEM" })]:= StrZero(1,Len(DBC->DBC_ITEM))

	aHeader2  := aClone(aHeader)
	aCols2    := aClone(aCols)
	aColsIt[1]:= aClone(aCols)

Else

	dbSelectArea("DBB")
	dbSetOrder(2)
	dbSeek(xFilial("DBB")+DBA->DBA_HAWB)
	nRecDBB := Recno()

	If ( TcSrvType()!="AS/400" )
		lQuery := .T.
		cQuery := "SELECT DBB.*,DBB.R_E_C_N_O_ DBBRECNO "
		cQuery += "FROM "+RetSqlName("DBB")+" DBB "
		cQuery += "WHERE DBB.DBB_FILIAL='"+xFilial("DBB")+"' AND "
		cQuery += "DBB.DBB_HAWB='"+DBA->DBA_HAWB+"' AND "
		cQuery += "DBB.D_E_L_E_T_<>'*' "
		cQuery += "ORDER BY "+SqlOrder(DBB->(IndexKey()))
		cQuery := ChangeQuery(cQuery)
		DBB->( dbCloseArea() )
	EndIf

	DBCloseArea()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do aHeader e aCols (1) usando a Funcao FillGetDados  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeek  := xFilial("DBB")+DBA->DBA_HAWB
	cWhile := "DBB->DBB_FILIAL+DBB->DBB_HAWB"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FillGetDados(nOpcX,"DBB",2,cSeek,{|| &cWhile },,{"DBB_VALEMB"},,,cQuery,,,,,,,,"DBB")

	If lQuery
		dbSelectArea("DBB")
		dbCloseArea()
		ChkFile("DBB",.F.)
	EndIf

	dbSelectArea("DBB")
	dbSetOrder(2)
	DBB->(dbGoto(nRecDBB))

	If !MaFisFound("NF")
		MaFisIni(DBB->DBB_FORNEC,DBB->DBB_FORNEC,"F","N",Nil,aRefImpos,,.T.)
	EndIf

	//Atualiza moeda para que pegue os decimais MV_CENT... corretamente
	If !l143Inclui
		nMoedaDes := DBB->DBB_MOEDA
	Endif

	aHeader1 := aClone(aHeader)
	aCols1   := aClone(aCols)
	aColsGrv := aClone(aCols)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do aHeader e aCols (2)                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader:= {}
	aCols  := {}

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("DBC")
	While ( !Eof() .And. SX3->X3_ARQUIVO == "DBC" )
		If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CAMPO <> "DBC_VALEMB" )
			Aadd(aHeader,{ TRIM(X3Titulo()),;
				TRIM(SX3->X3_CAMPO),;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID ,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT } )

			If SX3->X3_VISUAL <> "V"
				Aadd(aAlterDBC, TRIM(SX3->X3_CAMPO) )
			EndIf
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona os campos de Alias e Recno da tabela para WalkThru   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ADHeadRec("DBC",aHeader)

	dbSelectArea("DBC")
	dbSetOrder(1)
	If ( TcSrvType()!="AS/400" )
		lQuery := .T.
		cQuery := "SELECT DBC.*,DBC.R_E_C_N_O_ DBCRECNO "
		cQuery += "FROM "+RetSqlName("DBC")+" DBC "
		cQuery += "WHERE DBC.DBC_FILIAL='"+xFilial("DBC")+"' AND "
		cQuery += "DBC.DBC_HAWB='"+DBA->DBA_HAWB+"' AND "
		cQuery += "DBC.D_E_L_E_T_<>'*' "
		cQuery += "ORDER BY "+SqlOrder(DBC->(IndexKey()))

		cQuery := ChangeQuery(cQuery)
		DBC->( dbCloseArea() )

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"DBC",.T.,.T.)
		For nCntFor := 1 To Len(aHeader)
			If aHeader[nCntFor,8] <> "C" .And. aHeader[nCntFor,10] <> "V"
				TcSetField("DBC",AllTrim(aHeader[nCntFor][2]),aHeader[nCntFor,8],aHeader[nCntFor,4],aHeader[nCntFor,5])
			EndIf
		Next nCntFor
	Else
		DBC->(dbSeek(xFilial("DBC")+DBA->DBA_HAWB))
	EndIf

	While xFilial("DBC")+DBA->DBA_HAWB==DBC_FILIAL+DBC_HAWB .And. !Eof()

		While xFilial("DBC")+DBB->DBB_HAWB+DBB->DBB_ITEM==DBC_FILIAL+DBC->DBC_HAWB+DBC_ITDOC .And. !Eof()

			aadd(aCols,Array(Len(aHeader)+1))

			For nCntFor	:= 1 To Len(aHeader)
				If IsHeadRec(aHeader[nCntFor][2])
					aCols[Len(aCols)][nCntFor] := IIf(lQuery , DBCRECNO , DBC->(Recno()) )
				ElseIf IsHeadAlias(aHeader[nCntFor][2])
					aCols[Len(aCols)][nCntFor] := "DBC"
				ElseIf ( aHeader[nCntFor][10] != "V" )
					aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
				Else
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
				EndIf
			Next nCntFor

			aCols[Len(aCols)][Len(aHeader)+1] := .F.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega os impostos da primeira Invoice para Matxfis         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFirstFis
				If MaFisFound()
					MaFisIniLoad(Len(aCols))
					For nX := 1 To Len(aRefImpDBC)
						MaFisLoad(aRefImpDBC[nX][3],DBC->(FieldGet(FieldPos(aRefImpDBC[nX][2]))),Len(aCols))
					Next nX
					MaFisEndLoad(Len(aCols),,.F.)
				EndIf
			EndIf

			dbSelectArea("DBC")
			dbSkip()

		EndDo
		If lFirstFis
			MaFisEndLoad(Len(aCols))
		EndIf

		DBB->(dbSkip())
		If Len(aCols) == 0
			dbSkip()
		Else
			Aadd(aColsIt,aClone(aCols))
		EndIf
		aCols := {}

		lFirstFis := .F.

	EndDo

	aValFld[VALMERC]	:= MaFisRet(,"NF_VALMERC")
	aValFld[VALDESC]	:= MaFisRet(,"NF_DESCONTO")
	aValFld[FRETE]		:= MaFisRet(,"NF_FRETE")
	aValFld[VALDESP]	:= MaFisRet(,"NF_DESPESA")
	aValFld[SEGURO]  	:= MaFisRet(,"NF_SEGURO")
	//	aValFld[PACKING]    := MaFisRet(,"NF_VALEMB")
	aValFld[VALBRU]	    := MaFisRet(,"NF_TOTAL")
	aValFld[TOTDESP]	:= aValFld[FRETE]+aValFld[SEGURO]+aValFld[VALDESP]//+aValFld[PACKING]

	If Len(aColsIt) < 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHeader := {}
		FillGetDados(nOpcX,"DBC",1,,,,{"DBC_VALEMB"},,,,,.T.,,,,,)
		aCols[1][aScan(aHeader,{|x| Trim(x[2])=="DBC_ITDOC"})]:= StrZero(1,Len(DBC->DBC_ITDOC))
		aCols[1][aScan(aHeader,{|x| Trim(x[2])=="DBC_ITEM"})] := StrZero(1,Len(DBC->DBC_ITEM))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Encerra a area de trabalho da query                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQuery
		dbSelectArea("DBC")
		dbCloseArea()
		ChkFile("DBC",.F.)
		dbSelectArea("DBC")
	EndIf

	aHeader2 := aClone(aHeader)
	aCols2   := aClone(aColsIt[1])

	aHeader := aClone(aHeader1)
	aCols   := aClone(aCols1)
EndIf

If !lAutomato
	aObjects := {}
	aAdd( aObjects, { 000, 110, .T., .F. } )
	aAdd( aObjects, { 040, 050, .T., .T. } )
	AAdd( aObjects, { 000, 070, .T., .F. } )
	

	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL

	EnChoice( cAlias ,nReg, If(nOpcx==6,2,nOpcX),,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],420}, aCpos, If(nOpcx==6,2,nOpcX),,,,,,,,,.F.,,,,,.T.,)

	@ 040,435 BUTTON oBntFOB PROMPT STR0050 SIZE 105,015 FONT oDlg:oFont ACTION Processa({|lEnd| A143GeraNF("5",@lEnd)},STR0012,,.T.) OF oDlg PIXEL  // "Gerar NFE FOB"
	@ 060,435 BUTTON oBntFre PROMPT STR0051 SIZE 105,015 FONT oDlg:oFont ACTION Processa({|lEnd| A143GeraNF("6",@lEnd)},STR0012,,.T.) OF oDlg PIXEL  // "Gerar NFE Frete"
	@ 080,435 BUTTON oBntSeg PROMPT STR0052 SIZE 105,015 FONT oDlg:oFont ACTION Processa({|lEnd| A143GeraNF("7",@lEnd)},STR0012,,.T.) OF oDlg PIXEL  // "Gerar NFE Seguro"
	@ 040,555 BUTTON oBntCIF PROMPT STR0053 SIZE 105,015 FONT oDlg:oFont ACTION Processa({|lEnd| A143GeraNF("8",@lEnd)},STR0012,,.T.) OF oDlg PIXEL  // "Gerar NFE CIF"
	@ 060,555 BUTTON oBntDes PROMPT STR0055 SIZE 105,015 FONT oDlg:oFont ACTION Processa({|lEnd| A143GeraNF("A",@lEnd)},STR0012,,.T.) OF oDlg PIXEL  // "Gerar NFE Gastos"
	If cPaisLoc $ "CHI|PER|BOL|COL"
		@ 080,555 BUTTON oBtnDUA PROMPT STR0091 SIZE 105,015 FONT oDlg:oFont ACTION Processa({|lEnd| A143GeraNF("D",@lEnd)},STR0012,,.T.) OF oDlg PIXEL  // "Gerar NFE DUA"
	EndIf

	If cPaisLoc == "ANG"
		@ 080,555 BUTTON oBntChk PROMPT STR0087 SIZE 105,015 FONT oDlg:oFont ACTION Processa({|lEnd| A143ChkLst(nOpcx)},"Monta Tela CheckList",,.T.) OF oDlg PIXEL  // "Monta Tela CheckList"
	Endif

	If nOpcX <> 6
		oBntFOB:Disable()
		oBntFre:Disable()
		oBntSeg:Disable()
		oBntCIF:Disable()
		oBntDes:Disable()
		If cPaisLoc $ "CHI|PER|BOL|COL"
			oBtnDUA:Disable()
		EndIf
	EndIf
Else
	If cPaisLoc $ "ARG|PER|COL"
		If FindFunction("GetParAuto")
			aRetAuto	:= GetParAuto("MATA143TESTCASE")
			cActBoton	:= aRetAuto[1]

			//Se procede a ejecutar generacion de NF's
			If cActBoton == "5" //Genera NF Tipo FOB
				A143GeraNF("5", lEnd)
			ElseIf cActBoton == "6" //Genera NF Tipo Flete
				A143GeraNF("6", lEnd)
			ElseIf cActBoton == "7" //Genera NF Tipo Seguro
				A143GeraNF("7", lEnd)
			ElseIf cActBoton == "8" //Genera NF Tipo CIF
				A143GeraNF("8", lEnd)
			ElseIf cActBoton == "A" //Genera NF Tipo Gastos
				A143GeraNF("A", lEnd)
			EndIf
		EndIf
	EndIf
EndIf
If !lAutomato
	oFldInv := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{'',''},oDlg,,,,.T.,.F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])

	aHeader  := aClone(aHeader2)
	aCols    := aClone(aCols2)
	oGetDad2 := MSGetDados():New(002,002,aPosObj[2,3]-aPosObj[2,1]-25,aPosObj[2,4]-aPosObj[2,2]-5,If( nOpcX == 6 , 2 , nOpcX ),"M143LOk2","M143TOk2","+DBC_ITEM",If( nOpcX==2 .Or. nOpcX==5 .Or. nOpcX==6 , .F. , .T. ),aAlterDBC,,.T.,900,"M143COKDBC",,,"A143Gd2Del()",oFldInv:aDialogs[2])
	oGetDad2 :oBrowse:lDisablePaint := .T.
	oGetDad2:lF3Header = .T.

	aHeader  := aClone(aHeader1)
	aCols    := aClone(aCols1)
	oGetDad1 := MSGetDados():New(002,002,aPosObj[2,3]-aPosObj[2,1]-15,aPosObj[2,4]-aPosObj[2,2]-4,If( nOpcX == 6 , 2 , nOpcX ),"M143LOk1","M143TOk1","+DBB_ITEM",If( nOpcX==2 .Or. nOpcX==5 .Or. nOpcX==6 , .F. , .T. ),,,.T.,900,"M143COK",,,"A143Gd1Del()",oFldInv:aDialogs[1])
	oGetDad1 :oBrowse:lDisablePaint := .T.
	oGetDad1:oBrowse:bChange:={|| A143IniFis(aObj) }

	oFldInv:bSetOption:={|nAtu| A143Folder(nAtu,oFldInv:nOption,oFldInv,{oGetDad1,oGetDad2}) }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao dos Folders da Area do Rodape do Despacho             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFldRodape := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitRdp,{"HEADER"},oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1],)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MsGets do Folder dos totais da Invoice                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFldRodape:aDialogs[1]:oFont:=oDlg:oFont

	@ 006,005 SAY STR0059    OF  oFldRodape:aDialogs[1] PIXEL SIZE 085,009 // "Valor da Mercadoria"
	@ 005,090 MSGET aObj[01] VAR aValFld[VALMERC]   PICTURE    PesqPict('DBB','DBB_VALMER',17,nMoedaDes) OF oFldRodape:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
	@ 020,005 SAY STR0060    OF  oFldRodape:aDialogs[1] PIXEL SIZE 070,009  // "Frete"
	@ 019,090 MSGET aObj[02] VAR aValFld[FRETE]     PICTURE    PesqPict('DBB','DBB_FRETE',17,nMoedaDes)  OF oFldRodape:aDialogs[1] PIXEL WHEN .F. SIZE 080,009

	@ 006,195 SAY STR0061    OF  oFldRodape:aDialogs[1] PIXEL SIZE 049,009 // "Descontos"
	@ 005,250 MSGET aObj[03] VAR aValFld[VALDESC]   PICTURE    PesqPict('DBB','DBB_DESCON',17,nMoedaDes) OF oFldRodape:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
	@ 020,195 SAY STR0062    OF  oFldRodape:aDialogs[1] PIXEL SIZE 050,009  // "Despesas"
	@ 019,250 MSGET aObj[04] VAR aValFld[VALDESP]   PICTURE    PesqPict('DBB','DBB_DESPES',17,nMoedaDes) OF oFldRodape:aDialogs[1] PIXEL WHEN .F. SIZE 080,009

	@ 006,350 SAY STR0063    OF  oFldRodape:aDialogs[1] PIXEL SIZE 050,009  // "Seguro"
	@ 005,405 MSGET aObj[05] VAR aValFld[SEGURO]    PICTURE    PesqPict('DBB','DBB_SEGURO',17,nMoedaDes) OF oFldRodape:aDialogs[1] PIXEL WHEN .F. SIZE 080,009

	@ 020,350 SAY STR0065    OF  oFldRodape:aDialogs[1] PIXEL SIZE 078,009 // "Total da Invoice"
	@ 019,430 MSGET aObj[06] VAR aValFld[VALBRU]    PICTURE    PesqPict('DBB','DBB_VALBRU',17,nMoedaDes) OF oFldRodape:aDialogs[1] PIXEL WHEN .F. SIZE 080,009

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MsGets do Folder das despesas acessorias                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFldRodape:aDialogs[2]:oFont := oDlg:oFont

	@ 006,005 SAY STR0060    OF  oFldRodape:aDialogs[2] PIXEL SIZE 045,009 //"Valor do Frete"
	@ 005,080 MSGET aObj[07] VAR aValFld[FRETE]   PICTURE    PesqPict('DBB','DBB_FRETE',14,nMoedaDes) OF oFldRodape:aDialogs[2];
		PIXEL WHEN !l143Visual .And. lEditaDesp VALID  A143VFold("NF_FRETE",aValFld[FRETE]) SIZE 080,009 HASBUTTON
	@ 020,005 SAY STR0062    OF  oFldRodape:aDialogs[2] PIXEL SIZE 052,009 // "Despesas"
	@ 019,080 MSGET aObj[08] VAR aValFld[VALDESP] PICTURE    PesqPict('DBB','DBB_DESPES',14,nMoedaDes) OF oFldRodape:aDialogs[2];
		PIXEL WHEN !l143Visual .And. lEditaDesp VALID A143VFold("NF_DESPESA",aValFld[VALDESP]) SIZE 080,009 HASBUTTON

	@ 006,180 SAY STR0063    OF  oFldRodape:aDialogs[2] PIXEL SIZE 060,009 // "Seguro"
	@ 005,260 MSGET aObj[09] VAR aValFld[SEGURO]  PICTURE    PesqPict('DBB','DBB_SEGURO',14,nMoedaDes) OF oFldRodape:aDialogs[2];
		PIXEL WHEN !l143Visual .And. lEditaDesp VALID A143VFold("NF_SEGURO",aValFld[SEGURO]) SIZE 080,009 HASBUTTON

	@ 020,180 SAY STR0066 OF oFldRodape:aDialogs[2] PIXEL SIZE 070,009 // "Total de Despesas Acessorias"
	@ 019,260 MSGET aObj[10] VAR aValFld[TOTDESP] PICTURE    PesqPict('DBB','DBB_VALBRU',14,nMoedaDes) OF oFldRodape:aDialogs[2];
		PIXEL WHEN .F. SIZE 080,009 HASBUTTON

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MsGets do Folder do Resumo de Impostos                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFldRodape:aDialogs[3]:oFont := oDlg:oFont
	aObj[11] := MaFisRodape(1,oFldRodape:aDialogs[3],,{003,003,400,040},bListRefresh,lBloqAlt)
	ACTIVATE MSDIALOG oDlg ON INIT (M143Refre({oGetDad1,oGetDad2}), EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .And. A143FldRfr(oFldInv).And. M143TudOk(nOpcX),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{||(nOpcA:=2,oDlg:End())},,aButtons))
EndIf

If nOpcA == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³P.E. antes da execucao da Vis/Inc/Alt/Exc.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("MT143GRV")
		lRet := ExecBlock("MT143GRV",.F.,.F.,{nOpcx})
		If ValType(lRet) <> "L"
			lRet := .T.
		EndIf
	EndIf

	If lRet
		If nOpcX == 3 // Inclusao
			Begin Transaction

				nPosDoc := aScan(aHeader,{|x| AllTrim(x[2])=='DBC_ITDOC'})
				If nPosDoc > 0
					aColsIt[Val(aCols[1,nPosDoc])] := aClone(aCols)
				EndIf

				A143Grava(nOpcX)

				While ( GetSX8Len() > nSaveSX8 )
					ConfirmSX8()
				EndDo

				EvalTrigger()

			End Transaction
		ElseIf nOpcX == 4 // Alteracao
			Begin Transaction

				nPosDoc := aScan(aHeader,{|x| AllTrim(x[2])=="DBC_ITDOC"})
				If nPosDoc > 0
					If Val(aCols[1,nPosDoc]) > Len(aColsIt)
						aColsIt[Len(aColsIt)] := aClone(aCols)
					Else
						If Inclui
							aColsIt[Val(aCols[1,nPosDoc])] := aClone(aCols)
						Else
							If (Val(aCols[1,nPosDoc]) == Len(aColsIt) .And. n < Len(aColsIt)) .Or. n < Len(aColsIt)
								aColsIt[n] := aClone(aCols)
							Else
								aColsIt[Val(aCols[1,nPosDoc])] := aClone(aCols)
							Endif
						Endif
					Endif
				Else
					aCols1 := aClone(aCols)
				EndIf

				A143Grava(nOpcX)

			End Transaction
		ElseIf nOpcX == 5 // Exclusao
			Begin Transaction
				A143Grava(nOpcX)
			End Transaction
		EndIf
	EndIf

Else
	If nOpcX == 3
		While ( GetSX8Len() > nSaveSX8 )
			RollBackSX8()
		EndDo
	EndIf
EndIf

MsUnLockAll()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o filtro original                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cOldFilter)
	dbSelectArea(cAlias)
	Set Filter To &cOldFilter
EndIf

If MaFisFound("NF")
	MaFisEnd()
EndIf

SetKey(VK_F5 , Nil)
SetKey(VK_F6 , Nil)

RestArea(aArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A143FldRfr   ³ Autor ³ Alexandre Inacio Lemes³ Data ³ 27/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Forca o retorno ao Folder de Invoices ao finalizar o processo  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A143FldRfr()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum	  										      	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ COMPRAS INTERNACIONAL                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143FldRfr(oFldInv)

If oFldInv:nOption == 2
	oFldInv:SetOption(1)
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A143Folder³ Autor ³ Alexandre Inacio Lemes  ³Data  ³18/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de Tratamento dos Folders                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Folder de Destino                                      ³±±
±±³          ³ExpN2: Folder Atual                                           ³±±
±±³          ³ExpO3: Objeto do Folder                                       ³±±
±±³          ³ExpA4: Array com as getdados.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum										        	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A143Folder(nFldDst,nFldAtu,oFldInv,aGetDad)

Local lRetorno		:= .F.
Local lFldDesp		:= .T.
Local nPosIt1		:= aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_ITEM"  })
Local nPosCF		:= aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_FORNEC"})
Local nPosLoj		:= aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_LOJA"  })
Local nPosTipo		:= aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_TIPONF"})
Local nPosProv		:= aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_PROVEN"})
Local nPosDtEm		:= aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_EMISSA"})
Local nPosStatus	:= aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_OK"    })
Local nPosIt2		:= aScan(aHeader2,{|x| AllTrim(x[2])=="DBC_ITDOC" })
Local nPosDesc		:= aScan(aHeader2,{|x| AllTrim(x[2])=="DBC_DESCRI"})
Local nY			:= 1
Local nNumInv		:= 0
Local lCposEdi		:= ExistBlock("M143CPOSED")
Local nX			:= 0
Local aCposFSD		:= {"DBC_TOTAL","DBC_TES"}
Local aCposGsto		:= {"DBC_CODPRO","DBC_DESCRI","DBC_QUANT","DBC_PRECO","DBC_TOTAL","DBC_QTSEGU","DBC_TES","DBC_VLDESC"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a Validacao da GetDados                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( aGetDad[nFldAtu]:TudoOk() )

	lRetorno := .T.
	aGetDad[nFldAtu]:oBrowse:lDisablePaint := .T.
	Do Case
	Case ( nFldAtu == 2 )
		nNumInv := aScan(aCols1,{|x| x[nPosIt1] == aCols[1][nPosIt2]})
		lEditaDesp := .F.
		If nNumInv > Len(aColsIt)
			aColsIt[Len(aColsIt)] := aClone(aCols)
		Else
			If Inclui
				aColsIt[nNumInv] := aClone(aCols)
			Endif
		Endif
	Case ( nFldAtu == 1 )
		aCols1  := aClone(aCols)

		If cPaisLoc $ "ARG|BOL|CHI|PAR|URU" .and. nFldDst == 2    //Ajuste para N no aplica para los otros paises, en la función M143TOk1 se resguarda el valor de N y se restaura.
			n := aGetDad[nFldAtu]:oBrowse:nAt
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente ativa o folder de despesas acessorias para Invoices FOB e CIF ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCols1[n][nPosTipo] $ "58"
			lEditaDesp := (aCols1[n][nPosStatus] <> "S")
			aGetDad[2]:oBrowse:nOpc := IIf(lEditaDesp, nOpcion, 2)
		Else
			lFldDesp:= .F.
			aGetDad[2]:oBrowse:nOpc := nOpcion
		EndIf

	EndCase
	Do Case
	Case ( nFldDst == 2 )

		If cPaisLoc == "ARG" .and. nPosDtEm>0
			dDEmiss := aCols[n][nPosDtEm]
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento da getdados DBC para NFEs de FRETE, SEGURO e DUA   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCposEdi
			aCposEdi := ExecBlock("M143CPOSED",.F.,.F.)
			If Len(aCposEdi) > 0
				For nX := 1 tO Len(aCposEdi)
					If Len(aCposEdi[nX]) == 3
						If DBC->(ColumnPos( aCposEdi[nX][1] )) > 0
							If aCposEdi[nX][2]
								aAdd(aCposFSD,aCposEdi[nX][1])
							EndIf
							If aCposEdi[nX][3]
								aAdd(aCposGsto,aCposEdi[nX][1])
							EndIf
						EndIf
					EndIf
				Next nX
			EndIf
		EndIf

		If aCols[n][nPosTipo] $ "67D" // Frete, Seguro e DUA
			aGetdad[2]:aAlter := aCposFSD
			aGetdad[2]:oBrowse:aAlter := aCposFSD
			aGetdad[2]:nMax:= 1
		ElseIf aCols[n][nPosTipo] $ "A" // Despesas de Importacao
			aGetdad[2]:aAlter := aCposGsto
			aGetdad[2]:oBrowse:aAlter := aCposGsto
			aGetdad[2]:nMax:= 900
		Else
			aGetdad[2]:aAlter:= aAlterDBC
			aGetdad[2]:oBrowse:aAlter:= aAlterDBC
			aGetdad[2]:nMax:= 900
		EndIf

		SA2->(dbSetOrder(1))
		SA2->(MsSeek(xFilial("SA2")+aCols[n][nPosCF]+aCols[N][nPosLoj]))

		If !MaFisFound("NF")
			If !Empty(aCols[N][nPosCF]) .And.!Empty(aCols[N][nPosLoj])
				MaFisIni(aCols[N][nPosCF],aCols[N][nPosLoj],"F","N",Nil,aRefImpos,,.T.)
				If nPosProv > 0
					MaFisAlt("NF_PROVENT",aCols[N][nPosProv])
				EndIf
			EndIf
		EndIf

		While n > Len(aColsIt)
			aadd(aColsIt,{Array(Len(aHeader2)+1)})
			dbSelectArea("DBC")
			For nY := 1 To Len(aHeader2)
				If IsHeadRec(aHeader2[nY][2])
					aColsIt[Len(aColsIt)][1][nY] := 0
				ElseIf IsHeadAlias(aHeader2[nY][2])
					aColsIt[Len(aColsIt)][1][nY] := "DBC"
				ElseIf Trim(aHeader2[nY][2]) == "DBC_ITDOC"
					aColsIt[Len(aColsIt)][1][nY] := PADL(Len(aColsIt),3,"0")
				ElseIf Trim(aHeader2[nY][2]) == "DBC_ITEM"
					aColsIt[Len(aColsIt)][1][nY] := "0001"
				ElseIf Trim(aHeader2[nY][2]) != "DBC_HAWB"
					aColsIt[Len(aColsIt)][1][nY] := CriaVar(aHeader2[nY][2])
				EndIf
				aColsIt[Len(aColsIt)][1][Len(aHeader2)+1] := aCols1[Len(aColsIt)][Len(aCols1[Len(aColsIt)])]
			Next nY
		EndDo
		cCliFor := aCols1[n][nPosCF]
		cLoja   := aCols1[n][nPosLoj]
		If n > Len(aColsIt)
			aCols := aClone(aColsIt[Len(aColsIt)])
		Else
			If Inclui
				aCols := aClone(aColsIt[n])
				If Len(aCols1) > Len(aColsIt)
					aCols[1][Len(aCols[1])] := aCols1[n][Len(aCols1[n])]
				EndIf
			Else
				If (n == Len(aColsIt) .And. n < Len(aColsIt)) .Or. n < Len(aColsIt)
					aCols := aClone(aColsIt[n])
				Else
					aCols := aClone(aColsIt[n])
				Endif
			Endif
		Endif
		aHeader	:= aClone(aHeader2)
		aCols[1][nPosIt2] := aCols1[n][nPosIt1]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento da getdados DBC para NFEs de FRETE, SEGURO e DUA ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCols1[n][nPosTipo] $ "67D"
			Do Case
				Case (aCols[1][nPosDesc] =="6")
					aCols[1][nPosDesc] := STR0070
				Case (aCols[1][nPosDesc] =="7")
					aCols[1][nPosDesc] := STR0071
				OtherWise
					aCols[1][nPosDesc] := STR0092
			EndCase
			// - OLD: aCols[1][nPosDesc]:= IIF(aCols1[n][nPosTipo] == "6" , STR0070 , STR0071 )  // FRETE FOB // SEGURO
		EndIf

	Case ( nFldDst == 1 )
		aCols   := aClone(aCols1)
		aHeader := aClone(aHeader1)
	EndCase
	nOrigem := aGetDad[nFldAtu]:oBrowse:nAt
	n := Max(aGetDad[nFldDst]:oBrowse:nAt,1)
	aGetDad[nFldDst]:oBrowse:lDisablePaint := .F.
	aGetDad[nFldDst]:oBrowse:Refresh(.T.)

EndIf

oFldRodape:nOption := 1
If oFldInv:nOption == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente ativa o folder de despesas acessorias para Invoices FOB e CIF ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFldDesp
		oFldRodape:aDialogs[2]:lActive:=.T.
		oFldRodape:lCanGotFocus:= .T.
		oFldRodape:SetFocus()
	Else
		oFldRodape:aDialogs[2]:lActive:=.F.
	Endif

	//Atualiza moeda
	MaFisAlt("NF_MOEDA",nMoedaDes)
Else
	oFldRodape:aDialogs[2]:lActive:=.T.
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M143TudOk ³ Autor ³Alexandre Inacio Lemes ³ Data ³24/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Getdados  1 e 2                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M143TudOk(nOpcX)

Local cItDoc     := ""
Local nSave      := N
Local nPosDoc    := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_ITEM"  })
Local nPosTipo   := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_TIPONF"})
Local nPItDoc    := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_ITDOC" })
Local nPosProd   := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_CODPRO"})
Local nPosUnit   := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_PRECO" })
Local nPosTotal  := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_TOTAL" })
Local nPosNumPO  := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_PEDIDO"})
Local nPosItemPO := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_ITEMPC"})
Local nPosTes    := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_TES"   })
Local nPosOk    	:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_OK"  })
Local nCntFor    := 0
Local nExistItem := 0
Local nX         := 1
Local nY         := 0
Local nI         := 0
Local nScan      := 0
Local lRet       := .T.
Local lAllDelet  := .F.
Local nTamAhead	 := 0

If Empty(M->DBA_HAWB)
	Help(" ",1,"OBRIGAT2")
	lRet := .F.
EndIf
nTamAhead := Len(aHeader) + 1
While nX <= Len(aCols)
	If aCols[nX][nTamAhead]
		lAllDelet:=.T.
	Else
		lAllDelet:=.F.
		Exit
	Endif
	nX++
Enddo

If lAllDelet
	Help(" ",1,"A143OBR3")
	lRet := .F.
Endif
If oFldInv:nOption == 1

	aCols1  := aClone(aCols)

	If	lRet
		For nCntFor := 1 To Len(aCols)
			If !aCols[nCntFor][Len(aCols[nCntFor])]
				If Empty(aCols[nCntFor][nPosOk ])
					If DBB->(FieldPos("DBB_PROVEN"))>0
						If	!GdNoEmpty({'DBB_DOC','DBB_EMISSA','DBB_TIPO','DBB_FORNEC','DBB_LOJA','DBB_PROVEN'},nCntFor,aHeader,aCols)
							lRet := .F.
							Exit
						EndIf
					Else
						If	!GdNoEmpty({'DBB_DOC','DBB_EMISSA','DBB_TIPO','DBB_FORNEC','DBB_LOJA'},nCntFor,aHeader,aCols)
							lRet := .F.
							Exit
						EndIf
					EndIf

				Else
					If	!GdNoEmpty({'DBB_DOC','DBB_EMISSA','DBB_TIPO','DBB_FORNEC','DBB_LOJA'},nCntFor,aHeader,aCols)
						lRet := .F.
						Exit
					EndIf
				Endif
			EndIf
		Next nCntFor
	EndIf

	If	lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ao confirmar os dados, se estiver posicionado na pasta invoices, verifica se os campos obrigatorios |
		//³da pasta itens da invoices foram preenchidos.                                                       |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntFor := 1 To Len(aColsIt[1])

			If !aColsIt[1][nCntFor][Len(aColsIt[1][nCntFor])]

				nScan := aScan(aCols1 , { |x| x[Len(aHeader1)+1] == .F. .And. x[nPosDoc]== aColsIt[1][nCntFor][nPItDoc] } )
				If nScan > 0 .And. aCols1[nScan][nPosTipo] $ "5|8|A" //5 FOB //8 CIF //A DESPESAS
					If	!GdNoEmpty({'DBC_CODPRO','DBC_QUANT','DBC_PRECO','DBC_TOTAL','DBC_TES'},nCntFor,aHeader2,aColsIt[1])
						lRet := .F.
						Exit
					EndIf
				Else
					If	!GdNoEmpty({'DBC_TOTAL','DBC_TES'},nCntFor,aHeader2,aColsIt[1])
						lRet := .F.
						Exit
					EndIf
				EndIf

			EndIf

		Next nCntFor

	EndIf

	If lRet .And. nOpcX <> 6
		For nCntFor := 1 to Len(aCols)
			N := nCntFor
			If !(lRet:=M143LOk1())
				Exit
			EndIf
		Next
	Endif

ElseIf oFldInv:nOption == 2

	If	lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ao confirmar os dados, se estiver posicionado na pasta invoices, verifica se os campos obrigatorios |
		//³da pasta itens da invoices foram preenchidos.                                                       |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntFor := 1 To Len(aCols)

			If !aCols[nCntFor][Len(aCols[nCntFor])]

				nScan := aScan(aCols1 , { |x| x[Len(aHeader1)+1] == .F. .And. x[nPosDoc]== aCols[nCntFor][nPItDoc] } )
				If nScan > 0 .And. aCols1[nScan][nPosTipo] $ "5|8|A" //5 FOB //8 CIF //A DESPESAS
					If	!GdNoEmpty({'DBC_CODPRO','DBC_QUANT','DBC_PRECO','DBC_TOTAL','DBC_TES'},nCntFor,aHeader2,aCols)
						lRet := .F.
						Exit
					EndIf
				Else
					If	!GdNoEmpty({'DBC_TOTAL','DBC_TES'},nCntFor,aHeader2,aCols)
						lRet := .F.
						Exit
					EndIf
				EndIf

			EndIf

		Next nCntFor

	EndIf

	If lRet

		For nCntFor := 1 to Len(aCols)
			N := nCntFor
			If !(lRet:=M143LOk2())
				Exit
			EndIf
		Next

		N:= nSave

		If lRet

			If nPItDoc != 0 .And. n > 1
				If Empty(aCols[n,nPItDoc])
					aCols[n,nPItDoc] := aCols[n-1,nPItDoc]
				EndIf
			EndIf

			If Val(aCols[n,nPItDoc]) > Len(aColsIt)
				aColsIt[Len(aColsIt)] := aClone(aCols)
			Else
				If Inclui
					aColsIt[Val(aCols[n,nPItDoc])] := aClone(aCols)
				Endif
			Endif

		EndIf
	EndIf
Else
	aCols1  := aClone(aCols)
EndIf

If lRet

	If aCols1[Len(aCols1)][nPosDoc] == aColsIt[Len(aColsIt)][1][nPItDoc]

		For nX := 1 To Len(aCols1)

			If !aCols1[nX][Len(aCols1[nX])]

				cItDoc := aCols1[nX][nPosDoc]

				If Val(cItDoc) > Len(aColsIt) // Rotina para proteger o cItDoc caso tenha havido delecoes que alteraram o Len do aColsIt
					For nI := 1 To Len(aColsIt)
						If aScan(aColsIt[nI] , { |x| x[Len(aHeader2)+1] == .F. .And. x[nPItDoc] == cItDoc } ) > 0
							cItDoc := StrZero(nI,3)
							Exit
						EndIf
					Next nI
				EndIf

				If aCols1[nX][nPosTipo] $ "5|8" //5 FOB //8 CIF
					For nY := 1 To Len(aColsIt[Val(cItDoc)])
						If aScan(aColsIt[Val(cItDoc)] , { |x| x[Len(aHeader2)+1] == .F. },nY,1 ) > 0
							If (nExistItem := aScan(aColsIt[Val(cItDoc)] , { |x| !Empty(x[nPosProd]) .And. !Empty(x[nPosNumPO]) .And. !Empty(x[nPosItemPO]) },nY,1 )) == 0
								Exit
							EndIf
						EndIf
					Next nY
				ElseIf aCols1[nX][nPosTipo] $ "A" //A DESPESAS
					nExistItem := aScan(aColsIt[Val(cItDoc)] , { |x| x[Len(aHeader2)+1] == .F. .And. !Empty(x[nPosProd]) .And. !Empty(x[nPosTes]) .And. x[nPosTotal] > 0 } )

					If nExistItem > 0
                        For nY := 1 To Len(aColsIt[Val(cItDoc)])
							If !aColsIt[Val(cItDoc)][nY][LEN(aColsIt[Val(cItDoc)][nY])]
								SF4->(dbSetOrder(1))
								If SF4->(MsSeek(xFilial('SF4')+aColsIt[Val(cItDoc)][nY][nPosTes], .F.))
									If SF4->F4_QTDZERO <> "1"
										Aviso("A143NOTES",STR0072,{"Ok"},1) // "A TES utilizada em NFEs de Frete, DUA Seguro ou Despesas deve conter o campo F4_QTDZERO = Sim, Verifique a TES utilizada nos itens das Invoices deste Tipo."
										Return lRet := .F.
									Endif
								EndIf
							EndIf
                        Next nY
					EndIf

				ElseIf aCols1[nX][nPosTipo] $ "67D" // Frete // Seguro //DUA
					nExistItem := aScan(aColsIt[Val(cItDoc)] , { |x| x[Len(aHeader2)+1] == .F. .And. !Empty(x[nPosTes]) .And. x[nPosTotal] > 0 } )

					If nExistItem > 0
						SF4->(dbSetOrder(1))
						If SF4->(MsSeek(xFilial('SF4')+aColsIt[Val(cItDoc)][nExistItem][nPosTes], .F.))
							If SF4->F4_QTDZERO <> "1"
								Aviso("A143NOTES",STR0072,{"Ok"},1) // "A TES utilizada em NFEs de Frete, DUA, Seguro ou Despesas deve conter o campo F4_QTDZERO = Sim, Verifique a TES utilizada nos itens das Invoices deste Tipo."
								lRet := .F.
								Exit
							Endif
						EndIf
					EndIf

				Else
					nExistItem := aScan(aColsIt[Val(cItDoc)] , { |x| x[Len(aHeader2)+1] == .F. .And. !Empty(x[nPosProd]) } )
				EndIf

				If nExistItem > 0
					lRet := .T.
				Else
					Help(" ",1,"A143NOITEM")
					lRet := .F.
					Exit
				EndIf

			EndIf

		Next nX

	Else
		If !aCols1[Len(aCols1)][Len(aCols1[Len(aCols1)])] // Realiza a consistencia somente se a invoice nao estiver deletada.
			Aviso("A143NODBC",STR0073,{"Ok"},1) //"Verifique se existe alguma Invoice sem Itens informados"
			lRet := .F.
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada antes da Confirmacao                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. ExistBlock("MT143TOK")
	lRet := ExecBlock("MT143TOK",.F.,.F.,{nOpcx})
	If ValType(lRet) <> "L"
		lRet := .T.
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M143TOk1 ³ Autor ³Alexandre Inacio Lemes ³ Data ³24/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de validacao da Getdados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M143TOk1()

Local lRetorno:= .T.
Local nPDoc   := GDFieldPos( "DBB_DOC" )
Local nUsado  := Len(aHeader)
Local nX      := 0
Local nSave   := N
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui os itens nao informados                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aCols)
	If ( Empty(aCols[nX][nPDoc]) )
		aCols[nX][nUsado+1] := .T.
	EndIf
Next nX

For nX := 1 to Len(aCols)
	N := nX
	If !(lRetorno:=M143LoK1())
		Exit
	EndIf
Next nX
If lRetorno
	N:= nSave
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³M143Lok1  ³ Autor ³ Alexandre Inacio Lemes  ³Data  ³18/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ LinhaOk da Getdados do Folder INVOICES                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Se Ok = .T.  se nao Ok = .F.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M143Lok1()

Local nPItem    := aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_ITEM"})
Local nPosFornec:= aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_FORNEC"})
Local nPLoja    := aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_LOJA"})
Local nPSerie   := aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_SERIE"})
Local nPNota    := aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_DOC"})
Local nPCond    := aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_COND"})
Local nPEmissao := aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_EMISSA"})
Local nPosStatus:= aScan(aHeader1,{|x| AllTrim(x[2])=="DBB_OK"})
Local nPosMoeda	:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_MOEDA" })
Local nPosTxMoeda:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_TXMOED" })
Local nPosTipo := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_TIPONF"})
Local nPosProv	:= aScan(aHeader1,{|x| Alltrim(x[2])=="DBB_PROVEN" })
Local nPosOk	:= aScan(aHeader1,{|x| Alltrim(x[2])=="DBB_OK" })
Local nX        := 0
Local nY        := 0
Local cHawb     := IIf(INCLUI,M->DBA_HAWB,DBA->DBA_HAWB)
Local lValidNFs := IIf(ALTERA .And. DBA_OK == "3",.F.,.T.)
Local lRetorno  := .T.
Local lProven	:= .F.
Local nCont := 0
Local nContDUA := 0
Local cHelpProven	:= ""

If (lRetorno := oFldInv:nOption <> 2)

	If !aCols[n][Len(aCols[n])]
		nMoedaDes  := aCols[N][nPosMoeda]
		nTxMoeda	:= aCols[N][nPosTxMoeda]
		nMoedaPed	:= nMoedaDes
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica os campo obrigatórios                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosProv > 0 .And. nPosOk > 0
			If Empty(aCols[n][nPosProv]) .And. Empty(aCols[n][nPosOk])
				lProven := .T.

				SX3->(DbSetOrder(2))
				If SX3->(MsSeek("DBB_PROVEN"))
					cHelpProven := X3Titulo()
				Endif

			EndIf
		EndIf

		If lProven .Or.Empty(aCols[n][nPNota]).Or. Empty(aCols[n][nPosFornec]) .Or. Empty(aCols[n][nPLoja]) .Or. Empty(aCols[n][nPCond]) .Or. Empty(aCols[n][nPEmissao])
			Help(" ",1,"A143INVCPO",,cHelpProven,5,0)
			lRetorno := .F.
		EndIf

		SA2->(dbSetOrder(1))	//A2_FILIAL+A2_COD+A2_LOJA
		If SA2->(MsSeek(xFilial("SA2")+aCols[n][nPosFornec]+aCols[n][nPLoja]))
			If !RegistroOk("SA2")
				lRetorno := .F.
			EndIf
		Else
			Help(" ",1,"REGNOIS")
			lRetorno := .F.
		EndIf

		lValidNFs := (aCols[n][nPosStatus] <> "S") // La asignación que hace en la declaración de lValidNFs, no valida en nuevas NF de un Proceso con todos los doc entrada generados

		If lValidNFs
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica a duplicidade de lancamentos de NFs                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SD1")
			dbSetOrder(1)
			If lRetorno .And. MsSeek(xFilial("SD1")+aCols[n][nPNota]+aCols[n][nPSerie]+aCols[n][nPosFornec]+aCols[n][nPLoja])
				Help(" ",1,"EXISTNF")
				lRetorno := .F.
			EndIf

			dbSelectArea("DBB")
			dbSetOrder(1)
			If lRetorno .And. MsSeek(xFilial("DBB")+aCols[n][nPNota]+aCols[n][nPSerie]+aCols[n][nPosFornec]+aCols[n][nPLoja]) .And. DBB->DBB_HAWB <> cHawb
				While !Eof() .And. xFilial("DBB") == DBB->DBB_FILIAL .And. aCols[n][nPNota] == DBB->DBB_DOC .And. aCols[n][nPSerie] == DBB->DBB_SERIE

					If aCols[n][nPosFornec] == DBB->DBB_FORNEC .And. aCols[n][nPLoja] == DBB->DBB_LOJA
						Help(" ",1,"EXISTNF")
						lRetorno := .F.
					EndIf

					dbSelectArea("DBB")
					dbSkip()
				EndDo
			EndIf

			If lRetorno
				For nX := 1 To Len(aCols)
					If nX <> N .And. !aCols[nX][Len(aCols[nX])]
						If aCols[nX][nPNota] == aCols[n][nPNota] .And. aCols[nX][nPSerie] ==  aCols[n][nPSerie] .And. aCols[nX][nPosFornec] == aCols[n][nPosFornec] .And. aCols[nX][nPLoja] == aCols[n][nPLoja]
							Help(" ",1,"EXISTNF")
							lRetorno := .F.
						EndIf
					EndIf
				Next nX
			EndIf

		EndIf

		If lRetorno .And. (ExistBlock("MT143LK1"))
			lRetorno := ExecBlock("MT143LK1",.F.,.F.)
			If ValType(lRetorno) <> "L"
				lRetorno := .T.
			EndIf
		EndIf

	Else
		If Len(aColsIt) >= n
			For nX := 1 To Len(aColsIt[n])
				aColsIt[n][nX][Len(aHeader2)+1] := .T.
			Next
		EndIf
	EndIf

	If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foi digitada mais de uma DUA.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCont := 1 To Len(aCols)
			If aCols[nCont][nPosTipo] == "D" .AND. !aCols[nCont][Len(aHeader)+1]
				nContDUA++
			EndIf
		Next nCont

		If nContDUA > 1
			Help(" ",1,"EXISTDUA")
			lRetorno := .F.
		EndIf
	EndIf
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M143TOk2 ³ Autor ³Alexandre Inacio Lemes ³ Data ³24/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de validacao da Getdados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M143TOk2()

Local nPosIt2 := aScan(aHeader2,{|x| AllTrim(x[2])=="DBC_ITDOC"})
Local nX      := 0
Local nSave   := N
Local lRetorno:= .T.
Local nPosItInv	:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_ITEM"})
Local nNumInv	:= aScan(aCols1,{|x| Alltrim(x[nPosItInv]) == aCols[1][nPosIt2]})

If oFldInv:nOption = 2

	For nX := 1 to Len(aCols)
		N := nX
		If !(lRetorno:=M143LOk2())
			Exit
		EndIf
	Next nX

	N := nSave

	If lRetorno
		If nNumInv > Len(aColsIt)
			aColsIt[Len(aColsIt)] := aClone(aCols)
		Else
			If Inclui
				aColsIt[nNumInv] := aClone(aCols)
			Else
				If (nNumInv == Len(aColsIt) .And. nOrigem < Len(aColsIt)) .Or. nOrigem < Len(aColsIt)
					aColsIt[nOrigem] := aClone(aCols)
				Else
					aColsIt[nNumInv] := aClone(aCols)
				Endif
			Endif
		Endif
	EndIf

EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M143LOk2 ³ Autor ³Alexandre Inacio Lemes ³ Data ³24/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da linha Ok                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: item do aCols (opcional)                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M143LOk2()

Local lRetorno:= .T.
Local nPItDoc := aScan(aHeader,{|x| AllTrim(x[2])=="DBC_ITDOC" })
Local nCodPro := aScan(aHeader,{|x| AllTrim(x[2])=="DBC_CODPRO"})
Local nLocal  := aScan(aHeader,{|x| AllTrim(x[2])=="DBC_LOCAL"})
Local nQuant  := aScan(aHeader,{|x| AllTrim(x[2])=="DBC_QUANT" })
Local nUnit   := aScan(aHeader,{|x| AllTrim(x[2])=="DBC_PRECO" })
Local nTotal  := aScan(aHeader,{|x| AllTrim(x[2])=="DBC_TOTAL" })
Local nPosTES := aScan(aHeader,{|x| AllTrim(x[2])=="DBC_TES"   })
Local nUsado  := Len(aHeader)
Local nLin    := N
Local nPosItDoc	 := aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_ITDOC" })
Local nPosMoeda	 := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_MOEDA"})
Local nPosItInv	:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_ITEM"})
Local nNumInv	:= aScan(aCols1,{|x| Alltrim(x[nPosItInv]) == aCols[1][nPosItDoc]})
nMoedaDes     := aCols1[Val(aCols[1][nPosItDoc])][nPosMoeda]

If ( !aCols[nLin][nUsado+1] )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a permissao do armazem. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11) .And. FindFunction("MaAvalPerm")
		lRetorno := MaAvalPerm(3,{aCols[n][nLocal],aCols[n][nCodPro]})
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se nao ha Campos obrigatorios em branco              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty(aCols[nLin][nCodPro]) .And. (Empty(aCols[nLin][nQuant]) .Or. Empty(aCols[nLin][nUnit]) .Or. Empty(aCols[nLin][nPosTes]))
		Help(" ",1,"A143ITMCPO")
		lRetorno := .F.
	EndIf

	If lRetorno .And. !Empty(aCols[nLin][nQuant]) .And. !Empty(aCols[nLin][nUnit]) .And. !Empty(aCols[nLin][nTotal])
	    If cPaisLoc=="PAR" .And. MsDecimais(nMoedaDes)  ==0
			If QtdComp(NoRound(aCols[nLin][nTotal])) > QtdComp(NoRound(aCols[nLin][nQuant] * aCols[nLin][nUnit]))+1.00 .Or.;
					QtdComp(NoRound(aCols[nLin][nTotal])) < QtdComp(NoRound(aCols[nLin][nQuant] * aCols[nLin][nUnit]))- 1.00
				Help(" ",1,"TOTAL")
				lRetorno := .F.
			Endif
		Else
			If lRetorno .And. QtdComp(NoRound(aCols[nLin][nTotal])) > QtdComp(NoRound(aCols[nLin][nQuant] * aCols[nLin][nUnit]))+0.49 .Or.;
					QtdComp(NoRound(aCols[nLin][nTotal])) < QtdComp(NoRound(aCols[nLin][nQuant] * aCols[nLin][nUnit]))-0.49
				Help(" ",1,"TOTAL")
				lRetorno := .F.
			Endif
		EndIf
	Endif

	If lRetorno .And. nPItDoc != 0 .And. nLin > 1
		If Empty(aCols[nLin,nPItDoc])
			aCols[nLin,nPItDoc] := aCols[nLin-1,nPItDoc]
		EndIf
	EndIf

	If lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Fornecedor x Produto possui bloqueio da Qualidade.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRetorno := QieSitFornec(cCliFor,cLoja,aCols[nLin][nCodPro],.T.)
	EndIf
	If lRetorno .And. (ExistBlock("MT143LK2"))
		lRetorno := ExecBlock("MT143LK2",.F.,.F.)
		If ValType(lRetorno) <> "L"
			lRetorno := .T.
		EndIf
	EndIf

EndIf
nPosPO := aScan(aPO,aCols[n][12])
If nPosPO == 0 .And. !(cPaisLoc $ "PER|COL|EQU")
	aadd(aPO,aCols[n][12])
Endif
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M143Refre³ Autor ³Alexandre Inacio Lemes ³Data  ³24/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua o refresh nas GetDados                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M143Refre( ExpA1 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 -> Array contendo objetos GetDados                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M143Refre( aGetDad )

Local nX         := 0
Local cNomeCols  := ""
Local cNomeHead  := ""
Local aColsAnt   := aClone(aCols)
Local aHeaderAnt := aClone(aHeader)

For nX := 1 To Len( aGetDad )
	cNomeCols := 'aCols'  + StrZero(nX, 1)
	aCols     := aClone(&(cNomeCols))
	cNomeHead := 'aHeader'+ StrZero(nX, 1)
	aHeader   := aClone(&(cNomeHead))
	aGetDad[nX]:oBrowse:lDisablePaint := .F.
	aGetDad[nX]:oBrowse:Refresh(.T.)
Next nX

aCols   := aClone(aColsAnt)
aHeader := aClone(aHeaderAnt)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A143VldTp³ Autor ³Alexandre Inacio Lemes ³Data  ³27/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a validacao do DBB_TIPONF                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A143VldTp()

Local aArea      := GetArea()
Local nPosItem   := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_ITEM"  })
Local nPosTipo   := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_TIPONF"})
Local nPosPrd    := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_CODPRO"})
Local nPosQtde   := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_QUANT" })
Local nPosDesc   := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_DESCRI"})
Local nPosNumPO  := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_PEDIDO"})
Local nPosItemPO := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_ITEMPC"})
Local nPosInvoice:= 0
Local nX         := 0
Local lRetorno   := .T.

If M->DBB_TIPONF $ "67AD" // Frete // Seguro // Despesas //DUA

	nPosInvoice:= Val(aCols[N,nPosItem])

	If Len(aColsIt) >= nPosInvoice

		For nX :=1 To Len(aColsIt[nPosInvoice])

			If !aColsIt[nPosInvoice][nX][Len(aColsIt[nPosInvoice][nX])] .And. !Empty(aColsIt[nPosInvoice][nX][nPosPrd]) .And. ;
					!Empty(aColsIt[nPosInvoice][nX][nPosNumPo]) .And. !Empty(aColsIt[nPosInvoice][nX][nPosItemPo])

				Help(" ",1,"A143FOBCIF") // Ja Existe P.O. Informado para esta Invoice, os Tipos de Notas aceitos neste caso são 5-FOB ou 8-CIF
				lRetorno := .F.
				Exit

			EndIf

		Next nX

	EndIf

EndIf

If M->DBB_TIPONF <> aCols[N,nPosTipo]

	nPosInvoice:= Val(aCols[N,nPosItem])

	If Len(aColsIt) >= nPosInvoice

		If aCols[N,nPosTipo] $ "6D" // Frete //DUA

			If M->DBB_TIPONF $ "5|8|A" .And. Empty(aColsIt[nPosInvoice][1][nPosPrd]) .And. !Empty(aColsIt[nPosInvoice][1][nPosDesc]) .And. aColsIt[nPosInvoice][1][nPosQtde] == 0
				Aviso("A143FRETE",STR0074,{"Ok"},1) //"O tipo desta invoice não poderá ser alterado pois já existe frete informado para esta invoice"
				lRetorno := .F.
			Else
				aColsIt[nPosInvoice][1][nPosDesc] := STR0071 // "SEGURO"
			EndIf

		ElseIf aCols[N,nPosTipo] == "7" // Seguro

			If M->DBB_TIPONF $ "5|8|A" .And. Empty(aColsIt[nPosInvoice][1][nPosPrd]) .And. !Empty(aColsIt[nPosInvoice][1][nPosDesc]) .And. aColsIt[nPosInvoice][1][nPosQtde] == 0
				Aviso("A143SEGUR",STR0075,{"Ok"},1) // "O tipo desta invoice não poderá ser alterado pois já existe seguro informado para esta invoice"
				lRetorno := .F.
			Else
				aColsIt[nPosInvoice][1][nPosDesc] := STR0070 // "FRETE FOB"
			EndIf

		ElseIf aCols[N,nPosTipo] == "A" // Despesas

			If !Empty(aColsIt[nPosInvoice][1][nPosPrd])
				Aviso("A143DESPE",STR0076,{"Ok"},1) // "O tipo desta invoice não poderá ser alterado pois já existe despesas lancadas para esta invoice"
				lRetorno := .F.
			EndIf

		EndIf
	EndIf

EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M143COk  ³ Autor ³Alexandre Inacio Lemes ³Data  ³24/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a validacao dos Campos das GetDados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M143COk( ExpC1, ExpC2)	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Campo a ser validado                              ³±±
±±³          ³ ExpC2 -> Origem da Validacao                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M143COk(cCampo)

Local aArea			:= GetArea()
Local nPosTipo		:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_TIPONF"})
Local nPosLoja		:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_LOJA"  })
Local nPosCF		:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_FORNEC"})
Local nPosItem		:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_ITEM"  })
Local nPosStatus	:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_OK"    })
Local nQuant		:= aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_QUANT" })
Local nUnit			:= aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_PRECO" })
Local nTotal		:= aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_TOTAL" })
Local nPosPrd		:= aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_CODPRO"})
Local nPosNumPO		:= aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_PEDIDO"})
Local nPosItemPO	:= aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_ITEMPC"})
Local nPosInvoice	:= 0
Local nX			:= 0
Local lRetorno		:= .T.
Local cLojaAnt		:= ""

DEFAULT cCampo		:= ReadVar()

cCampo := If(Subs(cCampo,1,3)=="M->",Subs(cCampo,4,(Len(cCampo)-3)),cCampo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A alteracao dos campos somente sera possivel quando a invoice nao tiver sido gerada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[n][nPosStatus] == " "

	Do Case
	Case cCampo == "DBB_FORNEC"
		cLojaAnt := aCols[n][nPosLoja]

		If !Empty(cLojaAnt)
			dbSelectArea("SA2")
			dbSetOrder(1)	//A2_FILIAL+A2_COD+A2_LOJA

			If dbSeek(xFilial("SA2")+M->DBB_FORNEC+aCols[n][nPosLoja])
				If RegistroOk("SA2")

					If aCols[n][nPosTipo] == "5" .Or. aCols[n][nPosTipo] == "8"  // FOB // CIF

						nPosInvoice:= Val(aCols[N,nPosItem])

						If Len(aColsIt) >= nPosInvoice

							For nX :=1 To Len(aColsIt[nPosInvoice])
								If !aColsIt[nPosInvoice][nX][Len(aColsIt[nPosInvoice][nX])] .And. !Empty(aColsIt[nPosInvoice][nX][nPosPrd])
									dbSelectArea("SC7")
									dbSetOrder(4)	//C7_FILIAL+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN
									If MsSeek(xFilial("SC7")+aColsIt[nPosInvoice][nX][nPosPrd]+aColsIt[nPosInvoice][nX][nPosNumPO]+aColsIt[nPosInvoice][nX][nPosItemPO])
										If SC7->C7_FORNECE <> M->DBB_FORNEC
											Help(" ",1,"A143FORNEC")
											lRetorno := .F.
											M->DBB_FORNEC := SC7->C7_FORNECE
											cLojaAnt := SC7->C7_LOJA
											Exit
										EndIf
									EndIf
								EndIf
							Next nX

						EndIf

					EndIf

				Else
					lRetorno := .F.

				EndIf

				If !lRetorno
					aCols[n][nPosLoja] := cLojaAnt
				Else
					M->DBB_LOJA := SA2->A2_LOJA
					If !MsSeek(xFilial("SA2")+M->DBB_FORNEC+aCols[n][nPosLoja])
						aCols[n][nPosLoja] := M->DBB_LOJA
					EndIf
				EndIf

			Else
				aCols[n][nPosLoja] := cLojaAnt
				Help(" ",1,"REGNOIS")
				lRetorno := .F.

			EndIf

			M->DBB_LOJA := ""
			SA2->(DbCloseArea())
			dbSelectArea("SA2")
		EndIf

	Case cCampo == "DBB_LOJA"

		If !Empty(M->DBB_LOJA)
			dbSelectArea("SA2")
			dbSetOrder(1)
			If MsSeek(xFilial("SA2")+aCols[n][nPosCF]+M->DBB_LOJA)
				If RegistroOk("SA2")

					If aCols[n][nPosTipo] == "5" .Or. aCols[n][nPosTipo] == "8" // FOB // CIF

						nPosInvoice:= Val(aCols[N,nPosItem])

						If Len(aColsIt) >= nPosInvoice

							For nX :=1 To Len(aColsIt[nPosInvoice])
								If !aColsIt[nPosInvoice][nX][Len(aColsIt[nPosInvoice][nX])] .And. !Empty(aColsIt[nPosInvoice][nX][nPosPrd])
									dbSelectArea("SC7")
									dbSetOrder(4)
									If MsSeek(xFilial("SC7")+aColsIt[nPosInvoice][nX][nPosPrd]+aColsIt[nPosInvoice][nX][nPosNumPO]+aColsIt[nPosInvoice][nX][nPosItemPO])
										If SC7->C7_FORNECE+SC7->C7_LOJA <> aCols[n][nPosCF]+M->DBB_LOJA
											Help(" ",1,"A143FORNEC")
											lRetorno := .F.
											Exit
										EndIf
									EndIf
								EndIf
							Next nX

						EndIf

					EndIf

				Else
					lRetorno := .F.
				EndIf
			Else
				Help(" ",1,"REGNOIS")
				lRetorno := .F.
			EndIf
		EndIf

	Case cCampo == "DBB_MOEDA"

		If aCols[n][nPosTipo] == "5" .Or. aCols[n][nPosTipo] == "8" //FOB // CIF

			nPosInvoice:= Val(aCols[N,nPosItem])

			If Len(aColsIt) >= nPosInvoice

				For nX :=1 To Len(aColsIt[nPosInvoice])
					If !aColsIt[nPosInvoice][nX][Len(aColsIt[nPosInvoice][nX])] .And. !Empty(aColsIt[nPosInvoice][nX][nPosPrd])
						dbSelectArea("SC7")
						dbSetOrder(4)
						If MsSeek(xFilial("SC7")+aColsIt[nPosInvoice][nX][nPosPrd]+aColsIt[nPosInvoice][nX][nPosNumPO]+aColsIt[nPosInvoice][nX][nPosItemPO])
							If SC7->C7_MOEDA <> M->DBB_MOEDA
								Help(" ",1,"A143DIFMOE") // A moeda para NF FOB e CIF é previamente informada no purchase order e não pode ser alterada.
								lRetorno := .F.
								Exit
							EndIf
						EndIf
					EndIf
				Next nX

			EndIf

		EndIf

	Case cCampo == "DBB_TIPONF"

		If aCols[n][nPosTipo] == "6" .Or. aCols[n][nPosTipo] == "7"  .Or. aCols[n][nPosTipo] == "9" .Or. aCols[n][nPosTipo] == "A" .Or. aCols[n][nPosTipo] == "D"  // Frete // Seguro // Despesas //DUA

			nPosInvoice:= Val(aCols[N,nPosItem])

			If Len(aColsIt) >= nPosInvoice

				For nX :=1 To Len(aColsIt[nPosInvoice])

					If !aColsIt[nPosInvoice][nX][Len(aColsIt[nPosInvoice][nX])] .And. !Empty(aColsIt[nPosInvoice][nX][nPosPrd]) .And. ;
							!Empty(aColsIt[nPosInvoice][nX][nPosNumPo]) .And. !Empty(aColsIt[nPosInvoice][nX][nPosItemPo])

						Help(" ",1,"A143FOBCIF") // Ja Existe P.O. Informado para esta Invoice, o Tipo da Nota aceitos neste caso são 5-FOB ou 8-CIF
						lRetorno := .F.
						Exit

					EndIf

				Next nX

			EndIf

		EndIf

	EndCase

Else
	Aviso("A143NOALT",STR0068,{"Ok"},1) // "Esta Invoice Ja gerou documento de entrada e não poderá ser alterada.
	lRetorno := .F.
EndIf

RestArea(aArea)

Return( lRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M143COkDBC³ Autor ³Alexandre Inacio Lemes ³Data  ³24/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a validacao dos Campos das GetDados Itens Invoices  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M143COkDBC( ExpC1 )      	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Campo a ser validado                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M143COkDBC(cCampo)

Local nPosStatus := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_OK"    })
Local nPosItDoc	 := aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_ITDOC" })
Local lRetorno := .T.
Local nPosItInv	:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_ITEM"})
Local nNumInv	:= aScan(aCols1,{|x| Alltrim(x[nPosItInv]) == aCols[1][nPosItDoc]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A alteracao dos campos somente sera possivel quando a invoice nao tiver sido gerada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols1[nNumInv][nPosStatus] == "S"
	Aviso("A143NOALT",STR0068,{"Ok"},1) // // "Esta Invoice Ja gerou documento de entrada e não poderá ser alterada.
	lRetorno := .F.
EndIf

Return( lRetorno )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A143Grava ³ Autor ³Alexandre Inacio Lemes ³ Data ³24/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do desembaraco do processo de importacao-Despacho ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 -> Efetuado                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: [3] Inclusao                                         ³±±
±±³          ³       [4] Alteracao                                        ³±±
±±³          ³       [5] Exclusao                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A143Grava(nOpcX)

Local cHawb      := ""
Local cStatusDBA := ""
Local nPosRecDBB := Len(aHeader1)
Local nPosRecDBC := Len(aHeader2)
Local nPosCHK	 := 0
Local nCntItem	 := 0
Local nDelet 	 := 0
Local nX         := 0
Local nY         := 0
Local nGerada    := 0
Local nNaoGerada := 0
Local lA143Exclui:= .T.

Do Case
Case nOpcX == 3		// Inclusao

	dbSelectArea("DBA")
	Reclock("DBA",.T.)
	For nX := 1 To DBA->(FCount())
		If	FieldName(nX)!="DBA_XDESPA" .And. FieldName(nX)!="DBA_XTIPOI" .And. FieldName(nX)!="DBA_XFTEMP" .And. FieldName(nX)!="DBA_XDJAI"
			If ( FieldName(nX)!="DBA_FILIAL" )
				FieldPut(nX,M->&(FieldName(nX)))
			Else
				DBA->DBA_FILIAL := xFilial("DBA")
			EndIf
		EndIf
	Next nX
	DBA->DBA_OK := "1" // O Desembaraco e gerado com status que nenhuma NFE foi gerada
	MsUnlock()

	dbSelectArea("DBB")
	For nX := 1 To Len(aCols1)
		If ( !aCols1[nX][Len(aHeader1)+1] )
			Reclock("DBB",.T.)
			For nY := 1 To Len(aHeader1)
				If ( aHeader1[nY][10] != "V" )
					FieldPut(FieldPos(aHeader1[nY][2]),aCols1[nX][nY])
				EndIf
			Next nY
			DBB->DBB_FILIAL := xFilial("DBB")
			DBB->DBB_HAWB   := DBA->DBA_HAWB
			DBB->DBB_OK     := " " // As Invoices do desembaraco sao geradas com status de NFE nao gerada
			DBB->DBB_ITEM   := StrZero(Val(DBB->DBB_ITEM) - nDelet,Len(DBB->DBB_ITEM))  //renumerar qdo deletar NFs
			MsUnlock()
		Else
			nDelet++
		EndIf
	Next nX

	nDelet := 0

	dbSelectArea("DBC")
	For nCntItem := 1 To Len(aColsIt)
		If ( aCols1[nCntItem][Len(aHeader1)+1] )
			nDelet++
		EndIf
		For nX := 1 To Len(aColsIt[nCntItem])
			If ( !aColsIt[nCntItem][nX][Len(aHeader2)+1] )
				Reclock("DBC",.T.)
				For nY := 1 To Len(aHeader2)
					If ( aHeader2[nY][10] != "V" )
						FieldPut(FieldPos(aHeader2[nY][2]),aColsIt[nCntItem][nX][nY])
					EndIf
				Next nY
				DBC->DBC_FILIAL := xFilial("DBC")
				DBC->DBC_HAWB	:= DBA->DBA_HAWB
				DBC->DBC_ITDOC  := StrZero(Val(DBC_ITDOC) - nDelet,Len(DBC->DBC_ITDOC))  //renumerar qdo deletar NFs
				MsUnlock()

				//-- Alimenta campo Qtd. a Classificar no PO
				If !Empty(DBC->(DBC_PEDIDO+DBC_ITEMPC))
					dbSelectArea("SC7")
					dbSetOrder(1)
					dbSeek(xFilial("SC7")+DBC->(DBC_PEDIDO+DBC_ITEMPC))
					RecLock("SC7",.F.)
					SC7->C7_QTDACLA += DBC->DBC_QUANT
					MsUnLock()
				EndIf
			EndIf
		Next nX
	Next nCntItem

	cHawb := DBA->DBA_HAWB

	// Grava Amarração Processo x Documento
If cPaisLoc $ "ANG|EQU|HAI"
	If !EmpTy(aHeaderChk) .And. !EmpTy(aColsChk)
		dbSelectArea("DBG")
		For nX := 1 To Len(aColsChk)
			RecLock("DBG",.T.)
			Replace DBG_FILIAL With xFilial("DBG")
			Replace DBG_NRPROC With cHawb
			For nY := 1 To Len(aColsChk[nX])-3
				Replace &(aHeaderChk[nY][2]) With aColsChk[nX][nY]
			Next
			MsUnLock()
		Next
		aHeaderChk:= {}; aColsChk :={}
	EndIf
EndIf
Case nOpcX == 4		//Alteracao

	dbSelectArea("DBC")
	For nX := 1 To Len(aColsIt)
		For nY := 1 To Len(aColsIt[nX])
			If aColsIt[nX][nY][nPosRecDBC] > 0
				dbGoto(aColsIt[nX][nY][nPosRecDBC])

				//-- Subtrai campo Qtd. a Classificar no PO
				If !Empty(DBC->(DBC_PEDIDO+DBC_ITEMPC))
					dbSelectArea("SC7")
					dbSetOrder(1)
					dbSeek(xFilial("SC7")+DBC->(DBC_PEDIDO+DBC_ITEMPC))
					RecLock("SC7",.F.)
					SC7->C7_QTDACLA -= DBC->DBC_QUANT
					MsUnLock()
				EndIf

				Reclock("DBC",.F.)
				dbDelete()
				MsUnlock()
			EndIf
		Next nY
	Next nX

	dbSelectArea("DBB")
	For nX := 1 To Len(aCols1)
		If aCols1[nX][nPosRecDBB] > 0
			dbGoto(aCols1[nX][nPosRecDBB])
			Reclock("DBB",.F.)
			dbDelete()
			MsUnlock()
		EndIf
	Next nX

	dbSelectArea("DBA")
	Reclock("DBA",.F.)
	For nX := 1 To DBA->(FCount())
		If ( FieldName(nX)!="DBA_FILIAL" )
			FieldPut(nX,M->&(FieldName(nX)))
		Else
			DBA->DBA_FILIAL := xFilial("DBA")
		EndIf
	Next nX
	If Len(aCols1) > Len(aColsGrv)			// Ao incluir nova invoice o status do desembaraço é alterado para "NFs parcialmente geradas"
		DBA->DBA_OK := "2"
	EndIf
	MsUnlock()

	dbSelectArea("DBB")
	For nX := 1 To Len(aCols1)
		If ( !aCols1[nX][Len(aHeader1)+1] )
			Reclock("DBB",.T.)
			For nY := 1 To Len(aHeader1)
				If ( aHeader1[nY][10] != "V" )
					FieldPut(FieldPos(aHeader1[nY][2]),aCols1[nX][nY])
				EndIf
			Next nY
			DBB->DBB_FILIAL := xFilial("DBB")
			DBB->DBB_HAWB   := DBA->DBA_HAWB
			DBB->DBB_ITEM   := StrZero(Val(DBB->DBB_ITEM) - nDelet,Len(DBB->DBB_ITEM))  //renumerar qdo deletar NFs
			MsUnlock()
		Else
			nDelet ++
		EndIf
	Next nX

	// Atualiza status da processo de desembaraco
	cStatusDBA := DBA->DBA_OK
	dbSetOrder(2)
	MsSeek(xFilial("DBB")+DBA->DBA_HAWB , .F. )
	While !Eof() .And. xFilial("DBB") == DBB->DBB_FILIAL .And. DBB->DBB_HAWB == DBA->DBA_HAWB
		If DBB->DBB_OK <> "S"
			nNaoGerada++
		Else
			nGerada++
		EndIf
		DBB->(dbSkip())
	EndDo
	If nGerada > 0 .And. nNaoGerada > 0
		cStatusDBA := "2"
	ElseIf nGerada > 0
		cStatusDBA := "3"
	ElseIf nNaoGerada > 0
		cStatusDBA := "1"
	EndIf
	If cStatusDBA <> DBA->DBA_OK
		If RecLock("DBA", .F.)
			DBA->DBA_OK := cStatusDBA
			MsUnlock()
		EndIf
	EndIf

	nDelet := 0

	dbSelectArea("DBC")
	For nCntItem := 1 To Len(aColsIt)
		If ( !aCols1[nCntItem][Len(aHeader1)+1] )
			For nX := 1 To Len(aColsIt[nCntItem])
				If ( !aColsIt[nCntItem][nX][Len(aHeader2)+1] )
					Reclock("DBC",.T.)
					For nY := 1 To Len(aHeader2)
						If ( aHeader2[nY][10] != "V" )
							FieldPut(FieldPos(aHeader2[nY][2]),aColsIt[nCntItem][nX][nY])
						EndIf
					Next nY
					DBC->DBC_FILIAL := xFilial("DBC")
					DBC->DBC_HAWB   := DBA->DBA_HAWB
					DBC->DBC_ITDOC  := StrZero(Val(DBC_ITDOC) - nDelet,Len(DBC->DBC_ITDOC))
					MsUnlock()

					//-- Alimenta campo Qtd. a Classificar no PO
					If !Empty(DBC->(DBC_PEDIDO+DBC_ITEMPC))
						dbSelectArea("SC7")
						dbSetOrder(1)
						dbSeek(xFilial("SC7")+DBC->(DBC_PEDIDO+DBC_ITEMPC))
						RecLock("SC7",.F.)
						SC7->C7_QTDACLA += DBC->DBC_QUANT
						MsUnLock()
					EndIf
				EndIf
			Next nX
		Else
			nDelet ++
		EndIf
	Next nCntItem

	cHawb := DBA->DBA_HAWB

If cPaisLoc $ "ANG|EQU|HAI"
If !Empty(aColsChk)
	dbSelectArea("DBG")
	DBG->(DbSeek(xFilial("DBG")+M->DBA_HAWB))
	While DBG->(!Eof()) .And. DBG->DBG_NRPROC == M->DBA_HAWB
		nPosCHK:=aScan(aColsChk,{|x| x[2] == DBG->DBG_TIPDOC})
		If nPosCHK > 0
			If aColsChk[nPosCHK][1] == .T.
				RecLock("DBG",.f.)
				DBG->DBG_OK := "ok"
				MsUnlock()
			Else
				RecLock("DBG",.f.)
				DBG->DBG_OK :=""
				MsUnlock()
			EndIf

		EndIf
		DBG->(DbSkip())
	End
	aColsChk:= {}
EndIf
EndIf
Case nOpcX == 5		//Exclusao

	//-- ExecBlock p/ tratar a delecao do Processo de Importação
	If ExistBlock("A143EXCLUI")
		lA143Exclui := ExecBlock("A143EXCLUI", .F. , .F.)
		If ValType(lA143Exclui) <> "L"
			lA143Exclui := .T.
		EndIf
	EndIf

	cHawb := DBA->DBA_HAWB

	If lA143Exclui

		dbSelectArea("DBC")
		For nX := 1 To Len(aColsIt)
			For nY := 1 To Len(aColsIt[nX])
				dbGoto(aColsIt[nX][nY][nPosRecDBC])

				//-- Subtrai campo Qtd. a Classificar no PO
				If !Empty(DBC->(DBC_PEDIDO+DBC_ITEMPC))
					dbSelectArea("SC7")
					dbSetOrder(1)
					dbSeek(xFilial("SC7")+DBC->(DBC_PEDIDO+DBC_ITEMPC))
					RecLock("SC7",.F.)
					SC7->C7_QTDACLA -= DBC->DBC_QUANT
					MsUnLock()
				EndIf

				Reclock("DBC",.F.)
				dbDelete()
				MsUnlock()
			Next nY
		Next nX

		dbSelectArea("DBB")
		For nX := 1 To Len(aCols1)
			dbGoto(aCols1[nX][nPosRecDBB])
			Reclock("DBB",.F.)
			dbDelete()
			MsUnlock()
		Next nX

		Reclock("DBA",.F.)
		dbDelete()
		MsUnlock()

	EndIf

EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada apos inclusao/alteracao/exclusao do Desembaraco (Despacho)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("A143GRVA")
	ExecBlock("A143GRVA",.F.,.F.,{nOpcX,cHawb})
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³M143Legend ³Autor ³Alexandre Inacio Lemes ³ Data ³24/04/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M143Legend()

BrwLegenda(cCadastro,STR0035,aLegenda)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SuperRecnoºAutor  ³Microsiga           º Data ³  08/29/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o Recno do arquivo corrente                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SuperRecno()

Local nRet := Recno()

#IFDEF TOP
	If !(TcSrvType()=='AS/400') .And. FieldPos('R_E_C_N_O_') > 0
		nRet := R_E_C_N_O_
	EndIf
#ENDIF

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M143F5PO  ³Autor  ³Alexandre Inacio Lemes ³Data  ³16/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao dos Purchase Orders.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M143F5PO()

Local aArea      := GetArea()
Local aAreaSA2   := SA2->(GetArea())
Local aAreaSC7   := SC7->(GetArea())
Local aButtons   := { {'PESQUISA',{||A103VisuPC(aRecSC7[oListBox:nAt])},STR0013,STR0094} } //"Purchase Orders", "Consultar Purchase Order"
Local aF5Pc      := {}
Local aRecSC7    := {}
Local aTitCampos := {}
Local aConteudos := {}

Local bLine      := { || .T. }
Local bSavKeyF5  := SetKey(VK_F5,Nil)
Local bSavKeyF6  := SetKey(VK_F6,Nil)

Local nPosItDoc	 := aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_ITDOC" })
Local nPosNumPo  := aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_PEDIDO" })
Local nPosItemPo := aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_ITEMPC" })
Local nPosCF	 := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_FORNEC"})
Local nPosLoja	 := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_LOJA"})
Local nPosMoeda	 := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_MOEDA"})
Local nPosTxMoeda:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_TXMOED"})
Local nPosTipo   := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_TIPONF"})
Local nPosItInv	 := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_ITEM"})
Local nPosInvOk	 := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_OK"})
Local nPosQTD	 := aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_QUANT" })
Local nNumInv	 := aScan(aCols1,{|x| Alltrim(x[nPosItInv]) == aCols[1][nPosItDoc]})
Local nSalPed    := 0
Local nOpc       := 0
Local nF5Pc      := 0
Local nX         := 0
Local nY         := 0

Local cAliasSC7  := "SC7"
Local cQuery     := ""
Local cNomeFor   := ""
Local cLine      := ""
Local cFornece   := aCols1[nNumInv][nPosCF]
Local cLoja      := aCols1[nNumInv][nPosLoja]
Local cTipoNFe   := aCols1[nNumInv][nPosTipo]
Local cFilPOQry	 := ""

Local lQuery     := .F.
Local lContinua  := .T.
Local lExiste    := .F.
Local l143FilPO	 := ExistBlock("MT143FILPO")
Local l143POSel	 := ExistBlock("MT143POSEL")

Local oListBox
Local oDlg
Local oOk        := LoadBitMap(GetResources(), "LBOK")
Local oNo        := LoadBitMap(GetResources(), "LBNO")

Local nFreeQT   := 0
Local aArrayF4 	:= {}
Local aArrSldo 	:= {}
Local nPosPO	:= 0
Local nZ		:= 0
Local nY		:= 0
Local nSalAct   := 0
Local nTDisp    := 0

nMoedaDes     := aCols1[Val(aCols[1][nPosItDoc])][nPosMoeda]
nMoedaPed := nMoedaDes
nTxMoeda := aCols1[Val(aCols[1][nPosItDoc])][nPosTxMoeda]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

If lContinua .And. (cTipoNFe $ "5|8|A") // FOB // CIF

	dbSelectArea("SA2")
	dbSetOrder(1)
	MsSeek(xFilial("SA2")+cFornece+cLoja)
	cNomeFor	:= SA2->A2_NOME

	#IFDEF TOP
		dbSelectArea("SC7")
		If TcSrvType() <> "AS/400"
			SC7->( dbSetOrder( 9 ) )
			lQuery    := .T.
			cAliasSC7 := "QRYSC7"

			cQuery := "SELECT R_E_C_N_O_ RECSC7 FROM "
			cQuery += RetSqlName("SC7") + " SC7 "
			cQuery += "WHERE "
			cQuery += "C7_FILENT = '"+xFilEnt(xFilial("SC7"))+"' AND "
			cQuery += "C7_FORNECE = '"+cFornece+"' AND "
			cQuery += "(C7_QUANT-C7_QUJE-C7_QTDACLA)>0 AND "
			cQuery += "C7_TIPO = 3 AND "
			cQuery += "C7_MOEDA = CAST('" + AllTrim(Str(nMoedaDes,2)) + "' AS INTEGER) AND "
			cQuery += "C7_LOJA = '"+cLoja+"' AND "
			cQuery += "SC7.D_E_L_E_T_ = ' '"
			cQuery += "ORDER BY " + SqlOrder( SC7->( IndexKey() ) )

			// Ponto de entrada para alterar a pesquisa de Purchase Orders
			If l143FilPO
				cFilPOQry := ExecBlock("MT143FILPO",.F.,.F.,{cQuery})
				If ValType(cFilPOQry) == "C"
					cQuery := cFilPOQry
				EndIf
			EndIf

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)
		Else
	#ENDIF
	dbSelectArea("SC7")
	dbSetOrder(9)
	MsSeek(xFilEnt(xFilial("SC7"))+cFornece+cLoja,.T.)
	#IFDEF TOP
		Endif
	#ENDIF
	Do While If(lQuery, ;
			(cAliasSC7)->(!Eof()), ;
			(cAliasSC7)->(!Eof()) .And. xFilEnt(xFilial('SC7'))+cFornece == (cAliasSC7)->C7_FILENT+;
			(cAliasSC7)->C7_FORNECE .And. cLoja == (cAliasSC7)->C7_LOJA )

		If lQuery
			('SC7')->(dbGoto((cAliasSC7)->RECSC7))
		EndIf

		If ('SC7')->C7_MOEDA == nMoedaDes

			lExiste := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o Saldo do Purchase Order                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nSalPed := ('SC7')->C7_QUANT-('SC7')->C7_QUJE-('SC7')->C7_QTDACLA

			If cPaisLoc $ "PER|COL|EQU"
				nFreeQT := M143Cant(nNumInv,nPosInvOk,nPosNumPo,nPosItemPo,('SC7')->C7_NUM,('SC7')->C7_ITEM)
				nCantBD := M143CantBD(('SC7')->C7_NUM,('SC7')->C7_PRODUTO,M->DBA_HAWB)
			EndIf


			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If aCols[nX][nPosNumPo] == ('SC7')->C7_NUM .And. aCols[nX][nPosItemPo] == ('SC7')->C7_ITEM
						If !(cPaisLoc $ "PER|COL|EQU")
							lExiste := .T.
							Exit
						Else
							nSalAct := aCols[nX][nPosQTD] + nFreeQT
							If nSalAct == ('SC7')->C7_QUANT
								lExiste := .T.
								Exit
							EndIf
						EndIF
					EndIf
				EndIf
			Next nX

			If  cPaisLoc $ "PER|COL|EQU"
				IF nFreeQT+nCantBD >= ('SC7')->C7_QUANT
					lExiste := .T.
				EndIF
			EndIf

			If lExiste
				(cAliasSC7)->(dbSkip())
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se nao h  residuos, se possui saldo em abto e   ³
			//³ se esta liberado por alcadas se houver controle.         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( Empty(('SC7')->C7_RESIDUO) .And. nSalPed > 0 .And.;
					If(SuperGetMV("MV_RESTNFE")=="S",('SC7')->C7_CONAPRO <> "B",.T.).And.;
					('SC7')->C7_TPOP <> "P" .And. ('SC7')->C7_TIPO == 3 )

				nF5Pc := aScan(aF5Pc,{|x|x[2]==('SC7')->C7_LOJA .And. x[3]==('SC7')->C7_NUM})

				If ( nF5Pc == 0 )
					aConteudos := {.F.,('SC7')->C7_LOJA,('SC7')->C7_NUM,DTOC(('SC7')->C7_EMISSAO),'PO' }
					nPosPO := aScan(aPO, ('SC7')->C7_NUM)
					If nPosPO == 0
						aAdd(aF5Pc , aConteudos )
						aAdd(aRecSC7, ('SC7')->(Recno()))
					ElseIf cPaisLoc=="CHI" .And. nPosPO <> 0
						aAdd(aF5Pc , aConteudos )
						aAdd(aRecSC7, ('SC7')->(Recno()))
					Endif
				EndIf

			EndIf
		EndIf
		(cAliasSC7)->(dbSkip())
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe os dados na Tela                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( !Empty(aF5Pc) )

		aTitCampos := {" ",STR0014,STR0044,STR0022,STR0047} //"Loja"###"Purchase"###"Emissao"###"Origem"

		cLine := "{If(aF5Pc[oListBox:nAt,1],oOk,oNo),aF5Pc[oListBox:nAT][2],aF5Pc[oListBox:nAT][3],aF5Pc[oListBox:nAT][4],aF5Pc[oListBox:nAT][5] } "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta dinamicamente o bline do CodeBlock                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bLine := &( "{ || " + cLine + " }" )
		DEFINE MSDIALOG oDlg FROM 050,040  TO 285,541 TITLE STR0008+" - <F5> " Of oMainWnd PIXEL //"Selecionar Purchase Order"

		oListBox:=TWBrowse():New( 027,004,243,086,,aTitCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oListBox:SetArray(aF5Pc)
		oListBox:bLDblClick := { || aF5Pc[oListBox:nAt,1] := !aF5Pc[oListBox:nAt,1] }
		oListBox:bLine := bLine
		@ 015,004 SAY STR0046 Of oDlg PIXEL SIZE 047,009 //"Fornecedor"
		@ 014,035 MSGET cNomeFor PICTURE PesqPict('SA2','A2_NOME') When .F. Of oDlg PIXEL SIZE 120,009

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||(nOpc := 1,nF5Pc := oListBox:nAt,oDlg:End())},{||(nOpc := 0,nF5Pc := oListBox:nAt,oDlg:End())},,aButtons)

		// Ponto de entrada que permite visualizar POs marcadas
		If l143POSel .And. nOpc == 1
			ExecBlock("MT143POSEL",.F.,.F.,{aF5Pc,cFornece,cLoja})
		EndIf

		Processa({|| M143ProcPO(aF5Pc,nOpc,cFornece,cLoja,@nSalPed)})

	Else
		Help(" ",1,"A103F4")
	EndIf

Else
	Help(" ",1,"A143F5F6") // A carga do P.O. somente pode ser realizada para invoices tipo 5-FOB ou 8-CIF, altere o tipo da invoice.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Integrida dos dados de Entrada                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	dbSelectArea(cAliasSC7)
	dbCloseArea()
	dbSelectArea("SC7")
Endif

SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)

RestArea(aAreaSA2)
RestArea(aAreaSC7)
RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M143ProcPO|Autor  ³Alexandre Inacio Lemes ³Data  ³16/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa o carregamento do P.O. para os itens da Invoice   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os itens do Purchase Order               ³±±
±±³          ³ ExpN1 = Opcao valida                                       ³±±
±±³          ³ ExpC1 = Fornecedor                                         ³±±
±±³          ³ ExpC2 = loja fornecedor                                    ³±±
±±³          ³ ExpN2 = Saldo do pedido                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M143ProcPO(aF5Pc,nOpc,cFornece,cLoja,nSalPed)

Local cSeek      := ""
Local cFilialOri := ""
Local cItDoc     := ""
Local cItem		 := StrZero(1,Len(DBC->DBC_ITEM))
Local lZeraCols  := .T.
Local nPosItDoc	 := aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_ITDOC"  })
Local nPosNumPo  := aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_PEDIDO" })
Local nPosItemPo := aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_ITEMPC" })
Local nPosQTD	 := aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_QUANT" })
Local nX         := 0
Local nY         := 0
Local nZ         := 0
Local nFreeQT    := 0
Local aColsBkp	 := {}
Local lSaldo	 := .F.
Local nPosItInv	 := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_ITEM"})
Local nPosInvOk	 := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_OK"})
Local nNumInv	 := aScan(aCols1,{|x| Alltrim(x[nPosItInv]) == aCols[1][nPosItDoc]})
Local nCantBD	:= 0

If ( nOpc == 1 )
	For nX	:= 1 to Len(aF5Pc)
		If aF5Pc[nx][1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Fornecedor                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA2")
			dbSetOrder(1)
			MsSeek(xFilial("SA2")+cFornece+cLoja)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Purchase Order                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SC7")
			dbSetOrder(9)
			cSeek := ""
			cSeek += xFilEnt(xFilial("SC7"))+cFornece
			cSeek += aF5Pc[nx][2]+aF5Pc[nx][3]
			MsSeek(cSeek)
			If lZeraCols
				cItDoc      := aCols[1,nPosItDoc]
				aColsBkp	:= aClone(aCols)
				aCols		:= {}
				lZeraCols	:= .F.
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Muda ordem para trazer ordenado por item                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Eof()
				cSeek      :=xFilEnt(xFilial("SC7"))+aF5Pc[nx][3]
				cFilialOri :=C7_FILIAL
				dbSetOrder(14)
				dbSeek(cSeek)
			EndIf

			While ( !Eof() .And. SC7->C7_FILENT+SC7->C7_NUM == cSeek )
				// Verifica se o fornecedor esta correto
				If C7_FILIAL+C7_FORNECE+C7_LOJA == cFilialOri+cFornece+aF5Pc[nx][2]

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Pesquisa a Quantidade utilizada em outras invoices       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					nFreeQT := M143Cant(nNumInv,nPosInvOk,nPosNumPo,nPosItemPo,('SC7')->C7_NUM,('SC7')->C7_ITEM)

					If !cPaisLoc $ "PER|COL|EQU|CHI"
						If cPaisLoc $ "ARG|BOL|PAR|URU"
							If ('SC7')->C7_QTDACLA > 0
								nSalPed := SC7->C7_QUANT-SC7->C7_QUJE-('SC7')->C7_QTDACLA
							Else
								nSalPed := SC7->C7_QUANT-SC7->C7_QUJE-('SC7')->C7_QTDACLA-nFreeQT
							Endif
						Else
							nSalPed := SC7->C7_QUANT-SC7->C7_QUJE-('SC7')->C7_QTDACLA-nFreeQT
						Endif
					Else
						nCantBD := M143CantBD(SC7->C7_NUM,SC7->C7_PRODUTO,M->DBA_HAWB)
						nSalPed := SC7->C7_QUANT-SC7->C7_QUJE-nFreeQT-nCantBD
					EndIf

					If (nSalPed > 0 .And. Empty(SC7->C7_RESIDUO))
						Po2Acols(SC7->(RecNo()),,nSalPed,cItem,cItDoc,.T.)
						cItem := SomaIt(cItem)
						lSaldo := .T.
					EndIf

				EndIf

				dbSelectArea("SC7")
				dbSkip()
			EndDo
			If !lSaldo
				aCols := aClone(aColsBkp)
			EndIf
		EndIf
	Next nX
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M143F6PO ³ Autor ³Alexandre Inacio Lemes ³ Data ³24/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de importacao de Pedidos de Compra por Item.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M143F6PO(ExpO1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpO1: Objeto da getdados (itens selecionados do PC)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M143F6PO(oGetDad2)

Local aArea			:= GetArea()
Local aAreaSB1		:= SB1->(GetArea())
Local aCab			:= {}
Local aArrSldo		:= {}
Local aArrayF4		:= {}
Local aNewArray 	:= {}
Local aF6PO			:= {}
Local aButtons		:= { {'PESQUISA',{||A103VisuPC(aArrSldo[oQual:nAt][2])},STR0013,STR0094} } //"Purchase Orders", "Consultar Purchase Order"

Local bSavKeyF5		:= SetKey(VK_F5,Nil)
Local bSavKeyF6     := SetKey(VK_F6,Nil)

Local nPosPrd		:= aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_CODPRO"})
Local nPosNumPo  	:= aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_PEDIDO"})
Local nPosItemPo	:= aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_ITEMPC"})
Local nPosQTD		:= aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_QUANT" })
Local nPosItDoc	 	:= aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_ITDOC" })
Local nPosItem	 	:= aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_ITEM"  })
Local nPosCF		:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_FORNEC"})
Local nPosLoja		:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_LOJA"  })
Local nPosMoeda	   	:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_MOEDA" })
Local nPosTipo    	:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_TIPONF"})
Local nPosItInv		:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_ITEM"})
Local nPosInvOk		:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_OK"})
Local nNumInv		:= aScan(aCols1,{|x| Alltrim(x[nPosItInv]) == aCols[1][nPosItDoc]})
Local nFreeQT		:= 0
Local nSavQual		:= 0
Local nX     		:= 0
Local nY     		:= 0
Local nZ     		:= 0
Local nOpcA 		:= 0
Local nSalPed     	:= 0
Local cTipoNFe    	:= aCols1[nNumInv][nPosTipo]
Local cSeek			:= If(oFldInv:nOption > 1,aCols1[nNumInv][nPosCF] + aCols1[nNumInv][nPosLoja],"")
Local cVar			:= If(oFldInv:nOption > 1,aCols[n][nPosPrd],"")
Local cItDoc      	:= ""
Local cItem       	:= ""
Local cFornece   	:= aCols1[nNumInv][nPosCF]
Local cLoja      	:= aCols1[nNumInv][nPosLoja]

Local oQual
Local oDlg

Local lAllPC        := .T.
Local l143POSel		:= ExistBlock("MT143POSEL")

Local nW:= 0
Local nQtdUti:= 0
Local nAchoN := 0
Local nAchoI := 0
Local lAchoI := .T.

If cTipoNFe == "5" .Or. cTipoNFe == "8"  // FOB // CIF
	nMoedaDes        := aCols1[nNumInv][nPosMoeda]
	dbSelectArea("SC7")
	If Empty(cVar)
		dbSetOrder(9)
	Else
		dbSetOrder(6)
		cSeek := cVar + cSeek
	EndIf

	MsSeek(xFilEnt(xFilial("SC7"))+cSeek)

	If cPaisLoc == "CHI" .And. Len(Acols) >= 1 .And. ! Empty(aCols[n][nPosPrd]) .And. Acols[n][nPosQTD] <> 0
		cVar := aCols[n][nPosPrd]
	Endif

	If !Eof()

		If Empty(cVar)
			cCond := "C7_FILENT+C7_FORNECE+C7_LOJA"
		Else
			cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE+C7_LOJA"
		EndIf

		While !Eof() .And. xFilEnt(cFilial)+cSeek == &(cCond)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Filtra os Purchase Order                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (GetMV("MV_RESTNFE") == "S" .And. C7_CONAPRO == "B") .Or. C7_TPOP == "P" .Or. C7_TIPO <> 3 .Or. SC7->C7_MOEDA <> nMoedaDes
				dbSkip()
				Loop
			EndIf

			lAchoI := .T.

			If Empty(SC7->C7_RESIDUO)

				nFreeQT := 0
				nQtdUti:= 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pesquisa a Quantidade utilizada em outras invoices       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nZ := 1 To Len(aColsIt)
					For nY := 1 to Len(aColsIt[nZ])
						If !aColsIt[nZ][nY][Len(aColsIt[nZ][nY])] .And. nZ <> Val(aCols[1,nPosItDoc]) .And. aCols1[nZ][nPosInvOk] != "S"
							If aColsIt[nZ][nY][nPosNumPo] == ('SC7')->C7_NUM .And. aColsIt[nZ][nY][nPosItemPo] == ('SC7')->C7_ITEM
								nFreeQT += aColsIt[nZ][nY][nPosQTD]
							EndIf
						EndIf
					Next nY
				Next nZ

				For nW:= 1 to Len(aColsIt)
					If SC7->C7_NUM == aColsIt[nW][1][nPosNumPo] .And. SC7->C7_PRODUTO == aColsIt[nW][1][nPosPrd] .And. SC7->C7_QUANT <> aColsIt[nW][1][nPosQTD]
						nQtdUti+= aColsIt[nW][1][nPosQTD]
					EndIf
				Next nW

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pesquisa a Quantidade utilizada na Invoice Atual         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 To Len( aCols )
					If nX # n .And. !ATail(aCols[nX]) .And.  aCols[nX,nPosPrd] == C7_PRODUTO .And. aCols[nX,nPosNumPo] == C7_NUM .And. aCols[nX,nPosItemPo] == C7_ITEM
						nFreeQT += aCols[ nX,nPosQTD ]
					EndIf
				Next

				If cPaisLoc $ 'PER|COL|CHI'
					nFreeQT := (SC7->C7_QUANT - SC7->C7_QUJE - nFreeQT - M143CantBD(SC7->C7_NUM,SC7->C7_PRODUTO,M->DBA_HAWB))
				Elseif cPaisLoc == "ARG"
					nFreeQT := (SC7->C7_QUANT - SC7->C7_QUJE - nFreeQT - (SC7->C7_QTDACLA - nQtdUti) - M143CantBD(SC7->C7_NUM,SC7->C7_PRODUTO,M->DBA_HAWB))
				Else
					nFreeQT := (SC7->C7_QUANT - SC7->C7_QUJE - (SC7->C7_QTDACLA - nQtdUti) - nFreeQT)
				EndIf

				If (nFreeQT > 0)

					nAchoN := aScan(aCols,{|x| Alltrim(x[12]) == &("C7_NUM")})
					nAchoI := aScan(aCols,{|x| Alltrim(x[13]) == &("C7_ITEM")})

					IF nAchoN > 0
						IF nAchoI > 0
							IF nFreeQT == 0
								lAchoI := .F.
							EndIF
						ENDIF
					ENDIF

					If lAchoI

						AAdd( aArrayF4,{ SC7->C7_LOJA,;
						SC7->C7_NUM,;
						SC7->C7_ITEM,;
						TransForm(nFreeQT,PesqPict("SC7","C7_QUANT")),;
						DTOC(SC7->C7_DATPRF),;
						Substr(C7_PRODUTO,1,15),;
						Substr(C7_DESCRI,1,20),;
						"PO",;
						TransForm(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO")) ,;
						DTOC(SC7->C7_EMISSAO) ,;
						SC7->C7_Local ,;
						SC7->C7_OBS } )

						AAdd( aArrSldo,{nFreeQT,SuperRecno()} )

					EndIf

				EndIf

			EndIf

			dbSkip()

		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a chamada do ponto de entrada                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock( "MT143F6P" )
			aNewArray := ExecBlock( "MT143F6P", .F., .F.,{aArrayF4} )
			If ValType(aNewArray) == 'A'
				aArrayF4 := aNewArray
			Endif
		EndIf

		If !Empty(aArrayF4)

			DEFINE MSDIALOG oDlg FROM 30,20  TO 265,521 TITLE STR0013 Of oMainWnd PIXEL //"Purchase Orders"

			aCab := {STR0014,STR0008,STR0015,STR0016,STR0017,STR0018,STR0019,STR0020,STR0021,STR0022,STR0023,STR0023} //"Loja"###"Purchase"###"Item"###"Saldo"###"Entrega"###"Produto"###"Descricao"###"Tipo"###"Valor Unit."###"Emissao"###"Local"###"Local"

			oQual := TWBrowse():New( 29,4,243,76,,aCab,{15,30,15,40,30,60,70,15,40,30},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oQual:SetArray(aArrayF4)
			oQual:bLine := { || aArrayF4[oQual:nAT] }

			If !Empty(cVar)
				@ 015,004 SAY STR0018 Of oDlg PIXEL SIZE 047,009 //"Produto"
				@ 014,030 MSGET cVar PICTURE PesqPict('SB1','B1_COD') When .F. Of oDlg PIXEL SIZE 080,009
			Else
				@ 015,004 SAY STR0024 Of oDlg PIXEL SIZE 120,009 //'Selecione o Purchase Order'
			EndIf

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nSavQual:=oQual:nAT,nOpca:=1,oDlg:End()},{||oDlg:End()},,aButtons)

			If nOpca == 1
				dbSelectArea("SC7")
				MsGoto(aArrSldo[nSavQual][2])
				nSalPed:= aArrSldo[nSavQual][1]
				lAllPC := SC7->C7_QUANT == nSalPed
				cItem  := If( Len(aCols) == 1 , Nil , Soma1(aCols[Len(aCols)-1][nPosItem]) )
				cItDoc := aCols[1,nPosItDoc]

				// Ponto de entrada que permite visualizar POs marcadas
				If l143POSel
					// Cria aF6PO semelhante ao aF5PC para que os arrays fiquem iguais tanto no vinculo por item quanto por documento
					aF6PO := {.T.,SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,"PO"}
					ExecBlock("MT143POSEL",.F.,.F.,{aF6PO,cFornece,cLoja})
				EndIf

				Po2Acols(SC7->(RecNo()),,nSalPed,cItem,cItDoc,.F.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Impede que o item obtido do PC seja deletado pela getdados do Despacho na mov das setas³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValType( oGetDad2 ) == "O"
					oGetDad2:lNewLine:=.F.
				EndIf
			EndIf
		Else
			Help(" ",1,"A103F4")
		EndIf
	Else
		Help(" ",1,"A103F4")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a chamada do ponto de entrada                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "MT143IPC" )
		ExecBlock( "MT143IPC", .F., .F. )
	EndIf

Else
	Help(" ",1,"A143F5F6") // A carga do P.O. somente pode ser realizada para invoices tipo 5-FOB ou 8-CIF, altere o tipo da invoice.
Endif

SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)

RestArea(aAreaSB1)
RestArea(aArea)

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Po2Acols  ³Autor  ³Alexandre Inacio Lemes ³Data  ³16/01/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina atualiza o acols com base no item do purchase    ³±±
±±³          ³order                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Numero do registro do SC7                            ³±±
±±³          ³ExpN2 : Item da NF                                           ³±±
±±³          ³ExpN3 : Saldo do Pedido                                      ³±±
±±³          ³ExpC4 : Item a ser carregado no aCols ( DBC_ITEM )           ³±±
±±³          ³ExpC5 : Item da Getdados das NFEs (cabecalho) para vincular  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Sempre .T.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACOM Internacional Processo de Importacao de Produtos    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Po2Acols(nRecSC7,nItem,nSalPed,cItem,cItDoc,laColsAdd)

Local aArea		:= GetArea()
Local aAreaSC7	:= SC7->(GetArea())
Local aAreaSF4	:= SF4->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local nPosTxMoed:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_TXMOED" })
Local nPosItDoc	:= aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_ITDOC"  })
Local nPosValMod:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_MOEDA" })
Local nX        := 0
Local lAllPC    := .T.
Local nPosItInv	:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_ITEM"})
Local nNumInv	:= 0
Local aItemPO 	:= {}
Local nRecno	:= 0
Local lM143CTZ  :=GetMV('MV_M143CTZ',.F.,.F.) //Usar tasa informada en despacho al vincular P.O.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia do item do acols                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nItem == Nil .Or. nItem > Len(aCols)
	If laColsAdd
		aadd(aCols,Array(Len(aHeader)+1))
	EndIf
	For nX := 1 to Len(aHeader)
		If Trim(aHeader[nX][2]) == "DBC_ITEM"
			aCols[Len(aCols)][nX] 	:= IIF(cItem<>Nil,cItem,StrZero(1,Len(DBC->DBC_ITEM)))
		ElseIf Trim(aHeader[nX][2]) == "DBC_ITDOC"
			aCols[Len(aCols)][nX] 	:= cItDoc
		ElseIf Trim(aHeader[nX][2]) == "DBC_ALI_WT"
			aCols[Len(aCols)][nX] 	:= "DBC"
		ElseIf Trim(aHeader[nX][2]) == "DBC_REC_WT"
			aCols[Len(aCols)][nX] 	:= 0
		Else
			aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2], (aHeader[nX][10] <> "V") )
		EndIf
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
	Next nX
	nItem := Len(aCols)
EndIf
nNumInv := aScan(aCols1,{|x| Alltrim(x[nPosItInv]) == aCols[1][nPosItDoc]})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona registros                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC7")
MsGoto(nRecSC7)
lAllPC := SC7->C7_QUANT==nSalPed

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega a Taxa da Moeda do P.O. para o cabecalho da Invoice  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SC7->C7_TXMOEDA)
	If IIF(lM143CTZ,((aCols1[nNumInv][nPosValMod] <> 1 .AND. aCols1[nNumInv][nPosTxMoed] <= 1) .OR. Empty(aCols1[nNumInv][nPosTxMoed])), .T.)
		aCols1[nNumInv][nPosTxMoed] := SC7->C7_TXMOEDA
	EndIf
EndIf

dbSelectArea("SB1")
dbSetOrder(1)
MsSeek(xFilial("SB1")+SC7->C7_PRODUTO)

If cPaisLoc $ "PER|COL|EQU"
	If M143Busca(M->DBA_HAWB,cItDoc,cItem,nItem,aItemPO)
		nRecno	 := aItemPO[1]
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os impostos do pedido de compra para a Invoice       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MaFisFound()
	MaFisIniLoad(nItem)
	For nX := 1 To Len(aRefImpos)
		Do Case
			Case aRefImpos[nX][3] == "IT_QUANT"
				MaFisLoad(aRefImpos[nX][3],nSalPed,nItem)
			Case aRefImpos[nX][3] == "IT_PRCUNI"
				MaFisLoad(aRefImpos[nX][3],SC7->C7_PRECO,nItem)
			Case aRefImpos[nX][3] == "IT_VALMERC"
				MaFisLoad(aRefImpos[nX][3],Iif(lAllPC,SC7->C7_TOTAL,NoRound(nSalPed*SC7->C7_PRECO,TamSX3('D1_TOTAL')[2])),nItem)
			Case aRefImpos[nX][3] == "IT_DESCONTO"
				MaFisLoad(aRefImpos[nX][3],((SC7->C7_VLDESC/SC7->C7_QUANT) * nSalPed),nItem)
			Case aRefImpos[nX][3] == "IT_TES"
				If !Empty(SC7->C7_TES)
					dbSelectArea("SF4")
					dbSetOrder(1)
					MsSeek(xFilial("SF4")+SC7->C7_TES)
					MaFisLoad("IT_CF",MaFisCFO(nItem,SF4->F4_CF),nItem)
					MaFisLoad(aRefImpos[nX][3],SC7->C7_TES,nItem)
				EndIf
			OtherWise
				MaFisLoad(aRefImpos[nX][3],SC7->(FieldGet(FieldPos(aRefImpos[nX][2]))),nItem)
		EndCase
	Next nX
	MaFisEndLoad(nItem,2)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o acols com base no pedido de compras               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aHeader)
	Do Case
	Case Trim(aHeader[nX][2]) == "DBC_ITDOC"
		If  Len(aCols) > 1
			aCols[Len(aCols)][nX]:= aCols[Len(aCols)-1][nX]
		EndIf
	Case Trim(aHeader[nX][2]) == "DBC_CODPRO"
		aCols[nItem][nX] := SC7->C7_PRODUTO
	Case Trim(aHeader[nX][2]) == "DBC_TOTAL"
		aCols[nItem][nX] := IIf(lAllPC, SC7->C7_TOTAL , NoRound( nSalPed * SC7->C7_PRECO ,TamSX3('DBC_TOTAL')[2]))
	Case Trim(aHeader[nX][2]) == "DBC_QUANT"
		aCols[nItem][nX] := nSalPed
	Case Trim(aHeader[nX][2]) == "DBC_PRECO"
		aCols[nItem][nX] := SC7->C7_PRECO
	Case Trim(aHeader[nX][2]) == "DBC_PEDIDO"
		aCols[nItem][nX] := SC7->C7_NUM
	Case Trim(aHeader[nX][2]) == "DBC_ITEMPC"
		aCols[nItem][nX] := SC7->C7_ITEM
	Case Trim(aHeader[nX][2]) == "DBC_HAWB"
		aCols[nItem][nX] := M->DBA_HAWB
	Case Trim(aHeader[nX][2]) == "DBC_DESCRI"
		aCols[nItem][nX] := SC7->C7_DESCRI
	Case Trim(aHeader[nX][2]) == "DBC_TES"
		If nRecno <> 0
			aCols[nItem][nX] 	:= ""
		Else
			aCols[nItem][nX] := SC7->C7_TES
		EndIf
	Case Trim(aHeader[nX][2]) == "DBC_DATPRF"
		aCols[nItem][nX] := SC7->C7_DATPRF
	Case Trim(aHeader[nX][2]) == "DBC_LOCAL"
		aCols[nItem][nX] := SC7->C7_LOCAL
	Case Trim(aHeader[nX][2]) == "DBC_UM"
		aCols[nItem][nX] := SC7->C7_UM
	Case Trim(aHeader[nX][2]) == "DBC_SEGUM"
		aCols[nItem][nX] := SC7->C7_SEGUM
	Case Trim(aHeader[nX][2]) == "DBC_CC"
		aCols[nItem][nX] := SC7->C7_CC
	Case Trim(aHeader[nX][2]) == "DBC_CLVL"
		aCols[nItem][nX] := SC7->C7_CLVL
	Case Trim(aHeader[nX][2]) == "DBC_CONTA"
		aCols[nItem][nX] := SC7->C7_CONTA
	Case Trim(aHeader[nX][2]) == "DBC_ITCTA"
		aCols[nItem][nX] := SC7->C7_ITEMCTA
	Case Trim(aHeader[nX][2]) == "DBC_SEGURO"
		aCols[nItem][nX] := SC7->C7_SEGURO
		//Case Trim(aHeader[nX][2]) == "DBC_VALEMB"
		//aCols[nItem][nX] := SC7->C7_VALEMB
	Case Trim(aHeader[nX][2]) == "DBC_VLDESC"
		aCols[nItem][nX] := ((SC7->C7_VLDESC/SC7->C7_QUANT) * nSalPed)
	Case Trim(aHeader[nX][2]) == "DBC_VALFRE"
		aCols[nItem][nX] := SC7->C7_VALFRE
	Case Trim(aHeader[nX][2]) == "DBC_DESPES"
		aCols[nItem][nX] := SC7->C7_DESPESA
	Case Trim(aHeader[nX][2]) == "DBC_QTSEGU"
		aCols[nItem][nX] := SC7->C7_QTSEGUM
	Case Trim(aHeader[nX][2]) == "DBC_ALI_WT"
		aCols[nItem][nX] 	:= "DBC"
	Case Trim(aHeader[nX][2]) == "DBC_REC_WT"
		If nRecno <> 0
			aCols[nItem][nX] 	:= nRecno
		Else
			aCols[nItem][nX] 	:= 0
		EndIf
	OtherWise
		If Empty(aCols[nItem,nX])
			aCols[nItem,nX] := CriaVar(aHeader[nX][2])
		EndIf
	EndCase
Next nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a chamada do ponto de entrada                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MT143IPC" )
	ExecBlock( "MT143IPC", .F., .F. )
EndIf

Eval(bListRefresh)

RestArea(aAreaSB1)
RestArea(aAreaSF4)
RestArea(aAreaSC7)
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Ma143Form³ Autor ³Alexandre Inacio Lemes ³ Data ³10/07/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do Formulario Proprio.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ma143Form()

Local aArea		  := GetArea()
Local lRetorno    := .T.
Local nPDoc       := aScan(aHeader,{|x| AllTrim(x[2]) == 'DBB_DOC'})
Local nPSerie     := aScan(aHeader,{|x| AllTrim(x[2]) == 'DBB_SERIE'})
Local nPItem      := aScan(aHeader,{|x| AllTrim(x[2]) == 'DBB_ITEM'})

If ReadVar() == "M->DBB_FORMUL" .And. &(ReadVar()) == "1"
	Private cNumero:= ""
	Private cSerie := ""
	lRetorno:= Sx5NumNota(@cSerie,"1")
	aCols[n][nPDoc]   := cNumero
	aCols[n][nPSerie] := cSerie
Else
	aCols[n][nPDoc]   := CriaVar(aHeader[nPDoc,2])
	aCols[n][nPSerie] := SerieNfId("DBB",5,"DBB_SERIE")
EndIf

RestArea(aArea)

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³Autor  ³Alexandre Inacio Lemes ³ Data ³18/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

PRIVATE aRotina	:= {	{ STR0002,"AxPesqui"  , 0, 1, 0, .F.},; //"Pesquisar"
	{ STR0003,"A143Despac", 0, 2, 0, nil},; //"Visualizar"
	{ STR0004,"A143Despac", 0, 3, 0, nil},; //"Incluir"
	{ STR0005,"A143Despac", 0, 4, 0, nil},; //"Alterar"
	{ STR0006,"A143Despac", 0, 5, 0, nil},; //"Excluir"
	{ STR0007,"A143Despac", 0, 6, 0, nil},; //"Gerar Documentos de Entrada"
	{ STR0103,'M143Reabre', 0, 7, 0, Nil},; //"Reabrir Despacho"
	{ STR0035,'M143Legend', 0, 2, 0, .F.}}  //"Legenda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MTA143MNU")
	ExecBlock("MTA143MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A143SegUm ³ Autor ³Alexandre Inacio Lemes ³Data  ³25/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Trata UM e segunda UM no MATA143                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A143SegUm()

Local cVarCod  := ""
Local cVarQtd  := ""
Local cVarQtd2 := ""
Local cVarTotal:= ""
Local cProduto := ""
Local cCampo   := Alltrim(ReadVar())
Local lMudou   := .F.
Local cAlias   := Alias()
Local nOrder   := IndexOrd()
Local nRecno   := Recno()
Local nOrdSB1  := SB1->(IndexOrd()),nRecSB1:=SB1->(Recno())
Local nValQDa  := 0 // quantidade anterior - Calculo do Desconto Devolucao
Local nValQDb  := 0 // quantidade atual    - Calculo do Desconto Devolucao
Local nPosCod  := 0
Local nPosQtd  := 0
Local nPosQtd2 := 0
Local nPosTotal:= 0
Local nPosDesc := 0
Local nQuant   := 0
Local nX       := 0

For nX := 1 To Len(aHeader)
	If Trim(Substr(aHeader[nX][2],4)) == "_CODPRO"
		nPosCod   := nX
		cVarCod   := "M->"+AllTrim(aHeader[nX][2])
	ElseIf Trim(Substr(aHeader[nX][2],4)) == "_QUANT"
		nPosQtd   := nX
		cVarQtd   := "M->"+AllTrim(aHeader[nX][2])
	ElseIf Trim(Substr(aHeader[nX][2],4)) == "_QTSEGU"
		nPosQtd2  := nX
		cVarQtd2  := "M->"+AllTrim(aHeader[nX][2])
	ElseIf Trim(Substr(aHeader[nX][2],4)) == "_TOTAL"
		nPosTotal := nX
		cVarTotal := "M->"+AllTrim(aHeader[nX][2])
	ElseIf Trim(Substr(aHeader[nX][2],4)) == "_VLDESC"
		nPosDesc:=nX
	EndIf
	// Caso j  achou todos, abandona o Loop
	If nPosCod > 0 .And. nPosQtd > 0 .And. nPosQtd2 > 0 .And. nPosTotal > 0 .And. nPosDesc > 0
		Exit
	EndIf
Next nX

// Caso esteja no codigo do produto, obtem o produto
If cCampo == cVarCod
	cProduto:=&(ReadVar())
Else
	nQuant:=&(ReadVar())
	cProduto:=aCols[n][nPosCod]
EndIf

dbSelectArea("SB1")
dbSetOrder(1)
If MsSeek(xFilial("SB1")+cProduto)
	// Altera campo da Quantidade na Segunda UM
	If cCampo == cVarQtd
		If nPosQtd2 > 0
			nValQDa := aCols[n][nPosQtd]
			aCols[n][nPosQtd2]:=	ConvUm(SB1->B1_COD,nQuant,aCols[n][nPosQtd2],2)
			nValQDb :=&(ReadVar())
			&(cVarQtd2):= aCols[n][nPosQtd2]
			lMudou:=.T.
		EndIf
		// Altera campo da Quantidade na Primeira UM
	ElseIf cCampo == cVarQtd2
		If nPosQtd > 0 .and. (&(cVarQtd2) # aCols[n][nPosQtd2])
			nValQDa   := aCols[n][nPosQtd]
			aCols[n][nPosQtd]:=	ConvUm(SB1->B1_COD,aCols[n][nPosQtd],nQuant,1)
			nValQDb   := aCols[n][nPosQtd]
			&(cVarQtd):= aCols[n][nPosQtd]

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento para atualizacao do campo qtdsol no pedido de compra ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Right( AllTrim( ReadVar() ), 10 ) == "C7_QTSEGUM"
				If !Empty( GDFieldPos( "C7_QTDSOL" ) )
					A120QtdSol( aCols[n,nPosQtd] )
				EndIf
			EndIf

			lMudou:=.T.
		EndIf
		// Altera campo da Quantidade na Segunda UM ou na Primeira UM
	ElseIf cCampo == cVarCod
		If nPosQtd > 0 .And. nPosQtd2 > 0
			If !Empty(aCols[n][nPosQtd])
				aCols[n][nPosQtd2]:=	ConvUm(SB1->B1_COD,aCols[n][nPosQtd],aCols[n][nPosQtd2],2)
				&(cVarQtd2):= aCols[n][nPosQtd2]
			ElseIf !Empty(aCols[n][nPosQtd2])
				aCols[n][nPosQtd]:=	ConvUm(SB1->B1_COD,aCols[n][nPosQtd],aCols[n][nPosQtd2],1)
				&(cVarQtd):= aCols[n][nPosQtd]
				lMudou:=.T.
			EndIf
		EndIf
	EndIf
	// Zera total qdo mudou quantidade
	If lMudou .And. nPosTotal > 0
		aCols[n][nPosTotal]:= 0
		&(cVarTotal):= 0
		If Type("cTipo")=="C"
			If nPosDesc > 0
				aCols[n][nPosDesc] := (aCols[n][nPosDesc]/nValQDa)*nValQDb
			EndIF
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Compatibilizacao com programas que utilizam a Funcao Fiscal  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MaFisFound("IT",n)
			MaFisAlt("IT_QUANT",&(cVarQtd),n)
			MaFisAlt("IT_VALMERC",0,n)
			If nPosDesc > 0
				MaFisAlt("IT_DESCONTO",aCols[n][nPosDesc],n)
			EndIf
		EndIf
	EndIf
EndIf

dbSelectArea(cAlias)
dbSetOrder(nOrder)
dbGoto(nRecno)
SB1->(dbSetOrder(nOrdSB1))
SB1->(dbGoto(nRecSB1))

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A143Produto³Autor³Alexandre Inacio Lemes ³ Data ³25/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do Produto digitado.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Codigo do Produto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Dicionario de Dados - DBC_CODPRO                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143Produto(cProduto)

Local aArea		 := GetArea()
Local nPosDoc    := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_ITEM"  })
Local nPosTipo   := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_TIPONF"})
Local nPosItDoc  := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_ITDOC" })
Local nPosUM     := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_UM"    })
Local nPosSegum  := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_SEGUM" })
Local nPosLocal  := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_LOCAL" })
Local nPosDesc   := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_DESCRI"})
Local nPosNumPO  := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_PEDIDO"})
Local nPosItemPO := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_ITEMPC"})
Local nPosCC     := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_CC"    })
Local nPosConta  := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_CONTA" })
Local nPosCLVL   := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_CLVL"  })
Local nPosItCta  := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_ITCTA" })
Local nPosTES    := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_TES"   })
Local nScan      := 0
Local lRet 		 := .T.

dbSelectArea("SB1")
dbSetOrder(1)
If MsSeek(xFilial("SB1")+cProduto,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Registro esta Bloqueado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If RegistroOk("SB1")

		nScan := aScan(aCols1 , { |x| x[Len(aHeader1)+1] == .F. .And. x[nPosDoc]== aCols[1][nPosItDoc] } )
		MaFisRef("IT_PRODUTO","MT120",cProduto)

		If nScan > 0 .And. aCols1[nScan][nPosTipo] $ "5|8|A" // FOB // CIF

			If SB1->B1_IMPORT == "S"

				If Empty(aCols[N][nPosNumPO]) .And. Empty(aCols[N][nPosItemPO])
					aCols[N][nPosUM]    := SB1->B1_UM        // Unidade de medida
					aCols[N][nPosSegum] := SB1->B1_SEGUM     // Segunda Unidade
					aCols[N][nPosDesc]  := SB1->B1_DESC      // Descricao do Produto
					aCols[N][nPosLocal] := If(Empty(aCols[N][nPosLocal]), RetFldProd(SB1->B1_COD,"B1_LOCPAD"),aCols[N][nPosLocal] )
					If aCols1[nScan][nPosTipo] == "5"
						aCols[N][nPosTES]   := If(Empty(aCols[N][nPosTES]),RetFldProd(SB1->B1_COD,"B1_TE"),aCols[N][nPosTES])
					Else
						aCols[N][nPosTES]   := If(!Empty(RetFldProd(SB1->B1_COD,"B1_TE")),RetFldProd(SB1->B1_COD,"B1_TE"),aCols[N][nPosTES])
					EndIf

					If !Empty(aCols[N][nPosTES])
						MaFisAlt("IT_TES",aCols[N][nPosTES],N)
					EndIf

					If nPosCC <> 0 .And. nPosCLVL <> 0 .And. nPosConta <> 0 .And. nPosItCta <> 0
						aCols[N][nPosCC]    := If( Empty(aCols[N][nPosCC])   , SB1->B1_CC    , aCols[N][nPosCC]   )
						aCols[N][nPosCLVL]  := If( Empty(aCols[N][nPosCLVL]) , SB1->B1_CLVL  , aCols[N][nPosCLVL] )
						aCols[N][nPosConta] := If( Empty(aCols[N][nPosConta]), SB1->B1_CONTA , aCols[N][nPosConta])
						aCols[N][nPosItCta] := If( Empty(aCols[N][nPosItCta]), SB1->B1_ITEMCC, aCols[N][nPosItCta])
					EndIf

					A143SegUm()

				Else
					Help(" ",1,"A143PRODUT")
					lRet := .F.
				EndIf
			Else
				Help(" ",1,"A113IMPORT")
				lRet := .F.
			Endif

		ElseIf nScan > 0 .And. aCols1[nScan][nPosTipo] $ "A" // Despesas

			If SB1->B1_DESPIMP == "S"

				aCols[N][nPosUM]    := SB1->B1_UM        // Unidade de medida
				aCols[N][nPosSegum] := SB1->B1_SEGUM     // Segunda Unidade
				aCols[N][nPosDesc]  := SB1->B1_DESC      // Descricao do Produto
				aCols[N][nPosLocal] := If(Empty(aCols[N][nPosLocal]), RetFldProd(SB1->B1_COD,"B1_LOCPAD"),aCols[N][nPosLocal] )
				aCols[N][nPosTES]   := If(!Empty(RetFldProd(SB1->B1_COD,"B1_TE")),RetFldProd(SB1->B1_COD,"B1_TE"),aCols[N][nPosTES])

				If !Empty(aCols[N][nPosTES])
					MaFisAlt("IT_TES",aCols[N][nPosTES],N)
				EndIf

				A143SegUm()

			Else
				Aviso("A143NODES",STR0077,{"Ok"},1) // "Para invoices de despesas de importação utilizar produtos cadastrados como despesa de importação, verifique o campo B1_DESPIMP do produto digitado."
				lRet := .F.
			Endif

		EndIf

	Else
		lRet := .F.
	EndIf
Else
	Help(" ",1,"REGNOIS")
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A143Quant³ Autor ³Alexandre Inacio Lemes ³ Data ³25/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da quantidade digitada.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Quantidade digitada                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Dicionario de Dados - DBC_QUANT                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143Quant(nQuant)

Local aArea		:= GetArea()
Local nPosPrc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DBC_PRECO"})
Local nPosQTD	 := aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_QUANT" })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a quantidade da Segunda UM                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A143SegUm()
If cPaisLoc $ "PER|COL|EQU"
	MaFisAlt("IT_VALMERC" , NoRound(aCols[N][nPosPrc] * aCols[N][nPosQTD],TamSx3("DBC_TOTAL")[2]) , N )
Else
	MaFisAlt("IT_VALMERC" , NoRound(aCols[N][nPosPrc] * M->DBC_QUANT,TamSx3("DBC_TOTAL")[2]) , N )
EndIf

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A143Preco³ Autor ³Alexandre Inacio Lemes ³ Data ³25/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do preco unitario digitado                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Preco digitado                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Dicionario de Dados - Campo: DBC_PRECO                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143Preco(nPreco)

// Desenvolver Validacao se necessario pois a chamada ja esta no dicionario do campo DBC_PRECO

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A143Total³ Autor ³Alexandre Inacio Lemes ³ Data ³25/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do valor total digitado                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor Total                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Dicionario de Dados - Campo: DBC_TOTAL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143Total(nTotal)

Local aArea    := GetArea()
Local nPosDoc  := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_ITEM"  })
Local nPosTipo := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_TIPONF"})
Local nPosQtde := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_QUANT" })
Local nPosPreco:= aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_PRECO" })
Local nPosItDoc:= aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_ITDOC" })
Local nDif     := NoRound( aCols[N,nPosQtde] * aCols[N,nPosPreco] , 2 ) - nTotal
Local nScan    := 0
Local lRet     := .T.
Local nPosMoeda	 := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_MOEDA"})
Local nNumInv  := aScan(aCols1,{|x| Alltrim(x[nPosDoc]) == aCols[1][nPosItDoc]})
nMoedaDes     := aCols1[nNumInv][nPosMoeda]

If nDif < 0
	nDif := -(nDif)
EndIf

nScan := aScan(aCols1 , { |x| x[Len(aHeader1)+1] == .F. .And. x[nPosDoc]== aCols[N][nPosItDoc] } )

If nScan > 0 .And. aCols1[nScan][nPosTipo] $ "5|8|A" // FOB // CIF // Despesas
	If cPaisLoc=="PAR" .And. MsDecimais(nMoedaDes)  ==0
		If Int(nDif) > 1.00
			Help(" ",1,"TOTAL")
			lRet := .F.
		EndIf
    Else
		If nDif > 0.49
			Help(" ",1,"TOTAL")
			lRet := .F.
		EndIf
    EndIf
EndIf

RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A143VFold ³ Autor ³Alexandre Inacio Lemes ³ Data ³05/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exucuta o calculo de valores para campos Totalizadores.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Referencia ( vide MATXFIS)                         ³±±
±±³          ³ ExpC2 = Valor da Referencia                                ³±±
±±³          ³ ExpL3 = .T./.F.- Executa o Refresh do folder               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Campos Totalizadores do MATA143                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143VFold(cReferencia,xValor,lRefre)

Local aArea	   := GetArea()
Local lRetorno := .T.
Local nPosCF   := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_FORNEC"})
Local nPosProv := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_PROVEN"})

If ValType(xValor)== "N" .And. xValor < 0
	lRetorno := .F.
EndIf

If lRetorno

	If lRefre == Nil
		lRefre := .T.
	EndIf

	If MaFisFound("NF")
		If cReferencia $ "NF_FRETE/NF_DESPESA/NF_SEGURO"
			M143Peso(cReferencia)
		EndIf
		MaFisAlt(cReferencia,xValor)
		If cPaisLoc == "ARG" .And. (cReferencia=="NF_CODCLIFOR" .Or.cReferencia=="NF_LOJA")
			SA2->(DbSetOrder(1))
			SA2->(MsSeek(xFilial("SA2")+MaFisRet(,"NF_CODCLIFOR")+MaFisRet(,"NF_LOJA")))
			MaFisAlt("NF_SERIENF",LocXTipSer("SA2",MVNOTAFIS))
		Endif
		If cReferencia == "NF_PROVENT"
			MaFisToCols(aHeader2 , IIf( Len(aColsIt) >= N , aColsIt[N] , aCols2 ) ,, "MT120")
		EndIf
		If lRefre
			MaFisToCols(aHeader,aCols,,"MT120")
			Eval(bRefresh)
			Eval(bGDRefresh)
		EndIf
	Else
		If cReferencia=="NF_LOJA"
			MaFisIni(aCols[N][nPosCF],xValor,"F","N",Nil,aRefImpos,,.T.)
			If nPosProv > 0
				If !Empty(aCols[N][nPosProv])
					MaFisAlt("NF_PROVENT",aCols[N][nPosProv])
    			EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A143Refresh³ Autor ³Alexandre Inacio Lemes³ Data ³03/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa o Refresh do Folder.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os valores do Rodape                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ COMPRAS INTERNACIONAL                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143Refresh(aValFld)

Local aArea	    := GetArea()
Local nPosDesc	:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_DESCON"})
Local nPosFret	:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_FRETE" })
Local nPosDesp	:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_DESPES"})
Local nPosSegu	:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_SEGURO"})
Local nPosItDoc	:= aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_ITDOC" })
Local nPosItInv	:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_ITEM"})
Local nNumInv	:= 0

If Type("nNResp") == "N" .and. nNResp > 0
	N := nNResp
EndIf

If oFldInv:nOption == 1		// Folder Invoices
	nNumInv := Val(aCols1[N][nPosItInv])
ElseIf oFldInv:nOption == 2	// Folder Itens das Invoices
	nNumInv := aScan(aCols1,{|x| Alltrim(x[nPosItInv]) == aCols[1][nPosItDoc]})
EndIf

If nPosDesc >0 .And. nNumInv > 0
	aCols1[nNumInv][nPosDesc] := MaFisRet(,"NF_DESCONTO")
EndIf
If nPosFret>0 .And. nNumInv > 0
	aCols1[nNumInv][nPosFret] := MaFisRet(,"NF_FRETE")
EndIf
If nPosDesp>0 .And. nNumInv > 0
	aCols1[nNumInv][nPosDesp] := MaFisRet(,"NF_DESPESA")
EndIf
If nPosSegu>0 .And. nNumInv > 0
	aCols1[nNumInv][nPosSegu] := MaFisRet(,"NF_SEGURO")
EndIf


aValFld[VALMERC]	:= MaFisRet(,"NF_VALMERC")
aValFld[VALDESC]	:= MaFisRet(,"NF_DESCONTO")
aValFld[FRETE]		:= MaFisRet(,"NF_FRETE")
aValFld[VALDESP]	:= MaFisRet(,"NF_DESPESA")
aValFld[SEGURO]  	:= MaFisRet(,"NF_SEGURO")
aValFld[VALBRU]	    := MaFisRet(,"NF_TOTAL")
aValFld[TOTDESP]	:= aValFld[FRETE]+aValFld[SEGURO]+aValFld[VALDESP]//+aValFld[PACKING]

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A143FRefre³ Autor ³Alexandre Inacio Lemes ³ Data ³05/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa o refresh nos objetos do array.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array contendo os Objetos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ COMPRAS INTERNACIONAL                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143FRefresh(aObj)

Local nX := 0

aObj[01]:Picture := PesqPict('DBB','DBB_VALMER',17,nMoedaDes)
aObj[02]:Picture := PesqPict('DBB','DBB_FRETE' ,17,nMoedaDes)
aObj[03]:Picture := PesqPict('DBB','DBB_DESCON',17,nMoedaDes)
aObj[04]:Picture := PesqPict('DBB','DBB_DESPES',17,nMoedaDes)
aObj[05]:Picture := PesqPict('DBB','DBB_SEGURO',17,nMoedaDes)
aObj[06]:Picture := PesqPict('DBB','DBB_VALBRU',17,nMoedaDes)
aObj[07]:Picture := PesqPict('DBB','DBB_FRETE' ,14,nMoedaDes)
aObj[08]:Picture := PesqPict('DBB','DBB_DESPES',14,nMoedaDes)
aObj[09]:Picture := PesqPict('DBB','DBB_SEGURO',14,nMoedaDes)
aObj[10]:Picture := PesqPict('DBB','DBB_VALBRU',14,nMoedaDes)

For nX := 1 to Len(aObj)
	aObj[nX]:Refresh()
Next nX

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A143Trigger³ Autor ³Alexandre Inacio Lemes³ Data ³15/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Simula a validacao da GetDados para campos alterados pelo   ³±±
±±³          ³gatilho                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Campo alterado pelo gatilho                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA143                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143Trigger(cCampo)

Local aArea 	:= GetArea()
Local aRefer    := {}
Local nPosCpo	:= aScan(aHeader,{|x| AllTrim(x[2])==AllTrim(cCampo)})
Local lRetorno	:= .T.

If nPosCpo > 0
	aRefer := MaFisGetRF(aHeader[nPosCpo][6])
	If !Empty(aRefer[1])
		MaFisRef(aRefer[1],aRefer[2],aCols[N,nPosCpo])
	EndIf
Else
	lRetorno := .F.
EndIf

RestArea(aArea)

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A143IniFis³ Autor ³Alexandre Inacio Lemes ³ Data ³28/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143IniFis(aObj)

Local cValid     := ""
Local cRefCols   := ""
Local nPosFor    := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_FORNEC"})
Local nPosLoja   := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_LOJA"  })
Local nPosItem   := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_ITEM"  })
Local nPosMoeda	 := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_MOEDA" })
Local nPosTxMoeda:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_TXMOED" })
Local nPosProv   := aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_PROVEN"})
Local nPosInvoice:= 0
Local nX         := 0
Local nY         := 0

nMoedaDes  := aCols[N][nPosMoeda]
aValFld[VALMERC] := 0
aValFld[VALDESC] := 0
aValFld[FRETE]	 := 0
aValFld[VALDESP] := 0
aValFld[SEGURO]  := 0
//aValFld[PACKING] := 0
aValFld[VALBRU]	 := 0
aValFld[TOTDESP] := 0

A143FRefresh(aObj)

If !Empty(aCols[N][nPosFor]) .And.!Empty(aCols[N][nPosLoja])

	MaFisEnd(.F.)

	MaFisIni(aCols[N][nPosFor],aCols[N][nPosLoja],"F","N",Nil,aRefImpos,,.T.)

	If nPosProv > 0
		If !Empty(aCols[N][nPosProv])
			MaFisAlt("NF_PROVENT",aCols[N][nPosProv])
		EndIf
	EndIf
	nPosInvoice:= Val(aCols[N,nPosItem])

	If Len(aColsIt) >= nPosInvoice
		nQTdInv:= Len(aColsIt[nPosInvoice])
		For nX := 1 to  nQTdInv
			MaFisIniLoad(nX,,.T.)
			For nY	:= 1 To Len(aHeader2)
				cValid	:= AllTrim(UPPER(aHeader2[nY][6]))
				cRefCols := MaFisGetRf(cValid)[1]
				If !Empty(cRefCols) .And. MaFisFound("IT",nX)
					MaFisLoad(cRefCols,aColsIt[nPosInvoice][nX][nY],nX)
				EndIf
			Next nY
			If nX ==  nQTdInv
				MaFisEndLoad(nX,1)
			Else
				MaFisEndLoad(nX,1,.f.)
			EndIf

			If aColsIt[nPosInvoice][nX][Len(aColsIt[nPosInvoice][nX])]
				MaFisDel(nX, aColsIt[nPosInvoice][nX][Len(aColsIt[nPosInvoice][nX])] )
			EndIf

		Next nX
	EndIf

	aValFld[VALMERC] := MaFisRet(,"NF_VALMERC")
	aValFld[VALDESC] := MaFisRet(,"NF_DESCONTO")
	aValFld[FRETE]	 := MaFisRet(,"NF_FRETE")
	aValFld[VALDESP] := MaFisRet(,"NF_DESPESA")
	aValFld[SEGURO]  := MaFisRet(,"NF_SEGURO")
	//	aValFld[PACKING] := MaFisRet(,"NF_VALEMB")
	aValFld[VALBRU]	 := MaFisRet(,"NF_TOTAL")
	aValFld[TOTDESP] := aValFld[FRETE]+aValFld[SEGURO]+aValFld[VALDESP]//+aValFld[PACKING]

	A143FRefresh(aObj)
Else
	MaFisEnd(.F.)
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A143Gd1Del³ Autor ³Alexandre Inacio Lemes ³ Data ³ 06/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica a delecao da linha da getdados 1 DBB               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Getdados1 das Invoices do MATA143                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143Gd1Del()

Local nPosDoc := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_ITEM"  })
Local nPosOk  := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_OK"    })
Local nPItDoc := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_ITDOC" })
Local cItDoc  := ""
Local nX      := 0
Local nY      := 0
Local lExiste := .F.

If nOpcion == 4 .And. !Empty(aCols[n][nPosOk])
	// Documento ya generado. El borrado debe ser a través de la rutina de documentos de entrada
	Return .F.
EndIf

If aCols[N][Len(aCols[N])]

	cItDoc := aCols[N][nPosDoc]

	For nX := 1 To Len(aColsIt)
		If aScan(aColsIt[nX] , { |x| x[nPItDoc] == cItDoc } ) > 0
            lExiste:= .T.
			For nY := 1 To Len(aColsIt[nX])
				aColsIt[nX][nY][Len(aHeader2)+1] := .T.
			Next nY
			Exit
		EndIf
	Next nX

	If !lExiste
		aadd(aColsIt,{Array(Len(aHeader2)+1)})
		dbSelectArea("DBC")
		For nY := 1 To Len(aHeader2)
			If IsHeadRec(aHeader2[nY][2])
				aColsIt[Len(aColsIt)][1][nY] := 0
			ElseIf IsHeadAlias(aHeader2[nY][2])
				aColsIt[Len(aColsIt)][1][nY] := "DBC"
			ElseIf Trim(aHeader2[nY][2]) == "DBC_ITDOC"
				aColsIt[Len(aColsIt)][1][nY] := cItDoc
			ElseIf Trim(aHeader2[nY][2]) == "DBC_ITEM"
				aColsIt[Len(aColsIt)][1][nY] := "0001"
			ElseIf Trim(aHeader2[nY][2]) != "DBC_HAWB"
				aColsIt[Len(aColsIt)][1][nY] := CriaVar(aHeader2[nY][2])
			EndIf
			aColsIt[Len(aColsIt)][1][Len(aHeader2)+1] := .T.
		Next nY
	EndIf

EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A143GdDel³ Autor ³Alexandre Inacio Lemes ³ Data ³ 28/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica a delecao da linha                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Getdados2 dos Itens da Invoice do MATA143                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143Gd2Del()
Local nPosStatus	:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_OK"    })
Local nPosItInv		:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_ITEM"})
Local nPosItDoc		:= aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_ITDOC" })
Local nNumInv		:= 0

If nOpcion == 4
	nNumInv := aScan(aCols1,{|x| Alltrim(x[nPosItInv]) == aCols[1][nPosItDoc]})
	If !Empty(aCols1[nNumInv][nPosStatus])
		// Documento ya generado. El borrado debe ser a través de la rutina de documentos de entrada
		Return .F.
	EndIf
EndIf

If !MaFisFound("IT",n)
	MaFisAdd("","",0,0,0,"","",,0,0,0,0,0)
EndIf

MaFisDel(n,aCols[n][Len(aCols[n])])
Eval(bRefresh)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M143GerLog³Autor  ³Alexandre Inacio Lemes ³ Data ³24/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Arquivo Texto com LOG de erro c/itens nao gerados     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M143GerLog(aLogErro,lEnd)

Local cLogFile   := 'DESPACHO.LOG'
Local cString    := ''
Local cNAR       := AllTrim(RetTitle('DBB_HAWB'))
Local cItem      := AllTrim(RetTitle('DBB_ITEM'))
Local cDoc       := AllTrim(RetTitle('DBB_DOC'))
Local cSerie     := AllTrim(SerieNfId("DBB",7,"DBB_SERIE"))
Local nLogHdl    := 0
Local nX         := 0

DEFAULT aLogErro   := {}
DEFAULT lEnd       := .F.

If File(cLogFile)
	nLogHdl := fOpen(cLogFile, 2)
	fSeek(nLogHdl, 0, 2)
Else
	nLogHdl := MSfCreate(cLogFile, 0)
EndIf
If nLogHdl > 0
	cString := Replicate('-', 80) + Chr(13) + Chr(10)
	fWrite(nLogHdl,cString,Len(cString))
	cString := SubStr(cUsuario,7,6) + ', ' + Time() + ', ' + DtoC(Date()) + Chr(13) + Chr(10)
	fWrite(nLogHdl,cString,Len(cString))
	If Len(aLogErro) > 0
		cString := PadR(cNAR, TamSX3('DBB_HAWB')[1]) + '|' + PadR(cItem, TamSX3('DBB_ITEM')[1])+ '|' + PadR(cDoc, TamSX3('DBB_DOC')[1])+ '|' + PadR(cSerie, SerieNfId("DBB",6,"DBB_SERIE")) + Chr(13) + Chr(10)
		fWrite(nLogHdl,cString,Len(cString))
		For nX := 1 to Len(aLogErro)
			cString := aLogErro[nX,1] + '|' + aLogErro[nX,2] + '|' + aLogErro[nX,3] + '|' + aLogErro[nX,4] + Chr(13) + Chr(10)
			fWrite(nLogHdl,cString,Len(cString))
		Next nX
	EndIf
	If lEnd
		cString := STR0040 //'INTERROMPIDO PELO USUARIO'
		fWrite(nLogHdl,cString,Len(cString))
	EndIf
	fClose(nLogHdl)
Else
	Help(" ",1,"A143NOTLOG") // "Nao foi possivel realizar a gravacao do LOG de erro referente ao(s) item(ns) do Processo de Importação."
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M143Log   ³Autor  ³Alexandre Inacio Lemes ³ Data ³24/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Indica o log dos Itens da Nota Fiscal nao gerados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M143Log(aLogErro)

Local cNAR       := AllTrim(RetTitle('DBB_HAWB'))
Local cItem      := AllTrim(RetTitle('DBB_ITEM'))
Local cDoc       := AllTrim(RetTitle('DBB_DOC'))
Local cSerie     := AllTrim(SerieNfId("DBB",7,"DBB_SERIE"))
Local cVarq      := ''
Local nAt        := 0
Local oDlg
Local oQual

DEFAULT aLogErro   := {}

If Len(aLogErro) > 0
	DEFINE MSDIALOG oDlg TITLE STR0039 From 130,70 To 350,410 OF oMainWnd PIXEL //"Um ou mais itens do Processo não gerados"
	@ 10,13 TO 90,172 LABEL '' OF oDlg  PIXEL
	@ 20,18 LISTBOX oQual VAR cVarq Fields HEADER cNAR,cItem,cDoc, cSerie SIZE 150,62 NOSCROLL OF oDlg PIXEL
	oQual:SetArray(aLogErro)
	oQual:bLine := { || {aLogErro[oQual:nAt,1],aLogErro[oQual:nAt,2],aLogErro[oQual:nAt,3],aLogErro[oQual:nAt,4]}}
	DEFINE SBUTTON FROM 95,90 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A143GeraNF³ Autor ³ Alexandre Inacio Lemes  ³Data  ³18/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera as Facturas FOB / Frete / Seguro / DUA / CIF / Impostos ³±±
±±³          ³ e Despesas do Processo de Importacao.                        ³±±
±±³          ³ Notas Geradas Tipo 5 - 6 - 7 - 8 - 9 - A - D                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1: Encerra a Geracao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum										        	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143GeraNF(cTipoNFE,lEnd)

Local aLogErro   := {}
Local aCabs      := {}
Local aItens     := {}
Local aOutros	   :={}
Local aitens1	   :={}
Local aitens2	   :={}
Local aItensBKP  := {}
Local aRetPE	 := {}
Local aTesValRat := {}

Local cSeek      := ""
Local cCF        := ""
Local cNumNF     := ""
Local cSerie     := ""
Local cStatusDBA := ""
Local cTipoNF    := SuperGetMV("MV_TPNRNFS")

Local cTesDesp	:= ""
Local cItem		:= StrZero(0,TamSX3('D1_ITEM')[1])

Local nValDesp := 0
Local nX		:= 0
Local nY      	:= 0
Local nContDBB 	:= 0
Local nj		:= 1
Local X		   	:= 1
Local na 		:= 0
Local nb		:= 0
Local nc 		:= 0

Local nPosRecDBB := Len(aHeader1)
Local nPosTipo   := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_TIPONF"})
Local nPosOk     := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_OK"})
Local nPosFornec := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_FORNEC"})
Local nPosLoja   := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_LOJA"})
Local nPosSerie  := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_SERIE"})
Local nPosNota   := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_DOC"})
Local nPosTesRat := 0
Local nRat       := 0
Local nRat1      := 0

Local lFormul    := !Empty(DBB->(FieldPos("DBB_FORMUL")))
Local lGerou     := .F.
Local lRetorno   := .T.
Local lFirst     := .T.
Local lRet       := .T.
Local lMT143SD1	 := ExistBlock("MT143SD1")
Local lMT143SF1  := ExistBlock("MT143SF1")
Local lM143ITEM  := ExistBlock("M143ITEM")
Local lM143CAB   := ExistBlock("M143CAB")
Local lM143TOK   := ExistBlock("M143TODOK")
Local lContinua  := .T.

Local oDlg
Local oBtn1
Local lMostMsg	:= .T.
Local nTipo	:= 10
Local nj := 1
Local X := 1
Local NI := 1
Local na := 1
Local nb := 1
Local nc := 1
Local nValor := 0
Local aVenc := {}
Local nMoeda	 := 0
Local TxMoeda := 0
Local aRet	 := {}
Local cParcela:= ""
Local nDecimal:= 2
Local nTotDup := 0
Local nValBas1 := 0
Local nValimp1 := 0
Local nValBas2 := 0
Local nValimp2 := 0
Local nValBas3 := 0
Local nValimp3 := 0
Local nValBas4 := 0
Local nValimp4 := 0
Local nValBas5 := 0
Local nValimp5 := 0
Local nValBas6 := 0
Local nValimp6 := 0
Local nValBas7 := 0
Local nValimp7 := 0
Local nValBas8 := 0
Local nValimp8 := 0
Local nValBas9 := 0
Local nValimp9 := 0
Local nValBasA := 0
Local nValimpA := 0
Local nValBasB := 0
Local nValimpB := 0
Local nValBasC := 0
Local nValimpC := 0
Local nValBasD := 0
Local nValimpD := 0
Local nValBasE := 0
Local nValimpE := 0
Local nValBasF := 0
Local nValimpF := 0
Local nValBasG := 0
Local nValimpG := 0
Local nValBasH := 0
Local nValimpH := 0
Local nValBasI := 0
Local nValimpI := 0
Local nValBasJ := 0
Local nValimpJ := 0
Local nValBasK := 0
Local nValimpK := 0
Local nValBasL := 0
Local nValimpL := 0
Local nValBasM := 0
Local nValimpM := 0
Local nValBasN := 0
Local nValimpN := 0
Local nValBasO := 0
Local nValimpO := 0
Local nValBasP := 0
Local nValimpP := 0
Local nValBasQ := 0
Local nValimpQ := 0
Local nValBasR := 0
Local nValimpR := 0
Local nValBasS := 0
Local nValimpS := 0
Local nValBasT := 0
Local nValimpT := 0
Local nValBasU := 0
Local nValimpU := 0
Local nValBasV := 0
Local nValimpV := 0
Local nValBasW := 0
Local nValimpW := 0
Local nValBasX := 0
Local nValimpX := 0
Local nValBasY := 0
Local nValimpY := 0
Local nValBasZ := 0
Local nValimpZ := 0
Local ValorImp := ""
Local lGeraDup := .F.
Local lAutomato:= IsBlind()
Local nResN
Local lSomaMerc :=.F.
Local nPesoIt:= 0
Local nPesoTot:= 0
Local lProvDom := .F.
Local lGerNF	:= .F.
Local nDocNoGer	:= 0
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local aAreaWms  := {}
Local cCampos   := ""

Private nTotalNf:= 0
Private nTotalMerc:=0
PRIVATE oProcess
PRIVATE aRecsSF1 := {}
Private aCfgNF	:=	{}
Private aDupl   := {}
Private acampCab := {}
Private aItemCab := {}
Private acampDad := {}
Private aItemDad := {}
Private cTipo 	:= "N"
Private aPergs	:=	{.F.,.F.,.F.,.F.,.F.}
Private lBloqImp    := .F.
Private dDEmissao := dDatabase
Private cNatureza := ""
Private cFunName := "MATA101N"
Private cCondicao := ""
Private nNResp  := 0
Private dDataEmis:= dDatabase
Private lActFjRm := .F.

DEFAULT lEnd     := .F.

If !lAutomato
	nResN := N //Respalda la fila actual en la que esta el acols
EndIf
If cPaisLoc == "ARG"
	aPergs:= {}
	If cTipoNFE == "5"
		lFob := .T.
	EndIf
EndIf
If cPaisLoc == "ANG"
	DBG->(DbSetOrder(1))
	DBG->(DbSeek(xFilial("DBG")+M->DBA_HAWB))
	While DBG->(!Eof()) .And. DBG->DBG_NRPROC == M->DBA_HAWB
		If Empty(DBG->DBG_OK)
			lRet := .F.
			Aviso(STR0026,STR0086,{"Ok"}) //"Existem documentos pendentes no CheckList"
			Exit
		EndIf
		DBG->(DbSkip())
	End
EndIf

If lRet .And. (DBA->DBA_OK <> "3")
	If lAutomato .Or. MsgYesNo(STR0025, STR0026) //"Confirma a geração do documento de entrada?"//"Atenção"
		ProcRegua(Len(aCols1))
		n:= 0

		For nX := 1 to Len(aCols1)
			aTesValRat := {}

			If aCols1[nX][nPosTipo] == cTipoNFE
				If lAutomato
					If cPaisLoc == "ARG" .And. FindFunction("ACPOIMPARG") .And. (Type("ACPOIMP") == "U" .Or. Len(ACPOIMP) == 0)
						ACPOIMP := ACPOIMPARG()
					EndIf
				EndIf
				n:= n+1
				nContDBB ++
				IncProc(STR0027+  AllTrim(Str(Int((nContDBB/Len(aCols1))*100)))  +'%' ) //"Aguarde... Gerando "

				If lEnd //-- Interrompe a geracao
					If Aviso(STR0026, STR0028, {STR0029, STR0030}) == 1 //'Atencao'###'Deseja interromper a geração?'###'Sim'###'Nao'
						Exit
					Else
						lEnd := .F.
					EndIf
				EndIf

				If cPaisloc $ "ARG|PAR"
					aRecsSF1 := {}
					aCabs    := {}
					aItens   := {}
					cNumNF   := ""
					cSerie   := ""
					cTesDesp := ""
					nValDesp := 0
					nTotalMerc := 0
					nTotalNf	:= 0
				Else
					aRecsSF1 := {}
					aCabs    := {}
					aItens   := {}
					cNumNF   := ""
					cSerie   := ""
					cTesDesp := ""
					nValDesp := 0
					nTotalMerc := 0
					nTotalNf	:= 0
				EndIf
				nPesoIt:= 0
				nPesoTot:= 0
				lGeraDup := .F.

				dbSelectArea("DBB")
				dbSetOrder(1)
				dbGoto(aCols1[nX][nPosRecDBB])

				If lFormul .And. DBB->DBB_FORMUL == "1" .And. (DBB->DBB_DOC+DBB->DBB_SERIE == DBB->DBB_HAWB+DBB->DBB_ITEM)
					If lFirst
						cSerieId := IIf( lUsaNewKey , SerieNfId("SF1",4,"F1_SERIE",dDataBase,cEspecie,cSerie),cSerie )
						lRetorno := Sx5NumNota(@cSerie,cTipoNF)
						If lRetorno
							lFirst   := .F.
						EndIf
					EndIf
					If lRetorno .And. cTipoNF <> "3"
						cNumNF := NxtSX5Nota(cSerie,.T.,cTipoNF)
					Else
						cNumNF := ""
						cSerie := ""
					EndIf
				Else
					cNumNF := DBB->DBB_DOC
					cSerie := DBB->DBB_SERIE
				EndIf

				cTipo := IIf( DBB->DBB_TIPONF $ "5|8" , "N" , "C" )

				dbSelectArea("DBB")
				//-- Desconsidera NF que ja foram geradas
				If !Empty(cNumNF)
					SF1->(dbSetOrder(1))
					If SF1->(MsSeek(xFilial('SF1')+cNumNF+cSerie+DBB->DBB_FORNEC+DBB->DBB_LOJA+cTipo, .F.))
						If ExistBlock("MT143MSG")
							lMostMsg := ExecBlock("MT143MSG",.F.,.F.,)
						EndIf
						If ValType(lMostMsg)=="L" .AND. lMostMsg
							Aviso(STR0026,STR0048+cNumNF+cSerie+cTipo+" "+STR0046+DBB->DBB_FORNEC+DBB->DBB_LOJA+" "+STR0049 ,{'Ok'}) //'Atencao'###'"O Documento de Entrada "" Já existe e não pode ser Gerado"
						EndIf
						nContDBB --
						Loop
					EndIf
				Else
					nContDBB --
					Loop
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Construcao do aCabs e aItens para as NFEs FOB e CIF - TIPONF 5 e 8.               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dDataEmis:= DBB->DBB_EMISSA
				If DBB->DBB_TIPONF $ "5|8"

					dbSelectArea("DBC")
					If dbSeek(cSeek:=DBB->DBB_FILIAL+DBB->DBB_HAWB+DBB->DBB_ITEM, .F.)

						Do While !Eof() .And. !lEnd .And. cSeek==DBC_FILIAL+DBC_HAWB+DBC_ITDOC

							If lEnd //-- Interrompe a geracao
								If Aviso(STR0026, STR0028, {STR0029, STR0030}) == 1 //'Atencao'###'Deseja interromper a geração?'###'Sim'###'Nao'
									Exit
								Else
									lEnd := .F.
								EndIf
							EndIf


							SF4->(dbSetOrder(1))
							If SF4->(MsSeek(xFilial('SF4')+DBC->DBC_TES, .F.))
								cCF := SF4->F4_CF
							Else
								cCF := ""
							EndIf

								aAdd(aItens, {})
								nItens:=Len(aItens)
								aAdd(aItens[nItens] , {"D1_FILIAL"  , xFilial("SD1")  , Nil})
								aAdd(aItens[nItens] , {"D1_DOC"     , cNumNF          , Nil})
								aAdd(aItens[nItens] , {"D1_SERIE"   , cSerie          , Nil})
								aAdd(aItens[nItens] , {"D1_FORNECE" , DBB->DBB_FORNEC , Nil})
								aAdd(aItens[nItens] , {"D1_LOJA"    , DBB->DBB_LOJA   , Nil})
								aAdd(aItens[nItens] , {"D1_EMISSAO" , DBB->DBB_EMISSA , Nil})
								aAdd(aItens[nItens] , {"D1_DTDIGIT" , dDataBase       , Nil})
								aAdd(aItens[nItens] , {"D1_ESPECIE" , "NF"            , Nil})
								aAdd(aItens[nItens] , {"D1_TIPODOC" , "10"            , Nil})
								aAdd(aItens[nItens] , {"D1_TIPO"    , "N"             , Nil})
								aAdd(aItens[nItens] , {"D1_FORMUL"  , "N"             , Nil})
								nPesoIt:= Round(Posicione('SB1',1,xFilial('SB1')+DBC->DBC_CODPRO,'B1_PESO') * DBC->DBC_QUANT,TamSX3('D1_PESO')[2])
								nPesoTot:= nPesoTot+ nPesoIt
								aAdd(aItens[nItens] , {"D1_PESO"    , nPesoIt , Nil})
								aAdd(aItens[nItens] , {"D1_ITEM"    , DBC->DBC_ITEM   , Nil})
								aAdd(aItens[nItens] , {"D1_COD"     , DBC->DBC_CODPRO , Nil})
								aAdd(aItens[nItens] , {"D1_UM"      , DBC->DBC_UM     , Nil})
								If !Empty(DBC->DBC_SEGUM)
									aAdd(aItens[nItens] , {"D1_SEGUM"   , DBC->DBC_SEGUM  , Nil})
								Else
									aAdd(aItens[nItens] , {"D1_SEGUM"   ," " , Nil})
								EndIf
							aAdd(aItens[nItens] , {"D1_QTSEGUM" , DBC->DBC_QTSEGU , Nil})
								aAdd(aItens[nItens] , {"D1_QUANT"   , DBC->DBC_QUANT  , Nil})
								aAdd(aItens[nItens] , {"D1_VUNIT"   , DBC->DBC_PRECO  , Nil})
								aAdd(aItens[nItens] , {"D1_TOTAL"   , DBC->DBC_TOTAL  , Nil})
								aAdd(aItens[nItens] , {"D1_LOCAL"   , DBC->DBC_LOCAL  , Nil})
								aAdd(aItens[nItens] , {"D1_PEDIDO"  , DBC->DBC_PEDIDO , Nil})
								aAdd(aItens[nItens] , {"D1_ITEMPC"  , DBC->DBC_ITEMPC , Nil})
								aAdd(aItens[nItens] , {"D1_TES"     , DBC->DBC_TES    , Nil})
								aAdd(aItens[nItens] , {"D1_CF"      , cCF             , Nil})
								aAdd(aItens[nItens] , {"D1_CC"      , DBC->DBC_CC     , Nil})
								aAdd(aItens[nItens] , {"D1_CONTA"   , DBC->DBC_CONTA  , Nil})
								aAdd(aItens[nItens] , {"D1_ITEMCTA" , DBC->DBC_ITCTA  , Nil})
								aAdd(aItens[nItens] , {"D1_CLVL"    , DBC->DBC_CLVL   , Nil})
								aAdd(aItens[nItens] , {"D1_VALFRE"  , DBC->DBC_VALFRE , Nil})
								aAdd(aItens[nItens] , {"D1_DESPESA" , DBC->DBC_DESPES , Nil})
								aAdd(aItens[nItens] , {"D1_SEGURO"  , DBC->DBC_SEGURO , Nil})
								aAdd(aItens[nItens] , {"D1_VALDESC" , DBC->DBC_VLDESC , Nil})
								aAdd(aItens[nItens] , {"D1_BASIMP1" , DBC->DBC_BSIMP1 , Nil})
								aAdd(aItens[nItens] , {"D1_ALQIMP1" , DBC->DBC_ALIMP1 , Nil})
								aAdd(aItens[nItens] , {"D1_VALIMP1" , DBC->DBC_VLIMP1 , Nil})
								aAdd(aItens[nItens] , {"D1_BASIMP2" , DBC->DBC_BSIMP2 , Nil})
								aAdd(aItens[nItens] , {"D1_ALQIMP2" , DBC->DBC_ALIMP2 , Nil})
								aAdd(aItens[nItens] , {"D1_VALIMP2" , DBC->DBC_VLIMP2 , Nil})
								aAdd(aItens[nItens] , {"D1_BASIMP3" , DBC->DBC_BSIMP3 , Nil})
								aAdd(aItens[nItens] , {"D1_ALQIMP3" , DBC->DBC_ALIMP3 , Nil})
								aAdd(aItens[nItens] , {"D1_VALIMP3" , DBC->DBC_VLIMP3 , Nil})
								aAdd(aItens[nItens] , {"D1_BASIMP4" , DBC->DBC_BSIMP4 , Nil})
								aAdd(aItens[nItens] , {"D1_ALQIMP4" , DBC->DBC_ALIMP4 , Nil})
								aAdd(aItens[nItens] , {"D1_VALIMP4" , DBC->DBC_VLIMP4 , Nil})
								aAdd(aItens[nItens] , {"D1_BASIMP5" , DBC->DBC_BSIMP5 , Nil})
								aAdd(aItens[nItens] , {"D1_ALQIMP5" , DBC->DBC_ALIMP5 , Nil})
								aAdd(aItens[nItens] , {"D1_VALIMP5" , DBC->DBC_VLIMP5 , Nil})
								aAdd(aItens[nItens] , {"D1_BASIMP6" , DBC->DBC_BSIMP6 , Nil})
								aAdd(aItens[nItens] , {"D1_ALQIMP6" , DBC->DBC_ALIMP6 , Nil})
								aAdd(aItens[nItens] , {"D1_VALIMP6" , DBC->DBC_VLIMP6 , Nil})
								aAdd(aItens[nItens] , {"D1_BASIMP7" , DBC->DBC_BSIMP7 , Nil})
								aAdd(aItens[nItens] , {"D1_ALQIMP7" , DBC->DBC_ALIMP7 , Nil})
								aAdd(aItens[nItens] , {"D1_VALIMP7" , DBC->DBC_VLIMP7 , Nil})
								aAdd(aItens[nItens] , {"D1_BASIMP8" , DBC->DBC_BSIMP8 , Nil})
								aAdd(aItens[nItens] , {"D1_ALQIMP8" , DBC->DBC_ALIMP8 , Nil})
								aAdd(aItens[nItens] , {"D1_VALIMP8" , DBC->DBC_VLIMP8 , Nil})
								aAdd(aItens[nItens] , {"D1_BASIMP9" , DBC->DBC_BSIMP9 , Nil})
								aAdd(aItens[nItens] , {"D1_ALQIMP9" , DBC->DBC_ALIMP9 , Nil})
								aAdd(aItens[nItens] , {"D1_VALIMP9" , DBC->DBC_VLIMP9 , Nil})
								aAdd(aItens[nItens] , {"D1_NUMSEQ"  , ProxNum()		, Nil})
								aAdd(aItens[nItens]	 , {"D1_GRUPO"   ,Posicione('SB1',1,xFilial('SB1')+DBC->DBC_CODPRO,'B1_GRUPO'), Nil})

								//Campos WMS - Argentina
								If cPaisLoc == "ARG" .And. lWmsNew
									If IntWMS(DBC->DBC_CODPRO)
										aAreaWms := SB5->(GetArea())
										dbSelectArea("SB5")
										SB5->(DBSetOrder(1)) //B5_FILIAL+B5_COD
										If SB5->(MsSeek(xFilial("SB5") + DBC->DBC_CODPRO, .F.))
											If !Empty(SB5->B5_SERVENT) .And. !Empty(SB5->B5_ENDECD)
												aAdd(aItens[nItens] , {"D1_SERVIC" , SB5->B5_SERVENT , Nil})
												aAdd(aItens[nItens] , {"D1_ENDER" , SB5->B5_ENDECD , Nil})
											Else
												cCampos := Iif(Empty(SB5->B5_SERVENT),AllTrim(RetTitle('B5_SERVENT')),'')
												cCampos += Iif(Empty(SB5->B5_ENDECD),Iif(!Empty(cCampos),', ','')+AllTrim(RetTitle('B5_ENDECD')),'')
												Help(" ", 1, "M143WMS", , STRTRAN(STR0101, "[VAR01]", cCampos), 2, 0) //"Los campos [VAR01] deben completarse cuando se utiliza la integración con el módulo de WMS."
												Return
											EndIf
										EndIf
										RestArea(aAreaWms)
									Else
										aAdd(aItens[nItens] , {"D1_SERVIC" , CriaVar('D1_SERVIC', .F.) , Nil})
										aAdd(aItens[nItens] , {"D1_ENDER" , CriaVar('D1_ENDER', .F.) , Nil})
									EndIf
								EndIf

								If cPaisLoc == "ARG"
									If ACPOIMP[_D1_BASIMPA]
										aAdd(aItens[nitens] , {"D1_BASIMPA" , DBC->DBC_BSIMPA   , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPA" , DBC->DBC_VLIMPA , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPA" , DBC->DBC_ALIMPA  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPB]
										aAdd(aItens[nitens] , {"D1_BASIMPB" , DBC->DBC_BSIMPB , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPB" , DBC->DBC_VLIMPB , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPB" , DBC->DBC_ALIMPB  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPC]
										aAdd(aItens[nitens] , {"D1_BASIMPC" , DBC->DBC_BSIMPC , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPC" , DBC->DBC_VLIMPC , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPC" , DBC->DBC_ALIMPC  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPD]
										aAdd(aItens[nitens] , {"D1_BASIMPD" , DBC->DBC_BSIMPD , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPD" , DBC->DBC_VLIMPD , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPD" , DBC->DBC_ALIMPD  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPE]
										aAdd(aItens[nitens] , {"D1_BASIMPE" , DBC->DBC_BSIMPE , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPE" , DBC->DBC_VLIMPE , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPE" , DBC->DBC_ALIMPE  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPF]
										aAdd(aItens[nitens] , {"D1_BASIMPF" , DBC->DBC_BSIMPF , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPF" , DBC->DBC_VLIMPF , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPF" , DBC->DBC_ALIMPF  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPG]
										aAdd(aItens[nitens] , {"D1_BASIMPG" , DBC->DBC_BSIMPG , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPG" , DBC->DBC_VLIMPG , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPG" , DBC->DBC_ALIMPG  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPH]
										aAdd(aItens[nitens] , {"D1_BASIMPH" , DBC->DBC_BSIMPH , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPH" , DBC->DBC_VLIMPH , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPH" , DBC->DBC_ALIMPH  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPI]
										aAdd(aItens[nitens] , {"D1_BASIMPI" , DBC->DBC_BSIMPI , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPI" , DBC->DBC_VLIMPI , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPI" , DBC->DBC_ALIMPI  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPJ]
										aAdd(aItens[nitens] , {"D1_BASIMPJ" , DBC->DBC_BSIMPJ , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPJ" , DBC->DBC_VLIMPJ , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPJ" , DBC->DBC_ALIMPJ  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPK]
										aAdd(aItens[nitens] , {"D1_BASIMPK" , DBC->DBC_BSIMPK , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPK" , DBC->DBC_VLIMPK , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPK" , DBC->DBC_ALIMPK  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPL]
										aAdd(aItens[nitens] , {"D1_BASIMPL" , DBC->DBC_BSIMPL , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPL" , DBC->DBC_VLIMPL , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPL" , DBC->DBC_ALIMPL  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPM]
										aAdd(aItens[nitens] , {"D1_BASIMPM" , DBC->DBC_BSIMPM , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPM" , DBC->DBC_VLIMPM , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPM" , DBC->DBC_ALIMPM  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPN]
										aAdd(aItens[nitens] , {"D1_BASIMPN" , DBC->DBC_BSIMPN , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPN" , DBC->DBC_VLIMPN , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPN" , DBC->DBC_ALIMPN  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPO]
										aAdd(aItens[nitens] , {"D1_BASIMPO" , DBC->DBC_BSIMPO , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPO" , DBC->DBC_VLIMPO , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPO" , DBC->DBC_ALIMPO  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPP]
										aAdd(aItens[nitens] , {"D1_BASIMPP" , DBC->DBC_BSIMPP , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPP" , DBC->DBC_VLIMPP , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPP" , DBC->DBC_ALIMPP  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPQ]
										aAdd(aItens[nitens] , {"D1_BASIMPQ" , DBC->DBC_BSIMPQ , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPQ" , DBC->DBC_VLIMPQ , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPQ" , DBC->DBC_ALIMPQ  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPR]
										aAdd(aItens[nitens] , {"D1_BASIMPR" , DBC->DBC_BSIMPR , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPR" , DBC->DBC_VLIMPR , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPR" , DBC->DBC_ALIMPR  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPS]
										aAdd(aItens[nitens] , {"D1_BASIMPS" , DBC->DBC_BSIMPS , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPS" , DBC->DBC_VLIMPS , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPS" , DBC->DBC_ALIMPS  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPT]
										aAdd(aItens[nitens] , {"D1_BASIMPT" , DBC->DBC_BSIMPT , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPT" , DBC->DBC_VLIMPT , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPT" , DBC->DBC_ALIMPT  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPU]
										aAdd(aItens[nitens] , {"D1_BASIMPU" , DBC->DBC_BSIMPU , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPU" , DBC->DBC_VLIMPU , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPU" , DBC->DBC_ALIMPU  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPV]
										aAdd(aItens[nitens] , {"D1_BASIMPV" , DBC->DBC_BSIMPV , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPV" , DBC->DBC_VLIMPV , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPV" , DBC->DBC_ALIMPV  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPW]
										aAdd(aItens[nitens] , {"D1_BASIMPW" , DBC->DBC_BSIMPW , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPW" , DBC->DBC_VLIMPW , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPW" , DBC->DBC_ALIMPW  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPX]
										aAdd(aItens[nitens] , {"D1_BASIMPX" , DBC->DBC_BSIMPX , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPX" , DBC->DBC_VLIMPX , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPX" , DBC->DBC_ALIMPX  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPY]
										aAdd(aItens[nitens] , {"D1_BASIMPY" , DBC->DBC_BSIMPY , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPY" , DBC->DBC_VLIMPY , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPY" , DBC->DBC_ALIMPY  , Nil})
									EndIf
									If  ACPOIMP[_D1_BASIMPZ]
										aAdd(aItens[nitens] , {"D1_BASIMPZ" , DBC->DBC_BSIMPZ , Nil})
										aAdd(aItens[nitens] , {"D1_VALIMPZ" , DBC->DBC_VLIMPZ , Nil})
										aAdd(aItens[nitens] , {"D1_ALQIMPZ" , DBC->DBC_ALIMPZ  , Nil})
									EndIf
									aAdd(aItens[nitens] , {"D1_PROVENT" , DBB->DBB_PROVEN  , Nil})
								EndIf
							If cPaisLoc == "BOL"
								lSomaMerc:=.T.

								If SF4->(Dbseek(xFilial("SF4")+DBC->DBC_TES)) .And. SF4->F4_AGREG == 'N'
									lSomaMerc:=.F.
								EndIf

								If lSomaMerc
									nTotalMerc:= nTotalMerc+ DBC->DBC_TOTAL
								EndIf
							Else
								nTotalMerc:= nTotalMerc+ DBC->DBC_TOTAL
							EndIf

							If SuperGetMV("MV_MULNATP") == .T.

								DbSelectArea("SC7")
								DbSetOrder(1)
								DbSeek(xFilial("SC7")+DBC->DBC_PEDIDO+DBC->DBC_ITEMPC)

								DbSelectArea("SEV")
								DbSetOrder(1)
								If !DbSeek(xFilial("SEV")+cSerie+cNumNF)

									If !Empty(SC7->C7_NATUREZ)
										RecLock("SEV",.T.)
										SEV->EV_FILIAL:= xFilial("SEV")
										SEV->EV_PREFIXO:=cSerie
										SEV->EV_NUM:= cNumNF
										SEV->EV_PARCELA:=""
										SEV->EV_CLIFOR:=DBB->DBB_FORNEC
										SEV->EV_LOJA:=DBB->DBB_LOJA
										SEV->EV_TIPO:="NF"
										SEV->EV_VALOR:=DBC->DBC_TOTAL
										SEV->EV_NATUREZ:=Alltrim(SC7->C7_NATUREZ)
										SEV->EV_RECPAG:="P"
										SEV->EV_PERC:=100
										SEV->EV_IDENT:="1"

										SEV->(MsUnlock())
									Else
										Alert(STR0095)
										Return

									EndIf
								EndIf
								EndIf

								aArea := GetArea()
								#IFDEF TOP
									If TcSrvType()<>"AS/400"
									cAliasImp2 := "IMP2"
									lQuery    := .T.

									cQuery := "SELECT FC_INCDUPL, FB_CPOLVRO, FB_CODIGO "
									cQuery += "  FROM " + RetSqlName("SFC")+ " SFC INNER JOIN "
									cQuery += RetSqlName("SFB")+ " SFB ON (SFC.FC_IMPOSTO = SFB.FB_CODIGO AND SFB.D_E_L_E_T_ <> '*' AND SFB.FB_FILIAL = '" + xFilial("SFB") + "') "
									cQuery += " WHERE FC_TES = '" + DBC->DBC_TES + "' AND SFC.D_E_L_E_T_ <> '*' AND SFC.FC_FILIAL = '" + xFilial("SFC") + "'"

									cQuery := ChangeQuery(cQuery)
									dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasImp2)

									TcSetField(cAliasImp2,"FB_CODIGO","C",8,0)
									EndIf
							#ENDIF
							If SF4->(Dbseek(xFilial("SF4")+DBC->DBC_TES)) .And. SF4->F4_DUPLIC == 'S'
							lGeraDup := .T.
							EndIf
							If cPaisLoc == "BOL"
								lSomaMerc:=.T.

								If SF4->F4_AGREG == 'N'
									lSomaMerc:=.F.
								EndIf
							EndIf

							nTotalNf := nTotalNf + DBC->DBC_TOTAL - DBC->DBC_VLDESC + DBC->DBC_VALFRE + DBC->DBC_DESPES + DBC->DBC_SEGURO

							Do While !IMP2->(EOF()) .and. !cPaisLoc $ "ARG|PAR|COL|PER|EQU"
								If IMP2->FC_INCDUPL = '1'
								ValorImp := "DBC->DBC_VLIMP" + IMP2->FB_CPOLVRO

								nTotalNf := nTotalNf + &ValorImp
								EndIf
								IMP2->(DbSkip())
							EndDo
							dbSelectArea(cAliasImp2)
							dbCloseArea()

							RestArea(aArea)

							nMoeda  := DBB->DBB_MOEDA
							TxMoeda := DBB->DBB_TXMOED
							cCondicao := DBB->DBB_COND
							If lMT143SD1
								aItens:= IF (ValType(aRetPE:= ExecBlock("MT143SD1",.F.,.F.,{aItens})) == "A",aRetPE,aItens)
							EndIf

							If lMT143SF1
								aCabs := IF (ValType(aRetPE:= ExecBlock("MT143SF1",.F.,.F.,{aCabs})) == "A",aRetPE,aCabs)
							EndIf

							//-- Subtrai campo Qtd. a Classificar no PO para poder gerar a nota
							If !Empty(DBC->(DBC_PEDIDO+DBC_ITEMPC))
								dbSelectArea("SC7")
								dbSetOrder(1)
								dbSeek(xFilial("SC7")+DBC->(DBC_PEDIDO+DBC_ITEMPC))
								RecLock("SC7",.F.)
								SC7->C7_QTDACLA -= DBC->DBC_QUANT
								MsUnLock()
							EndIf
								If cPaisLoc $ "ARG|PAR|COL|PER|EQU"
									nValBas1:= nValBas1+DBC->DBC_BSIMP1
									nValimp1:= nValimp1+DBC->DBC_VLIMP1
									nTotalNf:= nTotalNf+DBC->DBC_VLIMP1

									nValBas2:= nValBas2+DBC->DBC_BSIMP2
									nValimp2:= nValimp2+DBC->DBC_VLIMP2
									nTotalNf:= nTotalNf+DBC->DBC_VLIMP2

									nValBas3:= nValBas3+DBC->DBC_BSIMP3
									nValimp3:= nValimp3+DBC->DBC_VLIMP3
									nTotalNf:= nTotalNf+DBC->DBC_VLIMP3

									nValBas4:= nValBas4+DBC->DBC_BSIMP4
									nValimp4:= nValimp4+DBC->DBC_VLIMP4
									nTotalNf:= nTotalNf+DBC->DBC_VLIMP4

									nValBas5:= nValBas5+DBC->DBC_BSIMP5
									nValimp5:= nValimp5+DBC->DBC_VLIMP5
									nTotalNf:= nTotalNf+DBC->DBC_VLIMP5

									nValBas6:= nValBas6+DBC->DBC_BSIMP6
									nValimp6:= nValimp6+DBC->DBC_VLIMP6
									nTotalNf:= nTotalNf+DBC->DBC_VLIMP6

									nValBas7:= nValBas7+DBC->DBC_BSIMP7
									nValimp7:= nValimp7+DBC->DBC_VLIMP7
									nTotalNf:= nTotalNf+DBC->DBC_VLIMP7

									nValBas8:= nValBas8+DBC->DBC_BSIMP8
									nValimp8:= nValimp8+DBC->DBC_VLIMP8
									nTotalNf:= nTotalNf+DBC->DBC_VLIMP8

									nValBas9:= nValBas9+DBC->DBC_BSIMP9
									nValimp9:= nValimp9+DBC->DBC_VLIMP9
									nTotalNf:= nTotalNf+DBC->DBC_VLIMP9

								If cPaisLoc $ "ARG|PAR"
									If ACPOIMP[_D1_BASIMPA]
										nValBasA:= nValBasA+DBC->DBC_BSIMPA
										nValimpA:= nValimpA+DBC->DBC_VLIMPA
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPA

									EndIf
									If ACPOIMP[_D1_BASIMPB]
										nValBasB:= nValBasB+DBC->DBC_BSIMPB
										nValimpB:= nValimpB+DBC->DBC_VLIMPB
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPB
									EndIf
									If ACPOIMP[_D1_BASIMPC]
										nValBasC:= nValBasC+DBC->DBC_BSIMPC
										nValimpC:= nValimpC+DBC->DBC_VLIMPC
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPC
									EndIf
									If ACPOIMP[_D1_BASIMPD]
										nValBasD:= nValBasD+DBC->DBC_BSIMPD
										nValimpD:= nValimpD+DBC->DBC_VLIMPD
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPD
									EndIf
									If ACPOIMP[_D1_BASIMPE]
										nValBasE:= nValBasE+DBC->DBC_BSIMPE
										nValimpE:= nValimpE+DBC->DBC_VLIMPE
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPE
									EndIf
									If ACPOIMP[_D1_BASIMPF]
										nValBasF:= nValBasF+DBC->DBC_BSIMPF
										nValimpF:= nValimpF+DBC->DBC_VLIMPF
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPF
									EndIf
									If ACPOIMP[_D1_BASIMPG]
										nValBasG:= nValBasG+DBC->DBC_BSIMPG
										nValimpG:= nValimpG+DBC->DBC_VLIMPG
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPG
									EndIf
									If ACPOIMP[_D1_BASIMPH]
										nValBasH:= nValBasH+DBC->DBC_BSIMPH
										nValimpH:= nValimpH+DBC->DBC_VLIMPH
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPH
									EndIf
									If ACPOIMP[_D1_BASIMPI]
										nValBasI:= nValBasI+DBC->DBC_BSIMPI
										nValimpI:= nValimpI+DBC->DBC_VLIMPI
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPI
									EndIf
									If ACPOIMP[_D1_BASIMPJ]
										nValBasJ:= nValBasJ+DBC->DBC_BSIMPJ
										nValimpJ:= nValimpJ+DBC->DBC_VLIMPJ
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPJ
									EndIf
									If ACPOIMP[_D1_BASIMPK]
										nValBasK:= nValBasK+DBC->DBC_BSIMPK
										nValimpK:= nValimpK+DBC->DBC_VLIMPK
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPK
									EndIf
									If ACPOIMP[_D1_BASIMPL]
										nValBasL:= nValBasL+DBC->DBC_BSIMPL
										nValimpL:= nValimpL+DBC->DBC_VLIMPL
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPL
									EndIf
									If ACPOIMP[_D1_BASIMPM]
										nValBasM:= nValBasM+DBC->DBC_BSIMPM
										nValimpM:= nValimpM+DBC->DBC_VLIMPM
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPM
									EndIf
									If ACPOIMP[_D1_BASIMPN]
										nValBasN:= nValBasN+DBC->DBC_BSIMPN
										nValimpN:= nValimpN+DBC->DBC_VLIMPN
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPN
									EndIf
									If ACPOIMP[_D1_BASIMPO]
										nValBasO:= nValBasO+DBC->DBC_BSIMPO
										nValimpO:= nValimpO+DBC->DBC_VLIMPO
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPO
									EndIf
									If ACPOIMP[_D1_BASIMPP]
										nValBasP:= nValBasP+DBC->DBC_BSIMPP
										nValimpP:= nValimpP+DBC->DBC_VLIMPP
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPP
									EndIf
									If ACPOIMP[_D1_BASIMPQ]
										nValBasQ:= nValBasQ+DBC->DBC_BSIMPQ
										nValimpQ:= nValimpQ+DBC->DBC_VLIMPQ
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPQ
									EndIf
									If ACPOIMP[_D1_BASIMPR]
										nValBasR:= nValBasR+DBC->DBC_BSIMPR
										nValimpR:= nValimpR+DBC->DBC_VLIMPR
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPR
									EndIf
									If ACPOIMP[_D1_BASIMPS]
										nValBasS:= nValBasS+DBC->DBC_BSIMPS
										nValimpS:= nValimpS+DBC->DBC_VLIMPS
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPS
									EndIf
									If ACPOIMP[_D1_BASIMPT]
										nValBasT:= nValBasT+DBC->DBC_BSIMPT
										nValimpT:= nValimpT+DBC->DBC_VLIMPT
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPT
									EndIf
									If ACPOIMP[_D1_BASIMPU]
										nValBasU:= nValBasU+DBC->DBC_BSIMPU
										nValimpU:= nValimpU+DBC->DBC_VLIMPU
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPU
									EndIf
									If ACPOIMP[_D1_BASIMPV]
										nValBasV:= nValBasV+DBC->DBC_BSIMPV
										nValimpV:= nValimpV+DBC->DBC_VLIMPV
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPV
									EndIf
									If ACPOIMP[_D1_BASIMPW]
										nValBasW:= nValBasW+DBC->DBC_BSIMPW
										nValimpW:= nValimpW+DBC->DBC_VLIMPW
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPW
									EndIf
									If ACPOIMP[_D1_BASIMPX]
										nValBasX:= nValBasX+DBC->DBC_BSIMPX
										nValimpX:= nValimpX+DBC->DBC_VLIMPX
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPX
									EndIf
									If ACPOIMP[_D1_BASIMPY]
										nValBasY:= nValBasy+DBC->DBC_BSIMPY
										nValimpY:= nValimpy+DBC->DBC_VLIMPY
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPY
									EndIf
									If ACPOIMP[_D1_BASIMPZ]
										nValBasz:= nValBasz+DBC->DBC_BSIMPZ
										nValimpZ:= nValimpZ+DBC->DBC_VLIMPZ
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPZ
									EndIf
								EndIf
							EndIf
							dbSelectArea("DBC")
							dbSkip()
						EndDo

						If lEnd
							Exit
						EndIf

					EndIf

						aAdd(aCabs, {"F1_FILIAL " , xFilial('SF1')  ,  Nil})
						aAdd(aCabs, {"F1_TIPO"    , "N"             ,  Nil})
						aAdd(aCabs, {"F1_FORMUL"  , "N"             ,  Nil})
						aAdd(aCabs, {"F1_DOC"     , cNumNF          ,  Nil})
						aAdd(aCabs, {"F1_SERIE"   , cSerie          ,  Nil})
						aAdd(aCabs, {"F1_EMISSAO" , DBB->DBB_EMISSA ,  Nil})
						aAdd(aCabs, {"F1_FORNECE" , DBB->DBB_FORNEC ,  Nil})
						aAdd(aCabs, {"F1_LOJA"    , DBB->DBB_LOJA   ,  Nil})
						aAdd(aCabs, {"F1_ESPECIE" , "NF"            ,  Nil})
						aAdd(aCabs, {"F1_COND"    , DBB->DBB_COND   ,  Nil})
						aAdd(aCabs, {"F1_TIPODOC" , "10"            ,  Nil})
						aAdd(aCabs, {"F1_MOEDA"   , DBB->DBB_MOEDA  ,  Nil})
						aAdd(aCabs, {"F1_TXMOEDA" , DBB->DBB_TXMOED ,  Nil})
						aAdd(aCabs, {"F1_DTDIGIT" , dDataBase       ,  Nil})
						aAdd(aCabs, {"F1_EST"     , "EX"            ,  Nil})
						aAdd(aCabs, {"F1_HAWB"    , DBB->DBB_HAWB   ,  Nil})
						aAdd(aCabs, {"F1_FRETE"   , DBB->DBB_FRETE  ,  Nil})
						aAdd(aCabs, {"F1_DESPESA" , DBB->DBB_DESPES ,  Nil})
						aAdd(aCabs, {"F1_SEGURO"  , DBB->DBB_SEGURO ,  Nil})
						aAdd(aCabs, {"F1_DESCONT" , DBB->DBB_DESCON ,  Nil})
						aAdd(aCabs, {"F1_PESOL"   , nPesoTot  ,  Nil})
						aAdd(aCabs, {"F1_NATUREZ" , DBB->DBB_NATURE ,  Nil})
						aAdd(aCabs, {"F1_VALBRUT" , nTotalNf ,  Nil})
						aAdd(aCabs, {"F1_VALMERC" , nTotalMerc ,  Nil})
						IF  cPaisLoc == "PER"
							aAdd(aCabs, {"F1_NATUREZ" , DBB->DBB_NATURE ,  Nil})
							If DBB->(ColumnPos("DBB_TIPODO")) > 0
								aAdd(aCabs, {"F1_TPDOC", IIf(!Empty(DBB->DBB_TIPODO), DBB->DBB_TIPODO, "01"), Nil})
							EndIf
							If DBB->(ColumnPos("DBB_SERIE2")) > 0
								aAdd(aCabs, {"F1_SERIE2"  ,	DBB->DBB_SERIE2 ,  Nil})
							EndIf
						EndIF
						lProvDom:=iif(cPaisLoc=="PER",ProvDomicil(),.F.)

						If lProvDom
							aAdd(aCabs, {"F1_TPRENTA" ,"01",  Nil})
						Endif
						If cPaisLoc $ "ARG|PAR"
							If DBB->(FieldPos("DBB_PROVEN"))>0 .And. !Empty(DBB->DBB_PROVEN)
								aAdd(aCabs, {"F1_PROVENT" , DBB->DBB_PROVEN ,  Nil})
							EndIf
						EndIf
						If cPaisLoc == "ARG" 
							If  DBB->(FieldPos("DBB_RG1415"))>0 .And. !Empty(DBB->DBB_RG1415)
								aAdd(aCabs, {"F1_RG1415" , DBB->DBB_RG1415 ,  Nil})
							Elseif  !Empty(cSerie)
								aAdd(aCabs, {"F1_RG1415" , SPACE(3) ,  Nil})
							EndIF

							If DBB->(FieldPos("DBB_TPVENT"))>0 .And. !Empty(DBB->DBB_TPVENT)
								aAdd(aCabs, {"F1_TPVENT" , DBB->DBB_TPVENT ,  Nil})
							Elseif SubStr(Alltrim(cSerie),1,1) == "E" .AND. cTipoNFE == "5"
								aAdd(aCabs, {"F1_TPVENT" , "B" ,  Nil})
							EndIf
							
							If DBB->(FieldPos("DBB_NUMDES"))>0 .And. !Empty(DBB->DBB_NUMDES)
								aAdd(aCabs, {"F1_NUMDES" , DBB->DBB_NUMDES ,  Nil})
							EndIf
						EndIf
				Else
						dbSelectArea("DBC")
						If dbSeek(cSeek:=DBB->DBB_FILIAL+DBB->DBB_HAWB+DBB->DBB_ITEM, .F.)

							SF4->(DbsetOrder(1))
							Do While !Eof() .And. IIf(cPaisLoc == "BOL",.T.,Len(ACPOIMP)>0) .And. !lEnd .And. cSeek==DBC_FILIAL+DBC_HAWB+DBC_ITDOC

								aArea := GetArea()
								#IFDEF TOP
									If TcSrvType()<>"AS/400"
									cAliasImp := "IMP"
									lQuery    := .T.

									cQuery := "SELECT FC_INCDUPL, FB_CPOLVRO, FB_CODIGO "
									cQuery += "  FROM " + RetSqlName("SFC")+ " SFC INNER JOIN "
									cQuery += RetSqlName("SFB")+ " SFB ON (SFC.FC_IMPOSTO = SFB.FB_CODIGO AND SFB.D_E_L_E_T_ <> '*' AND SFB.FB_FILIAL = '" + xFilial("SFB") + "') "
									cQuery += " WHERE FC_TES = '" + DBC->DBC_TES + "' AND SFC.D_E_L_E_T_ <> '*' AND SFC.FC_FILIAL = '" + xFilial("SFC") + "'"

									cQuery := ChangeQuery(cQuery)
									dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasImp)

									TcSetField(cAliasImp,"FB_CODIGO","C",5,0)
									EndIf
							#ENDIF
							If SF4->(Dbseek(xFilial("SF4")+DBC->DBC_TES)) .And. SF4->F4_DUPLIC == 'S'
							lGeraDup := .T.
							EndIf

							lSomaMerc:=.T.

							If SF4->F4_AGREG == 'N'
								lSomaMerc:=.F.
							EndIF


							If lSomaMerc
								nTotalMerc := nTotalMerc + DBC->DBC_TOTAL
								nTotalNf := nTotalNf + DBC->DBC_TOTAL - DBC->DBC_VLDESC
							EndIf
							Do While !IMP->(EOF())
								If IMP->FC_INCDUPL = '1'
									If IMP->FB_CPOLVRO $ "1|2|3|4|5|6|7|8|9"
										ValorImp := "DBC->DBC_VLIMP" + IMP->FB_CPOLVRO

										nTotalNf := nTotalNf + &ValorImp
									EndIf
								EndIf
								IMP->(DbSkip())
							EndDo
							dbSelectArea(cAliasImp)
							dbCloseArea()

							RestArea(aArea)
								If cPaisLoc $ "ARG|PAR"
									If ACPOIMP[_D1_BASIMPA]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPA
									EndIf
									If ACPOIMP[_D1_BASIMPB]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPB
									EndIf
									If ACPOIMP[_D1_BASIMPC]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPC
									EndIf
									If ACPOIMP[_D1_BASIMPD]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPD
									EndIf
									If ACPOIMP[_D1_BASIMPE]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPE
									EndIf
									If ACPOIMP[_D1_BASIMPF]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPF
									EndIf
									If ACPOIMP[_D1_BASIMPG]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPG
									EndIf
									If ACPOIMP[_D1_BASIMPH]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPH
									EndIf
									If ACPOIMP[_D1_BASIMPI]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPI
									EndIf
									If ACPOIMP[_D1_BASIMPJ]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPJ
									EndIf
									If ACPOIMP[_D1_BASIMPK]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPK
									EndIf
									If ACPOIMP[_D1_BASIMPL]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPL
									EndIf
									If ACPOIMP[_D1_BASIMPM]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPM
									EndIf
									If ACPOIMP[_D1_BASIMPN]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPN
									EndIf
									If ACPOIMP[_D1_BASIMPO]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPO
									EndIf
									If ACPOIMP[_D1_BASIMPP]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPP
									EndIf
									If ACPOIMP[_D1_BASIMPQ]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPQ
									EndIf
									If ACPOIMP[_D1_BASIMPR]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPR
									EndIf
									If ACPOIMP[_D1_BASIMPS]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPS
									EndIf
									If ACPOIMP[_D1_BASIMPT]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPT
									EndIf
									If ACPOIMP[_D1_BASIMPU]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPU
									EndIf
									If ACPOIMP[_D1_BASIMPV]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPV
									EndIf
									If ACPOIMP[_D1_BASIMPW]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPW
									EndIf
									If ACPOIMP[_D1_BASIMPX]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPX
									EndIf
									If ACPOIMP[_D1_BASIMPY]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPY
									EndIf
									If ACPOIMP[_D1_BASIMPZ]
										nTotalNf:= nTotalNf+DBC->DBC_VLIMPZ
									EndIf
								Endif
								dbSelectArea("DBC")
								dbSkip()
							EndDo
							//SF4->(RestArea(aAreaSF4))
							nMoeda  := DBB->DBB_MOEDA
							TxMoeda := DBB->DBB_TXMOED
							cCondicao := DBB->DBB_COND
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Construcao do aCabs e aItens para as NFEs de Frete, Seguro e Despesas e DUA TIPONF 6,7,A,D³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAdd(aCabs, {"F1_FILIAL " , xFilial('SF1')  ,  Nil})
					aAdd(aCabs, {"F1_TIPO"    , "C"             ,  Nil})
					aAdd(aCabs, {"F1_FORMUL"  , "N"             ,  Nil})
					aAdd(aCabs, {"F1_DOC"     , cNumNF          ,  Nil})
					aAdd(aCabs, {"F1_SERIE"   , cSerie          ,  Nil})
					aAdd(aCabs, {"F1_EMISSAO" , DBB->DBB_EMISSA ,  Nil})
					aAdd(aCabs, {"F1_FORNECE" , DBB->DBB_FORNEC ,  Nil})
					aAdd(aCabs, {"F1_LOJA"    , DBB->DBB_LOJA   ,  Nil})
					aAdd(aCabs, {"F1_ESPECIE" , "NF"            ,  Nil})
					aAdd(aCabs, {"F1_DTDIGIT" , dDataBase       ,  Nil})
					aAdd(aCabs, {"F1_EST"     , "EX"            ,  Nil})
					aAdd(aCabs, {"F1_NATUREZ" , DBB->DBB_NATURE ,  Nil})
					aAdd(aCabs, {"F1_DESPESA" , DBB->DBB_DESPES ,  Nil})
					aAdd(aCabs, {"F1_FRETE"  , DBB->DBB_FRETE ,  Nil})
					aAdd(aCabs, {"F1_SEGURO" , DBB->DBB_SEGURO ,  Nil})
					aAdd(aCabs, {"F1_VALBRUT" , nTotalNf ,  Nil})
					aAdd(aCabs, {"F1_VALMERC" , nTotalMerc ,  Nil})
					If DBB->DBB_TIPONF $ "67D" // Frete // Seguro // DUA
						aAdd(aCabs, {"F1_TIPODOC" , "14"        ,  Nil})
					Else // "A" Despesas
						aAdd(aCabs, {"F1_TIPODOC" , "13"        ,  Nil})
					EndIf
					aAdd(aCabs, {"F1_HAWB"    , DBB->DBB_HAWB   ,  Nil})
					aAdd(aCabs, {"F1_PESOL"   , DBB->DBB_PESOL  ,  Nil})
					If cPaisLoc == "BOL"
						If DBB->(FieldPos("DBB_CODCTR"))>0 .And. SF1->(FieldPos("F1_CODCTR"))>0 .And. !Empty(DBB->DBB_CODCTR)
							aAdd(aCabs, {"F1_CODCTR" , DBB->DBB_CODCTR ,  Nil})
						EndIf
					EndIf
					If DBB->(FieldPos("DBB_NUMAUT"))>0 .And. SF1->(FieldPos("F1_NUMAUT"))>0 .And. !Empty(DBB->DBB_NUMAUT)
						aAdd(aCabs, {"F1_NUMAUT" , DBB->DBB_NUMAUT ,  Nil})
					EndIf
					aAdd(aCabs, {"F1_COND"    , DBB->DBB_COND   ,  Nil})
					aAdd(aCabs, {"F1_MOEDA"   , DBB->DBB_MOEDA  ,  Nil})
					aAdd(aCabs, {"F1_TXMOEDA" , DBB->DBB_TXMOED ,  Nil})
						If DBB->DBB_TIPONF $ "A|6|7" .And. cPaisloc$"ARG|PAR"
						aAdd(aCabs, {"F1_DESCONT" , DBB->DBB_DESCON ,  Nil})
					EndIf
					lProvDom:=iif(cPaisLoc=="PER",ProvDomicil(),.F.)

					If lProvDom
						aAdd(aCabs, {"F1_TPRENTA" ,"01",  Nil})
					Endif
					If DBB->(FieldPos("DBB_FORNEC"))>0 .and. DBB->(FieldPos("DBB_PROVEN"))>0 .And. !Empty(DBB->DBB_FORNEC)
						aAdd(aCabs, {"F1_PROVENT" , DBB->DBB_PROVEN ,  Nil})
					EndIf
					If cPaisLoc == "ARG"
						If DBB->(FieldPos("DBB_RG1415"))>0 .And. !Empty(DBB->DBB_RG1415)
							aAdd(aCabs, {"F1_RG1415" , DBB->DBB_RG1415 ,  Nil})
						Elseif !Empty(cSerie)
							aAdd(aCabs, {"F1_RG1415" , SPACE(3) ,  Nil})
						EndIF

						If DBB->(FieldPos("DBB_TPVENT"))>0 .And. !Empty(DBB->DBB_TPVENT)
							aAdd(aCabs, {"F1_TPVENT" , DBB->DBB_TPVENT ,  Nil})
						EndIf

						If DBB->(FieldPos("DBB_NUMDES"))>0 .And. !Empty(DBB->DBB_NUMDES)
							aAdd(aCabs, {"F1_NUMDES" , DBB->DBB_NUMDES ,  Nil})
						EndIf
					EndIf
					For nY := 1 to Len(aCols1)
						If (cPaisLoc<>"BOL".and. aCols1[nY][nPosTipo] $ If( cTipoNFE $ "67D" , "5" , "5|8|A" )) .Or.  ;
								(cPaisLoc=="BOL" .and. aCols1[nY][nPosTipo] $  If( cTipoNFE $ "67D" , "5|8" , "5|8|A" ))
							SF1->(dbSetOrder(1))
							If SF1->(MsSeek(xFilial("SF1")+aCols1[nY][nPosNota]+aCols1[nY][nPosSerie]+aCols1[nY][nPosFornec]+aCols1[nY][nPosLoja]+"N"))
								aadd(aRecsSF1,("SF1")->(RecNo()))
							EndIf
						EndIf
					Next nY
					If cPaisLoc == "EQU"
						aAdd(aCabs, {"F1_NUMREF", DBA->DBA_NUMREF,  Nil})
					EndIf
					EndIf
					aTesValRat := {}
					dbSelectArea("DBC")
					If MsSeek(cSeek:=DBB->DBB_FILIAL+DBB->DBB_HAWB+DBB->DBB_ITEM, .F.)
							If cPaisLoc $ "ARG|PAR|COL|PER|EQU"
								nValBas1 := 0
								nValimp1 := 0
								nValBas2 := 0
								nValimp2 := 0
								nValBas3 := 0
								nValimp3 := 0
								nValBas4 := 0
								nValimp4 := 0
								nValBas5 := 0
								nValimp5 := 0
								nValBas6 := 0
								nValimp6 := 0
								nValBas7 := 0
								nValimp7 := 0
								nValBas8 := 0
								nValimp8 := 0
								nValBas9 := 0
								nValimp9 := 0
								nValBasA := 0
								nValimpA := 0
								nValBasB := 0
								nValimpB := 0
								nValBasC := 0
								nValimpC := 0
								nValBasD := 0
								nValimpD := 0
								nValBasE := 0
								nValimpE := 0
								nValBasF := 0
								nValimpF := 0
								nValBasG := 0
								nValimpG := 0
								nValBasH := 0
								nValimpH := 0
								nValBasI := 0
								nValimpI := 0
								nValBasJ := 0
								nValimpJ := 0
								nValBasK := 0
								nValimpK := 0
								nValBasL := 0
								nValimpL := 0
								nValBasM := 0
								nValimpM := 0
								nValBasN := 0
								nValimpN := 0
								nValBasO := 0
								nValimpO := 0
								nValBasP := 0
								nValimpP := 0
								nValBasQ := 0
								nValimpQ := 0
								nValBasR := 0
								nValimpR := 0
								nValBasS := 0
								nValimpS := 0
								nValBasT := 0
								nValimpT := 0
								nValBasU := 0
								nValimpU := 0
								nValBasV := 0
								nValimpV := 0
								nValBasW := 0
								nValimpW := 0
								nValBasX := 0
								nValimpX := 0
								nValBasY := 0
								nValimpY := 0
								nValBasZ := 0
								nValimpZ := 0
							EndIf
						Do While !Eof() .And. !lEnd .And. cSeek==DBC_FILIAL+DBC_HAWB+DBC_ITDOC
							nValDesp += DBC->DBC_TOTAL
							cTesDesp := DBC->DBC_TES

							//Cria Totalização por Tes //
							nPosTesRat:=aScan(aTesValRat,{|x| x[1] == cTesDesp})
							If nPosTesRat == 0
									aadd(aTesValRat,{cTesDesp, DBC->DBC_TOTAL, DBC->DBC_VLDESC,{}})
									If cPaisLoc $ "ARG|PAR|COL|PER|EQU|BOL"
										aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMP1,DBC->DBC_ALIMP1,DBC->DBC_VLIMP1})
										nValBas1:= nValBas1+DBC->DBC_BSIMP1
										nValimp1:= nValimp1+DBC->DBC_VLIMP1
										aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMP2,DBC->DBC_ALIMP2,DBC->DBC_VLIMP2})
										nValBas2:= nValBas2+DBC->DBC_BSIMP2
										nValimp2:= nValimp2+DBC->DBC_VLIMP2
										aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMP3,DBC->DBC_ALIMP3,DBC->DBC_VLIMP3})
										nValBas3:= nValBas3+DBC->DBC_BSIMP3
										nValimp3:= nValimp3+DBC->DBC_VLIMP3
										aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMP4,DBC->DBC_ALIMP4,DBC->DBC_VLIMP4})
										nValBas4:= nValBas4+DBC->DBC_BSIMP4
										nValimp4:= nValimp4+DBC->DBC_VLIMP4
										aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMP5,DBC->DBC_ALIMP5,DBC->DBC_VLIMP5})
										nValBas5:= nValBas5+DBC->DBC_BSIMP5
										nValimp5:= nValimp5+DBC->DBC_VLIMP5
										aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMP6,DBC->DBC_ALIMP6,DBC->DBC_VLIMP6})
										nValBas6:= nValBas6+DBC->DBC_BSIMP6
										nValimp6:= nValimp6+DBC->DBC_VLIMP6
										aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMP7,DBC->DBC_ALIMP7,DBC->DBC_VLIMP7})
										nValBas7:= nValBas7+DBC->DBC_BSIMP7
										nValimp7:= nValimp7+DBC->DBC_VLIMP7
										aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMP8,DBC->DBC_ALIMP8,DBC->DBC_VLIMP8})
										nValBas8:= nValBas8+DBC->DBC_BSIMP8
										nValimp8:= nValimp8+DBC->DBC_VLIMP8
										aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMP9,DBC->DBC_ALIMP9,DBC->DBC_VLIMP9})
										nValBas9:= nValBas9+DBC->DBC_BSIMP9
										nValimp9:= nValimp9+DBC->DBC_VLIMP9
										If cPaisLoc $ "ARG|PAR"
										If ACPOIMP[_D1_BASIMPA]       //10
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPA,DBC->DBC_ALIMPA,DBC->DBC_VLIMPA})
											nValBasA:= nValBasA+DBC->DBC_BSIMPA
											nValimpA:= nValimpA+DBC->DBC_VLIMPA
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPB]           //11
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPB,DBC->DBC_ALIMPB,DBC->DBC_VLIMPB})
											nValBasB:= nValBasB+DBC->DBC_BSIMPB
											nValimpB:= nValimpB+DBC->DBC_VLIMPB
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPC]               //12
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPC,DBC->DBC_ALIMPC,DBC->DBC_VLIMPC})
											nValBasC:= nValBasC+DBC->DBC_BSIMPC
											nValimpC:= nValimpC+DBC->DBC_VLIMPC
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPD]//13
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPD,DBC->DBC_ALIMPD,DBC->DBC_VLIMPD})
											nValBasD:= nValBasD+DBC->DBC_BSIMPD
											nValimpD:= nValimpD+DBC->DBC_VLIMPD
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPE]//14
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPE,DBC->DBC_ALIMPE,DBC->DBC_VLIMPE})
											nValBasE:= nValBasE+DBC->DBC_BSIMPE
											nValimpE:= nValimpE+DBC->DBC_VLIMPE
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPF]//15
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPF,DBC->DBC_ALIMPF,DBC->DBC_VLIMPF})
											nValBasF:= nValBasF+DBC->DBC_BSIMPF
											nValimpF:= nValimpF+DBC->DBC_VLIMPF
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPG]//16
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPG,DBC->DBC_ALIMPG,DBC->DBC_VLIMPG})
											nValBasG:= nValBasG+DBC->DBC_BSIMPG
											nValimpG:= nValimpG+DBC->DBC_VLIMPG
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPH]//17
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPH,DBC->DBC_ALIMPH,DBC->DBC_VLIMPH})
											nValBasH:= nValBasH+DBC->DBC_BSIMPH
											nValimpH:= nValimpH+DBC->DBC_VLIMPH
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPI]//18
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPI,DBC->DBC_ALIMPI,DBC->DBC_VLIMPI})
											nValBasI:= nValBasI+DBC->DBC_BSIMPI
											nValimpI:= nValimpI+DBC->DBC_VLIMPI
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPJ]//19
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPJ,DBC->DBC_ALIMPJ,DBC->DBC_VLIMPJ})
											nValBasJ:= nValBasJ+DBC->DBC_BSIMPJ
											nValimpJ:= nValimpJ+DBC->DBC_VLIMPJ
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPK]//20
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPK,DBC->DBC_ALIMPK,DBC->DBC_VLIMPK})
											nValBasK:= nValBasK+DBC->DBC_BSIMPK
											nValimpK:= nValimpK+DBC->DBC_VLIMPK
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPL]//21
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPL,DBC->DBC_ALIMPL,DBC->DBC_VLIMPL})
											nValBasL:= nValBasL+DBC->DBC_BSIMPL
											nValimpL:= nValimpL+DBC->DBC_VLIMPL
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPM]//22
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPM,DBC->DBC_ALIMPM,DBC->DBC_VLIMPM})
											nValBasM:= nValBasM+DBC->DBC_BSIMPM
											nValimpM:= nValimpM+DBC->DBC_VLIMPM
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPN]//23
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPN,DBC->DBC_ALIMPN,DBC->DBC_VLIMPN})
											nValBasN:= nValBasN+DBC->DBC_BSIMPN
											nValimpN:= nValimpN+DBC->DBC_VLIMPN
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPO]//24
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPO,DBC->DBC_ALIMPO,DBC->DBC_VLIMPO})
											nValBasO:= nValBasO+DBC->DBC_BSIMPO
											nValimpO:= nValimpO+DBC->DBC_VLIMPO
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPP]//25
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPP,DBC->DBC_ALIMPP,DBC->DBC_VLIMPP})
											nValBasP:= nValBasP+DBC->DBC_BSIMPP
											nValimpP:= nValimpP+DBC->DBC_VLIMPP
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPQ]//26
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPQ,DBC->DBC_ALIMPQ,DBC->DBC_VLIMPQ})
											nValBasQ:= nValBasQ+DBC->DBC_BSIMPQ
											nValimpQ:= nValimpQ+DBC->DBC_VLIMPQ
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPR]//27
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPR,DBC->DBC_ALIMPR,DBC->DBC_VLIMPR})
											nValBasR:= nValBasR+DBC->DBC_BSIMPR
											nValimpR:= nValimpR+DBC->DBC_VLIMPR
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPS]//28
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPS,DBC->DBC_ALIMPS,DBC->DBC_VLIMPS})
											nValBasS:= nValBasS+DBC->DBC_BSIMPS
											nValimpS:= nValimpS+DBC->DBC_VLIMPS
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf

										If ACPOIMP[_D1_BASIMPT]//29
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPT,DBC->DBC_ALIMPT,DBC->DBC_VLIMPT})
											nValBasT:= nValBasT+DBC->DBC_BSIMPT
											nValimpT:= nValimpT+DBC->DBC_VLIMPT
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf

										If ACPOIMP[_D1_BASIMPU]    //30
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPU,DBC->DBC_ALIMPU,DBC->DBC_VLIMPU})
											nValBasU:= nValBasU+DBC->DBC_BSIMPU
											nValimpU:= nValimpU+DBC->DBC_VLIMPU
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf

										If ACPOIMP[_D1_BASIMPV]//31
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPV,DBC->DBC_ALIMPV,DBC->DBC_VLIMPV})
											nValBasV:= nValBasV+DBC->DBC_BSIMPV
											nValimpV:= nValimpV+DBC->DBC_VLIMPV
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf

										If ACPOIMP[_D1_BASIMPW]//32
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPW,DBC->DBC_ALIMPW,DBC->DBC_VLIMPW})
											nValBasW:= nValBasW+DBC->DBC_BSIMPW
											nValimpW:= nValimpW+DBC->DBC_VLIMPW
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf

										If ACPOIMP[_D1_BASIMPX]//33
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPX,DBC->DBC_ALIMPX,DBC->DBC_VLIMPX})
											nValBasX:= nValBasX+DBC->DBC_BSIMPX
											nValimpX:= nValimpX+DBC->DBC_VLIMPX
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPY]//34
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPY,DBC->DBC_ALIMPY,DBC->DBC_VLIMPY})
											nValBasY:= nValBasY+DBC->DBC_BSIMPY
											nValimpY:= nValimpY+DBC->DBC_VLIMPY
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										If ACPOIMP[_D1_BASIMPZ]    //35
											aadd(aTesValRat[Len(aTesValRat)][4],{DBC->DBC_BSIMPZ,DBC->DBC_ALIMPZ,DBC->DBC_VLIMPZ})
											nValBasz:=nValBasz+DBC->DBC_BSIMPZ
											nValimpZ:=nValimpZ+DBC->DBC_VLIMPZ
										Else
											aadd(aTesValRat[Len(aTesValRat)][4],{0,0,0})
										EndIf
										EndIf
									EndIf
							Else
								aTesValRat[nPosTesRat][2]:=aTesValRat[nPosTesRat][2]+DBC->DBC_TOTAL
								aTesValRat[nPosTesRat][3]:=aTesValRat[nPosTesRat][3]+DBC->DBC_VLDESC
								If cPaisLoc $ "ARG|PAR|COL|PER|EQU|BOL"
									aTesValRat[nPosTesRat][4][1][1]+=DBC->DBC_BSIMP1
									aTesValRat[nPosTesRat][4][1][3]+=DBC->DBC_VLIMP1
								EndIf
								nValBas1+=DBC->DBC_BSIMP1
								nValimp1+=DBC->DBC_VLIMP1
								If cPaisLoc $ "ARG|PAR|COL|PER|EQU|BOL"
									aTesValRat[nPosTesRat][4][2][1]+=DBC->DBC_BSIMP2
									aTesValRat[nPosTesRat][4][2][3]+=DBC->DBC_VLIMP2
								EndIf
								nValBas2+=DBC->DBC_BSIMP2
								nValimp2+=DBC->DBC_VLIMP2
								If cPaisLoc $ "ARG|PAR|COL|PER|EQU|BOL"
									aTesValRat[nPosTesRat][4][3][1]+=DBC->DBC_BSIMP3
									aTesValRat[nPosTesRat][4][3][3]+=DBC->DBC_VLIMP3
								EndIf
								nValBas3+=DBC->DBC_BSIMP3
								nValimp3+=DBC->DBC_VLIMP3
								If cPaisLoc $ "ARG|PAR|COL|PER|EQU|BOL"
									aTesValRat[nPosTesRat][4][4][1]+=DBC->DBC_BSIMP4
									aTesValRat[nPosTesRat][4][4][3]+=DBC->DBC_VLIMP4
								EndIf
								nValBas4+=DBC->DBC_BSIMP4
								nValimp4+=DBC->DBC_VLIMP4
								If cPaisLoc $ "ARG|PAR|COL|PER|EQU|BOL"
									aTesValRat[nPosTesRat][4][5][1]+=DBC->DBC_BSIMP5
									aTesValRat[nPosTesRat][4][5][3]+=DBC->DBC_VLIMP5
								EndIf
								nValBas5+=DBC->DBC_BSIMP5
								nValimp5+=DBC->DBC_VLIMP5
								If cPaisLoc $ "ARG|PAR|COL|PER|EQU|BOL"
									aTesValRat[nPosTesRat][4][6][1]+=DBC->DBC_BSIMP6
									aTesValRat[nPosTesRat][4][6][3]+=DBC->DBC_VLIMP6
								EndIf
									nValBas6+=DBC->DBC_BSIMP6
									nValimp6+=DBC->DBC_VLIMP6
								If cPaisLoc $ "ARG|PAR|COL|PER|EQU|BOL"
									aTesValRat[nPosTesRat][4][7][1]+=DBC->DBC_BSIMP7
									aTesValRat[nPosTesRat][4][7][3]+=DBC->DBC_VLIMP7
								EndIF
								nValBas7+=DBC->DBC_BSIMP7
								nValimp7+=DBC->DBC_VLIMP7
								If cPaisLoc $ "ARG|PAR|COL|PER|EQU|BOL"
									aTesValRat[nPosTesRat][4][8][1]+=DBC->DBC_BSIMP8
									aTesValRat[nPosTesRat][4][8][3]+=DBC->DBC_VLIMP8
								EndIf
								nValBas8+=DBC->DBC_BSIMP8
								nValimp8+=DBC->DBC_VLIMP8
								If cPaisLoc $ "ARG|PAR|COL|PER|EQU|BOL"
									aTesValRat[nPosTesRat][4][9][1]+=DBC->DBC_BSIMP9
									aTesValRat[nPosTesRat][4][9][3]+=DBC->DBC_VLIMP9
								EndIf
								nValBas9+=DBC->DBC_BSIMP9
								nValimp9+=DBC->DBC_VLIMP9

								If cPaisLoc $ "ARG|PAR"
									If ACPOIMP[_D1_BASIMPA]//10
										aTesValRat[nPosTesRat][4][10][1]+=DBC->DBC_BSIMPA
										aTesValRat[nPosTesRat][4][10][3]+=DBC->DBC_VLIMPA
										nValBasA:= nValBasA+DBC->DBC_BSIMPA
										nValimpA:= nValimpA+DBC->DBC_VLIMPA
									EndIF
									If ACPOIMP[_D1_BASIMPB]//11
										aTesValRat[nPosTesRat][4][11][1]+=DBC->DBC_BSIMPB
										aTesValRat[nPosTesRat][4][11][3]+=DBC->DBC_VLIMPB
										nValBasB:= nValBasB+DBC->DBC_BSIMPB
										nValimpB:= nValimpB+DBC->DBC_VLIMPB
									EndIf
									If ACPOIMP[_D1_BASIMPC]//12
										aTesValRat[nPosTesRat][4][12][1]+=DBC->DBC_BSIMPC
										aTesValRat[nPosTesRat][4][12][3]+=DBC->DBC_VLIMPC
										nValBasC:= nValBasC+DBC->DBC_BSIMPC
										nValimpC:= nValimpC+DBC->DBC_VLIMPC
									EndIf
									If ACPOIMP[_D1_BASIMPD]//13
										aTesValRat[nPosTesRat][4][13][1]+=DBC->DBC_BSIMPD
										aTesValRat[nPosTesRat][4][13][3]+=DBC->DBC_VLIMPD
										nValBasD:= nValBasD+DBC->DBC_BSIMPD
										nValimpD:= nValimpD+DBC->DBC_VLIMPD
									EndIf
									If ACPOIMP[_D1_BASIMPE]//14
										aTesValRat[nPosTesRat][4][14][1]+=DBC->DBC_BSIMPE
										aTesValRat[nPosTesRat][4][14][3]+=DBC->DBC_VLIMPE
										nValBasE:= nValBasE+DBC->DBC_BSIMPE
										nValimpE:= nValimpE+DBC->DBC_VLIMPE
									EndIf
									If ACPOIMP[_D1_BASIMPF]//15
										aTesValRat[nPosTesRat][4][15][1]+=DBC->DBC_BSIMPF
										aTesValRat[nPosTesRat][4][15][3]+=DBC->DBC_VLIMPF
										nValBasF:= nValBasF+DBC->DBC_BSIMPF
										nValimpF:= nValimpF+DBC->DBC_VLIMPF
									EndIf
									If ACPOIMP[_D1_BASIMPG]//16
										aTesValRat[nPosTesRat][4][16][1]+=DBC->DBC_BSIMPG
										aTesValRat[nPosTesRat][4][16][3]+=DBC->DBC_VLIMPG
										nValBasG:= nValBasG+DBC->DBC_BSIMPG
										nValimpG:= nValimpG+DBC->DBC_VLIMPG
									EndIf
									If ACPOIMP[_D1_BASIMPH]//17
										aTesValRat[nPosTesRat][4][17][1]+=DBC->DBC_BSIMPH
										aTesValRat[nPosTesRat][4][17][3]+=DBC->DBC_VLIMPH
										nValBasH:= nValBasH+DBC->DBC_BSIMPH
										nValimpH:= nValimpH+DBC->DBC_VLIMPH
									EndIf
									If ACPOIMP[_D1_BASIMPI]//18
										aTesValRat[nPosTesRat][4][18][1]+=DBC->DBC_BSIMPI
										aTesValRat[nPosTesRat][4][18][3]+=DBC->DBC_VLIMPI
										nValBasI:= nValBasI+DBC->DBC_BSIMPI
										nValimpI:= nValimpI+DBC->DBC_VLIMPI
									EndIf
									If ACPOIMP[_D1_BASIMPJ]//19
										aTesValRat[nPosTesRat][4][19][1]+=DBC->DBC_BSIMPJ
										aTesValRat[nPosTesRat][4][19][3]+=DBC->DBC_VLIMPJ
										nValBasJ:= nValBasJ+DBC->DBC_BSIMPJ
										nValimpJ:= nValimpJ+DBC->DBC_VLIMPJ
									EndIf
									If ACPOIMP[_D1_BASIMPK]//20
										aTesValRat[nPosTesRat][4][20][1]+=DBC->DBC_BSIMPK
										aTesValRat[nPosTesRat][4][20][3]+=DBC->DBC_VLIMPK
										nValBasK:= nValBasK+DBC->DBC_BSIMPK
										nValimpK:= nValimpK+DBC->DBC_VLIMPK
									EndIf
									If ACPOIMP[_D1_BASIMPL]//21
										aTesValRat[nPosTesRat][4][21][1]+=DBC->DBC_BSIMPL
										aTesValRat[nPosTesRat][4][21][3]+=DBC->DBC_VLIMPL
										nValBasL:= nValBasL+DBC->DBC_BSIMPL
										nValimpL:= nValimpL+DBC->DBC_VLIMPL
									EndIf
									If ACPOIMP[_D1_BASIMPM]//22
										aTesValRat[nPosTesRat][4][22][1]+=DBC->DBC_BSIMPM
										aTesValRat[nPosTesRat][4][22][3]+=DBC->DBC_VLIMPM
										nValBasM:= nValBasM+DBC->DBC_BSIMPM
										nValimpM:= nValimpM+DBC->DBC_VLIMPM
									EndIf
									If ACPOIMP[_D1_BASIMPN]//23
										aTesValRat[nPosTesRat][4][23][1]+=DBC->DBC_BSIMPN
										aTesValRat[nPosTesRat][4][23][3]+=DBC->DBC_VLIMPN
										nValBasN:= nValBasN+DBC->DBC_BSIMPN
										nValimpN:= nValimpN+DBC->DBC_VLIMPN
									EndIf
									If ACPOIMP[_D1_BASIMPO]//24
										aTesValRat[nPosTesRat][4][24][1]+=DBC->DBC_BSIMPO
										aTesValRat[nPosTesRat][4][24][3]+=DBC->DBC_VLIMPO
										nValBasO:= nValBasO+DBC->DBC_BSIMPO
										nValimpO:= nValimpO+DBC->DBC_VLIMPO
									EndIf
									If ACPOIMP[_D1_BASIMPP]//25
										aTesValRat[nPosTesRat][4][25][1]+=DBC->DBC_BSIMPP
										aTesValRat[nPosTesRat][4][25][3]+=DBC->DBC_VLIMPP
										nValBasP:= nValBasP+DBC->DBC_BSIMPP
										nValimpP:= nValimpP+DBC->DBC_VLIMPP
									EndIF
									If ACPOIMP[_D1_BASIMPQ]//26
										aTesValRat[nPosTesRat][4][26][1]+=DBC->DBC_BSIMPQ
										aTesValRat[nPosTesRat][4][26][3]+=DBC->DBC_VLIMPQ
										nValBasQ:= nValBasQ+DBC->DBC_BSIMPQ
										nValimpQ:= nValimpQ+DBC->DBC_VLIMPQ
									EndIf
									If ACPOIMP[_D1_BASIMPR]//27
										aTesValRat[nPosTesRat][4][27][1]+=DBC->DBC_BSIMPR
										aTesValRat[nPosTesRat][4][27][3]+=DBC->DBC_VLIMPR
										nValBasR:= nValBasR+DBC->DBC_BSIMPR
										nValimpR:= nValimpR+DBC->DBC_VLIMPR
									EndIf
									If ACPOIMP[_D1_BASIMPS]//28
										aTesValRat[nPosTesRat][4][28][1]+=DBC->DBC_BSIMPS
										aTesValRat[nPosTesRat][4][28][3]+=DBC->DBC_VLIMPS
										nValBasS:= nValBasS+DBC->DBC_BSIMPS
										nValimpS:= nValimpS+DBC->DBC_VLIMPS
									EndIf
									If ACPOIMP[_D1_BASIMPT]//29
										aTesValRat[nPosTesRat][4][29][1]+=DBC->DBC_BSIMPT
										aTesValRat[nPosTesRat][4][29][3]+=DBC->DBC_VLIMPT
										nValBasT:= nValBasT+DBC->DBC_BSIMPT
										nValimpT:= nValimpT+DBC->DBC_VLIMPT
									EndIf
									If ACPOIMP[_D1_BASIMPU]    //30
										aTesValRat[nPosTesRat][4][30][1]+=DBC->DBC_BSIMPU
										aTesValRat[nPosTesRat][4][30][3]+=DBC->DBC_VLIMPU
										nValBasU:= nValBasU+DBC->DBC_BSIMPU
										nValimpU:= nValimpU+DBC->DBC_VLIMPU
									EndIf
									If ACPOIMP[_D1_BASIMPV]//31
										aTesValRat[nPosTesRat][4][31][1]+=DBC->DBC_BSIMPV
										aTesValRat[nPosTesRat][4][31][3]+=DBC->DBC_VLIMPV
										nValBasV:= nValBasV+DBC->DBC_BSIMPV
										nValimpV:= nValimpV+DBC->DBC_VLIMPV
									EndIf
									If ACPOIMP[_D1_BASIMPW]//32
										aTesValRat[nPosTesRat][4][32][1]+=DBC->DBC_BSIMPW
										aTesValRat[nPosTesRat][4][32][3]+=DBC->DBC_VLIMPW
										nValBasW:= nValBasW+DBC->DBC_BSIMPW
										nValimpW:= nValimpW+DBC->DBC_VLIMPW
									EndIf
									If ACPOIMP[_D1_BASIMPX]//33
										aTesValRat[nPosTesRat][4][33][1]+=DBC->DBC_BSIMPX
										aTesValRat[nPosTesRat][4][33][3]+=DBC->DBC_VLIMPX
										nValBasX:= nValBasX+DBC->DBC_BSIMPX
										nValimpX:= nValimpX+DBC->DBC_VLIMPX
									EndIf
									If ACPOIMP[_D1_BASIMPY]//34
										aTesValRat[nPosTesRat][4][34][1]+=DBC->DBC_BSIMPY
										aTesValRat[nPosTesRat][4][34][3]+=DBC->DBC_VLIMPY
										nValBasY:= nValBasY+DBC->DBC_BSIMPY
										nValimpY:= nValimpY+DBC->DBC_VLIMPY
									EndIf
									If ACPOIMP[_D1_BASIMPZ]    //35
										aTesValRat[nPosTesRat][4][35][1]+=DBC->DBC_BSIMPZ
										aTesValRat[nPosTesRat][4][35][3]+=DBC->DBC_VLIMPZ
										nValBasz:=nValBasz+DBC->DBC_BSIMPZ
										nValimpZ:=nValimpZ+DBC->DBC_VLIMPZ
									EndIf
								EndIf

							EndIf

							dbSelectArea("DBC")
							dbSkip()
						EndDo
					EndIf

					If Len(aRecsSF1)>0
						If Len(aTesValRat)>1
							If !lAutomato
								Aviso("A143MTES",STR0093,{"Ok"},1)
							EndIf
							aItensBKP := {}
							//Rateia os valores de acordo com a Tes //
							For nRat:=1 to Len(aTesValRat)
								If !lAutomato
									oProcess:=MsNewProcess():New({|lEnd| A143RatDesp(cTipoNFE,aRecsSF1,oProcess,@lEnd,aCabs,@aItens,aTesValRat[nRat][2],aTesValRat[nRat][1],cNumNF,cSerie,aTesValRat[nRat][3],aTesValRat[nRat][4])},"Carregando Notas Fiscais de Origem...",,.T.) // "Carregando Notas Fiscais de Origem..."
									oProcess:Activate()
								Else
									A143RatDesp(cTipoNFE,aRecsSF1,oProcess,@lEnd,aCabs,@aItens,aTesValRat[nRat][2],aTesValRat[nRat][1],cNumNF,cSerie,aTesValRat[nRat][3],aTesValRat[nRat][4])
								EndIf
								For nRat1:=1 to Len(aItens)
									aaDD(aItensBKP,aItens[nRat1])
								Next nRat1
								aItens:={}
							Next nRat
							//Ajusta o D1_ITEM e carrega o aItens
							nPosItem:= aScan(aItensBKP[1],{|x|Alltrim(x[1]) == "D1_ITEM" })
							For nRat:=1 to Len(aItensBKP)
								cItem := Soma1(cItem)
								aItensBKP[nRat][nPosItem][2]:=cItem
							Next nRat
							aItens:=aClone(aItensBKP)
						ElseIf Len(aTesValRat)== 1
							If !lAutomato
								nRat:=Len(aTesValRat)
									oProcess:=MsNewProcess():New({|lEnd| A143RatDesp(cTipoNFE,aRecsSF1,oProcess,@lEnd,aCabs,@aItens,nValDesp,cTesDesp,cNumNF,cSerie,aTesValRat[nRat][3],aTesValRat[nRat][4])},"Carregando Notas Fiscais de Origem...",,.T.) // "Carregando Notas Fiscais de Origem..."
								oProcess:Activate()
							Else
								nRat:=Len(aTesValRat)
								A143RatDesp(cTipoNFE,aRecsSF1,oProcess,@lEnd,aCabs,@aItens,nValDesp,cTesDesp,cNumNF,cSerie,aTesValRat[nRat][3],aTesValRat[nRat][4])
							EndIf
						EndIf
					EndIf
				EndIf
				If cPaisLoc $ "ARG|PAR|COL|PER|EQU"
						If nValimp1 > 0
							aAdd(aCabs, {"F1_VALIMP1" , nValimp1 ,  Nil})
							aAdd(aCabs, {"F1_BASIMP1" , nValBas1 ,  Nil})
						EndIf
						If nValimp2 > 0
							aAdd(aCabs, {"F1_VALIMP2" , nValimp2 ,  Nil})
							aAdd(aCabs, {"F1_BASIMP2" , nValBas2 ,  Nil})
						EndIf
						If nValimp3 > 0
							aAdd(aCabs, {"F1_VALIMP3" , nValimp3 ,  Nil})
							aAdd(aCabs, {"F1_BASIMP3" , nValBas3 ,  Nil})
						EndIf
						If nValimp4 > 0
							aAdd(aCabs, {"F1_VALIMP4" , nValimp4 ,  Nil})
							aAdd(aCabs, {"F1_BASIMP4" , nValBas4 ,  Nil})
						EndIf
						If nValimp5 > 0
							aAdd(aCabs, {"F1_VALIMP5" , nValimp5 ,  Nil})
							aAdd(aCabs, {"F1_BASIMP5" , nValBas5 ,  Nil})
						EndIf
						If nValimp6 > 0
							aAdd(aCabs, {"F1_VALIMP6" , nValimp6 ,  Nil})
							aAdd(aCabs, {"F1_BASIMP6" , nValBas6 ,  Nil})
						EndIf
						If nValimp7 > 0
							aAdd(aCabs, {"F1_VALIMP7" , nValimp7 ,  Nil})
							aAdd(aCabs, {"F1_BASIMP7" , nValBas7 ,  Nil})
						EndIf
						If nValimp8 > 0
							aAdd(aCabs, {"F1_VALIMP8" , nValimp8 ,  Nil})
							aAdd(aCabs, {"F1_BASIMP8" , nValBas8 ,  Nil})
						EndIf
						If nValimp9 > 0
							aAdd(aCabs, {"F1_VALIMP9" , nValimp9 ,  Nil})
							aAdd(aCabs, {"F1_BASIMP9" , nValBas9 ,  Nil})
						EndIf
						If cPaisLoc $ "ARG|PAR"
						If nValimpA > 0
							aAdd(aCabs, {"F1_VALIMPA" , nValimpA ,  Nil})
							aAdd(aCabs, {"F1_BASIMPA" , nValBasA ,  Nil})
						EndIf
						If nValimpB > 0
							aAdd(aCabs, {"F1_VALIMPB" , nValimpB ,  Nil})
							aAdd(aCabs, {"F1_BASIMPB" , nValBasB ,  Nil})
						EndIf
						If nValimpC > 0
							aAdd(aCabs, {"F1_VALIMPC" , nValimpC ,  Nil})
							aAdd(aCabs, {"F1_BASIMPC" , nValBasC ,  Nil})
						EndIf
						If nValimpD > 0
							aAdd(aCabs, {"F1_VALIMPD" , nValimpD ,  Nil})
							aAdd(aCabs, {"F1_BASIMPD" , nValBasD ,  Nil})
						EndIf
						If nValimpE > 0
							aAdd(aCabs, {"F1_VALIMPE" , nValimpE ,  Nil})
							aAdd(aCabs, {"F1_BASIMPE" , nValBasE ,  Nil})
						EndIf
						If nValimpF > 0
							aAdd(aCabs, {"F1_VALIMPF" , nValimpF ,  Nil})
							aAdd(aCabs, {"F1_BASIMPF" , nValBasF ,  Nil})
						EndIf
						If nValimpG > 0
							aAdd(aCabs, {"F1_VALIMPG" , nValimpG ,  Nil})
							aAdd(aCabs, {"F1_BASIMPG" , nValBasG ,  Nil})
						EndIf
						If nValimpH > 0
							aAdd(aCabs, {"F1_VALIMPH" , nValimpH ,  Nil})
							aAdd(aCabs, {"F1_BASIMPH" , nValBasH ,  Nil})
						EndIf
						If nValimpI > 0
							aAdd(aCabs, {"F1_VALIMPI" , nValimpI ,  Nil})
							aAdd(aCabs, {"F1_BASIMPI" , nValBasI ,  Nil})
						EndIf
						If nValimpJ > 0
							aAdd(aCabs, {"F1_VALIMPJ" , nValimpJ ,  Nil})
							aAdd(aCabs, {"F1_BASIMPJ" , nValBasJ ,  Nil})
						EndIf
						If nValimpK > 0
							aAdd(aCabs, {"F1_VALIMPK" , nValimpK ,  Nil})
							aAdd(aCabs, {"F1_BASIMPK" , nValBasK ,  Nil})
						EndIf
						If nValimpL > 0
							aAdd(aCabs, {"F1_VALIMPL" , nValimpL ,  Nil})
							aAdd(aCabs, {"F1_BASIMPL" , nValBasL ,  Nil})
						EndIf
						If nValimpM > 0
							aAdd(aCabs, {"F1_VALIMPM" , nValimpM ,  Nil})
							aAdd(aCabs, {"F1_BASIMPM" , nValBasM ,  Nil})
						EndIf
						If nValimpN > 0
							aAdd(aCabs, {"F1_VALIMPN" , nValimpN ,  Nil})
							aAdd(aCabs, {"F1_BASIMPN" , nValBasN ,  Nil})
						EndIf
						If nValimpO > 0
							aAdd(aCabs, {"F1_VALIMPO" , nValimpO ,  Nil})
							aAdd(aCabs, {"F1_BASIMPO" , nValBasO ,  Nil})
						EndIf
						If nValimpP > 0
							aAdd(aCabs, {"F1_VALIMPP" , nValimpP ,  Nil})
							aAdd(aCabs, {"F1_BASIMPP" , nValBasP ,  Nil})
						EndIf
						If nValimpQ > 0
							aAdd(aCabs, {"F1_VALIMPQ" , nValimpQ ,  Nil})
							aAdd(aCabs, {"F1_BASIMPQ" , nValBasQ ,  Nil})
						EndIf
						If nValimpR > 0
							aAdd(aCabs, {"F1_VALIMPR" , nValimpR ,  Nil})
							aAdd(aCabs, {"F1_BASIMPR" , nValBasR ,  Nil})
						EndIf
						If nValimpS > 0
							aAdd(aCabs, {"F1_VALIMPS" , nValimpS ,  Nil})
							aAdd(aCabs, {"F1_BASIMPS" , nValBasS ,  Nil})
						EndIf
						If nValimpT > 0
							aAdd(aCabs, {"F1_VALIMPT" , nValimpT ,  Nil})
							aAdd(aCabs, {"F1_BASIMPT" , nValBasT ,  Nil})
						EndIf
						If nValimpU > 0
							aAdd(aCabs, {"F1_VALIMPU" , nValimpU ,  Nil})
							aAdd(aCabs, {"F1_BASIMPU" , nValBasU ,  Nil})
						EndIf
						If nValimpV > 0
							aAdd(aCabs, {"F1_VALIMPV" , nValimpV ,  Nil})
							aAdd(aCabs, {"F1_BASIMPV" , nValBasV ,  Nil})
						EndIf
						If nValimpW > 0
							aAdd(aCabs, {"F1_VALIMPW" , nValimpW ,  Nil})
							aAdd(aCabs, {"F1_BASIMPW" , nValBasW ,  Nil})
						EndIf
						If nValimpX > 0
							aAdd(aCabs, {"F1_VALIMPX" , nValimpX ,  Nil})
							aAdd(aCabs, {"F1_BASIMPX" , nValBasX ,  Nil})
						EndIf
						If nValimpY > 0
							aAdd(aCabs, {"F1_VALIMPY" , nValimpY ,  Nil})
							aAdd(aCabs, {"F1_BASIMPY" , nValBasY ,  Nil})
						EndIf
						If nValimpZ > 0
							aAdd(aCabs, {"F1_VALIMPZ" , nValimpZ ,  Nil})
							aAdd(aCabs, {"F1_BASIMPZ" , nValBasZ ,  Nil})
						EndIf
					EndIf
				EndIf
				//Ponto de entrada para manipular o cabecalho e os itens antes da execução do MATA101N
				If lM143ITEM
					aItens:= If(ValType(aRet:= ExecBlock("M143ITEM",.F.,.F.,{aItens})) == "A",aRet,aItens)
				EndIf
				If lM143CAB
					aCabs := If(ValType(aRet:= ExecBlock("M143CAB",.F.,.F.,{aCabs})) == "A",aRet,aCabs)
				EndIf

				If lM143TOK
					lContinua := .T.
					lContinua := ExecBlock("M143TODOK",.F.,.F.,{aCabs,aItens,cTipoNFE})
				EndIf

				If !lEnd .And. (Len(aCabs)>0 .And. Len(aItens)>0) .And. lContinua
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Protege a ordem do SC7 para a chamada da Rotina Automatica³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SC7")
					dbSetOrder(1)
					lMSErroAuto := .F.

					MaFisEnd()
						If cPaisLoc $ "ARG|PAR"
							aImpIB2:={}

							If cPaisLoc == 'ARG'
								Pergunte("MTXRED",.F.)
								AEval(aPergunta,{|x,y| AAdd(aPergs,&("MV_PAR"+StrZero(y,2))==1)})
								AAdd(aPergs,.F.)
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Monta array de configuracao da NF ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aCfgNF := MontaCfgNF(nTipo,aPergs,.F.)

							If Empty(aCfgNF)
								Return .F.
							EndIf


							If MaFisFound("NF")
								MaFisEnd()
							EndIf

							MaFisIni('ZZZZZZ','ZZ',"F","N",Nil,Nil,Nil,Nil,Nil,"MATA101N",Nil,Nil,Nil,Nil,Nil,Nil,Nil,)

							cNFiscal:=cNumNF
							acab:={}
							aitem:={}
							aOutros:={}
							aitens1:={}
							aitens2:={}
							nj:= 1
							x:= 1
							For nj:= 1 to len(aCabs)
								Aadd(acab,acabs[nj][1])
								aadd(aItem,acabs[nj][2])
								Aadd(aOutros,acabs[nj][3])
							Next

							For	 na:= 1 to len(aItens[1])
								Aadd(aitens2,aItens[1][na][1])
							Next // campo

							For x:= 1 to len(aItens)
								Aadd(aitens1,{})
								For	 nb:= 1 to len(aItens[x])
									Aadd(aitens1[x],aItens[x][nb][2]) // conteudo
								Next
								Aadd(aitens1[x],.f.) // conteudo
							Next
							nValor := IIF(lGeraDup,nTotalNf,0)
							aVenc	:= Condicao(nValor,cCondicao,0,dDataEmis,0)
							cParcela:= IIF(Len(aVenc)>1,SuperGetMV("MV_1DUP   ")," ")
							aDupl	:={}
							nTotDup:=0
							If  Len(aVenc)==1
								aAdd(aDupl,cNumNF+"³"+cSerie +"³ "+cParcela+" ³";
										+DTOC(aVenc[1][1])+"³ "+Transform(aVenc[1][2],PesqPict("SE2","E2_VALOR")))
										nTotDup := nTotDup + Round(aVenc[1][2],nDecimal)
							Else
								For nc := 1 To Len(aVenc)
									If nc == Len(aVenc) .And. Len(aVenc) > 1
										aAdd(aDupl,cNumNF+"³"+cSerie +"³ "+cParcela+" ³";
										+DTOC(aVenc[nc][1])+"³ "+Transform(NoRound(nValor-nTotDup,nDecimal),PesqPict("SE2","E2_VALOR")))
									Else
										aAdd(aDupl,cNumNF+"³"+cSerie +"³ "+cParcela+" ³";
										+DTOC(aVenc[nc][1])+"³ "+Transform(aVenc[nc][2],PesqPict("SE2","E2_VALOR")))
									EndIf
										cParcela := IIF(cParcela==" ","A",MaParcela(cParcela))
										nTotDup := nTotDup + Round(aVenc[nc][2],nDecimal)
								Next nc
							EndIf

							bRefreshol:=bRefresh
							bDoRefresh  := {|| NIL }
							bRefresh    := {|| Eval(bDoRefresh)}

							M143CalImp(acab,aItem,aitens2,aitens1)

							bRefresh:=bRefreshol
							aSavecol:= aclone(acols)
							aSaveHead:= aclone(aHeader)
							If cPaisLoc == "ARG"
								acols   := {}
								aHeader := {}
							EndIf
							If !lAutomato
								nNResp := N
							EndIf
							lMSErroAuto := !GravaNfGeral({acab,aItem,aOutros},aitens1,aitens2,nTipo,aCfgNF[16],,.f.,,,aDupl,cNumNF)
							acols:= aclone(aSavecol)
							aHeader:= aclone(aSaveHead)
						Else
							MSExecAuto({|x,y,z,a| MATA101N(x,y,z,a)},aCabs,aItens,3,.F.)
							ResetLojaCH(xFilial("SD1"),DBB->DBB_DOC,DBB->DBB_SERIE,DBB->DBB_FORNEC,DBB->DBB_TIPONF,aItens[1][6][2],DBB->DBB_HAWB,DBB->DBB_ITEM)
						EndIf

					If lMSErroAuto
						MostraErro()

						If aScan(aLogErro, {|x| x[1]+x[2]+x[3]+x[4]==DBB->DBB_HAWB+DBB->DBB_ITEM+DBB->DBB_DOC+DBB->DBB_SERIE}) == 0
							aAdd(aLogErro, {DBB->DBB_HAWB, DBB->DBB_ITEM, DBB->DBB_DOC, DBB->DBB_SERIE})
						EndIf

						If cPaisLoc $ "COL|PER"
							lGerNF := M143FndNF() //Valida creacion de NF en SF1
						EndIf

					EndIf

					If !lMSErroAuto .Or. lGerNF //Si no hubo error o encontro NF en SF1
						DBSelectArea("DBB")
						RecLock("DBB", .F.)
						Replace DBB_DOC   With cNumNF
						Replace DBB_SERIE With cSerie
						Replace DBB_OK    With "S"
						DBB->(MsUnlock())
						lGerou := .T.
						Mata143Met(DBB->DBB_TIPONF)
					ElseIf cPaisLoc $ "COL|PER"
						nDocNoGer++
					EndIf

				EndIf
			EndIf
		Next nX

		nNResp := 0

		If !lAutomato
			N := nResN //Regresa el valor de la posicion de la fila en el acols
		EndIf

		If Len(aLogErro) > 0 .Or. lEnd

			M143GerLog(aLogErro, lEnd)

			If lEnd
				Help(" ",1,"A143STOPGE") // "A geração foi interrompida pelo operador"
			Else
				If !lAutomato
					DEFINE MSDIALOG oDlg FROM  96, 039 TO 310,612 TITLE STR0001 PIXEL //"Processo de Importação"
					@ 18,6 TO 66,280 LABEL '' OF oDlg  PIXEL
					If cPaisLoc $ "COL|PER" .And. nDocNoGer == 0
						@ 29, 015 SAY STR0097 OF oDlg PIXEL SIZE 268, 8 //"Ocurrieron los incidentes mostrados anteriormente, pero, el/los documento(s) ha(n) sido "
						@ 38, 015 SAY STR0098 OF oDlg PIXEL SIZE 268, 8 //"generado(s) correctamente y el despacho ha sido actualizado. Se recomienda revisar los incidentes."
					Else
						@ 29, 015 SAY STR0032 OF oDlg PIXEL SIZE 268, 8 //"Algumas notas fiscais deste Processo de Imporatação não foram geradas. Corrija os problemas que "
						@ 38, 015 SAY STR0033 OF oDlg PIXEL SIZE 268, 8 //"impediram a geração completa do processo e execute novamente a rotina correspondente. "
						@ 48, 015 SAY STR0034 OF oDlg PIXEL SIZE 268, 8 //'Obs.: Foi gerado o arquivo "DESPACHO.LOG" com informações sobre os itens não gerados '
					EndIf
					@ 86, 505 BTNBMP oBtn1 RESOURCE "S4WB016N" PIXEL SIZE 25,25 DESIGN ACTION M143Log(aLogErro) OF oDlg //Imprime icono de ayuda
					DEFINE SBUTTON FROM 80, 252 TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg
					ACTIVATE DIALOG oDlg
				EndIf
			EndIf

			lRet := .F.
		EndIf

		If lGerou .And. !lEnd
			cStatusDBA := "3" // Assume o Status que todas NFEs do desembaraco foram geradas
			dbSelectArea("DBB")
			DBB->(dbSetOrder(2)) //DBB_FILIAL+DBB_HAWB+DBB_ITEM
			DBB->(dbSeek(xFilial("DBB")+DBA->DBA_HAWB , .F. ))
			While !Eof() .And. xFilial("DBB") == DBB->DBB_FILIAL .And. DBB->DBB_HAWB == DBA->DBA_HAWB
				If DBB->DBB_OK <> "S"
					cStatusDBA := "2" // Ao encontrar apenas 1 NFE nao gerada no desembaraco assume o Status de desembaraco parcialmente gerado
					Exit
				EndIf
				DBB->(dbSkip())
			EndDo

			If RecLock("DBA", .F.)
				DBA->DBA_OK := cStatusDBA
				DBA->(MsUnlock())
			EndIf
			If !lAutomato
				If (Len(aLogErro) == 0 .And. nDocNoGer == 0)
					Aviso("A143GERADO",STR0084,{"Ok"},1) // "Fatura(s) gerada(s) com sucesso."
				EndIf
			EndIf
			If ExistBlock("MT143TGV") .And. cPaisLoc == "CHI"
				lRet := ExecBlock("MT143TGV", .F., .F.)
				If ValType(lRet) != "L"
					lRet := .T.
				EndIf
			EndIf
		Else
			If !lAutomato
				Aviso("A143NOGERA",STR0069,{"Ok"},1) // "Não foram encontradas Invoices neste processo para a geração das NFEs."
			EndIf
		EndIf
	EndIf

Else
	If !lAutomato
		Help(" ",1,"A143ALLNFE") // "Todas as notas fiscais deste processo de importação já foram geradas.
	EndIf

EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A143RatDesp  ³ Autor ³ Alexandre Inacio Lemes³ Data ³ 15/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza o rateio das Invoices de Frete,Seguro e Gastos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A143RatDesp()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum	  										      	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ COMPRAS INTERNACIONAL                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A143RatDesp(cTipoNFE,aRecsSF1,oProcess,lEnd, aCabs,aItens ,nValDesp,cTesDesp,cNumNF,cSerie,nValdesc,aImp,cMensag,cCar,lvalid)

Local aStruSD1	:= {}
Local cItem		:= StrZero(0,TamSX3('D1_ITEM')[1])
Local cAliasSD1	:= "SD1"
Local cCF       := ""
Local cRatDesp	:= SuperGetMV("MV_RATDESP")
Local nDecimais	:= SuperGetMV("MV_CENT")
Local nRateio	:= Iif( cTipoNFE == "A" , Val(SubStr(cRatDesp,At("DESP=",cRatDesp)+5,1)) , Val(SubStr(cRatDesp,At("FR=",cRatDesp)+3,1)) )
Local nDifTotal	:= 0
Local nDecs		:= 0
Local nPesoTotal:= 0
Local nVlrTotal	:= 0
Local nY		:= 0
Local nX        := 0
Local nSF1      := 0
Local nPosUnit  := 0
Local nPosTotal := 0
Local nPosPeso  := 0
Local nAux      := 0
Local lQuery 	:= .F.
Local nDifTotDs	:= 0
Local nTotItens := 0
Local nPorcTotal:= 0

Local nBasImp1	:= 0
Local nValImp1	:= 0
Local nALQImp1	:= 0
Local nBasImp2	:= 0
Local nValImp2	:= 0
Local nALQImp2	:= 0
Local nBasImp3	:= 0
Local nValImp3	:= 0
Local nALQImp3	:= 0
Local nBasImp4	:= 0
Local nValImp4	:= 0
Local nALQImp4	:= 0
Local nBasImp5	:= 0
Local nValImp5	:= 0
Local nALQImp5	:= 0
Local nBasImp6	:= 0
Local nValImp6	:= 0
Local nALQImp6	:= 0
Local nBasImp7	:= 0
Local nValImp7	:= 0
Local nALQImp7	:= 0
Local nBasImp8	:= 0
Local nValImp8	:= 0
Local nALQImp8	:= 0
Local nBasImp9	:= 0
Local nValImp9	:= 0
Local nALQImp9	:= 0
Local nBasImpA	:= 0
Local nValImpA	:= 0
Local nALQImpA	:= 0
Local nBasImpB	:= 0
Local nValImpB	:= 0
Local nALQImpB	:= 0
Local nBasImpC	:= 0
Local nValImpC	:= 0
Local nALQImpC	:= 0
Local nBasImpD	:= 0
Local nValImpD	:= 0
Local nALQImpD	:= 0
Local nBasImpE	:= 0
Local nValImpE	:= 0
Local nALQImpE	:= 0
Local nBasImpF	:= 0
Local nValImpF	:= 0
Local nALQImpF	:= 0
Local nBasImpG	:= 0
Local nValImpG	:= 0
Local nALQImpG	:= 0
Local nBasImpH	:= 0
Local nValImpH	:= 0
Local nALQImpH	:= 0
Local nBasImpI	:= 0
Local nValImpI	:= 0
Local nALQImpI	:= 0
Local nBasImpJ	:= 0
Local nValImpJ	:= 0
Local nALQImpJ	:= 0
Local nBasImpK	:= 0
Local nValImpK	:= 0
Local nALQImpK	:= 0
Local nBasImpL	:= 0
Local nValImpL	:= 0
Local nALQImpL	:= 0
Local nBasImpM	:= 0
Local nValImpM	:= 0
Local nALQImpM	:= 0
Local nBasImpN	:= 0
Local nValImpN	:= 0
Local nALQImpN	:= 0
Local nBasImpO	:= 0
Local nValImpO	:= 0
Local nALQImpO	:= 0
Local nBasImpP	:= 0
Local nValImpP	:= 0
Local nALQImpP	:= 0
Local nBasImpQ	:= 0
Local nValImpQ	:= 0
Local nALQImpQ	:= 0
Local nBasImpR	:= 0
Local nValImpR	:= 0
Local nALQImpR	:= 0
Local nBasImpS	:= 0
Local nValImpS	:= 0
Local nALQImpS	:= 0
Local nBasImpT	:= 0
Local nValImpT	:= 0
Local nALQImpT	:= 0
Local nBasImpU	:= 0
Local nValImpU	:= 0
Local nALQImpU	:= 0
Local nBasImpV	:= 0
Local nValImpV	:= 0
Local nALQImpV	:= 0
Local nBasImpW	:= 0
Local nValImpW	:= 0
Local nALQImpW	:= 0
Local nBasImpX	:= 0
Local nValImpX	:= 0
Local nALQImpX	:= 0
Local nBasImpY	:= 0
Local nValImpY	:= 0
Local nALQImpY	:= 0
Local nBasImpZ	:= 0
Local nValImpZ	:= 0
Local nALQImpZ	:= 0
Local nDifBIp1	:= 0
Local nDifBIp2	:= 0
Local nDifBIp3	:= 0
Local nDifBIp4	:= 0
Local nDifBIp5	:= 0
Local nDifBIp6	:= 0
Local nDifBIp7	:= 0
Local nDifBIp8	:= 0
Local nDifBIp9	:= 0
Local nDifBIpA	:= 0
Local nDifBIpB	:= 0
Local nDifBIpC	:= 0
Local nDifBIpD	:= 0
Local nDifBIpE	:= 0
Local nDifBIpF	:= 0
Local nDifBIpG	:= 0
Local nDifBIpH	:= 0
Local nDifBIpI	:= 0
Local nDifBIpJ	:= 0
Local nDifBIpK	:= 0
Local nDifBIpL	:= 0
Local nDifBIpM	:= 0
Local nDifBIpN	:= 0
Local nDifBIpO	:= 0
Local nDifBIpP	:= 0
Local nDifBIpQ	:= 0
Local nDifBIpR	:= 0
Local nDifBIpS	:= 0
Local nDifBIpT	:= 0
Local nDifBIpU	:= 0
Local nDifBIpV	:= 0
Local nDifBIpW	:= 0
Local nDifBIpX	:= 0
Local nDifBIpY	:= 0
Local nDifBIpZ	:= 0

Local nDifVIp1	:= 0
Local nDifVIp2	:= 0
Local nDifVIp3	:= 0
Local nDifVIp4	:= 0
Local nDifVIp5	:= 0
Local nDifVIp6	:= 0
Local nDifVIp7	:= 0
Local nDifVIp8	:= 0
Local nDifVIp9	:= 0
Local nDifVIpA	:= 0
Local nDifVIpB	:= 0
Local nDifVIpC	:= 0
Local nDifVIpD	:= 0
Local nDifVIpE	:= 0
Local nDifVIpF	:= 0
Local nDifVIpG	:= 0
Local nDifVIpH	:= 0
Local nDifVIpI	:= 0
Local nDifVIpJ	:= 0
Local nDifVIpK	:= 0
Local nDifVIpL	:= 0
Local nDifVIpM	:= 0
Local nDifVIpN	:= 0
Local nDifVIpO	:= 0
Local nDifVIpP	:= 0
Local nDifVIpQ	:= 0
Local nDifVIpR	:= 0
Local nDifVIpS	:= 0
Local nDifVIpT	:= 0
Local nDifVIpU	:= 0
Local nDifVIpV	:= 0
Local nDifVIpW	:= 0
Local nDifVIpX	:= 0
Local nDifVIpY	:= 0
Local nDifVIpZ	:= 0
lOCAL nBaseXX 	:= 0
Local nValXX 		:= 0
Local Imp5		:= 0
Local Bas5		:= 0
Local	nTotBase1:=0
Local	nTotBase2:=0
Local	nTotBase3:=0
Local	nTotBase4:=0
Local	nTotBase5:=0
Local	nTotBase6:=0
Local	nTotBase7:=0
Local	nTotBase8:=0
Local	nTotBase9:=0

Local	nTotVal1:=0
Local	nTotVal2:=0
Local	nTotVal3:=0
Local	nTotVal4:=0
Local	nTotVal5:=0
Local	nTotVal6:=0
Local	nTotVal7:=0
Local	nTotVal8:=0
Local	nTotVal9:=0

Local	NtotNF:= 0
Local	NtotDesc:= 0
Local   lAutomato:= isBlind()
Local   nTotalAjust := 0
Local  	nDif      := 0
DEFAULT nValdesc := 0

#IFDEF TOP
	lQuery	:=	TcSrvType()<>"AS/400"
#ENDIF

If !lAutomato
	oProcess:SetRegua1(2)
	oProcess:IncRegua1(STR0078)    //"Lendo notas fiscais de origem..."
	oProcess:SetRegua2(Len(aRecsSF1))
EndIf
For nSF1 :=1 To Len(aRecsSF1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os itens da nota de origem                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SF1->(DbGoto(aRecsSF1[nSF1]))

    nDecs := MsDecimais(DBB->DBB_MOEDA)
    If !lAutomato
    	oProcess:IncRegua2(STR0079+SF1->F1_SERIE+"/"+SF1->F1_DOC)//"Lendo nota fiscal "
	EndIf
	dbSelectArea("SD1")
	dbSetOrder(1)
	If Empty(aStruSD1)
		aStruSD1 := SD1->(dbStruct())
	EndIf

	If lQuery .And. aScan(aStruSD1,{|x| x[2]=="M"}) == 0
		cAliasSD1 := "SD11"
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

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
		For nX := 1 To Len(aStruSD1)
			If aStruSD1[nX][2] <> "C"
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX
	Else
		MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	EndIf
	nTotal:= 1
	While !lEnd .And. !Eof() .And. (cAliasSD1)->D1_FILIAL  == xFilial("SD1")  .And.;
									(cAliasSD1)->D1_DOC     == SF1->F1_DOC 	.And.;
									(cAliasSD1)->D1_SERIE   == SF1->F1_SERIE   .And.;
									(cAliasSD1)->D1_FORNECE == SF1->F1_FORNECE .And.;
									(cAliasSD1)->D1_LOJA    == SF1->F1_LOJA

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Preenche o aItens com base nas notas originais do SD1        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SF1->F1_FORMUL == (cAliasSD1)->D1_FORMUL

			cItem := Soma1(cItem)

			SF4->(dbSetOrder(1))
			If SF4->(MsSeek(xFilial('SF4')+cTesDesp, .F.))
				cCF := SF4->F4_CF
			Else
				cCF := ""
			EndIf

			c143CUSB := (cAliasSD1)->D1_FORNECE
			aAdd(aItens, {})
				nItens:=Len(aItens)
				aAdd(aItens[nitens] , {"D1_FILIAL"  , xFilial("SD1")         , Nil})
				aAdd(aItens[nitens] , {"D1_DOC"     , cNumNF                 , Nil})
				aAdd(aItens[nitens] , {"D1_SERIE"   , cSerie                 , Nil})
				aAdd(aItens[nitens] , {"D1_ITEM"    , cItem                  , Nil})
				aAdd(aItens[nitens] , {"D1_FORNECE" , DBB->DBB_FORNEC        , Nil})
				aAdd(aItens[nitens] , {"D1_LOJA"    ,IIF(cPaisLoc<>"CHI",DBB->DBB_LOJA,IIF(DBB->DBB_TIPONF $ "A",(cAliasSD1)->D1_LOJA,DBB->DBB_LOJA ) ), Nil})
				aAdd(aItens[nitens] , {"D1_EMISSAO" , DBB->DBB_EMISSA        , Nil})
				aAdd(aItens[nitens] , {"D1_DTDIGIT" , dDataBase              , Nil})
				aAdd(aItens[nitens] , {"D1_ESPECIE" , "NF"                   , Nil})
				If DBB->DBB_TIPONF $ "67" // Frete // Seguro
					aAdd(aItens[nitens] , {"D1_TIPODOC" , "14"               , Nil})
				Else // "A" Despesas
					aAdd(aItens[nitens] , {"D1_TIPODOC" , "13"               , Nil})
				EndIf
				aAdd(aItens[nitens] , {"D1_TIPO"    , "C"                     , Nil})
				aAdd(aItens[nitens] , {"D1_FORMUL"  , "N"                     , Nil})
				aAdd(aItens[nitens] , {"D1_PESO"    , (cAliasSD1)->D1_PESO    , Nil})
				aAdd(aItens[nitens] , {"D1_COD"     , (cAliasSD1)->D1_COD     , Nil})
				aAdd(aItens[nitens] , {"D1_UM"      , (cAliasSD1)->D1_UM      , Nil})
				aAdd(aItens[nitens] , {"D1_QUANT"   , 0                       , Nil})
				aAdd(aItens[nitens] , {"D1_VALFRE"  , DBB->DBB_FRETE          , Nil})
				aAdd(aItens[nitens] , {"D1_SEGURO"  , DBB->DBB_SEGURO         , Nil})
				aAdd(aItens[nitens] , {"D1_DESPESA" , DBB->DBB_DESPES         , Nil})
				aAdd(aItens[nitens] , {"D1_VALDESC" , DBB->DBB_DESCON         , Nil})
				If !Empty((cAliasSD1)->D1_SEGUM)
					aAdd(aItens[nitens],{"D1_SEGUM" , (cAliasSD1)->D1_SEGUM, Nil})
				Else
					aAdd(aItens[nItens],{"D1_SEGUM" , ""                   , Nil})
				EndIf
				aAdd(aItens[nitens] , {"D1_NFORI"   , (cAliasSD1)->D1_DOC     , Nil})
				aAdd(aItens[nitens] , {"D1_SERIORI" , (cAliasSD1)->D1_SERIE   , Nil})
				aAdd(aItens[nitens] , {"D1_ITEMORI" , (cAliasSD1)->D1_ITEM    , Nil})
				aAdd(aItens[nitens] , {"D1_LOCAL"   , (cAliasSD1)->D1_LOCAL   , Nil})
				aAdd(aItens[nitens] , {"D1_VUNIT"   , xMoeda((cAliasSD1)->D1_TOTAL,SF1->F1_MOEDA,DBB->DBB_MOEDA,dDataBase,,SF1->F1_TXMOEDA,DBB->DBB_TXMOED ) , Nil})
				aAdd(aItens[nitens] , {"D1_TOTAL"   , xMoeda((cAliasSD1)->D1_TOTAL,SF1->F1_MOEDA,DBB->DBB_MOEDA,dDataBase,,SF1->F1_TXMOEDA,DBB->DBB_TXMOED ) , Nil})
				//aAdd(aItens[nitens] , {"D1_CUSTO"   , xMoeda((cAliasSD1)->D1_TOTAL,SF1->F1_MOEDA,DBB->DBB_MOEDA,dDataBase,,SF1->F1_TXMOEDA,DBB->DBB_TXMOED ) , Nil})
				aAdd(aItens[nitens] , {"D1_NUMCQ"   , (cAliasSD1)->D1_NUMCQ   , Nil})
				aAdd(aItens[nitens] , {"D1_CC"      , (cAliasSD1)->D1_CC      , Nil})
				aAdd(aItens[nitens] , {"D1_CONTA"   , (cAliasSD1)->D1_CONTA   , Nil})
				aAdd(aItens[nitens] , {"D1_ITEMCTA" , (cAliasSD1)->D1_ITEMCTA , Nil})
				aAdd(aItens[nitens] , {"D1_CLVL"    , (cAliasSD1)->D1_CLVL    , Nil})
				aAdd(aItens[nitens] , {"D1_TES"     , cTesDesp                , Nil})
				aAdd(aItens[nitens] , {"D1_CF"      , cCF                     , Nil})
				aAdd(aItens[nitens] , {"D1_NUMSEQ"  , ProxNum()		        , Nil})
				aAdd(aItens[nitens] , {"D1_GRUPO"   ,Posicione('SB1',1,xFilial('SB1')+(cAliasSD1)->D1_COD ,'B1_GRUPO'), Nil})
				If cPaisLoc $ "ARG|PAR|COL|PER|EQU"
					aAdd(aItens[nitens] , {"D1_BASIMP1" , 0	 , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMP1" , 0  , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMP1" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_BASIMP2" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMP2" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMP2" , 0  , Nil})
					aAdd(aItens[nitens] , {"D1_BASIMP3" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMP3" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMP3" , 0  , Nil})
					aAdd(aItens[nitens] , {"D1_BASIMP4" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMP4" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMP4" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_BASIMP5" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMP5" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMP5" , 0  , Nil})
					aAdd(aItens[nitens] , {"D1_BASIMP6" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMP6" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMP6" , 0  , Nil})
					aAdd(aItens[nitens] , {"D1_BASIMP7" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMP7" , 0 , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMP7" , 0  , Nil})
					IIf(SD1->(ColumnPos("D1_BASIMP8")) > 0,aAdd(aItens[nitens] , {"D1_BASIMP8" , 0 , Nil}),"")
					IIf(SD1->(ColumnPos("D1_VALIMP8")) > 0,aAdd(aItens[nitens] , {"D1_VALIMP8" , 0 , Nil}),"")
					IIf(SD1->(ColumnPos("D1_ALQIMP8")) > 0,aAdd(aItens[nitens] , {"D1_ALQIMP8" , 0 , Nil}),"")
					IIf(SD1->(ColumnPos("D1_BASIMP9")) > 0,aAdd(aItens[nitens] , {"D1_BASIMP9" , 0 , Nil}),"")
					IIf(SD1->(ColumnPos("D1_VALIMP9")) > 0,aAdd(aItens[nitens] , {"D1_VALIMP9" , 0 , Nil}),"")
					IIf(SD1->(ColumnPos("D1_ALQIMP9")) > 0,aAdd(aItens[nitens] , {"D1_ALQIMP9" , 0 , Nil}),"")
				EndIf

				If cPaisLoc == "ARG"
				If ACPOIMP[_D1_BASIMPA]
					aAdd(aItens[nitens] , {"D1_BASIMPA" , (cAliasSD1)->D1_BASIMPA  , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPA" , (cAliasSD1)->D1_VALIMPA , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPA" , (cAliasSD1)->D1_ALQIMPA  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPB]
					aAdd(aItens[nitens] , {"D1_BASIMPB" , (cAliasSD1)->D1_BASIMPB , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPB" , (cAliasSD1)->D1_VALIMPB , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPB" , (cAliasSD1)->D1_ALQIMPB  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPC]
					aAdd(aItens[nitens] , {"D1_BASIMPC" , (cAliasSD1)->D1_BASIMPC , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPC" , (cAliasSD1)->D1_VALIMPC , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPC" , (cAliasSD1)->D1_ALQIMPC  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPD]
					aAdd(aItens[nitens] , {"D1_BASIMPD" , (cAliasSD1)->D1_BASIMPD , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPD" , (cAliasSD1)->D1_VALIMPD , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPD" , (cAliasSD1)->D1_ALQIMPD  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPE]
					aAdd(aItens[nitens] , {"D1_BASIMPE" , (cAliasSD1)->D1_BASIMPE , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPE" , (cAliasSD1)->D1_VALIMPE , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPE" , (cAliasSD1)->D1_ALQIMPE  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPF]
					aAdd(aItens[nitens] , {"D1_BASIMPF" , (cAliasSD1)->D1_BASIMPF , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPF" , (cAliasSD1)->D1_VALIMPF , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPF" , (cAliasSD1)->D1_ALQIMPF  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPG]
					aAdd(aItens[nitens] , {"D1_BASIMPG" , (cAliasSD1)->D1_BASIMPG , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPG" , (cAliasSD1)->D1_VALIMPG , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPG" , (cAliasSD1)->D1_ALQIMPG  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPH]
					aAdd(aItens[nitens] , {"D1_BASIMPH" , (cAliasSD1)->D1_BASIMPH , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPH" , (cAliasSD1)->D1_VALIMPH , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPH" , (cAliasSD1)->D1_ALQIMPH  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPI]
					aAdd(aItens[nitens] , {"D1_BASIMPI" , (cAliasSD1)->D1_BASIMPI , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPI" , (cAliasSD1)->D1_VALIMPI , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPI" , (cAliasSD1)->D1_ALQIMPI  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPJ]
					aAdd(aItens[nitens] , {"D1_BASIMPJ" , (cAliasSD1)->D1_BASIMPJ , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPJ" , (cAliasSD1)->D1_VALIMPJ , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPJ" , (cAliasSD1)->D1_ALQIMPJ  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPK]
					aAdd(aItens[nitens] , {"D1_BASIMPK" , (cAliasSD1)->D1_BASIMPK , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPK" , (cAliasSD1)->D1_VALIMPK , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPK" , (cAliasSD1)->D1_ALQIMPK  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPL]
					aAdd(aItens[nitens] , {"D1_BASIMPL" , (cAliasSD1)->D1_BASIMPL , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPL" , (cAliasSD1)->D1_VALIMPL , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPL" , (cAliasSD1)->D1_ALQIMPL  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPM]
					aAdd(aItens[nitens] , {"D1_BASIMPM" , (cAliasSD1)->D1_BASIMPM , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPM" , (cAliasSD1)->D1_VALIMPM , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPM" , (cAliasSD1)->D1_ALQIMPM  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPN]
					aAdd(aItens[nitens] , {"D1_BASIMPN" , (cAliasSD1)->D1_BASIMPN , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPN" , (cAliasSD1)->D1_VALIMPN , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPN" , (cAliasSD1)->D1_ALQIMPN  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPO]
					aAdd(aItens[nitens] , {"D1_BASIMPO" , (cAliasSD1)->D1_BASIMPO , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPO" , (cAliasSD1)->D1_VALIMPO , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPO" , (cAliasSD1)->D1_ALQIMPO  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPP]
					aAdd(aItens[nitens] , {"D1_BASIMPP" , (cAliasSD1)->D1_BASIMPP , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPP" , (cAliasSD1)->D1_VALIMPP , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPP" , (cAliasSD1)->D1_ALQIMPP  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPQ]
					aAdd(aItens[nitens] , {"D1_BASIMPQ" , (cAliasSD1)->D1_BASIMPQ , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPQ" , (cAliasSD1)->D1_VALIMPQ , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPQ" , (cAliasSD1)->D1_ALQIMPQ  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPR]
					aAdd(aItens[nitens] , {"D1_BASIMPR" , (cAliasSD1)->D1_BASIMPR , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPR" , (cAliasSD1)->D1_VALIMPR , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPR" , (cAliasSD1)->D1_ALQIMPR  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPS]
					aAdd(aItens[nitens] , {"D1_BASIMPS" , (cAliasSD1)->D1_BASIMPS , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPS" , (cAliasSD1)->D1_VALIMPS , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPS" , (cAliasSD1)->D1_ALQIMPS  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPT]
					aAdd(aItens[nitens] , {"D1_BASIMPT" , (cAliasSD1)->D1_BASIMPT , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPT" , (cAliasSD1)->D1_VALIMPT , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPT" , (cAliasSD1)->D1_ALQIMPT  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPU]
					aAdd(aItens[nitens] , {"D1_BASIMPU" , (cAliasSD1)->D1_BASIMPU , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPU" , (cAliasSD1)->D1_VALIMPU , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPU" , (cAliasSD1)->D1_ALQIMPU  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPV]
					aAdd(aItens[nitens] , {"D1_BASIMPV" , (cAliasSD1)->D1_BASIMPV , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPV" , (cAliasSD1)->D1_VALIMPV , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPV" , (cAliasSD1)->D1_ALQIMPV  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPW]
					aAdd(aItens[nitens] , {"D1_BASIMPW" , (cAliasSD1)->D1_BASIMPW , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPW" , (cAliasSD1)->D1_VALIMPW , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPW" , (cAliasSD1)->D1_ALQIMPW  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPX]
					aAdd(aItens[nitens] , {"D1_BASIMPX" , (cAliasSD1)->D1_BASIMPX , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPX" , (cAliasSD1)->D1_VALIMPX , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPX" , (cAliasSD1)->D1_ALQIMPX  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPY]
					aAdd(aItens[nitens] , {"D1_BASIMPY" , (cAliasSD1)->D1_BASIMPY , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPY" , (cAliasSD1)->D1_VALIMPY , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPY" , (cAliasSD1)->D1_ALQIMPY  , Nil})
				EndIf
				If  ACPOIMP[_D1_BASIMPZ]
					aAdd(aItens[nitens] , {"D1_BASIMPZ" , (cAliasSD1)->D1_BASIMPZ , Nil})
					aAdd(aItens[nitens] , {"D1_VALIMPZ" , (cAliasSD1)->D1_VALIMPZ , Nil})
					aAdd(aItens[nitens] , {"D1_ALQIMPZ" , (cAliasSD1)->D1_ALQIMPZ  , Nil})
				EndIf
					aAdd(aItens[nitens] , {"D1_PROVENT" , DBB->DBB_PROVEN  , Nil})
				EndIf

				If DBB->DBB_TIPONF $ "A" .AND.  cPaisloc $ "PAR|COL|EQU"
					aAdd(aItens[nitens] , {"D1_VALDESC" ,  xMoeda((cAliasSD1)->D1_VALDESC,SF1->F1_MOEDA,DBB->DBB_MOEDA,dDataBase,,SF1->F1_TXMOEDA,DBB->DBB_TXMOED ) , Nil})
				EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza os acumuladores do rateio                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPesoTotal += (cAliasSD1)->D1_PESO
			nVlrTotal  += xMoeda((cAliasSD1)->D1_TOTAL,SF1->F1_MOEDA,DBB->DBB_MOEDA,dDataBase,,SF1->F1_TXMOEDA,DBB->DBB_TXMOED )

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

	If lEnd
		Exit
	Endif

Next nSF1

If lEnd
	Return
Endif

If Len(aItens) == 0
	MsgAlert(STR0080) //" Não foram encontrados itens nas notas fiscais de origem."
	Return
Endif
If !lAutomato
	oProcess:IncRegua1(STR0081)//"Gerando rateios e atualizando dados..."
	oProcess:SetRegua2(Len(aItens))
	oProcess:IncRegua2(STR0082)//"Inicializando dados..."
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o rateio do Frete, Seguro ou Despesas nos itens.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc $ "ARG|PAR|COL|PER|EQU"
	nBasImp1	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMP1"})
	nValImp1	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMP1"})
	nAlqImp1	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMP1"})

	nBasImp2	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMP2"})
	nValImp2	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMP2"})
	nAlqImp2	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMP2"})

	nBasImp3	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMP3"})
	nValImp3	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMP3"})
	nAlqImp3	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMP3"})

	nBasImp4	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMP4"})
	nValImp4	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMP4"})
	nAlqImp4	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMP4"})


	nBasImp5	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMP5"})
	nValImp5	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMP5"})
	nAlqImp5	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMP5"})

	nBasImp6	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMP6"})
	nValImp6	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMP6"})
	nAlqImp6	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMP6"})

	nBasImp7	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMP7"})
	nValImp7	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMP7"})
	nAlqImp7	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMP7"})

	nBasImp8	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMP8"})
	nValImp8	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMP8"})
	nAlqImp8	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMP8"})

	nBasImp9	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMP9"})
	nValImp9	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMP9"})
	nAlqImp9	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMP9"})
If cPaisLoc $ "ARG|PAR"
	nBasImpA	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPA"})
	nValImpA	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPA"})
	nAlqImpA	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPA"})

	nBasImpB	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPB"})
	nValImpB	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPB"})
	nAlqImpB	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPB"})

	nBasImpC	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPC"})
	nValImpC	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPC"})
	nAlqImpC	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPC"})

	nBasImpD	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPD"})
	nValImpD	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPD"})
	nAlqImpD	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPD"})

	nBasImpE	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPE"})
	nValImpE	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPE"})
	nAlqImpE	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPE"})

	nBasImpF	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPF"})
	nValImpF	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPF"})
	nAlqImpF	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPF"})

	nBasImpG	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPG"})
	nValImpG	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPG"})
	nAlqImpG	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPG"})

	nBasImpH	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPH"})
	nValImpH	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPH"})
	nAlqImpH	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPH"})

	nBasImpI	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPI"})
	nValImpI	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPI"})
	nAlqImpI	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPI"})

	nBasImpJ	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPJ"})
	nValImpJ	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPJ"})
	nAlqImpJ	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPJ"})

	nBasImpK	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPK"})
	nValImpK	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPK"})
	nAlqImpK	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPK"})

	nBasImpL	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPL"})
	nValImpL	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPL"})
	nAlqImpL	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPL"})

	nBasImpM	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPM"})
	nValImpM	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPM"})
	nAlqImpM	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPM"})

	nBasImpN	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPN"})
	nValImpN	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPN"})
	nAlqImpN	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPN"})

	nBasImpO	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPO"})
	nValImpO	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPO"})
	nAlqImpO	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPO"})

	nBasImpP	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPP"})
	nValImpP	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPP"})
	nAlqImpP	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPP"})

	nBasImpQ	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPQ"})
	nValImpQ	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPQ"})
	nAlqImpQ	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPQ"})

	nBasImpR	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPR"})
	nValImpR	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPR"})
	nAlqImpR	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPR"})

	nBasImpS	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPS"})
	nValImpS	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPS"})
	nAlqImpS	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPS"})

	nBasImpT	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPT"})
	nValImpT	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPT"})
	nAlqImpT	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPT"})

	nBasImpU	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPU"})
	nValImpU	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPU"})
	nAlqImpU	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPU"})

	nBasImpV	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPV"})
	nValImpV	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPV"})
	nAlqImpV	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPV"})

	nBasImpW	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPW"})
	nValImpW	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPW"})
	nAlqImpW	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPW"})

	nBasImpX	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPX"})
	nValImpX	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPX"})
	nAlqImpX	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPX"})

	nBasImpY	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPY"})
	nValImpY	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPY"})
	nAlqImpY	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPY"})

	nBasImpZ	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_BASIMPZ"})
	nValImpZ	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_VALIMPZ"})
	nAlqImpZ	:= aScan(aItens[1],{|x|AllTrim(x[1])=="D1_ALQIMPZ"})
	EndIf
EndIf
	nTotItens:= Len(aItens)

For nX := 1 to Len(aItens)
	nPosUnit  := aScan(aItens[nX],{|x|Alltrim(x[1]) == "D1_VUNIT" })
	nPosTotal := aScan(aItens[nX],{|x|Alltrim(x[1]) == "D1_TOTAL" })
	nPosPeso  := aScan(aItens[nX],{|x|Alltrim(x[1]) == "D1_PESO"  })
	nPosDesc  := aScan(aItens[nX],{|x|Alltrim(x[1]) == "D1_VALDESC"  })
	If nRateio == 2 .And. nPesoTotal > 0

 		aItens[nX][nPosTotal][2]:= NoRound((aItens[nX][nPosPeso][2] / nPesoTotal) *  nValDesp ,nDecs,@nDifTotal)
		If Empty(aItens[nX][nPosTotal][2])
			aItens[nX][nPosTotal][2] := (1/(10**nDecs))
			nDifTotal				  -= (1/(10**nDecs))
		ElseIf NoRound(nDifTotal,nDecs)  >= (1/(10**nDecs))
			aItens[nX][nPosTotal][2] += NoRound(nDifTotal,nDecs)
			nDifTotal			      -= NoRound(nDifTotal,nDecs)
		EndIf

		aItens[nX][nPosUnit][2]:= aItens[nX][nPosTotal][2]

		//Desconto
		If nPosDesc > 0
			aItens[nX][nPosDesc ][2]:= NoRound((aItens[nX][nPosPeso][2] / nPesoTotal) *  nValdesc ,nDecs,@nDifTotDs)
			If Empty(aItens[nX][nPosDesc][2])
				If  (cPaisloc!="BOL" )
					aItens[nX][nPosDesc][2] := (1/(10**nDecs))
					nDifTotDs				-= (1/(10**nDecs))
				Endif
			ElseIf NoRound(nDifTotDs,nDecs)  >= (1/(10**nDecs))
				aItens[nX][nPosDesc][2] += NoRound(nDifTotDs,nDecs)
				nDifTotDs			      -= NoRound(nDifTotDs,nDecs)
			EndIf
			If cPaisLoc $ "PER"
				NtotDesc:=NtotDesc +aItens[nX][nPosDesc][2]
				If nX == nTotItens .And.  nValdesc - NtotDesc  <> 0
					aItens[nX][nPosDesc][2]:=aItens[nX][nPosDesc][2] +(nValdesc - NtotDesc )
				EndIf
				If nValdesc==0
					aItens[nX][nPosDesc][2]:=0
				EndIf
			EndIf
		EndIf

	Else
		nPorcTotal:= aItens[nX][nPosTotal][2] / nVlrTotal

		If cPaisLoc $ "PER|COL|EQU"
			aItens[nX][nPosTotal][2] := NoRound( nPorcTotal * nValDesp , nDecs ) //- Prorrateo del total de invoice x item
			nTotalAjust  += aItens[nX][nPosTotal][2]
		Else
			aItens[nX][nPosTotal][2] := NoRound( nPorcTotal * nValDesp , nDecs, @nDifTotal ) //- Prorrateo del total de invoice x item
		Endif
		If Empty(aItens[nX][nPosTotal][2])
			aItens[nX][nPosTotal][2] := (1/(10**nDecs))
			nDifTotal				  -= (1/(10**nDecs))
		ElseIf NoRound(nDifTotal,nDecs)   >= (1/(10**nDecs))
			aItens[nX][nPosTotal][2]  += NoRound(nDifTotal,nDecs)
			nDifTotal			       -= NoRound(nDifTotal,nDecs)
		EndIf

		If nPosDesc > 0
			aItens[nX][nPosDesc][2]:= NoRound(nPorcTotal *  nValdesc ,nDecs,@nDifTotDs)
			If Empty(aItens[nX][nPosDesc][2])
				If  (cPaisloc!="BOL" )
				aItens[nX][nPosDesc][2] := (1/(10**nDecs))
				nDifTotDs				  -= (1/(10**nDecs))
				Endif
			ElseIf NoRound(nDifTotDs,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nPosDesc][2]  += NoRound(nDifTotDs,nDecs)
				nDifTotDs			       -= NoRound(nDifTotDs,nDecs)
			EndIf
		EndIf
			NtotDesc:=NtotDesc +aItens[nX][nPosDesc][2]

			If nX == nTotItens .And.  nValdesc - NtotDesc  <> 0
				aItens[nX][nPosDesc][2]:=aItens[nX][nPosDesc][2] +(nValdesc - NtotDesc )
			EndIf

			If nValdesc==0
				aItens[nX][nPosDesc][2]:=0
			EndIf

		If cPaisLoc $ "PAR|CHI"     .and. DBB->DBB_MOEDA == 1   .and. nDecimais == 0
			If (nX == Len(aItens))
				aItens[nX][nPosUnit][2]:= (nValDesp - nAux)
				aItens[nX][nPosTotal][2]:= (nValDesp - nAux)
			Else
				nAux 	:= nAux + aItens[nX][nPosTotal][2]
				aItens[nX][nPosUnit][2]:= aItens[nX][nPosTotal][2]
			EndIf
		ElseIf cPaisLoc == "ARG" .Or. ( cPaisLoc $ "PAR|CHI" .and. DBB->DBB_MOEDA <> 1 )
				nAux 	:= nAux + aItens[nX][nPosTotal][2]
				NtotNF:=NtotNF +aItens[nX][nPosTotal][2]
				If nX == nTotItens .And. nValDesp - NtotNF <> 0
					aItens[nX][nPosTotal][2]:=aItens[nX][nPosTotal][2] +(nValDesp - NtotNF )
				EndIf
					aItens[nX][nPosUnit][2]:= aItens[nX][nPosTotal][2]
		EndIf

	EndIf
		If cPaisLoc $ "ARG|PAR|COL"
	//Inicio do rateio dos impostos
		If aImp[1][1] > 0  //base
			aItens[nX][nBasImp1][2]:= NoRound(nPorcTotal * aImp[1][1] , nDecs, @nDifBIp1 )
			aItens[nX][nAlqImp1][2]:= aImp[1][2]


			If Empty(aItens[nX][nBasImp1][2])
				aItens[nX][nBasImp1][2] := (1/(10**nDecs))
				nDifBIp1				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifBIp1,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nBasImp1][2]  += NoRound(nDifBIp1,nDecs)
				nDifBIp1		       -= NoRound(nDifBIp1,nDecs)
			EndIf

		Else
			aItens[nX][nAlqImp1][2]:= 0
			aItens[nX][nBasImp1][2]:=0
		EndIf


		If aImp[1][3] > 0  //valor
			aItens[nX][nValImp1][2]:= NoRound(nPorcTotal * aImp[1][3] , nDecs, @nDifVIp1 )

			If Empty(aItens[nX][nValImp1][2])
				aItens[nX][nValImp1][2] := (1/(10**nDecs))
				nDifVIp1				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifVIp1,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nValImp1][2]  += NoRound(nDifVIp1,nDecs)
				nDifVIp1		       -= NoRound(nDifVIp1,nDecs)
			EndIf

		Else
			aItens[nX][nValImp1][2]:=0
		EndIf


		If aImp[2][1] > 0  //base
			aItens[nX][nBasImp2][2]:= NoRound(nPorcTotal * aImp[2][1] , nDecs, @nDifBIp2 )
			aItens[nX][nAlqImp2][2]:= aImp[2][2]
			If Empty(aItens[nX][nBasImp2][2])
				aItens[nX][nBasImp2][2] := (1/(10**nDecs))
				nDifBIp2				  -= (1/(10**nDecs))
			ElseIf Round(nDifBIp2,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nBasImp2][2]  += Round(nDifBIp2,nDecs)
				nDifBIp2		       -= Round(nDifBIp2,nDecs)
			EndIf

			nBaseXX+= aItens[nX][nBasImp2][2]
		Else
			aItens[nX][nAlqImp2][2]:= 0
			aItens[nX][nBasImp2][2]:=0
		EndIf



		If aImp[2][3] > 0  //valor
			aItens[nX][nValImp2][2]:= NoRound(nPorcTotal * aImp[2][3] , nDecs, @nDifVIp2 )
			If Empty(aItens[nX][nValImp2][2])
				aItens[nX][nValImp2][2] := (1/(10**nDecs))
				nDifVIp2				  -= (1/(10**nDecs))
			ElseIf Round(nDifVIp2,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nValImp2][2]  += Round(nDifVIp2,nDecs)
				nDifVIp2		       -= Round(nDifVIp2,nDecs)
			EndIf
			nValXX+= aItens[nX][nValImp2][2]
		Else
			aItens[nX][nValImp2][2]:=0
		EndIf

		If aImp[3][1] > 0  //base
			aItens[nX][nBasImp3][2]:= NoRound(nPorcTotal * aImp[3][1] , nDecs, @nDifBIp3 )
			aItens[nX][nAlqImp3][2]:= aImp[3][2]
			If Empty(aItens[nX][nBasImp3][2])
				aItens[nX][nBasImp3][2] := (1/(10**nDecs))
				nDifBIp3				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifBIp3,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nBasImp3][2]  += NoRound(nDifBIp3,nDecs)
				nDifBIp3		       -= NoRound(nDifBIp3,nDecs)
			EndIf
		Else
			aItens[nX][nAlqImp3][2]:= 0
			aItens[nX][nBasImp3][2]:=0

		EndIf

		If aImp[3][3] > 0  //valor
			aItens[nX][nValImp3][2]:= NoRound(nPorcTotal * aImp[3][3] , nDecs, @nDifVIp3 )
			If Empty(aItens[nX][nValImp3][2])
				aItens[nX][nValImp3][2] := (1/(10**nDecs))
				nDifVIp3				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifVIp3,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nValImp3][2]  += NoRound(nDifVIp3,nDecs)
				nDifVIp3		       -= NoRound(nDifVIp3,nDecs)
			EndIf
		Else
			aItens[nX][nValImp3][2]:= 0
		EndIf


		If aImp[4][1] > 0  //base
			aItens[nX][nBasImp4][2]:= NoRound(nPorcTotal * aImp[4][1] , nDecs, @nDifBIp4 )
			aItens[nX][nAlqImp4][2]:= aImp[4][2]
			If Empty(aItens[nX][nBasImp4][2])
				aItens[nX][nBasImp4][2] := (1/(10**nDecs))
				nDifBIp4				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifBIp4,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nBasImp4][2]  += NoRound(nDifBIp4,nDecs)
				nDifBIp4		       -= NoRound(nDifBIp4,nDecs)
			EndIf
		Else
			aItens[nX][nAlqImp4][2]:= 0
			aItens[nX][nBasImp4][2]:=0
		EndIf

		If aImp[4][3] > 0  //valor
			aItens[nX][nValImp4][2]:= NoRound(nPorcTotal * aImp[4][3] , nDecs, @nDifVIp4 )
			If Empty(aItens[nX][nValImp4][2])
				aItens[nX][nValImp4][2] := (1/(10**nDecs))
				nDifVIp4				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifVIp4,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nValImp4][2]  += NoRound(nDifVIp4,nDecs)
				nDifVIp4		       -= NoRound(nDifVIp4,nDecs)
			EndIf
		Else
			aItens[nX][nValImp4][2]:=0
		EndIf


		If aImp[5][1] > 0  //base
			aItens[nX][nBasImp5][2]:= NoRound(nPorcTotal * aImp[5][1] , nDecs, @nDifBIp5 )
			aItens[nX][nAlqImp5][2]:= aImp[5][2]
			If Empty(aItens[nX][nBasImp5][2])
				aItens[nX][nBasImp5][2] := (1/(10**nDecs))
				nDifBIp5				  -= (1/(10**nDecs))
			ElseIf Round(nDifBIp5,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nBasImp5][2]  += Round(nDifBIp5,nDecs)
				nDifBIp5		       -= Round(nDifBIp5,nDecs)
			EndIf
			Bas5+= aItens[nX][nBasImp2][2]
		Else
			aItens[nX][nBasImp5][2]:= 0
			aItens[nX][nAlqImp5][2]:= 0
		EndIf

		If aImp[5][3] > 0  //valor
			aItens[nX][nValImp5][2]:= NoRound(nPorcTotal * aImp[5][3] , nDecs, @nDifVIp5 )
			If Empty(aItens[nX][nValImp5][2])
				aItens[nX][nValImp5][2] := (1/(10**nDecs))
				nDifVIp5				  -= (1/(10**nDecs))
			ElseIf Round(nDifVIp5,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nValImp5][2]  += Round(nDifVIp5,nDecs)
				nDifVIp5		       -= Round(nDifVIp5,nDecs)
			EndIf
			Imp5+= aItens[nX][nValImp2][2]
		Else
			aItens[nX][nValImp5][2]:= 0
		EndIf

		If aImp[6][1] > 0  //base
			aItens[nX][nBasImp6][2]:= NoRound(nPorcTotal * aImp[6][1] , nDecs, @nDifBIp6 )
			aItens[nX][nAlqImp6][2]:= aImp[6][2]
			If Empty(aItens[nX][nBasImp6][2])
				aItens[nX][nBasImp6][2] := (1/(10**nDecs))
				nDifBIp6				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifBIp6,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nBasImp6][2]  += NoRound(nDifBIp6,nDecs)
				nDifBIp6		       -= NoRound(nDifBIp6,nDecs)
			EndIf
		EndIf

		If aImp[6][3] > 0  //valor
			aItens[nX][nValImp6][2]:= NoRound(nPorcTotal * aImp[6][3] , nDecs, @nDifVIp6 )
			If Empty(aItens[nX][nValImp6][2])
				aItens[nX][nValImp6][2] := (1/(10**nDecs))
				nDifVIp6				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifVIp6,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nValImp6][2]  += NoRound(nDifVIp6,nDecs)
				nDifVIp6		       -= NoRound(nDifVIp6,nDecs)
			EndIf
		EndIf

		If aImp[7][1] > 0  //base
			aItens[nX][nBasImp7][2]:= NoRound(nPorcTotal * aImp[7][1] , nDecs, @nDifBIp7 )
			aItens[nX][nAlqImp7][2]:= aImp[7][2]
			If Empty(aItens[nX][nBasImp7][2])
				aItens[nX][nBasImp7][2] := (1/(10**nDecs))
				nDifBIp7				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifBIp7,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nBasImp7][2]  += NoRound(nDifBIp7,nDecs)
				nDifBIp7		       -= NoRound(nDifBIp7,nDecs)
			EndIf
		EndIf

		If aImp[7][3] > 0  //valor
			aItens[nX][nValImp7][2]:= NoRound(nPorcTotal * aImp[7][3] , nDecs, @nDifVIp7 )
			If Empty(aItens[nX][nValImp7][2])
				aItens[nX][nValImp7][2] := (1/(10**nDecs))
				nDifVIp7				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifVIp7,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nValImp7][2]  += NoRound(nDifVIp7,nDecs)
				nDifVIp7		       -= NoRound(nDifVIp7,nDecs)
			EndIf
		EndIf

		If aImp[8][1] > 0  //base
			aItens[nX][nBasImp8][2]:= NoRound(nPorcTotal * aImp[8][1] , nDecs, @nDifBIp8 )
			aItens[nX][nAlqImp8][2]:= aImp[8][2]
			If Empty(aItens[nX][nBasImp8][2])
				aItens[nX][nBasImp8][2] := (1/(10**nDecs))
				nDifBIp8				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifBIp8,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nBasImp8][2]  += NoRound(nDifBIp8,nDecs)
				nDifBIp8		       -= NoRound(nDifBIp8,nDecs)
			EndIf
		EndIf

		If aImp[8][3] > 0  //valor
			aItens[nX][nValImp8][2]:= NoRound(nPorcTotal * aImp[8][3] , nDecs, @nDifVIp8 )
			If Empty(aItens[nX][nValImp8][2])
				aItens[nX][nValImp8][2] := (1/(10**nDecs))
				nDifVIp8				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifVIp8,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nValImp8][2]  += NoRound(nDifVIp8,nDecs)
				nDifVIp8		       -= NoRound(nDifVIp8,nDecs)
			EndIf
		EndIf

		If aImp[9][1] > 0  //base
			aItens[nX][nBasImp9][2]:= NoRound(nPorcTotal * aImp[9][1] , nDecs, @nDifBIp9 )
			aItens[nX][nAlqImp9][2]:= aImp[9][2]
			If Empty(aItens[nX][nBasImp9][2])
				aItens[nX][nBasImp9][2] := (1/(10**nDecs))
				nDifBIp9				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifBIp9,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nBasImp9][2]  += NoRound(nDifBIp9,nDecs)
				nDifBIp9		       -= NoRound(nDifBIp9,nDecs)
			EndIf
		EndIf

		If aImp[9][3] > 0  //valor
			aItens[nX][nValImp9][2]:= NoRound(nPorcTotal * aImp[9][3] , nDecs, @nDifVIp9 )
			If Empty(aItens[nX][nValImp9][2])
				aItens[nX][nValImp9][2] := (1/(10**nDecs))
				nDifVIp9				  -= (1/(10**nDecs))
			ElseIf NoRound(nDifVIp9,nDecs)   >= (1/(10**nDecs))
				aItens[nX][nValImp9][2]  += NoRound(nDifVIp9,nDecs)
				nDifVIp9		       -= NoRound(nDifVIp9,nDecs)
			EndIf
		EndIf

		nTotBase1:=nTotBase1+aItens[nX][nBasImp1][2]
		nTotBase2:=nTotBase2+aItens[nX][nBasImp2][2]
		nTotBase3:=nTotBase3+aItens[nX][nBasImp3][2]
		nTotBase4:=nTotBase4+aItens[nX][nBasImp4][2]
		nTotBase5:=nTotBase5+aItens[nX][nBasImp5][2]
		nTotBase6:=nTotBase6+aItens[nX][nBasImp6][2]
		nTotBase7:=nTotBase7+aItens[nX][nBasImp7][2]
		IIf(nBasImp8>0,nTotBase8:=nTotBase8+aItens[nX][nBasImp8][2],"")
		IIf(nBasImp9>0,nTotBase9:=nTotBase9+aItens[nX][nBasImp9][2],"")


		nTotVal1:=nTotVal1+aItens[nX][nValImp1][2]
		nTotVal2:=nTotVal2+aItens[nX][nValImp2][2]
		nTotVal3:=nTotVal3+aItens[nX][nValImp3][2]
		nTotVal4:=nTotVal4+aItens[nX][nValImp4][2]
		nTotVal5:=nTotVal5+aItens[nX][nValImp5][2]
		nTotVal6:=nTotVal6+aItens[nX][nValImp6][2]
		nTotVal7:=nTotVal7+aItens[nX][nValImp7][2]
		IIf(nValImp8>0,nTotVal8:=nTotVal8+aItens[nX][nValImp8][2],"")
		IIf(nValImp9>0,nTotVal9:=nTotVal9+aItens[nX][nValImp9][2],"")




		If nX == nTotItens

			aItens[nX][nValImp1][2]:=aItens[nX][nValImp1][2] +(aImp[1][3] -nTotVal1)
			aItens[nX][nValImp2][2]:=aItens[nX][nValImp2][2] +(aImp[2][3] -nTotVal2)
			aItens[nX][nValImp3][2]:=aItens[nX][nValImp3][2] +(aImp[3][3] -nTotVal3)
			aItens[nX][nValImp4][2]:=aItens[nX][nValImp4][2] +(aImp[4][3] -nTotVal4)
			aItens[nX][nValImp5][2]:=aItens[nX][nValImp5][2] +(aImp[5][3] -nTotVal5)
			aItens[nX][nValImp6][2]:=aItens[nX][nValImp6][2] +(aImp[6][3] -nTotVal6)
			aItens[nX][nValImp7][2]:=aItens[nX][nValImp7][2] +(aImp[7][3] -nTotVal7)
			IIf(nValImp8>0,aItens[nX][nValImp8][2]:=aItens[nX][nValImp8][2] +(aImp[8][3] -nTotVal8),"")
			IIf(nValImp9>0,aItens[nX][nValImp9][2]:=aItens[nX][nValImp9][2] +(aImp[9][3] -nTotVal9),"")

			aItens[nX][nBasImp1][2]:=aItens[nX][nBasImp1][2] +(aImp[1][1] -nTotBase1)
			aItens[nX][nBasImp2][2]:=aItens[nX][nBasImp2][2] +(aImp[2][1] -nTotBase2)
			aItens[nX][nBasImp3][2]:=aItens[nX][nBasImp3][2] +(aImp[3][1] -nTotBase3)
			aItens[nX][nBasImp4][2]:=aItens[nX][nBasImp4][2] +(aImp[4][1] -nTotBase4)
			aItens[nX][nBasImp5][2]:=aItens[nX][nBasImp5][2] +(aImp[5][1] -nTotBase5)
			aItens[nX][nBasImp6][2]:=aItens[nX][nBasImp6][2] +(aImp[6][1] -nTotBase6)
			aItens[nX][nBasImp7][2]:=aItens[nX][nBasImp7][2] +(aImp[7][1] -nTotBase7)
			IIf(nBasImp8>0,aItens[nX][nBasImp8][2]:=aItens[nX][nBasImp8][2] +(aImp[8][1] -nTotBase8),"")
			IIf(nBasImp9>0,aItens[nX][nBasImp9][2]:=aItens[nX][nBasImp9][2] +(aImp[9][1] -nTotBase9),"")
		EndIf

		If cPaisLoc $ "ARG|PAR"

		If ACPOIMP[_D1_BASIMPA]
			If aImp[10][1] > 0  //base
				aItens[nX][nBasImpA][2]:= NoRound(nPorcTotal * aImp[10][1] , nDecs, @nDifBIpA )
				aItens[nX][nAlqImpA][2]:= aImp[10][2]
				If Empty(aItens[nX][nBasImpA][2])
					aItens[nX][nBasImpA][2] := (1/(10**nDecs))
					nDifBIpA				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpA,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpA][2]  += NoRound(nDifBIpA,nDecs)
					nDifBIpA		       -= NoRound(nDifBIpA,nDecs)
				EndIf
			EndIf

			If aImp[10][3] > 0  //valor
				aItens[nX][nValImpA][2]:= NoRound(nPorcTotal * aImp[10][3] , nDecs, @nDifVIpA )
				If Empty(aItens[nX][nValImpA][2])
					aItens[nX][nValImpA][2] := (1/(10**nDecs))
					nDifVIpA				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpA,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpA][2]  += NoRound(nDifVIpA,nDecs)
					nDifVIpA		       -= NoRound(nDifVIpA,nDecs)
				EndIf
			EndIf
		EndIf

		If ACPOIMP[_D1_BASIMPB]
			If aImp[11][1] > 0  //base
				aItens[nX][nBasImpB][2]:= NoRound(nPorcTotal * aImp[11][1] , nDecs, @nDifBIpB )
				aItens[nX][nAlqImpB][2]:= aImp[11][2]
				If Empty(aItens[nX][nBasImpB][2])
					aItens[nX][nBasImpB][2] := (1/(10**nDecs))
					nDifBIpB				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpB,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpB][2]  += NoRound(nDifBIpB,nDecs)
					nDifBIpB		       -= NoRound(nDifBIpB,nDecs)
				EndIf
			EndIf

			If aImp[11][3] > 0  //valor
				aItens[nX][nValImpB][2]:= NoRound(nPorcTotal * aImp[11][3] , nDecs, @nDifVIpB )
				If Empty(aItens[nX][nValImpB][2])
					aItens[nX][nValImpB][2] := (1/(10**nDecs))
					nDifVIpB				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpB,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpB][2]  += NoRound(nDifVIpB,nDecs)
					nDifVIpB		       -= NoRound(nDifVIpB,nDecs)
				EndIf
			EndIf
		EndIf

		If ACPOIMP[_D1_BASIMPC]
			If aImp[12][1] > 0  //base
				aItens[nX][nBasImpC][2]:= NoRound(nPorcTotal * aImp[12][1] , nDecs, @nDifBIpC )
				aItens[nX][nAlqImpC][2]:= aImp[12][2]
				If Empty(aItens[nX][nBasImpC][2])
					aItens[nX][nBasImpC][2] := (1/(10**nDecs))
					nDifBIpC				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpC,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpC][2]  += NoRound(nDifBIpC,nDecs)
					nDifBIpC		       -= NoRound(nDifBIpC,nDecs)
				EndIf
			EndIf

			If aImp[12][3] > 0  //valor
				aItens[nX][nValImpC][2]:= NoRound(nPorcTotal * aImp[12][3] , nDecs, @nDifVIpC )
				If Empty(aItens[nX][nValImpC][2])
					aItens[nX][nValImpC][2] := (1/(10**nDecs))
					nDifVIpC				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpC,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpC][2]  += NoRound(nDifVIpC,nDecs)
					nDifVIpC		       -= NoRound(nDifVIpC,nDecs)
				EndIf
			EndIf
		EndIf

		If ACPOIMP[_D1_BASIMPD]
			If aImp[13][1] > 0  //base
				aItens[nX][nBasImpD][2]:= NoRound(nPorcTotal * aImp[13][1] , nDecs, @nDifBIpD )
				aItens[nX][nAlqImpD][2]:= aImp[13][2]
				If Empty(aItens[nX][nBasImpD][2])
					aItens[nX][nBasImpD][2] := (1/(10**nDecs))
					nDifBIpD				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpD,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpD][2]  += NoRound(nDifBIpD,nDecs)
					nDifBIpD		       -= NoRound(nDifBIpD,nDecs)
				EndIf
			EndIf

			If aImp[13][3] > 0  //valor
				aItens[nX][nValImpD][2]:= NoRound(nPorcTotal * aImp[13][3] , nDecs, @nDifVIpD )
				If Empty(aItens[nX][nValImpD][2])
					aItens[nX][nValImpD][2] := (1/(10**nDecs))
					nDifVIpD				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpD,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpD][2]  += NoRound(nDifVIpD,nDecs)
					nDifVIpD		       -= NoRound(nDifVIpD,nDecs)
				EndIf
			EndIf
		EndIf

		If ACPOIMP[_D1_BASIMPE]
			If aImp[14][1] > 0  //base
				aItens[nX][nBasImpE][2]:= NoRound(nPorcTotal * aImp[14][1] , nDecs, @nDifBIpE )
				aItens[nX][nAlqImpE][2]:= aImp[14][2]
				If Empty(aItens[nX][nBasImpE][2])
					aItens[nX][nBasImpE][2] := (1/(10**nDecs))
					nDifBIpE				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpE,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpE][2]  += NoRound(nDifBIpE,nDecs)
					nDifBIpE		       -= NoRound(nDifBIpE,nDecs)
				EndIf
			EndIf

			If aImp[14][3] > 0  //valor
				aItens[nX][nValImpE][2]:= NoRound(nPorcTotal * aImp[14][3] , nDecs, @nDifVIpE )
				If Empty(aItens[nX][nValImpE][2])
					aItens[nX][nValImpE][2] := (1/(10**nDecs))
					nDifVIpE				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpE,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpE][2]  += NoRound(nDifVIpE,nDecs)
					nDifVIpE		       -= NoRound(nDifVIpE,nDecs)
				EndIf
			EndIf
		EndIf

		If ACPOIMP[_D1_BASIMPF]
			If aImp[15][1] > 0  //base
				aItens[nX][nBasImpF][2]:= NoRound(nPorcTotal * aImp[15][1] , nDecs, @nDifBIpF )
				aItens[nX][nAlqImpF][2]:= aImp[15][2]
				If Empty(aItens[nX][nBasImpF][2])
					aItens[nX][nBasImpF][2] := (1/(10**nDecs))
					nDifBIpF				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpF,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpF][2]  += NoRound(nDifBIpF,nDecs)
					nDifBIpF		       -= NoRound(nDifBIpF,nDecs)
				EndIf
			EndIf

			If aImp[15][3] > 0  //valor
				aItens[nX][nValImpF][2]:= NoRound(nPorcTotal * aImp[15][3] , nDecs, @nDifVIpF )
				If Empty(aItens[nX][nValImpF][2])
					aItens[nX][nValImpF][2] := (1/(10**nDecs))
					nDifVIpF				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpF,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpF][2]  += NoRound(nDifVIpF,nDecs)
					nDifVIpF		       -= NoRound(nDifVIpF,nDecs)
				EndIf
			EndIf
		EndIf

		If ACPOIMP[_D1_BASIMPG]
			If aImp[16][1] > 0  //base
				aItens[nX][nBasImpG][2]:= NoRound(nPorcTotal * aImp[16][1] , nDecs, @nDifBIpG )
				aItens[nX][nAlqImpG][2]:= aImp[16][2]
				If Empty(aItens[nX][nBasImpG][2])
					aItens[nX][nBasImpG][2] := (1/(10**nDecs))
					nDifBIpG				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpG,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpG][2]  += NoRound(nDifBIpG,nDecs)
					nDifBIpG		       -= NoRound(nDifBIpG,nDecs)
				EndIf
			EndIf

			If aImp[16][3] > 0  //valor
				aItens[nX][nValImpG][2]:= NoRound(nPorcTotal * aImp[16][3] , nDecs, @nDifVIpG )
				If Empty(aItens[nX][nValImpG][2])
					aItens[nX][nValImpG][2] := (1/(10**nDecs))
					nDifVIpG				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpG,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpG][2]  += NoRound(nDifVIpG,nDecs)
					nDifVIpG		       -= NoRound(nDifVIpG,nDecs)
				EndIf
			EndIf
		EndIf

		If ACPOIMP[_D1_BASIMPH]
			If aImp[17][1] > 0  //base
				aItens[nX][nBasImpH][2]:= NoRound(nPorcTotal * aImp[17][1] , nDecs, @nDifBIpH )
				aItens[nX][nAlqImpH][2]:= aImp[17][2]
				If Empty(aItens[nX][nBasImpH][2])
					aItens[nX][nBasImpH][2] := (1/(10**nDecs))
					nDifBIpH				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpH,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpH][2]  += NoRound(nDifBIpH,nDecs)
					nDifBIpH		       -= NoRound(nDifBIpH,nDecs)
				EndIf
			EndIf

			If aImp[17][3] > 0  //valor
				aItens[nX][nValImpH][2]:= NoRound(nPorcTotal * aImp[17][3] , nDecs, @nDifVIpH )
				If Empty(aItens[nX][nValImpH][2])
					aItens[nX][nValImpH][2] := (1/(10**nDecs))
					nDifVIpH				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpH,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpH][2]  += NoRound(nDifVIpH,nDecs)
					nDifVIpH		       -= NoRound(nDifVIpH,nDecs)
				EndIf
			EndIf
		EndIf

		If ACPOIMP[_D1_BASIMPI]
			If aImp[18][1] > 0  //base
				aItens[nX][nBasImpI][2]:= NoRound(nPorcTotal * aImp[18][1] , nDecs, @nDifBIpI )
				aItens[nX][nAlqImpI][2]:= aImp[18][2]
				If Empty(aItens[nX][nBasImpI][2])
					aItens[nX][nBasImpI][2] := (1/(10**nDecs))
					nDifBIpI				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpI,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpI][2]  += NoRound(nDifBIpI,nDecs)
					nDifBIpI		       -= NoRound(nDifBIpI,nDecs)
				EndIf
			EndIf

			If aImp[18][3] > 0  //valor
				aItens[nX][nValImpI][2]:= NoRound(nPorcTotal * aImp[18][3] , nDecs, @nDifVIpI )
				If Empty(aItens[nX][nValImpI][2])
					aItens[nX][nValImpI][2] := (1/(10**nDecs))
					nDifVIpI				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpI,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpI][2]  += NoRound(nDifVIpI,nDecs)
					nDifVIpI		       -= NoRound(nDifVIpI,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPJ]
			If aImp[19][1] > 0  //base
				aItens[nX][nBasImpJ][2]:= NoRound(nPorcTotal * aImp[19][1] , nDecs, @nDifBIpJ )
				aItens[nX][nAlqImpJ][2]:= aImp[19][2]
				If Empty(aItens[nX][nBasImpJ][2])
					aItens[nX][nBasImpJ][2] := (1/(10**nDecs))
					nDifBIpJ				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpJ,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpJ][2]  += NoRound(nDifBIpJ,nDecs)
					nDifBIpJ		       -= NoRound(nDifBIpJ,nDecs)
				EndIf
			EndIf

			If aImp[19][3] > 0  //valor
				aItens[nX][nValImpJ][2]:= NoRound(nPorcTotal * aImp[19][3] , nDecs, @nDifVIpJ )
				If Empty(aItens[nX][nValImpJ][2])
					aItens[nX][nValImpJ][2] := (1/(10**nDecs))
					nDifVIpJ				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpJ,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpJ][2]  += NoRound(nDifVIpJ,nDecs)
					nDifVIpJ		       -= NoRound(nDifVIpJ,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPK]
			If aImp[20][1] > 0  //base
				aItens[nX][nBasImpK][2]:= NoRound(nPorcTotal * aImp[20][1] , nDecs, @nDifBIpK )
				aItens[nX][nAlqImpK][2]:= aImp[20][2]
				If Empty(aItens[nX][nBasImpK][2])
					aItens[nX][nBasImpK][2] := (1/(10**nDecs))
					nDifBIpK				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpK,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpK][2]  += NoRound(nDifBIpK,nDecs)
					nDifBIpK		       -= NoRound(nDifBIpK,nDecs)
				EndIf
			EndIf

			If aImp[20][3] > 0  //valor
				aItens[nX][nValImpK][2]:= NoRound(nPorcTotal * aImp[20][3] , nDecs, @nDifVIpK )
				If Empty(aItens[nX][nValImpK][2])
					aItens[nX][nValImpK][2] := (1/(10**nDecs))
					nDifVIpK				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpK,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpK][2]  += NoRound(nDifVIpK,nDecs)
					nDifVIpK		       -= NoRound(nDifVIpK,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPL]
			If aImp[21][1] > 0  //base
				aItens[nX][nBasImpL][2]:= NoRound(nPorcTotal * aImp[21][1] , nDecs, @nDifBIpL )
				aItens[nX][nAlqImpL][2]:= aImp[21][2]
				If Empty(aItens[nX][nBasImpL][2])
					aItens[nX][nBasImpL][2] := (1/(10**nDecs))
					nDifBIpL				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpL,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpL][2]  += NoRound(nDifBIpL,nDecs)
					nDifBIpL		       -= NoRound(nDifBIpL,nDecs)
				EndIf
			EndIf

			If aImp[21][3] > 0  //valor
				aItens[nX][nValImpL][2]:= NoRound(nPorcTotal * aImp[21][3] , nDecs, @nDifVIpL )
				If Empty(aItens[nX][nValImpL][2])
					aItens[nX][nValImpL][2] := (1/(10**nDecs))
					nDifVIpL				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpL,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpL][2]  += NoRound(nDifVIpL,nDecs)
					nDifVIpL		       -= NoRound(nDifVIpL,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPM]
			If aImp[22][1] > 0  //base
				aItens[nX][nBasImpM][2]:= NoRound(nPorcTotal * aImp[22][1] , nDecs, @nDifBIpM )
				aItens[nX][nAlqImpM][2]:= aImp[22][2]
				If Empty(aItens[nX][nBasImpM][2])
					aItens[nX][nBasImpM][2] := (1/(10**nDecs))
					nDifBIpM				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpM,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpM][2]  += NoRound(nDifBIpM,nDecs)
					nDifBIpM		       -= NoRound(nDifBIpM,nDecs)
				EndIf
			EndIf

			If aImp[22][3] > 0  //valor
				aItens[nX][nValImpM][2]:= NoRound(nPorcTotal * aImp[22][3] , nDecs, @nDifVIpM )
				If Empty(aItens[nX][nValImpM][2])
					aItens[nX][nValImpM][2] := (1/(10**nDecs))
					nDifVIpM				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpM,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpM][2]  += NoRound(nDifVIpM,nDecs)
					nDifVIpM		       -= NoRound(nDifVIpM,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPN]
			If aImp[23][1] > 0  //base
				aItens[nX][nBasImpN][2]:= NoRound(nPorcTotal * aImp[23][1] , nDecs, @nDifBIpN )
				aItens[nX][nAlqImpN][2]:= aImp[23][2]
				If Empty(aItens[nX][nBasImpN][2])
					aItens[nX][nBasImpN][2] := (1/(10**nDecs))
					nDifBIpN				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpN,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpN][2]  += NoRound(nDifBIpN,nDecs)
					nDifBIpN		       -= NoRound(nDifBIpN,nDecs)
				EndIf
			EndIf

			If aImp[23][3] > 0  //valor
				aItens[nX][nValImpN][2]:= NoRound(nPorcTotal * aImp[23][3] , nDecs, @nDifVIpN )
				If Empty(aItens[nX][nValImpN][2])
					aItens[nX][nValImpN][2] := (1/(10**nDecs))
					nDifVIpN				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpN,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpN][2]  += NoRound(nDifVIpN,nDecs)
					nDifVIpN		       -= NoRound(nDifVIpN,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPO]
			If aImp[24][1] > 0  //base
				aItens[nX][nBasImpO][2]:= NoRound(nPorcTotal * aImp[24][1] , nDecs, @nDifBIpO )
				aItens[nX][nAlqImpO][2]:= aImp[24][2]
				If Empty(aItens[nX][nBasImpO][2])
					aItens[nX][nBasImpO][2] := (1/(10**nDecs))
					nDifBIpO				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpO,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpO][2]  += NoRound(nDifBIpO,nDecs)
					nDifBIpO		       -= NoRound(nDifBIpO,nDecs)
				EndIf
			EndIf

			If aImp[24][3] > 0  //valor
				aItens[nX][nValImpO][2]:= NoRound(nPorcTotal * aImp[24][3] , nDecs, @nDifVIpO )
				If Empty(aItens[nX][nValImpO][2])
					aItens[nX][nValImpO][2] := (1/(10**nDecs))
					nDifVIpO				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpO,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpO][2]  += NoRound(nDifVIpO,nDecs)
					nDifVIpO		       -= NoRound(nDifVIpO,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPP]
			If aImp[25][1] > 0  //base
				aItens[nX][nBasImpP][2]:= NoRound(nPorcTotal * aImp[25][1] , nDecs, @nDifBIpP )
				aItens[nX][nAlqImpP][2]:= aImp[25][2]
				If Empty(aItens[nX][nBasImpP][2])
					aItens[nX][nBasImpP][2] := (1/(10**nDecs))
					nDifBIpP				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpP,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpP][2]  += NoRound(nDifBIpP,nDecs)
					nDifBIpP		       -= NoRound(nDifBIpP,nDecs)
				EndIf
			EndIf

			If aImp[25][3] > 0  //valor
				aItens[nX][nValImpP][2]:= NoRound(nPorcTotal * aImp[25][3] , nDecs, @nDifVIpP )
				If Empty(aItens[nX][nValImpP][2])
					aItens[nX][nValImpP][2] := (1/(10**nDecs))
					nDifVIpP				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpP,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpP][2]  += NoRound(nDifVIpP,nDecs)
					nDifVIpP		       -= NoRound(nDifVIpP,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPQ]
			If aImp[26][1] > 0  //base
				aItens[nX][nBasImpQ][2]:= NoRound(nPorcTotal * aImp[26][1] , nDecs, @nDifBIpQ )
				aItens[nX][nAlqImpQ][2]:= aImp[26][2]
				If Empty(aItens[nX][nBasImpQ][2])
					aItens[nX][nBasImpQ][2] := (1/(10**nDecs))
					nDifBIpQ				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpQ,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpQ][2]  += NoRound(nDifBIpQ,nDecs)
					nDifBIpQ		       -= NoRound(nDifBIpQ,nDecs)
				EndIf
			EndIf

			If aImp[26][3] > 0  //valor
				aItens[nX][nValImpQ][2]:= NoRound(nPorcTotal * aImp[26][3] , nDecs, @nDifVIpQ )
				If Empty(aItens[nX][nValImpQ][2])
					aItens[nX][nValImpQ][2] := (1/(10**nDecs))
					nDifVIpQ				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpQ,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpQ][2]  += NoRound(nDifVIpQ,nDecs)
					nDifVIpQ		       -= NoRound(nDifVIpQ,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPR]
			If aImp[27][1] > 0  //base
				aItens[nX][nBasImpR][2]:= NoRound(nPorcTotal * aImp[27][1] , nDecs, @nDifBIpR )
				aItens[nX][nAlqImpR][2]:= aImp[27][2]
				If Empty(aItens[nX][nBasImpR][2])
					aItens[nX][nBasImpR][2] := (1/(10**nDecs))
					nDifBIpR				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpR,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpR][2]  += NoRound(nDifBIpR,nDecs)
					nDifBIpR		       -= NoRound(nDifBIpR,nDecs)
				EndIf
			EndIf

			If aImp[27][3] > 0  //valor
				aItens[nX][nValImpR][2]:= NoRound(nPorcTotal * aImp[27][3] , nDecs, @nDifVIpR )
				If Empty(aItens[nX][nValImpR][2])
					aItens[nX][nValImpR][2] := (1/(10**nDecs))
					nDifVIpR				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpR,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpR][2]  += NoRound(nDifVIpR,nDecs)
					nDifVIpR		       -= NoRound(nDifVIpR,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPS]
			If aImp[28][1] > 0  //base
				aItens[nX][nBasImpS][2]:= NoRound(nPorcTotal * aImp[28][1] , nDecs, @nDifBIpS )
				aItens[nX][nAlqImpS][2]:= aImp[28][2]
				If Empty(aItens[nX][nBasImpS][2])
					aItens[nX][nBasImpS][2] := (1/(10**nDecs))
					nDifBIpS				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpS,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpS][2]  += NoRound(nDifBIpS,nDecs)
					nDifBIpS		       -= NoRound(nDifBIpS,nDecs)
				EndIf
			EndIf

			If aImp[28][3] > 0  //valor
				aItens[nX][nValImpS][2]:= NoRound(nPorcTotal * aImp[28][3] , nDecs, @nDifVIpS )
				If Empty(aItens[nX][nValImpS][2])
					aItens[nX][nValImpS][2] := (1/(10**nDecs))
					nDifVIpS				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpS,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpS][2]  += NoRound(nDifVIpS,nDecs)
					nDifVIpS		       -= NoRound(nDifVIpS,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPT]
			If aImp[29][1] > 0  //base
				aItens[nX][nBasImpT][2]:= NoRound(nPorcTotal * aImp[29][1] , nDecs, @nDifBIpT )
				aItens[nX][nAlqImpT][2]:= aImp[29][2]
				If Empty(aItens[nX][nBasImpT][2])
					aItens[nX][nBasImpT][2] := (1/(10**nDecs))
					nDifBIpT				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpT,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpT][2]  += NoRound(nDifBIpT,nDecs)
					nDifBIpT		       -= NoRound(nDifBIpT,nDecs)
				EndIf
			EndIf

			If aImp[29][3] > 0  //valor
				aItens[nX][nValImpT][2]:= NoRound(nPorcTotal * aImp[29][3] , nDecs, @nDifVIpT )
				If Empty(aItens[nX][nValImpT][2])
					aItens[nX][nValImpT][2] := (1/(10**nDecs))
					nDifVIpT				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpT,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpT][2]  += NoRound(nDifVIpT,nDecs)
					nDifVIpT		       -= NoRound(nDifVIpT,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPU]
			If aImp[30][1] > 0  //base
				aItens[nX][nBasImpU][2]:= NoRound(nPorcTotal * aImp[30][1] , nDecs, @nDifBIpU )
				aItens[nX][nAlqImpU][2]:= aImp[30][2]
				If Empty(aItens[nX][nBasImpU][2])
					aItens[nX][nBasImpU][2] := (1/(10**nDecs))
					nDifBIpU				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpU,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpU][2]  += NoRound(nDifBIpU,nDecs)
					nDifBIpU		       -= NoRound(nDifBIpU,nDecs)
				EndIf
			EndIf

			If aImp[30][3] > 0  //valor
				aItens[nX][nValImpU][2]:= NoRound(nPorcTotal * aImp[30][3] , nDecs, @nDifVIpU )
				If Empty(aItens[nX][nValImpU][2])
					aItens[nX][nValImpU][2] := (1/(10**nDecs))
					nDifVIpU				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpU,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpU][2]  += NoRound(nDifVIpU,nDecs)
					nDifVIpU		       -= NoRound(nDifVIpU,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPV]
			If aImp[31][1] > 0  //base
				aItens[nX][nBasImpV][2]:= NoRound(nPorcTotal * aImp[31][1] , nDecs, @nDifBIpV )
				aItens[nX][nAlqImpV][2]:= aImp[31][2]
				If Empty(aItens[nX][nBasImpV][2])
					aItens[nX][nBasImpV][2] := (1/(10**nDecs))
					nDifBIpV				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpV,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpV][2]  += NoRound(nDifBIpV,nDecs)
					nDifBIpV		       -= NoRound(nDifBIpV,nDecs)
				EndIf
			EndIf

			If aImp[31][3] > 0  //valor
				aItens[nX][nValImpV][2]:= NoRound(nPorcTotal * aImp[31][3] , nDecs, @nDifVIpV )
				If Empty(aItens[nX][nValImpV][2])
					aItens[nX][nValImpV][2] := (1/(10**nDecs))
					nDifVIpV				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpV,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpV][2]  += NoRound(nDifVIpV,nDecs)
					nDifVIpV		       -= NoRound(nDifVIpV,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPW]
			If aImp[32][1] > 0  //base
				aItens[nX][nBasImpW][2]:= NoRound(nPorcTotal * aImp[32][1] , nDecs, @nDifBIpW )
				aItens[nX][nAlqImpW][2]:= aImp[32][2]
				If Empty(aItens[nX][nBasImpW][2])
					aItens[nX][nBasImpW][2] := (1/(10**nDecs))
					nDifBIpW				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpW,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpW][2]  += NoRound(nDifBIpW,nDecs)
					nDifBIpW		       -= NoRound(nDifBIpW,nDecs)
				EndIf
			EndIf

			If aImp[32][3] > 0  //valor
				aItens[nX][nValImpW][2]:= NoRound(nPorcTotal * aImp[32][3] , nDecs, @nDifVIpW )
				If Empty(aItens[nX][nValImpW][2])
					aItens[nX][nValImpW][2] := (1/(10**nDecs))
					nDifVIpW				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpW,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpW][2]  += NoRound(nDifVIpW,nDecs)
					nDifVIpW		       -= NoRound(nDifVIpW,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPX]
			If aImp[33][1] > 0  //base
				aItens[nX][nBasImpX][2]:= NoRound(nPorcTotal * aImp[33][1] , nDecs, @nDifBIpX )
				aItens[nX][nAlqImpX][2]:= aImp[33][2]
				If Empty(aItens[nX][nBasImpX][2])
					aItens[nX][nBasImpX][2] := (1/(10**nDecs))
					nDifBIpX				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpX,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpX][2]  += NoRound(nDifBIpX,nDecs)
					nDifBIpX		       -= NoRound(nDifBIpX,nDecs)
				EndIf
			EndIf

			If aImp[33][3] > 0  //valor
				aItens[nX][nValImpX][2]:= NoRound(nPorcTotal * aImp[33][3] , nDecs, @nDifVIpX )
				If Empty(aItens[nX][nValImpX][2])
					aItens[nX][nValImpX][2] := (1/(10**nDecs))
					nDifVIpX				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpX,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpX][2]  += NoRound(nDifVIpX,nDecs)
					nDifVIpX		       -= NoRound(nDifVIpX,nDecs)
				EndIf
			EndIf
		Endif
		If ACPOIMP[_D1_BASIMPY]
			If aImp[34][1] > 0  //base
				aItens[nX][nBasImpY][2]:= NoRound(nPorcTotal * aImp[34][1] , nDecs, @nDifBIpY )
				aItens[nX][nAlqImpY][2]:= aImp[34][2]
				If Empty(aItens[nX][nBasImpY][2])
					aItens[nX][nBasImpY][2] := (1/(10**nDecs))
					nDifBIpY				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpY,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpY][2]  += NoRound(nDifBIpY,nDecs)
					nDifBIpY		       -= NoRound(nDifBIpY,nDecs)
				EndIf
			EndIf

			If aImp[34][3] > 0  //valor
				aItens[nX][nValImpY][2]:= NoRound(nPorcTotal * aImp[34][3] , nDecs, @nDifVIpY )
				If Empty(aItens[nX][nValImpY][2])
					aItens[nX][nValImpY][2] := (1/(10**nDecs))
					nDifVIpY				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpY,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpY][2]  += NoRound(nDifVIpY,nDecs)
					nDifVIpY		       -= NoRound(nDifVIpY,nDecs)
				EndIf
			EndIf
		Endif

		If ACPOIMP[_D1_BASIMPZ]
			If aImp[35][1] > 0  //base
				aItens[nX][nBasImpZ][2]:= NoRound(nPorcTotal * aImp[35][1] , nDecs, @nDifBIpZ )
				aItens[nX][nAlqImpZ][2]:= aImp[35][2]
				If Empty(aItens[nX][nBasImpZ][2])
					aItens[nX][nBasImpZ][2] := (1/(10**nDecs))
					nDifBIpZ				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifBIpZ,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nBasImpZ][2]  += NoRound(nDifBIpZ,nDecs)
					nDifBIpZ		       -= NoRound(nDifBIpZ,nDecs)
				EndIf
			EndIf

			If aImp[35][3] > 0  //valor
				aItens[nX][nValImpZ][2]:= NoRound(nPorcTotal * aImp[35][3] , nDecs, @nDifVIpZ )
				If Empty(aItens[nX][nValImpZ][2])
					aItens[nX][nValImpZ][2] := (1/(10**nDecs))
					nDifVIpZ				  -= (1/(10**nDecs))
				ElseIf NoRound(nDifVIpZ,nDecs)   >= (1/(10**nDecs))
					aItens[nX][nValImpZ][2]  += NoRound(nDifVIpZ,nDecs)
					nDifVIpZ		       -= NoRound(nDifVIpZ,nDecs)
				EndIf
			EndIf
		EndIf
	EndIf
	ENDIF
	If !lEnd
		If !lAutomato
			oProcess:IncRegua2(STR0083+Alltrim(STR(nX))+"/"+Alltrim(STR(Len(aItens))) ) // "Atualizando item "
		Endif
	Else
		Exit
	Endif

Next nX

If cPaisLoc $ "PER|COL|EQU"
	nDif := nValDesp - nTotalAjust
	If nDif <> 0
		aItens[Len(aItens)][nPosTotal][2] += nDif
	Endif
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	  ³A143ChkLst  ³ Autor ³ Eduardo Dias       ³ Data ³ 04.09.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Monta Checklist                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³A143ChkLst()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³COMPRAS - ANGOLA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A143ChkLst(nOpc)

Local aArea       := GetArea()
Local nX,nY       := 0
Local nBKP        := n
Local nOpcC       := 0
Local oDlg1, oGet1
Local aHeaderBKP  := aClone(aHeader)
Local aColsBKP	  := aClone(aCols)

Acols := {}; aHeader:= {}

If cPaisLoc $ "ANG|EQU|HAI" .And. nOpc == 3 // Inclusão
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do aHeader e aCols (1) usando a Funcao FillGetDados  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DBG")

	DEFINE MSDIALOG oDlg1 TITLE STR0088 FROM 000,000 TO 275,625 OF oMainWnd PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FillGetDados(nOpc,"DBG",1,,,,{"DBG_FILIAL", "DBG_NRPROC", "DBG_OK"},,,,,.T.)

	aHeader:=If(Empty(aHeaderChk),aHeader,aHeaderChk)
	ACols  :=If(Empty(aColsChk),ACols,aColsChk)

	oGet1:= MSGetDados():New(016,002,136,312,nOpc,"A143ChkLOk","A143ChkTOk","",If(nOpc==2 .Or. nOpc==5,.F.,.T.),,,,999)

	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| If(A143ChkTOk(),(nOpcC:=1,oDlg1:End()),nOpcC:=2)},{||oDlg1:End()}) CENTERED

	If nOpcC == 2
		aColsChk   := {}
	EndIf

ElseIf cPaisLoc $ "ANG|EQU|HAI" .And. nOpc == 4 // Alteração
	dbSelectArea("DBG")

	DBG->(DbSeek(xFilial("DBG")+M->DBA_HAWB))

	While DBG->(!Eof()) .And. DBG->DBG_NRPROC == M->DBA_HAWB
		CN5->(DbSetOrDer(1))
	    CN5->(DbSeek(xFilial("CN5")+DBG->DBG_TIPDOC))
		aAdd(aColsChk,{lOkMark:=If(Empty(DBG->DBG_OK),.F.,.T.),DBG->DBG_TIPDOC,CN5->CN5_DESCRI})
		DBG->(DbSkip())
	End

	If !Empty(aColsChk)
		a143MrkList()
	EndIf

EndIf

// Limpa aCols do Cheklist ao cancelar a inclusão na msgetdados
aHeader	   := aClone(aHeaderBKP)
aCols  	   := aClone(aColsBKP)
n          := nBKP
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	  ³A143ChkLOk  ³ Autor ³ Eduardo Dias       ³ Data ³ 04.09.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Validacao da amarracao Processo X Documento (Linha)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³A143ChkLOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³COMPRAS - ANGOLA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A143ChkLOk()

Local aArea	:=GetArea()
Local lRet	:= .T.
Local nPos  := 0

If cPaisLoc == 'ANG' .AND. lRet
	nPos := aScan(aCols,{|x| x[1] == aCols[n][1]})

	If Empty( aCols[n][1] )
		lRet := .F.
		Aviso(STR0026,STR0090,{"OK"})
	ElseIf nPos < N
		If acols[n][len(acols[n])] == .F.
			lRet := .F.
			Aviso(STR0026,STR0089,{"OK"})
		EndIf
	Endif
EndIf

RestArea(aArea)
Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A143VlTDocºAutor  ³Eduardo Dias        º Data ³  07/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação do Tipo de Documento                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMPRAS - ANGOLA                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A143VlTDoc()
Local lRet := .T.

lRet := ExistCpo("CN5",M->DBG_TIPDOC) .And. ExistChav("DBG",M->DBA_HAWB+M->DBG_TIPDOC)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	  ³A143ChkTOk  ³ Autor ³ Eduardo Dias       ³ Data ³ 05.09.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Valida a inclusao do documento a ser analisado            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³A143ChkTOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³COMPRAS - ANGOLA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A143ChkTOk()

Local aArea		:= GetArea()
Local lRet		:= .T.
Local nPos  	:= 0
Local nX    	:= 0
aColsChk := {}
aHeaderChk := aClone(aHeader) // Faz Bkp do AHeader relacionado ao Cheklist para apresentar novamente


// Tira do Acols do Cheklist os itens deletados
If cPaisLoc == 'ANG'
	For nX := 1 To Len(aCols)
		If acols[nX][len(acols[nX])] == .F. .And. !Empty(aCols[nX][1])
			aAdd(aColsChk,aCols[nX])   // Faz Bkp do aCols relacionado ao Cheklist para apresentar novamente
		EndIf
	NexT
EndIf
// Quando o item não estiver deletado ou vazio, verifica a sua primeira posição no acols
If (n <= Len(aColsChk),nPos:= aScan(aColsChk,{|x| x[1] == aColsChk[n][1]}), nPos:= 0)

// Valida se existe item duplicado na amarração do Processo X Documento
If  nPos > 0
	If nPos < N
		lRet := .F.
		MsgStop (STR0085) //Não poderá ser gravado mais que uma amarração para o mesmo tipo de documento relacionado ao processo!
	EndIf
Endif

RestArea(aArea)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	  ³a143MrkList ³ Autor ³ Eduardo Dias       ³ Data ³ 07.09.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Valida a inclusao do documento a ser analisado            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³a143MrkList()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³COMPRAS - ANGOLA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a143MrkList()

Local aArea:= GetArea()
Local aTitCampos := {"","TP Doc","Descrição"}
Local cLine    := ""
Local bLine    := ""
Local nOpcA := 0
Local nX,nY		:= 0
Local aButtons	:= {}
Local oListBox
Local oOk   	:= LoadBitMap(GetResources(), "LBOK")
Local oNo    	:= LoadBitMap(GetResources(), "LBNO")



cLine:= "{If(aColsChk[oListBox:nAt,1],oOk,oNo),aColsChk[oListBox:nAT][2],aColsChk[oListBox:nAT][3]} "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dinamicamente o bline do CodeBlock                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == 'ANG'
	bLine := &( "{ || " + cLine + " }" )
	DEFINE MSDIALOG oDlgCHK FROM 050,040  TO 285,541 TITLE "Check-List" Of oMainWnd PIXEL
	oListBox:=TWBrowse():New( 027,004,243,086,,aTitCampos,,oDlgCHK,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListBox:SetArray(aColsChk)
	oListBox:bLDblClick := { || aColsChk[oListBox:nAt,1] := !aColsChk[oListBox:nAt,1] }
	oListBox:bLine := bLine
EndIf

ACTIVATE MSDIALOG oDlgCHK CENTERED ON INIT EnchoiceBar(oDlgCHK,{||(nOpcA :=1, oDlgCHK:End())},{||(nOpcA := 0,oDlgCHK:End())},,aButtons)
If nOpcA == 0
	aColsChk:= {}
EndIF

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	  ³a143NumRef  ³ Autor ³ Rodrigo Toledo     ³ Data ³ 08.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Cria o numero de referendo do controle especifico para    ³±±
±±³			  ³ localizacao Equador.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³a143NumRef()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³COMPRAS - EQUADOR                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a143NumRef()
Local cQuery  := ""
Local cNumRef := ""

If cPaisLoc == "EQU" .And. !Empty(M->DBA_DISADU) .And. !Empty(M->DBA_REGIMP)
	cNumRef := M->DBA_DISADU+Left(DToS(M->DBA_DTHAWB),4)+M->DBA_REGIMP
	#IFDEF TOP
		cQuery := "SELECT MAX(DBA_NUMREF) AS NumRef "
		cQuery += "FROM "+RetSqlName("DBA")+" DBA "
		cQuery += "WHERE DBA.DBA_FILIAL='"+xFilial("DBA")+"' AND "
		cQuery += "DBA.DBA_NUMREF LIKE '"+cNumRef+"%' AND "
		cQuery += "DBA.D_E_L_E_T_<>'*' "
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBDBA",.T.,.T.)
		cNumRef := IIF(Empty(TRBDBA->NumRef),cNumRef+"0000010",cNumRef+Soma1(Substr(NumRef,10,6))+"0")
		TRBDBA->(dbCloseArea())
	#ELSE
		cFilDBA := 'Substr(DBA_NUMREF,1,9) == "'+cNumRef+'"'
		DBA->(dbSetFilter({|| &cFilDBA}, cFilDBA))
		DBA->(DbGoTop())
		If Empty(DBA->DBA_NUMREF)
			cNumRef := cNumRef+"0000010"
		Else
			While !Eof() .And. DBA->DBA_FILIAL == xFilial("DBA")
				If DBA->DBA_NUMREF >= cNumRef
			  		cNumRef := M->DBA_DISADU+Left(DToS(M->DBA_DTHAWB),4)+M->DBA_REGIMP+(Soma1(Substr(DBA->DBA_NUMREF,10,6)))+"0"
			  	EndIf
			  	DBA->(dbSkip())
			End
		EndIf
		DBA->(DbClearFilter())
	#ENDIF
	M->DBA_NUMREF := cNumRef
EndIf

Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A143FldIt    ³ Autor ³ TOTVS                 ³ Data ³ 12/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Forca mudança para o Folder de Itens ao alterar imposto        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A143FldIt()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum	  										      	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ COMPRAS INTERNACIONAL                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143FldIt(oFldInv)

If oFldInv:nOption == 1
	oFldInv:SetOption(2)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A143GetLoja³ Autor ³Aline Sebrian  		 ³Data  ³27/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornar a Loja de acordo com o fornecedor.				  ³±±
±±³			 ³ Chamada pelo gatilho do campoDBB_FORNEC.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GCT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A143GetLoja()
Local nPosLoja   := 0
Local cLoja      := ""
Local lRotAuto   := Type("lMsHelpAuto") == "L" .And. lMsHelpAuto
Local cFilSA2    := xFilial("SA2")

If !lRotAuto
	nPosLoja   := aScan(aHeader,{|x| x[2] == "DBB_LOJA  "})
	SA2->(dbSetOrder(1))	//A2_FILIAL+A2_COD+A2_LOJA

	If !Empty(aCols[n][nPosLoja])
		SA2->(MsSeek(xFilial("SA2")+M->DBB_FORNEC+aCols[n][nPosLoja]))
		If SA2->(Found())
			cLoja := SA2->A2_LOJA
		EndIf
	EndIf

	If Empty(cLoja)
		SA2->(MsSeek(cFilSA2+M->DBB_FORNEC))
		If SA2->(Found())
			While !SA2->(EoF()) .And. SA2->(A2_FILIAL+A2_COD) == cFilSA2+M->DBB_FORNEC
				If !(SA2->A2_MSBLQL == "1")
					cLoja  := SA2->A2_LOJA
					Exit
				EndIf
				SA2->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf

Return cLoja


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M143CalImp   ³ Autor ³ TOTVS                 ³ Data ³ 12/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Forca mudança para o Folder de Itens ao alterar imposto        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M143CalImp                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum	  									           	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ COMPRAS INTERNACIONAL                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function M143CalImp(acampCab,aItemCab,acampDad,aItemDad)

local ni := 1
Local nBasImp1	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMP1"})
Local nValImp1	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMP1"})
Local nALQImp1	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMP1"})
Local nBasImp2	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMP2"})
Local nValImp2	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMP2"})
Local nALQImp2	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMP2"})
Local nBasImp3	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMP3"})
Local nValImp3	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMP3"})
Local nALQImp3	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMP3"})
Local nBasImp4	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMP4"})
Local nValImp4	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMP4"})
Local nALQImp4	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMP4"})
Local nBasImp5	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMP5"})
Local nValImp5	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMP5"})
Local nALQImp5	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMP5"})
Local nBasImp6	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMP6"})
Local nValImp6	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMP6"})
Local nALQImp6	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMP6"})
Local nBasImp7	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMP7"})
Local nValImp7	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMP7"})
Local nALQImp7	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMP7"})
Local nBasImp8	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMP8"})
Local nValImp8	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMP8"})
Local nALQImp8	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMP8"})
Local nBasImp9	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMP9"})
Local nValImp9	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMP9"})
Local nALQImp9	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMP9"})
Local nBasImpA	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPA"})
Local nValImpA	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPA"})
Local nALQImpA	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPA"})
Local nBasImpB	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPB"})
Local nValImpB	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPB"})
Local nALQImpB	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPB"})
Local nBasImpC	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPC"})
Local nValImpC	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPC"})
Local nALQImpC	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPC"})
Local nBasImpD	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPD"})
Local nValImpD	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPD"})
Local nALQImpD	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPD"})
Local nBasImpE	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPE"})
Local nValImpE	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPE"})
Local nALQImpE	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPE"})
Local nBasImpF	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPF"})
Local nValImpF	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPF"})
Local nALQImpF	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPF"})
Local nBasImpG	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPG"})
Local nValImpG	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPG"})
Local nALQImpG	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPG"})
Local nBasImpH	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPH"})
Local nValImpH	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPH"})
Local nALQImpH	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPH"})
Local nBasImpI	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPI"})
Local nValImpI	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPI"})
Local nALQImpI	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPI"})
Local nBasImpJ	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPJ"})
Local nValImpJ	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPJ"})
Local nALQImpJ	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPJ"})
Local nBasImpK	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPK"})
Local nValImpK	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPK"})
Local nALQImpK	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPK"})
Local nBasImpL	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPL"})
Local nValImpL	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPL"})
Local nALQImpL	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPL"})
Local nBasImpM	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPM"})
Local nValImpM	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPM"})
Local nALQImpM	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPM"})
Local nBasImpN	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPN"})
Local nValImpN	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPN"})
Local nALQImpN	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPN"})
Local nBasImpO	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPO"})
Local nValImpO	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPO"})
Local nALQImpO	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPO"})
Local nBasImpP	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPP"})
Local nValImpP	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPP"})
Local nALQImpP	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPP"})
Local nBasImpQ	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPQ"})
Local nValImpQ	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPQ"})
Local nALQImpQ	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPQ"})
Local nBasImpR	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPR"})
Local nValImpR	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPR"})
Local nALQImpR	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPR"})
Local nBasImpS	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPS"})
Local nValImpS	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPS"})
Local nALQImpS	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPS"})
Local nBasImpT	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPT"})
Local nValImpT	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPT"})
Local nALQImpT	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPT"})
Local nBasImpU	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPU"})
Local nValImpU	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPU"})
Local nALQImpU	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPU"})
Local nBasImpV	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPV"})
Local nValImpV	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPV"})
Local nALQImpV	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPV"})
Local nBasImpW	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPW"})
Local nValImpW	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPW"})
Local nALQImpW	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPW"})
Local nBasImpX	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPX"})
Local nValImpX	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPX"})
Local nALQImpX	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPX"})
Local nBasImpY	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPY"})
Local nValImpY	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPY"})
Local nALQImpY	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPY"})
Local nBasImpZ	:= aScan(acampDad,{|x| AllTrim(x)=="D1_BASIMPZ"})
Local nValImpZ	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALIMPZ"})
Local nALQImpZ	:= aScan(acampDad,{|x| AllTrim(x)=="D1_ALQIMPZ"})
Local nProd  	:= aScan(acampDad,{|x| AllTrim(x)=="D1_COD"})
Local nQtdVen  	:= aScan(acampDad,{|x| AllTrim(x)=="D1_QUANT"})
Local nValor   	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VUNIT"})
Local nTES     	:= aScan(acampDad,{|x| AllTrim(x)=="D1_TES"})
Local nTotal   	:= aScan(acampDad,{|x| AllTrim(x)=="D1_TOTAL"})
Local nCF      	:= aScan(acampDad,{|x| AllTrim(x)=="D1_CF"})
Local nPeso    	:= aScan(acampDad,{|x| AllTrim(x)=="D1_PESO"})
Local nValDesc  	:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALDESC"})
Local nFrete  		:= aScan(acampDad,{|x| AllTrim(x)=="D1_VALFRE"})
Local nSeguro  	:= aScan(acampDad,{|x| AllTrim(x)=="D1_SEGURO"})
Local nDespesa  	:= aScan(acampDad,{|x| AllTrim(x)=="D1_DESPESA"})
Local nFSerie  	:= aScan(acampCab,{|x| AllTrim(x)=="F1_SERIE"})
Local nFEst    	:= aScan(acampCab,{|x| AllTrim(x)=="F1_EST"})
Local nFFrete  	:= aScan(acampCab,{|x| AllTrim(x)=="F1_FRETE"})
Local nFDespesa 	:= aScan(acampCab,{|x| AllTrim(x)=="F1_DESPESA"})
Local nFValmerc 	:= aScan(acampCab,{|x| AllTrim(x)=="F1_VALMERC"})
Local nFValbrut 	:= aScan(acampCab,{|x| AllTrim(x)=="F1_VALBRUT"})
Local nFDescont 	:= aScan(acampCab,{|x| AllTrim(x)=="F1_DESCONT"})
Local nFSeguro 		:= aScan(acampCab,{|x| AllTrim(x)=="F1_SEGURO"})
Local nFMoeda 		:= aScan(acampCab,{|x| AllTrim(x)=="F1_MOEDA"})
Local nFTipodoc 	:= aScan(acampCab,{|x| AllTrim(x)=="F1_TIPODOC"})
Local nFProvent 	:= aScan(acampCab,{|x| AllTrim(x)=="F1_PROVENT"})
Local nFTxMoeda 	:= aScan(acampCab,{|x| AllTrim(x)=="F1_TXMOEDA"})
Local cProv		:=""
Local nBasCImp1:= 0
Local nValCImp1:= 0
Local nBasCImp2:= 0
Local nValCImp2:= 0
Local nBasCImp3:= 0
Local nValCImp3:= 0
Local nBasCImp4:= 0
Local nValCImp4:= 0
Local nBasCImp5:= 0
Local nValCImp5:= 0
Local nBasCImp6:= 0
Local nValCImp6:= 0
Local nBasCImp7:= 0
Local nValCImp7:= 0
Local nBasCImp8:= 0
Local nValCImp8:= 0
Local nBasCImp9:= 0
Local nValCImp9:= 0
Local nBasCImpA:= 0
Local nValCImpA:= 0
Local nBasCImpB:= 0
Local nValCImpB:= 0
Local nBasCImpC:= 0
Local nValCImpC:= 0
Local nBasCImpD:= 0
Local nValCImpD:= 0
Local nBasCImpE:= 0
Local nValCImpE:= 0
Local nBasCImpF:= 0
Local nValCImpF:= 0
Local nBasCImpG:= 0
Local nValCImpG:= 0
Local nBasCImpH:= 0
Local nValCImpH:= 0
Local nBasCImpI:= 0
Local nValCImpI:= 0
Local nBasCImpJ:= 0
Local nValCImpJ:= 0
Local nBasCImpK:= 0
Local nValCImpK:= 0
Local nBasCImpL:= 0
Local nValCImpL:= 0
Local nBasCImpM:= 0
Local nValCImpM:= 0
Local nBasCImpN:= 0
Local nValCImpN:= 0
Local nBasCImpO:= 0
Local nValCImpO:= 0
Local nBasCImpP:= 0
Local nValCImpP:= 0
Local nBasCImpQ:= 0
Local nValCImpQ:= 0
Local nBasCImpR:= 0
Local nValCImpR:= 0
Local nBasCImpS:= 0
Local nValCImpS:= 0
Local nBasCImpT:= 0
Local nValCImpT:= 0
Local nBasCImpU:= 0
Local nValCImpU:= 0
Local nBasCImpV:= 0
Local nValCImpV:= 0
Local nBasCImpW:= 0
Local nValCImpW:= 0
Local nBasCImpX:= 0
Local nValCImpX:= 0
Local nBasCImpY:= 0
Local nValCImpY:= 0
Local nBasCImpZ:= 0
Local nValCImpZ:= 0
Local abckacols:= acols
Local nAnt:= N
Local nQtdIten:= 0
Local aHeaderb:=aheader
		aheader:=aHeader2
		Acols:=aCols2

	 // Cabecalho

		MaFisLoad("NF_SERIENF",aItemCab[nFSerie])
		MaFisLoad("NF_UFORIGEM",aItemCab[nFEst])
		MaFisLoad("NF_FRETE",aItemCab[nFFrete])
		MaFisLoad("NF_DESPESA",aItemCab[nFDespesa])
		MaFisLoad("NF_VALMERC",aItemCab[nFValmerc])
		MaFisLoad("NF_TOTAL",aItemCab[nFValbrut])
		MaFisLoad("NF_BASEDUP",aItemCab[nFValbrut])
		If nFDescont > 0
			MaFisLoad("NF_DESCONTO",aItemCab[nFDescont])
		EndIf
		MaFisLoad("NF_SEGURO",aItemCab[nFSeguro])
		MaFisLoad("NF_MOEDA",aItemCab[nFMoeda])
		MaFisLoad("NF_TXMOEDA",aItemCab[nFTxMoeda])
		MaFisLoad("NF_TIPODOC",aItemCab[nFTipodoc])
		If cPaisLoc == "ARG"
			If nFProvent > 0
			  MaFisLoad("NF_PROVENT",aItemCab[nFProvent])
			  cProv:= aItemCab[nFProvent]
			Endif
       EndIf
nQtdIten:= Len(aItemDad)
For ni:= 1 to nQtdIten   // Itens
	N:=NI
	MaFisIniLoad(NI)

	MaFisLoad("IT_PRODUTO",aItemDad[ni,nProd],n)
	MaFisLoad("IT_QUANT",aItemDad[ni,nQtdVen],n)
	MaFisLoad("IT_QUANT",aItemDad[ni,nQtdVen],n)
	MaFisLoad("IT_PRCUNI",aItemDad[ni,nValor],n)
	If aItemDad[ni,nQtdVen] ==0
		MaFisLoad("IT_VALMERC",aItemDad[ni,nValor],n)
	Else
		MaFisLoad("IT_VALMERC",aItemDad[ni,nValor]*aItemDad[ni,nQtdVen],n)
	EndIf
	MaFisLoad("IT_TES",aItemDad[ni,nTES],n)
	MaFisLoad("IT_CF",aItemDad[ni,nCF],n)
	MaFisLoad("IT_PESO",aItemDad[ni,nPeso],n)
	MaFisLoad("IT_DESCONTO",aItemDad[ni,nValDesc],n)
	MaFisLoad("IT_FRETE",aItemDad[ni,nFrete],n)
	MaFisLoad("IT_SEGURO",aItemDad[ni,nSeguro],n)
	MaFisLoad("IT_DESPESA",aItemDad[ni,nDespesa],n)
	MaFisLoad("IT_PROVENT",cProv,n)
	MaFisLoad("IT_TES",aItemDad[ni,nTES],n)
	MaFisLoad("IT_CF",aItemDad[ni,nCF],n)
	If nBasImp1 >0
		M143ATVL("1",aItemDad[ni,nValImp1],aItemDad[ni,nBasImp1],aItemDad[ni,nALQImp1],"D")
		nBasCImp1:=nBasCImp1+aItemDad[ni,nBasImp1]
		nValCImp1:=nValCImp1+aItemDad[ni,nValImp1]
	EndIf
	If nBasImp2 >0
		M143ATVL("2",aItemDad[ni,nValImp2],aItemDad[ni,nBasImp2],aItemDad[ni,nALQImp2],"D")
		nBasCImp2:=nBasCImp2+aItemDad[ni,nBasImp2]
		nValCImp2:=nValCImp2+aItemDad[ni,nValImp2]
	EndIf
	If nBasImp3 >0
		M143ATVL("3",aItemDad[ni,nValImp3],aItemDad[ni,nBasImp3],aItemDad[ni,nALQImp3],"D")
		nBasCImp3:=nBasCImp3+aItemDad[ni,nBasImp3]
		nValCImp3:=nValCImp3+aItemDad[ni,nValImp3]
	EndIf
	If nBasImp4 >0
		M143ATVL("4",aItemDad[ni,nValImp4],aItemDad[ni,nBasImp4],aItemDad[ni,nALQImp4],"D")
		nBasCImp4:=nBasCImp4+aItemDad[ni,nBasImp4]
		nValCImp4:=nValCImp4+aItemDad[ni,nValImp4]
	EndIf
	If nBasImp5 >0
		M143ATVL("5",aItemDad[ni,nValImp5],aItemDad[ni,nBasImp5],aItemDad[ni,nALQImp5],"D")
		nBasCImp5:=nBasCImp5+aItemDad[ni,nBasImp5]
		nValCImp5:=nValCImp5+aItemDad[ni,nValImp5]
	EndIf
	If nBasImp6 >0
		M143ATVL("6",aItemDad[ni,nValImp6],aItemDad[ni,nBasImp6],aItemDad[ni,nALQImp6],"D")
		nBasCImp6:=nBasCImp6+aItemDad[ni,nBasImp6]
		nValCImp6:=nValCImp6+aItemDad[ni,nValImp6]
	EndIf
	If nBasImp7 >0
		M143ATVL("7",aItemDad[ni,nValImp7],aItemDad[ni,nBasImp7],aItemDad[ni,nALQImp7],"D")
		nBasCImp7:=nBasCImp7+aItemDad[ni,nBasImp7]
		nValCImp7:=nValCImp7+aItemDad[ni,nValImp7]
	EndIf
	If nBasImp8 >0
		M143ATVL("8",aItemDad[ni,nValImp8],aItemDad[ni,nBasImp8],aItemDad[ni,nALQImp8],"D")
		nBasCImp8:=nBasCImp8+aItemDad[ni,nBasImp8]
		nValCImp8:=nValCImp8+aItemDad[ni,nValImp8]
	EndIf
	If nBasImp9 >0
		M143ATVL("9",aItemDad[ni,nValImp9],aItemDad[ni,nBasImp9],aItemDad[ni,nALQImp9],"D")
		nBasCImp9:=nBasCImp9+aItemDad[ni,nBasImp9]
		nValCImp9:=nValCImp9+aItemDad[ni,nValImp9]
	EndIf
	If nBasImpA >0
		M143ATVL("A",aItemDad[ni,nValImpA],aItemDad[ni,nBasImpA],aItemDad[ni,nALQImpA],"D")
		nBasCImpA:=nBasCImpA+aItemDad[ni,nBasImpA]
		nValCImpA:=nValCImpA+aItemDad[ni,nValImpA]
	EndIf
	If nBasImpB >0
		M143ATVL("B",aItemDad[ni,nValImpB],aItemDad[ni,nBasImpB],aItemDad[ni,nALQImpB],"D")
		nBasCImpB:=nBasCImpB+aItemDad[ni,nBasImpB]
		nValCImpB:=nValCImpB+aItemDad[ni,nValImpB]
	EndIf
	If nBasImpC >0
		M143ATVL("C",aItemDad[ni,nValImpC],aItemDad[ni,nBasImpC],aItemDad[ni,nALQImpC],"D")
		nBasCImpC:=nBasCImpC+aItemDad[ni,nBasImpC]
		nValCImpC:=nValCImpC+aItemDad[ni,nValImpC]
	EndIf
	If nBasImpD >0
		M143ATVL("D",aItemDad[ni,nValImpD],aItemDad[ni,nBasImpD],aItemDad[ni,nALQImpD],"D")
		nBasCImpD:=nBasCImpD+aItemDad[ni,nBasImpD]
		nValCImpD:=nValCImpD+aItemDad[ni,nValImpD]
	EndIf
	If nBasImpE >0
		M143ATVL("E",aItemDad[ni,nValImpE],aItemDad[ni,nBasImpE],aItemDad[ni,nALQImpE],"D")
		nBasCImpE:=nBasCImpE+aItemDad[ni,nBasImpE]
		nValCImpE:=nValCImpE+aItemDad[ni,nValImpE]
	EndIf
	If nBasImpF >0
		M143ATVL("F",aItemDad[ni,nValImpF],aItemDad[ni,nBasImpF],aItemDad[ni,nALQImpF],"D")
		nBasCImpF:=nBasCImpF+aItemDad[ni,nBasImpF]
		nValCImpF:=nValCImpF+aItemDad[ni,nValImpF]
	EndIf
	If nBasImpG >0
		M143ATVL("G",aItemDad[ni,nValImpG],aItemDad[ni,nBasImpG],aItemDad[ni,nALQImpG],"D")
		nBasCImpG:=nBasCImpG+aItemDad[ni,nBasImpG]
		nValCImpG:=nValCImpG+aItemDad[ni,nValImpG]
	EndIf
	If nBasImpH >0
		M143ATVL("H",aItemDad[ni,nValImpH],aItemDad[ni,nBasImpH],aItemDad[ni,nALQImpH],"D")
		nBasCImpH:=nBasCImpH+aItemDad[ni,nBasImpH]
		nValCImpH:=nValCImpH+aItemDad[ni,nValImpH]
	EndIf
	If nBasImpI >0
		M143ATVL("I",aItemDad[ni,nValImpI],aItemDad[ni,nBasImpI],aItemDad[ni,nALQImpI],"D")
		nBasCImpI:=nBasCImpI+aItemDad[ni,nBasImpI]
		nValCImpI:=nValCImpI+aItemDad[ni,nValImpI]
	EndIf
	If nBasImpJ >0
		M143ATVL("J",aItemDad[ni,nValImpJ],aItemDad[ni,nBasImpJ],aItemDad[ni,nALQImpJ],"D")
		nBasCImpJ:=nBasCImpJ+aItemDad[ni,nBasImpJ]
		nValCImpJ:=nValCImpJ+aItemDad[ni,nValImpJ]
	EndIf
	If nBasImpK >0
		M143ATVL("K",aItemDad[ni,nValImpK],aItemDad[ni,nBasImpK],aItemDad[ni,nALQImpK],"D")
		nBasCImpK:=nBasCImpK+aItemDad[ni,nBasImpK]
		nValCImpK:=nValCImpK+aItemDad[ni,nValImpK]
	EndIf
	If nBasImpL >0
		M143ATVL("L",aItemDad[ni,nValImpL],aItemDad[ni,nBasImpL],aItemDad[ni,nALQImpL],"D")
		nBasCImpL:=nBasCImpL+aItemDad[ni,nBasImpL]
		nValCImpL:=nValCImpL+aItemDad[ni,nValImpL]
	EndIf
	If nBasImpM >0
		M143ATVL("M",aItemDad[ni,nValImpM],aItemDad[ni,nBasImpM],aItemDad[ni,nALQImpM],"D")
		nBasCImpM:=nBasCImpM+aItemDad[ni,nBasImpM]
		nValCImpM:=nValCImpM+aItemDad[ni,nValImpM]
	EndIf
	If nBasImpN >0
		M143ATVL("N",aItemDad[ni,nValImpN],aItemDad[ni,nBasImpN],aItemDad[ni,nALQImpN],"D")
		nBasCImpN:=nBasCImpN+aItemDad[ni,nBasImpN]
		nValCImpN:=nValCImpN+aItemDad[ni,nValImpN]
	EndIf
	If nBasImpO >0
		M143ATVL("O",aItemDad[ni,nValImpO],aItemDad[ni,nBasImpO],aItemDad[ni,nALQImpO],"D")
		nBasCImpO:=nBasCImpO+aItemDad[ni,nBasImpO]
		nValCImpO:=nValCImpO+aItemDad[ni,nValImpO]
	EndIf
	If nBasImpP >0
		M143ATVL("P",aItemDad[ni,nValImpP],aItemDad[ni,nBasImpP],aItemDad[ni,nALQImpP],"D")
		nBasCImpP:=nBasCImpP+aItemDad[ni,nBasImpP]
		nValCImpP:=nValCImpP+aItemDad[ni,nValImpP]
	EndIf
	If nBasImpQ >0
		M143ATVL("Q",aItemDad[ni,nValImpQ],aItemDad[ni,nBasImpQ],aItemDad[ni,nALQImpQ],"D")
		nBasCImpQ:=nBasCImpQ+aItemDad[ni,nBasImpQ]
		nValCImpQ:=nValCImpQ+aItemDad[ni,nValImpQ]
	EndIf
	If nBasImpR >0
		M143ATVL("R",aItemDad[ni,nValImpR],aItemDad[ni,nBasImpR],aItemDad[ni,nALQImpR],"D")
		nBasCImpR:=nBasCImpR+aItemDad[ni,nBasImpR]
		nValCImpR:=nValCImpR+aItemDad[ni,nValImpR]
	EndIf
	If nBasImpS >0
		M143ATVL("S",aItemDad[ni,nValImpS],aItemDad[ni,nBasImpS],aItemDad[ni,nALQImpS],"D")
		nBasCImpS:=nBasCImpS+aItemDad[ni,nBasImpS]
		nValCImpS:=nValCImpS+aItemDad[ni,nValImpS]
	EndIf
	If nBasImpT >0
		M143ATVL("T",aItemDad[ni,nValImpT],aItemDad[ni,nBasImpT],aItemDad[ni,nALQImpT],"D")
		nBasCImpT:=nBasCImpT+aItemDad[ni,nBasImpT]
		nValCImpT:=nValCImpT+aItemDad[ni,nValImpT]
	EndIf
	If nBasImpU >0
		M143ATVL("U",aItemDad[ni,nValImpU],aItemDad[ni,nBasImpU],aItemDad[ni,nALQImpU],"D")
		nBasCImpU:=nBasCImpU+aItemDad[ni,nBasImpU]
		nValCImpU:=nValCImpU+aItemDad[ni,nValImpU]
	EndIf
	If nBasImpV >0
		M143ATVL("V",aItemDad[ni,nValImpV],aItemDad[ni,nBasImpV],aItemDad[ni,nALQImpV],"D")
		nBasCImpV:=nBasCImpV+aItemDad[ni,nBasImpV]
		nValCImpV:=nValCimpV+aItemDad[ni,nValImpV]
	EndIf
	If nBasImpW >0
		M143ATVL("W",aItemDad[ni,nValImpW],aItemDad[ni,nBasImpW],aItemDad[ni,nALQImpW],"D")
		nBasCImpW:=nBasCImpW+aItemDad[ni,nBasImpW]
		nValCImpW:=nValCimpW+aItemDad[ni,nValImpW]
	EndIf
	If nBasImpX >0
		M143ATVL("X",aItemDad[ni,nValImpX],aItemDad[ni,nBasImpX],aItemDad[ni,nALQImpX],"D")
		nBasCImpX:=nBasCImpX+aItemDad[ni,nBasImpX]
		nValCImpX:=nValCimpX+aItemDad[ni,nValImpX]
	EndIf
	If nBasImpY >0
		M143ATVL("Y",aItemDad[ni,nValImpY],aItemDad[ni,nBasImpY],aItemDad[ni,nALQImpY],"D")
		nBasCImpY:=nBasCImpY+aItemDad[ni,nBasImpY]
		nValCImpY:=nValCImpY+aItemDad[ni,nValImpY]
	EndIf
	If nBasImpZ >0
		M143ATVL("Z",aItemDad[ni,nValImpZ],aItemDad[ni,nBasImpZ],aItemDad[ni,nALQImpZ],"D")
		nBasCImpZ:=nBasCImpZ+aItemDad[ni,nBasImpZ]
		nValCImpZ:=nValCImpZ+aItemDad[ni,nValImpZ]
	EndIf
	MaFisLoad("IT_TOTAL",aItemDad[ni,nTotal],n)

	If ni<>  nQtdIten
		MaFisEndLoad( nI,,.f.  )
	Else
		MaFisEndLoad( nI)
	EndIf
Next

	MaFisLoad("NF_TOTAL",aItemCab[nFValbrut])
	MaFisLoad("NF_BASEDUP",aItemCab[nFValbrut])

	aheader:=aHeaderb
	acols := abckacols
	N:= nAnt
Return(.T.)


Static Function M143ATVL(cLetra,nposVal,nposBas,nPosAlq,cTipo)

If cTipo=="D"
	MaFisLoad("IT_VALIV"+cLetra,nposVal,n)
	MaFisLoad("IT_BASEIV"+cLetra,nposBas,n)
	MaFisLoad("IT_ALIQIV"+cLetra,nPosAlq,n)
Else
	MaFisRef("NF_VALIV" +cLetra,"MT120",nposVal)
	MaFisRef("NF_BASEIV"+cLetra,"MT120",nposBas)
EndIf

Return()

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A143MOEDA   ³ Autor ³ Rodrigo M Pontes      ³ Data ³ 10/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza a moeda										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A143MOEDA                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum	  									           	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ COMPRAS INTERNACIONAL                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function A143MOEDA()

If FunName() == "MATA143"
	nMoedaDes := M->DBB_MOEDA
Endif

Return .T.

/*/{Protheus.doc} M143Peso
//Genera peso total por ítem y gran total del documento para prorrateo de flete, gasto o seguro
//los campos de peso no está en las tablas/browse, solo actualiza en arreglos de MatxFis
@author arodriguez
@since 15/10/2019
@version 1.0
@return NIL
@param cReferencia, characters, campo que se edita (flete, gasto o seguro)
@type function
/*/
Static Function M143Peso(cReferencia)
Local aAreaSB1		:= SB1->(GetArea())
Local cFilSB1		:= xFilial("SB1")
Local cMvRatDesp	:= SuperGetMV("MV_RATDESP")
Local cTpRatFrete	:= Substr(cMvRatDesp,At("FR=",cMvRatDesp)+3,1)
Local cTpRatDesp	:= Substr(cMvRatDesp,At("DESP=",cMvRatDesp)+5,1)
Local cTpRatSeg		:= Substr(cMvRatDesp,At("SEG=",cMvRatDesp)+4,1)
Local nPosDoc		:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_ITEM"  })
Local nPosTipo		:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_TIPONF"})
Local nPosItDoc		:= aScan(aHeader,{|x| AllTrim(x[2]) == "DBC_ITDOC" })
Local nPosProd		:= aScan(aHeader,{|x| AllTrim(x[2]) == "DBC_CODPRO" })
Local nPosCant		:= aScan(aHeader,{|x| AllTrim(x[2]) == "DBC_QUANT" })
Local nPosDelDoc	:= Len(aHeader1)+1
Local nPosDel		:= Len(aHeader)+1
Local nDecCant		:= TamSX3("D1_PESO")[2]
Local nScan			:= 0
Local nPesoItem		:= 0
Local nPesoTotal	:= 0
Local nX			:= 0
Local lProrrPeso	:= (("NF_FRETE"$cReferencia .And. cTpRatFrete=="2") .Or. ;
						("NF_DESPESA"$cReferencia .And. cTpRatDesp=="2") .Or. ;
						("NF_SEGURO"$cReferencia .And. cTpRatSeg=="2"))

If Len(aCols) > 0 .And. nPosItDoc > 0
	nScan := aScan(aCols1 , { |x| x[nPosDelDoc] == .F. .And. x[nPosDoc]== aCols[1][nPosItDoc] } )

	If nScan > 0 .And. aCols1[nScan][nPosTipo] $ "5|8" .And. lProrrPeso // FOB // CIF
		SB1->(dbSetOrder(1))

		For nX := 1 to Len(aCols)
			If !aCols[nX,nPosDel]
				SB1->(msSeek(cFilSB1+aCols[nX,nPosProd]))
				nPesoItem := Round(SB1->B1_PESO * aCols[nX,nPosCant],nDecCant)
				nPesoTotal += nPesoItem
				MaFisAlt("IT_PESO" , nPesoItem , nX)
			EndIf
		Next nX

		MaFisAlt("NF_PESO" , nPesoTotal)
		SB1->(RestArea(aAreaSB1))
	EndIf
EndIf

Return Nil

/*/{Protheus.doc} ProvDomicil
//Valida si el proveedor usado es domiciliado o no dominiliado
//si el proveedor es no domiciliado retorna verdadero , de lo contrario retorna falso
@author Eduardo Pérez
@since 08/05/2020
@version 1.0
@return lDomicil, boolean, variable donde se guarda el valor logico validando el tipo de proveedor(domiciliado , no domiciliado)
@param
@type function
/*/
Function ProvDomicil()
	Local lDomicil := .F.
	Local aAreaPro := GetArea()

	DbSelectArea("SA2")
	SA2->(dbSetOrder(1)) // A2_FILIAL + A2_FORNEC + A2_LOJA
	SA2->(dbSeek(xFilial("SA2") +  DBB->DBB_FORNEC + DBB->DBB_LOJA))
	If(Alltrim(SA2->A2_DOMICIL)) == "2"
		lDomicil := .T.
	Endif
	RestArea(aAreaPro)
return lDomicil


/*/{Protheus.doc} M143Busca
//Obtiene el Recno de los items actuales de la factura modificada.
@author Verónica Flores
@since 04/08/2020
@version 1.0
@return lExiste, boolean,valida si existe registro de la factura en el despacho.
@param cDesp, caracter, campo del despacho que se edita.
@param cNFac, caracter, campo de la factura que se edita.
@param cItem, caracter, campo del item que se edita.
@param aItemPO, caracter, arreglo que almacena el recno del item.
@type function
/*/

Function M143Busca(cDesp,cNFac,cItem,nItem,aItemPO)
	Local aAreaDBC 	:= GetArea()
	Local lExiste 	:= .F.
	Local nPosTES    := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_TES"   })

	Default cItem := ""

	DbSelectArea("DBC")
	DBC->(dbSetOrder(1)) // DBC_HAWB + DBC_ITDOC + DBC_ITEM

	If DBC->(dbSeek(xFilial("DBC") +  cDesp + cNFac + cItem))
		lExiste 	:= .T.
		aItemPO := {DBC->(Recno())}
		MaFisAlt("IT_TES",aCols[N][nPosTES],nItem)
		MaFisAlt("IT_VALMERC",0,nItem)
	EndIf

	RestArea(aAreaDBC)
Return lExiste

/*/{Protheus.doc} M143Cant
//Suma la cantidad de los items actuales del despacho que se esta modificando.
@author Verónica Flores
@since 05/08/2020
@version 1.0
@return nFreeQT, numerico , retorna la suma de la cantidad del item utilizada en el despacho.
@param nNumInv, numerico , numero de facturas del despacho.
@param nPosInvOk, numerico , numero de posicion del campo "DBB_OK".
@param nPosNumPo, numerico , numero de posicion del campo "DBC_PEDIDO".
@param nPosItemPo, numerico , numero de posicion del campo "DBC_ITEMPC".
@param cNumPO, caracter , campo de la PO que se edita.
@param cItem, caracter , campo del item que se edita.
@type function
/*/

Function M143Cant(nNumInv,nPosInvOk,nPosNumPo,nPosItemPo,cNumPO,cItem)
	Local nZ := 0
	Local nY :=0
	Local nFreeQT := 0
	Local nPosQTD	 := aScan(aHeader2,{|x| Alltrim(x[2]) == "DBC_QUANT" })

		For nZ := 1 To Len(aColsIt)
			For nY := 1 to Len(aColsIt[nZ])
				If !aColsIt[nZ][nY][Len(aColsIt[nZ][nY])] .And. nZ <> nNumInv .And. aCols1[nZ][nPosInvOk] != "S"
					If aColsIt[nZ][nY][nPosNumPo] == cNumPO .And. aColsIt[nZ][nY][nPosItemPo] == cItem
						nFreeQT += aColsIt[nZ][nY][nPosQTD]
					EndIf
				EndIf
			Next nY
		Next nZ
Return nFreeQT

/*/{Protheus.doc} M143CantBD
//Suma la cantidad del producto utilizado en otros despachos.
@author Verónica Flores
@since 05/08/2020
@version 1.0
@param cPedido, caracter , campo de la PO seleccionada.
@param cCodPro, caracter , campo del producto seleccionado.
@param cDesp, caracter , campo del despacho que se edita.
@type function
/*/
Function M143CantBD(cPedido,cCodPro,cDesp)

	Local nCantBD 	:= 0
	Local aArea		:= GetArea()
	Local cFilDBB	:= xFilial("DBB")

	BeginSql Alias "DBCQT"
		SELECT DBC_QUANT, DBC_HAWB, DBC_ITDOC
		FROM %Table:DBC% DBC
		WHERE
		DBC.DBC_FILIAL = %xFilial:DBC% AND
		DBC.DBC_PEDIDO = %Exp:cPedido% AND DBC.DBC_CODPRO = %Exp:cCodPro% AND DBC.DBC_HAWB <> %Exp:cDesp% AND
		DBC.%NotDel%
	EndSql
	dbSelectArea("DBB")
	DBB->(dbSetOrder(2)) //DBB_FILIAL+DBB_HAWB+DBB_ITEM
	dbSelectArea("DBCQT")
	DBCQT->(dbGoTop())
	While !DBCQT->(Eof())
		If cPaisLoc$"PER|COL|EQU|ARG" .And. (IsInCallStack("M143F6PO") .Or. IsInCallStack("M143ProcPO"))
			If DBB->(MsSeek(cFilDBB+DBCQT->(DBC_HAWB+DBC_ITDOC))) .And. IIF(cPaisLoc$"PER|COL|EQU",DBB->DBB_OK == "S",.T.)
				DBCQT->(dbSkip())
				Loop
			EndIf
		EndIf
		nCantBD += DBCQT->DBC_QUANT
		DBCQT->(dbSkip())
	EndDo
	DBCQT->(dbCloseArea())
	RestArea(aArea)
Return nCantBD


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A143Cant³ Autor ³Veronica Flores³          Data ³04/08/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³ Validacion de la cantidad digitada                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Cantidad del producto                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Dicionario de Datos - Campo: DBC_QUANT                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A143Cant(nQtAct)

Local aArea    := GetArea()
Local nPosDoc  := aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_ITEM"  })
Local nPosItDoc:= aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_ITDOC" })
Local nPosProd := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_CODPRO" })
Local nPosNumPo:= aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_PEDIDO" })
Local nPosItem := aScan(aHeader2,{|x| AllTrim(x[2]) == "DBC_ITEMPC" })
Local nPosInvOk:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DBB_OK"})
Local nNumInv  := aScan(aCols1,{|x| Alltrim(x[nPosDoc]) == aCols[1][nPosItDoc]})
Local lRet     := .T.
Local nCant	   := 0
Local nCantBD  := 0
Local nTotal   := 0

	If !Empty(aCols[N][nPosNumPO]) .And. !Empty(aCols[N][nPosItem])
		nCant   := M143Cant(nNumInv,nPosInvOk,nPosNumPo,nPosItem,aCols[N][nPosNumPo],aCols[N][nPosItem])
		nCantBD := M143CantBD(aCols[N][nPosNumPo],aCols[N][nPosProd],M->DBA_HAWB)
		nTotal  := nCant + nCantBD + nQtAct
		BeginSql Alias "TMPSC7"
			SELECT C7_QUANT
			FROM %Table:SC7% SC7
			WHERE
			SC7.C7_FILIAL = %xFilial:SC7% AND
			SC7.C7_NUM = %Exp:aCols[N][nPosNumPO]% AND SC7.C7_PRODUTO = %Exp:aCols[N][nPosProd]% AND
			SC7.C7_TIPO = 3 AND SC7.%NotDel%
		EndSql

		dbSelectArea("TMPSC7")
		TMPSC7->(dbGoTop())
		If !TMPSC7->(Eof())
			If nTotal > TMPSC7->C7_QUANT
				MsgAlert(STR0096 + " " + aCols[N][nPosNumPO]) //STR0096 - La cantidad indicada es mayor a la disponible en la PO ###
				lRet := .F.
			EndIf
		EndIF
		TMPSC7->(dbCloseArea())

	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} M143FndNF
Funcion utilizada para buscar documentos en SF1, para
confirmar guardado tras usar rutina automatica.
@type Function
@author Marco Augusto Gonzalez Rivera
@since 13/10/2020
@version 1.0
@example M143FndNF()
@return lRet, Logico, .T. si encuentra el documento / .F. Si no encuentra el documento
@see (links_or_references)
/*/
Static Function M143FndNF()

	Local aArea		:= GetArea()
	Local lRet		:= .F.
	Local nPosDoc	:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_DOC"})
	Local nPosSer	:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_SERIE"})
	Local nPosProv	:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_FORNEC"})
	Local nPosLoja	:= aScan(aHeader1,{|x| AllTrim(x[2]) == "DBB_LOJA"})

	DBSelectArea("SF1")
	DBSetOrder(1) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

	If SF1->(MSSeek(xFilial("SF1")+aCols1[n][nPosDoc]+aCols1[n][nPosSer]+aCols1[n][nPosProv]+aCols1[n][nPosLoja]))
		lRet := .T.
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} Mata143LibM
Función utilizada para validar la fecha de la LIB para ser utilizada en Telemetria
@type       Function
@author     raul.medina
@since      2021
@version    12.1.27
@return     _lMetric, lógico, si la LIB puede ser utilizada para Telemetria
/*/
Static Function Mata143LibM()

If _lMetric == Nil
	_lMetric := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
EndIf

Return _lMetric

 /*/{Protheus.doc} Mata143Met
Función utilizada realizar la metrica de tipo de documento
@type       Function
@author     raul.medina
@since      2021
@version    12.1.27
@parametro  cDoc, caracter, Documento generado.
	/*/

Static Function Mata143Met(cDoc)
Local cIdMetric		:= ""
Local cSubRutina	:= ""

Default cDoc := ""

	If Mata143LibM()
		cIdMetric   := "compras-protheus_media-compras-internacional_total"
		cSubRutina  := "mata143-"
		If cDoc == "5"
			cSubRutina += "fob"
		ElseIf cDoc == "6"
			cSubRutina += "flete"
		ElseIf cDoc == "7"
			cSubRutina += "seguro"
		ElseIf cDoc == "8"
			cSubRutina += "cif"
		ElseIf cDoc == "9"
			cSubRutina += "impuestos/gastos"
		ElseIf cDoc == "A"
			cSubRutina += "gastos"
		ElseIf cDoc == "D"
			cSubRutina += "dua"
		EndIf
		cSubRutina	+= "-total"
		If isBlind()
			cSubRutina  += "-auto"
		EndIf
		FWCustomMetrics():setSumMetric(cSubRutina, cIdMetric, 1, /*dDateSend*/, /*nLapTime*/,"MATA143")
	EndIf

Return

/*/{Protheus.doc} A143Reabre
	Reabre el despacho, borrar el campo de fecha finalización (DBA_DT_ENC)
	@type  Function
	@author ARodriguez
	@since 18/10/2021
	@version 1.0
	@param ninguno
	@return nil
	/*/
Function M143Reabre()
Local lAutomato := IsBlind()

If !Empty(DBA->DBA_DT_ENC)
	If lAutomato .Or. MsgYesNo(OemToAnsi(STR0104) + CRLF + OemToAnsi(STR0105), OemToAnsi(STR0103))	//"¿Reabrir el despacho?"##"Se borrará la fecha de finalización."##"Reabrir Despacho"
		If Reclock("DBA",.F.)
			DBA->DBA_DT_ENC := CtoD("")
			DBA->(MsUnlock())
			If ExistBlock("MT143REABR")
				ExecBlock("MT143REABR",.F.,.F.,{DBA->DBA_FILIAL,DBA->DBA_HAWB})
			Endif
		EndIf
	EndIf

ElseIf !lAutomato
	MsgAlert(OemToAnsi(STR0106), OemToAnsi(STR0103))	//"El despacho no está finalizado."##"Reabrir Despacho"

EndIf

Return Nil


/*/{Protheus.doc} buscaRegCH
	se usa para posicionarse en los registros de la SD1 por medio de los valores
	enviados de la mata103x usando el indice 1, para evitar poner localiaciones
	dentro del fuente mata103x ya que es de brasil.
	@type  Function
	@author user
	@since 07/04/2022
	@version version
	@param cfilial,caracter , filial
	@param cDoc,caracter , numero de documento
	@param cSerie,caracter ,serie documento
	@param cProveedor,caracter ,proveedor
	@param cLoja,caracter ,tienda
	@param  lMata143,boleano, .T. Indica si la mata143 esta en la pila de llamadas
	@param cTipoGas,caracter ,tipo de de documento del despacho (A=Gasto)
	@param lMata143,booleana ,.T. si existe en la pila de llamadas(IsInCallStack)
	@return nil, nil, No regresa valor
	/*/
Function buscaRegCH(cfilial,cDoc,cSerie,cProveedor,cLoja,lMata143,cTipoGas)
Default cfilial:=""
Default cDoc:=""
Default cSerie:=""
Default cProveedor:=""
Default cLoja:=""
Default lMata143:=.F.
Default cTipoGas:=""

IF (cPaisloc== "CHI") .AND. lMata143 .And. (ALLTRIM(cTipoGas) =="A")
	MsSeek(cfilial + cDoc +cSerie+ cProveedor + cLoja )
ENDIF
	
Return NIL

/*/{Protheus.doc} ResetLojaCH
	La función se usa para cuando el documento origen en este caso la FOB es una sucursal diferente a la del gasto
	se envia dentro los items que corresponde al gasto la tienda del documento origen para
	poder buscar el documento origen cuando se realiza el posicinamiento en la SD1 en el fuente mata103x, al grabar
	el documento el encabezado queda con la tienda informada en el gasto lo cual es correcto pero se necesita actualizar
	la tienda de los items del gasto ya que esta fue modificada para poder posicionarse en los items del documento origen
	@type  Function
	@author user
	@since 08/04/2022
	@version version
	@param cfilial,caracter , filial
	@param cDoc,caracter , numero de documento
	@param cSerie,caracter ,serie documento
	@param cProveedor,caracter ,proveedor
	@param cTipoGas,caracter ,tipo de de documento del despacho (A=Gasto)
	@param cPaLoja,caracter ,tienda
	@param cDesp,caracter ,numero de despacho
	@param cDespItem,caracter ,numero de de item(tipo de documento) despacho	
	@return nil, nil, No regresa valor
	/*/
Function ResetLojaCH(cfilial,cDoc,cSerie,cProveedor,cTipoGas,cPaLoja,cDesp,cDespItem)
Local aAreaSD1
Local aAreaDBB
Local cAux:=""

Default cfilial:=""
Default cDoc:=""
Default cSerie:=""
Default cProveedor:=""
Default cTipoGas:=""
Default cPaLoja:=""
Default cDesp:=""
Default cDespItem:=""

IF cPaisLoc=="CHI" .AND.ALLTRIM(cTipoGas)=="A"

	aAreaDBB:= DBB->(GetArea())
	dbSelectArea("DBB")	
	dbSetOrder(2) //DBB_FILIAL+DBB_HAWB+DBB_ITEM                                                                    
	MsSeek(cfilial+cDesp+cDespItem)
	While !Eof() .And. DBB->DBB_FILIAL  == xFilial("DBB")  .And.;
									DBB->DBB_HAWB     == cDesp .And.;
									DBB->DBB_ITEM  == cDespItem;
								


					
					cAux:=DBB->DBB_LOJA
	dbSkip()
	EndDo
	RestArea(aAreaDBB)

	IF cPaloja<>cAux
		aAreaSD1:= SD1->(GetArea())
		dbSelectArea("SD1")
		dbSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                                                                                      

		MsSeek(cfilial+cDoc+cSerie+cProveedor+cPaLoja)
		While !Eof() .And. SD1->D1_FILIAL  == xFilial("SD1")  .And.;
										SD1->D1_DOC     == cDoc .And.;
										SD1->D1_SERIE   == cSerie .AND.;
										SD1->D1_FORNECE == cProveedor .and.;
										SD1->D1_LOJA    == cPaLoja


						RecLock("SD1",.F.)
						SD1->D1_LOJA:=cAux
						MsUnLock()
		dbSkip()
		EndDo
		RestArea(aAreaSD1) 
	ENDIF
ENDIF

Return NIL

#Include "PROTHEUS.CH"
#Include "FINXLOAD.CH"
#INCLUDE "FWLIBVERSION.CH"

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location
STATIC __oQryFK4	:= Nil
STATIC __aCpoLGPD	:= {}
STATIC __lLGPDFIN 	:= cPaisLoc == "BRA" .And. FindFunction( "FwPDCanUse" ) .And. FwPDCanUse(.T.)
STATIC __aLGPDFin 	:= Iif(__lLGPDFIN, LoadLGPD(), {})
Static __lMetric	:= .F.
Static __cFunBkp	:= ""
Static __cFunMet	:= ""
Static __lFndFix	:= .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FINLOAD  ºAutor  ³Totvs               º Data ³  01/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de carregamento das configuracoes módulo FIN        º±±
±±º          ³ executada na primeira vez que o usuário entra no módulo    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Modulo Financeiro - Localidades                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINLoad()

Local lRet		:= .T.
Local aTabelas	:= {"SA1", "SA2", "SA6", "SED", "SE1", "SE2", "SE3", "SE5", "SE8", "SEA", "FK7"}
Local cModoCpt	:= ""
Local nX		:= 0

MsgRun(STR0001,STR0002,{|| FINTabelas()}) // "Carregando as configurações do Módulo Financeiro"  ## "Aguarde"
MsgRun(STR0001,STR0088,{|| FinValFKS()}) // 
MsgRun(STR0001,STR0104,{|| FinValSEQ()}) // Validar tamanho dos campos SEQ referente as tabelas SE5 e SEF 

__lMetric	:= FwLibVersion() >= "20210517" 
__cFunBkp   := FunName()
__cFunMet	:= Iif(AllTrim(__cFunBkp)=='RPC',"RPCFINXLOAD",__cFunBkp)

If __lMetric// Metrica de controle de acessos 
	SetFunName(__cFunMet)
    FwCustomMetrics():setUniqueMetric("MV_BR10925 Conteudo " + "(" +SuperGetMv("MV_BR10925",.T.,"2") + ")", "financeiro-protheus_qtd-por-conteudo_total", SuperGetMv("MV_BR10925",.T.,"2"))
	FwCustomMetrics():setUniqueMetric("MV_BX10925 Conteudo " + "(" +SuperGetMv("MV_BX10925",.T.,"2") + ")", "financeiro-protheus_qtd-por-conteudo_total", SuperGetMv("MV_BX10925",.T.,"2"))
	FwCustomMetrics():setUniqueMetric("MV_FINATFN Conteudo " + "(" +SuperGetMv("MV_FINATFN",.T.,"2") + ")", "financeiro-protheus_qtd-por-conteudo_total", SuperGetMv("MV_FINATFN",.T.,"2"))

	For nX := 1 to Len(aTabelas)
		cModoCpt := FWModeAccess(aTabelas[nx],1)+FWModeAccess(aTabelas[nx],2)+FWModeAccess(aTabelas[nx],3)
		FwCustomMetrics():setUniqueMetric(aTabelas[nX] + " Compartilhamento " + "(" + cModoCpt + ")", "financeiro-protheus_qtd-por-conteudo_total", cModoCpt)
	Next

	SetFunName(__cFunBkp)
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINTabelasºAutor  ³Francisco Junior    º Data ³  01/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza o carregamento das tabelas auxiliares CTB           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FINTabelas()
Local aArea := GetArea()

__lFndFix := FindFunction("FKSXFIX")

// Valida a sincronização de parametros
If cPaisLoc == "BRA" 
	FinValMv()
EndIf
// Ajuste pontual do em função de problemas na ferramenta ATUSX
// Deverá ser removido deste ponto após normalizacao da ferramenta
If ChkFile("FR0")
	FINAtuFR0()
EndIf

//Lê a origem do movimento de baixa/adiantamento
If ChkFile("FKB")
 	FINGrvFKB()
EndIf

If TableInDic("FJS")
	FinaAtuFJS()
EndIf

If TableInDic("CWO")
	FINFKSCWO()
EndIf

If cPaisLoc == "BRA"
	//Configurações CNAB
	FinaAtuSEJ()
	
	//Popula as tabelas referentes às situações do documento hábil - SIAFI
	LoadSIAFI()
EndIf

//Situacao de Cobranca
FinaAtuFRV()
FININCNAT()

//PCREQ-3782 - Bloqueio por situação de cobrança
If TableInDic("FW1")
	FinaAtuFW1()
EndIf

//PCREQ-3768 - Valores acessórios CP
If TableInDic("FKC")
	FINFKSFKC()
EndIf

//Ajustes nas tabelas FKs
If GetRpoRelease() >= "12.1.033" .And. __lFndFix
	FKSXFIX()
Endif

RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FINAtuFr0 ³ Autor ³ --------------------- ³ Data ³ 01/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do FRO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATUALIZACAO SIGAFIN                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FINAtuFR0()
Local cChave	:= ""
Local cFilFR0	:= ""
Local nI		:= 0
Local nX		:= 0
Local nInicio	:= 0
Local nFim		:= 0
Local nLenChv	:= 0
Local nLenTab	:= 0
Local aAreaAtu	:= GetArea()
Local aFR0		:= {}
Local aAreaFR0	:= {}

If cPaisLoc == "PER"
	// Criação da tabela de tipos de documentos de despesa
	AAdd(aFR0,{"000","PE1","","Medios de pagos","Medios de pagos","Medios de pagos","Medios de pagos","Medios de pagos","Medios de pagos"} ) //"Tipos de pagamentos
	AAdd(aFR0,{"PE1","CC","006","tarjeta de crédito","tarjeta de crédito","tarjeta de crédito","tarjeta de crédito","tarjeta de crédito"} )  // tarjeta de crédito
	AAdd(aFR0,{"PE1","CD","005","tarjeta de débito","tarjeta de débito","tarjeta de débito","tarjeta de débito","tarjeta de débito"} )   // tarjeta de débito
	AAdd(aFR0,{"PE1","CH","007","cheques no negociables","cheques no negociables","cheques no negociables","cheques no negociables","cheques no negociables"} )  //cheques con la cláusula de "no negociable",
	AAdd(aFR0,{"PE1","EF","001", "depósito en cuenta", "depósito en cuenta", "depósito en cuenta", "depósito en cuenta", "depósito en cuenta" } )  	 //depósito en cuenta
	AAdd(aFR0,{"PE1","TF","003", "transferencia de fondos", "transferencia de fondos", "transferencia de fondos", "transferencia de fondos", "transferencia de fondos"})  //transferencia de fondos

	// convenio para evitar a dupla tributacao
	AAdd(aFR0,{"000","PE2","","Convenios para evitar la doble tributación","Convenios para evitar la doble tributación","Convenios para evitar la doble tributación","Convenios para evitar la doble tributación","Convenios para evitar la doble tributación","Convenios para evitar la doble tributación"} ) //"Tipos de pagamentos
	AAdd(aFR0,{"PE2","0","","Ninguno","Ninguno","Ninguno","Ninguno","Ninguno"})
	AAdd(aFR0,{"PE2","1","","Canada","Canada","Canada","Canada","Canada"})
	AAdd(aFR0,{"PE2","2","","Chile","Chile","Chile","Chile","Chile"})
	AAdd(aFR0,{"PE2","3","","CAN","CAN","CAN","CAN","CAN"})
	AAdd(aFR0,{"PE2","4","","Brasil","Brasil","Brasil","Brasil","Brasil"})

	//Codigos de nacionalidade - paises
	AAdd(aFR0,{"000","PE3","","Nacionalidad","Nacionalidad","Nacionalidad","Nacionalidad","Nacionalidad"} )
	AAdd(aFR0,{"PE3","9001","","BOUVET ISLAND"})
	nInicio := Len(aFR0)
	AAdd(aFR0,{"PE3","9002","","COTE D IVOIRE"})
	AAdd(aFR0,{"PE3","9003","","FALKLAND ISLANDS (MALVINAS)"})
	AAdd(aFR0,{"PE3","9004","","FRANCE, METROPOLITAN"})
	AAdd(aFR0,{"PE3","9005","","FRENCH SOUTHERN TERRITORIES"})
	AAdd(aFR0,{"PE3","9006","","HEARD AND MC DONALD ISLANDS"})
	AAdd(aFR0,{"PE3","9007","","MAYOTTE"})
	AAdd(aFR0,{"PE3","9008","","SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS"})
	AAdd(aFR0,{"PE3","9009","","SVALBARD AND JAN MAYEN ISLANDS"})
	AAdd(aFR0,{"PE3","9010","","UNITED STATES MINOR OUTLYING ISLANDS"})
	AAdd(aFR0,{"PE3","9011","","OTROS PAISES O LUGARES"})
	AAdd(aFR0,{"PE3","9013","","AFGANISTAN"})
	AAdd(aFR0,{"PE3","9017","","ALBANIA"})
	AAdd(aFR0,{"PE3","9019","","ALDERNEY"})
	AAdd(aFR0,{"PE3","9023","","ALEMANIA"})
	AAdd(aFR0,{"PE3","9026","","ARMENIA"})
	AAdd(aFR0,{"PE3","9027","","ARUBA"})
	AAdd(aFR0,{"PE3","9028","","ASCENCION"})
	AAdd(aFR0,{"PE3","9029","","BOSNIA-HERZEGOVINA"})
	AAdd(aFR0,{"PE3","9031","","BURKINA FASO"})
	AAdd(aFR0,{"PE3","9037","","ANDORRA"})
	AAdd(aFR0,{"PE3","9040","","ANGOLA"})
	AAdd(aFR0,{"PE3","9041","","ANGUILLA"})
	AAdd(aFR0,{"PE3","9043","","ANTIGUA Y BARBUDA"})
	AAdd(aFR0,{"PE3","9047","","ANTILLAS HOLANDESAS"})
	AAdd(aFR0,{"PE3","9053","","ARABIA SAUDITA"})
	AAdd(aFR0,{"PE3","9059","","ARGELIA"})
	AAdd(aFR0,{"PE3","9063","","ARGENTINA"})
	AAdd(aFR0,{"PE3","9069","","AUSTRALIA"})
	AAdd(aFR0,{"PE3","9072","","AUSTRIA"})
	AAdd(aFR0,{"PE3","9074","","AZERBAIJÁN"})
	AAdd(aFR0,{"PE3","9077","","BAHAMAS"})
	AAdd(aFR0,{"PE3","9080","","BAHREIN"})
	AAdd(aFR0,{"PE3","9081","","BANGLADESH"})
	AAdd(aFR0,{"PE3","9083","","BARBADOS"})
	AAdd(aFR0,{"PE3","9087","","BÉLGICA"})
	AAdd(aFR0,{"PE3","9088","","BELICE"})
	AAdd(aFR0,{"PE3","9090","","BERMUDAS"})
	AAdd(aFR0,{"PE3","9091","","BELARUS"})
	AAdd(aFR0,{"PE3","9093","","MYANMAR"})
	AAdd(aFR0,{"PE3","9097","","BOLIVIA"})
	AAdd(aFR0,{"PE3","9101","","BOTSWANA"})
	AAdd(aFR0,{"PE3","9105","","BRASIL"})
	AAdd(aFR0,{"PE3","9108","","BRUNEI DARUSSALAM"})
	AAdd(aFR0,{"PE3","9111","","BULGARIA"})
	AAdd(aFR0,{"PE3","9115","","BURUNDI"})
	AAdd(aFR0,{"PE3","9119","","BUTÁN"})
	AAdd(aFR0,{"PE3","9127","","CABO VERDE"})
	AAdd(aFR0,{"PE3","9137","","CAIMÁN, ISLAS"})
	AAdd(aFR0,{"PE3","9141","","CAMBOYA"})
	AAdd(aFR0,{"PE3","9145","","CAMERÚN, REPUBLICA UNIDA DEL"})
	AAdd(aFR0,{"PE3","9147","","CAMPIONE D TALIA"})
	AAdd(aFR0,{"PE3","9149","","CANADÁ"})
	AAdd(aFR0,{"PE3","9155","","CANAL (NORMANDAS), ISLAS"})
	AAdd(aFR0,{"PE3","9157","","CANTÓN Y ENDERBURRY"})
	AAdd(aFR0,{"PE3","9159","","SANTA SEDE"})
	AAdd(aFR0,{"PE3","9165","","COCOS (KEELING),ISLAS"})
	AAdd(aFR0,{"PE3","9169","","COLOMBIA"})
	AAdd(aFR0,{"PE3","9173","","COMORAS"})
	AAdd(aFR0,{"PE3","9177","","CONGO"})
	AAdd(aFR0,{"PE3","9183","","COOK, ISLAS"})
	AAdd(aFR0,{"PE3","9187","","COREA (NORTE), REPUBLICA POPULAR DEMOCRATICA DE"})
	AAdd(aFR0,{"PE3","9190","","COREA (SUR), REPUBLICA DE"})
	AAdd(aFR0,{"PE3","9193","","COSTA DE MARFIL"})
	AAdd(aFR0,{"PE3","9196","","COSTA RICA"})
	AAdd(aFR0,{"PE3","9198","","CROACIA"})
	AAdd(aFR0,{"PE3","9199","","CUBA"})
	AAdd(aFR0,{"PE3","9203","","CHAD"})
	AAdd(aFR0,{"PE3","9207","","CHECOSLOVAQUIA  "})
	AAdd(aFR0,{"PE3","9211","","CHILE   "})
	AAdd(aFR0,{"PE3","9215","","CHINA   "})
	AAdd(aFR0,{"PE3","9218","","TAIWAN (FORMOSA)        "})
	AAdd(aFR0,{"PE3","9221","","CHIPRE  "})
	AAdd(aFR0,{"PE3","9229","","BENIN   "})
	AAdd(aFR0,{"PE3","9232","","DINAMARCA       "})
	AAdd(aFR0,{"PE3","9235","","DOMINICA        "})
	AAdd(aFR0,{"PE3","9239","","ECUADOR "})
	AAdd(aFR0,{"PE3","9240","","EGIPTO  "})
	AAdd(aFR0,{"PE3","9242","","EL SALVADOR     "})
	AAdd(aFR0,{"PE3","9243","","ERITREA "})
	AAdd(aFR0,{"PE3","9244","","EMIRATOS ARABES UNIDOS  "})
	AAdd(aFR0,{"PE3","9245","","ESPAÑA  "})
	AAdd(aFR0,{"PE3","9246","","ESLOVAQUIA      "})
	AAdd(aFR0,{"PE3","9247","","ESLOVENIA       "})
	AAdd(aFR0,{"PE3","9249","","ESTADOS UNIDOS  "})
	AAdd(aFR0,{"PE3","9251","","ESTONIA "})
	AAdd(aFR0,{"PE3","9253","","ETIOPIA "})
	AAdd(aFR0,{"PE3","9259","","FEROE, ISLAS    "})
	AAdd(aFR0,{"PE3","9267","","FILIPINAS       "})
	AAdd(aFR0,{"PE3","9271","","FINLANDIA       "})
	AAdd(aFR0,{"PE3","9275","","FRANCIA "})
	AAdd(aFR0,{"PE3","9281","","GABON   "})
	AAdd(aFR0,{"PE3","9285","","GAMBIA  "})
	AAdd(aFR0,{"PE3","9286","","GAZA Y JERICO   "})
	AAdd(aFR0,{"PE3","9287","","GEORGIA "})
	AAdd(aFR0,{"PE3","9289","","GHANA   "})
	AAdd(aFR0,{"PE3","9293","","GIBRALTAR       "})
	AAdd(aFR0,{"PE3","9297","","GRANADA "})
	AAdd(aFR0,{"PE3","9301","","GRECIA  "})
	AAdd(aFR0,{"PE3","9305","","GROENLANDIA     "})
	AAdd(aFR0,{"PE3","9309","","GUADALUPE       "})
	AAdd(aFR0,{"PE3","9313","","GUAM    "})
	AAdd(aFR0,{"PE3","9317","","GUATEMALA       "})
	AAdd(aFR0,{"PE3","9325","","GUAYANA FRANCESA        "})
	AAdd(aFR0,{"PE3","9327","","GUERNSEY        "})
	AAdd(aFR0,{"PE3","9329","","GUINEA  "})
	AAdd(aFR0,{"PE3","9331","","GUINEA ECUATORIAL       "})
	AAdd(aFR0,{"PE3","9334","","GUINEA-BISSAU   "})
	AAdd(aFR0,{"PE3","9337","","GUYANA  "})
	AAdd(aFR0,{"PE3","9341","","HAITI   "})
	AAdd(aFR0,{"PE3","9345","","HONDURAS        "})
	AAdd(aFR0,{"PE3","9348","","HONDURAS BRITANICAS     "})
	AAdd(aFR0,{"PE3","9351","","HONG KONG       "})
	AAdd(aFR0,{"PE3","9355","","HUNGRIA "})
	AAdd(aFR0,{"PE3","9361","","INDIA   "})
	AAdd(aFR0,{"PE3","9365","","INDONESIA       "})
	AAdd(aFR0,{"PE3","9369","","IRAK    "})
	AAdd(aFR0,{"PE3","9372","","IRAN, REPUBLICA ISLAMICA DEL    "})
	AAdd(aFR0,{"PE3","9375","","IRLANDA (EIRE)  "})
	AAdd(aFR0,{"PE3","9377","","ISLA AZORES     "})
	AAdd(aFR0,{"PE3","9378","","ISLA DEL MAN    "})
	AAdd(aFR0,{"PE3","9379","","ISLANDIA        "})
	AAdd(aFR0,{"PE3","9380","","ISLAS CANARIAS  "})
	AAdd(aFR0,{"PE3","9381","","ISLAS DE CHRISTMAS      "})
	AAdd(aFR0,{"PE3","9382","","ISLAS QESHM     "})
	AAdd(aFR0,{"PE3","9383","","ISRAEL  "})
	AAdd(aFR0,{"PE3","9386","","ITALIA  "})
	AAdd(aFR0,{"PE3","9391","","JAMAICA "})
	AAdd(aFR0,{"PE3","9395","","JONSTON, ISLAS  "})
	AAdd(aFR0,{"PE3","9399","","JAPON   "})
	AAdd(aFR0,{"PE3","9401","","JERSEY  "})
	AAdd(aFR0,{"PE3","9403","","JORDANIA        "})
	AAdd(aFR0,{"PE3","9406","","KAZAJSTAN       "})
	AAdd(aFR0,{"PE3","9410","","KENIA   "})
	AAdd(aFR0,{"PE3","9411","","KIRIBATI   "})
	AAdd(aFR0,{"PE3","9412","","KIRGUIZISTAN    "})
	AAdd(aFR0,{"PE3","9413","","KUWAIT  "})
	AAdd(aFR0,{"PE3","9418","","LABUN   "})
	AAdd(aFR0,{"PE3","9420","","LAOS, REPUBLICA POPULAR DEMOCRATICA DE  "})
	AAdd(aFR0,{"PE3","9426","","LESOTHO "})
	AAdd(aFR0,{"PE3","9429","","LETONIA "})
	AAdd(aFR0,{"PE3","9431","","LIBANO  "})
	AAdd(aFR0,{"PE3","9434","","LIBERIA "})
	AAdd(aFR0,{"PE3","9438","","LIBIA   "})
	AAdd(aFR0,{"PE3","9440","","LIECHTENSTEIN   "})
	AAdd(aFR0,{"PE3","9443","","LITUANIA        "})
	AAdd(aFR0,{"PE3","9445","","LUXEMBURGO      "})
	AAdd(aFR0,{"PE3","9447","","MACAO   "})
	AAdd(aFR0,{"PE3","9448","","MACEDONIA       "})
	AAdd(aFR0,{"PE3","9450","","MADAGASCAR      "})
	AAdd(aFR0,{"PE3","9453","","MADEIRA "})
	AAdd(aFR0,{"PE3","9455","","MALAYSIA        "})
	AAdd(aFR0,{"PE3","9458","","MALAWI  "})
	AAdd(aFR0,{"PE3","9461","","MALDIVAS        "})
	AAdd(aFR0,{"PE3","9464","","MALI    "})
	AAdd(aFR0,{"PE3","9467","","MALTA   "})
	AAdd(aFR0,{"PE3","9469","","MARIANAS DEL NORTE, ISLAS       "})
	AAdd(aFR0,{"PE3","9472","","MARSHALL, ISLAS "})
	AAdd(aFR0,{"PE3","9474","","MARRUECOS       "})
	AAdd(aFR0,{"PE3","9477","","MARTINICA       "})
	AAdd(aFR0,{"PE3","9485","","MAURICIO        "})
	AAdd(aFR0,{"PE3","9488","","MAURITANIA      "})
	AAdd(aFR0,{"PE3","9493","","MEXICO  "})
	AAdd(aFR0,{"PE3","9494","","MICRONESIA, ESTADOS FEDERADOS DE        "})
	AAdd(aFR0,{"PE3","9495","","MIDWAY ISLAS    "})
	AAdd(aFR0,{"PE3","9496","","MOLDAVIA        "})
	AAdd(aFR0,{"PE3","9497","","MONGOLIA        "})
	AAdd(aFR0,{"PE3","9498","","MONACO  "})
	AAdd(aFR0,{"PE3","9501","","MONTSERRAT, ISLA        "})
	AAdd(aFR0,{"PE3","9505","","MOZAMBIQUE      "})
	AAdd(aFR0,{"PE3","9507","","NAMIBIA "})
	AAdd(aFR0,{"PE3","9508","","NAURU   "})
	AAdd(aFR0,{"PE3","9511","","NAVIDAD (CHRISTMAS), ISLA       "})
	AAdd(aFR0,{"PE3","9517","","NEPAL   "})
	AAdd(aFR0,{"PE3","9521","","NICARAGUA       "})
	AAdd(aFR0,{"PE3","9525","","NIGER   "})
	AAdd(aFR0,{"PE3","9528","","NIGERIA "})
	AAdd(aFR0,{"PE3","9531","","NIUE, ISLA      "})
	AAdd(aFR0,{"PE3","9535","","NORFOLK, ISLA   "})
	AAdd(aFR0,{"PE3","9538","","NORUEGA "})
	AAdd(aFR0,{"PE3","9542","","NUEVA CALEDONIA "})
	AAdd(aFR0,{"PE3","9545","","PAPUASIA NUEVA GUINEA   "})
	AAdd(aFR0,{"PE3","9548","","NUEVA ZELANDA   "})
	AAdd(aFR0,{"PE3","9551","","VANUATU "})
	AAdd(aFR0,{"PE3","9556","","OMAN    "})
	AAdd(aFR0,{"PE3","9566","","PACIFICO, ISLAS DEL     "})
	AAdd(aFR0,{"PE3","9573","","PAISES BAJOS    "})
	AAdd(aFR0,{"PE3","9576","","PAKISTAN        "})
	AAdd(aFR0,{"PE3","9578","","PALAU, ISLAS    "})
	AAdd(aFR0,{"PE3","9579","","TERRITORIO AUTONOMO DE PALESTINA.       "})
	AAdd(aFR0,{"PE3","9580","","PANAMA  "})
	AAdd(aFR0,{"PE3","9586","","PARAGUAY        "})
	AAdd(aFR0,{"PE3","9589","","PERÚ    "})
	AAdd(aFR0,{"PE3","9593","","PITCAIRN, ISLA  "})
	AAdd(aFR0,{"PE3","9599","","POLINESIA FRANCESA      "})
	AAdd(aFR0,{"PE3","9603","","POLONIA "})
	AAdd(aFR0,{"PE3","9607","","PORTUGAL        "})
	AAdd(aFR0,{"PE3","9611","","PUERTO RICO     "})
	AAdd(aFR0,{"PE3","9618","","QATAR   "})
	AAdd(aFR0,{"PE3","9628","","REINO UNIDO     "})
	AAdd(aFR0,{"PE3","9629","","ESCOCIA "})
	AAdd(aFR0,{"PE3","9633","","REPUBLICA ARABE UNIDA   "})
	AAdd(aFR0,{"PE3","9640","","REPUBLICA CENTROAFRICANA        "})
	AAdd(aFR0,{"PE3","9644","","REPUBLICA CHECA "})
	AAdd(aFR0,{"PE3","9645","","REPUBLICA DE SWAZILANDIA        "})
	AAdd(aFR0,{"PE3","9646","","REPUBLICA DE TUNEZ      "})
	AAdd(aFR0,{"PE3","9647","","REPUBLICA DOMINICANA    "})
	AAdd(aFR0,{"PE3","9660","","REUNION "})
	AAdd(aFR0,{"PE3","9665","","ZIMBABWE        "})
	AAdd(aFR0,{"PE3","9670","","RUMANIA "})
	AAdd(aFR0,{"PE3","9675","","RUANDA  "})
	AAdd(aFR0,{"PE3","9676","","RUSIA   "})
	AAdd(aFR0,{"PE3","9677","","SALOMON, ISLAS  "})
	AAdd(aFR0,{"PE3","9685","","SAHARA OCCIDENTAL       "})
	AAdd(aFR0,{"PE3","9687","","SAMOA OCCIDENTAL        "})
	AAdd(aFR0,{"PE3","9690","","SAMOA NORTEAMERICANA    "})
	AAdd(aFR0,{"PE3","9695","","SAN CRISTOBAL Y NIEVES  "})
	AAdd(aFR0,{"PE3","9697","","SAN MARINO      "})
	AAdd(aFR0,{"PE3","9700","","SAN PEDRO Y MIQUELON    "})
	AAdd(aFR0,{"PE3","9705","","SAN VICENTE Y LAS GRANADINAS    "})
	AAdd(aFR0,{"PE3","9710","","SANTA ELENA     "})
	AAdd(aFR0,{"PE3","9715","","SANTA LUCIA     "})
	AAdd(aFR0,{"PE3","9720","","SANTO TOME Y PRINCIPE   "})
	AAdd(aFR0,{"PE3","9728","","SENEGAL "})
	AAdd(aFR0,{"PE3","9731","","SEYCHELLES      "})
	AAdd(aFR0,{"PE3","9735","","SIERRA LEONA    "})
	AAdd(aFR0,{"PE3","9741","","SINGAPUR        "})
	AAdd(aFR0,{"PE3","9744","","SIRIA, REPUBLICA ARABE DE       "})
	AAdd(aFR0,{"PE3","9748","","SOMALIA "})
	AAdd(aFR0,{"PE3","9750","","SRI LANKA       "})
	AAdd(aFR0,{"PE3","9756","","SUDAFRICA, REPUBLICA DE "})
	AAdd(aFR0,{"PE3","9759","","SUDAN   "})
	AAdd(aFR0,{"PE3","9764","","SUECIA  "})
	AAdd(aFR0,{"PE3","9767","","SUIZA   "})
	AAdd(aFR0,{"PE3","9770","","SURINAM "})
	AAdd(aFR0,{"PE3","9773","","SAWSILANDIA     "})
	AAdd(aFR0,{"PE3","9774","","TADJIKISTAN     "})
	AAdd(aFR0,{"PE3","9776","","TAILANDIA       "})
	AAdd(aFR0,{"PE3","9780","","TANZANIA, REPUBLICA UNIDA DE    "})
	AAdd(aFR0,{"PE3","9783","","DJIBOUTI        "})
	AAdd(aFR0,{"PE3","9786","","TERRITORIO ANTARTICO BRITANICO  "})
	AAdd(aFR0,{"PE3","9787","","TERRITORIO BRITANICO DEL OCEANO INDICO  "})
	AAdd(aFR0,{"PE3","9788","","TIMOR DEL ESTE  "})
	AAdd(aFR0,{"PE3","9800","","TOGO    "})
	AAdd(aFR0,{"PE3","9805","","TOKELAU "})
	AAdd(aFR0,{"PE3","9810","","TONGA   "})
	AAdd(aFR0,{"PE3","9815","","TRINIDAD Y TOBAGO       "})
	AAdd(aFR0,{"PE3","9816","","TRISTAN DA CUNHA        "})
	AAdd(aFR0,{"PE3","9820","","TUNICIA "})
	AAdd(aFR0,{"PE3","9823","","TURCAS Y CAICOS, ISLAS  "})
	AAdd(aFR0,{"PE3","9825","","TURKMENISTAN    "})
	AAdd(aFR0,{"PE3","9827","","TURQUIA "})
	AAdd(aFR0,{"PE3","9828","","TUVALU  "})
	AAdd(aFR0,{"PE3","9830","","UCRANIA "})
	AAdd(aFR0,{"PE3","9833","","UGANDA  "})
	AAdd(aFR0,{"PE3","9840","","URSS    "})
	AAdd(aFR0,{"PE3","9845","","URUGUAY "})
	AAdd(aFR0,{"PE3","9847","","UZBEKISTAN      "})
	AAdd(aFR0,{"PE3","9850","","VENEZUELA       "})
	AAdd(aFR0,{"PE3","9855","","VIET NAM        "})
	AAdd(aFR0,{"PE3","9858","","VIETNAM (DEL NORTE)     "})
	AAdd(aFR0,{"PE3","9863","","VIRGENES, ISLAS (BRITANICAS)    "})
	AAdd(aFR0,{"PE3","9866","","VIRGENES, ISLAS (NORTEAMERICANAS)       "})
	AAdd(aFR0,{"PE3","9870","","FIJI    "})
	AAdd(aFR0,{"PE3","9873","","WAKE, ISLA      "})
	AAdd(aFR0,{"PE3","9875","","WALLIS Y FORTUNA, ISLAS "})
	AAdd(aFR0,{"PE3","9880","","YEMEN   "})
	AAdd(aFR0,{"PE3","9885","","YUGOSLAVIA      "})
	AAdd(aFR0,{"PE3","9888","","ZAIRE   "})
	AAdd(aFR0,{"PE3","9890","","ZAMBIA  "})
	AAdd(aFR0,{"PE3","9895","","ZONA DEL CANAL DE PANAMA        "})
	AAdd(aFR0,{"PE3","9896","","ZONA LIBRE OSTRAVA      "})
	AAdd(aFR0,{"PE3","9897","","ZONA NEUTRAL (PALESTINA)        "})
	nFim := Len(aFR0)
	For nI := nInicio To nFim
		cChave := AllTrim(aFR0[nI,4])
		For nX := 1 To 4
			Aadd(aFR0[nI],cChave)
		Next
	Next

	//	datas de venvimentos para titulos de impostos
	AAdd(aFR0,{"000","PE4","","Tabla de vencimientos para las obligaciones tributarias","Tabla de vencimientos para las obligaciones tributarias","Tabla de vencimientos para las obligaciones tributarias","Tabla de vencimientos para las obligaciones tributarias","Tabla de vencimientos para las obligaciones tributarias"} )
	AAdd(aFR0,{"PE4"," "," "," "," "," "," "," "})
EndIf

If cPaisLoc == "EQU"
	// Código de Status de Pagamento
	AAdd(aFR0,{"000","EQ2","","Estatus de Pago","Estatus de Pago","Estatus de Pago","Estatus de Pago","Estatus de Pago"} ) 	//"Status de Pagamento"
	AAdd(aFR0,{"EQ2","01" ,"","En analise","En analise","En analise","En analise","En analise"})  							//"Em Análise"
	AAdd(aFR0,{"EQ2","02" ,"","Pago Aprobado","Pago Aprobado","Pago Aprobado","Pago Aprobado","Pago Aprobado"} )   			//"Pagamento Aprovado"
	AAdd(aFR0,{"EQ2","03" ,"","Rechazo Parcial","Rechazo Parcial","Rechazo Parcial","Rechazo Parcial","Rechazo Parcial"} )  //"Rejeição Parcial"
	AAdd(aFR0,{"EQ2","04" ,"","Rechazo Total","Rechazo Total","Rechazo Total","Rechazo Total","Rechazo Total" } )		  	//"Rejeição Total"
	// Motivos de Rejeição
	AAdd(aFR0,{"000","EQ3","","Motivos de Rechazo","Motivos de Rechazo","Motivos de Rechazo","Motivos de Rechazo","Motivos de Rechazo"} ) 	//"Motivos de Rejeição"
	AAdd(aFR0,{"EQ3","01" ,"","Tarjeta de credito o debito no existe","Tarjeta de credito o debito no existe","Tarjeta de credito o debito no existe","Tarjeta de credito o debito no existe","Tarjeta de credito o debito no existe"})		//"Cartão de credito ou debito não existe"
	AAdd(aFR0,{"EQ3","02" ,"","Tarjeta de credito o debito vencida","Tarjeta de credito o debito vencida","Tarjeta de credito o debito vencida","Tarjeta de credito o debito vencida","Tarjeta de credito o debito vencida"} )   			//"Cartao de credito vencido"
	AAdd(aFR0,{"EQ3","03" ,"","Tarjeta de credito o debito bloqueado","Tarjeta de credito o debito bloqueado","Tarjeta de credito o debito bloqueado","Tarjeta de credito o debito bloqueado","Tarjeta de credito o debito bloqueado"} )  	//"Cartão de credito ou debito bloqueado"
	AAdd(aFR0,{"EQ3","04" ,"","Sin limite de credito","Sin limite de credito","Sin limite de credito","Sin limite de credito","Sin limite de credito" } )		  	//"Sem limite de credito"
	AAdd(aFR0,{"EQ3","05" ,"","Otros","Otros","Otros","Otros","Otros"} ) //Outros
	// Meios de Pagamentos
	AAdd(aFR0,{"000","EQ4","","Medios de Pagos","Medios de Pagos","Medios de Pagos","Medios de Pagos","Medios de Pagos"} ) 	//"Meios de Pagamentos"
	AAdd(aFR0,{"EQ4","01" ,"","Cheque","Cheque","Cheque","Cheque","Cheque"})					//"Cheque"
	AAdd(aFR0,{"EQ4","02" ,"","Transferencia bancaria","Transferencia bancaria","Transferencia bancaria","Transferencia bancaria","Transferencia bancaria"})	//"Transferencia bancaria"
	AAdd(aFR0,{"EQ4","03" ,"","Acreditación","Acreditación","Acreditación","Acreditación","Acreditación"} )	//"Credito"
	AAdd(aFR0,{"EQ4","04" ,"","CBU-Cuenta Corriente","CBU-Cuenta Corriente","CBU-Cuenta Corriente","CBU-Cuenta Corriente","CBU-Cuenta Corriente" } )	//"CBU-Conta Corrente"
	// Estatus de Cheques
	AAdd(aFR0,{"000","EQ5","","Estatus de Cheques","Estatus de Cheques","Estatus de Cheques","Estatus de Cheques","Estatus de Cheques"} ) 	//"Situação dos Cheques"
	AAdd(aFR0,{"EQ5","00" ,"","No usado","No usado","No usado","No usado","No usado"}) //"Não usado"
	AAdd(aFR0,{"EQ5","01" ,"","En cartera","En cartera","En cartera","En cartera","En cartera"}) //"Transferencia bancaria"
	AAdd(aFR0,{"EQ5","02" ,"","Asignado a un pago","Asignado a un pago","Asignado a un pago","Asignado a un pago","Asignado a un pago"} )	//"Pagamento Vinculado"
	AAdd(aFR0,{"EQ5","03" ,"","Emitido","Emitido","Emitido","Emitido","Emitido"} )	//"Emitido"
	AAdd(aFR0,{"EQ5","04" ,"","Dado de baja","Dado de baja","Dado de baja","Dado de baja","Dado de baja" } ) //"Liquidado"
	AAdd(aFR0,{"EQ5","05" ,"","Imnutilizado","Imnutilizado","Imnutilizado","Imnutilizado","Imnutilizado" } ) //"Anulado"
	AAdd(aFR0,{"EQ5","06" ,"","Reemplazado","Reemplazado","Reemplazado","Reemplazado","Reemplazado" } )	//"Substituido"
	AAdd(aFR0,{"EQ5","07" ,"","Rechazado","Rechazado","Rechazado","Rechazado","Rechazado" } )//"Devolvido"
	// Tipos de Caja y Bancos
	AAdd(aFR0,{"000","EQ6","","Tipos de Caja y Bancos","Tipos de Caja y Bancos","Tipos de Caja y Bancos","Tipos de Caja y Bancos","Tipos de Caja y Bancos" }) //"Tipo de Caixa e Bancos"
	AAdd(aFR0,{"EQ6","01" ,"","Banco Cuenta Corriente","Banco Cuenta Corriente","Banco Cuenta Corriente","Banco Cuenta Corriente","Banco Cuenta Corriente" }) //"Banco Conta Corrente"
	AAdd(aFR0,{"EQ6","02" ,"","Banco Cuenta Ahorro","Banco Cuenta Ahorro","Banco Cuenta Ahorro","Banco Cuenta Ahorro","Banco Cuenta Ahorro"}) //"Banco Conta Poupança"
	AAdd(aFR0,{"EQ6","03" ,"","Fondo Fijo","Fondo Fijo","Fondo Fijo","Fondo Fijo","Fondo Fijo"} ) //"Fundo Fixo"
	AAdd(aFR0,{"EQ6","04" ,"","Caja Chica","Caja Chica","Caja Chica","Caja Chica","Caja Chica" } )	//"Caixinha"
EndIf

If cPaisLoc == "DOM"
	// Classificação das Operações Financeiras.
	AAdd(aFR0,{"000","RD1","","Clasificación Op. Financieras","Clasificación Op. Financieras","Clasificación Op. Financieras","Clasificación Op. Financieras","Clasificación Op. Financieras"} )
	AAdd(aFR0,{"RD1","01" ,"","Gastos Personal","Gastos Personal","Gastos Personal","Gastos Personal","Gastos Personal"})
	AAdd(aFR0,{"RD1","02" ,"","Gastos por Trabajos, Suministos y Servicios","Gastos por Trabajos, Suministos y Servicios","Gastos por Trabajos, Suministos y Servicios","Gastos por Trabajos, Suministos y Servicios","Gastos por Trabajos, Suministos y Servicios"} )
	AAdd(aFR0,{"RD1","03" ,"","Arrendamientos","Arrendamientos","Arrendamientos","Arrendamientos","Arrendamientos"} )
	AAdd(aFR0,{"RD1","04" ,"","Gastos de Activos Fijos","Gastos de Activos Fijos","Gastos de Activos Fijos","Gastos de Activos Fijos","Gastos de Activos Fijos" } )
	AAdd(aFR0,{"RD1","05" ,"","Gastos de Representación","Gastos de Representación","Gastos de Representación","Gastos de Representación","Gastos de Representación" } )
	AAdd(aFR0,{"RD1","06" ,"","Otras Deducciones Admitidas","Otras Deducciones Admitidas","Otras Deducciones Admitidas","Otras Deducciones Admitidas","Otras Deducciones Admitidas" } )
	AAdd(aFR0,{"RD1","07" ,"","Gastos Financieros","Gastos Financieros","Gastos Financieros","Gastos Financieros","Gastos Financieros" } )
	AAdd(aFR0,{"RD1","08" ,"","Gastos Extraordinarios","Gastos Extraordinarios","Gastos Extraordinarios","Gastos Extraordinarios","Gastos Extraordinarios" } )
	AAdd(aFR0,{"RD1","09" ,"","Compras y Gastos que formaran parte del Costo de Ventas","Compras y Gastos que formaran parte del Costo de Ventas","Compras y Gastos que formaran parte del Costo de Ventas","Compras y Gastos que formaran parte del Costo de Ventas","Compras y Gastos que formaran parte del Costo de Ventas" } )
	AAdd(aFR0,{"RD1","10" ,"","Adquisiciones de Activos","Adquisiciones de Activos","Adquisiciones de Activos","Adquisiciones de Activos","Adquisiciones de Activos" } )
EndIf

If cPaisLoc == "BRA"
	//Indicador de Natureza de Retenção
	AAdd(aFR0,{"000","001","","Indicador de Natureza de Retenção na Fonte"						,"Indicador de la Modalidad de Retencion"								,"Type of Withholding in the Income Tax"							,"Indicador de Natureza de Retenção na Fonte","Indicador de Natureza de Retenção na Fonte"} )
	AAdd(aFR0,{"001","01","","Retenção por Órgãos, Autarquias e Fundaçõe Federais" 				,"Retención de Órganos, Autarquías y Fundaciones Federales"				,"Withholding by Federal Bodies, Autarchy and Foundations"			,"",""})
	AAdd(aFR0,{"001","02","","Retenção por outras Entidades da Administração Pública Federal"	,"Retención por otras Entidades de la Administración Pública Federal"	,"Withholding by other Federal Public Administration Entities"		,"",""})
	AAdd(aFR0,{"001","03","","Retenção por Pessoas Jurídicas de Direito Privado"				,"Retención por Personas Jurídicas de Derecho Privado"					,"Withholding by Legal Entities of Private Company"					,"",""})
	AAdd(aFR0,{"001","04","","Recolhimento por Sociedade Cooperativa"							,"Pago por Sociedad Cooperativa"										,"Payment by Cooperative Organization"								,"",""})
	AAdd(aFR0,{"001","05","","Retenção por Fabricante de Máquinas e Veículos"					,"Retención por Fabricante de Máquinas y Vehículos"						,"Withholding by Machinery and Vehicle Manufactures"				,"",""})
	AAdd(aFR0,{"001","99","","Outras Retenções"													,"Otras Retenciones"													,"Other Withholdings"												,"",""})
EndIf

dbSelectArea("FR0")
aAreaFR0 := GetArea()
dbSetOrder(1)
cFilFR0 := xFilial("FR0")
nLenChv := TamSX3("FR0_CHAVE")[1]
nLenTab := TamSX3("FR0_TABELA")[1]
For nI := 1 To Len(aFR0)
	cChave := xFilial("FR0") + PadR(aFR0[nI][01],nLenTab) + PadR(aFR0[nI][02],nLenChv)
	If FR0->(!dbSeek(cChave))
		RecLock("FR0",.T.)
		FR0_FILIAL	:= xFilial("FR0")
		FR0_TABELA	:= aFR0[nI][01]
		FR0_CHAVE	:= aFR0[nI][02]
		FR0_CHVAUX	:= aFR0[nI][03]
		FR0_DESC01	:= aFR0[nI][04]
		FR0_DESC02	:= aFR0[nI][05]
		FR0_DESC03	:= aFR0[nI][06]
		FR0_DESC04	:= aFR0[nI][07]
		FR0_DESC05	:= aFR0[nI][08]
		MsUnLock()
	EndIf
Next nI
RestArea(aAreaFR0)
RestArea(aAreaAtu)
Return()

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa560CProd ³ Autor ³ Jose Lucas          ³ Data ³ 21/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verificar a existencia ou criar Produto genérico para uso  ³±±
±±³          ³ na execução da MsExecAuto, integração com Compras/Fiscal.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa560CProd(ExpC1)				                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Código do Produto		    				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa560CProd(cProduto)
Local aSavArea := GetArea()
Local cDescri  := ""

DEFAULT cProduto := ""

cDescri := If(cProduto$"499",STR0102,STR0103)

SB1->(dbSetOrder(1))
If !SB1->(dbSeek(xFilial("SB1")+cProduto))
   	RecLock("SB1",.T.)
   	SB1->B1_FILIAL := xFilial("SB1")
   	SB1->B1_COD    := cProduto
   	SB1->B1_DESC   := cDescri
   	SB1->B1_TIPO   := "PA"
	SB1->B1_GRUPO  := "00007"
	SB1->B1_LOCPAD := "01"
	SB1->B1_UM     := "UN"
	MsUnLock()
EndIf
RestArea(aSavArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa560CTES  ³ Autor ³ Jose Lucas          ³ Data ³ 21/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verificar a existencia ou criar TES genérico para uso na   ³±±
±±³          ³ execução da MsExecAuto, integração com Compras/Fiscal.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa560Ctes(ExpC1)					                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Código do TES			    				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa560CTes(cTES)
Local aSavArea := GetArea()
Local cTexto   := ""
Local aSFC     := {}
Local aRegSFC  := {}
Local nCount   := 0
Local nCntLin  := 0
Local nCntCol  := 0

DEFAULT cTES := ""

cTexto := If(cTES$"499",STR0102,STR0103)


SF4->(dbSetOrder(1))
If !SF4->(dbSeek(xFilial("SF4")+cTES))
   	RecLock("SF4",.T.)
   	SF4->F4_FILIAL  := xFilial("SF4")
   	SF4->F4_CODIGO  := cTES
   	SF4->F4_TIPO    := "E"
   	SF4->F4_TEXTO   := cTexto
   	SF4->F4_CF      := "112"
	SF4->F4_DUPLIC  := "N"
	SF4->F4_ESTOQUE := "N"
	SF4->F4_QTDZERO := "2"
	SF4->F4_GERALF  := "1"
	SF4->F4_LIVRO   := "M100LARG"
	MsUnLock()
	SFC->(dbSetOrder(1))
	If SFC->(dbSeek(xFilial("SFC")+"012"))
		While SFC->(!Eof()) .and. SFC->FC_FILIAL == xFilial("SFC") .and. SFC->FC_TES == "012"
			aRegSFC := {}
			For nCount := 1 To SFC->(FCount())
				AADD(aRegSFC,{SFC->(FieldName(nCount)),SFC->(FieldGet(nCount))})
			Next nCount
			AADD(aSFC,AClone(aRegSFC))
			SFC->(dbSkip())
		End
	EndIf
	If Len(aSFC) > 0
		SFC->(dbSetOrder(1))
		If ! SFC->(dbSeek(xFilial("SFC")+cTES))
			For nCntLin := 1 To Len(aSFC)
				RecLock("SFC",.T.)
		 		For nCntCol := 1 To SFC->(FCount())
		 			If AllTrim(aSFC[nCntLin][nCntCol][1]) == "FC_TES"
						SFC->FC_TES := cTES
		 			Else
		   				SFC->(FieldPut(SFC->(FieldPos(aSFC[nCntLin][nCntCol][1])),aSFC[nCntLin][nCntCol][2]))
		   			EndIf
				Next nCntCol
			    MsUnLock()
			Next nCntLin
		EndIf
	EndIf
EndIf
RestArea(aSavArea)
Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa560CCond ³ Autor ³ Jose Lucas          ³ Data ³ 21/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verificar a existencia ou criar a Condicao genérica para   ³±±
±±³          ³ uso na MsExecAuto, integração com Compras/Fiscal.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa560CProd(ExpC1)				                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Código do Produto		    				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa560CCond(cCondicao)
Local aSavArea := GetArea()
Local cDescri  := ""

DEFAULT cCondicao := ""
	
cDescri := If(cCondicao$"499",STR0102,STR0103)


SE4->(dbSetOrder(1))
If !SE4->(dbSeek(xFilial("SE4")+cCondicao))
   	RecLock("SE4",.T.)
   	SE4->E4_FILIAL := xFilial("SE4")
   	SE4->E4_CODIGO := cCondicao
   	SE4->E4_TIPO   := "1"
   	SE4->E4_COND   := "0" //A vista
	SE4->E4_DESCRI := cDescri
	SE4->E4_DDD    := "D"
	SE4->E4_ACRES  := "N"
	MsUnLock()
EndIf
RestArea(aSavArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FinaAtuFJSºAutor  ³Jair Ribeiro        º Data ³  08/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Conteudo padrao Tabela modo de pagamento                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinaAtuFJS()
Local nI		:= 0
Local nJ		:= 0
Local aEstrut	:= {}
Local aFJS		:= {}
Local aArea		:= FJS->(GetArea())
Local cFilFJS	:= xFilial("FJS")

aEstrut := {"FJS_FILIAL","FJS_TIPO","FJS_CARTE","FJS_DESC","FJS_RCOP","FJS_TRANS","FJS_TERCEI","FJS_BLOQ","FJS_TIPOIN","FJS_TPVAL"}

If cPaisLoc == "ARG"
	aAdd(aFJS,{cFilFJS,"CH"		,"3","Cheque"					,"1","2","4","2","CH","1"})
	aAdd(aFJS,{cFilFJS,"PGR"	,"1","Pagaré"					,"1","2","1","2","DC"," "})
	aAdd(aFJS,{cFilFJS,"RI"		,"1","Retención IVA"			,"3","2","4","2","RI"," "})
	aAdd(aFJS,{cFilFJS,"RG"		,"1","Retención ganancias"		,"3","2","4","2","RG"," "})
	aAdd(aFJS,{cFilFJS,"RB"		,"1","Retención Ing. Brutos"	,"3","2","4","2","RB"," "})
	aAdd(aFJS,{cFilFJS,"RS"		,"1","SUSS"						,"3","2","4","2","RS"," "})
	aAdd(aFJS,{cFilFJS,"EF"		,"3","En efectivo"				,"2","2","4","2","EF"," "})
	aAdd(aFJS,{cFilFJS,"TF"		,"3","Depósito"					,"2","2","4","2","TF"," "})
Else
	aAdd(aFJS,{cFilFJS,"CH"		,"3","Cheque"					,"1","2","4","2","CH","1"})
	aAdd(aFJS,{cFilFJS,"EF"		,"3","En efectivo"				,"2","2","4","2","EF"," "})
	aAdd(aFJS,{cFilFJS,"TF"		,"3","Depósito"					,"2","2","4","2","TF"," "})
	aAdd(aFJS,{cFilFJS,"DC"	    ,"3","Pagaré"                   ,"1","2","4","2","DC"," "})
EndIf

DbSelectArea("FJS")
FJS->(DbSetOrder(1)) //FJS_FILIAL+FJS_TIPO
FJS->(DbGoTop())
If FJS->(EOF())
	For nI := 1 To Len(aFJS)
		If !FJS->(DbSeek(PadR(aFJS[nI,1],TamSx3("FJS_FILIAL")[1])+PadR(aFJS[nI,2],TamSx3("FJS_TIPO")[1])))
			FJS->(RecLock("FJS",.T.))
			For nJ:=1 to Len(aEstrut)
				If FJS->(FieldPos(aEstrut[nJ]))> 0
					FJS->(FieldPut(FieldPos(aEstrut[nJ]),aFJS[nI,nJ]))
				EndIf
			Next nJ
			FJS->(MsUnlock())
		EndIf
	Next nI
EndIf
FJS->(RestArea(aArea))
Return

//---------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc} FinaAtuSEJ
Função para popular tabela SEJ na inicialização do SIGAFIN
Facilitador para uso do CNAB

@sample FinaAtuSEJ()
@author Mauricio Pequim Jr
@since 17/05/13
@version 1.0

/*/
//---------------------------------------------------------------------------------------------------------
Static Function FinaAtuSEJ()
Local nI		:= 0
Local nJ		:= 0
Local aEstrut	:= {}
Local aSEJ		:= {}
Local aArea		:= SEJ->(GetArea())
Local cFilSEJ	:= xFilial("SEJ")
Local nTamFil	:= TamSx3("EJ_FILIAL")[1]
Local nTamBco	:= TamSx3("EJ_BANCO")[1]
Local nTamOcor	:= TamSx3("EJ_OCORBCO")[1]

aEstrut := {"EJ_FILIAL","EJ_BANCO","EJ_OCORBCO","EJ_OCORSIS","EJ_DESC","EJ_DEBCRE"}

aAdd(aSEJ,{cFilSEJ,'001','101','CHQ','CHEQUES','D'})
aAdd(aSEJ,{cFilSEJ,'001','102','ENC','ENCARGOS','D'})
aAdd(aSEJ,{cFilSEJ,'001','103','EST','ESTORNOS','D'})
aAdd(aSEJ,{cFilSEJ,'001','104','LAV','LANCAMENTOS AVISADOS','D'})
aAdd(aSEJ,{cFilSEJ,'001','105','ENC','TARIFAS','D'})
aAdd(aSEJ,{cFilSEJ,'001','106','LAV','APLICACAO','D'})
aAdd(aSEJ,{cFilSEJ,'001','107','LAV','EMPREST / FINANCIAM','D'})
aAdd(aSEJ,{cFilSEJ,'001','108','LAV','CAMBIO','D'})
aAdd(aSEJ,{cFilSEJ,'001','109','ENC','CPMF','D'})
aAdd(aSEJ,{cFilSEJ,'001','110','ENC','IOF','D'})
aAdd(aSEJ,{cFilSEJ,'001','111','ENC','IMPOSTO DE RENDA','D'})
aAdd(aSEJ,{cFilSEJ,'001','112','COB','PAGAM FORNECEDORES','D'})
aAdd(aSEJ,{cFilSEJ,'001','113','COB','PAGAM FUNCIONARIOS','D'})
aAdd(aSEJ,{cFilSEJ,'001','114','COB','SAQUE ELETRONICO','D'})
aAdd(aSEJ,{cFilSEJ,'001','115','LAV','ACOES','D'})
aAdd(aSEJ,{cFilSEJ,'001','116','LAV','SEGUROS','D'})
aAdd(aSEJ,{cFilSEJ,'001','117','LAV','TRANSF ENTRE CONTAS','D'})
aAdd(aSEJ,{cFilSEJ,'001','118','EST','DEVOL DA COMPENSACAO','D'})
aAdd(aSEJ,{cFilSEJ,'001','119','DEV','DEVOLUCAO DE CHEQUES','D'})
aAdd(aSEJ,{cFilSEJ,'001','120','LAV','TRANSF INTERBANCARIA','D'})
aAdd(aSEJ,{cFilSEJ,'001','121','COB','DESCONTO DE DUPLICAT','D'})
aAdd(aSEJ,{cFilSEJ,'001','122','LAV','OC/AEROPS','D'})
aAdd(aSEJ,{cFilSEJ,'001','201','DEP','DEPOSITOS','C'})
aAdd(aSEJ,{cFilSEJ,'001','202','COB','COBRANCA','C'})
aAdd(aSEJ,{cFilSEJ,'001','203','DEV','DEVOLUCAO DE CHEQUES','C'})
aAdd(aSEJ,{cFilSEJ,'001','204','EST','ESTORNOS','C'})
aAdd(aSEJ,{cFilSEJ,'001','205','LAV','LANCAMENTOS AVISADOS','C'})
aAdd(aSEJ,{cFilSEJ,'001','206','LAV','RESGATE DE APLICACOE','C'})
aAdd(aSEJ,{cFilSEJ,'001','207','LAV','EMPRESTIMO / FINANCI','C'})
aAdd(aSEJ,{cFilSEJ,'001','208','LAV','CAMBIO','C'})
aAdd(aSEJ,{cFilSEJ,'001','209','DEP','TRANSF INTERBANCARIA','C'})
aAdd(aSEJ,{cFilSEJ,'001','210','LAV','ACOES','C'})
aAdd(aSEJ,{cFilSEJ,'001','211','LAV','DIVIDENDOS','C'})
aAdd(aSEJ,{cFilSEJ,'001','212','LAV','SEGURO','C'})
aAdd(aSEJ,{cFilSEJ,'001','213','DEP','TRANSF ENTRE CONTAS','C'})
aAdd(aSEJ,{cFilSEJ,'001','214','DEP','DEPOSITOS ESPECIAIS','C'})
aAdd(aSEJ,{cFilSEJ,'001','215','EST','DEVOLUCAO COMPENSACA','C'})
aAdd(aSEJ,{cFilSEJ,'001','216','DEP','OCT','C'})
aAdd(aSEJ,{cFilSEJ,'237','101','CHQ','CHEQUES','D'})
aAdd(aSEJ,{cFilSEJ,'237','102','ENC','ENCARGOS','D'})
aAdd(aSEJ,{cFilSEJ,'237','103','EST','ESTORNOS','D'})
aAdd(aSEJ,{cFilSEJ,'237','104','LAV','LANCAMENTO AVISADO','D'})
aAdd(aSEJ,{cFilSEJ,'237','105','ENC','TARIFAS','D'})
aAdd(aSEJ,{cFilSEJ,'237','106','LAV','APLICACAO','D'})
aAdd(aSEJ,{cFilSEJ,'237','107','LAV','EMPRESTIMO/FINANCIAM','D'})
aAdd(aSEJ,{cFilSEJ,'237','108','LAV','CAMBIO','D'})
aAdd(aSEJ,{cFilSEJ,'237','109','ENC','CPMF','D'})
aAdd(aSEJ,{cFilSEJ,'237','110','ENC','IOF','D'})
aAdd(aSEJ,{cFilSEJ,'237','111','ENC','IMPOSTO DE RENDA','D'})
aAdd(aSEJ,{cFilSEJ,'237','112','COB','PAGAMENTO FORNECEDOR','D'})
aAdd(aSEJ,{cFilSEJ,'237','113','LAV','PAGAMENTOS FUNCIONAR','D'})
aAdd(aSEJ,{cFilSEJ,'237','114','LAV','SAQUE ELETRONICO','D'})
aAdd(aSEJ,{cFilSEJ,'237','115','LAV','ACOES','D'})
aAdd(aSEJ,{cFilSEJ,'237','117','LAV','TRANSF ENTRE CONTAS','D'})
aAdd(aSEJ,{cFilSEJ,'237','118','DEV','DEVOLUCAO COMPENSACA','D'})
aAdd(aSEJ,{cFilSEJ,'237','119','DEV','DEVOLUCAO CHEQUES','D'})
aAdd(aSEJ,{cFilSEJ,'237','120','LAV','TRANSF INTERBANC DOC','D'})
aAdd(aSEJ,{cFilSEJ,'237','121','LAV','ANTECIPACAO A FORNEC','D'})
aAdd(aSEJ,{cFilSEJ,'237','122','LAV','OC / AEROPS','D'})
aAdd(aSEJ,{cFilSEJ,'237','201','DEP','DEPOSITOS','C'})
aAdd(aSEJ,{cFilSEJ,'237','202','COB','LIQUIDO DE COBRANCA','C'})
aAdd(aSEJ,{cFilSEJ,'237','203','DEV','DEVOLUCAO CHEQUES','C'})
aAdd(aSEJ,{cFilSEJ,'237','204','EST','ESTORNOS','C'})
aAdd(aSEJ,{cFilSEJ,'237','205','LAV','LANCAMENTO AVISADO','C'})
aAdd(aSEJ,{cFilSEJ,'237','206','LAV','RESGATE / APLICACAO','C'})
aAdd(aSEJ,{cFilSEJ,'237','207','LAV','EMPRESTIMO/FINANCIAM','C'})
aAdd(aSEJ,{cFilSEJ,'237','208','LAV','CAMBIO','C'})
aAdd(aSEJ,{cFilSEJ,'237','209','LAV','TRANSF INTERBANC DOC','C'})
aAdd(aSEJ,{cFilSEJ,'237','210','LAV','ACOES','C'})
aAdd(aSEJ,{cFilSEJ,'237','211','LAV','DIVIDENDOS','C'})
aAdd(aSEJ,{cFilSEJ,'237','212','LAV','SEGUROS','C'})
aAdd(aSEJ,{cFilSEJ,'237','213','LAV','TRANFER.ENTRE CONTAS','C'})
aAdd(aSEJ,{cFilSEJ,'237','214','DEP','DEPOSITO ESPECIAIS','C'})
aAdd(aSEJ,{cFilSEJ,'237','215','DEV','DEVOLUCAO COMPENSACA','C'})
aAdd(aSEJ,{cFilSEJ,'237','216','LAV','OCT','C'})
aAdd(aSEJ,{cFilSEJ,'237','217','LAV','PAGAMENTO FORNECEDOR','C'})
aAdd(aSEJ,{cFilSEJ,'237','218','LAV','PAGAMENTO DIVERSOS','C'})
aAdd(aSEJ,{cFilSEJ,'237','219','LAV','PAGAMENTOS SALARIOS','C'})
aAdd(aSEJ,{cFilSEJ,'341','101','CHQ','CHEQUES','D'})
aAdd(aSEJ,{cFilSEJ,'341','102','ENC','ENCARGOS','D'})
aAdd(aSEJ,{cFilSEJ,'341','103','EST','ESTORNOS','D'})
aAdd(aSEJ,{cFilSEJ,'341','104','LAV','LANCAMENTOS AVISADOS','D'})
aAdd(aSEJ,{cFilSEJ,'341','105','ENC','TARIFAS','D'})
aAdd(aSEJ,{cFilSEJ,'341','106','LAV','APLICACAO','D'})
aAdd(aSEJ,{cFilSEJ,'341','107','LAV','EMPREST / FINANCIAM','D'})
aAdd(aSEJ,{cFilSEJ,'341','108','LAV','CAMBIO','D'})
aAdd(aSEJ,{cFilSEJ,'341','109','ENC','CPMF','D'})
aAdd(aSEJ,{cFilSEJ,'341','110','ENC','IOF','D'})
aAdd(aSEJ,{cFilSEJ,'341','111','ENC','IMPOSTO DE RENDA','D'})
aAdd(aSEJ,{cFilSEJ,'341','112','COB','PAGAM FORNECEDORES','D'})
aAdd(aSEJ,{cFilSEJ,'341','113','COB','PAGAM FUNCIONARIOS','D'})
aAdd(aSEJ,{cFilSEJ,'341','114','COB','SAQUE ELETRONICO','D'})
aAdd(aSEJ,{cFilSEJ,'341','115','LAV','ACOES','D'})
aAdd(aSEJ,{cFilSEJ,'341','116','LAV','SEGUROS','D'})
aAdd(aSEJ,{cFilSEJ,'341','117','LAV','TRANSF ENTRE CONTAS','D'})
aAdd(aSEJ,{cFilSEJ,'341','118','EST','DEVOL DA COMPENSACAO','D'})
aAdd(aSEJ,{cFilSEJ,'341','119','DEV','DEVOLUCAO DE CHEQUES','D'})
aAdd(aSEJ,{cFilSEJ,'341','120','LAV','TRANSF INTERBANCARIA','D'})
aAdd(aSEJ,{cFilSEJ,'341','121','COB','DESCONTO DE DUPLICAT','D'})
aAdd(aSEJ,{cFilSEJ,'341','122','LAV','OC/AEROPS','D'})
aAdd(aSEJ,{cFilSEJ,'341','201','DEP','DEPOSITOS','C'})
aAdd(aSEJ,{cFilSEJ,'341','202','COB','COBRANCA','C'})
aAdd(aSEJ,{cFilSEJ,'341','203','DEV','DEVOLUCAO DE CHEQUES','C'})
aAdd(aSEJ,{cFilSEJ,'341','204','EST','ESTORNOS','C'})
aAdd(aSEJ,{cFilSEJ,'341','205','LAV','LANCAMENTOS AVISADOS','C'})
aAdd(aSEJ,{cFilSEJ,'341','206','LAV','RESGATE DE APLICACOE','C'})
aAdd(aSEJ,{cFilSEJ,'341','207','LAV','EMPRESTIMO / FINANCI','C'})
aAdd(aSEJ,{cFilSEJ,'341','208','LAV','CAMBIO','C'})
aAdd(aSEJ,{cFilSEJ,'341','209','DEP','TRANSF INTERBANCARIA','C'})
aAdd(aSEJ,{cFilSEJ,'341','210','LAV','ACOES','C'})
aAdd(aSEJ,{cFilSEJ,'341','211','LAV','DIVIDENDOS','C'})
aAdd(aSEJ,{cFilSEJ,'341','212','LAV','SEGURO','C'})
aAdd(aSEJ,{cFilSEJ,'341','213','DEP','TRANSF ENTRE CONTAS','C'})
aAdd(aSEJ,{cFilSEJ,'341','214','DEP','DEPOSITOS ESPECIAIS','C'})
aAdd(aSEJ,{cFilSEJ,'341','215','EST','DEVOLUCAO COMPENSACA','C'})
aAdd(aSEJ,{cFilSEJ,'341','216','DEP','OCT','C'})


DbSelectArea("SEJ")
SEJ->(DbSetOrder(1)) //EJ_FILIAL+EJ_BANCO+EJ_OCORBCO
SEJ->(DbGoTop())
If SEJ->(EOF())
	For nI := 1 To Len(aSEJ)
		If !SEJ->(DbSeek(PadR(aSEJ[nI,1],nTamFil)+PadR(aSEJ[nI,2],nTamBco)+PadR(aSEJ[nI,3],nTamOcor)))
			SEJ->(RecLock("SEJ",.T.))
			For nJ:=1 to Len(aEstrut)
				If SEJ->(FieldPos(aEstrut[nJ]))> 0
					SEJ->(FieldPut(FieldPos(aEstrut[nJ]),aSEJ[nI,nJ]))
				EndIf
			Next nJ
			SEJ->(MsUnlock())
		EndIf
	Next nI
EndIf
SEJ->(RestArea(aArea))
Return



//---------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc} FinaAtuFRV
Função para popular tabela FRV na inicialização do SIGAFIN
Situacao de cobranca

@sample FinaAtuSEJ()
@author Mauricio Pequim Jr
@since 27/11/13
@version 1.0

/*/
//---------------------------------------------------------------------------------------------------------
Function FinaAtuFRV()
Local nI		:= 0
Local nJ		:= 0
Local aEstrut	:= {}
Local aFRV		:= {}
lOCAL aPIX		:= {}
Local aArea	:= FRV->(GetArea())
Local cFilFRV	:= xFilial("FRV")
Local nTamFil	:= TamSx3("FRV_FILIAL")[1]
Local cCartPix	:= "K"
Local lTemPix	:= .F.
Local lcpoPix	:= FRV->(FieldPos("FRV_PIX")) > 0

If cPaisloc = "BRA" .And. lcpoPix
	DbSelectArea("FRV")
	FRV->(DbSetOrder(1)) //FRV_FILIAL+FRV_CODIGO
	FRV->(DbGoTop())
	If FRV->(!EOF())
		VlCartPix(@cCartPix,@lTemPix)
	EndIf
EndIf
aEstrut := {"FRV_FILIAL","FRV_CODIGO","FRV_DESCRI","FRV_BANCO","FRV_DESCON","FRV_PROTES","FRV_BLQMOV"}

aAdd(aFRV,{cFilFRV,'0'		,STR0004 ,'2','2','2','2'})	//'CARTEIRA'
aAdd(aFRV,{cFilFRV,'1'		,STR0005 ,'1','2','2','2'})	//'SIMPLES'
aAdd(aFRV,{cFilFRV,'2'		,STR0006 ,'1','1','2','2'})	//'DESCONTADA'
aAdd(aFRV,{cFilFRV,'3'		,STR0007 ,'1','2','2','2'})	//'CAUCIONADA'
aAdd(aFRV,{cFilFRV,'4'		,STR0008 ,'1','2','2','2'})	//'VINCULADA'
aAdd(aFRV,{cFilFRV,'5'		,STR0009 ,'1','2','2','2'})	//'COM ADVOGADO'
aAdd(aFRV,{cFilFRV,'6'		,STR0010 ,'1','2','1','2'})	//'JUDICIAL'
aAdd(aFRV,{cFilFRV,'7'		,STR0011 ,'1','1','2','2'})	//'CAUÇÃO DESCONTADA'
aAdd(aFRV,{cFilFRV,'F'		,STR0012 ,'2','2','1','2'})	//'CARTEIRA PROTESTO'
aAdd(aFRV,{cFilFRV,'G'		,STR0013 ,'2','2','2','2'})	//'CARTEIRA ACORDO'
aAdd(aFRV,{cFilFRV,'H'		,STR0014 ,'1','2','2','2'})	//'CARTÓRIO'
aAdd(aFRV,{cFilFRV,'I'		,STR0015 ,'2','2','2','2'})	//'CARTEIRA CAIXA LOJA'
aAdd(aFRV,{cFilFRV,'J'		,STR0016 ,'2','2','2','2'})	//'CARTEIRA CAIXA GERAL'


DbSelectArea("FRV")
FRV->(DbSetOrder(1)) //FRV_FILIAL+FRV_CODIGO
FRV->(DbGoTop())
If FRV->(EOF())
	For nI := 1 To Len(aFRV)
		If !FRV->(DbSeek(PadR(aFRV[nI,1],nTamFil)+aFRV[nI,2]))
			FRV->(RecLock("FRV",.T.))
			For nJ:=1 to Len(aEstrut)
				If FRV->(FieldPos(aEstrut[nJ]))> 0
					FRV->(FieldPut(FieldPos(aEstrut[nJ]),aFRV[nI,nJ]))
				EndIf
			Next nJ
			FRV->(MsUnlock())
		EndIf
	Next nI
EndIf
//Cria a carteira PIX caso ainda não exista nenhuma e já tenha o campo FRV_PIX
If !lTemPix .And. cPaisloc = "BRA" .And. lcpoPix
	aEstrut := {"FRV_FILIAL","FRV_CODIGO","FRV_DESCRI","FRV_BANCO","FRV_DESCON","FRV_PROTES","FRV_BLQMOV","FRV_SITPDD","FRV_PIX"}
	aAdd(aPIX,{cFilFRV,cCartPix	,STR0101 ,'1','2','2','2','2','1'})	//'CARTEIRA PIX'

	DbSelectArea("FRV")
	FRV->(DbSetOrder(1)) //FRV_FILIAL+FRV_CODIGO
	FRV->(DbGoTop())
	If !FRV->(DbSeek(PadR(aPIX[1,1],nTamFil)+aPIX[1,2]))
		FRV->(RecLock("FRV",.T.))
		For nJ:=1 to Len(aEstrut)
			If FRV->(FieldPos(aEstrut[nJ]))> 0
				FRV->(FieldPut(FieldPos(aEstrut[nJ]),aPIX[1,nJ]))
			EndIf
		Next nJ
	EndIf
	FRV->(MsUnlock())
EndIf

FRV->(RestArea(aArea))
Return


/*/{Protheus.doc} FINGrvFKB()
Função para ler a origem do movimento de baixa/adiantamento
@author Totvs
@since 18/04/2014
@version P12
/*/

Function FINGrvFKB()
Local cChave		:= ""
Local nI			:= 0
Local aAreaAtu	:= GetArea()
Local aFKB			:={}
Local nLenChv		:= 0


AAdd(aFKB,{"AP",STR0017,	"1",	"2"} ) //Aplicação
AAdd(aFKB,{"BA",STR0018,	"2",	"2"} ) //Baixa de titulo
AAdd(aFKB,{"BD",STR0019,	"1",	"2"} ) //Transferência por borderô descontado
AAdd(aFKB,{"BL",STR0020,	"1",	"2"} ) //Baixa por Lote
AAdd(aFKB,{"C2",STR0021,	"2",	"2"} ) //Correção Monetária de título em carteira descontada
AAdd(aFKB,{"CA",STR0022,	"1",	"2"} ) //Cancelamento de Cheque Avulso
AAdd(aFKB,{"CB",STR0023,	"1",	"2"} ) //Cancelamento de Transferência por borderô descontado
AAdd(aFKB,{"CD",STR0024,	"2",	"2"} ) //Cheque pré datado via Movimento Bancário Manual
AAdd(aFKB,{"CH",STR0025,	"1",	"2"} ) //Cheque
AAdd(aFKB,{"CM",STR0026,	"2",	"2"} ) //Correção Monetária
AAdd(aFKB,{"CP",STR0027,	"2",	"2"} ) //Compensação CR ou CP
AAdd(aFKB,{"CX",STR0028,	"2",	"2"} ) //Correção Monetária
AAdd(aFKB,{"D2",STR0029,	"2",	"2"} ) //Desconto em título em carteira descontada
AAdd(aFKB,{"DB",STR0030,	"1",	"2"} ) //Despesas bancárias
AAdd(aFKB,{"DC",STR0031,	"2",	"2"} ) //Desconto
AAdd(aFKB,{"DH",STR0032,	"1",	"2"} ) //Dinheiro
AAdd(aFKB,{"E2",STR0033,	"1",	"2"} ) //Estorno de movimento de desconto (Cobrança Descontada)
AAdd(aFKB,{"EC",STR0034,	"1",	"2"} ) //Estorno de cheque
AAdd(aFKB,{"EP",STR0035,	"1",	"2"} ) //Empréstimo
AAdd(aFKB,{"ES",STR0036,	"1",	"2"} ) //Estorno de Baixa
AAdd(aFKB,{"IS",STR0037,	"2",	"2"} ) //Imposto Substitutivo (Localizações)
AAdd(aFKB,{"J2",STR0038,	"2",	"2"} ) //Juros de titulo em carteira descontada
AAdd(aFKB,{"JR",STR0039,	"2",	"2"} ) //Juros
AAdd(aFKB,{"LJ",STR0040,	"1",	"2"} ) //Movimento do SigaLoja
AAdd(aFKB,{"M2",STR0041,	"2",	"2"} ) //Multa de titulo em carteira descontada
AAdd(aFKB,{"MT",STR0042,	"2",	"2"} ) //Multa
AAdd(aFKB,{"OC",STR0043,	"1",	"2"} ) //Outros Créditos
AAdd(aFKB,{"OD",STR0044,	"1",	"2"} ) //Outras Despesas
AAdd(aFKB,{"OG",STR0045,	"2",	"2"} ) //Outras Ganancias (Localizações)
AAdd(aFKB,{"PA",STR0046,	"1",	"2"} ) //Inclusão PA
AAdd(aFKB,{"PE",STR0047,	"1",	"2"} ) //Pagamento Empréstimo
AAdd(aFKB,{"R$",STR0048,	"1",	"2"} ) //Dinheiro
AAdd(aFKB,{"RA",STR0049,	"1",	"2"} ) //Inclusão RA
AAdd(aFKB,{"RF",STR0050,	"1",	"2"} ) //Resgate de Aplicações
AAdd(aFKB,{"SG",STR0051,	"1",	"2"} ) //Entrada de Dinheiro no Caixa (Loja)
AAdd(aFKB,{"TC",STR0052,	"1",	"2"} ) //Troco
AAdd(aFKB,{"TE",STR0053,	"1",	"2"} ) //Estorno de transferência (Movimento Bancário Manual)
AAdd(aFKB,{"TL",STR0054,	"2",	"2"} ) //Tolerância de Recebimento
AAdd(aFKB,{"TR",STR0055,	"1",	"2"} ) //Transferência para carteira descontada
AAdd(aFKB,{"V2",STR0056,	"1",	"2"} ) //Baixa de título em carteira descontada
AAdd(aFKB,{"VL",STR0057,	"1",	"2"} ) //Baixa de titulo
AAdd(aFKB,{"VM",STR0058,	"2",	"2"} ) //Variação Monetária
AAdd(aFKB,{"I2",STR0059,	"2",	"2"} ) //IOF calculado na cobrança descontada
AAdd(aFKB,{"IT",STR0060,	"1",	"2"} ) //Imposto nas Transações Financeiras
AAdd(aFKB,{"EI",STR0061,	"1",	"2"} ) //IOF calculado na cobrança descontada
AAdd(aFKB,{"VA",STR0078,	"2",	"2"} ) //"Valores Acessórios"


dbSelectArea("FKB")
dbSetOrder(1)
nLenChv := TamSX3("FKB_TPDOC")[1]
For nI := 1 To Len(aFKB)
	cChave := xFilial("FKB")+Padr(aFKB[nI,1],nLenChv)
	If FKB->(!MsSeek(cChave))
		RecLock("FKB",.T.)
		FKB_FILIAL	:= xFilial("FKB")
		FKB_TPDOC	:= aFKB[nI][1]
		FKB_DESCR	:= aFKB[nI][2]
		FKB_ATUBCO	:= aFKB[nI][3]
		FKB_PERALT	:= aFKB[nI][4]
		MsUnLock()
	EndIf
Next nI
RestArea(aAreaAtu)
Return()

/*/{Protheus.doc} FINFKSCWO()
Função para carregar os dados adicionais a tabela CWO referente a reestruturação do financeiro
@author Pâmela Bernardo
@since 18/12/2014
@version P12
/*/
Static Function FINFKSCWO()

Local aTabela	:= {}
Local nI		:=	0
Local cFilCWO	:= xFilial("CWO")

IncProc(STR0010)				//Cargando tablas a los puntos de asiento

AADD(aTabela,{ cFilCWO,'516','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'517','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'518','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'519','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'520','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'521','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'522','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'523','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'524','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'525','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'526','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'527','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'528','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'529','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'530','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'531','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'532','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'533','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'535','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'535','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'536','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'537','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'538','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'539','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'542','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'548','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'549','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'554','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'555','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'556','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'557','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'558','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'559','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'560','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'56A','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'56B','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'561','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'562','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'563','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'564','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'565','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'566','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'567','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'568','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'569','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'570','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'570','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'571','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'572','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'573','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'574','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'575','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'575','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'576','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'576','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'577','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'578','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'580','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'581','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'583','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'585','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'586','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'587','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'588','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'589','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'590','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'591','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'592','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'593','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'594','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'594','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'595','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'596','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'597','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'598','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'599','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'59A','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'59B','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5B9','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BA','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BB','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BC','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BD','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BE','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BF','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BG','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BH','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BI','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BJ','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BK','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BL','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BM','FK2', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BN','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BO','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BP','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BQ','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BR','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BS','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BT','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BU','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BV','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BX','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BW','FK5', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BY','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BZ','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5BT','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5C1','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5C2','FK1', '1', 'FINCARVAR()'})
AADD(aTabela,{ cFilCWO,'5C3','FK1', '1', 'FINCARVAR()'})

CWO->(DbSetOrder(2))		//CWO_FILIAL+CWO_CODPTO+CWO_TABLA
For nI := 1 To Len(aTabela)
   
	If !(CWO->(DbSeek(xFilial("CWO")+aTabela[nI][02]+aTabela[nI][03])))   
			
		RECLOCK("CWO",.T.)
		CWO->CWO_FILIAL	:= cFilCWO	   	
    	CWO->CWO_CODPTO 	:= aTabela[nI][02]
		CWO->CWO_TABLA	:= aTabela[nI][03]
		CWO->CWO_INDICE	:= aTabela[nI][04]
		CWO->CWO_LLAVE	:= aTabela[nI][05]
		CWO->CWO_TIPO		:= "F" 
		CWO->(MsUnlock())
	    	
	EndIf	
Next

Return .t.


/*/{Protheus.doc} FININCNAT()
Função para carregar as naturezas de impostos que possuem retenção baixa
@author Pâmela Bernardo
@since 23/03/2015
@version P12.1.4
/*/

Function FININCNAT()

Local cNatureza
	If cPaisloc = "BRA"
		cNatureza	:= &(SuperGetMV("MV_IRF"))
		cNatureza	:= cNatureza+Space(10-Len(cNatureza))				
		DbSelectArea("SED")
		If ( ! DbSeek( cFilial + cNatureza ) )
			RecLock("SED",.T.)
				SED->ED_FILIAL  := xFilial("SED")
				SED->ED_CODIGO  := cNatureza
				SED->ED_CALCIRF := "N"
				SED->ED_CALCISS := "N"
				SED->ED_CALCINS := "N"
				SED->ED_CALCCSL := "N"
				SED->ED_CALCCOF := "N"
				SED->ED_CALCPIS := "N"
				SED->ED_DESCRIC := "IMPOSTO RENDA RETIDO NA FONTE"
				SED->ED_TIPO	:= "2"
			MsUnlock()
			FKCOMMIT()
		EndIf
		
		
		cNatureza       := SuperGetMV("MV_PISNAT")
		cNatureza := cNatureza+(Space(10-Len(cNatureza)))
		If ( ! DbSeek( cFilial + cNatureza ) )
			RecLock("SED",.T.)
				SED->ED_FILIAL  := cFilial
				SED->ED_CODIGO  := cNatureza
				SED->ED_CALCIRF := "N"
				SED->ED_CALCISS := "N"
				SED->ED_CALCINS := "N"
				SED->ED_CALCCSL := "N"
				SED->ED_CALCCOF := "N"
				SED->ED_CALCPIS := "N"
				SED->ED_DESCRIC := "PIS"
				SED->ED_TIPO	:= "2"
			MsUnlock()
			FKCOMMIT()
		EndIf

		cNatureza	:= (SuperGetMV("MV_COFINS"))
		cNatureza	:= cNatureza+(Space(10-Len(cNatureza)))
		If ( ! DbSeek( cFilial + cNatureza ) )
			RecLock("SED",.T.)
				SED->ED_FILIAL  := xFilial()
				SED->ED_CODIGO  := cNatureza
				SED->ED_CALCIRF := "N"
				SED->ED_CALCISS := "N"
				SED->ED_CALCINS := "N"
				SED->ED_CALCCSL := "N"
				SED->ED_CALCCOF := "N"
				SED->ED_CALCPIS := "N"
				SED->ED_DESCRIC := "COFINS"
				SED->ED_TIPO	:= "2"
			MsUnlock()
			FKCOMMIT()
		EndIf
		
		cNatureza	:= SuperGetMV("MV_CSLL")
		cNatureza	:= cNatureza+(Space(10-Len(cNatureza)))
		If ( ! DbSeek( cFilial + cNatureza ) )
			RecLock("SED",.T.)
				SED->ED_FILIAL  := cFilial
				SED->ED_CODIGO  := cNatureza
				SED->ED_CALCIRF := "N"
				SED->ED_CALCISS := "N"
				SED->ED_CALCINS := "N"
				SED->ED_CALCCSL := "N"
				SED->ED_CALCCOF := "N"
				SED->ED_CALCPIS := "N"
				SED->ED_DESCRIC := "CONTRIB.S/LUCRO LIQUIDO"
				SED->ED_TIPO	:= "2"
			MsUnlock()
			FKCOMMIT()
		EndIf
		
		cNatureza		:= &(GetMv("MV_ISS"))
		cNatureza		:= cNatureza+Space(10-Len(cNatureza))
		If ( !DbSeek( cFilial + cNatureza ) )
			RecLock("SED",.T.)
				SED->ED_FILIAL  := cFilial
				SED->ED_CODIGO  := cNatureza
				SED->ED_CALCIRF := "N"
				SED->ED_CALCISS := "N"
				SED->ED_CALCINS := "N"
				SED->ED_CALCCSL := "N"
				SED->ED_CALCCOF := "N"
				SED->ED_CALCPIS := "N"
				SED->ED_DESCRIC := "IMPOSTO SOBRE SERVICOS"
				SED->ED_TIPO	:= "2"
			MsUnlock()
			FKCOMMIT()
		EndIf
		cNatureza	:= &(SuperGetMV("MV_INSS"))
		cNatureza	:= cNatureza+Space(10-Len(cNatureza))
		If ( !DbSeek( cFilial + cNatureza ) )
			RecLock("SED",.T.)
				SED->ED_FILIAL  := xFilial()
				SED->ED_CODIGO  := cNatureza
				SED->ED_CALCIRF := "N"
				SED->ED_CALCISS := "N"
				SED->ED_CALCINS := "N"
				SED->ED_CALCCSL := "N"
				SED->ED_CALCCOF := "N"
				SED->ED_CALCPIS := "N"
				SED->ED_DESCRIC := "RETENCAO P/ SEGURIDADE SOCIAL"
				SED->ED_TIPO	:= "2"
			MsUnlock()
			FKCOMMIT()
		EndIf
	EndIf

Return .T.


//---------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc} FinaAtuFW1
Função para popular tabela FW1 na inicialização do SIGAFIN
Processos para Bloqueio CR

@sample FinaAtuFw1()
@author Mauricio Pequim Jr
@since 27/05/13
@version 1.0

/*/
//---------------------------------------------------------------------------------------------------------
Static Function FinaAtuFW1()
Local nI		:= 0
Local nJ		:= 0
Local aEstrut	:= {}
Local aFw1		:= {}
Local aArea		:= FW1->(GetArea())
Local cFilFW1	:= xFilial("FW1")
Local nTamFil	:= TamSx3("FW1_FILIAL")[1]

aEstrut := {"FW1_FILIAL","FW1_CODIGO","FW1_DESCRI"}

aAdd(aFW1,{cFilFW1,'0001',STR0062})	//"Alteração do título"
aAdd(aFW1,{cFilFW1,'0002',STR0063})	//"Exclusão do título"
aAdd(aFW1,{cFilFW1,'0003',STR0064})	//"Baixa manual do título"
aAdd(aFW1,{cFilFW1,'0004',STR0065})	//"Baixa automática do título"
aAdd(aFW1,{cFilFW1,'0005',STR0066})	//"Renegociação do título via Fatura"
aAdd(aFW1,{cFilFW1,'0006',STR0067})	//"Renegociação do título via Liquidação"
aAdd(aFW1,{cFilFW1,'0007',STR0068})	//"Baixa por compensação com adiantamentos"
aAdd(aFW1,{cFilFW1,'0008',STR0069})	//"Baixa por compe,nsação entre carteiras"
aAdd(aFW1,{cFilFW1,'0009',STR0070})	//"Envio, via CNAB para cobrança bancária"
aAdd(aFW1,{cFilFW1,'0010',STR0071})	//"Solicitação de Transferências"
aAdd(aFW1,{cFilFW1,'0011',STR0072})	//"Recebimentos Diversos"
aAdd(aFW1,{cFilFW1,'0012',STR0073})	//"Envio de informações ao Serasa"
aAdd(aFW1,{cFilFW1,'0013',STR0074})	//"Workflow de cobrança"

DbSelectArea("FW1")
FW1->(DbSetOrder(1)) //FW1_FILIAL+FW1_CODIGO

For nI := 1 To Len(aFW1)
	If !FW1->(MsSeek(PadR(aFW1[nI,1],nTamFil)+aFW1[nI,2]))
		FW1->(RecLock("FW1",.T.))
		For nJ:=1 to Len(aEstrut)
			If FW1->(FieldPos(aEstrut[nJ]))> 0
				FW1->(FieldPut(FieldPos(aEstrut[nJ]),aFW1[nI,nJ]))
			EndIf
		Next nJ
		FW1->(MsUnlock())
	EndIf
Next nI

FW1->(RestArea(aArea))

Return


//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINFKSFKC
Função para popular tabela FKC na inicialização do SIGAFIN
Valores Acessórios CP (INSS/IRRF)

@sample FinaAtuFw1()
@author Mauricio Pequim Jr
@since 27/05/13
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------
Static Function FINFKSFKC()
Local nI		:= 0
Local nJ		:= 0
Local aEstrut	:= {}
Local aFKC		:= {}
Local aArea		:= FKC->(GetArea())
Local cFilFKC	:= xFilial("FKC")
Local nTamFil	:= TamSx3("FKC_FILIAL")[1]

aEstrut := {"FKC_FILIAL","FKC_CODIGO","FKC_DESC","FKC_ACAO","FKC_TPVAL","FKC_APLIC","FKC_PERIOD","FKC_ATIVO","FKC_RECPAG","FKC_VARCTB","FKC_REGRA"}

/*
FKC_ACAO	= 1=Soma;2=Subtrai
FKC_TPVAL	= 1=Percentual;2=Valor
FKC_APLIC	= 1=Até a data de vencimento;2=Apos a data de vencimento;3=Sempre
FKC_PERIOD	= 1=Fixo;2=Diario;3=Mensal;4=Anual
FKC_ATIVO	= 1=Sim;2=Não
FKC_RECPAG	= 1=Pagar;2=Receber;3=Ambas
*/

aAdd(aFKC,{cFilFKC,'000001',STR0075,"1","2","3","1","1","1","VALORENT",""})		//"Valores de Outras Entidades"
aAdd(aFKC,{cFilFKC,'000002',STR0076,"1","2","3","1","1","1","JURTRIB" ,""})		//"Juros de tributos"
aAdd(aFKC,{cFilFKC,'000003',STR0077,"1","2","3","1","1","1","MULTRIB" ,""})		//"Multa de tributos"

DbSelectArea("FKC")
FKC->(DbSetOrder(1)) //FW1_FILIAL+FW1_CODIGO

For nI := 1 To Len(aFKC)
	If !FKC->(MsSeek(PadR(aFKC[nI,1],nTamFil)+aFKC[nI,2]))
		FKC->(RecLock("FKC",.T.))
		For nJ:=1 to Len(aEstrut)
			If FKC->(FieldPos(aEstrut[nJ]))> 0
				FKC->(FieldPut(FieldPos(aEstrut[nJ]),aFKC[nI,nJ]))
			EndIf
		Next nJ
		FKC->(MsUnlock())
	EndIf
Next nI

FKC->(RestArea(aArea))

Return


/*/{Protheus.doc} FinValMv
Rotina para validar a sincronização dos parametros
@type  Static Function
@author ana.nascimento
@since 14/09/2017
@version 12.1.17
@return 
/*/
Static Function FinValMv()

Local cMVBQ10925 := SuperGetMv("MV_BQ10925",.T.,"1")
Local cRARTIMP := SuperGetMv("MV_RARTIMP",.T.,"2")


If cRARTIMP == "1" .And. cMVBQ10925 == "1"
	 final(STR0089,STR0090)
EndIf


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FinValFKS
Rotina para validar os compartilhamentos das FK's.

@type Static Function
@author richard.lopes
@since 27/08/2019
@version 12.1.25
@return Nil
/*/
//-------------------------------------------------------------------
Static Function FinValFKS()
	Local nX	     As Numeric
	Local nEnt	     As Numeric
	Local cTab       As Character
	Local cComp      As Character
	Local cTabAux    As Character 
	Local cTabelas   As Character 
	Local aTabelas   As Array
	Local aFilhasFKK As Array

	Local lRet       As Logical

	nX	       := 0
	nEnt       := 0
	cTab       := "SE5" 
	cComp      := ""
	cTabAux    := ""
	cTabelas   := ""
	aTabelas   := {}
	aFilhasFKK := {"FKL", "FKN","FKO","FKP","FKS", "FKT","FKU","FKV","FOS","FOT","FOV","FOU"}

	lRet     := .F.


	For nEnt := 1 To 3
		cComp := FwModeAccess(cTab, nEnt)

		For nX := 1 To 10
			cTabAux := "FK" + If(nX == 10, 'A', Right(Str(nX), 1))

			If (!FwModeAccess(cTabAux, nEnt) == cComp)
				If aScan(aTabelas, cTabAux) < 1
					aAdd(aTabelas, cTabAux)
				EndIf
			EndIf
		Next nX
	Next nEnt

	If !Empty(aTabelas)
		For nX := 1 To Len(aTabelas)
			If nX == Len(aTabelas)
				cTabelas += aTabelas[nX]
			Else
				cTabelas += aTabelas[nX] + ", "
			EndIf
		Next nX

		Help(' ', 1, STR0079,, STR0080 + " " + cTabelas + STR0081 + cTab , 2, 0,,,,,, {STR0082})
		lRet := .T.
	EndIf

	nX	     := 0
	nEnt     := 0
	cTab     := "FKK"
	cComp	 := ""
	cTabelas := ""
	aTabelas := {}

	If AliasInDic(cTab) .and. AliasInDic("FK0")
		For nEnt := 1 To 3
			cComp := FwModeAccess(cTab, nEnt)

			For nX := 1 To Len(aFilhasFKK)
				If (!FwModeAccess(aFilhasFKK[nX], nEnt) == cComp)
					If aScan(aTabelas, aFilhasFKK[nX]) < 1
						aAdd(aTabelas, aFilhasFKK[nX])
					EndIf
				EndIf
			Next nX
		Next nEnt

		If !Empty(aTabelas)
			For nX := 1 To Len(aTabelas)
				If nX == Len(aTabelas)
					cTabelas += aTabelas[nX]
				Else
					cTabelas += aTabelas[nX] + ", "
				EndIf
			Next nX

			Help(' ', 1, STR0079,, STR0080 + " " + cTabelas + STR0081 + cTab , 2, 0,,,,,, {STR0082})
			lRet := .T.
		EndIf
	Endif

	nEnt      := 0
	cComp     := ""
	cTab      := "SE1"
	cTabAux   := "FKD"

	For nEnt  := 1 To 3
		cComp := FwModeAccess(cTab, nEnt)
		If(!FwModeAccess(cTabAux, nEnt) == cComp)
			Help(' ', 1, STR0079,, STR0091 + '"' + AllTrim(FwX2Nome(cTabAux)) + ' ('+ cTabAux + ')"' + STR0092 + '"' + AllTrim(FwX2Nome(cTab)) + ' (' + cTab + ')"' , 2, 0,,,,,, {STR0082})
			lRet := .T.
			Exit
		EndIf
	Next nEnt


	If lRet
		Ms_Quit()
	EndIf
Return


/*/{Protheus.doc} LoadLGPD
Carrega array para validação do Frame se o campo será ofuscado ou não

@param 
@return aProtLGPD
@author Francisco Oliveira
@since 11/12/2019
@version P12
/*/
Static Function LoadLGPD()

Local aProtLGPD	AS Array

aProtLGPD	:= {}

If !IsBlind()
	// SA1
	Aadd(__aCpoLGPD, 'A1_NOME'   	)
	Aadd(__aCpoLGPD, 'A1_NREDUZ'   	)
	Aadd(__aCpoLGPD, 'A1_TEL'   	)
	Aadd(__aCpoLGPD, 'A1_CGC'    	)
	Aadd(__aCpoLGPD, 'A1_END'		)
	Aadd(__aCpoLGPD, 'A1_BAIRRO'	)

	// SA2
	Aadd(__aCpoLGPD, 'A2_NOME'   	)
	Aadd(__aCpoLGPD, 'A2_NREDUZ'   	)
	Aadd(__aCpoLGPD, 'A2_CGC'    	)
	Aadd(__aCpoLGPD, 'A2_EMAIL'    	)
	Aadd(__aCpoLGPD, 'A2_PFISICA'   )
	Aadd(__aCpoLGPD, 'A2_CPFIRP'    )
	Aadd(__aCpoLGPD, 'A2_TEL'    	)

	// SA3
	Aadd(__aCpoLGPD, 'A3_NOME'   	)

	// SA6
	Aadd(__aCpoLGPD, 'A6_AGENCIA' 	)
	Aadd(__aCpoLGPD, 'A6_COD' 		)
	Aadd(__aCpoLGPD, 'A6_NUMCON' 	)

	// SE1
	Aadd(__aCpoLGPD, 'E1_NOMCLI' 	)
	Aadd(__aCpoLGPD, 'E1_HIST'   	)
	Aadd(__aCpoLGPD, 'E1_AGEDEP' 	)
	Aadd(__aCpoLGPD, 'E1_EMITCHQ' 	)

	// SE2
	Aadd(__aCpoLGPD, 'E2_NOMFOR' 	)
	Aadd(__aCpoLGPD, 'E2_CTACHQ' 	)
	Aadd(__aCpoLGPD, 'E2_CNPJRET'	)

	// SE5
	Aadd(__aCpoLGPD, 'E5_BANCO'  	)
	Aadd(__aCpoLGPD, 'E5_AGENCIA'	)
	Aadd(__aCpoLGPD, 'E5_CONTA'  	)
	Aadd(__aCpoLGPD, 'E5_HISTOR' 	)
	Aadd(__aCpoLGPD, 'E5_BENEF' 	)

	// FIG
	Aadd(__aCpoLGPD, 'FIG_NOMFOR'	)
	Aadd(__aCpoLGPD, 'FIG_CNPJ'		)

	// FIF
	Aadd(__aCpoLGPD, 'FIF_CODAGE' 	)
	Aadd(__aCpoLGPD, 'FIF_CODBCO' 	)
	Aadd(__aCpoLGPD, 'FIF_NUMCC' 	)

	// FJA
	Aadd(__aCpoLGPD, 'FJA_DESTIN' 	)

	// FKF
	Aadd(__aCpoLGPD, 'FKF_CEDNOM' 	)

	// FJP
	Aadd(__aCpoLGPD, 'FJP_CONTR' 	)

	// FO0
	Aadd(__aCpoLGPD, 'FO0_RAZAO' 	)

	// FOM
	Aadd(__aCpoLGPD, 'FOM_NREDUZ' 	)
	Aadd(__aCpoLGPD, 'FOM_CNPJ' 	)

	// FV7
	Aadd(__aCpoLGPD, 'FV7_CTAFAV' 	)

	// SET
	Aadd(__aCpoLGPD, 'ET_CTABCO' 	)
	Aadd(__aCpoLGPD, 'ET_AGEBCO' 	)

	// SEQ
	Aadd(__aCpoLGPD, 'EQ_NUMCON' 	)	
	Aadd(__aCpoLGPD, 'EQ_BANCO' 	)
	Aadd(__aCpoLGPD, 'EQ_AGENCIA' 	)

	// SEL
	Aadd(__aCpoLGPD, 'EL_AGECHQ' 	)
	Aadd(__aCpoLGPD, 'EL_AGENCIA' 	)
	Aadd(__aCpoLGPD, 'EL_BANCO' 	)
	Aadd(__aCpoLGPD, 'EL_BCOCHQ' 	)
	Aadd(__aCpoLGPD, 'EL_CONTA' 	)
	Aadd(__aCpoLGPD, 'EL_CTACHQ' 	)

	// SRL
	Aadd(__aCpoLGPD, 'RL_CPFCGC' 	)

	// SEJ
	Aadd(__aCpoLGPD, 'EJ_BANCO' 	)

	// SEI
	Aadd(__aCpoLGPD, 'EI_CONTA' 	)
	Aadd(__aCpoLGPD, 'EI_BANCO' 	)
	Aadd(__aCpoLGPD, 'EI_AGENCIA' 	)

	// SEH
	Aadd(__aCpoLGPD, 'EH_AGECONT' 	)
	Aadd(__aCpoLGPD, 'EH_CONTA' 	)
	Aadd(__aCpoLGPD, 'EH_BCOCONT' 	)
	Aadd(__aCpoLGPD, 'EH_AGENCIA' 	)

	// SEG
	Aadd(__aCpoLGPD, 'EG_CONTA' 	)
	Aadd(__aCpoLGPD, 'EG_BANCO' 	)
	Aadd(__aCpoLGPD, 'EG_AGENCIA' 	)

	// SEB
	Aadd(__aCpoLGPD, 'EB_BANCO' 	)

	// SEA
	Aadd(__aCpoLGPD, 'EA_NUMCON' 	)
	Aadd(__aCpoLGPD, 'EA_AGEDEP' 	)
	Aadd(__aCpoLGPD, 'EA_PORTADO'	)

	// SE8
	Aadd(__aCpoLGPD, 'E8_CONTA' 	)
	Aadd(__aCpoLGPD, 'E8_BANCO' 	)
	Aadd(__aCpoLGPD, 'E8_AGENCIA' 	)

	// SE9
	Aadd(__aCpoLGPD, 'E9_CONTA' 	)
	Aadd(__aCpoLGPD, 'E9_BANCO' 	)
	Aadd(__aCpoLGPD, 'E9_AGENCIA' 	)

	// SEF
	Aadd(__aCpoLGPD, 'EF_NUM' 		)
	Aadd(__aCpoLGPD, 'EF_CONTA' 	)
	Aadd(__aCpoLGPD, 'EF_AGENCIA' 	)
	Aadd(__aCpoLGPD, 'EF_BANCO' 	)
	Aadd(__aCpoLGPD, 'EF_BENEF' 	)
	Aadd(__aCpoLGPD, 'EF_EMITENT' 	)

	// SEE
	Aadd(__aCpoLGPD, 'EE_CODIGO' 	)
	Aadd(__aCpoLGPD, 'EE_CONTA' 	)
	Aadd(__aCpoLGPD, 'EE_AGENCIA' 	)

	// FOD
	Aadd(__aCpoLGPD, 'FOD_NOME' 	)
	Aadd(__aCpoLGPD, 'FOD_CGCCPF' 	)

	// FVU
	Aadd(__aCpoLGPD, 'FVU_NOME' 	)
	Aadd(__aCpoLGPD, 'FVU_CNPJ' 	)

	// FK3
	Aadd(__aCpoLGPD, 'FK3_CGC' 		)

	// FK4
	Aadd(__aCpoLGPD, 'FK4_CGC' 		)

	// FK5
	Aadd(__aCpoLGPD, 'FK5_BANCO'	)
	Aadd(__aCpoLGPD, 'FK5_CONTA'	)
	Aadd(__aCpoLGPD, 'FK5_AGENCI' 	)


	aProtLGPD := FwProtectedDataUtil():UsrAccessPDField(__cUserID, __aCpoLGPD)
EndIf

Return aProtLGPD

/*/{Protheus.doc} RetGlbLGPD
Valida se o campo deverá ou não ser ofuscado

@param cCampos
@return lRet
@author Francisco Oliveira
@since 11/12/2019
@version P12
/*/

Function RetGlbLGPD(cCampos)

Local lRet		AS Logical

lRet		:= .F.

Default cCampos	:= ""

If !__lLGPDFIN
	Return lRet
Endif

If aScan(__aCpoLGPD , {|x| AllTrim(x) == cCampos }) >  0   
	If Len(__aLGPDFin) > 0
		lRet := aScan(__aLGPDFin , {|x| AllTrim(x) == cCampos }) ==  0
	Else
		lRet := .T.
	Endif
Endif

Return lRet

/*/{Protheus.doc} GetFinLGPD
Retorna se o ambiente está habilitado para ofuscação LGPD

@param 
@return __lLGPDFIN
@author rafael rondon
@since 11/12/2019
@version P12
/*/
Function GetFinLGPD()

Return __lLGPDFIN

/*/{Protheus.doc} GetHlpLGPD
Retorna tela de help se o campo informado estiver bloqueado para acesso.

@param 
@return lRet
@author Francisco Oliveira
@since 20/12/2019
@version P12
/*/

Function GetHlpLGPD(aCposHlp)

Local lRet	AS Logical
Local nX	AS Numeric

Default	aCposHlp := {}

lRet	:= .F.
nX		:= 0

If !__lLGPDFIN
	Return lRet
Endif

If Len(aCposHlp) > 0
	For nX := 1 To Len(aCposHlp)
		If RetGlbLGPD(aCposHlp[nX])
			Help(" ",1,"DADO_PROTEGIDO")
			lRet	:= .T.
			Exit
		Endif
	Next nX
Endif

Return lRet


/*/{Protheus.doc} GetLGPDValue
Retorna o valor de um determinado campo após aplicação da regra RetGlbLGPD()

@param 
@return cRet
@author Norberto Monteiro de Melo
@since 23/12/2019
@version P12
/*/
Function GetLGPDValue(cAlias, cField)
Local cRet := ""
Local nTam := 0

Default cAlias := ""
Default cField := ""

If !EMPTY(cAlias + cField) 
	If RetGlbLGPD(cField)
		nTam := TAMSX3(cField)[1]
		cRet := REPLICATE("*",nTam)
	Else
		cRet := (cAlias)->&(cField)
	EndIf
EndIf

Return cRet

/*/{Protheus.doc} VlCartPix
Reponsavel por verificar se o codigo da situacao de cobrancao ja existe,
caso exista o codigo é trocado automaticamente.

@author     Ana Nascimento
@since      20/10/2020
@version    P12.1.27
@param      cCarteira, character, código da carteira a ser verificada. parâmetro por referência
@param      lTemPix, logical, valida se já existe carteira PIX na base do cliente
@return     Nil
/*/
Static Function VlCartPix(cCarteira As Character, lTemPix As Logical)

    Local cCodCart      As Character
    Local cQuery        As Character
    Local cTempAlias    As Character
    Local aCarteira     As Array
    Local nTamFRVCod    As Numeric

    Default cCarteira   := ""
	Default lTemPix		:= .F.

    cTempAlias  := GetNextAlias()
    aCarteira   := {}

    nTamFRVCod  := TamSX3("FRV_CODIGO")[1]
    cCodCart    := Replicate("0", nTamFRVCod)

    cQuery := " SELECT FRV_CODIGO, FRV_PIX"
    cQuery += " FROM " + RetSQLName("FRV") + " FRV"
    cQuery += " WHERE FRV.D_E_L_E_T_ = ' ' AND FRV.FRV_FILIAL = '" + xFilial("FRV") + "'"
	cQuery += " ORDER BY FRV_PIX DESC"

    cQuery := ChangeQuery(cQuery)

    MPSysOpenQuery(cQuery, cTempAlias)

    (cTempAlias)->(DbGoTop())

    //Situação de Cobrança
    While (cTempAlias)->(!(EoF())) .And. !lTemPix
        AAdd(aCarteira, Upper(AllTrim((cTempalias)->FRV_CODIGO)))
		If (cTempalias)->FRV_PIX == "1"
			lTemPix := .T.
		EndIf 
        (cTempAlias)->(DbSkip())
    End

    (cTempAlias)->(DbCloseArea())

    If Len(aCarteira) > 0 .And. !lTemPix
   
        //verifica se já existe carteira com o código K na tabela
        IF !(AScan(aCarteira, Upper(Alltrim(cCarteira))) > 0) 
            Return Nil
        EndIf

		//Caso já exista carteira K irá pegar o proximo código disponivel
        cCodCart := SubStr(cCodCart, 1, nTamFRVCod)
        While cCodCart != SubStr(Replicate("Z", nTamFRVCod), 1, nTamFRVCod)
     
	        If AScan(aCarteira, Upper(AllTrim(cCodCart))) > 0
                cCodCart := Soma1(cCodCart)
            Else
                cCarteira := cCodCart
                Exit
            EndIf
        End
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FinValSEQ
Rotina para validar o tamanho dos campos de sequência das tabelas SE5 e SEF.

@type Static Function
@author douglas.oliveira
@since 08/11/2021
/*/
//-----------------------------------/--------------------------------
Static Function FinValSEQ() As Logical

Local nTamSEF As Numeric
Local nTamSE5 As Numeric
Local lRet    As Logical	

nTamSEF := 0
nTamSE5 := 0
lRet    := .F.

nTamSE5 := TamSX3("E5_SEQ")[1]

nTamSEF := TamSX3("EF_SEQUENC")[1]

If nTamSE5 <> nTamSEF
    Help(' ',1,STR0104,,STR0105,2,0,,,,,,{STR0106})
	lRet := .T.
EndIf

Return lRet





	 


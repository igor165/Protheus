#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM870.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM790  ³ Autor ³ Abel Ribeiro          ³ Data ³ 06/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Informacoes de Ingressos e Retencoes (DIAN)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±±±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS / FNC     ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rodrigo L.   ³14/01/11³00000000145/2011³-Ajuste para nova interface 11 utilizando ³±±
±±³             ³        ³                ³ a funcao MsAdvSize (p/ flexibilidade da  ³±±
±±³             ³        ³                ³ tela de acordo com a resolucao).         ³±±
±±³	            ³        ³                ³                                          ³±±
±±³Ademar Jr.   ³18/05/11³00000011782/2011³-COL-Ajustes na funcao GPM870Processa()   ³±±
±±³	            ³        ³                ³ Compartilhamento do RGO = SRA (E-E-E)    ³±±
±±³Ademar Jr.   ³08/08/11³00000020223/2011³-COL-Ajustes para gravar no RGO apenas os ³±±
±±³	            ³        ³Chamado TDMMLG  ³     funcionario que tenham valor.        ³±±
±±³Alfredo Med. ³27/11/13³Prj.:COL11.8_RH ³-MEX- Toma como referencia de NIT el      ³±±
±±³             ³        ³Req.:239713	  ³campo RA_RG,en vez de RA_CIC 			 ³±±
±±³M.Camargo    ³22/11/18³DMINA-5176 Repli³-COL- Se crea fun fExpSQLIn que convierte ³±±
±±³             ³        ³ca DMINA-4054	  ³instrucción advpl "$"(Contenido en) a     ³±±
±±³             ³        ³          	  ³expresión SQL (IN o NOT IN) se utiliza den³±±
±±³             ³        ³          	  ³-tro de fun GPM870Processa                ³±±
±±³             ³        ³          	  ³En fun fExpSQLIn se contempla instruccion ³±±
±±³             ³        ³          	  ³"$"(Contenido) con paréntesis             ³±±
±±³Oscar G.     ³21/10/20³DMINA-10247     ³Se añaden nuevas opciones por actualiza-  ³±±
±±³             ³        ³                ³cion en formato de impresion.             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPEM870()

Local nOpca 	    := 0
Local aFilterExp	:=  {} 					//expressao do filtro
Local aRetFiltro							//retorno do filtro
Local bNewFiltro							//bloco para inclusao de novos filtros
Local bAltFilter							//bloco para Alteracao do filtro selecionado
Local bBtnCalcule							//bloco do botão OK
Local bPergunte								//bloco para o pergunte
Local cSays1		 := OemToAnsi(STR0003)	//"Genera Datos para Emision del Certificado de Ingreso y Retencion"
Local cSays2		 := OemToAnsi(STR0001)	//"de acordo com a movimentação do Ano anterior."
Local oDlg
Local oBtnNewFil
Local oBtnAltFil
Local oBtnCalcule
Local oBtnEnd
Local oBtnPergunte
Local lShowDlgFilt	:= .T.					//visualizar a dialog de filtros
Local bDialogInit							//bloco de inicializacao da janela

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Private cFiltSRA    := ""
Private cFil        := ""
Private cPathFile   := ""
Private cExtRel     := ".##R"
Private cCadastro   := OemToAnsi(STR0002)   //"Genera Datos para Emision del Certificado de Ingreso y Retencion"
Private cTabMestra  := "SRA"
Private cExpFiltro	:= ""					//variavel com o retorno do filtro
Private cTxtFil     := ""
Private lTudo       := .F.
Private aINFO       := {}

DEFINE FONT oFont1  NAME "Arial" SIZE 0,-13 BOLD
cBlkGet :=  "{ | u | If( PCount() == 0, cTxtFil,cTxtFil:= u ) }"
cBlKVld :=  "{|| .T. }"
cBlKWhen := "{|| .F. }"

Pergunte("GPM870",.F.)

dbSelectArea("RGO")

bDialogInit 	:= { || ;
						Gpem870Arq(	@cTabMestra	,;
									oBtnNewFil	,;
									oBtnAltFil	,;
									oBtnCalcule	,;
									.T.			 ;
								 )								,;	// seta o arquivo Mestre
						Gpem020SetFil(@aFilterExp, cTabMestra)	,;	// Setar as opcoes que filtrara o cadastro de Filtro
						lShowDlgFilt := .F.						,;
						Gpem020Filter( 	aFilterExp	,;
										cTabMestra	,;
										@cExpFiltro ,;
										lShowDlgFil  ;
									),;	// setar o ultimo filtro utilizado
						lShowDlgFilt := .T.;
				   }
Gpem020SetFil(@aFilterExp, cTabMestra)
lShowDlgFilt := .F.
Gpem020Filter(aFilterExp,cTabMestra,@cExpFiltro,lShowDlgFil)

If !Empty(cExpFiltro)
	cTxtFil := Gpem870QbrFil(cExpFiltro)
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize	 := MsAdvSize()
aAdvSize[5]	 :=	(aAdvSize[5]/100) * 75	//horizontal
aAdvSize[6]	 :=  (aAdvSize[6]/100) * 55	//Vertical
aInfoAdvSize := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	 := MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlg TITLE STR0002 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() STYLE DS_MODALFRAME PIXEL//"Gera Dados para Emissao do Certificado de Ingresso e Retenção"
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Descricao da Janela                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
@ aObjSize[1,1]+14,aObjSize[1,2]+2 TO aObjSize[1,3]*0.43,aObjSize[1,4]*0.75 OF oDlg PIXEL
@ aObjSize[1,1]+17,aObjSize[1,2]+5 SAY cSays1  Of oDlg Pixel  FONT oFont1
@ aObjSize[1,1]+27,aObjSize[1,2]+5 SAY cSays2  Of oDlg Pixel  FONT oFont1
@ aObjSize[1,1]+37,aObjSize[1,2]+5 SAY STR0030 Of oDlg Pixel FONT oFont1 // "Filtro de Funcionário:"
oTxtFil := TMultiGet():New(aObjSize[1,1]+47,aObjSize[1,2]+5,&cBlKGet,oDlg,aObjSize[1,4]*0.73,aObjSize[1,3]*0.16,,.F.,,,,.T.,,.F.,&(cBlkWhen),.F.,.F.,.F.,&(cBlkVld),,.F.,.F.,.T.)
//@ 50,25 MsGET oTxtFil VAR cTxtFil When .F. Of oDlg SIZE 200,40 Pixel
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Funcoes em GpFiltro  - Blocos de Execucao dos filtros                    ³
³ GpFiltro - Chama a janela principal do cadastro de filtros               ³
³ GpFltAlsGet - Retorna a expressao para elaborar o filtro                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
bLogProc 		:= { || GPM870Log() }
bNewFiltro 		:= { || aRetFiltro := GpFiltro( aFilterExp ), cExpFiltro := GpFltAlsGet( aRetFiltro , cTabMestra ), Gpem870QbrFil(cExpFiltro), oTxtFil:Refresh() }
bAltFilter 		:= { || Gpem870Filter( aFilterExp, cTabMestra, @cExpFiltro, lShowDlgFil ), Gpem870QbrFil(cExpFiltro),oTxtFil:Refresh() }
bBtnCalcule		:= { || nOpca := 1, IF( GPM870Ok()( ),oDlg:End(), nOpca:=0 ) }
bPergunte 		:= { || Pergunte("GPM870",.T.) }

oBtnLogProc 	:= TButton():New( aObjSize[1,3]*0.45, aObjSize[1,2]+002, "&"+OemToAnsi(STR0014),NIL,bLogProc			, 040 , 012 , NIL , NIL , NIL , .T. )	// "Arq. Log"
oBtnAltFil  	:= TButton():New( aObjSize[1,3]*0.45, aObjSize[1,2]+044, "&"+OemToAnsi(STR0020),NIL,bAltFilter			, 040 , 012 , NIL , NIL , NIL , .T. )	// "Alterar Filtro"
oBtnNewFil  	:= TButton():New( aObjSize[1,3]*0.45, aObjSize[1,2]+086, "&"+OemToAnsi(STR0021),NIL,bNewFiltro			, 040 , 012 , NIL , NIL , NIL , .T. )	// "Incluir Filtro"
oBtnPergunte	:= TButton():New( aObjSize[1,3]*0.45, aObjSize[1,2]+128, "&"+OemToAnsi(STR0022),NIL,bPergunte 			, 040 , 012 , NIL , NIL , NIL , .T. )	// "Parâmetros"
oBtnCalcule		:= TButton():New( aObjSize[1,3]*0.45, aObjSize[1,2]+170, "&"+OemToAnsi(STR0023),NIL,bBtnCalcule 		, 040 , 012 , NIL , NIL , NIL , .T. )	// "Processar"
oBtnEnd			:= TButton():New( aObjSize[1,3]*0.45, aObjSize[1,2]+212, "&"+OemToAnsi(STR0024),NIL,{ || oDlg:End() }	, 040 , 012 , NIL , NIL , NIL , .T. )	// "Sair"

ACTIVATE DIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Mes Referencia                                    ³
//³ mv_par02 - Nao Referencia                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF nOpca == 1
	If Empty(cExpFiltro)
		
		lRet := MsgYesNo(OemToAnsi(STR0029),OemToAnsi(STR0018)) // "Nenhum filtro foi selecionado! Processar toda a tabela?"###"Aten‡„o"
		
		IF lRet
			lTudo := .T.
		ENDIF
	Else
		lRet := .T.
	EndIf
	If lRet
		ProcGpe({|lEnd| GPM870Processa(cExpFiltro,cTabMestra)})  // Chamada do Processamento
	Endif
Endif
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM870ProcessaºAutor  ³Abel Ribeiro    º Data ³  09/01/06    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                             º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPM870Processa(cExpFiltro,cTabMestra)

Local nS	  := 0
Local lOk     := .T.
Local cFilter := ""

Private aLog	  := {}
Private aTitle	  := {}
Private aTotRegs  := array(9)
Private aVerba	  := {}
Private cAliasSRD := "SRD"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis PRIVADAS BASICAS                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCRA 	:= { STR0004,STR0005,STR0006 } //"Confirma"###"Redigita"###"Abandona"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis PRIVADAS DO PROGRAMA                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cInfOut   := ""
Private cCidade   := ""
Private cAno	  := MV_PAR01
Private nTamCpf	  := TamSX3("RA_RG")[1] //RA_CIC
Private aDadosRGO := {}
Private nTotFunc:= 0

Default cExpFiltro := ""

IF lok
	If File(cPathFile)
		FERASE(cPathFile)                      //Deleta o Arquivo
	Endif
	
	aFill(aTotRegs,0)
	
	If !Empty(cExpFiltro)
		If cPaisLoc == "COL" 
			cExpFiltro := fExpSQLIn(cExpFiltro)
		EndIf
		cExpFiltro := StrTran(cExpFiltro,".", ' ')
		cExpFiltro := StrTran(cExpFiltro,'"', "'")
		cExpFiltro := StrTran(cExpFiltro,'==', "=")
		
		cFilter    := StrTran(cExpFiltro, "SRA->",RetSqlName("SRA")+".")
		
		If aTotRegs[2] == 0
			cLog := STR0019 // "Filtro da Tabela SRA: "
			Aadd(aTitle,cLog)
			Aadd(aLog,{})
			aTotRegs[2] := len(aLog)
		EndIf
		Aadd(aLog[aTotRegs[2]], cExpFiltro )
	Else
		If !MsgYesNo( OemToAnsi(STR0007),OemToAnsi(STR0018)) .AND. !lTudo
			RETURN
		ENDIF
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem das Datas para a Query³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DDtPesqI := CTOD("01/01/" +  MV_PAR01)
	DDtPesqF := CTOD("31/12/" +  MV_PAR01)
	
	dbSelectArea( "SRA" )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Buscar Valores no Acumulado "SRD"                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SRD")
		
	lQuery	:= .T.
	
	cSQL := " SELECT  * "
	cSQL += " FROM " +	RetSqlName("SRA") "
	
	If TcSrvType() != "AS/400"
		cSQL += " WHERE "
		If !Empty(cFilter)                          //Adiciona o Filtro do Usuário
			cSQL += cFilter + " AND "
		ENDIF
		cSQL += " D_E_L_E_T_ <> '*' "
	Else
		cSQL += "  @DELETED@  <> '*' "
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define order by...						                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL 		+= " ORDER BY RA_FILIAL,RA_MAT "
	cSQL     	:= ChangeQuery(cSQL)
	
	aStruSRA 	:= SRA->(dbStruct())
	SRA->( dbCloseArea() )             //Fecha o SRA para uso da Query
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"SRA9",.F.,.T.)
	For nS := 1 To Len(aStruSRA)
		If ( aStruSRA[nS][2] <> "C" )
			TcSetField("SRA9",aStruSRA[nS][1],aStruSRA[nS][2],aStruSRA[nS][3],aStruSRA[nS][4])
		EndIf
	Next nS
	cQrySRA:= "SRA9"
	
	DbSelectArea(cQrySRA)
	ProcRegua((cQrySRA)->(RecCount()))
	DbGotop()
	
	GPProcRegua((cQrySRA)->(RecCount()))
	
	lProcessou := .F.
	
	While (cQrySRA)->(!Eof())
		
		lProcessou := .T.
		
		SRA->(dbSetOrder(1))
		SRA->(dbSeek( (cQrySRA)->RA_FILIAL+(cQrySRA)->RA_MAT) )
		
		GPIncProc( (cQrySRA)->RA_FILIAL + " - " + (cQrySRA)->RA_MAT + " - " + (cQrySRA)->RA_NOME)
		
		cFIL := (cQrySRA)->RA_FILIAL
		cMAT := (cQrySRA)->RA_MAT
		cNIF := (cQrySRA)->RA_RG //RA_CIC
		
		If !fInfo(@aInfo,cFil)
			Exit
		Endif
		
		nValor   := 0
		cCidade  := PADR(aInfo[5]  ,30)                              //Local de Onde se praticou a Retencao
		
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'A '",dDTPesqI,dDTPesqF, "V")) ) > 0	//Acumula Salarios
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"A",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'W '",dDTPesqI,dDTPesqF,"V")) ) > 0	//37 - W - Pagos realizados con bonos electrónicos o de papel de servicio, cheques, tarjetas, vales, etc.
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"W",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'B '",dDTPesqI,dDTPesqF, "V")) ) > 0	//46 - B - Cesantías e intereses de cesantías efectivamente pagadas al empleado
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"B",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'B1'",dDTPesqI,dDTPesqF, "V")) ) > 0	//47 - B1 - Cesantías consignadas al fondo de cesantías
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"B1",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'F '",dDTPesqI,dDTPesqF, "V")) ) > 0	//Acumula Valores Aportes de Saude
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"F",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'G '",dDTPesqI,dDTPesqF, "V")) ) > 0	//51 - G - Aportes obligatorios a fondos de pensiones y solidaridad pensional a cargo del trabajador
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"G",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'G1'",dDTPesqI,dDTPesqF, "V")) ) > 0	//52 - G1 - Cotizaciones voluntarias al régimen de ahorro individual con solidaridad – RAIS
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"G1",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'H '",dDTPesqI,dDTPesqF,"V")) ) > 0	//Acumula Valores de Aportes Fundos de Pensao
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"H",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'I '",dDTPesqI,dDTPesqF,"V")) ) > 0	//Acumula Valors de IR
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"I",nValor} )
		EndIf
		//Adiciona Registros que não constam como verbas, mas deverão constarem no arquivo Final, para posterior manutenção do usuário
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'C '",dDTPesqI,dDTPesqF,"V")) ) > 0	//Acumula Valors de Gastos de Representacao
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"C",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'D '",dDTPesqI,dDTPesqF,"V")) ) > 0	//Acumula Valors de Pensao de Jubilacion
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"D",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'E '",dDTPesqI,dDTPesqF,"V")) ) > 0	//Acumula Valors de Otros Ingressos
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"E",nValor} )
		EndIf

		//Conceptos Recibidos
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'J '",dDTPesqI,dDTPesqF,"V")) ) > 0	//56 - J - Arrendamientos (recibidos)
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"J",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'K '",dDTPesqI,dDTPesqF,"V")) ) > 0	//57 - K - Honorarios, comisiones y servicios (recibidos)
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"K",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'L '",dDTPesqI,dDTPesqF,"V")) ) > 0	//58 - L - Intereses y rendimientos financieros (recibidos)
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"L",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'M '",dDTPesqI,dDTPesqF,"V")) ) > 0	//59 - M - Enajenación de activos fijos (recibidos)
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"M",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'N '",dDTPesqI,dDTPesqF,"V")) ) > 0	//60 - N - Loterías, rifas, apuestas y similares (recibidos)
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"N",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'O '",dDTPesqI,dDTPesqF,"V")) ) > 0	//61 - O - Otros (recibidos)
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"O",nValor} )
		EndIf

		//Conceptos Retenidos
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'J1'",dDTPesqI,dDTPesqF,"V")) ) > 0	//56 - J - Arrendamientos (retenidos)
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"J1",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'K1'",dDTPesqI,dDTPesqF,"V")) ) > 0	//57 - K - Honorarios, comisiones y servicios (retenidos)
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"K1",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'L1'",dDTPesqI,dDTPesqF,"V")) ) > 0	//58 - L - Intereses y rendimientos financieros (retenidos)
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"L1",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'M1'",dDTPesqI,dDTPesqF,"V")) ) > 0	//59 - M - Enajenación de activos fijos (retenidos)
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"M1",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'N1'",dDTPesqI,dDTPesqF,"V")) ) > 0	//60 - N - Loterías, rifas, apuestas y similares (retenidos)
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"N1",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'O1'",dDTPesqI,dDTPesqF,"V")) ) > 0	//61 - O - Otros (retenidos)
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"O1",nValor} )
		EndIf
		
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'P '",dDTPesqI,dDTPesqF,"V")) ) > 0	//Acumula Valors de pagos por honorarios
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"P",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'Q '",dDTPesqI,dDTPesqF,"V")) ) > 0	//Acumula Valors de pagos por servicios
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"Q",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'R '",dDTPesqI,dDTPesqF,"V")) ) > 0	//Acumula Valors de pagos por comisiones
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"R",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'S '",dDTPesqI,dDTPesqF,"V")) ) > 0	//Acumula Valors de pagos por prestaciones sociales
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"S",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'T '",dDTPesqI,dDTPesqF,"V")) ) > 0	//Acumula Valors de pagos por viaticos
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"T",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'U '",dDTPesqI,dDTPesqF,"V")) ) > 0	//Acumula Valors de pagos por compensaciones por el trabajo asociado cooperativo
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"U",nValor} )
		EndIf
		If ( nValor := ABS(fBuscaACM(NIL,"RV_DIRF == 'V '",dDTPesqI,dDTPesqF,"V")) ) > 0	//Acumula Valors de aportes voluntarios a fondos de pensiones
			AAdd(aDadosRGO,{cFIL,cMAT,cNIF,cANO,"V",nValor} )
		EndIf
		
		If !empty(SRA->RA_RG) //RA_CIC
			// Grava os Dados
			fGravaRGO(cFil,cANO,cMat,cNIF)
		Else
			If aTotRegs[3] == 0
				cLog := STR0008         // "Funcionário sem CPF cadastrado."
				Aadd(aTitle,cLog)
				Aadd(aLog,{})
				aTotRegs[3] := len(aLog)
			EndIf
			Aadd(aLog[aTotRegs[3]], SRA->RA_FILIAL+"-"+SRA->RA_MAT+ space(02)+SRA->RA_NOME )
		Endif
		
		nTotFunc ++
		
		(cQrySRA)->( dbSkip())
	Enddo
	
	dbSelectArea(cQrySRA)
	dbCloseArea()
	
	If aTotRegs[9] == 0 .and. aTotRegs[4] == 0 .and. aTotRegs[5] == 0
		
		If aTotRegs[4] == 0
			cLog := STR0026                                      //"Total de Funcionários Processados
			Aadd(aTitle,cLog)
			Aadd(aLog,{})
			aTotRegs[4] := len(aLog)
		EndIf
		
		Aadd(aLog[aTotRegs[4]], STR0027+STRZERO(nTOTFUNC,6))    //"Total Func: "
		
		IF nTOTFUNC > 0
			If aTotRegs[9] == 0 .AND. aTotRegs[3] == 0           //Verifica Se não tem Inconsistência
				cLog := STR0009                                   //"Informações Geradas com Sucesso !"
				Aadd(aTitle,cLog)
				Aadd(aLog,{})
				aTotRegs[9] := len(aLog)
				
				Aadd(aLog[aTotRegs[9]], STR0010)                  //"Não foi encontrada nenhuma inconsistência durante a geração.")
				If aTotRegs[5] == 0
					cLog := STR0011                                  //"Informações para gerar o Certificado de Ingressos e Retenções"
					Aadd(aTitle,cLog)
					Aadd(aLog,{})
					aTotRegs[5] := len(aLog)
				EndIf
				
				Aadd(aLog[aTotRegs[5]], STR0012)                   //"Para consultar as informações Geradas, acesse a opção Miscelanea - Cert.Ingr.Retenc - Manutenção"
				
			ELse
				cLog := STR0032                                   //"Foram encontradas Inconsistências na Geração"
				Aadd(aTitle,cLog)
				Aadd(aLog,{})
				aTotRegs[3] := len(aLog)
				
				Aadd(aLog[aTotRegs[3]], STR0008)
			ENDIF
			
		Else
			If aTotRegs[9] == 0
				cLog := STR0028                                 //"Não   foi encontrado movimento. Verifique os parâmetro/Filtro."
				Aadd(aTitle,cLog)
				Aadd(aLog,{})
				aTotRegs[9] := len(aLog)
			EndIf
			
			Aadd(aLog[aTotRegs[9]], STR0031)                   //"Não Foi  Gerado Nenhum Registro")
		ENDIF
	EndIf
	
	fMakeLog(aLog,aTitle,,,"GPEM870",STR0013,"M","P",,.F.)     //"Log de ocorrências "
ENDIF
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM870Ok  ºAutor  ³Microsiga           º Data ³  01/19/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPM870Ok()
Return (MsgYesNo(OemToAnsi(STR0007),OemToAnsi(STR0018))) //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fGravaRGO     ºAutor  ³ABEL RIBEIRO    º Data ³  14/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava dados no Arquivo de Dados RGO,                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGravaRGO(cFil,cANO,cMat,cNIF)
Local I
Local nTan := TamSx3("RGO_NIF")[1] //Len(RGO->RGO_NIF)

cNIF := SubStr((cNIF+Space(nTan)),1,nTan)

FOR I = 1 TO LEN(aDadosRgo)
	cChave:= cFil+cANO+cMat+cNIF+aDADOSRGO[I,5]
	dbSelectArea("RGO")
	dbSetOrder(1)
	If dbSeek( cChave )
		RecLock("RGO",.F.)
	Else
		RecLock("RGO",.T.)
		RGO->RGO_FILIAL  := cFil                                                      //Filial
		RGO->RGO_MAT     := cMat                                                      //Matricula do Empregado
		RGO->RGO_NIF     := cNIF                                                      //Identificação do Empregado
		RGO->RGO_ANO     := cANO                                                      //Ano de Exercicio
		RGO->RGO_TIPREN  := aDADOSRGO[I,5]                                            //Tipo de Rendimento
	Endif
	RGO->RGO_LOCREN := cCIDADE                                                       //Local de onde se praticou a retenção
	IF aDADOSRGO[I,5] == "I"
		RGO->RGO_VLRRET := IIF(aDADOSRGO[I,6] < 0,ABS(aDADOSRGO[I,6]),aDADOSRGO[I,6]) //Valor Retido de Imposto
	Else
		RGO->RGO_VLRREN := IIF(aDADOSRGO[I,6] < 0,ABS(aDADOSRGO[I,6]),aDADOSRGO[I,6])    //valor do Rendimento
	ENDIF
	RGO->RGO_USER := cUsuario
NEXT
MsUnLock()

aDadosRGO := {}

Return


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpem870Filter³Autor³ Abel Ribeiro           ³Data³22/08/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Botao de alteracao do filtro                 				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function Gpem870Filter(	aFilterExp 	,;		// opcoes do filtro  // MUDEI AQUI
						cTabMestra	,;		// alias do filtro
						cExpFiltro	,;		// string com o filtro - passado por referencia
						lShowDlg	 ;		// Se visualiza janela de filtros
						)
Local aRetFiltro 	:= {}
Local aHeader 		:= {}

Local cTxtFil 		:= ""

DEFAULT lShowDlg	:= .T.

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Elabora o cabecalho do arquivo Mestre                 	       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
aHeader := GdMontaHeader(NIL,NIL,NIL,cTabMestra,NIL,.T.,.T.,.F.,.F.,.F.,.F.,.F.)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Retorna os filtros selecionados                       	       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
aRetFiltro := GpFiltro( aFilterExp, .F. )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Se for na inicializacao da dialog, nao mostrar a janela       ³
³Caso possua mais de 1 filtro selecionado-retornar filtro Vazio³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
If (;
	( Len(aRetFiltro) > 1 );
	.And.;
	( lShowDlg );
	)
	aRetFiltro := GpFiltro( aFilterExp )
ElseIf (;
	( Len(aRetFiltro) > 1 );
	.And.;
	!( lShowDlg );
	)
	aRetFiltro := NIL
EndIf

If !Empty(aRetFiltro)
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Retorna a expressao dos filtros                      	       ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	cExpFiltro := GpFltAlsGet( aRetFiltro , cTabMestra )
	
	If lShowDlg
		cTxtFil    := GpFltBldDesc( cExpFiltro, @aHeader, cTabMestra )
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Janela para alteracao dos valores do filtro          	       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		AltValExp( cTabMestra , @cExpFiltro , @cTxtFil , NIL , aHeader )
	EndIf
EndIf
Return( NIL )


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpem870Arq³Autor³ ABEL RIBEIRO              ³Data³22/08/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³                                             				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Function Gpem870Arq(	cTabMestra		,;	// nome do arquivo mestre  // MUDEI AQUI
						oBtnNewFil		,;	// botao de novo filtro
						oBtnAltFil		,;  // botao de alteracao do filtro
						oBtnCalcule		 ;	// botao OK
						)
Local lBtn		:= .T.

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Ativar / Desativar os botoes conforme arquivo selecionado     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
IF lBtn
	lBtn	:= !Empty( cTabMestra )
EndIF
oBtnNewFil:lActive 	:= lBtn
oBtnAltFil:lActive 	:= lBtn
oBtnCalcule:lActive	:= lBtn
Return( NIL )


/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpem870SetFil³Autor³ ABEL RIBEIRO           ³Data³22/08/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Setar as opcoes do Filtro									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Function Gpem870SetFil( aFilterExp , cTabMestra )

Local aGrpUsr		:= {}	// Grupo dos Usuarios
Local cGrpUsr		:= ""	// string com o Grupo de usuario
Local nLoop			:= 0

aAdd( aFilterExp , { "FILTRO_ALS" , cTabMestra 	, NIL , NIL    } )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Localizar os grupos a que o usuario pertence                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
aGrpUsr := UsrRetGrp( SubStr( cUsuario , 7 , 15 ) )
For nLoop := 1 To Len(aGrpUsr)
	cGrpUsr := aGrpUsr[nLoop]
	aAdd( aFilterExp , { "FILTRO_GRP" , cGrpUsr 	, NIL , NIL    } )
Next nLoop
Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM870Log     ºAutor  ³ABEL RIBEIRO      º Data ³  07/08/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualizacao do Relatoiro de Log de Processamento.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPM870Log()
cPathFile := ""
cExtRel := ".##R"
cPathFile := ( __RelDir + "GPEM870" + cExtRel )
If File(cPathFile)
	OurSpool( "GPEM870" )
	Ms_Flush()
Else
	MsgStop(STR0025) // "Não existe Log de Correção para exibir"
Endif
Return

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpem770QbrFil³Autor³ Abel Ribeiro           ³Data³22/08/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna o texto do filtro qubrado em linhas            		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Function Gpem870QbrFil(cExpFiltro)
nLinha := 1
nStrFil := 1
cTxtFil := ""
While nStrFil <= Len(cExpFiltro)
	If nLinha > 5
		Exit
	Endif
	cTxtFil += Substr(cExpFiltro,nStrFil,80)+Chr(13)
	nStrFil+=80
	nLinha++
EndDo
While nLinha <= 5
	cTxtFil += Chr(13)
	nLinha++
EndDo
Return(cTxtFil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fExpSQLIn     ºAutor  ³Alf Medrano     º Data ³  03/10/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Convierte expresión advpl (Campo $ "A/B/C") en expresion SQL º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gpem870QbrFil,GPM870Processa                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fExpSQLIn(cExpFil)
Local nPosFin := 0 
Local nPosP := 0
Local nPosS := 0
Local nX := 0 
Local nY := 0 
Local nList := 0
Local nBan := 0
Local nPosPar := 0
Local lNotIn := .F.
Local lSigno:= .F.
Local cCad := ""
Local cCadFil := ""
Local cCadIn := ""
Local cCadLin := ""
Local cCadLSal := ""
Local cCadFin := ""
Local aList := {}
Default cExpFil := ""

For nX := 1 to len(cExpFil)
	cCadIn := Substr(cExpFil,nX, 1)
	If cCadIn == "!"
		nBan := nX
	EndIf 
	If nBan > 0 .and. nX == nBan + 1 .and. cCadIn == "("
		lNotIn := .T.
		lSigno := .T.
	EndIf
	If cCadIn == "$"
		cCad := Substr(cExpFil,nX, len(cExpFil)  ) // Extrae desde la posición del carácter encontrado ($) hasta el final de la cadena
		nPosFin := AT(")",cCad) //primera coincidencia
		nPosFin := nPosFin - 1 
		cCadFil := Substr(cExpFil,nX, nPosFin) // Extrae hasta donde se cierra la expresion IN --> ejemplo $ "A/B/C/D")  
		nPosPar := AT("(",cCadFil)
		nPosP := AT('"',cCadFil)//primera coincidencia 
		nPosS := RAT('"',cCadFil)//ultima coincidencia 
		cCadLin := Substr(cCadFil,nPosP + 1 ,nPosS - nPosP - 1) //obtiene la cadena con las opciones ---> ejemplo "A/B/C/D"
		aList := StrToArray(cCadLin,"/") //Convierte en array las opciones
		nList := len(aList)
		//arma la expresión IN con el contenido del array
		For nY := 1 to nList 
			If nY == 1
				If lNotIn
					cCadLSal := " NOT IN ("
					lNotIn := .F.
				Else
					cCadLSal := " IN ("
				EndIf
			EndIf
			cCadLSal+= "'" + aList[nY] + "'"
			If nY < nList
				cCadLSal += "," 
			Else
				If nPosPar == 0
					cCadLSal += "))"
				Else
					cCadLSal += ")"
				EndIf	
			EndIf	
		Next
		nPosFin :=  nPosFin + nX // posicion donde se cierra la expresion IN
		cCadIn := cCadLSal
		nX := nPosFin
	EndIf
	//se elimina el signo '!' solo si despues le sige un '('  
	If lSigno
		cCadFin := substr(cCadFin,1,Len(cCadFin) - 1)
		lSigno :=  .F.
	EndIf
	cCadFin += cCadIn 
Next

Return cCadFin

#INCLUDE "PROTHEUS.CH"
#INCLUDE "OMSM010.CH"

#DEFINE CRMARCA  1
#DEFINE CRCORBRW 2
#DEFINE CRALIAS  3
#DEFINE CRNOME   4
#DEFINE CRROTINA 5
#DEFINE CRMODEL  6
#DEFINE CRFILTRO 7
#DEFINE CRFILIAL 8

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OMSM010   ³ Autor ³Leandro Paulino        ³ Data ³15.04.2011|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Carga Inicial dos registros que ja constam na base³±±
±±³          ³e serão integrados com o SIGAGFE.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OMSM010()
Local cFiltUsr
Local lEnd   	 := .F.
Local aSize     := {}
Local aObjects  := {}
Local aListBox  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local oOk       := LoadBitMap(GetResources(),"LBOK")
Local oNo       := LoadBitMap(GetResources(),"LBNO")
Local oSay
Local oWS
Local oBtn01
Local oBtn02
Local bLineBkp

Private oVerde    := LoadBitmap( GetResources()	,	'BR_VERDE'		)
Private oAmarelo	:=	LoadBitmap( GetResources()	,	'BR_AMARELO'	)
Private oListBox	:= Nil
Private oDlg		:= Nil
Private oQtdDoc	:= Nil
Private oQtdMrk	:= Nil
Private nQtdDoc	:= 0
Private nQtdMrk	:= 0
Private lExecAuto	:= .F.

//-- Checkbox
Private lAllMark:= .F.   // Usado para o controle da marca de todos os documentos
//-- Rotinas Marcadas
Private aRotMark:= {}


CursorWait()

//-- Array com as rotinas a serem integradas GFE x TMS
Aadd(aListBox,{'2', oVerde, 'SA1', STR0001 , 'MATA030', 'MATA030_SA1',  NIL,  'A1_FILIAL'  }) //Cadastro de Clientes
Aadd(aListBox,{'2', oVerde, 'SA2', STR0002 , 'MATA020', 'MATA020_SA2',  NIL,  'A2_FILIAL'  }) //Cadastro de Fornecedores
Aadd(aListBox,{'2', oVerde, 'DA3', STR0003 , 'OMSA060', 'OMSA060_DA3',  NIL,  'DA3_FILIAL' }) //Cadastro de Veículos
Aadd(aListBox,{'2', oVerde, 'DA4', STR0004 , 'OMSA040', 'OMSA040_DA4',  NIL,  'DA4_FILIAL' }) //Cadastro de Morotistas
Aadd(aListBox,{'2', oVerde, 'SA4', STR0005 , 'MATA050', 'MATA050_SA4',  NIL,  'A4_FILIAL'  }) //Cadastro de Transportadoras
Aadd(aListBox,{'2', oVerde, 'CC2', STR0006 , 'FISA010', 'FISA010_CC2',  NIL,  'CC2_FILIAL' }) //Tabela de Municipios do IBGE
Aadd(aListBox,{'2', oVerde, 'DUT', STR0007 , 'TMSA530', 'TMSA530_DUT',  NIL,  'DUT_FILIAL' }) //Cadastro de Tipos de Veículos
Aadd(aListBox,{'2', oVerde, 'SB1', STR0027 , 'MATA010', 'MATA010_SB1',  NIL,  'B1_FILIAL'  }) //Cadastro de Produtos
Aadd(aListBox,{'2', oVerde, 'SAH', STR0028 , 'QIEA030', 'QIEA030_SAH',  NIL,  'AH_FILIAL'  }) //Unidades de Medida
Aadd(aListBox,{'2', oVerde, 'CTT', STR0025 , 'CTBA030', 'CTBA030_CTT',  NIL,  'CTT_FILIAL' }) //Centro de Custo
Aadd(aListBox,{'2', oVerde, 'CT1', STR0026 , 'CTBA020', 'CTBA020_CT1',  NIL,  'CT1_FILIAL' }) //Plano de Contas
Aadd(aListBox,{'2', oVerde, 'SA3', STR0029 , 'MATA040', 'MATA040_SA3',  NIL,  'A3_FILIAL'  }) //Cadastro de Vendedores
Aadd(aListBox,{'2', oVerde, 'SE4', STR0030 , 'MATA360', 'MATA360_SE4',  NIL,  'E4_FILIAL'  }) //Cadastro de Condições de Pagamento
Aadd(aListBox,{'2', oVerde, 'DA0', STR0031 , 'OMSA010', 'OMSA010_DA0',  NIL,  'DA0_FILIAL' }) //Cadastro de Tabela de Preços
Aadd(aListBox,{'2', oVerde, 'SA5', STR0032 , 'MATA060', 'MATA060_SA5',  NIL,  'A5_FILIAL'  }) //Relação Produtos X Fornecedores
Aadd(aListBox,{'2', oVerde, 'SF2', STR0033 , 'MATA461', 'MATA461_SF2',  NIL,  'F2_FILIAL'  }) //Nota Fiscal de Saída
Aadd(aListBox,{'2', oVerde, 'DAO', STR0034 , 'TMSAO05', 'MdFieldDAO' ,  NIL,  ''           }) //Cadastro de Macros
// Em analise para implantação
//Aadd(aListBox,{CRMARCA:='2', CRCORBRW := oVerde,	CRALIAS:='DAK',CRNOME:= "Tabela de Cargas" ,CRROTINA:='OMSA200',CRMODEL:='OMSA200_DAK', CRFILTRO:=NIL, CRFILIAL:='DAK_FILIAL'  })	//Tabela de Cargas

CursorArrow()

aSize    := MsAdvSize(.F. )
aObjects := {}

AAdd( aObjects, { 100, 020, .T., .F., .T.  } )
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 020, .F., .F. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3, .T.  }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE STR0008 From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL

		oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)

		@ 005,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0009 SIZE 168, 08; //-- Marca/Desmarca Todos
		ON CLICK(OsM010All(aListBox)) OF oPanel PIXEL

		//-- Cabecalho dos campos do Monitor.
		@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER;
		  "","",STR0010,STR0011, STR0012 SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL

		oListBox:SetArray( aListBox )
		oListBox:bLDblClick := { || OsM010Mrk(aListBox) }
		oListBox:bLine      := { || {	Iif(aListBox[ oListBox:nAT,CRMARCA ] == '1',oOk,oNo),;
												aListBox[ oListBox:nAT,CRCORBRW],;
												aListBox[ oListBox:nAT,CRALIAS ],;
												aListBox[ oListBox:nAT,CRROTINA],;
												aListBox[ oListBox:nAT,CRNOME  ]}}

		//-- Botoes da tela do monitor.
		@ aPosObj[3,1],aPosObj[3,4] - 100 BUTTON oBtn01 	PROMPT STR0013 ACTION OsM010Leg()			OF oDlg PIXEL SIZE 035,011	//-- "Legenda"
		@ aPosObj[3,1],aPosObj[3,4] - 060 BUTTON oBtn02 	PROMPT STR0014	ACTION Iif(MsgYesNo(STR0015,STR0008),;   //--"Confirma o Processamento",Carga Inicial
				Processa( { |lEnd| OsM010Proc(aListBox,@lEnd) }, , STR0018, .T. ),'') 						OF oDlg PIXEL SIZE 035,011	//-- "Transmitindo para o EAI"
		@ aPosObj[3,1],aPosObj[3,4] - 020 BUTTON oBtn03 	PROMPT STR0019	ACTION OsM010Fil(@aListBox)OF oDlg PIXEL SIZE 035,011	//-- "Filtro"
		@ aPosObj[3,1],aPosObj[3,4] + 020 BUTTON oBtn04 	PROMPT STR0020	ACTION oDlg:End()  			OF oDlg PIXEL SIZE 035,011	//-- "Sair"

ACTIVATE MSDIALOG oDlg CENTERED

Return ( Nil )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OsM010Leg ³ Autor ³Leandro Paulino			³Data ³05.05.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina da Legenda do Filtro da Rotina                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³																  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function OsM010Leg()

BrwLegenda( STR0023		, STR0019,;				//--	"Status do Doc." # "Status"
			{{'BR_AMARELO' , STR0021 },;  		//-- Não Transmitido
			{'BR_VERDE'    , STR0022 }})  		//-- Documento Aguardando

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OsM010Mrk³  Autor ³ Leandro Paulino      ³ Data ³05.05.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca as rotinas no listbox                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OsM010Mrk()    		                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OMSM010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OsM010Mrk(aListBox,nItem,lRefresh,lUmItem,lRetMark)

Local   nPosMrk := 0
Local	  nDocMrk := 0

Default nItem   := oListBox:nAt
Default lRefresh:= .T.
Default lUmItem := .T.
Default lRetMark:= .F.

If lUmItem
	aListBox[nItem,CRMARCA] := Iif(aListBox[nItem,CRMARCA] == '1','2','1')
	If(aListBox[nItem,CRMARCA]) == '1'
		nQtdMrk += 1
	ElseIf(aListBox[nItem,CRMARCA]) == '2'
		nQtdMrk -= 1
	EndIf
Else
	If lAllMark
		aListBox[nItem,CRMARCA] := '1'
		nQtdMrk += 1
	Else
		aListBox[nItem,CRMARCA] := '2'
		nQtdMrk := 0
	EndIf
EndIf
nPosMrk := Ascan(aRotMark,{ | e | e[1]+e[2] == aListBox[nItem,CRALIAS]+aListBox[nItem,CRROTINA] })
If nPosMrk == 0
	Aadd(aRotMark,{ aListBox[nItem,CRROTINA], aListBox[nItem,CRALIAS], '' })
	nPosMrk := Len(aRotMark)
EndIf
aRotMark[nPosMrk,3] := aListBox[nItem,CRMARCA]
If lRefresh
	oListBox:Refresh()
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OsM010All³  Autor ³ Leandro Paulino     ³ Data ³05.05.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca todas as rotinas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OsM010All()    		                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OMSM010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OsM010All(aListBox)

Local nI      := 0
Local lRefresh:= .T.
Local lUmItem := .F.

CursorWait()
nQtdMrk := 0

For nI := 1 To Len(aListBox)
	OsM010Mrk(aListBox,nI,lRefresh,lUmItem)
Next nI

CursorArrow()

oListBox:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OsM010Proc  ³ Autor ³Leandro Paulino       ³ Data ³15.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel por enviar as tabelas para MaEnvEAI      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Param[1] - Array contendo as rotinas da tela				     ³±±
±±³			 ³															  					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OsM010Proc(aListBox,lEnd)

Local   nI			:= 0
Local   aCargaIni	:= {}
Local   aGetArea	:= GetArea()
Local   lModel		:= .F.
Local   cFilAtu	:= cFilAnt
Local   cTitMsg	:= ('OsM010Proc - MaEnvEAI')
Local   cProcMsg	:= ""
Local   nProcess	:= 0

Private INCLUI    	:= .T.
Private ALTERA    	:= .F.
Private oModelCarga	:= Nil

Default aListBox  := {}

aCargaIni := OsM010Rot(aListBox)

For nI := 1 To Len(aCargaIni)
	dbSelectArea(aCargaIni[nI,CRALIAS])
  	dbGoTop()

	//Se for uma rotina MVC, carrega model para correto funcionamento
	//da IntegDef que utilize essa estrutura para gerar a mensagem
	If ( FWHasModel( aCargaIni[nI,CRROTINA] ) )
		oModelCarga 	:= FWLoadModel( aCargaIni[nI,CRROTINA] )
		lModel 		:= .T.
	EndIf

	cIndAlias := CriaTrab( Nil, .F. )

	IndRegua((aCargaIni[nI,CRALIAS]), cIndAlias, IndexKey(), , aCargaIni[nI,CRFILTRO],STR0024) //--"Selecionando Registros..."

	nIndAlias := RetIndex(aCargaIni[nI,CRALIAS])

	DbSetOrder( nIndAlias + 1 )
	ProcRegua( (aCargaIni[nI,CRALIAS])->( RecCount() ) )
	While (!(aCargaIni[nI,CRALIAS])->(Eof()))
		nProcess++
		IncProc()

		If !Empty( (aCargaIni[nI,CRALIAS])->&(aCargaIni[nI,CRFILIAL]) )
			cFilAnt := (aCargaIni[nI,CRALIAS])->&(aCargaIni[nI,CRFILIAL])
		EndIf

		If ( lModel )
			oModelCarga:Activate()
		EndIf

		If FWHasEAI( aCargaIni[nI,CRROTINA] /*cFunction*/, /*lVerifySend*/, /*lVerifyRec*/, .T. /*lVerifyUMess*/ )
			SetRotInteg(aCargaIni[nI,CRROTINA])
			RegToMemory(aCargaIni[nI,CRALIAS],.F.)
			FWIntegDef(aCargaIni[nI,CRROTINA],,,,aCargaIni[nI,CRROTINA])
		Else
			MaEnvEAI(,,4,aCargaIni[nI,CRROTINA],{{aCargaIni[nI,CRALIAS],aCargaIni[nI,CRMODEL], NIL, NIL, NIL, NIL }})
		EndIf

		If ( lModel )
			oModelCarga:DeActivate()
		EndIf

		(aCargaIni[nI,CRALIAS])->(dbSkip())
	EndDo

	cProcMsg += ( aCargaIni[nI,CRALIAS] ) + ": " +StrZero( nProcess, 8 ) + " " + STR0049 + If( Mod(nI,2)==0 , Chr(13)+Chr(10) , '  -  ' )	//Registros Processados.
	nProcess := 0

	If	File( cIndAlias + OrdBagExt() )
		DbSelectArea((aCargaIni[nI,CRALIAS]))
		DbClearFilter()
		Ferase( cIndAlias + OrdBagExt() )
	EndIf

	RetIndex((aCargaIni[nI,CRALIAS]))
Next nI

MsgInfo(cProcMsg, cTitMsg)

cFilAnt := cFilAtu
RestArea(aGetArea)

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OsM010Rot ³ Autor ³ Leandro Paulino       ³ Data ³05.05.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preparar rotinas para processamento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorna as rotinas selecionadas.                           ³±±
±±³          ³ Array dos documentos                                       ³±±
±±³          ³ [1] - Marca/Desmarca                                       ³±±
±±³          ³ [2] - Cor Legenda    		                                ³±±
±±³          ³ [3] - Alias				                                      ³±±
±±³          ³ [4] - Nome do Alias 			                                ³±±
±±³          ³ [5] - Rotina        			                                ³±±
±±³          ³ [6] - Model        			                                ³±±
±±³          ³ [7] - Filtro       			                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function OsM010Rot(aListBox)

Local   nI         := 0
Local   aRotProc 	 := {}

For nI := 1 To Len(aListBox)
	If aListBox[nI,CRMARCA] == '1'
		Aadd( aRotProc, aListBox[nI] )
	EndIf
Next nI

Return ( aRotProc )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OsM010Fil ³ Autor ³ Leandro Paulino       ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preparar rotinas para processamento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Array dos documentos                                       ³±±
±±³          ³ [1] - Marca/Desmarca                                       ³±±
±±³          ³ [2] - Cor Legenda    		                                ³±±
±±³          ³ [3] - Alias				                                      ³±±
±±³          ³ [4] - Nome do Alias 			                                ³±±
±±³          ³ [5] - Rotina        			                                ³±±
±±³          ³ [6] - Model        			                                ³±±
±±³          ³ [7] - Filtro       			                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Static Function OsM010Fil(aListBox)

Default aListBox := {}

aListBox[oListBox:nAT,CRFILTRO] := BuildExpr( aListBox[ oListBox:nAT,CRALIAS ], ,aListBox[oListBox:nAT,CRFILTRO])

If !Empty(aListBox[oListBox:nAT,CRFILTRO] )
	aListBox[ oListBox:nAT,CRCORBRW] := oAmarelo
	oListBox:Refresh()
Else
	aListBox[ oListBox:nAT,CRCORBRW] := oVerde
	oListBox:Refresh()
EndIf

Return ( Nil )

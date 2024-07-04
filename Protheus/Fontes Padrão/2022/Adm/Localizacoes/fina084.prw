#INCLUDE "fina084.ch"
#include 'protheus.ch'
#include 'tcbrowse.ch'

#DEFINE _RECSE2 		1
#DEFINE _BAIXAS 		2
#DEFINE _SALDO  		3
#DEFINE _INVOICES 	4

#DEFINE _MARCADO		"LBTIK"
#DEFINE _DESMARCADO 	"LBNO"
#DEFINE _PRETO   		"BR_PRETO"
#DEFINE _AMARELO    	"BR_AMARELO"
#DEFINE _AZUL       	"BR_AZUL"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA084   ºAutor  ³Bruno Sobieski      ºFecha ³  10-14-04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para geracao de diferencias de cambio no contas a    º±±
±±º          ³pagar.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±    
±±ºUso       ³ AP                                                         º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glez ³06/06/16³TVFHOB³Se agrega filtro en la funcion Fa084GDif³±±
±±³              ³        ³      ³para no procesar los documentos con TRM ³±±
±±³              ³        ³      ³pactada. Cambios para Colombia          ³±±
±±³              ³        ³      ³Se elimina funcion ajustaSX1.           ³±±
±±³Luis Enríquez ³30/12/16³SERINN001³Se realizó merge para hacer cambios  ³±±
±±³              ³        ³-201     ³para creacion de tablas temp. CTREE  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Roberto Glez  ³02/06/17³MMI-5670³Ajuste en Diferencia cambiaría para   ³±±
±±³              ³        ³MMI-5333³tomar los valores de la moneda,       ³±±
±±³              ³        ³        ³independientemente de si se tomaron   ³±±
±±³              ³        ³        ³por día o se modificaron y se ajusta  ³±±
±±³              ³        ³        ³cuando se realiza varias veces        ³±±
±±³              ³        ³        ³mientras aún tenga saldo el doc       ³±± 
±±³Luis Enriquez ³07/06/17³TSSERMI01³-Merge 12.1.16 En método AddIndex de ³±±
±±³              ³        ³-96      ³clase FWTemporaryTable se modifica a ³±±
±±³              ³        ³         ³2 caracteres nombre de indice.(CTREE)³±±
±±³Raul Ortiz M  ³12/03/18³DMICNS   ³Se modifica la función FA084Dele para³±±
±±³              ³        ³-1276    ³considerar el recno desde otra rutina³±±
±±³              ³        ³         ³Argentina                            ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fina084()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis 														  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cFiltro	:=	""
	Local bFiltro
	Local nA := 0     
	Local lFR_MOEDA := .F.
	Local nOpcion := 0 // Utilizada en scripts automáticos (4 Generación por lote)
	Local lAutomato := IsBlind() // Tratamiento para scripts automáticos
	Private aIndices		:=	{} //Array necessario para a funcao FilBrowse
	Private bFiltraBrw 	:= {|| .T. }
	Private aRecSE2		:={}
	Private cMoedaTx,nC	:=	MoedFin()  
	Private lCmpMda:= cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|RUS|URU"
	Private oTmpTable := Nil
	Private aOrdem := {}
	//Declaracao de variaveis Multimoeda
	Private aTxMoedas	:=	{}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restringe o uso do programa ao Financeiro e Sigaloja			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!(AmIIn(6,12,17,72)) .and. !lAutomato)		// S¢ Fin e Loja e EIC e Photo
		Return
	Endif
	If cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|RUS|URU"
		lFR_MOEDA := .T.
	Else
		lFR_MOEDA := .F.
	Endif

	Private aRotina := MenuDef(lFR_MOEDA)
	Pergunte("FIN84A",.F.)
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica o numero do Lote 											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE cLote
	LoteCont( "FIN" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabe‡alho da tela de baixas								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE cCadastro := OemToAnsi(STR0007) //"Diferencia de cambio cuentas a pagar"
	Pergunte("FIN84A",.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para pre-validar os dados a serem  ³
	//³ exibidos.                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ExistBlock("F084BROW")
		cFiltro	:=	ExecBlock("F084BROW",.F.,.F.,cFiltro)
	Endif                           

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ So devem ser exibidos os titulos em moeda diferente ³
	//³ da corrente.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|URU"
		If !Empty(cFiltro)
			cFiltro	:=	"E2_FILIAL='"+xFilial('SE2')+"' "+Iif(Empty(cFiltro),"",".And.("+ cFiltro + ")")
			bFiltro	:=	{|| FilBrowse("SE2",@aIndices,cFiltro )}
			If mv_par10==1 
				bFiltraBrw	:= bFiltro
				Eval( bFiltraBrw )
			Endif
		Endif
	Else
		cFiltro	:=	"E2_FILIAL='"+xFilial('SE2')+"' .And. (E2_MOEDA > 1 .Or. E2_CONVERT=='N')"+Iif(Empty(cFiltro),"",".And.("+ cFiltro + ")")
	EndIf
	SetKey (VK_F12,{|a,b| AcessaPerg("FIN84A",.T.)})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endere‡a a Fun‡„o de BROWSE											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !lAutomato
		oBrowse	:=	mBrowse( 6, 1,22,75,"SE2",,,,,, Fa084Legenda("SE2"))
    Else
       If FindFunction("GetParAuto")
			aRetAuto 		:= GetParAuto("FINA084TESTCASE")
			nOpcion 		:= aRetAuto[1]			
	   EndIF
	   Do Case
			Case nOpcion == 4
				Fa084GDifM()
	   EndCase
    Endif
	dbSelectArea("SE2")
	If !Empty(cFiltro)
		If mv_par10 == 1
			EndFilBrw("SE2",@aIndices)
		Endif
	Endif
	dbSetOrder(1)

	Set key VK_F12  To

	//leem
	If oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil 
	EndIf 
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa084Vis  ºAutor  ³Bruno Sobieski      ºFecha ³  10-14-04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualiza o detalhe de uma diferencia de cambio             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
Function Fa084Vis()                                        
	Local nRecSE2		:=	SE2->(Recno())
	Local aCampos	:=	{}            
	Local nTotAjuste	:=	0
	If SE2->E2_CONVERT <> "N"	
		Help('',1,'FA084008')
		Return
	Endif                              
	Fa084GerTRB(@aCampos,@nTotAjuste)

	DbSelectArea('TRB')
	DbGoTop()
	SE2->(MsGoTo(nRecSE2))
	Fa084Tela(2,nTotAjuste,aCampos,.F.)
	SE2->(MsGoTo(nRecSE2))
	DbSelectArea('TRB')
	DbCloseArea()
	If bFiltraBrw <> Nil
		Eval(bFiltraBrw)
	Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa084GDif ºAutor  ³Bruno Sobieski      ºFecha ³  10-14-04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera a diferencia de cambio para um titulo.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
Function Fa084GDif(lMultiplo,aCorrecoes,lMarcados,lExterno,nMoedaCor,nTxaAtual,nMoedaTit)    
	Local nTaxaAtu	:=	0
	//Local nX	:=nY	:=	0
	Local nTotAjuste	:=	0
	Local aStruTRB	:=	{}
	Local aCampos 	:=	{}                                                       
	Local nOpca		:=	2
	Local cArquivo		:=	""
	Local nShowCampos	:=	0
	Local nIniLoop	:=	0

	Local nX:=1
	Local nY:= 1
	DEFAULT aCorrecoes	:=	{}
	DEFAULT lMarcados 	:=	.F.
	DEFAULT lExterno := .F.

	//Verifica si tienen TRM Pactada
	If cPaisLoc == "COL" 
		If SE2->E2_TRMPAC == "1"
			MSGINFO( STR0052 ,STR0053 )// "No se puede ejecutar esta opcion, porque el documento tiene TRM pactada" ##INFO
			Return
		EndIf
	Endif

	If (!(FunName()$"FINA847|FINA850") .And. cPaisLoc $ "ANG|COL|EQU|HAI|MEX|PER|PTG" ) .OR. (!(FunName()$"FINA085A") .And. cPaisLoc == "URU")
		mv_par11:= 1
	EndIf

	//Verifica se a moeda selecionada para a geracao do titulo existe.
	If Empty(GetMv("MV_MOEDA"+ALLTRIM(STR(MV_PAR11))))
		Help("",1,"NMOEDADIF")
		Return
	Endif

	// Verifica se pode ser incluido mov. com essa data
	If !(dtMovFin(dDataBASE,,"1") )
		Return  .F.
	EndIf

	If !lMultiplo
		aRecSE2	:=	{}
		If SE2->E2_CONVERT == "N"	
			Help('',1,'FA084005')
			Return
		Endif                                            

		If cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|URU"
			If SE2->E2_MOEDA  == mv_par11 .And. !lExterno
				Help('',1,'FA084011')
				Return
			EndIf
		ElseIf cPaisLoc == "RUS" .And. lExterno .And. SE2->E2_MOEDA  <= 1
			Return
		ElseIf SE2->E2_MOEDA  <= 1    
			Help('',1,'FA084011')
			Return
		Endif


		IF SE2->E2_EMIS1 > dDataBase
			Help('',1,'FA084009')
			Return
		Endif

		If Fa084TemDC()
			Help('',1,'FA084012')
			Return
		EndIf

		If  cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|URU"
			nTaxaAtu	:= If(mv_par01==0,RecMoeda(dDataBase,mv_par11),mv_par01)
		Elseif cPaisLoc == "RUS"
			nTaxaAtu	:= If(mv_par01==0,RecMoeda(dDataBase,SE2->E2_MOEDA),mv_par01)
		Else
			nTaxaAtu	:= If(mv_par01==0,RecMoeda(dDataBase,SE2->E2_MOEDA),mv_par01)	
		EndIf	
		AADD(aCorrecoes,Fa084CDif(@nTaxaAtu,lExterno))
		Aadd(aRecSE2,SE2->(Recno()))	
	Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar se ja foi ajustado ate esta data³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|URU" .And. SE2->E2_DTDIFCA >= dDataBase 
		Help('',1,'FA084001')
		Return
	Endif
	//Monta estrutura do trb
	If lMultiplo
		aadd(aStruTrb,{"TRB_MARCA"		,"C",12,0})
	Endif
	aadd(aStruTrb,{"TRB_ORIGEM"	,"C",12,0})
	aadd(aStruTrb,{"E2_FORNECE"	,"C",TamSx3("E2_FORNECE")[1],TamSx3("E2_FORNECE")[2]})
	aadd(aStruTrb,{"E2_LOJA"  		,"C",TamSx3("E2_LOJA"   )[1],TamSx3("E2_LOJA"   )[2]})
	aadd(aStruTrb,{"E2_PREFIXO"	,"C",TamSx3("E2_PREFIXO")[1],TamSx3("E2_PREFIXO")[2]})
	aadd(aStruTrb,{"E2_NUM"			,"C",TamSx3("E2_NUM"    )[1],TamSx3("E2_NUM"    )[2]})
	aadd(aStruTrb,{"E2_PARCELA"	,"C",TamSx3("E2_PARCELA")[1],TamSx3("E2_PARCELA")[2]})
	aadd(aStruTrb,{"E2_TIPO"		,"C",TamSx3("E2_TIPO"   )[1],TamSx3("E2_TIPO"   )[2]})
	aadd(aStruTrb,{"E2_ORDPAGO"	,"C",TamSx3("E2_ORDPAGO")[1],TamSx3("E2_ORDPAGO")[2]})
	aadd(aStruTrb,{"E2_EMISSAO"	,"D",TamSx3("E2_EMISSAO")[1],TamSx3("E2_EMISSAO")[2]})
	//aadd(aStruTrb,{"E2_VALOR"		,"N",TamSx3("E2_VALOR"  )[1],TamSx3("E2_VALOR"  )[2]})
	aadd(aStruTrb,{"TRB_VALDIF"	,"N",TamSx3("E2_VLCRUZ" )[1],TamSx3("E2_VLCRUZ" )[2]})

	nShowCampos	:=	Len(aStruTRB)

	aadd(aStruTrb,{"TRB_VALOR1" 	,"N",TamSx3("E2_VALOR"  )[1],TamSx3("E2_VALOR"  )[2]})
	aadd(aStruTrb,{"TRB_VALCOR"	,"N",TamSx3("E2_VLCRUZ" )[1],TamSx3("E2_VLCRUZ" )[2]})
	aadd(aStruTrb,{"TRB_TIPODI"	,"C",1                      ,0                      })
	aadd(aStruTrb,{"TRB_TXATU"	   ,"N",TamSx3("FR_TXATU" )[1],TamSx3("FR_TXATU" )[2]})
	aadd(aStruTrb,{"TRB_TXORI"	   ,"N",TamSx3("FR_TXATU" )[1],TamSx3("FR_TXATU" )[2]})
	aadd(aStruTrb,{"TRB_DTAJUS"	,"D",TamSx3("E2_EMISSAO")[1],TamSx3("E2_EMISSAO")[2]})
	aadd(aStruTrb,{"E5_SEQ"		,"C",TamSx3("E5_SEQ" )[1],TamSx3("E5_SEQ" )[2]})

	SX3->(DbSetOrder(2))
	If lMultiplo
		AAdd(aCampos,{' ','TRB_MARCA' ,aStruTRB[1][2],aStruTRB[1][3],aStruTRB[1][4],"@BMP"})
		AAdd(aCampos,{' ','TRB_ORIGEM',aStruTRB[2][2],aStruTRB[2][3],aStruTRB[2][4],"@BMP"})
	Else
		AAdd(aCampos,{' ','TRB_ORIGEM',aStruTRB[1][2],aStruTRB[1][3],aStruTRB[1][4],"@BMP"})
	Endif
	nIniLoop	:=	Len(aCampos)+1
	For nX := nIniLoop To nShowCampos
		If !(aStruTRB[nX][1]$"TRB_VALDIF")
			SX3->(DbSeek(aStruTRB[nX][1]))
			AAdd(aCampos,{X3TITULO(aStruTRB[nX][1]),aStruTRB[nX][1],aStruTRB[nX][2],aStruTRB[nX][3],aStruTRB[nX][4],PesqPict("SE2",aStruTRB[nX][1])})
		Else
			AAdd(aCampos,{STR0008,aStruTRB[nX][1],aStruTRB[nX][2],aStruTRB[nX][3],aStruTRB[nX][4],PesqPict("SE2","E2_VLCRUZ")}) //"Diferencia"
		Endif
	Next

	//Creacion de Objeto 
	oTmpTable := FWTemporaryTable():New("TRB") //leem
	oTmpTable:SetFields( aStruTrb ) //leem

	aOrdem	:=	{"E2_FORNECE","E2_LOJA","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO"} //leem

	oTmpTable:AddIndex("I1", aOrdem) //leem

	oTmpTable:Create() //leem
	
	For nY:= 1 To Len(aCorrecoes)
		For nX:=1 To Len(aCorrecoes[nY][_BAIXAS])
			SE5->(MsGoTo(aCorrecoes[nY][_BAIXAS][nX][1]))
										  
			Reclock('TRB',.T.)
			Replace E2_FORNECE With SE5->E5_CLIFOR
			Replace E2_LOJA 	 With SE5->E5_LOJA
			Replace E2_PREFIXO With SE5->E5_PREFIXO
			Replace E2_NUM     With SE5->E5_NUMERO 
			Replace E2_PARCELA With SE5->E5_PARCELA
			Replace E2_TIPO    With SE5->E5_TIPO
			Replace E2_EMISSAO With SE5->E5_DATA
			Replace E2_ordpago With SE5->E5_ORDREC
			Replace TRB_ORIGEM With _AMARELO
			Replace TRB_VALDIF With aCorrecoes[nY][_BAIXAS][nX][2]
			//		Replace E2_VALOR   With aCorrecoes[nY][_BAIXAS][nX][3]
			Replace TRB_VALOR1 With aCorrecoes[nY][_BAIXAS][nX][3]*aCorrecoes[nY][_BAIXAS][nX][5]
			Replace TRB_VALCOR With aCorrecoes[nY][_BAIXAS][nX][3]*aCorrecoes[nY][_BAIXAS][nX][4]
			Replace TRB_TXATU  With aCorrecoes[nY][_BAIXAS][nX][4]
			Replace TRB_TXORI  With aCorrecoes[nY][_BAIXAS][nX][5]
			Replace TRB_DTAJUS With dDataBase
			Replace TRB_TIPODI With "B"
			Replace E5_SEQ 	 WITH SE5->E5_SEQ
			If lMultiplo
				TRB_MARCA	:=	IIf(lMarcados,_MARCADO,_DESMARCADO)
			Endif
			MsUnLOck()                                            
			If !lMultiplo .Or. (lMultiplo .And. lMarcados)
				If TRB->E2_TIPO$ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM
					nTotAjuste	-=	TRB_VALDIF 
				Else		    
					nTotAjuste	+=	TRB_VALDIF 
				EndIf
			EndIf
		 
		Next                       

		If aCorrecoes[nY][_SALDO][1] <> 0
			SE2->(MsGoTo(aCorrecoes[nY][_RECSE2]))
			Reclock('TRB',.T.)
			Replace E2_FORNECE With SE2->E2_FORNECE
			Replace E2_LOJA 	 With SE2->E2_LOJA
			Replace E2_PREFIXO With SE2->E2_PREFIXO
			Replace E2_NUM     With SE2->E2_NUM    
			Replace E2_PARCELA With SE2->E2_PARCELA
			Replace E2_TIPO    With SE2->E2_TIPO
			Replace E2_EMISSAO With SE2->E2_EMIS1 
			Replace TRB_ORIGEM With _AZUL
			Replace TRB_VALDIF With aCorrecoes[nY][_SALDO][1]
			//		Replace E2_VALOR   With aCorrecoes[nY][_SALDO][2]
			Replace TRB_VALOR1 With aCorrecoes[nY][_SALDO][2]*aCorrecoes[nY][_SALDO][4]
			Replace TRB_VALCOR With aCorrecoes[nY][_SALDO][2]*aCorrecoes[nY][_SALDO][3]
			Replace TRB_TXATU  With aCorrecoes[nY][_SALDO][3]
			Replace TRB_TXORI  With aCorrecoes[nY][_SALDO][4]
			Replace TRB_DTAJUS With dDataBase
			Replace TRB_TIPODI With "S"
			If lMultiplo
				TRB_MARCA	:=	IIf(lMarcados,_MARCADO,_DESMARCADO)
			Endif
			MsUnLock()
			If !lMultiplo .Or. (lMultiplo .And. lMarcados)
				If TRB->E2_TIPO$ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM                       
					nTotAjuste	-=	TRB_VALDIF 
				Else
					nTotAjuste	+=	TRB_VALDIF 
				EndIf
			EndIf
		Endif
		If aCorrecoes[nY][_INVOICES][1] <> 0
			SE2->(MsGoTo(aCorrecoes[nY][_RECSE2]))
			Reclock('TRB',.T.)
			Replace E2_FORNECE With SE2->E2_FORNECE
			Replace E2_LOJA 	 With SE2->E2_LOJA
			Replace E2_PREFIXO With SE2->E2_PREFIXO
			Replace E2_NUM     With SE2->E2_NUM    
			Replace E2_PARCELA With SE2->E2_PARCELA
			Replace E2_TIPO    With SE2->E2_TIPO
			Replace E2_EMISSAO With SE2->E2_EMIS1 
			Replace TRB_ORIGEM With _PRETO
			Replace TRB_VALDIF With aCorrecoes[nY][_INVOICES][1]
			//		Replace E2_VALOR   With aCorrecoes[nY][_INVOICES][2]
			Replace TRB_VALOR1 With aCorrecoes[nY][_INVOICES][2]*aCorrecoes[nY][_INVOICES][4]
			Replace TRB_VALCOR With aCorrecoes[nY][_INVOICES][3]
			Replace TRB_TXATU  With aCorrecoes[nY][_INVOICES][4]
			Replace TRB_TXORI  With aCorrecoes[nY][_INVOICES][5]
			Replace TRB_DTAJUS With aCorrecoes[nY][_INVOICES][6]
			Replace TRB_TIPODI With "I"
			If lMultiplo
				TRB_MARCA	:=	IIf(lMarcados,_MARCADO,_DESMARCADO)
			Endif
			MsUnLock()
			If !lMultiplo .Or. (lMultiplo .And. lMarcados)
				If TRB->E2_TIPO$ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM                       
					nTotAjuste	-=	TRB_VALDIF 
				Else
					nTotAjuste	+=	TRB_VALDIF 
				EndIf
			EndIf
		Endif
	Next
	DbGoTop()
	If !lExterno
		nOpca	:=	Fa084Tela(3,nTotAjuste,aCampos,lMultiplo)
	Else
		nOpca := 1  
	EndIf
	If nOpca == 1  
		Begin Transaction
			Processa({|| F084Grava(aRecSE2,lMultiplo,lExterno)},STR0009) //"Grabando documentos"
		End Transaction
	Endif

	DbSelectArea('TRB')
	DbCloseArea()
	If !lExterno .And. bFiltraBrw <> Nil
		Eval(bFiltraBrw)
	Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa084GDifMºAutor  ³Bruno Sobieski      ºFecha ³  10-14-04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera a diferencia de cambio para varios titulos             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     

Function Fa084GDifM()
	Local nTaxaAtu	:=	0

	Local aCorrecoes	:=	{}
	Local aMV_PAR		:= Array(9)
	aRecSE2	:=	{}
	// Verifica se pode ser incluido mov. com essa data
	If !(dtMovFin(dDataBASE,,"1") )
		Return  .F.
	EndIf

	If Pergunte("FIN84B",.T.)
		aMV_PAR[01]	:=	MV_PAR01	
		aMV_PAR[02]	:=	MV_PAR02	
		aMV_PAR[03]	:=	MV_PAR03	
		aMV_PAR[04]	:=	MV_PAR04	
		aMV_PAR[05]	:=	MV_PAR05	
		aMV_PAR[06]	:=	MV_PAR06	
		aMV_PAR[07]	:=	MV_PAR07	
		aMV_PAR[08]	:=	MV_PAR08	
		aMV_PAR[09]	:=	MV_PAR09	
	Else
		Pergunte("FIN84A",.F.)
		Return
	Endif
	Pergunte("FIN84A",.F.) 

	//Verifica se a moeda selecionada para a geracao do titulo existe.
	If Empty(GetMv("MV_MOEDA"+ALLTRIM(STR(MV_PAR11))))
		Help("",1,"NMOEDADIF")
		Return
	Endif

	Processa({|| F084DifMulti(@aRecSE2,@aCorrecoes,aMV_PAR)},STR0026) //'Calculando diferencias de cambio'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aRecSE2) > 0
		Fa084GDif(.T.,aCorrecoes,aMV_PAR[09]==1)    
	Else
		Help(" ",1,"RECNO")
	EndIf

	DbSelectArea('SE2')
	If bFiltraBrw <> Nil
		Eval(bFiltraBrw)
	Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa084DifMuºAutor  ³Bruno Sobieski      ºFecha ³  10-14-04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula as correcoes para varios titulos.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
Static Function F084DifMulti(aRecSE2,aCorrecoes,aMV_PAR)
	Local nTaxaAtu	:=	0
	Local nCounter	:=	0
	Local cAliasSE2:=	"SE2"

	#IFDEF TOP
	Local lFa084Qry	:=	ExistBlock("FA084QRY")
	Local cQuery		:=	''
	Local aStru			:=	{}                                                
	LOCAL	cQueryADD	:=	''
	Local ni := 1
	#ENDIF
	ProcRegua(500)	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria‡Æo da estrutura de TRB com base em SE2.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE2")
	dbSetOrder(6)

	#IFDEF TOP
	If TcSrvType() != "AS/400"
		aStru := dbStruct()
		cQuery := "SELECT SE2.*,"
		cQuery += "R_E_C_N_O_ RECNO "
		cQuery += "  FROM "+	RetSqlName("SE2") + " SE2 "
		cQuery += " WHERE E2_FILIAL ='" +xFilial('SE2')+ "'"
		cQuery += "   AND E2_FORNECE Between '" + aMv_par[01] + "' AND '" + aMv_par[02] + "'"
		cQuery += "   AND E2_LOJA    Between '" + aMv_par[03] + "' AND '" + aMv_par[04] + "'"
		cQuery += "   AND E2_PREFIXO Between '" + aMv_par[05] + "' AND '" + aMv_par[06] + "'"
		cQuery += "   AND E2_NUM between '"     + aMv_par[07] + "' AND '" + aMv_par[08] + "'"
		If cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|URU"
			cQuery += "   AND E2_MOEDA <> " + Alltrim(Str(mv_par11)) + " "
			cQuery += "   AND E2_CONVERT <> 'N'"
									  
		Else
			cQuery += "   AND E2_MOEDA >1 "	
			cQuery += "   AND E2_DTDIFCA <'"+Dtos(dDataBase)+"'"
		EndIf	
		cQuery += "   AND E2_EMIS1 <= '"+Dtos(dDataBase)+"'"
		cQuery += "   AND D_E_L_E_T_ <> '*' "

		// Permite a inclusão de uma condicao adicional para a Query
		// Esta condicao obrigatoriamente devera ser tratada em um AND ()
		// para nao alterar as regras basicas da mesma.
		IF lFa084Qry
			cQueryADD := ExecBlock("FA084QRY",.F.,.F.)
			IF ValType(cQueryADD) == "C".And.Len(cQueryADD) >0
				cQuery += " AND (" + cQueryADD + ")"
			ENDIF
		ENDIF

		cQuery += " ORDER BY "+ SqlOrder(SE2->(IndexKey()))

		cQuery := ChangeQuery(cQuery)


		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE2QRY', .F., .T.)

		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C' .AND. aStru[ni,2] != "M"
				TCSetField('SE2QRY', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next
		dbSelectArea('SE2QRY')
		cAliasSE2	:=	'SE2QRY'
	Else
		#Endif
		DbSeek(xFilial('SE2')+aMV_PAR[01]+aMV_PAR[03]+aMV_PAR[05]+aMV_PAR[07],.T.)
		#IFDEF TOP
	Endif
	#ENDIF

	While !(cAliasSE2)->(Eof()) .And. (cAliasSE2)->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)<=;
	xFilial('SE2')+aMv_par[02]+aMv_par[04]+aMv_par[06]+aMv_par[08]
		#IFDEF TOP
		If  TcSrvType() == "AS/400"
			#ENDIF
			If cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|URU"
				If E2_EMIS1 > dDataBase.Or. E2_DTDIFCA >= dDataBase
					DbSkip()
					Loop
				Endif     
				If E2_MOEDA < 2   
					DbSkip()
					Loop
				EndIf	
			Else
				If E2_MOEDA <> mv_par11                
					(cAliasSE2)->(DbSkip())
					Loop
				EndIf
			Endif

			#IFDEF TOP
		EndIf
		#ENDIF

		If Fa084TemDC(cAliasSE2)
			(cAliasSE2)->(DbSkip())
			Loop
		EndIf

		#IFDEF TOP
		If TcSrvType() != "AS/400"
			SE2->(MsGoTo(SE2QRY->RECNO))
		Endif
		#ENDIF
		nTaxaAtu	:= If(mv_par01==0,RecMoeda(dDataBase,(cAliasSE2)->E2_MOEDA),mv_par01)
		IncProc(STR0027+" "+(cAliasSE2)->E2_PREFIXO+"/"+(cAliasSE2)->E2_NUM) // "Calculando dif. de cambio del titulo"
		nCounter++
		If nCounter == 500
			nCounter	:=	0
			ProcRegua(500)	
		Endif
		Aadd(aRecSE2,SE2->(Recno()))	
		AADD(aCorrecoes,Fa084CDif(@nTaxaAtu))
		DbSelectArea('SE2')       
		DbSetOrder(6)
		MsGoto(aRecSE2[Len(aRecSE2)])
		DbSelectArea(cAliasSE2)
		DbSkip()
	Enddo	

	#IFDEF TOP
	If TcSrvType() != "AS/400"
		DbSelectArea(cAliasSE2)
		DbCloseArea()
		DbSelectArea('SE2')
	Endif
	#ENDIF

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa084Canc ºAutor  ³Bruno Sobieski      ºFecha ³  10-14-04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Apaga uma nota de diferencia de cambio.                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
Function Fa084Canc()
	Local nTotAjuste	:=	0
	Local aCampos 		:=	{}     
	Local nX				:=	0     
	Local nRecSE2		:=	SE2->(Recno())
	Local nIndex		:=	SE2->(IndexOrd())
	Local dData
	If SE2->E2_CONVERT <> "N"	
		Help('',1,'FA084008')
		Return
	Endif                              
	// Verifica se pode ser incluido mov. com essa data
	If !(dtMovFin(dDataBASE,,"1") )
		Return  .F.
	EndIf

	IF SE2->E2_EMIS1 > dDataBase
		Help('',1,'FA084009')
		Return
	Endif

	DbSelectArea('SFR')
	DbSetOrder(2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar se tem algum ajuste             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !DbSeek(xFilial()+"2"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
		Help('',1,'FA084006')
		Return
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificar se algum dos titulos ajustados, tem ³
		//³algum ajuste posterior.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		dData		:=	SE2->E2_EMIS1
		cChave	:=	PADR(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA , len(SFR->FR_CHAVDE))
		DbSelectArea('SFR')
		DbSetOrder(1)                                 
		While !EOF() .And. FR_CARTEI=="2" .AND. FR_CHAVDE ==	cChave
			If SFR->FR_DATADI > SE2->E2_EMIS1
				Help('',1,'FA084007')
				Return
			Endif
			DbSkip()
		Enddo
	Endif	                                

	Fa084GerTRB(@aCampos,@nTotAjuste)

	DbSelectArea('TRB')
	DbGoTop()
	SE2->(MsGoTo(nRecSE2))
	nOpca	:=	Fa084Tela(5,nTotAjuste,aCampos,.F.)
	SE2->(MsGoTo(nRecSE2))
	If nOpca == 1  
		Begin Transaction
			Processa({|| FA084Dele(nRecSE2)},STR0010) //"Borrando documentos"
		End Transaction
	Endif

	DbSelectArea('TRB')
	DbCloseArea()
	Pergunte("FIN84A",.F.)
	SetKey (VK_F12,{|a,b| AcessaPerg("FIN84A",.T.)})
	DbSelectArea('SE2')
	DbSetOrder(nIndex)
	/*
	If bFiltraBrw <> Nil
	Eval(bFiltraBrw)
	Endif
	*/
Return	



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa084CDif ºAutor  ³Bruno Sobieski      ºFecha ³  10-14-04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula a diferencia de cambio para um titulo.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fa084CDif(nTaxaAtu,lExterno)
	Local nValor	:=	0
	Local nSaldoInv:=0
	Local nTotComp	:=	0                                                                                
	Local dUltDif	:=	Ctod('')                                                                                
	Local nX			:=	0   
	Local aBaixas	:=	{}
	Local nTxOrig	:=	0
	Local aInvoices:={}
	Local	aSaldoInv:={0,0,0,0,0,Nil}
	Local	aSaldo   :={0,0,0,0}
	Local nI := 1
	Local nTxBaixa:= 0
	Local lAchouSFR := .F.
	Local lAchouDT := .F.  
	Local nTxAt :=0                
	Local lRet:=.T.

	Default lExterno := .F.
	Private aBaixaSE5	:=	{}  
	Private lCmpMda:= SFR->(FieldPos("FR_MOEDA")) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega a taxa da ultima correcao, e os titulos do SIGAEIC para os que mudou ³
	//³o VLCRUZ, para recorregir estes valores e a data do ultimo ajuste.        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If (SFR->(FieldPos('FR_MOEDA')) == 0)
		aInvoices	:=	F084GetTx(@nTxOrig,@dUltDif)

		If mv_par08==1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcular as correcoes das Baixas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Sel080Baixa( "VL /BA /CP /",SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA,SE2->E2_TIPO,@nTotComp,Nil,SE2->E2_FORNECE,SE2->E2_LOJA)
			For nX:= 1 To Len(aBaixaSE5)
				dBaixa		:= aBaixaSE5[nX,07]
				cSequencia 	:= aBaixaSE5[nX,09]
				cChave      := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+Dtos(dBaixa)+SE2->E2_FORNECE+SE2->E2_LOJA+cSequencia
				If ( MV_PAR06 == 3 ) .AND. ( aBaixaSE5[nX][7] == SE2->E2_EMISSAO )
					Loop // de acordo com Juan (consultor), caso parametro mv_par06 = documento, não deve-se gerar DC para baixas com mesma data da emissao do titulo			
				Endif
				If dBaixa >= dUltDif .And. dBaixa <= dDataBase
					dbSelectArea("SE5")
					dbSetOrder(2)
					cTipoDoc := "BA/VL/CP"
					For nI := 1 to len( cTipoDoc) Step 3
						If dbSeek(xFilial("SE5")+substr(cTipoDoc,nI,2)+cChave) 
							SFR->(DbSetOrder(3))
							IF !SFR->(MsSeek(xFilial('SFR')+"2"+"B"+cSequencia+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO))
								If SE5->E5_TXMOEDA	<> 0
									nTxBaixa	:=	SE5->E5_TXMOEDA
								ElseIf !Empty(SE5->E5_ORDREC)
									SEK->(DbSetOrder(1))
									SEK->(DbSeek(xFilial("SEK")+SE5->E5_ORDREC+"TB"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE5->E5_SEQ))
									If ( SEK->(FieldPos("EK_TXMOE"+StrZero(SE2->E2_MOEDA,2))) > 0 )
										nTxBaixa	:=	SEK->&("EK_TXMOE"+StrZero(SE2->E2_MOEDA,2))  
									EndIf
								Else
									nTxBaixa	:=	(SE5->E5_VALOR/SE5->E5_VLMOED2)    
								EndIf   

								If nTxBaixa	== 0
									nTxBaixa	:= RecMoeda(dDataBase,SE2->E2_MOEDA)
								EndIf
								nValor	:=	SE5->E5_VALOR * (nTxBaixa-nTxOrig)
		
								If nValor <> 0 .And. cPaisLoc $ "ARG|URU"
									AAdd(aBaixas,{SE5->(Recno()),nValor,SE5->E5_VALOR,nTxBaixa, nTxOrig})
								ElseIf cPaisLoc <> "ARG" 
									AAdd(aBaixas,{SE5->(Recno()),nValor,SE5->E5_VALOR,nTxBaixa, nTxOrig})
								EndIF
							Endif
						Endif	
					Next
				Endif
			Next
		Endif
		If mv_par07 ==1	                                                                  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcular a correcao do saldo    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
			nSaldo := SaldoTit( SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_NATUREZ, "P", SE2->E2_FORNECE, SE2->E2_MOEDA, dDataBase, ;
			dDataBase, SE2->E2_LOJA ) 
			aSaldo	:=	{nSaldo *(nTaxaAtu-nTxOrig),nSaldo,nTaxaAtu, nTxOrig}
		Endif

	Else


		aInvoices	:=	F084GetTx(@nTxOrig,@dUltDif,@lAchouSFR,@lAchouDT,@nTxAt)

		If mv_par08==1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcular as correcoes das Baixas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Sel080Baixa( "VL /BA /CP /",SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA,SE2->E2_TIPO,@nTotComp,Nil,SE2->E2_FORNECE,SE2->E2_LOJA)
			For nX:= 1 To Len(aBaixaSE5)
				dBaixa		:= aBaixaSE5[nX,07]
				cSequencia 	:= aBaixaSE5[nX,09]
				cChave      := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+Dtos(dBaixa)+SE2->E2_FORNECE+SE2->E2_LOJA+cSequencia
				If ( MV_PAR06 == 3 ) .AND. ( aBaixaSE5[nX][7] == SE2->E2_EMISSAO )
					Loop // de acordo com Juan (consultor), caso parametro mv_par06 = documento, não deve-se gerar DC para baixas com mesma data da emissao do titulo			
				Endif
				If dBaixa <= dDataBase
					dbSelectArea("SE5")
					dbSetOrder(2)
					cTipoDoc := "BA/VL/CP"      
					For nI := 1 to len( cTipoDoc) Step 3

						If dbSeek(xFilial("SE5")+substr(cTipoDoc,nI,2)+cChave) 
							SFR->(DbSetOrder(3))
							lAtuaBx:=.T.
							IF !SFR->(MsSeek(xFilial('SFR')+"2"+"B"+cSequencia+PADR(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+ SE2->E2_FORNECE+SE2->E2_LOJA,len(SFR->FR_CHAVDE))))
								lAtuaBx:=.T.
							Else
								While !EOF() .And. SFR->FR_FILIAL == xFilial("SFR") .And. SFR->FR_SEQUEN == cSequencia .And. SFR->FR_CHAVOR==PADR(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA, len(SFR->FR_CHAVOR)) .And. lAtuaBx
									If  SFR->FR_MOEDA == MV_PAR11
										lAtuaBx:=.F.
									Endif
									SFR->(DbSkip())
								EndDo	
							Endif
							If lAtuaBx
								If !Empty(SE5->E5_ORDREC)
									SEK->(DbSetOrder(1))
									SEK->(DbSeek(xFilial("SEK")+SE5->E5_ORDREC+"TB"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE5->E5_SEQ))
									If ( SEK->(FieldPos("EK_TXMOE"+StrZero(SE2->E2_MOEDA,2))) > 0 )
										nTxBaixa	:=	SEK->&("EK_TXMOE"+StrZero(SE2->E2_MOEDA,2))
									EndIf
								Else
									nTxBaixa	:=(SE5->E5_VALOR/SE5->E5_VLMOED2)
								EndIf                                                                                 

								If nTxBaixa	== 0
									nTxBaixa	:= RecMoeda(dDataBase,SE2->E2_MOEDA)
								EndIf

								If lExterno .and. !IsInCallStack("Fa085Grava")
									nTxBaixa:= nMoedaTit
								EndIf	

								If mv_par01 <>0 
									nTxBaixa:=mv_par01
								EndIf

								//Verifica se a taxa contratada foi preenchida
								If !lAchouSFR
									nTxAt := Iif(SE2->E2_TXMOEDA > 0,SE2->E2_TXMOEDA,nTxAt)
								EndIf	
								
								If cPaisLoc == "RUS" .And. lExterno
									nVlOrig     := xMoeda(SE5->E5_VALOR,SE2->E2_MOEDA,MV_PAR11,dUltDif,,nTxOrig,nTxBaixa )
									nValorAtual := xMoeda(SE5->E5_VALOR,SE2->E2_MOEDA,MV_PAR11,SE5->E5_DATA,,nTxBaixa)
								Else	
									nVlOrig     := xMoeda(SE5->E5_VALOR,SE2->E2_MOEDA,MV_PAR11,dUltDif,,nTxAt,nTxOrig)
									nValorAtual := xMoeda(SE5->E5_VALOR,SE2->E2_MOEDA,MV_PAR11,SE5->E5_DATA,,nTxBaixa)
								Endif
								
								If lExterno 
									nValorAtual	:=	xMoeda(SE5->E5_VALOR,SE2->E2_MOEDA,MV_PAR11,SE5->E5_DATA,,nTxBaixa)
								EndIf	

								nValor:= nValorAtual - nVlOrig
								If cPaisLoc == "RUS"
									AAdd(aBaixas,{SE5->(Recno()),nValor,SE5->E5_VALOR,nTxBaixa,nTxOrig })
								Else
									If nValor <> 0 .And. cPaisLoc $ "ARG|URU"
										AAdd(aBaixas,{SE5->(Recno()),nValor,SE5->E5_VALOR,nTxBaixa,RecMoeda(dDataBase,MV_PAR11)})
									ElseIf cPaisLoc <> "ARG"
										AAdd(aBaixas,{SE5->(Recno()),nValor,SE5->E5_VALOR,nTxBaixa,RecMoeda(dDataBase,MV_PAR11)})
									EndIF															   
			  
								Endif
							EndIf

						Endif	
					Next
				Endif
			Next
		Endif
		If mv_par07 ==1	                                                                  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcular a correcao do saldo    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      

			nSaldo := SaldoTit( SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_NATUREZ, "P", SE2->E2_FORNECE, SE2->E2_MOEDA, dDataBase, ;
			dDataBase, SE2->E2_LOJA ) 
			nTxMdOrig:= Iif(lAchouSFR,nTxOrig,RecMoeda(dUltDif, SE2->E2_MOEDA))  //taxa da moeda do titulo original
			If lAchouSFR
				If cPaisLoc=="RUS"
					nTxMda:=nTxMdOrig
				Else
					nTxMda:=nTxAt
				Endif
			Else
				If Empty(dUltDif)
					nTxMda:=Iif(SE2->E2_TXMOEDA > 0, SE2->E2_TXMOEDA , RecMoeda(SE2->E2_EMISSAO, SE2->E2_MOEDA))
				Else
					nTxMda:=Iif(SE2->E2_TXMOEDA > 0, SE2->E2_TXMOEDA , RecMoeda(dUltDif, SE2->E2_MOEDA))
				Endif
			EndIf

			If cPaisLoc == "RUS"
			
				If !lAchouDT  // Se achou variacao para este mesmo dia, entao desconsidera
					nSldOrig	:= Round(xMoeda(nSaldo,SE2->E2_MOEDA,MV_PAR11,dUltDif,5,nTxMdOrig),2)
					nSaldoAt	:= Round(xMoeda(nSaldo,SE2->E2_MOEDA,MV_PAR11,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2],aTxMoedas[MV_PAR11][2])  - nSldOrig,2)
				Else
					nSaldoAt:=0
				EndIf
				aSaldo	:=	{nSaldoAt,nSaldo,aTxMoedas[SE2->E2_MOEDA][2],nTxMda}
			
			Else
				
				If !lAchouDT  
					nSldOrig	:= Round(xMoeda(nSaldo,SE2->E2_MOEDA,MV_PAR11,dUltDif,5,nTxMda,nTxOrig),2)
		  			If mv_par01 == 0	  	  		
						nSaldoAt := Round(xMoeda(nSaldo,SE2->E2_MOEDA,MV_PAR11,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2],aTxMoedas[MV_PAR11][2])  - nSldOrig,2)
					Else
						nSaldoAt := Round(xMoeda(nSaldo,SE2->E2_MOEDA,MV_PAR11,,5,mv_par01,aTxMoedas[MV_PAR11][2])  - nSldOrig,2)
					Endif 
				Else
					nSaldoAt:=0
				EndIf
				
				aSaldo	:=	{nSaldoAt,nSaldo,iif(cPaisLoc!='URU',aTxMoedas[SE2->E2_MOEDA][2],iif(mv_par01!=0,mv_par01,aTxMoedas[SE2->E2_MOEDA][2])) ,aTxMoedas[MV_PAR11][2]} 
			Endif
		Endif
	EndIf	

	If mv_par09==1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcular a recorrecao para invoices, dado que pode ter mudado o VLCRUZ.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
		nValor	:=	0
		For nX:=1 To Len(aInvoices)
			SFR->(DbGoTo(aInvoices[nX]))
			nValor	+=	SFR->FR_VALOR 
			dDataDif	:=	SFR->FR_DATADI  
			nTaxaDif	:=	SFR->FR_TXATU 
		Next	                      
		If Len(aInvoices) > 0
			nTxOrig		:=	SE2->E2_VLCRUZ/SE2->E2_VALOR
			nSaldoInv 	:= SaldoTit( SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_NATUREZ, "P", SE2->E2_FORNECE, SE2->E2_MOEDA, dDataDif, ;
			dDataDif, SE2->E2_LOJA ) 
			aSaldoInv	:=	{(nSaldoInv*(nTaxaDif-nTxOrig))-nValor,nSaldoInv,nValor,nTaxaDif,nTxOrig,dDataDif}
		Endif
	Endif
Return {SE2->(RECNO()),aBaixas,aSaldo,aSaldoInv}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa084GetTxºAutor  ³Bruno Sobieski      ºFecha ³  10-14-04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pega a taxa que sera considerada como a taxa original (e a  º±±
±±º          ³taxa da ultima correcao, ou a do titulo)                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍ'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F084GetTx(nTaxa,dUltDif,lAchouSFR,lAchouDT,nTaxaAt)
	Local	aInvoices	:=	{}
	Local cSequencia	:=	Space(TamSx3('FR_SEQUEN')[1])
	Local cTipoMov		:=	"S"

	If (SFR->(FieldPos('FR_MOEDA')) <> 0)
		dUltDif:=SE2->E2_EMIS1
		nTaxa	:= RecMoeda(SE2->E2_EMIS1,mv_par11)
	Else
		nTaxa	:=	SE2->E2_VLCRUZ/SE2->E2_VALOR
	EndIf	
	DbSelectArea('SFR')
	IF Alltrim(SE2->E2_ORIGEM)	==	"SIGAEIC"
		DbSetOrder(1) 
		DbSeek(xFilial()+"2"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
		While !EOF() .And. FR_FILIAL==xFilial() .And.FR_CARTEI=="2".And.;
		FR_CHAVOR==PADR(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA,len(FR_CHAVOR))
			If SE2->E2_VLCRUZ <> FR_VALOR
				AAdd(aInvoices,SFR->(Recno()))
			Endif
			If FR_TIPODI=='S' 
				If (SFR->(FieldPos('FR_MOEDA')) <> 0)
					nTaxa	:=	Iif(SFR->FR_MOEDA==0 .Or. SFR->FR_MOEDA == mv_par11,SFR->FR_TXATU,RecMoeda(SFR->FR_DATADI,mv_par11) )
				Else
					nTaxa:=SFR->FR_TXATU
				EndIf	
				dUltDif	:=	SFR->FR_DATADI
				lAchouSFR:=.T.
			Endif
			DbSkip()
		Enddo    
	Else
		DbSetOrder(3) 
		DbSeek(xFilial()+"2"+cTipoMov+cSequencia+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
		While !EOF() .And. FR_FILIAL==xFilial() .And.FR_CARTEI=="2".And.	FR_CHAVOR==PADR(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA,len(FR_CHAVOR))
			If FR_FILIAL==xFilial() .And.FR_CARTEI=="2".And.	FR_CHAVOR==PADR(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA,len(FR_CHAVOR))
				If FR_TIPODI=='S'	
					If (SFR->(FieldPos('FR_MOEDA')) <> 0)
						If cPaisLoc == "RUS"
							nTaxa	:=	Iif(SFR->FR_MOEDA==0 .Or. SFR->FR_MOEDA == mv_par11,SFR->FR_TXATU,RecMoeda(SFR->FR_DATADI,mv_par11) ) //CLOVIS
						Else
							nTaxa :=	Iif( SFR->FR_MOEDA == mv_par11,IIf(SFR->FR_MOEDA==0,RecMoeda(SFR->FR_DATADI,mv_par11), SFR->FR_TXORI),nTaxa )
						Endif
						lAchouSFR:=.T.
					Else
						nTaxa:=SFR->FR_TXATU
					EndIf	


					If (SFR->(FieldPos('FR_MOEDA')) <> 0) .And. SFR->FR_MOEDA== mv_par11
						dUltDif	:=	SFR->FR_DATADI
						lAchouDT:=Iif(SFR->FR_DATADI ==dDataBase,.T.,.F.)
						If cPaisLoc == "RUS"
							nTaxa:= SFR->FR_TXATU
							nTaxaAt:= SFR->FR_TXORI
						Else
							nTaxa:= SFR->FR_TXORI
							nTaxaAt:=SFR->FR_TXATU						
						Endif						
					EndIf	 
				EndIf 
			Endif
			SFR->(DbSkip())
		EndDo 
		/*	If lAchouDt
		nTaxa:=RecMoeda(SE2->E2_EMIS1,mv_par10)
		EndIf	*/
	Endif	                

Return aInvoices

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa084GravaºAutor  ³Bruno Sobieski      ºFecha ³  10-14-04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera os titulos de diferencia de cambio.                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F084Grava(aRecSE2,lMultiplo,lExterno)
	Local aTitulo	:=	{}
	Local	nOpc		:= 3    // Inclusao
	Local aNum		:=	{}                                     
	Local lRet		:=	.T.
	Local cPrefixo	:=	mv_par02
	Local cTipDeb 	:=	mv_par03
	Local cTipCred	:=	mv_par04
	Local cNatureza:=	mv_par05
	Local nSepara  :=	mv_par06
	Local lGravaData:=Iif(mv_par07==1,.T.,.F.)
	Local aGerar	:=	{}
	Local aBaixa	:=	{}
	Local nX:= 0
	Local nY:=	0
	Local nRecSX5	:=	0

	Local aSE2:={}
	Local nMoedaTit := mv_par11
	Local cChaveLbn := ""  
	Local cGerDocFis := MV_PAR13
	Local cPrefOri:= ""
	Private lMsErroAuto	:=	.F.
	Private cProvent := ""
	Default lExterno := .F.
	DbSelectArea("TRB")
	DbGoTop()
	If cPaisLoc $ "ANG|COL|EQU|HAI|MEX|PER|PTG|URU"
		nMoedaTit:= 1
	EndIf	
	If cGerDocFis == 1 .And. mv_par11 == 1 .And. cPaisLoc $ "ARG|BOL|URU"
		cTipDeb  := "NDP"
		cTipCred := "NCP"
	EndIf      
	While !TRB->(EOF())
		If !lMultiPlo .Or. (Alltrim(TRB->TRB_MARCA)==_MARCADO)
			If nSepara == 1
				If (nPos	:=	Ascan(aGerar,{|x| x[2]==TRB->E2_FORNECE+TRB->E2_LOJA}))==0
					AAdd(aGerar,{{TRB->(Recno())},TRB->E2_FORNECE+TRB->E2_LOJA,Iif(TRB->E2_TIPO$ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM,(TRB->TRB_VALDIF*-1),TRB->TRB_VALDIF),dDataBase,TRB->E2_FORNECE,TRB->E2_LOJA,'DC '+Dtoc(dDataBase)})
				Else
					AAdd(aGerar[nPos][1],	TRB->(Recno()))
					If TRB->E2_TIPO$ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM
						aGerar[nPos][3]	-=	TRB->TRB_VALDIF		
					Else
						aGerar[nPos][3]	+=	TRB->TRB_VALDIF		
					EndIf
				Endif
			ElseIf nSepara == 2
				If (nPos	:=	Ascan(aGerar,{|x| x[2]==TRB->E2_PREFIXO+TRB->E2_NUM+TRB->E2_PARCELA+TRB->E2_TIPO+TRB->E2_FORNECE+TRB->E2_LOJA}))==0
					AAdd(aGerar,{{TRB->(Recno())},TRB->E2_PREFIXO+TRB->E2_NUM+TRB->E2_PARCELA+TRB->E2_TIPO+TRB->E2_FORNECE+TRB->E2_LOJA,Iif(TRB->E2_TIPO$ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM,(TRB->TRB_VALDIF*-1),TRB->TRB_VALDIF),dDataBase,TRB->E2_FORNECE,TRB->E2_LOJA,"DC " + TRB->E2_PREFIXO+"/"+TRB->E2_NUM})
				Else
					AAdd(aGerar[nPos][1],	TRB->(Recno()))
					If TRB->E2_TIPO$ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM
						aGerar[nPos][3]	-=	TRB->TRB_VALDIF		
					Else                                    
						aGerar[nPos][3]	+=	TRB->TRB_VALDIF						
					EndIf

				Endif
			Else
				AAdd(aGerar,{{TRB->(Recno())},'',Iif(TRB->E2_TIPO$ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM,(TRB->TRB_VALDIF*-1),TRB->TRB_VALDIF),TRB->TRB_DTAJUS,TRB->E2_FORNECE,TRB->E2_LOJA,TRB->E2_PREFIXO+TRB->E2_NUM+iIF(empty(TRB->E2_ORDPAGO),"Seq:"+TRB->E5_SEQ," OP:"+TRB->E2_ORDPAGO)})
			Endif	                            
		Endif
		TRB->(DbSkip())
	Enddo	     
	ProcRegua(Len(aGerar)*2)
	For nX:=1 To Len(aGerar)

		If Abs(aGerar[nX][3]) > 0
			DbSelectArea('SX5')
			DbSetOrder(1)
			cTipoDoc:= If(aGerar[nX][3]>0,cTipDeb,cTipCred)
			If cGerDocFis == 1 .And. mv_par11 == 1 .And. cPaisloc $ "ARG|URU|BOL"    
				If ExistBlock("FinAltSe")
					cPrefixo:= ExecBlock("FinAltSe",.F.,.F.,{cTipoDoc})
					cPrefOri:= cPrefixo
				Elseif cPaisloc $ "ARG"
					cPrefixo := LocXTipSer("SA2",cTipoDoc)   
				EndIf
				If !SX5->(DbSeek(xFilial("SX5")+"01"+cPrefixo)).And. cPaisloc $ "ARG" 
					cPrefixo := LocXTipSer("SA2",cTipoDoc) 
					If !MsgYesNo(STR0048 + cPrefOri + STR0049 + " "+ cPrefixo +"."+ STR0050,"Confirmación")
						Exit
					EndIf	
				EndIf		

			EndIf
			If SX5->(DbSeek(xFilial()+'01'+cPrefixo))
				nTimes := 0
				While !MsRLock() .and. nTimes < 10
					nTimes++
					Inkey(.1)
					DbSeek( xFilial("SX5")+"01"+cPrefixo,.F. )
				EndDo
				If MsRLock()
					If cPaisloc = "RUS"
						cNum	:=	Right(alltrim(SX5->X5_DESCENG),TamSX3('E2_NUM')[1])
					Else						
						cNum	:=	Substr(X5Descri(),1,TamSX3('E2_NUM')[1])
					EndIf
					nRecSX5	:=	Recno()
				Else
					If lExterno
						lTrava:=.F.
						lCont:=.T.
						While !lTrava // .And. lCont
							nTimes:=1
							While !MsRLock() .and. nTimes < 10
								nTimes++
								Inkey(.1)
								DbSeek( xFilial("SX5")+"01"+cPrefixo,.F. )
							EndDo
							If MsRLock()
								If cPaisloc = "RUS"
									cNum	:=	Right(alltrim(SX5->X5_DESCENG),TamSX3('E2_NUM')[1])
								Else						
									cNum	:=	Substr(X5Descri(),1,TamSX3('E2_NUM')[1])
								EndIf								
								nRecSX5	:=	Recno()
								lTrava:=.T.
								//Else
								//		lCont:=MsgYesNo("Registro em uso por outra usuario.Deseja tentar novamente. ","Trava Registro")
							EndIf	
						EndDo	
						/*If !lCont	
						HELP('',1,'FA084004')
						Exit
						EndIf	*/
					Else
						HELP('',1,'FA084004')
						Exit
					EndIf	
				Endif	
			Else
				HELP('',1,'FA084003')
				Exit
			Endif	

			If cGerDocFis == 1 .And. mv_par11 == 1 .And. cPaisloc $ "ARG|URU|BOL"   			
				F84ValidNum(cPrefixo,@cNum,cTipoDoc,.F.,aGerar[nX][2])
			Else  
				DbSelectArea("SE2")
				DbSetOrder( 6 )
				If DbSeek( xFilial("SE2")+aGerar[nX][5]+aGerar[nX][6]+cPrefixo+cNum+Space(TamSX3('E2_PARCELA')[1])+IIf(aGerar[nX][3]>0,cTipDeb,cTipCred) )
					lRet := .F.
				EndIf		
			EndIf
			cProvent:= ""
			If lRet
				If cPaisloc == "ARG" 
					DbSelectArea("SF1")  
					dbSetOrder(1)
					If DbSeek(xFilial("SF1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_TIPO)
						cProvent:= SF1->F1_PROVENT  
					EndIf	
				EndIf 
				IncProc(STR0011+cPrefixo+"/"+cNum) //'Grabando documento : '
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inclusao de documento no contas a pagar³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aTitulo := { 	{"E2_PREFIXO"	, cPrefixo 			,	Nil},;
				{"E2_NUM"		, cNum				, 	Nil},;
				{"E2_PARCELA"	, ''					,	Nil},;
				{"E2_TIPO"		, cTipoDoc, Nil},;
				{"E2_NATUREZ"	, cNatureza			,	Nil},;
				{"E2_FORNECE"	, aGerar[nX][5]	,  Nil},;
				{"E2_LOJA"		, aGerar[nX][6]	,	Nil},;
				{"E2_EMISSAO"	, aGerar[nX][4]  	,  NIL},;
				{"E2_VENCTO"	, aGerar[nX][4]	,  NIL},;
				{"E2_VENCREA"	, aGerar[nX][4] 	,  NIL},;
				{"E2_ORIGEM"	, 'FINA084'			,	NIL},;
				{"E2_MOEDA"		, nMoedaTit					,	NIL},;
				{"E2_CONVERT"	, 'N'					,	NIL},;
				{"E2_HIST"		, aGerar[nX][7]	,Nil},;
				{"E2_VALOR"		, Abs(aGerar[nX][3])	,	Nil}}

				If cPaisLoc $ "ARG|URU|PAR|CHI|PER|BOL" .and. SuperGetMV( "MV_CTLIPAG",,.F.)
					AADD( aTitulo,{ "E2_DATALIB" , dDataBase, Nil })
				EndIf

				If ExistBlock('FA084CPO')
					aTitulo	:=	ExecBlock('FA084CPO',.F.,.F.,aTitulo)
				Endif
				lMsErroAuto := .F.
				If Abs(aGerar[nX][3]) > 0
					MSExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,nOpc)
					If lMsErroAuto
						DisarmTransaction()
						MostraErro()
					Else
						If SE2->E2_CONVERT <> 'N'
							dbSelectArea( "SE2" )
							RecLock("SE2",.F.)
							Replace E2_CONVERT With 'N'
							MsUnLock()
						Endif                           
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Inclusao de amarracao Titulo x Dif Cambio ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nY:=1 TO LEN(aGerar[nX][1])
							TRB->(dbGoTo(aGerar[nX][1][nY]))
							dbSelectArea( "SFR" )
							RecLock("SFR",.T.)
							REPLACE FR_FILIAL 	WITH	xFilial()
							Replace FR_CHAVDE	WITH	SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
							Replace FR_CHAVOR	WITH	TRB->E2_PREFIXO+TRB->E2_NUM+TRB->E2_PARCELA+TRB->E2_TIPO+TRB->E2_FORNECE+TRB->E2_LOJA
							Replace FR_CARTEI	WITH	"2"
							Replace FR_TIPODI	WITH	TRB->TRB_TIPODI
							Replace FR_DATADI	WITH	TRB->TRB_DTAJUS
							Replace FR_TXATU 	WITH	TRB->TRB_TXATU
							Replace FR_TXORI 	WITH	TRB->TRB_TXORI
							Replace FR_CORANT	WITH	TRB->TRB_VALCOR
							Replace FR_VALOR 	WITH	TRB->TRB_VALDIF
							Replace FR_GEROU 	WITH	"1"
							Replace FR_ORDPAG	WITH	TRB->E2_ORDPAGO
							Replace FR_SEQUEN With  TRB->E5_SEQ 
							If cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|RUS|URU"
								Replace FR_MOEDA With nMoedaTit
							EndIf	
							MsUnLock()                                  
						Next nY
						SX5->(DbSeek(xFilial()+'01'+cPrefixo))
						IF RecLock("SX5",.F.)
							Replace X5_DESCRI  With Soma1(cNum)
							Replace X5_DESCENG With Soma1(cNum)
							Replace X5_DESCSPA With Soma1(cNum)
							MsUnlock()
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ponto de entrada p/ gravacao dos campos criados pelo usuario ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ExistBlock("FA084GRV")
							EXECBLOCK("FA084GRV",.F.,.F.)
						Endif                                              
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Baixa do titulo                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						IncProc(STR0012+cPrefixo+"/"+cNum) //'Bajando documento : '
						aBaixa	:=	{}	
						AADD( aBaixa, { "E2_PREFIXO" 	, SE2->E2_PREFIXO		, Nil } )	// 01
						AADD( aBaixa, { "E2_NUM"     	, SE2->E2_NUM		 	, Nil } )	// 02
						AADD( aBaixa, { "E2_PARCELA" 	, SE2->E2_PARCELA		, Nil } )	// 03
						AADD( aBaixa, { "E2_TIPO"    	, SE2->E2_TIPO			, Nil } )	// 04
						AADD( aBaixa, { "E2_FORNECE"	, SE2->E2_FORNECE		, Nil } )	// 05
						AADD( aBaixa, { "E2_LOJA"    	, SE2->E2_LOJA			, Nil } )	// 06
						AADD( aBaixa, { "AUTMOTBX"  	, "DIF"					, Nil } )	// 07
						AADD( aBaixa, { "AUTBANCO"  	, ""					, Nil } )	// 08
						AADD( aBaixa, { "AUTAGENCIA"  	, ""					, Nil } )	// 09
						AADD( aBaixa, { "AUTCONTA"  	, ""					, Nil } )	// 10
						AADD( aBaixa, { "AUTDTBAIXA"	, SE2->E2_EMISSAO		, Nil } )	// 11
						AADD( aBaixa, { "AUTHIST"   	, STR0020				, Nil } )	// 12
						AADD( aBaixa, { "AUTDESCONT" 	, 0						, Nil } )	// 13
						AADD( aBaixa, { "AUTMULTA"	 	, 0						, Nil } )	// 14
						AADD( aBaixa, { "AUTJUROS"		, 0						, Nil } )	// 15
						AADD( aBaixa, { "AUTOUTGAS" 	, 0						, Nil } )	// 16
						AADD( aBaixa, { "AUTVLRPG"  	, 0        				, Nil } )	// 17
						AADD( aBaixa, { "AUTVLRME"  	, 0						, Nil } )	// 18
						AADD( aBaixa, { "AUTCHEQUE"  	, ""					, Nil } )	// 19
						lMsErroAuto := .F.
						MSExecAuto({|x,y| Fina080(x,y)},aBaixa,3)
						If lMsErroAuto
							DisarmTransaction()
							MostraErro()
						Else
							aSE2:=GetaRea()
							For nY:=1 TO LEN(aGerar[nX][1])
								TRB->(dbGoTo(aGerar[nX][1][nY]))
								SE2->(DbSetOrder(1))
								If SE2->(DbSeek(xFilial("SE2")+TRB->E2_PREFIXO+TRB->E2_NUM+TRB->E2_PARCELA+TRB->E2_TIPO+TRB->E2_FORNECE+TRB->E2_LOJA))
									If  ((!(FunName()$"FINA847|FINA850") .And. cPaisLoc <> "URU")   .Or. (!(FunName()$"FINA085A") .And. cPaisLoc == "URU") ) .And. ;
									  	((mv_par07 ==1  .And. Alltrim(SE2->E2_ORIGEM) <> "SIGAEIC") .Or. lExterno) .Or. (mv_par09==1 .And. Alltrim(SE2->E2_ORIGEM)	==	"SIGAEIC") 
										RecLock('SE2',.F.)
										Replace E2_DTDIFCA	With dDataBase
										MsUnLock()
									EndIf
								EndIf	
							Next
							RestArea(aSE2)
						EndIf
					EndIf
				EndIf	
				If cGerDocFis== 1 .And. mv_par11 == 1 .And. cPaisloc $ "ARG|URU|BOL" // Verifica se gera documento fiscal  e se a dif será em moeda 1
					F084GeraNF(aGerar[nX][3],TRB->E2_EMISSAO)    	
				EndIf 
			Else
				Help('',1,'FA084002')
			Endif
		Endif	
	Next	
	If nRecSX5 > 0
		SX5->(MsGoTo(nRecSX5))
		MsUnLock()
	Endif	

	If !lExterno
		Pergunte("FIN84A",.F.)
		SetKey (VK_F12,{|a,b| AcessaPerg("FIN84A",.T.)})
	EndIf	
Return	

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa084Tela   ³ Autor ³ Bruno Sobieski      ³ Data ³ 22.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a tela para mostrar os dados                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fina084                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa084Tela(nOpc,nTotAjuste,aCampos,lMultiplo)
	Local aObjects := {}
	LOCAL aPosObj  :={}
	LOCAL aSize		:=MsAdvSize()
	LOCAL aInfo    :={aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	Local nOpca		:=	2
	Local oCol		:= Nil
	Local oLbx
	Local nX			:=	0
	Local bOk,bCanc
	Local nBitMaps	:=	1
	Local oTotAjuste
	Local aButtons	:=	{}
	Local bMarkAll
	Local bUnMarkAll
	Local bInverte 
	Local lVisual 	:=	(nOpc == 2)
	Local lInclui	:=	(nOpc == 3)
	Local lDeleta	:=	(nOpc == 5)
	Local oFont 
	Local nMoeda:= 1
    Local lAutomato := IsBlind()
	DEFINE FONT oFont NAME "Arial" BOLD

	DEFAULT lMultiplo	:=	.F.
	If lMultiplo
		nBitMaps := 2
	Endif	

	If cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|URU"
		nMoeda:= mv_par11
	EndIf	               

	If !lDeleta
		bOk	:=	{|| nOpca:=	1,oDlg:End()}
		bCanc	:=	{|| nOpca:=	2,oDlg:End()}
	Else
		bOk	:=	{|| IIf(Fa084DelOk(),(nOpca:=1,oDlg:End()),Nil)}
		bCanc	:=	{|| nOpca:=	2,oDlg:End()}
	Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Passo parametros para calculo da resolucao da tela                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aadd( aObjects, { 100, 015, .T., .T. } )
	aadd( aObjects, { 100, 085, .T., .T. } )
	aPosObj  := MsObjSize( aInfo, aObjects, .T. )
	If !lAutomato
	DEFINE MSDIALOG oDlg FROM aSize[7], 000 TO aSize[6], aSize[5] TITLE OemToAnsi(Iif(lDeleta,STR0013,IIf(lInclui,STR0014,STR0023))+STR0015) PIXEL //"Borrado de "###"Generacion de"###"Visualizacion de"###" ajuste por diferencia de cambio"

	@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4]-83 LABEL "" OF oDlg  PIXEL
	@ aPosObj[1,1]+005,010 SAY OemToAnsi(STR0028+' (' + GetMv("MV_SIMB"+Alltrim(Str(nMoeda)))+')') 	SIZE 80, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE //Valor Del Ajuste
	@ aPosObj[1,1]+005,072 SAY oTotAjuste VAR nTotAjuste   PICTURE PesqPict("SE2","E2_VLCRUZ",18) SIZE 65, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE
	If !lInclui
		@ aPosObj[1,1]+015,010 SAY OemToAnsi(STR0029+' :  '+Dtoc(SE2->E2_EMIS1)) SIZE 60, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE // Emision
		@ aPosObj[1,1]+015,072 SAY OemToAnsi(STR0030+' : '+SE2->E2_TIPO) SIZE 35, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE //Tipo
		@ aPosObj[1,1]+015,105 SAY OemToAnsi(STR0031+' : '+SE2->E2_PREFIXO) SIZE 40, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE //Prefijo
		@ aPosObj[1,1]+015,145 SAY OemToAnsi(STR0032+' : '+SE2->E2_NUM) SIZE 100, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE  //Numero
		@ aPosObj[1,1]+025,010 SAY OemToAnsi(STR0033+' : '+Posicione('SA2',1,xFilial('SA2')+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_NOME")) SIZE 150, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE //Proveedor
	Endif
	@ aPosObj[1,1],aPosObj[1,4]-82 TO aPosObj[1,3],aPosObj[1,4] LABEL "" OF oDlg  PIXEL
	@ aPosObj[1,1]+005,aPosObj[1,4]-80 BITMAP RESOURCE 'BR_AMARELO'	NO BORDER SIZE 10,7 OF oDlg PIXEL 
	@ aPosObj[1,1]+005,aPosObj[1,4]-70 SAY STR0034  SIZE 20, 7 OF oDlg PIXEL //'Pagos'
	@ aPosObj[1,1]+015,aPosObj[1,4]-80 BITMAP RESOURCE 'BR_AZUL'	NO BORDER 	SIZE 10,7 OF oDlg PIXEL 
	@ aPosObj[1,1]+015,aPosObj[1,4]-70 SAY STR0035  SIZE 20, 7 OF oDlg PIXEL //'Saldo'
	@ aPosObj[1,1]+025,aPosObj[1,4]-80 BITMAP  RESOURCE 'BR_PRETO'		NO BORDER SIZE 10,7 OF oDlg PIXEL 
	@ aPosObj[1,1]+025,aPosObj[1,4]-70 SAY STR0036  SIZE 70, 7 OF oDlg PIXEL //'Invoices Corregidas'

	oLbx := TCBROWSE():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3]-55, , , , , , , , , , ,, , , , , .T., , .T., , .F.,,)
	If lMultiplo
		oLbx:BLDblClick := {|| Fa084Mark(oLbx,@nTotAjuste,@oTotAjuste,1)}

		bMarkAll	:= { || CursorWait() ,;
		Fa084Mark(oLbx,@nTotAjuste,@oTotAjuste,2),;
		CursorArrow();
		}
		bUnMarkAll	:= { || CursorWait() ,;
		Fa084Mark(oLbx,@nTotAjuste,@oTotAjuste,3),;
		CursorArrow();                        
		}
		bInverte		:= { || CursorWait() ,;
		Fa084Mark(oLbx,@nTotAjuste,@oTotAjuste,4),;
		CursorArrow();
		}
		SetKey( VK_F4 , bMarkAll )
		SetKey( VK_F5 , bUnMarkAll )
		SetKey( VK_F6 , bInverte )
		aAdd( aButtons ,	{;
		"CHECKED"						,;
		bMarkAll							,;
		OemToAnsi( STR0037 + "...<F4>" )	,;			//"Marca Todos"
		OemToAnsi( STR0038 )				 ;			//"Marca"
		})

		aAdd( aButtons ,	{;
		"UNCHECKED"						,;
		bUnMarkAll							,;
		OemToAnsi(  STR0039 + "...<F5>" )	,;			//"Desmarca Todos"
		OemToAnsi( STR0040 )				 ;			//"Desmarca"
		})
		aAdd( aButtons ,	{;
		"PENDENTE"						,;
		bInverte							,;
		OemToAnsi( STR0041 + "...<F6>" )	,;			//"Inverte todos"
		OemToAnsi( STR0042 )				 ;			//"Inverte"
		})
	Endif
	For nX:=1 To nBitMaps
		//Definir colunaa com o BITMAP
		DEFINE COLUMN oCol DATA FIELDWBlock(aCampos[nX][2],Select('TRB')) BITMAP HEADER OemToAnsi(aCampos[nX][1]) PICTURE  aCampos[nX][6] ALIGN LEFT SIZE CalcFieldSize(aCampos[nX,3],aCampos[nX,4],aCampos[nX,5],aCampos[nX,2],aCampos[nX,1]) PIXELS
		oLbx:AddColumn(oCol)	 	
	Next

	//Definir as demais colunas
	For nX:=(nBitMaps+1) To Len(aCampos)
		DEFINE COLUMN oCol DATA FIELDWBlock(aCampos[nX][2],Select('TRB')) HEADER OemToAnsi(aCampos[nX][1]) PICTURE  aCampos[nX][6] ALIGN LEFT SIZE CalcFieldSize(aCampos[nX,3],aCampos[nX,4],aCampos[nX,5],aCampos[nX,2],aCampos[nX,1]) PIXELS
		oLbx:AddColumn(oCol)	 	
	Next
   
	   ACTIVATE MSDIALOG oDlg On INIT EnchoiceBar(oDlg,bOk,bCanc,,aButtons)
    Else
       nOpca := 1
    EndIf

	Set key VK_F4  To
	Set key VK_F5  To
	Set key VK_F6  To

Return nOpca

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa084Dele   ³ Autor ³ Bruno Sobieski      ³ Data ³ 22.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apaga o ajuste por diferencia de cambio                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fina084                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA084Dele(nRecSE2,nRecSFR)
	Local aBaixa	:=	{}
	Local aDifs	:=	{}
	Local nX:=1
	Local dUltDif	
	Local cSequencia	:=	Space(TamSx3('FR_SEQUEN')[1])
	Local cTipoMov		:=	"S"
	local nMoedaTit :=1  
	local cAlias := ""
	  
	Local lAutomato := IsBlind()
	Default nRecSFR := 0

	If cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|URU"
		nMoedaTit := mv_par11
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Baixa do titulo                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SE2->(MsGoTo(nRecSE2))
	If cPaisLoc $ "ARG|BOL|URU"
		If SE2->E2_TIPO == "NDP"
			cAlias := "SF1" 
		ElseIf SE2->E2_TIPO == "NCP"
			cAlias := "SF2" 
		EndIf
		If !Empty(cAlias)
			DbSelectArea(cAlias)
			DbSetOrder(1)
			If DbSeek(xFilial(cAlias)+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA)
				F084CancelNF(cAlias)
			EndIf	
		EndIf	
	EndIf	
	IncProc( STR0043+' : '+SE2->E2_PREFIXO+"/"+SE2->E2_NUM) //Borrando baja de documento
	aBaixa	:=	{}	
	AADD(aBaixa,{"E2_PREFIXO" 	,SE2->E2_PREFIXO		, Nil})	// 01
	AADD(aBaixa,{"E2_NUM"     	,SE2->E2_NUM			, Nil})	// 02
	AADD(aBaixa,{"E2_PARCELA" 	,SE2->E2_PARCELA		, Nil})	// 03
	AADD(aBaixa,{"E2_TIPO"    	,SE2->E2_TIPO			, Nil})	// 04
	AADD(aBaixa,{"E2_MOEDA"   	,SE2->E2_MOEDA			, Nil})	// 05
	AADD(aBaixa,{"E2_TXMOEDA"	,SE2->E2_TXMOEDA		, Nil})	// 06
	lMsErroAuto := .F.
	MSExecAuto({|x,y| Fina080(x,y)},aBaixa,5)
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
	Else 	
		DbSelectArea('TRB')
		DbGoTop()
		While !EOF()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Delecao de amarracao Titulo x Dif Cambio  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea( "SFR" )		
			If (nRecSFR > 0) .And. ( (FUNNAME() == "FINA847") .or. (lAutomato .and. cPaisLoc == "ARG" )  .Or. (FUNNAME() == "FINA086" .and. cPaisLoc=="URU") )
				SFR->(dbGoTo(nRecSFR))
			Else
				SFR->(dbGoTo(TRB->TRB_RECSFR))
			EndIf
			If FA084EstDC()
				AAdd(aDifs,SFR->FR_CHAVOR)
				RecLock("SFR",.F.)
				DbDelete()
				MsUnLock()
			EndIf
			DbSelectArea('TRB')
			DbSkip()
		Enddo
		IncProc(STR0044+' : '+SE2->E2_PREFIXO+"/"+SE2->E2_NUM) //Borrando documento
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Delecao de documento no contas a pagar³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTitulo := { 	{"E2_PREFIXO"	, SE2->E2_PREFIXO	,	Nil},;
		{"E2_NUM"		, SE2->E2_NUM		, 	Nil},;
		{"E2_PARCELA"	, SE2->E2_PARCELA	,	Nil},;
		{"E2_TIPO"		, SE2->E2_TIPO		, 	Nil},;
		{"E2_NATUREZ"	, SE2->E2_NATUREZA,	Nil},;
		{"E2_FORNECE"	, SE2->E2_FORNECE	,  Nil},;
		{"E2_LOJA"		, SE2->E2_LOJA		,	Nil},;
		{"E2_MOEDA"		, nMoedaTit					,	NIL}}
		lMsErroAuto := .F.
		DbSelectArea('SE2')	
		MSExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,5)
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Regravar a data de ultima diferencie de cambio calculada, com³
			//³a ultima data de DC.                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX:=1 To Len(aDifs)
				dUltDif	:=	Ctod('')
				DbSelectArea('SFR')
				DbSetOrder(3)
				DbSeek(xFilial()+"2"+cTipoMov+cSequencia+aDifs[nX]+'zzzzzz',.T.)
				DbSkip(-1)
				If FR_FILIAL==xFilial() .And. FR_CARTEI=="2" .And. FR_CHAVOR==PADR(aDifs[nX],len(FR_CHAVOR)) .And.FR_TIPODI=='S'
					dUltDif	:=	SFR->FR_DATADI
				EndIf
				DbSelectArea('SE2')	
				DbSetOrder(1)
				MsSeek(xFilial()+aDifs[nX])			
				RecLock('SE2',.F.)
				Replace E2_DTDIFCA With dUltDif
				MsUnLock()
			Next	
		Endif
	Endif	

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa084DelOk  ³ Autor ³ Bruno Sobieski      ³ Data ³ 22.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a exclusao da diferencia de cambio                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fina084                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fa084DelOk()
	Local	lRet	:=	.T.

	lRet	:=	(Aviso(STR0045,STR0046+CRLF+STR0016,{STR0017,STR0005})==1) //'Confirmacion'###'Seran borrados todos los movimientos de diferencia de cambio visualizados.'###"Confirmar"###"Cancelar"


Return lRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa084GerTRB ³ Autor ³ Bruno Sobieski      ³ Data ³ 22.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera arquivo de trabalho para a visualizacao e delecao     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fina084                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Fa084GerTRB(aCampos,nTotAjuste)
	Local aStruTRB	:=	{}
	Local nX	:=	0
	Local cArquivo	:=	''
	Local cChave	:=	''
	//Monta estrutura do trb
	aadd(aStruTrb,{"TRB_ORIGEM"	,"C",12,0})
	aadd(aStruTrb,{"E2_FORNECE"	,"C",TamSx3("E2_FORNECE")[1],TamSx3("E2_FORNECE")[2]})
	aadd(aStruTrb,{"E2_LOJA"  		,"C",TamSx3("E2_LOJA"   )[1],TamSx3("E2_LOJA"   )[2]})
	aadd(aStruTrb,{"E2_PREFIXO"	,"C",TamSx3("E2_PREFIXO")[1],TamSx3("E2_PREFIXO")[2]})
	aadd(aStruTrb,{"E2_NUM"			,"C",TamSx3("E2_NUM"    )[1],TamSx3("E2_NUM"    )[2]})
	aadd(aStruTrb,{"E2_PARCELA"	,"C",TamSx3("E2_PARCELA")[1],TamSx3("E2_PARCELA")[2]})
	aadd(aStruTrb,{"E2_TIPO"		,"C",TamSx3("E2_TIPO"   )[1],TamSx3("E2_TIPO"   )[2]})
	aadd(aStruTrb,{"E2_ORDPAGO"	,"C",TamSx3("E2_ORDPAGO")[1],TamSx3("E2_ORDPAGO")[2]})
	aadd(aStruTrb,{"E2_EMISSAO"	,"D",TamSx3("E2_EMISSAO")[1],TamSx3("E2_EMISSAO")[2]})
	//aadd(aStruTrb,{"E2_VALOR"	   ,"N",TamSx3("E2_VALOR"  )[1],TamSx3("E2_VALOR"  )[2]})
	aadd(aStruTrb,{"TRB_VALDIF"	,"N",TamSx3("E2_VLCRUZ" )[1],TamSx3("E2_VLCRUZ" )[2]})
	aadd(aStruTrb,{"TRB_RECSFR"	,"N",10,0})

	SX3->(DbSetOrder(2))
	AAdd(aCampos,{' ','TRB_ORIGEM',aStruTRB[1][2],aStruTRB[1][3],aStruTRB[1][4],"@BMP"})
	For nX := 2 To (Len(aStruTRB)-1)
		If !(aStruTRB[nX][1]$"TRB_VALDIF")
			SX3->(DbSeek(aStruTRB[nX][1]))
			AAdd(aCampos,{X3TITULO(aStruTRB[nX][1]),aStruTRB[nX][1],aStruTRB[nX][2],aStruTRB[nX][3],aStruTRB[nX][4],PesqPict("SE2",aStruTRB[nX][1])})
		Else
			AAdd(aCampos,{STR0008,aStruTRB[nX][1],aStruTRB[nX][2],aStruTRB[nX][3],aStruTRB[nX][4],PesqPict("SE2","E2_VLCRUZ")}) //"Diferencia"
		Endif
	Next

	//Creacion de Objeto 
	oTmpTable := FWTemporaryTable():New("TRB") //leem
	oTmpTable:SetFields( aStruTrb ) //leem

	aOrdem	:=	{"E2_FORNECE","E2_LOJA","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO"} //leem

	oTmpTable:AddIndex("I1", aOrdem) //leem

	oTmpTable:Create() //leem

	SE2->(DbSetOrder(1))
	cChave	:=		PADR(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA , len(SFR->FR_CHAVDE))
	DbSelectArea('SFR')
	DbSetOrder(2)
	DbSeek(xFilial()+"2"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
	While !EOF() .And. FR_CARTEI=="2" .AND. FR_CHAVDE ==	cChave
		SE2->(DbSeek(xFilial()+left(SFR->FR_CHAVOR,len(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA))))
		Reclock('TRB',.T.)
		Replace E2_FORNECE With SE2->E2_FORNECE
		Replace E2_LOJA 	 With SE2->E2_LOJA
		Replace E2_PREFIXO With SE2->E2_PREFIXO
		Replace E2_NUM     With SE2->E2_NUM    
		Replace E2_PARCELA With SE2->E2_PARCELA
		Replace E2_TIPO    With SE2->E2_TIPO
		Replace E2_EMISSAO With SFR->FR_DATADI 
		Replace E2_ORDPAGO With SFR->FR_ORDPAG
		Replace TRB_ORIGEM With Iif(SFR->FR_TIPODI=="S",_AZUL,IIf(SFR->FR_TIPODI=="B",_AMARELO,_PRETO))
		Replace TRB_VALDIF With SFR->FR_VALOR
		Replace TRB_RECSFR With SFR->(Recno())
		MsUnLock()		
		If TRB->E2_TIPO$ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM		
			nTotAjuste	-=	SFR->FR_VALOR
		Else
			nTotAjuste	+=	SFR->FR_VALOR
		EndIf
		DbSelectArea('SFR')
		DbSkip()
	EndDo
	//BBB
	DbGotop()
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa084Legenda³ Autor ³ Bruno Sobieski      ³ Data ³ 22.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fina084 e Fina084                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa084Legenda(cAlias, nReg)

	Local aLegenda := { 	{"BR_VERDE", STR0018 },;	 //"Titulo en abierto"
	{"BR_AZUL" , STR0019 },;	 //"Bajado parcialmente"
	{"BR_AMARELO" , STR0020 },;	 //"Diferencia de cambio"
	{"BR_VERMELHO", STR0021} ,;	 //"Bajado totalmente"
	{"BR_PRETO"  , STR0047} }	 //"Ya ajustado"

	Local uRetorno := .T.

	If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
		uRetorno := {}
		Aadd(uRetorno, { 'E2_CONVERT == "N"', aLegenda[3][1] } )
		Aadd(uRetorno, { 'E2_DTDIFCA >= dDataBase  ', aLegenda[5][1] } )
		Aadd(uRetorno, { 'ROUND(E2_SALDO,2) = 0', aLegenda[4][1] } )
		Aadd(uRetorno, { 'ROUND(E2_SALDO,2) # ROUND(E2_VALOR,2)', aLegenda[2][1] } )
		Aadd(uRetorno, { '.T.', aLegenda[1][1] } )
	Else
		BrwLegenda(cCadastro, STR0006 , aLegenda) //"Leyenda"
	Endif

Return uRetorno

Static Function Fa084Mark(oLbx,nTotAjuste,oTotAjuste,nOpc)
	Local	cChave	:=	TRB->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
	Local nRecno	:=	TRB->(Recno())
	Local cMarca	:=	IIf(TRB->TRB_MARCA  <> _DESMARCADO,_DESMARCADO,_MARCADO)     
	Local bWhile

	DbSelectArea('TRB')
	//Inverte o atual   
	If nOpc == 1
		bWhile	:=	{|| cChave==TRB->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)}
		DbSeek(cChave)
		//Marcar todos
	ElseIf nOpc == 2
		bWhile	:=	{|| .T.}
		DbGoTop()	
		cMarca	:=	_MARCADO
		//DesMarcar todos
	ElseIf nOpc == 3
		bWhile	:=	{|| .T.}
		DbGoTop()	
		cMarca	:=	_DESMARCADO
		//Inverte todos
	ElseIf nOpc == 4
		bWhile	:=	{|| .T.}
		DbGoTop()	
	Endif
	While !Eof() .And. Eval(bWhile)
		If nOpc == 1 .Or. nOpc==4 //Inverte
			cMarca	:=	IIf(TRB->TRB_MARCA  <> _DESMARCADO,_DESMARCADO,_MARCADO)     
		Endif	
		cMarcaAnt := TRB_MARCA
		RecLock('TRB',.F.)
		Replace TRB_MARCA  With cMarca
		MsUnlock()                                       
		If cMarcaAnt <> cMarca
			If TRB->E2_TIPO$ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM
				nTotAjuste	+=	(TRB->TRB_VALDIF * IIf(cMarca  <> _DESMARCADO,-1,1))
			Else
				nTotAjuste	+=	(TRB->TRB_VALDIF * IIf(cMarca  <> _DESMARCADO,1,-1))
			EndIf	
		Endif
		DbSkip()
	Enddo         
	DbGoTo(nRecno)
	oLbx:Refresh()
	oTotAjuste:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³21/11/06 ³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef(lFR_MOEDA) 
	Local nA := 0   


	Local aRotina := { { OemToAnsi(STR0001), "PesqBrw", 0 , 1},; //"Pesquisar" //"Busqueda"
	{ OemToAnsi(STR0002)	, "AxVisual" 	, 0 , 2},; //"Visualizar"
	{ OemToAnsi(STR0003)	, "Fa084Vis" 	, 0 , 2},; //"Vis. Detalhe"
	{ OemToAnsi(STR0022)	, "Fa084GDifM" , 0 , 4},; 
	{ OemToAnsi(STR0004)	, "FA084GDif(.F.)" , 0 , 4},; //"Gen. Dif. Cambio"
	{ OemToAnsi(STR0005)	, "FA084CanC" 	 ,0 , 5},; //"Cancelar" 
	{ OemToAnsi(STR0006)	, "Fa084Legenda",0 , 6} } //"Le&genda" 

	Default lFR_MOEDA := .F.
	If lFR_MOEDA
		Aadd(aRotina,{ OemToAnsi(STR0024),"FA084SETMOE()",0,1})		// Modificar tasas }
		Aadd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1")})
		For nA	:=	2	To nC
			cMoedaTx	:=	Str(nA,IIf(nA <= 9,1,2))
			If !Empty(GetMv("MV_MOEDA"+cMoedaTx))
				Aadd(aTxMoedas,{GetMv("MV_MOEDA"+cMoedaTx),RecMoeda(dDataBase,nA),PesqPict("SM2","M2_MOEDA"+cMoedaTx) })
			Else
				Exit
			Endif
		Next
	EndIf	

Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA085SetMoºAutor  ³Alexandre Silva     º Data ³  11.01.02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Configura as taxas das moedas.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA085A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa084SetMo()

	Local   lConfirmo   :=	 .F.
	Local   aCabMoed	  :=	{}
	Local   aTamMoed	  := {23,25,30,30}
	Local   aCpsMoed    := {"cMoeda","nTaxa"}
	Local	  aTmp1	     := aTxMoedas[1]
	Private nQtMoedas   := Moedfin()
	Private aLinMoed    :=	aClone(aTxMoedas)
	Private oBMoeda              
	aDel(aLinMoed,1)
	aSize(aLinMoed,Len(aLinMoed)-1)
	/*
	Set Filter to

	Eval(bFiltraBrw)
	*/
	Posicione("SX3",2,"EL_MOEDA","X3_TITULO")
	Aadd(aCabMoed,X3Titulo())
	Aadd(aCabMoed,STR0025)

	If nQtMoedas > 1
		Define MSDIALOG oDlg From 50,250 TO 212,480 TITLE STR0025 PIXEL //"Tasas"

		oBMoeda:=TwBrowse():New(04,05,09,09,,aCabMoed,aTamMoed,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

		oBMoeda:SetArray(aLinMoed)
		oBMoeda:bLine 	:= { ||{aLinMoed[oBMoeda:nAT][1],;
		Transform(aLinMoed[oBMoeda:nAT][2],PesqPict("SM2","M2_MOEDA"+AllTrim(Str(oBMoeda:nAT)),TamSx3("M2_MOEDA"+AllTrim(Str(oBMoeda:nAT)))[1]))}}

		oBMoeda:bLDblClick   := {||EdMoeda(),oBMoeda:ColPos := 1,oBMoeda:SetFocus()}
		oBMoeda:lHScroll     := .F.
		oBMoeda:lVScroll     := .T.
		oBMoeda:nHeight      := 112
		oBMoeda:nWidth	      := 215
		obMoeda:AcolSizes[1]	:= 50

		DEFINE  SButton FROM 064,50 TYPE 1 Action (lConfirmo := .T. , oDlg:End() ) ENABLE OF oDlg  PIXEL
		DEFINE  SButton FROM 064,80 TYPE 2 Action (,oDlg:End() ) ENABLE OF oDlg  PIXEL
		Activate MSDialog oDlg
	Else
		Help("",1,"NoMoneda")
	EndIf

	If lConfirmo
		AAdd(aLinMoed,{})
		aIns(aLinMoed,1)
		aLinMoed[1]	:=	aClone(aTmp1)
		aTxMoedas	:=	aClone(aLinMoed)
	Endif

Return
Static Function EdMoeda()

	oBMoeda:ColPos := 1
	lEditCell(@aLinMoed,oBMoeda,PesqPict("SM2","M2_MOEDA"+AllTrim(Str(oBMoeda:nAT)),TamSX3("M2_MOEDA"+AllTrim(Str(oBMoeda:nAT)))[1]),2)
	aLinMoed[oBMoeda:nAT][2] := obMoeda:Aarray[oBMoeda:nAT][2]

Return                       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA084TemDCºAutor  ³Marcelo Akama       º Data ³  02.09.09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se tem diferença de cambio gerada                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA084                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa084TemDC(cAliasSE2)
	Local aAreaSFR	:= SFR->(GetArea())
	Local aAreaSE2  := {}
	Local lRet		:= .F.
	Local lBaixa	:= .F.
	Local lSaldo	:= .F.
	Local cChave
	Local nLen

	DEFAULT cAliasSE2 := "SE2"

	aAreaSE2 := (cAliasSE2)->(GetArea())
	cChave := (cAliasSE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
	nLen   := Len(cChave)
	cChave := PADR(cChave, len(SFR->FR_CHAVOR) )
	SE2->(dbSetOrder(1))
	SFR->(dbSetOrder(1))
	SFR->(dbSeek(xFilial("SFR")+"2"+cChave+DTOS(dDataBase), .T.))
	Do While !lRet .And. SFR->FR_FILIAL==xFilial("SFR") .And. SFR->FR_CARTEI=="2" .And. SFR->FR_CHAVOR==cChave .And. SFR->FR_DATADI>=dDataBase
		dbSelectArea("SE2")
		If SE2->(dbSeek(xFilial("SE2")+left(SFR->FR_CHAVDE,nLen))) .And. SE2->E2_MOEDA == mv_par11
			If SFR->FR_TIPODI == "S"
				lSaldo := .T.
			Endif
			If SFR->FR_TIPODI == "B"
				lBaixa := .T.
			Endif
		EndIf
		SFR->(dbSkip())
	EndDo

	lRet := (lBaixa .And. lSaldo)

	SFR->(RestArea(aAreaSFR))
	SE2->(RestArea(aAreaSE2))

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA084EstDCºAutor  ³Marcelo Akama       º Data ³  03.09.09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Estorna lancamentos de diferenca de cambio                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA084                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA084EstDC()
	Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
	Local nHdlPrv
	Local cArquivo
	Local nTotDoc
	Local lLanctOk
	Local nLinha
	Local lDigita	:= .T.
	Local lAglutina	:= .F.
	Local lRet		:= .T.
	Private cLote
	Private aFlagCTB := {}

	If cPaisLoc $ "ANG|COL|MEX" .And. SFR->FR_LA == "S"

		//+--------------------------------------------------------------+
		//¦ Verifica o Número do Lote 									 ¦
		//+--------------------------------------------------------------+
		dbSelectArea("SX5")
		dbSeek(xFilial()+"09FIN")
		If Found()
			If At(UPPER("EXEC"),SX5->X5_DESCRI) > 0
				cLote := &(SX5->X5_DESCRI)
			Else
				cLote := SX5->X5_DESCRI
			Endif
		Else
			cLote := "FIN"
		Endif

		nHdlPrv := HeadProva( cLote, "COFFA01", Substr( cUsuario, 7, 6 ), @cArquivo )

		If nHdlPrv <= 0
			Help(" ",1,"A100NOPROV")
			Return .F.
		EndIf

		nTotDoc := DetProva( nHdlPrv,;
		IIf(SFR->FR_CARTEI=="1","57B","57D"),;
		"COFFA01",;
		cLote,;
		@nLinha,;
		/*lExecuta*/,;
		/*cCriterio*/,;
		/*lRateio*/,;
		/*cChaveBusca*/,;
		/*aCT5*/,;
		/*lPosiciona*/,;
		@aFlagCTB,;
		/*aTabRecOri*/,;
		/*aDadosProva*/ )

		//+-----------------------------------------------------+
		//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
		//+-----------------------------------------------------+
		RodaProva(  nHdlPrv, nTotDoc)

		//+-----------------------------------------------------+
		//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
		//+-----------------------------------------------------+
		lRet := cA100Incl(	cArquivo,;
		nHdlPrv,;
		3,;
		cLote,;
		lDigita,;
		lAglutina,;
		/*cOnLine*/,;
		/*dData*/,;
		/*dReproc*/,;
		@aFlagCTB,;
		/*aDadosProva*/,;
		/*aDiario*/ )
		aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F084GeraNFºAutor  ³Ana Paula Nascimentoº Data ³  18.03.10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera documento fiscal para diferença de cambios geradas     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA084 e FINA085A                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F084GeraNF(nTotDif,dDataTit)
	Local  lTeste:=.T.
	Local aCab 			:= {} 	//Dados do cabeçalho
	Local aItem 		:= {} 	//Dados do item
	Local aLinea 		:= {} 	//Matriz que guarda la matriz aItem (requerido por la rutina)
	Local nSigno  :=      Iif(SE2->E2_TIPO $MV_CPNEG+"/"+MVPAGANT,-1,1)
	Local cTipo:=  Iif(SE2->E2_TIPO == "NCP",07,09)
	Local nNumNF := 0
	Local lGera := .T.
	Local cSerie:= "   "                      
	Local cGerDocFis := MV_PAR13
	Local cTipoDoc := SE2->E2_TIPO  
	Private lMsErroAuto := .F.  
	DEFAULT dDataTit := dDatabase

	// ******************Dados do Item*********************
	DbSelectArea("SB1")  
	SB1->( dbSetOrder(1) )
	If DbSeek(xFilial("SB1")+MV_PAR12)
		cCodProd:=SB1->B1_COD
		cUndMed:=SB1->B1_UM
		cDep:=SB1->B1_LOCPAD
	Elseif cGerDocFis == 1
		Help('',1,'FA084013')
		lGera := .F.
		DisarmTransaction()
	EndIF

	If lGera
		// *********** Dados da TES *****************
		DbSelectArea("SF4")
		dbSetOrder(1)
		If SE2->E2_TIPO $ "NCP" .And. !Empty(SA2->A2_TESC)
			DbSeek(xFilial('SF4')+SA2->A2_TESC)
			cTES:= SA2->A2_TESC
			cCf:= SF4->F4_CF

		Elseif SE2->E2_TIPO $ "NDP" .And. !Empty(SA2->A2_TESD)
			DbSeek(xFilial('SF4')+SA2->A2_TESD)
			cCf:= SF4->F4_CF    
			cTES:= SA2->A2_TESD
			cGerNF:=  SF4->F4_DOCDIF
		Else
			Help('',1,'FA084015')
			lGera:= .F.      // Se nao tiver TES configurada no fornecedor não deverá ser gerado doc fiscal
			DisarmTransaction()
		EndIf


		If SF4->F4_DOCDIF <>"1" .And. SF4->F4_DUPLIC == "N"
			lGera:= .F.
		ElseIf SF4->F4_DOCDIF =="1" .And. SF4->F4_DUPLIC == "N"
			lGera:=.T.
		ElseIf SF4->F4_DOCDIF <>"1" .And. SF4->F4_DUPLIC == "S"
			lGera:=.F.
		ElseIf SF4->F4_DOCDIF =="1" .And. SF4->F4_DUPLIC == "S"
			lGera:=.T.
		EndIf   
	EndIf	
	// Documento Fiscal 
	If SE2->E2_TIPO $ "NCP" .And. lGera
		aAdd(aCab, {"F2_CLIENTE"		, SE2->E2_FORNECE	,Nil}) //Código Cliente
		aAdd(aCab, {"F2_LOJA"			, SE2->E2_LOJA		,Nil}) //Tienda Cliente
		aAdd(aCab, {"F2_SERIE"			, SE2->E2_PREFIXO	,Nil}) //Serie del documento
		aAdd(aCab, {"F2_DOC"			, SE2->E2_NUM		,Nil}) //Número de documento		
		aAdd(aCab, {"F2_TIPO"			, "D"				,Nil}) //Tipo da nota (C=Credito / D=Debito)
		aAdd(aCab, {"F2_NATUREZ"		, ""				,Nil}) //Naturaleza (Financiero)
		aAdd(aCab, {"F2_ESPECIE"		, SE2->E2_TIPO		,Nil}) //Tipo de Documento para la tabla SF2 (RTS = Remito de Transferencia Salida)
		aAdd(aCab, {"F2_EMISSAO"		, dDatabase			,Nil}) //Fecha de Emisión
		aAdd(aCab, {"F2_DTDIGIT"		, dDatabase			,Nil}) //Fecha de Digitación	
		aAdd(aCab, {"F2_MOEDA"			, 1					,Nil}) //Moneda
		aAdd(aCab, {"F2_TXMOEDA"		, 1					,Nil}) //Tasa de moneda						
		aAdd(aCab, {"F2_TIPODOC"		, "07"				,Nil}) //Tipo de documento (utilizado en la función LOCXNF)								
		aAdd(aCab, {"F2_FORMUL"			, "N" 				,Nil}) //Indica si se utiliza un Formulario Propio para el documento
		aAdd(aCab, {"F2_COND"			, ""				,Nil}) //Condición de pago						
		If cPaisloc == "ARG" 
			DbSelectArea("SX3")
			SX3->(dbSetOrder(2))
			SX3->(DbSeek("F2_TPVENT"))
			If   at ("12",SX3->X3_VALID) > 0
		 		aAdd(aCab, {"F2_TPVENT"			, "2"			 ,Nil}) //Tipo de venda
		 	Else
		 		aAdd(aCab, {"F2_TPVENT"			, "S"			 ,Nil}) //Tipo de venda
		 	EndIf  
			aAdd(aCab, {"F2_FECDSE"			, dDataTit			 ,Nil}) //Tipo de venda
			aAdd(aCab, {"F2_FECHSE"			, dDatabase			 ,Nil}) //Tipo de venda

		EndIf

		If cPaisloc == "ARG" 
			aAdd(aCab, {"F2_PROVENT"			,cProvent			 ,Nil})//	
		EndIf

		// Item 1
		aAdd(aItem, {"D2_COD"			, cCodProd				,Nil}) //Código de producto
		aAdd(aItem, {"D2_UM"			, cUndMed				,Nil}) //Unidad de medida						
		aAdd(aItem, {"D2_QUANT"			, 1						,Nil}) //Cantidad
		aAdd(aItem, {"D2_PRCVEN"		, nTotDif*nSigno,Nil}) //Precio de Venta		
		aAdd(aItem, {"D2_TOTAL"			, nTotDif*nSigno,Nil}) //Total				
		aAdd(aItem, {"D2_TES"			, cTES					,Nil}) //TES						
		aAdd(aItem, {"D2_CF"			, cCf					,Nil})//Código Fiscal (completar según TES)
		aAdd(aItem, {"D2_LOCAL"			, cDep					,Nil}) //Depósito		
		aAdd(aLinea, aItem)
		aItem:={}  
		msExecAuto({|w,x,y,z| LocXNF(w,x,y,z)}, cTipo, aCab, aLinea, 3)			 
		If lMsErroAuto
			lRet := .F.
			MostraErro()
			DisarmTransaction()
		EndIf
	ElseIf SE2->E2_TIPO $ "NDP"  .And. lGera

		// Documento Fiscal 
		aAdd(aCab, {"F1_FORNECE"		, SE2->E2_FORNECE,Nil}) //Código Cliente
		aAdd(aCab, {"F1_LOJA"			, SE2->E2_LOJA   ,Nil}) //Tienda Cliente
		aAdd(aCab, {"F1_SERIE"			, SE2->E2_PREFIXO   		,Nil}) //Serie del documento
		aAdd(aCab, {"F1_DOC"			, SE2->E2_NUM   ,Nil}) //Número de documento		
		aAdd(aCab, {"F1_TIPO"			, "C"		     ,Nil}) //Tipo da nota (C=Credito / D=Debito)
		aAdd(aCab, {"F1_NATUREZ"		, ""		     ,Nil}) //Naturaleza (Financiero)
		aAdd(aCab, {"F1_ESPECIE"		, SE2->E2_TIPO   ,Nil}) //Tipo de Documento 
		aAdd(aCab, {"F1_EMISSAO"		, dDatabase		 ,Nil}) //Fecha de Emisión
		aAdd(aCab, {"F1_DTDIGIT"		, dDatabase		 ,Nil}) //Fecha de Digitación	
		aAdd(aCab, {"F1_MOEDA"			, 1				 ,Nil}) //Moneda
		aAdd(aCab, {"F1_TXMOEDA"		, 1				 ,Nil}) //Tasa de moneda						
		aAdd(aCab, {"F1_TIPODOC"		, "09"			 ,Nil}) //Tipo de documento (utilizado en la función LOCXNF)								
		aAdd(aCab, {"F1_FORMUL"			, "N", 			 ,Nil}) //Indica si se utiliza un Formulario Propio para el documento
		aAdd(aCab, {"F1_COND"			, ""			 ,Nil}) //Condición de pago	  
		If cPaisloc == "ARG" 
			aAdd(aCab, {"F1_TPVENT"			, "S"			 ,Nil}) //Tipo de venda     
			aAdd(aCab, {"F1_FECDSE"			, dDataTit			 ,Nil}) //Tipo de venda
			aAdd(aCab, {"F1_FECHSE"			, dDatabase			 ,Nil}) //Tipo de venda

		EndIf

		If cPaisloc == "ARG" 
			aAdd(aCab, {"F1_PROVENT"			,cProvent			 ,Nil})//	
		EndIf

		// Item 1

		aAdd(aItem, {"D1_COD"			, cCodProd				,Nil}) //Código de producto
		aAdd(aItem, {"D1_UM"			, cUndMed				,Nil}) //Unidad de medida						
		aAdd(aItem, {"D1_QUANT"			, 1						,Nil}) //Cantidad
		aAdd(aItem, {"D1_VUNIT"			, nTotDif*nSigno,Nil}) //Precio de Venta		
		aAdd(aItem, {"D1_TOTAL"			, nTotDif*nSigno,Nil}) //Total				
		aAdd(aItem, {"D1_TES"			, cTES					,Nil}) //TES						
		aAdd(aItem, {"D1_CF"			, cCf					,Nil}) //Código Fiscal (completar según TES)
		aAdd(aItem, {"D1_LOCAL"			, cDep					,Nil}) //Depósito		
		aAdd(aLinea, aItem)
		aItem:={} 
		msExecAuto({|w,x,y,z| LocXNF(w,x,y,z)}, cTipo, aCab, aLinea, 3)			 
		If lMsErroAuto
			lRet := .F.
			MostraErro()
			DisarmTransaction()
		EndIf

	EndIf 



Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F084CancelNFºAutor  ³Ana Paula Nascimentoº Data ³  18.03.10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera documento fiscal no cancelamento da					  º±±
±±º			 ³diferença de cambios geradas     							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA084 e FINA085A                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F084CancelNF(cAlias)

	Local aCab 			:= {} 	//Dados do cabeçalho
	Local aItem 		:= {} 	//Dados do item
	Local aLinea 		:= {} 	//Matriz que guarda la matriz aItem (requerido por la rutina)
	Local nSigno  :=      Iif(SE2->E2_TIPO $MV_CPNEG+"/"+MVPAGANT,-1,1)
	Local cTipo:=  Iif(SE2->E2_TIPO == "NDP",07,09) // Grava a reversão         
	Local cTipoDoc := SE2->E2_TIPO   
	Local cSerie := SE2->E2_PREFIXO
	Local aArea:=GetArea()
	Local lGera := .T.    
	Local lRet  := .T.          
	Local cNum:=""
	Private lMsErroAuto:= .F.


	DbSelectArea("SF4")
	dbSetOrder(1)
	If SE2->E2_TIPO $ "NDP" .And. !Empty(SA2->A2_TESC)
		DbSeek(xFilial('SF4')+SA2->A2_TESC)
		cTES:= SA2->A2_TESC
		cCf:= SF4->F4_CF

	Elseif SE2->E2_TIPO $ "NCP" .And. !Empty(SA2->A2_TESD)
		DbSeek(xFilial('SF4')+SA2->A2_TESD)
		cCf:= SF4->F4_CF    
		cTES:= SA2->A2_TESD
	Else
		Help('',1,'FA084014')
		lGera := .F.  // Se nao tiver TES configurada no fornecedor não deverá ser gerado doc fiscal
		DisarmTransaction()
	EndIf 

	If lGera
		// Validações da TES
		// Só será gerado documento fiscal se a TES cadastradaa estiver configurada para essa finalidade
		// e nao seja configurada para geração de duplicadas, pois a duplicata sera gerada no
		// financeiro pela rotina de diferença de cambio padrão.
		If SF4->F4_DOCDIF <>"1" .And. SF4->F4_DUPLIC == "N"
			lGera:= .F.
		ElseIf SF4->F4_DOCDIF =="1" .And. SF4->F4_DUPLIC == "N"
			lGera:=.T.
		ElseIf SF4->F4_DOCDIF <>"1" .And. SF4->F4_DUPLIC == "S"
			lGera:=.F.
		ElseIf SF4->F4_DOCDIF =="1" .And. SF4->F4_DUPLIC == "S"
			lGera:=.F.
		EndIf   


		If cAlias == "SF1"
			DbSelectArea("SD1")
			dbSetOrder(1)
			DbSeek(xFilial("SD1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA)
			cCodProd:= SD1->D1_COD
			cUndMed:=SD1->D1_UM
			cDep :=SD1->D1_LOCAL
		Else
			DbSelectArea("SD2")
			dbSetOrder(3)
			DbSeek(xFilial("SD2")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA)
			cCodProd:= SD2->D2_COD
			cUndMed:=SD2->D2_UM                 
			cDep :=SD2->D2_LOCAL
		EndIf

		cTipoDoc:=Iif(SE2->E2_TIPO$"NCP","NDP","NCP" )
		F84ValidNum(cSerie,@cNum,cTipoDoc,.T.,SE2->E2_FORNECE+SE2->E2_LOJA)

	EndIf	
	// Caso esteja cancelando debito será gerado um credito e vice versa. Nota de Reversão.        
	If Alltrim(SE2->E2_TIPO) $ "NDP" .And. lGera
		aAdd(aCab, {"F2_CLIENTE"		, SE2->E2_FORNECE	,Nil}) //Código Cliente
		aAdd(aCab, {"F2_LOJA"			, SE2->E2_LOJA		,Nil}) //Tienda Cliente
		aAdd(aCab, {"F2_SERIE"			, cSerie			,Nil}) //Serie del documento
		aAdd(aCab, {"F2_DOC"			, cNum	  		,Nil}) //Número de documento		
		aAdd(aCab, {"F2_TIPO"			, "C"				,Nil}) //Tipo da nota (C=Credito / D=Debito)
		aAdd(aCab, {"F2_NATUREZ"		, ""				,Nil}) //Naturaleza (Financiero)
		aAdd(aCab, {"F2_ESPECIE"		, "NCP"	  			,Nil}) //Tipo de Documento para la tabla SF2 (RTS = Remito de Transferencia Salida)
		aAdd(aCab, {"F2_EMISSAO"		, dDatabase			,Nil}) //Fecha de Emisión
		aAdd(aCab, {"F2_DTDIGIT"		, dDatabase			,Nil}) //Fecha de Digitación	
		aAdd(aCab, {"F2_MOEDA"			, 1					,Nil}) //Moneda
		aAdd(aCab, {"F2_TXMOEDA"		, 1					,Nil}) //Tasa de moneda						
		aAdd(aCab, {"F2_TIPODOC"		, "07"				,Nil}) //Tipo de documento (utilizado en la función LOCXNF)								
		aAdd(aCab, {"F2_FORMUL"			, "S" 				,Nil}) //Indica si se utiliza un Formulario Propio para el documento
		aAdd(aCab, {"F2_COND"			, ""				,Nil}) //Condición de pago						
		If cPaisloc == "ARG" 
			DbSelectArea("SX3")
			SX3->(dbSetOrder(2))
			SX3->(DbSeek("F2_TPVENT"))
			If   at ("12",SX3->X3_VALID) > 0
		 		aAdd(aCab, {"F2_TPVENT"			, "2"			 ,Nil}) //Tipo de venda
		 	Else
		 		aAdd(aCab, {"F2_TPVENT"			, "S"			 ,Nil}) //Tipo de venda
		 	EndIf 
			aAdd(aCab, {"F2_FECDSE"			, SE2->E2_EMISSAO			 ,Nil}) //Tipo de venda
			aAdd(aCab, {"F2_FECHSE"			, dDatabase			 ,Nil}) //Tipo de venda

		EndIf

		If cPaisloc == "ARG" 
			aAdd(aCab, {"F2_PROVENT"			,SF1->F1_PROVENT			 ,Nil})//	
		EndIf

		// Item 1
		aAdd(aItem, {"D2_COD"			, cCodProd				,Nil}) //Código de producto
		aAdd(aItem, {"D2_UM"			, cUndMed				,Nil}) //Unidad de medida						
		aAdd(aItem, {"D2_QUANT"			, 1						,Nil}) //Cantidad
		aAdd(aItem, {"D2_PRCVEN"		, SE2->E2_VALOR			,Nil}) //Precio de Venta		
		aAdd(aItem, {"D2_TOTAL"			, SE2->E2_VALOR			,Nil}) //Total				
		aAdd(aItem, {"D2_TES"			, cTES					,Nil}) //TES						
		aAdd(aItem, {"D2_CF"			, cCf					,Nil})//Código Fiscal (completar según TES)
		aAdd(aItem, {"D2_LOCAL"			, cDep					,Nil}) //Depósito		
		aAdd(aLinea, aItem)
		aItem:={}  
		msExecAuto({|w,x,y,z| LocXNF(w,x,y,z)}, cTipo, aCab, aLinea, 3)			 
		If lMsErroAuto
			lRet := .F.
			MostraErro()
			DisarmTransaction()
		EndIf
	ElseIf Alltrim(SE2->E2_TIPO) $ "NCP" .And. lGera

		// Documento Fiscal 
		aAdd(aCab, {"F1_FORNECE"		, SE2->E2_FORNECE,Nil}) //Código Cliente
		aAdd(aCab, {"F1_LOJA"			, SE2->E2_LOJA   ,Nil}) //Tienda Cliente
		aAdd(aCab, {"F1_SERIE"			, cSerie,Nil}) //Serie del documento
		aAdd(aCab, {"F1_DOC"			, cNum   		 ,Nil}) //Número de documento		
		aAdd(aCab, {"F1_TIPO"			, "D"		     ,Nil}) //Tipo da nota (C=Credito / D=Debito)
		aAdd(aCab, {"F1_NATUREZ"		, ""		     ,Nil}) //Naturaleza (Financiero)
		aAdd(aCab, {"F1_ESPECIE"		, "NDP"   		 ,Nil}) //Tipo de Documento 
		aAdd(aCab, {"F1_EMISSAO"		, dDatabase		 ,Nil}) //Fecha de Emisión
		aAdd(aCab, {"F1_DTDIGIT"		, dDatabase		 ,Nil}) //Fecha de Digitación	
		aAdd(aCab, {"F1_MOEDA"			, 1				 ,Nil}) //Moneda
		aAdd(aCab, {"F1_TXMOEDA"		, 1				 ,Nil}) //Tasa de moneda						
		aAdd(aCab, {"F1_TIPODOC"		, "09"			 ,Nil}) //Tipo de documento (utilizado en la función LOCXNF)								
		aAdd(aCab, {"F1_FORMUL"			, "S", 			 ,Nil}) //Indica si se utiliza un Formulario Propio para el documento
		aAdd(aCab, {"F1_COND"			, ""			 ,Nil}) //Condición de pago						
		If cPaisloc == "ARG" 
			aAdd(aCab, {"F1_TPVENT"			, "S"			 ,Nil}) //Tipo de venda
			aAdd(aCab, {"F1_FECDSE"			, SE2->E2_EMISSAO,Nil}) //Tipo de venda
			aAdd(aCab, {"F1_FECHSE"			, dDatabase		 ,Nil}) //Tipo de venda

		EndIf
		If cPaisloc == "ARG" 
			aAdd(aCab, {"F1_PROVENT"			,SF2->F2_PROVENT			 ,Nil})//	
		EndIf			

		// Item 1

		aAdd(aItem, {"D1_COD"			, cCodProd				,Nil}) //Código de producto
		aAdd(aItem, {"D1_UM"			, cUndMed				,Nil}) //Unidad de medida						
		aAdd(aItem, {"D1_QUANT"			, 1						,Nil}) //Cantidad
		aAdd(aItem, {"D1_VUNIT"			, SE2->E2_VALOR			,Nil}) //Precio de Venta		
		aAdd(aItem, {"D1_TOTAL"			, SE2->E2_VALOR			,Nil}) //Total				
		aAdd(aItem, {"D1_TES"			, cTES					,Nil}) //TES						
		aAdd(aItem, {"D1_CF"			, cCf					,Nil}) //Código Fiscal (completar según TES)
		aAdd(aItem, {"D1_LOCAL"			, cDep					,Nil}) //Depósito		
		aAdd(aLinea, aItem)
		aItem:={} 
		msExecAuto({|w,x,y,z| LocXNF(w,x,y,z)}, cTipo, aCab, aLinea, 3)			 
		If lMsErroAuto
			lRet := .F.
			MostraErro()
			DisarmTransaction()
		EndIf

	EndIf 

	RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F84ValidNumºAutor  ³Ana Paula Nascimentoº Data ³  01.06.11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida numeração											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA074 												      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F84ValidNum(cPrefixo,cNum,cTipoDoc,lCancel,cForLoja)
	Local lRet := .T.
	Local cAlias:=Iif(cTipoDoc$"NCP","SF2","SF1" )     
	Local aAreaSE2 := SE2->(GetArea())	

	If lCancel
		DbSelectArea('SX5')
		DbSetOrder(1)
		If SX5->(DbSeek(xFilial("SX5")+"01"+cPrefixo)) 
			cNum:=	Substr( X5Descri(), 1, TamSX3('E2_NUM')[1] )
		EndIf	
	EndIf

	// Verifica se ja existe algum documento com a mesma numeração no contas a receber
	DbSelectArea("SE2")
	DbSetOrder( 1 )
	While SE2->(!Eof()) .And. lRet
		If  DbSeek( xFilial("SE2")+cPrefixo+cNum+Space(TamSX3('E2_PARCELA')[1])+cTipoDoc)
			RecLock("SX5",.F.)
			Replace X5_DESCRI  With Soma1(cNum)
			Replace X5_DESCENG With Soma1(cNum)
			Replace X5_DESCSPA With Soma1(cNum)
			SX5->(MsUnlock()) 
			cNum := Substr(X5Descri(),1,TamSX3('E2_NUM')[1]) 
		Else
			lRet := .F.
		EndIf		                                                 
		SE2->(DbSkip())
	EndDo


	lRet:=.T.
	// Verifica se ja existe documentos com a mesma numeração na SF1 ou SF2
	DbSelectArea(cAlias)  
	(cAlias)->(DbGoTop())
	DbSetOrder(1)
	While (cAlias)->(!Eof()) .And. lRet
		If  (cAlias)->(DbSeek( xFilial(cAlias)+cNum+cPrefixo+cForLoja))
			RecLock("SX5",.F.)
			Replace X5_DESCRI  With Soma1(cNum)
			Replace X5_DESCENG With Soma1(cNum)
			Replace X5_DESCSPA With Soma1(cNum)
			SX5->(MsUnlock()) 
			cNum := Substr(X5Descri(),1,TamSX3('E2_NUM')[1]) 
		Else
			lRet := .F.
		EndIf		                                                 
		(cAlias)->(DbSkip())
	EndDo 

	RestArea(aAreaSE2)

Return cNum


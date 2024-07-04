#INCLUDE "FISRISRV.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
                                                                               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FISRISRV  ³ Autor ³ Alberto Rodriguez     ³ Data ³20/06/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Comprobante de retenciones varias del ISR				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISRISRV()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Venezuela			 									  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Function FISRISRV()

Private cPerg   := "FISRISRV"
Private oReport := Nil

/**********************
//Parametros FISRISRV
//******************** 
//MV_PAR01 - Fecha Inicial
//MV_PAR02 - Fecha Final
//MV_PAR03 - Proveedor Inicial
//MV_PAR04 - Proveedor Final
//********************/ 

If TRepInUse()
	If Pergunte(cPerg,.T.)
		oReport:=ReportDef()
		oReport:PrintDialog()
	EndIf
Else
	MsgAlert(OemToAnsi(STR0002), OemToAnsi(STR0001)) //"Para utilizar este relatório configure o parâmetro MV_TREPORT"
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef  ³ Autor ³Alberto Rodriguez      ³ Data ³ 20/06/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatorio                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oSecao1, oSecao2
Local cReport	:= "FISRISRV"
Local cPerg    	:= "FISRISRV"
Local cTitulo	:= OemToAnsi(STR0001) //"Comprobante de retenciones varias del Impuesto Sobre la Renta"	
Local cDesc		:= OemToAnsi(STR0003) //"Este programa tiene como objetivo imprimir el resumen de retenciones ISR"
Local cString	:= ""

oReport := TReport():New(cReport,cTitulo,cPerg,{|oReport| ReportPrint(oReport)},cDesc)
oReport:SetPortrait()					// Formato Vertical SetLandscape()  
oReport:DisableOrientation()			// Não permite mudar o formato de impressão para Landscape, somente Vertical
oReport:SetTotalInLine(.F.)
oReport:PageTotalInLine(.F.)
oReport:oPage:nPaperSize	:= 1  		// Impressão em papel A4 - LandScape 9=a4,1=Carta,5=Oficio,8=A3
oReport:lHeaderVisible		:= .F.		// Não imprime cabeçalho do protheus
oReport:lFooterVisible 		:= .F.		// Não imprime rodapé do protheus
oReport:lParamPage			:= .F.		// Não imprime pagina de parametros
oReport:SetEdit(.F.)					// Não permite personilizar o relatório, desabilitando o botão <Personalizar>

Pergunte(oReport:uParam,.F.)

oSecao1:=TRSection():New(oReport,"Detalle",{"SFE","SA2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSecao1:SetPageBreak(.T.)

TRCell():New(oSecao1,"MES","",OemToAnsi(STR0015)/*"Mes"*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
cString := OemToAnsi(Strtran(STR0016,"#CRLF#",CRLF)) // DecodeUTF8(, "cp1252") 
TRCell():New(oSecao1,"PAGADO","",cString/*Total pagado*/,X3PICTURE("FE_VALBASE"),25/*TamSX3("FE_VALBASE")[1]*/,/*lPixel*/,/*{|| code-block de impressao }*/)
cString := OemToAnsi(Strtran(STR0017,"#CRLF#",CRLF))
TRCell():New(oSecao1,"BASE","",cString/*Base retención*/,X3PICTURE("FE_VALBASE"),25/*TamSX3("FE_VALBASE")[1]*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"RETENIDO","",OemToAnsi(STR0018)/*Impuesto retenido*/,X3PICTURE("FE_RETENC"),25/*TamSX3("FE_RETENC")[1]*/,/*lPixel*/,/*{|| code-block de impressao }*/)
cString := OemToAnsi(Strtran(STR0019,"#CRLF#",CRLF))
TRCell():New(oSecao1,"BASEACUM","",cString/*Base acumulada*/,X3PICTURE("FE_VALBASE"),25/*TamSX3("FE_VALBASE")[1]*/,/*lPixel*/,/*{|| code-block de impressao }*/)
cString := OemToAnsi(Strtran(STR0020,"#CRLF#",CRLF))
TRCell():New(oSecao1,"RETACUM","",cString/*Retención acumulada*/,X3PICTURE("FE_RETENC"),25/*TamSX3("FE_RETENC")[1]*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSecao1:Cell("PAGADO"):SetHeaderAlign("RIGHT")
oSecao1:Cell("BASE"):SetHeaderAlign("RIGHT")
oSecao1:Cell("RETENIDO"):SetHeaderAlign("RIGHT")
oSecao1:Cell("BASEACUM"):SetHeaderAlign("RIGHT") 
oSecao1:Cell("RETACUM"):SetHeaderAlign("RIGHT") 

oSecao2:=TRSection():New(oReport,"Total",{"SFE","SA2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSecao2,"MES","","",/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"PAGADO","","",X3PICTURE("FE_VALBASE"),25/*TamSX3("FE_VALBASE")[1]*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"BASE","","",X3PICTURE("FE_VALBASE"),25/*TamSX3("FE_VALBASE")[1]*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"RETENIDO","","",X3PICTURE("FE_RETENC"),25/*TamSX3("FE_RETENC")[1]*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"BASEACUM","","","@!",25/*TamSX3("FE_VALBASE")[1]*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"RETACUM","","","@!",25/*TamSX3("FE_RETENC")[1]*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSecao2:Cell("PAGADO"):SetHeaderAlign("RIGHT")
oSecao2:Cell("BASE"):SetHeaderAlign("RIGHT")
oSecao2:Cell("RETENIDO"):SetHeaderAlign("RIGHT") 

oSecao3:=TRSection():New(oReport,OemToAnsi(Upper(STR0001)),{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSecao3:SetPageBreak(.F.)
oSecao3:SetHeaderSection(.F.)

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Alberto Rodriguez      ³ Data ³ 20/06/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                            ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local oRegistro		:= oReport:Section(1)
Local oTotal		:= oReport:Section(2)
Local oCabec		:= oReport:Section(3)
Local cAliasSFE		:= "SFE"
Local nLastRec		:= 0

Local cTitulo		:= OemToAnsi(STR0004) //"COMPROBANTE DE RETENCIONES VARIAS DEL"
Local cSubTitulo	:= OemToAnsi(STR0005) //"IMPUESTO SOBRE LA RENTA"
Local cNomeEmp		:= Alltrim(SM0->M0_NOME)
Local cRIFEmp		:= Alltrim(SM0->M0_CGC)
Local cTipoAgente	:= OemToAnsi(STR0024)
Local cTelEmp		:= Alltrim(SM0->M0_TEL)
Local cDirEmp		:= Alltrim(SM0->M0_ENDENT)+Alltrim(SM0->M0_COMPENT)+", "+Alltrim(SM0->M0_BAIRENT)
Local cLocEmp		:= Alltrim(SM0->M0_CIDENT)
Local cPeriod		:= OemToAnsi(STR0025) + " " + dtoc(MV_PAR01) + " " + OemToAnsi(STR0026) + " " + dtoc(MV_PAR02)
Local cNomeBenef	:= ""
Local cRIFBenef		:= ""
Local cTipoBenef	:= ""
Local cDirBenef		:= ""
Local cLocBenef		:= ""
Local cTelBenef		:= ""
Local aTipoPersona	:= {}
Local aTotales		:= {}
Local cMes			:= ""
Local nPagado		:= 0
Local nBase			:= 0
Local nRetenido		:= 0
Local nBaseAcum		:= 0
Local nRetAcum		:= 0
Local nTotPagado	:= 0
Local nTotBase		:= 0
Local nTotRetenido	:= 0
Local nRow			:= 0
Local nX			:= 0

Private oFont1 := TFont():New("Verdana",,10,,.F.,,,,,.F.)
Private oFont2 := TFont():New("Verdana",,10,,.T.,,,,,.T.)
Private oFont3 := TFont():New("Verdana",,15,,.F.,,,,,.F.)

//Carrega tipos de persoa do campo combo pelo X3_CBOX
dbSelectArea("SX3")
SX3->(dbSetOrder(2))
If SX3->(dbSeek("A2_TIPO"))
	aTipoPersona := StrToKarr( X3CBox(), ";" )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 1 - Detalhe                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oRegistro:Cell("MES"):SetBlock({|| PadR(cMes,15)})
oRegistro:Cell("PAGADO"):SetBlock({|| nPagado})
oRegistro:Cell("BASE"):SetBlock({|| nBase})
oRegistro:Cell("RETENIDO"):SetBlock({|| nRetenido})
oRegistro:Cell("BASEACUM"):SetBlock({|| nBaseAcum})
oRegistro:Cell("RETACUM"):SetBlock({|| nRetAcum})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 2 - Totalizador                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oTotal:Cell("MES"):SetBlock({|| PadR(cMes,15)})
oTotal:Cell("PAGADO"):SetBlock({|| nTotPagado})
oTotal:Cell("BASE"):SetBlock({|| nTotBase})
oTotal:Cell("RETENIDO"):SetBlock({|| nTotRetenido})
oTotal:Cell("BASEACUM"):SetBlock({|| ""})
oTotal:Cell("RETACUM"):SetBlock({|| ""})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Altera o titulo para impressao                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetTitle(OemToAnsi(STR0003)) // "Comprobante de retenciones varias del Impuesto Sobre la Renta"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatorio                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SFE")
dbSetOrder(3) // FE_FILIAL+FE_FORNECE+FE_LOJA+DTOS(FE_EMISSAO)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query do relatório da secao 1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):BeginQuery()	
cAliasSFE := GetNextAlias()

BeginSql Alias cAliasSFE

	SELECT 
		SFE.FE_FORNECE
		,SFE.FE_LOJA
		,SFE.FE_EMISSAO
		,SFE.FE_TIPO
		,SFE.FE_ESPECIE
		,SFE.FE_RETENC
		,SFE.FE_VALBASE
	
	FROM %table:SFE% SFE
	
	WHERE
		SFE.FE_FILIAL = %Exp:xFilial("SFE")% AND 
		SFE.FE_EMISSAO >= %Exp:mv_par01% AND 
		SFE.FE_EMISSAO <= %Exp:mv_par02% AND 
		SFE.FE_FORNECE >= %Exp:mv_par03% AND 
		SFE.FE_FORNECE <= %Exp:mv_par04% AND 
		SFE.FE_TIPO = 'R' AND
		SFE.FE_NROCERT <> ' ' AND
		SFE.%NotDel% 
		
	ORDER BY %Order:SFE%
	
EndSql 

oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea((cAliasSFE))
(cAliasSFE)->(dbGoTop())
nLastRec := (cAliasSFE)->(LastRec())
oReport:SetMeter(nLastRec)

If (cAliasSFE)->(EOF())
	oReport:Say(300,350,OemToAnsi(STR0027))//"Sin movimiento."

Else
	While (cAliasSFE)->(!EOF())
		cProv := (cAliasSFE)->FE_FORNECE
		cLoja := (cAliasSFE)->FE_LOJA
		aSize( aTotales, 0 )

		For nX := 1 to 12
			aAdd( aTotales , { 0, 0, 0, 0, 0 } )
		Next nX

		While (cAliasSFE)->(!EOF()) .And. (cAliasSFE)->(FE_FORNECE+FE_LOJA) == cProv+cLoja
			oRegistro:Init()
			oReport:IncMeter()

			nX := Month((cAliasSFE)->FE_EMISSAO)
		
			If Trim((cAliasSFE)->FE_ESPECIE) $ "NF|NDP|"
				aTotales[nX,1]	+= (cAliasSFE)->(FE_VALBASE+FE_RETENC)
				aTotales[nX,2]	+= (cAliasSFE)->FE_VALBASE
				aTotales[nX,3]	+= (cAliasSFE)->FE_RETENC
				nTotPagado		+= (cAliasSFE)->(FE_VALBASE+FE_RETENC)
				nTotBase		+= (cAliasSFE)->FE_VALBASE
				nTotRetenido	+= (cAliasSFE)->FE_RETENC
			Else // NCP
				aTotales[nX,1]	-= (cAliasSFE)->(FE_VALBASE+FE_RETENC)
				aTotales[nX,2]	-= (cAliasSFE)->FE_VALBASE
				aTotales[nX,3]	-= (cAliasSFE)->FE_RETENC
				nTotPagado		-= (cAliasSFE)->(FE_VALBASE+FE_RETENC)
				nTotBase		-= (cAliasSFE)->FE_VALBASE
				nTotRetenido	-= (cAliasSFE)->FE_RETENC
			Endif

			(cAliasSFE)->(dbSkip())
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca dados do Fornecedor da Retencao no SA2³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		SA2->( dbSetOrder(1) )
		If SA2->( dbSeek( xFilial("SA2")+cProv+cLoja ) )
			cNomeBenef	:= SA2->A2_NOME
			cRIFBenef	:= SA2->A2_CGC
			nX := aScan( aTipoPersona , {|x| SA2->A2_TIPO==Substr(x,1,1) } ) // "x - persona xxx yyy"
			If nX > 0
				cTipoBenef	:= Upper( Alltrim( Substr(aTipoPersona[nX],3) ))
				cTipoBenef	:= Strtran( cTipoBenef , "PERSONA ")
			Else 
				cTipoBenef	:= ""
			Endif 
			cDirBenef	:= SA2->( Alltrim(A2_END)+", "+Alltrim(A2_BAIRRO))
			cLocBenef	:= AllTrim(SA2->A2_MUN)
			SX5->( dbSeek(xFilial("SX5")+"12"+SA2->A2_EST) )
			If SX5->( Found() )
				cLocBenef	+= If(!Empty(cLocBenef),", ","") + AllTrim(X5Descri())
			Endif
			cTelBenef	:= Alltrim(SA2->A2_TEL)
		Else
			cNomeBenef	:= ""
			cRIFBenef	:= ""
			cTipoBenef	:= ""
			cDirBenef	:= ""
			cLocBenef	:= ""
			cTelBenef	:= ""
		Endif
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Secao 3 - Cabecalho      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:StartPage()
		oCabec:Init()
		oReport:Say(0100,650,cTitulo,oFont3)
		oReport:Say(0150,775,cSubTitulo,oFont3)
		oReport:Say(0310,050,OemToAnsi(STR0006),oFont2)
		oReport:Say(0360,050,OemToAnsi(STR0007)) // DecodeUTF8(STR0007, "cp1252")
		oReport:Say(0360,450,": " + cNomeEmp)
		oReport:Say(0400,050,OemToAnsi(STR0008))
		oReport:Say(0400,450,": " + cRIFEmp)
		oReport:Say(0440,050,OemToAnsi(STR0009))
		oReport:Say(0440,450,": " + cTipoAgente)
		oReport:Say(0480,050,OemToAnsi(STR0010))
		oReport:Say(0480,450,": " + cTelEmp)
		oReport:Say(0520,050,OemToAnsi(STR0011))
		oReport:Say(0520,450,": " + cDirEmp)
		oReport:Say(0560,450,"  " + cLocEmp)
	
		oReport:Say(0650,050,OemToAnsi(STR0012),oFont2)
		oReport:Say(0700,050,OemToAnsi(STR0007))
		oReport:Say(0700,450,": " + cNomeBenef)
		oReport:Say(0740,050,OemToAnsi(STR0008))
		oReport:Say(0740,450,": " + cRIFBenef)
		oReport:Say(0780,050,OemToAnsi(STR0013))
		oReport:Say(0780,450,": " + cTipoBenef)
		oReport:Say(0820,050,OemToAnsi(STR0011))
		oReport:Say(0820,450,": " + cDirBenef)
		oReport:Say(0860,450,"  " + cLocBenef)
		oReport:Say(0900,050,OemToAnsi(STR0010))
		oReport:Say(0900,450,": " + cTelBenef)
		oReport:Say(0940,050,OemToAnsi(STR0014))
		oReport:Say(0940,450,": " + cPeriod)
		oReport:SkipLine(40)
		oCabec:Finish()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime a variável no objeto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	
		oRegistro:Init()
	    nBaseAcum := 0
	    nRetAcum := 0
	    
	    For nX := 1 to 12
			cMes			:= MesExtenso(nX)
			nPagado			:= aTotales[nX,1]
			nBase			:= aTotales[nX,2]
			nRetenido		:= aTotales[nX,3]
			nBaseAcum		+= aTotales[nX,2]
			nRetAcum		+= aTotales[nX,3]

			oRegistro:Cell("MES"):Show()
			oRegistro:Cell("PAGADO"):Show()
			oRegistro:Cell("BASE"):Show()
			oRegistro:Cell("RETENIDO"):Show()
			oRegistro:Cell("BASEACUM"):Show()
			oRegistro:Cell("RETACUM"):Show()
			oRegistro:PrintLine()   	 
		Next nX
		
		oRegistro:Finish()
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime variável de totais2³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	
		oTotal:Init()
		oTotal:Cell("MES"):SetValue(PadC(OemToAnsi(STR0021),15))	// "Totales..."
	
	   	oTotal:Cell("MES"):Show()
	   	oTotal:Cell("PAGADO"):Show()
		oTotal:Cell("BASE"):Show()
	 	oTotal:Cell("RETENIDO"):Show()
		oTotal:Cell("BASEACUM"):Show()
		oTotal:Cell("RETACUM"):Show()
	 	oTotal:PrintLine()

		oReport:SkipLine(20)
		nRow := oReport:Row()
		oReport:Say(nRow   ,0800,Replicate("_",40))
		oReport:Say(nRow+40,0860,OemToAnsi(STR0022))
		oReport:Say(nRow+80,0920,OemToAnsi(STR0023) + " " + cRIFEmp)

		oTotal:Finish() 
		oReport:EndPage()
	EndDo

EndIf	 

Return


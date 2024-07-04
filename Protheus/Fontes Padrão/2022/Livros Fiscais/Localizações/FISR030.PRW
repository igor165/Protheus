#INCLUDE "FISR030.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
                                                                               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FISR030   ³ Autor ³ Camila Januário       ³ Data ³12/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Livro de Honorários              	    			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISR030()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Chile				 									  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Function FISR030()

Private cPerg   := "FISR030"
Private oReport := Nil

/**********************
//Parametros FISR030
//******************** 
//MV_PAR01 - Data Inicial
//MV_PAR02 - Data Final
//MV_PAR03 - Imprime 
//MV_PAR04 - Número Pag. Inicial
//********************/ 
          
If TRepInUse()
	If Pergunte(cPerg,.T.)
		oReport:=ReportDef()
		oReport:lHeaderVisible := .F. // Não imprime cabeçalho do protheus
		oReport:lFooterVisible := .F. // Não imprime rodapé do protheus
		oReport:PrintDialog()
	EndIf	
Else
	MsgAlert(STR0002) //"Para utilizar este relatório configure o parâmetro MV_TREPORT"
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef  ³ Autor ³Camila Januário        ³ Data ³ 12.09.11 ³±±
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
Local cReport	:= "FISR030"
Local cPerg    	:= "FISR030"
Local cTitulo	:= OemToAnsi(STR0003)//"Livro de Honorarios"	
Local cDesc		:= OemToAnsi(STR0004) //"Este programa tem como objetivo imprimir o Livro de Honorários"
Local nTamBol     := SerieNfId('SFE',6,'FE_SERIE')+4+TamSx3("FE_NFISCAL")[1]

oReport := TReport():New(cReport,cTitulo,cPerg,{|oReport| ReportPrint(oReport)},cDesc)
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)
oReport:PageTotalInLine(.F.)
Pergunte(oReport:uParam,.F.)
oReport:lHeaderVisible := .F. 


oSecao1:=TRSection():New(oReport,OemToAnsi(STR0003),{"SFE","SA2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSecao1:SetPageBreak(.T.)

TRCell():New(oSecao1,"FE_EMISSAO","SFE",OemToAnsi(STR0005)/*"data"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"A2_CGC","SA2",OemToAnsi(STR0006)/*RUT*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"A2_NOME","SA2",OemToAnsi(STR0007)/*nome*/,/*Picture*/,,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"NROBOLETA","",OemToAnsi(STR0008)/*Nro. Boleta*/,/*Picture*/,nTamBol,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"HONORARIO","",OemToAnsi(STR0009)/*Honorario*/,X3PICTURE("FE_VALBASE"),TamSX3("FE_VALBASE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"FE_RETENC","SFE",OemToAnsi(STR0010)/*Retencao*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"FE_VALBASE","SFE",OemToAnsi(STR0011)/*Montante Neto*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
oSecao1:SetEdit(.F.)
oSecao1:SetLeftMargin(20)                               

oSecao1:Cell("HONORARIO"):SetHeaderAlign("RIGHT")
oSecao1:Cell("FE_RETENC"):SetHeaderAlign("RIGHT")
oSecao1:Cell("FE_VALBASE"):SetHeaderAlign("RIGHT") 


oSecao2:=TRSection():New(oReport,OemToAnsi(STR0003),{"SFE","SA2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSecao2:SetNoFilter("SFE")
oSecao2:SetEdit(.F.)

TRCell():New(oSecao2,"FE_EMISSAO","SFE","",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"A2_CGC","SA2","",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"A2_NOME","SA2","",/*Picture*/,,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"NROBOLETA","","",/*Picture*/,nTamBol,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oSecao2,"TOTHON","","",X3PICTURE("FE_VALBASE"),TamSX3("FE_VALBASE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"FE_RETENC","SFE","",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"FE_VALBASE","SFE","",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 

oSecao2:SetLeftMargin(20)

oSecao2:Cell("TOTHON"):SetHeaderAlign("RIGHT")
oSecao2:Cell("FE_RETENC"):SetHeaderAlign("RIGHT")
oSecao2:Cell("FE_VALBASE"):SetHeaderAlign("RIGHT")   

oSecao3:=TRSection():New(oReport,OemToAnsi(STR0003),{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSecao3:SetPageBreak(.F.)
oSecao3:SetHeaderSection(.T.)

oSecao3:SetLeftMargin(20)    

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Camila Januário        ³ Data ³ 12.09.11 ³±±
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

Local oRegistro     := oReport:Section(1)
Local oTotal     	:= oReport:Section(2)
Local oCabec		:= oReport:Section(3)
Local cCondicao		:= ""
Local cAliasSFE		:= "SFE"
Local cCabec		:= ""
Local nLinha		:= 0
Local nLastRec		:= 0
Local cRut			:= SM0->M0_CGC
Local nPag			:= MV_PAR04
Local cNomeEmp		:= Alltrim(SM0->M0_NOME)+SPACE(2)+Alltrim(SM0->M0_ENDENT)+" - "+Alltrim(SM0->M0_CIDENT)
Local cTitulo		:= STR0012 //"L I V R O  DE  H O N O R A R I O S"
Local cPeriod		:= MesExtenso(Substr(dtoc(MV_PAR01),4,2))+SPACE(4)+STR0013+SPACE(4)+Alltrim(Str(Year(MV_PAR01))) //de
Local cNroBol       := ""
Local nRetenc       := 0
Local nNeto         := 0
Local nHonor        := 0
Local nTotHon       := 0
Local nTotRet       := 0
Local nTotNeto      := 0
Local cCGC          := ""
Local cNome         := ""
Local NROBOLETA     := ""
Local HONORARIO     := 0  
Local lImpCab		:= IIF((MV_PAR03 == 1 .or. MV_PAR03 == 3),.T.,.F.)
Local lImpReg		:= IIF((MV_PAR03 == 1 .or. MV_PAR03 == 2),.T.,.F.)
Local nRow          := 0
Local cCpoSerie		:= ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 1 - Detalhe                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oRegistro:Cell("FE_EMISSAO"):SetBlock({|| dEmissao})
oRegistro:Cell("A2_CGC"):SetBlock({|| cCGC})
oRegistro:Cell("A2_NOME"):SetBlock({|| cNome})
oRegistro:Cell("NROBOLETA"):SetBlock({|| cNroBol})
oRegistro:Cell("HONORARIO"):SetBlock({|| nHonor})
oRegistro:Cell("FE_RETENC"):SetBlock({|| nRetenc})
oRegistro:Cell("FE_VALBASE"):SetBlock({|| nNeto})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 2 - Totalizador                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oTotal:Cell("TOTHON"):SetBlock({|| nTotHon})
oTotal:Cell("FE_RETENC"):SetBlock({|| nTotRet})
oTotal:Cell("FE_VALBASE"):SetBlock({|| nTotNeto})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Altera o titulo para impressao                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabec := OemToAnsi(STR0003)/*+" - "+OemToAnsi(STR0036)+DtoC(mv_par01)+OemToAnsi(STR0037)+Dtoc(mv_par02)*/  //livro de honorario
oReport:SetTitle(cCabec)
oReport:SetPageNumber(MV_PAR04)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 3 - Cabecalho      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lImpCab
	oCabec:Init()
	oReport:Say(100,350,cRut)
	oReport:Say(140,350,cNomeEmp)
	oReport:Say(100,2700,"PAG.: "+StrZero(nPag,6))
	oReport:Say(200,1300,cTitulo)
	oReport:Say(250,1380,cPeriod)
	oCabec:Finish()
Else
	oCabec:Init()
	oReport:Say(100,300,"")
	oReport:Say(140,300,"")
	oReport:Say(100,2600,"")
	oReport:Say(200,1300,"")
	oReport:Say(250,1380,"")
	oCabec:Finish()
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatorio                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SFE")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query do relatório da secao 1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):BeginQuery()	
cAliasSFE := GetNextAlias()
cCpoSerie	:= '% SFE.'+SerieNfId('SFE',3,'FE_SERIE')+' AS FE_SERIEX %'

BeginSql Alias cAliasSFE

	SELECT 
		SFE.FE_FORNECE
		,SFE.FE_LOJA
		,SFE.FE_EMISSAO
		,SFE.FE_SERIE
		,SFE.FE_NFISCAL 
		,SFE.FE_RETENC
		,SFE.FE_VALBASE
		,%Exp:cCpoSerie%
	
	FROM %table:SFE% SFE
	
	WHERE
		SFE.FE_FILIAL = %Exp:xFilial("SFE")% AND 
		SFE.FE_EMISSAO >= %Exp:mv_par01% AND 
		SFE.FE_EMISSAO <= %Exp:mv_par02% AND 
		SFE.FE_TIPO = 'H' AND
		SFE.FE_NROCERT = ' ' AND
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
oReport:SkipLine(9)

If (cAliasSFE)->(EOF())
	oReport:Say(300,350,STR0015)//"Sem movimento."
EndIf

If lImpReg .and. (cAliasSFE)->(!EOF())
	While (cAliasSFE)->(!EOF())
		oRegistro:Init()
		oReport:IncMeter()
		
        If (oReport:Row() >= (oReport:PageHeight() - 100))
			oReport:EndPage()
			oReport:StartPage()
	        If lImpCab
				oCabec:Init() 
				nPag++			
				oReport:Say(100,350,cRut)
				oReport:Say(140,350,cNomeEmp)
				oReport:Say(100,2700,"PAG.: "+StrZero(nPag,6))
				oReport:Say(200,1300,cTitulo)
				oReport:Say(250,1380,cPeriod)
				oCabec:Finish()
			Else
				oCabec:Init()
				oReport:Say(100,300,"")
				oReport:Say(140,300,"")
				oReport:Say(100,2600,"")
				oReport:Say(200,1300,"")
				oReport:Say(250,1380,"")
				oCabec:Finish()
			EndIf
			oReport:SkipLine(10)
	    EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca dados do Fornecedor da Retencao no SA2³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		SA2->( dbSetOrder(1) )
		If SA2->( dbSeek( xFilial("SA2")+(cAliasSFe)->FE_FORNECE+(cAliasSFE)->FE_LOJA))
			cNome := SA2->A2_NOME
			cCGC  := SA2->A2_CGC
		Else
			cNome := ""
			cCGC  := ""
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem dados para secao 1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		dEmissao := (cAliasSFE)->FE_EMISSAO
		cNroBol  := (cAliasSFE)->FE_SERIEX +SPACE(4)+(cAliasSFE)->FE_NFISCAL 
	    nRetenc  := (cAliasSFE)->FE_RETENC
	    nNeto    := (cAliasSFE)->FE_VALBASE
		nHonor   := nRetenc+nNeto
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime a variável no objeto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	
	    
		oRegistro:Cell("FE_EMISSAO"):Show()
		oRegistro:Cell("A2_CGC"):Show()
		oRegistro:Cell("A2_NOME"):Show()
		oRegistro:Cell("NROBOLETA"):Show()
		oRegistro:Cell("HONORARIO"):Show()
		oRegistro:Cell("FE_RETENC"):Show()
		oRegistro:Cell("FE_VALBASE"):Show()
		
		nRow := oReport:Row()
		
		oRegistro:PrintLine()   	 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem dados para secao 2³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		
		nTotHon += nHonor
		nTotRet += nRetenc
		nTotNeto += nNeto	
		
		(cAliasSFE)->(dbSkip())
	EndDo

	oRegistro:Finish()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime variável de totais2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	
	oTotal:Init()
    
 	oTotal:Cell("FE_EMISSAO"):Hide()
	oTotal:Cell("A2_CGC"):Hide()
	oTotal:Cell("A2_NOME"):Hide()
	oTotal:Cell("NROBOLETA"):SetValue(STR0014)//"Totais:"
	
   	oTotal:Cell("TOTHON"):Show()
	oTotal:Cell("FE_RETENC"):Show()
 	oTotal:Cell("FE_VALBASE"):Show()
	
	oTotal:PrintLine()
	oTotal:Finish() 
EndIf	 

Return

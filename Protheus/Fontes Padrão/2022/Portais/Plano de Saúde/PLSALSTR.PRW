#Include "PLSALSTR.ch"
#Include "Protheus.ch"
#Include "REPORT.CH"
#Include "TBICONN.CH"
#Include "TBICODE.CH"
#Include "TOPCONN.CH"
#Include "PLSMGER.CH"
#Include "RPTDEF.CH"  

#define COL1 0
#define COL2 45

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³PALSTRTP  ³Autor  ³ TOTVS             	          ³ Data ³13/10/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tipo do relatório a ser gerado									³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function PALSTRTP(cProtocolo)
Default cProtocolo := ""

PALSTRWeb(cProtocolo)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³PALSTRWeb  ³Autor  ³ Totvs		             ³ Data ³ 09/10/15    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de listagem de medicamentos para Web                    	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Function PALSTRWeb(cProtocolo,lWeb)
STATIC oRel			:= nil
LOCAL nPixLin		:= 40
LOCAL nLargLogo		:= 140
LOCAL nIniBox		:= 90
LOCAL nPixCol		:= 40
LOCAL nPixFin		:= 550
LOCAL nValTot		:= 0
LOCAL cRelName		:= "ListaMedicamentos"+CriaTrab(NIL,.F.)   
LOCAL lView			:= .t.
LOCAL nquantlin		:= 780		 
LOCAL aDados   		:= {}
LOCAL nCnt			:= 0
LOCAL cPathDest		:= PswRet()[2,3] 	 
LOCAL nI			:=0
LOCAL nAL			:= 0.25
LOCAL nAC			:= 0.24
LOCAL nLinIni		:= 0
LOCAL cDescPla		:= ""
Local cFilIni		:=	PadR("",FWGETTAMFILIAL)
Local cDirWeb		:= getWebDir() + getSkinPls() + "\relatorios\"
Local cMatric		:=	""
LOCAL cMsgEntga     := GETNEWPAR("MV_MSGREMB","")

DEFAULT cProtocolo 	:= ""
Default lWeb		:= .T.

If (lWeb)
	oRel := FWMSPrinter():New(cRelName,6,.F.,NIL,.T.,nil,@oRel,nil,nil,.F.,.F.)
Else		
	oRel := FWMsPrinter():New(cRelName,6,.F.,cDirWeb,.T.,,,,.F.,,,.F.)
EndIf	
oRel:cPathPDF := cDirWeb

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ POSICIONA NA REDE NAO REFERENCIADA
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
B4F->( dbSetOrder(1) )//Filial + protocolo
B4F->( msSeek(xFilial("B4F")+alltrim(cProtocolo)) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ POSICIONA NO BENEFICIARIO
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
BA1->(DbSetOrder(2))//Usuários
BA1->(MsSeek(xFilial("BA1")+B4F->B4F_MATRIC))
		
BA3->(DBSetOrder(1))
BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
	
dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cFilIni,.T.))

	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Instancia os objetos de fonte antes da pintura do relatorio    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oFont9  	:= TFont():New( "Arial",, 9,,.F.)
oFont10  	:= TFont():New( "Arial",, 10,,.F.)
oFont10N 	:= TFont():New( "Arial",, 10,,.T.)
oFont12  	:= TFont():New( "Arial",, 12,,.F.)
oFont12N 	:= TFont():New( "Arial",, 12,,.T.)
oFont14 	:= TFont():New( "Arial",, 14,,.F.)
oFont14N 	:= TFont():New( "Arial",, 14,,.T.)
oFont16 	:= TFont():New( "Arial",, 16,,.F.)
oFont16N 	:= TFont():New( "Arial",, 16,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Obj
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oRel:setResolution(72)
oRel:setPortrait()
oRel:setPaperSize(DMPAPER_A4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ nEsquerda, nSuperior, nDireita, nInferior 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oRel:setMargin(05,05,05,05)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ setup da impressora
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
nColIni := 065
If oRel:nPaperSize  == 9 // Papél A4
	nLinMax	:= 1754
	nColMax	:= 2335
	nLayout 	:= 2
Elseif oRel:nPaperSize == 1 // Papel Carta
	nLinMax	:= 1545
	nColMax	:= 2400
	nLayout 	:= 3
Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	nLinMax	:= 1764
	nColMax	:= 2400
	nLayout 	:= 1
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inicializa uma pagina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oRel:StartPage()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ insere logo no relatorio
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ			
//INI
aBMP	:= {"lgesq.bmp"}
aBMP2  := {"lgdir.bmp"}

If File("lgesq" + FWGrpCompany() + FWCodFil() + ".bmp")
	aBMP := { "lgesq" + FWGrpCompany() + FWCodFil() + ".bmp" }
ElseIf File("lgesq" + FWGrpCompany() + ".bmp")
	aBMP := { "lgesq" + FWGrpCompany() + ".bmp" }
EndIf

If File("lgdir" + FWGrpCompany() + FWCodFil() + ".bmp")
	aBMP2 := { "lgdir" + FWGrpCompany() + FWCodFil() + ".bmp" }
ElseIf File("lgdir" + FWGrpCompany() + ".bmp")
	aBMP2 := { "lgdir" + FWGrpCompany() + ".bmp" }
EndIf

If !Empty(aBMP[1])
	oRel:SayBitmap(10,10, aBMP[1],50,50) 		//-- Tem que estar abaixo do RootPath -- esta no SYSTEM
Endif

If !Empty(aBMP2[1])
	oRel:SayBitmap(10,530, aBMP2[1],50,50) 		//-- Tem que estar abaixo do RootPath
Endif
//FIM

nPixLin += 25

//======== VARIAVEIS DAS COLUNAS =======================
nColTot	:= 500
nCol1 := nPixCol - 15							
nCol2 := (nCol1 + (nColTot * 0.07))  
nCol3 := (nCol2 + (nColTot * 0.08))  
nCol4 := (nCol3 + (nColTot * 0.09))  
nCol5 := (nCol4 + (nColTot * 0.06))  
nCol6 := (nCol5 + (nColTot * 0.07))  
nCol7 := (nCol6 + (nColTot * 0.09)) 
nCol8 := (nCol7 + (nColTot * 0.25))
nCol9 := (nCol8 + (nColTot * 0.27))
nUsoc := (nCol8 + (nColTot * 0.30))
//======================================================

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Imprime cabeçalho
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oRel:say(nPixLin,nColTot*0.25,ALLTRIM(SM0->M0_NOMECOM),oFont16n)
nPixLin += 30

oRel:say(nPixLin,nPixCol,STR0001 + alltrim(SM0->M0_ENDCOB) + " - " + alltrim(SM0->M0_BAIRCOB) +", " +; 
		  alltrim(SM0->M0_CIDCOB) + " - " + alltrim(SM0->M0_ESTCOB) + STR0002 + alltrim(SM0->M0_CEPCOB),oFont12) //"Endereço: "##" - CEP: "

nPixLin += 15

oRel:say(nPixLin,nPixCol,STR0003 + alltrim(SM0->M0_TEL) +STR0004 + alltrim(SM0->M0_FAX),oFont12) //"Fone: " ## " / Fax: "

nPixLin += 20
		 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Imprime o Box principal
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oRel:Box(nPixLin,(nColIni + 0000)*nAC,820,(nColIni + nColMax)*nAC)

nPixLin += 15
oRel:say(nPixLin,nPixCol,STR0005,oFont16n)//"Solicitação de cadastro de medicamentos de uso constante"

nPixLin += 15
oRel:say(nPixLin,nPixCol,STR0006,oFont14n)//"Numero"
oRel:say(nPixLin,nColTot*0.65,STR0007, oFont14n)//"Data"

// Num. Protoc e data
nPixLin += 15
oRel:say(nPixLin,nPixCol,alltrim(B4F->B4F_CODREC),oFont12)
oRel:say(nPixLin,nColTot*0.65,DTOC(Date()),oFont12)

nPixLin += 30
oRel:say(nPixLin,nPixCol,STR0008,oFont14n) //"Solicitante - Matrícula"
oRel:say(nPixLin,nColTot*0.65,STR0009,oFont14n) //"Unid. Organ."
oRel:say(nPixLin,nColTot*0.90,STR0010,oFont14n) //"Telefone"

IF !EMPTY(BA1->(BA1_MATANT))
	cMatric:= BA1->BA1_MATANT
Else
	cMatric:= Transform(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),__cPictUsr)
Endif 

//nome e matricula do beneficiário
nPixLin += 15
oRel:say(nPixLin,nPixCol,Alltrim(BA1->BA1_NOMUSR) + " - " + cMatric,oFont12)





//unidade organizacional(setor de trabalho)
dbSetOrder(1)
BBZ->(dbSeek(xFilial("BBZ") + BA3->BA3_UNDORG))
oRel:say(nPixLin,nColTot*0.65, IIF( !EMPTY(BBZ->BBZ_SIGLA), alltrim(BBZ->BBZ_SIGLA),STR0011)) //"Sem Cadastro"

//telefone
oRel:say(nPixLin,nColTot*0.90,"(" + SUBSTR(BA1->BA1_TELEFO,1,2) + ") " + IIf(LEN(ALLTRIM(BA1->BA1_TELEFO)) > 10,Transform(SUBSTR(BA1->BA1_TELEFO,3),"@R 9-9999-9999"),;
		 																	   Transform(SUBSTR(BA1->BA1_TELEFO,3),"@R 9999-9999")),oFont12)

nPixLin += 30
oRel:say(nPixLin,nPixCol,STR0001,oFont14n)//"Endereço"


//rua, numero e bairro
nPixLin += 15
oRel:say(nPixLin,nPixCol,ALLTRIM(BA3->BA3_END) + ", " + ALLTRIM(BA3->BA3_NUMERO) + " - " + ALLTRIM(BA3->BA3_BAIRRO),oFont12)

//cidade, estado e CEP
nPixLin += 15
oRel:say(nPixLin,nPixCol,ALLTRIM(BA3->BA3_MUN) + " - " + ALLTRIM(BA3->BA3_ESTADO) + STR0012 + Transform(ALLTRIM(BA3->BA3_CEP),"@R 99999-999"),oFont12)// "  CEP: "

//linha divisoria
nPixLin += 15
oRel:Line( nPixLin, nPixCol-24, nPixLin, nPixCol+535)

nPixLin += 20
oRel:say(nPixLin,nPixCol,STR0013,oFont12n)//"Medicamentos solicitados"
nPixLin += 30

//retorna os medicamentos
B7D->(DbSetOrder(3))
B7D->(MsSeek(xFilial("B7D") + B4F->B4F_CODREC  ))
While !B7D->(Eof()) .AND. xFilial("B7D")+B7D->B7D_CODREC == xFilial("B7D")+B4F->B4F_CODREC
	
	//Descrição do medicamento
	BR8->(DbSetOrder(1))
    BR8->(MsSeek(xFilial("BR8")+B7D->B7D_CODPAD+B7D->B7D_CODMED ))
	
	AADD(aDados, {B7D->B7D_CODMED, BR8->BR8_DESCRI})

 	B7D->(dbSkip())
EndDo

nTotal := LEN(aDados)

If nTotal > 0
	oRel:say(nPixLin,nPixCol,STR0014,oFont14N)//"Cod.Medicamento"
    nPixCol := 160
	oRel:say(nPixLin,nPixCol,STR0015,oFont14N)//"Medicamento"
	nPixLin += 15 
Endif

nPixCol := 40

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Imprime os itens de acordo com a RDA
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
For nCnt := 1 to nTotal
	
		oRel:say(nPixLin,nPixCol ,aDados[nCnt,1],oFont14N)//+ 068
		oRel:say(nPixLin,nPixCol + 120,aDados[nCnt,2],oFont14N)
		nPixLin += 20			
		
		//Cria nova pagina
		If nPixLin >= nquantlin 
			
			PALSTRNewPg(nPixCol, cMsgEntga)
			nPixLin := 95
			nPixCol := 40
		EndIf
				
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Cria uma nova pagina  
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nPixLin >= nquantlin 

	PALSTRNewPg(nPixCol, cMsgEntga)
	nPixLin := 95
	nPixCol := 40
EndIf
				
oRel:EndPage()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Finaliza a pagina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                                                           

oRel:Preview()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

return cRelName+".pdf"/*,""*/



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³PALSTRNewPg  ³Autor  ³ Thiago Guilherme		       ³ Data ³08.08.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera nova pagina															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function PALSTRNewPg(nPixCol,cMsgEntga)
		
	    Default cMsgEntga := ""
	    
		oRel:Line(790, nPixCol-24, 790, nPixCol+535)
		oRel:say(810,40,cMsgEntga,TFont():New( "Arial",, 11,,.F.))
		
		oRel:StartPage()
		
		//insere logo na nova pagina
		aBMP	:= {"lgesq.bmp"}
		aBMP2  := {"lgdir.bmp"}
		
		If File("lgesq" + FWGrpCompany() + FWCodFil() + ".bmp")
			aBMP := { "lgesq" + FWGrpCompany() + FWCodFil() + ".bmp" }
		ElseIf File("lgesq" + FWGrpCompany() + ".bmp")
			aBMP := { "lgesq" + FWGrpCompany() + ".bmp" }
		EndIf
		
		If File("lgdir" + FWGrpCompany() + FWCodFil() + ".bmp")
			aBMP2 := { "lgdir" + FWGrpCompany() + FWCodFil() + ".bmp" }
		ElseIf File("lgdir" + FWGrpCompany() + ".bmp")
			aBMP2 := { "lgdir" + FWGrpCompany() + ".bmp" }
		EndIf
		
		If !Empty(aBMP[1])
			oRel:SayBitmap(10,10, aBMP[1],130,50) 		//-- Tem que estar abaixo do RootPath -- esta no SYSTEM
		Endif
		
		If !Empty(aBMP2[1])
			oRel:SayBitmap(10,450, aBMP2[1],130,50) 		//-- Tem que estar abaixo do RootPath
		Endif
		
		oRel:Box(80, 15.6, 820,576)
Return


